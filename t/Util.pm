package Util;
use strict;
use base 'Exporter';
our @EXPORT_OK = qw(set_up tear_down);

use File::Copy;
use File::Copy::Recursive qw(dircopy);
use File::Remove qw(remove);

sub set_up
{
	mkdir 'temp';
	for (qw(a b c windows unix)) {
		copy("fixtures/$_.txt", "temp/$_.txt");
	}
	
	dircopy('fixtures/a', 'temp/a');
}

sub tear_down
{
	remove(\1, 'temp');
}

1;