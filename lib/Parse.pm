# $Id: Parse.pm,v 1.2 2002/07/17 06:55:24 comdog Exp $
package MacOSX::iTunes::Library::Parse;
use strict;

use vars qw($Debug $Ate %hohm_types);

use MacOSX::iTunes;
use MacOSX::iTunes::Item;
use MacOSX::iTunes::Playlist;

$Debug = 0;
$Ate   = 0;

my %Dispatch = (
	hdfm => \&hd,   # header record
	hdsm => \&hd,   # header/footer start record
	htlm => \&htlm, # playlist meta data
	htim => \&htim, # a song record
	hohm => \&hohm, # general record type
	hplm => \&hplm, # footer ??? record
	hpim => \&hpim, # start of playlist
	hptm => \&hptm, # song in playlist
	);
	
sub parse
	{
	my $class = shift;
	my $fh    = shift;
		
	my $data = do { local $/; <$fh> };
	
	my %songs     = ();
	
	my $itunes = MacOSX::iTunes->new();
	
	while( $data )
		{
		$data =~ m/^(....)/;
		
		print STDERR "Marker is $1\n" if $Debug;
		
		my $marker = $1;
		
		my @result = $Dispatch{$marker}->( \$data );
		
		if( $marker eq 'htim' )
			{
			$songs{ $result[1] } = $result[0];
			}
		elsif( $marker eq 'hpim' )
			{
			my $playlist = shift @result;
			
			$itunes->add_playlist( $playlist );
			
			foreach my $song ( @result )
				{
				warn "Could not add item! [$song]" 
					unless $playlist->add_item( $songs{$song} );
				}
			}
		}
		
	require Data::Dumper;
	
	print STDERR Data::Dumper::Dumper( $itunes ), "\n" if $Debug;
	
	$itunes;	
	}
	
sub hd
	{
	my $ref = shift;
	local $Ate = 0;
	
	eat( $ref, 4 );
	
	my( $length ) = unpack( "I", ${eat( $ref, 4 )} );
		
	print STDERR "\tlength is $length\n" if $Debug;
	
	eat( $ref, $length - $Ate );
	}

=item htlm( DATA )

The htlm record holds the number of lists.  When we run into
this record, remember the right number of playlists.

=cut
	
sub htlm
	{
	my $ref   = shift;
	local $Ate = 0;

	eat( $ref, 4 );
	
	my( $length ) = unpack( "I", ${eat( $ref, 4 )} );
	
	my( $songs ) = unpack( "I", ${eat( $ref, 4 )} );
	
	print STDERR "\tlength is $length\n" if $Debug;
	print STDERR "\tsongs is $songs\n" if $Debug;
	
	eat( $ref, $length - $Ate );	
		
	return $songs;
	}

=item htim

The htim record starts the Item object

=cut

sub htim
	{
	my $ref   = shift;

	local $Ate = 0;

	eat( $ref, 4 );
	
	my( $header_length ) = unpack( "I", ${eat( $ref, 4 )} );
	my( $record_length ) = unpack( "I", ${eat( $ref, 4 )} );
			
	my( $hohms )  = unpack( "I", ${eat( $ref, 4 )} );
	
	my( $id )     = unpack( "I", ${eat( $ref, 4 )} );
	my( $type )   = unpack( "I", ${eat( $ref, 4 )} );
	eat( $ref, 4 * 3);

	my( $bytes )  = unpack( "I", ${eat( $ref, 4 )} );
	my( $time  )  = unpack( "I", ${eat( $ref, 4 )} );

	my( $track )  = unpack( "I", ${eat( $ref, 4 )} );
	my( $tracks ) = unpack( "I", ${eat( $ref, 4 )} );
	
	print  STDERR "\theader length is $header_length\n" if $Debug;
	print  STDERR "\trecord length is $record_length\n" if $Debug;
	print  STDERR "\thohms is $hohms\n" if $Debug;
	printf STDERR "\tid is %x\n", $id if $Debug;
	print  STDERR "\tbytes is $bytes\n" if $Debug;
	print  STDERR "\ttrack is $track of $tracks\n" if $Debug;
		
	eat( $ref, $header_length - $Ate );
		
	my %hash;
	my %songs;
	foreach my $index ( 1 .. $hohms )
		{		
		my $hohm = $Dispatch{'hohm'}->( $ref );
		
		foreach my $key ( keys %$hohm )
			{
			$hash{$key} = $hohm->{$key};
			}
		}
				
	my $item = MacOSX::iTunes::Item->new(
		{
		title     => $hash{title},
		genre     => $hash{genre},
		seconds   => $time,
		filesize  => $bytes,
		file      => $hash{filename},
		artist    => $hash{artist},
		album     => $hash{album},
		file_type => $hash{"file type"},
		creator   => $hash{creator},
		volume    => $hash{volume},
		directory => $hash{directory},
		path      => $hash{path},
		track     => $track,
		tracks    => $tracks,
		}
		);
	
	my $key = make_song_key( $id );
				
	return ($item, $key);
	}

