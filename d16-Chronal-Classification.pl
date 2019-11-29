#! /usr/bin/env perl
# Advent of Code 2018 Day 16 - Chronal Classification - complete solution
# Problem link: http://adventofcode.com/2018/day/16
#   Discussion: http://gerikson.com/blog/comp/Advent-of-Code-2018.html#d16
#      License: http://gerikson.com/files/AoC2018/UNLICENSE
###########################################################

use Modern::Perl '2015';

#### INIT - load input data from file into array
my $testing = 0;
my @input;
my $debug = 0;
my $file = $testing ? 'test.txt' : 'input.txt';
open( my $fh, '<', "$file" );
while (<$fh>) { chomp; s/\r//gm; push @input, $_; }

### CODE
# parse the input, we have 2 separate sections
my @events;
my $is_token = 0;
my $event;
my @program;
foreach my $line (@input) {
    if ( $line =~ m/^Before: \[(.*)\]/ ) {
        $is_token = 1;
        my $str = $1;
        $str =~ s/\,//g;
        push @{$event}, [ split( / /, $str ) ];
    }
    elsif ( $is_token and $line =~ m/^(\d+.*)/ ) {
        push @{$event}, [ split( / /, $1 ) ];
    }
    elsif ( $is_token and $line =~ m/^After:  \[(.*)\]/ ) {
        my $str = $1;
        $str =~ s/\,//g;
        push @{$event}, [ split( / /, $str ) ];
        push @events, $event;
        $is_token = 0;
        $event    = undef;
    }
    elsif ( !$is_token and $line =~ m/^(\d+.*)/ ) {
        push @program, [ split( / /, $1 ) ];
    }
}
my @Reg = ( 0, 0, 0, 0 );
sub compare_registers;


my ( $A, $B, $C ) = ( 0, 1, 2 );
my %ops = (
    addi => sub { $Reg[ $_[$C] ] = $Reg[ $_[$A] ] + $_[$B] },
    addr => sub { $Reg[ $_[$C] ] = $Reg[ $_[$A] ] + $Reg[ $_[$B] ] },
    bani => sub { $Reg[ $_[$C] ] = $Reg[ $_[$A] ] & $_[$B] },
    banr => sub { $Reg[ $_[$C] ] = $Reg[ $_[$A] ] & $Reg[ $_[$B] ] },
    bori => sub { $Reg[ $_[$C] ] = $Reg[ $_[$A] ] | $_[$B] },
    borr => sub { $Reg[ $_[$C] ] = $Reg[ $_[$A] ] | $Reg[ $_[$B] ] },
    eqir => sub { $Reg[ $_[$C] ] = $_[$A] == $Reg[ $_[$B] ] ? 1 : 0 },
    eqri => sub { $Reg[ $_[$C] ] = $Reg[ $_[$A] ] == $_[$B] ? 1 : 0 },
    eqrr => sub { $Reg[ $_[$C] ] = $Reg[ $_[$A] ] == $Reg[ $_[$B] ] ? 1 : 0 },
    gtir => sub { $Reg[ $_[$C] ] = $_[$A] > $Reg[ $_[$B] ] ? 1 : 0 },
    gtri => sub { $Reg[ $_[$C] ] = $Reg[ $_[$A] ] > $_[$B] ? 1 : 0 },
    gtrr => sub { $Reg[ $_[$C] ] = $Reg[ $_[$A] ] > $Reg[ $_[$B] ] ? 1 : 0 },
    muli => sub { $Reg[ $_[$C] ] = $Reg[ $_[$A] ] * $_[$B] },
    mulr => sub { $Reg[ $_[$C] ] = $Reg[ $_[$A] ] * $Reg[ $_[$B] ] },
    seti => sub { $Reg[ $_[$C] ] = $_[$A] },
    setr => sub { $Reg[ $_[$C] ] = $Reg[ $_[$A] ] },
);

my @results;
my %stats;
while (@events) {
    my $event = shift @events;

    my ( $before, $instr, $after ) = @{$event};
    my $count = 0;
    foreach my $op ( sort keys %ops ) {
        @Reg = @{$before};
        my $test = $ops{$op}->( @{$instr}[ 1, 2, 3 ] );
        printf(
            "[%s] [%s] - %s - [%s] (%s)\n",
            $op,
            join( ',', @{$before} ),
            join( ',', @{$instr} ),
            join( ',', @{$after} ),
            join( ',', @Reg )
        ) if $testing;
        my $ok =
          (      $Reg[0] == $after->[0]
              && $Reg[1] == $after->[1]
              && $Reg[2] == $after->[2]
              && $Reg[3] == $after->[3] ) ? 1 : 0;
        say $ok ? 'OK' : 'XX' if $debug;
        $count++ if $ok;
        $stats{ $instr->[0] }->{$op}++ if $ok;

    }
    say ">> $count" if $testing;
    push @results, $count if $count >= 3;
}

#say join(',',@results);
say "Part 1: ", scalar @results;

my %solution;
while ( keys %stats ) {
    foreach my $id ( keys %stats ) {
        if ( scalar keys %{ $stats{$id} } == 1 ) {    # found a lone op
            my $op = ( keys %{ $stats{$id} } )[0];
            say ">> found lone op $op at $id" if $debug;

            $solution{$id} = $op;
            delete $stats{$id};
        }

        # remove existing known ops
        while ( my ( $k, $op ) = each %solution ) {
            foreach my $v ( keys %{ $stats{$id} } ) {
                if ( $v eq $op ) {

                    #	    say ">> found $v matching $op, deleting...";
                    delete $stats{$id}->{$v};
                }

            }
        }

        # check for empty sets
        if ( scalar keys %{ $stats{$id} } == 0 ) {
            delete $stats{$id};
        }
    }

}
@Reg = (0,0,0,0);
while ( @program ) {
    my $instr = shift @program;
    my $op    = $solution{ $instr->[0] };
    $ops{$op}->( @{$instr}[ 1, 2, 3 ] );
}
say "Part 2: ", $Reg[0];
