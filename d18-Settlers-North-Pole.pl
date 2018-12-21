#! /usr/bin/env perl
# Advent of Code 2018 Day 18 - Settlers of The North Pole - complete solution
# Problem link: http://adventofcode.com/2018/day/18
#   Discussion: http://gerikson.com/blog/comp/Advent-of-Code-2018.html#d18
#      License: http://gerikson.com/files/AoC2018/UNLICENSE
###########################################################

use Modern::Perl '2015';

# useful modules
use Clone qw/clone/;
use Digest::MD5 qw/md5_hex/;
#### INIT - load input data from file into array
my $testing = 0;
my $debug   = 0;
my @input;
my $file = $testing ? 'test.txt' : 'input.txt';
open( my $fh, '<', "$file" );
while (<$fh>) { chomp; s/\r//gm; push @input, $_; }

### CODE
my $Map;
my ( $X,    $Y )    = ( 0, 1 );
my ( $xmax, $ymax ) = ( 0, 0 );
my $row = 0;
while (@input) {
    my @line = split( //, shift @input );
    my $col = 0;
    foreach my $el (@line) {
        $Map->{$col}->{$row} = $el;
        $col++;
        $xmax = $col if $col > $xmax;
    }
    $row++;
}
$ymax = $row;

sub dump_state;
sub map_digest;
sub map_value;

my %generate = (
    '.' => \&open_field,
    '#' => \&lumberyard,
    '|' => \&forest,
);

if ($testing) {

    say "Initial state:";
    dump_state;
    say '';
}
my $count = 0;
my %stats;
my @list;
my %sequences;
my $Id;
my $part_2;
while ( $count < 1000 ) {


    my $Next;
    foreach my $x ( 0 .. $xmax - 1 ) {
        foreach my $y ( 0 .. $ymax - 1 ) {
            my $type = $Map->{$x}->{$y};

            # find neighbors
            my $neighbors;
            $neighbors = find_neighbors( [ $x, $y ] );

            $Next->{$x}->{$y} = $generate{$type}->($neighbors);
        }
    }

    $Map = clone $Next;

    # gather data for the sequence detection
    my $md5 = map_digest;
    my $val = map_value;

    say "Part 1: $val" if $count == 9;
    
    if ( exists $sequences{$md5} ) {
        my $cycle_length = $count - $sequences{$md5}->{count};
        $part_2 = $sequences{$md5}->{count} +
          ( 1_000_000_000 - 1 - $count ) % $cycle_length;
        say "Part 2: ", $list[$part_2];
        last;

    }
    $sequences{$md5}->{val}   = $val;
    $sequences{$md5}->{count} = $count;
    push @list, $val;
    if ($testing) {

        say "After ", $count + 1, " minutes:";
        dump_state;

        say '';
    }
    $count++;
}

#### SUBS

sub map_value {    # as per problem definition
    my ( $forest, $lumber ) = ( 0, 0 );
    foreach my $x ( keys %{$Map} ) {
        foreach my $y ( keys %{ $Map->{$x} } ) {
            $forest++ if $Map->{$x}->{$y} eq '|';
            $lumber++ if $Map->{$x}->{$y} eq '#';
        }
    }
    return $forest * $lumber;
}

sub map_digest {
    my $string;
    foreach my $x ( sort { $a <=> $b } keys %{$Map} ) {
        foreach my $y ( sort { $a <=> $b } keys %{ $Map->{$x} } ) {
            $string .= $Map->{$x}->{$y};
        }
    }
    return md5_hex($string);
}

sub forest {
    my ($n) = @_;
    if ( exists $n->{'#'} and $n->{'#'} >= 3 ) {
        return '#';
    }
    else {
        return '|';
    }
}

sub lumberyard {
    my ($n) = @_;
    if (    ( exists $n->{'#'} and $n->{'#'} >= 1 )
        and ( exists $n->{'|'} and $n->{'|'} >= 1 ) )
    {
        return '#';
    }
    else {
        return '.';
    }
}

sub open_field {
    my ($n) = @_;
    if ( exists $n->{'|'} and $n->{'|'} >= 3 ) {
        return '|';
    }
    else {
        return '.';
    }
}

sub find_neighbors {
    my ($point) = @_;
    my $result;
    for my $i ( -1, 0, 1 ) {
        for my $j ( -1, 0, 1 ) {
            next if ( $i == 0 and $j == 0 );    # skip point itself
            my $m = $Map->{ $point->[$X] + $i }->{ $point->[$Y] + $j };
            $m = defined $m ? $m : '_';
            printf "(%2d,%2d) -> (%2d,%2d) %s\n",
              @{$point}, $point->[$X] + $i, $point->[$Y] + $j, $m
              if $debug;

            $result->{$m}++;
        }
    }
    printf "(%2d,%2d) %s\n", $point->[$X], $point->[$Y],
      join( ' ', map { "$_ => $result->{$_}" } sort keys %{$result} )
      if $debug;
    return $result;
}

sub dump_state {
    foreach my $row ( 0 .. $ymax - 1 ) {
        foreach my $col ( 0 .. $xmax - 1 ) {
            print $Map->{$col}->{$row};
        }
        print "\n";
    }
}
