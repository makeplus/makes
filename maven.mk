MAVEN-VERSION ?= 3.9.12
# https://github.com/apache/maven

ifndef MAVEN-LOADED
MAVEN-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
$(eval $(call include-local))
ifndef JAVA-LOADED
ifndef GRAALVM-LOADED
include $(MAKES)/java.mk
endif
endif

MAVEN-HOME := $(or $(MAVEN_HOME),$(LOCAL-HOME))
MAVEN-OPTS := -Duser.home=$(MAVEN-HOME)
export MAVEN_OPTS := $(MAVEN-OPTS)

MAVEN-DOWN := https://dlcdn.apache.org/maven/maven-3
MAVEN-DOWN := $(MAVEN-DOWN)/$(MAVEN-VERSION)/binaries
MAVEN-DIR := apache-maven-$(MAVEN-VERSION)
MAVEN-TAR := $(MAVEN-DIR)-bin.tar.gz
MAVEN-DIR := $(LOCAL-ROOT)/$(MAVEN-DIR)
MAVEN-DOWN := $(MAVEN-DOWN)/$(MAVEN-TAR)
MAVEN-BIN := $(MAVEN-DIR)/bin
override PATH := $(MAVEN-BIN):$(PATH)

MAVEN-REPOSITORY := $(LOCAL-HOME)/.m2/repository
MAVEN := $(MAVEN-BIN)/mvn

SHELL-DEPS += $(MAVEN)


$(MAVEN): $(LOCAL-CACHE)/$(MAVEN-TAR)
	tar -C $(LOCAL-ROOT) -xzf $<
	touch $@
	@echo

$(LOCAL-CACHE)/$(MAVEN-TAR):
	@echo "* Installing 'maven' locally"
	curl+ $(MAVEN-DOWN) > $@

endif
