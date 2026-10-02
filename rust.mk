RUST-VERSION ?= 1.99.0
# https://github.com/rust-lang/rust

ifndef RUST-LOADED
RUST-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
$(eval $(call include-local))

CARGO-CMDS := \
  build \
  check \
  clippy \
  fmt \
  test \

export CARGO_HOME := $(LOCAL-ROOT)/cargo
export RUSTUP_HOME := $(LOCAL-ROOT)/rustup

CARGO-BIN := $(CARGO_HOME)/bin
override PATH := $(CARGO-BIN):$(PATH)
export PATH

ifeq ($(OS-NAME),windows)
CARGO := $(CARGO-BIN)/cargo.exe
RUSTUP := $(CARGO-BIN)/rustup.exe
else
CARGO := $(CARGO-BIN)/cargo
RUSTUP := $(CARGO-BIN)/rustup
endif
RUST-COMP-BASH := $(LOCAL-SHARE)/bash-completion/completions/cargo
RUST-COMP-ZSH := $(LOCAL-SHARE)/zsh/site-functions/_cargo
RUSTUP-COMP-BASH := $(LOCAL-SHARE)/bash-completion/completions/rustup
RUSTUP-COMP-ZSH := $(LOCAL-SHARE)/zsh/site-functions/_rustup
RUSTUP-COMP-FISH := \
  $(LOCAL-SHARE)/fish/vendor_completions.d/rustup.fish
RUST-COMP := \
  $(RUST-COMP-BASH) \
  $(RUST-COMP-ZSH) \
  $(RUSTUP-COMP-BASH) \
  $(RUSTUP-COMP-ZSH) \
  $(RUSTUP-COMP-FISH)

SHELL-DEPS += $(CARGO) $(RUST-COMP)


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
	rustup install $(RUST-VERSION)
	rustup default $(RUST-VERSION)
	rustup component add clippy
	rustup component add rustfmt
	touch $@

$(RUST-COMP-BASH): $(CARGO)
	$Q mkdir -p $(@D)
	$Q $(RUSTUP) completions bash cargo > $@

$(RUST-COMP-ZSH): $(CARGO)
	$Q mkdir -p $(@D)
	$Q $(RUSTUP) completions zsh cargo > $@

$(RUSTUP-COMP-BASH): $(CARGO)
	$Q mkdir -p $(@D)
	$Q $(RUSTUP) completions bash rustup > $@

$(RUSTUP-COMP-ZSH): $(CARGO)
	$Q mkdir -p $(@D)
	$Q $(RUSTUP) completions zsh rustup > $@

$(RUSTUP-COMP-FISH): $(CARGO)
	$Q mkdir -p $(@D)
	$Q $(RUSTUP) completions fish rustup > $@

endif
