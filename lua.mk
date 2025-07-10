ifndef LUA-LOADED
LUA-LOADED := true

$(if $(MAKES),,$(error Please 'include .makes/init.mk'))
$(eval $(call include-local))

LUA-VERSION ?= 5.4.8
LUA-TARBALL := lua-$(LUA-VERSION).tar.gz
LUA-DOWNLOAD := https://www.lua.org/ftp/$(LUA-TARBALL)

LUA := $(LOCAL-BIN)/lua

SHELL-DEPS += $(LUA)


$(LUA): $(LOCAL-CACHE)/$(LUA-TARBALL)
	tar -C $(LOCAL-CACHE) -xf $<
	$(MAKE) -C $(LOCAL-CACHE)/lua-$(LUA-VERSION) \
	  linux install INSTALL_TOP=$(LOCAL-PREFIX)
	touch $@
	@echo

$(LOCAL-CACHE)/$(LUA-TARBALL):
	@echo "Installing 'Lua $(LUA-VERSION)' locally"
	curl+ $(LUA-DOWNLOAD) >$@

endif
