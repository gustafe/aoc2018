#! /usr/bin/env perl
# Advent of Code 2018 Day 14 - Chocolate Charts - part 2
# Problem link: http://adventofcode.com/2018/day/14
#   Discussion: http://gerikson.com/blog/comp/Advent-of-Code-2018.html#d14
#      License: http://gerikson.com/files/AoC2018/UNLICENSE
###########################################################
use Modern::Perl '2015';

# useful modules

use List::Util qw/sum/;

### CODE

my $target = shift @ARGV || 890691;

my $debug   = 0;
my @recipes = ( 3, 7 );
my %elves   = ( e1 => 0, e2 => 1 );

my $rounds = 0;
my $len    = length($target);

while (1) {
    no warnings qw/uninitialized/;
    say "> $rounds" if $rounds % 100_000 == 0;

    # create new recipes
    my @newrec = split( //, sum( map { $recipes[ $elves{$_} ] } qw/e1 e2/ ) );
    say join ' ', @newrec if $debug;

    push @recipes, @newrec;

    # move the elves
    foreach my $e ( keys %elves ) {

        my $newpos = $elves{$e} + 1 + $recipes[ $elves{$e} ];

        if ( $newpos > $#recipes ) {

            $newpos %= @recipes;
        }
        say $newpos if $debug;
        $elves{$e} = $newpos;
    }

    if ( join( '', @recipes[ -8 .. -1 ] ) =~ /$target/ ) {
        say "Part 2: ", index( join( '', @recipes ), $target );

        last;
    }
    $rounds++;
}
