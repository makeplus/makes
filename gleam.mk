GLEAM-VERSION ?= 1.17.0
# https://github.com/gleam-lang/gleam

ifndef GLEAM-LOADED
GLEAM-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
$(eval $(call include-local))

OA-linux-arm64 := aarch64-unknown-linux-musl
OA-linux-int64 := x86_64-unknown-linux-musl
OA-macos-arm64 := aarch64-apple-darwin
OA-macos-int64 := x86_64-apple-darwin
OA-windows-arm64 := aarch64-pc-windows-msvc
OA-windows-int64 := x86_64-pc-windows-msvc

ifeq (windows,$(OS-NAME))
  GLEAM-EXT := zip
  GLEAM-EXE := gleam.exe
else
  GLEAM-EXT := tar.gz
  GLEAM-EXE := gleam
endif

GLEAM-ARC := gleam-v$(GLEAM-VERSION)-$(OA-$(OS-ARCH)).$(GLEAM-EXT)
GLEAM-DOWN := https://github.com/gleam-lang/gleam/releases/download/v$(GLEAM-VERSION)/$(GLEAM-ARC)
GLEAM-LOCAL := $(LOCAL-ROOT)/gleam-$(GLEAM-VERSION)
GLEAM := $(GLEAM-LOCAL)/bin/$(GLEAM-EXE)

SHELL-DEPS += $(GLEAM)

override PATH := $(GLEAM-LOCAL)/bin:$(PATH)
export PATH


$(GLEAM): $(LOCAL-CACHE)/$(GLEAM-ARC)
	$Q rm -rf $(GLEAM-LOCAL)
	$Q mkdir -p $(GLEAM-LOCAL)/bin
ifeq (windows,$(OS-NAME))
	$Q unzip -q -j $< $(GLEAM-EXE) -d $(GLEAM-LOCAL)/bin
else
	$Q tar -C $(GLEAM-LOCAL)/bin -xzf $< gleam
endif
	$Q chmod +x $@
	@$(ECHO)

$(LOCAL-CACHE)/$(GLEAM-ARC):
	@$(ECHO) "* Installing 'gleam' locally"
	$Q curl+ $(GLEAM-DOWN) > $@

endif
