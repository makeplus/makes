CLAUDE-VERSION ?= latest
# https://github.com/anthropics/claude-code

ifndef CLAUDE-LOADED
CLAUDE-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
$(eval $(call include-local))

include $(MAKES)/nono.mk
include $(MAKES)/gh.mk
include $(MAKES)/jq.mk
include $(MAKES)/ys.mk

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

CLAUDE-NONO-OPTS += --allow-cwd

# CLAUDE-NONO-R-FILES += $(XAUTHORITY)
CLAUDE-NONO-R-FILES += /etc/gitconfig
CLAUDE-NONO-R-DIRS += ~/.config/gh
CLAUDE-NONO-R-DIRS += /proc
# CLAUDE-NONO-R-DIRS += /tmp/.X11-unix
CLAUDE-NONO-RW-FILES +=
CLAUDE-NONO-RW-DIRS += /tmp/claude-$(shell id -u)
CLAUDE-NONO-RW-DIRS += ~/.cache/makes

CLAUDE-NONO-PROFILE = $(shell \
  $(MAKES)/util/generate-claude-nono-profile \
    "$(LOCAL-TMP)/claude-nono-profile" \
    "$(CLAUDE-NONO-R-FILES)" \
    "$(CLAUDE-NONO-RW-FILES)" \
    "$(CLAUDE-NONO-R-DIRS)" \
    "$(CLAUDE-NONO-RW-DIRS)" \
)

export CLAUDE_CODE_DISABLE_TERMINAL_TITLE := 1

ifndef CLAUDE-SYSTEM
$(CLAUDE):
	@$(ECHO) "Installing 'claude' locally"
	$Q curl -fsSL https://claude.ai/install.sh | bash
	$Q touch $@
endif

$(CLAUDE-READY): $(CLAUDE) $(JQ)
	@if [[ -z $$ANTHROPIC_API_KEY ]] && \
	    ! $< auth status &>/dev/null; \
	then \
	  echo 'Claude Code is not authenticated.'; \
	  echo 'Please set: ANTHROPIC_API_KEY'; \
	  echo 'or run: claude auth login'; \
	  exit 1; \
	fi
	$Q touch $@

# Claude Code's paste-image flow writes the clipboard image to
# $CLAUDE_CODE_TMPDIR (default /tmp) and then reads it back. Nono's
# default profile allows writes to /tmp but blocks reads, so redirect
# to the already-RW /tmp/claude-<uid> dir from claude.mk.
claude-nono: export CLAUDE_CODE_TMPDIR := /tmp/claude-$(shell id -u)
claude-nono: $(CLAUDE-READY) $(NONO) $(GH)
	nono run --profile $(CLAUDE-NONO-PROFILE) $(CLAUDE-NONO-OPTS) -- \
	  claude$(if $(CLAUDE-MODEL), --model $(CLAUDE-MODEL))$(if $(CLAUDE-OPTS), $(CLAUDE-OPTS), --dangerously-skip-permissions)

claude-nono-profile: $(NONO) $(YS)
	@nono policy show --json $(CLAUDE-NONO-PROFILE) | ys -Y -

endif
