ifndef LUAROCKS-LOADED
LUAROCKS-LOADED := true

$(if $(MAKES),,$(error Please 'include .makes/init.mk'))
$(eval $(call include-local))

LUAROCKS-VERSION ?= 3.12.2
LUAROCKS-TARBALL := luarocks-$(LUAROCKS-VERSION).tar.gz
LUAROCKS-DOWNLOAD := \
  https://luarocks.github.io/luarocks/releases/$(LUAROCKS-TARBALL)

LUAROCKS := $(LOCAL-BIN)/luarocks

SHELL-DEPS += $(LUAROCKS)


$(LUAROCKS): $(LUA) $(LOCAL-CACHE)/$(LUAROCKS-TARBALL)
	tar -C $(LOCAL-CACHE) -xf $(LOCAL-CACHE)/$(LUAROCKS-TARBALL)
	(cd $(LOCAL-CACHE)/luarocks-$(LUAROCKS-VERSION) && \
	  ./configure --prefix=$(LOCAL-PREFIX))
	$(MAKE) -C $(LOCAL-CACHE)/luarocks-$(LUAROCKS-VERSION) install
	touch $@
	@echo

$(LOCAL-CACHE)/$(LUAROCKS-TARBALL):
	@echo "Installing 'Lua $(LUAROCKS-VERSION)' locally"
	curl+ $(LUAROCKS-DOWNLOAD) >$@

endif
