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


# gnuplot file
# main plot
$outfile_plot = $dir.$league."_plot.gp";
open($tgp, '>', $outfile_plot) or die "Could not open file $outputfile: $!";	

# top ranking
$outfile_plot_1 = $dir.$league."_plot_1.gp";
open($tgp_1, '>', $outfile_plot_1) or die "Could not open file $outputfile: $!";	

# points home
$outfile_plot_2 = $dir.$league."_plot_2.gp";
open($tgp_2, '>', $outfile_plot_2) or die "Could not open file $outputfile: $!";	

# points away
$outfile_plot_3 = $dir.$league."_plot_3.gp";
open($tgp_3, '>', $outfile_plot_3) or die "Could not open file $outputfile: $!";	

# goals home
$outfile_plot_4 = $dir.$league."_plot_4.gp";
open($tgp_4, '>', $outfile_plot_4) or die "Could not open file $outputfile: $!";	

# goals away
$outfile_plot_5 = $dir.$league."_plot_5.gp";
open($tgp_5, '>', $outfile_plot_5) or die "Could not open file $outputfile: $!";	

# points evolution
$outfile_plot_6 = $dir.$league."_plot_6.gp";
open($tgp_6, '>', $outfile_plot_3) or die "Could not open file $outputfile: $!";	

# games
$outfile_plot_7 = $dir.$league."_plot_7.gp";
open($tgp_7, '>', $outfile_plot_7) or die "Could not open file $outputfile: $!";	

# table
$outfile_plot_8 = $dir.$league."_plot_8.gp";
open($tgp_8, '>', $outfile_plot_8) or die "Could not open file $outputfile: $!";	


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

printf $tgp_2 "set size   0.2, 0.3\n";
printf $tgp_2 "set origin 0.0, 0.6\n";
printf $tgp_2 "unset label\n";
printf $tgp_2 "set lmargin 7\n";
printf $tgp_2 "set rmargin 0\n";
printf $tgp_2 "set tmargin 0\n";
printf $tgp_2 "set bmargin 0\n";
printf $tgp_2 "set grid ytics\n";
printf $tgp_2 "set border 15\n";
printf $tgp_2 "set xrange [0:%.1f]\n", $nteams + 1;
printf $tgp_2 "set yrange [0:10 < * < 200]\n"; 
printf $tgp_2 "unset xlabel\n";
printf $tgp_2 "set ylabe 'Points'\n";
printf $tgp_2 "unset xtics\n";
printf $tgp_2 "set format x ''\n";
printf $tgp_2 "set format y '%s'\n", "%.0f";
printf $tgp_2 "set tics scale 1\n";

printf $tgp_3 "set size   0.2, 0.3\n";
printf $tgp_3 "set origin 0.2, 0.6\n";
printf $tgp_3 "unset label\n";
printf $tgp_3 "set lmargin 7\n";
printf $tgp_3 "set rmargin 0\n";
printf $tgp_3 "set tmargin 0\n";
printf $tgp_3 "set bmargin 0\n";
printf $tgp_3 "set grid ytics\n";
printf $tgp_3 "set border 15\n";
printf $tgp_3 "set xrange [0:%.1f]\n", $nteams + 1;
printf $tgp_3 "set yrange [0:10 < * < 200]\n"; 
printf $tgp_3 "unset xlabel\n";
printf $tgp_3 "set ylabe 'Points'\n";
printf $tgp_3 "unset xtics\n";
printf $tgp_3 "set format x ''\n";
printf $tgp_3 "set format y '%s'\n", "%.0f";
printf $tgp_3 "set tics scale 1\n";

printf $tgp_4 "set size   0.2, 0.3\n";
printf $tgp_4 "set origin 0.4, 0.6\n";
printf $tgp_4 "unset label\n";
printf $tgp_4 "set lmargin 7\n";
printf $tgp_4 "set rmargin 0\n";
printf $tgp_4 "set tmargin 0\n";
printf $tgp_4 "set bmargin 0\n";
printf $tgp_4 "set grid ytics\n";
printf $tgp_4 "set border 15\n";
printf $tgp_4 "set xrange [0:%.1f]\n", $nteams + 1;
printf $tgp_4 "set yrange [0:10 < * < 200]\n"; 
printf $tgp_4 "unset xlabel\n";
printf $tgp_4 "set ylabe 'Goals'\n";
printf $tgp_4 "unset xtics\n";
printf $tgp_4 "set format x ''\n";
printf $tgp_4 "set format y '%s'\n", "%.0f";
printf $tgp_4 "set tics scale 1\n";

