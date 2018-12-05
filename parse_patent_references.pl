#!/usr/bin/perl

require "init_variables.pl";

$reference_file = $output_reference_file_filtered;

`dos2unix $output_reference_file_filtered`;

print "Reference file: $reference_file\n";
# $reference_file = "/mnt/nfs4/d_li/citations/OTHER_CITATIONS/NPLCITE_09.filtered.TXT";

$output_file = "patent_references_data.txt";

open(F_IN,"<html_chars.txt");
while(<F_IN>) {
        $line = $_;
        chomp($line);
        @data = split(/\t/,$line);
        $chars = $data[0];
	push @special_char_list, $chars;
        $sub = $data[1];
        $special_chars{$chars} = $sub;
}

open(F_OUT,">".$output_file);
open(F_IN,"<".$reference_file);

# <F_IN>;

while(<F_IN>) {
	$line = $_;
	$index++;
	chomp($line);

	# @data = split(/\t/,$line);
	# $citation = $data[1];
	$line =~ /^[0-9 ]+/;
	$citation = $';
# print $citation."\n";
	if ($citation =~ /^\"(.*)\"$/) {
		$citation = $1;
	}
	while($citation =~ s/\<[a-z]+\>/ /ig) {}
	while($citation =~ s/\<\/[a-z]+\>/ /ig) {}
	while($citation =~ s/\&ldquo\;/\"/i) {}
	while($citation =~ s/\&rdquo\;/\"/i) {}
	for($i=0;$i<scalar(@special_char_list);$i++) {
		$chars = $special_char_list[$i];
		$sub = $special_chars{$chars};
		while($citation =~ s/\&$chars\;/$sub/i) {}
	}
	$citation =~ s/ABSTRACT OF //ig;
	$citation =~ s/PubMed Abstract by //ig;
	$citation1 = $citation;
#	print $citation."\n";
############# Extract Year ####################
	$counter = 0;
	@years = ();
	$year = "";
	while ($citation =~ /[^0-9]([12][90][0-9][0-9])[^0-9]/g) {
		$temp = $1;
		if ($temp < 2008 && $temp > 1950) {
			if ($year ne $temp) {
				$year = $temp;
				push @years, $year;
			}
		}
	}
	if ($citation =~ /^([12][90][0-9][0-9])[^0-9]/) {
                $temp = $1;
                if ($temp < 2008 && $temp > 1950) {
                        if ($year ne $temp) {
                                $year = $temp;
                                push @years, $year;
                        }
                }
	}

########### Extract Page ######################
# 17 (5) :347-355
	$citation =~ s/([0-9]+) ?([0-9\(\)]) ?(\:) ?([0-9\-]+)/\1\2\3\4/;
	$citation =~ s/\, ([0-9]+)[^0-9]\-([0-9]+)[^0-9]/\, \1\-\2/;
	$citation =~ s/\, [^0-9]([0-9]+)\-[^0-9]([0-9]+)/\, \1\-\2/;
	$citation =~ s/ [^0-9]([0-9]+)\-[^0-9]([0-9]+)/ \1\-\2/;	
	$citation =~ s/ S-([0-9])/ \1/;
	@pages = ();
 # PP. S-
	$citation =~ s/PP\. [^0-9]+([0-9])/PP\. \1/i;
# 45, 4559s-4562s

# 82/9 J.N.C.I. 763 (
	if ($citation =~ / ([0-9]+) \(/) {
        	$page = $1;
                push @pages, $page;
	}
	while($citation =~ /PP.? ?/ig) {
		$post = $';
		if ($post =~ /^([0-9\-]+)/) {
			$page = $1;
			push @pages, $page;
		}
	}
        while($citation =~ /\, P. /ig) {
                $post = $';
                if ($post =~ /^([0-9\-]+)\,/) {
                        $page = $1;
                        push @pages, $page;
                }
        }
        while($citation =~ / P. ([0-9]+)\,/ig) {
             	$page = $1;
        	push @pages, $page;
        }

        while($citation =~ /\, P. /ig) {
                $post = $';
                if ($post =~ /^([0-9\-]+) ?\(/) {
                        $page = $1;
                        push @pages, $page;
                }
        }
        while($citation =~ /\, P. /ig) {
                $post = $';
                if ($post =~ /^([0-9\-]+)\. *$/) {
                        $page = $1;
                        push @pages, $page;
                }
        }
        while($citation =~ / P. /ig) {
                $post = $';
                if ($post =~ /^([0-9\-]+)\. *$/) {
                        $page = $1;
                        push @pages, $page;
                }
        }
# ) 139-152, 
        while($citation =~ /\) ([0-9\-]+)\,/ig) {
                 $page = $1;
                 push @pages, $page;
        }

        while($citation =~ /\: ?([0-9]+\-[0-9]+)/ig) {
                 $page = $1;
                 push @pages, $page;
        }
        while($citation =~ /\, ?([0-9]+\-[0-9]+)\./ig) {
                 $page = $1;
                 push @pages, $page;
        }
# , 2686-92 
        while($citation =~ /\, ([0-9]+\-[0-9]+) /ig) {
                 $page = $1;
                 push @pages, $page;
        }
	while($citation =~ /\, ([0-9]+\-[0-9]+)\, /ig) {
                 $page = $1;
                 push @pages, $page;
	} 

############ Issue ####################################

	$issue = "";

	if ($citation =~ /NO\. ([0-9]+)/i) {
		$issue = $1;
	}

############ Volume ###################################
	@volumes = ();
        while($citation =~ /VOL. ([0-9]+)/ig) {
		$volume = $1;
		push @volumes, $volume;
	}
	# , 62, Suppl
        if ($citation =~ /\, ([0-9]+)\, suppl/i) {
                $volume = $1;
                push @volumes, $volume;
	}
	# 97 (7),
        while($citation =~ / ([0-9]+) ?\([0-9]+\)/ig) {
                $volume = $1;
                push @volumes, $volume;
        }
	
	# , 46:4
        while($citation =~ /\, ([0-9]+)\:[0-9]+/ig) {
                $volume = $1;
                push @volumes, $volume;
        }

	# ; 589-593.
	if ($citation =~ /\; ([0-9]+\-[0-9]+)\./) {
		$page = $1;
		push @pages, $page;
	}
	if ($citation =~ / ([0-9]+)\/[0-9]+[^0-9]/) {
                $volume = $1;
                push @volumes, $volume;
	}
	# , 705-711(
        if ($citation =~ /\, ([0-9]+\-[0-9]*)\(/) {
                $page = $1;
                push @pages, $page;
        }

	# 903-911 (
        if ($citation =~ / ([0-9]+\-[0-9]+) \(/) {
                $page = $1;
                push @pages, $page;
        }
       # 903-911.
        if ($citation =~ / ([0-9]+\-[0-9]+)\./) {
                $page = $1;
                push @pages, $page;
        }

	# 903-911 (
        if ($citation =~ / ([0-9]+\-[0-9]*)\(/) {
                $page = $1;
                push @pages, $page;
        }
	# , 80, 71
        if ($citation =~ / \, ([0-9]+)\, ([0-9\-]+)/) {
                $volume = $1;
                $page = $2;
                while($volume =~ s/\(.*\)//g) {};
                push @pages, $page;
                push @volumes, $volume;
        }
	# 35(9)571-575
        if ($citation =~ / ([0-9]+)\(([0-9]+)\)([0-9\-]+)/) {
                $volume = $1;
		$issue = $2;
                $page = $3;
                while($volume =~ s/\(.*\)//g) {};
                push @pages, $page;
                push @volumes, $volume;
        }
	# , 5;21-30
        if ($citation =~ / ([0-9]+)\;([0-9\-]+)/) {
                $volume = $1;
                $page = $2;
                while($volume =~ s/\(.*\)//g) {};
                push @pages, $page;
                push @volumes, $volume;
	}
	# 265:13925;
        if ($citation =~ / ([0-9]+)\:([0-9]+)\;/) {
                $volume = $1;
		$page = $2;
                while($volume =~ s/\(.*\)//g) {};
                push @pages, $page;
                push @volumes, $volume;
        }
	if ($citation =~ / ([0-9]+)\:([0-9\-]+)\.?/) {
                $volume = $1;
                $page = $2;
                while($volume =~ s/\(.*\)//g) {};
                push @pages, $page;
                push @volumes, $volume;
        }


        if ($citation =~ / [0-9][0-9][0-9][0-9], ([0-9]+)\./) {
                $volume = $1;
                while($volume =~ s/\(.*\)//g) {};
                # push @pages, $page;
                push @volumes, $volume;
        }
# 33, 2145 (
	if ($citation =~ / ([0-9]+), ([0-9]+) \(/) {
                $page = $2;
                $volume = $1;
                while($volume =~ s/\(.*\)//g) {};
                push @pages, $page;
                push @volumes, $volume;		
	}
        if ($citation =~ / ([0-9][0-9\)\(]+)\, ([0-9]+\-[0-9]+)/) {
		$page = $2;
		$volume = $1;
		while($volume =~ s/\(.*\)//g) {};
		push @pages, $page;
		push @volumes, $volume;
        }
# 215, pp.

        if ($citation =~ / ([0-9][0-9\)\(]+)\, PP\. ?([0-9]+\-[0-9]+)/i) {
                $page = $2;
                $volume = $1;
                while($volume =~ s/\(.*\)//g) {};
                push @pages, $page;
                push @volumes, $volume;
        }
        if ($citation =~ / ([0-9][0-9\)\(]+)\, P\. ?([0-9]+\-[0-9]+)/i) {
                $page = $2;
                $volume = $1;
                while($volume =~ s/\((.*)\)//g) {
                                $issue = $1;
                };
                push @pages, $page;
                push @volumes, $volume;
        }

# 80:1605, 
        while($citation =~ / ([0-9]+)\:([0-9\-]+)\, /ig) {
		$temp1 = $1;
		$temp2 = $2;
		if ($temp1 < 1900) {
	                 $volume = $temp1;
                 	while($volume =~ s/\((.*)\)//g) {
                                $issue = $1;
                        };
	                 push @volumes, $volume;
			$page = $temp2;
			push @pages, $page;
		}
        }

        while($citation =~ /([0-9\(\)\-]+)\: ?[0-9]+\-[0-9]+/ig) {
                 $volume = $1;
                 while($volume =~ s/\((.*)\)//g) {
                                $issue = $1;
                        };
                 push @volumes, $volume;
        }
# 25(6) 1368-1377 (
        while($citation =~ /([0-9\(\)\-]+) ([0-9]+\-[0-9]+) \(/ig) {
                 $volume = $1;
		 $page = $2;
                 while($volume =~ s/\((.*)\)//g) {
				$issue = $1;
			};
                 push @volumes, $volume;
		 push @pages, $page;
        }
# , 19:27.
        while($citation =~ /\, ([0-9\(\)\-]+)\:([0-9\-]+)\.$/ig) {
                 $volume = $1;
                 $page = $2;
                 while($volume =~ s/\((.*)\)//g) {
                                $issue = $1;
                        };

                 push @volumes, $volume;
                 push @pages, $page;
        }
        while($citation =~ / ([0-9\(\)\-]+)\:([0-9\-]+) \(/ig) {
                 $volume = $1;
                 $page = $2;
                 while($volume =~ s/\((.*)\)//g) {
                                $issue = $1;
                        };

                 push @volumes, $volume;
                 push @pages, $page;
        }
	while($citation =~ / ([0-9]+)\([0-9]\)\,/ig) {
		$volume = $1;
                 while($volume =~ s/\((.*)\)//g) {
                                $issue = $1;
                        };

		push @volumes, $volume;
	}
	while($citation =~ /\, ([0-9]+)\, ([0-9]+) \(/ig) {
		$volume = $1;
		$page = $2;
                 while($volume =~ s/\(.*\)//g) {};
                 push @volumes, $volume;
                 push @pages, $page;
	}




############ Title ####################################
	@titles = ();
	$title = " ";
	$title =~ /( )/;
	$title = $1;
	$title = "";
	if ($citation =~ /^(.+)\" BY [^\"]+$/) {
		$title = $1;
	#	push @titles, $title;
	#	$citation = $';
	}


	while ($citation =~ /\"([^\"]+)\"/g) {
		$title = $1;
	#	if (substr($title,length($title)-1,1) eq ",") {
	#		chop($title);
	#	}
	#	push @titles, $title;
	}
	if ($citation =~ /^(.*) BY /) {
		$pre = $1;
		if ($pre !~ /ET AL/) {
			if ($pre !~ /\"/ && $pre !~ /[0-9]/) {
				$citation =~ s/^.* BY //g;
			}
		}
	}

	if ($title eq " " || $title eq "") {
		if ($citation =~ /\"[^\"]+\"/) {
			$title = $1;
		}
	}
	if ($title !~ /[a-z]/i) {
		$title1 = "";
		while($citation =~ /([A-Z][^\,]+)\,/ig) {
			$temp = $1;
			if ($temp !~ /et al/i) {
				if (length($temp) > length($title1)) {
					$title1 = $temp;
				}
			}
		}
		if ($title1 ne "") {
			$title = $title1;
		}
	}
	while($title =~ s/^ //g) {}



############ Author ###################################
# print "+++++".$citation."+++++\n";
	$author = "";

	if ($citation !~ /^\"/i) {
		$citation1 = $citation;
	        if ($citation =~ /^[0-9]+/) {
			$citation1 = $';
        	}
		$citation1 =~ /^([A-Z\. \-\']+)[\,\;\:\"]/i;
		$author = $1;
		#if ($author =~ /^[A-Z] ([A-Z])/) {
		#	$author = $1.$';
		#}
	}
# print $author."==\n";
	if ($author =~ / ET AL/i) {
		$author = $`;
	}
# print $author."==\n";
        if ($author =~ / AND /) {
                $author = $`;
        }
# print $author."==\n";
        if ($citation =~ /([a-z]+)\, ET AL/i) {
		$pre = $`;
		$temp = $1;
		if (length($pre) > 30) {
	                $author = $temp;
		}
        }
# print $author."==\n";
	if ($author =~ /^[A-Z]\. /) {
		$author = $';
	}
        if ($author =~ /^[A-Z] /) {
                $author = $';
        }
        if ($author =~ /^[A-Z]\.[A-Z]\. /) {
                $author = $';
        }
        if ($author =~ /^[A-Z]\.[A-Z]\.[A-Z]\. /) {
                $author = $';
        }



        if ($author =~ /^[A-Z]\. /) {
               $author = $';
        }
        if ($author =~ /^[A-Z]\.[A-Z]\. /) {
                $author = $';
        }
	while ($author =~ s/ [A-Z]\.?$//g) {
		$author = $`;
	}
        while ($author =~ s/ [A-Z]\.?[A-Z]\.?$//g) {
                $author = $`;
        }
# print $author."==\n";
	$author =~ s/ BY //g;
	$author =~ s/\"[^\"]+\"//g;
	while($author =~ s/\,/ /g) {};
# print $author."==\n";
	while($author =~ s/^ //g) {};
	if ($author =~ /^([a-zA-Z ]+)\./) {
		$author = $1;
	}

# print $author."==\n";
        $author =~ s/ by //i;
        $author =~ s/^by //i;
        $author =~ s/^van //i;
        $author =~ s/^de //i;
        $author =~ s/^von //i;
        $author =~ s/ et al.$//;
        $author =~ s/ et al$//;
        $author =~ s/\,$//;
# print $author."<==\n";
        if ($author =~ /([a-z])/i) {
	        $author = $1.$';
	}
# print $author."==\n";
        while($author =~ s/^ //g) {};
        if ($author =~ / /) {
                $author = $`;
        }

$author0 = $author;
# print $author."==\n";
        if ($author eq "" || $author !~ /[a-z]/i || $author =~ /\"/ || length($author) < 2 || lc($author) eq "the" || lc($author) eq "trends") {
# print "Start second chance\n";
# print "Cit=".$citation."\n";
            if ($citation =~ / ET AL/i) {
	        $citation =~ / ET AL/i;
        	$author = $`;
	        $author =~ /[\,\.\"0-9\:]([^0-9^\:^\,^\.^\"]+)$/;
		$author = $1;
# print "et al found\n";
$author1 = $author;
            } else {
# Wiliam C. Bailey, MD;
	    	if ($citation =~ /\, MD/) {
			$author = $`;
			$author =~ /[\.\"]([^\.^\"]+)$/;
			$author = $1;
	    	}
	   }
$author2 = $author;
	   if ($author !~ /[a-z]/i) {
		$citation =~ /([A-Z\-]+)/i;
		$author = $1;
	   }

		$author =~ s/ by //i;
		$author =~ s/^by //i;
		$author =~ s/^van //i;
		$author =~ s/^de //i;
		$author =~ s/^von //i;
        	$author =~ s/ et al.$//;
	        $author =~ s/ et al$//;
		$author =~ s/\,$//;
		$author =~ /([a-z])/i;
		$author = $1.$';
		while($author =~ s/^ //g) {};
		if ($author =~ / /) {
			$author = $`;
  		}
	}
# if ($author eq "The" && $citation =~ /The Lancet/i) {
#	print $line."\n";
#	print "author0: $author0\n";
#	print "author1: $author1\n";
#	print "author2: $author2\n";
#	print "author: $author\n";
#	die "here\n";
#}
#print "--$author--\n";
#print $author."\n";
#if ($index == 50) {
#	die "here\n";
#}
######################################################
	 if ($counter > 1) {
                $double_counts++;
#               print $citation."\n";
        }
        if ($counter == 0) {
                $zero_counts++;
		# print $citation."\n";
        }

	$output = $index."|".$author."|".$title;
	$output = $output."|";
	%included = ();
        for($i=0;$i<scalar(@volumes);$i++) {
                $volumes1 = $volumes[$i];
		if ($volumes1 < 1800) {
			if ($included{$volumes1} eq "") {
				$included{$volumes1} = 1;
		                if ($i==0) {
        		                $output = $output.$volumes1;
                		} else {
                        		$output = $output."=".$volumes1;
				}
	                }
		}
        }
	$output = $output."|";
	%included = ();
	for($i=0;$i<scalar(@pages);$i++) {
		$pages1 = $pages[$i];	
                if ($included{$pages1} eq "") {
			$included{$pages1} = 1;
			if ($i==0) {
				$output = $output.$pages1;
			} else {
				$output = $output."=".$pages1;
			}
		}
	}
	$output = $output."|";
	%included = ();
        for($i=0;$i<scalar(@years);$i++) {
                $years1 = $years[$i];
		if ($included{$years1} eq "") {
			$included{$years1} = 1;
	                if ($i==0) {
        	                $output = $output.$years1;
                	} else {
                        	$output = $output."=".$years1;
			}
                }
        }
	$output = $output."|".$issue;
	@extra_numbers = ();
	while($citation =~ /[^0-9]([0-9][0-9]+)[^0-9]/g) {
		$number = $1;
		if ($output !~ /$number/) {
			push @extra_numbers, $number;
		}
	}
	for($i=0;$i<scalar(@extra_numbers);$i++) {
		$output = $output."|".$extra_numbers[$i];
	}

$temp0++;
	#### print $temp0."===".$citation1."\n";
	#### print $output."\n";
	print F_OUT $output."\n";
	if ($temp0 / 1000 == int($temp0 / 1000)) {
		print $temp0."\n";
	}
if ($citation1 =~ /DE JONG/) {
#	die "here\n";
}

}
print "Year double counts: $double_counts\n";
print "Year zero counts: $zero_counts\n";
