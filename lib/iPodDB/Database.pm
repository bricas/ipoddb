package iPodDB::Database;

=head1 NAME

iPodDB::Database - iPod music database

=head1 SYNOPSIS

    my $database = iPodDB::Database->new( $file );

=head1 DESCRIPTION

This module encapsulates the iPod database.

=cut

use base qw( Mac::iPod::DB );

use strict;
use warnings;

our $VERSION = '0.01';

=head1 METHODS

=head2 new( $file )

Loads the iPod database. Returns undef if a failure occurs.

=cut

sub new {
    my $class = shift;
    my $file  = shift;
    my $self;

    eval{ $self = $class->SUPER::new( $file ); };

    return undef unless $self;

    bless $self, $class;

    return $self;
}

=head1 SEE ALSO

=over 4

=item * Mac::iPod::DB

=back

=head1 AUTHOR

=over 4 

=item * Brian Cassidy E<lt>bricas@cpan.orgE<gt>

=back

=head1 COPYRIGHT AND LICENSE

Copyright 2004 by Brian Cassidy

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself. 

=cut

1;
