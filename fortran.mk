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


# FPM installation
FPM := $(LOCAL-BIN)/fpm
FPM-DOWN := https://github.com/fortran-lang/fpm/releases/download/v$(FPM-VERSION)

# Platforms with pre-built binaries
FPM-OA-linux-int64 := linux-x86_64
FPM-OA-macos-int64 := macos-x86_64

SHELL-DEPS += $(FPM)

ifdef FPM-OA-$(OS-ARCH)
# Use pre-built binary
FPM-NAME := fpm-$(FPM-VERSION)-$(FPM-OA-$(OS-ARCH))-gcc-12

$(FPM): $(LOCAL-CACHE)/$(FPM-NAME)
	cp $< $@
	chmod +x $@
	touch $@
	@echo

$(LOCAL-CACHE)/$(FPM-NAME):
	@echo "* Installing 'fpm' locally"
	curl+ $(FPM-DOWN)/$(FPM-NAME) > $@

else
# Build from source
FPM-SRC := fpm-$(FPM-VERSION).F90

$(FPM): $(GCC) $(LOCAL-CACHE)/$(FPM-SRC)
	@echo "* Building 'fpm' from source"
	$(GFORTRAN) -o $@ $(LOCAL-CACHE)/$(FPM-SRC)
	touch $@
	@echo

$(LOCAL-CACHE)/$(FPM-SRC):
	curl+ $(FPM-DOWN)/$(FPM-SRC) > $@

endif

endif
