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
	
	my $sd_directory = get_sd_directory($file_to_mark_for_deletion);
	my $sd_file = get_sd_file($file_to_mark_for_deletion);
	
	open SDF, ">$sd_file";
	print SDF basename($file_to_mark_for_deletion) . "\n";
	print SDF "delete\n";
	close SDF;
}

sub unmark_file_for_deletion
{
	my $file_to_unmark_for_deletion = shift;
	
}

sub delete_marked_files
{
	my $folder_to_search = shift;
}

# Private
sub get_sd_directory
{
	my $file_to_mark_for_deletion = shift;
	
	my $dir_name = dirname $file_to_mark_for_deletion;
	
	my $sd_directory = "$dir_name/.stay-deleted";
	
	mkdir $sd_directory unless -d $sd_directory;
	
	return $sd_directory;
}

sub get_sd_file
{
	my $file_to_mark_for_deletion = shift;
	my $sd_directory = get_sd_directory($file_to_mark_for_deletion);
	
	my $sd_file = $sd_directory . '/' . md5_hex(encode_utf8(basename($file_to_mark_for_deletion))) . '.txt';
	
	return $sd_file;
}

1;