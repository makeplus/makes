$(if $(MAKES),,$(error Please 'include .makes/init.mk'))
$(eval $(call include-local))

JAVA-VERSION ?= 24
JAVA-TARBALL := jdk-$(JAVA-VERSION)_linux-x64_bin.tar.gz
JAVA-DOWNLOAD := \
  https://download.oracle.com/java/$(JAVA-VERSION)/latest/$(JAVA-TARBALL)

JAVA-LOCAL := $(LOCAL-ROOT)/jdk-$(JAVA-VERSION)
JAVA-BIN := $(JAVA-LOCAL)/bin
JAVA := $(JAVA-BIN)/java

export JAVA_HOME := $(JAVA-LOCAL)
override PATH := $(JAVA-BIN):$(PATH)
export PATH


$(JAVA): $(LOCAL-CACHE)/$(JAVA-TARBALL)
	tar -C $(LOCAL-ROOT) -xzf $<
	mv $(LOCAL-ROOT)/jdk-$(JAVA-VERSION).* $(JAVA-LOCAL)
	touch $@
	@echo

$(LOCAL-CACHE)/$(JAVA-TARBALL):
	@echo "Installing 'java' locally"
	curl -Ls $(JAVA-DOWNLOAD) > $@
