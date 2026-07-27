GOBB-VERSION ?= 0.1.2
# https://github.com/clojurestar/gobb

ifndef GOBB-LOADED
GOBB-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
$(eval $(call include-local))

OA-linux-arm64 := linux_arm64
OA-linux-int64 := linux_amd64
OA-macos-arm64 := darwin_arm64
OA-macos-int64 := darwin_amd64
OA-windows-arm64 := windows_arm64
OA-windows-int64 := windows_amd64

ifeq (,$(OA-$(OS-ARCH)))
$(error 'gobb' has no prebuilt binary for $(OS-ARCH); see https://github.com/clojurestar/gobb)
endif

ifeq (windows,$(OS-NAME))
GOBB-ARC-EXT := zip
GOBB-EXE := gobb.exe
else
GOBB-ARC-EXT := tar.gz
GOBB-EXE := gobb
endif

GOBB-DIR := gobb-$(GOBB-VERSION)-$(OA-$(OS-ARCH))
GOBB-ARC := $(GOBB-DIR).$(GOBB-ARC-EXT)
GOBB-DOWN := https://github.com/clojurestar/gobb
GOBB-DOWN := $(GOBB-DOWN)/releases/download/v$(GOBB-VERSION)/$(GOBB-ARC)

GOBB-LOCAL := $(LOCAL-ROOT)/gobb-$(GOBB-VERSION)
GOBB := $(GOBB-LOCAL)/bin/$(GOBB-EXE)

SHELL-DEPS += $(GOBB)

override PATH := $(GOBB-LOCAL)/bin:$(PATH)
export PATH


$(GOBB): $(LOCAL-CACHE)/$(GOBB-ARC)
	$Q rm -rf $(LOCAL-TMP)/gobb-$(GOBB-VERSION)
	$Q mkdir -p $(GOBB-LOCAL)/bin $(LOCAL-TMP)/gobb-$(GOBB-VERSION)
	$Q case '$(GOBB-ARC)' in \
	  *.zip) unzip -q $< -d $(LOCAL-TMP)/gobb-$(GOBB-VERSION) ;; \
	  *) tar -C $(LOCAL-TMP)/gobb-$(GOBB-VERSION) -xzf $< ;; \
	esac
	$Q cp $(LOCAL-TMP)/gobb-$(GOBB-VERSION)/$(GOBB-DIR)/$(GOBB-EXE) $@
	$Q chmod +x $@
	$Q touch $@
	@$(ECHO)

$(LOCAL-CACHE)/$(GOBB-ARC):
	@$(ECHO) "* Installing 'gobb' locally"
	$Q curl+ $(GOBB-DOWN) > $@

endif
