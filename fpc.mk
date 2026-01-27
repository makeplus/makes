FPC-VERSION ?= 3.2.2
# https://github.com/fpc/FPCSource

ifndef FPC-LOADED
FPC-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
$(eval $(call include-local))

OA-linux-arm64 := aarch64-linux
OA-linux-int64 := x86_64-linux
OA-macos-arm64 := intelarm64-macosx
OA-macos-int64 := intelarm64-macosx
OA-windows-arm64 := aarch64-win64
OA-windows-int64 := x86_64-win64

FPC-ARCH := $(OA-$(OS-ARCH))

ifeq ($(OS-NAME),windows)
FPC-EXT := zip
FPC-ARCHIVE := fpc-$(FPC-VERSION).$(FPC-ARCH).$(FPC-EXT)
FPC-DOWN := https://sourceforge.net/projects/freepascal/files/Win32/$(FPC-VERSION)/$(FPC-ARCHIVE)/download
else
FPC-EXT := tar
FPC-ARCHIVE := fpc-$(FPC-VERSION).$(FPC-ARCH).$(FPC-EXT)
FPC-DOWN := https://sourceforge.net/projects/freepascal/files
ifeq ($(OS-NAME),macos)
FPC-DOWN := $(FPC-DOWN)/Mac%20OS%20X/$(FPC-VERSION)/$(FPC-ARCHIVE)/download
else
FPC-DOWN := $(FPC-DOWN)/Linux/$(FPC-VERSION)/$(FPC-ARCHIVE)/download
endif
endif

FPC-LOCAL := $(LOCAL-ROOT)/fpc-$(FPC-VERSION)
FPC-BIN := $(FPC-LOCAL)/bin
override PATH := $(FPC-BIN):$(PATH)

ifeq ($(OS-NAME),windows)
FPC := $(FPC-BIN)/fpc.exe
else
FPC := $(FPC-BIN)/fpc
endif

SHELL-DEPS += $(FPC)


# Install rules:
$(FPC): $(LOCAL-CACHE)/$(FPC-ARCHIVE)
	@$(ECHO) "Installing 'fpc' locally"
ifeq ($(OS-NAME),windows)
	$Q cd $(LOCAL-CACHE) && unzip -q $(FPC-ARCHIVE)
	$Q mv $(LOCAL-CACHE)/fpc-$(FPC-VERSION) $(FPC-LOCAL)
else
	$Q cd $(LOCAL-CACHE) && tar -xf $(FPC-ARCHIVE)
	$Q cd $(LOCAL-CACHE)/fpc-$(FPC-VERSION).$(FPC-ARCH) && \
	  printf "$(FPC-LOCAL)\nn\nn\nn\nn\n" | sh install.sh > /dev/null 2>&1
	$Q rm -rf $(LOCAL-CACHE)/fpc-$(FPC-VERSION).$(FPC-ARCH)
endif
	$Q touch $@
	@$(ECHO)

$(LOCAL-CACHE)/$(FPC-ARCHIVE):
	@$(ECHO) "Downloading 'fpc' archive"
	$Q curl+ $(FPC-DOWN) > $@

endif
