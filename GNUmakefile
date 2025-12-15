MAKES := .
include $(MAKES)/init.mk

export MAKES_LOCAL_DIR := $(ROOT)/local

include $(MAKES)/bpan.mk
include $(MAKES)/clean.mk
AGENTS-NAMES := claude
include $(MAKES)/agents.mk

TARGETS := $(wildcard *.mk)
TARGETS := $(TARGETS:%.mk=%)
TARGETS := \
  $(filter-out \
    agents \
    clean \
    docker \
    git \
    help \
    init \
    local \
    shell \
   ,$(TARGETS))
TARGETS := $(TARGETS:%=%-shell)

TEST-MAKEFILES := $(wildcard test/*/Makefile)
TEST-DIRS := $(TEST-MAKEFILES:%/Makefile=%)
TEST-NAMES := $(TEST-DIRS:test/%=%)
CLEAN-TARGETS := $(TEST-NAMES:%=clean-%)

MAKES-CLEAN += $(CLEAN-TARGETS)
MAKES-REALCLEAN += ./local/

v ?=


test: $(BPAN)
	prove$(if $(v), -v,) test/*.t

clean:: $(CLEAN-TARGETS)

$(CLEAN-TARGETS):
	@$(MAKE) -s -C test/$(@:clean-%=%) clean

version-check:
	util/check-versions

shell:
ifndef WITH
	@echo "WITH=... not specified for 'make shell'"
	@exit 1
endif
	$(MAKE) -f makefile.mk shell

$(TARGETS):
	$(MAKE) -f makefile.mk shell WITH=$(@:%-shell=%)
