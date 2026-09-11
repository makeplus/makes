LGX-VERSION ?= 0.2.1
# https://github.com/abogoyavlensky/lgx

ifndef LGX-LOADED
LGX-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
$(eval $(call include-local))
include $(MAKES)/let-go.mk

OA-linux-arm64 := linux_arm64
OA-linux-int64 := linux_amd64
OA-macos-arm64 := darwin_arm64
OA-macos-int64 := darwin_amd64

ifeq (,$(OA-$(OS-ARCH)))
$(error 'lgx' has no prebuilt binary for $(OS-ARCH); \
  see https://github.com/abogoyavlensky/lgx)
endif

LGX-DIR := lgx_$(LGX-VERSION)_$(OA-$(OS-ARCH))
LGX-TAR := $(LGX-DIR).tar.gz
LGX-DOWN := https://github.com/abogoyavlensky/lgx
LGX-DOWN := $(LGX-DOWN)/releases/download/v$(LGX-VERSION)/$(LGX-TAR)

LGX-LOCAL := $(LOCAL-ROOT)/lgx-$(LGX-VERSION)
LGX := $(LGX-LOCAL)/bin/lgx

export LGX_HOME ?= $(LOCAL-ROOT)/lgx
export LGX_LG ?= $(LG)

SHELL-DEPS += $(LGX)

override PATH := $(LGX-LOCAL)/bin:$(PATH)
export PATH


$(LGX): $(LOCAL-CACHE)/$(LGX-TAR) $(LG)
	$Q mkdir -p $(LGX-LOCAL)/bin
	$Q tar -C $(LGX-LOCAL)/bin -xzf $<
	$Q [[ -e $@ ]]
	$Q chmod +x $@
	$Q touch $@
	@$(ECHO)

$(LOCAL-CACHE)/$(LGX-TAR):
	@$(ECHO) "* Installing 'lgx' locally"
	$Q curl+ $(LGX-DOWN) > $@

endif
