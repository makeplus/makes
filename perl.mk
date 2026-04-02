PERL-VERSION ?= 5.42.2.0

ifndef PERL-LOADED
PERL-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
$(eval $(call include-local))

OA-linux-arm64 := linux-arm64
OA-linux-int64 := linux-amd64
OA-macos-arm64 := darwin-arm64
OA-macos-int64 := darwin-amd64

PERL-DIR := perl-$(OA-$(OS-ARCH))
PERL-TAR := perl-$(PERL-VERSION)-$(OA-$(OS-ARCH)).tar.gz
PERL-DOWN := https://github.com/skaji/relocatable-perl/releases/download
PERL-DOWN := $(PERL-DOWN)/$(PERL-VERSION)/$(PERL-DIR).tar.gz

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
export PATH

PERL_CPANM_HOME := $(LOCAL-ROOT)/cpanm
export PERL_CPANM_HOME

PERL-CPANFILE-DEPS := $(PERL-LOCAL)/.cpan-deps-installed


PERL := $(LOCAL-BIN)/perl
PERL-CPAN-DEPS := $(PERL-LOCAL)/.cpan-deps-installed
PERL-LINK := $(LOCAL-BIN)/.perl-$(PERL-VERSION)

SHELL-DEPS += $(PERL)

$(PERL): $(PERL-LINK)

$(PERL-LINK): $(PERL-LOCAL)/bin/perl
	rm -f $(LOCAL-BIN)/.perl-*
	ln -sf $< $(PERL)
	touch $@

$(PERL-LOCAL)/bin/perl: $(LOCAL-CACHE)/$(PERL-TAR)
	tar -C $(LOCAL-CACHE) -xzf $<
	rm -rf $(PERL-LOCAL)
	mv $(LOCAL-CACHE)/$(PERL-DIR) $(PERL-LOCAL)
	touch $@
	@echo

$(LOCAL-CACHE)/$(PERL-TAR):
	@echo "* Installing 'perl' locally"
	curl+ $(PERL-DOWN) > $@

ifneq (,$(wildcard Makefile.PL))
Makefile: Makefile.PL $(PERL-LINK)
	perl $<
endif

$(PERL-CPANFILE-DEPS): Makefile.PL cpanfile $(PERL)
	cpanm -n --installdeps .
	touch $@

endif

PERL-RELEASES-URL := https://api.github.com/repos/skaji/relocatable-perl/releases
perl-versions:
	@curl -sL '$(PERL-RELEASES-URL)?per_page=100' | \
	grep '"tag_name"' | \
	sed 's/.*: "//;s/".*//'

endif
