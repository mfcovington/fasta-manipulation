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
use Statistics::R;
use Getopt::Long;

#TODO: Fill in missing values with 0
#TODO: Verify that all sequences are equal length

my $base_dir = "/Users/mfc/git.repos/extract-seq-flanking-read/runs/out";
my $fasta_file = "$base_dir/subset.200.fa";

my ( $plot_only, $summary_only, $freq_scale, $no_xaxis, $width, $height );
my ($base_name) = $fasta_file =~ m|([^/]+).fa(?:sta)?$|i;
my $filetype = "pdf";

my $options = GetOptions(
    "fasta_file=s" => \$fasta_file,
    "filetype=s"   => \$filetype,
    "plot_only"    => \$plot_only,
    "summary_only" => \$summary_only,
    "freq_scale"   => \$freq_scale,
    "no_xaxis"     => \$no_xaxis,
    "width=f"      => \$width,
    "height=f"     => \$height,
);

my $nt_freqs   = get_nt_freqs($fasta_file);
my $nt_vectors = build_nt_vectors($nt_freqs);
seqlogo( $nt_vectors, $base_name, $filetype );

exit;

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

sub build_nt_vectors {
    my @nt_vectors;
    for my $nt (qw( A C G T )) {
        my @freqs
            = map { $$nt_freqs{$nt}{$_} } sort { $a <=> $b } keys $$nt_freqs{$nt};
        push @nt_vectors, "$nt <- c(", join( ", ", @freqs), ")\n";
    }
    return \@nt_vectors;
}

sub seqlogo {
    my ( $nt_vectors, $base_name, $filetype ) = @_;

    my $build_pwm = <<EOF;
# Adapted from http://davetang.org/muse/2013/01/30/sequence-logos-with-r/

library(seqLogo)
@$nt_vectors
df <- data.frame(A,C,G,T)

#define function that divides the frequency by the row sum i.e. proportions
proportion <- function(x){
  rs <- sum(x);
  return(x / rs);
}

#create position weight matrix
props <- apply(df, 1, proportion)
pwm <- makePWM(props)
EOF

    my $write_summary = <<EOF;
colnames(props) <- -ncol(props):-1
write.table(props, "$base_name.txt", quote = F, sep = "\t", col.names=NA)
EOF

    my $out_params = "";
    $out_params .= "width = $width, "   if $width;
    $out_params .= "height = $height, " if $height;

    my $seqlogo_params = "";
    $seqlogo_params .= "ic.scale = FALSE, " if $freq_scale;
    $seqlogo_params .= "xaxis = FALSE, "    if $no_xaxis;

    my $write_logo = <<EOF;
$filetype("$base_name.$filetype", $out_params)
seqLogo(pwm, $seqlogo_params)
dev.off()
EOF

    my $R = Statistics::R->new();
    $R->run($build_pwm);
    $R->run($write_summary) unless $plot_only;
    $R->run($write_logo) unless $summary_only;
    $R->stop();
}
