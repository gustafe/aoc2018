#! /usr/bin/env perl
# Advent of Code 2018 Day 17 - Reservoir Research - complete solution
# https://adventofcode.com/2018/day/17
# https://gerikson.com/blog/comp/adventofcode/Advent-of-Code-2018.html#d17
# https://gerikson.com/files/AoC2018/UNLICENSE
###########################################################
use Modern::Perl '2015';

# useful modules
use List::Util qw/sum min max/;
use Data::Dump qw/dump/;
use Test::More;
use Time::HiRes qw/gettimeofday tv_interval/;
sub sec_to_hms;

my $start_time = [gettimeofday];
#### INIT - load input data from file into array

my $testing = 0;
my @input;
my $file = $testing ? 'test.txt' : 'input.txt';
open( my $fh, '<', "$file" );
while (<$fh>) { chomp; s/\r//gm; push @input, $_; }

### CODE
my $Map;

for my $line (@input) {
    if ( $line =~ m/^(.)=(\d+), (.)=(\d+)\.\.(\d+)$/ ) {
        my ( $fix_coord, $fix_val, $range_coord, $range1, $range2 )
            = ( $1, $2, $3, $4, $5 );
        if ( $fix_coord eq 'y' ) {
            for my $x ( $range1 .. $range2 ) {
                $Map->{$x}{$fix_val} = '#';
            }
        }
        elsif ( $fix_coord eq 'x' ) {
            for my $y ( $range1 .. $range2 ) {
                $Map->{$fix_val}{$y} = '#';
            }
        }
        else {
            die "can't parse fixed coord: $fix_coord";
        }
    }
    else {
        warn "can't parse line: $line";
    }
}
my ( $min_x, $max_x ) = ( min( keys %$Map ), max( keys %$Map ) );
my ( $min_y, $max_y ) = ( 10e8, -1 );
for my $x ( keys %$Map ) {
    my @range = ( min( keys %{ $Map->{$x} } ), max( keys %{ $Map->{$x} } ) );
    $min_y = $range[0] if $range[0] < $min_y;
    $max_y = $range[1] if $range[1] > $max_y;
}
$Map->{500}{0} = '+';
sub flow;
sub dump_state;
flow( 500, 0, 0 );
my %ans;

for my $x ( keys %$Map ) {
    for my $y ( keys %{ $Map->{$x} } ) {
        next      if $y < $min_y;
        $ans{1}++ if ( $Map->{$x}{$y} eq '~' or $Map->{$x}{$y} eq '|' );
        $ans{2}++ if ( $Map->{$x}{$y} eq '~' );
    }
}

#dump_state;
### FINALIZE - tests and run time
is( $ans{1}, 31861, "Part 1: " . $ans{1} );
is( $ans{2}, 26030, "Part 2: " . $ans{2} );
done_testing();
say sec_to_hms( tv_interval($start_time) );

### SUBS
sub flow {

# code adapted from https://www.reddit.com/r/adventofcode/comments/a6wpup/2018_day_17_solutions/ebzumrh/
    my ( $x, $y, $d ) = @_;

    if ( !defined $Map->{$x}{$y} ) {
        $Map->{$x}{$y} = '|';
    }
    if ( $y == $max_y ) {
        return;
    }
    if ( $Map->{$x}{$y} eq '#' ) {
        return $x;
    }
    if ( !defined $Map->{$x}{ $y + 1 } ) {
        flow( $x, $y + 1, 0 );
    }
    if ( $Map->{$x}{ $y + 1 } eq '~' or $Map->{$x}{ $y + 1 } eq '#' ) {
        if ($d) {
            return flow( $x + $d, $y, $d );
        }
        else {
            my $left_x  = flow( $x - 1, $y, -1 );
            my $right_x = flow( $x + 1, $y, 1 );
            if ( $Map->{$left_x}{$y} eq '#' and $Map->{$right_x}{$y} eq '#' )
            {
                for my $fill_x ( $left_x + 1 .. $right_x - 1 ) {
                    $Map->{$fill_x}{$y} = '~';
                }
            }
        }
    }
    else {
        return $x;
    }
}

sub dump_state {
    for my $row ( 0 .. $max_y ) {
        for my $col ( 0 .. $max_x - $min_x ) {
            print $Map->{ $col + $min_x }{$row} // '.';
        }
        print "\n";
    }
}

sub sec_to_hms {
    my ($s) = @_;
    return sprintf(
        "Duration: %02dh%02dm%02ds (%.3f ms)",
        int( $s / ( 60 * 60 ) ),
        ( $s / 60 ) % 60,
        $s % 60, $s * 1000
    );
}
