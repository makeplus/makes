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
ifeq ($(OS-NAME),macos)
# macOS swiftly is a universal pkg (no arch in the name):
SWIFTLY-ARCHIVE := swiftly.pkg
SWIFTLY-DOWN := https://download.swift.org/swiftly/darwin/$(SWIFTLY-ARCHIVE)
else
SWIFTLY-ARCHIVE := swiftly-$(OA-$(OS-ARCH)).tar.gz
SWIFTLY-DOWN := https://download.swift.org/swiftly/linux/$(SWIFTLY-ARCHIVE)
endif

SHELL-DEPS += $(SWIFT)

override PATH := $(SWIFTLY-HOME)/bin:$(PATH)
export PATH
export SWIFTLY_HOME_DIR := $(SWIFTLY-HOME)
export SWIFTLY_BIN_DIR := $(SWIFTLY-HOME)/bin
export SWIFTLY_TOOLCHAINS_DIR := $(SWIFTLY-HOME)/toolchains
export GNUPGHOME := $(SWIFTLY-HOME)/gnupg
export CLANG_MODULE_CACHE_PATH := $(SWIFTLY-HOME)/clang-modules


$(SWIFT): $(LOCAL-CACHE)/$(SWIFTLY-ARCHIVE)
	$Q rm -rf $(SWIFTLY-HOME) $(LOCAL-TMP)/swiftly
	$Q mkdir -p $(SWIFTLY-HOME)/bin $(LOCAL-TMP)/swiftly
	$Q mkdir -p -m 700 $(GNUPGHOME)
ifeq ($(OS-NAME),macos)
	$Q pkgutil --expand-full $< $(LOCAL-TMP)/swiftly/pkg
	$Q cp $$(find $(LOCAL-TMP)/swiftly/pkg -type f -name swiftly | \
	    head -1) $(SWIFTLY)
else
	$Q tar -C $(LOCAL-TMP)/swiftly -xzf $<
	$Q cp $(LOCAL-TMP)/swiftly/swiftly $(SWIFTLY)
endif
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

$(LOCAL-CACHE)/$(SWIFTLY-ARCHIVE):
	@$(ECHO) "* Installing 'swift' locally"
	$Q curl+ $(SWIFTLY-DOWN) > $@

endif
