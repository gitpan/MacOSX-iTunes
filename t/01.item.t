# $Id: 01.item.t,v 1.3 2002/07/16 21:48:30 comdog Exp $

BEGIN { $| = 1; print "1..4\n"; }
END {print "not ok 1\n" unless $loaded;}
use MacOSX::iTunes::Item;
require "t/ok.pl";

$loaded = 1;
print "ok 1\n";

$\ = "\n";

my $item;

my $file   = 'mp3/The_Wee_Kirkcudbright_Centipede.mp3';
my $Title  = 'The Wee Kirkcudbright Centipede';
my $Genre  = '';
my $Artist = 'The Tappan Sisters';
my $Time   = 186.82775;

# can we create an item?
eval {
	$item = MacOSX::iTunes::Item->new_from_mp3( $file );
	die "Could not create item!" unless ref $item;
	#print STDERR $item->as_string;
	};
print $@ ? not_ok() : ok();	

# can we access the attributes?
eval {
	die "Incorrect title!"  unless $Title  eq $item->title;
	die "Incorrect genre!"  unless $Genre  eq $item->genre;
	die "Incorrect artist!" unless $Artist eq $item->artist;
	die "Incorrect time!"   unless $Time   eq $item->seconds;
	die "Incorrect file!"   unless $file   eq $item->file;
	};
print $@ ? not_ok() : ok();	

# does a non-existent file create an item?
eval {
	$item = MacOSX::iTunes::Item->new_from_mp3( 'foo.mp' );
	die "Created item from missing file!" if ref $item;
	};
print $@ ? not_ok() : ok();	
