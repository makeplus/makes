ifndef HELP
ifneq (,$(shell command -v perl))
HELP := $(shell $(MAKES)/bin/make-help $(MAKEFILE))
endif
endif

export HELP
