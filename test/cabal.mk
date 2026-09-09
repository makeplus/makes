M := .
include $(M)/init.mk

ifdef TEST-CARP
include $(M)/carp.mk
else
include $(M)/ghc.mk
GHC-TAR-BEFORE := $(GHC-TAR)
GHC-DOWN-BEFORE := $(GHC-DOWN)
include $(M)/cabal.mk
endif

# Simulate another module defining its own generic platform mappings.
OA-linux-int64 := unrelated-platform

inspect:
	@printf '%s\n' \
	  'archive=$(CABAL-TAR)' \
	  'download=$(CABAL-DOWN)' \
	  'ghc-before=$(GHC-TAR-BEFORE)' \
	  'ghc-after=$(GHC-TAR)' \
	  'ghc-url-before=$(GHC-DOWN-BEFORE)' \
	  'ghc-url-after=$(GHC-DOWN)'

install-cabal: $(CABAL)
	@$(CABAL) --version
