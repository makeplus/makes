K3D-VERSION ?= 5.8.3
# https://github.com/k3d-io/k3d

ifndef K3D-LOADED
K3D-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
$(eval $(call include-local))

#------------------------------------------------------------------------------
# Configuration Variables
#------------------------------------------------------------------------------

# Cluster name - can be overridden by user
K3D-CLUSTER-NAME ?= makes-k3d

# Number of server/agent nodes
K3D-SERVERS ?= 1
K3D-AGENTS ?= 0

# Optional: k3d create options (user can add --api-port, --port, etc.)
K3D-CREATE-OPTIONS ?=

#------------------------------------------------------------------------------
# OS/Architecture Mappings
#------------------------------------------------------------------------------

# k3d uses standard linux/darwin with amd64/arm64
OA-linux-arm64 := linux-arm64
OA-linux-int64 := linux-amd64
OA-macos-arm64 := darwin-arm64
OA-macos-int64 := darwin-amd64

#------------------------------------------------------------------------------
# Download Configuration
#------------------------------------------------------------------------------

K3D-BIN-NAME := k3d-$(OA-$(OS-ARCH))
K3D-DOWN := https://github.com/k3d-io/k3d/releases/download/v$(K3D-VERSION)/$(K3D-BIN-NAME)

#------------------------------------------------------------------------------
# Local Paths
#------------------------------------------------------------------------------

K3D := $(LOCAL-BIN)/k3d
K3D-KUBECONFIG := $(LOCAL-CACHE)/k3d-$(K3D-CLUSTER-NAME)-kubeconfig

# State marker file - indicates cluster exists and is running
K3D-CLUSTER-FILE := $(LOCAL-CACHE)/k3d-cluster-$(K3D-CLUSTER-NAME)

#------------------------------------------------------------------------------
# Docker Check
#------------------------------------------------------------------------------

# Check if Docker daemon is accessible via Unix socket
K3D-DOCKER-RUNNING := \
  $(shell curl -s --unix-socket /var/run/docker.sock http/_ping \
	  2>&1 >/dev/null && echo true)

# Macro to enforce Docker is running before cluster operations
define k3d-require-docker
$(if $(K3D-DOCKER-RUNNING),,$(error Docker is not running. Please start Docker first.))
endef

#------------------------------------------------------------------------------
# Shell Dependencies
#------------------------------------------------------------------------------

SHELL-DEPS += $(K3D)

#------------------------------------------------------------------------------
# Cleanup Integration
#------------------------------------------------------------------------------

realclean:: k3d-delete

#------------------------------------------------------------------------------
# Binary Installation Target
#------------------------------------------------------------------------------

$(K3D): $(LOCAL-CACHE)/$(K3D-BIN-NAME)
	cp $< $@
	chmod +x $@
	touch $@
	@echo

$(LOCAL-CACHE)/$(K3D-BIN-NAME):
	@echo "* Installing 'k3d' locally"
	curl+ $(K3D-DOWN) > $@

#------------------------------------------------------------------------------
# Idempotent Cluster Target
#------------------------------------------------------------------------------

# The main target: ensures cluster exists and is running
# This is what users depend on in their Makefiles
$(K3D-CLUSTER-FILE): $(K3D)
	$(call k3d-require-docker)
	@if $(K3D) cluster list -o json 2>/dev/null | \
	    grep -q '"name":"$(K3D-CLUSTER-NAME)"'; then \
	  if [ "$$($(K3D) cluster list -o json 2>/dev/null | \
	      grep '"name":"$(K3D-CLUSTER-NAME)"' | \
	      grep -o '"serversRunning":[0-9]*' | cut -d: -f2)" = "0" ]; then \
	    echo "* Starting stopped k3d cluster '$(K3D-CLUSTER-NAME)'"; \
	    $(K3D) cluster start $(K3D-CLUSTER-NAME); \
	  else \
	    echo "* k3d cluster '$(K3D-CLUSTER-NAME)' is already running"; \
	  fi; \
	else \
	  echo "* Creating k3d cluster '$(K3D-CLUSTER-NAME)'"; \
	  $(K3D) cluster create $(K3D-CLUSTER-NAME) \
	    --servers $(K3D-SERVERS) \
	    --agents $(K3D-AGENTS) \
	    $(K3D-CREATE-OPTIONS); \
	fi
	@$(K3D) kubeconfig get $(K3D-CLUSTER-NAME) > $(K3D-KUBECONFIG)
	@touch $@

# Convenience alias
K3D-CLUSTER := $(K3D-CLUSTER-FILE)

#------------------------------------------------------------------------------
# Manual Control Targets
#------------------------------------------------------------------------------

.PHONY: k3d-start k3d-stop k3d-status k3d-delete k3d-kubeconfig k3d-cluster

k3d-start: $(K3D)
	$(call k3d-require-docker)
	@if $(K3D) cluster list -o json 2>/dev/null | \
	    grep -q '"name":"$(K3D-CLUSTER-NAME)"'; then \
	  $(K3D) cluster start $(K3D-CLUSTER-NAME); \
	  $(K3D) kubeconfig get $(K3D-CLUSTER-NAME) > $(K3D-KUBECONFIG); \
	  touch $(K3D-CLUSTER-FILE); \
	else \
	  echo "Cluster '$(K3D-CLUSTER-NAME)' does not exist. Use 'make k3d-cluster' to create."; \
	  exit 1; \
	fi

k3d-stop: $(K3D)
	$(call k3d-require-docker)
	-$(K3D) cluster stop $(K3D-CLUSTER-NAME)
	$(RM) $(K3D-CLUSTER-FILE)

k3d-status: $(K3D)
	$(call k3d-require-docker)
	@$(K3D) cluster list

k3d-delete: $(K3D)
	$(call k3d-require-docker)
	-$(K3D) cluster delete $(K3D-CLUSTER-NAME)
	$(RM) $(K3D-CLUSTER-FILE) $(K3D-KUBECONFIG)

# Target to export kubeconfig for current cluster
k3d-kubeconfig: $(K3D-CLUSTER-FILE)
	@echo "export KUBECONFIG=$(K3D-KUBECONFIG)"

# Convenience target to create cluster (alias for the marker file)
k3d-cluster: $(K3D-CLUSTER-FILE)

endif
