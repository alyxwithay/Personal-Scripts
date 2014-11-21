#!/usr/bin/perl -w
=pod
by Alyx Schubert 9/14/10
This script looks in the alpha.summary file and takes the average of 
replicates.
ARGS: The *alpha.summary file that you want to take averages within.
OUTPUT: A file called alpha.summary.averages
NOTE: The sampleIDs should be in the format IDRun#
NOTE: They should also be in order.
=cut

my($file, $output, @name, $line, $rest, $count, $ID1, $ID2, $sample, $i, @val, $run2, $run1, $r, $c, $avg, @SD);
$ID1 = "nothing";
$run1 = 0;
$c=0;
$count=0;

while(@ARGV)
{
	$file = shift(@ARGV);
	
	#For naming the output file:
	$name[0] = $file;
	$name[1] = "avg";
	$output = join(".", @name);

	open(IN, "<$file") or die ("Cannot open file $file: $!");
	open(OUT, ">>$output") or die ("Cannot open file $output: $!");
	
	while($line = <IN>)
	{
		$count = 0;
		$line =~ /(\w*)\t(.*)/;
		$sample = $1;
		$rest = $2;
		
		#If is the header line:
		if ($sample eq "Sample")
		{
			print OUT "Sample Averages\t$rest\n";
		}
		#Else if is a sample line:
		else
		{

			$c = 0;
			$sample =~ /(.*)Run(\d)/;
			$ID2 = $1;
			$run2 = $2;
			if ($run1 == 1)
			{
				if($run2 == 1)
				{
					$count=1;
				}
			}
			else
			{
				if($run2 == 2)
				{
					$count=1;
				}
			}
			
			$r = $run2-1; #so if run1 then index=0, run2 then index=1
			while($rest =~ /(\d*\.\d*)/g)
			{
				$val[$r][$c] = $1;
				$c++;
			}#end while($rest =~ //g)

			if($count == 1)
			{
				print OUT "AVG $ID2\t";
				for($i = 0; $i < $c; $i++)
				{
					print OUT "$val[$r][$i]\t";
					$SD[$i] = 0;
				}	
				print OUT "\nSD $ID2\t";
				for($i = 0; $i < $c; $i++)
				{
					print OUT "$SD[$i]\t";
				}
				print OUT "\n";
				$count = 0;
			}
			
			#If they should be averaged: 
			#(I could put this all in the else of the previous if)
			if($ID2 eq $ID1 && $run2 != $run1)
			{
				print OUT "AVG $ID2\t";
				for($i = 0; $i < $c; $i++)
				{
					$avg = ($val[0][$i] + $val[1][$i])/2;
					#print "i:$i\n c:$c \n avg: $avg\n";
					print OUT "$avg\t";
					$SD[$i] = abs($avg-$val[0][$i]);
				}
				print OUT "\nSD $ID2\t";
				for($i = 0; $i < $c; $i++)
				{
					print OUT "$SD[$i]\t";
				}
				print OUT "\n";
				$count = 2;
			}#end if($ID2 eq $ID1 && $run2 != $run1)
			
			
			$ID1 = $ID2;
			$run1 = $run2;
			
		}#end else
		
	}#end while($line = <IN>)
	if($count != 2)
	{
		print OUT "AVG $ID2\t";
		for($i = 0; $i < $c; $i++)
		{
			print OUT "$val[$r][$i]\t";
			$SD[$i] = 0;
		}	
		print OUT "\nSD $ID2\t";
		for($i = 0; $i < $c; $i++)
		{
			print OUT "$SD[$i]\t";
		}
		print OUT "\n";
		$count = 2;	
	}

	close(IN) or die ("Cannot open file $file: $!");
	close(OUT) or die ("Cannot open file $output: $!");
}#end while(@ARGV)