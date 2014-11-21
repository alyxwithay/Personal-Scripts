#!/usr/bin/perl -w
=pod
by Alyx Schubert 3/6/13
This script__
ARGS: The arguments called to the command line are:
		-relabund file
		-cutoff value for number of top OTUs
OUT: Output is a new file that is named *.top.

=cut

my($abund, $output, $tax, $cutoff, $line1, $number, @rank, @otus, @array, @combo);
my $header=1;
my $num=25;
my $stat=0;
my $max=-1;
my $index=0;
my $maxind=-1;
my $sum=0;
my $other=0;

while(@ARGV)
{
	$abund=shift(@ARGV);
	$cutoff=shift(@ARGV);
	$output = join(".", ($abund, "top$cutoff", "txt")); #if you want to change the name, change here
	#$tax=shift(@ARGV);	
	open (ABUND, "<$abund") or die ("Cannot open file $names: $!");
	#open (TAX, "<$tax") or die ("Cannot open file $file: $!");
	open (OUT, ">>$output") or die ("Cannot open file $output: $!");
	
	while($line1 = <ABUND>)
	{
		
		if($header==1)
		{}
		else
		{
			#$num = 0;
#get the values into an array			
			while($line1 =~ /(\S*)/g) #picks up words/numbers/ids in addition to spaces
			{
				$num = $1;
				if($stat<6) #gets you to the first value
				{}
				elsif($num =~ /\S/) #double checks isn't a space
				{
					#print "$num\n";
					push(@array, $num); #@array stores original values
				}	
				$stat++;			
			}#end while($line1 =~ /(\S*)/g)
			#print "@array\n";
			#print "$array[2]\n$array[3]\n";
			
#next section for finding the max value and put	into order along with the otu indices		
			for ($i=0; $i<@array; $i++) 
			{
				for($j=0; $j<@array; $j++)
				{
					if($array[$j]>$max)
					{
						$max=$array[$j];
						$index=$j;
						#print "$max, $index\n";
					}
					
				}#end for($j=0; $j<length(@array); $j++)

				push(@rank, $max);
				$array[$index]=-1;
				push(@otus, $index); #stores the index that the max was found at in @array
				$max=-1;
			}#end for ($i=0; $i<length(@array); $i++)
			
			#print "@rank\n";
			#print "@otus\n";
			
			for($l=0; $l<$cutoff; $l++)
			{
				$found=0;
				for ($k=0; $k<@combo; $k++)
				{
					if($otus[$l]==$combo[$k])
					{
						$found=1;
						#print "found\n";
					}

				}#end for ($k=0; $k<@combo; $k++)
				if($found==0)
				{
					push(@combo, $otus[$l]);
				}
			}#end for($l=0; $l<$cutoff; $l++)
			
			@rank=0;
			shift(@rank);			
		} #end else 
		$header = 0;
		$stat=0;
		@otus = 0;
		shift(@otus);
		@array = 0; #reset @rank array
		shift(@array); #gets rid of 0 just added

		
	}#end while($line1 = <ABUND>)
	
	$header=1;
	#print "combined array: @combo\n";				
	close (ABUND) or die ("Cannot close file $names: $!");
#now have the array @combo containing the the top OTUs as defined by $cutoff for each group	

	print OUT "Group\t";

#next section is grabbing the header and values for the @combo array
	open (ABUND, "<$abund") or die ("Cannot open file $names: $!");
	while($line1 = <ABUND>)
	{
		if($header==1) #grabbing the proper header values
		{
			while($line1 =~ /(\S*)/g)
			{
				#print "here\n";
				$head=$1;
				if($stat<6)
				{}
				elsif($head =~/\S/)
				{
					push(@array, $head);
				}
				$stat++;
			}#end while($line1 =~ /(\S*)/g)
			#print "heading: @array\n";
			
			for($x=0; $x<@combo; $x++)
			{
				$a=$combo[$x];				
				print OUT "$array[$a]\t";
				$a=-1;
			}
			
			@array = 0; #reset @rank array
			shift(@array); #gets rid of 0 just added	
			print OUT "Other\n";
		}
		else #grabbing the values for the given OTUs
		{
			$stat=0;
			while($line1 =~ /(\S*)/g) #picks up words/numbers/ids in addition to spaces
			{
				$num = $1;
				if($stat==2)
				{
					print OUT "$num\t";
				}
				if($stat<6) #gets you to the first value
				{}
				elsif($num =~ /\S/) #double checks isn't a space
				{
					#print "$num\n";
					push(@array, $num); #@array stores original values
				}	
				$stat++;			
			}#end while($line1 =~ /(\S*)/g)
			#print "@array\n";
			$sum=0;
			for($x=0; $x<@combo; $x++)
			{
				$a=$combo[$x];				
				print OUT "$array[$a]\t";
				$sum=$sum+$array[$a];
				$a=-1;
			}
			$other=1-$sum;
			print OUT "$other\n";
		}
		$header=0;
		$stat=0;
		@array = 0; #reset @rank array
		shift(@array); #gets rid of 0 just added		
	}#end the second while($line1 = <ABUND>)
	
	
	close (ABUND) or die ("Cannot close file $names: $!");
#	close (TAX) or die ("Cannot close file $file: $!");
	close (OUT) or die ("Cannot close file $output: $!");
	
}#end while(@ARGV)
