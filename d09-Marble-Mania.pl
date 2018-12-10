#! /usr/bin/env perl
# Advent of Code 2018 Day 9 - Marble Mania - complete solution
# Problem link: http://adventofcode.com/2018/day/9
#   Discussion: http://gerikson.com/blog/comp/Advent-of-Code-2018.html#d09
#      License: http://gerikson.com/files/AoC2018/UNLICENSE
###########################################################
use Modern::Perl '2015';

# useful modules
use List::Util qw/sum max/;

#### INIT - load input data from file into array
my $testing = 0;
my $debug   = 0;
my @input;
my $file = $testing ? 'test.txt' : 'input.txt';
open( my $fh, '<', "$file" );
while (<$fh>) { chomp; s/\r//gm; push @input, $_; }

### CODE
my ( $no_of_players, $last_marble ) =
  $input[0] =~ /^(\d+).* worth (\d+) points/;

# give an argument, any argument, for part 2
my $part2 = shift @ARGV // undef;

my @players = ( 1 .. $no_of_players );
my %score;
sub add_to_circle;
sub remove_from_circle;
sub print_circle;

# initialize our data structure (circular double-linked list
my $circle->{0} = { next => 0, prev => 0 };
my $current = 0;
$last_marble = 100 * $last_marble if $part2;
my @marbles = ( 1 .. $last_marble );
while (@marbles) {

    my @list = @players;

    # play
    while (@list) {
        my $current_player = shift @list;
        my $marble         = shift @marbles;
        last unless defined $marble;    # don't overrun the number of marbles!
        if ( $marble % 23 == 0 ) {
            my $removed = remove_from_circle;
            $score{$current_player} += ( $marble + $removed );
        }
        else {
            $current = add_to_circle($marble);
        }
    }
}

say 'Part ', $part2 ? '2: ' : '1: ', max values %score;

sub add_to_circle {
    my ($new_val) = @_;
    my $one       = $circle->{$current}->{next};
    my $two       = $circle->{$one}->{next};

    # insert between one and two
    $circle->{$new_val}->{prev} = $one;
    $circle->{$new_val}->{next} = $two;

    $circle->{$one}->{next} = $new_val;
    $circle->{$two}->{prev} = $new_val;
    return $new_val;
}

sub remove_from_circle {

    my $steps   = 0;
    my $pointer = $current;

    # hardcoded 7 steps
    while ( $steps < 7 ) {
        $pointer = $circle->{$pointer}->{prev};
        $steps++;
    }

    my $prev = $circle->{$pointer}->{prev};
    my $next = $circle->{$pointer}->{next};

    $circle->{$prev}->{next} = $next;
    $circle->{$next}->{prev} = $prev;
    $current                 = $next;
    delete $circle->{$pointer};
    return $pointer;
}

sub print_circle {
    my $start = 0;
    my @list;
    push @list, $start;
    my $next = $circle->{$start}->{next};
    while ($next) {
        $next = $circle->{$start}->{next};
        push @list, $next;
        $start = $next;
    }
    pop @list;
    say join( ' ', @list );
}
