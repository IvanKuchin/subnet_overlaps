use strict;

my @masks = (0,0,map { pack("B*", substr("1" x $_ . "0" x 32, 0, 32)) } 2..32);
my @bits2rng = (0,0,map { 2**(32 - $_) } 2..32);


my	$vlsm_from = 17;
my	$vlsm_to = 32;
my	$excludeSummary = 1;

my	$ipv4String='[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}';
my	$vlsm;
my	$DEBUG_1 = 0;
my	$DEBUG_2 = 0;
my	$DEBUG_3 = 0;
my	$DEBUG_35 = 0;
my	$DEBUG_36 = 0;
my	$DEBUG_4 = 0;
my	$DEBUG_10 = 0;
my  %routes_companyB;
my  %routes_companyA;
my	%exactMatch;
my	$key;
my	$overlapCount;
my	%companyAOverlapsStr;
my	%companyBOverlapsStr;
my	%companyAOverlapsStrippedStr;
my	%companyBOverlapsStrippedStr;
my	%companyAOverlapsStrippedDedupStr;
my	%companyBOverlapsStrippedDedupStr;
my	$countdownTotal;
my	$countdownCurrent;
my	%companyBGraphml;
my	%companyAGraphml;


# my  %testHash;
# $testHash{"192.168.0.0/18"} = "";
# $testHash{"192.168.0.0/24"} = "";
# $testHash{"192.168.0.0/23"} = "";
# # $testHash{"192.168.0.0/16"} = "";
# $testHash{"192.168.0.0/22"} = "";
# $testHash{"192.168.128.0/17"} = "";
# $testHash{"192.168.128.0/18"} = "";
# $testHash{"192.168.128.0/20"} = "";
# $testHash{"192.168.128.0/19"} = "";

# die;

open(F, "sh_ip_route_companyB");
while(<F>)
{
	my	$lineFromFile = $_;
	chomp($lineFromFile);
	s/^O IA/O/;
	s/^O E2/O/;
	if(/^\s+$ipv4String\/(\d+)/)
	{
		$vlsm = $1;
		print "vlsm [$vlsm]\n" if($DEBUG_1);
	}
	if(/^\w\s+0\.0\.0\.0/) {goto end_loop_1; }
	if(/^\w\s+10\.0\.0\.0\/8/) {goto end_loop_1; }
	if(/^\w\s+172\.16\.0\.0\/12/) {goto end_loop_1; }
	if(/^\w\s+192\.168\.0\.0\/16/) {goto end_loop_1; }
	# --- removed on CompanyB site only 
	# --- by Digraj request
	# if(/^\w\s+10\.51\.0\.0\/16/) {goto end_loop_1; }
	# --- removed on CompanyB site only 
	# --- by Syed request
	# if(/^\w\s+10\.144\.0\.0\/16/) {goto end_loop_1; }
	# --- removed on CompanyB site only 
	# --- by Marcelo request
	# if(/^\w\s+10\.150\.0\.0\/16/) {goto end_loop_1; }
	# --- removed on CompanyB site only 
	# --- by Marcelo request
	# if(/^\w\s+10\.160\.0\.0\/16/) {goto end_loop_1; }
	# --- removed on CompanyB site only 
	# --- by Marcelo request
	# if(/^\w\s+10\.176\.0\.0\/16/) {goto end_loop_1; }
	# --- removed on CompanyB site only 
	# --- by Marcelo request
	# if(/^\w\s+10\.244\.0\.0\/16/) {goto end_loop_1; }

	unless(/^\w\s+(192|10|172)\./) {goto end_loop_1;}

	if(/^\w\s+($ipv4String)\s/)
	{
		print $1."/$vlsm\n" if($DEBUG_1);
		# $cidr->add($1."/$vlsm");
		$routes_companyB{$1."/$vlsm"} = $lineFromFile;
	}
	if(/^\w\s+($ipv4String)\/(\d+)/)
	{
		print $1."/".$2."\n" if($DEBUG_1);
		# $cidr->add($1."/".$2);
		$routes_companyB{$1."/".$2} = $lineFromFile;
	}
end_loop_1:
}
close(F);

# {
# 	my $res = isOverlap_1("10.3.2.0/21");
# 	if($res eq "")
# 	{
# 		print "no overlapping\n";
# 	}
# 	else
# 	{
# 		print "overlaps with ".$res."\n";
# 	}
# }
# die;

