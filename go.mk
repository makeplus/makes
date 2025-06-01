ifndef MAKES
$(error Please 'include .makes/init.mk')
endif
ifndef LOCAL-ROOT
include $(MAKES)/local.mk
endif

GO-VERSION := 1.24.3
GO-TARBALL := go$(GO-VERSION).linux-amd64.tar.gz
GO-DOWNLOAD := https://go.dev/dl/$(GO-TARBALL)

override PATH := $(GO-BIN):$(PATH)
export PATH

GO-LOCAL := $(LOCAL-ROOT)/go
GO-BIN := $(GO-LOCAL)/bin
GO := $(GO-BIN)/go

override PATH := $(GO-BIN):$(PATH)
export PATH


$(GO): $(LOCAL-CACHE)/$(GO-TARBALL)
	tar -C $(LOCAL-ROOT) -xzf $<
	touch $@

$(LOCAL-CACHE)/$(GO-TARBALL):
	curl -Ls $(GO-DOWNLOAD) > $@
	touch $@
