package iPodDB::Status;

=head1 NAME

iPodDB::Status - iPodDB Status bar

=head1 SYNOPSIS

	my $status = iPodDB::Status->new( $frame );
	$status->songs( $songs );
	$status->time( $time );
	$status->size( $size );

=head1 DESCRIPTION

This adds a status bar to the main iPodDB window. It keeps track of the
number of songs, the total length of the songs and the total size on disk
of the files.

=cut

use base qw( Class::Accessor );

use strict;
use warnings;

use constant SONGS => 1;
use constant TIME  => 2;
use constant SIZE  => 3;

__PACKAGE__->mk_accessors( qw( parent ) );

our $VERSION = '0.03';

my @columns = qw( songs time size );

=head1 METHODS

=head2 new( $frame )

Creates the status bar, with 3 columns (and one other for help text).

=cut

sub new {
	my $class  = shift;
	my $parent = shift;
	my $self   = {};

	$parent->CreateStatusBar( scalar @columns + 1 );

	bless $self, $class;

	$self->parent( $parent );
	$self->clear;

	return $self;
}

=head2 clear( )

Clears the status bar to 0 for each column.

=cut

sub clear {
	my $self = shift;
	$self->songs( 0 );
	$self->time( 0 );
	$self->size( 0 );
}

=head2 songs( [ $songs ] )

Gets / sets the songs column in the status bar.

=cut

sub songs {
	my $self  = shift;
	my $songs = shift;

	if( defined $songs ) {
		$self->parent->SetStatusText( "$songs songs", SONGS ) ;
		$self->{ _SONGS } = $songs;
	}

	return $self->{ _SONGS };
}

=head2 time( [ $time ] )

Gets / sets the time column in the status bar. It should be passed in as thousands of seconds.

=cut

sub time {
	my $self = shift;
	my $time = shift;

	if( defined $time ) {
		$self->{ _TIME } = $time;

		$time = $time / 1000 / 60 / 60;

		$self->parent->SetStatusText( sprintf( '%.1f hours', $time ), TIME ) ;
	}

	return $self->{ _TIME };
}


=head2 size( [ $size ] )

Gets / Sets the size column in the status bar. It should be passed in as bytes.

=cut

sub size {
	my $self = shift;
	my $size = shift;

	if( defined $size ) {
		$self->{ _SIZE } = $size;

		$size = $size / 1024 / 1024;

		$self->parent->SetStatusText( sprintf( '%.1f MB', $size ), SIZE ) ;
	}

	return $self->{ _SIZE };
}

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