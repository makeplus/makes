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

_makes-status:
	git -C $(MAKES) status --ignored $(args)

_makes-fetch _makes-pull:
	git -C $(MAKES) $(@:_makes-%=%) $(args)

_makes-push:
	git -C $(MAKES) push git@github.com:makeplus/makes $(args) && \
	  git -C $(MAKES) fetch

_makes-env:
	@echo export PATH=$$PATH

