#!perl

use Test::More tests => 1;
use ExtUtils::LibBuilder;

my $libbuilder = ExtUtils::LibBuilder->new();

isa_ok($libbuilder, 'ExtUtils::CBuilder');
