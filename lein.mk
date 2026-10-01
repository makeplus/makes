LEIN-VERSION ?= 2.13.0
# https://codeberg.org/leiningen/leiningen/tags

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

LEIN-LOCAL := $(LOCAL-ROOT)/lein-$(LEIN-VERSION)
LEIN := $(LEIN-LOCAL)/bin/lein
LEIN-COMP-BASH := $(LOCAL-SHARE)/bash-completion/completions/lein
LEIN-COMP-ZSH := $(LOCAL-SHARE)/zsh/site-functions/_lein
LEIN-COMP := $(LEIN-COMP-BASH) $(LEIN-COMP-ZSH)
LEIN-COMP-DOWN := https://codeberg.org/leiningen/leiningen/raw/tag
LEIN-COMP-DOWN := $(LEIN-COMP-DOWN)/$(LEIN-VERSION)

SHELL-DEPS += $(LEIN) $(LEIN-COMP)

override PATH := $(LEIN-LOCAL)/bin:$(PATH)
export PATH


$(LEIN):: $(CLOJURE) $(MAVEN)
	@$(ECHO) "* Installing 'lein' locally"
	$Q mkdir -p $(LEIN-LOCAL)/bin
	$Q curl+ $(LEIN-DOWN) > $@
	$Q chmod +x $@
	@$(ECHO)

$(LEIN-COMP-BASH):
	$Q mkdir -p $(@D)
	$Q curl+ $(LEIN-COMP-DOWN)/bash_completion.bash > $@

$(LEIN-COMP-ZSH):
	$Q mkdir -p $(@D)
	$Q curl+ $(LEIN-COMP-DOWN)/zsh_completion.zsh > $@

endif
