RAKU-VERSION ?= 2025.06.1-01

ifndef RAKU-LOADED
RAKU-LOADED := true

$(if $(MAKES),,$(error Please 'include .makes/init.mk'))
$(eval $(call include-local))

OA-linux-arm64 := XXX
OA-linux-int64 := linux-x86_64-gcc
OA-macos-arm64 := macos-arm64-clang
OA-macos-int64 := macos-x86_64-clang

RAKU-DIR := rakudo-moar-$(RAKU-VERSION)-$(OA-$(OS-ARCH))
RAKU-TARBALL := $(RAKU-DIR).tar.gz
RAKU-DOWNLOAD := https://rakudo.org/dl/rakudo
RAKU-DOWNLOAD := $(RAKU-DOWNLOAD)/$(RAKU-TARBALL)

RAKU-LOCAL := $(LOCAL-ROOT)/$(RAKU-DIR)
RAKU-BIN := $(RAKU-LOCAL)/bin
RAKU-SITE := $(RAKU-LOCAL)/share/perl6/site
RAKU-SITE-BIN := $(RAKU-SITE)/bin
RAKU-SITE-LIB := $(RAKU-SITE)/lib
RAKU := $(RAKU-BIN)/raku

SHELL-DEPS += $(RAKU)

override PATH := $(RAKU-BIN):$(RAKU-SITE-BIN):$(PATH)


$(RAKU): $(LOCAL-CACHE)/$(RAKU-TARBALL)
	tar -C $(LOCAL-CACHE) -xzf $<
	mv $(LOCAL-CACHE)/$(RAKU-DIR) $(RAKU-LOCAL)
	touch $@
	@echo

$(LOCAL-CACHE)/$(RAKU-TARBALL):
	@echo "Installing 'raku' locally"
	curl+ $(RAKU-DOWNLOAD) > $@

endif
