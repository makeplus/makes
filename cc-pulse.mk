CC-PULSE-COMMIT ?= ea22447
# https://github.com/NoobyGains/claude-pulse

ifndef CC-PULSE-LOADED
CC-PULSE-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
$(eval $(call include-local))

CC-PULSE-NAME := claude-pulse-$(CC-PULSE-COMMIT).py
CC-PULSE-DOWN := https://raw.githubusercontent.com/NoobyGains/claude-pulse
CC-PULSE-DOWN := $(CC-PULSE-DOWN)/$(CC-PULSE-COMMIT)/claude_status.py

CC-PULSE := $(LOCAL-BIN)/cc-pulse

SHELL-DEPS += $(CC-PULSE)


$(CC-PULSE): $(LOCAL-CACHE)/$(CC-PULSE-NAME)
	printf '#!/bin/bash\nexec python3 %s "$$@"\n' \
	  "$(abspath $<)" > $@
	chmod +x $@
	touch $@
	@echo

$(LOCAL-CACHE)/$(CC-PULSE-NAME):
	@echo "* Installing 'cc-pulse' locally"
	curl+ $(CC-PULSE-DOWN) > $@

endif
