BABASHKA-VERSION ?= 1.12.213

ifndef BABASHKA-LOADED
BABASHKA-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
$(eval $(call include-local))

OA-linux-arm64 := linux-aarch64-static
OA-linux-int64 := linux-amd64-static
OA-macos-arm64 := macos-aarch64
OA-macos-int64 := macos-amd64
OA-windows-int64 := windows-amd64

ifeq (windows,$(OS-NAME))
BABASHKA-EXT := zip
else
BABASHKA-EXT := tar.gz
endif

BABASHKA-DIR := babashka-$(BABASHKA-VERSION)-$(OA-$(OS-ARCH))
BABASHKA-TAR := $(BABASHKA-DIR).$(BABASHKA-EXT)
BABASHKA-DOWN := https://github.com/babashka/babashka
BABASHKA-DOWN := $(BABASHKA-DOWN)/releases/download/v$(BABASHKA-VERSION)/$(BABASHKA-TAR)

ifeq (windows,$(OS-NAME))
BB-EXE := bb.exe
else
BB-EXE := bb
endif

BB := $(LOCAL-BIN)/bb

SHELL-DEPS += $(BB)


$(BB): $(LOCAL-CACHE)/$(BABASHKA-TAR)
ifeq (windows,$(OS-NAME))
	$Q unzip -q -d $(LOCAL-CACHE) $<
else
	$Q tar -C $(LOCAL-CACHE) -xf $<
endif
	$Q [[ -e $(LOCAL-CACHE)/$(BB-EXE) ]]
	$Q mv $(LOCAL-CACHE)/$(BB-EXE) $(LOCAL-BIN)/
	$Q touch $@
	@$(ECHO)

$(LOCAL-CACHE)/$(BABASHKA-TAR):
	@$(ECHO) "* Installing 'bb' locally"
	$Q curl+ $(BABASHKA-DOWN) > $@

endif
