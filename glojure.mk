GLOJURE-VERSION ?= 0.6.4

ifndef GLOJURE-LOADED
GLOJURE-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
include $(MAKES)/go.mk

override GLOJURE-VERSION := $(if $(findstring 0.,$(GLOJURE-VERSION)) \
  ,v$(GLOJURE-VERSION),$(GLOJURE-VERSION))
GLOJURE-COMMIT ?= $(GLOJURE-VERSION)

GLOJURE-REPO ?= https://github.com/glojurelang/glojure
GLOJURE-DIR ?= $(LOCAL-CACHE)/glojure-$(GLOJURE-VERSION)
export GLOJURE_DIR := $(GLOJURE-DIR)

override GLOJURE-REPO := $(if $(findstring https://,$(GLOJURE-REPO)) \
  ,$(GLOJURE-REPO),https://github.com/$(GLOJURE-REPO))

GLJ := $(LOCAL-BIN)/glj

# Auto-detect: dev branch → build from source
ifndef GLOJURE-FROM-SOURCE
ifneq ($(GLOJURE-COMMIT),$(GLOJURE-VERSION))
GLOJURE-FROM-SOURCE := true
endif
endif

SHELL-DEPS += $(GLJ) $(GLOJURE-DIR)


ifdef GLOJURE-FROM-SOURCE
#--- Build from source ---

$(GLJ): $(GO) $(GLOJURE-DIR)
	$Q cd $(GLOJURE-DIR)/cmd/glj && \
	  GOBIN=$(LOCAL-BIN) go install . $O
	$Q touch $@

else
#--- Download pre-built binary ---

OA-linux-arm64 := linux_arm64
OA-linux-int64 := linux_amd64
OA-macos-arm64 := darwin_arm64
OA-macos-int64 := darwin_amd64

GLOJURE-STRIP-V := $(patsubst v%,%,$(GLOJURE-VERSION))
GLOJURE-TAR := glj-$(GLOJURE-STRIP-V)-$(OA-$(OS-ARCH)).tar.gz
GLOJURE-DOWN := \
  $(GLOJURE-REPO)/releases/download/$(GLOJURE-VERSION)/$(GLOJURE-TAR)

$(GLJ): $(LOCAL-CACHE)/$(GLOJURE-TAR)
	$Q tar -C $(LOCAL-CACHE) -xzf $<
	$Q [[ -e $(LOCAL-CACHE)/glj ]]
	$Q mv $(LOCAL-CACHE)/glj $(LOCAL-BIN)/
	$Q touch $@
	@$(ECHO)

$(LOCAL-CACHE)/$(GLOJURE-TAR):
	@$(ECHO) "* Installing 'glj' locally"
	$Q curl+ $(GLOJURE-DOWN) > $@

endif


# Repo clone always needed (for rewrite scripts)
# Shallow clone for speed
$(GLOJURE-DIR):
	$Q git clone --depth 1 -b $(GLOJURE-COMMIT)$(if $Q, -q) \
	  $(GLOJURE-REPO) $@

endif