printf $tgp_5 "set size   0.2, 0.3\n";
printf $tgp_5 "set origin 0.6, 0.6\n";
printf $tgp_5 "unset label\n";
printf $tgp_5 "set lmargin 7\n";
printf $tgp_5 "set rmargin 0\n";
printf $tgp_5 "set tmargin 0\n";
printf $tgp_5 "set bmargin 0\n";
printf $tgp_5 "set grid ytics\n";
printf $tgp_5 "set border 15\n";
printf $tgp_5 "set xrange [0:%.1f]\n", $nteams + 1;
printf $tgp_5 "set yrange [0:10 < * < 200]\n"; 
printf $tgp_5 "unset xlabel\n";
printf $tgp_5 "set ylabe 'Goals'\n";
printf $tgp_5 "unset xtics\n";
printf $tgp_5 "set format x ''\n";
printf $tgp_5 "set format y '%s'\n", "%.0f";
printf $tgp_5 "set tics scale 1\n";

printf $tgp_6 "set size   0.8, 0.38\n";
printf $tgp_6 "set origin 0.0, 0.20\n";
printf $tgp_6 "unset label\n";
printf $tgp_6 "set lmargin 7\n";
printf $tgp_6 "set rmargin 0\n";
printf $tgp_6 "set tmargin 0\n";
printf $tgp_6 "set grid ytics\n";
printf $tgp_6 "set border 15\n";
printf $tgp_6 "set xrange [0.5:%.1f]\n", $ngames + 0.5;
printf $tgp_6 "set yrange [0:10 < * < 200]\n"; 
printf $tgp_6 "set xlabel 'Spieltag'\n";
printf $tgp_6 "set ylabe 'Punkten'\n";
printf $tgp_6 "set xtics 1\n";
printf $tgp_6 "set format x '%s'\n", "%.0f";
printf $tgp_6 "set format y '%s'\n", "%.0f";
printf $tgp_6 "set tics scale 1\n";

printf $tgp_7 "set size   0.8, 0.13\n";
printf $tgp_7 "set origin 0.0, 0.01\n";
printf $tgp_7 "unset label\n";
printf $tgp_7 "set lmargin 7\n";
printf $tgp_7 "set rmargin 0\n";
printf $tgp_7 "set tmargin 0\n";
printf $tgp_7 "set bmargin 0\n";
printf $tgp_7 "unset grid\n";
printf $tgp_7 "set border 15\n";
printf $tgp_7 "set xrange [0.5:%.1f]\n", $ngames + 0.5;
printf $tgp_7 "set yrange [0:40]\n";
printf $tgp_7 "unset xlabel\n";
printf $tgp_7 "unset ylabel\n";
printf $tgp_7 "set format x ''\n";
printf $tgp_7 "set format y ''\n";
printf $tgp_7 "set tics scale 1\n";

printf $tgp_8 "set size   0.15, 1.0\n";
printf $tgp_8 "set origin 0.85, 0.0\n";
printf $tgp_8 "unset label\n";
printf $tgp_8 "set lmargin 10\n";
printf $tgp_8 "unset grid\n";
printf $tgp_8 "set border 0\n";
printf $tgp_8 "set xrange [0:20]\n";
printf $tgp_8 "set yrange [0:100]\n";
printf $tgp_8 "unset xlabel\n";
printf $tgp_8 "unset ylabel\n";
printf $tgp_8 "unset xtics\n";
printf $tgp_8 "unset ytics\n";
printf $tgp_8 "set tics scale 0\n";


# this file contains the data to be plotted
$outfile_points = $dir."table_teams_points.dat";
open($tt_points, '>', $outfile_points) or die "Could not open file $outputfile: $!";	

# points home
$outfile_pts_h = $dir."table_pts_h.dat";
open($tt_ph, '>', $outfile_pts_h) or die "Could not open file $outputfile: $!";	

