ifndef CLEAN-LOADED
CLEAN-LOADED := true

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
