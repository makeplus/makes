ODIN-VERSION ?= dev-2026-06
# https://github.com/odin-lang/Odin

ifndef ODIN-LOADED
ODIN-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
$(eval $(call include-local))

OA-linux-arm64 := linux-arm64-$(ODIN-VERSION)
OA-linux-int64 := linux-amd64-$(ODIN-VERSION)
OA-macos-arm64 := macos-arm64-dev-06
OA-macos-int64 := macos-amd64-$(ODIN-VERSION)
OA-windows-int64 := windows-$(ODIN-VERSION)

ifeq (windows,$(OS-NAME))
  ODIN-EXT := zip
  ODIN-EXE := odin.exe
else
  ODIN-EXT := tar.gz
  ODIN-EXE := odin
endif

ODIN-DIR := odin-$(OA-$(OS-ARCH))
ODIN-ARC := $(ODIN-DIR).$(ODIN-EXT)
ODIN-DOWN := https://github.com/odin-lang/Odin/releases/download/$(ODIN-VERSION)/$(ODIN-ARC)
ODIN-LOCAL := $(LOCAL-ROOT)/odin-$(ODIN-VERSION)
ODIN := $(ODIN-LOCAL)/$(ODIN-EXE)

SHELL-DEPS += $(ODIN)

override PATH := $(ODIN-LOCAL):$(PATH)
export PATH


$(ODIN): $(LOCAL-CACHE)/$(ODIN-ARC)
	$Q rm -rf $(ODIN-LOCAL) $(LOCAL-TMP)/odin-$(ODIN-VERSION)
	$Q mkdir -p $(LOCAL-TMP)/odin-$(ODIN-VERSION)
ifeq (windows,$(OS-NAME))
	$Q unzip -q $< -d $(LOCAL-TMP)/odin-$(ODIN-VERSION)
else
	$Q tar -C $(LOCAL-TMP)/odin-$(ODIN-VERSION) -xzf $<
endif
	$Q exe=$$(find $(LOCAL-TMP)/odin-$(ODIN-VERSION) -name $(ODIN-EXE) -type f | head -1); \
	  [[ -n "$$exe" ]]; \
	  mv "$${exe%/$(ODIN-EXE)}" $(ODIN-LOCAL)
	$Q touch $@
	@$(ECHO)

$(LOCAL-CACHE)/$(ODIN-ARC):
	@$(ECHO) "* Installing 'odin' locally"
	$Q curl+ $(ODIN-DOWN) > $@

endif
