R-VERSION ?= 4.5.2
# https://www.r-project.org
# https://github.com/r-hub/R

ifndef R-LOADED
R-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
$(eval $(call include-local))

OA-linux-arm64 := glibc-aarch64
OA-linux-int64 := glibc-x86_64
OA-macos-arm64 := arm64
OA-macos-int64 := x86_64

R-DIR := r-$(R-VERSION)
R-LOCAL := $(LOCAL-ROOT)/$(R-DIR)

ifdef IS-LINUX
R-ARCHIVE := r-$(R-VERSION)-$(OA-$(OS-ARCH)).tar.gz
else
R-ARCHIVE := R-$(R-VERSION)-$(OA-$(OS-ARCH)).pkg
endif

R-DOWN := https://github.com/r-hub/R/releases/download
R-DOWN := $(R-DOWN)/v$(R-VERSION)/$(R-ARCHIVE)

ifdef IS-LINUX
R-BIN := $(R-LOCAL)/bin
override PATH := $(R-BIN):$(PATH)
else
R-FRAMEWORK := $(R-LOCAL)/Library/Frameworks/R.framework
R-BIN := $(LOCAL-BIN)
endif

R := $(R-BIN)/R

SHELL-DEPS += $(R)


R-ORIG-PREFIX := /opt/R/$(R-VERSION)-glibc

$(R): $(LOCAL-CACHE)/$(R-ARCHIVE)
ifdef IS-LINUX
	mkdir -p $(R-LOCAL)
	tar -C $(R-LOCAL) --strip-components=3 -xzf $<
	sed -i 's|$(R-ORIG-PREFIX)|$(R-LOCAL)|g' \
	  $(R-LOCAL)/bin/R \
	  $(R-LOCAL)/bin/Rscript \
	  $(R-LOCAL)/lib/R/bin/R \
	  $(R-LOCAL)/lib/R/bin/Rscript \
	  $(R-LOCAL)/lib/R/etc/ldpaths \
	  $(R-LOCAL)/lib/R/etc/Makeconf \
	  $(R-LOCAL)/lib/R/etc/Renviron
	[[ -e $@ ]]
else
	rm -rf $(LOCAL-CACHE)/R-pkg-tmp
	pkgutil --expand $< $(LOCAL-CACHE)/R-pkg-tmp
	mkdir -p $(R-LOCAL)
	@for pkg in $(LOCAL-CACHE)/R-pkg-tmp/*.pkg; do \
	  [ -f "$$pkg/Payload" ] || continue; \
	  gunzip -c "$$pkg/Payload" | (cd $(R-LOCAL) && cpio -id 2>/dev/null); \
	done
	rm -rf $(LOCAL-CACHE)/R-pkg-tmp
	ln -sf $(R-FRAMEWORK)/Versions/Current/Resources/bin/R $@
	ln -sf $(R-FRAMEWORK)/Versions/Current/Resources/bin/Rscript \
	  $(LOCAL-BIN)/Rscript
	[[ -e $@ ]]
endif
	touch $@
	@echo

$(LOCAL-CACHE)/$(R-ARCHIVE):
	@echo "* Installing 'R' locally"
	curl+ $(R-DOWN) > $@

endif
