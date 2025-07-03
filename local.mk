ifdef LOCAL-LOADED
$(error local.mk already loaded)
endif
LOCAL-LOADED := true

$(if $(MAKES),,$(error Please 'include .makes/init.mk'))

ifdef MAKES_LOCAL_DIR
LOCAL-ROOT := $(MAKES_LOCAL_DIR)
else
ifdef MAKES_REPO_DIR
LOCAL-ROOT := $(MAKEFILE-DIR)/.cache/.local
else
LOCAL-ROOT := $(abspath $(dir $(MAKES)))/.local
endif
endif

# We intend everything written to disk to be inside this repo by default.
LOCAL-PREFIX := $(LOCAL-ROOT)
LOCAL-CACHE  := $(LOCAL-PREFIX)/cache
_ := $(shell mkdir -p $(LOCAL-CACHE))
LOCAL-TMP    := $(LOCAL-PREFIX)/tmp
_ := $(shell mkdir -p $(LOCAL-TMP))
LOCAL-BIN    := $(LOCAL-PREFIX)/bin
_ := $(shell mkdir -p $(LOCAL-BIN))
LOCAL-LIB    := $(LOCAL-PREFIX)/lib
_ := $(shell mkdir -p $(LOCAL-LIB))
LOCAL-MAN    := $(LOCAL-PREFIX)/man
_ := $(shell mkdir -p $(LOCAL-MAN))
LOCAL-SHARE  := $(LOCAL-PREFIX)/share
_ := $(shell mkdir -p $(LOCAL-SHARE))

ifdef MAKES_NO_LOCAL_HOME
LOCAL-HOME   := $(HOME)
else
LOCAL-HOME   := $(LOCAL-PREFIX)/home
_ := $(shell mkdir -p $(LOCAL-HOME))
endif

override PATH := $(LOCAL-BIN):$(PATH)

export PATH
