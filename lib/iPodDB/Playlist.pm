package iPodDB::Playlist;

=head1 NAME

iPodDB::Playlist - listing of playlists in a database

=head1 SYNOPSIS

    my $playlists = iPodDB::Playlist->new( $frame, $songlist );
    $playlists->populate( @playlists );

=head1 DESCRIPTION

This module provides a listing of the playlists in an iPod database. Clicking on
a different playlist will populate the songlist it is attached to.

=cut

use base qw( Wx::TreeCtrl Class::Accessor );
use Wx::Event qw( EVT_TREE_SEL_CHANGED );

use strict;
use warnings;

our $VERSION = '0.03';

=head1 PROPERTIES

=head2 songlist

An iPodDB::Playlist object (listing of songs in a given playlist)

=cut

__PACKAGE__->mk_accessors( qw( songlist ) );

=head1 METHODS

=head2 new( $frame, $songlist )

This creates the list widget and makes the link to the songlist widget.

=cut

sub new {
    my $class  = shift;
    my $parent = shift;
    my $self   = $class->SUPER::new( $parent, -1 );

    bless $self, $class;

    $self->songlist( shift );

    $self->EVT_TREE_SEL_CHANGED( $self, \&on_item_click );

    return $self;
}

=head2 populate( @playlists )

This will populate listing and expand the tree.

=cut

sub populate {
    my $self      = shift;
    my @playlists = @_;

    $self->DeleteAllItems;

    my $id;
    my $first = 1;
    for my $playlist ( @playlists ) {
        if( $first ) {
            $first--;
            $id = $self->AddRoot( $playlist->name, -1, -1, Wx::TreeItemData->new( $playlist ) );
            next;
        }
        $self->AppendItem( $id, $playlist->name, -1, -1, Wx::TreeItemData->new( $playlist ) ) 
    }
    $self->Expand( $id ) if defined $id;
}

=head2 select_root( )

This will select the first item in the list.

=cut

sub select_root {
    my $self = shift;
    $self->SelectItem( $self->GetRootItem );
}

=head1 EVENTS

=head2 on_item_click( )

This event will re-populate the songlist obect with the songs
from the selected playlist.

=cut

sub on_item_click {
    my $self     = shift;
    my $event    = shift;

    # for some reason this event gets called twice initially
    return unless $event->GetOldItem or not $self->songlist->songs;

    my $database = $self->GetGrandParent->database;
    my $playlist = $self->GetPlData( $event->GetItem );
    my @songs;

    # Mac::iPod::DB::Playlist will throw an error for smartlists
    eval { $playlist->songs; };

    unless( $@ ) {
        push @songs, $database->song( $_ ) for $playlist->songs;
    }

    $self->songlist->populate( @songs );
    $self->songlist->on_select;
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
