#!/usr/local/bin/perl

use Cwd;               # to get the directory path
use File::Spec;        # to join the directory path and file name
use File::Basename;    # to get the file name without extension
use POSIX;
use Data::Dumper;
use Scalar::Util qw(looks_like_number);
use List::Util qw(sum);

$league = $ARGV[0];

$ps = 1.0; # point size

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

# gnuplot file
$outfile_plot = $dir.$league."_plot.gp";
open($tgp, '>', $outfile_plot) or die "Could not open file $outputfile: $!";	

$outfile_plot_1 = $dir.$league."_plot_1.gp";
open($tgp_1, '>', $outfile_plot_1) or die "Could not open file $outputfile: $!";	

$outfile_plot_2 = $dir.$league."_plot_2.gp";
open($tgp_2, '>', $outfile_plot_2) or die "Could not open file $outputfile: $!";	

$outfile_plot_3 = $dir.$league."_plot_3.gp";
open($tgp_3, '>', $outfile_plot_3) or die "Could not open file $outputfile: $!";	

$outfile_plot_4 = $dir.$league."_plot_4.gp";
open($tgp_4, '>', $outfile_plot_4) or die "Could not open file $outputfile: $!";	

$outfile_plot_5 = $dir.$league."_plot_5.gp";
open($tgp_5, '>', $outfile_plot_5) or die "Could not open file $outputfile: $!";	


printf $tgp "set terminal postscript landscape enhanced color lw 1 rounded size 11.7in,8.3in font 'Courier, 10'\n";
printf $tgp "%s%s%s\n", "set output '", $league,"_plot.eps'";
printf $tgp "%s\n", "set multiplot";

printf $tgp_1 "set size   0.8, 0.08\n";
printf $tgp_1 "set origin 0.0, 0.91\n";
printf $tgp_1 "set lmargin 7\n";
printf $tgp_1 "set rmargin 0\n";
printf $tgp_1 "set tmargin 0\n";
printf $tgp_1 "set bmargin 0\n";
printf $tgp_1 "unset grid\n";
printf $tgp_1 "set border 0\n";
printf $tgp_1 "set xrange [0.5:%.1f]\n", $ngames + 0.5;
printf $tgp_1 "set yrange [0:14]\n";
printf $tgp_1 "unset xlabel\n";
printf $tgp_1 "unset ylabel\n";
printf $tgp_1 "set format x ''\n";
printf $tgp_1 "set format y ''\n";
printf $tgp_1 "set tics scale 0\n";

printf $tgp_2 "set size   0.8, 0.3\n";
printf $tgp_2 "set origin 0.0, 0.6\n";
printf $tgp_2 "unset label\n";
printf $tgp_2 "set lmargin 7\n";
printf $tgp_2 "set rmargin 0\n";
printf $tgp_2 "set tmargin 0\n";
printf $tgp_2 "set bmargin 0\n";
printf $tgp_2 "set grid ytics\n";
printf $tgp_2 "set border 15\n";
printf $tgp_2 "set xrange [0.5:%.1f]\n", $ngames + 0.5;
printf $tgp_2 "set yrange [0:10 < * < 200]\n"; 
printf $tgp_2 "unset xlabel\n";
printf $tgp_2 "set ylabe 'Tor'\n";
printf $tgp_2 "set xtics 1\n";
printf $tgp_2 "set format x ''\n";
printf $tgp_2 "set format y '%s'\n", "%.0f";
printf $tgp_2 "set tics scale 1\n";

printf $tgp_3 "set size   0.8, 0.38\n";
printf $tgp_3 "set origin 0.0, 0.20\n";
printf $tgp_3 "unset label\n";
printf $tgp_3 "set lmargin 7\n";
printf $tgp_3 "set rmargin 0\n";
printf $tgp_3 "set tmargin 0\n";
printf $tgp_3 "set grid ytics\n";
printf $tgp_3 "set border 15\n";
printf $tgp_3 "set xrange [0.5:%.1f]\n", $ngames + 0.5;
printf $tgp_2 "set yrange [0:10 < * < 200]\n"; 
printf $tgp_3 "set xlabel 'Spieltag'\n";
printf $tgp_3 "set ylabe 'Punkten'\n";
printf $tgp_3 "set xtics 1\n";
printf $tgp_3 "set format x '%s'\n", "%.0f";
printf $tgp_3 "set format y '%s'\n", "%.0f";
printf $tgp_3 "set tics scale 1\n";

