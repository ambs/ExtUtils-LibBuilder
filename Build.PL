use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'ExtUtils::LibBuilder',
    license             => 'perl',
    dist_author         => q{Alberto Simoes <ambs@cpan.org>},
    dist_version_from   => 'lib/ExtUtils/LibBuilder.pm',
    build_requires      => {
                            'ExtUtils::CBuilder' => '0.23',
                            'File::Spec'         => 0,
                            'File::Temp'         => 0,
                            'Test::More'         => 0,
    },
    add_to_cleanup      => [ 'ExtUtils-LibBuilder-*' ],
    resources           => {
                            repository => {
                                           type => 'git',
                                           url  => 'git://github.com/ambs/ExtUtils-LibBuilder.git',
                                          },
                           },
);

$builder->create_build_script();
