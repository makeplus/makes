BERKELEYDB-VERSION ?= 18.1.40
# https://www.oracle.com/database/technologies/related/berkeleydb.html

ifndef BERKELEYDB-LOADED
BERKELEYDB-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
$(eval $(call include-local))
include $(MAKES)/gcc.mk

BERKELEYDB-DIR := db-$(BERKELEYDB-VERSION)
BERKELEYDB-TAR := $(BERKELEYDB-DIR).tar.gz
BERKELEYDB-DOWN := https://download.oracle.com/berkeley-db/$(BERKELEYDB-TAR)
BERKELEYDB-LOCAL := $(LOCAL-ROOT)/berkeleydb-$(BERKELEYDB-VERSION)
BERKELEYDB-LIB := $(BERKELEYDB-LOCAL)/lib/libdb.a
# Static consumers must also link the SSL libraries used by replication.
BERKELEYDB-LIBS ?= $(BERKELEYDB-LIB) -lpthread -lssl -lcrypto

SHELL-DEPS += $(BERKELEYDB-LIB)

# The source archive lacks some directories required by install_docs.
# Install the development files and utilities without that optional target.
$(BERKELEYDB-LIB): $(LOCAL-CACHE)/$(BERKELEYDB-TAR) $(GCC)
	$Q mkdir -p $(LOCAL-TMP)
	$Q tar -C $(LOCAL-TMP) -xzf $<
	$Q cd $(LOCAL-TMP)/$(BERKELEYDB-DIR)/build_unix && \
	  ../dist/configure --prefix=$(BERKELEYDB-LOCAL) \
	    --disable-shared --enable-static --with-pic CC=$(GCC) && \
	  $(MAKE) && \
	  $(MAKE) install_include install_lib install_utilities
	$Q test -s $@
	@$(ECHO)

$(LOCAL-CACHE)/$(BERKELEYDB-TAR):
	@$(ECHO) "* Installing 'Berkeley DB $(BERKELEYDB-VERSION)' locally"
	$Q curl+ $(BERKELEYDB-DOWN) > $@

endif
