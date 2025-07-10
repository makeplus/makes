ifndef LUAJIT-LOADED
LUAJIT-LOADED := true

$(if $(MAKES),,$(error Please 'include .makes/init.mk'))
$(eval $(call include-local))

LUAJIT-VERSION ?= 2.1
LUAJIT-COMMIT ?= f9140a622a0c44a99efb391cc1c2358bc8098ab7
LUAJIT-REPO := LuaJIT-$(LUAJIT-COMMIT)
LUAJIT-REPO-URL := https://github.com/LuaJIT/LuaJIT

LUAJIT := $(LOCAL-BIN)/luajit

SHELL-DEPS += $(LUAJIT)


$(LUAJIT): $(LOCAL-CACHE)/$(LUAJIT-REPO)
	$(MAKE) -C $< install PREFIX=$(LOCAL-PREFIX)
	touch $@
	@echo

$(LOCAL-CACHE)/$(LUAJIT-REPO):
	@echo "Installing 'LuaJIT $(LUAJIT-VERSION)' locally"
	git clone $(LUAJIT-REPO-URL) $@

endif
