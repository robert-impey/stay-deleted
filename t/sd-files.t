#!perl

use strict;
use warnings;

use Test::More 'no_plan';

use lib::StayDeleted;
use t::Util qw(get_tmp_dir set_up tear_down);

my $tmp_dir = get_tmp_dir();

set_up();

{
	my ( $file, $action ) = StayDeleted::read_sd_file("$tmp_dir/windows.txt");
	is( $file,   'foo.txt', 'Reading file names in files with Windows EOL.' );
	is( $action, 'delete',  'Reading actions in files with Windows EOL.' );
}

{
	my ( $file, $action ) = StayDeleted::read_sd_file("$tmp_dir/unix.txt");
	is( $file,   'bar.txt', 'Reading file names in files with UNIX EOL.' );
	is( $action, 'keep',    'Reading actions in files with UNIX EOL.' );
}

tear_down();