BEGIN {
%hohm_types = (
	1 => 'goobledgook',
	2 => 'title',
	3 => 'album',
	4 => 'artist',
	5 => 'genre',
	6 => 'file type',
	100 => 'playlist',
	);
}
	
sub hohm
	{
	my $ref = shift;
	local $Ate = 0;
	
	eat( $ref, 4 );
	eat( $ref, 4 );

	my( $length ) = unpack( "I", ${eat( $ref, 4 )} );
	my( $type )   = unpack( "I", ${eat( $ref, 4 )} );

	print STDERR "\tlength is $length\n" if $Debug;
	print STDERR "\ttype is [$type]" if $Debug;
		
	print STDERR " => $hohm_types{$type}" 
		if( $Debug and exists $hohm_types{$type} );
	
	print STDERR "\n"  if $Debug;

	my %hohm = ( type => $type );
	
	my( $dl, $data );
	if( $type != 100 and $type != 1)
		{
		eat( $ref, 4 ) for 1 .. 3;
	
		($dl)  = unpack( "I", ${eat( $ref, 4 )} );
	
		eat( $ref, 4 ) for 1 .. 2;
	
		($data) = unpack( 'A*', ${eat( $ref, $dl )} );
		
		$hohm{ $hohm_types{$type} } = $data;
		}
	elsif( $type == 1 )
		{		
		eat( $ref, 4 ) for 1 .. 3;
		
		eat( $ref, 2 );
		
		my ($next_len) = unpack( 'S', ${eat( $ref, 2 )} );
		print STDERR "\tnext length is $next_len\n" if $Debug;

		eat( $ref, $next_len );

		($next_len) = unpack( 'S', "\000" . ${eat( $ref, 1 )} );
		print STDERR "\tvolume length is $next_len\n" if $Debug;
		
		my ($volume) = unpack( 'A*', ${eat( $ref, $next_len )} );
		print STDERR "\tVolume is [$volume]\n" if $Debug;
		$hohm{volume} = $volume;
		eat( $ref, 6*4 );
		
		($next_len) = unpack( 'S', "\000" . ${eat( $ref, 1 )} );
		print STDERR "\tfilename length is $next_len\n" if $Debug;

		my ($filename) = unpack( 'A*', ${eat( $ref, $next_len )} );
		print STDERR "\tfilename is [$filename]\n" if $Debug;
		$hohm{filename} = $filename;
		eat( $ref, 71 -  $next_len);
	
		my ($filetype) = unpack( 'A*', ${eat( $ref, 4 )} );
		print STDERR "\tfiletype is [$filetype]\n" if $Debug;
		$hohm{filetype} = $filetype;

		my ($creator)  = unpack( 'A*', ${eat( $ref, 4 )} );
		print STDERR "\tcreator is [$creator]\n" if $Debug;
		$hohm{creator} = $creator;

		eat( $ref, 5 * 4);

		($next_len) = unpack( 'I', ${eat( $ref, 4 )} );

		my ($directory) = unpack( 'A*', ${eat( $ref, $next_len )} );
		print STDERR "\tdirectory is [$directory]\n" if $Debug;
		$hohm{directory} = $directory;

		while( 1 )
			{
			my( $next ) = unpack( 'A', ${eat( $ref, 1 )} );
			next unless $next eq "\x5a";

			$next  = unpack( 'C', ${eat( $ref, 1 )} );
			$next .= unpack( 'C', ${eat( $ref, 1 )} );

			die unless $next eq '02';
						
			last;
			}
			
		($next_len) = unpack( 'S', ${eat( $ref, 2 )} );

		my ($path) = unpack( 'A*', ${eat( $ref, $next_len )} );
		print STDERR "\tpath is [$path]\n" if $Debug;
		$hohm{path} = $path;

		eat( $ref, $length - $Ate );
		}
	else
		{		
		eat( $ref, 3*4 );
		
		my ($next_len) = unpack( 'I', ${eat( $ref, 4 )} );

		eat( $ref, 2*4 );
		
		my ($playlist) = unpack( 'A*', ${eat( $ref, $next_len )} );
		print STDERR "\tplaylist is [$playlist]\n" if $Debug;
		$hohm{playlist} = $playlist;
	
		eat( $ref, $length - $Ate );
		}
		
	print STDERR "\tdata length is $dl\n\tdata is [$data]\n" 
		unless( not $Debug or $type == 1 or $type == 100);
	#eat( $ref, $length - 4 - 4 - 4 - 4 -12 -4);
	
	return \%hohm;
	}

