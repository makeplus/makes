TINYGO-VERSION ?= 0.42.0
# https://github.com/tinygo-org/tinygo

ifndef TINYGO-LOADED
TINYGO-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
$(eval $(call include-local))

OA-linux-arm64 := linux-arm64
OA-linux-int64 := linux-amd64
OA-macos-arm64 := darwin-arm64
OA-macos-int64 := darwin-amd64
OA-windows-int64 := windows-amd64

ifeq (,$(OA-$(OS-ARCH)))
$(error 'tinygo' has no prebuilt binary for $(OS-ARCH); \
  see https://github.com/tinygo-org/tinygo)
endif

ifeq (windows,$(OS-NAME))
TINYGO-ARC-EXT := zip
TINYGO-EXE := tinygo.exe
else
TINYGO-ARC-EXT := tar.gz
TINYGO-EXE := tinygo
endif

TINYGO-ARC := tinygo$(TINYGO-VERSION).$(OA-$(OS-ARCH)).$(TINYGO-ARC-EXT)
TINYGO-DOWN := https://github.com/tinygo-org/tinygo/releases/download
TINYGO-DOWN := $(TINYGO-DOWN)/v$(TINYGO-VERSION)/$(TINYGO-ARC)

TINYGO-DIR := tinygo-$(TINYGO-VERSION)
TINYGO-TAR := $(TINYGO-ARC)
TINYGO-LOCAL := $(LOCAL-ROOT)/$(TINYGO-DIR)
TINYGO-BIN := $(TINYGO-LOCAL)/bin
TINYGO-TMP := $(LOCAL-TMP)/tinygo-$(TINYGO-VERSION)
TINYGO := $(TINYGO-BIN)/$(TINYGO-EXE)

SHELL-DEPS += $(TINYGO)

override PATH := $(TINYGO-LOCAL)/bin:$(PATH)
export PATH


$(TINYGO): $(LOCAL-CACHE)/$(TINYGO-ARC)
	$Q rm -rf $(TINYGO-TMP)
	$Q mkdir -p $(TINYGO-TMP)
	$Q case '$(TINYGO-ARC)' in \
	  *.zip) unzip -q $< -d $(TINYGO-TMP) ;; \
	  *) tar -C $(TINYGO-TMP) -xzf $< ;; \
	esac
	$Q [[ -e $(TINYGO-TMP)/tinygo/bin/$(TINYGO-EXE) ]]
	$Q rm -rf $(TINYGO-LOCAL)
	$Q mv $(TINYGO-TMP)/tinygo $(TINYGO-LOCAL)
	$Q rmdir $(TINYGO-TMP)
	$Q [[ -e $@ ]]
	$Q chmod +x $@
	$Q touch $@
	@$(ECHO)

$(LOCAL-CACHE)/$(TINYGO-ARC):
	@$(ECHO) "* Installing 'tinygo' locally"
	$Q curl+ $(TINYGO-DOWN) > $@

endif
