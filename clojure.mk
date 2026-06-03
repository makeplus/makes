CLOJURE-VERSION ?= 1.12.4.1602
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

CLOJURE-LOCAL := $(LOCAL-ROOT)/clojure-$(CLOJURE-VERSION)
CLOJURE := $(CLOJURE-LOCAL)/bin/clojure

SHELL-DEPS += $(CLOJURE)

override PATH := $(CLOJURE-LOCAL)/bin:$(PATH)
export PATH


$(CLOJURE): $(CLOJURE-DEPS) $(JAVA)
	@$(ECHO) "* Installing 'clojure' locally"
	$Q bash <(curl+ $(CLOJURE-DOWN)) -p $(CLOJURE-LOCAL) $O
	$Q touch $@
	@$(ECHO)

endif
