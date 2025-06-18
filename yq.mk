$(if $(MAKES),,$(error Please 'include .makes/init.mk'))
$(eval $(call include-local))

YQ-VERSION ?= 4.45.4
YQ-NAME := yq_linux_amd64
YQ-TARBALL := $(YQ-NAME).tar.gz
YQ-REPO-URL := https://github.com/mikefarah/yq
YQ-DOWNLOAD := $(YQ-REPO-URL)/releases/download/v$(YQ-VERSION)/$(YQ-TARBALL)

YQ := $(LOCAL-PREFIX)/bin/yq


$(YQ): $(LOCAL-CACHE)/$(YQ-TARBALL)
	tar -C $(LOCAL-CACHE) -xf $< -- ./$(YQ-NAME)
	[[ -e $(LOCAL-CACHE)/$(YQ-NAME) ]]
	mv $(LOCAL-CACHE)/$(YQ-NAME) $@
	touch $@
	@echo

$(LOCAL-CACHE)/$(YQ-TARBALL):
	@echo "Installing 'go' locally"
	curl -Ls $(YQ-DOWNLOAD) > $@
