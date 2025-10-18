$(if $(LOCAL-LOADED),$(error local.mk already loaded))
LOCAL-LOADED := true
$(if $(INIT-LOADED),,$(error Please 'include init.mk' first))

ifdef MAKES_LOCAL_DIR
  LOCAL-ROOT := $(MAKES_LOCAL_DIR)
else ifdef MAKES-LOCAL-DIR
  LOCAL-ROOT := $(MAKES-LOCAL-DIR)
else
  LOCAL-ROOT := $(dir $(MAKES))/.local
endif
LOCAL-ROOT := $(abspath $(LOCAL-ROOT))

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
