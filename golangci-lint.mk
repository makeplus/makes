GOLANGCI-LINT-VERSION ?= 2.14.0
# https://github.com/golangci/golangci-lint

ifndef GOLANGCI-LINT-LOADED
GOLANGCI-LINT-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
$(eval $(call include-local))

OA-linux-arm64 := linux-arm64
OA-linux-int64 := linux-amd64
OA-macos-arm64 := darwin-arm64
OA-macos-int64 := darwin-amd64
OA-windows-arm64 := windows-arm64
OA-windows-int64 := windows-amd64

ifeq (,$(OA-$(OS-ARCH)))
$(error 'golangci-lint' has no prebuilt binary for $(OS-ARCH); \
  see https://github.com/golangci/golangci-lint)
endif

ifeq (windows,$(OS-NAME))
GOLANGCI-LINT-ARC-EXT := zip
GOLANGCI-LINT-EXE := golangci-lint.exe
else
GOLANGCI-LINT-ARC-EXT := tar.gz
GOLANGCI-LINT-EXE := golangci-lint
endif

GOLANGCI-LINT-RELEASE := $(patsubst v%,%,$(GOLANGCI-LINT-VERSION))
GOLANGCI-LINT-DIR := \
  golangci-lint-$(GOLANGCI-LINT-RELEASE)-$(OA-$(OS-ARCH))
GOLANGCI-LINT-ARC := $(GOLANGCI-LINT-DIR).$(GOLANGCI-LINT-ARC-EXT)
GOLANGCI-LINT-DOWN := https://github.com/golangci/golangci-lint/releases/download
GOLANGCI-LINT-DOWN := \
  $(GOLANGCI-LINT-DOWN)/v$(GOLANGCI-LINT-RELEASE)/$(GOLANGCI-LINT-ARC)

GOLANGCI-LINT-LOCAL := $(LOCAL-ROOT)/golangci-lint-$(GOLANGCI-LINT-RELEASE)
GOLANGCI-LINT-TMP := $(LOCAL-TMP)/golangci-lint-$(GOLANGCI-LINT-RELEASE)
GOLANGCI-LINT-BIN := $(GOLANGCI-LINT-LOCAL)/bin/$(GOLANGCI-LINT-EXE)
GOLANGCI-LINT := $(GOLANGCI-LINT-BIN)
GOLANGCI-LINT-COMP-BASH := \
  $(LOCAL-SHARE)/bash-completion/completions/golangci-lint
GOLANGCI-LINT-COMP-ZSH := \
  $(LOCAL-SHARE)/zsh/site-functions/_golangci-lint
GOLANGCI-LINT-COMP-FISH := \
  $(LOCAL-SHARE)/fish/vendor_completions.d/golangci-lint.fish
GOLANGCI-LINT-COMP := \
  $(GOLANGCI-LINT-COMP-BASH) \
  $(GOLANGCI-LINT-COMP-ZSH) \
  $(GOLANGCI-LINT-COMP-FISH)

SHELL-DEPS += $(GOLANGCI-LINT) $(GOLANGCI-LINT-COMP)

override PATH := $(GOLANGCI-LINT-LOCAL)/bin:$(PATH)
export PATH


$(GOLANGCI-LINT): $(LOCAL-CACHE)/$(GOLANGCI-LINT-ARC)
	$Q rm -rf $(GOLANGCI-LINT-TMP)
	$Q mkdir -p $(GOLANGCI-LINT-LOCAL)/bin $(GOLANGCI-LINT-TMP)
	$Q case '$(GOLANGCI-LINT-ARC)' in \
	  *.zip) unzip -q $< -d $(GOLANGCI-LINT-TMP) ;; \
	  *) tar -C $(GOLANGCI-LINT-TMP) -xzf $< ;; \
	esac
	$Q cp $(GOLANGCI-LINT-TMP)/$(GOLANGCI-LINT-DIR)/$(GOLANGCI-LINT-EXE) $@
	$Q chmod +x $@
	$Q touch $@
	@$(ECHO)

$(LOCAL-CACHE)/$(GOLANGCI-LINT-ARC):
	@$(ECHO) "* Installing 'golangci-lint' locally"
	$Q curl+ $(GOLANGCI-LINT-DOWN) > $@

$(GOLANGCI-LINT-COMP-BASH): $(GOLANGCI-LINT)
	$Q mkdir -p $(@D)
	$Q $(GOLANGCI-LINT) completion bash > $@

$(GOLANGCI-LINT-COMP-ZSH): $(GOLANGCI-LINT)
	$Q mkdir -p $(@D)
	$Q $(GOLANGCI-LINT) completion zsh > $@

$(GOLANGCI-LINT-COMP-FISH): $(GOLANGCI-LINT)
	$Q mkdir -p $(@D)
	$Q $(GOLANGCI-LINT) completion fish > $@

endif