open(F, "sh_ip_route_companyA");
while(<F>)
{
	my	$lineFromFile = $_;
	chomp($lineFromFile);
	s/^O IA/O/;
	s/^O E2/O/;
	if(/^\w\s+0\.0\.0\.0/) {goto end_loop_2; }
	if(/^\w\s+10\.0\.0\.0\/8/) {goto end_loop_2; }
	if(/^\w\s+172\.16\.0\.0\/12/) {goto end_loop_2; }
	if(/^\w\s+192\.168\.0\.0\/16/) {goto end_loop_2; }


	# if(/^\w\s+10\.82\.0\.0\/15/) {goto end_loop_2; }
	# if(/^\w\s+172\.22\.0\.0\/16/) {goto end_loop_2; }
	# if(/^\w\s+10\.129\.0\.0\/16/) {goto end_loop_2; }
	# if(/^\w\s+10\.45\.255\.10\/32/) {goto end_loop_2; }
	# if(/^\w\s+10\.45\.255\.10\/32/) {goto end_loop_2; }

	unless(/^\w\s+(192|10|172)\./) {goto end_loop_2;}

	if($excludeSummary)
	{
		# --- removing summary routes
		# if(/^\w\s+10\.93\.120\.0\/21/) {goto end_loop_2; }
		# if(/^\w\s+10\.94\.232\.0\/21/) {goto end_loop_2; }
	}

	if(/^\s+$ipv4String\/(\d+)/)
	{
		$vlsm = $1;
		print "vlsm [$vlsm]\n" if($DEBUG_2);
	}
	if(/^\w\s+($ipv4String)\s/)
	{
		print $1."/$vlsm\n" if($DEBUG_2);
		$routes_companyA{$1."/$vlsm"} = $lineFromFile;
		# $cidr->add($1."/$vlsm");
	}
	if(/^\w\s+($ipv4String)\/(\d+)/)
	{
		print $1."/".$2."\n" if($DEBUG_2);
		$routes_companyA{$1."/".$2} = $lineFromFile;
		# $cidr->add($1."/".$2);
	}
end_loop_2:
}
close(F);

if($excludeSummary)
{
	foreach $key (keys %routes_companyB)
	{
		$key =~ m/(.*)\/(\d+)/;
		# if($2 > 24) { delete $routes_companyB{$key}; }
		if($2 < 20) { delete $routes_companyB{$key}; }
	}
	foreach $key (keys %routes_companyA)
	{
		$key =~ m/(.*)\/(\d+)/;
		# if($2 > 24) { delete $routes_companyA{$key}; }
		if($2 < 18) { delete $routes_companyA{$key}; }
	}
}


open(F, ">debug_step10_src_prefixes_companyB");
flock(F, 2);
foreach $key(keys %routes_companyB)
{
	printf F $key."\n";
}
close(F);

open(F, ">debug_step10_src_prefixes_companyA");
flock(F, 2);
foreach $key(keys %routes_companyA)
{
	printf F $key."\n";
}
close(F);

%companyAOverlapsStr = ();
%companyBOverlapsStr = ();

print "--------------- Looking for exact matches\n";
foreach $key (keys %routes_companyA)
{
	my	$prefix;
	my	$netmask;
	my	$overlapPrefix;

	print "compare items ".$key."\n" if($DEBUG_3);

	$overlapPrefix = ExactMatch($key);
	unless($overlapPrefix eq "")
	{
			$exactMatch{$key} = "";
			$companyAOverlapsStr{$key} = $key;
			$companyBOverlapsStr{$key} = $key;
	}
}

open(F, ">debug_step20_match_exact");
flock(F, 2);
foreach $key(keys %exactMatch)
{
	printf F $key."\n";
}
close(F);


print "--------------- Looking for non-exact matches COMPANY_A against COMPANY_B\n";
open(F, ">debug_step30_match_nonexact_companyA_to_companyB");
flock(F, 2);
$overlapCount = 0;
printf F "--------------- Compare COMPANY_A against COMPANY_B\n";
foreach $key (keys %routes_companyA)
{
	my	$prefix;
	my	$netmask;
	my	$overlapPrefix;

	print "compare items ".$key."\n" if($DEBUG_3);

	$overlapPrefix = isOverlap_1($key);
	unless($overlapPrefix eq "")
	{
		$overlapCount++;
		# print "overlapping\t[COMPANY_A:\t$key] (".$routes_companyA{$key}.")\n\t\t[COMPANY_B:\t$overlapPrefix] (".$routes_companyB{$overlapPrefix}.")\n\n\n";
		printf F "COMPANY_A:\t$key\nCOMPANY_B:\t$overlapPrefix\n\n\n";

		$companyAOverlapsStr{$key} = $overlapPrefix;
	}
}
printf F "total number overlap prefixes: $overlapCount\n";
close(F);
print "--------------- Looking for non-exact matches COMPANY_B against COMPANY_A\n";
open(F, ">debug_step30_match_nonexact_companyB_to_companyA");
flock(F, 2);
$overlapCount = 0;
printf F "--------------- Compare COMPANY_B against COMPANY_A\n";
foreach $key (keys %routes_companyB)
{
	my	$prefix;
	my	$netmask;
	my	$overlapPrefix;

	print "compare items ".$key."\n" if($DEBUG_3);

	$overlapPrefix = isOverlap_2($key);
	unless($overlapPrefix eq "")
	{
		$overlapCount++;
		# print "overlapping\t[COMPANY_B:\t$key] (".$routes_companyB{$key}.")\n\t\t[COMPANY_A:\t$overlapPrefix] (".$routes_companyA{$overlapPrefix}.")\n\n\n";
		print F "COMPANY_B:\t$key\nCOMPANY_A:\t$overlapPrefix\n\n\n";

		$companyBOverlapsStr{$key} = $overlapPrefix;
	}
}
printf F "total number overlap prefixes: $overlapCount\n";
close(F);

# --- GraphML part
open(F, ">debug_step36_src_prefixes_companyB");
flock(F, 2);
foreach $key(keys %routes_companyB)
{
	printf F $key."\n";
}
close(F);

open(F, ">debug_step36_src_prefixes_companyA");
flock(F, 2);
foreach $key(keys %routes_companyA)
{
	printf F $key."\n";
}
close(F);

