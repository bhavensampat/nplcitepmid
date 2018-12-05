#!/usr/bin/perl

require "init_variables.pl";

# $reference_file = "/mnt/nfs4/d_li/citations/OTHER_CITATIONS/NPLCITE_09.filtered.TXT";

$reference_file = $output_reference_file_filtered;
$patents_file = "patent_references_data.txt";
$triple_match_file = "triple_matches.txt";
$triple_match_file_3 = "triple_matches3.txt";
$triple_match_file_4 = "triple_matches4.txt";

if ($ARGV[0] ne "") {
	$argument = $ARGV[0];
	$patents_file = $argument;
}

$watch_index = -1;
open(F_IN,"<".$patents_file);


open(F_IN,"<journals_key_list.txt");
while(<F_IN>) {
        $line = $_;
        chomp($line);
        @data = split(/\|/,$line);
        $journalNlmID = $data[4];
        for($i=1;$i<=3;$i++) {
                $data[$i] =~ s/journal//i;
                $data[$i] =~ s/the / /i;
                $data[$i] =~ s/of / /i;
                while($data[$i] =~ s/\./ /g) {};
                $data[$i] =~ /([a-z][a-z][a-z][a-z]+)/i;
                $data[$i] = $1;
                if (length($data[$i]) < 4) {
                        $data[$i] = "";
                }
        }
        $line1 = $data[1]."|".$data[2]."|".$data[3];
        $name_hash{$journalNlmID} = $line1;

#       print $line1."\n";
}
# die "here\n";

open(F_IN,"<".$patents_file);

while(<F_IN>) {
        $line = $_;
        chomp($line);
        @data = split(/\|/,$line);
        $index = $data[0];
        $index_list{$index} = $line;
}


print "Read references...\n";
$index = 0;
# open(F_IN,"<forraul2.test");
open(F_IN,"<".$reference_file);
# open(F_IN,"<forraul2.val");
# $line = <F_IN>;
while(<F_IN>) {
        $line = $_;
        chomp($line);
        $index++;
        $original_list{$index} = $line;
}
$max_index = $index;
print "References read.\n";

open(F_IN,"<".$triple_match_file);

