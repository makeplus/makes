LEIN-VERSION ?= 2.11.2

ifndef LEIN-LOADED
LEIN-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
$(eval $(call include-local))
include $(MAKES)/clojure.mk
include $(MAKES)/maven.mk

LEIN-CMDS := \
  help \
  classpath \
  repl \
  version \

export LEIN_HOME := $(LOCAL-HOME)
export LEIN_JVM_OPTS := \
  -XX:+TieredCompilation \
  -XX:TieredStopAtLevel=1 \
  $(MAVEN-OPTS)

LEIN-DOWN := https://codeberg.org/leiningen/leiningen/raw/tag
LEIN-DOWN := $(LEIN-DOWN)/$(LEIN-VERSION)/bin/lein

LEIN := $(LOCAL-BIN)/lein

SHELL-DEPS += $(LEIN)


$(LEIN):: $(CLOJURE) $(MAVEN)
	@echo "Installing 'lein' locally"
	curl+ $(LEIN-DOWN) > $@
	chmod +x $@

endif
