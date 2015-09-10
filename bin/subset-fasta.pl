#!/usr/bin/env perl
# subset-fasta.pl
# Mike Covington
# created: 2013-09-03
#
# Description:
#
use strict;
use warnings;
use autodie;
use v5.10;
use File::Basename;

my $usage = <<EOF;
USAGE: $0 SEQUENCE_FILE FASTA_FILE [CUSTOM_DELIMITER]
EOF

my $argv_count = scalar @ARGV;
die $usage unless $argv_count == 2 || $argv_count == 3;

my $gene_list = $ARGV[0];
my $fasta     = $ARGV[1];
my $delimiter = $ARGV[2] // '';
$delimiter = quotemeta($delimiter);

open my $gene_list_fh, "<", $gene_list;
my %genes = map { chomp; $_ => 1 } <$gene_list_fh>;
close $gene_list_fh;

my $fasta_basename = fileparse $fasta, qr/\.fa(sta)?/i;

open my $fa_fh,     "<", $fasta;
open my $fa_out_fh, ">", "$gene_list.$fasta_basename.fa";
my $hit = 0;
while (<$fa_fh>) {
    if (/^>([^\s$delimiter]+)/) {
        $hit = 0;
        $hit = 1 if exists $genes{$1};
    }
    print $fa_out_fh $_ if $hit == 1;
}
close $fa_fh;
close $fa_out_fh;

exit;
