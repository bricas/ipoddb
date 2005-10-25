package iPodDB::Preferences;

=head1 NAME

iPodDB::Preferences - Store and Retrieve preferences

=head1 SYNOPSIS

	my $preferences = iPodDB::Preferences->new;

=head1 DESCRIPTION

This module stores and retrieves the application preferences via Wx::ConfigBase.

=cut

use base( Class::Accessor );
use Wx qw( wxID_OK );

use strict;
use warnings;

use Path::Class;

use constant DBPATH => 'iPod_Control/iTunes/iTunesDB';

=head1 PROPERTIES

=head2 mountpoint

The location where the root directory of the iPod can be found.

=head2 database

The location of the database on the above mountpoint

=cut

__PACKAGE__->mk_accessors( qw( mountpoint database ) );

our $VERSION = '0.02';

=head1 METHODS

=head2 new( )

Gets the application preferences via Wx::ConfigBase::Get.

=cut

sub new {
	my $class  = shift;
	my $self   = $class->SUPER::new;
	my $config = Wx::ConfigBase::Get;

	$config->Write( 'version' => $iPodDB::VERSION );
	$self->config( $config );

	return $self;
}

=head2 get_preferences( [ $frame ] )

This will load up the perferences dialog so the user can customize the applcation.

=cut

sub get_preferences {
	my $self   = shift;
	my $parent = shift;
	my $dialog = Wx::DirDialog->new( $parent, 'Select iPod mount location' );

	unless( $dialog->ShowModal == wxID_OK ) {
		$self->mountpoint( undef );
		return;
	}

	$self->mountpoint( $dialog->GetPath );
}

=head2 config( [ $config ] )

Gets / sets the Wx::ConfigBase object.

=cut

sub config {
        my $self = shift;

        if( @_ ) {
            $self->{ _CONFIG } = shift;
        }

        return $self->{ _CONFIG };
}

=head2 set( $key => $value )

Sets a configuration variable. The variable will be delete if the value
is not defined. If a trigger (a sub named on_$key) then it will subsequently be
called with the value of the key as a parameter.

This should not be used directly, rather use the properties above (as methods).

=cut

sub set {
	my $self    = shift;
	my $key     = shift;
	my $value   = shift;
	my $config  = $self->config;
	my $trigger = "on_$key";

	if( not defined $value ) {
		$config->DeleteEntry( $key ) if $config->Exists( $key );
	}
	else {
		$config->Write( $key => $value );
	}

	$self->$trigger( $value ) if $self->can( $trigger );

	return $value;
}

=head2 get( $key )

Gets a configuration variable.

This should not be used directly, rather use the properties above (as methods).

=cut

sub get {
	my $self   = shift;
	my $key    = shift;
	my $config = $self->config;

	return undef unless $config->Exists( $key );
	return $config->Read( $key );
}

=head1 EVENTS

=head2 on_mountpoint( $value )

This trigger is called once the mountpoint is set. It will automatically
add the location of the iPod database on the mountpoint.

=cut

sub on_mountpoint {
	my $self   = shift;
	my $value  = shift;

	return $self->database( undef ) unless defined $value;

	my @path = split( /\//, DBPATH );
	my $file = dir( $value );

	for( 0..$#path ) {
		$file = $_ == $#path ? $file->file( $path[ $_ ] ) : $file->subdir( $path[ $_ ] );
	}

	$self->database( $file->stringify );
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