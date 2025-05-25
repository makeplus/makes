ifndef MAKES-INIT
$(error Please 'include .makes/init.mk')
endif
ifndef MAKES-LOCAL
include $(MAKES)/local.mk
endif

YS-VERSION ?= 0.1.96

YS := $(LOCAL-PREFIX)/bin/ys-$(YS-VERSION)


$(YS):
	curl -s https://yamlscript.org/install | \
	  BIN=1 \
	  VERSION=$(YS-VERSION) \
	  PREFIX=$(LOCAL-PREFIX) \
	  bash
