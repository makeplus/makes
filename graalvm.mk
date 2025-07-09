GRAALVM-VERSION ?= 24

ifndef GRAALVM-LOADED
GRAALVM-LOADED := true

$(if $(MAKES),,$(error Please 'include .makes/init.mk'))
$(eval $(call include-local))

$(if $(JAVA-LOADED),$(error Can't use both java.mk and graalvm.mk))

OA-linux-arm64 := linux-aarch64
OA-linux-int64 := linux-x64
OA-macos-arm64 := macos-aarch64
OA-macos-int64 := macos-x64

GRAALVM-TARBALL := graalvm-jdk-$(GRAALVM-VERSION)_$(OA-$(OS-ARCH))_bin.tar.gz
GRAALVM-DOWNLOAD := https://download.oracle.com/graalvm
GRAALVM-DOWNLOAD := \
 $(GRAALVM-DOWNLOAD)/$(GRAALVM-VERSION)/latest/$(GRAALVM-TARBALL)

GRAALVM-LOCAL := $(LOCAL-ROOT)/graalvm-jdk-$(GRAALVM-VERSION)
GRAALVM-HOME := $(GRAALVM-LOCAL)
ifeq (macos,$(OS-NAME))
GRAALVM-HOME := $(GRAALVM-HOME)/Contents/Home
endif
export GRAALVM_HOME := $(GRAALVM-HOME)
export JAVA_HOME := $(GRAALVM_HOME)

GRAALVM-BIN := $(GRAALVM-HOME)/bin
override PATH := $(GRAALVM-BIN):$(PATH)

GRAALVM := $(GRAALVM-BIN)/native-image
JAVA := $(GRAALVM-BIN)/java

SHELL-DEPS += $(GRAALVM)


$(GRAALVM) $(JAVA): $(LOCAL-CACHE)/$(GRAALVM-TARBALL)
	tar -C $(LOCAL-ROOT) -xzf $<
	mv $(LOCAL-ROOT)/graalvm-jdk-$(GRAALVM-VERSION).* $(GRAALVM-LOCAL)
	touch $@
	@echo

$(LOCAL-CACHE)/$(GRAALVM-TARBALL):
	@echo "Installing 'GraalVM' locally"
	curl+ $(GRAALVM-DOWNLOAD) > $@

endif
