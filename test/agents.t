#!/usr/bin/env bash

set -euo pipefail

source test/bpan-init

cd "$(dirname "${BASH_SOURCE[0]}")/agents"

clean() { make -s agents-clean 2>/dev/null || true; }

# Ensure clean state
clean

# Test 1: Basic generation from agents.md
make -s agents-copilot agents-gemini
ok-f AGENTS.md "Basic: AGENTS.md exists"
ok-f GEMINI.md "Basic: GEMINI.md exists"
try diff -q AGENTS.md expected/AGENTS.md
ok $rc "Basic: AGENTS.md matches expected"
try diff -q GEMINI.md expected/GEMINI.md
ok $rc "Basic: GEMINI.md matches expected"
clean

# Test 2: Agent override (claude.md → CLAUDE.md)
make -s agents-claude
ok-f CLAUDE.md "Override: CLAUDE.md exists"
try diff -q CLAUDE.md expected/CLAUDE.md
ok $rc "Override: CLAUDE.md matches expected"
clean

# Test 3: Template includes (%%%cursor.yaml%%%)
make -s agents-cursor AGENTS-CURSOR-MODE=modern
ok-f .cursor/rules/agents.mdc "Includes: agents.mdc exists"
try diff -q .cursor/rules/agents.mdc expected/agents.mdc
ok $rc "Includes: agents.mdc matches expected"
clean

# Test 4: Cursor modern mode
make -s agents-cursor AGENTS-CURSOR-MODE=modern
ok-d .cursor "Cursor modern: .cursor/ directory exists"
ok-f .cursor/rules/agents.mdc "Cursor modern: agents.mdc exists"
clean

# Test 5: Cursor legacy mode
make -s agents-cursor AGENTS-CURSOR-MODE=legacy
ok-f .cursorrules "Cursor legacy: .cursorrules exists"
try diff -q .cursorrules expected/cursorrules
ok $rc "Cursor legacy: .cursorrules matches expected"
clean

# Test 6: Hierarchical includes (subdir)
make -s -C subdir agents-copilot
ok-f subdir/AGENTS.md "Subdir: AGENTS.md exists"
try diff -q subdir/AGENTS.md expected/subdir-AGENTS.md
ok $rc "Subdir: AGENTS.md matches expected"
clean

# Test 7: Clean target removes all generated files
make -s agents-copilot agents-claude agents-gemini
make -s agents-cursor AGENTS-CURSOR-MODE=legacy
make -s -C subdir agents-copilot
clean
make -s -C subdir agents-clean
ok-not-e CLAUDE.md "Clean: CLAUDE.md removed"
ok-not-e AGENTS.md "Clean: AGENTS.md removed"
ok-not-e GEMINI.md "Clean: GEMINI.md removed"
ok-not-e .cursorrules "Clean: .cursorrules removed"
ok-not-e .cursor "Clean: .cursor/ removed"
ok-not-e subdir/AGENTS.md "Clean: subdir/AGENTS.md removed"

done-testing
