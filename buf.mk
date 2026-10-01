BUF-VERSION ?= 1.73.0

ifndef BUF-LOADED
BUF-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
$(eval $(call include-local))

OA-linux-arm64 := Linux-aarch64
OA-linux-int64 := Linux-x86_64
OA-macos-arm64 := Darwin-arm64
OA-macos-int64 := Darwin-x86_64

BUF-DIR := buf-$(OA-$(OS-ARCH))
BUF-TAR := $(BUF-DIR).tar.gz
BUF-DOWN := https://github.com/bufbuild/buf
BUF-DOWN := $(BUF-DOWN)/releases/download/v$(BUF-VERSION)/$(BUF-TAR)

BUF := $(LOCAL-BIN)/buf
BUF-COMP-BASH := $(LOCAL-SHARE)/bash-completion/completions/buf
BUF-COMP-ZSH := $(LOCAL-SHARE)/zsh/site-functions/_buf
BUF-COMP-FISH := $(LOCAL-SHARE)/fish/vendor_completions.d/buf.fish
BUF-COMP := $(BUF-COMP-BASH) $(BUF-COMP-ZSH) $(BUF-COMP-FISH)
BUF-MAN := $(LOCAL-SHARE)/man/man1/buf.1

SHELL-DEPS += $(BUF) $(BUF-COMP) $(BUF-MAN)


$(BUF): $(LOCAL-CACHE)/$(BUF-TAR)
	$Q tar -C $(LOCAL-CACHE) -xf $<
	cp -r $(LOCAL-CACHE)/buf/{bin,etc,share} $(LOCAL-PREFIX)
	[[ -e $@ ]]
	@$(ECHO)

$(LOCAL-CACHE)/$(BUF-TAR):
	@$(ECHO) "* Installing 'buf' locally"
	$Q curl+ $(BUF-DOWN) > $@

$(BUF-COMP-BASH): $(BUF)
	$Q mkdir -p $(@D)
	$Q cp $(LOCAL-PREFIX)/etc/bash_completion.d/buf $@

$(BUF-COMP-ZSH) $(BUF-COMP-FISH) $(BUF-MAN): $(BUF)
	$Q test -s $@

endif
