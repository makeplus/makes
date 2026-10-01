GRAALVM-VERSION ?= 25

ifndef GRAALVM-LOADED
GRAALVM-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
$(eval $(call include-local))
$(if $(JAVA-LOADED),$(error Can't use both java.mk and graalvm.mk))

OA-linux-arm64 := linux-aarch64
OA-linux-int64 := linux-x64
OA-macos-arm64 := macos-aarch64
OA-macos-int64 := macos-x64
OA-windows-int64 := windows-x64

# GraalVM no longer supports macOS Intel.  Keep the module loadable so
# projects that provide multiple engines can still use the other ones.
ifeq ($(OS-NAME)-$(ARCH-NAME),macos-int64)
GRAALVM-UNAVAILABLE := GraalVM no longer supports macOS Intel (x64)
endif

ifeq ($(OS-NAME),windows)
GRAALVM-ARCHIVE := graalvm-jdk-$(GRAALVM-VERSION)_$(OA-$(OS-ARCH))_bin.zip
else
GRAALVM-ARCHIVE := graalvm-jdk-$(GRAALVM-VERSION)_$(OA-$(OS-ARCH))_bin.tar.gz
endif
GRAALVM-DOWN := https://download.oracle.com/graalvm
GRAALVM-DOWN := $(GRAALVM-DOWN)/$(GRAALVM-VERSION)/latest/$(GRAALVM-ARCHIVE)

GRAALVM-LOCAL := $(LOCAL-ROOT)/graalvm-jdk-$(GRAALVM-VERSION)
GRAALVM-HOME := $(GRAALVM-LOCAL)
ifeq (macos,$(OS-NAME))
GRAALVM-HOME := $(GRAALVM-HOME)/Contents/Home
endif
export GRAALVM_HOME := $(GRAALVM-HOME)
export JAVA_HOME := $(GRAALVM_HOME)

GRAALVM-BIN := $(GRAALVM-HOME)/bin
override PATH := $(GRAALVM-BIN):$(PATH)
export PATH

GRAALVM := $(GRAALVM-BIN)/native-image
JAVA := $(GRAALVM-BIN)/java
GRAALVM-MAN := $(LOCAL-MAN)/man1/java.1

SHELL-DEPS += $(GRAALVM)
ifneq ($(OS-NAME),windows)
SHELL-DEPS += $(GRAALVM-MAN)
endif


ifdef GRAALVM-UNAVAILABLE
$(GRAALVM) $(JAVA):
	@$(error $(GRAALVM-UNAVAILABLE))
else ifeq ($(OS-NAME),windows)
$(GRAALVM) $(JAVA): $(LOCAL-CACHE)/$(GRAALVM-ARCHIVE)
	$Q if [[ ! -f $(GRAALVM) ]]; then \
		cd $(LOCAL-ROOT) && unzip -q cache/$(GRAALVM-ARCHIVE) && \
		mv $(LOCAL-ROOT)/graalvm-jdk-$(GRAALVM-VERSION).* $(GRAALVM-LOCAL) && \
		touch $(GRAALVM) $(JAVA); \
	fi
	@$(ECHO)
else
$(GRAALVM) $(JAVA): $(LOCAL-CACHE)/$(GRAALVM-ARCHIVE)
	$Q if [[ ! -f $(GRAALVM) ]]; then \
		cd $(LOCAL-ROOT) && tar -xzf cache/$(GRAALVM-ARCHIVE) && \
		mv $(LOCAL-ROOT)/graalvm-jdk-$(GRAALVM-VERSION).* $(GRAALVM-LOCAL) && \
		touch $(GRAALVM) $(JAVA); \
	fi
	@$(ECHO)
endif

$(LOCAL-CACHE)/$(GRAALVM-ARCHIVE):
	@$(ECHO) "* Installing 'GraalVM' locally"
	$Q curl+ $(GRAALVM-DOWN) > $@

ifneq ($(OS-NAME),windows)
$(GRAALVM-MAN): $(GRAALVM)
	$Q mkdir -p $(@D)
	$Q cp $(GRAALVM-HOME)/man/man1/* $(@D)/
endif

endif
