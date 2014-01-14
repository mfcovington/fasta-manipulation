#!/usr/bin/env perl
# Mike Covington
# created: 2014-01-12
#
# Description:
#
use strict;
use warnings;
use autodie;
use feature 'say';
use Data::Printer;

my $base_dir = "/Users/mfc/git.repos/extract-seq-flanking-read/runs/out";
# my $fasta_file = "$base_dir/A4_I1_5p14_sorted.10bp-upstream.fa";
# my $fasta_file = "$base_dir/A4_I1_5p14_sorted.100bp-upstream.fa";
# my $fasta_file = "$base_dir/phys_pifs.cdna.M82.hit.sorted.50bp-upstream.fa";
# my $fasta_file = "$base_dir/M82.Sh.veg.fa";
# my $fasta_file = "$base_dir/200.fa";
# my $fasta_file = "$base_dir/10000.fa";
# my $fasta_file = "$base_dir/subset.fa";
my $fasta_file = "$base_dir/subset.200.fa";

my %nt_freqs;

open my $fasta_fh, "<", $fasta_file;
while (<$fasta_fh>) {
    next if /^>/;
    chomp;
    tr/acgtn/ACGTN/;
    my @seq = unpack "(A1)*";
    for my $i ( 0 .. $#seq ) {
        $nt_freqs{$i}{ $seq[$i] }++;
    }
}
close $fasta_fh;

p %nt_freqs;

my @nts = qw(A C G T);
my %out;
for my $i ( sort { $a <=> $b } keys %nt_freqs ) {
    # say $nt_freqs{$i};

    # my $total =+

    push @{$out{$_}}, $nt_freqs{$i}{$_} for @nts;

}

my @r_cmd;
push @r_cmd, "$_ <- c(", join( ", ", @{$out{$_}}), ")\n" for keys %out;
print @r_cmd;

# say "$_ <- c(", join( ", ", @{$out{$_}}), ")" for keys %out;


