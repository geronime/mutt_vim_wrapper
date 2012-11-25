#!/usr/bin/env perl
use strict;

# Remove signatures in the original mail of group/reply (mutt vim wrapper).
# Author:  2011 (C) Jiri Nemecek ( nemecek<dot>jiri<at>gmail<dot>com )
# License: You can re/distribute and/or modify any parts of the script
# and its modules under the same terms as Perl itself.

# To use this preprocessing filter script add a line to your muttrc:
#   set editor="~/bin/mutt_vim_wrapper.pl %s"
# Adjust the editor exec line on the bottom of this script to suit your needs.

open F, "+<$ARGV[0]" or die "$ARGV[0]: $!";
my $trunc = undef; # whether to truncate: default unknown (undefined)
my @m = (); # message lines
MAIN: while ( <F> ) {
	if ( 'Subject:' eq substr $_, 0, 8 ) {
		next if defined $trunc; # unlikely, but we already found subject
		$trunc = /^subject: ?re:/i ? 1 : 0;
	} elsif ( $trunc and /^(> [> ]*)-- ?$/ ) {
		# process signature only if to truncate:
		# - remember the citation depth
		# - count empty lines in signature
		# - remember previous line because some signatures do not end
		#   with two empty lines and on the same citation level could be
		#   the header of the previous citation
		my ( $citation_pfx, $prevline, $blank_ln ) = ( $1, undef, 0 );
		while ( <F> ) {
			redo MAIN unless /^$citation_pfx/; # upper citation level
			if ( /^$citation_pfx ?>/ ) {       # deeper citation level found
				push @m, $prevline; # add previous line - probably the citation header
				last;
			} elsif (                          # forwarded message
					/^$citation_pfx\s*--+\s+(?:F|End f)orwarded message\s+--+\s*$/ ) {
				last;
			} elsif ( /^$citation_pfx\s*$/ ) { # blank line, add to counter
				++$blank_ln;
			} else { # same citation level but not empty
				last if $blank_ln >= 2; # signature terminated with 2++ empty lines
				( $blank_ln, $prevline ) = ( 0, $_ );
			}
		}
	}
	push @m, $_ if defined $_;
}
truncate F, 0;
seek F, 0, 0;
if ( $trunc ) { # remove empty reply lines from the end
	pop @m while $m[$#m] =~ /^> [> ]*$/;
}
print F @m;
close F;

exec "$ENV{EDITOR}",
	'-c', 'set textwidth=0',
	'-c', 'set expandtab',
	'-c', 'set nolinebreak',
	'-c', 'set showbreak=""',
	'-c', 'set noai',
	"$ARGV[0]";

