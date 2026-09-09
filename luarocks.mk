LUAROCKS-VERSION ?= 3.13.0
# https://github.com/luarocks/luarocks

ifndef LUAROCKS-LOADED
LUAROCKS-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
$(eval $(call include-local))
ifndef LUA-LOADED
ifndef LUAJIT-LOADED
include $(MAKES)/lua.mk
endif
endif

LUAROCKS-TAR := luarocks-$(LUAROCKS-VERSION).tar.gz
LUAROCKS-DOWN := https://luarocks.github.io/luarocks/releases/$(LUAROCKS-TAR)

LUAROCKS := $(LOCAL-BIN)/luarocks

# Prefer the explicitly loaded Lua module when both runtimes are present.
ifdef LUA-LOADED
LUAROCKS-LUA := $(LUA)
LUAROCKS-LUA-VERSION := $(word 1,$(subst ., ,$(LUA-VERSION))).$(word 2,$(subst ., ,$(LUA-VERSION)))
LUAROCKS-LUA-INCLUDE := $(LOCAL-INC)
else
LUAROCKS-LUA := $(LUAJIT)
LUAROCKS-LUA-VERSION := 5.1
LUAROCKS-LUA-INCLUDE := $(LOCAL-INC)/luajit-$(LUAJIT-VERSION)
endif

SHELL-DEPS += $(LUAROCKS)


$(LUAROCKS): $(LOCAL-CACHE)/$(LUAROCKS-TAR) $(LUAROCKS-LUA)
	tar -C $(LOCAL-CACHE) -xf $<
	(cd $(LOCAL-CACHE)/luarocks-$(LUAROCKS-VERSION) && \
	  ./configure --prefix=$(LOCAL-PREFIX) \
	    --lua-version=$(LUAROCKS-LUA-VERSION) \
	    --with-lua=$(LOCAL-PREFIX) \
	    --with-lua-bin=$(dir $(LUAROCKS-LUA)) \
	    --with-lua-interpreter=$(notdir $(LUAROCKS-LUA)) \
	    --with-lua-include=$(LUAROCKS-LUA-INCLUDE) \
	    --with-lua-lib=$(LOCAL-LIB))
	$(MAKE) -C $(LOCAL-CACHE)/luarocks-$(LUAROCKS-VERSION) install
	touch $@
	@echo

$(LOCAL-CACHE)/$(LUAROCKS-TAR):
	@echo "* Installing 'LuaRocks $(LUAROCKS-VERSION)' locally"
	curl+ $(LUAROCKS-DOWN) >$@

endif
