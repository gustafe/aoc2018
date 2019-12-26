#! /usr/bin/env perl
# Advent of Code 2018 Day 24 - Immune System Simulator 20XX  - complete solution
# Problem link: http://adventofcode.com/2018/day/24
#   Discussion: http://gerikson.com/blog/comp/Advent-of-Code-2018.html#d24
#      License: http://gerikson.com/files/AoC2018/UNLICENSE
###########################################################
use Modern::Perl '2015';

# useful modules
use List::Util qw/sum/;
use Data::Dumper;

#### INIT - load input data from file into array
my $testing = 0;
my $debug   = 0;
my @input;
my $file = $testing ? 'test.txt' : 'input.txt';
open( my $fh, '<', "$file" );
while (<$fh>) { chomp; s/\r//gm; push @input, $_; }

### CODE
my $boost = shift || 0;

# parse input

my $groups;    # keep one single record
my $id = 1;
my ( $immune_id, $infection_id ) = ( 1, 1 );
my $infection_section = 0;
my $type              = 1;
sub attacking_power;
sub dump_groups;
while (@input) {
    my $line = shift @input;
    next if length($line) == 0;
    next if $line =~ m/^Immune/;
    if ( $line =~ m/Infection:/ ) {
        $infection_section = 1;
        $type              = -1;
        next;
    }
    my ( $units, $hp, $attack, $attack_type, $initiative );
    my $item;
    if ( $line =~
m/^(\d+) units each with (\d+) hit points \((.*)\) with an attack that does (\d+) (\S+) damage at initiative (\d+)$/
      )
    {
        #	say "$1 $2 $3 $4 $5 $6";
        $item = {
            units       => $1,
            hp          => $2,
            attack      => $4,
            attack_type => $5,
            initiative  => $6
        };

        my @attributes = split( /;/, $3 );
        foreach my $attribute (@attributes) {
            if ( $attribute =~ m/^\ ?(\S+) to (.*)$/ ) {
                my $id = $1;
                my @types = split( /\,/, $2 );
                foreach my $t (@types) {
                    $t =~ s/^\s+//;
                    $item->{attribute}->{$id}->{$t}++;
                }

            }
            else {
                die "can't parse attribute: $attribute";
            }
        }

    }
    elsif ( $line =~
m/(\d+) units each with (\d+) hit points with an attack that does (\d+) (\S+) damage at initiative (\d+)$/
      )
    {
        $item = {
            units       => $1,
            hp          => $2,
            attack      => $3,
            attack_type => $4,
            initiative  => $5
        };

    }
    else {
        die "can't parse: $line";
    }
    my $label;
    if ($infection_section) {
        $label = "Infection group " . $infection_id;

        $infection_id++;
    }
    else {
        $label = "Immune group " . $immune_id;
        $immune_id++;
    }
    $groups->{$id}          = $item;
    $groups->{$id}->{label} = $label;
    $groups->{$id}->{type}  = $type;

    $id++;
}

# apply boost
foreach my $id ( keys %$groups ) {
    if ( $groups->{$id}->{type} == 1 ) {
        $groups->{$id}->{attack} += $boost;
    }
}

# find attack multipliers
my $multipliers;
foreach my $id ( keys %$groups ) {
    foreach my $id2 ( keys %$groups ) {
        next if ( $id == $id2 );
        next if ( $groups->{$id}->{type} eq $groups->{$id2}->{type} );

        if (
            exists $groups->{$id2}->{attribute}->{weak}
            ->{ $groups->{$id}->{attack_type} } )
        {
            $multipliers->{$id}->{$id2} = 2;
        }
        elsif (
            exists $groups->{$id2}->{attribute}->{immune}
            ->{ $groups->{$id}->{attack_type} } )
        {
            $multipliers->{$id}->{$id2} = 0;
        }
        else {
            $multipliers->{$id}->{$id2} = 1;
        }
    }
}

# selection phase
sub effective_power {
    my ($id) = @_;
    if ( $groups->{$id}->{units} <= 0 ) {
        return 0;
    }
    else {
        return $groups->{$id}->{units} * $groups->{$id}->{attack};
    }

}
my $round = 1;
LOOP: while (1) {

    my %targets;
    my %filter;
    foreach my $id (
        sort {
            effective_power($b) <=> effective_power($a)
              || $groups->{$b}->{initiative} <=> $groups->{$a}->{initiative}
        }
        keys %$groups
      )
    {
        my @opponents =
          grep { !exists $filter{$_} }
          grep { $multipliers->{$id}->{$_} > 0 }
          sort {
            effective_power($id) * $multipliers->{$id}->{$b}
              <=> effective_power($id) * $multipliers->{$id}->{$a}
              || effective_power($b) <=> effective_power($a)
              || $groups->{$b}->{initiative} <=> $groups->{$a}->{initiative}
          } keys %{ $multipliers->{$id} };
        if ($debug) {
            foreach my $opponent (@opponents) {
                printf(
                    "%s would deal defending %s %d damage\n",
                    $groups->{$id}->{label},
                    $groups->{$opponent}->{label},
                    effective_power($id) * $multipliers->{$id}->{$opponent}
                ) if $debug;
            }
        }
        next unless scalar @opponents;
        $targets{$id} = $opponents[0];
        %filter = reverse %targets;
    }

    # attacking phase

    # perform attacks in desc initiative order
    foreach my $attacker (
        sort { $groups->{$b}->{initiative} <=> $groups->{$a}->{initiative} }
        keys %targets )
    {
        my $defender = $targets{$attacker};

        # need to recompute power here, attacker may have lost units
        my $power =
          effective_power($attacker) * $multipliers->{$attacker}->{$defender};
        my $kills = int( $power / $groups->{$defender}->{hp} );
        say
"$groups->{$attacker}->{label} attacks $groups->{$defender}->{label}, killing $kills units"
          if $debug;
        $groups->{$defender}->{units} -= $kills;
    }
    my @counts = ( 0, 0 );
    say "ROUND: $round" if $debug;
    foreach my $id ( sort { $a <=> $b } keys %$groups ) {
        if ( $groups->{$id}->{units} <= 0 )
        {    # no units remain, remove this group
            say "no units remain in $groups->{$id}->{label}, deleting!"
              if $debug;
            delete $multipliers->{$id};
            foreach my $id2 ( keys %$multipliers ) {
                if ( exists $multipliers->{$id2}->{$id} ) {
                    delete $multipliers->{$id2}->{$id};
                }
            }
            delete $groups->{$id};
            next;

        }
        say join( ' ', map { "$_: $groups->{$id}->{$_}" } qw/label units/ )
          if $debug;
        $counts[0]++ if $groups->{$id}->{type} == -1;
        $counts[1]++ if $groups->{$id}->{type} == 1;
    }
    $round++;
    last LOOP if ( $counts[0] == 0 or $counts[1] == 0 );
}
my $sum;
my $types;
foreach my $id ( keys %$groups ) {
    $sum   += $groups->{$id}->{units};
    $types += $groups->{$id}->{type};
}
say $types< 0 ? "Infection" : "Immune", " win: $sum units remaining";

