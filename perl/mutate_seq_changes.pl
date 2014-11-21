#!/usr/bin/perl -w
=pod
by Alyx Schubert 6/9/10
This script reads in a sequence and randomly "mutates" the sequence
by making random substitutions throughout the sequence.
ARGS: The files that should be called to the command line are fasta files.
**NOTE: The error rate is hard coded in the subroutine. Change if necessary.
=cut


srand(time|$$);

while (<>)
{
	#Store the sequence ID and place it in new file
	if($_ =~ /^>.*/)
	{
		$ID = $_;
		chomp($ID);
		print "$ID\n";		
	}
	else
	{
		$seq = $_;
		chomp($seq);
		$mutant = mutate($seq);
		print "$mutant\n";
	}
}

exit; 


################################################################
# SUBROUTINES, listed in alphabetical order
################################################################

#Calculates the number of bases that need to be changed for a given error rate
#The error rate has been hard coded in 
#Arguments: $DNA_seq
sub errorrate
{
	my $dna = shift;
	my $len = length($dna);
	my $changes = int(.005*$len); #0.50% error rate
	return $changes;	
}

#Taken from "Beginning Perl for Bioinformatics" p135
#This subroutine mutates DNA sequences via a substitution
#Arguments: $DNA_seq
sub mutate
{
	my($dna) = @_;
	
	#Number of bases to change in order to get a certain error rate
	my($changes) = errorrate($dna);
		
	#Pick a random position in the DNA sequence
	my(@uniquepos);	
	my($pos) = randompos($dna);
	$uniquepos[0] = $pos;
	my($i) = 1;
	my($n) = 0;
	my($x) = 0;
	
	#This ensures that the correct number of unique positions are picked
	while($i<$changes)
	{
		$pos = randompos($dna);
		for($n=0; $n<$i; $n++)
		{
			if ($uniquepos[$n] == $pos)
			{
				$x = 1;
			}
		}
		if ($x==1)
		{
			
			$i--;
		}
		else
		{
			$uniquepos[$i] = $pos;
		}
		$i++;
		$x=0;
	}
	
	my($newbase);	
	for($i=0; $i<$changes; $i++)
	{
		#Pick a random nucleotide
		#This ensures that the new random base to substitute in is not
		#the same base as the one already in the sequence
		do
		{
			$newbase = randomnt();
		}
		until ($newbase ne substr($dna, $uniquepos[$i], 1));
	
		#Insert the random nt into the random position in the DNA
		#The substr arguments mean the following:
		#In the string $dna at position $pos change 1 character to
		#the string in $newbase		
		substr($dna, $uniquepos[$i], 1, $newbase);
	}
	
	return $dna;
}


#Taken from "Beginning Perl for Bioinformatics" p130
#This subroutine randomly selects a nucleotide.
#Arguments: none
#WARNING: must call srand() before calling this function
sub randomnt
{
	my (@nts) = ('A', 'C', 'G', 'T');
	return $nts[rand(@nts)]; #See pod comment below
}
=pod
By putting @nts as argument of rand(), it is read as the size of @nts
and so the values outputted range from 0<=X<(Size of @nts=4), noninclusive 4.
The number spit out by rand then becomes the index in the @nts array, and
that corresponding nucleotide is returned.
=cut


#Taken from "Beginning Perl for Bioinformatics" p127
#This subroutine randomly selects a position in the string.
#Argurments: $dna_sequence
#WARNING: must call srand() before calling this function
sub randompos
{
	my $string = shift; #or can write: my($string) = @_;
	return int(rand(length($string)));
	#ranges from 0 to length-1
}

