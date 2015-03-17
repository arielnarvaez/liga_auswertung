#!/usr/local/bin/perl

use Cwd;               # to get the directory path
use File::Spec;        # to join the directory path and file name
use File::Basename;    # to get the file name without extension
use POSIX;
use Data::Dumper;
use Scalar::Util qw(looks_like_number);
use List::Util qw(sum);

$league = $ARGV[0];

my $dir = './';

# read games
$rgames = $dir.$league."_date.dat";
open my $fh, "<", $rgames or die "can't read open '$fp': $OS_ERROR";
$ngames = 0;

# read the dates and save them in the array calendar 
while ( $line = <$fh> ) {
    @splitline = split("&", $line);
    $ngames += 1;
    push( @calendar, @splitline[1] );
}
close $fh or die "can't read close '$fp': $OS_ERROR";


# read teams
$rteams = $dir.$league."_teams.dat";
open my $fh, "<", $rteams or die "can't read open '$fp': $OS_ERROR";
$nteams = 0;

# read the teams name save them in the array teams_name and teams_abbr 
while ( $line = <$fh> ) {
    @splitline = split("&", $line);
    $nteams += 1;

    push( @{ $results{names} }, @splitline[0] );
    push( @{ $results{abbrs} }, @splitline[1] );
}
close $fh or die "can't read close '$fp': $OS_ERROR";

# delete spaces before and after the text
s{^\s+|\s+$}{}g foreach @{ $results{names} };
s{^\s+|\s+$}{}g foreach @{ $results{abbrs} };

# this file contains the data to be plotted
$outfile = $dir."table_teams.dat";
open($tt, '>', $outfile) or die "Could not open file $outputfile: $!";	

# create head of file table_teams.dat
# and the hash results is defined
printf $tt "# sp\t";
for $i ( 0 .. $#{ @results{names} } ) {
    $results{games}[$i] = 0;
    $results{won}[$i] = 0;
    $results{lost}[$i] = 0;
    $results{draw}[$i] = 0;
    $results{gfavor}[$i] = 0;
    $results{gcontra}[$i] = 0;
    $results{gcontra}[$i] = 0;
    $results{gdiff}[$i] = 0;
    $results{points}[$i] = 0;

    printf $tt "\t%s", $results{abbrs}[$i];
}
printf $tt "\n";


$sp = 0;
foreach my $ft ( glob($dir.$league."_sp*.dat") ) {

    $sp += 1;
    for $i ( 0 .. $#{ $results{names} } ) {
	$results{played}[$i] = 0;
    }

    open my $fh, "<", $ft or die "can't read open '$fp': $OS_ERROR";

    while ( $line = <$fh> ) {
	@splitline = split("&", $line);
	s{^\s+|\s+$}{}g foreach @splitline; # delete spaces before and after the text

	for $i ( 0 .. $#{ $results{names} } ) {

	    if ( $results{names}[$i] eq $splitline[1] ) {
		if ( looks_like_number($splitline[3]) ) {
		    $results{played}[$i]  = 1;
		    $results{games}[$i]   += 1;                             
		    $results{gfavor}[$i]  += $splitline[3];                
		    $results{gcontra}[$i] += $splitline[4];               
		    $results{gdiff}[$i]   += $splitline[3] - $splitline[4]; 
		    if ( $splitline[3] > $splitline[4] ) {      # victory
			$results{won}[$i]    += 1;
			$results{points}[$i] += 3;
		    } elsif ( $splitline[3] < $splitline[4] ) { # defeat
			$results{lost}[$i] += 1; 
		    } else {                                    # draw
			$results{draw}[$i] += 1; 
			$results{points}[$i]  += 1;
		    }
		}
	    }

	    if ( $results{names}[$i] eq $splitline[2] ) {
		if ( looks_like_number($splitline[3]) ) {
		    $results{played}[$i]  = 1;
		    $results{games}[$i]   += 1;  
		    $results{gfavor}[$i]  += $splitline[4];                
		    $results{gcontra}[$i] += $splitline[3];                
		    $results{gdiff}[$i]   += $splitline[4] - $splitline[3];
		    if ( $splitline[3] > $splitline[4] ) {      # defeat
			$results{lost}[$i] += 1; 
		    } elsif ( $splitline[3] < $splitline[4] ) { # victory
			$results{won}[$i]    += 1;
			$results{points}[$i] += 3; 
		    } else {                                    # draw
			$results{draw}[$i]   += 1; 
			$results{points}[$i] += 1;
		    }
		}
	    }
	}
    }

    $outfile = $dir."table_sp".$sp.".dat";
    open($of, '>', $outfile) or die "Could not open file $outputfile: $!";	

    if ( sum ( @{ $results{played} } ) != 0 ){
	print "$sp\n";
	# sorting bei points, then diff goals and then played games.
	my @idx = sort { -$results{points}[$a] <=> -$results{points}[$b] ||
			     -$results{gdiff}[$a] <=> -$results{gdiff}[$b] ||
			     $results{games}[$a] <=> $results{games}[$b] } 0 .. @{ $results{names} };
	pop @idx;

	@{ $results_tmp{abbrs} }   = @{ $results{abbrs} }[@idx];
	@{ $results_tmp{points} }  = @{ $results{points} }[@idx];

	for  $i ( 0 .. $#{ $results{names} } ) {
	    printf $of "%s\n", $results_tmp{abbrs}[$i];
	}

	printf $tt "   $sp\t";
	for $i (  0 .. $#{ $results{names} } ) {
	    if ( $results{played}[$i] == 1 ) {
		printf $tt "\t\t%s", $results{points}[$i];
	    } else {
		printf $tt "\t\t%s", "&";
	    }
	}
	printf $tt "\n";


    } else {
	printf $of "\n";
    }

    close $of;
}


$outfile = $dir."final_table.dat";
open($of, '>', $outfile) or die "Could not open file $outputfile: $!";	

# sorting bei points, then diff goals and then played games.
my @idx = sort { -$results{points}[$a] <=> -$results{points}[$b] ||
		     -$results{gdiff}[$a] <=> -$results{gdiff}[$b] ||
		     $results{games}[$a] <=> $results{games}[$b] } 0 .. @{ $results{names} };
pop @idx;

@{ $results_tmp{names} }   = @{ $results{names} }[@idx];
@{ $results_tmp{abbrs} }   = @{ $results{abbrs} }[@idx];
@{ $results_tmp{points} }  = @{ $results{points} }[@idx];
@{ $results_tmp{gcontra} } = @{ $results{gcontra} }[@idx];
@{ $results_tmp{gfavor} }  = @{ $results{gfavor} }[@idx];
@{ $results_tmp{gdiff} }   = @{ $results{gdiff} }[@idx];
@{ $results_tmp{won} }     = @{ $results{won} }[@idx];
@{ $results_tmp{lost} }    = @{ $results{lost} }[@idx];
@{ $results_tmp{draw} }    = @{ $results{draw} }[@idx];
@{ $results_tmp{games} }   = @{ $results{games} }[@idx];

for $i ( 0 .. $#{ $results{names} } ) {
    printf $of "%s %.0f %.0f %.0f %.0f %.0f %.0f %.0f\n", $results_tmp{abbrs}[$i], $results_tmp{games}[$i], 
    $results_tmp{points}[$i], $results_tmp{gfavor}[$i], $results_tmp{gcontra}[$i], 
    $results_tmp{won}[$i], $results_tmp{lost}[$i], $results_tmp{draw}[$i];
}

close $of;



