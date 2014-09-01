#!/usr/bin/env perl

use strict;
use warnings;

use Getopt::Long;
use Pod::Usage;

use StayDeleted qw(
  mark_file_for_deletion
  unmark_file_for_deletion
  delete_marked_files
);

my %opt = (
			mark   => 0,
			unmark => 0,
			delete => 0,
			verbose => 0,
			help   => 0,
			man    => 0
);

GetOptions(
			'mark=s'   => \$opt{mark},
			'unmark=s' => \$opt{unmark},
			'delete=s' => \$opt{delete},
			'verbose|v' => \$opt{verbose},
			'help|?'   => \$opt{help},
			'man'      => \$opt{man}
  )
  or pod2usage(2);

pod2usage(1) if $opt{help};
pod2usage( -exitstatus => 0, -verbose => 2 ) if $opt{man};

if ( $opt{mark} ) {
	mark_file_for_deletion( $opt{mark} );
} elsif ( $opt{unmark} ) {
	unmark_file_for_deletion( $opt{unmark} );
} elsif ( $opt{delete} ) {
	delete_marked_files( $opt{delete}, $opt{verbose});
} else {
	die "Tell me what to do!\n";
}

__END__

=head1 NAME

	stay-deleted.pl - For files that won't go away.

=head1 SYNOPSIS

	stay-deleted.pl
		Options:
			-mark [FILE|DIR]
			-unmark [FILE|DIR]
			-delete [DIR]
			-help brief help message
			-man full documentation

=head1 OPTIONS

=over 8

=item B<-mark [FILE|DIR]>

Mark a file or directory for deletion.

=item B<-unmark [FILE|DIR]>

Tell the program not to delete a file or directory that had
previously marked for deletion.

=item B<-delete [DIR]>

The program searches the given directory for stay-deleted files
and deletes the files and directories that have been marked.

=item B<-help>

Print a brief help message and exits.

=item B<-man>

Prints the manual page and exits.

=back

=head1 DESCRIPTION

This program is for marking files for deletion.
It is designed to work with folders that are synched
in both directions by rsync or similar tools.

=cut
