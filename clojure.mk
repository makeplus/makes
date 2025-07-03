ifndef CLOJURE-LOADED
CLOJURE-LOADED := true

$(if $(MAKES),,$(error Please 'include .makes/init.mk'))
$(eval $(call include-local))

ifndef GRAALVM-LOADED
CLOJURE-DEPS := $(GRAALVM)
else
include $(MAKES)/java.mk
CLOJURE-DEPS := $(JAVA)
endif

CLOJURE-VERSION ?= 1.12.1.1550
CLOJURE-INSTALLER := \
  https://github.com/clojure/brew-install/releases/download/$(CLOJURE-VERSION)/posix-install.sh

CLOJURE := $(LOCAL-BIN)/clojure

SHELL-DEPS += $(CLOJURE)


$(CLOJURE): $(CLOJURE-DEPS)
	@echo "Installing 'clojure' locally"
	bash <(curl+ $(CLOJURE-INSTALLER)) -p $(LOCAL-PREFIX)
	touch $@

endif
