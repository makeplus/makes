LUAROCKS-VERSION ?= 3.12.2
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

SHELL-DEPS += $(LUAROCKS)


$(LUAROCKS): $(LOCAL-CACHE)/$(LUAROCKS-TAR) $(LUA)
	tar -C $(LOCAL-CACHE) -xf $<
	(cd $(LOCAL-CACHE)/luarocks-$(LUAROCKS-VERSION) && \
	  ./configure --prefix=$(LOCAL-PREFIX))
	$(MAKE) -C $(LOCAL-CACHE)/luarocks-$(LUAROCKS-VERSION) install
	touch $@
	@echo

$(LOCAL-CACHE)/$(LUAROCKS-TAR):
	@echo "Installing 'Lua $(LUAROCKS-VERSION)' locally"
	curl+ $(LUAROCKS-DOWN) >$@

endif
