CMAKE-VERSION ?= 4.4.4
# https://github.com/Kitware/CMake

ifndef CMAKE-LOADED
CMAKE-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
$(eval $(call include-local))

OA-linux-arm64 := linux-aarch64
OA-linux-int64 := linux-x86_64
OA-macos-arm64 := macos-universal
OA-macos-int64 := macos-universal

CMAKE-DIR := cmake-$(CMAKE-VERSION)-$(OA-$(OS-ARCH))
CMAKE-TAR := $(CMAKE-DIR).tar.gz
CMAKE-DOWN := https://github.com/Kitware/CMake/releases/download
CMAKE-DOWN := $(CMAKE-DOWN)/v$(CMAKE-VERSION)/$(CMAKE-TAR)

CMAKE-LOCAL := $(LOCAL-ROOT)/cmake-$(CMAKE-VERSION)
ifeq ($(OS-NAME),macos)
CMAKE-BIN := $(CMAKE-LOCAL)/CMake.app/Contents/bin
else
CMAKE-BIN := $(CMAKE-LOCAL)/bin
endif
override PATH := $(CMAKE-BIN):$(PATH)
export PATH

CMAKE := $(CMAKE-BIN)/cmake
CTEST := $(CMAKE-BIN)/ctest
CPACK := $(CMAKE-BIN)/cpack
CMAKE-SUPPORT := $(patsubst %/bin,%,$(CMAKE-BIN))
CMAKE-COMP-BASH := $(LOCAL-SHARE)/bash-completion/completions/cmake
CMAKE-COMP := $(CMAKE-COMP-BASH)
CMAKE-MAN := $(LOCAL-MAN)/man1/cmake.1

SHELL-DEPS += $(CMAKE) $(CMAKE-COMP) $(CMAKE-MAN)


$(CMAKE) $(CTEST) $(CPACK): $(LOCAL-CACHE)/$(CMAKE-TAR)
	tar -C $(LOCAL-CACHE) -xzf $<
	mv $(LOCAL-CACHE)/$(CMAKE-DIR) $(CMAKE-LOCAL)
	touch $(CMAKE) $(CTEST) $(CPACK)
	@echo

$(LOCAL-CACHE)/$(CMAKE-TAR):
	@echo "* Installing 'cmake' locally"
	curl+ $(CMAKE-DOWN) > $@

$(CMAKE-COMP-BASH): $(CMAKE)
	$Q mkdir -p $(@D)
	$Q cp $(CMAKE-SUPPORT)/share/bash-completion/completions/cmake $@

$(CMAKE-MAN): $(CMAKE)
	$Q mkdir -p $(@D)
	$Q cp $(CMAKE-SUPPORT)/man/man1/*.1 $(@D)/

endif
