#! /usr/bin/env perl
# Advent of Code 2018 Day 4 - Repose Record - complete solution
# Problem link: http://adventofcode.com/2018/day/4
#   Discussion: http://gerikson.com/blog/comp/Advent-of-Code-2018.html#d04
#      License: http://gerikson.com/files/AoC2018/UNLICENSE
###########################################################
use Modern::Perl '2015';

# useful modules
use List::Util qw/sum minstr maxstr/;
use Data::Dumper;

#### INIT - load input data from file into array
my $testing = 0;
my @input;
my $file = $testing ? 'test.txt' : 'input.txt';
open( my $fh, '<', "$file" );
while (<$fh>) { chomp; s/\r//gm; push @input, $_; }

### CODE
my $debug = 0;
my $id    = undef;
my %stats;
my %minutes;
my $awake = undef;
my ( $start, $end ) = ( undef, undef );
foreach my $line ( sort @input ) {
    my ( $h, $m ) = $line =~ m/ (\d{2}):(\d{2})\]/;
    if ( $line =~ m/Guard \#(\d+)/ ) {
        $id    = $1;
        $awake = 1;
        ( $start, $end ) = ( undef, undef );
    }
    if ( $line =~ m/falls asleep/ and $awake ) {
        $awake = 0;
        $start = $m;
    }
    if ( $line =~ m/wakes up/ and !$awake ) {
        $awake = 1;
        $end   = $m;
    }
    if ( defined $start and defined $end ) {
        push @{ $stats{$id}->{spans} }, [ $start, $end ];
        for ( my $i = $start ; $i < $end ; $i++ ) {
            $stats{$id}->{freq}->{$i}++;
            $minutes{$i}->{$id}++;
        }
        ( $start, $end ) = ( undef, undef );
    }
}

# Part 1

# Find the guard that has the most minutes asleep. What minute does
# that guard spend asleep the most?

my $maxsum = { id => -1, val => 0 };
foreach my $id ( keys %stats ) {
    my $sum = 0;
    foreach my $span ( @{ $stats{$id}->{spans} } ) {
        $sum += $span->[1] - $span->[0];
    }
    if ( $sum > $maxsum->{val} ) {
        $maxsum->{val} = $sum;
        $maxsum->{id}  = $id;
    }
}
my $sought_id = $maxsum->{id};

my $most_m = (
    sort {
        $stats{$sought_id}->{freq}->{$b} <=> $stats{$sought_id}->{freq}->{$a}
    } keys %{ $stats{$sought_id}->{freq} }
)[0];

say "Part 1: ", $sought_id * $most_m;

# Part 2

# Of all guards, which guard is most frequently asleep on the same minute?

my $maxasleep = { val => 0, id => -1, sought => 0 };

foreach my $min ( sort { $a <=> $b } keys %minutes ) {
    my $most_asleep = ( sort { $minutes{$min}->{$b} <=> $minutes{$min}->{$a} }
          keys %{ $minutes{$min} } )[0];

    if ( $minutes{$min}->{$most_asleep} > $maxasleep->{val} ) {
        $maxasleep->{val}    = $minutes{$min}->{$most_asleep};
        $maxasleep->{id}     = $most_asleep;
        $maxasleep->{sought} = $min;
    }
}

say "Part 2: ", $maxasleep->{sought} * $maxasleep->{id};
