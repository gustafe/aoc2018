#! /usr/bin/env perl
# Advent of Code 2018 Day 14 - Chocolate Charts - part 1 
# Problem link: http://adventofcode.com/2018/day/14
#   Discussion: http://gerikson.com/blog/comp/Advent-of-Code-2018.html#d14
#      License: http://gerikson.com/files/AoC2018/UNLICENSE
###########################################################
use Modern::Perl '2015';
# useful modules
use List::Util qw/sum/;

### CODE

my $target = shift @ARGV || 890691;

my $debug = 0;
my @recipes = (3,7);
my %elves= (e1 => 0, e2=>1 );

my $rounds = 0;

# we need 10 more entries than our target
while (scalar @recipes <= $target+10 ) {

    # create new recipes
    my @newrec = split(//, sum (map {$recipes[$elves{$_}] } qw/e1 e2/  ));
    push @recipes, @newrec;

    # move the elves
    foreach my $e (keys %elves) {
	my $newpos = $elves{$e} + 1 + $recipes[$elves{$e}];
	if ($newpos > $#recipes) {
	    $newpos %= @recipes;
	}
	say $newpos if $debug;
	$elves{$e} = $newpos;
    }
    $rounds++;
}

my @sought = @recipes[$target..$target+9];
say "Part 1: ",join('', @sought);
