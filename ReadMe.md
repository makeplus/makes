makes
=====

Reusable parts for `Makefile`s


## Usage

In your (GNU 3.81+) Makefile start with:

```
# You can commit the `.mk` files or clone them.
$(shell [ -d .make ] || \
  (git clone -q https://github.com/makeplus/makes .make))

# Include `init.mk` first:
include .make/init.mk

# Then include any others you need:
include .make/this.mk
include .make/that.mk
```
