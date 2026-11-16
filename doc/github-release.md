# GitHub release binaries

Include `github-release.mk` after `init.mk` to discover and install public
GitHub release binaries without a repository-specific module.
The module uses a Makes-managed Python runtime and its standard library.

Pass parameters as environment variables:

- `GITHUB_RELEASE_REPO`: GitHub `owner/repo`.
- `GITHUB_RELEASE_TAG`: optional exact tag; otherwise latest stable release.
- `GITHUB_RELEASE_ASSET`: optional exact asset filename.
- `GITHUB_RELEASE_MANIFEST`: path for the resolved release JSON.
- `GITHUB_RELEASE_DEST`: destination for the extracted installation.

Run `github-release-resolve` first.
It writes the manifest and a companion `<manifest>.tag` file.
Ambiguous platform matches prompt on `/dev/tty`; unattended callers must supply
an exact asset name.
Run `github-release-install` to download, verify an available SHA-256 digest,
and extract into a staged directory before publishing the destination.

The destination contains `payload/`, `.github-release.json`, and
`.github-release-commands` (command name and relative path, separated by a tab).
All compatible native command binaries are recorded; callers decide how to
expose them on PATH.
A matching existing installation is reused.
Different or incomplete contents at the destination cause an error.

Supported hosts are Linux and macOS on x86-64 and ARM64.
Supported assets are tar/ZIP archives, raw native executables, and gzip/xz
compressed executables.
Unsafe archive paths and links, duplicate command names, and payloads with no
compatible native commands are rejected.
Scripts, package installers, and universal macOS executables are excluded.

Tests: run `test/github-release.py` with the managed Python runtime.