%companyBGraphml = %companyBOverlapsStr;
%companyAGraphml = %companyAOverlapsStr;

EnrichGraphmlWithSubnets(\%companyBGraphml, \%routes_companyB);
EnrichGraphmlWithSubnets(\%companyAGraphml, \%routes_companyA);

print "--------------- Build graphml COMPANY_B against COMPANY_A\n";
BuildGraphml(\%companyBGraphml, "debug_step35_match_nonexact_companyB_to_companyA.graphml", 1);
print "--------------- Build graphml COMPANY_A against COMPANY_B\n";
BuildGraphml(\%companyAGraphml, "debug_step35_match_nonexact_companyA_to_companyB.graphml", 0);
# --- end graphing


%companyAOverlapsStrippedStr = %companyAOverlapsStr;
%companyBOverlapsStrippedStr = %companyBOverlapsStr;

foreach $key (keys %companyAOverlapsStrippedStr)
{
	$key =~ m/(.*)\/(\d+)/;
	if($2 > $vlsm_to) { delete $companyAOverlapsStrippedStr{$key}; }
	if($2 < $vlsm_from) { delete $companyAOverlapsStrippedStr{$key}; }
}
foreach $key (keys %companyBOverlapsStrippedStr)
{
	$key =~ m/(.*)\/(\d+)/;
	if($2 > $vlsm_to) { delete $companyBOverlapsStrippedStr{$key}; }
	if($2 < $vlsm_from) { delete $companyBOverlapsStrippedStr{$key}; }
}

%companyAOverlapsStrippedDedupStr = %companyAOverlapsStrippedStr;
%companyBOverlapsStrippedDedupStr = %companyBOverlapsStrippedStr;

RemoveSubnets(\%companyAOverlapsStrippedDedupStr);
RemoveSubnets(\%companyBOverlapsStrippedDedupStr);

open(F, ">debug_step40_prefix-list_overlap_companyA_netmask_after_stripping_".$vlsm_from."_".$vlsm_to);
flock(F, 2);
foreach $key(keys %companyAOverlapsStrippedDedupStr)
{
	printf F "ip prefix-list OVERLAP-COMPANY_A-COMPANY_B permit ".$key." le 32\n";

}
close(F);

open(F, ">debug_step40_prefix-list_overlap_companyB_netmask_after_stripping_".$vlsm_from."_".$vlsm_to);
flock(F, 2);
foreach $key(keys %companyBOverlapsStrippedDedupStr)
{
	printf F "ip prefix-list OVERLAP-COMPANY_B-COMPANY_A permit ".$key." le 32\n";

}
close(F);

BuildNatPools(\%companyBOverlapsStrippedDedupStr, "100.64.0.0", "result_nat_rtr1_companyB");
BuildNatPools(\%companyAOverlapsStrippedDedupStr, "100.72.0.0", "result_nat_rtr2_companyA");
BuildNatPools(\%companyBOverlapsStrippedDedupStr, "100.80.0.0", "result_nat_rtr3_companyB");
BuildNatPools(\%companyAOverlapsStrippedDedupStr, "100.88.0.0", "result_nat_rtr4_companyA");
BuildNatPools(\%companyBOverlapsStrippedDedupStr, "100.96.0.0", "result_nat_rtr5_companyB");
BuildNatPools(\%companyAOverlapsStrippedDedupStr, "100.104.0.0", "result_nat_rtr6_companyA");
BuildNatPools(\%companyBOverlapsStrippedDedupStr, "100.112.0.0", "result_nat_rtr7_companyB");
BuildNatPools(\%companyAOverlapsStrippedDedupStr, "100.120.0.0", "result_nat_rtr8_companyA");

sub ExactMatch
{
	my	$testPrefix = shift;
	my	$startTestPrefix = prefix_aton_start($testPrefix);
	my	$endTestPrefix = prefix_aton_end($testPrefix);
	my	$result = "";
	my	$prefix;

	foreach $prefix(keys %routes_companyB)
	{
		my $start = prefix_aton_start($prefix);
		my $end = prefix_aton_end($prefix);

		print "COMPARE:\n\t$prefix\t\n\t\t[$start .. $end]\n\t$testPrefix\t\n\t\t[$startTestPrefix .. $endTestPrefix]\n" if($DEBUG_4);

		if((($startTestPrefix >= $start) && ($startTestPrefix <= $end)) || (($endTestPrefix >= $start) && ($endTestPrefix <= $end)) || (($start >= $startTestPrefix) && ($start <= $endTestPrefix)) || (($end >= $startTestPrefix) && ($end <= $endTestPrefix)))
		{
		# if((($startTestPrefix == $start) && ($endTestPrefix == $end)) )
		# {
		# 	return "";
		# }
		if((($startTestPrefix == $start) && ($endTestPrefix == $end)) )
		{
			# overlap found
			if(length($result)) 
			{
				$result .= ",";
			} 
			$result .= $prefix;

		}
		}
	}

	return $result;
}

