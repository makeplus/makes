# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Makes is a GNU Makefile framework that simplifies dependency management by automatically installing all dependencies locally within the project directory. It works on Linux and macOS (Intel and ARM) and provides modular `.mk` files for different languages and tools (Go, Rust, Python, Node, Java, Clojure, Crystal, etc.).

## Architecture

### Core Components

1. **init.mk** - Must be included first in any Makefile using Makes. Sets up:
   - Shell environment (forces bash)
   - Path variables (MAKES, MAKES-DIR, ROOT, MAKEFILE, MAKEFILE-DIR)
   - OS/architecture detection (OS-NAME, ARCH-NAME, OS-ARCH)
   - Local directory structure via local.mk

2. **local.mk** - Manages local installation directories. Creates and sets:
   - LOCAL-ROOT (from MAKES_LOCAL_DIR, or defaults to `.local` next to makes repo)
   - LOCAL-CACHE, LOCAL-TMP, LOCAL-BIN, LOCAL-LIB, LOCAL-INC, LOCAL-MAN, LOCAL-SHARE, LOCAL-HOME
   - Prepends LOCAL-BIN to PATH

3. **Language .mk files** (go.mk, rust.mk, python.mk, etc.) - Each follows the pattern:
   - Defines VERSION variable (e.g., GO-VERSION ?= 1.25.5)
   - Guards against double-loading with LOADED flag
   - Requires init.mk to be loaded first
   - Calls `$(eval $(call include-local))` to ensure local.mk is loaded
   - Sets up OS/ARCH-specific download URLs (OA-linux-arm64, OA-macos-int64, etc.)
   - Defines install targets that download to LOCAL-CACHE and extract to LOCAL-ROOT
   - Modifies PATH to include tool binaries
   - Adds dependencies to SHELL-DEPS for shell.mk

4. **shell.mk** - Provides shell targets (bash, zsh) with Makes tools in PATH. Should be included last.

5. **makefile.mk** - Standalone entry point for running Makes shells from anywhere. Automatically clones/updates the makes repo to `~/.makes/makes` (or `$MAKES_REPO_DIR`) and starts a shell with requested tools:
   ```bash
   make -f <(curl -sL https://github.com/makeplus/makes/raw/main/makefile.mk) shell WITH="tool1 tool2"
   ```
   Can also override versions: `make -f ... shell WITH="go" GO-VERSION=1.23.4`

### Installation Flow

When a tool is needed:
1. Makefile includes the tool's `.mk` file
2. The `.mk` file defines a target for the tool binary (e.g., `$(GO)`)
3. Target checks if binary exists in LOCAL-BIN
4. If not, downloads archive to LOCAL-CACHE using `bin/curl+`
5. `bin/curl+` checks `~/.cache/makes/` (or `$MAKES_CACHE_DIR`) for cached downloads to avoid re-downloading
6. Extracts to LOCAL-ROOT with version in directory name (e.g., `go-1.25.5/`)
7. Updates PATH to include tool's bin directory

### Caching Mechanism

- Create `~/.cache/makes/` directory to enable global caching of downloaded archives
- Set `MAKES_CACHE_DIR` environment variable to use a custom cache location
- `bin/curl+` converts URLs to filenames by replacing `/` with `__` (e.g., `go.dev__dl__go1.25.5.linux-amd64.tar.gz`)
- Cached files are reused across all projects, saving bandwidth and time

### Key Variables

- `MAKES` - Absolute path to the makes repository directory
- `LOCAL-ROOT` - Where all tools are installed (default: `.local` next to makes)
- `MAKES_LOCAL_DIR` / `MAKES-LOCAL-DIR` - User-override for LOCAL-ROOT location
- `MAKES_REPO_DIR` - User-override for makes repository location
- `MAKES_CACHE_DIR` - Custom cache directory for downloads (defaults to `~/.cache/makes/` if exists)
- `MAKES-INCLUDE` - List of .mk files to include (used by makefile.mk with WITH variable)
- `MAKES_SHELL` - Set to 1 when inside a Makes shell (prevents nested shells)
- `OS-NAME` - Detected OS: `linux` or `macos`
- `ARCH-NAME` - Detected architecture: `arm64` or `int64`
- `OS-ARCH` - Combined OS and architecture (e.g., `linux-arm64`)

