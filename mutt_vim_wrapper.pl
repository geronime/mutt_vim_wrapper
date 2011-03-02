#!/usr/bin/env perl

# Truncate signature in the original mail of group/reply

open F, "+<$ARGV[0]" or die "$ARGV[0]: $!";
$trunc = undef; # default unknown (undefined)
while ( <F> ) {
	if ( 'Subject:' eq substr $_, 0, 8 ) {
		next if defined $trunc; # we already found subject
		$trunc = /^subject: ?re:/i ? 1 : 0;
	} elsif ( $trunc and /^> ?-- ?$/ ) { # only if to truncate
		while ( <F> ) { next if /^>/; }
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

