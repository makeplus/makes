GLOJURE-VERSION ?= 0.5.1

ifndef GLOJURE-LOADED
GLOJURE-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
include $(MAKES)/go.mk

OA-linux-arm64 := linux_arm64
OA-linux-int64 := linux_amd64
OA-macos-arm64 := darwin_arm64
OA-macos-int64 := darwin_amd64
OA := $(OA-$(OS-ARCH))

override GLOJURE-VERSION := $(if $(findstring 0.,$(GLOJURE-VERSION)) \
  ,v$(GLOJURE-VERSION),$(GLOJURE-VERSION))

GLOJURE-DIR := $(LOCAL-CACHE)/glojure-$(GLOJURE-VERSION)
GLOJURE-REPO ?= https://github.com/glojurelang/glojure

override GLOJURE-REPO := $(if $(findstring https://,$(GLOJURE-REPO)) \
  ,$(GLOJURE-REPO),https://github.com/$(GLOJURE-REPO))

GLOJURE := $(LOCAL-BIN)/glj

SHELL-DEPS += $(GLOJURE)


$(GLOJURE): $(GLOJURE-DIR)/bin/$(OA)/glj
	cp $< $@
	touch $@
	@echo

$(GLOJURE-DIR)/bin/$(OA)/glj: $(GLOJURE-DIR) $(GO)
	$(MAKE) -C $(GLOJURE-DIR) bin/$(OA)/glj GO-VERSION=$(GO-VERSION)

$(GLOJURE-DIR):
	@echo "Installing 'glj' locally"
	git clone $(GLOJURE-REPO) $@
	git -C $@ checkout $(GLOJURE-VERSION)

endif
