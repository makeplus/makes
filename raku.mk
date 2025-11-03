RAKU-VERSION ?= 2025.10-01
# https://rakudo.org/dl/rakudo

ifndef RAKU-LOADED
RAKU-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
$(eval $(call include-local))

OA-linux-arm64 := XXX
OA-linux-int64 := linux-x86_64-gcc
OA-macos-arm64 := macos-arm64-clang
OA-macos-int64 := macos-x86_64-clang

RAKU-DIR := rakudo-moar-$(RAKU-VERSION)-$(OA-$(OS-ARCH))
RAKU-TAR := $(RAKU-DIR).tar.gz
RAKU-DOWN := https://rakudo.org/dl/rakudo
RAKU-DOWN := $(RAKU-DOWN)/$(RAKU-TAR)

RAKU-LOCAL := $(LOCAL-ROOT)/$(RAKU-DIR)
RAKU-SITE := $(RAKU-LOCAL)/share/perl6/site
RAKU-SITE-BIN := $(RAKU-SITE)/bin
RAKU-SITE-LIB := $(RAKU-SITE)/lib
RAKU-BIN := $(RAKU-LOCAL)/bin
override PATH := $(RAKU-BIN):$(RAKU-SITE-BIN):$(PATH)

RAKU := $(RAKU-BIN)/raku

SHELL-DEPS += $(RAKU)


$(RAKU): $(LOCAL-CACHE)/$(RAKU-TAR)
	tar -C $(LOCAL-CACHE) -xzf $<
	mv $(LOCAL-CACHE)/$(RAKU-DIR) $(RAKU-LOCAL)
	touch $@
	@echo

$(LOCAL-CACHE)/$(RAKU-TAR):
	@echo "* Installing 'raku' locally"
	curl+ $(RAKU-DOWN) > $@

endif
