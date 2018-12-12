#! /usr/bin/env perl
# Advent of Code 2018 Day 11 - Chronal Charge - complete solution
# Problem link: http://adventofcode.com/2018/day/11
#   Discussion: http://gerikson.com/blog/comp/Advent-of-Code-2018.html#d11
#      License: http://gerikson.com/files/AoC2018/UNLICENSE
###########################################################
use Modern::Perl '2015';

# useful modules
use List::Util qw/sum/;
use Data::Dumper;

#### INIT - load input data from file into array
my $testing = 0;

my (@in) = @ARGV;
my ( $test_x, $test_y, $serial );
if ( scalar @in > 0 ) {    # testing input
    ( $test_x, $test_y, $serial ) = @in;
}
else {
    $serial = 3628;
}

### CODE
my $MAX = 300;
sub power_level;
sub subsquare_sum;

# precalculate subsquares
# https://en.wikipedia.org/wiki/Summed-area_table
my $grid;
my $SA;

# some pre-init to prevent warnings later
map { $SA->[0]->[$_] = 0 } ( 0 .. $MAX );
map { $SA->[$_]->[0] = 0 } ( 0 .. $MAX );

foreach my $x ( 1 .. $MAX ) {
    foreach my $y ( 1 .. $MAX ) {
        my $val = power_level( $x, $y, $serial );
        $grid->[$x]->[$y] = $val;
        my $sum = $grid->[$x]->[$y];
        $sum += $SA->[$x]->[ $y - 1 ];
        $sum += $SA->[ $x - 1 ]->[$y];
        $sum -= $SA->[ $x - 1 ]->[ $y - 1 ];

        $SA->[$x]->[$y] = $sum;
    }
}

my $global_max = { x => 0, y => 0, val => 0, grid => 0 };
my $gridsize;
foreach $gridsize ( 1 .. 20 ) {   # cutoff found by inspection

    my $local_max = { x => 0, y => 0, val => 0 };

    foreach my $x ( 1 .. $MAX - $gridsize ) {
        foreach my $y ( 1 .. $MAX - $gridsize ) {
            my $sum = subsquare_sum( [ $x - 1, $y - 1 ],
                [ $x + $gridsize, $y + $gridsize ] );

            $global_max = { x => $x, y => $y, val => $sum, grid => $gridsize }
              if $sum > $global_max->{val};

	    $local_max = { x => $x, y => $y, val => $sum }
              if $sum > $local_max->{val} and $gridsize==2;
        }
    }
    if ( $gridsize == 2 ) {
        say "Part 1: ", join( ',', map { $global_max->{$_} } qw/x y/ );
    }
}
say "Part 2: ",
  join( ',', ( map { $global_max->{$_} } qw/x y/ ), $global_max->{grid} + 1 );

### SUBS

sub power_level {
    my ( $x, $y, $s ) = @_;
    my $rack_id     = $x + 10;
    my $power_level = $rack_id * $y;
    $power_level = $power_level + $s;
    $power_level = $power_level * $rack_id;
    if ( $power_level < 100 ) {
        $power_level = 0;
    }
    else {
        $power_level = int( $power_level / 100 );
        $power_level = $power_level % 10;
    }
    return $power_level - 5;
}

sub subsquare_sum {
    my ( $top_left, $bottom_right ) = @_;
    my ( $x_0,      $y_0 )          = @{$top_left};
    my ( $x_1,      $y_1 )          = @{$bottom_right};

    return $SA->[$x_1]->[$y_1] +
      $SA->[$x_0]->[$y_0] -
      $SA->[$x_1]->[$y_0] -
      $SA->[$x_0]->[$y_1];
}

