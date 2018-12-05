#!/usr/bin/perl

require "init_variables.pl";

# $reference_file = "/mnt/nfs4/d_li/citations/OTHER_CITATIONS/NPLCITE_09.filtered.TXT";
$reference_file = $output_reference_file_filtered;

$patents_file = "patent_references_data.txt";
$triple_match_file_3 = "triple_matches3.txt";
$triple_match_file_4 = "triple_matches4.txt";


$final_output_file = $final_output_file_loose;
$triple_match_file = $triple_match_file_3;

# $final_output_file = "NPLCITE_09.filtered.pmid.tight.TXT";
# $triple_match_file = $triple_match_file_4;


if ($ARGV[0] ne "") {
        $argument = $ARGV[0];
}
$patents_file = $argument;



open(F_IN,"<".$triple_match_file);

while(<F_IN>) {
	$line = $_;
	chomp($line);
	@data = split(/\|/,$line);
	$index = $data[0];
	$pmid = $data[1];
	$index_pmid{$index} = $pmid;
}



open(F_IN,"<".$reference_file);
open(F_IN2,"<".$patents_file);
open(F_OUT,">".$final_output_file);
# $line = <F_IN>;
$index = 0;
while(<F_IN>) {
	$line = $_;
	$line2 = <F_IN2>;
	chomp($line2);
	chomp($line);
# print "++$line2++\n";
	if ($line =~ /^([0-9]+) +([0-9]+) +/) {
		$line = $1."\t".$2."\t".$';
	}
	$index++;
	if ($index_pmid{$index} ne "") {
		$pmid = $index_pmid{$index};
	} else {
		$pmid = 0;
	}
	@data = split(/\t/,$line);
	$last = scalar(@data)-1;
	if ($last == 1) {
		$pmid1 = $data[$last];
	} else {
		$pmid1 = 0;
	}
	$total++;
# print "".$line."\n";
# print "$totel==>".$line2."\n";
	if ($pmid == $pmid1) {
		$correct++;
		if ($pmid == 0) {
			$tn++;
		} else {
			$tp++;
		}
	} else {
		if ($pmid1 !~ /e/i) {
#print "".$line."\n";
#print "$totel==>".$line2."\n";
			if ($pmid == 0 && $pmid1 > 0) {
				$false_negatives++;
				$fn++;
			}
			if ($pmid > 0 && $pmid1 == 0) {
				$fp++;
			}
			if ($pmid > 0 && $pmid1 > 0) {
				$incorrect++;
			}
		} else {
			$discarded++;
		}
	}
	print F_OUT $line."\t".$pmid."\n";
#if ($index == 3) {
# print $line."\t".$pmid."\n";
#}
}


$accuracy = $correct / ($incorrect + $correct + $false_negatives);
print "Correct: $correct ($accuracy)\n";
print "Incorrect: $incorrect\n";
print "FN: $false_negatives\n";
print "FP: $fp\n";
print "TN: $tn\n";
$fp = $fp + $incorrect;
$precision = $tp / ($tp + $fp);
$recall = $tp / ($tp + $fn);
print "Precision: $precision\n";
print "Recall: $recall\n";
$f_measure = 2 * ($precision * $recall) / ($precision + $recall);
print "F-measure: $f_measure\n";
print "Discarded: $discarded\n";
print "Total: $total\n";