sub isOverlap_1
{
	my	$testPrefix = shift;
	my	$startTestPrefix = prefix_aton_start($testPrefix);
	my	$endTestPrefix = prefix_aton_end($testPrefix);
	my	$result = "";
	my	$prefix;

	print "isOverlap1\n" if($DEBUG_4);

	foreach $prefix(keys %routes_companyB)
	{
		my $start = prefix_aton_start($prefix);
		my $end = prefix_aton_end($prefix);

		print "COMPARE:\n\t$prefix\t\n\t\t[$start .. $end]\n\t$testPrefix\t\n\t\t[$startTestPrefix .. $endTestPrefix]\n" if($DEBUG_4);

		if((($startTestPrefix >= $start) && ($startTestPrefix <= $end)) || (($endTestPrefix >= $start) && ($endTestPrefix <= $end)) || (($start >= $startTestPrefix) && ($start <= $endTestPrefix)) || (($end >= $startTestPrefix) && ($end <= $endTestPrefix)))
		{
		if((($startTestPrefix == $start) && ($endTestPrefix == $end)) )
		{
			print "break due to exact match\n" if($DEBUG_4);
			return "";
		}
		# if((($startTestPrefix == $start) && ($endTestPrefix == $end)) )
		unless(defined $exactMatch{$prefix}) # --- remove exact matches
		{
			# overlap found
			if(length($result)) 
			{
				$result .= ",";
			} 
			$result .= $prefix;
			print "overlap found\n" if($DEBUG_4);
		}
		}
	}

	return $result;
}

sub isOverlap_2
{
	my	$testPrefix = shift;
	my	$startTestPrefix = prefix_aton_start($testPrefix);
	my	$endTestPrefix = prefix_aton_end($testPrefix);
	my	$result = "";
	my	$prefix;

	print "isOverlap2\n" if($DEBUG_4);

	foreach $prefix(keys %routes_companyA)
	{
		my $start = prefix_aton_start($prefix);
		my $end = prefix_aton_end($prefix);

		print "COMPARE:\n\t$prefix\t\n\t\t[$start .. $end]\n\t$testPrefix\t\n\t\t[$startTestPrefix .. $endTestPrefix]\n" if($DEBUG_4);

		if((($startTestPrefix >= $start) && ($startTestPrefix <= $end)) || (($endTestPrefix >= $start) && ($endTestPrefix <= $end)) || (($start >= $startTestPrefix) && ($start <= $endTestPrefix)) || (($end >= $startTestPrefix) && ($end <= $endTestPrefix)))
		{
		if((($startTestPrefix == $start) && ($endTestPrefix == $end)) )
		{
			print "break due to exact match\n" if($DEBUG_4);
			return "";
		}
		# if((($startTestPrefix == $start) && ($endTestPrefix == $end)) )
		unless(defined $exactMatch{$prefix}) # --- remove exact matches
		{
			# overlap found
			if(length($result)) 
			{
				$result .= ",";
			} 
			$result .= $prefix;
			print "overlap found\n" if($DEBUG_4);
		}
		}
	}

	return $result;
}


sub prefix_aton_start
{
	my	$prefix = shift;
	my	($ip, $mask, $ml);
	my $start;
	my $end;

	$prefix =~ m/([0-9]{1,3})\.([0-9]{1,3})\.([0-9]{1,3})\.([0-9]{1,3})\/([0-9]{1,3})/;
	$ip = ($1 << 24) + ($2 << 16) + ($3 << 8) + $4;
	$ml = (32 - $5);
	$mask = ((2**$5-1) << $ml); 

	$start = $ip & $mask;
	$end = $ip | (4294967295 - $mask);

	return $start;
}

sub prefix_aton_end
{
	my	$prefix = shift;
	my	($ip, $mask, $ml);
	my $start;
	my $end;

	$prefix =~ m/([0-9]{1,3})\.([0-9]{1,3})\.([0-9]{1,3})\.([0-9]{1,3})\/([0-9]{1,3})/;
	$ip = ($1 << 24) + ($2 << 16) + ($3 << 8) + $4;
	$ml = (32 - $5);
	$mask = ((2**$5-1) << $ml); 

	$start = $ip & $mask;
	$end = $ip | (4294967295 - $mask);

	return $end;
}

sub prefix_ntoa
{
	my	$prefix = shift;
	my	$mask = shift;
	my	($firstOct, $secondOct, $thirdOct, $fourthOct);
	my	%maskHash;

	$maskHash{0} = "/32";
	$maskHash{1} = "/31";
	$maskHash{3} = "/30";
	$maskHash{7} = "/29";
	$maskHash{15} = "/28";
	$maskHash{31} = "/27";
	$maskHash{63} = "/26";
	$maskHash{127} = "/25";
	$maskHash{255} = "/24";
	$maskHash{511} = "/23";
	$maskHash{1023} = "/22";
	$maskHash{2047} = "/21";
	$maskHash{4095} = "/20";
	$maskHash{8191} = "/19";
	$maskHash{16383} = "/18";
	$maskHash{32767} = "/17";
	$maskHash{65535} = "/16";
	$maskHash{131071} = "/15";
	$maskHash{262143} = "/14";
	$maskHash{524287} = "/13";
	$maskHash{1048575} = "/12";
	$maskHash{2097151} = "/11";
	$maskHash{4194303} = "/10";
	$maskHash{8388607} = "/9";
	$maskHash{16777215} = "/8";
	$maskHash{33554431} = "/7";
	$maskHash{67108863} = "/6";
	$maskHash{134217727} = "/5";
	$maskHash{268435455} = "/4";
	$maskHash{536870911} = "/3";
	$maskHash{1073741823} = "/2";
	$maskHash{2147483647} = "/1";

	$firstOct = ($prefix & (255 << 24)) >> 24;
	$secondOct = ($prefix & (255 << 16)) >> 16;
	$thirdOct =  ($prefix & (255 << 8)) >> 8;
	$fourthOct =  ($prefix & 255);
	
	return $firstOct.".".$secondOct.".".$thirdOct.".".$fourthOct.$maskHash{$mask};
}