# points away
$outfile_pts_a = $dir."table_pts_a.dat";
open($tt_pa, '>', $outfile_pts_a) or die "Could not open file $outputfile: $!";	

# goals home
$outfile_goals_h = $dir."table_goals_h.dat";
open($tt_gh, '>', $outfile_goals_h) or die "Could not open file $outputfile: $!";	

# goals away
$outfile_goals_a = $dir."table_goals_a.dat";
open($tt_ga, '>', $outfile_goals_a) or die "Could not open file $outputfile: $!";	


# create head of file table_teams.dat
# and the hash results is defined
printf $tt_points "# sp\t";
printf $tt_ph "#";
printf $tt_pa "#";
printf $tt_gh "#";
printf $tt_ga "#";


for $i ( 0 .. $nteams - 1 ) {
    $results{games}[$i]   = 0;
    $results{won}[$i]     = 0;
    $results{lost}[$i]    = 0;
    $results{draw}[$i]    = 0;
    $results{gfavor}[$i]  = 0;
    $results{gcontra}[$i] = 0;
    $results{gdiff}[$i]   = 0;
    $results{points}[$i]  = 0;
    $results{hpoints}[$i] = 0;   # points collected at home
    $results{apoints}[$i] = 0;   # points collected away
    $results{hgoals}[$i] = 0;    # goals at home
    $results{agoals}[$i] = 0;    # goals away
    $results{lgpoints}[$i] = [0, 0, 0];   # points of the last 4 games

    printf $tt_points "\t%s", $results{abbrs}[$i];
    printf $tt_ph "\t%s", $results{abbrs}[$i];
    printf $tt_pa "\t%s", $results{abbrs}[$i];
    printf $tt_gh "\t%s", $results{abbrs}[$i];
    printf $tt_ga "\t%s", $results{abbrs}[$i];
}

printf $tt_points "\n";
printf $tt_ph "\n";
printf $tt_pa "\n";
printf $tt_gh "\n";
printf $tt_ga "\n";

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

	printf $tgp_7 "set label '%s %.0f  %s %.0f' at %.1f, %.1f center tc rgb 'black' font 'Courier,4'\n", 
	$results{abbrs}[$ihome], $splitline[3], $results{abbrs}[$iguest], $splitline[4], $sp, $pos_foot; 
	$pos_foot -= 1; 

	if ( looks_like_number($splitline[3]) ) {
	    $results{played}[$ihome]    = 1; # boolean
	    $results{games}[$ihome]     += 1;
	    $results{gfavor}[$ihome]    += $splitline[3];
	    $results{gcontra}[$ihome]   += $splitline[4];
	    $results{gdiff}[$ihome]     += $splitline[3] - $splitline[4];
	    $results{hgoals}[$ihome]    += $splitline[3];

	    $results{played}[$iguest]   = 1; # boolean
	    $results{games}[$iguest]    += 1;
	    $results{gfavor}[$iguest]   += $splitline[4];
	    $results{gcontra}[$iguest]  += $splitline[3];
	    $results{gdiff}[$iguest]    += $splitline[4] - $splitline[3];
	    $results{agoals}[$iguest]   += $splitline[4];


	    if ( $splitline[3] > $splitline[4] ) {      # home victory
		$results{won}[$ihome]      += 1;
		$results{lost}[$iguest]    += 1;
		$results{points}[$ihome]   += 3;
		$results{hpoints}[$ihome]  += 3;

		#push @results{lgpoints}[$ihome], 3;
		#push @results{lgpoints}[$iguest], 0;

	    } elsif ( $splitline[3] < $splitline[4] ) { # home defeat
		$results{lost}[$ihome]      += 1; 
		$results{won}[$iguest]      += 1;
		$results{points}[$iguest]   += 3;
		$results{apoints}[$iguest]  += 3;

		#push @results{lgpoints}[$ihome], 0;
		#push @results{lgpoints}[$iguest], 3;

	    } else {                                    # draw
		$results{draw}[$ihome]      += 1; 
		$results{points}[$ihome]    += 1;
		$results{draw}[$iguest]     += 1; 
		$results{points}[$iguest]   += 1;
		$results{hpoints}[$ihome]   += 1;
		$results{apoints}[$iguest]  += 1;

		#push @results{lgpoints}[$ihome], 1;
		#push @results{lgpoints}[$iguest], 1;
	    }

	    #if ( scalar @results{lgpoints}[$ihome] > 4) {
		#$tmp = shift @results{lgpoints}[$ihome];
	    #}

	    #if ( scalar @results{lgpoints}[$iguest] > 4) {
		#$tmp = shift @results{lgpoints}[$iguest];
	    #}
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
	for $i (  0 .. $nteams - 1 ) {
	    if ( $results{played}[$i] == 1 ) {
		printf $tt_points "\t\t%s", $results{points}[$i];
	    } else {
		printf $tt_points "\t\t&";
	    }
	}
	printf $tt_points "\n";

    } else {
	printf $of "\n";
    }

    close $of;
}

