# $Id: 00.parse.t,v 1.2 2002/07/17 06:52:36 comdog Exp $

BEGIN { $| = 1; print "1..3\n"; }
END {print "not ok 1\n" unless $loaded;}

use MacOSX::iTunes;
use MacOSX::iTunes::Library::Parse;

require "t/ok.pl";
$\ = "\n";

$loaded = 1;
print "ok 1";

my $File = "mp3/iTunes Music Library";

eval {
	open my $fh, $File or die "Could not open [$File]: $!\n";
	my $result = MacOSX::iTunes::Library::Parse->parse( $fh );
	die "Not an iTunes object!" 
		unless UNIVERSAL::isa( $result, 'MacOSX::iTunes' );
	};
print STDERR $@ if $@;
print $@ ? not_ok() : ok();	

eval {
	my $result = MacOSX::iTunes->read( $File );
	die "Not an iTunes object!" 
		unless UNIVERSAL::isa( $result, 'MacOSX::iTunes' );
	};
print STDERR $@ if $@;
print $@ ? not_ok() : ok();	
