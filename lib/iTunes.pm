# $Id: iTunes.pm,v 1.3 2002/07/17 06:55:24 comdog Exp $
package MacOSX::iTunes;

use MacOSX::iTunes::Item;
use MacOSX::iTunes::Playlist;

require Exporter;
use base qw(Exporter);

$VERSION = '0.01';

=head1 NAME

MacOSX::iTunes -

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 METHODS

=over 4 

=item new()

Creates a new MacOSX::iTunes object.  If you specify a filename argument
the object uses that file as the iTunes Music Library to initialize
the object, otherwise the object is empty (so you can build a new library).

Returns false on failure.

=cut
	
sub new
	{
	my $class = shift;
	
	my $self = {
		_playlists => {},
		};
		
	bless $self, $class;
	
	return $self;
	}
	
=item playlists

In list context, returns a list of the titles of the playlists.
In scalar context, returns the number of playlists.

=cut
	
sub playlists
	{
	my $self = shift;
	
	my @playlists = keys %{ $self->{_playlists} };
	
	return wantarray ? @playlists : scalar @playlists;
	}
	
=item get_playlist( PLAYLIST )

Takes a playlist title argument.

Extracts a MacOSX::Playlist object from the music library.  Returns 
false if the playlist does not exist.

=cut
	
sub get_playlist
	{
	my $self = shift;
	my $name = shift;
	
	return unless $self->playlist_exists($name);
	
	my $playlist = $self->{_playlists}{$name};
	
	return $playlist;
	}

=item add_playlist( OBJECT )

Takes a MacOSX::iTunes::Playlist objext as its only argument.

Adds the playlist to the music library.

=cut
	
sub add_playlist
	{
	my $self     = shift;
	my $playlist = shift;

	return unless defined $playlist;
	
	return unless(
		ref $playlist and $playlist->isa( 'MacOSX::iTunes::Playlist' ) );
	
	my $title = $playlist->title;

	return if $self->playlist_exists( $title );
	
	$self->{_playlists}{$title} = $playlist;
	
	return 1;
	}

=item delete_playlist( PLAYLIST | OBJECT )

Takes a playlist title or MacOSX::iTunes::Playlist object as 
an argument.  

Removes the playlist from the music library.

=cut
	
sub delete_playlist
	{
	my $self  = shift;
	my $title = shift;
	
	return unless $self->playlist_exists( $title );
	
	if( ref $title )
		{
		return unless $title->isa( 'MacOSX::iTunes::Playlist' );
		
		$title = $title->title;
		}
		
	delete ${ $self->{_playlists} }{$title};
	}

=item playlist_exists( PLAYLIST | OBJECT )

Takes a playlist title or MacOSX::iTunes::Playlist object as 
an argument.  

Returns true if the playlist exists in the music library, and false
otherwise.

The playlist exists if the music library has a playlist with
the same title, or if the object matches another object in
the music library.  See MacOSX::iTunes::Playlist to see how
one playlist object may match another.

NOTE:  at the moment, if you use an object argument, the 
function extracts the title of the playlist and sees if that
title is in the library.  this is just a placeholder until i
come up with something better.

=cut
	
sub playlist_exists
	{
	my $self  = shift;
	my $title = shift;
			
	if( ref $title )
		{
		return unless $title->isa('MacOSX::iTunes::Playlist');
		
		# XXX: this is a start - just grab the title
		$title = $title->title;
		}
	
	return exists ${ $self->{_playlists} }{ $title };	
	}

=item read( FILENAME )

Reads the named iTunes Music Library file and uses it to form the
music library object, replacing any other data already in the 
object.

=cut
	
sub read
	{
	my $self = shift;
	my $file = shift;
		
	return unless open my( $fh ), $file;

	require MacOSX::iTunes::Library::Parse;
	
	MacOSX::iTunes::Library::Parse->parse( $fh );
	}
	
=item merge( FILENAME | OBJECT )

Merges the current music library with the one in the named file
or MacOSX::iTunes object.  Does not affect the object argument.

=cut
	
sub merge
	{
	my $self = shift;
	
	$self->_not_implemented;
	}
	
=item write

Returns the music library as a string suitable for an iTunes
Music Object file.

=cut
	
sub write
	{
	my $self = shift;

	require Data::Dumper;
	
	Data::Dumper::Dumper( $self );
	}
	
sub _not_implemented
	{
	require Carp;
	
	my $function = (caller(1))[3];

	Carp::croak( "$function is unimplemented" );
	}
	
"See why 1984 won't be like 1984";

=back

=head1 TO DO

* everything - the list of things already done is much shorter.

=head1 BUGS

=head1 AUTHOR

Copyright 2002, brian d foy <bdfoy@cpan.org>

You may redistribute this under the same terms as Perl.

=cut
