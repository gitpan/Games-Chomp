package Games::Chomp;

use 5.006;
use strict;
use warnings;

use Benchmark;

our $VERSION = '0.02';


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

my @edge_position; # a position under which we have solved all the positions
# and there is no need to keep the loosing positions 

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

    $self->load_file();

    if ($self->in_winning($pos)) {
	print "Winning Position\n";
	$self->display_position($pos);
	exit;
    }
    if ($self->in_loosing($pos)) {
	print "Loosing Position\n";
	$self->display_position($pos);
	exit;
    }
    
    #$self->position($pos);
    $self->resolve($pos);


    if ($self->in_winning($pos)) {
	print "Winning Positions\n";
	$self->display_position($pos);
    } elsif ($self->in_loosing($pos)) {
	print "Loosing Position\n";
	$self->display_position($pos);
    }

    my $t1 = new Benchmark;
    my $td = timediff($t1,$t0);
    print "the code took:",timestr($td),"\n";

# $self->show_all_winning_pos;
# $self->show_all_loosing_pos();

    $self->save_file();

}

sub reset {
    my $self = shift;
    
    @winning_positions = ();
    @loosing_positions = ();

    return 1;  # not really interesting
}


sub resolve {
    my $self = shift;
    my $pos = shift;
    my $spec = shift;

#    unless ($self->special_position($pos)) {
	
    if ($self->in_winning($pos)) {
	return 1;
    }
    if ($self->in_loosing($pos)) {
	return 0;
    }

#    unless (defined $spec) {
#	my $rows = @$pos;
#	my $cols = $pos->[-1];
#	foreach my $ep (@edge_positions) {
#	    if ($ep->{rows} <
#	$self->resolve();
#    }

    my @all = $self->all_moves_from_here($pos);
    while (my $p = shift @all) {
#    print "DEBUG: Lengths: ", scalar @all, "\n";
	if ($self->resolve($p, 1)) {  # found winning sub position
	    $self->put_in_loosing($pos);
	    return 0;
	}
    }
    # all sub positions were loosing
    $self->put_in_winning($pos);
    return 1;
}


sub in_winning {
    my $self = shift;
    my $pos = shift;

    return 1 if ($self->special_position($pos) eq "win");

    $self->in_group($pos, \@winning_positions);
}

sub in_loosing {
    my $self = shift;
    my $pos = shift;
    return 1 if ($self->special_position($pos) eq "loose");

    $self->in_group($pos, \@loosing_positions);
}

sub special_position {
    my $self = shift;
    my $pos = shift;

#    return 0 if $sel

    if (@$pos == 1) {   # one row only
	return ($pos->[0] == 1  ? "win" : "loose");
    }
    if (@$pos == 2) {   # two row
	return ($pos->[0] == $pos->[1]+1 ? "win" : "loose");
    }

    # 3 or more rows
    if ($pos->[0] == $pos->[1]+1) {    # n, n-1
	return "loose";
    }

    if ($pos->[0] == @$pos) {   # sqare
	return $pos->[1] == 1 ? "win" : "loose";
    }
    return 0;
}

sub in_group {
    my $self = shift;
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
    my $self = shift;

    print "All Winning Positions:\n";
    foreach my $p (@winning_positions) {
	$self->display_position($p);
    }
}

sub show_all_loosing_pos {
    my $self = shift;

    print "All Loosing Positions:\n";
    foreach my $p (@loosing_positions) {
	$self->display_position($p);
    }
}
	

# separate function so we can hold the winning and loosing positions
# in any format.
sub put_in_loosing {
    my $self = shift;
    my $p = shift;
    push @loosing_positions, $p;
}

sub put_in_winning {
    my $self = shift;
    my $p = shift;
    push @winning_positions, $p;
}


sub display_position {
    my $self = shift;
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
    my $self = shift;
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
    my $self = shift;

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
    my $self = shift;

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


=head1 METHODS

  use Games::Chomp;
  my $chomp = new Games::Chomp;

  $chomp->run;
     ask for position in row-length representation
     computes all the positions up to that position and
     saves them in a file called chomp.txt in the local
     directory.
     Using run later will use the already calculated
     positions that were saved in that file.

  $chomp->reset;
     Empties the list of winning positions kept in memory.
     The only case you want to use this is if you want to
     benchmark the module and start from an empty environment.

  $chomp->resolve(POSITION);
     POSITION is array reference, it is a reference to a row-length 
     representation.
     
     resolve returns 1 if the above position is a winning position
     and returns 0 if it is a loosing position. As a side effect
     it *might* compute the 'winningness' of all the positions
     which are smaller than this one.

  $chomp->show_all_winning_pos
     prints all the winning positions calculated so far
     (except the already obvious onces.) in row-length representation.

  $chomp->transpose(POSITION)
     returns a reference to an array which is a POSITION where
     the rows and the columns are transposed.
     given [5,4,3]  it returns [3,3,3,2,1]
     not implemented yet

=head1 REPRESENTATIONS

 A certain state of the game can be represented in different ways.

 ROW-LENGTH
 One of the ways I call row-length representation. I use this
 representation in my implementation. In this representation we
 give a list of numbers that represent the number of chocolates 
 in the given row. [5,4,3] is the same as
     ooooo
     oooo
     ooo

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
