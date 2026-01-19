RUBY-VERSION ?= 4.0.1
# https://github.com/jdx/ruby

ifndef RUBY-LOADED
RUBY-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
$(eval $(call include-local))

OA-linux-arm64 := arm64_linux
OA-linux-int64 := x86_64_linux
OA-macos-arm64 := macos
OA-macos-int64 := macos

RUBY-DIR := ruby-$(RUBY-VERSION)
RUBY-TAR := $(RUBY-DIR).$(OA-$(OS-ARCH)).tar.gz
RUBY-DOWN := https://github.com/jdx/ruby/releases/download/$(RUBY-VERSION)/$(RUBY-TAR)

RUBY-LOCAL := $(LOCAL-ROOT)/ruby-$(RUBY-VERSION)
RUBY-BIN := $(RUBY-LOCAL)/bin
override PATH := $(RUBY-BIN):$(PATH)

RUBY := $(LOCAL-BIN)/ruby

SHELL-DEPS += $(RUBY)


$(RUBY): $(LOCAL-CACHE)/$(RUBY-TAR)
	tar -C $(LOCAL-CACHE) -xzf $<
	mv $(LOCAL-CACHE)/$(RUBY-DIR) $(RUBY-LOCAL)
	touch $@
	@echo

$(LOCAL-CACHE)/$(RUBY-TAR):
	@echo "* Installing 'ruby' locally"
	curl+ $(RUBY-DOWN) > $@

endif
