#! /usr/bin/env perl
# Advent of Code 2018 Day 1 - complete solution
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
say "hi!";
