CLAUDE-VERSION ?= latest
# https://github.com/anthropics/claude-code

ifndef CLAUDE-LOADED
CLAUDE-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
$(eval $(call include-local))

include $(MAKES)/git.mk
include $(MAKES)/jq.mk
include $(MAKES)/ys.mk

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

ifdef MAKES_CLAUDE_OPTS
CLAUDE-OPTS ?= $(MAKES_CLAUDE_OPTS)
endif
CLAUDE-OPTS ?=

CLAUDE-NONO-PROFILE-NAME ?= claude-code
CLAUDE-LOCAL-NONO-PROFILE-YAML := $(GIT-REPO-DIR)/.nono/claude-code.yaml
CLAUDE-LOCAL-NONO-PROFILE-JSON := $(GIT-REPO-DIR)/.nono/claude-code.json

CLAUDE-NONO-PROFILE = \
  $(if $(wildcard $(CLAUDE-LOCAL-NONO-PROFILE-JSON)),$(CLAUDE-LOCAL-NONO-PROFILE-JSON),$(CLAUDE-NONO-PROFILE-NAME))


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

claude-nono-start: $(CLAUDE-READY) $(if $(NONO-LOADED),$(NONO)) $(if $(wildcard $(CLAUDE-LOCAL-NONO-PROFILE-YAML)),$(CLAUDE-LOCAL-NONO-PROFILE-JSON))
ifndef NONO-LOADED
	$(error nono.mk must be included to use $@)
endif
	nono run --profile $(CLAUDE-NONO-PROFILE) --allow-cwd -- claude $(CLAUDE-OPTS)

ifdef NONO-LOADED

CLAUDE-NONO-SHOW-DEPS := $(NONO)
ifdef YS-LOADED
CLAUDE-NONO-SHOW-DEPS += $(YS)
CLAUDE-NONO-YAML-CMD := $(YS) -Y
endif
CLAUDE-NONO-YAML-CMD ?= cat

claude-nono-profile: $(CLAUDE-NONO-SHOW-DEPS)
	@nono policy show --json $(CLAUDE-NONO-PROFILE) | $(CLAUDE-NONO-YAML-CMD)

claude-nono-profile-json: $(NONO)
	@nono policy show --json $(CLAUDE-NONO-PROFILE)

claude-nono-profile-yaml: $(CLAUDE-NONO-SHOW-DEPS)
ifndef YS-LOADED
	$(error claude-nono-profile-yaml requires ys.mk included before nono.mk)
endif
	@nono policy show --json $(CLAUDE-NONO-PROFILE) | $(CLAUDE-NONO-YAML-CMD)

CLAUDE-NONO-PROFILE-TEMPLATE := $(MAKES)/share/claude-local-nono-profile.yaml

claude-local-nono-profile: $(YS)
ifneq (,$(wildcard $(CLAUDE-LOCAL-NONO-PROFILE-YAML)))
	@echo "Local profile already exists: $(CLAUDE-LOCAL-NONO-PROFILE-YAML)"
	@exit 1
endif
	@mkdir -p $(dir $(CLAUDE-LOCAL-NONO-PROFILE-YAML))
	cp $(CLAUDE-NONO-PROFILE-TEMPLATE) $(CLAUDE-LOCAL-NONO-PROFILE-YAML)
	ys -J $(CLAUDE-LOCAL-NONO-PROFILE-YAML) > $(CLAUDE-LOCAL-NONO-PROFILE-JSON)
	@echo
	@echo "Created local profile: $(CLAUDE-LOCAL-NONO-PROFILE-YAML)"

ifneq (,$(wildcard $(CLAUDE-LOCAL-NONO-PROFILE-YAML)))
claude-local-nono-profile-update: $(CLAUDE-LOCAL-NONO-PROFILE-JSON)

$(CLAUDE-LOCAL-NONO-PROFILE-JSON): $(CLAUDE-LOCAL-NONO-PROFILE-YAML) $(YS)
	  ys -J $< > $@
endif

claude-local-nono-profile-example:
	@cat $(CLAUDE-NONO-PROFILE-TEMPLATE)

endif # NONO-LOADED

endif
