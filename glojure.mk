GLOJURE-VERSION ?= 0.6.8

ifndef GLOJURE-LOADED
GLOJURE-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
$(eval $(call include-local))

OA-linux-arm64 := linux_arm64
OA-linux-int64 := linux_amd64
OA-macos-arm64 := darwin_arm64

ifeq (,$(OA-$(OS-ARCH)))
$(error 'glojure' has no prebuilt binary for $(OS-ARCH); see https://github.com/glojurelang/glojure)
endif

GLOJURE-TAR := glj-$(GLOJURE-VERSION)-$(OA-$(OS-ARCH)).tar.gz
GLOJURE-DOWN := https://github.com/glojurelang/glojure
GLOJURE-DOWN := $(GLOJURE-DOWN)/releases/download/v$(GLOJURE-VERSION)/$(GLOJURE-TAR)

GLOJURE-LOCAL := $(LOCAL-ROOT)/glojure-$(GLOJURE-VERSION)
GLJ := $(GLOJURE-LOCAL)/bin/glj

SHELL-DEPS += $(GLJ)

override PATH := $(GLOJURE-LOCAL)/bin:$(PATH)
export PATH


$(GLJ): $(LOCAL-CACHE)/$(GLOJURE-TAR)
	$Q mkdir -p $(GLOJURE-LOCAL)/bin
	$Q tar -C $(LOCAL-CACHE) -xzf $<
	$Q [[ -e $(LOCAL-CACHE)/glj ]]
	$Q mv $(LOCAL-CACHE)/glj $(GLOJURE-LOCAL)/bin/
	$Q touch $@
	@$(ECHO)

$(LOCAL-CACHE)/$(GLOJURE-TAR):
	@$(ECHO) "* Installing 'glj' locally"
	$Q curl+ $(GLOJURE-DOWN) > $@

endif
