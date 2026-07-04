SWIFT-VERSION ?= latest
# https://www.swift.org/install/

ifndef SWIFT-LOADED
SWIFT-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
$(eval $(call include-local))

OA-linux-arm64 := aarch64
OA-linux-int64 := x86_64

SWIFTLY-HOME := $(LOCAL-ROOT)/swiftly
SWIFTLY := $(SWIFTLY-HOME)/bin/swiftly
SWIFT := $(SWIFTLY-HOME)/bin/swift
SWIFTLY-TAR := swiftly-$(OA-$(OS-ARCH)).tar.gz
SWIFTLY-DOWN := https://download.swift.org/swiftly/linux/$(SWIFTLY-TAR)

SHELL-DEPS += $(SWIFT)

override PATH := $(SWIFTLY-HOME)/bin:$(PATH)
export PATH
export SWIFTLY_HOME_DIR := $(SWIFTLY-HOME)
export SWIFTLY_BIN_DIR := $(SWIFTLY-HOME)/bin
export SWIFTLY_TOOLCHAINS_DIR := $(SWIFTLY-HOME)/toolchains
export GNUPGHOME := $(SWIFTLY-HOME)/gnupg
export CLANG_MODULE_CACHE_PATH := $(SWIFTLY-HOME)/clang-modules


$(SWIFT): $(LOCAL-CACHE)/$(SWIFTLY-TAR)
	$Q rm -rf $(SWIFTLY-HOME) $(LOCAL-TMP)/swiftly
	$Q mkdir -p $(SWIFTLY-HOME)/bin $(LOCAL-TMP)/swiftly
	$Q mkdir -p -m 700 $(GNUPGHOME)
	$Q tar -C $(LOCAL-TMP)/swiftly -xzf $<
	$Q cp $(LOCAL-TMP)/swiftly/swiftly $(SWIFTLY)
	$Q chmod +x $(SWIFTLY)
	$Q $(SWIFTLY) init --assume-yes --no-modify-profile --skip-install --quiet-shell-followup
	$Q . $(SWIFTLY-HOME)/env.sh && $(SWIFTLY) install --use $(SWIFT-VERSION) \
	    --post-install-file $(SWIFTLY-HOME)/post-install.sh
	$Q if [[ -s $(SWIFTLY-HOME)/post-install.sh ]]; then \
	    echo "NOTE: Some system packages may be missing for Swift."; \
	    echo "See: $(SWIFTLY-HOME)/post-install.sh"; \
	fi
	$Q touch $@
	@$(ECHO)

$(LOCAL-CACHE)/$(SWIFTLY-TAR):
	@$(ECHO) "* Installing 'swift' locally"
	$Q curl+ $(SWIFTLY-DOWN) > $@

endif
