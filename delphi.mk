ifndef DELPHI-LOADED
DELPHI-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))

include $(MAKES)/fpc.mk

DELPHI := $(FPC)

endif