printf $tgp_4 "set size   0.8, 0.13\n";
printf $tgp_4 "set origin 0.0, 0.01\n";
printf $tgp_4 "unset label\n";
printf $tgp_4 "set lmargin 7\n";
printf $tgp_4 "set rmargin 0\n";
printf $tgp_4 "set tmargin 0\n";
printf $tgp_4 "set bmargin 0\n";
printf $tgp_4 "unset grid\n";
printf $tgp_4 "set border 15\n";
printf $tgp_4 "set xrange [0.5:%.1f]\n", $ngames + 0.5;
printf $tgp_4 "set yrange [0:40]\n";
printf $tgp_4 "unset xlabel\n";
printf $tgp_4 "unset ylabel\n";
printf $tgp_4 "set format x ''\n";
printf $tgp_4 "set format y ''\n";
printf $tgp_4 "set tics scale 1\n";

printf $tgp_5 "set size   0.15, 1.0\n";
printf $tgp_5 "set origin 0.85, 0.0\n";
printf $tgp_5 "unset label\n";
printf $tgp_5 "set lmargin 10\n";
printf $tgp_5 "unset grid\n";
printf $tgp_5 "set border 0\n";
printf $tgp_5 "set xrange [0:20]\n";
printf $tgp_5 "set yrange [0:100]\n";
printf $tgp_5 "unset xlabel\n";
printf $tgp_5 "unset ylabel\n";
printf $tgp_5 "unset xtics\n";
printf $tgp_5 "unset ytics\n";
printf $tgp_5 "set tics scale 0\n";


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
$outfile_points = $dir."table_teams_points.dat";
open($tt_points, '>', $outfile_points) or die "Could not open file $outputfile: $!";	

$outfile_hpoints = $dir."table_teams_hpoints.dat";
open($tt_hpoints, '>', $outfile_hpoints) or die "Could not open file $outputfile: $!";	

$outfile_gfavor = $dir."table_teams_gfavor.dat";
open($tt_gfavor, '>', $outfile_gfavor) or die "Could not open file $outputfile: $!";	


# create head of file table_teams.dat
# and the hash results is defined
printf $tt_points "# sp\t";
printf $tt_hpoints "# sp\t";
printf $tt_gfavor "# sp\t";

for $i ( 0 .. $nteams - 1 ) {
    $results{games}[$i]   = 0;
    $results{won}[$i]     = 0;
    $results{lost}[$i]    = 0;
    $results{draw}[$i]    = 0;
    $results{gfavor}[$i]  = 0;
    $results{gcontra}[$i] = 0;
    $results{gcontra}[$i] = 0;
    $results{gdiff}[$i]   = 0;
    $results{points}[$i]  = 0;
    $results{hpoints}[$i] = 0;   # points collected at home

    printf $tt_points "\t%s", $results{abbrs}[$i];
    printf $tt_hpoints "\t%s", $results{abbrs}[$i];
    printf $tt_gfavor "\t%s", $results{abbrs}[$i];
}
printf $tt_points "\n";
printf $tt_hpoints "\n";
printf $tt_gfavor "\n";

