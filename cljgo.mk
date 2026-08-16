CLJGO-VERSION ?= 0.9.0
# https://github.com/muthuishere/cljgo

ifndef CLJGO-LOADED
CLJGO-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
$(eval $(call include-local))

OA-linux-arm64 := linux_arm64
OA-linux-int64 := linux_amd64
OA-macos-arm64 := darwin_arm64
OA-macos-int64 := darwin_amd64
OA-windows-arm64 := windows_arm64
OA-windows-int64 := windows_amd64

ifeq (,$(OA-$(OS-ARCH)))
$(error 'cljgo' has no prebuilt binary for $(OS-ARCH); see https://github.com/muthuishere/cljgo)
endif

ifeq (windows,$(OS-NAME))
CLJGO-ARC-EXT := zip
CLJGO-EXE := cljgo.exe
else
CLJGO-ARC-EXT := tar.gz
CLJGO-EXE := cljgo
endif

CLJGO-DIR := cljgo_$(CLJGO-VERSION)_$(OA-$(OS-ARCH))
CLJGO-ARC := $(CLJGO-DIR).$(CLJGO-ARC-EXT)
CLJGO-DOWN := https://github.com/muthuishere/cljgo
CLJGO-DOWN := $(CLJGO-DOWN)/releases/download/v$(CLJGO-VERSION)/$(CLJGO-ARC)

CLJGO-LOCAL := $(LOCAL-ROOT)/cljgo-$(CLJGO-VERSION)
CLJGO := $(CLJGO-LOCAL)/bin/$(CLJGO-EXE)

SHELL-DEPS += $(CLJGO)

override PATH := $(CLJGO-LOCAL)/bin:$(PATH)
export PATH


$(CLJGO): $(LOCAL-CACHE)/$(CLJGO-ARC)
	$Q rm -rf $(LOCAL-TMP)/cljgo-$(CLJGO-VERSION)
	$Q mkdir -p $(CLJGO-LOCAL)/bin $(LOCAL-TMP)/cljgo-$(CLJGO-VERSION)
	$Q case '$(CLJGO-ARC)' in \
	  *.zip) unzip -q $< -d $(LOCAL-TMP)/cljgo-$(CLJGO-VERSION) ;; \
	  *) tar -C $(LOCAL-TMP)/cljgo-$(CLJGO-VERSION) -xzf $< ;; \
	esac
	$Q cp $(LOCAL-TMP)/cljgo-$(CLJGO-VERSION)/$(CLJGO-EXE) $@
	$Q chmod +x $@
	$Q touch $@
	@$(ECHO)

$(LOCAL-CACHE)/$(CLJGO-ARC):
	@$(ECHO) "* Installing 'cljgo' locally"
	$Q curl+ $(CLJGO-DOWN) > $@

endif
