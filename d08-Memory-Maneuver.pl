#! /usr/bin/env perl
# Advent of Code 2018 Day 8 - Memory Maneuver - complete solution
# Problem link: http://adventofcode.com/2018/day/8
#   Discussion: http://gerikson.com/blog/comp/Advent-of-Code-2018.html#d08
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
my $data = [ split / /, $input[0] ];

sub parse_tree;
sub get_meta_sum;
sub get_node_values;

my $tree = parse_tree($data);

say "Part 1: ", get_meta_sum($tree);
say "Part 2: ", get_node_values($tree);

sub parse_tree {
    my ($in) = @_;
    my ( $nr_children, $nr_meta ) = splice @{$in}, 0, 2;
    my $node;
    foreach ( 1 .. $nr_children ) {
        push @{ $node->{C} }, parse_tree($in);
    }
    $node->{M} = [ splice @{$in}, 0, $nr_meta ];
    return $node;
}

sub get_meta_sum {
    my ($in) = @_;
    my $sum;
    foreach my $node ( @{ $in->{C} } ) {
        $sum += get_meta_sum($node);
    }
    $sum += sum @{ $in->{M} };
    return $sum;
}

sub get_node_values {
    my ($in) = @_;
    my $sum;
    if ( @{ $in->{C} } ) {
        foreach my $m ( @{ $in->{M} } ) {
            $sum += get_node_values( $in->{C}->[ $m - 1 ] )
              if defined $in->{C}->[ $m - 1 ];
        }
    }
    else {
        $sum += sum @{ $in->{M} };
    }

    return $sum;
}
