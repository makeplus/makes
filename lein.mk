LEIN-CLOJURE-VERSION := 0.12.1

ifndef LEIN-LOADED
LEIN-LOADED := true

$(if $(CLOJURE-LOADED),,\
$(error lein.mk requires including clojure.mk first))

$(if $(MAKES),,$(error Please 'include .makes/init.mk'))
$(eval $(call include-local))

LEIN-URL := \
  https://codeberg.org/leiningen/leiningen/raw/tag/2.11.2/bin/lein

LEIN := $(LOCAL-BIN)/lein

SHELL-DEPS += $(LEIN)

export LEIN_HOME := $(LOCAL-HOME)
export LEIN_JVM_OPTS := \
  -XX:+TieredCompilation \
  -XX:TieredStopAtLevel=1 \
  $(MAVEN-OPTS)

LEIN-CMDS := \
  help \
  classpath \
  repl \
  version \



$(LEIN):: $(CLOJURE) $(MAVEN)
	@echo "Installing 'lein' locally"
	curl+ $(LEIN-URL) > $@
	chmod +x $@

endif