while(<F_IN>) {
	$line = $_;
#for($o=0; $o<1100000; $o++) {
#	$line = <F_IN>;
	chomp($line);
	@data = split(/\|/,$line);
	$index = $data[0];
if ($output{$index} eq "") {
	$output{$index} = $line;
}
$counter1++;
if ($counter1/10000 == int($counter1/10000)) {
	print "...".$counter1."...\n";
}
        $pmid = $data[1];
	$journal1 = $data[3];
	@data1 = split(/\,/,$journal1);
	$journalNlmID = $data1[1];
        $grants = $data[4];
        $year = $data[5];
        $volume = $data[6];
	$issue = $data[7];
        $pages = $data[8];
	while($pages =~ s/[^0-9^\-]//g) {};	
	$title = $data[11];
	@authors = split(/\@/,$data[10]);
        if ($pages =~ /\-/) {
                @data1 = split(/\-/,$pages);
                if (length($data1[1]) <= length($data1[0])) {
                        if (length($data1[1]) == length($data1[0])) {
                                $i=0;
                                # print "<==".$pages."\n";
                                while((substr($data1[1],$i,1) ne "") && (substr($data1[1],0,1) eq substr($data1[0],$i,1))) {
                                        $data1[1] = substr($data1[1],1);
                                        $i++;
                                }
                                $pages = $data1[0]."-".$data1[1];
                                # print "==>".$pages."\n";
                        }
                }
        }

	$patent_line = $index_list{$index};
        @data = split(/\|/,$patent_line);
	$index = $data[0];
	$original_line = $original_list{$index};
if ($index == $watch_index) {
	print "=>>$patent_line\n";
	print "<<=".$line."\n";
}
	$author1 = lc($data[1]);
	$author1 =~ s/^. //;
	$author1 =~ s/ .$//;
        $author1 =~ s/^van //i;
        $author1 =~ s/^von //i;
        $author1 =~ s/^de //i;

	if ($author1 =~ /et al/i) {
		$author1 = $`;
	}
	$title1 = $data[2];
        $pages1 = $data[4];
	$issue1 = $data[6];
	$other1 = $data[7];
	$other2 = $data[8];
	if ($pages1 =~ /\=/) {
	        @temp2 = split(/\=/,$pages1);
	} else {
		@temp2 = ($pages1);
	}
	$verified = 0;
$temp9 = scalar(@authors)/3;
if ($temp9 < 1) {
	$temp9 = 1;
	@authors = ();
}
        for($m=0;$m<$temp9;$m++) {
        $name = lc($authors[$m*3]);
        $name =~ s/^van //i;
        $name =~ s/^von //i;
        $name =~ s/^de //i;
        $name =~ s/et al$//i;
#       @authors = ($name);
        $author = $name;
	$pre_value_verified = $index_keeper{$index};
if ($index == $watch_index) {
	print "Pre value: $pre_value_verified\n";
}
        for($l=0;$l<scalar(@temp2);$l++) {
        $pages1 = $temp2[$l];
	if ($pages1 =~ /\,/) {
		$pages1 = $`;
	}
	$verified = 0;

# print "==$pages1==\n";

	if ($pages1 =~ /\-/) {
		@data1 = split(/\-/,$pages1);
		if (length($data1[1]) <= length($data1[0])) {
			if (length($data1[1]) == length($data1[0])) {
				$i=0;
				# print "<==".$pages1."\n";
				while((substr($data1[0],$i,1) ne "") && (substr($data1[1],0,1) eq substr($data1[0],$i,1))) {
					$data1[1] = substr($data1[1],1);
					$i++;
				}
				$pages1 = $data1[0]."-".$data1[1];
				# print "==>".$pages1."\n";
			}
		}
	}

if ($index == $watch_index) {
print "==$title==\n";
print $pages."\n";
print "==$title1==\n";
print $pages1."\n";
}


#	if ($index_keeper{$index} eq "") {
		# if ($verified == 0) {
			$temp = $pages;
			if ($pages =~ /\-/) {
				$temp = $`;
			}
			$temp1 = $pages1;
			if ($pages1 =~ /\-/) {
				$temp1 = $`;
			}
			if ($temp eq $temp1) {
				$verified++;
if ($index == $watch_index) {
print "equal pages\n";
print "verified=$verified\n";
}
	}
#				if ($verified == 0) {
				 	if (lc($author) eq lc($author1)) {
                			                $verified++;
							if ($verified > $index_keeper{$index}) {
								$index_keeper{$index} = $verified;
								$output{$index} = $line;
							}
					}
#				}
if ($index == $watch_index) {
print "++++$author++$author1++++\n";
print "verified=$verified\n";
}

#				if ($verified == 0) {
					if ($original_line =~ /[^0-9]$other1/i && $other1 ne "") {

						$verified++;
						if ($verified > $index_keeper{$index}) {
							$index_keeper{$index} = $verified;
							$output{$index} = $line;
						}
					}	
#				}
if ($index == $watch_index) {
print "Other=$other1\n";
print "verified=$verified\n";
}



	#		}
		# }

#		if ($verified == 0) {
			if (length($title1) > 10) {
				$title1 = substr(clean_title($title1),0,20);
				$title = clean_title($title);
				if (index(lc($title),lc($title1)) >= 0) {
					$verified++;
					if ($verified > $index_keeper{$index}) {
		                                $index_keeper{$index} = $verified;
						$output{$index} = $line;
					}
				}
if ($index == $watch_index) {
print "Title=$title\n";
print "Title1=$title1\n";
print "verified=$verified\n";
}
			}
#		}
#		if ($verified == 0) {
			@journal_names = split(/\|/,$name_hash{$journalNlmID});
if ($index == $watch_index) {
$temp=$name_hash{$journalNlmID};
print "Journals($journalNlmID)=$temp\n";
}
			$found = 0;
			for($n=0;$n<scalar(@journal_names) && $found==0;$n++) {
				$journal_name = substr($journal_names[$n],0,7);
				if (length($journal_name) > 3) {
if ($index == $watch_index) {
print "Journal tried=".$journal_name."\n";
}

					if (index(lc($original_line),lc($journal_name)) >= 0) {
						$verified++;
						$found = 1;
if ($index == $watch_index) {
print "Journal Found=".$journal_name."\n";
}

						if ($verified > $index_keeper{$index}) {
							$index_keeper{$index} = $verified;
							$output{$index} = $line;
						}
					}
				}
			}
#		}
#		if ($verified == 0) {
			if (length($author) > 3) {
	                       if (index(lc($author),lc($original_line)) >= 0) {
# print "Same author\n";
                               		$verified++;
					if ($verified > $index_keeper{$index}) {
						$index_keeper{$index} = $verified;
						$output{$index} = $line;
					}
                       		}
			}
#		}
		if ($issue ne "") {
			if ($issue eq $issue1) {
        	        	$verified++;
                	        if ($verified > $index_keeper{$index}) {
                                	$index_keeper{$index} = $verified;
                                        $output{$index} = $line;
                 		}
if ($index == $watch_index) {
				print "same issue\n";
}
			}
		}
		if ($verified_keeper{$index} < $index_keeper{$index}) {
			$verified_keeper{$index} = $index_keeper{$index};
		}



#	}
	}

if ($index == $watch_index) {
print "Total verified:++$verified++\n";
# print $line."\n";
}

	}
}

open(F_OUT,">".$triple_match_file_3);
open(F_OUT2,">".$triple_match_file_4);

@indices = keys %output;
for($i=1;$i<=$max_index;$i++) {
#	$index = $indices[$i];
	$line = $output{$i};
	# if ($index_keeper{$index} ne "") {
# print $index_keeper{$i}."\n";
	if ($index_keeper{$i} > 2) {
		print F_OUT2 $line."\n";
	}
	if ($index_keeper{$i} > 1) {
		print F_OUT $line."\n";
	}
}



sub clean_title() {
	@temp = (@_);
	$title_temp = $temp[0];
       while($title_temp =~ s/\&[^ ]+\;//g) {}
	while($title_temp =~ s/\.//g) {}
	while($title_temp =~ s/\://g) {}
       while($title_temp =~ s/\;//g) {}
       while($title_temp =~ s/\,//g) {}
       while($title_temp =~ s/\"//g) {}
       while($title_temp =~ s/\'//g) {}
       while($title_temp =~ s/\-//g) {}
       while($title_temp =~ s/\?//g) {}
       while($title_temp =~ s/  / /g) {}
       while($title_temp =~ s/ //g) {}
       while($title_temp =~ s/\(//g) {}
       while($title_temp =~ s/\)//g) {}
       while($title_temp =~ s/\[//g) {}
       while($title_temp =~ s/\]//g) {}
       while($title_temp =~ s/\`//g) {}
       while($title_temp =~ s/\>//g) {}
       while($title_temp =~ s/\<//g) {}
	while($title_temp =~ s/\.SUP\.//ig) {}
	while($title_temp =~ s/\.SUB\.//ig) {}			
	$title_temp =~ s/^. +//;
	$title_temp =~ s/ +.$//;
       $title_temp =~ s/^ +//;
       $title_temp =~ s/ +$//;
	return $title_temp;
}

