OS-TYPE := $(shell bash -c 'echo $$OSTYPE')
ARCH-TYPE := $(shell bash -c 'echo $$MACHTYPE')
OS-NAME := $(shell cut -f1 -d- <<<'$(OS-TYPE)')
ARCH-NAME := $(shell cut -f1 -d- <<<'$(ARCH-TYPE)')
OS-ARCH := $(OS-NAME)_$(ARCH-NAME)

# =linux-gnu=x86_64-pc-linux-gnu=

USER-UID := $(shell id -u)
USER-GID := $(shell id -g)

ifeq (0,$(USER-UID))
IS-ROOT := true
endif
