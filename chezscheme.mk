CHEZSCHEME-VERSION ?= 10.4.1
# https://github.com/cisco/ChezScheme

ifndef CHEZSCHEME-LOADED
CHEZSCHEME-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))

CHEZSCHEME-USE-SYSTEM ?= 1

ifeq (windows,$(OS-NAME))
CHEZSCHEME-EXE := scheme.exe
PETITE-CHEZSCHEME-EXE := petite.exe
else
CHEZSCHEME-EXE := scheme
PETITE-CHEZSCHEME-EXE := petite
endif

ifeq (1,$(CHEZSCHEME-USE-SYSTEM))
CHEZSCHEME-SYSTEM-PAIR := $(shell \
  for name in chez chezscheme scheme; do \
    exe=$$(command -v $$name 2>/dev/null) || continue; \
    test -x "$$exe" || continue; \
    dir=$$(cd "$$(dirname "$$exe")" && pwd -P) || continue; \
    exe=$$dir/$$(basename "$$exe"); \
    version=$$("$$exe" --version 2>/dev/null | tr -d '\r'); \
    test "$$version" = "$(CHEZSCHEME-VERSION)" || continue; \
    identity=$$(printf '(display (scheme-version)) (newline)\n' | \
      "$$exe" -q 2>/dev/null | tr -d '\r'); \
    test "$$identity" = \
      "Chez Scheme Version $(CHEZSCHEME-VERSION)" || continue; \
    petite=$$dir/$(PETITE-CHEZSCHEME-EXE); \
    test -x "$$petite" || continue; \
    version=$$("$$petite" --version 2>/dev/null | tr -d '\r'); \
    test "$$version" = "$(CHEZSCHEME-VERSION)" || continue; \
    identity=$$(printf '(display (scheme-version)) (newline)\n' | \
      "$$petite" -q 2>/dev/null | tr -d '\r'); \
    test "$$identity" = \
      "Petite Chez Scheme Version $(CHEZSCHEME-VERSION)" || continue; \
    printf '%s %s\n' "$$exe" "$$petite"; \
    break; \
  done)
endif

ifneq (,$(CHEZSCHEME-SYSTEM-PAIR))
CHEZSCHEME := $(word 1,$(CHEZSCHEME-SYSTEM-PAIR))
PETITE-CHEZSCHEME := $(word 2,$(CHEZSCHEME-SYSTEM-PAIR))
else
$(eval $(call include-local))
include $(MAKES)/gcc.mk

CHEZSCHEME-DIR := csv$(CHEZSCHEME-VERSION)
CHEZSCHEME-TAR := $(CHEZSCHEME-DIR).tar.gz
CHEZSCHEME-DOWN := https://github.com/cisco/ChezScheme/releases/download
CHEZSCHEME-DOWN := $(CHEZSCHEME-DOWN)/v$(CHEZSCHEME-VERSION)/$(CHEZSCHEME-TAR)

CHEZSCHEME-LOCAL := $(LOCAL-ROOT)/chezscheme-$(CHEZSCHEME-VERSION)
CHEZSCHEME := $(CHEZSCHEME-LOCAL)/bin/$(CHEZSCHEME-EXE)
PETITE-CHEZSCHEME := $(CHEZSCHEME-LOCAL)/bin/$(PETITE-CHEZSCHEME-EXE)

override PATH := $(CHEZSCHEME-LOCAL)/bin:$(PATH)
export PATH


$(CHEZSCHEME): $(LOCAL-CACHE)/$(CHEZSCHEME-TAR) $(GCC)
	@$(ECHO) "* Building 'Chez Scheme $(CHEZSCHEME-VERSION)' locally"
	$Q rm -rf $(CHEZSCHEME-LOCAL) $(LOCAL-TMP)/$(CHEZSCHEME-DIR)
	$Q mkdir -p $(LOCAL-TMP)
	$Q tar -C $(LOCAL-TMP) -xzf $<
	$Q cd $(LOCAL-TMP)/$(CHEZSCHEME-DIR) && \
	  ./configure \
	    --installprefix=$(CHEZSCHEME-LOCAL) \
	    --disable-x11 \
	    --disable-curses \
	    CC=$(GCC) && \
	  $(MAKE) && \
	  $(MAKE) install
	$Q test -x $(CHEZSCHEME)
	$Q test -x $(PETITE-CHEZSCHEME)
	$Q touch $@
	@$(ECHO)

$(LOCAL-CACHE)/$(CHEZSCHEME-TAR):
	@$(ECHO) "* Downloading 'Chez Scheme $(CHEZSCHEME-VERSION)' source"
	$Q curl+ $(CHEZSCHEME-DOWN) > $@
endif

SHELL-DEPS += $(CHEZSCHEME)

endif
