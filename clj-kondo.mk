CLJ-KONDO-VERSION ?= 2026.05.25
# https://github.com/clj-kondo/clj-kondo

ifndef CLJ-KONDO-LOADED
CLJ-KONDO-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
$(eval $(call include-local))

OA-linux-arm64 := linux-aarch64
OA-linux-int64 := linux-amd64
OA-macos-arm64 := macos-aarch64
OA-macos-int64 := macos-amd64
OA-windows-int64 := windows-amd64

CLJ-KONDO-ZIP := clj-kondo-$(CLJ-KONDO-VERSION)-$(OA-$(OS-ARCH)).zip
CLJ-KONDO-DOWN := https://github.com/clj-kondo/clj-kondo
CLJ-KONDO-DOWN := $(CLJ-KONDO-DOWN)/releases/download/v$(CLJ-KONDO-VERSION)/$(CLJ-KONDO-ZIP)

ifeq (windows,$(OS-NAME))
CLJ-KONDO-EXE := clj-kondo.exe
else
CLJ-KONDO-EXE := clj-kondo
endif

CLJ-KONDO := $(LOCAL-BIN)/$(CLJ-KONDO-EXE)

SHELL-DEPS += $(CLJ-KONDO)


$(CLJ-KONDO): $(LOCAL-CACHE)/$(CLJ-KONDO-ZIP)
	$Q unzip -q -d $(LOCAL-CACHE) $<
	$Q [[ -e $(LOCAL-CACHE)/$(CLJ-KONDO-EXE) ]]
	$Q mv $(LOCAL-CACHE)/$(CLJ-KONDO-EXE) $(LOCAL-BIN)/
	$Q touch $@
	@$(ECHO)

$(LOCAL-CACHE)/$(CLJ-KONDO-ZIP):
	@$(ECHO) "* Installing 'clj-kondo' locally"
	$Q curl+ $(CLJ-KONDO-DOWN) > $@

endif
