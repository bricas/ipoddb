package iPodDB::Songlist;

=head1 NAME

iPodDB::Songlist - listing of songs in a playlist

=head1 SYNOPSIS

	my $songlist = iPodDB::Songlist->new( $frame );
	$songlist->populate( $playlist );

=head1 DESCRIPTION

This module provides a listing of the songs in an iPod playlist. It has a
few events attached to it such as: sorting the column on click, and poping up
the File menu when you right-click a row.

=cut

use base qw( Wx::ListCtrl Exporter Class::Accessor );
use Wx qw( wxLC_REPORT wxLC_VRULES wxLC_HRULES wxLIST_STATE_SELECTED wxLIST_NEXT_ALL );
use Wx::Event qw( EVT_LIST_COL_CLICK EVT_LIST_ITEM_RIGHT_CLICK EVT_LIST_ITEM_SELECTED EVT_LIST_ITEM_DESELECTED EVT_LIST_BEGIN_DRAG );
use Wx::DND;

use strict;
use warnings;

use Path::Class;

use constant ARTIST     => 0;
use constant ALBUM      => 1;
use constant TITLE      => 2;

use constant ASCENDING  => 0;
use constant DESCENDING => 1;

our $VERSION     = '0.02';
our @EXPORT_OK   = qw( song_to_path );

my @columns      = qw( artist album title );
my @column_sort  = ( ASCENDING ) x 3;
my $current_sort = ARTIST;

=head1 PROPERTIES

=head2 songs

An list of Mac::iPod::DB::Song objects

=cut

__PACKAGE__->mk_accessors( qw( songs ) );

=head1 METHODS

=head2 new( $frame )

This creates the list widget.

=cut

sub new {
	my $class  = shift;
	my $parent = shift;

	my $self   = $class->SUPER::new( $parent, -1, [ -1, -1 ], [ -1, -1 ], wxLC_REPORT | wxLC_VRULES | wxLC_HRULES );

	bless $self, $class;

	$self->InsertColumn( $_, ucfirst( $columns[ $_ ] ) ) for 0..$#columns;

	$self->EVT_LIST_COL_CLICK( $self, \&on_column_click );
	$self->EVT_LIST_ITEM_RIGHT_CLICK( $self, \&on_row_right_click );
	$self->EVT_LIST_ITEM_SELECTED( $self, \&on_select );
	$self->EVT_LIST_ITEM_DESELECTED( $self, \&on_select );
	$self->EVT_LIST_BEGIN_DRAG( $self, \&on_drag );

	return $self;
}

=head2 populate( @songs )

This will add the list of songs to the listing as well as
update the status bar.

=cut

sub populate {
	my $self   = shift;
	my @songs  = @_;
	my $status = $self->GetGrandParent->status;

	$self->DeleteAllItems;
	$status->clear;

	return unless @songs;

	my $time;
	my $filesize;
	for my $index ( 0...$#songs ) {
		my $id   = $self->InsertItem( Wx::ListItem->new );
		my $song = $songs[ $index ];

		for( 0..$#columns ) {
			my $column = $columns[ $_ ];
			$self->SetItem( $id, $_, $song->$column );
		}
		$self->SetItemData( $id, $index );

		$time     += $song->time;
		$filesize += $song->filesize;
	}

	$self->songs( \@songs );

	$status->songs( scalar @songs );
	$status->time( $time );
	$status->size( $filesize );

	$self->SetColumnWidth( $_, -1 ) for 0..$#columns;
	$self->SortItems( sub { return $self->cmp_songs( $current_sort, @_ ); } );
}

=head2 as_songobject( [ @items ] )

This function returns an array of Mac::iPod::DB::Song objects based on a list of items.
If no list is provided the currently selected items are used.

=cut

sub as_songobject {
	my $self     = shift;
	my @items    = @_;
	my @allsongs = @{ $self->songs };
	my $item     = -1;
	my @songs;

	unless( @items ) {
		while( ( $item = $self->GetNextItem( $item, wxLIST_NEXT_ALL, wxLIST_STATE_SELECTED ) ) != -1 ) {
			push @items, $self->GetItemData( $item );
		}
	}

	push @songs, $allsongs[ $_ ] for @items;

	return @songs;
}

=head2 as_filedataobject( [ @items ] )

Return a Wx::FileDataObject from a list of items suitable for sending to the clipboard
or for processing in a drag and drop event. If no list is provided, the currently
selected items are used.

=cut

sub as_filedataobject {
	my $self  = shift;
	my @items = @_;
	my $path  = dir( $self->GetGrandParent->preferences->mountpoint );
	my $files = Wx::FileDataObject->new;
	
	for my $song ( $self->as_songobject( @items ) ) {
		my $file = song_to_path( $path, $song );
		$files->AddFile( $file->stringify );
	}

	return $files;
}

=head2 cmp_songs( $column, $a, $b )

This is the sorting function.

=cut

sub cmp_songs {
	my $self   = shift;
	my $column = shift;
	my $a      = shift;
	my $b      = shift;
	my @songs  = @{ $self->songs };
	my $field  = $columns[ $column ];

	return 0 unless @songs;

	if( $column_sort[ $column ] == DESCENDING ) {
		my $temp = $a;
		$a       = $b;
		$b       = $temp;
	}

	return $songs[ $a ]->$field cmp $songs[ $b ]->$field;
}

=head2 song_to_path( $directory, $song )

This utility function takes a directory (Path::Class object) and then the a song object. It then translates
the stored path to a path relative to the $directory. This method is available for export.

=cut

sub song_to_path {
	my $dir  = shift;
	my @path = split( ':', shift->path );

	for( 1..$#path ) {
		$dir = $_ == $#path ? $dir->file( $path[ $_ ] ) : $dir->subdir( $path[ $_ ] );
	}

	return $dir;
}

=head1 EVENTS

=head2 on_column_click( )

This event will sort the listing based on which column was clicked. It will
flip between ascending order and descending order on every click.

=cut

sub on_column_click {
	my $self   = shift;
	my $event  = shift;
	my $column = $event->GetColumn;

	if( $current_sort == $column ) {
		$column_sort[ $column ] ^= 1;
	}
	else {
		$current_sort = $column;
	}

	$self->SortItems( sub { return $self->cmp_songs( $column, @_ ); } );
}

=head2 on_row_right_click( )

This event will pop up the File menu as long as at least one song is selected.

=cut

sub on_row_right_click {
	my $self   = shift;
	my $event  = shift;
	my $parent = $self->GetGrandParent;

	if( $self->GetSelectedItemCount ) {
		$parent->PopupMenu( iPodDB::Menu::File->new( $parent ), $event->GetPoint );
	}
}

=head2 on_select( )

This event enables or disables options on the File menu when items are selected
or deselected.

=cut

sub on_select {
	my $self   = shift;
	my $menu   = $self->GetGrandParent->menu;
	my $enable = $self->GetSelectedItemCount ? 1 : 0;

	my @menus  = ( 'File', 'Copy To...', 'File', 'Copy' );

	while( @menus ) {
		my $item   = $menu->FindMenuItem( shift( @menus ), shift( @menus ) );
		$menu->Enable( $item, $enable );
	}
}

=head2 on_drag()

This event allows a user to drag files to a destination.

=cut

sub on_drag {
	my $self = shift;

	return unless $self->GetSelectedItemCount;

	Wx::DropSource->new( $self->as_filedataobject, $self->GetGrandParent )->DoDragDrop;
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