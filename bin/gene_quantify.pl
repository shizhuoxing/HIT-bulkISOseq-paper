open IN,"flnc2sample";
%fl=();@sample=();
while(<IN>){
	chomp;
	@a=();@a=split(/\t/,$_);
	push @sample,$a[0];
	open IN1,"$a[1]";
	while(<IN1>){
		@b=();@b=split(/\t/,$_);
		$fl{$b[0]}=$a[0];
	}
	close IN1;
}
close IN;

open IN,"gffcmp.all.isoseq_flnc.gff.rename.tmap";
%id=();
while(<IN>){
	chomp;
	@a=();@a=split(/\t/,$_);
	@b=();@b=split(/\./,$a[3]);
	$id{$b[0]}++;
}
close IN;

open IN,"gffcmp.all.isoseq_flnc.gff.rename.tmap";
%matrix1=();%matrix2=();
while(<IN>){
	chomp;
	@a=();@a=split(/\t/,$_);
	@b=();@b=split(/\./,$a[3]);
	if($a[0] ne "-" and $id{$b[0]}==1){
		$matrix1{$a[0]}{$fl{$b[0]}}++;
		$matrix2{$fl{$b[0]}}++;
	}
}
close IN;

$str="GeneID";
foreach $k(@sample){
	$str.=",$k\_TGScount,$k\_TGScpm";
}
$str=~s/\,$//;
print "$str\n";

foreach $k1(keys %matrix1){
	print "$k1";
	foreach $k2(@sample){
		$count=0;$count=$matrix1{$k1}{$k2} if(defined $matrix1{$k1}{$k2});
		$cpm=0;$cpm=($count/$matrix2{$k2})*1000000;
		print ",$count,$cpm";
	}
	print "\n";
}
