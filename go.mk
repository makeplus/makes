GO-VERSION ?= 1.25.5
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
OA-windows-arm64 := windows-arm64
OA-windows-int64 := windows-amd64

ifeq (windows,$(OS-NAME))
GO-EXT := zip
else
GO-EXT := tar.gz
endif
GO-TAR := go$(GO-VERSION).$(OA-$(OS-ARCH)).$(GO-EXT)
GO-DOWN := https://go.dev/dl/$(GO-TAR)

GO-LOCAL := $(LOCAL-ROOT)/go-$(GO-VERSION)
GO-LOCAL-BIN := $(GO-LOCAL)/bin

ifndef GO-NO-DEP-GO
export GOROOT := $(GO-LOCAL)
export GOPATH := $(LOCAL-ROOT)/go
override PATH := $(GOPATH)/bin:$(GO-LOCAL-BIN):$(PATH)
GO := $(GO-LOCAL-BIN)/go
endif

SHELL-DEPS += $(GO)


clean::
	chmod -R +w $(LOCAL-ROOT)

# Go command rules:
ifdef GO-CMDS-RULES

run:: $(GO)
ifndef GO-PROGRAM
	@echo "Set 'GO-PROGRAM' to use 'make run'"
	@exit 1
endif
	go $@ $(GO-PROGRAM).go

$(GO-CMDS):: $(GO) $(GO-DEPS)
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
ifeq (windows,$(OS-NAME))
	$Q unzip -q -d $(LOCAL-ROOT) $<
else
	$Q tar -C $(LOCAL-ROOT) -xzf $<
endif
	$Q rm -fr $(GO-LOCAL)
	$Q mv $(LOCAL-ROOT)/go $(GO-LOCAL)
	$Q ln -fs $@ $@$(GO-VERSION)
	$Q touch $@
	@$(ECHO)

$(LOCAL-CACHE)/$(GO-TAR):
	@$(ECHO) "Installing 'go' locally"
	$Q curl+ $(GO-DOWN) > $@

endif
