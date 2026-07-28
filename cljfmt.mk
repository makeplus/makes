CLJFMT-VERSION ?= 0.16.5
# https://github.com/weavejester/cljfmt

ifndef CLJFMT-LOADED
CLJFMT-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
$(eval $(call include-local))

OA-linux-arm64 := linux-aarch64
OA-linux-int64 := linux-amd64-static
OA-macos-arm64 := darwin-aarch64
OA-macos-int64 := darwin-amd64
OA-windows-arm64 :=
OA-windows-int64 := win-amd64

ifeq (,$(OA-$(OS-ARCH)))
$(error 'cljfmt' has no prebuilt binary for $(OS-ARCH); see https://github.com/weavejester/cljfmt)
endif

ifeq (windows,$(OS-NAME))
CLJFMT-ARC-EXT := zip
CLJFMT-EXE := cljfmt.exe
else
CLJFMT-ARC-EXT := tar.gz
CLJFMT-EXE := cljfmt
endif

CLJFMT-ARC := cljfmt-$(CLJFMT-VERSION)-$(OA-$(OS-ARCH)).$(CLJFMT-ARC-EXT)
CLJFMT-DOWN := https://github.com/weavejester/cljfmt
CLJFMT-DOWN := $(CLJFMT-DOWN)/releases/download/$(CLJFMT-VERSION)/$(CLJFMT-ARC)

CLJFMT-LOCAL := $(LOCAL-ROOT)/cljfmt-$(CLJFMT-VERSION)
CLJFMT := $(CLJFMT-LOCAL)/bin/$(CLJFMT-EXE)

SHELL-DEPS += $(CLJFMT)

override PATH := $(CLJFMT-LOCAL)/bin:$(PATH)
export PATH


$(CLJFMT): $(LOCAL-CACHE)/$(CLJFMT-ARC)
	$Q mkdir -p $(CLJFMT-LOCAL)/bin
ifeq (windows,$(OS-NAME))
	$Q unzip -oq $< -d $(CLJFMT-LOCAL)/bin
else
	$Q tar -C $(CLJFMT-LOCAL)/bin -xzf $<
endif
	$Q [[ -e $@ ]]
	$Q chmod +x $@
	$Q touch $@
	@$(ECHO)

$(LOCAL-CACHE)/$(CLJFMT-ARC):
	@$(ECHO) "* Installing 'cljfmt' locally"
	$Q curl+ $(CLJFMT-DOWN) > $@

endif
