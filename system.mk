ifndef SYSTEM-LOADED
SYSTEM-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
$(eval $(call include-local))

# Auto-detect package manager on Linux
ifdef IS-LINUX
SYSTEM-PKG-MGR := $(if $(shell command -v apt),apt,\
  $(if $(shell command -v dnf),dnf,\
  $(if $(shell command -v pacman),pacman,unknown)))
endif

# system-require function
# Usage: $(eval $(call system-require,binary-name[,NAME]))
# NAME defaults to uppercase of binary-name.
# Caller can set: <NAME>-APT, <NAME>-BREW, <NAME>-DNF, <NAME>-PACMAN
# for package name overrides (defaults to binary-name).
# <NAME>-MISSING controls error vs warn (default: error).
define system-require
$(eval $(call _system-require,$(or $(2),$(shell echo $(1) | tr a-z A-Z)),$(1)))
endef

define _system-require
$(1) := $$(shell command -v $(2))
$(1)-MISSING ?= error
ifeq (,$$($(1)))
  $(1)-INSTALL-MSG := $(2) is not installed.
  ifdef IS-MACOS
    $(1)-INSTALL-MSG += $$(newline)  brew install $$(or $$($(1)-BREW),$(2))
  else ifdef IS-LINUX
    ifeq (apt,$$(SYSTEM-PKG-MGR))
      $(1)-INSTALL-MSG += $$(newline)  sudo apt install $$(or $$($(1)-APT),$(2))
    else ifeq (dnf,$$(SYSTEM-PKG-MGR))
      $(1)-INSTALL-MSG += $$(newline)  sudo dnf install $$(or $$($(1)-DNF),$(2))
    else ifeq (pacman,$$(SYSTEM-PKG-MGR))
      $(1)-INSTALL-MSG += $$(newline)  sudo pacman -S $$(or $$($(1)-PACMAN),$(2))
    else
      $(1)-INSTALL-MSG += $$(newline)  Install using your system package manager.
    endif
  endif
  ifeq (error,$$($(1)-MISSING))
    $$(error $$($(1)-INSTALL-MSG))
  else
    $$(warning $$($(1)-INSTALL-MSG))
  endif
endif
endef

# Auto-include tool .mk files for SYSTEM-TOOLS entries
$(foreach tool,$(SYSTEM-TOOLS),\
  $(eval include $(MAKES)/$(tool).mk))

# SYSTEM target — prerequisite for all system tool checks
SYSTEM := $(LOCAL-CACHE)/system-check
SHELL-DEPS += $(SYSTEM)

$(SYSTEM):
	touch $@

endif
