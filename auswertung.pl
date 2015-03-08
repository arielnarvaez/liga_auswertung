#!/usr/local/bin/perl

use Cwd;               # to get the directory path
use File::Spec;        # to join the directory path and file name
use File::Basename;    # to get the file name without extension
use POSIX;
use Data::Dumper;
use Scalar::Util qw(looks_like_number);


$league = $ARGV[0];

my $dir = './';
$rteams = $dir.$league."_teams.dat";
$rgames = $dir.$league."_date.dat";

# read games
open my $fh, "<", $rgames or die "can't read open '$fp': $OS_ERROR";
$ngames = 0;
while ( $line = <$fh> ) {
    @splitline = split("&", $line);
    $ngames += 1;
    push( @calendar, @splitline[1] );
}
close $fh or die "can't read close '$fp': $OS_ERROR";

# read teams
open my $fh, "<", $rteams or die "can't read open '$fp': $OS_ERROR";
$nteams = 0;
while ( $line = <$fh> ) {
    @splitline = split("&", $line);
    $nteams += 1;
    push( @teams_name, @splitline[0] );
    push( @teams_abbr, @splitline[1] );
}
close $fh or die "can't read close '$fp': $OS_ERROR";

s{^\s+|\s+$}{}g foreach @teams_name;
s{^\s+|\s+$}{}g foreach @teams_abbr;

my @results;
# results[][0] played games
# results[][1] won
# results[][2] lost
# results[][3] draw
# results[][4] goals favor
# results[][5] goals contra
# results[][6] goals diff
# results[][7] points
# results[][8] team name

for ( my $i = 0; $i < @teams_name; ++$i ) {
   $results[$i][8] = $teams_abbr[$i];
}

$outfile = $dir."table_teams.dat";
open($tt, '>', $outfile) or die "Could not open file $outputfile: $!";	

printf $tt "# sp\t";
for ( $i = 0; $i < @teams_name; ++$i ) {
    printf $tt "\t%s", $teams_abbr[$i];
}
printf $tt "\n";

$sp = 0;
foreach my $ft ( glob($dir.$league."_sp*.dat") ) {
    $played_sp = 0 ; # if a game was played 
    $sp += 1;
    open my $fh, "<", $ft or die "can't read open '$fp': $OS_ERROR";
    while ( $line = <$fh> ) {
	@splitline = split("&", $line);
	s{^\s+|\s+$}{}g foreach @splitline;

	for ( $i = 0; $i < @teams_name; ++$i ) {
	    if ( $teams_name[$i] eq $splitline[1] ) {
		if ( looks_like_number($splitline[3]) ) {
		    $played_sp = 1 ; # if a game was played 
		    $results[$i][0] += 1;                             # played games
		    $results[$i][4] += $splitline[3];                 # goals favor
		    $results[$i][5] += $splitline[4];                 # goals contra
		    $results[$i][6] += $splitline[3] - $splitline[4]; # difference
		    if ( $splitline[3] > $splitline[4] ) {      # victory
			$results[$i][1] += 1; # won 
			$results[$i][7] += 3; # points
		    } elsif ( $splitline[3] < $splitline[4] ) { # defeat
			$results[$i][2] += 1; # lost
		    } else {                                    # draw
			$results[$i][3] += 1; # draw
			$results[$i][7] += 1; # points
		    }
		}
	    }

	    if ( $teams_name[$i] eq $splitline[2] ) {
		if ( looks_like_number($splitline[3]) ) {
		    $results[$i][0] += 1;                             # played games
		    $results[$i][4] += $splitline[4];                 # goals favor
		    $results[$i][5] += $splitline[3];                 # goals contra
		    $results[$i][6] += $splitline[4] - $splitline[3]; # difference
		    if ( $splitline[3] > $splitline[4] ) {      # defeat
			$results[$i][2] += 1; # lost
		    } elsif ( $splitline[3] < $splitline[4] ) { # victory
			$results[$i][1] += 1; # won 
			$results[$i][7] += 3; # points
		    } else {                                    # draw
			$results[$i][3] += 1; # draw
			$results[$i][7] += 1; # points
		    }
		}
	    }

	}
    }

    $outfile = $dir."table_sp".$sp.".dat";
    open($of, '>', $outfile) or die "Could not open file $outputfile: $!";	

    if ( $played_sp == 1 ){
	# sorting bei points, then diff goals and then played games.
	@results_tmp =  sort { -$a->[7] <=> -$b->[7] || 
				   -$a->[6] <=> -$b->[6] || 
				   $a->[0] <=> $b->[0] } @results;
	
	for ( $i = 0; $i < @teams_name; ++$i ) {
	    printf $of "%s %.0f\n", $results_tmp[$i][8], $results_tmp[$i][7];
	}
    } else {
	printf $of "\n";
    }

    close $of;
}


$outfile = $dir."final_table.dat";
open($of, '>', $outfile) or die "Could not open file $outputfile: $!";	

@results_tmp =  sort { -$a->[7] <=> -$b->[7] || 
			   -$a->[6] <=> -$b->[6] || 
			   $a->[0] <=> $b->[0] } @results;

for ( $i = 0; $i < @teams_name; ++$i ) {
    printf $of "%s %.0f %.0f %.0f\n", $results_tmp[$i][8], $results_tmp[$i][7], 
    $results_tmp[$i][6], $results_tmp[$i][0];
}

close $of;



