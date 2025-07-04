ifndef GIT-LOADED
GIT-LOADED := true

GIT-DIR := $(shell \
  dir=$$(git rev-parse --git-common-dir 2>/dev/null); \
  [[ $$dir && $$dir == *.git && -d $$dir ]] && \
  (cd "$$dir" && pwd -P))

$(if $(GIT-DIR),,$(error Not inside a git repo))

GIT-REPO-DIR := $(shell echo $$(dirname $(GIT-DIR)))
GIT-REPO-NAME := $(shell echo $$(basename $(GIT-REPO-DIR)))

endif
