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
#		 [5,5], [10,10], [20, 20], [30,30], [40,40],[100,100],
		 [1000,1000],
		 [5, 5, 5], [10,10,10], [20, 20, 20], [30,30,30],
		 [5,5,5,5], [10,10,10,10]
		 );
#if (@ARGV and $ARGV[0] eq 'save') {
unless (@ARGV) {
    open B, ">>", "BENCHMARK" or die "Cannot append to BENCHMARK file\n";
    print B "--------------------------------------------------------------------------------\n";
    print B "Games::Chomp version: $Games::Chomp::VERSION\n";
    print B "Date: ", scalar (localtime), "\n";
}
foreach my $pos (@positions) {
    $c->reset;
    $t0 = new Benchmark;
    $c->resolve($pos);
    $t1 = new Benchmark;
    $td = timediff($t1,$t0);
    printf "POSITION: %20.20s TIME: %s\n","@$pos", timestr($td);
#    if (@ARGV and $ARGV[0] eq 'save') {
    unless (@ARGV) {
	printf B "POSITION: %20.20s TIME: %s\n","@$pos", timestr($td);
    }
}




