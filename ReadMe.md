Makes
=====

GNU Makefiles Simplified


## Synopsis

Makes automatically installs all dependencies locally inside the current
working directory.
Those dependencies include this repo itself, which is cloned the first time
you run `make` on a Makefile using Makes.

It works on Linux or MacOS (Intel and ARM) without worrying about specifics.

Here's an example Makefile for a Clojure project:

```make
# Set a directory to put the 'makes' repository:
M := .cache/makes
# Auto install the 'makes' repo on first 'make' command:
$(shell [ -d $M ] || git clone -q https://github.com/makeplus/makes $M)

# Include `init.mk` first:
include $M/init.mk

# Include any other deps you need. All installed/cached locally.
include $M/java.mk
include $M/clojure.mk
include $M/lein.mk

# Define your rules. The $(LEIN) dependency comes from lein.mk and triggers a
# local install of lein which will be in your PATH here.
test repl: $(LEIN)
	lein $@
```

Users just run `make test` out of the box.

They don't need `java`, `clojure` or `lein` installed on their system.
Makes wouldn't use their system versions if they did have them installed.

This makes for very reliable builds and testing.


## Overview

Makefiles for complex projects are usually complex.
They need special code to handle different environments.
They need complicated rules to install dependencies.
They don't share code with other Makefiles from other projects.

**Makes** changes all that.

Makefiles that use Makes are generally very short and to the point:
* They name a directory for all the dependencies to be installed.
* They list their dependencies.
* They define their rules making use of lots of predefined rules and variables.

Most of the intricacies are handled by Makes.

Every dependency language or tool has its own `<name>.mk` file in `makes`
repository that does as much of the work as possible for you.


## Auto-installation

Auto-installation of the `makes` repo itself is optional.

You can simply add the files you want to your project repository.

Dependency languages and tools will always be auto installed into one of these
places:

* The directory named by `MAKES_LOCAL_DIR`
* `./.cache/.local` if `MAKES_REPO_DIR` is set
* A `.local` directory next to the `makes` repo directory

If you want to make changes to the `makes` repo itself in combination with
various Makefiles you are working with, you can keep `makes` in a location you
desire by setting `MAKES_REPO_DIR` and setting the first line of your Makefiles
to something like this:

```make
M := $(or $(MAKES_REPO_DIR),.cache/makes)
```


## Caching Installation Assets

Each `<dep>.mk` language/tool dependency for Makes installs the tool from a
release file.
These files can be very large.

If you create a `$HOME/.cache/makes/` directory, these large downloads will
be cached there.


## Using `shell.mk`

If you add a `include $(MAKES)/shell.mk` you will get rules for `make shell`,
`make bash` and `make zsh`.
These will start a subshell after installing all the Makes dependencies you
have already included.


## Testing Specific `<tool>.mk` Files

If you want to try out a specific `<name>.mk` file here, just run `make
<name>-shell`.
That will start a shell with the `<name>` tooling installed.

For instance, to try out `crystal.mk`, just run `make crystal-shell`.


## Makes Shells

If you have the makes repo cloned locally, you can source the `.rc` file to get the `makesh` command:

```bash
$ source /path/to/makes/.rc
$ makesh go ruby
(makesh go ruby) $ 
```

This starts a subshell with go and ruby installed.


## Using Gists for Makefiles

If you often want to use a language like Rust on various machines but you don't
want to install it first you can make a file like:

```
M := /tmp/makes
export MAKES_LOCAL_DIR := /tmp/local
$(shell [ -d $M ] || git clone -q https://github.com/makeplus/makes $M)
include $M/init.mk
include $M/go.mk
include $M/shell.mk
```

Then turn it into a GitHub gist:
https://gist.github.com/ingydotnet/20b903f984c28f0105739205f25400b1

Now you can run this anywhere and have a shell with Go tools installed:

```bash
$ go version
Command 'go' not found, but can be installed with:
sudo snap install go         # version 1.24.4, or
sudo apt  install golang-go  # version 2:1.21~2
sudo apt  install gccgo-go   # version 2:1.21~2
See 'snap info go' for additional versions.
$
$ make -f <(curl -sL https://gist.github.com/ingydotnet/20b903f984c28f0105739205f25400b1/raw) bash
Installing 'go' locally
curl+ https://go.dev/dl/go1.24.4.linux-amd64.tar.gz > /tmp/local/cache/go1.24.4.linux-amd64.tar.gz
tar -C /tmp/local -xzf /tmp/local/cache/go1.24.4.linux-amd64.tar.gz
mv /tmp/local/go /tmp/local/go-1.24.4
touch /tmp/local/go-1.24.4/bin/go

(makes) ~ $ go version
go version go1.24.4 linux/amd64
(makes) ~ $
(makes) ~ $ exit
exit
$ go version  # Go is not installed on your system; just in /tmp/local/
Command 'go' not found, but can be installed with:
sudo snap install go         # version 1.24.4, or
sudo apt  install golang-go  # version 2:1.21~2
sudo apt  install gccgo-go   # version 2:1.21~2
See 'snap info go' for additional versions.
$
$ # Next time you run this, Go is already installed:
$ make -f <(curl -sL https://gist.github.com/ingydotnet/20b903f984c28f0105739205f25400b1/raw) bash
(makes) ~ $ go version
go version go1.24.4 linux/amd64
(makes) ~ $
```

Need a specific Go version?

```bash
$ make -f <(curl -sL https://gist.github.com/ingydotnet/20b903f984c28f0105739205f25400b1/raw) bash GO-VERSION=1.23.4
Installing 'go' locally
curl+ https://go.dev/dl/go1.23.4.linux-amd64.tar.gz > /tmp/local/cache/go1.23.4.linux-amd64.tar.gz
tar -C /tmp/local -xzf /tmp/local/cache/go1.23.4.linux-amd64.tar.gz
mv /tmp/local/go /tmp/local/go-1.23.4
touch /tmp/local/go-1.23.4/bin/go

(makes) ~ $ go version
go version go1.23.4 linux/amd64
(makes) ~ $
```

All of this works for any language, not just Go.
And yes, you can include as many languages as you want into the Makefile.


## Makefile Template

You can use the `share/Makefile` in this repo as a template for your new
`Makefile`.


## Copyright and License

Copyright 2025 by Ingy döt Net

This is free software, licensed under:

The MIT (X11) License
