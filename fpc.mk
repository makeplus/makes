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

FPC-ARCH := $(OA-$(OS-ARCH))

ifeq ($(OS-NAME),windows)
# Windows releases are InnoSetup installers only. This one bundles the
# native i386-win32 compiler with the x86_64-win64 cross tools, so
# 'fpc -Px86_64' can build 64 bit binaries.
FPC-ARCHIVE := fpc-$(FPC-VERSION).win32.and.win64.exe
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

ifeq ($(OS-NAME),windows)
FPC-BIN := $(FPC-LOCAL)/bin/i386-win32
FPC := $(FPC-BIN)/fpc.exe
# The installer generates fpc.cfg next to fpc.exe, where it is found
# automatically:
FPC-CFG := $(FPC-BIN)/fpc.cfg
else
FPC-BIN := $(FPC-LOCAL)/bin
FPC := $(FPC-BIN)/fpc
# A local config so fpc does not depend on ~/.fpc.cfg or /etc/fpc.cfg.
# Compile with: fpc -n @$(FPC-CFG) ...
FPC-CFG := $(FPC-LOCAL)/fpc.cfg
endif

override PATH := $(FPC-BIN):$(PATH)
export PATH

SHELL-DEPS += $(FPC)


# Install rules:
$(FPC): $(LOCAL-CACHE)/$(FPC-ARCHIVE)
	@$(ECHO) "Installing 'fpc' locally"
ifeq ($(OS-NAME),windows)
	$Q chmod +x $(LOCAL-CACHE)/$(FPC-ARCHIVE)
	$Q $(LOCAL-CACHE)/$(FPC-ARCHIVE) /VERYSILENT /SUPPRESSMSGBOXES \
	  /NORESTART "/DIR=$$(cygpath -w $(FPC-LOCAL))"
	$Q test -f $(FPC-CFG) || $(FPC-BIN)/fpcmkcfg.exe \
	  -d "basepath=$$(cygpath -m $(FPC-LOCAL))" \
	  -o "$$(cygpath -m $(FPC-CFG))"
else
	$Q cd $(LOCAL-CACHE) && tar -xf $(FPC-ARCHIVE)
	$Q cd $(LOCAL-CACHE)/fpc-$(FPC-VERSION).$(FPC-ARCH) && \
	  printf "$(FPC-LOCAL)\nn\nn\nn\nn\n" | bash install.sh > /dev/null 2>&1
	$Q rm -rf $(LOCAL-CACHE)/fpc-$(FPC-VERSION).$(FPC-ARCH)
	$Q $(FPC-BIN)/fpcmkcfg \
	  -d basepath=$(FPC-LOCAL)/lib/fpc/$(FPC-VERSION) -o $(FPC-CFG)
endif
	$Q touch $@
	@$(ECHO)

$(LOCAL-CACHE)/$(FPC-ARCHIVE):
	@$(ECHO) "Downloading 'fpc' archive"
	$Q curl+ $(FPC-DOWN) > $@

endif