$sp = 0;
foreach my $ft ( glob($dir.$league."_sp*.dat") ) {

    $sp += 1;
    for $i ( 0 .. $nteams - 1 ) {
	$results{played}[$i] = 0;
    }

    open my $fh, "<", $ft or die "can't read open '$fp': $OS_ERROR";

    if (  $sp - 3*int($sp/3) == 1 ) { 
	$pos_foot = 30;
    } elsif ( $sp - 3*int($sp/3) == 2 ) {
	$pos_foot = 20;
    } else {
	$pos_foot = 10;
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

	printf $tgp_4 "set label '%s %.0f  %s %.0f' at %.1f, %.1f center tc rgb 'black' font 'Courier,4'\n", 
	$results{abbrs}[$ihome], $splitline[3], $results{abbrs}[$iguest], $splitline[4], $sp, $pos_foot; 
	$pos_foot -= 1; 

	if ( looks_like_number($splitline[3]) ) {
	    $results{played}[$ihome]    = 1;
	    $results{games}[$ihome]    += 1;
	    $results{gfavor}[$ihome]   += $splitline[3];
	    $results{gcontra}[$ihome]  += $splitline[4];
	    $results{gdiff}[$ihome]    += $splitline[3] - $splitline[4];

	    $results{played}[$iguest]   = 1;
	    $results{games}[$iguest]   += 1;
	    $results{gfavor}[$iguest]  += $splitline[4];
	    $results{gcontra}[$iguest] += $splitline[3];
	    $results{gdiff}[$iguest]   += $splitline[4] - $splitline[3];

	    if ( $splitline[3] > $splitline[4] ) {      # home victory
		$results{won}[$ihome]      += 1;
		$results{points}[$ihome]   += 3;
		$results{hpoints}[$ihome]  += 3;

		$results{lost}[$iguest]    += 1;
	    } elsif ( $splitline[3] < $splitline[4] ) { # home defeat
		$results{lost}[$ihome]     += 1; 

		$results{won}[$iguest]     += 1;
		$results{points}[$iguest]  += 3;
	    } else {                                    # draw
		$results{draw}[$ihome]     += 1; 
		$results{points}[$ihome]   += 1;
		$results{hpoints}[$ihome]  += 1;

		$results{draw}[$iguest]    += 1; 
		$results{points}[$iguest]  += 1;
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

	$pos_head = 13; 
	for  $i ( 0 .. $nteams - 1 ) {
	    if ( exists $idxold[$i] ) {
		
		for  $j ( 0 .. @idxold - 1) {
		    if ( $idx[$i] == $idxold[$j] ) { 
			$icomp = $j;
		    }
		}

		if ( $i == $icomp ) {
		    printf $of "%s %s\n", $results_tmp{abbrs}[$i], "0";

		    printf $tgp_1 "set label '%s' at %.1f, %.1f center tc rgb 'gray' font 'Courier,4'\n", 
		    $results_tmp{abbrs}[$i], $sp, $pos_head; 
		    $pos_head -= 1; 
		} elsif ( $i < $icomp ) {
		    printf $of "%s %s\n", $results_tmp{abbrs}[$i], "1";

		    printf $tgp_1 "set label '%s' at %.1f, %.1f center tc rgb 'green' font 'Courier,4'\n", 
		    $results_tmp{abbrs}[$i], $sp, $pos_head; 
		    $pos_head -= 1; 
		} else {
		    printf $of "%s %s\n", $results_tmp{abbrs}[$i], "-1";

		    printf $tgp_1 "set label '%s' at %.1f, %.1f center tc rgb 'red' font 'Courier,4'\n", 
		     $results_tmp{abbrs}[$i], $sp, $pos_head; 
		    $pos_head -= 1; 
		}
	    } else {
		printf $of "%s %s\n", $results_tmp{abbrs}[$i], "0";

		printf $tgp_1 "set label '%s' at %.1f, %.1f center tc rgb 'gray' font 'Courier,4'\n", 
		$results_tmp{abbrs}[$i], $sp, $pos_head; 
		$pos_head -= 1;
	
	    }
	}
	    
	@idxold = @idx;

	printf $tt_points "  %.0f\t", $sp;
	printf $tt_hpoints "  %.0f\t", $sp;
	printf $tt_gfavor "   %.0f\t", $sp ;
	for $i (  0 .. $nteams - 1 ) {
	    if ( $results{played}[$i] == 1 ) {
		printf $tt_points "\t\t%s", $results{points}[$i];
		printf $tt_hpoints "\t\t%s", $results{hpoints}[$i];
		printf $tt_gfavor "\t\t%s", $results{gfavor}[$i];
	    } else {
		printf $tt_points "\t\t&";
		printf $tt_hpoints "\t\t&";
		printf $tt_gfavor "\t\t&";
	    }
	}
	printf $tt_points "\n";
	printf $tt_hpoints "\n";
	printf $tt_gfavor "\n";

    } else {
	printf $of "\n";
    }

    close $of;
}

printf $tgp_1 "plot 'empty.dat' notitle\n";
printf $tgp_4 "plot 'empty.dat' notitle\n";


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

$xmax = 1.2*$sp;
$ymax = int( 6*($nteams - 1)/5);

if ($ymax*5 != 6*($nteams - 1) ){
    $ymax += 1;
}

$ymax = 1.2 * ($ymax * 5 );

printf $tgp_2 "%s", "plot ";
printf $tgp_3 "%s", "plot ";
for $i ( 0 .. $nteams -1 ) {
    printf $of "%s %.0f %.0f %.0f %.0f %.0f %.0f %.0f\n", $results_tmp{abbrs}[$i], $results_tmp{games}[$i], 
    $results_tmp{points}[$i], $results_tmp{gfavor}[$i], $results_tmp{gcontra}[$i], 
    $results_tmp{won}[$i], $results_tmp{lost}[$i], $results_tmp{draw}[$i];

    if ( $i == $nteams -1 ) {
	printf $tgp_2 "'table_teams_gfavor.dat' u 1:%.0f title '%s' w lp pt 7 ps %.1f\n", $idx[$i] + 2, $results_tmp{abbrs}[$i], $ps;
	printf $tgp_3 "'table_teams_points.dat' u 1:%.0f title '%s' w lp pt 7 ps %.1f\n", $idx[$i] + 2, $results_tmp{abbrs}[$i], $ps;

    } else {
	printf $tgp_2 "'table_teams_gfavor.dat' u 1:%.0f title '%s' w lp pt 7 ps %.1f,", $idx[$i] + 2, $results_tmp{abbrs}[$i], $ps;
	printf $tgp_3 "'table_teams_points.dat' u 1:%.0f title '%s' w lp pt 7 ps %.1f,", $idx[$i] + 2, $results_tmp{abbrs}[$i], $ps;
    }
}

close $of;



