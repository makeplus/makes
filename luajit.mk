LUAJIT-VERSION ?= 2.1
LUAJIT-COMMIT ?= f9140a622a0c44a99efb391cc1c2358bc8098ab7
# https://www.github.com/LuaJIT/LuaJIT/tags

ifndef LUAJIT-LOADED
LUAJIT-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
$(eval $(call include-local))

LUAJIT-NAME := LuaJIT-$(LUAJIT-COMMIT)
LUAJIT-DOWN := https://github.com/LuaJIT/LuaJIT

LUAJIT := $(LOCAL-BIN)/luajit

SHELL-DEPS += $(LUAJIT)


$(LUAJIT): $(LOCAL-CACHE)/$(LUAJIT-NAME)
	$(MAKE) -C $< install PREFIX=$(LOCAL-PREFIX)
	touch $@
	@echo

$(LOCAL-CACHE)/$(LUAJIT-NAME):
	@echo "Installing 'LuaJIT $(LUAJIT-VERSION)' locally"
	git clone $(LUAJIT-DOWN) $@

endif
