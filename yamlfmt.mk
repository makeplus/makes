YAMLFMT-VERSION ?= 0.21.0
# https://github.com/google/yamlfmt

ifndef YAMLFMT-LOADED
YAMLFMT-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
$(eval $(call include-local))

OA-linux-arm64 := Linux_arm64
OA-linux-int64 := Linux_x86_64
OA-macos-arm64 := Darwin_arm64
OA-macos-int64 := Darwin_x86_64
OA-windows-arm64 := Windows_arm64
OA-windows-int64 := Windows_x86_64

ifeq (,$(OA-$(OS-ARCH)))
$(error 'yamlfmt' has no prebuilt binary for $(OS-ARCH); \
  see https://github.com/google/yamlfmt)
endif

ifeq (windows,$(OS-NAME))
YAMLFMT-EXE := yamlfmt.exe
else
YAMLFMT-EXE := yamlfmt
endif

YAMLFMT-ARC := yamlfmt_$(YAMLFMT-VERSION)_$(OA-$(OS-ARCH)).tar.gz
YAMLFMT-DOWN := https://github.com/google/yamlfmt
YAMLFMT-DOWN := $(YAMLFMT-DOWN)/releases/download
YAMLFMT-DOWN := $(YAMLFMT-DOWN)/v$(YAMLFMT-VERSION)/$(YAMLFMT-ARC)

YAMLFMT-LOCAL := $(LOCAL-ROOT)/yamlfmt-$(YAMLFMT-VERSION)
YAMLFMT := $(YAMLFMT-LOCAL)/bin/$(YAMLFMT-EXE)

SHELL-DEPS += $(YAMLFMT)

override PATH := $(YAMLFMT-LOCAL)/bin:$(PATH)
export PATH


$(YAMLFMT): $(LOCAL-CACHE)/$(YAMLFMT-ARC)
	$Q mkdir -p $(YAMLFMT-LOCAL)/bin
	$Q tar -C $(YAMLFMT-LOCAL)/bin -xzf $< $(YAMLFMT-EXE)
	$Q [[ -e $@ ]]
	$Q chmod +x $@
	$Q touch $@
	@$(ECHO)

$(LOCAL-CACHE)/$(YAMLFMT-ARC):
	@$(ECHO) "* Installing 'yamlfmt' locally"
	$Q curl+ $(YAMLFMT-DOWN) > $@

endif
