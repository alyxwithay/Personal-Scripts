#!/usr/perl -w

while(<>){
	if($_ =~ "^>"){
	}
	else{
		$seq = $_;
		for($i = 1; $i < $freq + 1; $i++) {
			print ">$seqname" . "_" . "$i\n";
			print "$seq";
		}
	}
	if($_ =~ /^>(.*)_(\d*)/){
		$seqname = $1;
		$freq = $2;
		#print "$seqname";
		#print "$freq\n";
		#print "$seq\n";	
	}
}
			
	