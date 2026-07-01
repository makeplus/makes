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

PHP-TAR := php-$(PHP-VERSION)-cli-$(OA-$(OS-ARCH)).tar.gz
PHP-DOWN := https://dl.static-php.dev/static-php-cli/common/$(PHP-TAR)

PHP := $(LOCAL-BIN)/php

SHELL-DEPS += $(PHP)


$(PHP): $(LOCAL-CACHE)/$(PHP-TAR)
	$Q tar -C $(LOCAL-CACHE) -xzf $<
	$Q [[ -e $(LOCAL-CACHE)/php ]]
	$Q mv $(LOCAL-CACHE)/php $(LOCAL-BIN)/
	$Q touch $@
	@$(ECHO)

$(LOCAL-CACHE)/$(PHP-TAR):
	@$(ECHO) "* Installing 'php' locally"
	$Q curl+ $(PHP-DOWN) > $@

endif
