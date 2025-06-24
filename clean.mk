ifndef CLEAN-LOADED
CLEAN-LOADED := true

clean::
	$(RM) -r $(MAKES-CLEAN)

realclean:: clean
	$(RM) -r $(MAKES-REALCLEAN)

distclean:: realclean
	$(RM) -r $(MAKES-DISTCLEAN)

endif
