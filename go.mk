ifndef MAKES
$(error Please 'include .makes/init.mk')
endif
ifndef LOCAL-ROOT
include $(MAKES)/local.mk
endif

GO-VERSION ?= 1.24.3
GO-TARBALL := go$(GO-VERSION).linux-amd64.tar.gz
GO-DOWNLOAD := https://go.dev/dl/$(GO-TARBALL)

GO-CMDS := \
  bug \
  build \
  clean \
  doc \
  env \
  fix \
  fmt \
  generate \
  get \
  install \
  list \
  mod \
  work \
  run \
  telemetry \
  test \
  tool \
  version \
  vet \


GO-LOCAL := $(LOCAL-ROOT)/go-$(GO-VERSION)
GO-BIN := $(GO-LOCAL)/bin
GO := $(GO-BIN)/go

override PATH := $(GO-BIN):$(PATH)
export PATH


$(GO): $(LOCAL-CACHE)/$(GO-TARBALL)
	tar -C $(LOCAL-ROOT) -xzf $<
	mv $(LOCAL-ROOT)/go $(GO-LOCAL)
	touch $@
	@echo

$(LOCAL-CACHE)/$(GO-TARBALL):
	@echo "Installing 'go' locally"
	curl -Ls $(GO-DOWNLOAD) > $@
