# Using the "Makes" Makefile setup - https://github.com/makeplus/makes
M := $(or $(MAKES_REPO_DIR),.cache/makes)
$(shell [ -d $M ] || git clone -q https://github.com/makeplus/makes $M)
include $M/init.mk
# include $M/makes.mk           # Add '_makes-*' rules

### Helpers
# include $M/clean.mk           # Add '*clean' rules
# include $M/help.mk            # Add 'help' rule
# include $M/git.mk             # Set 'GIT-*' vars
# include $M/local.mk           # Support for local installs
# include $M/docker.mk          # Docker support

### Languages and Tools
# include $M/clojure.mk
# include $M/crystal.mk
# include $M/go.mk
# include $M/java.mk
# include $M/just.mk
# include $M/lein.mk
# include $M/maven.mk
# include $M/pulumi.mk
# include $M/python.mk
# include $M/rust.mk
# include $M/yq.mk
# include $M/ys.mk

### This goes after any language files
# include $M/shell.mk           # Add 'shell' rule
