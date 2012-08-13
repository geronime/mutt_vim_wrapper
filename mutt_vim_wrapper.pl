#!/usr/bin/env perl

# Truncate signature in the original mail of group/reply
# (wrapper script for mutt)

open F, "+<$ARGV[0]" or die "$ARGV[0]: $!";
$trunc = undef; # default unknown (undefined)
while ( <F> ) {
	if ( 'Subject:' eq substr $_, 0, 8 ) {
		next if defined $trunc; # we already found subject
		$trunc = /^subject: ?re:/i ? 1 : 0;
	} elsif ( $trunc and /^> ?-- ?$/ ) { # only if to truncate
		$blank_ln = 0; # count empty lines in signature
		$prevline = undef;
		  # store previous line because some signatures do not end
		  # with two empty lines:
		  # recognize with the next '> >' citation level
		  # and keep the previous line - header of the citation
		while ( <F> ) {
			if ( /^>\s*$/ ) {
				++$blank_ln;
			} elsif ( /^> >/ ) { # found previous message?
				push @m, $prevline;
				last;
			} elsif ( /^>/ ) {
				last if $blank_ln >= 2; # signature terminated with 2++ empty lines
				$blank_ln = 0;
			} else {
				last;
			}
			$prevline = $_;
		}
	}
	push @m, $_ if defined $_;
}
truncate F, 0;
seek F, 0, 0;
if ( $trunc ) { # remove empty reply lines from the end
	pop @m while $m[$#m] =~ /^>\s*$/;
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

