makes
=====

Reusable parts for `Makefile`s


## Usage

In your (GNU 3.81+) Makefile start with:

```
# You can commit the `.mk` files or clone them.
$(shell [ -d .makes ] || \
  (git clone -q https://github.com/makeplus/makes .makes))

# Include `init.mk` first:
include .makes/init.mk

# Then include any others you need:
include .makes/this.mk
include .makes/that.mk
```
