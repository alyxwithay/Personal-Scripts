#!/usr/bin/perl -w
=pod
by Alyx Schubert 6/22/10
This script reads in the reference taxonomy and the classify.seqs output taxonomy
file and compares the two results by saying what percentage similar they are at each
taxonomic level.
ARGS: Nothing should be called to the command line. The result is a file called
	  "similaritydepth_results.txt".
NOTE: If you want the error to reflect only the highest taxonomy where the error
	  occurs (since after that everything will also be erroneous), then include the
	  "last;" statement below. Otherwise if you want the error to matriculate down to
	  the lowest taxonomic level then comment this statement out.
NOTE: The files should be sorted according to accession number.
=cut

my ($ref_file, $tax_file, $result_file, $line1, $line2, $ID1, $ID2, $taxonA, $taxonB);
#my($tot1, $tot2, $tot3, $tot4, $tot5, $tot6, $tot7, $tot8, $tot9);
#my($err1, $err2, $err3, $err4, $err5, $err6, $err7, $err8, $err9);
#my($sim1, $sim2, $sim3, $sim4, $sim5, $sim6, $sim7, $sim8, $sim9);
my(@tot)= qw(0 0 0 0 0 0 0 0 0);
my @err = qw(0 0 0 0 0 0 0 0 0);
my @sim = qw(0 0 0 0 0 0 0 0 0);

my $total=0;
my $error=0;
my $similarity = 0;
my $level=0;

#NOTE: can prompt user, or hard code in to save time if the same every time
#print "Please enter the reference taxonomy filename with full path (unless file in same directory as perl script): \n";
#$ref_file = <STDIN>;

#open(IN1, $ref_file) or die("Cannot open file  : $!");
$ref_file = "ref.tax";
open(IN1, $ref_file) or die("Cannot open file $ref_file : $!");

print "Please enter the output taxonomy filename with full path (unless file in same directory as perl script): \n";
$tax_file = <STDIN>;

open(IN2, $tax_file) or die("Cannot open file $tax_file : $!");

#print "Please enter the name of the output file:\n";
#$result_file = <STDIN>;

open(OUT1, ">>identitydepth_results_accum.txt") or die("Cannot open output file : $!");

while ($line1 = <IN1>)
{
	$line1 =~ /^(\S*)/;
	$ID1 = $1;	
	#print "ID1 is: $ID1\n";
	$line2 = <IN2>;
	$line2 =~ /^(\S*)/;
	$ID2 = $1;
	#print "ID2 is: $ID2\n";
	
	#In other situations, the accession numbers might not be lined up like
	#they are in the files I'm testing today, so in that case I might have
	#to get the first ID of the output file and find the right ID of the
	#ref file and close/open files in a loop or something
	if ($ID1 eq $ID2)
	{
		#This will match the entire taxonomy, if just one level is wrong
		#then the whole taxonomy will be considered wrong
		$total++;
		while ($line1 =~ /(\w*);/g)
		{
			$taxonA = $1;
			#print "taxon1: $taxon1\n";
			if($line2 =~ /(\w*)\(/g)
			{
				$taxonB = $1;
			}
			else
			{
				#case where there is more to the ref.tax than is in out.tax
				$taxonB = "NULL";
				#print "reached end of line2\n";	
			}
			#print "taxon2: $taxon2\n";
			if($taxonA eq $taxonB)
			{
				$tot[$level]++;
				$level++;
			}
			else
			{
				$tot[$level]++;
				$err[$level]++;
				$level++;	
=pod
NOTE: If you want the errors to accumulate down the taxonomy (if there is an error
in the phylum, & you want the error to matriculate down to the genus and so forth)
then you should comment out this last statement.
=cut
				#last; #exit while loop at the first error, since everything after that is wrong
			}
		}
		$level=0;
	}
	#else{print "ids do not match";}
}

foreach(0..8)
{
	if ($tot[$_]==0)
	{
		$sim[$_]="NA";
		next;
	}
	$sim[$_] = 100*($tot[$_]-$err[$_])/$tot[$_];
}

print OUT1 "$tax_file";
print OUT1 "Total number of sequences: \t$total\n";
print OUT1 "Taxonomic Level Breakdowns:\n";

foreach(0..8)
{
	$level = $_+1;
	print OUT1 "$level: % \t$sim[$_]\n";	
}

print OUT1 "\n";

#print OUT1 "Totals: @tot\nErrs: @err\n";

close(IN1) or die("Cannot close file $ref_file: $!");
close(IN2) or die("Cannot close file $tax_file: $!");
close(OUT1) or die("Cannot close file: $!");