sub BuildNatPools
{
	my	$routesStr = shift;
	my	$startNetStr = shift;
	my	$fName = shift;
	my	$startNet = prefix_aton_start($startNetStr."/32");
	my	%routeHash;
	my	%netmaskHash;
	my	%filterHash;
	my	$currentPos;
	my	%maskHash;
	my	%deduplicatedHash;

	$maskHash{0} = "/32";
	$maskHash{1} = "/31";
	$maskHash{3} = "/30";
	$maskHash{7} = "/29";
	$maskHash{15} = "/28";
	$maskHash{31} = "/27";
	$maskHash{63} = "/26";
	$maskHash{127} = "/25";
	$maskHash{255} = "/24";
	$maskHash{511} = "/23";
	$maskHash{1023} = "/22";
	$maskHash{2047} = "/21";
	$maskHash{4095} = "/20";
	$maskHash{8191} = "/19";
	$maskHash{16383} = "/18";
	$maskHash{32767} = "/17";
	$maskHash{65535} = "/16";
	$maskHash{131071} = "/15";
	$maskHash{262143} = "/14";
	$maskHash{524287} = "/13";
	$maskHash{1048575} = "/12";
	$maskHash{2097151} = "/11";
	$maskHash{4194303} = "/10";
	$maskHash{8388607} = "/9";
	$maskHash{16777215} = "/8";
	$maskHash{33554431} = "/7";
	$maskHash{67108863} = "/6";
	$maskHash{134217727} = "/5";
	$maskHash{268435455} = "/4";
	$maskHash{536870911} = "/3";
	$maskHash{1073741823} = "/2";
	$maskHash{2147483647} = "/1";

	print "BuildNatPools: start ($startNetStr)\n" if($DEBUG_10);

	%deduplicatedHash = %$routesStr; 
	open(F, ">debug_step90_dedup_before_".$fName);
	flock(F, 2);
	foreach my $key (keys %deduplicatedHash)
	{
		print F "before deduplication: ".$key."\n";
	}
	close(F);
	RemoveSubnets(\%deduplicatedHash);
	open(F, ">debug_step90_dedup_after_".$fName);
	flock(F, 2);
	foreach my $key (keys %deduplicatedHash)
	{
		print F "after deduplication: ".$key."\n";
	}
	close(F);

	foreach my $key (keys %deduplicatedHash)
	{
		my $prefix;
		my $netmask;
		$prefix = prefix_aton_start($key);
		$netmask = prefix_aton_end($key) - prefix_aton_start($key);

		$routeHash{ $prefix } = $netmask;
	}


	open F, ">".$fName;
	flock(F, 2);

	$currentPos = $startNet;
	foreach my $maskLen (sort {$b <=> $a} keys %maskHash)
	{
		my	%maskLenSpecificHash;

		%maskLenSpecificHash = ();

		# print "- start mask checking: ".$maskHash{$maskLen}."\n" if($DEBUG_10);
		# foreach my $key (sort keys %routeHash)
		# {
		# 	if($netmaskHash{$key} == $maskLen)
		# 	{
		# 		print "--- if( ".prefix_ntoa($routeHash{$key}, $netmaskHash{$key}).")" if($DEBUG_10);
		# 		print " ok" if($DEBUG_10);
		# 		print "\n" if($DEBUG_10);

		# 		if((defined $filterHash{ $routeHash{$key} } ) and ( $filterHash{ $routeHash{$key} } > $maskLen))
		# 		{
		# 			print "overlap\n" if($DEBUG_10);
		# 		}
		# 		else
		# 		{
		# 			$maskLenSpecificHash{ $routeHash{$key} } = $maskLen;
		# 		}
		# 	}
		# }

		print "- start mask checking: ".$maskHash{$maskLen}."\n" if($DEBUG_10);
		foreach my $key (sort {$a <=> $b} keys %routeHash)
		{
			print "--- if( ".prefix_ntoa($key, $routeHash{$key}).")" if($DEBUG_10);
			if($routeHash{$key} == $maskLen)
			{
				print " ok" if($DEBUG_10);
				$maskLenSpecificHash{ $key } = $maskLen;
			}
			print "\n" if($DEBUG_10);
		}

		foreach my $key (sort {$a <=> $b} keys %maskLenSpecificHash)
		{
			my	$insideLocal =  prefix_ntoa($key, $maskLenSpecificHash{$key});
			my	$insideGlobal = prefix_ntoa($currentPos, $maskLenSpecificHash{$key});

			print F "ip nat inside source static network ".$insideLocal." ".$insideGlobal."  vrf XXX match-in-vrf\n";
			$currentPos += ($maskLenSpecificHash{$key} + 1);
		}

	}

	close(F);

}

