_makes-shell:
	@( \
	  cd $(MAKES) && \
	  bash --rcfile \
	  <(cat ~/.bashrc; echo 'PS1="(makes) \w > "') \
	)

_makes-edit:
	vim $(MAKES)/$(file)

_makes-git:
	git -C $(MAKES) $A

_makes-gll:
	git -C $(MAKES) log --graph --decorate --pretty=oneline --abbrev-commit $A

_makes-head:
	git -C $(MAKES) rev-parse HEAD

_makes-status:
	git -C $(MAKES) status --ignored $A

_makes-branch _makes-diff _makes-fetch _makes-pull:
	git -C $(MAKES) $(@:_makes-%=%) $A

_makes-add:
	git -C $(MAKES) add -A .

_makes-commit:
	git -C $(MAKES) commit -av $A

_makes-push:
	git -C $(MAKES) push git@github.com:makeplus/makes $A && \
	  git -C $(MAKES) fetch

_makes-env:
	@echo export PATH=$$PATH

