SMLNJ-VERSION ?= 110.99.9
# https://smlnj.org/

ifndef SML-LOADED
SML-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
$(eval $(call include-local))

SMLNJ-BASE := https://smlnj.cs.uchicago.edu/dist/working/$(SMLNJ-VERSION)
SMLNJ-LOCAL := $(LOCAL-ROOT)/smlnj-$(SMLNJ-VERSION)
SML := $(SMLNJ-LOCAL)/bin/sml

SHELL-DEPS += $(SML)

override PATH := $(SMLNJ-LOCAL)/bin:$(PATH)
export PATH

ifeq ($(OS-NAME),macos)
SMLNJ-PKG := smlnj-amd64-$(SMLNJ-VERSION).pkg
SMLNJ-DOWN := $(SMLNJ-BASE)/$(SMLNJ-PKG)

$(SML): $(LOCAL-CACHE)/$(SMLNJ-PKG)
	$Q rm -rf $(SMLNJ-LOCAL) $(LOCAL-TMP)/smlnj-$(SMLNJ-VERSION)
	$Q mkdir -p $(SMLNJ-LOCAL) $(LOCAL-TMP)/smlnj-$(SMLNJ-VERSION)
	$Q pkgutil --expand $< $(LOCAL-TMP)/smlnj-$(SMLNJ-VERSION)/pkg
	$Q find $(LOCAL-TMP)/smlnj-$(SMLNJ-VERSION)/pkg -name Payload -type f -exec sh -c 'gunzip -c "$$1" | (cd "$(SMLNJ-LOCAL)" && cpio -id 2>/dev/null)' sh {} \;
	$Q touch $@
	@$(ECHO)

$(LOCAL-CACHE)/$(SMLNJ-PKG):
	@$(ECHO) "* Installing 'smlnj' locally"
	$Q curl+ $(SMLNJ-DOWN) > $@
else
SMLNJ-FILES := config.tgz boot.amd64-unix.tgz cm.tgz compiler.tgz runtime.tgz system.tgz MLRISC.tgz smlnj-lib.tgz
SMLNJ-CACHE-FILES := $(SMLNJ-FILES:%=$(LOCAL-CACHE)/smlnj-$(SMLNJ-VERSION)-%)

$(SML): $(SMLNJ-CACHE-FILES)
	$Q rm -rf $(SMLNJ-LOCAL)
	$Q mkdir -p $(SMLNJ-LOCAL)
	$Q for f in $^; do tar -C $(SMLNJ-LOCAL) -xzf $$f; done
	$Q cd $(SMLNJ-LOCAL) && config/install.sh -default $(SMLNJ-LOCAL)
	$Q touch $@
	@$(ECHO)

$(LOCAL-CACHE)/smlnj-$(SMLNJ-VERSION)-%:
	@$(ECHO) "* Installing 'smlnj' component '$*' locally"
	$Q curl+ $(SMLNJ-BASE)/$* > $@
endif

endif
