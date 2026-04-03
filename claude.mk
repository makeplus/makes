CLAUDE-VERSION ?= latest
# https://github.com/anthropics/claude-code

ifndef CLAUDE-LOADED
CLAUDE-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
$(eval $(call include-local))

include $(MAKES)/nono.mk
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

CLAUDE-NONO-RW-DIRS += /tmp/claude-$(shell id -u)

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

claude-nono: $(CLAUDE-READY) $(NONO)
	nono run --profile $(CLAUDE-NONO-PROFILE) --allow-cwd -- \
	  claude$(if $(CLAUDE-MODEL), --model $(CLAUDE-MODEL))$(if $(CLAUDE-OPTS), $(CLAUDE-OPTS), --dangerously-skip-permissions)

claude-nono-profile: $(NONO) $(YS)
	@nono policy show --json $(CLAUDE-NONO-PROFILE) | ys -Y -

endif
