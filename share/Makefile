# Using the "Makes" Makefile framework - https://github.com/makeplus/makes

M := $(or $(MAKES_REPO_DIR),.cache/makes)
$(shell [ -d $M ] || git clone -q https://github.com/makeplus/makes $M)

### Required
include $M/init.mk

### Languages and Tools
# include $M/crystal.mk
# include $M/go.mk
# include $M/just.mk
# include $M/pulumi.mk
# include $M/python.mk
# include $M/rust.mk
# include $M/yq.mk
# include $M/ys.mk

### JVM Languages and Tools
# include $M/java.mk
# include $M/graalvm.mk
# include $M/maven.mk
# include $M/clojure.mk
# include $M/lein.mk

### Helpers
# include $M/clean.mk
# include $M/help.mk
# include $M/docker.mk
# include $M/shell.mk
