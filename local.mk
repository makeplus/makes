ifdef LOCAL-LOADED
$(error local.mk already loaded)
endif
LOCAL-LOADED := true

$(if $(MAKES),,$(error Please 'include .makes/init.mk'))

LOCAL-ROOT := $(abspath $(dir $(MAKES)))/.local

# We intend everything written to disk to be inside this repo by default.
LOCAL-PREFIX := $(LOCAL-ROOT)
LOCAL-CACHE  := $(LOCAL-ROOT)/cache
_ := $(shell mkdir -p $(LOCAL-CACHE))
LOCAL-TMP    := $(LOCAL-ROOT)/tmp
_ := $(shell mkdir -p $(LOCAL-TMP))
LOCAL-BIN    := $(LOCAL-ROOT)/bin
_ := $(shell mkdir -p $(LOCAL-BIN))
LOCAL-HOME   := $(LOCAL-ROOT)/home
_ := $(shell mkdir -p $(LOCAL-HOME))
LOCAL-LIB    := $(LOCAL-ROOT)/lib
_ := $(shell mkdir -p $(LOCAL-LIB))
LOCAL-MAN    := $(LOCAL-ROOT)/man
_ := $(shell mkdir -p $(LOCAL-MAN))
LOCAL-SHARE  := $(LOCAL-ROOT)/share
_ := $(shell mkdir -p $(LOCAL-SHARE))

override PATH := $(LOCAL-BIN):$(PATH)

export PATH
