RAKU-VERSION ?= 2026.05-01
# https://rakudo.org/dl/rakudo

ifndef RAKU-LOADED
RAKU-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
$(eval $(call include-local))

OA-linux-arm64 := XXX
OA-linux-int64 := linux-x86_64-gcc
OA-macos-arm64 := macos-arm64-clang
OA-macos-int64 := macos-x86_64-clang
OA-windows-int64 := win-x86_64-msvc

RAKU-DIR := rakudo-moar-$(RAKU-VERSION)-$(OA-$(OS-ARCH))
ifeq ($(OS-NAME),windows)
RAKU-TAR := $(RAKU-DIR).zip
else
RAKU-TAR := $(RAKU-DIR).tar.gz
endif
RAKU-DOWN := https://rakudo.org/dl/rakudo
RAKU-DOWN := $(RAKU-DOWN)/$(RAKU-TAR)

RAKU-LOCAL := $(LOCAL-ROOT)/$(RAKU-DIR)
RAKU-SITE := $(RAKU-LOCAL)/share/perl6/site
RAKU-SITE-BIN := $(RAKU-SITE)/bin
RAKU-SITE-LIB := $(RAKU-SITE)/lib
RAKU-BIN := $(RAKU-LOCAL)/bin
override PATH := $(RAKU-BIN):$(RAKU-SITE-BIN):$(PATH)
export PATH

ifeq ($(OS-NAME),windows)
RAKU := $(RAKU-BIN)/raku.exe
else
RAKU := $(RAKU-BIN)/raku
endif

SHELL-DEPS += $(RAKU)


ifeq ($(OS-NAME),windows)
$(RAKU): $(LOCAL-CACHE)/$(RAKU-TAR)
	cd $(LOCAL-CACHE) && unzip -q $(RAKU-TAR)
	mv $(LOCAL-CACHE)/$(RAKU-DIR) $(RAKU-LOCAL)
	touch $@
	@echo
else
$(RAKU): $(LOCAL-CACHE)/$(RAKU-TAR)
	tar -C $(LOCAL-CACHE) -xzf $<
	mv $(LOCAL-CACHE)/$(RAKU-DIR) $(RAKU-LOCAL)
	touch $@
	@echo
endif

$(LOCAL-CACHE)/$(RAKU-TAR):
	@echo "* Installing 'raku' locally"
	curl+ $(RAKU-DOWN) > $@

endif
