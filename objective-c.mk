ifndef OBJECTIVE-C-LOADED
OBJECTIVE-C-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))

include $(MAKES)/clang.mk

OBJC := $(CLANG)

endif
