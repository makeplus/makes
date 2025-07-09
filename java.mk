JAVA-VERSION ?= 24

ifndef JAVA-LOADED
JAVA-LOADED := true

$(if $(MAKES),,$(error Please 'include .makes/init.mk'))
$(eval $(call include-local))

$(if $(GRAALVM-LOADED),$(error Can't use both java.mk and graalvm.mk))

OA-linux-arm64 := linux-aarch64
OA-linux-int64 := linux-x64
OA-macos-arm64 := macos-aarch64
OA-macos-int64 := macos-x64

JAVA-TARBALL := jdk-$(JAVA-VERSION)_$(OA-$(OS-ARCH))_bin.tar.gz
JAVA-DOWNLOAD := \
  https://download.oracle.com/java/$(JAVA-VERSION)/latest/$(JAVA-TARBALL)

JAVA-LOCAL := $(LOCAL-ROOT)/jdk-$(JAVA-VERSION)
JAVA-HOME := $(JAVA-LOCAL)
ifeq (macos,$(OS-NAME))
JAVA-HOME := $(JAVA-HOME)/Contents/Home
endif
export JAVA_HOME := $(JAVA-HOME)

JAVA-BIN := $(JAVA-HOME)/bin
override PATH := $(JAVA-BIN):$(PATH)

JAVA := $(JAVA-BIN)/java

SHELL-DEPS += $(JAVA)


$(JAVA): $(LOCAL-CACHE)/$(JAVA-TARBALL)
	tar -C $(LOCAL-ROOT) -xzf $<
	mv $(LOCAL-ROOT)/jdk-$(JAVA-VERSION).* $(JAVA-LOCAL)
	touch $@
	@echo

$(LOCAL-CACHE)/$(JAVA-TARBALL):
	@echo "Installing 'java' locally"
	curl+ $(JAVA-DOWNLOAD) > $@

endif
