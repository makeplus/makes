ifndef DOCKER-COMPOSE-LOADED
DOCKER-COMPOSE-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
$(eval $(call include-local))

DOCKER ?= docker
DOCKER-COMPOSE-PATH := $(subst $(LOCAL-BIN):,,$(PATH))
DOCKER-COMPOSE-REAL := $(shell \
  PATH='$(DOCKER-COMPOSE-PATH)' command -v $(DOCKER) 2>/dev/null)
DOCKER-COMPOSE-NATIVE := $(shell \
  if [[ -n '$(DOCKER-COMPOSE-REAL)' ]] && \
      '$(DOCKER-COMPOSE-REAL)' compose version >/dev/null 2>&1; then \
    echo true; \
  fi)

export MAKES_DOCKER_REAL := $(DOCKER-COMPOSE-REAL)

ifeq (true,$(DOCKER-COMPOSE-NATIVE))

DOCKER-COMPOSE := $(DOCKER)

else

include $(MAKES)/compose.mk

DOCKER-COMPOSE := $(LOCAL-BIN)/docker
SHELL-DEPS += $(DOCKER-COMPOSE)
export MAKES_COMPOSE := $(COMPOSE)

$(DOCKER-COMPOSE): $(COMPOSE) $(MAKES)/util/docker-compose-wrapper
	$Q cp $(MAKES)/util/docker-compose-wrapper $@
	$Q chmod +x $@
	@$(ECHO)

endif

endif
