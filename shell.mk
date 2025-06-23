ifdef SHELL-LOADED
$(error shell.mk already loaded)
endif
SHELL-LOADED := true

shell:
ifndef MAKES_SHELL
	@( \
	  export MAKES_SHELL=1; \
	  bash --rcfile \
	  <(cat ~/.bashrc; echo 'PS1="(makes) \w $$ "') \
	)
else
	@echo 'You are already in a Makes bash shell'
endif
