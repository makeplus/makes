COBOL-VERSION ?= 3.2
# https://gnucobol.sourceforge.io/

ifndef COBOL-LOADED
COBOL-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
$(eval $(call include-local))
include $(MAKES)/gmp.mk

COBOL-DIR := gnucobol-$(COBOL-VERSION)
COBOL-TAR := $(COBOL-DIR).tar.xz
COBOL-DOWN := https://ftp.gnu.org/gnu/gnucobol/$(COBOL-TAR)
COBOL-LOCAL := $(LOCAL-ROOT)/cobol-$(COBOL-VERSION)
COBC := $(COBOL-LOCAL)/bin/cobc

SHELL-DEPS += $(COBC)

override PATH := $(COBOL-LOCAL)/bin:$(PATH)
export PATH
override LD_LIBRARY_PATH := $(COBOL-LOCAL)/lib:$(LD_LIBRARY_PATH)
export LD_LIBRARY_PATH


$(COBC): $(LOCAL-CACHE)/$(COBOL-TAR) $(GMP-LIB)
	$Q rm -rf $(COBOL-LOCAL) $(LOCAL-TMP)/$(COBOL-DIR)
	$Q mkdir -p $(LOCAL-TMP)
	$Q tar -C $(LOCAL-TMP) -xJf $<
	$Q cd $(LOCAL-TMP)/$(COBOL-DIR) && \
	  ./configure --prefix=$(COBOL-LOCAL) \
	    CPPFLAGS="$(CPPFLAGS)" LDFLAGS="$(LDFLAGS)" && \
	  make && \
	  make install
	$Q touch $@
	@$(ECHO)

$(LOCAL-CACHE)/$(COBOL-TAR):
	@$(ECHO) "* Installing 'cobol' locally"
	$Q curl+ $(COBOL-DOWN) > $@

endif
