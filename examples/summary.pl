#!/usr/bin/perl -w
# $Id: summary.pl,v 1.2 2002/07/17 07:14:56 comdog Exp $
use strict;

=head1 NAME

example/summary.pl

=head1 SYNOPSIS

perl summary.pl /path/to/itunes/music/library

perl summary.pl ../mp3/"iTunes Music Library"

=head1 DESCRIPTION

This script is a short example of the MacOSX::iTunes module.
It pretty-prints a summary of your iTunes library.

=cut

use MacOSX::iTunes;

my $file = $ARGV[0];
die "file [$file] does not exist\n" unless -e $file;

my $itunes = MacOSX::iTunes->read( $file );
die unless ref $itunes;

my @playlists = $itunes->playlists;

foreach my $title ( @playlists )
	{
	print "\t$title\n";
	my $playlist = $itunes->get_playlist( $title );
	
	foreach my $item ( $playlist->items )
		{
		my $title  = $item->title;
		my $artist = $item->artist;
		
		print "\t\t$title, $artist\n";
		}
	}

=head1 SEE ALSO

L<MacOSX::iTunes>

=head1 AUTHOR

Copyright 2002, brian d foy <bdfoy@cpan.org>

You may redistribute this under the same terms as Perl.

=cut
