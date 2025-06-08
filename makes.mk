_makes-shell:
	@( \
	  cd $(MAKES) && \
	  bash --rcfile \
	  <(cat ~/.bashrc; echo 'PS1="(makes) \w > "') \
	)

_makes-edit:
	vim $(MAKES)/$(file)

_makes-git:
	git -C $(MAKES) $(args)

_makes-gll:
	git log --graph --decorate --pretty=oneline --abbrev-commit $(args)

_makes-status:
	git -C $(MAKES) status --ignored $(args)

_makes-diff _makes-fetch _makes-pull:
	git -C $(MAKES) $(@:_makes-%=%) $(args)

_makes-add:
	git -C $(MAKES) add -A .

_makes-commit:
	git -C $(MAKES) commit -av $(args)

_makes-push:
	git -C $(MAKES) push git@github.com:makeplus/makes $(args) && \
	  git -C $(MAKES) fetch

_makes-env:
	@echo export PATH=$$PATH

