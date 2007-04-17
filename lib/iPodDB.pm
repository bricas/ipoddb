package iPodDB;

=head1 NAME

iPodDB - iPod music database browser

=head1 SYNOPSIS

    use iPodDB;

    iPodDB->new->run;

=head1 DESCRIPTION

iPodDB is a WxPerl-based app for browsing music on your iPod.

=cut

use base qw( Wx::App );
use Wx;

use strict;
use warnings;

use iPodDB::MainWindow;

our $VERSION = '0.04';
our $APPNAME = 'iPod Database Browser';

=head1 METHODS

=head2 run( )

This is just an alias for Wx's MainLoop().

=cut

sub run {
    $_[ 0 ]->MainLoop;
}

=head2 OnInit( )

This is used to initialize the application. It sets a few application
parameters and loads up an iPodDB::MainWindow object.

=cut

sub OnInit {
    my $self = shift;

    $self->SetAppName( $APPNAME );
    $self->SetVendorName( 'Brian Cassidy' );

    my $main = iPodDB::MainWindow->new;

    $self->SetTopWindow( $main );
    $main->Show( 1 );

    return 1;
}

=head1 SEE ALSO

=over 4

=item * Wx

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
