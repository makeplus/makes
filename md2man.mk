MD2MAN-VERSION ?= 2.0.7
# https://github.com/cpuguy83/go-md2man

ifndef MD2MAN-LOADED
MD2MAN-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
include $(MAKES)/go.mk

MD2MAN-PKG := github.com/cpuguy83/go-md2man/v2@v$(MD2MAN-VERSION)
MD2MAN := $(LOCAL-BIN)/go-md2man

SHELL-DEPS += $(MD2MAN)

$(MD2MAN): $(GO)
	@$(ECHO) "* Installing 'go-md2man' locally"
	$Q GOBIN=$(LOCAL-BIN) go install $(MD2MAN-PKG) $O
	$Q touch $@
	@$(ECHO)

endif
