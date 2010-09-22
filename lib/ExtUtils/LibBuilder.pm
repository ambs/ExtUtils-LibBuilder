package ExtUtils::LibBuilder;

use warnings;
use strict;

our $VERSION = '0.01';

use base 'ExtUtils::CBuilder';

use File::Spec;
use File::Temp qw/tempdir/;

=head1 NAME

ExtUtils::LibBuilder - A tool to build C libraries.

=head1 SYNOPSIS

    use ExtUtils::LibBuilder;

    my $libbuilder = ExtUtils::LibBuilder->new();

=head1 METHODS

=head2 new

=cut

sub new {
    my $class = shift;
    my %options = @_;

    my $self = bless ExtUtils::CBuilder->new(%options) => $class;
    # $self->{quiet} = 1;

    $self->{libext} = $^O eq "darwin" ? ".dylib" : ( $^O =~ /win/i ? ".dll" : ".so");
    $self->{exeext} = $^O =~ /win32/i ? ".exe" : "";

    print STDERR "\nTesting Linux\n\n";
    return $self if $^O !~ /darwin|win32/i && $self->_try;

    print STDERR "\nTesting Darwin\n\n";
    $self->{config}{lddlflags} =~ s/-bundle/-dynamiclib/;
    return $self if $^O !~ /win32/i && $self->_try;

    print STDERR "\nTesting Win32\n\n";

    print STDERR "\nNothing...\n\n";
    return undef;
}

sub _try {
    my ($self) = @_;
    my $tmp = tempdir CLEANUP => 1;
    _write_files($tmp);

    print STDERR "\nAAAAAAIEEEEEEH\n\n";

    my @csources = map { File::Spec->catfile($tmp, $_) } qw'library.c test.c';
    my @cobjects = map { $self->compile( source => $_) } @csources;

    my $libfile = File::Spec->catfile($tmp => "libfoo$self->{libext}");
    my $exefile = File::Spec->catfile($tmp => "foo$self->{exeext}");

    $self->link( objects     => [$cobjects[0]],
                 module_name => "foo",
                 lib_file    => $libfile );

    return 0 unless -f $libfile;

    $self->link_executable( exe_file           => $exefile,
                            extra_linker_flags => "-L $tmp -lfoo",
                            objects => [$cobjects[1]]);

    return 0 unless -f $exefile && -x _;
    return 1;
}

=head1 AUTHOR

Alberto Simoes, C<< <ambs at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-extutils-libbuilder at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=ExtUtils-LibBuilder>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc ExtUtils::LibBuilder


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=ExtUtils-LibBuilder>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/ExtUtils-LibBuilder>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/ExtUtils-LibBuilder>

=item * Search CPAN

L<http://search.cpan.org/dist/ExtUtils-LibBuilder/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2010 Alberto Simoes.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.


=cut


sub _write_files {
    my $outpath = shift;
    my $fh;
    seek DATA, 0, 0;
    while(<DATA>) {
        if (m!^==\[(.*?)\]==!) {
	    my $fname = $1;
            $fname = File::Spec->catfile($outpath, $fname);
            open $fh, ">$fname" or die "Can't create temporary file $fname\n";
        } elsif ($fh) {
            print $fh $_;
        }
    }
}

1; # End of ExtUtils::LibBuilder


__DATA__
==[library.c]==
  int answer(void) {
      return 42;
  }
==[test.c]==
#include <stdio.h>

int main() {
    int a = answer();
    printf("%d\n", a);
    return 0;
}


