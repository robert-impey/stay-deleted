#!perl

use strict;
use warnings;

use Test::More 'no_plan';

use StayDeleted;
use Util qw(set_up tear_down);

# Deleting Files
set_up();
StayDeleted::mark_file_for_deletion('t/temp/a.txt');

StayDeleted::mark_file_for_deletion('t/temp/b.txt');
StayDeleted::unmark_file_for_deletion('t/temp/b.txt');

ok( -f 't/temp/a.txt', 'a.txt should be there at this point.' );

ok( -f 't/temp/b.txt', 'b.txt should be there at this point.' );

ok( -f 't/temp/c.txt', 'c.txt should be there at this point.' );

StayDeleted::delete_marked_files('t/temp');

ok( !( -f 't/temp/a.txt' ), 'a.txt should have been deleted.' );

ok( -f 't/temp/b.txt', 'b.txt should still be there.' );

ok( -f 't/temp/c.txt', 'c.txt should still be there.' );

tear_down();

# Deleting directories
test_deleting_a_directory('t/temp/a');

test_deleting_a_directory('t/temp/A Directory with Spaces');

# Deleting files in directories.
test_deleting_a_file('t/temp/a/foo.txt');

# Deleting files with spaces in the name
test_deleting_a_file('t/temp/A File with Spaces in the Name.txt');

# Deleting files with non-ascii chars in the name.
TODO: {
	local $TODO =
'Issues with git and perl with these chars on Mac OSX, Linux and Windows.';
	test_deleting_a_file('t/temp/한국어.txt');
}

# Deleting files in a directory with spaces in the name
test_deleting_a_file('t/temp/A Directory with Spaces/Foo Bar.txt');

# Subs

sub test_deleting_a_file {
	my $file = shift;

	set_up();

	ok( -f $file, "'$file' should be there at this point." );

	StayDeleted::mark_file_for_deletion($file);
	StayDeleted::delete_marked_files('t/temp');

	ok( !( -f $file ), "'$file' should have been deleted." );

	tear_down();
}

sub test_deleting_a_directory {
	my $directory = shift;

	set_up();

	ok( -d $directory, "'$directory' should be there at this point." );

	StayDeleted::mark_file_for_deletion($directory);
	StayDeleted::delete_marked_files('t/temp');

	ok( !( -d $directory ), "'$directory' should have been deleted." );

	tear_down();
}
