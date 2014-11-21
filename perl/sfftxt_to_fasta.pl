#!/usr/bin/perl
#This script will take an sff.txt file and turn it into a fasta formatted file.  It will also remove all lowercase bases from the beginning and end of the sequence.
while(<>){
	if($_ =~ "^>"){
		chomp ($seqname = $_);
		}elsif ($_ =~ "^Bases"){
		chomp ($seq = $_);
			if ($seq =~ /(Bases:)\s(tcag)([A-Z]*)/){
				print "$seqname\n";
				print "$3\n";
			}
		}else{
			$junk = $_;
		}

		#print "$seq";
		}