## Common Development Tasks

### Testing a Specific Tool

Start a shell with a specific tool installed:

```bash
make <tool>-shell
```

For example: `make crystal-shell` starts a shell with Crystal installed. This uses makefile.mk internally to create a temporary environment.

### Running Makes Shells with Custom Tools

Use the `shell` target with the `WITH` variable to specify tools:

```bash
make shell WITH="go rust python"
```

This starts a shell with Go, Rust, and Python installed. You can also override versions:

```bash
make shell WITH="go" GO-VERSION=1.23.4
```

### Version Management

Check for new versions of all supported tools:

```bash
make version-check
```

This runs `bin/check-versions`, a YAMLScript program that:
- Parses each `.mk` file for VERSION and GitHub URL
- Queries GitHub tags for latest versions
- Reports which tools have updates available

### Cleaning Local Installations

```bash
make clean
```

Removes the `local/` directory with all installed tools.

### Adding a New Language/Tool

1. Create `<tool>.mk` following the established pattern
2. Add VERSION variable with GitHub reference comment (e.g., `# https://github.com/org/repo`)
3. Add double-loading guard: `ifndef TOOL-LOADED` / `TOOL-LOADED := true` / `endif`
4. Require init.mk: `$(if $(MAKES),,$(error Please 'include init.mk' first))`
5. Include local.mk: `$(eval $(call include-local))`
6. Set up OS/ARCH mappings (OA-linux-arm64, OA-linux-int64, OA-macos-arm64, OA-macos-int64)
7. Define download URL, local paths, and install target
8. Add tool binary to PATH: `override PATH := $(TOOL-BIN):$(PATH)`
9. Add to SHELL-DEPS: `SHELL-DEPS += $(TOOL)`
10. Update GNUmakefile TARGETS filter if the tool should be excluded from automatic shell targets

### Repository Maintenance

- `bin/check-versions` - YAMLScript script to check for version updates
- `bin/curl+` - Wrapper around curl for downloading with caching support (uses `~/.cache/makes/` if available, or `MAKES_CACHE_DIR`)
- `bin/make-help` - Perl script that generates help text from Makefile comments
- `share/Makefile` - Template for new projects using Makes

## Important Implementation Patterns

### Double-Loading Prevention

Each `.mk` file uses a guard pattern to prevent double-loading:
```make
ifndef TOOL-LOADED
TOOL-LOADED := true
# ... rest of file
endif
```

### OS/Architecture Mappings

Tools define OS/ARCH-specific download URLs using the `OA-` prefix pattern:
```make
OA-linux-arm64 := linux-arm64
OA-linux-int64 := linux-amd64
OA-macos-arm64 := darwin-arm64
OA-macos-int64 := darwin-amd64
```

Then construct download URLs using: `$(OA-$(OS-ARCH))`

### Version Detection Pattern

The `bin/check-versions` script expects this exact format in `.mk` files:
```make
TOOL-VERSION ?= 1.2.3
# https://github.com/org/repo
```

The version line must be followed by a GitHub URL comment for automatic version checking to work.

### Tool Installation Targets

Tool binaries are installed as Make targets (e.g., `$(GO)`, `$(CARGO)`). The pattern is:
1. Define variable pointing to binary: `GO := $(GO-LOCAL-BIN)/go`
2. Create target that depends on downloaded archive
3. Extract and install to versioned directory
4. Add binary to SHELL-DEPS for shell.mk

### PATH Management

Always use `override PATH :=` when modifying PATH to ensure it takes precedence:
```make
override PATH := $(TOOL-BIN):$(PATH)
```

## File Naming Conventions

- `*.mk` - Makefile modules for specific languages/tools
- `init.mk`, `local.mk`, `shell.mk`, `help.mk`, `clean.mk` - Core infrastructure
- `makefile.mk` - Special standalone entry point
- Files in `local/` - Installed tools (versioned directories)
