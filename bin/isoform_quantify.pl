open IN,"all_classification.filtered_lite_classification.txt";
%iso=();
while(<IN>){
	chomp;
	@a=();@a=split(/\t/,$_);
	if($a[5] eq "full-splice_match" or $a[5] eq "incomplete-splice_match" or $a[5] eq "novel_in_catalog" or $a[5] eq "novel_not_in_catalog"){
		$str="FSM" if($a[5] eq "full-splice_match");
		$str="ISM" if($a[5] eq "incomplete-splice_match");
		$str="NIC" if($a[5] eq "novel_in_catalog");
		$str="NNC" if($a[5] eq "novel_not_in_catalog");
		$iso{$a[0]}[0]=$str;
		$iso{$a[0]}[1]=$a[6];
		# print "$a[0]\t$iso{$a[0]}[0]\t$iso{$a[0]}[1]\n";
	}
}
close IN;

open IN,"flncUMI.list";
%umi=();@sample=();
while(<IN>){
	chomp;
	@a=();@a=split(/\t/,$_);
	push @sample,$a[0];
	open IN1,"$a[1]";
	while(<IN1>){
		chomp;
		@b=();@b=split(/\t/,$_);
		$umi{$b[0]}[0]=$a[0];
		$umi{$b[0]}[1]=$b[1];
	}
	close IN1;
}
close IN;

open IN,"all.collapse.v2.collapsed.group.txt";
%count=();@pbid=();
while(<IN>){
	chomp;
	@a=();@a=split(/\t/,$_);
	$str="$a[0]\($iso{$a[0]}[1]~$iso{$a[0]}[0]\)";
	@b=();@b=split(/\,/,$a[1]);
	# if(defined $iso{$a[0]}){
	if($iso{$a[0]}[0] ne ""){
		push @pbid,$str;
		# print "$a[0]\t$str\n";
		foreach $k(@b){
			$count{$str}{$umi{$k}[0]}{$umi{$k}[1]}++;
			# print "$str\t$umi{$k}[0]\t$umi{$k}[1]\n";
		}
	}
}
close IN;

print "IsoformID";
foreach $k(@sample){
	print ",$k";
}
print "\n";

foreach $k1(@pbid){
	$umisum=0;
	foreach $k2(@sample){
		@key1=();@key1=keys %{$count{$k1}{$k2}};
		$count=@key1;
		$umisum+=$count;
		# print "$k1\t$k2\t$count\n";
	}
	if($umisum>=5){
		print "$k1";
		foreach $k2(@sample){
			@key1=();@key1=keys %{$count{$k1}{$k2}};
			$count=@key1;
			print ",$count";
		}
		print "\n";
	}
}
