ifndef GO-LOADED
GO-LOADED := true

$(if $(MAKES),,$(error Please 'include .makes/init.mk'))
$(eval $(call include-local))

GO-VERSION ?= 1.24.3
GO-TARBALL := go$(GO-VERSION).linux-amd64.tar.gz
GO-DOWNLOAD := https://go.dev/dl/$(GO-TARBALL)

GO-CMDS := \
  bug \
  build \
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
  telemetry \
  test \
  tool \
  version \
  vet \

GO-CMDS-SKIP := xxx
GO-CMDS := $(foreach a,$(GO-CMDS),$(if $(findstring $a,$(GO-CMDS-SKIP)),,$a))


GO-LOCAL := $(LOCAL-ROOT)/go-$(GO-VERSION)
GO-BIN := $(GO-LOCAL)/bin
GO := $(GO-BIN)/go

override PATH := $(GO-BIN):$(PATH)
export PATH

ifndef GO-PROGRAM
ifneq (,$(wildcard main.go))
GO-PROGRAM := main
endif
endif


# Go command rules:
ifndef MAKES-NO-RULES

run: $(GO)
ifdef GO-PROGRAM
	go $@ $(GO-PROGRAM).go
else
	echo "Set 'GO-PROGRAM' to use 'make run'"
endif

$(GO-CMDS): $(GO) $(GO-DEPS)
	go $@$(if $(v), -v,) $(opts)

tidy: $(GO)
	go mod $@

ifndef MAKES-NO-CLEAN
clean:
	which go
	[[ -z '$(wildcard $(GO))' ]] || \
	  (set -x; go $@)
endif
endif


# Install rules:
$(GO): $(LOCAL-CACHE)/$(GO-TARBALL)
	tar -C $(LOCAL-ROOT) -xzf $<
	mv $(LOCAL-ROOT)/go $(GO-LOCAL)
	touch $@
	@echo

$(LOCAL-CACHE)/$(GO-TARBALL):
	@echo "Installing 'go' locally"
	curl -Ls $(GO-DOWNLOAD) > $@

endif
