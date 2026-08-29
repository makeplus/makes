TASK-VERSION ?= 3.53.1
# https://github.com/go-task/task

ifndef TASK-LOADED
TASK-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
$(eval $(call include-local))

OA-linux-arm64 := linux_arm64
OA-linux-int64 := linux_amd64
OA-macos-arm64 := darwin_arm64
OA-macos-int64 := darwin_amd64
OA-windows-arm64 := windows_arm64
OA-windows-int64 := windows_amd64

ifeq (,$(OA-$(OS-ARCH)))
$(error 'task' has no prebuilt binary for $(OS-ARCH); \
  see https://github.com/go-task/task)
endif

ifeq (windows,$(OS-NAME))
TASK-ARC-EXT := zip
TASK-EXE := task.exe
else
TASK-ARC-EXT := tar.gz
TASK-EXE := task
endif

TASK-ARC := task_$(OA-$(OS-ARCH)).$(TASK-ARC-EXT)
TASK-CACHE := task-$(TASK-VERSION)-$(TASK-ARC)
TASK-DOWN := https://github.com/go-task/task/releases/download
TASK-DOWN := $(TASK-DOWN)/v$(TASK-VERSION)/$(TASK-ARC)

TASK-LOCAL := $(LOCAL-ROOT)/task-$(TASK-VERSION)
TASK-TMP := $(LOCAL-TMP)/task-$(TASK-VERSION)
TASK := $(TASK-LOCAL)/bin/$(TASK-EXE)

SHELL-DEPS += $(TASK)

override PATH := $(TASK-LOCAL)/bin:$(PATH)
export PATH


$(TASK): $(LOCAL-CACHE)/$(TASK-CACHE)
	$Q rm -rf $(TASK-TMP)
	$Q mkdir -p $(TASK-LOCAL)/bin $(TASK-TMP)
	$Q case '$(TASK-ARC)' in \
	  *.zip) unzip -q $< -d $(TASK-TMP) ;; \
	  *) tar -C $(TASK-TMP) -xzf $< ;; \
	esac
	$Q cp $(TASK-TMP)/$(TASK-EXE) $@
	$Q chmod +x $@
	$Q touch $@
	@$(ECHO)

$(LOCAL-CACHE)/$(TASK-CACHE):
	@$(ECHO) "* Installing 'task' locally"
	$Q curl+ $(TASK-DOWN) > $@

endif
