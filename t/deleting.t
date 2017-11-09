#!perl

use strict;
use warnings;

use Test::More 'no_plan';

use lib::StayDeleted;
use t::Util qw(get_tmp_dir set_up tear_down);

my $tmp_dir = get_tmp_dir();

# Deleting Files
set_up();
StayDeleted::mark_file_for_deletion("$tmp_dir/a.txt");

StayDeleted::mark_file_for_deletion("$tmp_dir/b.txt");
StayDeleted::unmark_file_for_deletion("$tmp_dir/b.txt");

ok( -f "$tmp_dir/a.txt", 'a.txt should be there at this point.' );

ok( -f "$tmp_dir/b.txt", 'b.txt should be there at this point.' );

ok( -f "$tmp_dir/c.txt", 'c.txt should be there at this point.' );

StayDeleted::delete_marked_files("$tmp_dir");

ok( !( -f "$tmp_dir/a.txt" ), 'a.txt should have been deleted.' );

ok( -f "$tmp_dir/b.txt", 'b.txt should still be there.' );

ok( -f "$tmp_dir/c.txt", 'c.txt should still be there.' );

tear_down();

# Deleting directories
test_deleting_a_directory("$tmp_dir/a");

test_deleting_a_directory("$tmp_dir/A Directory with Spaces");

# Deleting files in directories.
test_deleting_a_file("$tmp_dir/a/foo.txt");

# Deleting files with spaces in the name
test_deleting_a_file("$tmp_dir/A File with Spaces in the Name.txt");

# Deleting files with non-ascii chars in the name.
test_deleting_a_file("$tmp_dir/한국어.txt");

# Deleting files in a directory with spaces in the name
test_deleting_a_file("$tmp_dir/A Directory with Spaces/Foo Bar.txt");

# Subs

sub test_deleting_a_file {
    my $file = shift;

    set_up();

    ok( -f $file, "'$file' should be there at this point." );

    StayDeleted::mark_file_for_deletion($file);
    StayDeleted::delete_marked_files($tmp_dir);

    ok( !( -f $file ), "'$file' should have been deleted." );

    tear_down();
}

sub test_deleting_a_directory {
    my $directory = shift;

    set_up();

    ok( -d $directory, "'$directory' should be there at this point." );

    StayDeleted::mark_file_for_deletion($directory);
    StayDeleted::delete_marked_files($tmp_dir);

    ok( !( -d $directory ), "'$directory' should have been deleted." );

    tear_down();
}

