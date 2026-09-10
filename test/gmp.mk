M := .
include $(M)/init.mk
include $(M)/gmp.mk

# Run with: make -f test/gmp.mk check-pic
check-pic: $(GMP-LIB) $(GCC)
	$(GCC) -fPIC -shared -Wl,--no-undefined -I$(GMP-LOCAL)/include \
	  test/gmp-pic.c $(GMP-LIB) -o $(LOCAL-TMP)/gmp-pic.so
