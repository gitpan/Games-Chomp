package Games::Chomp;

use 5.006;
use strict;
use warnings;

use Benchmark;

our $VERSION = '0.01';


my $filename = "chomp.txt"; # hardcoded place to save the positions
                            # between runs to reduce computation time

my @winning_positions = ();  # if you move to such a position you can win the whole game
                 # it actually means that all the possible moves of the other 
                 # player will lead him to loosing_position
                 # from a winning position one can move only to loosing positions
my @loosing_positions = ();   # if you move in such a position you will probably 
                 # lose the game (if you opponent is clever)
                 # it means that there is a move that lead to a winning_position
                 # from a loosing position there is (at least one) way to a winning
                 # posititon


sub new {
    my $self = shift;
    my $class = ref($self) || $self;
    
    my %data = (position => []);

# = (game_type => 'simple',
#		myturn => 0,
#		level => 0,
#		groups => [int (rand(10)+20)],    # default
#		moves => [0],                     # 0 means that you can take 
#		                                  # any number that is available
#		);

    bless(\%data, $class);
    return \%data;
}



sub run {
    my $self = shift;

    print "Please enter a position separated by spaces: ";
    my $input = <STDIN>;
    chomp $input;
    my $pos = [split / +/, $input];

    my $t0 = new Benchmark;

#    load_file();

    if (in_winning($pos)) {
	print "Winning Position\n";
	display_position($pos);
	exit;
    }
    if (in_loosing($pos)) {
	print "Loosing Position\n";
	display_position($pos);
	exit;
    }
    
    #$self->position($pos);
    $self->resolve($pos);


    if (in_winning($pos)) {
	print "Winning Positions\n";
	display_position($pos);
    } elsif (in_loosing($pos)) {
	print "Loosing Position\n";
	display_position($pos);
    }

    my $t1 = new Benchmark;
    my $td = timediff($t1,$t0);
    print "the code took:",timestr($td),"\n";

#show_all_winning_pos();
#show_all_loosing_pos();

#save_file();

}

sub reset {
    my $self = shift;
    
    @winning_positions = ();
    @loosing_positions = ();
    return 1;
}


sub resolve {
    my $self = shift;

    my $pos = shift;

    my @all = all_moves_from_here($pos);
    while (my $p = shift @all) {
#    print "DEBUG: Lengths: ", scalar @all, "\n";
	if (in_winning($p)) {
	    put_in_loosing($pos);
	    return;
	} elsif (not in_loosing($p)) {
	    push @all, $p;
	    $self->resolve($p);
	    next;
	}
    }
    put_in_winning($pos);
}


sub in_winning {
    my $pos = shift;

#    return 1 if (special_position($pos) eq "win");

    in_group($pos, \@winning_positions);
}

sub in_loosing {
    my $pos = shift;
#    return 1 if (special_position($pos) eq "loose");

    in_group($pos, \@loosing_positions);
}

sub special_position {
    my $pos = shift;
    if (@$pos == 1) {   # one liner
	return ($pos->[0] > 1  ? "win" : "loose");
    }
    if (@$pos == 2) {   # two liner
	return ($pos->[0] == $pos->[1]+1 ? "win" : "loose");
    }

    if ($pos->[0] == $pos->[1]+1) {    # n, n-1
	return "loose";
    }

    if ($pos->[0] == @$pos) {   # sqare
	return $pos->[1] == 1 ?   "win" : "loose";
    }
}

sub in_group {
    my $pos = shift;
    my $group = shift;

POS:foreach my $p (@$group) {
	next unless (@$pos == @$p);
	foreach my $i (0..$#{$pos}) {
	    next POS if ($pos->[$i] != $p->[$i]);
	}
	return 1; # all rows were equal
    }
    return 0;
}

sub show_all_winning_pos {
    print "All Winning Positions:\n";
    foreach my $p (@winning_positions) {
	display_position($p);
    }
}

sub show_all_loosing_pos {
    print "All Loosing Positions:\n";
    foreach my $p (@loosing_positions) {
	display_position($p);
    }
}
	

# separate function so we can hold the winning and loosing positions
# in any format.
sub put_in_loosing {
    my $p = shift;
    push @loosing_positions, $p;
}

