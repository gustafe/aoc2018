#! /usr/bin/env perl
# Advent of Code 2018 Day 22 - Mode Maze - complete solution
# Problem link: http://adventofcode.com/2018/day/22
#   Discussion: http://gerikson.com/blog/comp/Advent-of-Code-2018.html#d22
#      License: http://gerikson.com/files/AoC2018/UNLICENSE
###########################################################
use Modern::Perl '2015';

# useful modules
use List::Util qw/sum min/;
use Data::Dump qw/dump/;
use Test::More tests => 2;
use List::Util qw/all/;
use Time::HiRes qw/gettimeofday tv_interval/;
use Array::Heap::PriorityQueue::Numeric;

my $start_time = [gettimeofday];

#### INIT - load input data from file into array
my $testing = 0;
my @input;
my $file = $testing ? 'test.txt' : 'input.txt';
open( my $fh, '<', "$file" );
while (<$fh>) { chomp; s/\r//gm; push @input, $_; }

### CODE
# standard form of input
my ($depth) = $input[0] =~ m/depth: (\d+)/;
my ( $x_t, $y_t ) = $input[1] =~ m/target: (\d+)\,(\d+)/;

my $Map;    # memoization
sub calculate_type;
sub bydistance;

my $risk;

for my $x ( 0 .. $x_t ) {
    for my $y ( 0 .. $y_t ) {
        $risk += calculate_type( $x, $y )->{type};
    }
}
if ($testing) {
    is( $risk, 114, "Part 1: $risk" )

        # nop
}
else {
    is( $risk, 10115, "Part 1: $risk" );
}

# find the fastest path using Djikstra's

## combination of type and tool
#   0         1        2
# ['Rocky',  'Wet',   'Narrow'];
# ['nEither','Torch', 'Gear'];

#   E T G
# R X . .
# W . X .
# N . . X

my %allowed_states = (
    0 => { 1 => 1, 2 => 1 },
    1 => { 0 => 1, 2 => 1 },
    2 => { 0 => 1, 1 => 1 }
);

my $root   = '0,0,1';    # start with torch
my $bignum = 999999;

# search outside thebox above my ( $x_limit, $y_limit );

my $x_limit = 3 * $x_t;
my $y_limit = $y_t + $x_limit;

my @node;
for ( my $x = 0; $x <= $x_limit; $x++ ) {
    for ( my $y = 0; $y <= $y_limit; $y++ ) {
        my $type = calculate_type( $x, $y )->{type};
        foreach my $tool ( keys %{ $allowed_states{$type} } ) {
            push @node, join( ',', $x, $y, $tool );
        }
    }
}

my %dist;
my %edge;
say "==> calculating vertices...";

# calculate vertices
for ( my $x = 0; $x <= $x_limit; $x++ ) {
    for ( my $y = 0; $y <= $y_limit; $y++ ) {
        my $type = calculate_type( $x, $y )->{type};

        # what states are legal for this type?
        my @tools = keys %{ $allowed_states{$type} };

        # cost for switching tools
        $edge{ join( ',', $x, $y, $tools[0] ) }
            ->{ join( ',', $x, $y, $tools[1] ) } = 7;
        $edge{ join( ',', $x, $y, $tools[1] ) }
            ->{ join( ',', $x, $y, $tools[0] ) } = 7;

        # try to move
        for my $d ( [ -1, 0 ], [ 1, 0 ], [ 0, -1 ], [ 0, 1 ] ) {
            next
                if ( $x + $d->[0] < 0
                or $y + $d->[1] < 0
                or $x + $d->[0] > $x_limit
                or $y + $d->[1] > $y_limit );

            my ( $x2, $y2 ) = ( $x + $d->[0], $y + $d->[1] );
            my $type2 = calculate_type( $x2, $y2 )->{type};

            # can we get to the next node using our currently equipped tool?
            foreach my $tool (@tools) {
                $edge{ join( ',', $x, $y, $tool ) }
                    ->{ join( ',', $x2, $y2, $tool ) } = 1
                    if exists $allowed_states{$type2}{$tool};
            }

        }
    }
}
my $pq = Array::Heap::PriorityQueue::Numeric->new();
say "==> setting up queue...";
foreach my $n (@node) {
    $dist{$n} = $bignum;
    $pq->add_unordered( $n, $bignum );
}
$pq->restore_order();
$dist{$root} = 0;

say "==> starting loop...";
LOOP:
while ( $pq->peek ) {
    my $n = $pq->get();
    my ( $x, $y, $t ) = split( /,/, $n );
    my $manhattan = abs( $x_t - $x ) + abs( $y_t - $y );
    foreach my $n2 ( keys %{ $edge{$n} } ) {
        if ( $dist{$n2} > ( $dist{$n} + $edge{$n}{$n2} ) ) {

            $dist{$n2} = $dist{$n} + $edge{$n}{$n2};
            $pq->add( $n2, $dist{$n} + $edge{$n}{$n2} + $manhattan );
        }
    }
}
my $target = join( ',', $x_t, $y_t, 1 );
my $part2 = $dist{$target};

if ($testing) {
    is( $part2, 45, "Part 2: $part2" );
}
else {
    is( $part2, 990, "Part 2: $part2" );
}

say sec_to_hms( tv_interval($start_time) );

#### SUBS ####
sub sec_to_hms {
    my ($s) = @_;
    return sprintf(
        "Duration: %02dh%02dm%02ds (%.3f ms)",
        int( $s / ( 60 * 60 ) ),
        ( $s / 60 ) % 60,
        $s % 60, $s * 1000
    );
}

sub calculate_type {
    my ( $x, $y ) = @_;

    # recursive with memoization
    if ( defined $Map->[$x][$y] ) {
        return {
            type  => $Map->[$x][$y]{type},
            level => $Map->[$x][$y]{level}
        };
    }
    my ( $geo_index, $level, $type );
    if ( $x == 0 and $y == 0 ) {
        $geo_index = 0;
    }
    elsif ( $x == $x_t and $y == $y_t ) {
        $geo_index = 0;
    }
    elsif ( $x == 0 ) {
        $geo_index = $y * 48271;
    }
    elsif ( $y == 0 ) {
        $geo_index = $x * 16807;
    }
    else {
        $geo_index = calculate_type( $x - 1, $y )->{level}
            * calculate_type( $x, $y - 1 )->{level};
    }
    die "how did we get here?!" unless defined $geo_index;
    $level = ( $geo_index + $depth ) % 20183;
    $type  = $level % 3;
    $Map->[$x][$y] = { type => $type, level => $level };
    return { type => $type, level => $level };
}

