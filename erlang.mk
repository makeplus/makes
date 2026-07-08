ERLANG-VERSION ?= 28.1
# https://www.github.com/erlang/otp/releases

ifndef ERLANG-LOADED
ERLANG-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
$(eval $(call include-local))

ERLANG-DIR := otp_src_$(ERLANG-VERSION)
ifeq ($(OS-NAME),windows)
ERLANG-ARC := otp_win64_$(ERLANG-VERSION).zip
else
ERLANG-ARC := $(ERLANG-DIR).tar.gz
endif
ERLANG-DOWN := https://github.com/erlang/otp/releases/download
ERLANG-DOWN := $(ERLANG-DOWN)/OTP-$(ERLANG-VERSION)/$(ERLANG-ARC)

ERLANG-LOCAL := $(LOCAL-ROOT)/erlang-$(ERLANG-VERSION)
ERLANG-BIN := $(ERLANG-LOCAL)/bin
override PATH := $(ERLANG-BIN):$(PATH)
export PATH

ifeq ($(OS-NAME),windows)
ERL := $(ERLANG-BIN)/erl.exe
ERLC := $(ERLANG-BIN)/erlc.exe
ESCRIPT := $(ERLANG-BIN)/escript.exe
else
ERL := $(ERLANG-BIN)/erl
ERLC := $(ERLANG-BIN)/erlc
ESCRIPT := $(ERLANG-BIN)/escript
endif

SHELL-DEPS += $(ERL)


ifeq ($(OS-NAME),windows)
$(ERL): $(LOCAL-CACHE)/$(ERLANG-ARC)
	rm -rf $(ERLANG-LOCAL) $(LOCAL-TMP)/erlang-$(ERLANG-VERSION)
	mkdir -p $(ERLANG-LOCAL) $(LOCAL-TMP)/erlang-$(ERLANG-VERSION)
	unzip -q $< -d $(LOCAL-TMP)/erlang-$(ERLANG-VERSION)
	erl=$$(find $(LOCAL-TMP)/erlang-$(ERLANG-VERSION) \
	  -path '*/bin/erl.exe' -type f | head -1); \
	  test -n "$$erl"; \
	  root=$$(dirname "$$(dirname "$$erl")"); \
	  cp -R "$$root"/* $(ERLANG-LOCAL)/
	touch $@
	@echo
else
$(ERL): $(LOCAL-CACHE)/$(ERLANG-ARC)
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
endif

$(LOCAL-CACHE)/$(ERLANG-ARC):
	@echo "* Installing 'erlang' locally"
	curl+ $(ERLANG-DOWN) > $@

endif
