ifndef DOCKER-LOADED
DOCKER-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
$(eval $(call include-local))

DOCKER ?= docker
SHELL-DEPS += $(DOCKER)

DOCKER-INSTALL-HINT-linux := Install Docker Engine: \
  https://docs.docker.com/engine/install/
DOCKER-INSTALL-HINT-macos := Install Docker Desktop: \
  https://docs.docker.com/desktop/setup/install/mac-install/
DOCKER-INSTALL-HINT-windows := Install Docker Desktop: \
  https://docs.docker.com/desktop/setup/install/windows-install/

DOCKER-START-HINT-linux := Start Docker Engine and ensure this user can \
  access it: https://docs.docker.com/engine/install/linux-postinstall/
DOCKER-START-HINT-macos := Start Docker Desktop and wait until it is ready.
DOCKER-START-HINT-windows := Start Docker Desktop and wait until it is ready.

.PHONY: $(DOCKER)
$(DOCKER):
	@command -v $(DOCKER) >/dev/null 2>&1 || { \
	  printf '%s\n' \
	    'ERROR: Docker is not installed or not in PATH.' \
	    '$(DOCKER-INSTALL-HINT-$(OS-NAME))' >&2; \
	  exit 1; \
	}
	@output=$$($(DOCKER) info 2>&1) || { \
	  printf '%s\n' \
	    'ERROR: Docker is installed but not available.' \
	    '$(DOCKER-START-HINT-$(OS-NAME))' >&2; \
	  printf '%s\n' "$$output" >&2; \
	  exit 1; \
	}

DOCKER-RUNNING := $(shell \
  command -v $(DOCKER) >/dev/null 2>&1 && \
  $(DOCKER) info >/dev/null 2>&1 && echo true)

ifneq (,$(wildcard /.dockerenv))

IN-DOCKER := true

else

include $(MAKES)/git.mk

DOCKER-NAME ?= makes-$(GIT-REPO-NAME)
DOCKER-BUILD-FILE := $(LOCAL-CACHE)/docker-build-$(DOCKER-NAME)
DOCKER-RUN-FILE := $(LOCAL-CACHE)/docker-run-$(DOCKER-NAME)
DOCKER-BASH-HISTORY ?= $(LOCAL-CACHE)/bash-history
DOCKER-EXEC := $(DOCKER) exec -it $(DOCKER-NAME)
DOCKER-FILE := $(LOCAL-TMP)/Dockerfile
DOCKER-CONTEXT := .

ifdef DOCKER-USER
ifdef DOCKER-VERSION
DOCKER-NAME := $(DOCKER-USER)/$(DOCKER-NAME):$(DOCKER-VERSION)
DOCKER-URL := docker.io/$(DOCKER-NAME)
endif
endif

$(shell $(RM) $(DOCKER-RUN-FILE))

ifneq (,$(DOCKER-RUNNING))
ifneq (,$(shell $(DOCKER) ps 2>/dev/null | grep $(DOCKER-NAME)))
$(shell touch $(DOCKER-RUN-FILE))
endif
endif


realclean::
	@if command -v $(DOCKER) >/dev/null 2>&1 && \
	    $(DOCKER) info >/dev/null 2>&1; then \
	  $(DOCKER) kill $(DOCKER-NAME) || true; \
	fi
	$(RM) $(DOCKER-BUILD-FILE)

docker-shell: $(DOCKER-RUN-FILE) | $(DOCKER)
	$(DOCKER) exec -it $(DOCKER-NAME) bash

docker-ps: | $(DOCKER)
	$(DOCKER) ps | grep $(DOCKER-NAME)

docker-kill: | $(DOCKER)
	-$(DOCKER) kill $(DOCKER-NAME)
	$(RM) $(DOCKER-BUILD-FILE)

ifdef DOCKER-URL
docker-push: $(DOCKER-BUILD-FILE) | $(DOCKER)
	$(DOCKER) push $(DOCKER-URL)
endif

$(DOCKER-RUN-FILE): $(DOCKER-BUILD-FILE) | $(DOCKER)
	touch $(DOCKER-BASH-HISTORY)
	$(DOCKER) run -d --rm \
	  --name $(DOCKER-NAME) \
	  --workdir $(ROOT) \
	  --volume $(GIT-REPO-DIR):$(GIT-REPO-DIR) \
	  --volume $(DOCKER-BASH-HISTORY):/root/.bash-history \
	  $(DOCKER-RUN-OPTIONS) \
	  $(DOCKER-NAME) \
	  sleep infinity

$(DOCKER-BUILD-FILE): $(DOCKER-FILE) | $(DOCKER)
	$(DOCKER) build \
	  -f $(DOCKER-FILE) \
	  -t $(DOCKER-NAME) \
	  $(DOCKER-BUILD-OPTIONS) \
	  $(DOCKER-CONTEXT)
	touch $@

ifdef DOCKER-FILES
$(DOCKER-FILE): $(DOCKER-FILES)
	cat $^ > $@
else
$(DOCKER-FILE):
	@echo 'DOCKER-FILES not defined'
	@exit 1
endif

endif

endif
