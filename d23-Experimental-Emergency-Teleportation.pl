#! /usr/bin/env perl
# Advent of Code 2018 Day 23 - Experimental Emergency Teleportation - complete solution
# Problem link: http://adventofcode.com/2018/day/23
#      License: http://gerikson.com/files/AoC2018/UNLICENSE
###########################################################
use Modern::Perl '2015';
# useful modules
use List::Util qw/sum min max first/;
use Data::Dump qw/dump/;
use Test::More;
use Time::HiRes qw/gettimeofday tv_interval/;
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
my @bots;
for my $line (@input) {
    if ($line =~ m/^pos=<(-?\d+),(-?\d+),(-?\d+)>, r=(-?\d+)$/) {
	push @bots, {x=>$1,y=>$2,z=>$3,r=>$4}
    }
}
my $max_ranges; my $min_ranges;
for my $dim (qw/x y z r/) {
    $max_ranges->{$dim} = max ( map { $_->{$dim} } @bots );
    $min_ranges->{$dim} = min ( map { $_->{$dim} } @bots );
}
if ($debug) {
    dump @bots;
    dump $max_ranges;
    dump $min_ranges;
}
### Part 1

my $strong_idx = first { $bots[$_]->{r} == $max_ranges->{r} } 0..$#bots;

my $count;
for my $idx (0..$#bots) {
#    next if $idx == $strong_idx;
    my $d = manhattan( $bots[$strong_idx], $bots[$idx]);
    if ($d< $bots[$strong_idx]->{r}) {
	$count++
    }
}

### Part 2

# create a bounding box that contains all bots that's powers of 2
# this will simplify the octree calculation later

my $max_len = max ( map {$max_ranges->{$_} - $min_ranges->{$_}} qw/x y x/ );
my $side = 2;
while ($side < $max_len + 1) {
    $side *= 2;
}
say "max len: $max_len, side: $side" if $debug;

my $box = {max=> { map {$_=>$min_ranges->{$_} + $side - 1} (qw/x y z/) },
	   min => { map {$_=>$min_ranges->{$_}} (qw/x y z/)}
	   };
$box->{side} = $side;
dump $box if $debug;

$box->{in_range} = in_range( $box, \@bots );
$box->{dist} = distance_from_box( { x=>0,y=>0,z=>0}, $box );

my @boxes = ( $box);

while (1) {
    @boxes = sort { $b->{in_range} <=> $a->{in_range} ||
		      $a->{dist} <=> $b->{dist} ||
		      $a->{side} <=> $b->{side} } @boxes;
    $box = shift @boxes;
    printf("working on box between [%8d,%8d,%8d] and [%8d,%8d,%8d] with side %d and %d bots in range\n",
	   (map {$box->{min}{$_}} (qw/x y z/)),
	   (map {$box->{max}{$_}} (qw/x y z/)),
	   $box->{side},
	   $box->{in_range}) if $debug;
		  
    last if $box->{side} == 1;

    # construct octree
    my $new_side = $box->{side} / 2;
    for my $x ($box->{min}{x}, $box->{min}{x} + $new_side) {
	for my $y ($box->{min}{y}, $box->{min}{y} + $new_side) {
	    for my $z ($box->{min}{z}, $box->{min}{z} + $new_side) {
		my $new_box;
		$new_box = { min=> { x=>$x,y=>$y,z=>$z}, side=>$new_side};
		$new_box->{max}{x} = $x+ $new_side - 1;
		$new_box->{max}{y} = $y + $new_side - 1;
		$new_box->{max}{z} = $z + $new_side - 1;
		$new_box->{in_range} = in_range( $new_box, \@bots );
		$new_box->{dist} = distance_from_box( { x=> 0,y=>0,z=>0 }, $new_box );
		push @boxes, $new_box
	    }
	}
    }
}

### FINALIZE - tests and run time

is($count, 417, "Part 1: $count");
is($box->{dist}, 112997634, "Part 2: ".$box->{dist});
done_testing();
say sec_to_hms(tv_interval($start_time));

### SUBS
sub manhattan {
    my ( $p1, $p2 ) = @_;
    return sum( map {abs($p2->{$_} - $p1->{$_})} qw/x y z/);
}


sub distance_from_box {
    my ( $p, $box ) = @_;
    my $d=0;
    for my $dim (qw/x y z/) {
	$d += $p->{$dim} - $box->{max}{$dim} if $p->{$dim} > $box->{max}{$dim};
	$d += $box->{min}{$dim} - $p->{$dim} if $p->{$dim} < $box->{min}{$dim};
    }
    return $d;
}

sub in_range {
    my ( $box, $bots ) = @_;
    my $count= 0;
    for my $bot (@$bots) {
	$count++ if distance_from_box( $bot, $box ) <= $bot->{r}
    }
    return $count;
}


sub sec_to_hms {
    my ($s) = @_;
    return sprintf("Duration: %02dh%02dm%02ds (%.3f ms)",
    int( $s/(3600) ), ($s/60) % 60, $s % 60, $s * 1000 );
}
