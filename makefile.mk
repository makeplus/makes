M := $(or $(MAKES_REPO_DIR),$(HOME)/.makes/makes)
ifeq (,$(wildcard $M))
_ := $(shell git clone -q https://github.com/makeplus/makes $M)
else
_ := $(shell git -C $M pull -q)
endif

MAKES-LOCAL-DIR := $M/local

ifdef WITH
SHELL-NAME := makes w/ $(WITH)
MAKES-INCLUDE := $(WITH:%=%.mk)
endif

include $M/init.mk
include $M/shell.mk
