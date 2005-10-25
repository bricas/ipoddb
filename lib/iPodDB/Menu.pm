package iPodDB::Menu;

=head1 NAME

iPodDB::Menu - iPodDB Menu bar

=head1 SYNOPSIS

	my $menu = iPodDB::Menu->new( $frame );

=head1 DESCRIPTION

This adds a menu bar to the main iPodDB window. It has three menus:
File, Edit and Help.

=cut

use base qw( Wx::MenuBar );

use strict;
use warnings;

use iPodDB::Playlist;
use iPodDB::Menu::File;
use iPodDB::Menu::Edit;
use iPodDB::Menu::Help;

our $VERSION = '0.02';

=head1 METHODS

=head2 new( $frame )

Creates the menu bar and adds the File, Edit and Help menus to it.

=cut

sub new {
	my $class  = shift;
	my $parent = shift;
	my $self   = $class->SUPER::new;

	bless $self, $class;

	$self->Append( iPodDB::Menu::File->new( $parent ), '&File' );
	$self->Append( iPodDB::Menu::Edit->new( $parent ), '&Edit' );
	$self->Append( iPodDB::Menu::Help->new( $parent ), '&Help' );

	$parent->SetMenuBar( $self );

	return $self;
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