ERLANG-VERSION ?= 28.0.2

ifndef ERLANG-LOADED
ERLANG-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
$(eval $(call include-local))

ERLANG-DIR := otp_src_$(ERLANG-VERSION)
ERLANG-TAR := $(ERLANG-DIR).tar.gz
ERLANG-DOWN := https://github.com/erlang/otp/releases/download
ERLANG-DOWN := $(ERLANG-DOWN)/OTP-$(ERLANG-VERSION)/$(ERLANG-TAR)

ERLANG-LOCAL := $(LOCAL-ROOT)/erlang-$(ERLANG-VERSION)
ERLANG-BIN := $(ERLANG-LOCAL)/bin
override PATH := $(ERLANG-BIN):$(PATH)

ERL := $(ERLANG-BIN)/erl
ERLC := $(ERLANG-BIN)/erlc
ESCRIPT := $(ERLANG-BIN)/escript

SHELL-DEPS += $(ERL)


$(ERL): $(LOCAL-CACHE)/$(ERLANG-TAR)
	cd $(LOCAL-CACHE) && tar -xzf $<
	cd $(LOCAL-CACHE)/$(ERLANG-DIR) && \
		./configure --prefix=$(ERLANG-LOCAL) \
			--enable-dirty-schedulers \
			--enable-smp-support \
			--without-javac \
			--without-wx \
			--without-debugger \
			--without-observer \
			--without-et \
			--disable-hipe
	cd $(LOCAL-CACHE)/$(ERLANG-DIR) && make -j$(shell nproc 2>/dev/null || echo 4)
	cd $(LOCAL-CACHE)/$(ERLANG-DIR) && make install
	rm -rf $(LOCAL-CACHE)/$(ERLANG-DIR)
	touch $@
	@echo

$(LOCAL-CACHE)/$(ERLANG-TAR):
	@echo "Installing 'erlang' locally"
	curl+ $(ERLANG-DOWN) > $@

endif
