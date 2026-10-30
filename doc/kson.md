# KSON

`kson.mk` builds the native KSON CLI from tagged sources using Gradle and
GraalVM.
It supports Linux x64 and ARM64, and macOS ARM64.
The build requires a native C compiler, the platform SDK, and zlib development
headers and libraries.

```make
include $M/init.mk
include $M/kson.mk
include $M/shell.mk
```

Run `make shell CMD='kson --version'` to install and check the executable.
In the Makes repository, use `make kson-shell CMD='kson --version'`.
The native executable does not require Java at runtime.

## Build dependencies

KSON uses `graalvm.mk`, `gradle.mk`, and `perl.mk`.
Load `kson.mk` before other modules that select Java, such as `maven.mk` or
`gradle.mk`, so they reuse GraalVM.
Makes does not allow `java.mk` and `graalvm.mk` together.
KSON's Gradle build supplies its own Kotlin compiler.
`kotlin.mk` is unnecessary.

The module builds the JVM application distribution with Gradle's
`:tooling:cli:installDist` task, then calls GraalVM's `native-image` directly.
It does not run the upstream Gradle wrapper or install Pixi.
Release mode avoids requiring Git metadata in the downloaded source archive.

KSON's sources require an exact Java version.
The module adjusts `JDK_VERSION` in the extracted `jdk.properties` to match
Makes-managed Java, retaining the upstream version check.
This changes only the downloaded build sources.

## Versions and caches

- `KSON-VERSION` defaults to `0.3.0` and selects the source tag and
  installation.
- `GRADLE-VERSION` defaults to KSON's pinned `9.4.1` unless already selected.
- `GRAALVM-VERSION` uses the existing `graalvm.mk` default, currently `25`.
- `GRADLE_USER_HOME` defaults to `$(LOCAL-CACHE)/gradle`.
  An explicit setting is preserved.

For example:

```sh
make kson-shell KSON-VERSION=0.3.0 CMD='kson --version'
```

The executable is `$(LOCAL-ROOT)/kson-$(KSON-VERSION)/bin/kson`, also exposed
as `$(KSON)` and added to PATH.
Sources and intermediate outputs remain under `$(LOCAL-TMP)`.
Downloads and Gradle dependencies use `$(LOCAL-CACHE)`.
KSON's build also directs Maven resolution into `$(LOCAL-CACHE)/maven` and
uses `$(LOCAL-HOME)` as Java's user home.
These paths follow `MAKES_LOCAL_DIR`, normally inside a project's `.cache/`.

Standalone `gradle.mk` defaults to Gradle `9.8.2` and loads `java.mk` unless
Java or GraalVM was already included.
It exposes `$(GRADLE)` and adds its versioned `bin` directory to PATH.

## Validation

```sh
make test t='test/gradle.t test/kson.t'
make test t='test/gradle.t test/kson.t' slow=1
make shell WITH=shellcheck CMD='shellcheck test/gradle.t test/kson.t'
```

The slow tests download tools and compile KSON.
Windows and macOS Intel can load the module, but attempting installation
reports that native builds are unsupported.
