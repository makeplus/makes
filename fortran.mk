FPM-VERSION ?= 0.12.0
# https://github.com/fortran-lang/fpm

ifndef FORTRAN-LOADED
FORTRAN-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
$(eval $(call include-local))
ifndef GCC-LOADED
include $(MAKES)/gcc.mk
endif

SHELL-DEPS += $(GFORTRAN)


# FPM (only available for Linux x64)
ifeq ($(OS-ARCH),linux-int64)
FPM-NAME := fpm-$(FPM-VERSION)-linux-x86_64-gcc-12
FPM-DOWN := https://github.com/fortran-lang/fpm/releases/download
FPM-DOWN := $(FPM-DOWN)/v$(FPM-VERSION)/$(FPM-NAME)

FPM := $(LOCAL-BIN)/fpm

SHELL-DEPS += $(FPM)

$(FPM): $(LOCAL-CACHE)/$(FPM-NAME)
	cp $< $@
	chmod +x $@
	touch $@
	@echo

$(LOCAL-CACHE)/$(FPM-NAME):
	@echo "* Installing 'fpm' locally"
	curl+ $(FPM-DOWN) > $@
endif

endif
