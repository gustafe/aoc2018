#! /usr/bin/env perl
# Advent of Code 2018 Day 6 - Chronal Coordinates - complete solution
# Problem link: http://adventofcode.com/2018/day/6
#   Discussion: http://gerikson.com/blog/comp/Advent-of-Code-2018.html#d06
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

sub manhattan_distance {
    my ( $p, $q ) = (@_);
    return abs( $p->[0] - $q->[0] ) + abs( $p->[1] - $q->[1] );
}
my $LIMIT = $testing ? 32 : 10000;

my $index = 1;

my @labels = ( 'A' .. 'F' );    # for testing

my %points;
my ( $maxcol, $maxrow ) = ( 0,    0 );
my ( $mincol, $minrow ) = ( 10e6, 10e6 );
foreach my $line (@input) {
    my ( $c, $r ) = $line =~ /(\d+)\,\ (\d+)/;
    $maxcol = $c if $c > $maxcol;
    $maxrow = $r if $r > $maxrow;
    $mincol = $c if $c < $mincol;
    $minrow = $r if $r < $minrow;

    my $label = $testing ? shift @labels : $index;
    $points{$label} = { row => $r, col => $c };
    $index++;

}

my @sought;
my %areas;
my %on_edges;
foreach my $r ( $minrow .. $maxrow ) {
    foreach my $c ( $mincol .. $maxcol ) {

        my %dists;
        foreach my $label ( keys %points ) {
            next if $label eq '.';

            # calculate the manhattan_distance to each point from where we are
            # add to the tally of closest
            my $d =
              manhattan_distance( [ map { $points{$label}->{$_} } qw/col row/ ],
                [ $c, $r ] );
            push @{ $dists{$d} }, $label;

        }

        my $sum;
        my $count = 0;
        foreach my $d ( sort { $a <=> $b } keys %dists ) {
            if ( !$count ) {
                my @closest = @{ $dists{$d} };
                if ( scalar @closest == 1 ) {
                    $points{ $closest[0] }->{count}++;
                    $on_edges{ $closest[0] }++
                      if ( $c == $mincol
                        or $c == $maxcol
                        or $r == $minrow
                        or $r == $maxrow );
                }
                else {    # more than 2 coordinates closest
                    $points{'.'}->{count}++;
                }

            }
            $sum += $d * scalar @{ $dists{$d} };
            $count++;
        }
        if ( $sum < $LIMIT ) {
            push @sought, [ $r, $c ];
        }
    }
}

my $largest_id = (
    grep { !exists $on_edges{$_} }
    sort { $points{$b}->{count} <=> $points{$a}->{count} } keys %points
)[0];
say "Part 1: ", $points{$largest_id}->{count};
say "Part 2: ", scalar @sought;
