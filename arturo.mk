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

OA-linux-arm64 := mini-arm64-linux
OA-linux-int64 := full-x86_64-linux
OA-macos-arm64 := mini-arm64-macos
OA-macos-int64 := full-x86_64-macos
OA-windows-int64 := windows-amd64

ARTURO-NAME := arturo-$(ARTURO-VERSION)-$(OA-$(OS-ARCH))
ifeq ($(OS-NAME),windows)
ARTURO-TAR := $(ARTURO-NAME).zip
ARTURO := $(LOCAL-BIN)/arturo.exe
else
ARTURO-TAR := $(ARTURO-NAME).tar.gz
ARTURO := $(LOCAL-BIN)/arturo
endif
ARTURO-DOWN := https://github.com/arturo-lang/arturo
ARTURO-DOWN := $(ARTURO-DOWN)/releases/download/v$(ARTURO-VERSION)/$(ARTURO-TAR)

SHELL-DEPS += $(ARTURO)


ifeq ($(OS-NAME),windows)
$(ARTURO): $(LOCAL-CACHE)/$(ARTURO-TAR)
	rm -rf $(LOCAL-TMP)/arturo-$(ARTURO-VERSION)
	mkdir -p $(LOCAL-TMP)/arturo-$(ARTURO-VERSION)
	unzip -q -d $(LOCAL-TMP)/arturo-$(ARTURO-VERSION) $<
	cp $(LOCAL-TMP)/arturo-$(ARTURO-VERSION)/* $(LOCAL-BIN)/
	touch $@
	@echo
else
$(ARTURO): $(LOCAL-CACHE)/$(ARTURO-TAR)
	tar -C $(LOCAL-CACHE) -xf $< -- arturo
	[[ -e $(LOCAL-CACHE)/arturo ]]
	mv $(LOCAL-CACHE)/arturo $@
	touch $@
	@echo
endif

$(LOCAL-CACHE)/$(ARTURO-TAR):
	@echo "* Installing 'arturo' locally"
	curl+ $(ARTURO-DOWN) > $@

endif
