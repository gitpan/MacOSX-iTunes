# $Id: ok.pl,v 1.1.1.1 2002/06/14 06:20:06 comdog Exp $

=head1 NAME

ok.pl - common functions for tests

=head1 SYNOPSIS

require ok.pl;

print ok();
print not_ok();

=head1 DESCRIPTION

I want some common functions in all of my Test::Harness scripts,
so here they are. :)

=head1 METHODS

=over 4

=item not_ok

Returns the string 'not ok' and print the value of $@ to STDERR

=cut

sub not_ok
	{
	warn $@;
	
	'not ok';
	}
	
=item ok

Returns the string 'ok'

=cut

sub ok { 'ok' }

=head1 AUTHOR

brian d foy <bdfoy@cpan.org>

=cut

1;
