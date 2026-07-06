VIMSCRIPT-VERSION ?= 0.12.4
# https://github.com/neovim/neovim

ifndef VIMSCRIPT-LOADED
VIMSCRIPT-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
$(eval $(call include-local))

NVIM-NAME-linux-arm64 := nvim-linux-arm64
NVIM-NAME-linux-int64 := nvim-linux-x86_64
NVIM-NAME-macos-arm64 := nvim-macos-arm64
NVIM-NAME-macos-int64 := nvim-macos-x86_64
NVIM-NAME-windows-arm64 := nvim-win-arm64
NVIM-NAME-windows-int64 := nvim-win64

ifeq (windows,$(OS-NAME))
  NVIM-EXT := zip
  NVIM-EXE := nvim.exe
else
  NVIM-EXT := tar.gz
  NVIM-EXE := nvim
endif

NVIM-NAME := $(NVIM-NAME-$(OS-ARCH))
NVIM-ARC := $(NVIM-NAME).$(NVIM-EXT)
NVIM-DOWN := https://github.com/neovim/neovim/releases/download/v$(VIMSCRIPT-VERSION)/$(NVIM-ARC)
VIMSCRIPT-LOCAL := $(LOCAL-ROOT)/vimscript-$(VIMSCRIPT-VERSION)
NVIM := $(VIMSCRIPT-LOCAL)/bin/$(NVIM-EXE)

SHELL-DEPS += $(NVIM)

override PATH := $(VIMSCRIPT-LOCAL)/bin:$(PATH)
export PATH


$(NVIM): $(LOCAL-CACHE)/$(NVIM-ARC)
	$Q rm -rf $(VIMSCRIPT-LOCAL) $(LOCAL-TMP)/vimscript-$(VIMSCRIPT-VERSION)
	$Q mkdir -p $(LOCAL-TMP)/vimscript-$(VIMSCRIPT-VERSION)
ifeq (windows,$(OS-NAME))
	$Q unzip -q $< -d $(LOCAL-TMP)/vimscript-$(VIMSCRIPT-VERSION)
else
	$Q tar -C $(LOCAL-TMP)/vimscript-$(VIMSCRIPT-VERSION) -xzf $<
endif
	$Q mv $(LOCAL-TMP)/vimscript-$(VIMSCRIPT-VERSION)/$(NVIM-NAME) $(VIMSCRIPT-LOCAL)
	$Q touch $@
	@$(ECHO)

$(LOCAL-CACHE)/$(NVIM-ARC):
	@$(ECHO) "* Installing 'vimscript' locally"
	$Q curl+ $(NVIM-DOWN) > $@

endif
