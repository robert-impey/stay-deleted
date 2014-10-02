#!perl

use strict;
use warnings;

use Test::More 'no_plan';

use StayDeleted;
use Util qw(set_up tear_down);

set_up();

{
	my ( $file, $action ) = StayDeleted::read_sd_file('t/temp/windows.txt');
	is( $file,   'foo.txt', 'Reading file names in files with Windows EOL.' );
	is( $action, 'delete',  'Reading actions in files with Windows EOL.' );
}

{
	my ( $file, $action ) = StayDeleted::read_sd_file('t/temp/unix.txt');
	is( $file,   'bar.txt', 'Reading file names in files with UNIX EOL.' );
	is( $action, 'keep',    'Reading actions in files with UNIX EOL.' );
}

tear_down();
