GIT-DIR := $(shell \
  dir=$$(git rev-parse --git-common-dir 2>/dev/null); \
  [[ $$dir && $$dir == *.git && -d $$dir ]] && \
  (cd "$$dir" && pwd -P))
ifeq (,$(GIT-DIR))
$(error Not inside a git repo)
endif

GIT-REPO-DIR := $(shell echo $$(dirname $(GIT-DIR)))
GIT-REPO-NAME := $(shell echo $$(basename $(GIT-REPO-DIR)))
