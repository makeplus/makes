ifndef MAKES-LOADED
MAKES-LOADED := true


makes-default:

makes-shell:
	@( \
	  cd $(MAKES) && \
	  bash --rcfile \
	  <(cat ~/.bashrc; echo 'PS1="(makes) \w $$ "') \
	)

makes-bash:
	@( \
	  bash --rcfile \
	  <(cat ~/.bashrc; echo 'PS1="(makes) \w $$ "') \
	)

makes-edit:
	$${EDITOR:-vim} $(MAKES)/$(file)

makes-git:
	git -C $(MAKES) $A

makes-gll:
	git -C $(MAKES) log --graph --decorate --pretty=oneline --abbrev-commit $A

makes-head:
	git -C $(MAKES) rev-parse HEAD

makes-status:
	git -C $(MAKES) status --ignored $A

makes-branch _makes-diff _makes-fetch _makes-pull:
	git -C $(MAKES) $(@:_makes-%=%) $A

makes-add:
	git -C $(MAKES) add -A .

makes-commit:
	git -C $(MAKES) commit -av $A

makes-push:
	git -C $(MAKES) push git@github.com:makeplus/makes $A && \
	  git -C $(MAKES) fetch

makes-env:
	@echo export PATH=$$PATH

endif
