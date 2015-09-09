#!/usr/bin/env perl
# Mike Covington
# created: 2014-04-24
#
# Description:
#
use strict;
use warnings;
use autodie;
use feature 'say';
use File::Basename;
use File::Path 'make_path';
use Getopt::Long;

use FindBin;
use lib "$FindBin::Bin";
use amino_acid_translation;

my ( $simple, $ss );

my $options = GetOptions(
    "simple" => \$simple,
    "ss"     => \$ss,
);

die "USAGE: $0 <DNA FASTA input file> <Protein FASTA output file>\n"
    unless scalar @ARGV == 2;

my ( $cds_fasta_file, $prot_fasta_file ) = @ARGV;
my $fa_width = 80;

my ( undef, $out_dir, undef ) = fileparse $prot_fasta_file;
make_path $out_dir;

open my $cds_fasta_fh,  "<", $cds_fasta_file;
open my $prot_fasta_fh, ">", $prot_fasta_file;

my $cds_seq;
while ( my $fa_line = <$cds_fasta_fh> ) {
    if ( $fa_line =~ /^>/ ) {
        if ($cds_seq) {
            say $prot_fasta_fh $_
                for unpack "(A$fa_width)*",
                $simple ? translate($cds_seq) : longest_orf( $cds_seq, $ss );
            $cds_seq = '';
        }
        print $prot_fasta_fh $fa_line;
    }
    else {
        chomp $fa_line;
        $cds_seq .= $fa_line;
    }
}
say $prot_fasta_fh $_
    for unpack "(A$fa_width)*",
    $simple ? translate($cds_seq) : longest_orf( $cds_seq, $ss );

close $cds_fasta_fh;
close $prot_fasta_fh;

exit;
