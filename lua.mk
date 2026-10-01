LUA-VERSION ?= 5.5.1
# https://github.com/lua/lua

ifndef LUA-LOADED
LUA-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
$(eval $(call include-local))

LUA-TAR := lua-$(LUA-VERSION).tar.gz
LUA-DOWN := https://www.lua.org/ftp/$(LUA-TAR)

LUA := $(LOCAL-BIN)/lua
LUA-MAN := $(LOCAL-MAN)/man1/lua.1

SHELL-DEPS += $(LUA) $(LUA-MAN)

ifdef IS-LINUX
BUILD-OS := linux
else ifdef IS-MACOS
BUILD-OS := macosx
else ifdef IS-WINDOWS
BUILD-OS := mingw
else
$(error Can't build lua on this OS)
endif


$(LUA): $(LOCAL-CACHE)/$(LUA-TAR)
	tar -C $(LOCAL-CACHE) -xf $<
	$(MAKE) -C $(LOCAL-CACHE)/lua-$(LUA-VERSION) \
	  $(BUILD-OS) install INSTALL_TOP=$(LOCAL-PREFIX)
	touch $@
	@echo

$(LOCAL-CACHE)/$(LUA-TAR):
	@echo "* Installing 'Lua $(LUA-VERSION)' locally"
	curl+ $(LUA-DOWN) >$@

$(LUA-MAN): $(LUA)
	$Q test -s $@

endif
