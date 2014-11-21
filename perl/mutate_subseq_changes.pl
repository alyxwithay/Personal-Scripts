#!/usr/bin/perl -w
=pod
by Alyx Schubert 6/9/10
This script reads in a sequence and randomly "mutates" a subsequence of a
given sequence, for instance the first 200bp of the V35 sequences, by
making random substitutions and creating indels throughout the subsequence.
It gets an error rate which is used to calculate the total #changes needed.
ARGS: The files called in the command line are fasta files.
**NOTE: The error rate is hard coded in the subroutine. Change if necessary.
**NOTE: The subsequence location to be mutated is also hard coded in, but
		this can be changed for different regions.
**NOTE: If you get the error "Use of uninitialized value in length..." this 
		means that you are trying to grab a subseq that is longer than the seq
		you actually have.
**NOTE: If you want only substitutions, use mutatesubseq(), if you want indels
		and substitutions then use mutatesubseq_adv()
=cut


srand(time|$$);
our $rate=.01; #percentage of the total sequence to change
our $ins=.4; #percentage of the total changes to be made
our $del=.4; #percentage of the total changes to be made
our $sub=.2; #percentage of the total changes to be made

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
		$mutant = mutatesubseq_adv($seq);
		print "$mutant\n";
	}
}
 	
exit; 



################################################################
# SUBROUTINES, listed in alphabetical order
################################################################

#Calculates the number of bases that need to be changed for a given error rate
#NOTE: The error rate has been hard coded where indicated
#Arguments: $DNA_seq
sub errorrate
{
	my $dna = shift;
	my $len = length($dna);
	my $changes = int($rate*$len); #error rate, hard coded above
	return $changes;	
}

#Taken from "Beginning Perl for Bioinformatics" p135
#But adapted by Alyx Schubert
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
	#and that all the positions are in fact unique
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

#Taken from "Beginning Perl for Bioinformatics" p135
#But adapted by Alyx Schubert
#This subroutine mutates with not only substitutions but also indels
#Arguments: $DNA_seq
sub mutate_adv
{
	my($dna) = @_;
	
	#ERROR RATE
	#Number of bases to change in order to get a certain error rate
	my($changes) = errorrate($dna);
	
	#FILL @UNIQUEPOS
	#Pick a random position in the DNA sequence
	my(@uniquepos);	
	my($pos) = randompos($dna);
	$uniquepos[0] = $pos;
	my($i) = 1;
	my($n) = 0;
	my($x) = 0;
	
	#This ensures that the correct number of unique positions are picked
	#and that all the positions are in fact unique
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

	#SUBSTITUTIONS FIRST
	my $totsub = int($sub * $changes);
	my($newbase);
	for($x=0; $x<$totsub; $x++)
	{
		#Pick a random nucleotide
		#This ensures that the new random base to substitute in is not
		#the same base as the one already in the sequence
		do
		{
			$newbase = randomnt();
		}
		until ($newbase ne substr($dna, $uniquepos[$x], 1));
	
		#Insert the random nt into the random position in the DNA
		#The substr arguments mean the following:
		#In the string $dna at position $pos change 1 character to
		#the string in $newbase	
		substr($dna, $uniquepos[$x], 1, $newbase);
	}
		
	#INSERTIONS & DELETIONS
	#I'm doing it this way because if I just multiply them both and truncate
	#the decimal everytime, I'm going to end up having a smaller error rate
	my $pick = int(rand(2));
	my $midtot;
	if ($pick == 0)
	{
		$midtot = $changes - int($ins * $changes);
	}
	else
	{
		$midtot = $totsub + int($del * $changes);
	}
	
	#Deletions
	my $size = scalar(@uniquepos);
	while($x < $midtot)
	{
		substr($dna, $uniquepos[$x], 1, "");
		
		#Now need to change the rest of the positions that are bigger than the
		#position just deleted so the same nts are targeted downstream, (p-1)
		for(my $n=$x+1; $n < $size; $n++)
		{
			if($uniquepos[$n] > $uniquepos[$x])
			{
				$uniquepos[$n] -= 1;
			}
		}
		$x++;
	}
	
	#Insertions
	while($x < $changes)
	{
		$newbase = randomnt();
		substr($dna, $uniquepos[$x], 0, $newbase);
		
		#Now need to change the rest of the positions that are bigger than the
		#position just inserted so same nts are targeted downstream, (p+1)
		for($n=$x+1; $n < $size; $n++)
		{
			if($uniquepos[$n] > $uniquepos[$x])
			{
				$uniquepos[$n] += 1;
			}
		}
		$x++;
	}
	
	return $dna;
}


#This subroutine will mutate one subsequence of a given sequence
#Arguments: $dna_sequence
#NOTE: The subsequence location has been hard coded where indicated
sub mutatesubseq
{
	my ($dna) = @_;
	#NOTE: Change size and location of subsequence by altering withing parenthesis:
	$dna =~ /^(\w{200})/; #subsequence to mutate is beginning 200bp
	my ($end) = $1;
	my($mutEnd) = mutate($end);
	
	#NOTE: substr arguments must also be changed according to where sub sequence is
	#This is for mutating at the end of the sequence:
	#substr($dna, (length($dna)-length($mutEnd)), (length($mutEnd)), $mutEnd); 
	#This is for mutating at the beginning of the sequence:
	substr($dna, 0, (length($mutEnd)), $mutEnd);
	
	return $dna;
}

#This subroutine will mutate one subsequence of a given sequence w/sub & indels
#Arguments: $dna_sequence
#NOTE: The subsequence location has been hard coded where indicated
sub mutatesubseq_adv
{
	my ($dna) = @_;
	#NOTE: Change size and location of subsequence by altering withing parenthesis:
	$dna =~ /^(\w{200})/; #subsequence to mutate is beginning 200bp
	my ($end) = $1;
	my($mutEnd) = mutate_adv($end);
	
	#NOTE: substr arguments must also be changed according to where sub sequence is
	#This is for mutating at the end of the sequence:
	#substr($dna, (length($dna)-length($mutEnd)), (length($mutEnd)), $mutEnd); 
	#This is for mutating at the beginning of the sequence:
	substr($dna, 0, (length($mutEnd)), $mutEnd);
	
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
