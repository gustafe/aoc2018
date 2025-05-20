#! /usr/bin/env perl
# Advent of Code 2018 Day 20 - A Regular Map - complete solution
# https://adventofcode.com/2018/day/20
# https://gerikson.com/files/AoC2018/UNLICENSE
###########################################################

use Modern::Perl '2015';
# useful modules
use List::Util qw/sum min/;
use Data::Dump qw/dump/;
use Test::More;
use Time::HiRes qw/gettimeofday tv_interval/;
use Clone qw/clone/;
sub sec_to_hms;

my $start_time = [gettimeofday];
#### INIT - load input data from file into array

my $testing = 0;
my $debug = 0;
my @input;
my $file = $testing ? 'test.txt' : 'input.txt';
open( my $fh, '<', "$file" );
while (<$fh>) { chomp; s/\r//gm; push @input, $_; }

### CODE
my %dirs = ( N => [-1,0],
	     E => [0,1],
	     S => [1,0],
	     W => [0,-1] );
my @chars = split(//,$input[0]);
#shift @chars; pop @chars;

my @positions;
my $distances;
$distances->{0}{0} = 0;

my @curr = (0,0);
my @prev = (0,0);

for my $idx (1 .. $#chars-1) {
    my $c = $chars[$idx];
    if ($c eq '(') {
	say $c if $debug;
	push @positions, [@curr];
    } elsif ( $c eq ')') {
	say $c if $debug;
	@curr = @{pop @positions};
    } elsif ( $c eq '|') {
	say $c if $debug;
	@curr = @{$positions[-1]};
	printf("==> [%3d,%3d]\n", @curr) if $debug;
    } else {

	$curr[0] += $dirs{$c}->[0];
	$curr[1] += $dirs{$c}->[1];
	if (defined $distances->{$curr[0]}{$curr[1]}) {
	    $distances->{$curr[0]}{$curr[1]} = min ( $distances->{$curr[0]}{$curr[1]},
							 $distances->{$prev[0]}{$prev[1]} + 1 );
	    
	} else {
	    $distances->{$curr[0]}{$curr[1]} = $distances->{$prev[0]}{$prev[1]} + 1
	}
    }
    printf("[%3d,%3d] %4d %4d\n", @curr, $distances->{$curr[0]}{$curr[1]}, scalar @positions) if $debug;
    @prev=@curr;
}

my $max_d = 0;
my $count = 0;
for my $r (keys %$distances) {
    for my $c (keys %{$distances->{$r}}) {
	$max_d = $distances->{$r}{$c} if $distances->{$r}{$c} > $max_d;
	$count++ if $distances->{$r}{$c} >= 1000;
	  
    }
}

### FINALIZE - tests and run time
is($max_d, 4018, "Part 1: max distance   : $max_d");
is($count, 8581, "Part 2: number of rooms: $count");
done_testing();
say sec_to_hms(tv_interval($start_time));

### SUBS
sub sec_to_hms {
    my ($s) = @_;
    return sprintf("Duration: %02dh%02dm%02ds (%.3f ms)",
    int( $s/(3600) ), ($s/60) % 60, $s % 60, $s * 1000 );
}
