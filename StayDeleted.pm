package StayDeleted;
use strict;
use base 'Exporter';
our @EXPORT_OK = qw(
  mark_file_for_deletion
  unmark_file_for_deletion
  delete_marked_files
);

use File::Basename;
use File::Remove qw(remove);
use File::Find::Rule;
use File::Glob qw(bsd_glob);
use Cwd qw(abs_path getcwd);

use Digest::MD5 qw(md5_hex);
use Encode qw(encode_utf8);

sub mark_file_for_deletion {
	my $file_to_mark_for_deletion = shift;
	my $verbose                   = shift;

	print "Marking $file_to_mark_for_deletion for deletion\n" if $verbose;

	set_file_action( $file_to_mark_for_deletion, 'delete' );
}

sub unmark_file_for_deletion {
	my $file_to_unmark_for_deletion = shift;

	set_file_action( $file_to_unmark_for_deletion, 'keep' );
}

sub delete_marked_files {
	my $folder_to_search = shift;
	my $verbose          = shift;

	print "Deleting marked files from '$folder_to_search'\n" if $verbose;

	if ( -d $folder_to_search ) {
		my $start_dir = &getcwd;

		foreach ( File::Find::Rule->directory->in($folder_to_search) ) {
			my $current_dir = $_;
			if ( -d $current_dir ) {
				chdir $current_dir or die $!;

				my $sd_directory = get_sd_directory($current_dir);

				if ( -d $sd_directory ) {
					for ( bsd_glob("$sd_directory/*.txt") ) {
						my ( $file_for_action, $action ) = read_sd_file($_);

						if ( $action eq 'delete' ) {
							if ( -f $file_for_action ) {
								unlink($file_for_action);
							}
							elsif ( -d $file_for_action ) {
								remove( \1, $file_for_action );
							}
							elsif ($verbose) {
								print
"$file_for_action is not a file or a directory!\n";
							}
						}
					}
				}
			}
		}

		chdir $start_dir;
	}
	else {
		die "$folder_to_search does not exist!\n";
	}
}

# Private
sub get_sd_directory {
	my $dirname = shift;

	my $sd_directory = "$dirname/.stay-deleted";

	return $sd_directory;
}

sub get_sd_file {
	my $file_to_mark_for_action = shift;

	my $sd_file =
	  md5_hex( encode_utf8( basename($file_to_mark_for_action) ) ) . '.txt';

	return $sd_file;
}

sub set_file_action {
	my $file_to_set_for_action = shift;
	my $action                 = shift;

	my $dirname  = dirname $file_to_set_for_action;
	my $basename = basename $file_to_set_for_action;

	my $sd_directory = get_sd_directory($dirname);
	my $sd_file      = get_sd_file($basename);

	mkdir $sd_directory unless -d $sd_directory;

	open SDF, ">$sd_directory/$sd_file";
	print SDF "$basename\n";
	print SDF "$action\n";
	close SDF;
}

sub read_sd_file {
	my $sd_file = shift;

	open SDF, "<$sd_file" or die "Cannot open $sd_file!: $!";
	my @lines = <SDF>;
	close SDF;

	my $file_for_action = $lines[0];
	$file_for_action = ltrim($file_for_action);

	my $action = $lines[1];
	$action = ltrim($action);

	return ( $file_for_action, $action );
}

sub ltrim {
	my $str = shift;
	$str =~ s/\s*$//;
	return $str;
}

1;
