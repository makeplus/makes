GMP-VERSION ?= 6.3.0
# https://gmplib.org/

ifndef GMP-LOADED
GMP-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
$(eval $(call include-local))
include $(MAKES)/gcc.mk

GMP-DIR := gmp-$(GMP-VERSION)
GMP-TAR := $(GMP-DIR).tar.xz
GMP-DOWN := https://ftp.gnu.org/gnu/gmp/$(GMP-TAR)
GMP-LOCAL := $(LOCAL-ROOT)/gmp-$(GMP-VERSION)
GMP-LIB := $(GMP-LOCAL)/lib/libgmp.a

override PATH := $(GMP-LOCAL)/bin:$(PATH)
export PATH
override CPPFLAGS := -I$(GMP-LOCAL)/include $(CPPFLAGS)
override LDFLAGS := -L$(GMP-LOCAL)/lib $(LDFLAGS)
export CPPFLAGS
export LDFLAGS


$(GMP-LIB): $(LOCAL-CACHE)/$(GMP-TAR) $(GCC)
	$Q rm -rf $(GMP-LOCAL) $(LOCAL-TMP)/$(GMP-DIR)
	$Q mkdir -p $(LOCAL-TMP)
	$Q tar -C $(LOCAL-TMP) -xJf $<
	$Q cd $(LOCAL-TMP)/$(GMP-DIR) && \
	  ./configure --prefix=$(GMP-LOCAL) --disable-shared --enable-static && \
	  make && \
	  make install
	$Q touch $@
	@$(ECHO)

$(LOCAL-CACHE)/$(GMP-TAR):
	@$(ECHO) "* Installing 'gmp' locally"
	$Q curl+ $(GMP-DOWN) > $@

endif
