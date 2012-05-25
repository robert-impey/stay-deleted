package Util;
use strict;
use base 'Exporter';
our @EXPORT_OK = qw(set_up tear_down);

use File::Copy;

sub set_up
{
	mkdir 'temp';
	for (qw(a b c windows unix)) {
		copy("fixtures/$_.txt", "temp/$_.txt");
	}
}

sub tear_down
{
	system 'rm -rf temp';
}

1;