JAVA-VERSION ?= 24

ifndef JAVA-LOADED
JAVA-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
$(eval $(call include-local))
$(if $(GRAALVM-LOADED),$(error Can't use both java.mk and graalvm.mk))

OA-linux-arm64 := linux-aarch64
OA-linux-int64 := linux-x64
OA-macos-arm64 := macos-aarch64
OA-macos-int64 := macos-x64

JAVA-TAR := jdk-$(JAVA-VERSION)_$(OA-$(OS-ARCH))_bin.tar.gz
JAVA-DOWN := https://download.oracle.com/java
JAVA-DOWN := $(JAVA-DOWN)/$(JAVA-VERSION)/latest/$(JAVA-TAR)

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


$(JAVA): $(LOCAL-CACHE)/$(JAVA-TAR)
	tar -C $(LOCAL-ROOT) -xzf $<
	mv $(LOCAL-ROOT)/jdk-$(JAVA-VERSION).* $(JAVA-LOCAL)
	touch $@
	@echo

$(LOCAL-CACHE)/$(JAVA-TAR):
	@echo "* Installing 'java' locally"
	curl+ $(JAVA-DOWN) > $@

endif
