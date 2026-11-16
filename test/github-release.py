"""Release discovery and extraction tests, without network access."""
import gzip
import hashlib
import importlib.util
import io
import json
import os
import pty
import select
import time
from pathlib import Path
import shutil
import struct
import tarfile
import tempfile
import unittest
from unittest.mock import patch
import zipfile

path = Path(__file__).resolve().parents[1] / 'util/github-release.py'
spec = importlib.util.spec_from_file_location('github_release', path)
release = importlib.util.module_from_spec(spec)
spec.loader.exec_module(release)


def tar_bytes(entries):
    buffer = io.BytesIO()
    with tarfile.open(fileobj=buffer, mode='w:gz') as archive:
        for name, data, kind in entries:
            member = tarfile.TarInfo(name)
            member.mode = 0o755
            if kind == 'link':
                member.type = tarfile.SYMTYPE
                member.linkname = data
                archive.addfile(member)
            elif kind == 'device':
                member.type = tarfile.CHRTYPE
                archive.addfile(member)
            else:
                member.size = len(data)
                archive.addfile(member, io.BytesIO(data))
    return buffer.getvalue()


class ReleaseTests(unittest.TestCase):
    def assets(self, *names):
        return [{'name': name} for name in names]

    def test_platforms(self):
        for project in ('fzf', 'bat', 'fd', 'lazygit', 'starship'):
            assets = self.assets(*(f'{project}-{suffix}.tar.gz' for suffix in (
                'linux_amd64', 'aarch64-unknown-linux-musl',
                'x86_64-apple-darwin', 'darwin_arm64')))
            for system, machine, expected in [
                ('linux', 'x86_64', 0), ('linux', 'aarch64', 1),
                ('darwin', 'x86_64', 2), ('darwin', 'arm64', 3),
            ]:
                with self.subTest(project=project, system=system, machine=machine):
                    self.assertEqual(release.candidates(assets, system, machine),
                                     [assets[expected]])

    def test_portable_linux(self):
        assets = self.assets('bat-x86_64-unknown-linux-gnu.tar.gz',
                             'bat-x86_64-unknown-linux-musl.tar.gz')
        self.assertEqual(release.candidates(assets, 'linux', 'x86_64'),
                         [assets[1]])

    def test_exclusions(self):
        assets = self.assets('linux-amd64.sha256', 'linux-amd64.deb',
                             'linux-amd64-source.tar.gz',
                             'linux-amd64-avx2.tar.gz', 'linux-x64ish.tar.gz',
                             'linux-x86_64_v3.tar.gz')
        self.assertEqual(release.candidates(assets, 'linux', 'x86_64'), [])

    def test_unsupported_platform(self):
        with self.assertRaisesRegex(ValueError, 'Unsupported platform'):
            release.candidates([], 'windows', 'x86_64')

    def test_exact_asset(self):
        assets = self.assets('first.zip', 'second.zip')
        with patch.object(release, 'request_release', return_value={
            'tag_name': 'v1.0', 'assets': assets,
        }) as request:
            result = release.resolve('Owner/Repo', 'v1.0', 'second.zip')
        request.assert_called_once_with('Owner/Repo', 'v1.0')
        self.assertEqual(result['repository'], 'owner/repo')
        self.assertEqual(result['asset'], assets[1])

    def test_no_match(self):
        with patch.object(release, 'request_release', return_value={
            'tag_name': 'v1', 'assets': [],
        }), self.assertRaisesRegex(ValueError, 'No compatible'):
            release.resolve('owner/repo')

    def test_ambiguity_without_terminal(self):
        with patch.object(release, 'request_release', return_value={
            'tag_name': 'v1', 'assets': [],
        }), patch.object(release, 'candidates', return_value=self.assets('a', 'b')):
            with patch('builtins.open', side_effect=OSError('No terminal')):
                with self.assertRaisesRegex(ValueError, '--asset NAME'):
                    release.resolve('owner/repo')

    def test_interactive_selection(self):
        class Terminal(io.StringIO):
            def readline(self):
                return '2\n'
        with patch.object(release, 'request_release', return_value={
            'tag_name': 'v1', 'assets': [],
        }), patch.object(release, 'candidates', return_value=self.assets('a', 'b')):
            with patch('builtins.open', return_value=Terminal()):
                self.assertEqual(release.resolve('owner/repo')['asset']['name'], 'b')

    def test_real_terminal_selection(self):
        try:
            pid, fd = pty.fork()
        except OSError as error:
            self.skipTest(f'PTY allocation unavailable: {error}')
        if pid == 0:
            try:
                with patch.object(release, 'request_release', return_value={
                    'tag_name': 'v1', 'assets': [],
                }), patch.object(release, 'candidates', side_effect=[
                    [], self.assets('first', 'second'),
                ]):
                    result = release.resolve('owner/repo')
                os.write(1, ('SELECTED:' + result['asset']['name']).encode())
                os._exit(0)
            except BaseException as error:
                os.write(2, str(error).encode())
                os._exit(1)
        output = b''
        sent = False
        deadline = time.monotonic() + 5
        try:
            while time.monotonic() < deadline:
                ready, _, _ = select.select([fd], [], [], 0.1)
                if not ready:
                    continue
                try:
                    chunk = os.read(fd, 4096)
                except OSError:
                    break
                if not chunk:
                    break
                output += chunk
                if b'Choose asset' in output and not sent:
                    os.write(fd, b'2\n')
                    sent = True
            self.assertIn(b'SELECTED:second', output)
        finally:
            os.close(fd)
            try:
                os.kill(pid, 9)
            except ProcessLookupError:
                pass
            os.waitpid(pid, 0)

    def test_invalid_selector(self):
        for repo, tag in [('a/../b', None), ('-a/b', None), ('a/b', '../bad')]:
            with self.assertRaises(ValueError):
                release.request_release(repo, tag)

    def test_native_headers(self):
        with tempfile.TemporaryDirectory() as tmp:
            file = Path(tmp) / 'bin'
            header = bytearray(64)
            header[:6] = b'\x7fELF\x02\x01'
            struct.pack_into('<HH', header, 16, 2, 62)
            file.write_bytes(header)
            self.assertTrue(release.native_program(file, 'linux', 'x86_64'))
            self.assertFalse(release.native_program(file, 'linux', 'arm64'))
            struct.pack_into('<HH', header, 16, 3, 62)
            file.write_bytes(header)
            self.assertFalse(release.native_program(file, 'linux', 'x86_64'))
            header[:4] = b'\xcf\xfa\xed\xfe'
            struct.pack_into('<III', header, 4, 0x0100000c, 0, 2)
            file.write_bytes(header)
            self.assertTrue(release.native_program(file, 'darwin', 'arm64'))
            self.assertFalse(release.native_program(file, 'darwin', 'x86_64'))

    def test_archive_rejections(self):
        for entries in [
            [('../escape', b'x', 'file')],
            [('/absolute', b'x', 'file')],
            [('link', '../../escape', 'link')],
            [('link', 'inside', 'link'), ('link/file', b'x', 'file')],
            [('same', b'x', 'file'), ('same', b'y', 'file')],
            [('device', b'', 'device')],
        ]:
            with self.subTest(entries=entries), tempfile.TemporaryDirectory() as tmp:
                root = Path(tmp)
                archive = root / 'archive'
                archive.write_bytes(tar_bytes(entries))
                dest = root / 'dest'
                dest.mkdir()
                with self.assertRaises(ValueError):
                    release.extract(archive, dest)
                self.assertEqual(list(dest.iterdir()), [])

    def test_zip_and_internal_link(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            archive = root / 'archive'
            with zipfile.ZipFile(archive, 'w') as source:
                source.writestr('pkg/data', b'hello')
            dest = root / 'dest'
            dest.mkdir()
            self.assertTrue(release.extract(archive, dest))
            self.assertEqual((dest / 'pkg/data').read_bytes(), b'hello')
            archive.write_bytes(tar_bytes([
                ('pkg/bin', b'binary', 'file'), ('pkg/alias', 'bin', 'link'),
            ]))
            release.extract(archive, dest)
            self.assertEqual((dest / 'pkg/alias').read_bytes(), b'binary')

    def test_install_and_retry(self):
        binary = Path(shutil.which('true')).read_bytes()
        content = tar_bytes([('pkg/bin/tool', binary, 'file'),
                             ('pkg/bin/other', binary, 'file'),
                             ('pkg/data/config', b'data', 'file')])
        metadata = {'repository': 'owner/tool', 'tag': 'v1', 'asset': {
            'name': 'tool.tar.gz', 'browser_download_url':
            'https://github.com/owner/tool/releases/download/v1/tool.tar.gz',
            'digest': 'sha256:' + hashlib.sha256(content).hexdigest(),
        }}
        with tempfile.TemporaryDirectory() as tmp:
            destination = Path(tmp) / 'install'
            with patch.object(release.urllib.request, 'urlopen', return_value=io.BytesIO(content)):
                release.install(metadata, destination)
            manifest = json.loads((destination / '.github-release.json').read_text())
            self.assertEqual(sorted(manifest['commands']), ['other', 'tool'])
            self.assertEqual((destination / 'payload/pkg/data/config').read_bytes(), b'data')
            metadata['asset']['download_count'] = 100
            with patch.object(release.urllib.request, 'urlopen', side_effect=AssertionError):
                release.install(metadata, destination)

    def test_failed_install_leaves_no_destination(self):
        metadata = {'repository': 'owner/tool', 'tag': 'v1', 'asset': {
            'name': 'tool', 'browser_download_url':
            'https://github.com/owner/tool/releases/download/v1/tool',
            'digest': 'sha256:' + '0' * 64,
        }}
        with tempfile.TemporaryDirectory() as tmp:
            destination = Path(tmp) / 'install'
            with patch.object(release.urllib.request, 'urlopen', return_value=io.BytesIO(b'bad')):
                with self.assertRaisesRegex(ValueError, 'SHA-256 mismatch'):
                    release.install(metadata, destination)
            self.assertFalse(destination.exists())
            self.assertEqual(list(Path(tmp).iterdir()), [])

    def test_payload_rejections(self):
        binary = Path(shutil.which('true')).read_bytes()
        for entries, expected in [
            ([('README', b'just documentation', 'file')], 'no compatible'),
            ([('a/tool', binary, 'file'), ('b/tool', binary, 'file')],
             'Duplicate command basename'),
        ]:
            content = tar_bytes(entries)
            metadata = {'repository': 'owner/tool', 'tag': 'v1', 'asset': {
                'name': 'tool.tar.gz', 'browser_download_url':
                'https://github.com/owner/tool/releases/download/v1/tool.tar.gz',
            }}
            with self.subTest(expected=expected), tempfile.TemporaryDirectory() as tmp:
                destination = Path(tmp) / 'install'
                with patch.object(release.urllib.request, 'urlopen', return_value=io.BytesIO(content)):
                    with self.assertRaisesRegex(ValueError, expected):
                        release.install(metadata, destination)
                self.assertFalse(destination.exists())

    def test_api_errors_and_exact_prerelease(self):
        error = release.urllib.error.HTTPError('url', 403, 'rate limited', {}, None)
        with patch.object(release.urllib.request, 'urlopen', side_effect=error):
            with self.assertRaisesRegex(ValueError, 'API rate limit'):
                release.request_release('owner/tool')
        response = io.BytesIO(json.dumps({
            'tag_name': 'v2-beta.1', 'prerelease': True, 'assets': [],
        }).encode())
        with patch.object(release.urllib.request, 'urlopen', return_value=response) as request:
            result = release.request_release('owner/tool', 'v2-beta.1')
        self.assertTrue(result['prerelease'])
        self.assertTrue(request.call_args.args[0].full_url.endswith('/tags/v2-beta.1'))

    def test_interrupted_download(self):
        class BrokenDownload(io.BytesIO):
            def read(self, size=-1):
                raise OSError('Connection interrupted')
        metadata = {'repository': 'owner/tool', 'tag': 'v1', 'asset': {
            'name': 'tool', 'browser_download_url':
            'https://github.com/owner/tool/releases/download/v1/tool',
        }}
        with tempfile.TemporaryDirectory() as tmp:
            destination = Path(tmp) / 'install'
            with patch.object(release.urllib.request, 'urlopen', return_value=BrokenDownload()):
                with self.assertRaisesRegex(OSError, 'interrupted'):
                    release.install(metadata, destination)
            self.assertEqual(list(Path(tmp).iterdir()), [])

    def test_zip_traversal(self):
        with tempfile.TemporaryDirectory() as tmp:
            archive = Path(tmp) / 'archive'
            destination = Path(tmp) / 'dest'
            destination.mkdir()
            with zipfile.ZipFile(archive, 'w') as source:
                source.writestr('../escape', b'bad')
            with self.assertRaisesRegex(ValueError, 'Unsafe archive path'):
                release.extract(archive, destination)
            self.assertFalse((Path(tmp) / 'escape').exists())

    def test_compressed_standalone(self):
        content = gzip.compress(Path(shutil.which('true')).read_bytes())
        metadata = {'repository': 'owner/tool', 'tag': 'v1', 'asset': {
            'name': 'tool.gz', 'browser_download_url':
            'https://github.com/owner/tool/releases/download/v1/tool.gz',
        }}
        with tempfile.TemporaryDirectory() as tmp:
            destination = Path(tmp) / 'install'
            with patch.object(release.urllib.request, 'urlopen', return_value=io.BytesIO(content)):
                release.install(metadata, destination)
            self.assertTrue((destination / 'payload/tool').is_file())


if __name__ == '__main__':
    unittest.main()
