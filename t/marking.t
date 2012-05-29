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
	my ($file_name, $action) = read_a_file();
	
	is($file_name, 'a.txt', 'The first line should be the file name.');
	is($action, 'delete', 'The second line should say to delete the file.');
}

StayDeleted::unmark_file_for_deletion('temp/a.txt');

{
	my ($file_name, $action) = read_a_file();
	
	is($file_name, 'a.txt', 'The first line should be the file name.');
	is($action, 'keep', 'The second line should say to keep the file.');
}

tear_down();

# Subs
sub read_a_file
{
	open ATXT, '<temp/.stay-deleted/a5e54d1fd7bb69a228ef0dcd2431367e.txt';
	my @lines = <ATXT>;
	close ATXT;
	
	my $file_name = $lines[0];
	chomp $file_name;
	
	my $action = $lines[1];
	chomp $action;
	
	return ($file_name, $action);
}
