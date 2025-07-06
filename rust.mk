ifndef RUST-LOADED
RUST-LOADED := true

$(if $(MAKES),,$(error Please 'include .makes/init.mk'))
$(eval $(call include-local))

export CARGO_HOME := $(LOCAL-ROOT)/cargo
export RUSTUP_HOME := $(LOCAL-ROOT)/rustup

CARGO-BIN := $(CARGO_HOME)/bin

override PATH := $(CARGO-BIN):$(PATH)

CARGO := $(CARGO-BIN)/rustup
RUSTUP := $(CARGO-BIN)/rustup

SHELL-DEPS += $(CARGO)

CARGO-CMDS := \
  build \
  check \
  clippy \
  fmt \
  test \


$(CARGO):
	@echo "Installing '$@'"
	curl --proto '=https' --tlsv1.2 -sSf \
	  https://sh.rustup.rs | \
	  RUSTUP_HOME=$(RUSTUP_HOME) \
	  CARGO_HOME=$(CARGO_HOME) \
	  RUSTUP_INIT_SKIP_PATH_CHECK=yes \
	  bash -s -- \
	    -q -y \
	    --profile minimal \
	    --no-modify-path \
	> /dev/null
	rustup component add clippy
	rustup component add rustfmt
	touch $@

endif
