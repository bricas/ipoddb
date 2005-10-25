package iPodDB::Menu::Help;

=head1 NAME

iPodDB::Menu::Help - the help menu

=head1 SYNOPSIS

	my $help = iPodDB::Menu::Help->new( $frame );

=head1 DESCRIPTION

This is the Help menu portion of the menu bar.

=cut

use base qw( Wx::Menu );
use Wx qw( wxOK wxICON_INFORMATION );
use Wx::Event qw( EVT_MENU );

use strict;
use warnings;

our $VERSION = '0.02';

=head1 METHODS

=head2 new( $frame )

Creates the menu and sets up the callbacks when menu items are clicked.

=cut

sub new {
	my $class  = shift;
	my $parent = shift;
	my $self   = $class->SUPER::new;

	bless $self, $class;
	
	$self->Append( my $about_id = Wx::NewId, '&About', 'About iPodDB' );

	EVT_MENU( $parent, $about_id, \&on_about );

	return $self;
}

=head1 EVENTS

=head2 on_about( )

When the "About" option is selected this event is triggered. It will popup
a dialog with the credits for this application.

=cut

sub on_about {
	my $self = shift;

	Wx::MessageBox( "iPodDB Version $iPodDB::VERSION\nCopyright 2004 by Brian Cassidy", 'About iPodDB', wxOK | wxICON_INFORMATION, $self );
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