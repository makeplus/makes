PURESCRIPT-VERSION ?= 0.15.16
# https://github.com/purescript/purescript

ifndef PURESCRIPT-LOADED
PURESCRIPT-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
$(eval $(call include-local))

OA-linux-arm64 := linux-arm64
OA-linux-int64 := linux64
OA-macos-arm64 := macos-arm64
OA-macos-int64 := macos
OA-windows-int64 := win64

ifeq (windows,$(OS-NAME))
  PURESCRIPT-EXE := purs.exe
else
  PURESCRIPT-EXE := purs
endif

PURESCRIPT-TAR := $(OA-$(OS-ARCH)).tar.gz
PURESCRIPT-DOWN := https://github.com/purescript/purescript/releases/download/v$(PURESCRIPT-VERSION)/$(PURESCRIPT-TAR)
PURESCRIPT-LOCAL := $(LOCAL-ROOT)/purescript-$(PURESCRIPT-VERSION)
PURS := $(PURESCRIPT-LOCAL)/bin/$(PURESCRIPT-EXE)

SHELL-DEPS += $(PURS)

override PATH := $(PURESCRIPT-LOCAL)/bin:$(PATH)
export PATH


$(PURS): $(LOCAL-CACHE)/purescript-$(PURESCRIPT-VERSION)-$(PURESCRIPT-TAR)
	$Q rm -rf $(PURESCRIPT-LOCAL) $(LOCAL-TMP)/purescript-$(PURESCRIPT-VERSION)
	$Q mkdir -p $(PURESCRIPT-LOCAL)/bin $(LOCAL-TMP)/purescript-$(PURESCRIPT-VERSION)
	$Q tar -C $(LOCAL-TMP)/purescript-$(PURESCRIPT-VERSION) -xzf $<
	$Q cp $$(find $(LOCAL-TMP)/purescript-$(PURESCRIPT-VERSION) -name $(PURESCRIPT-EXE) -type f | head -1) $@
	$Q chmod +x $@
	@$(ECHO)

$(LOCAL-CACHE)/purescript-$(PURESCRIPT-VERSION)-$(PURESCRIPT-TAR):
	@$(ECHO) "* Installing 'purescript' locally"
	$Q curl+ $(PURESCRIPT-DOWN) > $@

endif
