#! /usr/bin/env perl
# Advent of Code 2018 Day 12 - Subterranean Sustainability - part 1
# Problem link: http://adventofcode.com/2018/day/12
#   Discussion: http://gerikson.com/blog/comp/Advent-of-Code-2018.html#d12
#      License: http://gerikson.com/files/AoC2018/UNLICENSE
###########################################################
use Modern::Perl '2015';

# useful modules
use List::Util qw/min  max sum first/;
use List::MoreUtils qw/first_index/;
use Data::Dumper;
use Clone 'clone';
#### INIT - load input data from file into array
my $testing = 0;
my @input;
my $file = $testing ? 'test.txt' : 'input.txt';
open( my $fh, '<', "$file" );
while (<$fh>) { chomp; s/\r//gm; push @input, $_; }

### CODE

my $iterations = shift @ARGV || 20;

my $state;
my %patterns;

foreach my $line (@input) {
    if ( $line =~ m/^initial state: (.*)$/ ) {

        my @in = split //, $1;
        my $id = 0;
        while (@in) {
            my $pot = shift @in;
            push @{$state}, { id => $id, status => $pot };
            $id++

        }
    }
    elsif ( $line =~ m/^(\S{5}) \=\> (.$)/ ) {

        $patterns{$1} = $2;
    }
}

my $round = 0;
while ( $round < $iterations ) {

    # add pots to the beginning and the end
    my $first_id = $state->[0]->{id};
    my $last_id  = $state->[-1]->{id};

    unshift @{$state},
      map { { id => $first_id - $_, status => '.' } } ( -4, -3, -2, -1 );
    push @{$state},
      map { { id => $last_id + $_, status => '.' } } ( 1, 2, 3, 4 );

    if ($testing) {
        my $str;
        foreach my $pot ( @{$state} ) {
            $str .= $pot->{status} if $pot->{id} >= -5;
        }
        printf "%2d %s\n", $round, $str;
    }
    my $new_state = clone $state;

    for ( my $idx = 2 ; $idx <= $#{$state} - 2 ; $idx++ ) {
        my $pattern;
        foreach my $offset ( -2, -1, 0, 1, 2 ) {
            $pattern .= $state->[ $idx + $offset ]->{status};
        }

        if ( exists $patterns{$pattern} ) {

            $new_state->[$idx]->{status} = $patterns{$pattern};
        }
        else {

            if ($testing) {
                $new_state->[$idx]->{status} = '.';
            }
            else {

                die "can't find $pattern in list!";
            }

        }

    }
    $state = clone $new_state;

    $round++;
}

my $sum;

my $count;
my $first = 0;

foreach my $pot ( @{$state} ) {

    if ( $pot->{status} eq '#' ) {
        $first = $pot->{id} unless $first;
        $count++;

        $sum += $pot->{id};
    }

}

my $str = join '', map { $_->{status} } @{$state};
$str =~ s/^\.+//;
$str =~ s/\.+$//;

if ($iterations == 20) {
    say "Part 1: ", $sum;
} else {
    # output to research part 2
    say join( ' ', $iterations, $count, $first, $sum, $str );
}
