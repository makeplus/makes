KSON-VERSION ?= 0.3.0.2
# https://github.com/kson-org/kson

ifndef KSON-LOADED
KSON-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
$(eval $(call include-local))

KSON-LOCAL := $(LOCAL-ROOT)/kson-$(KSON-VERSION)
KSON-TMP := $(LOCAL-TMP)/kson-$(KSON-VERSION)
KSON-DIST := $(KSON-TMP)/tooling/cli/build/install/cli
KSON-ARC := kson-$(KSON-VERSION).tar.gz
KSON-DOWN := https://github.com/kson-org/kson/archive
KSON-DOWN := $(KSON-DOWN)/refs/tags/v$(KSON-VERSION).tar.gz
KSON := $(KSON-LOCAL)/bin/kson

KSON-SUPPORTED := $(filter $(OS-ARCH),linux-int64 linux-arm64 macos-arm64)

ifneq (,$(KSON-SUPPORTED))
include $(MAKES)/graalvm.mk
# Match KSON's wrapper unless the caller already selected Gradle.
GRADLE-VERSION ?= 9.4.1
include $(MAKES)/gradle.mk
include $(MAKES)/perl.mk
endif

SHELL-DEPS += $(KSON)

override PATH := $(KSON-LOCAL)/bin:$(PATH)
export PATH


ifeq (,$(KSON-SUPPORTED))
$(KSON):
	@$(error KSON source builds are unsupported on $(OS-ARCH); \
	  supported platforms: linux-int64 linux-arm64 macos-arm64)
else
$(KSON): $(LOCAL-CACHE)/$(KSON-ARC) $(GRADLE) $(GRAALVM) $(PERL)
	$Q command -v cc >/dev/null || \
	  { echo 'KSON needs a native C compiler and SDK' >&2; exit 1; }
	$Q printf '#include <zlib.h>\nint main(void) { return 0; }\n' | \
	  cc -x c - -lz -o $(KSON-TMP).check || \
	  { echo 'KSON needs C and zlib development libraries' >&2; exit 1; }
	$Q rm -f $(KSON-TMP).check
	$Q rm -rf $(KSON-TMP)
	$Q mkdir -p $(KSON-TMP) $(KSON-LOCAL)/bin
	$Q tar -C $(KSON-TMP) --strip-components=1 -xzf $<
	# Adapt only the downloaded sources to the Makes-managed JVM.
	$Q java_version=$$($(JAVA) -XshowSettings:properties -version 2>&1 | \
	  $(PERL) -ne 'print $$1 if /^\s*java\.version = (.*)/'); \
	  test -n "$$java_version"; \
	  KSON_JAVA_VERSION=$$java_version $(PERL) -i -pe \
	    's/^JDK_VERSION=.*/JDK_VERSION=$$ENV{KSON_JAVA_VERSION}/' \
	    $(KSON-TMP)/jdk.properties
	$Q $(GRADLE) -p $(KSON-TMP) --no-daemon --console=plain \
	  -Duser.home=$(LOCAL-HOME) \
	  -Dmaven.repo.local=$(LOCAL-CACHE)/maven -Prelease=true \
	  :tooling:cli:installDist
	$Q $(GRAALVM) -cp '$(KSON-DIST)/lib/*' \
	  --no-fallback -H:+ReportExceptionStackTraces \
	  -o $(KSON-TMP)/kson \
	  org.kson.tooling.cli.CommandLineInterfaceKt
	$Q cp $(KSON-TMP)/kson $@.tmp
	$Q chmod +x $@.tmp
	$Q mv $@.tmp $@
	$Q touch $@
	@$(ECHO)

$(LOCAL-CACHE)/$(KSON-ARC):
	@$(ECHO) "* Building 'kson' locally"
	$Q curl+ $(KSON-DOWN) > $@.tmp
	$Q mv $@.tmp $@
endif

endif
