#! /usr/bin/env perl
# Advent of Code 2018 Day 12 - Subterranean Sustainability - part 2
# Problem link: http://adventofcode.com/2018/day/12
#   Discussion: http://gerikson.com/blog/comp/Advent-of-Code-2018.html#d12
#      License: http://gerikson.com/files/AoC2018/UNLICENSE
###########################################################
use Modern::Perl '2015';

### CODE
my $in = shift @ARGV || 50_000_000_000;
die "input must be >= 129" unless $in>=129;

# these patterns and constants found by inspecting output of part 1
my $pattern = '##...##...##...##...##...##...##...##...##...##...##...##...##...##...##...##...##...##...##...##...##...##...##...##...##...##';
my $offset = 26;
my $sum = -52;

my $index = $in-$offset;

my @list = split //,$pattern;
while (@list) {
    my $token =shift @list;
    if ($token eq '#') {
	$sum += $index;
    }
    $index++;
}
say "Part 2: ", $sum;

