# $Id: 00.write.t,v 1.1 2002/07/16 21:48:02 comdog Exp $

BEGIN { $| = 1; print "1..1\n"; }
END {print "not ok 1\n" unless $loaded;}
use MacOSX::iTunes::Library::Write;
require "t/ok.pl";

$loaded = 1;
print "ok 1\n";

