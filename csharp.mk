ifndef CSHARP-LOADED
CSHARP-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))

include $(MAKES)/dotnet.mk

CSHARP := $(DOTNET)

endif
