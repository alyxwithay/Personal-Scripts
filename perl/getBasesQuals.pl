#!perl

#	takes in a *sff.txt file and creates a *.fasta and *.qual files, trimmed to
#	remove bad base calls


use strict;
use warnings;

foreach my $file (@ARGV){

	$file =~ /(.*).sff.txt/;
	my $qualFile = "$1.qual";
	my $fastaFile= "$1.fasta";

	open(INPUT, $file) or die;
	open(QUAL, ">$qualFile") or die;
	open(FASTA, ">$fastaFile") or die;

	my $start = -1;;
	my $end = -1;

	while(<INPUT>){

		if($_ =~ /^>/){
			print QUAL $_;
			print FASTA $_;
			chomp($_);
			$start = -1;
			$end = -1;
		}
		elsif($_ =~ /^Bases:\s*(.*)/){
			my $seq = $1;

			for(my $i=0;$i<length($seq);$i++){
				if($start == -1 && substr($seq, $i, 1) =~ /[A-Z]/){
					$start = $i;
				}
				elsif($end == -1 && $start != -1 && substr($seq, $i, 1) =~ /[a-z]/){
					$end = $i;
				}
			}
			if($end == -1){	$end = length($seq) - 1;	}

			if($start == -1){
				print FASTA "A\n";
			}
			else{
				print FASTA substr($seq, $start, $end-$start), "\n";
			}
		}
		elsif($_ =~ /^Quality Scores:\s*(.*)/){

			if($start == -1){
				print QUAL "0\n";
			}
			else{
				my @quals = split /\s/, $1;
				for(my $i=$start;$i<$end;$i++){
					print QUAL "$quals[$i] ";
				}
				print QUAL "\n";
			}
		}
	}
}
