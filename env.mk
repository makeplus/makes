OS-TYPE := $(shell bash -c 'echo $$OSTYPE')
ARCH-TYPE := $(shell bash -c 'echo $$MACHTYPE')

USER-UID := $(shell id -u)
USER-GID := $(shell id -g)

ifeq (0,$(USER-UID))
IS-ROOT := true
endif
