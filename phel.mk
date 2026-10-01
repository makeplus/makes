PHEL-VERSION ?= 0.53.0
# https://github.com/phel-lang/phel-lang

ifndef PHEL-LOADED
PHEL-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
include $(MAKES)/php.mk

PHEL-PHAR := phel.phar
PHEL-DOWN := https://github.com/phel-lang/phel-lang
PHEL-DOWN := $(PHEL-DOWN)/releases/download/v$(PHEL-VERSION)/$(PHEL-PHAR)

PHEL-LOCAL := $(LOCAL-ROOT)/phel-$(PHEL-VERSION)
PHEL := $(PHEL-LOCAL)/bin/phel
PHEL-COMP-BASH := $(LOCAL-SHARE)/bash-completion/completions/phel
PHEL-COMP-ZSH := $(LOCAL-SHARE)/zsh/site-functions/_phel
PHEL-COMP-FISH := $(LOCAL-SHARE)/fish/vendor_completions.d/phel.fish
PHEL-COMP := $(PHEL-COMP-BASH) $(PHEL-COMP-ZSH) $(PHEL-COMP-FISH)
PHEL-COMP-TMP := $(LOCAL-TMP)/phel-completion

SHELL-DEPS += $(PHEL) $(PHEL-COMP)

override PATH := $(PHEL-LOCAL)/bin:$(PATH)
export PATH


$(PHEL): $(LOCAL-CACHE)/phel-$(PHEL-VERSION).phar $(PHP)
	$Q mkdir -p $(PHEL-LOCAL)/bin
	$Q cp $< $@
	$Q chmod +x $@
	@$(ECHO)

$(LOCAL-CACHE)/phel-$(PHEL-VERSION).phar:
	@$(ECHO) "* Installing 'phel' locally"
	$Q curl+ $(PHEL-DOWN) > $@

$(PHEL-COMP-BASH): $(PHEL)
	$Q mkdir -p $(@D) $(PHEL-COMP-TMP)
	$Q cd $(PHEL-COMP-TMP) && $(PHEL) completion bash > $@

$(PHEL-COMP-ZSH): $(PHEL)
	$Q mkdir -p $(@D) $(PHEL-COMP-TMP)
	$Q cd $(PHEL-COMP-TMP) && $(PHEL) completion zsh > $@

$(PHEL-COMP-FISH): $(PHEL)
	$Q mkdir -p $(@D) $(PHEL-COMP-TMP)
	$Q cd $(PHEL-COMP-TMP) && $(PHEL) completion fish > $@

endif
