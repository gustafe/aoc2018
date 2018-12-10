#! /usr/bin/env perl
# Advent of Code 2018 Day 10 - The Stars Align - complete solution
# Problem link: http://adventofcode.com/2018/day/10
#   Discussion: http://gerikson.com/blog/comp/Advent-of-Code-2018.html#d10
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

# load into an array of positions and velocities, keep track of
# initial size
my ( $X, $Y ) = ( 0, 1 );
my $state;
my $velocity;
my $bounds = { map { $_ => 0 } qw(xmax xmin ymax ymin) };
while (@input) {
    my $line = shift @input;
    my ( $pos, $vel ) = $line =~ m/<(.*)>.*<(.*)>$/;
    my ( $x,   $y )   = split /\,/, $pos;
    my ( $vx,  $vy )  = split /\,/, $vel;

    push @{$velocity}, [ $vx, $vy ];
    push @{$state},    [ $x,  $y ];

    $bounds->{xmax} = $x if $x > $bounds->{xmax};
    $bounds->{ymax} = $y if $y > $bounds->{ymax};
    $bounds->{xmin} = $x if $x < $bounds->{xmin};
    $bounds->{ymin} = $y if $y < $bounds->{ymin};
}
my $count = 0;
# assuming we converge to a minimal state space... print that!
while (1) {
    my $new_bounds = { map { $_ => 0 } qw(xmax xmin ymax ymin) };
    my $new_state;
    for ( my $idx = 0 ; $idx < scalar @{$state} ; $idx++ ) {
        my $x = $state->[$idx]->[$X] + $velocity->[$idx]->[$X];
        my $y = $state->[$idx]->[$Y] + $velocity->[$idx]->[$Y];

        $new_state->[$idx]->[$X] = $x;
        $new_state->[$idx]->[$Y] = $y;

        $new_bounds->{xmax} = $x if $x > $new_bounds->{xmax};
        $new_bounds->{ymax} = $y if $y > $new_bounds->{ymax};
        $new_bounds->{xmin} = $x if $x < $new_bounds->{xmin};
        $new_bounds->{ymin} = $y if $y < $new_bounds->{ymax};
    }

    # area expanding?

    if ( ( $new_bounds->{xmax} - $new_bounds->{xmin} ) >
            ( $bounds->{xmax} - $bounds->{xmin} )
        and ( $new_bounds->{ymax} - $new_bounds->{ymin} ) >
        ( $bounds->{ymax} - $bounds->{ymin} ) )
    {
        # keep the last known state, break out of loop
        last;
    }
    $state  = $new_state;
    $bounds = $new_bounds;
    $count++;
}

# print results!

my $grid;
foreach my $p ( @{$state} ) {
    $grid->{ $p->[$Y] }->{ $p->[$X] }++;
}

say "Part 1:";
foreach my $y ( 0 .. ( $bounds->{ymax} ) ) {
    my $line;
    foreach my $x ( 0 .. ( $bounds->{xmax} ) ) {
        if ( exists $grid->{$y}->{$x} ) {
            $line .= '#';
        }
        else {
            $line .= ' ';
        }
    }

    # some whitespace munging to clean up the output
    $line =~ s/^\s+//;
    next if length($line) == 0;
    say $line;
}

say "Part 2: ", $count;
