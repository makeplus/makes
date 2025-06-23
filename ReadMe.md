Makes
=====

Reusable parts for `Makefile`s


## Usage

In your (GNU 3.81+) Makefile start with:

```
# You can commit the `.mk` files or clone them.
M := .cache/makes
$(shell [ -d $M ] || git clone -q https://github.com/makeplus/makes $M)

# Include `init.mk` first:
include $M/init.mk

# Then include any others you need:
include $M/this.mk
include $M/that.mk
```


## Makefile Template

The `share/Makefile` in this repo is a template for new repos.

To use Makes in a new project just run:

```bash
[[ -f Makefile ]] || wget https://github.com/makeplus/makes/raw/share/Makefile
make
```

