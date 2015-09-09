use strict;
use warnings;

sub format_seq {
    my ( $seq, $width ) = @_;
    return join "\n", unpack "(A$width)*", $seq;
}

sub longest_orf {
    my ( $nt_seq, $ss ) = @_;

    my @translations;
    for my $reading_frame ( 0 .. 2 ) {
        push @translations, translate( substr $nt_seq, $reading_frame );
        push @translations,
            translate( substr $nt_seq, reverse_complement($reading_frame) )
            unless $ss;
    }

    my @orfs;
    for my $aa_seq (@translations) {
        push @orfs, $aa_seq =~ /(M[ACDEFGHIKLMNPQRSTVWYX]*-?)/ig;
    }

    my @sorted_orfs = reverse sort { length $a <=> length $b } @orfs;

    print
        "WARNING: Can't distinguish between multiple ORFs of the same length!\n"
        if scalar @sorted_orfs > 1
        && length $sorted_orfs[0] == length $sorted_orfs[1];

    return $sorted_orfs[0];
}

sub reverse_complement {
    my $nt_seq = shift;

    $nt_seq = reverse $nt_seq;
    $nt_seq =~ tr/ACGTUacgtu/TGCAAtgcaa/;

    return $nt_seq;
}

sub translate {
    my $nt_seq = shift;
    my $codon_table = codon_table();

    $nt_seq =~ tr/acgtuU/ACGTTT/;
    my $pos = 0;
    my $aa_seq;
    while ( $pos < length($nt_seq) - 2 ) {
        my $codon = substr $nt_seq, $pos, 3;
        my $amino_acid = $$codon_table{$codon};
        if ( defined $amino_acid ) {
            $aa_seq .= $amino_acid;
        }
        else {
            $aa_seq .= "X";
        }
        $pos += 3;
    }
    return $aa_seq;
}

sub codon_table {
    return {
        TTT => 'F', TCT => 'S', TAT => 'Y', TGT => 'C',
        TTC => 'F', TCC => 'S', TAC => 'Y', TGC => 'C',
        TTA => 'L', TCA => 'S', TAA => '-', TGA => '-',
        TTG => 'L', TCG => 'S', TAG => '-', TGG => 'W',
        CTT => 'L', CCT => 'P', CAT => 'H', CGT => 'R',
        CTC => 'L', CCC => 'P', CAC => 'H', CGC => 'R',
        CTA => 'L', CCA => 'P', CAA => 'Q', CGA => 'R',
        CTG => 'L', CCG => 'P', CAG => 'Q', CGG => 'R',
        ATT => 'I', ACT => 'T', AAT => 'N', AGT => 'S',
        ATC => 'I', ACC => 'T', AAC => 'N', AGC => 'S',
        ATA => 'I', ACA => 'T', AAA => 'K', AGA => 'R',
        ATG => 'M', ACG => 'T', AAG => 'K', AGG => 'R',
        GTT => 'V', GCT => 'A', GAT => 'D', GGT => 'G',
        GTC => 'V', GCC => 'A', GAC => 'D', GGC => 'G',
        GTA => 'V', GCA => 'A', GAA => 'E', GGA => 'G',
        GTG => 'V', GCG => 'A', GAG => 'E', GGG => 'G',
    };
}

1;
