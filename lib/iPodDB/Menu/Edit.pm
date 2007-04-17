package iPodDB::Menu::Edit;

=head1 NAME

iPodDB::Menu::Edit - the edit menu

=head1 SYNOPSIS

    my $edit = iPodDB::Menu::Edit->new( $frame );

=head1 DESCRIPTION

This is the Edit menu portion of the menu bar.

=cut

use base qw( Wx::Menu );

use strict;
use warnings;

our $VERSION = '0.03';

=head1 METHODS

=head2 new( $frame )

Creates the menu and sets up the callbacks when menu items are clicked.

=cut

sub new {
    my $class  = shift;
    my $parent = shift;
    my $self   = $class->SUPER::new;

    bless $self, $class;
    
    $self->Append( my $pref_id = Wx::NewId, '&Preferences', 'Modify your preferences' );

    $parent->EVT_MENU( $pref_id, \&on_preferences );

    return $self;
}

=head1 EVENTS

=head2 on_preferences( )

When the "Preferences" option is selected this event is triggered. It will popup
the preferences dialog for the user to modify then attempt to load the new database.

=cut

sub on_preferences {
    my $self        = shift;
    my $preferences = $self->preferences;
    my $mountpoint  = $preferences->mountpoint;

    $preferences->mountpoint( undef );
    $self->load_database;

    if( defined $preferences->mountpoint ) {
        $self->playlist->populate( $self->database->playlists ) if $self->database;
        $self->playlist->select_root;
    }
    else {
        $preferences->mountpoint( $mountpoint );
    }
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
