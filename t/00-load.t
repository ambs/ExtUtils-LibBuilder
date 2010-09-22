#!perl -T

use Test::More tests => 1;

BEGIN {
    use_ok( 'ExtUtils::LibBuilder' ) || print "Bail out!
";
}

diag( "Testing ExtUtils::LibBuilder $ExtUtils::LibBuilder::VERSION, Perl $], $^X" );
