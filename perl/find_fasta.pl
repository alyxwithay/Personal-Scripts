#!/usr/bin/perl -w
=pod
by Alyx Schubert 6/24/10
This script reads in a file with a list of ID's to find. It returns the data
in the file associated with those ID's.
ARGS: The arguments called to the command line are a list of names/IDs file,
	  followed by the file to search for them in.
NOTE: It's easiest when both inputted files are sorted and you know that you
	  will find every ID in the file you are looking for.
NOTE: May need to tailor to whatever kind of file you are parsing through.
	  Current file type set to: *.ngfa
=cut

my($names, $file, $output, $line1, $line2, $data);
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
		print OUT ">$ID1\n";
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
			$line2 =~  /^>(\S*)/; #nonwhitespace characters followed by tab
			$ID2 = $1;
			#print "ID2: $ID2\n";
		}
		if($nomatch == 1)
		{
			next;
		}
		$line2 = <FILE>;
		$line2 =~ /(\S*)/;
		$data = $1;
		print OUT "$data\n";

		
		
	} #end while($line1 = <NAMES>)
	
	close (NAMES) or die ("Cannot close file $names: $!");
	close (FILE) or die ("Cannot close file $file: $!");
	close (OUT) or die ("Cannot close file $output: $!");
	
} #end while(@ARGV)