CLOJURE-VERSION ?= 1.12.3.1577
# https://www.github.com/clojure/brew-install/releases/

ifndef CLOJURE-LOADED
CLOJURE-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
$(eval $(call include-local))
ifndef JAVA-LOADED
ifndef GRAALVM-LOADED
include $(MAKES)/java.mk
endif
endif

CLOJURE-DOWN := https://github.com/clojure/brew-install/releases/download
CLOJURE-DOWN := $(CLOJURE-DOWN)/$(CLOJURE-VERSION)/posix-install.sh

CLOJURE := $(LOCAL-BIN)/clojure

SHELL-DEPS += $(CLOJURE)


$(CLOJURE): $(CLOJURE-DEPS) $(JAVA)
	@echo "Installing 'clojure' locally"
	bash <(curl+ $(CLOJURE-DOWN)) -p $(LOCAL-PREFIX)
	touch $@

endif
