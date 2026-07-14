RUBY-VERSION ?= 4.0.6
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

ifeq ($(OS-NAME),windows)
# The jdx/ruby project has no Windows builds; use the RubyInstaller
# InnoSetup installer (installed silently):
RUBY-TAR := rubyinstaller-$(RUBY-VERSION)-1-x64.exe
RUBY-DOWN := https://github.com/oneclick/rubyinstaller2/releases/download/RubyInstaller-$(RUBY-VERSION)-1/$(RUBY-TAR)
else
RUBY-TAR := $(RUBY-DIR).$(OA-$(OS-ARCH)).tar.gz
RUBY-DOWN := https://github.com/jdx/ruby/releases/download/$(RUBY-VERSION)/$(RUBY-TAR)
endif

RUBY-LOCAL := $(LOCAL-ROOT)/ruby-$(RUBY-VERSION)
RUBY-BIN := $(RUBY-LOCAL)/bin
override PATH := $(RUBY-BIN):$(PATH)
export PATH

RUBY := $(LOCAL-BIN)/ruby

SHELL-DEPS += $(RUBY)


$(RUBY): $(LOCAL-CACHE)/$(RUBY-TAR)
ifeq ($(OS-NAME),windows)
	chmod +x $<
# MSYS bash rewrites /FLAG arguments into Windows paths when calling
# native programs; disable that conversion for the installer flags:
	MSYS2_ARG_CONV_EXCL='*' MSYS_NO_PATHCONV=1 \
	  $< /SP- /VERYSILENT /SUPPRESSMSGBOXES /NORESTART \
	  "/DIR=$$(cygpath -w $(RUBY-LOCAL))"
else
	tar -C $(LOCAL-CACHE) -xzf $<
	mv $(LOCAL-CACHE)/$(RUBY-DIR) $(RUBY-LOCAL)
endif
	touch $@
	@echo

$(LOCAL-CACHE)/$(RUBY-TAR):
	@echo "* Installing 'ruby' locally"
	curl+ $(RUBY-DOWN) > $@

endif
