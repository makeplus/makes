GO-VERSION ?= 1.24.4

ifndef GO-LOADED
GO-LOADED := true

$(if $(MAKES),,$(error Please 'include .makes/init.mk'))
$(eval $(call include-local))

GO-TARBALL := go$(GO-VERSION).$(OA2-$(OS-ARCH)).tar.gz
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
GO := $(GO-BIN)/go

SHELL-DEPS += $(GO)

override PATH := $(GO-BIN):$(PATH)

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
