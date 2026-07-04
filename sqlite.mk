SQLITE-VERSION ?= 3.53.3
SQLITE-VERSION-NUM ?= 3530300
# https://sqlite.org/download.html

ifndef SQLITE-LOADED
SQLITE-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
$(eval $(call include-local))

OA-linux-int64 := linux-x64
OA-macos-arm64 := osx-arm64
OA-macos-int64 := osx-x64
OA-windows-arm64 := win-arm64
OA-windows-int64 := win-x64

ifeq (windows,$(OS-NAME))
  SQLITE-EXE := sqlite3.exe
else
  SQLITE-EXE := sqlite3
endif

SQLITE-ZIP := sqlite-tools-$(OA-$(OS-ARCH))-$(SQLITE-VERSION-NUM).zip
SQLITE-DOWN := https://sqlite.org/2026/$(SQLITE-ZIP)
SQLITE-LOCAL := $(LOCAL-ROOT)/sqlite-$(SQLITE-VERSION)
SQLITE := $(SQLITE-LOCAL)/bin/$(SQLITE-EXE)

SHELL-DEPS += $(SQLITE)

override PATH := $(SQLITE-LOCAL)/bin:$(PATH)
export PATH


$(SQLITE): $(LOCAL-CACHE)/$(SQLITE-ZIP)
	$Q rm -rf $(LOCAL-TMP)/sqlite-$(SQLITE-VERSION)
	$Q mkdir -p $(SQLITE-LOCAL)/bin $(LOCAL-TMP)/sqlite-$(SQLITE-VERSION)
	$Q unzip -q $< -d $(LOCAL-TMP)/sqlite-$(SQLITE-VERSION)
	$Q cp $$(find $(LOCAL-TMP)/sqlite-$(SQLITE-VERSION) -name $(SQLITE-EXE) -type f | head -1) $@
	$Q chmod +x $@
	@$(ECHO)

$(LOCAL-CACHE)/$(SQLITE-ZIP):
	@$(ECHO) "* Installing 'sqlite' locally"
	$Q curl+ $(SQLITE-DOWN) > $@

endif
