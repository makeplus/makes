ifndef FSHARP-LOADED
FSHARP-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))

include $(MAKES)/dotnet.mk

FSHARP := $(DOTNET)

endif
