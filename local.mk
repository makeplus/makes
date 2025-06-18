# This system is intended only to be used in a Git repository.
GIT-DIR := $(shell \
  dir=$$(git rev-parse --git-common-dir 2>/dev/null); \
  [[ $$dir && $$dir == *.git && -d $$dir ]] && \
  (cd "$$dir" && pwd -P))
ifeq (,$(GIT-DIR))
$(error Not inside a git repo)
endif

GIT-ROOT := $(shell dirname $(GIT-DIR))

LOCAL-ROOT := $(GIT-DIR)/.local

# We intend everything written to disk to be inside this repo by default.
# We cache under .git/0/ and use .git/0/tmp for /tmp/.
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
