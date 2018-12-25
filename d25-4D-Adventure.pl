#! /usr/bin/env perl
# Advent of Code 2018 Day 25.pl - Four-Dimensional Adventure - complete solution
# Problem link: http://adventofcode.com/2018/day/25.pl
#   Discussion: http://gerikson.com/blog/comp/Advent-of-Code-2018.html#d25
#      License: http://gerikson.com/files/AoC2018/UNLICENSE
###########################################################
use Modern::Perl '2015';

#### INIT - load input data from file into array

my @input;

while (<>) { chomp; s/\r//gm; push @input, $_; }

### CODE
sub distance;
sub dump_point;

my @points;
for my $line (@input) {
    push @points, { pos => [ split( /\,/, $line ) ], const_id => undef };
}
my $const_id = 0;

for ( my $i = 0 ; $i < scalar @points ; $i++ ) {
    if ( !defined $points[$i]->{const_id} ) {
        my @list;

        $const_id++;

        $points[$i]->{const_id} = $const_id;
        push @list, $i;
        while (@list) {
            my $j = shift @list;

            # check is any other points are in range
            for ( my $k = 0 ; $k < scalar @points ; $k++ ) {
                next if $j == $k;
                next if defined $points[$k]->{const_id};

                my $d = distance( $points[$k]->{pos}, $points[$j]->{pos} );
                if ( $d <= 3 ) {
                    $points[$k]->{const_id} = $const_id;
                    push @list, $k;
                }
            }
        }
    }
}

say "Part 1: ", $const_id;

### SUBS
sub dump_point {
    my ($p) = @_;
    printf(
        "[%2d,%2d,%2d,%2d] id=%s\n",
        @{ $p->{pos} },
        defined $p->{const_id} ? $p->{const_id} : ''
    );
}

sub distance {
    my ( $p, $q ) = @_;
    my $d;
    for my $idx ( 0 .. 3 ) {
        $d += abs( $p->[$idx] - $q->[$idx] );
    }
    return $d;

}
