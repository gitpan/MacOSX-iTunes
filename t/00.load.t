# $Id: 00.load.t,v 1.1.1.1 2002/06/14 06:20:06 comdog Exp $

BEGIN { $| = 1; print "1..1\n"; }
END {print "not ok 1\n" unless $loaded;}
use MacOSX::iTunes;
$loaded = 1;
print "ok 1\n";
