#include <gmp.h>

/* Force the allocator references that failed when linking libcob.so. */
void check_gmp_pic(void) {
    mpz_t value;
    mpz_init_set_ui(value, 42);
    mpz_mul(value, value, value);
    mpz_clear(value);
}
