GDSCRIPT-VERSION ?= 4.7-stable
# https://github.com/godotengine/godot

ifndef GDSCRIPT-LOADED
GDSCRIPT-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
$(eval $(call include-local))

OA-linux-arm64 := linux.arm64
OA-linux-int64 := linux.x86_64
OA-macos-arm64 := macos.universal
OA-macos-int64 := macos.universal
OA-windows-arm64 := windows_arm64.exe
OA-windows-int64 := win64.exe

$(if $(OA-$(OS-ARCH)),,$(error gdscript.mk does not support $(OS-ARCH)))

GDSCRIPT-ZIP := Godot_v$(GDSCRIPT-VERSION)_$(OA-$(OS-ARCH)).zip
GDSCRIPT-DOWN := https://github.com/godotengine/godot/releases/download/$(GDSCRIPT-VERSION)/$(GDSCRIPT-ZIP)
GDSCRIPT-LOCAL := $(LOCAL-ROOT)/gdscript-$(GDSCRIPT-VERSION)
ifeq ($(OS-NAME),windows)
GDSCRIPT := $(GDSCRIPT-LOCAL)/godot.exe
else
GDSCRIPT := $(GDSCRIPT-LOCAL)/godot
endif

SHELL-DEPS += $(GDSCRIPT)

override PATH := $(GDSCRIPT-LOCAL):$(PATH)
export PATH

$(GDSCRIPT): $(LOCAL-CACHE)/$(GDSCRIPT-ZIP)
	@$(ECHO) "* Installing 'gdscript' locally"
	$Q rm -rf $(GDSCRIPT-LOCAL) $(LOCAL-TMP)/gdscript-$(GDSCRIPT-VERSION)
	$Q mkdir -p $(GDSCRIPT-LOCAL) $(LOCAL-TMP)/gdscript-$(GDSCRIPT-VERSION)
	$Q unzip -q -d $(LOCAL-TMP)/gdscript-$(GDSCRIPT-VERSION) $<
ifeq ($(OS-NAME),macos)
	$Q cp -R $(LOCAL-TMP)/gdscript-$(GDSCRIPT-VERSION)/Godot.app $(GDSCRIPT-LOCAL)/
	$Q ln -sf $(GDSCRIPT-LOCAL)/Godot.app/Contents/MacOS/Godot $@
else ifeq ($(OS-NAME),windows)
	$Q cp $$(find $(LOCAL-TMP)/gdscript-$(GDSCRIPT-VERSION) -type f -name '*.exe' | head -1) $@
else
	$Q cp $$(find $(LOCAL-TMP)/gdscript-$(GDSCRIPT-VERSION) -type f -name 'Godot_*' | head -1) $@
	$Q chmod +x $@
endif
	@$(ECHO)

$(LOCAL-CACHE)/$(GDSCRIPT-ZIP):
	@$(ECHO) "* Downloading 'gdscript' archive"
	$Q curl+ $(GDSCRIPT-DOWN) > $@

endif
