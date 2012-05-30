#!perl

use strict;
use warnings;

use Test::More 'no_plan';

require "../StayDeleted.pm";
use Util qw(set_up tear_down);

set_up();
StayDeleted::mark_file_for_deletion('temp/a.txt');
ok(-d 'temp/.stay-deleted', 'Directory for stay-deleted.pl should be created.');
ok(-f 'temp/.stay-deleted/a5e54d1fd7bb69a228ef0dcd2431367e.txt', 'File marking a.txt for deletion should have been created.');

{
	my ($file_name, $action) = read_sd_file('a5e54d1fd7bb69a228ef0dcd2431367e');
	
	is($file_name, 'a.txt', 'The first line should be the file name.');
	is($action, 'delete', 'The second line should say to delete the file.');
}

StayDeleted::unmark_file_for_deletion('temp/a.txt');

{
	my ($file_name, $action) = read_sd_file('a5e54d1fd7bb69a228ef0dcd2431367e');
	
	is($file_name, 'a.txt', 'The first line should be the file name.');
	is($action, 'keep', 'The second line should say to keep the file.');
}

StayDeleted::mark_file_for_deletion('temp/한국어.txt');
ok(-f 'temp/.stay-deleted/40594a16245875754a6e62790f9872e0.txt', 'File marking 한국어.txt for deletion should have been created.');

{
	my ($file_name, $action) = read_sd_file('40594a16245875754a6e62790f9872e0');
	
	is($file_name, '한국어.txt', 'The first line should be the file name.');
	is($action, 'delete', 'The second line should say to keep the file.');
}

tear_down();

# Subs
sub read_sd_file
{
	my $md5 = shift;
	
	open TXT, "<temp/.stay-deleted/$md5.txt";
	my @lines = <TXT>;
	close TXT;
	
	my $file_name = $lines[0];
	chomp $file_name;
	
	my $action = $lines[1];
	chomp $action;
	
	return ($file_name, $action);
}
