"""Discover and unpack public GitHub release binaries for Makes."""
import argparse
import gzip
import hashlib
import json
import lzma
import os
from pathlib import Path, PurePosixPath
import platform
import posixpath
import re
import shutil
import stat
import struct
import tarfile
import tempfile
import urllib.error
import urllib.parse
import urllib.request
import zipfile


SAFE_VERSION = r'[A-Za-z0-9][A-Za-z0-9.+_-]*'
SAFE_COMMAND = r'[A-Za-z0-9][A-Za-z0-9._-]*'


def request_release(repo, tag=None):
    if not re.fullmatch(r'[A-Za-z0-9][A-Za-z0-9-]*/[A-Za-z0-9][A-Za-z0-9_.-]*', repo):
        raise ValueError('Expected a GitHub owner/repo')
    if tag and not re.fullmatch(SAFE_VERSION, tag):
        raise ValueError('Unsupported release tag')
    endpoint = 'tags/' + urllib.parse.quote(tag, safe='') if tag else 'latest'
    url = f'https://api.github.com/repos/{repo}/releases/{endpoint}'
    request = urllib.request.Request(url, headers={
        'Accept': 'application/vnd.github+json',
        'User-Agent': 'makes-github-release',
    })
    try:
        with urllib.request.urlopen(request, timeout=30) as response:
            release = json.load(response)
    except urllib.error.HTTPError as error:
        error.close()
        raise ValueError(f'GitHub returned HTTP {error.code} for {repo}; '
                         'check the repository, release tag, or API rate limit') from error
    if release.get('draft'):
        raise ValueError('Draft releases are unsupported')
    if not re.fullmatch(SAFE_VERSION, release.get('tag_name', '')):
        raise ValueError('Unsupported release tag in GitHub response')
    return release


def token(name, aliases):
    return any(re.search(r'(?<![a-z0-9])' + re.escape(alias) +
                         r'(?![a-z0-9])', name) for alias in aliases)


def candidates(assets, system, machine):
    os_names = {'linux': ('linux',), 'darwin': ('darwin', 'macos', 'osx')}
    arch_names = {
        'x86_64': ('x86_64', 'amd64', 'x64'),
        'aarch64': ('aarch64', 'arm64'),
        'arm64': ('aarch64', 'arm64'),
    }
    if system not in os_names or machine not in arch_names:
        raise ValueError(f'Unsupported platform: {system}/{machine}')
    matches = []
    for asset in assets:
        name = asset['name'].lower()
        if re.search(r'(checksum|sha256|sha512|signature|source|\.sig$|\.asc$)', name):
            continue
        if re.search(r'\.(deb|rpm|msi|exe|dmg|pkg|apk|appimage)$', name):
            continue
        if not token(name, os_names[system]):
            continue
        if not token(name, arch_names[machine]):
            continue
        if re.search(r'(avx|x86[_-]64[_-]v[234])', name):
            continue
        matches.append(asset)
    if system == 'linux':
        portable = [a for a in matches if token(a['name'].lower(), ('musl',))]
        if portable:
            matches = portable
    return sorted(matches, key=lambda a: a['name'])


def resolve(repo, tag=None, asset_name=None):
    release = request_release(repo, tag)
    assets = release.get('assets', [])
    candidates([], platform.system().lower(), platform.machine())
    if asset_name:
        matches = [a for a in assets if a['name'] == asset_name]
    else:
        matches = candidates(assets, platform.system().lower(), platform.machine())
    if not matches:
        raise ValueError('No compatible release asset found')
    if len(matches) > 1:
        choices = '\n'.join(f'{i + 1}: {a["name"]}' for i, a in enumerate(matches))
        try:
            with open('/dev/tty', 'r') as reader, open('/dev/tty', 'w') as writer:
                writer.write(choices + '\nChoose asset (empty to cancel): ')
                writer.flush()
                selection = reader.readline().strip()
            if not selection:
                raise ValueError('Asset selection cancelled')
            index = int(selection) - 1
            if not 0 <= index < len(matches):
                raise ValueError('Invalid asset selection')
            matches = [matches[index]]
        except OSError as error:
            raise ValueError('Ambiguous assets; use --asset NAME:\n' + choices) from error
    return {'repository': repo.lower(), 'tag': release['tag_name'],
            'asset': matches[0]}


def safe_path(name):
    path = PurePosixPath(name)
    if (path.is_absolute() or '..' in path.parts or '\\' in name or
            any(ord(c) < 32 or ord(c) == 127 for c in name)):
        raise ValueError(f'Unsafe archive path: {name!r}')
    return path


