# $Id: 01.playlist.t,v 1.2 2002/06/16 07:24:06 comdog Exp $

BEGIN { $| = 1; print "1..12\n"; }

END   { print "not ok 1\n" unless $loaded; }

use MacOSX::iTunes::Item;
use MacOSX::iTunes::Playlist;
require "t/ok.pl";

$loaded = 1;
print "ok 1\n";

$\ = "\n";

my $playlist;
my $item;

my $file     = 'mp3/The_Wee_Kirkcudbright_Centipede.mp3';
my $Title    = 'The Tappan Sisters';

# how many files in the mp3 directory?
my $expected = 7;

# can we create an item?  we need this for later tests
eval {
	$item = MacOSX::iTunes::Item->new( $file );
	die "Could not create item!" unless ref $item;
	};
print $@ ? not_ok() : ok();	

# can we create a playlist?
eval {
	$playlist = MacOSX::iTunes::Playlist->new( $Title );
	die "Could not create playlist object!" unless ref $playlist;

	die "Incorrect number of items! Should be 0"
		unless $playlist->items == 0;
	};
print $@ ? not_ok() : ok();	

# can we fetch the title?
eval {
	my $title = $playlist->title;
	die "Stored title [$title] should be [$Title]"
		unless $title eq $Title;
	};
print $@ ? not_ok() : ok();	

# can we add an item?
eval {
	die "Could not add to playlist!"
		unless $playlist->add_item( $item );
	
	die "Incorrect number of items! Should be 1"
		unless $playlist->items == 1;
	};
print $@ ? not_ok() : ok();	
	
# can we not add a not item?
eval {
	die "Oops! Added string when it should be an object."
		if $playlist->add_item( 'This is not an item' );
	die "Incorrect number of items after string add! Should be 1"
		unless $playlist->items == 1;

	die "Oops! Added empty list."
		if $playlist->add_item( );
	die "Incorrect number of items after empty add! Should be 1"
		unless $playlist->items == 1;

	die "Oops! Added undef item."
		if $playlist->add_item( undef );
	die "Incorrect number of items after undef add! Should be 1"
		unless $playlist->items == 1;

	die "Oops! Added hash reference item."
		if $playlist->add_item( {} );
	die "Incorrect number of items after hash reference add! Should be 1"
		unless $playlist->items == 1;
	};
print $@ ? not_ok() : ok();	

# can we create a playlist with an item?
eval {
	$playlist = MacOSX::iTunes::Playlist->new( $Title, [ $item ] );
	die "Could not create playlist object with object!" 
		unless ref $playlist;
		
	die "Incorrect number of items! Should be 1"
		unless $playlist->items == 1;
	};
print $@ ? not_ok() : ok();	

# can we create a playlist with multiple items?
eval {
	my @items;
	foreach my $index ( 0 .. 10 )
		{
		# undocumented fake item
		push @items, MacOSX::iTunes::Item->_new($index);
		}
	
	my $count = @items;
	
	$playlist = MacOSX::iTunes::Playlist->new( $Title, \@items );
	die "Could not create playlist object with mulitple object!" 
		unless ref $playlist;
	
	die "Wrong number of items!  Should be $count."
		unless $playlist->items == $count;	

	};
print $@ ? not_ok() : ok();	

# can we get a random element in list context?
eval {
	my $count = $playlist->items;
	my %hash;
	
	foreach my $try ( 0 .. 100 )
		{
		my @item  = $playlist->random_item;
		
		die "random_item returned the wrong index [ ${$item[0]} | $item[1] ]"
			unless ${$item[0]} == $item[1];
		die "random_item returned the wrong total number"
			unless $item[2] == $count;
			
		$hash{ $item[1] }++;
		}
		
	my @keys   = keys %hash;
	my @values = values %hash;
	
	# i should be able to fetch all of the elements at least once
	die "Didn't fetch all of the items during random fetching"
		unless @keys == $count;
		
	my $min = 100_000;
	foreach my $try ( @values ) { $min = $try if $try < $min }
	
	my @normal = map { sprintf "%.2f", $_ / $min } @values;	
	};
print $@ ? not_ok() : ok();	

# can we get a random element in scalar context?
eval {
	foreach my $try ( 0 .. 100 )
		{
		my $item  = $playlist->random_item;

		die "Fetched a non-item!" 
			unless $item->isa( 'MacOSX::iTunes::Item' );
		}
	};
print $@ ? not_ok() : ok();	

# can we find mp3 files?
eval {
	my $playlist = MacOSX::iTunes::Playlist->new_from_directory(
		$Title, 'mp3' );
	die "Could not create playlist from directory!"
		unless ref $playlist;
		
	my $count = $playlist->items;
	die "Oops! Expected 7 items, got $count"
		unless $count == $expected;

	die "Oops! Incorrect title"
		unless $playlist->title eq $Title;
	};
print $@ ? not_ok() : ok();	

# can we merge playlists?
eval {
	my $playlist1 = MacOSX::iTunes::Playlist->new_from_directory(
		'First Playlist', 'mp3' );
	die "Could not create first playlist from directory!"
		unless ref $playlist1;
			
	my $count = $playlist1->items;
	die "Oops! Expected $expected items, got $count"
		unless $count == $expected;

	my $playlist2 = MacOSX::iTunes::Playlist->new_from_directory(
		'Second Playlist', 'mp3/empty.d' );
	die "Could not create second playlist from directory!"
		unless ref $playlist2;
	die "Oops! Expected 3 items"
		unless $playlist2->items == 3;
	
	$playlist1->merge( $playlist2 );
	die "Oops! Expected 10 items"
		unless $playlist1->items == 10;
	
	};
print $@ ? not_ok() : ok();	
