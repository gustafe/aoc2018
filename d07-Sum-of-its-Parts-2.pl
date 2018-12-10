#! /usr/bin/env perl
# Advent of Code 2018 Day 7 - The Sum of Its Parts - part 2
# Problem link: http://adventofcode.com/2018/day/7
#   Discussion: http://gerikson.com/blog/comp/Advent-of-Code-2018.html#d07
#      License: http://gerikson.com/files/AoC2018/UNLICENSE
###########################################################

use Modern::Perl '2015';
# useful modules
use List::Util qw/sum/;
use Data::Dumper;

#### INIT - load input data from file into array
my $testing = 0;
my $debug = 0;
my @input;
my $file = $testing ? 'test.txt' : 'input.txt';
open( my $fh, '<', "$file" );
while (<$fh>) { chomp; s/\r//gm; push @input, $_; }

### CODE

my $threshold = $testing? 0 : 60;

sub time_per_task {
    my ( $label ) = @_;
    return $threshold + ord( $label ) - 64;
}
my $no_of_workers = $testing ? 2 : 5;
my %graph;
foreach my $line (@input) {
    my ( $input, $output ) = $line =~ /^Step (.) .*step (.) can begin.$/;
    $graph{$output}->{from}->{$input}++;
    $graph{$input}->{to}->{$output}++;

}

my @queue;
push @queue, sort grep {scalar keys %{$graph{$_}->{from}}==0}  keys %graph;
my @result;
my @workers = (1..$no_of_workers);
my @processing;
my %processed;
my $time = 0;
my %pool;
# seed the pool
for (@queue ) {
    my $w = shift @workers;
    $pool{$_} = {worker=>$w, time=>time_per_task( $_ )} if defined $w;
}

sub dump_state {
    my $ws;
    foreach my $k(sort keys %pool) {
	$ws .= "$k w=$pool{$k}->{worker} t=$pool{$k}->{time} ";
    }
    printf("T=%4d Q=(%s) R=(%s) W=[ %s]\n",
	  $time, join('',@queue),join('',@result),$ws?$ws:'');
}
dump_state if $debug;
while (@queue) {
    # scan the pool, decrementing time
    my @finished;
    while (my ($task, $data) = each %pool)      {
	$data->{time}--;
	if ($data->{time}==0) {
	   push @finished,$task;
	    push @workers, $data->{worker};
	    delete $pool{$task}
	}
    }
    while (@finished) {
	my $done =shift @finished;
	push @result, $done;
	$processed{$done}++;
	# modify the queue
	my @newqueue;
	while (@queue) {
	    my $val = shift @queue;
	    push @newqueue, $val unless $val eq $done;
	}
	@queue = @newqueue;

	# we have processed stuff, so check for new entries
	my @possible = keys %{$graph{$done}->{to}};
	# can we add to queue?
	while (@possible) {
	    my $candidate = shift @possible;
	    my $ok =1;
	    foreach my $r (keys %{$graph{$candidate}->{from}}) {
		$ok = 0 unless exists $processed{$r};
	    }
	    push @queue, $candidate if $ok;
	}
	# assign new worker
	@queue = sort @queue;
	for (@queue) {
	    next if exists $pool{$_};
	    my $w = shift @workers;

	    $pool{$_} = {worker => $w, time=>time_per_task( $_ )}
	      if defined $w;

	}
    }
    $time++;
    dump_state if $debug;

}

say "Part 2: ",$time;
