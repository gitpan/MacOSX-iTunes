# $Id: 02.itunes.t,v 1.2 2002/06/15 05:28:39 comdog Exp $

BEGIN { $| = 1; print "1..9\n"; }

END {print "not ok 1\n" unless $loaded;}

use MacOSX::iTunes::Playlist;
use MacOSX::iTunes;
require "t/ok.pl";

$loaded = 1;
print "ok 1\n";

$\ = "\n";

my $playlist;
my $iTunes;
my $Title = 'Schoolhouse Rock';
eval {
	$playlist = MacOSX::iTunes::Playlist->new( $Title );
	die "Could not create playlist object!" unless ref $playlist;
	
	$iTunes = MacOSX::iTunes->new();
	die "Could not create iTunes object!" unless ref $iTunes;
	};
print $@ ? not_ok() : ok();	

# test if i can add a playlist correctly
eval {
	die "Could not add playlist!"
		unless $iTunes->add_playlist( $playlist );
	die "Added playlist, but it does not exist!"
		unless $iTunes->playlist_exists( $playlist );
	die "Added playlist, but playlist count is wrong!"
		unless 1 == $iTunes->playlists;
	};
print $@ ? not_ok() : ok();	

# test if i can fetch the playlist correctly
eval {
	die "Could not fetch playlist!"
		unless my $fetched = $iTunes->get_playlist( $Title );
	die "Fetched playlist is different! $fetched | $playlist"
		unless $fetched eq $playlist;
	};
print $@ ? not_ok() : ok();	

# test if i can't fetch the playlist incorrectly
eval {
	die "Could fetch non-existent playlist!"
		if $iTunes->get_playlist( "Doesn't Exist" );
	};
print $@ ? not_ok() : ok();	

# test if i can't re-add a playlist
eval {
	die "Could add playlist that I already added!"
		if $iTunes->add_playlist( $playlist );
	};
print $@ ? not_ok() : ok();	

# test if i can delete a playlist correctly -- by object
eval {
	die "Playlist to delete does not exist!"
		unless $iTunes->playlist_exists( $playlist );
	die "Playlist to delete does not exist!"
		unless $iTunes->delete_playlist( $playlist );
	die "Playlist to delete was deleted, but it's still there!"
		if $iTunes->playlist_exists( $playlist );
	die "Added playlist, but playlist count is wrong!"
		unless 0 == $iTunes->playlists;
	};
print $@ ? not_ok() : ok();	

# test if i can delete a playlist correctly -- by title
eval {
	$playlist = MacOSX::iTunes::Playlist->new( $Title );
	die "Could not create playlist object!" unless ref $playlist;

	$iTunes->add_playlist( $playlist );
	
	die "Playlist to delete does not exist!"
		unless $iTunes->playlist_exists( $Title );
	die "Playlist to delete does not exist!"
		unless $iTunes->delete_playlist( $Title );
	die "Playlist to delete was deleted, but it's still there!"
		if $iTunes->playlist_exists( $Title );
	};
print $@ ? not_ok() : ok();	

# test if i can't add a playlist incorrectly
eval {
	die "Oops! Added null playlist!"
		if $iTunes->add_playlist( );
	die "Oops! Added playlist from an undef argument!"
		if $iTunes->add_playlist( undef );
	die "Oops! Added playlist from a string argument!"
		if $iTunes->add_playlist( 'Title' );
	die "Oops! Added playlist with wrong object class!"
		if $iTunes->add_playlist( $iTunes );
	};
print $@ ? not_ok() : ok();	
