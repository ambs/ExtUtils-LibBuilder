#!perl

use Test::More tests => 7;
use ExtUtils::LibBuilder;

our @CLEAN;

my $libbuilder = ExtUtils::LibBuilder->new();

isa_ok($libbuilder, 'ExtUtils::CBuilder');

open OUT, ">", "lib.c" or die "Can't create test file";
print OUT <<'EOT';
int sum(int a, int b) { return a + b; }
EOT
close OUT;
add_to_cleanup("lib.c");

$libbuilder->compile( source => 'lib.c' );
ok(-f "lib.o");
add_to_cleanup("lib.o");

$libbuilder->link( objects     => "lib.o",
                   module_name => "bar",
                   lib_file    => "libbar$libbuilder->{libext}");
ok(-f "libbar$libbuilder->{libext}");
add_to_cleanup("libbar$libbuilder->{libext}");

open OUT, ">", "main.c" or die "Can't create test file";
print OUT <<'EOT';
#include <stdio.h>
extern int sum(int a, int b);
int main(void) {
  int a, b, c;
  a = 5;
  b = sum(a, a);
  c = sum(a, b);
  printf("%d\n", c);
  return 0;
}
EOT
close OUT;
add_to_cleanup("main.c");

$libbuilder->compile( source => 'main.c' );
ok(-f "main.o");

$libbuilder->link_executable( exe_file => "add$libbuilder->{exeext}",
                              extra_linker_flags => "-L. -lbar",
                              objects => ["main.o"]);
ok(-f "add$libbuilder->{exeext}");
ok(-x "add$libbuilder->{exeext}");

my $ans = `add$libbuilder->{exeext}`;
chomp $ans;
is($ans, 15);

clean();

sub add_to_cleanup {
    push @CLEAN, @_;
}

sub clean {
    unlink $_ for @CLEAN;
}
