GOLANGCI-LINT-VERSION ?= 1.64.8
# https://github.com/golangci/golangci-lint

ifndef GOLANGCI-LINT-LOADED
GOLANGCI-LINT-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
include $(MAKES)/go.mk

GOLANGCI-LINT-PKG := github.com/golangci/golangci-lint/cmd/golangci-lint@v$(GOLANGCI-LINT-VERSION)
GOLANGCI-LINT := $(LOCAL-BIN)/golangci-lint

SHELL-DEPS += $(GOLANGCI-LINT)

$(GOLANGCI-LINT): $(GO)
	@$(ECHO) "* Installing 'golangci-lint' locally"
	$Q GOBIN=$(LOCAL-BIN) go install $(GOLANGCI-LINT-PKG) $O
	$Q touch $@
	@$(ECHO)

endif
