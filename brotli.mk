BROTLI-VERSION ?= 1.2.0
# https://github.com/google/brotli

ifndef BROTLI-LOADED
BROTLI-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
$(eval $(call include-local))

BROTLI-DIR := brotli-$(BROTLI-VERSION)
BROTLI-TAR := v$(BROTLI-VERSION).tar.gz
BROTLI-DOWN := https://github.com/google/brotli/archive/refs/tags/$(BROTLI-TAR)

BROTLI := $(LOCAL-BIN)/brotli

SHELL-DEPS += $(BROTLI)


$(BROTLI): $(LOCAL-CACHE)/$(BROTLI-TAR)
	@echo "* Building 'brotli' from source"
	cd $(LOCAL-CACHE) && tar -xzf $<
	cd $(LOCAL-CACHE)/$(BROTLI-DIR) && \
		cc -O2 -Ic/include \
			c/common/*.c c/dec/*.c c/enc/*.c c/tools/brotli.c \
			-o brotli -lm
	mv $(LOCAL-CACHE)/$(BROTLI-DIR)/brotli $@
	rm -rf $(LOCAL-CACHE)/$(BROTLI-DIR)
	touch $@
	@echo

$(LOCAL-CACHE)/$(BROTLI-TAR):
	@echo "* Installing 'brotli' locally"
	curl+ $(BROTLI-DOWN) > $@

endif
