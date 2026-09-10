M := .
include $(M)/init.mk
include $(M)/berkeleydb.mk

# Run with: make -f test/berkeleydb.mk check-link
check-link: $(BERKELEYDB-LIB) $(GCC)
	$(GCC) -I$(BERKELEYDB-LOCAL)/include test/berkeleydb-link.c \
	  $(BERKELEYDB-LIBS) -o $(LOCAL-TMP)/berkeleydb-link
	$(LOCAL-TMP)/berkeleydb-link
