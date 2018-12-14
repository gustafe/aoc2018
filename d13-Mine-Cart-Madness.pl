#! /usr/bin/env perl
# Advent of Code 2018 Day 13 - Mine Cart Madness - complete solution
# Problem link: http://adventofcode.com/2018/day/13
#   Discussion: http://gerikson.com/blog/comp/Advent-of-Code-2018.html#d13
#      License: http://gerikson.com/files/AoC2018/UNLICENSE
###########################################################
use Modern::Perl '2015';

# useful modules
use List::Util qw/sum/;
use Data::Dumper;

#use Clone qw/clone/;
#### INIT - load input data from file into array
my $testing = 0;
my $debug   = 0;
my @input;
my $file = $testing ? 'test.txt' : 'input.txt';
open( my $fh, '<', "$file" );
while (<$fh>) { chomp; s/\r//gm; push @input, $_; }

### CODE
my ( $X, $Y ) = ( 0, 1 );

my $Track;
my $Cars;

my %rail_types = map { $_ => 1 } qw {/ \ | - +  };
my %car_types  = map { $_ => 1 } qw {> < ^ v};

my $row = 0;
my $col;
my $car_id = 1;

while (@input) {
    my $curr = shift @input;
    $col = 0;
    foreach my $el ( split //, $curr ) {
        if ( defined $rail_types{$el} ) {
            $Track->[$col]->[$row] = $el;
        }
        elsif ( defined $car_types{$el} ) {

            # mark position on Track, but rail type currently unknown
            # it's given it's always on straight track

            if ( $el eq '>' or $el eq '<' ) {
                $Track->[$col]->[$row] = '-';
            }
            elsif ( $el eq '^' or $el eq 'v' ) {
                $Track->[$col]->[$row] = '|';
            }
            $Cars->{$car_id} =
              { x => $col, y => $row, dir => $el, turns => [qw/L S R/] };
            $car_id++;

        }
        $col++;
    }
    $row++;
}

my %turn_left  = ( '>' => '^', '^' => '<', '<' => 'v', 'v' => '>' );
my %turn_right = ( '>' => 'v', 'v' => '<', '<' => '^', '^' => '>' );

my %move = (
    '>' => sub { my ($p) = @_; return [ $p->[$X] + 1, $p->[$Y] ] },
    '<' => sub { my ($p) = @_; return [ $p->[$X] - 1, $p->[$Y] ] },
    '^' => sub { my ($p) = @_; return [ $p->[$X], $p->[$Y] - 1 ] },
    'v' => sub { my ($p) = @_; return [ $p->[$X], $p->[$Y] + 1 ] },
);

my %turn = (
    '-'  => sub { return $_[0] },
    '|'  => sub { return $_[0] },
    '/'  => \&turn_1,
    '\\' => \&turn_2,
    '+'  => \&crossroads
);

### MAIN LOOP

my $tick             = 0;
my $no_of_collisions = 0;
while (1) {
    my @removed;
    foreach my $id (
        sort {
                 $Cars->{$a}->{y} <=> $Cars->{$b}->{y}
              || $Cars->{$a}->{x} <=> $Cars->{$b}->{x}
        }
        keys %{$Cars}
      )
    {

        my ( $dir, $x, $y, $next_turn ) =
          map { $Cars->{$id}->{$_} } qw/dir x y turns/;

        my $newpos = $move{$dir}->( [ $x, $y ] );

        # collision?

        my @crash = grep {
            $Cars->{$_}->{x} == $newpos->[$X]
              and $Cars->{$_}->{y} == $newpos->[$Y]
        } keys %{$Cars};
        if (@crash) {
            if ( $no_of_collisions == 0 ) {
                say "Part 1: ", join( ',', @{$newpos} );
                $no_of_collisions++;
            }
            push @removed, ( @crash, $id );
        }

        # what's under the new position, do we have to change direction?

        my $type = $Track->[ $newpos->[$X] ]->[ $newpos->[$Y] ];

        die "off the rails at ", join( ',', @{$newpos} ) unless defined $type;

        my $newdir;

        if ( $type eq '+' ) {    # need to check which direction to choose
            my $choice = shift @{$next_turn};
            push @{$next_turn}, $choice;
            $newdir = $turn{$type}->( $dir, $choice );
        }
        else {
            $newdir = $turn{$type}->($dir);
        }

        # update this car with new info

        $Cars->{$id} = {
            x     => $newpos->[$X],
            y     => $newpos->[$Y],
            dir   => $newdir,
            turns => $next_turn
        };

    }
    if (@removed) {
        foreach my $car (@removed) {
            delete $Cars->{$car};
        }
    }
    if ( keys %{$Cars} == 1 ) {    # last one!

        #		print Dumper $Cars;
        say "Part 2: ", join ',',
          map { $Cars->{ ( keys %{$Cars} )[0] }->{$_} } qw/x y/;
        last;
    }

    $tick++;
}

### SUBS

sub turn_1 {    # denoted by /
    my %newdirs = ( '>' => '^', '<' => 'v', '^' => '>', 'v' => '<' );
    return $newdirs{ $_[0] };
}

sub turn_2 {    # denoted by \
    my %newdirs = ( '>' => 'v', '<' => '^', '^' => '<', 'v' => '>' );
    return $newdirs{ $_[0] };
}

sub crossroads {
    my ( $dir, $choice ) = @_;
    return $dir              if $choice eq 'S';
    return $turn_left{$dir}  if $choice eq 'L';
    return $turn_right{$dir} if $choice eq 'R';
}
