JULIA-VERSION ?= 1.12.3
JULIA-VER ?= 1.12
# https://github.com/JuliaLang/julia

ifndef JULIA-LOADED
JULIA-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
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
JULIA-TAR := $(JULIA-DIR)-$(OA2-$(OS-ARCH)).tar.gz
JULIA-DOWN := https://julialang-s3.julialang.org/bin
JULIA-DOWN := \
  $(JULIA-DOWN)/$(OA1-$(OS-ARCH))/$(JULIA-VER)/$(JULIA-TAR)

JULIA-LOCAL := $(LOCAL-ROOT)/$(JULIA-DIR)
JULIA-BIN := $(JULIA-LOCAL)/bin
override PATH := $(JULIA-BIN):$(PATH)

JULIA := $(JULIA-BIN)/julia

SHELL-DEPS += $(JULIA)


$(JULIA): $(LOCAL-CACHE)/$(JULIA-TAR)
	tar -C $(LOCAL-CACHE) -xzf $<
	mv $(LOCAL-CACHE)/$(JULIA-DIR) $(JULIA-LOCAL)
	touch $@
	@echo

$(LOCAL-CACHE)/$(JULIA-TAR):
	@echo "* Installing 'julia' locally"
	curl+ $(JULIA-DOWN) > $@

endif
