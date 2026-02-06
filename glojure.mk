GLOJURE-VERSION ?= 0.6.4

ifndef GLOJURE-LOADED
GLOJURE-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
include $(MAKES)/go.mk

override GLOJURE-VERSION := $(if $(findstring 0.,$(GLOJURE-VERSION)) \
  ,v$(GLOJURE-VERSION),$(GLOJURE-VERSION))
GLOJURE-COMMIT ?= $(GLOJURE-VERSION)

GLOJURE-GET-URL ?= github.com/glojurelang/glojure/cmd/glj
GLOJURE-GET-URL := $(GLOJURE-GET-URL)@$(GLOJURE-COMMIT)

GLOJURE-REPO ?= https://github.com/glojurelang/glojure
GLOJURE-DIR ?= $(LOCAL-CACHE)/glojure-$(GLOJURE-VERSION)
export GLOJURE_DIR := $(GLOJURE-DIR)

override GLOJURE-REPO := $(if $(findstring https://,$(GLOJURE-REPO)) \
  ,$(GLOJURE-REPO),https://github.com/$(GLOJURE-REPO))

GLJ := $(LOCAL-BIN)/glj

SHELL-DEPS += $(GLJ) $(GLOJURE-DIR)


$(GLJ): $(GO) $(GLOJURE-DIR)
	$Q cd $(GLOJURE-DIR)/cmd/glj && GOBIN=$(LOCAL-BIN) go install . $O
	$Q touch $@

$(GLOJURE-DIR):
	$Q git clone$(if $Q, -q) $(GLOJURE-REPO) $@
	$Q git -C $@ checkout$(if $Q, -q) $(GLOJURE-COMMIT)

endif
