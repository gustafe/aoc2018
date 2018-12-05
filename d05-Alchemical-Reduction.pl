#! /usr/bin/env perl
# Advent of Code 2018 Day 5 - Alchemical Reduction -  complete solution
# Problem link: http://adventofcode.com/2018/day/5
#   Discussion: http://gerikson.com/blog/comp/Advent-of-Code-2018.html#d05
#      License: http://gerikson.com/files/AoC2018/UNLICENSE
###########################################################

use Modern::Perl '2015';

# useful modules
use List::Util qw/sum/;
use Data::Dumper;

#### INIT - load input data from file into array
my $testing = 0;
my $debug   = 0;
my @input;
my $file = $testing ? 'test.txt' : 'input.txt';
open( my $fh, '<', "$file" );
while (<$fh>) { chomp; s/\r//gm; push @input, $_; }

### CODE

sub is_match {
    my ( $k, $m ) = @_;

    #my @in = split(//,$in);
    if ( abs( ord( $k ? $k : '' ) - ord($m) ) == 32 ) {
        return 1;
    }
    else {
        return 0;
    }
}

sub reduce {
    my ($str) = @_;
    my @in = split( //, $str );
    my @next;
    push @next, shift @in;
    while (@in) {
        my $unit = shift @in;
        if ( is_match( $next[-1], $unit ) ) {
            pop @next;
        }
        else {
            push @next, $unit;
        }
    }
    return scalar @next;
}

say "Part 1: ", reduce( $input[0] );

my $min = length( $input[0] );
foreach my $c ( 'a' .. 'z' ) {
    my $u         = uc $c;
    my $shortened = $input[0];
    $shortened =~ s/[$c,$u]//xg;
    if ( $min > reduce($shortened) ) {
        $min = reduce($shortened);
    }
}
say "Part 2: $min";

