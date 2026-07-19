JOLT-VERSION ?= 0.4.5
# https://github.com/jolt-lang/jolt

ifndef JOLT-LOADED
JOLT-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
$(eval $(call include-local))

OA-linux-int64 := x86_64-linux
OA-macos-arm64 := aarch64-macos
OA-windows-int64 := x86_64-windows

ifeq (,$(OA-$(OS-ARCH)))
$(error 'jolt' has no prebuilt binary for $(OS-ARCH); see https://github.com/jolt-lang/jolt)
endif

ifeq (windows,$(OS-NAME))
JOLT-ARC-EXT := zip
JOLT-EXE := joltc.exe
else
JOLT-ARC-EXT := tar.gz
JOLT-EXE := joltc
endif

JOLT-DIR := joltc-v$(JOLT-VERSION)-$(OA-$(OS-ARCH))
JOLT-ARC := $(JOLT-DIR).$(JOLT-ARC-EXT)
JOLT-DOWN := https://github.com/jolt-lang/jolt
JOLT-DOWN := $(JOLT-DOWN)/releases/download/v$(JOLT-VERSION)/$(JOLT-ARC)

JOLT-LOCAL := $(LOCAL-ROOT)/jolt-$(JOLT-VERSION)
JOLT := $(JOLT-LOCAL)/bin/$(JOLT-EXE)

SHELL-DEPS += $(JOLT)

override PATH := $(JOLT-LOCAL)/bin:$(PATH)
export PATH


$(JOLT): $(LOCAL-CACHE)/$(JOLT-ARC)
	$Q rm -rf $(LOCAL-TMP)/jolt-$(JOLT-VERSION)
	$Q mkdir -p $(JOLT-LOCAL)/bin $(LOCAL-TMP)/jolt-$(JOLT-VERSION)
	$Q case '$(JOLT-ARC)' in \
	  *.zip) unzip -q $< -d $(LOCAL-TMP)/jolt-$(JOLT-VERSION) ;; \
	  *) tar -C $(LOCAL-TMP)/jolt-$(JOLT-VERSION) -xzf $< ;; \
	esac
	$Q cp $$(find $(LOCAL-TMP)/jolt-$(JOLT-VERSION) -name $(JOLT-EXE) -type f | head -1) $@
	$Q chmod +x $@
	$Q touch $@
	@$(ECHO)

$(LOCAL-CACHE)/$(JOLT-ARC):
	@$(ECHO) "* Installing 'jolt' locally"
	$Q curl+ $(JOLT-DOWN) > $@

endif
