LUA-VERSION ?= 5.4.8

ifndef LUA-LOADED
LUA-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
$(eval $(call include-local))

LUA-TAR := lua-$(LUA-VERSION).tar.gz
LUA-DOWN := https://www.lua.org/ftp/$(LUA-TAR)

LUA := $(LOCAL-BIN)/lua

SHELL-DEPS += $(LUA)


$(LUA): $(LOCAL-CACHE)/$(LUA-TAR)
	tar -C $(LOCAL-CACHE) -xf $<
	$(MAKE) -C $(LOCAL-CACHE)/lua-$(LUA-VERSION) \
	  linux install INSTALL_TOP=$(LOCAL-PREFIX)
	touch $@
	@echo

$(LOCAL-CACHE)/$(LUA-TAR):
	@echo "Installing 'Lua $(LUA-VERSION)' locally"
	curl+ $(LUA-DOWN) >$@

endif
