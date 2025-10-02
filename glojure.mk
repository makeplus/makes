GLOJURE-VERSION ?= 0.6.3

ifndef GLOJURE-LOADED
GLOJURE-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
include $(MAKES)/go.mk

override GLOJURE-VERSION := $(if $(findstring 0.,$(GLOJURE-VERSION)) \
  ,v$(GLOJURE-VERSION),$(GLOJURE-VERSION))
GLOJURE-COMMIT ?= $(GLOJURE-VERSION)

GLOJURE-GET-URL ?= github.com/glojurelang/glojure/cmd/glj
GLOJURE-GET-URL := $(GLOJURE-GET-URL)@$(GLOJURE-VERSION)

GLOJURE-REPO ?= https://github.com/glojurelang/glojure
GLOJURE-DIR := $(LOCAL-CACHE)/glojure-$(GLOJURE-VERSION)
export GLOJURE_DIR := $(GLOJURE-DIR)

override GLOJURE-REPO := $(if $(findstring https://,$(GLOJURE-REPO)) \
  ,$(GLOJURE-REPO),https://github.com/$(GLOJURE-REPO))

GLJ := $(LOCAL-BIN)/glj

SHELL-DEPS += $(GLJ) $(GLOJURE-DIR)


$(GLJ): $(GO)
	go install $(GLOJURE-GET-URL)

$(GLOJURE-DIR):
	git clone $(GLOJURE-REPO) $@
	git -C $@ reset --hard $(GLOJURE-COMMIT)

endif
