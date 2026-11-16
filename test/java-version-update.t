#!/usr/bin/env perl

use strict;
use warnings;
use Test::More;
use File::Temp qw(tempdir);
use File::Copy qw(copy);
use Cwd qw(abs_path getcwd);

my $root = getcwd();
my $tmp = tempdir(CLEANUP => 1);
my $ys = $ENV{YS} or die "Run through make test\n";
$ys = abs_path($ys);

sub write_file {
    my ($path, $text) = @_;
    open my $fh, '>', $path or die "$path: $!";
    print {$fh} $text;
    close $fh or die "$path: $!";
}

copy("$root/util/check-versions", "$tmp/check-versions") or die $!;
copy("$root/util/version-update", "$tmp/version-update") or die $!;
open my $source, '<', "$root/util/check-versions" or die $!;
my $code = do { local $/; <$source> };
my ($missing) = $code =~ /missing =::\n(.*?)\n\ndefn/s;
for my $name ($missing =~ /^- (\S+)/mg) {
    write_file("$tmp/$name.mk", "# https://example.test/$name\n");
}
write_file("$tmp/skipped.mk", "SKIPPED-VERSION ?= 1.0.0\n");
write_file("$tmp/Makefile", "version-check:\n\t\@'$ys' check-versions\n");
mkdir "$tmp/bin" or die $!;
write_file("$tmp/bin/curl", <<'CURL');
#!/usr/bin/env perl
use strict;
use warnings;
open my $log, '>>', $ENV{CURL_LOG} or die $!;
print {$log} "$ARGV[-1]\n";
close $log;
if (grep { $_ eq '-fsIL' } @ARGV) {
    exit($ENV{ARCHIVE_FAIL} || 0);
}
exit 22 if $ENV{PAGE_FAIL};
open my $page, '<', $ENV{ORACLE_PAGE} or die $!;
print while <$page>;
CURL
chmod 0755, "$tmp/bin/curl" or die $!;
local $ENV{PATH} = "$tmp/bin:$ENV{PATH}";
local $ENV{ORACLE_PAGE} = "$tmp/oracle.html";
local $ENV{CURL_LOG} = "$tmp/curl.log";
chdir $tmp or die $!;

sub check_update {
    my ($label, $old, $versions, $expected, $failure) = @_;
    write_file('java.mk', "JAVA-VERSION ?= $old\n");
    write_file('oracle.html', join "\n", map {
        "<h3>Java SE Development Kit $_ downloads</h3>"
    } @$versions);
    write_file('curl.log', '');
    my $output = `'$ys' version-update 2>&1`;
    my $status = $?;
    if ($failure) {
        isnt($status, 0, "$label fails visibly");
    } else {
        is($status, 0, "$label succeeds") or diag $output;
    }
    open my $java, '<', 'java.mk' or die $!;
    is(<$java>, "JAVA-VERSION ?= $expected\n", $label);
    open my $log, '<', 'curl.log' or die $!;
    return do { local $/; <$log> };
}

my $log = check_update('full Oracle patch version', '27',
    ['25.0.5.0.3', '27.0.1.0.2', '27.0.1.0.3', '28-ea'],
    '27.0.1.0.3');
like($log, qr{/27/archive/jdk-27\.0\.1\.0\.3_linux-x64_bin\.tar\.gz},
    'validates the exact archive before updating');
check_update('numeric patch ordering', '27.0.1.0.3',
    ['27.0.1.0.10', '27.0.1.0.9'], '27.0.1.0.10');
$log = check_update('new major release', '27.0.1.0.3',
    ['28', '27.0.2'], '28');
like($log, qr{/28/latest/jdk-28_linux-x64_bin\.tar\.gz},
    'validates a major-only release through latest');
check_update('no downgrade', '27.0.1.0.3', ['25.0.5.0.3'], '27.0.1.0.3');
check_update('already current', '27.0.1.0.3',
    ['27.0.1.0.3'], '27.0.1.0.3');
check_update('missing release heading', '27.0.1.0.3',
    ['28-ea'], '27.0.1.0.3', 1);
{
    local $ENV{PAGE_FAIL} = 1;
    check_update('failed page request', '27', ['27.0.1.0.3'], '27', 1);
}
{
    local $ENV{ARCHIVE_FAIL} = 22;
    check_update('unavailable archive', '27', ['27.0.1.0.3'], '27', 1);
}
my $skipped = `'$ys' check-versions --skipped 2>&1`;
is($?, 0, 'skipped report succeeds');
unlike($skipped, qr/java\.mk/, 'Java is no longer skipped');
chdir $root or die $!;
done_testing;
