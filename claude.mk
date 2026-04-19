CLAUDE-VERSION ?= latest
# https://github.com/anthropics/claude-code

ifndef CLAUDE-LOADED
CLAUDE-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
$(eval $(call include-local))

include $(MAKES)/nono.mk
include $(MAKES)/gh.mk
include $(MAKES)/jq.mk

ifdef GITHUB_ACTIONS
CLAUDE-MODE ?= full
else
CLAUDE-MODE ?= readonly
endif

CLAUDE-MODEL ?=

CLAUDE-SYSTEM := $(shell which claude 2>/dev/null)

ifdef CLAUDE-SYSTEM
CLAUDE := $(CLAUDE-SYSTEM)
else
CLAUDE := $(HOME)/.local/bin/claude
override PATH := $(HOME)/.local/bin:$(PATH)
export PATH
endif

ifeq ($(CLAUDE-MODE),full)
CLAUDE-ALLOWED-TOOLS ?= --allowedTools Read,Grep,Glob,Edit,Write,Bash
else ifeq ($(CLAUDE-MODE),edit)
CLAUDE-ALLOWED-TOOLS ?= --allowedTools Read,Grep,Glob,Edit,Write
else
CLAUDE-ALLOWED-TOOLS ?= --allowedTools Read,Grep,Glob
endif

CLAUDE-QUIET ?=
CLAUDE-DEBUG ?=
CLAUDE-RUN = sh -c \
  '$(CLAUDE) $(CLAUDE-ALLOWED-TOOLS) \
   $(if $(CLAUDE-MODEL),--model $(CLAUDE-MODEL),) \
   $(if $(CLAUDE-QUIET),,--verbose --output-format stream-json) \
   $(if $(CLAUDE-DEBUG),--debug-file /dev/stderr,) \
   -p "$$1" \
   $(if $(CLAUDE-QUIET),, | $(JQ) --unbuffered -Rrf $(MAKES)/util/claude-stream.jq)' \
  --

CLAUDE-READY := $(LOCAL-CACHE)/claude-ready

SHELL-DEPS += $(CLAUDE)

ifdef MAKES_CLAUDE_OPTS
CLAUDE-OPTS ?= $(MAKES_CLAUDE_OPTS)
endif
CLAUDE-OPTS ?=

CLAUDE-NONO-OPTS += \
  --profile claude-code \
  --allow-cwd \
  --allow /tmp/claude-$(shell id -u) \
  --allow ~/.cache/makes \
  --read-file /etc/gitconfig \
  --read ~/.config/gh \
  --read /proc \
  --read /usr/bin \
  --read /usr/local/bin \
  --read /usr/libexec \
  --read /usr/include \

CLAUDE-NONO-DEPS ?= \
  $(GH) \

export CLAUDE_CODE_DISABLE_TERMINAL_TITLE := 1


.SECONDEXPANSION:

ifndef CLAUDE-SYSTEM
$(CLAUDE):
	@$(ECHO) "Installing 'claude' locally"
	$Q curl -fsSL https://claude.ai/install.sh | bash
	$Q touch $@
endif

$(CLAUDE-READY): $(CLAUDE)
	@if [[ -z $$ANTHROPIC_API_KEY ]] && \
	    ! $< auth status &>/dev/null; \
	then \
	  echo 'Claude Code is not authenticated.'; \
	  echo 'Please set: ANTHROPIC_API_KEY'; \
	  echo 'or run: claude auth login'; \
	  exit 1; \
	fi
	$Q touch $@

# Symlink ./CLAUDE.md from ~/.claude/<project-path>/CLAUDE.md if it exists.
CLAUDE-MD-SOURCE := $(HOME)/.claude$(ROOT)/CLAUDE.md
CLAUDE-MD-LINK := $(ROOT)/CLAUDE.md

_claude-md-link:
ifneq (,$(wildcard $(CLAUDE-MD-SOURCE)))
	@if [[ ! -e $(CLAUDE-MD-LINK) ]]; then \
	  ln -s $(CLAUDE-MD-SOURCE) $(CLAUDE-MD-LINK); \
	fi
endif

# Claude Code's paste-image flow writes the clipboard image to
# $CLAUDE_CODE_TMPDIR (default /tmp) and then reads it back. Nono's
# default profile allows writes to /tmp but blocks reads, so redirect
# to the already-RW /tmp/claude-<uid> dir from claude.mk.
claude-nono: export CLAUDE_CODE_TMPDIR := /tmp/claude-$(shell id -u)
claude-nono: _claude-md-link $(CLAUDE-READY) $(NONO) $$(CLAUDE-NONO-DEPS)
ifeq (,$(wildcard $(HOME)/.claude.lock))
	touch $(HOME)/.claude.lock
	(sleep 2 && rm -f $(HOME)/.claude.lock) &
endif
	nono run $(CLAUDE-NONO-OPTS) -- \
	  claude --dangerously-skip-permissions \
	  $(if $(CLAUDE-OPTS), $(CLAUDE-OPTS)) \

claude-nono-profile: $(NONO)
	@echo $(CLAUDE-NONO-OPTS)

endif
