ifndef PODMAN-LOADED
PODMAN-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
$(eval $(call include-local))

PODMAN ?= podman
SHELL-DEPS += $(PODMAN)

PODMAN-INSTALL-HINT-linux := Install Podman: \
  https://podman.io/docs/installation
PODMAN-INSTALL-HINT-macos := Install Podman: \
  https://podman.io/docs/installation
PODMAN-INSTALL-HINT-windows := Install Podman: \
  https://podman.io/docs/installation

PODMAN-START-HINT-linux := Check rootless Podman setup: \
  https://docs.podman.io/en/latest/markdown/podman.1.html#rootless-mode
PODMAN-START-HINT-macos := Run podman machine start and wait until it is ready.
PODMAN-START-HINT-windows := Run podman machine start and wait until it is \
  ready.

.PHONY: $(PODMAN)
$(PODMAN):
	@command -v $(PODMAN) >/dev/null 2>&1 || { \
	  printf '%s\n' \
	    'ERROR: Podman is not installed or not in PATH.' \
	    '$(PODMAN-INSTALL-HINT-$(OS-NAME))' >&2; \
	  exit 1; \
	}
	@output=$$($(PODMAN) info 2>&1) || { \
	  printf '%s\n' \
	    'ERROR: Podman is installed but not available.' \
	    '$(PODMAN-START-HINT-$(OS-NAME))' >&2; \
	  printf '%s\n' "$$output" >&2; \
	  exit 1; \
	}

PODMAN-RUNNING := $(shell \
  command -v $(PODMAN) >/dev/null 2>&1 && \
  $(PODMAN) info >/dev/null 2>&1 && echo true)

endif
