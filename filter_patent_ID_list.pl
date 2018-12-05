#!/usr/bin/perl

require "init_variables.pl";

# $reference_file = "/mnt/nfs4/d_li/citations/OTHER_CITATIONS/NPLCITE_10.TXT";
# $patent_class_file = "/mnt/nfs4/d_li/citations/BASIC_BIB/BASIC_10.TXT";
# $patent_class_key_file = "class_match.txt";
# $output_reference_file_filtered = "/mnt/nfs4/d_li/citations/OTHER_CITATIONS/NPLCITE_10.filtered.TXT";

print "Reading patent IDs...\n";

open(F_IN, "<".$patent_ID_file);

while(<F_IN>) {
	$line = $_;
	chomp($line);
	$id = $line;
	$id_class{$id} = 1;
}


print "Filtering references by patent ID...\n";

open(F_OUT,">".$output_reference_file_filtered);
open(F_IN,"<".$reference_file);

<F_IN>;

while(<F_IN>) {
        $line = $_;
        $index++;
        chomp($line);

        $line =~ /^([0-9]+)/;
        $id = $1;
	$class = $id_class{$id};
#	$matched_class = $class_match{$class};
# print $line."\n";
#	print $matched_class."--".$class."==".$id."\n";
	if ($class ne "") {
		print F_OUT $line."\n";
	}
	$counter++;
	if ($counter / 1000 == int($counter/1000)) {
		print $counter."\n";
	}
	
}

