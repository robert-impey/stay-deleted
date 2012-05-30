#!perl

use strict;
use warnings;

use Test::More 'no_plan';

require "../StayDeleted.pm";
use Util qw(set_up tear_down);

set_up();
StayDeleted::mark_file_for_deletion('temp/a.txt');

StayDeleted::mark_file_for_deletion('temp/b.txt');
StayDeleted::unmark_file_for_deletion('temp/b.txt');

ok(-f 'temp/a.txt', 'a.txt should be there at this point.');
ok(-f 'temp/b.txt', 'b.txt should be there at this point.');
ok(-f 'temp/c.txt', 'c.txt should be there at this point.');

StayDeleted::delete_marked_files('temp');

ok(!(-f 'temp/a.txt'), 'a.txt should have been deleted.');
ok(-f 'temp/b.txt', 'b.txt should still be there.');
ok(-f 'temp/c.txt', 'c.txt should still be there.');

ok(-d 'temp/a', 'Directory "a" should be present before being deleted.');
StayDeleted::mark_file_for_deletion('temp/a');
StayDeleted::delete_marked_files('temp');
ok(!(-d 'temp/a'), 'Directory "a" should have been deleted.');

tear_down();
