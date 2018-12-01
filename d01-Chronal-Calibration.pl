#! /usr/bin/env perl
# Advent of Code 2018 Day 1: Chronal Calibration - complete solution
# Problem link: http://adventofcode.com/2018/day/1
#   Discussion: http://gerikson.com/blog/comp/Advent-of-Code-2018.html#d01
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
my @list = @input;
my $freq = 0;
while (@list) {
    my $next = shift @list;
    $freq = $freq + $next;
}

say "Part 1: ", $freq;

my %seen = ( 0 => 1 );
$freq = 0;
my $loopcount = 0;
LOOP:
while (1) {
    my @list = @input;

    #    warn "==> $loopcount";
    while (@list) {
        my $next = shift @list;
        $freq = $freq + $next;
        $seen{$freq}++;
        if ( $seen{$freq} > 1 ) {
            last LOOP;
        }
    }
    $loopcount++;
}
say "Part 2: ", $freq;
