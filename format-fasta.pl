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

my $fasta_file = $ARGV[0];
my $fa_width //= 80;
my $seqid;
my $seq;

open my $fasta_fh, "<", $fasta_file;
while ( my $fa_line = <$fasta_fh>) {
    if ($fa_line =~ /^>/) {
        if ($seq) {
            say $_ for unpack "(A$fa_width)*", $seq;
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

say $_ for unpack "(A$fa_width)*", $seq;

exit;
