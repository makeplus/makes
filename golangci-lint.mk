GOLANGCI-LINT-VERSION ?= 2.14.0
# https://github.com/golangci/golangci-lint

ifndef GOLANGCI-LINT-LOADED
GOLANGCI-LINT-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
include $(MAKES)/go.mk

GOLANGCI-LINT-PKG := github.com/golangci/golangci-lint/v2/cmd/golangci-lint@v$(GOLANGCI-LINT-VERSION)
GOLANGCI-LINT-LOCAL := $(LOCAL-ROOT)/golangci-lint-$(GOLANGCI-LINT-VERSION)
GOLANGCI-LINT-BIN := $(GOLANGCI-LINT-LOCAL)/bin/golangci-lint
GOLANGCI-LINT := $(LOCAL-BIN)/golangci-lint
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

$(GOLANGCI-LINT): $(GOLANGCI-LINT-BIN)
	$Q rm -f $@
	$Q ln -s $< $@
	@$(ECHO)

$(GOLANGCI-LINT-BIN): $(GO)
	@$(ECHO) "* Installing 'golangci-lint' locally"
	$Q mkdir -p $(dir $@)
	$Q GOBIN=$(dir $@) go install $(GOLANGCI-LINT-PKG) $O
	$Q touch $@
	@$(ECHO)

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
