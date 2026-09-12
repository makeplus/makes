ifndef FSHARP-LOADED
FSHARP-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))

include $(MAKES)/csharp.mk

FSHARP := $(CSHARP)

endif
