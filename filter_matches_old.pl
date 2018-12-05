#!/usr/bin/perl

open(F_IN,"<patents_data.txt");

while(<F_IN>) {
        $line = $_;
	chomp($line);
        @data = split(/\|/,$line);
        $index = $data[0];
        $index_list{$index} = $line;
}
$index = 0;
open(F_IN,"<forraul2.test");
$line = <F_IN>;
while(<F_IN>) {
        $line = $_;
        chomp($line);
        $index++;
        $original_list{$index} = $line;
}


open(F_IN,"<triple_matches.txt");
open(F_OUT,">triple_matches2.txt");
open(F_OUT2,">triple_matches1.txt");
while(<F_IN>) {
	$line = $_;
	chomp($line);
	@data = split(/\|/,$line);
	$index = $data[0];
        $pmid = $data[1];
	$journal1 = $data[3];
	@data1 = split(/\,/,$journal1);
	$journalNlmID = $data1[1];
        $grants = $data[4];
        $year = $data[5];
        $volume = $data[6];
        $pages = $data[8];	
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
if ($index == 4915) {
	print "=>>$patent_line\n";
	print "<<=".$line."\n";
}
	$author1 = lc($data[1]);
	$author1 =~ s/^. //;
	$author1 =~ s/ .$//;
	if ($author1 =~ /et al/) {
		$author1 = $`;
	}
	$title1 = $data[2];
        $pages1 = $data[4];
	$other1 = $data[6];
	$other2 = $data[7];
	if ($pages1 =~ /\=/) {
	        @temp2 = split(/\=/,$pages1);
	} else {
		@temp2 = ($pages1);
	}
	$verified = 0;

        for($m=0;$m<scalar(@authors)/3;$m++) {
        $name = lc($authors[$m*3]);
        $name =~ s/^van //i;
        $name =~ s/^von //i;
        $name =~ s/^de //i;
        $name =~ s/et al$//i;
#       @authors = ($name);
        $author = $name;

# print "$patent_line\n";
        for($l=0;$l<scalar(@temp2);$l++) {
        $pages1 = $temp2[$l];
	if ($pages1 =~ /\,/) {
		$pages1 = $`;
	}


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

if ($index == 4915) {
print "==$title==\n";
print $pages."\n";
print "==$title1==\n";
print $pages1."\n";
}


	if ($index_keeper{$index} eq "") {
		if ($verified == 0) {
			$temp = $pages;
			if ($pages =~ /\-/) {
				$temp = $`;
			}
			$temp1 = $pages1;
			if ($pages1 =~ /\-/) {
				$temp1 = $`;
			}
			if ($temp eq $temp1) {
if ($index == 4915) {
print "equal pages\n";
print "++++$author++$author1++++\n";
}
				if ($verified == 0) {
				 	if (lc($author) eq lc($author1)) {
        			                        $index_keeper{$index} = 1;
                			                $verified = 1;
					}
				}
				if ($verified == 0) {
					if ($line =~ /$other1/ && $other1 ne "") {
						$index_keeper{$index} = 1;
						$verified = 1;
					}	
				}
			}
		}

		if ($verified == 0) {
			if (length($title1) > 10) {
				$title1 = substr(clean_title($title1),0,20);
				$title = clean_title($title);
				if (index(lc($title),lc($title1)) >= 0) {
					$index_keeper{$index} = 1;
	                                $verified = 1;
				}
			}
		}
		if ($verified == 0) {
			@journal_names = split(/\|/,$name_hash{$journalNlmID});
			for($i=0;$i<scalar(@journal_names);$i++) {
				$journal_name = $journal_names[$i];
				if (length($journal_name) > 3) {
					if (index(lc($$journal_name),lc($original_line)) >= 0) {
						$index_keeper{$index} = 1;
						$verified = 1;
					}
				}
			}
		}
		if ($verified == 0) {
			if (length($author) > 3) {
	                       if (index(lc($author),lc($original_line)) >= 0) {
                               		$index_keeper{$index} = 1;
                               		$verified = 1;
                       		}
			}
		}



	}
	}

if ($index == 4915) {
print "verified:++$verified++\n";
# print $line."\n";
}

	}
	if ($verified == 1) {
		print F_OUT2 $line."\n";	
# print $index."===".$line."<=>".$patent_line."\n";
	} else {
# print $index."===".$line."<=>".$patent_line."\n";
		print F_OUT $line."\n";
	}
#if ($index == 3984) {
#	die "here\n";
#}
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
	while($title_temp =~ s/\.SUP\.//g) {}
	while($title_temp =~ s/\.SUB\.//g) {}			
	$title_temp =~ s/^. +//;
	$title_temp =~ s/ +.$//;
       $title_temp =~ s/^ +//;
       $title_temp =~ s/ +$//;
	return $title_temp;
}

