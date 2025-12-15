define test-label
  @$(echo) "=== $(1) ==="
endef

define test-make
  @$(MAKE) -s $(1)
endef

define test-make-c
  @$(MAKE) -s -C $(1) $(2)
endef

define file-matches
  @test -f $(1) && $(echo) "  ✓ $(1) exists" || \
    ($(echo) "  ✗ $(1) not found"; exit 1)
  @diff -q $(1) $(2) && $(echo) "  ✓ $(1) matches $(2)" || \
    ($(echo) "  ✗ $(1) mismatch"; exit 1)
endef

define test-clean
  @$(MAKE) -s agents-clean
endef