# Input:
# hash{inet_aton("x.x.x.x")} = inet_aton("255.255.x.x")
# $prefix
# $netmask
sub isSubnet
{
	my	$supernetHash = shift;
	my	$testPrefix = shift;
	my	$testMask = shift;

	foreach my $key (keys %$supernetHash)
	{
		my	$supernetPrefix;
		my	$supernetMask;

		$supernetPrefix = $key;
		$supernetMask = $$supernetHash{$key};

		if( 
			( ($testPrefix >= $supernetPrefix) and ($testPrefix <= ($supernetPrefix + $supernetMask)) ) 
			and 
			( $supernetMask > $testMask ) 
		)
		{
			return 1;
		}

	}
}


sub RemoveSubnets
{
	my	$inputHash = shift;

	foreach my $key1 (keys %$inputHash)
	{
		my	$isSubnetFlag;
		my	$testPrefix;
		my	$testMask;

		$isSubnetFlag = 0;
		$testPrefix = prefix_aton_start($key1);
		$testMask = prefix_aton_end($key1) - prefix_aton_start($key1);

		foreach my $key2 (keys %$inputHash)
		{
			my	$supernetPrefix;
			my	$supernetMask;

			$supernetPrefix = prefix_aton_start($key2);
			$supernetMask = prefix_aton_end($key2) - prefix_aton_start($key2);

			if( 
				( ($testPrefix >= $supernetPrefix) and ($testPrefix <= ($supernetPrefix + $supernetMask)) ) 
				and 
				( $supernetMask > $testMask ) 
			)
			{
				$isSubnetFlag = 1;
			}

		}
		if($isSubnetFlag == 1)
		{
			delete $$inputHash{$key1};
		}
	}
}

sub GetParentPrefix
{
	my	$childPrefix = shift;
	my	$inputHash = shift;

	my	($isParentFound, $parentNetHosts, $parentPrefix);
	my	$testPrefix;
	my	$testMask;
	{

		$isParentFound = 0;
		$parentNetHosts = 4294967295;
		$parentPrefix = "";

		$testPrefix = prefix_aton_start($childPrefix);
		$testMask = prefix_aton_end($childPrefix) - prefix_aton_start($childPrefix);

		foreach my $key2 (keys %$inputHash)
		{
			my	$supernetPrefix;
			my	$supernetNetHosts;

			$supernetPrefix = prefix_aton_start($key2);
			$supernetNetHosts = prefix_aton_end($key2) - prefix_aton_start($key2);

			if( 
				( ($testPrefix >= $supernetPrefix) and ($testPrefix <= ($supernetPrefix + $supernetNetHosts)) ) 
				and 
				( $supernetNetHosts > $testMask ) 
			)
			{
				$isParentFound = 1;
				if($supernetNetHosts < $parentNetHosts) 
				{
					$parentPrefix = $key2;
					$parentNetHosts = $supernetNetHosts;  
				}
			}

		}
	}

	return $parentPrefix
}



