#!/usr/bin/perl

# running a few computations and displaying the benchmark results.
use warnings;
use strict;
use Benchmark;


use lib qw(blib/lib);
use Games::Chomp;

my $c = new Games::Chomp;

my ($t0, $t1, $td);

my @positions = (
		 [5,5], [10,10], [20, 20], [30,30], [40,40], 
		 [5, 5, 5], [10,10,10], [20, 20, 20]
		 );

foreach my $pos (@positions) {
    $c->reset;
    $t0 = new Benchmark;
    $c->resolve($pos);
    $t1 = new Benchmark;
    $td = timediff($t1,$t0);
    printf "POSITION: %10.10s TIME: %s\n","@$pos", timestr($td);
}







