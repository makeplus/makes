# https://github.com/hanslub42/rlwrap

ifndef RLWRAP-LOADED
RLWRAP-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
include $(MAKES)/system.mk

RLWRAP:
	$(eval $(call system-require,rlwrap))

endif
