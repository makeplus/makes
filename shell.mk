ifndef SHELL-LOADED
SHELL-LOADED := true

SHELL-NAME ?= makes
MAKES-SHELL ?= bash


ifdef CMD
shell: $(SHELL-DEPS)
	@sh -c '$(CMD)'
else
shell: $(MAKES-SHELL)
endif

bash: $(SHELL-DEPS)
ifdef MAKES_SHELL
	@$(error You are already in a Makes shell)
endif
	@( \
	  export MAKES_SHELL=1; \
	  bash --rcfile \
	  <(cat ~/.bashrc; \
	    echo 'PS1="($(SHELL-NAME)) \w $$ "'; \
	    echo 'export PATH=$(PATH)'; \
	   ) \
	)

zsh: $(SHELL-DEPS)
ifdef MAKES_SHELL
	@$(error You are already in a Makes shell)
endif
	@( \
	  export MAKES_SHELL=1; \
	  export PATH='$(PATH)'; \
	  zsh; \
	)

endif

shell-env: $(SHELL-DEPS)
	@echo export PATH='$(PATH)'
