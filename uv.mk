UV-VERSION ?= 0.12.19

ifndef UV-LOADED
UV-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
$(eval $(call include-local))

OA-linux-arm64 := aarch64-unknown-linux-gnu
OA-linux-int64 := x86_64-unknown-linux-gnu
OA-macos-arm64 := aarch64-apple-darwin
OA-macos-int64 := x86_64-apple-darwin
OA-windows-arm64 := aarch64-pc-windows-msvc
OA-windows-int64 := x86_64-pc-windows-msvc

UV-DIR := uv-$(OA-$(OS-ARCH))
ifeq ($(OS-NAME),windows)
UV-TAR := $(UV-DIR).zip
else
UV-TAR := $(UV-DIR).tar.gz
endif
UV-DOWN := https://github.com/astral-sh/uv/releases/download
UV-DOWN := $(UV-DOWN)/$(UV-VERSION)/$(UV-TAR)

UV := $(LOCAL-BIN)/uv
UVX := $(LOCAL-BIN)/uvx
UV-COMP-BASH := $(LOCAL-SHARE)/bash-completion/completions/uv
UV-COMP-ZSH := $(LOCAL-SHARE)/zsh/site-functions/_uv
UV-COMP-FISH := $(LOCAL-SHARE)/fish/vendor_completions.d/uv.fish
UVX-COMP-BASH := $(LOCAL-SHARE)/bash-completion/completions/uvx
UVX-COMP-ZSH := $(LOCAL-SHARE)/zsh/site-functions/_uvx
UVX-COMP-FISH := $(LOCAL-SHARE)/fish/vendor_completions.d/uvx.fish
UV-COMP := \
  $(UV-COMP-BASH) $(UV-COMP-ZSH) $(UV-COMP-FISH) \
  $(UVX-COMP-BASH) $(UVX-COMP-ZSH) $(UVX-COMP-FISH)

SHELL-DEPS += $(UV) $(UV-COMP)


ifeq ($(OS-NAME),windows)
$(UV): $(LOCAL-CACHE)/$(UV-TAR)
	$Q cd $(LOCAL-CACHE) && unzip -q $(UV-TAR)
	$Q cp $(LOCAL-CACHE)/uv.exe $(LOCAL-BIN)/
	$Q touch $@
	@$(ECHO)
else
$(UV): $(LOCAL-CACHE)/$(UV-TAR)
	$Q tar -C $(LOCAL-CACHE) -xzf $<
	$Q cp $(LOCAL-CACHE)/$(UV-DIR)/uv* $(LOCAL-BIN)/
	$Q touch $@
	@$(ECHO)
endif

$(LOCAL-CACHE)/$(UV-TAR):
	@$(ECHO) "* Installing 'uv' locally"
	$Q curl+ $(UV-DOWN) > $@

$(UV-COMP-BASH): $(UV)
	$Q mkdir -p $(@D)
	$Q $(UV) --generate-shell-completion bash > $@

$(UV-COMP-ZSH): $(UV)
	$Q mkdir -p $(@D)
	$Q $(UV) --generate-shell-completion zsh > $@

$(UV-COMP-FISH): $(UV)
	$Q mkdir -p $(@D)
	$Q $(UV) --generate-shell-completion fish > $@

$(UVX-COMP-BASH): $(UV)
	$Q mkdir -p $(@D)
	$Q $(UVX) --generate-shell-completion bash > $@

$(UVX-COMP-ZSH): $(UV)
	$Q mkdir -p $(@D)
	$Q $(UVX) --generate-shell-completion zsh > $@

$(UVX-COMP-FISH): $(UV)
	$Q mkdir -p $(@D)
	$Q $(UVX) --generate-shell-completion fish > $@

endif
