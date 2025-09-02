GO-VERSION ?= 1.25.0
# https://github.com/golang/go

ifndef GO-LOADED
GO-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
$(eval $(call include-local))

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

ifndef GO-PROGRAM
ifneq (,$(wildcard main.go))
GO-PROGRAM := main
endif
endif

OA-linux-arm64 := linux-arm64
OA-linux-int64 := linux-amd64
OA-macos-arm64 := darwin-arm64
OA-macos-int64 := darwin-amd64

GO-TAR := go$(GO-VERSION).$(OA-$(OS-ARCH)).tar.gz
GO-DOWN := https://go.dev/dl/$(GO-TAR)

GO-LOCAL := $(LOCAL-ROOT)/go-$(GO-VERSION)

export GOROOT := $(GO-LOCAL)
export GOPATH := $(LOCAL-ROOT)/go
override PATH := $(GOPATH)/bin:$(GO-LOCAL)/bin:$(PATH)

GO := $(GO-LOCAL)/bin/go

SHELL-DEPS += $(GO)


clean::
	chmod -R +w $(LOCAL-ROOT)

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
$(GO):: $(LOCAL-CACHE)/$(GO-TAR)
	tar -C $(LOCAL-ROOT) -xzf $<
	mv $(LOCAL-ROOT)/go $(GO-LOCAL)
	ln $@ $@$(GO-VERSION)
	touch $@
	@echo

$(LOCAL-CACHE)/$(GO-TAR):
	@echo "Installing 'go' locally"
	curl+ $(GO-DOWN) > $@

endif
