#!/usr/bin/perl -w
=pod
by Alyx Schubert 6/17/10
This script reads in a sequence and randomly "mutates" a subsequence of a
given sequence, for instance the first 200bp of the V35 sequences, by
making random substitutions and creating indels throughout the subsequence.
It goes through base by base and "rolls the die" and according to a given error
rate it will be mutated or not.
ARGS: The files called to the command line should be fasta files.
**NOTE: The error rate is hard coded in the subroutine. Change if necessary.
**NOTE: The subsequence location to be mutated is also hard coded in, but
		this can be changed for different regions.
**NOTE: If you get the error "Use of uninitialized value in length..." this 
		means that you are trying to grab a subseq that is longer than the seq
		you actually have.
=cut

srand(time|$$);

#If a base is mutated, the breakdown of mutation method is:
our $sub=.2; #percentage of the total changes to be made
our $del=.4; #percentage of the total changes to be made
#NOTE: By default, insertions are 1-$sub-$del.

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
		$mutant = mutsubseq($seq);
		print "$mutant\n";
	}
}
 	
exit; 


################################################################
# SUBROUTINES
################################################################

#Looks at each nt in the sequence and each nt has a certain %chance of being
#mutated, depending on the chosen error rate.
#Arguments: $dna
#NOTE: To change error rate, call different method below
sub mutate
{
	my($dna) = @_;
	
	my $len = length($dna);

	for(my $i=0; $i<$len; $i++)
	{
		#Mutate or not?
		#NOTE: If you want the error rate changed, then call diff function
		my $stat = one();
		
		#Mutating...
		if ($stat==1)
		{
			my $meth = mutmethod();
			
			#Substitution
			if($meth==0)
			{
				my $newbase;
				do {
					$newbase = randomnt();
				} 
				until ($newbase ne substr($dna, $i, 1));
				substr($dna, $i, 1, $newbase);
			}
			
			#Deletion
			elsif($meth==1)
			{
				substr($dna, $i, 1, "");
				$i--;
				$len--;
			}
			
			#Insertion
			else
			{
				$newbase = randomnt();
				substr($dna, $i, 0, $newbase);
				$i++;
				$len++;
			}
		}
	}
	return $dna;
	
}

#To mutate or not? error rate of 0.5%
#status=0 is a no, status=1 is a yes
#Arguments: none
sub half
{
	my $status = 0;
	my @a = (0);
	my $dice = int(rand(200)); #0-199
	foreach(@a)
	{
		if ($_==$dice)
		{
			$status = 1;
		}
	}
	
	return $status
}

#To mutate or not? error rate of 1%
#status=0 is a no, status=1 is a yes
#Arguments: none
sub one
{
	my $status = 0;
	my @a = (0);
	my $dice = int(rand(100)); #0-99
	foreach(@a)
	{
		if ($_==$dice)
		{
			$status = 1;
		}
	}
	
	return $status
}

#To mutate or not? error rate of 2%
#status=0 is a no, status=1 is a yes
#Arguments: none
sub two
{
	my $status = 0;
	my @a = (0..1);
	my $dice = int(rand(100)); #0-99
	foreach(@a)
	{
		if ($_==$dice)
		{
			$status = 1;
		}
	}
	
	return $status
}

#To mutate or not? error rate of 3%
#status=0 is a no, status=1 is a yes
#Arguments: none
sub three
{
	my $status = 0;
	my @a = (0..2);
	my $dice = int(rand(100)); #0-99
	foreach(@a)
	{
		if ($_==$dice)
		{
			$status = 1;
		}
	}
	
	return $status
}

#Picks which way to mutate a sequence
#meth=0 is substitution, meth=1 is deletion, meth=2 is insertion
#Arguments: none
sub mutmethod
{
	my $method = 0;
	
	my $dice = int(rand(100)); #0-99
	if($dice<($sub*100)) 
	{
		#substitution
		$method=0;
	}
	elsif($dice>=($sub*100) && $dice<(($sub*100)+($del*100)))
	{
		#deletion
		$method=1;
	}
	else
	{
		#insertion
		$method=2;
	}
		
	return $method;
}

#Returns a random nucleotide
#Arguments: none
sub randomnt
{
	my (@nts) = ('A', 'C', 'G', 'T');
	return $nts[rand(@nts)]; #See pod comment below
}

sub mutsubseq
{
	my ($dna) = @_;
	my $dnaLen = length($dna);
	#NOTE: Change size and location of subsequence by altering withing parenthesis:
	$dna =~ /^(\w{200})/; #subsequence to mutate is beginning 200bp
	my ($end) = $1;
	my $endLen = length($end);
	my($mutEnd) = mutate($end);
	
	#NOTE: substr arguments must also be changed according to where sub sequence is
	#This is for mutating at the end of the sequence:
	#substr($dna, ($dnaLen-$endLen), $endLen, $mutEnd); 
	#This is for mutating at the beginning of the sequence:
	substr($dna, 0, $endLen, $mutEnd);
	
	return $dna;
}
