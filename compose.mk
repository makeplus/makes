# https://github.com/docker/compose/releases

COMPOSE-VERSION ?= 2.40.1

ifndef COMPOSE-LOADED
COMPOSE-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
$(eval $(call include-local))

OA-linux-arm64 := linux-aarch64
OA-linux-int64 := linux-x86_64
OA-macos-arm64 := darwin-aarch64
OA-macos-int64 := darwin-x86_64

COMPOSE-BIN := docker-compose-$(OA-$(OS-ARCH))
COMPOSE-DOWN := https://github.com/docker/compose/releases/download
COMPOSE-DOWN := $(COMPOSE-DOWN)/v$(COMPOSE-VERSION)/$(COMPOSE-BIN)

COMPOSE := $(LOCAL-BIN)/docker-compose-$(COMPOSE-VERSION)

SHELL-DEPS += $(COMPOSE)


$(COMPOSE):
	curl+ $(COMPOSE-DOWN) > $@
	chmod +x $@
	ln -s docker-compose-$(COMPOSE-VERSION) $(LOCAL-BIN)/docker-compose
	@$(ECHO)

endif
