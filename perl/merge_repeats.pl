#!/usr/bin/perl -w
=pod
by Alyx Schubert 3/21/12
This script reads in a shared file and finds the repeats and makes an average
of all the OTU counts in a new file. These can then be taken and added to the
current shared file, to replace the two repeats.

ARGS: The arguments called to the command line are the shared file.

=cut

my ($INfile, $OUTfile, $line, @array1, $line1, $line2, $count1, $count2, $item1, $item2, $avg, $avgR);
my $lineNUM=1;
my $ID1 = "NULL";
my $ID2 = "NULL"; 

while(@ARGV)
{
	$INfile = shift(@ARGV); #removes the filename and puts into $names
	#print "infile: $INfile\n";
	push(@array1, $INfile); #puts $names at the end of @array1 array
	push(@array1, "avg"); #if you want to change the name, change here
	$OUTfile = join(".", @array1); #joins everything in @array1 sequentially by "."
	#print "outfile: $OUTfile\n";
	#print "array: @array1\n";
	#print "arg array aft: @ARGV\n";

	open (IN, "<$INfile") or die ("Cannot open file $names: $!");
	open (OUT, ">>$OUTfile") or die ("Cannot open file $output: $!");

	
	while($line = <IN>)
	{
		chomp($line);
		if($lineNUM==1)
		{
			print OUT "$line";
			$lineNUM++;
		}
		else
		{
			$line2=$line;
			if($line =~ /DA\d{5}/)
			{
				$line =~ /(DA\d{5})/;
				$ID2 = $1;
			}
			
			#print "ID2: $ID2 on line $lineNUM\n";
			if($ID2 eq $ID1) #compare current line (ID2) to the previous line (ID1)
			{
				$count1=0;
				$count2=0;
				while ($line1 =~ /(\S*)/g)
				{
					$item1 = $1;
					$count1++;
					$print1 = 1;
					while($line2 =~ /(\S*)/g)
					{
						$item2 = $1;
						$count2++;
						#print "count1,2: $count1, $count2\n";
						if($count1>6 && $count1==$count2 && $item1 ne "" && $item1 ne "\n")
						{
							$avg = ($item1 + $item2)/2;
							$avgR = int($avg+0.5);
							print OUT "$avgR";
							#print "avg: $avg from $item1 & $item2\n";
							$print1 = 0;
							
						}						
						#print "item1, 2: $item1, $item2\n";
					} #end while($line2 =~ /(\S*)/g)
					$count2=0;
					if( $print1 == 1)
					{
						if($item1 eq "")
						{
							print OUT "\t";
							#print "im hereeee!\n";
						}
						elsif($item1 eq "0.03")
						{
							print OUT "\n$item1";
						}
						else
						{
							if($item1 eq $ID2)
							{
								print OUT "$item1";
								print OUT ".avg";
							}
							else
							{
								print OUT "$item1";
							}
						}
					}
					#if($count1==16)
					#{
					#	print OUT "\n";
					#}
				} #end while ($line1 =~ /(\S*)/g)
				#print "done with big while loop\n";
				#print "id1, 2: $ID1, $ID2\n";
			}
			$lineNUM++;
			$line1=$line2;
			$ID1=$ID2;
			#$ID2 = "NULL";
		} #end else	
		#print "$lineNUM\n";
	} #end while($line1 = <IN>)	
	
	close (IN) or die ("Cannot close file $names: $!");
	close (OUT) or die ("Cannot close file $output: $!");
	#print "The end\n";
	
} #end while(@ARGV)