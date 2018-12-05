#! /usr/bin/env perl
# Advent of Code 2018 Day 3 - No Matter How You Slice It - complete solution
# Problem link: http://adventofcode.com/2018/day/3
#   Discussion: http://gerikson.com/blog/comp/Advent-of-Code-2018.html#d03
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
my %swatches;
foreach my $line (@input) {
    if ( $line =~ m/\#(\d+)\ \@\ (\d+)\,(\d+)\:\ (\d+)x(\d+)/ ) {
	$swatches{$1} = { col => $2, row => $3, w => $4, h => $5 };
    }
    else {
        die "can't parse: $line";
    }
}

# populate the grid
my %grid;
foreach my $id ( keys %swatches ) {
    my ( $col, $row, $w, $h ) = map { $swatches{$id}->{$_} } qw/col row w h/;
    for ( my $c = $col ; $c < $col + $w ; $c++ ) {
        for ( my $r = $row ; $r < $row + $h ; $r++ ) {
            push @{ $grid{$c}->{$r} }, $id;
        }
    }
}

# count populated
my $count;
my %candidates;
foreach ( my $c = 0 ; $c < 1000 ; $c++ ) {
    foreach ( my $r = 0 ; $r < 1000 ; $r++ ) {
        next unless exists $grid{$c}->{$r};
        $count++ if scalar @{ $grid{$c}->{$r} } > 1;

        # which swatches are only on one square?
        if ( scalar @{ $grid{$c}->{$r} } == 1 ) {
            push @{ $candidates{ $grid{$c}->{$r}->[0] } }, [ $c, $r ];
        }
    }
}

say "Part 1: ", $count;

# compare one-square candidates with known swatches
# it turns out there's only one!
foreach my $id ( keys %candidates ) {

    if ( $swatches{$id}->{w} * $swatches{$id}->{h} ==
        scalar @{ $candidates{$id} } )
    {
        say "Part 2: ", $id;
    }
}