printf $tgp_1 "plot 'empty.dat' notitle\n";
printf $tgp_7 "plot 'empty.dat' notitle\n";

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


$xmax = 1.2*$sp;
$ymax = int( 6*($nteams - 1)/5);

if ($ymax*5 != 6*($nteams - 1) ){
    $ymax += 1;
}

$ymax = 1.2 * ($ymax * 5 );

printf $tgp_2 "%s", "plot ";
printf $tgp_6 "%s", "plot ";

for $i ( 0 .. $nteams -1 ) {
    printf $of "%s %.0f %.0f %.0f %.0f %.0f %.0f %.0f\n", $results_tmp{abbrs}[$i], $results_tmp{games}[$i], 
    $results_tmp{points}[$i], $results_tmp{gfavor}[$i], $results_tmp{gcontra}[$i], 
    $results_tmp{won}[$i], $results_tmp{lost}[$i], $results_tmp{draw}[$i];

    printf $tt_ph "\t%.0f\t", $results{hpoints}[$i];
    printf $tt_pa "\t%.0f\t", $results{apoints}[$i];
    printf $tt_gh "\t%.0f\t", $results{hgoals}[$i];
    printf $tt_ga "\t%.0f\t", $results{agoals}[$i];

    if ( $i == $nteams -1 ) {
	printf $tgp_2 "'table_pts_h.dat' u (%.0f):%.0f notitle w bar lc rgb '%s'\n", $i, $idx[$i] + 1, "ariel";
	printf $tgp_3 "'table_pts_a.dat' u (%.0f):%.0f notitle w bar lc rgb '%s'\n", $i, $idx[$i] + 1, "ariel";
	printf $tgp_4 "'table_goals_h.dat' u (%.0f):%.0f notitle w bar lc rgb '%s'\n", $i, $idx[$i] + 1, "ariel";
	printf $tgp_5 "'table_goals_a.dat' u (%.0f):%.0f notitle w bar lc rgb '%s'\n", $i, $idx[$i] + 1, "ariel";
	printf $tgp_6 "'table_teams_points.dat' u 1:%.0f title '%s' w lp pt 7 ps %.1f\n", $idx[$i] + 2, $results_tmp{abbrs}[$i], $ps;

    } else {
	printf $tgp_2 "'table_pts_h.dat' u (%.0f):%.0f notitle w bar lc rgb '%s',", $i, $idx[$i] + 1, "ariel";
	printf $tgp_3 "'table_pts_a.dat' u (%.0f):%.0f notitle w bar lc rgb '%s',", $i, $idx[$i] + 1, "ariel";
	printf $tgp_4 "'table_goals_h.dat' u (%.0f):%.0f notitle w bar lc rgb '%s',", $i, $idx[$i] + 1, "ariel";
	printf $tgp_5 "'table_goals_a.dat' u (%.0f):%.0f notitle w bar lc rgb '%s',", $i, $idx[$i] + 1, "ariel";
	printf $tgp_6 "'table_teams_points.dat' u 1:%.0f title '%s' w lp pt 7 ps %.1f,", $idx[$i] + 2, $results_tmp{abbrs}[$i], $ps;
    }
}

printf $tt_ph "\n";
printf $tt_pa "\n";
printf $tt_gh "\n";
printf $tt_ga "\n";


close $of;
