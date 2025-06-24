ifndef DOCKER-LOADED
DOCKER-LOADED := true

ifneq (,$(wildcard /.dockerenv))

MAKES-IN-DOCKER := true

else

$(if $(MAKES),,$(error Please 'include .makes/init.mk'))
$(eval $(call include-local))
include $(MAKES)/git.mk

DOCKER-NAME ?= makes-$(GIT-REPO-NAME)
DOCKER-BUILD-FILE := $(LOCAL-CACHE)/docker-build-$(DOCKER-NAME)
DOCKER-RUN-FILE := $(LOCAL-CACHE)/docker-run-$(DOCKER-NAME)
DOCKER-BASH-HISTORY := $(LOCAL-CACHE)/bash-history
DOCKER-EXEC := docker exec -it $(DOCKER-NAME)
DOCKER-FILE := $(LOCAL-TMP)/Dockerfile
DOCKER-CONTEXT := .

ifdef DOCKER-USER
ifdef DOCKER-VERSION
DOCKER-NAME := $(DOCKER-USER)/$(DOCKER-NAME):$(DOCKER-VERSION)
DOCKER-URL := docker.io/$(DOCKER-NAME)
endif
endif

$(shell $(RM) $(DOCKER-RUN-FILE))

ifneq (,$(shell docker ps | grep $(DOCKER-NAME)))
$(shell touch $(DOCKER-RUN-FILE))
endif

realclean:: docker-kill

docker-shell: $(DOCKER-RUN-FILE)
	docker exec -it $(DOCKER-NAME) bash

docker-ps:
	docker ps | grep $(DOCKER-NAME)

docker-kill:
	-docker kill $(DOCKER-NAME)
	$(RM) $(DOCKER-BUILD-FILE)

ifdef DOCKER-URL
docker-push: $(DOCKER-BUILD-FILE)
	docker push $(DOCKER-URL)
endif

$(DOCKER-RUN-FILE): $(DOCKER-BUILD-FILE)
	docker run -d --rm \
	  --name $(DOCKER-NAME) \
	  --workdir $(ROOT) \
	  --volume $(GIT-REPO-DIR):$(GIT-REPO-DIR) \
	  --volume $(DOCKER-BASH-HISTORY):/root/.bash-history \
	  $(DOCKER-RUN-OPTIONS) \
	  $(DOCKER-NAME) \
	  sleep infinity

$(DOCKER-BUILD-FILE): $(DOCKER-FILE)
	docker build \
	  -f $(DOCKER-FILE) \
	  -t $(DOCKER-NAME) \
	  $(DOCKER-BUILD-OPTIONS) \
	  $(DOCKER-CONTEXT)
	touch $@

ifdef DOCKER-FILES
$(DOCKER-FILE): $(DOCKER-FILES)
	cat $^ > $@
else
$(DOCKER-FILE):
	@echo 'DOCKER-FILES not defined'
	@exit 1
endif

endif

endif
