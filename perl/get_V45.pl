#!/usr/bin/perl -w
=pod
by Alyx Schubert 6/9/10
This script reads in V35 sequences and extrapolates the V45 (last 200bp)
into a new file with its corresponding ID
ARGS: The arguments called to the command line are *.fasta or *.fa or *.ngfa files
=cut

while (<>)
{
	#Store the sequence ID and place it in new file
	if($_ =~ /^>.*/)
	{
		$ID = $_;
		chomp($ID);
		print "$ID\n";		
	}
	#Store the sequence, find the last 200bp (V45) and put it with its ID
	else
	{
		$seq = $_;
		chomp($seq);
		#$len = length($seq);
		#print "Sequence Length: $len\n";
		$seq =~ /(\w{200})\Z/;
		$end = $1;			
		print "$end\n";
		#print "$seq\n";
	}

}