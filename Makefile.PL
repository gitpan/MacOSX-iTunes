# $Id: Makefile.PL,v 1.4 2002/07/17 07:16:19 comdog Exp $
use ExtUtils::MakeMaker;

open IN,  "mp3/iTunes_Music_Library";
open OUT, "> mp3/iTunes Music Library";

print OUT do { local $/; <IN> };


WriteMakefile(
    'NAME'		    => 'MacOSX::iTunes',
    #'VERSION_FROM'	=> 'lib/iTunes.pm',
	'VERSION'       => '0.5_01',
	
    'PM'            => {
    	'lib/iTunes.pm'       => '$(INST_LIBDIR)/iTunes.pm',
    	'lib/Playlist.pm'     => '$(INST_LIBDIR)/iTunes/Playlist.pm',
    	'lib/Item.pm'         => '$(INST_LIBDIR)/iTunes/Item.pm',
    	'lib/Parse.pm'        => '$(INST_LIBDIR)/iTunes/Library/Parse.pm',
    	'lib/Write.pm'        => '$(INST_LIBDIR)/iTunes/Library/Write.pm',
    	'doc/file_format.pod' => '$(INST_LIBDIR)/iTunes/FileFormat.pm',
    	},
    	
	);