sub hplm
	{
	my $ref   = shift;

	local $Ate = 0;

	eat( $ref, 4 );

	my( $length ) = unpack( "I", ${eat( $ref, 4 )} );
	my( $lists  ) = unpack( "I", ${eat( $ref, 4 )} );

	print STDERR "\tlength is $length\n" if $Debug;
	print STDERR "\tlists is $lists\n" if $Debug;

	eat( $ref, $length - $Ate );
		
	return $lists;
	}

sub hpim
	{
	my $ref   = shift;

	local $Ate = 0;
	
	eat( $ref, 4 );

	my( $length ) = unpack( "I", ${eat( $ref, 4 )} );

	print STDERR "\tlength is $length\n" if $Debug;

	my( $foo ) = unpack( "I", ${eat( $ref, 4 )} );
	my( $bar ) = unpack( "I", ${eat( $ref, 4 )} );
	
	my( $songs ) = unpack( "I", ${eat( $ref, 4 )} );

	print STDERR "\tsongs in playlist is $songs\n" if $Debug;
	
	eat( $ref, $length - $Ate );
	
	my $result = $Dispatch{'hohm'}->( $ref );
	
	my $playlist = MacOSX::iTunes::Playlist->new( $result->{playlist} );
	
	my @songs = ();
	foreach my $index ( 1 .. $songs )
		{
		my $song = $Dispatch{'hptm'}->( $ref );
		
		print STDERR "\tKey is $song\n" if $Debug;
		
		push @songs, $song;
		}
	
	return ( $playlist, @songs );	
	}
	
sub hptm
	{
	my $ref = shift;
	local $Ate = 0;
		
	eat( $ref, 4 );

	my( $length ) = unpack( "I", ${eat( $ref, 4 )} );
	eat( $ref, 4 );

	eat( $ref, 4*3 );

	my( $song ) = make_song_key( unpack( "I", ${eat( $ref, 4 )} ) );

	print STDERR "\tlength is $length\n" if $Debug;
	
	eat( $ref, $length - $Ate );
	
	return $song;
	}

sub make_song_key
	{
	sprintf "%08x", $_[0];
	}
		
sub peek
	{
	my $ref = shift;
	
	my $data = substr( $$ref, 0, 1 );
	
	sprintf "%x", unpack( "S", "\000" . $data );
	}
	
sub eat
	{
	my $ref = shift;
	my $l   = shift;
	$Ate += $l;
	
	my $data = substr( $$ref, 0, $l );
	
	substr( $$ref, 0, $l ) = '';
	
	\$data;
	}

"See why 1984 won't be like 1984";

=back

=head1 SEE ALSO

L<MacOSX::iTunes>, L<MacOSX::iTunes::Item>

=head1 TO DO

* everything - the list of things already done is much shorter.

=head1 BUGS

=head1 AUTHOR

Copyright 2002, brian d foy <bdfoy@cpan.org>

You may redistribute this under the same terms as Perl.

=cut
