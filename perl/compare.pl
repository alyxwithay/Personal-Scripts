#!/usr/bin/perl -w
=pod
by Alyx Schubert 6/23/10
This script reads in two taxonomy files and compares them. If one is shorter
than the other it doesn't count against it. Returns a percentage of how many
sequences matched.
ARGS: Only two files should be entered in the command line, which are the two files
	  that you want compared. The result is a file, which is named whatever you call
	  it.
NOTE: The files should be sorted according to accession number. 
NOTE: In the command line there should be two files for comparison entered.
=cut

my ($result_file, $line1, $line2, $ID1, $ID2, $taxonA, $taxonB);
my($input1, $input2);

my $total = 0;
my $stat = 1;
my $error = 0;
my $similarity = 0;
my $tax2 = 0;
my $pass = 0;

while(@ARGV)
{
	if(scalar(@ARGV)>2)
	{
		die("Only call two arguments to be compared.");
	}
	
	$input1 = shift(@ARGV);
	$input2 = shift(@ARGV);
	open(IN1, $input1) or die("Cannot open file $input1 : $!");
	open(IN2, $input2) or die("Cannot open file $input2 : $!");
	
	#print "Please enter the name of the output file:\n";
	#$result_file = <STDIN>;
	$result_file = "comparisons.txt";
	open(OUT1, ">>$result_file") or die("Cannot open file $result_file : $!");

	while ($line1 = <IN1>)
	{
		$line1 =~ /^(\S*)/;
		$ID1 = $1;	
		#print "ID1 is: $ID1\n";
		$line2 = <IN2>;
		$line2 =~ /^(\S*)/;
		$ID2 = $1;
		#print "ID2 is: $ID2\n";
		
=pod	
NOTE: These two files need to have the same sequences and thus also the same
	  number of sequences.
=cut
		#print OUT1 "ID: $ID1\n";
		if ($ID1 eq $ID2)
		{
			while($line2 =~ /(\w*)\(/g)
			{
				$tax2++; #number of tax levels in seq #2
			}

			
			#first check through all tax levels in #1
			while ($line1 =~ /(\w*)\(/g)
			{
				$taxonA = $1;
				#print OUT1 "taxonA: $taxonA \n";
				if($line2 =~ /(\w*)\(/g)
				{
					$taxonB = $1;
					$pass++; #count how many times go through this if statement
					
					#if $pass is greater than then number of tax levels for #2,
					#then to avoid wrapping around to the beginning:
					if($pass>$tax2) 
					{
						$taxonB = $taxonA;
					}
				}
				else
				{
					#case where there is more in #1 than is in #2
					$taxonB = $taxonA;
				}
				#print OUT1 "taxonB: $taxonB \n";
				if($taxonA eq $taxonB)
				{
					#do nothing
				}
				else
				{
					$stat = 0; #means that at least one level was wrong
					#print OUT1 "error at $ID1\n";
				}
			} #end while ($line1 =~ /(\w*)\(/g)

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
			$tax2=0;
			$pass=0;
			#print OUT1 "\n";
		}#end if ($ID1 eq $ID2)
	}#end while ($line1 = <IN1>)

$similarity = 100*($total-$error)/$total;

print OUT1 "$input1 vs $input2\t";
#print OUT1 "The total number of sequences compared:\t$total\n";
print OUT1 "The percent match is %\t$similarity\n\n";

=pod
print "$tax_file";
print "The total number of sequences: $total\n";
print "The total number of errors: $err\n";
print "The percent similarity to the reference is %$similarity\n\n";
=cut

close(IN1) or die("Cannot close file $input1: $!");
close(IN2) or die("Cannot close file $input2: $!");
close(OUT1) or die("Cannot close file $result_file: $!");
}#end while(@ARGV)