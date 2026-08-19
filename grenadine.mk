GRENADINE-VERSION ?= 0.1.9
# https://github.com/clojurestar/grenadine

ifndef GRENADINE-LOADED
GRENADINE-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
$(eval $(call include-local))

OA-linux-arm64 := linux_arm64
OA-linux-int64 := linux_amd64
OA-macos-arm64 := darwin_arm64
OA-macos-int64 := darwin_amd64
OA-windows-arm64 := windows_arm64
OA-windows-int64 := windows_amd64

ifeq (,$(OA-$(OS-ARCH)))
$(error 'grenadine' has no prebuilt binary for $(OS-ARCH); see https://github.com/clojurestar/grenadine)
endif

ifeq (windows,$(OS-NAME))
GRENADINE-ARC-EXT := zip
GRENADINE-EXE := grenadine.exe
else
GRENADINE-ARC-EXT := tar.gz
GRENADINE-EXE := grenadine
endif

GRENADINE-DIR := grenadine-$(GRENADINE-VERSION)-$(OA-$(OS-ARCH))
GRENADINE-ARC := $(GRENADINE-DIR).$(GRENADINE-ARC-EXT)
GRENADINE-DOWN := https://github.com/clojurestar/grenadine
GRENADINE-DOWN := $(GRENADINE-DOWN)/releases/download/v$(GRENADINE-VERSION)/$(GRENADINE-ARC)

GRENADINE-LOCAL := $(LOCAL-ROOT)/grenadine-$(GRENADINE-VERSION)
GRENADINE := $(GRENADINE-LOCAL)/bin/$(GRENADINE-EXE)

SHELL-DEPS += $(GRENADINE)

override PATH := $(GRENADINE-LOCAL)/bin:$(PATH)
export PATH


$(GRENADINE): $(LOCAL-CACHE)/$(GRENADINE-ARC)
	$Q rm -rf $(LOCAL-TMP)/grenadine-$(GRENADINE-VERSION)
	$Q mkdir -p $(GRENADINE-LOCAL)/bin $(LOCAL-TMP)/grenadine-$(GRENADINE-VERSION)
	$Q case '$(GRENADINE-ARC)' in \
	  *.zip) unzip -q $< -d $(LOCAL-TMP)/grenadine-$(GRENADINE-VERSION) ;; \
	  *) tar -C $(LOCAL-TMP)/grenadine-$(GRENADINE-VERSION) -xzf $< ;; \
	esac
	$Q cp $(LOCAL-TMP)/grenadine-$(GRENADINE-VERSION)/$(GRENADINE-DIR)/$(GRENADINE-EXE) $@
	$Q chmod +x $@
	$Q touch $@
	@$(ECHO)

$(LOCAL-CACHE)/$(GRENADINE-ARC):
	@$(ECHO) "* Installing 'grenadine' locally"
	$Q curl+ $(GRENADINE-DOWN) > $@

endif
