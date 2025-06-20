makes
=====

Reusable parts for `Makefile`s


## Usage

In your (GNU 3.81+) Makefile start with:

```
# You can commit the `.mk` files or clone them.
M := .makes
$(shell [ -d $M ] || git clone -q https://github.com/makeplus/makes $M)

# Include `init.mk` first:
include $M/init.mk

# Then include any others you need:
include $M/this.mk
include $M/that.mk
```


## Hiding the `.makes` directory

You can clone the `.makes/` directory inside the `.git/` directory, by changing
the first line above to:

```
M := .git/.makes
```

This will hide the directory from Git commands but it will still be local to
your repo.


## Makefile Variables

Makes will set these Makefile variables for you.

* `SHELL` - Set to `bash` if the current value is the default `/bin/sh`.
* `MAKES` - The `makes` clone directory's absolute path.
* `MAKEFILE` - The absolute path of the initial Makefile used.
* `MAKEFILE-DIR` - The directory of the MAKEFILE value.


## Example Makefile

The `share/Makefile` in this repo is a template for new repos.
