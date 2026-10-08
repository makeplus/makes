PANDOC-VERSION ?= 3.12.1
# https://github.com/jgm/pandoc

ifndef PANDOC-LOADED
PANDOC-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
$(eval $(call include-local))

OA-linux-arm64 := linux-arm64
OA-linux-int64 := linux-amd64
OA-macos-arm64 := arm64-macOS
OA-macos-int64 := x86_64-macOS

PANDOC-NAME := pandoc-$(PANDOC-VERSION)-$(OA-$(OS-ARCH))
PANDOC-TAR := $(PANDOC-NAME).$(if $(IS-MACOS),zip,tar.gz)
PANDOC-DOWN := https://github.com/jgm/pandoc/releases/download
PANDOC-DOWN := $(PANDOC-DOWN)/$(PANDOC-VERSION)/$(PANDOC-TAR)

PANDOC := $(LOCAL-BIN)/pandoc
PANDOC-COMP-BASH := $(LOCAL-SHARE)/bash-completion/completions/pandoc
PANDOC-COMP := $(PANDOC-COMP-BASH)
PANDOC-MAN := $(LOCAL-MAN)/man1/pandoc.1.gz

SHELL-DEPS += $(PANDOC) $(PANDOC-COMP) $(PANDOC-MAN)


$(PANDOC): $(LOCAL-CACHE)/$(PANDOC-TAR)
ifdef IS-MACOS
	cd $(LOCAL-BIN) && unzip -j $< '*/bin/pandoc'
else
	tar --strip-components=2 -C $(LOCAL-BIN) -xf $< pandoc-$(PANDOC-VERSION)/bin/pandoc
endif
	[[ -e $@ ]]
	@touch $@
	@echo

$(LOCAL-CACHE)/$(PANDOC-TAR):
	@echo "* Installing 'pandoc' locally"
	curl+ $(PANDOC-DOWN) > $@
	@touch $@

$(PANDOC-COMP-BASH): $(PANDOC)
	$Q mkdir -p $(@D)
	$Q $(PANDOC) --bash-completion > $@

$(PANDOC-MAN): $(LOCAL-CACHE)/$(PANDOC-TAR)
	$Q mkdir -p $(@D)
	$Q tar -xOf $< \
	  pandoc-$(PANDOC-VERSION)/share/man/man1/pandoc.1.gz > $@

endif