sub put_in_winning {
    my $p = shift;
    push @winning_positions, $p;
}


sub display_position {
    my $pos = shift;

    foreach my $p (@$pos) {
	print "$p\n";
    }
    print "---\n";
}

# get a reference to a position (later position object)
# and returns a list of all the possible positions that can be reached
# from here
sub all_moves_from_here {
    my $pos = shift;

    my @possible=();
ROW:for (my $row=0; $row < @$pos; $row++) {
COL:    for (my $col = 0; $col< $pos->[$row]; $col++) {
	    next COL if ($row == 0 and $col ==0);
	    my @newpos = @$pos;  # a copy of the current position
	    #$newpos[$row] = $col;
	    if ($col) {
		for (my $newrow=$row; $newrow < @$pos; $newrow++) {
		    if ($newpos[$newrow]> $col) {
			$newpos[$newrow]=$col;
		    }
		}
	    } else {
		$#newpos=$row-1;
	    }
	    push @possible, \@newpos;
	}
    }
    return @possible;
}
				    


sub load_file {
    return 0 unless (-e $filename);
    open F, $filename or return 0;
    while (my $line = <F>) {
	chomp $line;
	my @values = split /,/, $line;
	my $group = shift @values;
	if ($group eq "win") {
	    push @winning_positions, \@values;
	} elsif ($group eq "loose") {
	    push @loosing_positions, \@values;
	} elsif ($group eq "pos") {
	   # @edge_position = @values;
	} else {
	    warn "INVALID LINE: $line\n";
	}
    }
    close F;
}


sub save_file {
    open F, ">", $filename or die "Could not save to file\n";
    foreach my $pos (@winning_positions) {
	print F join "," , "win", @$pos;
	print F "\n";
    }

    foreach my $pos (@loosing_positions) {
	print F join "," , "loose", @$pos;
	print F "\n";
    }
    close F;
}



1;
__END__
# Below is stub documentation for your module. You better edit it!

=head1 NAME

Games::Chomp - Playing Chomp and calculating winning positions

=head1 SYNOPSIS

  use Games::Chomp;
  my $chomp = new Games::Chomp;
  $chomp->run;

=head1 DESCRIPTION

 Chomp is the name of a mathematical table game with 
 finate number of positions. Though it is easily proven 
 that the one who moves first has a winning strategy
 there is no mathematical function that will calculate
 the next winning move from any given position.

 This module provides an algorithm to programatically 
 calculate the winning moves for any given position.

 The current implementation has some O(n**4) (?) complexity
 so it is not a good one but this is the first version after
 all.




=head1 THE RULES

 There is a chocolate of n*m cubes.
 The upper left cube is poisoned. Two people are eating the
 chocolate (at least one cube at a time) and whoever eats the 
 poisoned chocolate looses.

 Eating the chocolate is done by pointing at one of the existing 
 cubes eating it and everything to the right and below it.

 Examples:
 In the following case 
 z - is the poisoned cube.
 o - is a regular cube
 x - is where the player points

 Beginning: a chocolate with 4 rows and 6 cubes in every row.
 zooooo
 oooooo
 oooooo
 oooooo

 player 1 points at row 2 cube 4

 zooooo
 oooxoo
 oooooo
 oooooo

 result:

 zooooo
 ooo
 ooo
 ooo


 player 2 points at row 3 cube 2

 zooooo
 ooo
 oxo
 ooo

 result:

 zooooo
 ooo
 o
 o

 player 1 points at row 1 cube 2

 zxoooo
 ooo
 o
 o

 z
 o
 o
 o

 player 2 points at row 2 cube 1

 z
 x
 o
 o

 result:

 z

 player 1 has to eat the poisoned cube so s/he looses.

=head1 AUTHOR

 Gabor Szabo <lt>gabor@tracert.com<gt>

=head1 COPYRIGHT

 The Games::Chomp module is Copyright (c) 2002 Gabor Szabo.
 All rights reserved.
 
 You may distribute under the terms of either the GNU General Public
 License or the Artistic License, as specified in the Perl README file.

=head1 SEE ALSO

 Games::NIM

=cut
