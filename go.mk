GO-VERSION ?= 1.24.4

ifndef GO-LOADED
GO-LOADED := true

$(if $(MAKES),,$(error Please 'include .makes/init.mk'))
$(eval $(call include-local))

OA-linux-arm64 := linux-arm64
OA-linux-int64 := linux-amd64
OA-macos-arm64 := darwin-arm64
OA-macos-int64 := darwin-amd64

GO-TARBALL := go$(GO-VERSION).$(OA-$(OS-ARCH)).tar.gz
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

GO-CMDS-SKIP ?= xxx
GO-CMDS := $(filter-out $(GO-CMDS-SKIP),$(GO-CMDS))

GO-LOCAL := $(LOCAL-ROOT)/go-$(GO-VERSION)
GO-BIN := $(GO-LOCAL)/bin

override PATH := $(GO-BIN):$(PATH)

GO := $(GO-BIN)/go

SHELL-DEPS += $(GO)

ifndef GO-PROGRAM
ifneq (,$(wildcard main.go))
GO-PROGRAM := main
endif
endif


# Go command rules:
ifndef MAKES-NO-RULES

run:: $(GO)
ifndef GO-PROGRAM
	@echo "Set 'GO-PROGRAM' to use 'make run'"
	@exit 1
endif
	go $@ $(GO-PROGRAM).go

$(GO-CMDS):: $(if $(GO-NO-DEP-GO),,$(GO)) $(GO-DEPS)
	go $@$(if $(v), -v,) $(opts)

tidy:: $(GO)
	go mod $@

ifndef MAKES-NO-CLEAN
clean::
	@[[ -z '$(wildcard $(GO))' ]] || \
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
	curl+ $(GO-DOWNLOAD) > $@

endif
