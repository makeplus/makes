# Using the "Makes" Makefile setup - https://github.com/makeplus/makes
M := $(or $(MAKES_REPO_DIR),.cache/makes)
$(shell [ -d $M ] || git clone -q https://github.com/makeplus/makes $M)
include $M/init.mk
include $M/clean.mk
include $M/clojure.mk
include $M/docker.mk
include $M/git.mk
include $M/go.mk
include $M/help.mk
include $M/java.mk
include $M/just.mk
include $M/lein.mk
include $M/local.mk
include $M/maven.mk
include $M/makes.mk
include $M/pulumi.mk
include $M/python.mk
include $M/rust.mk
include $M/shell.mk
include $M/yq.mk
include $M/ys.mk
