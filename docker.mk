ifeq (,$(wildcard /.dockerenv))
$(if $(MAKES),,$(error Please 'include .makes/init.mk'))
$(eval $(call include-local))
include $(MAKES)/git.mk

DOCKER-NAME := makes-$(GIT-REPO-NAME)
DOCKER-BUILD-FILE := $(LOCAL-CACHE)/docker-build-$(DOCKER-NAME)
DOCKER-RUN-FILE := $(LOCAL-CACHE)/docker-run-$(DOCKER-NAME)
DOCKER-BASH-HISTORY := $(LOCAL-CACHE)/bash-history
DOCKER-FILE := Dockerfile
DOCKER-CONTEXT := .

$(shell $(RM) $(DOCKER-RUN-FILE))

ifneq (,$(shell docker ps | grep $(DOCKER-NAME)))
$(shell touch $(DOCKER-RUN-FILE))
endif

docker-shell: $(DOCKER-RUN-FILE)
	docker exec -it $(DOCKER-NAME) bash

docker-kill:
	docker kill $(DOCKER-NAME)
	$(RM) $(DOCKER-BUILD-FILE)

$(DOCKER-RUN-FILE): $(DOCKER-BUILD-FILE)
	docker run -d --rm \
	  --name $(DOCKER-NAME) \
	  --workdir $(GIT-REPO-DIR) \
	  --volume $(GIT-REPO-DIR):$(GIT-REPO-DIR) \
	  --volume $(DOCKER-BASH-HISTORY):/root/.bash-history \
	  $(DOCKER-NAME) \
	  sleep infinity

$(DOCKER-BUILD-FILE):
	docker build \
	  -f $(DOCKER-FILE) \
	  -t $(DOCKER-NAME) \
	  $(DOCKER-CONTEXT)
	touch $@
endif
