GRAALVM-VERSION ?= 24

ifndef GRAALVM-LOADED
GRAALVM-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
$(eval $(call include-local))
$(if $(JAVA-LOADED),$(error Can't use both java.mk and graalvm.mk))

OA-linux-arm64 := linux-aarch64
OA-linux-int64 := linux-x64
OA-macos-arm64 := macos-aarch64
OA-macos-int64 := macos-x64

GRAALVM-TAR := graalvm-jdk-$(GRAALVM-VERSION)_$(OA-$(OS-ARCH))_bin.tar.gz
GRAALVM-DOWN := https://download.oracle.com/graalvm
GRAALVM-DOWN := $(GRAALVM-DOWN)/$(GRAALVM-VERSION)/latest/$(GRAALVM-TAR)

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


$(GRAALVM) $(JAVA): $(LOCAL-CACHE)/$(GRAALVM-TAR)
	tar -C $(LOCAL-ROOT) -xzf $<
	mv $(LOCAL-ROOT)/graalvm-jdk-$(GRAALVM-VERSION).* $(GRAALVM-LOCAL)
	touch $@
	@echo

$(LOCAL-CACHE)/$(GRAALVM-TAR):
	@echo "Installing 'GraalVM' locally"
	curl+ $(GRAALVM-DOWN) > $@

endif
