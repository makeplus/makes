JULIA-VER ?= 1.11
JULIA-VERSION ?= $(JULIA-VER).5

ifndef JULIA-LOADED
JULIA-LOADED := true

$(if $(MAKES),,$(error Please 'include .makes/init.mk'))
$(eval $(call include-local))

OA1-linux-arm64 := linux/aarch64
OA2-linux-arm64 := linux-aarch64
OA1-linux-int64 := linux/x64
OA2-linux-int64 := linux-x86_64
OA1-macos-arm64 := mac/aarch64
OA2-macos-arm64 := macaarch64
OA1-macos-int64 := mac/x64
OA2-macos-int64 := mac64

JULIA-DIR := julia-$(JULIA-VERSION)
JULIA-TARBALL := $(JULIA-DIR)-$(OA2-$(OS-ARCH)).tar.gz
JULIA-DOWNLOAD := https://julialang-s3.julialang.org/bin
JULIA-DOWNLOAD := \
  $(JULIA-DOWNLOAD)/$(OA1-$(OS-ARCH))/$(JULIA-VER)/$(JULIA-TARBALL)

JULIA-LOCAL := $(LOCAL-ROOT)/$(JULIA-DIR)
JULIA-BIN := $(JULIA-LOCAL)/bin
JULIA := $(JULIA-BIN)/julia

SHELL-DEPS += $(JULIA)

override PATH := $(JULIA-BIN):$(PATH)


$(JULIA): $(LOCAL-CACHE)/$(JULIA-TARBALL)
	tar -C $(LOCAL-CACHE) -xzf $<
	mv $(LOCAL-CACHE)/$(JULIA-DIR) $(JULIA-LOCAL)
	touch $@
	@echo

$(LOCAL-CACHE)/$(JULIA-TARBALL):
	@echo "Installing 'julia' locally"
	curl+ $(JULIA-DOWNLOAD) > $@

endif
