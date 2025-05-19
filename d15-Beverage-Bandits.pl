#! /usr/bin/env perl
# Advent of Code 2018 Day 15 - Beverage Bandits - complete solution
# https://adventofcode.com/2018/day/15
# https://gerikson.com/files/AoC2018/UNLICENSE
###########################################################

use Modern::Perl '2015';
# useful modules
use List::Util qw/max sum/;
use Data::Dump qw/dump/;
use Clone qw/clone/;
use Test::More;
use Time::HiRes qw/gettimeofday tv_interval/;
sub sec_to_hms;

my $part2 = 0;

my $start_time = [gettimeofday];
#### INIT - load input data from file into array
my $file_no = shift @ARGV || 0;
my $testing = 0;
my $debug = 0;

my @input;
my $file;
if ($file_no and $file_no<=6) {
    $testing = 1;
    $file = "test_combat_".$file_no.".txt";
} else {
   $file = $testing ? 'test_pathing.txt' : 'input.txt'; 
}


open( my $fh, '<', "$file" );
while (<$fh>) { chomp; s/\r//gm; push @input, $_; }

### CODE
my $Map;
my $attack_power = 3;
my @dirs = ([-1,0],[0,-1],[0,1],[1,0]);
my $initial_positions;
my $row=0;
for my $line (@input) {
    my $col = 0;
    for my $char (split(//, $line)) {
	if ($char eq 'E' or $char eq 'G') {
	    $initial_positions->{$row}{$col} = {type=> $char, hp=>200};
	    $Map->{$row}{$col} = '.';
	} else {
	    $Map->{$row}{$col} = $char;
	}
	$col++;
    }
    $row++;
}

my $maxrow = max keys %$Map;
my $maxcol = max keys %{$Map->{$maxrow}};

my %test_data = (
		 1 => { ap => 15,
			map=>'########..E..##...E.##.#.#.##...#.##.....########',
			ans=>4988, turns=>29, sum=> 172},
#		 2=>{map=>'########...#E##E#...##.E##.##E..#E##.....########',		    ans=>36334, turns=> 37, sum=>982},
		 3=>{map=>'########.E.E.##.#E..##E.##E##.E.#.##...#.########',
		     		     ap=>4,
		     ans=>31284, turns=>33, sum=>948},
		 4=>{map=>'########.E.#.##.#E..##..#..##...#.##.....########',
		     ap=>15,
		     ans=>3478, turns=> 37, sum=>94},
		 5=>{map=>'########...E.##.#..E##.###.##.#.#.##...#.########',
		     ap=>12,
		     ans=>6474, turns=>39, sum=>166},
		 6=>{map=>'##########.......##.E.#...##..##...##...##..##...#...##.......##.......##########',
		     ap=>34,
		     ans=>1140, turns=>30, sum=>38},
		);
if ($file =~ /test_combat_(\d+)\.txt/) {
#    say join("\t", $turns, $test_data{$1}->{turns});
#    say join("\t", $sum, $test_data{$1}->{sum});
    my $res = simulate( $test_data{$1}->{ap});
    my $correct= $test_data{$1}->{map};
    my $check = $test_data{$1}->{ans};
    dump $res;
    is( $res->{mapstring}, $correct, "map for $file correct");
    is($res->{ans}, $check, "result for $file correct");
}

if ($testing) {
    done_testing();
    exit 0;
} else {
    my $res;
    if ($part2) {

	$res = simulate( 16 )
    } else {
	$res = simulate( 3 );
    }


    my $ans = $res->{ans};

    if ($part2) {
	is($ans, 52374, "Part 2: $ans");
    } else {
	is($ans, 215168, "Part 1: $ans");
    }
}



#my $result = simulate(15);
#dump $result;
#my ($sum,$turns,$ans,$mapstring) = map {$result->{$_}} qw/sum turns ans mapstring/;


#is($ans, 215168, "Part 1: $ans") unless $testing;
done_testing();
say sec_to_hms(tv_interval($start_time));

### SUBS

sub simulate {
    my ( $elf_power ) = @_;
    my $turn = 0;
    my $positions = clone $initial_positions;
    my $current_map;
    my $no_elves=0;
    my $elf_died=0;
    for my $row(0..$maxrow) {
	for my $col (0..$maxcol) {
	    if ($positions->{$row}{$col}) {
		$current_map->{$row}{$col} = $positions->{$row}{$col}{type};
		$no_elves++ if $positions->{$row}{$col}{type} eq 'E';
	    } else {
		$current_map->{$row}{$col} = $Map->{$row}{$col};
	    }
	}
    }
    my $seen;
    my $removed;
    my $mapstring;

    TURN: while (1) {

	  my $players;
	  my @move_order;
	  my $no_moved =0;
	  $attack_power=3;
	  for my $r (sort {$a<=>$b} keys %{$positions}) {
	      for my $c (sort {$a<=>$b} keys %{$positions->{$r}}) {
		  push @move_order, {type=>$positions->{$r}{$c}{type},
				     pos=>[$r,$c],
				     hp=>$positions->{$r}{$c}{hp},};
		  $players->{$positions->{$r}{$c}{type}}++;
	      }
	  }
	  last TURN unless ( $players->{E} and $players->{G} );
	  if ($players->{E} != $no_elves and $part2) {
	      $elf_died = 1;
	      last TURN;
	  }
	  my @marked_for_deletion;
	ACTOR: for my $idx (0..$#move_order) {
	      my $actor = $move_order[$idx];
	      if (@marked_for_deletion) {
		  for my $del (@marked_for_deletion) {
		      if ($actor->{pos}[0] == $del->[0] and
			  $actor->{pos}[1] == $del->[1]) {
			  next ACTOR;
		      }
		  }
	      }
	      my @candidates;
	      my @defenders;
	      for my $d (@dirs) {
		  my $pos = $actor->{pos};
		  if ($current_map->{$pos->[0]+$d->[0]}{$pos->[1]+$d->[1]} eq '.') {
		      push @candidates, [$pos->[0]+$d->[0],$pos->[1]+$d->[1]];
		  } elsif ($current_map->{$pos->[0]+$d->[0]}{$pos->[1]+$d->[1]} ne '#' and
			   $current_map->{$pos->[0]+$d->[0]}{$pos->[1]+$d->[1]} ne $actor->{type} ) {
		      push @defenders, [$positions->{$pos->[0]+$d->[0]}{$pos->[1]+$d->[1]}{hp}, $pos->[0]+$d->[0],$pos->[1]+$d->[1]];
		  }
	      }
	      # attack or move? 
	      if (@defenders) {
		  #	    say stringify_unit( $actor) . " has defenders adjacent, will attack";
		  @defenders = sort {$a->[0]<=>$b->[0] ||
				       $a->[1]<=>$b->[1]||
				       $a->[2]<=>$b->[2] }@defenders ;
		  my $def = $defenders[0];
		  if ($actor->{type} eq 'E') {
		      $attack_power = $elf_power
		  } else {
		      $attack_power = 3
		  }
		  $positions->{$def->[1]}{$def->[2]}{hp} -= $attack_power;
		  printf("unit type %s at [%d,%d] has HP %d\n",
			 $positions->{$def->[1]}{$def->[2]}{type},
			 $def->[1],$def->[2],$positions->{$def->[1]}{$def->[2]}{hp}) if $debug;
		  if ($positions->{$def->[1]}{$def->[2]}{hp}<=0) {
		      printf("unit type %s at [%d,%d] has HP %d, will be removed\n",		   $positions->{$def->[1]}{$def->[2]}{type},
			     $def->[1],$def->[2],$positions->{$def->[1]}{$def->[2]}{hp}) if $debug;
		      $players->{$positions->{$def->[1]}{$def->[2]}{type}}--;
		      push @marked_for_deletion, [$def->[1], $def->[2]];
		      delete $positions->{$def->[1]}{$def->[2]};
		      $current_map->{$def->[1]}{$def->[2]} = '.';
		  }
		  next ACTOR;
	      }
	      last TURN unless ($players->{E} and $players->{G});
	      if ($players->{E} != $no_elves and $part2) {
		  $elf_died = 1;
		  last TURN;
	      }

	      my @targets;
	      for my $r (0..$maxrow) {
		  for my $c (0..$maxcol) {
		      if ($current_map->{$r}{$c} ne '.' and $current_map->{$r}{$c} ne '#' and
			  $current_map->{$r}{$c} ne $actor->{type}) {
			  my $epos = [$r,$c];
			  for my $d (@dirs) {
			      if ($current_map->{$epos->[0]+$d->[0]}{$epos->[1]+$d->[1]} eq '.') {
				  push @targets, [$epos->[0]+$d->[0], $epos->[1]+$d->[1]];
			      }
			  }
		      }
		  }
	      }
	      
	      if (!@targets) {
		  #	    say stringify_unit( $actor) . " can't find targets to move towards";
		  next ACTOR;
	      }
	      my @distances;
	      if (@candidates and @targets) {
		  for my $start (sort {$a->[0] <=> $b->[0] || $a->[1] <=> $b->[1]} @candidates) {
		      for my $end (sort {$a->[0] <=> $b->[0] || $a->[1] <=> $b->[1]} @targets) {
			  if ($start->[0] == $end->[0] and $start->[1] == $end->[1]) {
			      push @distances, [1, $start, $end]
			  } else {
			      my $dist = find_path( $current_map, $start ,$end);
			      if (defined $dist) {
				  push @distances, [$dist, $start, $end];
			      }
			  }
		      }
		  }
		  if (!@distances) {
		      #		say stringify_unit($actor) . " no valid distances found";
		      
		  } else {
		      #		printf("%s has %2d distances\n",		       stringify_unit($actor), scalar @distances);

		      @distances = sort {$a->[0] <=> $b->[0] ||
					   $a->[1][0] <=> $b->[1][0] ||
					   $a->[1][1] <=> $b->[1][1] } @distances;
		      # move actor to new position
		      my $selected = $distances[0];
		      my $newpos = $selected->[1];
		      printf("%s moved to [%d,%d]\n",
			     stringify_unit($actor), @{$newpos}) if $debug;
		      delete $positions->{$actor->{pos}[0]}{$actor->{pos}[1]};
		      $positions->{$newpos->[0]}{$newpos->[1]} = {type=> $actor->{type},
								  hp => $actor->{hp}};
		      $seen->{$newpos->[0]}{$newpos->[1]}++;
		      $current_map->{$actor->{pos}[0]}{$actor->{pos}[1]}='.';
		      $current_map->{$newpos->[0]}{$newpos->[1]} = $actor->{type};
		      $no_moved++;
		      # special case for moving 1 step towards a target - can we attack?
		      if ($selected->[0] == 1) {
			  my @defenders;
			  # check for enemies
			  for my $d (@dirs) {
			      if ($current_map->{$newpos->[0]+$d->[0]}{$newpos->[1]+$d->[1]} ne '#' and
				  $current_map->{$newpos->[0]+$d->[0]}{$newpos->[1]+$d->[1]} ne '.' and
				  $current_map->{$newpos->[0]+$d->[0]}{$newpos->[1]+$d->[1]} ne $actor->{type} ) {
				  push @defenders, [$positions->{$newpos->[0]+$d->[0]}{$newpos->[1]+$d->[1]}{hp},
						    $newpos->[0]+$d->[0], $newpos->[1]+$d->[1]];
			      }
			  }
			  if (@defenders) {
			      #say stringify_unit( $actor) . " has defenders adjacent after moving, will attack";
			      @defenders = sort {$a->[0]<=>$b->[0] ||
						   $a->[1]<=>$b->[1]||
						   $a->[2]<=>$b->[2] }@defenders ;
			      my $def = $defenders[0];
			      if ($actor->{type} eq 'E') {
				  $attack_power = $elf_power
			      } else {
				  $attack_power = 3
			      }

			      $positions->{$def->[1]}{$def->[2]}{hp} -= $attack_power;
			      printf("unit type %s at [%d,%d] has HP %d\n",
				     $positions->{$def->[1]}{$def->[2]}{type},
				     $def->[1],$def->[2],$positions->{$def->[1]}{$def->[2]}{hp}) if $debug;
			      if ($positions->{$def->[1]}{$def->[2]}{hp}<=0) {
				  printf("unit type %s at [%d,%d] has HP %d, will be removed\n",
					 $positions->{$def->[1]}{$def->[2]}{type},
					 $def->[1],$def->[2],$positions->{$def->[1]}{$def->[2]}{hp}) if $debug;
				  $players->{$positions->{$def->[1]}{$def->[2]}{type}}--;
				  push @marked_for_deletion, [$def->[1], $def->[2]];
				  delete $positions->{$def->[1]}{$def->[2]};
				  $current_map->{$def->[1]}{$def->[2]} = '.';
			      }
			  }
		      }
		  }
	      }
	  }
	  $turn++;

	  say "After round $turn:";
	  if ($testing) {

	  dump_map( $current_map );
	  for my $r (sort {$a<=>$b} keys %$positions) {
	      for my $c (sort {$a<=>$b} keys %{$positions->{$r}} ) {
		  	    printf("[%d,%d] %s %3d\n", $r, $c, $positions->{$r}{$c}{type}, $positions->{$r}{$c}{hp})
	      }
	  }

	  }
	  # check if we have all unit types left
	  last TURN unless ($players->{E} and $players->{G});
	  if ($players->{E} != $no_elves and $part2) {
	      $elf_died = 1;
	      last TURN;
	  }
      }
      
    dump_map( $current_map) if $testing; 
    
    if ($elf_died) {
	return undef;
    } else {
	for my $r (0..$maxrow) {
	    for my $c (0..$maxcol) {
		$mapstring .= $current_map->{$r}{$c}
	    }
	}
	my $sum;
	for my $r (keys %$positions) {
	    for my $c (keys %{$positions->{$r}}) {
		$sum += $positions->{$r}{$c}{hp}
	    }
	}
	#  say $turn;
	# say $sum;
	
	my $ans = ( $turn) * $sum;
	#   say $ans;
	return {ans=>$ans,
		sum=>$sum,
		turns=>$turn,
		mapstring=>$mapstring};
    }
}

sub find_path {
    my ($map, $start, $end ) = @_;
    my @queue = ([1, $start ]);
    my %seen;
    my $shortest = undef;

  BFS: while (@queue) {
	my $curr = shift @queue;
	my $step = $curr->[0];
	my ( $r, $c ) = @{$curr->[1]};
	next if $seen{$r}{$c};
	$seen{$r}{$c}++;

	$step += 1;
	for my $d (@dirs) {
	    if ($map->{$r+$d->[0]}{$c+$d->[1]} ne  '.' ) {
		next 
	    }
	    if ($r+$d->[0] == $end->[0] and $c+$d->[1] == $end->[1]) { # reached target
		$shortest  = $step;
		last BFS;
	    }

	    push @queue, [ $step, [$r+$d->[0] ,$c+$d->[1]]];
	}
	
    }
    return $shortest;
}

sub stringify_unit {
    my ($unit) = @_;
    return sprintf("unit type %s at [%2d,%2d] with HP %3d",
		   $unit->{type}, $unit->{pos}[0],$unit->{pos}[1], $unit->{hp});
}
sub dump_map {
    my ( $map ) = @_;
    for my $row (0..$maxrow) {
	for my $col (0..$maxcol) {
	    print $map->{$row}{$col}
	}
	print "\n"
    }
}

sub sec_to_hms {
    my ($s) = @_;
    return sprintf("Duration: %02dh%02dm%02ds (%.3f ms)",
    int( $s/(3600) ), ($s/60) % 60, $s % 60, $s * 1000 );
}
