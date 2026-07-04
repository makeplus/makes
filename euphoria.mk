EUPHORIA-VERSION ?= 4.1.0
EUPHORIA-BUILD ?= 57179171dbed
# https://github.com/OpenEuphoria/euphoria

ifndef EUPHORIA-LOADED
EUPHORIA-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
$(eval $(call include-local))

OA-linux-int64 := Linux-x64
OA-macos-int64 := OSX-x64
OA-windows-int64 := Windows-x64

ifeq ($(OS-NAME),windows)
  EUPHORIA-EXT := zip
  EUI-EXE := eui.exe
else
  EUPHORIA-EXT := tar.gz
  EUI-EXE := eui
endif

EUPHORIA-ARC := euphoria-$(EUPHORIA-VERSION)-$(OA-$(OS-ARCH))-$(EUPHORIA-BUILD).$(EUPHORIA-EXT)
EUPHORIA-DOWN := https://github.com/OpenEuphoria/euphoria/releases/download/$(EUPHORIA-VERSION)/$(EUPHORIA-ARC)
EUPHORIA-LOCAL := $(LOCAL-ROOT)/euphoria-$(EUPHORIA-VERSION)
EUI := $(EUPHORIA-LOCAL)/bin/$(EUI-EXE)

SHELL-DEPS += $(EUI)

override PATH := $(EUPHORIA-LOCAL)/bin:$(PATH)
export PATH
export EUDIR := $(EUPHORIA-LOCAL)


$(EUI): $(LOCAL-CACHE)/$(EUPHORIA-ARC)
	$Q rm -rf $(EUPHORIA-LOCAL) $(LOCAL-TMP)/euphoria-$(EUPHORIA-VERSION)
	$Q mkdir -p $(LOCAL-TMP)/euphoria-$(EUPHORIA-VERSION)
ifeq ($(OS-NAME),windows)
	$Q unzip -q $< -d $(LOCAL-TMP)/euphoria-$(EUPHORIA-VERSION)
else
	$Q tar -C $(LOCAL-TMP)/euphoria-$(EUPHORIA-VERSION) -xzf $<
endif
	$Q exe=$$(find $(LOCAL-TMP)/euphoria-$(EUPHORIA-VERSION) -name $(EUI-EXE) -type f | head -1); \
	  [[ -n "$$exe" ]]; \
	  mv "$${exe%/bin/$(EUI-EXE)}" $(EUPHORIA-LOCAL)
	$Q chmod +x $@
	@$(ECHO)

$(LOCAL-CACHE)/$(EUPHORIA-ARC):
	@$(ECHO) "* Installing 'euphoria' locally"
	$Q curl+ $(EUPHORIA-DOWN) > $@

endif
