package StayDeleted;
use strict;
use base 'Exporter';
our @EXPORT_OK = qw(
	mark_file_for_deletion
	unmark_file_for_deletion
	delete_marked_files
);

use File::Basename;
use Digest::MD5 qw(md5_hex);
use Encode qw(encode_utf8);
	
sub mark_file_for_deletion
{
	my $file_to_mark_for_deletion = shift;
	
	set_file_action($file_to_mark_for_deletion, 'delete');
}

sub unmark_file_for_deletion
{
	my $file_to_unmark_for_deletion = shift;
	
	set_file_action($file_to_unmark_for_deletion, 'keep');
}

sub delete_marked_files
{
	my $folder_to_search = shift;
	
	my $sd_directory = get_sd_directory($folder_to_search);
	
	for (glob("$sd_directory/*.txt")) {
		open SDF, "<$_";
		my @lines = <SDF>;
		close SDF;
		
		my $file_for_action = $lines[0];
		chomp $file_for_action;
		$file_for_action = "$folder_to_search/$file_for_action";
		my $action = $lines[1];
		chomp $action;
		
		if ($action eq 'delete') {
			if (-f $file_for_action) {
				unlink($file_for_action);
			}
		}
	}
}

# Private
sub get_sd_directory
{
	my $dirname = shift;
	
	my $sd_directory = "$dirname/.stay-deleted";
	
	mkdir $sd_directory unless -d $sd_directory;
	
	return $sd_directory;
}

sub get_sd_file
{
	my $file_to_mark_for_action = shift;
	
	my $sd_file = md5_hex(encode_utf8(basename($file_to_mark_for_action))) . '.txt';
	
	return $sd_file;
}

sub set_file_action
{
	my $file_to_set_for_action = shift;
	my $action = shift;
	
	my $dirname = dirname $file_to_set_for_action;
	my $basename = basename $file_to_set_for_action;
	
	my $sd_directory = get_sd_directory($dirname);
	my $sd_file = get_sd_file($basename);
	
	open SDF, ">$sd_directory/$sd_file";
	print SDF "$basename\n";
	print SDF "$action\n";
	close SDF;
}

1;