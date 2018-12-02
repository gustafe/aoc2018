#! /usr/bin/env perl
# Advent of Code 2018 Day 2 - Inventory Management System - complete solution
# Problem link: http://adventofcode.com/2018/day/2
#   Discussion: http://gerikson.com/blog/comp/Advent-of-Code-2018.html#d02
#      License: http://gerikson.com/files/AoC2018/UNLICENSE
###########################################################
use Modern::Perl '2015';

# useful modules
use List::Util qw/sum/;
use Data::Dumper;

#### INIT - load input data from file into array
my $testing = 0;
my @input;
my $file = $testing ? 'test.txt' : 'input.txt';
open( my $fh, '<', "$file" );
while (<$fh>) { chomp; s/\r//gm; push @input, $_; }

### CODE
my $count_2;
my $count_3;
foreach my $str (@input) {
    my %freq;
    foreach my $chr ( split( //, $str ) ) {
        $freq{$chr}++;
    }
    my $flag_2 = 0;
    my $flag_3 = 0;
    foreach my $k ( keys %freq ) {
        $flag_2++ if $freq{$k} == 2;
        $flag_3++ if $freq{$k} == 3;
    }
    $count_2++ if $flag_2;
    $count_3++ if $flag_3;
}

say "Part 1: ", $count_2 * $count_3;

LOOP:
foreach my $str1 (@input) {
    foreach my $str2 (@input) {
        next if ( $str1 eq $str2 );

        my @a1 = split( //, $str1 );
        my @a2 = split( //, $str2 );
        my @diffs;
        for ( my $i = 0 ; $i < scalar @a1 ; $i++ ) {
            if ( $a1[$i] ne $a2[$i] ) {
                push @diffs, $i;
            }
        }

        if ( scalar @diffs == 1 ) {
            my $res;
            my $same = $diffs[0];
            for ( my $i = 0 ; $i < scalar @a1 ; $i++ ) {
                $res .= $a1[$i] unless $i == $same;
            }
            say "Part 2: ", $res;
            last LOOP;
        }
    }
}
