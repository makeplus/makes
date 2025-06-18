$(if $(MAKES),,$(error Please 'include .makes/init.mk'))
$(eval $(call include-local))
include $(MAKES)/java.mk

CLOJURE-VERSION ?= 1.12.1.1550
CLOJURE-INSTALLER := \
  https://github.com/clojure/brew-install/releases/download/$(CLOJURE-VERSION)/posix-install.sh

CLOJURE := $(LOCAL-BIN)/clojure


$(CLOJURE): $(JAVA)
	@echo "Installing 'clojure' locally"
	bash <(curl -sL $(CLOJURE-INSTALLER)) -p $(LOCAL-PREFIX)
	touch $@
