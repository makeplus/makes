PULUMI-VERSION ?= 3.265.0

ifndef PULUMI-LOADED
PULUMI-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
$(eval $(call include-local))

OA-linux-arm64 := linux-arm64
OA-linux-int64 := linux-x64
OA-macos-arm64 := darwin-arm64
OA-macos-int64 := darwin-x64

PULUMI-NAME := pulumi-v$(PULUMI-VERSION)-$(OA-$(OS-ARCH))
PULUMI-TAR := $(PULUMI-NAME).tar.gz
PULUMI-DOWN := https://github.com/pulumi/pulumi/releases/download
PULUMI-DOWN := $(PULUMI-DOWN)/v$(PULUMI-VERSION)/$(PULUMI-TAR)

PULUMI := $(LOCAL-BIN)/pulumi
PULUMI-COMP-BASH := $(LOCAL-SHARE)/bash-completion/completions/pulumi
PULUMI-COMP-ZSH := $(LOCAL-SHARE)/zsh/site-functions/_pulumi
PULUMI-COMP-FISH := \
  $(LOCAL-SHARE)/fish/vendor_completions.d/pulumi.fish
PULUMI-COMP := \
  $(PULUMI-COMP-BASH) \
  $(PULUMI-COMP-ZSH) \
  $(PULUMI-COMP-FISH)

SHELL-DEPS += $(PULUMI) $(PULUMI-COMP)


$(PULUMI): $(LOCAL-CACHE)/$(PULUMI-TAR)
	tar -C $(LOCAL-CACHE) -xf $<
	[[ -e $(LOCAL-CACHE)/pulumi/pulumi ]]
	mv $(LOCAL-CACHE)/pulumi/pulumi* $(LOCAL-BIN)/
	@touch $@
	@echo

$(LOCAL-CACHE)/$(PULUMI-TAR):
	@echo "* Installing 'pulumi' locally"
	curl+ $(PULUMI-DOWN) > $@
	@touch $@

$(PULUMI-COMP-BASH): $(PULUMI)
	$Q mkdir -p $(@D) $(LOCAL-TMP)/pulumi-home
	$Q PULUMI_HOME=$(LOCAL-TMP)/pulumi-home \
	  $(PULUMI) gen-completion bash > $@

$(PULUMI-COMP-ZSH): $(PULUMI)
	$Q mkdir -p $(@D) $(LOCAL-TMP)/pulumi-home
	$Q PULUMI_HOME=$(LOCAL-TMP)/pulumi-home \
	  $(PULUMI) gen-completion zsh > $@

$(PULUMI-COMP-FISH): $(PULUMI)
	$Q mkdir -p $(@D) $(LOCAL-TMP)/pulumi-home
	$Q PULUMI_HOME=$(LOCAL-TMP)/pulumi-home \
	  $(PULUMI) gen-completion fish > $@

endif