sub BuildGraphml
{
	my	$hashRef = shift;
	my	$fName = shift;
	my	$isKeyCompanyB = shift;
	my	%srcHash = %$hashRef;
	my	$companyBColor = "#CCCCFF";
	my	$companyAColor = "#ffff99";
	my	%leftPrefixes;
	my	%rightPrefixes;
	my	$rightTitle;
	my	$leftTitle;

	print "BuildGraphml: start ($fName)\n" if($DEBUG_35);

	$leftTitle = ($isKeyCompanyB ? "COMPANY_B" : "COMPANY_A");
	$rightTitle = ($isKeyCompanyB ? "COMPANY_A" : "COMPANY_B");

	foreach my $key(keys %srcHash)
	{
		$leftPrefixes{$key} = "";
		
		foreach my $keyInner(split(/,/, $srcHash{$key}))
		{
			$rightPrefixes{$keyInner} = "";
		}
	}

	foreach my $key(keys %leftPrefixes)
	{
		$leftPrefixes{$key} = GetParentPrefix($key, \%leftPrefixes);
	}

	foreach my $key(keys %rightPrefixes)
	{
		$rightPrefixes{$key} = GetParentPrefix($key, \%rightPrefixes);
	}

	open(F, ">".$fName."_parent_prefixes_left");
	flock(F, 2);
	foreach my $key (sort keys %leftPrefixes)
	{
		print F "$key <-".$leftPrefixes{$key}."\n";
	}
	close(F);

	open(F, ">".$fName."_parent_prefixes_right");
	flock(F, 2);
	foreach my $key (sort keys %rightPrefixes)
	{
		print F "$key <-".$rightPrefixes{$key}."\n";
	}
	close(F);

	open(F, ">".$fName);
	flock(F, 2);
	print F '<?xml version="1.0" encoding="UTF-8"?>'."\n";
	print F '<graphml xmlns="http://graphml.graphdrawing.org/xmlns/graphml" '."\n";
	print F 'xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" '."\n";
	print F 'xmlns:y="http://www.yworks.com/xml/graphml" '."\n";
	print F 'xsi:schemaLocation="http://graphml.graphdrawing.org/xmlns/graphml http://www.yworks.com/xml/schema/graphml/1.0/ygraphml.xsd">'."\n";
	print F '<key for="node" id="d0" yfiles.type="nodegraphics"/>'."\n";
	print F '<key for="edge" id="d1" yfiles.type="edgegraphics"/>'."\n";
	print F '<key for="edge" attr.name="description" attr.type="string" id="d3"/>'."\n";
	print F '<key for="node" attr.name="description" attr.type="string" id="d4"/>'."\n";
	print F '<graph id="G" edgedefault="undirected">'."\n";

	 # --- build key objects
	foreach my $keyOuter(keys %srcHash)
	{
		my	$parentMask;
		my	$parentID;

		$keyOuter =~ /([\d\.]+)\/(\d+)/;
		$parentMask = $2;

		$parentID = $leftTitle.$keyOuter;

		print F "<node id=\"".$parentID."\">\n";
		print F "	<data key=\"d0\">\n";
		print F "		<y:ShapeNode>\n";
		print F "			<y:Geometry width=\"".50*(32-$parentMask+1)."\" height=\"30.0\"/>\n";
		print F "			<y:Fill color=\"".($isKeyCompanyB ? $companyBColor : $companyAColor)."\" transparent=\"false\"/>\n";
		if(($parentMask > $vlsm_to) || ($parentMask < $vlsm_from)) { print F "			<y:BorderStyle color=\"#FF0000\" type=\"line\" width=\"1.0\"/>"."\n"; }
		print F "			<y:NodeLabel  rotationAngle=\"0.0\">".($isKeyCompanyB ? "COMPANY_B" : "COMPANY_A").$keyOuter."</y:NodeLabel>\n";
		print F "			<y:Shape type=\"rectangle\"/>\n";
		print F "		</y:ShapeNode>\n";
		print F "	</data>\n";
		print F "	<data key=\"d4\">";
		print F "description";
		print F "</data>\n";
		print F "</node>\n";

	    if($leftPrefixes{$keyOuter}.length())
	    {
			# --- regular link
			print F DrawEdge($leftTitle, $leftTitle, $leftPrefixes{$keyOuter}, $keyOuter, "subnet");
		}

		foreach my $keyInner(split(/,/, $srcHash{$keyOuter}))
		{
			my	$childMask;
			my	$childID;
			my	$lineColor;
			my	$lineWidth;
			my	$lineDescription;
			my	$lineType;

			$keyInner =~ /([\d\.]+)\/(\d+)/;
			$childMask = $2;

			$lineColor = "#000000";
			$lineWidth = "3.0";
			$lineType = "line";
			$lineDescription = "";
			$childID = $rightTitle.$keyInner;

			print F "<node id=\"".$childID."\">\n";
			print F "	<data key=\"d0\">\n";
			print F "		<y:ShapeNode>\n";
			print F "			<y:Geometry width=\"".50*(32-$childMask+1)."\" height=\"30.0\"/>\n";
			print F "			<y:NodeLabel rotationAngle=\"0.0\">".($isKeyCompanyB ? "COMPANY_A" : "COMPANY_B").$keyInner."</y:NodeLabel>\n";
			print F "			<y:Fill color=\"".($isKeyCompanyB ? $companyAColor : $companyBColor)."\" transparent=\"false\"/>\n";
			if(($childMask > $vlsm_to) || ($childMask < $vlsm_from)) { print F "			<y:BorderStyle color=\"#FF0000\" type=\"line\" width=\"1.0\"/>"."\n"; }
			print F "			<y:Shape type=\"rectangle\"/>\n";
			print F "		</y:ShapeNode>\n";
			print F "	</data>\n";
			print F "	<data key=\"d4\">";
			print F "description";
			print F "</data>\n";
			print F "</node>\n";

			# --- regular link
			if(($childMask <= $vlsm_to) && ($childMask >= $vlsm_from) && ($parentMask <= $vlsm_to) && ($parentMask >= $vlsm_from))
			{
				# --- if overlap if fair and will not be filtered
				print F DrawEdge($leftTitle, $rightTitle, $keyOuter, $keyInner, "regular");
			}
			elsif(($rightPrefixes{$keyInner} eq "")) 
			{
				# --- if there is no parent on right side
				print F DrawEdge($leftTitle, $rightTitle, $keyOuter, $keyInner, "regular");
			}
		    # print F "<edge id=\"".$parentID."_".$childID."\" source=\"".$parentID."\" target=\"".$childID."\">"."\n";
		    # print F "  <data key=\"d3\">".$lineDescription."</data>"."\n";
		    # print F "  <data key=\"d1\">"."\n";
		    # print F "    <y:PolyLineEdge>"."\n";
		    # print F "      <y:Path sx=\"0.0\" sy=\"0.0\" tx=\"0.0\" ty=\"0.0\"/>"."\n";
		    # if(($childMask > $vlsm_to) || ($childMask < $vlsm_from)) { $lineColor = "#FF0000"; $lineWidth = "1.0"; }
		    # if(($parentMask > $vlsm_to) || ($parentMask < $vlsm_from)) { $lineColor = "#FF0000"; $lineWidth = "1.0"; }
		    # print F "      <y:LineStyle color=\"".$lineColor."\" type=\"".$lineType."\" width=\"".$lineWidth."\"/>"."\n";
		    # print F "      <y:Arrows source=\"none\" target=\"standard\"/>"."\n";
		    # print F "      <y:BendStyle smoothed=\"true\"/>"."\n";
		    # print F "    </y:PolyLineEdge>"."\n";
		    # print F "  </data>"."\n";
		    # print F "</edge>"."\n";

		    # --- link to parent subnet
		    if($rightPrefixes{$keyInner}.length())
		    {
		    	my	$parentID;
		    	my	$parentPrefix;
		    	my	$parentMask;

		    	$parentPrefix = $rightPrefixes{$keyInner};
		    	$parentPrefix =~ /(.*)\/(\d+)/;
		    	$parentMask = $2;
		    	$parentID = $rightTitle.$parentPrefix;
				$lineColor = "#000000";
				$lineWidth = "3.0";
				$lineType = "dashed";

				$lineDescription = "parent: ".$rightPrefixes{$keyInner};

				# --- regular link
				print F DrawEdge($rightTitle, $rightTitle, $rightPrefixes{$keyInner}, $keyInner, "subnet");
			    # print F "<edge id=\"".$parentID."_".$childID."\" source=\"".$parentID."\" target=\"".$childID."\">"."\n";
			    # print F "  <data key=\"d3\">".$lineDescription."</data>"."\n";
			    # print F "  <data key=\"d1\">"."\n";
			    # print F "    <y:PolyLineEdge>"."\n";
			    # print F "      <y:Path sx=\"0.0\" sy=\"0.0\" tx=\"0.0\" ty=\"0.0\"/>"."\n";
			    # if(($childMask > $vlsm_to) || ($childMask < $vlsm_from)) { $lineColor = "#FF0000"; $lineWidth = "1.0"; }
			    # if(($parentMask > $vlsm_to) || ($parentMask < $vlsm_from)) { $lineColor = "#FF0000"; $lineWidth = "1.0"; }
			    # print F "      <y:LineStyle color=\"".$lineColor."\" type=\"".$lineType."\" width=\"".$lineWidth."\"/>"."\n";
			    # print F "      <y:Arrows source=\"none\" target=\"standard\"/>"."\n";
			    # print F "      <y:BendStyle smoothed=\"true\"/>"."\n";
			    # print F "    </y:PolyLineEdge>"."\n";
			    # print F "  </data>"."\n";
			    # print F "</edge>"."\n";
		    }
		}

	}

	print F "</graph>\n</graphml>\n";
	close(F);

	print "BuildGraphml: end\n" if($DEBUG_35);
}

