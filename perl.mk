PERL-VERSION ?= 5.42.0.0

ifndef PERL-LOADED
PERL-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
$(eval $(call include-local))

OA-linux-arm64 := linux-arm64
OA-linux-int64 := linux-amd64
OA-macos-arm64 := darwin-arm64
OA-macos-int64 := darwin-amd64

PERL-DIR := perl-$(OA-$(OS-ARCH))
PERL-TAR := $(PERL-DIR).tar.gz
PERL-DOWN := https://github.com/skaji/relocatable-perl/releases/download
PERL-DOWN := $(PERL-DOWN)/$(PERL-VERSION)/$(PERL-TAR)

ifeq ($(OS-NAME),windows)
# Use system Perl on Windows (GitHub Actions runners have Strawberry Perl)
PERL := $(LOCAL-BIN)/perl

.PHONY: $(PERL)
$(PERL):
	@which perl > /dev/null 2>&1 || (echo "ERROR: perl not found in PATH" && exit 1)
	@mkdir -p $(LOCAL-BIN)
	@touch $@
else
PERL-LOCAL := $(LOCAL-ROOT)/perl-$(PERL-VERSION)
PERL-BIN := $(PERL-LOCAL)/bin
override PATH := $(PERL-BIN):$(PATH)

PERL := $(LOCAL-BIN)/perl

SHELL-DEPS += $(PERL)

$(PERL): $(LOCAL-CACHE)/$(PERL-TAR)
	tar -C $(LOCAL-CACHE) -xzf $<
	mv $(LOCAL-CACHE)/$(PERL-DIR) $(PERL-LOCAL)
	touch $@
	@echo
endif

$(LOCAL-CACHE)/$(PERL-TAR):
	@echo "* Installing 'perl' locally"
	curl+ $(PERL-DOWN) > $@

endif
