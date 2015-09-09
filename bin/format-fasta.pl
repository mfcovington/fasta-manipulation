#!/usr/bin/env perl
# Mike Covington
# created: 2013-12-24
#
# Description:
#
use strict;
use warnings;
use Log::Reproducible;
use autodie;
use feature 'say';
use Getopt::Long;

use FindBin;
use lib "$FindBin::Bin/../lib";
use fasta_tools;

my $seq_width = 80;

my $options = GetOptions(
    "width=i" => \$seq_width,
);

my $fasta_file = $ARGV[0];
my $seqid;
my $seq;

open my $fasta_fh, "<", $fasta_file;
while ( my $fa_line = <$fasta_fh>) {
    if ($fa_line =~ /^>/) {
        if ($seq) {
            say format_seq( $seq, $seq_width );
            $seq = '';
        }
        print $fa_line;
    }
    else{
        chomp $fa_line;
        $seq .= $fa_line;
    }
}
close $fasta_fh;

say format_seq( $seq, $seq_width );

exit;
