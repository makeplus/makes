SCALA-CLI-VERSION ?= 1.15.0
# https://github.com/VirtusLab/scala-cli

ifndef SCALA-LOADED
SCALA-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
$(eval $(call include-local))

OA-linux-arm64 := aarch64-pc-linux
OA-linux-int64 := x86_64-pc-linux
OA-macos-arm64 := aarch64-apple-darwin
OA-macos-int64 := x86_64-apple-darwin
OA-windows-int64 := x86_64-pc-win32

ifeq (windows,$(OS-NAME))
  SCALA-CLI-ARC := scala-cli-$(OA-$(OS-ARCH)).zip
  SCALA-CLI-EXE := scala-cli.exe
else
  SCALA-CLI-ARC := scala-cli-$(OA-$(OS-ARCH)).gz
  SCALA-CLI-EXE := scala-cli
endif

SCALA-CLI-DOWN := https://github.com/VirtusLab/scala-cli/releases/download/v$(SCALA-CLI-VERSION)/$(SCALA-CLI-ARC)
SCALA-LOCAL := $(LOCAL-ROOT)/scala-cli-$(SCALA-CLI-VERSION)
SCALA-CLI := $(SCALA-LOCAL)/bin/$(SCALA-CLI-EXE)

SHELL-DEPS += $(SCALA-CLI)

override PATH := $(SCALA-LOCAL)/bin:$(PATH)
export PATH


$(SCALA-CLI): $(LOCAL-CACHE)/$(SCALA-CLI-ARC)
	$Q mkdir -p $(SCALA-LOCAL)/bin
ifeq (windows,$(OS-NAME))
	$Q unzip -q -j $< $(SCALA-CLI-EXE) -d $(SCALA-LOCAL)/bin
else
	$Q gzip -dc $< > $@
endif
	$Q chmod +x $@
	@$(ECHO)

$(LOCAL-CACHE)/$(SCALA-CLI-ARC):
	@$(ECHO) "* Installing 'scala-cli' locally"
	$Q curl+ $(SCALA-CLI-DOWN) > $@

endif
