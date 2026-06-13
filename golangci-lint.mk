GOLANGCI-LINT-VERSION ?= 2.12.2
# https://github.com/golangci/golangci-lint

ifndef GOLANGCI-LINT-LOADED
GOLANGCI-LINT-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
include $(MAKES)/go.mk

GOLANGCI-LINT-PKG := github.com/golangci/golangci-lint/v2/cmd/golangci-lint@v$(GOLANGCI-LINT-VERSION)
GOLANGCI-LINT-LOCAL := $(LOCAL-ROOT)/golangci-lint-$(GOLANGCI-LINT-VERSION)
GOLANGCI-LINT-BIN := $(GOLANGCI-LINT-LOCAL)/bin/golangci-lint
GOLANGCI-LINT := $(LOCAL-BIN)/golangci-lint

SHELL-DEPS += $(GOLANGCI-LINT)

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

endif
