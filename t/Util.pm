package Util;
use strict;
use base 'Exporter';
our @EXPORT_OK = qw(set_up tear_down);

use File::Copy;

sub set_up
{
	mkdir 'temp';
	copy("fixtures/a.txt", "temp/a.txt");
}

sub tear_down
{
	chdir "temp";
	foreach (glob ("* .*")) {
		system "rm -rf $_" unless ($_ eq '.' or $_ eq '..');
	}
	chdir "..";
	rmdir 'temp';
}

1;