GLOAT-VERSION ?= 0.1.89
# https://github.com/gloathub/gloat

ifndef GLOAT-LOADED
GLOAT-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
$(eval $(call include-local))

GLOAT-REPO ?= https://github.com/gloathub/gloat
GLOAT-DIR ?= $(LOCAL-CACHE)/gloat-$(GLOAT-VERSION)
GLOAT-BIN := $(GLOAT-DIR)/bin

override PATH := $(GLOAT-BIN):$(PATH)
export PATH

GLOAT := $(GLOAT-BIN)/gloat
GLOAT-BASH-COMPLETION := \
  $(LOCAL-SHARE)/bash-completion/completions/gloat
GLOAT-ZSH-COMPLETION := $(LOCAL-SHARE)/zsh/site-functions/_gloat
GLOAT-FISH-COMPLETION := \
  $(LOCAL-SHARE)/fish/vendor_completions.d/gloat.fish
GLOAT-MAN-NAMES := \
  gloat.1 \
  gloat-go-interop.1 \
  gloat-install.1 \
  gloat-java-interop.1 \
  gloat-repl.1 \
  gloat-tutorial.1
GLOAT-MAN := $(addprefix $(LOCAL-MAN)/man1/,$(GLOAT-MAN-NAMES))

SHELL-DEPS += \
  $(GLOAT) \
  $(GLOAT-BASH-COMPLETION) \
  $(GLOAT-ZSH-COMPLETION) \
  $(GLOAT-FISH-COMPLETION) \
  $(GLOAT-MAN)


$(GLOAT): $(GLOAT-DIR)
	$Q gloat --version $O
	$Q touch $@
	@$(ECHO)

$(GLOAT-BASH-COMPLETION): $(GLOAT)
	$Q mkdir -p $(@D)
	$Q cp $(GLOAT-DIR)/template/completion.bash \
	  $@

$(GLOAT-ZSH-COMPLETION): $(GLOAT)
	$Q mkdir -p $(@D)
	$Q cp $(GLOAT-DIR)/template/completion.zsh \
	  $@

$(GLOAT-FISH-COMPLETION): $(GLOAT)
	$Q mkdir -p $(@D)
	$Q cp $(GLOAT-DIR)/template/completion.fish \
	  $@

$(GLOAT-MAN): $(GLOAT)
	$Q mkdir -p $(@D)
	$Q cp $(GLOAT-DIR)/man/man1/$(@F) $@

$(GLOAT-DIR):
	@$(ECHO) "* Cloning 'gloat' locally (v$(GLOAT-VERSION))"
	$Q git clone$(if $Q, -q) --depth=1 --branch v$(GLOAT-VERSION) \
	  --config advice.detachedHead=false \
	  $(GLOAT-REPO) $@
	@$(ECHO)

endif
