TCL-VERSION ?= 8.6.3
# https://tclkits.rkeene.org/

ifndef TCL-LOADED
TCL-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
$(eval $(call include-local))

TCLKIT-NAME-linux-int64 := tclkitsh-$(TCL-VERSION)-rhel5-x86_64
TCLKIT-HASH-linux-int64 := 36b5cb68899cfcb79417a29f9c6d8176ebae0d24
TCLKIT-NAME-macos-int64 := tclkit-$(TCL-VERSION)-macosx10.5-ix86+x86_64
TCLKIT-HASH-macos-int64 := 1b4a7ae47ebab6ea9e0e16af4d8714c8b4aa0ce2
TCLKIT-NAME-windows-int64 := tclkitsh-$(TCL-VERSION)-win32-x86_64.exe
TCLKIT-HASH-windows-int64 := 3827d0c8fab8a88fad26b62bb1becae808ce6d5a

TCLKIT-NAME := $(TCLKIT-NAME-$(OS-ARCH))
TCLKIT-HASH := $(TCLKIT-HASH-$(OS-ARCH))
TCLKIT-DOWN := https://tclkits.rkeene.org/fossil/raw/$(TCLKIT-NAME)?name=$(TCLKIT-HASH)

ifeq ($(OS-NAME),windows)
  TCLSH-EXE := tclsh.exe
else
  TCLSH-EXE := tclsh
endif

TCL-LOCAL := $(LOCAL-ROOT)/tcl-$(TCL-VERSION)
TCLSH := $(TCL-LOCAL)/bin/$(TCLSH-EXE)

SHELL-DEPS += $(TCLSH)

override PATH := $(TCL-LOCAL)/bin:$(PATH)
export PATH


$(TCLSH): $(LOCAL-CACHE)/$(TCLKIT-NAME)
	$Q mkdir -p $(TCL-LOCAL)/bin
	$Q cp $< $@
	$Q chmod +x $@
	@$(ECHO)

$(LOCAL-CACHE)/$(TCLKIT-NAME):
	@$(ECHO) "* Installing 'tclkit' locally"
	$Q curl+ '$(TCLKIT-DOWN)' > $@

endif
