$(if $(LOCAL-LOADED),$(error local.mk already loaded))
LOCAL-LOADED := true

$(if $(MAKES),,$(error Please 'include .makes/init.mk'))

ifdef MAKES_LOCAL_DIR
  LOCAL-ROOT := $(MAKES_LOCAL_DIR)
else ifdef MAKES-LOCAL-DIR
  LOCAL-ROOT := $(MAKES-LOCAL-DIR)
else ifdef MAKES_REPO_DIR
  LOCAL-ROOT := $(MAKEFILE-DIR)/.cache/.local
else
  LOCAL-ROOT := $(abspath $(dir $(MAKES)))/.local
endif

LOCAL-PREFIX := $(LOCAL-ROOT)
LOCAL-CACHE  := $(LOCAL-PREFIX)/cache
LOCAL-TMP    := $(LOCAL-PREFIX)/tmp
LOCAL-BIN    := $(LOCAL-PREFIX)/bin
LOCAL-LIB    := $(LOCAL-PREFIX)/lib
LOCAL-MAN    := $(LOCAL-PREFIX)/man
LOCAL-SHARE  := $(LOCAL-PREFIX)/share

ifdef MAKES_NO_LOCAL_HOME
  LOCAL-HOME   := $(HOME)
else
  LOCAL-HOME   := $(LOCAL-PREFIX)/home
endif

$(shell mkdir -p \
  $(LOCAL-CACHE) \
  $(LOCAL-TMP) \
  $(LOCAL-BIN) \
  $(LOCAL-LIB) \
  $(LOCAL-MAN) \
  $(LOCAL-SHARE) \
  $(LOCAL-HOME) \
)

override PATH := $(LOCAL-BIN):$(PATH)

export PATH
