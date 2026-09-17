# https://github.com/yaml/go-yaml

ifndef GO-YAML-LOADED
GO-YAML-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
include $(MAKES)/go.mk

GO-YAML-PKG := go.yaml.in/yaml/v4/cmd/go-yaml@main
GO-YAML := $(LOCAL-BIN)/go-yaml

SHELL-DEPS += $(GO-YAML)

$(GO-YAML): $(GO)
	@$(ECHO) "* Installing 'go-yaml' locally"
	$Q GOBIN=$(LOCAL-BIN) $(GO) install $(GO-YAML-PKG) $O
	$Q touch $@
	@$(ECHO)

endif
