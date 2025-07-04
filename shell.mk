$(if $(SHELL-LOADED),$(error shell.mk already loaded))
SHELL-LOADED := true

SHELL-NAME ?= makes
MAKES-SHELL ?= bash


shell: $(MAKES-SHELL)

bash: $(SHELL-DEPS)
ifndef MAKES_SHELL
	@( \
	  export MAKES_SHELL=1; \
	  bash --rcfile \
	  <(cat ~/.bashrc; \
	    echo 'PS1="($(SHELL-NAME)) \w $$ "'; \
	    echo 'export PATH=$(PATH)'; \
	   ) \
	)
else
	@echo 'You are already in a Makes bash shell'
endif

zsh: $(SHELL-DEPS)
ifndef MAKES_SHELL
	( \
	  export MAKES_SHELL=1; \
	  export PATH='$(PATH)'; \
	  zsh; \
	)
else
	@echo 'You are already in a Makes bash shell'
endif
