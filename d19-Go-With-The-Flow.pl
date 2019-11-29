#! /usr/bin/env perl
# Advent of Code 2018 Day 19 - Go With The Flow - complete solution
# Problem link: http://adventofcode.com/2018/day/19
#   Discussion: http://gerikson.com/blog/comp/Advent-of-Code-2018.html#d19
#      License: http://gerikson.com/files/AoC2018/UNLICENSE
###########################################################

use Modern::Perl '2015';

# useful modules
use List::Util qw/sum/;


#### INIT - load input data from file into array
my $testing = 0;
my $debug   = 0;
my @input;

my $file = $testing ? 'test.txt' : 'input.txt';
open( my $fh, '<', "$file" );
while (<$fh>) { chomp; s/\r//gm; push @input, $_; }

### CODE
my $Ip = 0;
my $ipval;
my @Reg = ( 0, (0) x 5 );
my @instr;
while (@input) {
    my $line = shift @input;
    if ( $line =~ m/^\#ip (\d+)$/ ) {
        $ipval = $1;
    }
    elsif ( $line =~ m/^(....) (\d+) (\d+) (\d+)$/ ) {
        push @instr, [ $1, $2, $3, $4 ];
    }
    else {
        die "can't parse $line !";
    }
}
my ( $A, $B, $C ) = ( 0, 1, 2 );

my $counter = 0;
say "Instruction pointer: $ipval" if $debug;

my %ops = (
    addi => \&addi,
    addr => \&addr,
    bani => sub { $Reg[ $_[$C] ] = $Reg[ $_[$A] ] & $_[$B] },
    banr => sub { $Reg[ $_[$C] ] = $Reg[ $_[$A] ] & $Reg[ $_[$B] ] },
    bori => sub { $Reg[ $_[$C] ] = $Reg[ $_[$A] ] | $_[$B] },
    borr => sub { $Reg[ $_[$C] ] = $Reg[ $_[$A] ] | $Reg[ $_[$B] ] },
    eqir => sub { $Reg[ $_[$C] ] = $_[$A] == $Reg[ $_[$B] ] ? 1 : 0 },
    eqri => sub { $Reg[ $_[$C] ] = $Reg[ $_[$A] ] == $_[$B] ? 1 : 0 },
    eqrr => \&eqrr,
    gtir => sub { $Reg[ $_[$C] ] = $_[$A] > $Reg[ $_[$B] ] ? 1 : 0 },
    gtri => sub { $Reg[ $_[$C] ] = $Reg[ $_[$A] ] > $_[$B] ? 1 : 0 },
    gtrr => \&gtrr,
    muli => \&muli,
    mulr => \&mulr,
    seti => \&seti,
    setr => \&setr,
);

my %stats;

my @before;

my $count = 0;

while ( ( $Ip >= 0 or $Ip <= $#instr ) ) {
    $stats{$Ip}++;
    my $working = $instr[$Ip];
    @before = @Reg;

    # execute the instruction
    $Reg[$ipval] = $Ip;
    last unless defined $ops{ $working->[0] };

    # return value used for debugging output
    my $pp = $ops{ $working->[0] }->( @{$working}[ 1, 2, 3 ] );
    if ($debug) {
        printf "ip=%2d %12s | %-20s [%s]\n", $Ip, join( ' ', @{$working} ), $pp,
          join( ',', @Reg );

    }

    $Ip = $Reg[$ipval];
    $Ip++;
    $count++;
}

if ($debug) {

    foreach ( my $idx = 0 ; $idx <= $#instr ; $idx++ ) {
        printf( "%2d [%s] %d\n",
            $idx, join( ' ', @{ $instr[$idx] } ),
            $stats{$idx} );
    }
}
say "Part 1 (brute force): ", $before[0];

#### Part 2

# Algo computes the sum of divisors of value in $Reg[4]

@Reg = ( 1, (0) x 5 );
$Ip = 0;

while ( ( $Ip >= 0 or $Ip <= $#instr ) ) {
    my $working = $instr[$Ip];
    @before = @Reg;

    # execute the instruction
    $Reg[$ipval] = $Ip;
    last unless defined $ops{ $working->[0] };

    my $pp = $ops{ $working->[0] }->( @{$working}[ 1, 2, 3 ] );

    #    last if ($pp eq 'GOTO 1'); # we've reached end of init phase
    last if $Reg[$ipval] == 1;
    $Ip = $Reg[$ipval];
    $Ip++;

}
my $num = $Reg[4];
# https://www.perlmonks.org/?node_id=371578
my @divisors = grep { $num % $_ == 0 } 1 .. $num;
say "Part 2 (calculated) : ", sum @divisors;

### SUBS

sub addi {
    my $i = $Reg[ $_[$A] ];
    my $j = $_[$B];
    $Reg[ $_[$C] ] = $Reg[ $_[$A] ] + $_[$B];
    if ( $_[$C] == $ipval ) {
        return sprintf "GOTO %d", $i + $j + 1;
    }
    else {
        return sprintf "R[%d] = %d+%d", $_[$C], $i, $j;
    }
}

sub addr {
    my ( $i, $j ) = ( $Reg[ $_[$A] ], $Reg[ $_[$B] ] );
    $Reg[ $_[$C] ] = $Reg[ $_[$A] ] + $Reg[ $_[$B] ];
    my $str;
    if ( $_[$C] == $ipval ) {
        $str = sprintf "GOTO %d", $i + $j + 1;
    }
    else {
        $str = sprintf "R[%d] = %d+%d", $_[$C], $i, $j;
    }
    return $str;
}

sub eqrr {
    my ( $i, $j ) = ( $Reg[ $_[$A] ], $Reg[ $_[$B] ] );
    $Reg[ $_[$C] ] = $Reg[ $_[$A] ] == $Reg[ $_[$B] ] ? 1 : 0;
    if ( $i == $j ) {
        return sprintf "%d==%d => R[%d] = 1", $i, $j, $_[$C];
    }
    else {
        return sprintf "%d!=%d => R[%d] = 0", $i, $j, $_[$C];
    }
}

sub gtrr {
    my ( $i, $j ) = ( $Reg[ $_[$A] ], $Reg[ $_[$B] ] );
    $Reg[ $_[$C] ] = $Reg[ $_[$A] ] > $Reg[ $_[$B] ] ? 1 : 0;
    if ( $i > $j ) {
        return sprintf "%d >%d => R[%d] = 1", $i, $j, $_[$C];
    }
    else {
        return sprintf "%d!>%d => R[%d] = 0", $i, $j, $_[$C];
    }

}

sub mulr {
    my ( $i, $j ) = ( $Reg[ $_[$A] ], $Reg[ $_[$B] ] );

    $Reg[ $_[$C] ] = $Reg[ $_[$A] ] * $Reg[ $_[$B] ];
    if ( $_[$C] == $ipval ) {
        return sprintf "GOTO %d", $i * $j + 1;
    }
    else {
        return sprintf "R[%d] = %d*%d", $_[$C], $i, $j;
    }
}

sub muli {
    my ( $i, $j ) = ( $Reg[ $_[$A] ], $_[$B] );

    $Reg[ $_[$C] ] = $Reg[ $_[$A] ] * $_[$B];
    if ( $_[$C] == $ipval ) {
        return sprintf "GOTO %d", $i * $j + 1;
    }
    else {
        return sprintf "R[%d] = %d*%d", $_[$C], $i, $j;
    }
}

sub seti {
    my $i = $_[$A];
    $Reg[ $_[$C] ] = $_[$A];
    if ( $_[$C] == $ipval ) {
        return sprintf "GOTO %d", $i + 1;
    }
    else {
        return sprintf "R[%d] = %d", $_[$C], $i;
    }

}

sub setr {
    my $i = $Reg[ $_[$A] ];
    $Reg[ $_[$C] ] = $Reg[ $_[$A] ];
    return sprintf "R[%d] = %d", $_[$C], $i;
}

