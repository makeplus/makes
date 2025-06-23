$(if $(MAKES),,$(error Please 'include .makes/init.mk'))
$(eval $(call include-local))

YS-VERSION ?= 0.1.97

YS := $(LOCAL-PREFIX)/bin/ys-$(YS-VERSION)


$(YS):
	@echo 'Installing ys-$(YS-VERSION)'
	curl -s https://yamlscript.org/install | \
	  BIN=1 \
	  VERSION=$(YS-VERSION) \
	  PREFIX=$(LOCAL-PREFIX) \
	  bash
	@echo
