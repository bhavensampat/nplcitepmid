#!/usr/bin/perl

require "init_variables.pl";

# $reference_file = "/mnt/nfs4/d_li/citations/OTHER_CITATIONS/NPLCITE_10.TXT";
# $patent_class_file = "/mnt/nfs4/d_li/citations/BASIC_BIB/BASIC_10.TXT";
# $patent_class_key_file = "class_match.txt";
# $output_reference_file_filtered = "/mnt/nfs4/d_li/citations/OTHER_CITATIONS/NPLCITE_10.filtered.TXT";

open(F_IN, "<".$patent_class_key_file);

while(<F_IN>) {
        $line = $_;
        chomp($line);
        @data = split(/\t/, $line);
        $class = $data[0];
        $category = $data[2];
        if ($category == 1 || $category == 3) {
                $class_match{$class} = 1;
        }
}

print "Reading patent classes...\n";

open(F_IN, "<".$patent_class_file);

while(<F_IN>) {
	$line = $_;
	chomp($line);
	$line =~ /^([0-9]+)/;
	$id = $1;
	$line =~ /([0-9]+) [^\ ]+$/;
	$class = $1;
#	print $id."\t".$class."\n";
	$id_class{$id} = $class;
}

print "Filtering references by patent class...\n";

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
	$matched_class = $class_match{$class};
# print $line."\n";
#	print $matched_class."--".$class."==".$id."\n";
	if ($matched_class == 1) {
		print F_OUT $line."\n";
	}
	$counter++;
	if ($counter / 1000 == int($counter/1000)) {
		print $counter."\n";
	}
	
}