def link_path(name, link, kind):
    if (link.startswith('/') or '\\' in link or
            any(ord(c) < 32 or ord(c) == 127 for c in link)):
        raise ValueError(f'Unsafe archive link: {link!r}')
    base = posixpath.dirname(name) if kind == 'link' else ''
    return safe_path(posixpath.normpath(posixpath.join(base, link)))


def extract(archive, destination):
    """Validate the complete archive before writing, including link parents."""
    entries = []
    if zipfile.is_zipfile(archive):
        source = zipfile.ZipFile(archive)
        for member in source.infolist():
            mode = member.external_attr >> 16
            kind = 'dir' if member.is_dir() else 'file'
            link = None
            if stat.S_ISLNK(mode):
                kind = 'link'
                link = source.read(member).decode('utf-8')
            elif stat.S_IFMT(mode) not in (0, stat.S_IFREG, stat.S_IFDIR):
                source.close()
                raise ValueError('Unsupported special archive member')
            entries.append((member.filename, kind, mode, link, member))
    elif tarfile.is_tarfile(archive):
        source = tarfile.open(archive)
        for member in source.getmembers():
            if member.isdir():
                kind = 'dir'
            elif member.isfile():
                kind = 'file'
            elif member.issym():
                kind = 'link'
            elif member.islnk():
                kind = 'hardlink'
            else:
                source.close()
                raise ValueError('Unsupported special archive member')
            entries.append((member.name, kind, member.mode, member.linkname, member))
    else:
        return False
    with source:
        paths = {}
        for name, kind, mode, link, member in entries:
            path = safe_path(name)
            if str(path) == '.':
                if kind != 'dir':
                    raise ValueError('Invalid archive root')
                continue
            if path in paths and not (kind == paths[path] == 'dir'):
                raise ValueError(f'Duplicate archive member: {name}')
            paths[path] = kind
            if kind in ('link', 'hardlink'):
                link_path(name, link, kind)
        for path in paths:
            for parent in path.parents:
                if parent in paths and paths[parent] != 'dir':
                    raise ValueError(f'Archive member beneath a non-directory: {path}')
        for name, kind, mode, link, member in entries:
            target = destination / safe_path(name)
            if kind in ('link', 'hardlink'):
                continue
            if kind == 'dir':
                target.mkdir(parents=True, exist_ok=True)
            else:
                target.parent.mkdir(parents=True, exist_ok=True)
                stream = (source.open(member) if isinstance(source, zipfile.ZipFile)
                          else source.extractfile(member))
                with stream, target.open('wb') as output:
                    shutil.copyfileobj(stream, output)
                target.chmod(0o755 if mode & 0o111 else 0o644)
        for name, kind, mode, link, member in entries:
            target = destination / safe_path(name)
            if kind not in ('link', 'hardlink'):
                continue
            linked = destination / link_path(name, link, kind)
            # Reject chained and dangling links; no extraction can escape root.
            if linked.is_symlink() or not linked.is_file():
                raise ValueError(f'Invalid archive link: {name}')
            target.parent.mkdir(parents=True, exist_ok=True)
            if kind == 'link':
                target.symlink_to(link)
            else:
                os.link(linked, target)
    return True


