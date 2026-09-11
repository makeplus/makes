FENNEL-VERSION ?= 1.6.1
# https://fennel-lang.org/

ifndef FENNEL-LOADED
FENNEL-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
$(eval $(call include-local))

FENNEL-LOCAL := $(LOCAL-ROOT)/fennel-$(FENNEL-VERSION)
FENNEL-BIN := $(FENNEL-LOCAL)/bin
FENNEL-NAME := fennel-$(FENNEL-VERSION)
FENNEL-NATIVE-linux-int64 := -x86_64
FENNEL-NATIVE-windows-int64 := .exe
FENNEL-NATIVE := $(FENNEL-NATIVE-$(OS-ARCH))
ifneq (,$(FENNEL-NATIVE))
FENNEL-NAME := $(FENNEL-NAME)$(FENNEL-NATIVE)
else
include $(MAKES)/lua.mk
FENNEL-DEPS := $(LUA)
endif

ifeq ($(OS-NAME)-$(FENNEL-NATIVE),windows-.exe)
FENNEL := $(FENNEL-BIN)/fennel.exe
else
FENNEL := $(FENNEL-BIN)/fennel
endif
FENNEL-DOWN := https://fennel-lang.org/downloads/$(FENNEL-NAME)

override PATH := $(FENNEL-BIN):$(PATH)
export PATH

SHELL-DEPS += $(FENNEL)


$(FENNEL): $(LOCAL-CACHE)/$(FENNEL-NAME) $(FENNEL-DEPS)
	$Q mkdir -p $(FENNEL-BIN)
	$Q cp $< $@
	$Q chmod +x $@
	@$(ECHO)

$(LOCAL-CACHE)/$(FENNEL-NAME):
	@$(ECHO) "* Installing 'fennel' locally"
	$Q curl+ $(FENNEL-DOWN) > $@

endif
