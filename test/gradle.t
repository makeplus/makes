#!/usr/bin/env bash

# shellcheck disable=SC1091
source test/init

work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT

cat > "$work/Makefile" <<MAKE
M := $ROOT
MAKES_LOCAL_DIR := $work/local
include \$(M)/init.mk
ifdef PROVIDER
include \$(M)/\$(PROVIDER).mk
endif
include \$(M)/gradle.mk
include \$(M)/gradle.mk

inspect:
	@printf '%s\n' \\
	  'gradle=\$(GRADLE)' \\
	  'download=\$(GRADLE-DOWN)' \\
	  'cache=\$(GRADLE_USER_HOME)' \\
	  'java=\$(JAVA)' \\
	  'java-loaded=\$(or \$(JAVA-LOADED),false)' \\
	  'graalvm-loaded=\$(or \$(GRAALVM-LOADED),false)' \\
	  'count=\$(words \$(filter \$(GRADLE),\$(SHELL-DEPS)))'
MAKE

out=$(make --no-print-directory -f "$work/Makefile" inspect)
has "$out" 'java-loaded=true' 'Gradle includes Java by default'
has "$out" "cache=$work/local/cache/gradle" \
  'Gradle defaults to a local dependency cache'
has "$out" 'count=1' 'Repeated includes add Gradle only once'

out=$(make --no-print-directory -f "$work/Makefile" \
  PROVIDER=graalvm inspect)
has "$out" 'graalvm-loaded=true' 'Gradle reuses GraalVM'
has "$out" 'java-loaded=false' 'Gradle does not load conflicting Java'
has "$out" '/graalvm-jdk-25/' 'Gradle uses GraalVM Java'

out=$(make --no-print-directory -f "$work/Makefile" \
  GRADLE-VERSION=1.2.3 GRADLE_USER_HOME="$work/custom-cache" inspect)
has "$out" '/gradle-1.2.3/bin/gradle' \
  'Version overrides select a separate installation'
has "$out" \
  'download=https://services.gradle.org/distributions/gradle-1.2.3-bin.zip' \
  'Version overrides select the distribution'
has "$out" "cache=$work/custom-cache" 'Explicit dependency caches are retained'

out=$(make --no-print-directory -f "$work/Makefile" \
  OS-NAME=windows ARCH-NAME=int64 inspect)
has "$out" '/bin/gradle.bat' 'Windows selects the batch launcher'

if [[ -z ${slow-} ]]; then
  pass 'Use slow=1 to run the Gradle installation test'
  done-testing
  exit 0
fi

cat > "$work/build.gradle" <<'GRADLE'
tasks.register('greet') {
    doLast { println 'makes-gradle-ok' }
}
GRADLE

out=$(make --no-pr gradle-test \
  CMD="gradle --version; gradle --no-daemon -q -p $work greet")
has "$out" 'Gradle 9.8.2' 'Installed Gradle reports its version'
has "$out" 'makes-gradle-ok' 'Gradle executes a project task'

done-testing
