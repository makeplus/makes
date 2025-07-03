ifndef CLEAN-LOADED
CLEAN-LOADED := true

MAKES-CLEAN :=
MAKES-REALCLEAN :=
MAKES-DISTCLEAN :=

ifeq (,$(patsubst %/.cache/makes,,$(lastword $(MAKES))))
_path := $(abspath $(dir $(MAKES)))
ifneq (,$(wildcard $(_path)))
MAKES-DISTCLEAN := $(_path)
endif

# else
# ifeq ($(LOCAL-ROOT),$(MAKEFILE-DIR)/.cache/.local)
# MAKES-DISTCLEAN := $(MAKEFILE-DIR)/.cache
# endif
endif


clean::
	@if [[ '$(MAKES-CLEAN)' ]]; then \
	  set -x; \
	  $(RM) -r $(MAKES-CLEAN); \
	fi

realclean:: clean
	@if [[ '$(MAKES-REALCLEAN)' ]]; then \
	  set -x; \
	  $(RM) -r $(MAKES-REALCLEAN); \
	fi

distclean:: realclean
	@if [[ '$(MAKES-DISTCLEAN)' ]]; then \
	  set -x; \
	  $(RM) -r $(MAKES-DISTCLEAN); \
	fi

endif
