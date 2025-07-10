ifndef CURSOR-VERSION
$(if $(shell command -v jq),,$(error cursor.mk requires jq to be installed))
endif

CURSOR-HISTORY-URL := \
  https://github.com/oslook/cursor-ai-downloads/raw/HEAD/version-history.json

CURSOR-HISTORY-JSON := $(shell curl -sL $(CURSOR-HISTORY-URL))

CURSOR-VERSION ?= $(shell \
  jq -r '.versions[0].version' <<<'$(CURSOR-HISTORY-JSON)')

OA-linux-arm64 := linux-arm64
OA-linux-int64 := linux-amd64
OA-macos-arm64 := darwin-arm64
OA-macos-int64 := darwin-amd64

ifdef CURSOR-VERSION
  CURSOR-DATE := $(shell \
    jq -r '.versions[0].date' <<<'$(CURSOR-HISTORY-JSON)')
  URL-linux-int64 := $(shell \
    jq -r '.versions[] | select(.version == "$(CURSOR-VERSION)") | \
    .platforms."linux-x64"' <<<'$(CURSOR-HISTORY-JSON)')
else
  CURSOR-VERSION := 1.2.2
  CURSOR-DATE := 2025-07-07
  URL-linux-int64 := https://downloads.cursor.com/production/faa03b17cce93e8a80b7d62d57f5eda6bb6ab9fa/linux/x64/Cursor-1.2.2-x86_64.AppImage
endif

$(if $(MAKES),,$(error Please 'include .makes/init.mk'))
$(eval $(call include-local))

CURSOR-DOWNLOAD := $(URL-$(OS-ARCH))
CURSOR-EXE := $(shell basename $(CURSOR-DOWNLOAD))

ifndef CURSOR-EXE
$(error Unable to determine cursor executable)
endif

CURSOR := $(LOCAL-BIN)/$(CURSOR-EXE)

SHELL-DEPS := $(CURSOR)


$(CURSOR):
	@echo "Installing '$(CURSOR-EXE)'"
	curl+ $(CURSOR-DOWNLOAD) > $@
	chmod +x $@
	touch $@
	@echo
