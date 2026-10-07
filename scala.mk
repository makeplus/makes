SCALA-CLI-VERSION ?= 1.18.0
# https://github.com/VirtusLab/scala-cli

ifndef SCALA-LOADED
SCALA-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
$(eval $(call include-local))

OA-linux-arm64 := aarch64-pc-linux
OA-linux-int64 := x86_64-pc-linux
OA-macos-arm64 := aarch64-apple-darwin
OA-macos-int64 := x86_64-apple-darwin
OA-windows-int64 := x86_64-pc-win32

ifeq (windows,$(OS-NAME))
  SCALA-CLI-ARC := scala-cli-$(OA-$(OS-ARCH)).zip
  SCALA-CLI-EXE := scala-cli.exe
else
  SCALA-CLI-ARC := scala-cli-$(OA-$(OS-ARCH)).gz
  SCALA-CLI-EXE := scala-cli
endif

SCALA-CLI-DOWN := https://github.com/VirtusLab/scala-cli/releases/download/v$(SCALA-CLI-VERSION)/$(SCALA-CLI-ARC)
SCALA-LOCAL := $(LOCAL-ROOT)/scala-cli-$(SCALA-CLI-VERSION)
SCALA-CLI := $(SCALA-LOCAL)/bin/$(SCALA-CLI-EXE)
SCALA-COMP-BASH := \
  $(LOCAL-SHARE)/bash-completion/completions/scala-cli
SCALA-COMP-ZSH := $(LOCAL-SHARE)/zsh/site-functions/_scala-cli
SCALA-COMP-FISH := \
  $(LOCAL-SHARE)/fish/vendor_completions.d/scala-cli.fish
SCALA-COMP := \
  $(SCALA-COMP-BASH) \
  $(SCALA-COMP-ZSH) \
  $(SCALA-COMP-FISH)

SHELL-DEPS += $(SCALA-CLI) $(SCALA-COMP)

override PATH := $(SCALA-LOCAL)/bin:$(PATH)
export PATH


$(SCALA-CLI): $(LOCAL-CACHE)/$(SCALA-CLI-ARC)
	$Q mkdir -p $(SCALA-LOCAL)/bin
ifeq (windows,$(OS-NAME))
	$Q unzip -q -j $< $(SCALA-CLI-EXE) -d $(SCALA-LOCAL)/bin
else
	$Q gzip -dc $< > $@
endif
	$Q chmod +x $@
	@$(ECHO)

$(LOCAL-CACHE)/$(SCALA-CLI-ARC):
	@$(ECHO) "* Installing 'scala-cli' locally"
	$Q curl+ $(SCALA-CLI-DOWN) > $@

$(SCALA-COMP-BASH): $(SCALA-CLI)
	$Q mkdir -p $(@D) $(LOCAL-TMP)/scala-completion-bash
	$Q $(SCALA-CLI) install completions --shell bash \
	  --output $(LOCAL-TMP)/scala-completion-bash \
	  --rc-file $@ >/dev/null

$(SCALA-COMP-ZSH): $(SCALA-CLI)
	$Q mkdir -p $(@D) $(LOCAL-TMP)/scala-completion-zsh
	$Q $(SCALA-CLI) install completions --shell zsh \
	  --output $(LOCAL-TMP)/scala-completion-zsh \
	  --rc-file $(LOCAL-TMP)/scala-completion-zsh/rc >/dev/null
	$Q cp $(LOCAL-TMP)/scala-completion-zsh/zsh/_scala-cli $@

$(SCALA-COMP-FISH): $(SCALA-CLI)
	$Q mkdir -p $(@D) $(LOCAL-TMP)/scala-completion-fish
	$Q $(SCALA-CLI) install completions --shell fish \
	  --output $(LOCAL-TMP)/scala-completion-fish \
	  --rc-file $@ >/dev/null

endif
