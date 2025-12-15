# agents.mk - AI coding agent configuration file generator
#
# Generates agent-specific configuration files from a single source.
# Source files are committed to git; generated files are gitignored.

ifndef AGENTS-LOADED
AGENTS-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))

MAKES-CLEAN += \
  $(MAKEFILE-DIR)/CLAUDE.md \
  $(MAKEFILE-DIR)/AGENTS.md \
  $(MAKEFILE-DIR)/GEMINI.md \
  $(MAKEFILE-DIR)/.cursorrules \
  $(MAKEFILE-DIR)/.cursor/rules/agents.mdc \
  $(MAKEFILE-DIR)/.cursor \

# ============================================================================
# Configuration Variables (can be overridden)
# ============================================================================
AGENTS-DIR-NAME ?= .ai-agents
AGENTS-NAMES ?= claude cursor copilot gemini
# 'modern' (.cursor/rules/*.mdc) - default
# 'legacy' (.cursorrules)
AGENTS-CURSOR-MODE ?= modern

# ============================================================================
# Derived Paths
# ============================================================================
AGENTS-DIR := $(MAKEFILE-DIR)/$(AGENTS-DIR-NAME)
AGENTS-SOURCE := $(AGENTS-DIR)/template.md

# Output paths
AGENTS-CLAUDE-OUT := $(MAKEFILE-DIR)/CLAUDE.md
AGENTS-COPILOT-OUT := $(MAKEFILE-DIR)/AGENTS.md
AGENTS-GEMINI-OUT := $(MAKEFILE-DIR)/GEMINI.md

# Cursor output depends on mode
ifeq (modern,$(AGENTS-CURSOR-MODE))
  AGENTS-CURSOR-OUT := $(MAKEFILE-DIR)/.cursor/rules/agents.mdc
else
  AGENTS-CURSOR-OUT := $(MAKEFILE-DIR)/.cursorrules
endif

# ============================================================================
# Source File Resolution (agent-specific override or fallback to template.md)
# ============================================================================
AGENTS-CLAUDE-SRC := \
  $(if $(wildcard $(AGENTS-DIR)/claude-template.md),\
  $(AGENTS-DIR)/claude-template.md,$(AGENTS-SOURCE))
AGENTS-CURSOR-SRC := \
  $(if $(wildcard $(AGENTS-DIR)/cursor-template.md),\
  $(AGENTS-DIR)/cursor-template.md,$(AGENTS-SOURCE))
AGENTS-COPILOT-SRC := \
  $(if $(wildcard $(AGENTS-DIR)/copilot-template.md),\
  $(AGENTS-DIR)/copilot-template.md,$(AGENTS-SOURCE))
AGENTS-GEMINI-SRC := \
  $(if $(wildcard $(AGENTS-DIR)/gemini-template.md),\
  $(AGENTS-DIR)/gemini-template.md,$(AGENTS-SOURCE))

v ?=

ifdef v
  echo := echo
else
  echo := :
endif

# ============================================================================
# Main Target
# ============================================================================
agents: $(foreach name,$(AGENTS-NAMES),agents-$(name))

# Helper script for template expansion
AGENTS-EXPAND := $(MAKES)/util/agents-expand

# ============================================================================
# Per-Agent Targets
# ============================================================================
agents-claude: $(AGENTS-CLAUDE-OUT)
$(AGENTS-CLAUDE-OUT): $(AGENTS-CLAUDE-SRC)
	@$(echo) "Generating CLAUDE.md"
	@$(AGENTS-EXPAND) $< $(AGENTS-DIR) > $@

agents-cursor: $(AGENTS-CURSOR-OUT)

ifeq ($(AGENTS-CURSOR-MODE),modern)
# Modern mode: Generate .cursor/rules/agents.mdc with YAML frontmatter
$(AGENTS-CURSOR-OUT): $(AGENTS-CURSOR-SRC)
	@$(echo) "Generating .cursor/rules/agents.mdc"
	@mkdir -p $(dir $@)
	@$(AGENTS-EXPAND) $< $(AGENTS-DIR) > $@
else
# Legacy mode: Generate .cursorrules
$(AGENTS-CURSOR-OUT): $(AGENTS-CURSOR-SRC)
	@$(echo) "Generating .cursorrules"
	@$(AGENTS-EXPAND) $< $(AGENTS-DIR) > $@
endif

agents-copilot: $(AGENTS-COPILOT-OUT)
$(AGENTS-COPILOT-OUT): $(AGENTS-COPILOT-SRC)
	@$(echo) "Generating AGENTS.md"
	@$(AGENTS-EXPAND) $< $(AGENTS-DIR) > $@

agents-gemini: $(AGENTS-GEMINI-OUT)
$(AGENTS-GEMINI-OUT): $(AGENTS-GEMINI-SRC)
	@$(echo) "Generating GEMINI.md"
	@$(AGENTS-EXPAND) $< $(AGENTS-DIR) > $@

# ============================================================================
# Clean Target
# ============================================================================
agents-clean:
	$(RM) -r $(MAKES-CLEAN)

endif
