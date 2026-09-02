ifndef DOCKER-OR-PODMAN-LOADED
DOCKER-OR-PODMAN-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
$(eval $(call include-local))

DOCKER-OR-PODMAN-SHELL-DEPS := $(SHELL-DEPS)
DOCKER-OR-PODMAN-MAKEFILE := $(firstword $(MAKEFILE_LIST))
include $(MAKES)/docker.mk
include $(MAKES)/podman.mk
SHELL-DEPS := $(DOCKER-OR-PODMAN-SHELL-DEPS)

DOCKER-OR-PODMAN-TARGET := docker-or-podman
DOCKER-OR-PODMAN-FALLBACK := .docker-or-podman-unavailable
DOCKER-OR-PODMAN ?= $(strip \
  $(if $(DOCKER-RUNNING),$(DOCKER), \
    $(if $(PODMAN-RUNNING),$(PODMAN), \
      $(DOCKER-OR-PODMAN-FALLBACK))))

SHELL-DEPS += $(DOCKER-OR-PODMAN)

.PHONY: $(DOCKER-OR-PODMAN-TARGET) $(DOCKER-OR-PODMAN-FALLBACK)
$(DOCKER-OR-PODMAN-TARGET): $(DOCKER-OR-PODMAN)

$(DOCKER-OR-PODMAN-FALLBACK):
	@printf '%s\n' \
	  'ERROR: Neither Docker nor Podman is available.' >&2
	@$(MAKE) --no-print-directory \
	  -f $(DOCKER-OR-PODMAN-MAKEFILE) $(DOCKER) || true
	@$(MAKE) --no-print-directory \
	  -f $(DOCKER-OR-PODMAN-MAKEFILE) $(PODMAN) || true
	@exit 1

endif
