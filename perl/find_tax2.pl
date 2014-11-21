#!/usr/bin/perl -w
=pod
by Alyx Schubert 6/28/10
This script reads in a file with a list of ID's to find. It returns the data
in the file associated with those ID's.
ARGS: The arguments called to the command line are a list of names/IDs file,
	  followed by the file to search for them in.
OUT: Output is a new file that is named *.subset. For multiple files, need a shell.
NOTE: It's easiest when both inputted files are sorted and you know that you
	  will find every ID in the file you are looking for.
NOTE: May need to tailor to whatever kind of file you are parsing through.
	  Current file type set to: *.taxonomy
=cut

my($names, $file, $output, $line1, $line2, $data1, $data2, $dataP);
my $ID1 = "NULL";
my $ID2 = "NULL";
my $stat = 0;
my $nomatch = 0; 

while(@ARGV)
{
	$names = shift(@ARGV);
	push(@ARGV, "subset"); #if you want to change the name, change here
	$output = join(".", @ARGV);
	$file = shift(@ARGV);
	shift(@ARGV); #gets rid of the extra name added before
	open (NAMES, "<$names") or die ("Cannot open file $names: $!");
	open (FILE, "<$file") or die ("Cannot open file $file: $!");
	open (OUT, ">>$output") or die ("Cannot open file $output: $!");
	
	while($line1 = <NAMES>)
	{
		$nomatch = 0;
		$stat = 0;
		
		$line1 =~ /^(\S*)/; #nonwhitespace characters
		$ID1 = $1;		
		#print "ID1: $ID1\n";
		print OUT "$ID1\t";
		until($ID1 eq $ID2)
		{
			if(eof(FILE))
			{
				close (FILE) or die ("Cannot close file $file: $!");
				open (FILE, "<$file") or die ("Cannot open file $file: $!");
				$stat++;
				if($stat>1)
				{
					print OUT "Match not found\n";
					$nomatch = 1;
					last;
				}
			}
			$line2 = <FILE>;
			$line2 =~  /^(\S*)/; #nonwhitespace characters
			$ID2 = $1;
			#print "ID2: $ID2\n";
		}
		if($nomatch == 1)
		{
			next;
		}
		#$line2 = <FILE>;
		$line2 =~ /\t(\S*)\t(\S*)/;
		$data1 = $1;
		$data2 = $2; #should print out the taxonomy information, whereas putting $1 will give the OTU size
		$data2 =~ /\w*\W\d*\W*\"*(\w*)\(/;
		#Bacteria(100);Firmicutes(100);unclassified(100);unclassified(100);unclassified(100);unclassified(100);
		#Bacteria(100);Firmicutes(100);Clostridia(100);Clostridiales(100);Clostridiaceae_1(100);Clostridium_sensu_stricto(100);
		$dataP = $1;
		print OUT "$data1\t$dataP\t$data2\n";

		
		
	} #end while($line1 = <NAMES>)
	
	close (NAMES) or die ("Cannot close file $names: $!");
	close (FILE) or die ("Cannot close file $file: $!");
	close (OUT) or die ("Cannot close file $output: $!");
	
} #end while(@ARGV)