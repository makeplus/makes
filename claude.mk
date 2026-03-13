CLAUDE-VERSION ?= latest
# https://github.com/anthropics/claude-code

ifndef CLAUDE-LOADED
CLAUDE-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
$(eval $(call include-local))
include $(MAKES)/jq.mk

ifdef GITHUB_ACTIONS
CLAUDE-MODE ?= full
else
CLAUDE-MODE ?= readonly
endif

CLAUDE-SYSTEM := $(shell which claude 2>/dev/null)

ifdef CLAUDE-SYSTEM
CLAUDE := $(CLAUDE-SYSTEM)
else
CLAUDE := $(HOME)/.local/bin/claude
endif

ifeq ($(CLAUDE-MODE),bypass)
CLAUDE-ALLOWED-TOOLS := --dangerously-skip-permissions
else ifeq ($(CLAUDE-MODE),full)
CLAUDE-ALLOWED-TOOLS := --allowedTools Read,Grep,Glob,Edit,Write,Bash
else ifeq ($(CLAUDE-MODE),edit)
CLAUDE-ALLOWED-TOOLS := --allowedTools Read,Grep,Glob,Edit,Write
else
CLAUDE-ALLOWED-TOOLS := --allowedTools Read,Grep,Glob
endif

CLAUDE-QUIET ?=
CLAUDE-DEBUG ?=
CLAUDE-RUN = sh -c \
  '$(CLAUDE) $(CLAUDE-ALLOWED-TOOLS) \
   $(if $(CLAUDE-QUIET),,--verbose --output-format stream-json) \
   $(if $(CLAUDE-DEBUG),--debug-file /dev/stderr,) \
   -p "$$1" \
   $(if $(CLAUDE-QUIET),, | $(JQ) --unbuffered -Rrf $(MAKES)/util/claude-stream.jq)' \
  --

CLAUDE-READY := $(LOCAL-CACHE)/claude-ready

SHELL-DEPS += $(CLAUDE)

ifndef CLAUDE-SYSTEM
$(CLAUDE):
	@$(ECHO) "Installing 'claude' locally"
	$Q curl -fsSL https://claude.ai/install.sh | bash
	$Q touch $@
endif

$(CLAUDE-READY): $(CLAUDE) $(JQ)
	@if [[ -z $$ANTHROPIC_API_KEY ]] && \
	    ! $< auth status &>/dev/null \
	then \
	  echo 'Claude Code is not authenticated.'; \
	  echo 'Please set: ANTHROPIC_API_KEY'; \
	  echo 'or run: claude auth login'; \
	  exit 1; \
	fi
	$Q touch $@

endif
