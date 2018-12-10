#! /usr/bin/env perl
# Advent of Code 2018 Day 7 - The Sum of Its Parts - part 1
# Problem link: http://adventofcode.com/2018/day/7
#   Discussion: http://gerikson.com/blog/comp/Advent-of-Code-2018.html#d07
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
my %graph;
foreach my $line (@input) {
    my ( $input, $output ) = $line =~ /^Step (.) .*step (.) can begin.$/;
    $graph{$output}->{from}->{$input}++;
    $graph{$input}->{to}->{$output}++;
}
my @queue;

push @queue,
  sort grep { scalar keys %{ $graph{$_}->{from} } == 0 } keys %graph;

my @result;
my %processed;
while (@queue) {
    my $next = shift @queue;
    push @result, $next;
    $processed{$next}++;

    my @possible = keys %{ $graph{$next}->{to} };

    # can we add to queue?
    while (@possible) {
        my $candidate = shift @possible;
        my $ok        = 1;
        foreach my $r ( keys %{ $graph{$candidate}->{from} } ) {
            $ok = 0 unless exists $processed{$r};
        }
        push @queue, $candidate if $ok;
    }
    @queue = sort @queue;

}

say "Part 1: ", @result;
