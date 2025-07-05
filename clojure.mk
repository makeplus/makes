CLOJURE-VERSION ?= 1.12.1.1550

ifndef CLOJURE-LOADED
CLOJURE-LOADED := true

$(if $(or $(JAVA-LOADED),$(GRAALVM-LOADED)),,\
$(error clojure.mk requires including java.mk or graalvm.mk first))

include $(MAKES)/maven.mk

$(if $(MAKES),,$(error Please 'include .makes/init.mk'))
$(eval $(call include-local))

CLOJURE-INSTALLER := \
  https://github.com/clojure/brew-install/releases/download/$(CLOJURE-VERSION)/posix-install.sh

CLOJURE := $(LOCAL-BIN)/clojure

SHELL-DEPS += $(CLOJURE)


$(CLOJURE): $(CLOJURE-DEPS) $(JAVA)
	@echo "Installing 'clojure' locally"
	bash <(curl+ $(CLOJURE-INSTALLER)) -p $(LOCAL-PREFIX)
	touch $@

endif
