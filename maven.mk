ifndef MAVEN-LOADED
MAVEN-LOADED := true

$(if $(MAKES),,$(error Please 'include .makes/init.mk'))
$(eval $(call include-local))

MAVEN-VERSION ?= 3.9.10
MAVEN-SRC := https://dlcdn.apache.org/maven/maven-3/$(MAVEN-VERSION)/binaries
MAVEN-DIR := apache-maven-$(MAVEN-VERSION)
MAVEN-TARBALL := $(MAVEN-DIR)-bin.tar.gz
MAVEN-DIR := $(LOCAL-ROOT)/$(MAVEN-DIR)
MAVEN-URL := $(MAVEN-SRC)/$(MAVEN-TARBALL)
MAVEN-DOWNLOAD := $(LOCAL-CACHE)/$(MAVEN-TARBALL)
MAVEN-BIN := $(MAVEN-DIR)/bin
MAVEN-REPOSITORY := $(LOCAL-HOME)/.m2/repository
MAVEN := $(MAVEN-BIN)/mvn

SHELL-DEPS += $(MAVEN)

MAVEN-OPTS := -Duser.home=$(LOCAL-HOME)
export MAVEN_OPTS := $(MAVEN-OPTS)
override PATH := $(MAVEN-BIN):$(PATH)
export PATH


$(MAVEN): $(MAVEN-DOWNLOAD)
	tar -C $(LOCAL-ROOT) -xzf $<
	touch $@
	@echo

$(MAVEN-DOWNLOAD):
	@echo "Installing 'maven' locally"
	curl+ $(MAVEN-URL) > $@

endif