def native_program(path, system=None, machine=None):
    system = system or platform.system().lower()
    machine = machine or platform.machine()
    with path.open('rb') as stream:
        header = stream.read(64)
        if len(header) < 64:
            return False
        if header[:4] == b'\x7fELF' and system == 'linux':
            if header[4:6] != b'\x02\x01':
                return False
            kind, cpu = struct.unpack_from('<HH', header, 16)
            expected = 62 if machine == 'x86_64' else 183
            if cpu != expected or kind not in (2, 3):
                return False
            if kind == 2:
                return True
            # PIE programs have an interpreter or the DF_1_PIE dynamic flag.
            offset = struct.unpack_from('<Q', header, 32)[0]
            size, count = struct.unpack_from('<HH', header, 54)
            if size < 56 or count > 4096:
                return False
            for i in range(count):
                stream.seek(offset + size * i)
                ph = stream.read(56)
                if len(ph) < 56:
                    return False
                ptype = struct.unpack_from('<I', ph)[0]
                if ptype == 3:
                    return True
                if ptype == 2:
                    start = struct.unpack_from('<Q', ph, 8)[0]
                    length = struct.unpack_from('<Q', ph, 32)[0]
                    stream.seek(start)
                    for _ in range(min(length // 16, 65536)):
                        entry = stream.read(16)
                        if len(entry) != 16:
                            break
                        tag, value = struct.unpack('<QQ', entry)
                        if tag == 0:
                            break
                        if tag == 0x6ffffffb and value & 0x08000000:
                            return True
            return False
        if system == 'darwin' and header[:4] == b'\xcf\xfa\xed\xfe':
            cpu, _, kind = struct.unpack_from('<III', header, 4)
            expected = 0x01000007 if machine == 'x86_64' else 0x0100000c
            return cpu == expected and kind == 2
    return False


def install(metadata, destination):
    destination = Path(destination)
    if not re.fullmatch(SAFE_VERSION, metadata['tag']):
        raise ValueError('Unsupported release tag')
    old_manifest = destination / '.github-release.json'
    if destination.is_symlink():
        raise ValueError("Refusing a linked installation destination")
    if destination.exists():
        if old_manifest.is_file():
            old = json.loads(old_manifest.read_text())
            identity = ('id', 'name', 'browser_download_url', 'digest', 'size', 'updated_at')
            same_asset = all(old.get('asset', {}).get(k) == metadata['asset'].get(k)
                             for k in identity)
            if same_asset and all(old.get(k) == metadata.get(k)
                                  for k in ('repository', 'tag')):
                commands = old.get('commands', {})
                if (commands and (destination / '.github-release-commands').is_file()
                        and all((destination / p).is_file() for p in commands.values())):
                    return
        raise ValueError('Destination already exists with different or incomplete '
                         'contents; uninstall that version before replacing it')
    destination.parent.mkdir(parents=True, exist_ok=True)
    with tempfile.TemporaryDirectory(prefix='.github-release-',
                                     dir=destination.parent) as temporary:
        stage = Path(temporary)
        archive = stage / 'download'
        asset = metadata['asset']
        url = asset['browser_download_url']
        if not url.startswith('https://github.com/'):
            raise ValueError('Expected an HTTPS GitHub release download URL')
        digest = hashlib.sha256()
        request = urllib.request.Request(url, headers={'User-Agent': 'makes-github-release'})
        with urllib.request.urlopen(request, timeout=60) as response, archive.open('wb') as output:
            while chunk := response.read(1024 * 1024):
                output.write(chunk)
                digest.update(chunk)
        expected = asset.get('digest')
        if expected and expected.startswith('sha256:'):
            if digest.hexdigest() != expected[7:]:
                raise ValueError('Release asset SHA-256 mismatch')
        payload = stage / 'payload'
        payload.mkdir()
        if not extract(archive, payload):
            name = metadata['repository'].split('/')[1]
            target = payload / name
            suffix = asset['name'].lower()
            opener = gzip.open if suffix.endswith('.gz') else (
                lzma.open if suffix.endswith('.xz') else open)
            with opener(archive, 'rb') as source, target.open('wb') as output:
                shutil.copyfileobj(source, output)
        commands = {}
        for path in sorted(payload.rglob('*')):
            if not path.is_file():
                continue
            if not re.fullmatch(SAFE_COMMAND, path.name):
                continue
            if not native_program(path):
                continue
            if path.name in commands:
                raise ValueError(f'Duplicate command basename: {path.name}')
            path.chmod(0o755)
            commands[path.name] = str(Path('payload') / path.relative_to(payload))
        if not commands:
            raise ValueError('Asset contains no compatible native command binaries')
        tree = stage / 'install'
        tree.mkdir()
        payload.rename(tree / 'payload')
        manifest = dict(metadata, commands=commands)
        (tree / '.github-release.json').write_text(json.dumps(manifest, indent=2) + '\n')
        (tree / '.github-release-commands').write_text(''.join(
            f'{name}\t{path}\n' for name, path in commands.items()))
        tree.rename(destination)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('operation', choices=('resolve', 'install'))
    args = parser.parse_args()
    try:
        manifest = Path(os.environ['GITHUB_RELEASE_MANIFEST'])
        if args.operation == 'resolve':
            metadata = resolve(os.environ['GITHUB_RELEASE_REPO'],
                               os.environ.get('GITHUB_RELEASE_TAG') or None,
                               os.environ.get('GITHUB_RELEASE_ASSET') or None)
            manifest.write_text(json.dumps(metadata) + '\n')
            Path(str(manifest) + '.tag').write_text(metadata['tag'] + '\n')
        else:
            install(json.loads(manifest.read_text()),
                    os.environ['GITHUB_RELEASE_DEST'])
    except (ValueError, OSError, KeyError, tarfile.TarError, zipfile.BadZipFile) as error:
        parser.exit(1, f'github-release: {error}\n')


if __name__ == '__main__':
    main()
