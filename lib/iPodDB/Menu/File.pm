package iPodDB::Menu::File;

=head1 NAME

iPodDB::Menu::File - the file menu

=head1 SYNOPSIS

    my $file = iPodDB::Menu::File->new( $frame );

=head1 DESCRIPTION

This is the File menu portion of the menu bar. It is also a popup menu
when a user right-clicks a song.

=cut

use base qw( Wx::Menu );
use Wx qw( wxOK wxID_OK wxTheClipboard wxPD_CAN_ABORT wxPD_APP_MODAL wxYES_NO wxNO_DEFAULT wxICON_EXCLAMATION wxID_YES );
use Wx::DND;

use strict;
use warnings;

use iPodDB::Songlist qw( song_to_path );

use File::Copy;
use Path::Class;

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

    $self->Append( my $copyto_id = Wx::NewId, "&Copy To...\tCtrl-T", 'Copy files to a new location' );
    $self->Append( my $copy_id   = Wx::NewId, "&Copy\tCtrl-C", 'Copy files to the clipboard' );

    unless( $parent->songlist and $parent->songlist->GetSelectedItemCount ) {
        $self->Enable( $copyto_id, 0 );
        $self->Enable( $copy_id, 0 );
    }

    $parent->EVT_MENU( $copyto_id, \&on_copyto );
    $parent->EVT_MENU( $copy_id, \&on_copy );

    return $self;
}

=head1 EVENTS

=head2 on_copyto( )

When the "Copy To..." option is selected this event is triggered. It will popup
a dialog asking the user to select a destination directory, then a progress dialog
to show them the progress of the copy operation.

=cut

sub on_copyto {
    my $self     = shift;
    my $songlist = $self->songlist;
    my $path     = dir( $self->preferences->mountpoint );

    return unless $songlist->GetSelectedItemCount;

    my $dialog = Wx::DirDialog->new( $self, 'Choose a destination directory' );

    return unless $dialog->ShowModal == wxID_OK;

    my $dpath    = dir( $dialog->GetPath );
    my $text     = "Copying files to $dpath:\n%s";
    my $progress = Wx::ProgressDialog->new( 'Copying Files...', sprintf( $text, '' ), $songlist->GetSelectedItemCount, $self, wxPD_CAN_ABORT | wxPD_APP_MODAL );

    my $i = 0;
    for my $song ( $songlist->as_songobject ) {
        my $source      = song_to_path( $path, $song );
        my $file        = $source->basename;
        my $destination = $dpath->file( $file );

        last unless $progress->Update( $i++, sprintf( $text, $file ) );

        if( -e $destination ) {
            next unless Wx::MessageDialog->new(
                $self,
                "This folder already contains a file named '$file'.\nWould you like to replace the existing file?",
                'Confirm File Replace',
                wxYES_NO | wxNO_DEFAULT | wxICON_EXCLAMATION
            )->ShowModal == wxID_YES;

            unless( unlink $destination ) {
                Wx::MessageDialog->new( $self, "Cannot delete $destination!", 'Error', wxOK )->ShowModal;
                next;
            }
        }


        eval{ copy( $source, $destination ); };

        if( $@ ) {
            Wx::MessageDialog->new( $self, "Cannot copy file: $@", 'Error', wxOK )->ShowModal;
            last;
        }
    }
    $progress->Destroy;
}

=head2 on_copy( )

When the "Copy" option is selected this event is triggered. It simply copies the
list of selected files to the clipboard. Thus, a user can do a paste operation in to
any folder they desire.

=cut

sub on_copy {
    my $self       = shift;
    my $songlist   = $self->songlist;
    my $path       = dir( $self->preferences->mountpoint );

    return unless $songlist->GetSelectedItemCount;

    my $files      = $songlist->as_filedataobject;

    wxTheClipboard->Open;
    wxTheClipboard->SetData( $files );
    wxTheClipboard->Close;
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
