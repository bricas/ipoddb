package iPodDB::MainWindow;

=head1 NAME

iPodDB::MainWindow - main window of the iPodb database browser

=head1 SYNOPSIS

    my $main = iPodDB::MainWindow->new;

=head1 DESCRIPTION

This is the main window of the iPodDB application to which everything is attached.

=cut

use base qw( Wx::Frame Class::Accessor );
use Wx qw( wxOK wxBOTH wxDefaultPosition wxDefaultSize wxNO_FULL_REPAINT_ON_RESIZE wxCLIP_CHILDREN wxLC_REPORT wxLC_VRULES wxLC_HRULES );
use Wx::Event qw( EVT_MENU );

use strict;
use warnings;

use iPodDB::Preferences;
use iPodDB::Database;
use iPodDB::Playlist;
use iPodDB::Songlist;
use iPodDB::Menu;
use iPodDB::Status;

=head1 PROPERTIES

=head2 preferences

An iPodDB::Preferences object

=head2 database

An iPodDB::Database object

=head2 splitter

The Wx::SplitterWindow object that holds the songlist and playlist panes

=head2 playlist

An iPodDB::Playlist object (listing of playlists)

=head2 songlist

An iPodDB::Songlist object (listing of songs in a given playlist)

=head2 menu

An iPodDB::Menu object

=head2 status

An iPodDB::Status object

=cut

__PACKAGE__->mk_accessors( qw( splitter preferences database playlist songlist menu status ) );

our $VERSION = '0.03';

=head1 METHODS

=head2 new( )

This creates the main window and all of its sub components. It will also call the load_database() method.

=cut

sub new {
    my $class = shift;
    my $size  = Wx::GetDisplaySize;
    my $self  = $class->SUPER::new( undef, -1, 'iPod Database Viewer', [ 0, 0 ], [ int( $size->GetWidth * 0.75 ), int( $size->GetHeight * 0.75 ) ] );
    $self->Centre( wxBOTH );

    bless $self, $class;

    # Load preferences and database
    $self->preferences( iPodDB::Preferences->new );
    $self->load_database;

    # Add status and menu bars
    $self->status( iPodDB::Status->new( $self ) );
    $self->menu( iPodDB::Menu->new( $self ) );

    # Create the split interface
    $self->splitter( Wx::SplitterWindow->new( $self, -1, wxDefaultPosition, wxDefaultSize, wxNO_FULL_REPAINT_ON_RESIZE | wxCLIP_CHILDREN ) );

    # Load song list
    $self->songlist( iPodDB::Songlist->new( $self->splitter ) );

    # Load playlist tree, link it to the songlist and populate it
    $self->playlist( iPodDB::Playlist->new( $self->splitter, $self->songlist ) );
    $self->playlist->populate( $self->database->playlists ) if $self->database;

    # Add elements to split interface
    $size = $self->GetSize;
    $self->splitter->SplitVertically( $self->playlist, $self->songlist, int( $size->GetWidth * 0.15 ) );

    # Select the first playlist to get things going
    $self->playlist->select_root;

    return $self;
}

=head2 load_database( )

This will try to load the iPod database based on the current preferences, if no preferences
are set, or the database could not be found, it will pop up the prefences dialog.

=cut

sub load_database {
    my $self        = shift;
    my $preferences = $self->preferences;

    $preferences->get_preferences( $self ) unless $preferences->mountpoint;

    my $database    = iPodDB::Database->new( $preferences->database );

    while( $preferences->mountpoint and not $database ) {
        Wx::MessageDialog->new(    $self, 'iTunesDB not found at mount point', 'Error', wxOK )->ShowModal unless $database;

        $preferences->get_preferences( $self );
        $database = iPodDB::Database->new( $preferences->database );
    }

    $self->database( $database ) if $database;
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
