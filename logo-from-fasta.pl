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
use Statistics::R;

my $base_dir = "/Users/mfc/git.repos/extract-seq-flanking-read/runs/out";
# my $fasta_file = "$base_dir/A4_I1_5p14_sorted.10bp-upstream.fa";
# my $fasta_file = "$base_dir/A4_I1_5p14_sorted.100bp-upstream.fa";
# my $fasta_file = "$base_dir/phys_pifs.cdna.M82.hit.sorted.50bp-upstream.fa";
# my $fasta_file = "$base_dir/M82.Sh.veg.fa";
# my $fasta_file = "$base_dir/200.fa";
# my $fasta_file = "$base_dir/10000.fa";
# my $fasta_file = "$base_dir/subset.fa";
my $fasta_file = "$base_dir/subset.200.fa";

my $nt_freqs = get_nt_freqs($fasta_file);

sub get_nt_freqs {
    my $fasta_file = shift;
    my %nt_freqs;

    open my $fasta_fh, "<", $fasta_file;
    while (<$fasta_fh>) {
        next if /^>/;
        chomp;
        tr/acgtn/ACGTN/;
        my @seq = unpack "(A1)*";
        for my $i ( 0 .. $#seq ) {
            $nt_freqs{ $seq[$i] }{$i}++;
        }
    }
    close $fasta_fh;

    return \%nt_freqs;
}

p $nt_freqs;

my @r_cmd;
for my $nt (qw( A C G T )) {
    my @freqs
        = map { $$nt_freqs{$nt}{$_} } sort { $a <=> $b } keys $$nt_freqs{$nt};
    push @r_cmd, "$nt <- c(", join( ", ", @freqs), ")\n";
}
print @r_cmd;


my $build_pwm = <<EOF;
# Adapted from http://davetang.org/muse/2013/01/30/sequence-logos-with-r/

library(seqLogo)
@r_cmd
df <- data.frame(A,C,G,T)

#define function that divides the frequency by the row sum i.e. proportions
proportion <- function(x){
  rs <- sum(x);
  return(x / rs);
}

#create position weight matrix
pwm <- apply(df, 1, proportion)
pwm <- makePWM(pwm)
EOF

my ($base_name) = $fasta_file =~ m|([^/]+).fa(?:sta)?$|i;
my $filetype = "pdf";

my $write_logo = <<EOF;
$filetype("$base_name.$filetype")
seqLogo(pwm)
dev.off()
EOF

my $R = Statistics::R->new();
$R->run($build_pwm);
$R->run($write_logo);
$R->stop();
