#!/usr/bin/perl -w
=pod
by Alyx Schubert 6/16/10
This script reads in the reference taxonomy and the classify.seqs output taxonomy
file and compares the two results by saying what percentage similar they are.
ARGS: The taxonomy file to be compared should be called. You can call multiple 
	  taxonomy files with *.taxonomy. The result is a file called 
	  "identity.txt".
NOTE: The files should be sorted according to accession number.
NOTE: Need to change the reference taxonomy accordingly.
=cut

my ($ref_file, $tax_file, $result_file, $line1, $line2, $ID1, $ID2, $taxonA, $taxonB);

while(@ARGV)
{

my $total=0;
my $stat=1;
my $error=0;
my $similarity = 0;

#NOTE: can prompt user, or hard code in to save time if the same every time
#print "Please enter the reference taxonomy filename with full path (unless file in same directory as perl script): \n";
#$ref_file = <STDIN>;

$ref_file = "silva.bacteria.rdp6.tax";
open(IN1, $ref_file) or die("Cannot open file $ref_file : $!");

$tax_file = shift(@ARGV);
open(IN2, $tax_file) or die("Cannot open file $tax_file : $!");

#print "Please enter the name of the output file:\n";
#$result_file = <STDIN>;

#will append results to end of this file:
open(OUT1, ">>identity_results.txt") or die("Cannot open file  : $!");

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
				#do nothing
			}
			else
			{
				$stat = 0; #means that at least one level was wrong
			}
		}
		if($stat==1)
		{
			$total++; #counts the total sequences
		}
		else
		{
			$total++;
			$error++;
			#print "Error in: $ID2\n";
		}
		$stat=1;
	}
	#else{print "ids do not match";}
}

$similarity = 100*($total-$error)/$total;
chop($tax_file);

print OUT1 "$tax_file: ";
#print OUT1 "The total number of sequences: $total\n";
#print OUT1 "The total number of errors: $err\n";
print OUT1 "percent similarity to the reference is %\t$similarity\n";


=pod
print "$tax_file: ";
#print "The total number of sequences: \t$total\n";
#print "The total number of errors: \t$err\n";
print "The percent similarity to the reference is %\t$similarity\n\n";
=cut
close(IN1) or die("Cannot close file $ref_file: $!");
close(IN2) or die("Cannot close file $tax_file: $!");
close(OUT1) or die("Cannot close file: $!");

}#end while(@ARGV)
