#!perl

use strict;
use warnings;

use Test::More 'no_plan';

require "../StayDeleted.pm";
use Util qw(set_up tear_down);

# Deleting Files
set_up();
StayDeleted::mark_file_for_deletion('temp/a.txt');

StayDeleted::mark_file_for_deletion('temp/b.txt');
StayDeleted::unmark_file_for_deletion('temp/b.txt');

ok( -f 'temp/a.txt', 'a.txt should be there at this point.' );

ok( -f 'temp/b.txt', 'b.txt should be there at this point.' );

ok( -f 'temp/c.txt', 'c.txt should be there at this point.' );

StayDeleted::delete_marked_files('temp');

ok( !( -f 'temp/a.txt' ), 'a.txt should have been deleted.' );

ok( -f 'temp/b.txt', 'b.txt should still be there.' );

ok( -f 'temp/c.txt', 'c.txt should still be there.' );

tear_down();

# Deleting directories
test_deleting_a_directory('temp/a');

test_deleting_a_directory('temp/A Directory with Spaces');

# Deleting files in directories.
test_deleting_a_file('temp/a/foo.txt');

# Deleting files with spaces in the name
test_deleting_a_file('temp/A File with Spaces in the Name.txt');

# Deleting files with non-ascii chars in the name.
TODO: {
	local $TODO =
'Issues with git and perl with these chars on Mac OSX, Linux and Windows.';
	test_deleting_a_file('temp/한국어.txt');
}

# Deleting files in a directory with spaces in the name
test_deleting_a_file('temp/A Directory with Spaces/Foo Bar.txt');

# Subs

sub test_deleting_a_file {
	my $file = shift;

	set_up();

	ok( -f $file, "'$file' should be there at this point." );

	StayDeleted::mark_file_for_deletion($file);
	StayDeleted::delete_marked_files('temp');

	ok( !( -f $file ), "'$file' should have been deleted." );

	tear_down();
}

sub test_deleting_a_directory {
	my $directory = shift;

	set_up();

	ok( -d $directory, "'$directory' should be there at this point." );

	StayDeleted::mark_file_for_deletion($directory);
	StayDeleted::delete_marked_files('temp');

	ok( !( -d $directory ), "'$directory' should have been deleted." );

	tear_down();
}
