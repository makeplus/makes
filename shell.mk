ifdef SHELL-LOADED
$(error shell.mk already loaded)
endif
SHELL-LOADED := true

MAKES-SHELL-NAME ?= makes


shell: $(MAKES-SHELL-DEPS)
ifndef MAKES_SHELL
	@( \
	  export MAKES_SHELL=1; \
	  bash --rcfile \
	  <(cat ~/.bashrc; \
	    echo 'PS1="($(MAKES-SHELL-NAME)) \w $$ "'; \
	    echo 'export PATH="$(PATH)"'; \
	   ) \
	)
else
	@echo 'You are already in a Makes bash shell'
endif