sub DrawEdge
{
	my	$fromCompany = shift;
	my	$toCompany = shift;
	my	$fromPrefix = shift;
	my	$toPrefix = shift;
	my	$lineDescription = shift;
	my	$lineColor;
	my	$parentID;
	my	$childID;
	my	$toMask;
	my	$fromMask;
	my	$lineWidth;
	my	$lineType;
	my	$resultStr;

	$resultStr = "";
	$lineType = "line";
	$lineColor = "#000000";
	$lineWidth = "3.0";
	$parentID = $fromCompany.$fromPrefix;
	$childID = $toCompany.$toPrefix;

	$fromPrefix =~ /(.*)\/(\d+)/;
	$fromMask = $2;
	$toPrefix =~ /(.*)\/(\d+)/;
	$toMask = $2;
    if(($toMask > $vlsm_to) || ($toMask < $vlsm_from) ||
      ($fromMask > $vlsm_to) || ($fromMask < $vlsm_from)) { $lineColor = "#FF0000"; $lineWidth = "1.0"; }

	if($fromCompany eq $toCompany) {$lineType = "dashed"; }

    $resultStr .= "<edge id=\"".$parentID."_".$childID."\" source=\"".$parentID."\" target=\"".$childID."\">"."\n";
    $resultStr .= "  <data key=\"d3\">".$lineDescription."</data>"."\n";
    $resultStr .= "  <data key=\"d1\">"."\n";
    $resultStr .= "    <y:PolyLineEdge>"."\n";
    $resultStr .= "      <y:Path sx=\"0.0\" sy=\"0.0\" tx=\"0.0\" ty=\"0.0\"/>"."\n";
    $resultStr .= "      <y:LineStyle color=\"".$lineColor."\" type=\"".$lineType."\" width=\"".$lineWidth."\"/>"."\n";
    $resultStr .= "      <y:Arrows source=\"none\" target=\"standard\"/>"."\n";
    $resultStr .= "      <y:BendStyle smoothed=\"true\"/>"."\n";
    $resultStr .= "    </y:PolyLineEdge>"."\n";
    $resultStr .= "  </data>"."\n";
    $resultStr .= "</edge>"."\n";

    return $resultStr;
}

sub EnrichGraphmlWithSubnets
{
	my	$overlapPrefixHash = shift;
	my	$enrichHash = shift;

	print "EnrichGraphmlWithSubnets: start\n" if($DEBUG_36);

	for(my $i = 0; $i < 2; $i++)
	{
		foreach my $key (keys %$enrichHash)
		{
			my	$testParent;

			print "EnrichGraphmlWithSubnets: testing($i) $key\n" if($DEBUG_36);

			$testParent = GetParentPrefix($key, $enrichHash);

			print "EnrichGraphmlWithSubnets: parent $testParent\n" if($DEBUG_36);

			if((defined $$overlapPrefixHash{$testParent}) && (!(defined $$overlapPrefixHash{$key})))
			{
	
				print "EnrichGraphmlWithSubnets: add child $key to $testParent\n" if($DEBUG_36);
				$$overlapPrefixHash{$key} = "";
			}
		}	
	}

	print "EnrichGraphmlWithSubnets: end\n" if($DEBUG_36);
}
