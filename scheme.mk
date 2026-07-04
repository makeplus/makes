ifndef SCHEME-LOADED
SCHEME-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
$(eval $(call include-local))
include $(MAKES)/racket.mk

SCHEME := $(LOCAL-BIN)/scheme

SHELL-DEPS += $(SCHEME)


$(SCHEME): $(RACKET)
	$Q printf '#!/usr/bin/env bash\nexec %s -I r5rs "$$@"\n' '$(RACKET)' > $@
	$Q chmod +x $@
	@$(ECHO)

endif
