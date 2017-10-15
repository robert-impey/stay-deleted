#!perl

use strict;
use warnings;

use Test::More 'no_plan';

use lib::StayDeleted;
use t::Util qw(get_tmp_dir set_up tear_down);

my $tmp_dir = get_tmp_dir();

test_file_marking( 'a.txt', 'a5e54d1fd7bb69a228ef0dcd2431367e' );
test_file_marking( '한국어.txt', '40594a16245875754a6e62790f9872e0' );

# Subs

sub test_file_marking {
	set_up();

	my $marked_file    = shift;
	my $file_name_hash = shift;

	StayDeleted::mark_file_for_deletion("$tmp_dir/$marked_file");
	my $sd_dir = "$tmp_dir/.stay-deleted";
	ok( -d $sd_dir, 'Directory for stay-deleted.pl should be created.' );

	my $sd_file = "$sd_dir/$file_name_hash.txt";

	ok( -f $sd_file,
		"File marking $marked_file for deletion should have been created." );

	my ( $file_name, $action ) = StayDeleted::read_sd_file($sd_file);

	is( $file_name, $marked_file, "The first line should be the file name, $marked_file" );

	is( $action, 'delete', 'The second line should say to delete the file.' );

	StayDeleted::unmark_file_for_deletion("$tmp_dir/$marked_file");

	( $file_name, $action ) = StayDeleted::read_sd_file($sd_file);

	is( $file_name, $marked_file, "The first line should be the file name, $marked_file" );

	is( $action, 'keep', 'The second line should say to keep the file.' );

	tear_down();
}

