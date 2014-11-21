#!/usr/bin/perl -w
=pod
by Alyx Schubert 9/10/10
This script looks in individual *.summary files outputted from summary.single() for
alpha diversity measurements. It will parse through these files and extract the
result of all the calculators that were called in mothur for summary.single() 
so that all the samples and their results are in one file.
ARGS: The *.summary files that you want to search through should be called.
OUTPUT: A file called alpha.summary.
NOTE: If there are multiple files called then they should all have the same
	  calculation results in each and in the same order. For example, if you 
	  call summary.single(calc=nseqs-coverage-npshannon), then all the files
	  should have the same headings nseqs \t coverage \t npshannon. Otherwise
	  when the results from multiple files are grabbed the numbers might not 
	  correspond with the correct heading, etc.
NOTE: If there are multiple files, then all filenames should be in the format
	  *.final.an.*.summary, where the first star is the same for them all and 
	  is the name of the data set and the second star is variable and is the 
	  name of the individual samples.
=cut

my($file, $output, $name, $line, $headers, $results, $sampNum, $sampID, $type);
$sampNum = 0;

while(@ARGV)
{
	$file = shift(@ARGV);
	$file =~ /(\w*)\..*\.(\w*)\.(Schloss.*)\.summary/;
	$name = $1;
	$type = $2;
	$sampID = $3;
	
	$sampNum++;
	
	#For naming the output file:
	$name[2] = "alpha.summary";
	$name[1] = $type;
	$name[0] = $name;
	$output = join(".", @name);
	
	open(IN, "<$file") or die ("Cannot open file $file: $!");
	open(OUT, ">>$output") or die ("Cannot open file $output: $!");
	
	#If this is the first of many files to be opened, the output file needs
	#the headers from the first file
	if($sampNum==1)
	{
		print OUT "Sample\t";
		while($line = <IN>)
		{
			if($line =~ /label/)
			{
				$line =~ /label\t(.*)/;
				$headers = $1;
				print OUT "$headers\n";
			}
			else
			{
				$line =~ /\d\t(.*)/;
				$results = $1;
				print OUT "$sampID\t$results\n";
			}
		}#end while($line = <IN>)
	}#end if($sampleNum==1)
	
	#If this is the 2nd or ith file (not the first) then you don't need to 
	#grab the header file
	else
	{
		while($line = <IN>)
		{
			if($line =~ /label/)
			{
				#do nothing, don't want the header file
			}
			else
			{
				$line =~ /\d\t(.*)/;
				$results = $1;
				print OUT "$sampID\t$results\n";
			}
						
		}#end while($line = <IN>)
	}#end else
	
	close (IN) or die("Cannot close file $file: $!");
	close (OUT) or die("Cannot close file $output: $!");
	
}#end while (@ARGV)