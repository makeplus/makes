PHP-VERSION ?= 8.5.8
# https://github.com/php/php-src

ifndef PHP-LOADED
PHP-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
$(eval $(call include-local))

OA-linux-arm64 := linux-aarch64
OA-linux-int64 := linux-x86_64
OA-macos-arm64 := macos-aarch64
OA-macos-int64 := macos-x86_64

ifeq ($(OS-NAME),windows)
# The static-php project has no current Windows builds; use the
# official windows.php.net zip and generate a php.ini next to
# php.exe (loaded automatically) enabling the common extensions:
PHP-TAR := php-$(PHP-VERSION)-nts-Win32-vs17-x64.zip
PHP-DOWN := https://windows.php.net/downloads/releases/archives/$(PHP-TAR)
PHP-LOCAL := $(LOCAL-ROOT)/php-$(PHP-VERSION)
override PATH := $(PHP-LOCAL):$(PATH)
export PATH
PHP := $(PHP-LOCAL)/php.exe
else
PHP-TAR := php-$(PHP-VERSION)-cli-$(OA-$(OS-ARCH)).tar.gz
PHP-DOWN := https://dl.static-php.dev/static-php-cli/common/$(PHP-TAR)
PHP := $(LOCAL-BIN)/php
endif

SHELL-DEPS += $(PHP)


$(PHP): $(LOCAL-CACHE)/$(PHP-TAR)
ifeq ($(OS-NAME),windows)
	$Q mkdir -p $(PHP-LOCAL)
	$Q cd $(PHP-LOCAL) && unzip -qo $(LOCAL-CACHE)/$(PHP-TAR)
	$Q printf '%s\n' \
	  'extension_dir = "ext"' \
	  'extension=curl' \
	  'extension=mbstring' \
	  'extension=openssl' \
	  'extension=ffi' \
	  'ffi.enable = true' \
	  > $(PHP-LOCAL)/php.ini
else
	$Q tar -C $(LOCAL-CACHE) -xzf $<
	$Q [[ -e $(LOCAL-CACHE)/php ]]
	$Q mv $(LOCAL-CACHE)/php $(LOCAL-BIN)/
endif
	$Q touch $@
	@$(ECHO)

$(LOCAL-CACHE)/$(PHP-TAR):
	@$(ECHO) "* Installing 'php' locally"
	$Q curl+ $(PHP-DOWN) > $@

endif
