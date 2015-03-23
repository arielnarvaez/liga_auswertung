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

# gnuplot file
$outfile_plot = $dir.$league."_plot.gp";
open($tgp, '>', $outfile_plot) or die "Could not open file $outputfile: $!";	

printf $tgp "%s\n", "set terminal postscript landscape enhanced color lw 1 rounded size 11.7in,8.3in font 'Courier, 10'";
printf $tgp "%s%s%s\n", "set output '", $league,"_plot.eps'";
printf $tgp "%s\n", "set grid ytics";
printf $tgp "%s\n", "set xlabel 'Spieltag'";
printf $tgp "%s\n", "set ylabel 'Punkten'";


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
for $i ( 0 .. $nteams - 1 ) {
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
    for $i ( 0 .. $nteams -1 ) {
	$results{played}[$i] = 0;
    }

    open my $fh, "<", $ft or die "can't read open '$fp': $OS_ERROR";


    if ( $sp even ) { # even
	$pos_foot = -1;
    } else { # odd
	$pos_foot = -10;
    }

    while ( $line = <$fh> ) {
	@splitline = split("&", $line);
	s{^\s+|\s+$}{}g foreach @splitline; # delete spaces before and after the text

	for  $j ( 0 .. $nteams -1 ) {
	    if ( $results{names}[$j] eq $splitline[1] ) { 
		$ihome = $j;
	    }
	    if ( $results{names}[$j] eq $splitline[2] ) { 
		$iguest = $j;
	    }
	}


	printf $tgp "set label '%s %.0f  %s %.0f' at %.1f, %.1f center tc rgb 'gray' font 'Courier,5'\n", 
	$results{abbrs}[$ihome], $splitline[3], $results{abbrs}[$iguest], $splitline[4], $sp, $pos_foot; 
	$pos_foot -= 1; 

	for $i ( 0 .. $nteams - 1 ) {
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
			$results{points}[$i]  += 0;
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
			$results{lost}[$i]   += 1; 
			$results{points}[$i] += 0;
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
	print "     $sp\n";
	# sorting bei points, then diff goals and then played games.
	my @idx = sort { -$results{points}[$a] <=> -$results{points}[$b] ||
			     -$results{gdiff}[$a] <=> -$results{gdiff}[$b] ||
			     $results{games}[$a] <=> $results{games}[$b] } 0 .. $nteams - 1;

	@{ $results_tmp{abbrs} }   = @{ $results{abbrs} }[@idx];
	@{ $results_tmp{points} }  = @{ $results{points} }[@idx];

	$pos_head = 105; 
	for  $i ( 0 .. $nteams - 1 ) {
	    if ( exists $idxold[$i] ) {
		
		for  $j ( 0 .. @idxold - 1) {
		    if ( $idx[$i] == $idxold[$j] ) { 
			$icomp = $j;
		    }
		}

		if ( $i == $icomp ) {
		    printf $of "%s %s\n", $results_tmp{abbrs}[$i], "0";

		    printf $tgp "set label '%s' at %.1f, %.1f center tc rgb 'gray' font 'Courier,5'\n", 
		    $results_tmp{abbrs}[$i], $sp, $pos_head; 
		    $pos_head -= 1; 
		} elsif ( $i < $icomp ) {
		    printf $of "%s %s\n", $results_tmp{abbrs}[$i], "1";

		    printf $tgp "set label '%s' at %.1f, %.1f center tc rgb 'green' font 'Courier,5'\n", 
		    $results_tmp{abbrs}[$i], $sp, $pos_head; 
		    $pos_head -= 1; 
		} else {
		    printf $of "%s %s\n", $results_tmp{abbrs}[$i], "-1";

		    printf $tgp "set label '%s' at %.1f, %.1f center tc rgb 'red' font 'Courier,5'\n", 
		     $results_tmp{abbrs}[$i], $sp, $pos_head; 
		    $pos_head -= 1; 
		}
	    } else {
		printf $of "%s %s\n", $results_tmp{abbrs}[$i], "0";

		printf $tgp "set label '%s' at %.1f, %.1f center tc rgb 'gray' font 'Courier,5'\n", 
		$results_tmp{abbrs}[$i], $sp, $pos_head; 
		$pos_head -= 1;
	
	    }
	}
	    
	@idxold = @idx;

	printf $tt "   $sp\t";
	for $i (  0 .. $nteams - 1 ) {
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
		     $results{games}[$a] <=> $results{games}[$b] } 0 .. $nteams - 1;

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

#printf $tgp "%s\n", "set title 'B Klasse Zugspitze 4' font "Helvetica,16" tc rgb "red" tgpfset 0,3

$xmax = 1.4*$sp;
$ymax = int( 6*($nteams - 1)/5);

if ($ymax*5 != 6*($nteams - 1) ){
    $ymax += 1;
}

$ymax = 1.4 * ($ymax * 5 );

printf $tgp "set xrange [0.5:%.1f]\n", $xmax;
printf $tgp "%s\n", "set xtics 1";
printf $tgp "set yrange [0:%s]\n", $ymax;
printf $tgp "%s\n", "set ytics 5";
#printf $tgp "%s\n", "set size   0.9, 0.75";
#printf $tgp "%s\n", "set origin 0.0, 0.15";
printf $tgp "%s\n", "set key at 29,30 reverse";

printf $tgp "%s", "plot ";
for $i ( 0 .. $nteams -1 ) {
    printf $of "%s %.0f %.0f %.0f %.0f %.0f %.0f %.0f\n", $results_tmp{abbrs}[$i], $results_tmp{games}[$i], 
    $results_tmp{points}[$i], $results_tmp{gfavor}[$i], $results_tmp{gcontra}[$i], 
    $results_tmp{won}[$i], $results_tmp{lost}[$i], $results_tmp{draw}[$i];

    if ( $i == $nteams -1 ) {
	printf $tgp "'table_teams.dat' u 1:%.0f title '%s' w lp pt 7 ps 2", $idx[$i] + 2, $results_tmp{abbrs}[$i];
    } else {
	printf $tgp "'table_teams.dat' u 1:%.0f title '%s' w lp pt 7 ps 2,", $idx[$i] + 2, $results_tmp{abbrs}[$i];
    }
}

close $of;



