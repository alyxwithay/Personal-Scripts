#!/usr/bin/perl -w
=pod
by Alyx Schubert 6/28/10
This script reads in a taxonomy file. It returns the number of phyla and and 
how many of each there are.
ARGS: The arguments called to the command line are a taxonomy file.
OUT: The output is a new file called *.phyla. The "NONE" category is the same
	 as "unclassified" in mothur.

=cut

my($file, $output, $line1, @name, @phyla, @count, $unique);


while(@ARGV)
{
	$name[1] = "phyla";
	$phyla[0] = "NONE";
	$count[0] = 0;
	$unique = 0;
	my $i = 0;
	my $total =0;
	my $stat = 1;
	
	
	$file = shift(@ARGV);
	$name[0] = $file;
	$output = join(".", @name);

	open (FILE, "<$file") or die ("Cannot open file $file: $!");
	open (OUT, ">>$output") or die ("Cannot open file $output: $!");
	
	print OUT "$file\nPhyla\tAbundance\n";

	while($line1 = <FILE>)
	{
		$stat=1;
		$line1 =~ /\tBacteria\(\d*\);(\w*)\(/; #nonwhitespace characters
		$phylum = $1;	
		if($phylum)
		{
		}	
		else
		{
			$phylum = "NONE";
		}
		
		#$total++;

		#print "phylum: $phylum\n";
		#print "phyla 1: @phyla\n";
		for($i=0; $i <= $unique; $i++)
		{
		#	print "i:$i\n";
		#	print "Compare $phyla[$i] to $phylum\n";
			if($phyla[$i] eq $phylum)
			{
				$count[$i]++;
				$stat = 1;
				last;
			}
			else
			{
				$stat = 0;
			}
		}
		if($stat==0)
		{
			push(@phyla, $phylum);
			push(@count, 1);
			$unique++;
		}
		#print "Phyla2: @phyla\ncount: @count\n\n";
	} #end while($line1 = <FILE>)
	
	#shift(@phyla);
	#shift(@count);
	#print "@phyla\nunique:$unique\n";
	
	for($i=0; $i<=$unique; $i++)
	{
		print OUT "$phyla[$i]\t$count[$i]\n";
	}
	
	close (FILE) or die ("Cannot close file $file: $!");
	close (OUT) or die ("Cannot close file $output: $!");
	
} #end while(@ARGV)