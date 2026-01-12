JAVA-VERSION ?= 25

ifndef JAVA-LOADED
JAVA-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
$(eval $(call include-local))
$(if $(GRAALVM-LOADED),$(error Can't use both java.mk and graalvm.mk))

OA-linux-arm64 := linux-aarch64
OA-linux-int64 := linux-x64
OA-macos-arm64 := macos-aarch64
OA-macos-int64 := macos-x64
OA-windows-int64 := windows-x64

ifeq ($(OS-NAME),windows)
JAVA-ARCHIVE := jdk-$(JAVA-VERSION)_$(OA-$(OS-ARCH))_bin.zip
else
JAVA-ARCHIVE := jdk-$(JAVA-VERSION)_$(OA-$(OS-ARCH))_bin.tar.gz
endif
JAVA-DOWN := https://download.oracle.com/java
JAVA-DOWN := $(JAVA-DOWN)/$(JAVA-VERSION)/latest/$(JAVA-ARCHIVE)

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


ifeq ($(OS-NAME),windows)
$(JAVA): $(LOCAL-CACHE)/$(JAVA-ARCHIVE)
	cd $(LOCAL-ROOT) && unzip -q cache/$(JAVA-ARCHIVE)
	mv $(LOCAL-ROOT)/jdk-$(JAVA-VERSION).* $(JAVA-LOCAL)
	touch $@
	@echo
else
$(JAVA): $(LOCAL-CACHE)/$(JAVA-ARCHIVE)
	cd $(LOCAL-ROOT) && tar -xzf cache/$(JAVA-ARCHIVE)
	mv $(LOCAL-ROOT)/jdk-$(JAVA-VERSION).* $(JAVA-LOCAL)
	touch $@
	@echo
endif

$(LOCAL-CACHE)/$(JAVA-ARCHIVE):
	@echo "* Installing 'java' locally"
	curl+ $(JAVA-DOWN) > $@

endif
