use warnings;
use strict;


use Test;
BEGIN { plan tests => 10 };
use Games::Chomp;
ok(1);

my $g = new Games::Chomp;
ok(defined $g);

ok($g->reset);

## Testing problem solving for a few small numbers
ok($g->resolve([1]));
ok($g->resolve([2,1]));
ok($g->resolve([30,29]));

ok($g->resolve([3,1,1]));
ok($g->resolve([5,5,3]));

ok(0==$g->resolve([2,2]));
ok(0==$g->resolve([5,5,5]));
