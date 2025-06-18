# Using the "Makes" Makefile setup - https://github.com/makeplus/makes
M := .git/.makes
$(shell [ -d $M ] || git clone -q https://github.com/makeplus/makes $M)
include $M/init.mk
include $M/clojure.mk
include $M/go.mk
include $M/java.mk
include $M/just.mk
include $M/python.mk
include $M/rust.mk
include $M/yq.mk
include $M/ys.mk
