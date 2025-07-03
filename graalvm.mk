ifndef GRAALVM-LOADED
GRAALVM-LOADED := true

$(if $(MAKES),,$(error Please 'include .makes/init.mk'))
$(eval $(call include-local))

GRAALVM-VERSION ?= 24
GRAALVM-TARBALL := graalvm-jdk-$(GRAALVM-VERSION)_linux-x64_bin.tar.gz
GRAALVM-DOWNLOAD := https://download.oracle.com/graalvm
GRAALVM-DOWNLOAD := \
 $(GRAALVM-DOWNLOAD)/$(GRAALVM-VERSION)/latest/$(GRAALVM-TARBALL)

GRAALVM-LOCAL := $(LOCAL-ROOT)/graalvm-jdk-$(GRAALVM-VERSION)
GRAALVM-BIN := $(GRAALVM-LOCAL)/bin
GRAALVM := $(GRAALVM-BIN)/native-image

SHELL-DEPS += $(GRAALVM)

export GRAALVM_HOME := $(GRAALVM-LOCAL)
export JAVA_HOME := $(GRAALVM_HOME)
override PATH := $(GRAALVM-BIN):$(PATH)
export PATH


$(GRAALVM): $(LOCAL-CACHE)/$(GRAALVM-TARBALL)
	tar -C $(LOCAL-ROOT) -xzf $<
	mv $(LOCAL-ROOT)/graalvm-jdk-$(GRAALVM-VERSION).* $(GRAALVM-LOCAL)
	touch $@
	@echo

$(LOCAL-CACHE)/$(GRAALVM-TARBALL):
	@echo "Installing 'GraalVM' locally"
	curl -Ls $(GRAALVM-DOWNLOAD) > $@

endif
