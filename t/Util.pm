package t::Util;
use strict;
use base 'Exporter';
our @EXPORT_OK = qw(get_tmp_dir set_up tear_down);

use File::Copy;
use File::Copy::Recursive qw(dircopy);
use File::Remove qw(remove);
use File::Spec;

my $tmp_dir = File::Spec->tmpdir() . '/stay-deleted-tests';

sub get_tmp_dir {
    return $tmp_dir;
}

sub set_up {
    dircopy( 't/fixtures', $tmp_dir );
}

sub tear_down {
    remove( \1, $tmp_dir );
}

1;
