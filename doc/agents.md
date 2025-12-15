# agents.mk - AI Coding Agent Configuration Generator

The `agents.mk` module generates agent-specific configuration files from a single source, supporting multiple AI coding assistants (Claude Code, Cursor, GitHub Copilot, Google Gemini) with a unified workflow.

## Table of Contents

- [Overview](#overview)
- [Why This Exists](#why-this-exists)
- [Quick Start](#quick-start)
- [Configuration](#configuration)
- [Source Directory Structure](#source-directory-structure)
- [Templating System](#templating-system)
- [Generated Files](#generated-files)
- [Targets](#targets)
- [Examples](#examples)
- [Troubleshooting](#troubleshooting)
- [Background Research](#background-research)

## Overview

AI coding assistants read project-specific instruction files to understand your codebase. Each tool historically used different file names and locations:

- **Claude Code** → `CLAUDE.md`
- **GitHub Copilot** → `AGENTS.md` or `.github/copilot-instructions.md`
- **Cursor** → `.cursorrules` or `.cursor/rules/*.mdc`
- **Google Gemini** → `GEMINI.md`

The `agents.mk` module lets you maintain a **single source** (`.ai-agents/agents.md`) and automatically generate all required files.

## Why This Exists

### The Problem

1. **File proliferation** - Maintaining separate `CLAUDE.md`, `GEMINI.md`, `.cursorrules` with duplicate content
2. **Symlink issues** - Claude Code has multiple bugs with symlinked config files
3. **Format differences** - Cursor's modern `.mdc` format requires YAML frontmatter
4. **Monorepo complexity** - Sharing common instructions across packages

### The Solution

- **Single source of truth** - Maintain instructions in `.ai-agents/agents.md`
- **Optional overrides** - Customize per-agent when needed
- **Template includes** - Share common sections across files
- **No symlinks** - Files are copied/generated (works around Claude Code bugs)
- **Hierarchical includes** - Share content across monorepo packages

## Quick Start

### 1. Include the Module

In your project's `Makefile`:

```makefile
include path/to/makes/init.mk
include path/to/makes/agents.mk
```

### 2. Create Source Directory

```bash
mkdir .ai-agents
```

### 3. Create Main Instructions

```bash
cat > .ai-agents/agents.md <<'EOF'
# Project Guidelines

This is a TypeScript project using React and Next.js.

## Build Commands

- `npm install` - Install dependencies
- `npm run dev` - Start dev server
- `npm test` - Run tests

## Code Style

- Use TypeScript strict mode
- Prefer functional components
- Write tests for all components
EOF
```

### 4. Generate Agent Files

```bash
make agents
```

This creates:
- `CLAUDE.md`
- `AGENTS.md`
- `GEMINI.md`
- `.cursor/rules/agents.mdc` (or `.cursorrules` if legacy mode)

### 5. Gitignore Generated Files

Add to `.gitignore`:
```
# Generated AI agent config files
CLAUDE.md
AGENTS.md
GEMINI.md
.cursorrules
.cursor/rules/agents.mdc
```

## Configuration

### Variables

Override in your Makefile before including `agents.mk`:

```makefile
# Source directory name (default: .ai-agents)
AGENTS-DIR-NAME := .project-ai

# Which agents to generate files for (default: claude cursor copilot gemini)
AGENTS-NAMES := claude copilot

# Cursor output format (default: modern)
# 'modern' = .cursor/rules/agents.mdc (with YAML frontmatter)
# 'legacy' = .cursorrules (plain markdown)
AGENTS-CURSOR-MODE := legacy
```

## Source Directory Structure

The `.ai-agents/` directory (committed to git) contains:

```
.ai-agents/
├── agents.md      # Main source (required)
├── claude.md      # Optional: Claude-specific override
├── copilot.md     # Optional: Copilot-specific override
├── gemini.md      # Optional: Gemini-specific override
├── cursor.md      # Optional: Cursor-specific override
└── cursor.yaml    # Optional: YAML frontmatter for Cursor .mdc
```

### Fallback Behavior

If an agent-specific file exists, it's used; otherwise, `agents.md` is used:

```makefile
# Pseudo-code
CLAUDE.md = claude.md exists ? claude.md : agents.md
AGENTS.md = copilot.md exists ? copilot.md : agents.md
GEMINI.md = gemini.md exists ? gemini.md : agents.md
.cursorrules = cursor.md exists ? cursor.md : agents.md
```

## Templating System

### Include Syntax

Use `%%%filename%%%` to include other files:

```markdown
# Project Guidelines

%%%common/style.md%%%
%%%common/testing.md%%%
```

### Include Resolution

Includes are resolved by searching:

1. Current `.ai-agents/` directory
2. Parent directories up to git root
3. Git root

**Example directory tree:**
```
project/
├── .ai-agents/
│   ├── common/
│   │   └── style.md          # Shared style guide
│   └── cursor.yaml           # Shared frontmatter
└── packages/
    └── api/
        └── .ai-agents/
            └── agents.md     # Can use %%%common/style.md%%%
```

**Resolution order for `packages/api/.ai-agents/agents.md`:**
```
packages/api/.ai-agents/common/style.md   # 1. Local first
packages/.ai-agents/common/style.md       # 2. Parent
.ai-agents/common/style.md                # 3. Root
```

### Cursor YAML Frontmatter Example

**File: `.ai-agents/cursor.yaml`**
```yaml
---
description: "Project coding guidelines"
alwaysApply: true
globs: "*.ts,*.tsx"
---
```

**File: `.ai-agents/cursor.md`**
```markdown
%%%cursor.yaml%%%

# TypeScript Project Guidelines

Always use strict mode and type annotations.
```

**Generated: `.cursor/rules/agents.mdc`**
```markdown
---
description: "Project coding guidelines"
alwaysApply: true
globs: "*.ts,*.tsx"
---

# TypeScript Project Guidelines

Always use strict mode and type annotations.
```

## Generated Files

All generated files are created in your project root and should be gitignored:

| Agent | File | Source | Format |
|-------|------|--------|--------|
| **Claude Code** | `CLAUDE.md` | `claude.md` or `agents.md` | Plain Markdown |
| **GitHub Copilot** | `AGENTS.md` | `copilot.md` or `agents.md` | Plain Markdown |
| **Google Gemini** | `GEMINI.md` | `gemini.md` or `agents.md` | Plain Markdown |
| **Cursor (modern)** | `.cursor/rules/agents.mdc` | `cursor.md` or `agents.md` | Markdown + YAML frontmatter |
| **Cursor (legacy)** | `.cursorrules` | `cursor.md` or `agents.md` | Plain Markdown |

### Why AGENTS.md for Copilot?

GitHub Copilot natively supports `AGENTS.md` as of August 2025. This is the cross-tool standard, so we generate it instead of the GitHub-specific `.github/copilot-instructions.md`.

## Targets

### `make agents`

Generate all configured agent files:
```bash
make agents
```

### Per-Agent Targets

Generate specific agent files:
```bash
make agents-claude    # Generate CLAUDE.md
make agents-cursor    # Generate cursor config
make agents-copilot   # Generate AGENTS.md
make agents-gemini    # Generate GEMINI.md
```

### `make agents-clean`

Remove all generated agent files:
```bash
make agents-clean
```

## Examples

### Example 1: Simple Single-File Setup

**File: `.ai-agents/agents.md`**
```markdown
# My Project

This is a Python project using FastAPI.

## Commands

- `poetry install` - Install dependencies
- `poetry run pytest` - Run tests
- `poetry run uvicorn app.main:app` - Start server

## Style

- Follow PEP 8
- Use type hints
- Write docstrings for all functions
```

Run `make agents` to generate all agent files.

### Example 2: Agent-Specific Customization

**File: `.ai-agents/agents.md`** (default)
```markdown
# My Project

General project guidelines...
```

**File: `.ai-agents/claude.md`** (Claude-specific)
```markdown
# My Project - Claude Code Instructions

Use the TodoWrite tool to track implementation progress.

General project guidelines...
```

Claude gets the custom file; other agents get the default.

### Example 3: Modular with Includes

**File: `.ai-agents/agents.md`**
```markdown
# My Project

%%%sections/overview.md%%%
%%%sections/commands.md%%%
%%%sections/style.md%%%
```

**File: `.ai-agents/sections/overview.md`**
```markdown
## Overview

This is a TypeScript monorepo...
```

**File: `.ai-agents/sections/commands.md`**
```markdown
## Build Commands

- `npm install`
- `npm run build`
```

**File: `.ai-agents/sections/style.md`**
```markdown
## Code Style

- Use ESLint
- Prettier for formatting
```

### Example 4: Monorepo with Shared Includes

**File: `.ai-agents/common/testing.md`** (root)
```markdown
## Testing Standards

- Write unit tests for all business logic
- Use Jest for testing
- Aim for 80% code coverage
```

**File: `packages/api/.ai-agents/agents.md`**
```markdown
# API Package

This package implements the REST API.

%%%common/testing.md%%%

## API-Specific Guidelines

- Follow OpenAPI spec
- Document all endpoints
```

**File: `packages/web/.ai-agents/agents.md`**
```markdown
# Web Package

This package implements the React frontend.

%%%common/testing.md%%%

## Web-Specific Guidelines

- Use React Testing Library
- Test user interactions
```

Both packages share the same testing standards from root.

### Example 5: Cursor Modern Mode with Custom Frontmatter

**File: `.ai-agents/cursor.yaml`**
```yaml
---
description: "TypeScript React best practices"
alwaysApply: true
globs: "*.ts,*.tsx,*.jsx"
---
```

**File: `.ai-agents/cursor.md`**
```markdown
%%%cursor.yaml%%%

# TypeScript React Guidelines

## Component Structure

- Use functional components
- Prefer hooks over class components
- Extract custom hooks for reusable logic

## State Management

- Use React Context for global state
- Keep state close to where it's used
- Avoid prop drilling
```

Run `make agents-cursor` to generate `.cursor/rules/agents.mdc` with the frontmatter prepended.

## Troubleshooting

### Generated Files Not Updating

**Problem:** You changed `.ai-agents/agents.md` but `CLAUDE.md` didn't update.

**Solution:** Make tracks dependencies. Run `make agents-clean` then `make agents`, or just `make agents` again (Make will regenerate if source is newer).

### Include File Not Found

**Problem:** `Warning: Include not found: common/style.md`

**Solution:** The include path is resolved from your `.ai-agents/` directory upward. Check:
1. Is the file path correct? (case-sensitive on Linux/Mac)
2. Is the file in `.ai-agents/common/style.md` or a parent `.ai-agents/` directory?
3. Use `find . -name "style.md"` to locate the file

### Cursor YAML Not Applied

**Problem:** `.cursor/rules/agents.mdc` generated without YAML frontmatter.

**Solutions:**
1. Check `AGENTS-CURSOR-MODE` is set to `modern` (default)
2. Create `.ai-agents/cursor.yaml` with your frontmatter
3. Or add `%%%cursor.yaml%%%` at the top of `.ai-agents/cursor.md`
4. Verify YAML syntax is correct (use a YAML validator)

### Circular Include Loop

**Problem:** Script hangs when generating files.

**Solution:** You have a circular include (file A includes file B, which includes file A). The `agents-expand` script doesn't detect this. Review your includes:

```bash
# Find all includes in your files
grep -r "%%%" .ai-agents/
```

### Wrong Root Directory

**Problem:** Includes not found in monorepo.

**Solution:** The script uses git root by default. If your project isn't a git repo:

```bash
# The script falls back to / if not in git repo
# Make your directory a git repo:
git init
```

Or modify the script to pass a custom root directory.

## Background Research

This module was designed based on extensive research into AI coding agent configuration standards (December 2025). Key findings:

### File Format Compatibility

Most agents use **plain Markdown**:
- `CLAUDE.md`, `AGENTS.md`, `GEMINI.md`, `.cursorrules` are format-identical
- Only Cursor's modern `.mdc` format differs (requires YAML frontmatter)

### The AGENTS.md Standard

**AGENTS.md** is an emerging cross-tool standard (as of August 2025):
- Supported by: OpenAI Codex, GitHub Copilot, Google Gemini, Cursor, Zed
- 20,000+ repositories on GitHub use it
- Stewarded by the Agentic AI Foundation (Linux Foundation)

### Why Not Symlinks?

**Claude Code has multiple bugs with symlinks:**
- Issue #1388: Doesn't index symlinked files
- Issue #764: Can't detect files in symlinked `~/.claude` directories
- Issue #3575: Permission failures with symlinked settings
- Issue #10573: Broken symlink support in v2.0.28

**Solution:** This module copies files instead of symlinking.

### Research Sources

For detailed research and sources, see the conversation that led to this module's design. Key topics researched:
- File naming conventions (uppercase vs lowercase)
- Symlink compatibility across tools
- Format differences (YAML frontmatter requirements)
- Cross-tool standardization efforts

## Additional Resources

- [AGENTS.md Official Specification](https://agents.md/)
- [GitHub Copilot AGENTS.md Guide](https://github.blog/ai-and-ml/github-copilot/how-to-write-a-great-agents-md-lessons-from-over-2500-repositories/)
- [Cursor Rules Documentation](https://docs.cursor.com/context/rules)
- [Claude Code CLAUDE.md Guide](https://claude.com/blog/using-claude-md-files)
