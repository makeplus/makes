ARTURO-VERSION ?= 0.10.0

# XXX Needs these. Need to auto-install:
# sudo apt install libwebkit2gtk-4.1-dev
# cd /usr/lib/x86_64-linux-gnu/
# sudo ln -s libwebkit2gtk-4.1.so.0.17.8 libwebkit2gtk-4.0.so.37
# sudo apt install libjavascriptcoregtk-4.1-dev
# sudo ln -s libjavascriptcoregtk-4.1.so.0.8.6 libjavascriptcoregtk-4.0.so.18
# sudo apt install libpcre3-dev

ifndef ARTURO-LOADED
ARTURO-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
$(eval $(call include-local))

OA-linux-arm64 := linux-arm64-mini
OA-linux-int64 := linux-amd64
OA-macos-arm64 := macos-arm64-mini
OA-macos-int64 := macos-amd64
OA-windows-int64 := windows-amd64

ARTURO-NAME := arturo-$(ARTURO-VERSION)-$(OA-$(OS-ARCH))
ARTURO-ZIP := $(ARTURO-NAME).zip
ifeq ($(OS-NAME),windows)
ARTURO := $(LOCAL-BIN)/arturo.exe
else
ARTURO := $(LOCAL-BIN)/arturo
endif
ARTURO-DOWN := https://github.com/arturo-lang/arturo
ARTURO-DOWN := $(ARTURO-DOWN)/releases/download/v$(ARTURO-VERSION)
ARTURO-DOWN := $(ARTURO-DOWN)/$(ARTURO-ZIP)

SHELL-DEPS += $(ARTURO)


ifeq ($(OS-NAME),windows)
$(ARTURO): $(LOCAL-CACHE)/$(ARTURO-ZIP)
	rm -rf $(LOCAL-TMP)/arturo-$(ARTURO-VERSION)
	mkdir -p $(LOCAL-TMP)/arturo-$(ARTURO-VERSION)
	unzip -q -d $(LOCAL-TMP)/arturo-$(ARTURO-VERSION) $<
	cp $(LOCAL-TMP)/arturo-$(ARTURO-VERSION)/* $(LOCAL-BIN)/
	touch $@
	@echo
else
$(ARTURO): $(LOCAL-CACHE)/$(ARTURO-ZIP)
	rm -rf $(LOCAL-TMP)/arturo-$(ARTURO-VERSION)
	mkdir -p $(LOCAL-TMP)/arturo-$(ARTURO-VERSION)
	unzip -q -d $(LOCAL-TMP)/arturo-$(ARTURO-VERSION) $<
	[[ -e $(LOCAL-TMP)/arturo-$(ARTURO-VERSION)/arturo ]]
	mv $(LOCAL-TMP)/arturo-$(ARTURO-VERSION)/arturo $@
	touch $@
	@echo
endif

$(LOCAL-CACHE)/$(ARTURO-ZIP):
	@echo "* Installing 'arturo' locally"
	curl+ $(ARTURO-DOWN) > $@

endif
