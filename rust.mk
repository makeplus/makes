ifndef MAKES
$(error Please 'include .makes/init.mk')
endif
ifndef LOCAL-ROOT
include $(MAKES)/local.mk
endif

export CARGO_HOME := $(LOCAL-ROOT)/cargo
export RUSTUP_HOME := $(LOCAL-ROOT)/rustup

CARGO-BIN := $(CARGO_HOME)/bin

override PATH := $(CARGO-BIN):$(PATH)
export PATH

CARGO := $(CARGO-BIN)/cargo
RUSTUP := $(CARGO-BIN)/rustup

CARGO-CMDS := \
  build \
  check \
  clippy \
  fmt \
  test \


$(CARGO)::
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

distclean::
	$(RM) -r $(CARGO_HOME) $(RUSTUP_HOME)
