#!/usr/bin/perl -w
=pod
by Alyx Schubert 6/23/10
This script reads in the classify.seqs output taxonomy file and calculates how deeply
each sequence is classified (as in how many taxonomic levels did it get assigned?).
ARGS: Multiple *.taxonomy files can be listed in the command line and the 
	  result is a *.taxonomy.count file
NOTE: The files should be sorted according to accession number. They should also 
	  have bootstrap values in ().
=cut

my ($input, $output, $line, $ID);
my $total=0;
my @A = ("count");

while (@ARGV)
{
	$input = shift(@ARGV);
	unshift(@A, $input); #add $input file to beginning of array
	$output = join('.', @A); #join the two elements
	shift(@A); #remove the $input file from beginning
	open(OUT1, ">>$output") or die("Cannot open output file: $!");
	
	print OUT1 "Accession#\tNumber of Levels\n";
	
	open(IN1, $input) or die("Cannot open input file $input: $!");

	while($line = <IN1>)
	{
		#$line = $_;
		$line =~ /^(\S*)/;
		$ID = $1;	
		#print "ID1 is: $ID1\n";
		print OUT1 "$ID\t";
		
		while ($line =~ /(\w*)\(/g)
		{
			$total++;
		}
		print OUT1 "$total\n";
		$total = 0;
	}

close(IN1) or die("Cannot close file $input: $!");
close(OUT1) or die("Cannot close file: $!");
}