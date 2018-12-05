#!/usr/bin/perl

$patents_file = 'patent_references_data.txt';
$triple_match_file = "triple_matches.txt";
$medline_citations_file = "citations_data.txt";

$batch = 400000;

if ($ARGV[0] ne "") {
        $argument = $ARGV[0];
        $patents_file = $argument;
}
# $patents_file = "";
# print "==$argument==\n";

open(F_IN,"<journals_key_list.txt");
while(<F_IN>) {
	$line = $_;
    chomp($line);
    @data = split(/\|/,$line);
    $journalNlmID = $data[4];
	for($i=1;$i<=3;$i++) {
		if ($data[$i] =~ /[^a-z^A-Z]/) {
			$data[$i] = $`;
		}
		if ($data[$i] =~ /^ *journal/i) {
			$data[$i] = $';
		}
		if (length($data[$i]) < 4) {
			$data[$i] = "";
		}
	}
	$line1 = $data[1]."|".$data[2]."|".$data[3];
    $name_hash{$journalNlmID} = $line1;
#	print $line1."\n";
}


open(F_OUT,">".$triple_match_file);

for($m=0;$m<85;$m++) {
	
	print "Opening $patents_file ...\n";
	open(F_IN,"<".$patents_file);

	%title_list = ();
	%pair_match5 = ();
	%pair_match6 = ();
	%pair_match7 = ();
	%pair_match8 = ();
	%pair_match9  = ();
	%pair_match10  = ();
	%triple_match1  = ();
	%triple_match2  = ();
	%triple_match3  = ();
	%triple_match4  = ();
	%triple_match5  = ();
	%triple_match6  = ();
	%triple_match7  = ();
	%triple_match8  = ();
	%triple_match9  = ();
	%triple_match10  = ();
	%triple_match11  = ();	

	
	$counter = 0;
	while(<F_IN>) {
		$line = $_;
		$counter++;

		$temp = $m;
		if ($counter >= $batch * $temp + 1 && $counter <= $batch * ($temp + 1)) {
			
			if ($counter/10000 == int($counter/10000)) {
        		print $temp." - ...".$counter."...\n";
			}
		
			chomp($line);
			@data = split(/\|/,$line);
			$index = $data[0];
			if ($data[1] eq "") {
				$data[1] = "A";
			}
			@last_names = split(/ /,lc($data[1]));	
			$title = substr(clean_title($data[2]),0,10);
			$title_list{$title} = 1;
			$title30 = substr(clean_title30($data[2]),0,30);
        	if ($data[3] eq "") {
                $data[3] = "0";
        	}
			@volumes = split(/\=/,$data[3]);
        	if ($data[4] eq "") {
                $data[4] = "0";
        	}
			@pages = split(/\=/,$data[4]);
        	if ($data[5] eq "") {
                $data[5] = "0";
        	}
			@years = split(/\=/,$data[5]);
			if (scalar(@last_names) > 3) {
				$temp = 3;
			} else {
				$temp = scalar(@last_names);
			}
			$issue = $data[6];
			$temp = 1;

			for($i=0;$i<$temp;$i++) {
				$last_name = lc($last_names[$i]);
				for($j=0;$j<scalar(@volumes);$j++) {
					$volume = $volumes[$j];
					for($k=0;$k<scalar(@pages);$k++) {
						$page = $pages[$k];
						if ($page =~ /\-/) {
							$page =~ /([0-9]+)\-/;
							$page = $1;
						}
						for($l=0;$l<scalar(@years);$l++) {
							$year = $years[$l];

							if ($page ne "" && $volume ne "") {
								$pair_match5{$volume}{$page} = 1;
							}
							if ($year ne "" && $volume ne "") {
								$pair_match6{$volume}{$year} = 1;
							}
							if ($page ne "" && $year ne "") {
								$pair_match7{$page}{$year} = 1;
							}
							if ($last_name ne "" && $year ne "") {
								$pair_match8{$last_name}{$year} = 1;
							}
							if ($last_name ne "" && $page ne "") {
								$pair_match9{$last_name}{$page} = 1;
							}
							if ($last_name ne "" && $volume ne "") {
								$pair_match10{$last_name}{$volume} = 1;
							}

							if ($triple_match1{$last_name}{$volume}{$page} eq "") {
								$triple_match1{$last_name}{$volume}{$page} = $index;
							} else {
								$triple_match1{$last_name}{$voluume}{$page} = $triple_match1{$last_name}{$volume}{$page}."|".$index;
							}
							if ($triple_match2{$last_name}{$volume}{$year} eq "") {
								$triple_match2{$last_name}{$volume}{$year} = $index;
							} else {
								$triple_match2{$last_name}{$volume}{$year} = $triple_match2{$last_name}{$volume}{$year}."|".$index;
							}
							if ($triple_match3{$last_name}{$year}{$page} eq "") {
								$triple_match3{$last_name}{$year}{$page} = $index;
							} else {
								$triple_match3{$last_name}{$year}{$page} = $triple_match3{$last_name}{$year}{$page}."|".$index;
							}
							if ($triple_match4{$year}{$volume}{$page} eq "") {
								$triple_match4{$year}{$volume}{$page} = $index;
							} else {
								$triple_match4{$year}{$volume}{$page} = $triple_match4{$year}{$volume}{$page}."|".$index;
							}
							if ($triple_match5{$title}{$volume}{$page} eq "") {
								$triple_match5{$title}{$volume}{$page} = $index;
							} else {
								$triple_match5{$title}{$volume}{$page} = $triple_match5{$title}{$volume}{$page}."|".$index;
							}
							if ($triple_match6{$title}{$volume}{$year} eq "") {
								$triple_match6{$title}{$volume}{$year} = $index;
							} else {
								$triple_match6{$title}{$volume}{$year} = $triple_match6{$title}{$volume}{$year}."|".$index;
							}
							if ($triple_match7{$title}{$page}{$year} eq "") {
								$triple_match7{$title}{$page}{$year} = $index;
							} else {
								$triple_match7{$title}{$page}{$year} = $triple_match7{$title}{$page}{$year}."|".$index;
							}
							if ($triple_match8{$title}{$last_name}{$year} eq "") {
        						$triple_match8{$title}{$last_name}{$year} = $index;
							} else {
        						$triple_match8{$title}{$last_name}{$year} = $triple_match8{$title}{$last_name}{$year}."|".$index;
							}
							if ($triple_match9{$title}{$last_name}{$page} eq "") {
    	    					$triple_match9{$title}{$last_name}{$page} = $index;
							} else {
        						$triple_match9{$title}{$last_name}{$page} = $triple_match9{$title}{$last_name}{$page}."|".$index;
							}
							if ($triple_match10{$title}{$last_name}{$volume} eq "") {
    	    					$triple_match10{$title}{$last_name}{$volume} = $index;
							} else {
    	    					$triple_match10{$title}{$last_name}{$volume} = $triple_match10{$title}{$last_name}{$volume}."|".$index;
							}
							if ($triple_match11{$title30} eq "") {
        						$triple_match11{$title30} = $index;
							} else {
    	    					$triple_match11{$title30} = $triple_match11{$title30}."|".$index;
							}
						}
					}
				}
			}
		}
	}


	$counter = 0;
	open(F_IN,"<".$medline_citations_file);
	open(F_OUT,">>".$triple_match_file);
	$line = <F_IN>;
	while(<F_IN>) {
		$line = $_;
		$counter++;
		if ($counter/10000 == int($counter/10000)) {
			print $m." - ".$counter."...\n";
		}
		chomp($line);
		@data = split(/\|/,$line);
		$pmid = $data[0];
		$grants = $data[3];
		$year = $data[4];
		$volume = $data[5];
		$pages = $data[7];
		while($pages =~ s/[a-z]//ig) {}
		$title = $data[10];
		$title1 = $title;
		if ($pages =~ /\-/) {
			$page = $`;
		} else {
			$page = $pages;
		}
		@names = split(/\@/,$data[9]);
		$last_name = lc($names[0]);
		$last_name =~ s/^van //i;
		$last_name =~ s/^de //i;
		$last_name =~ s/^von //i;
		$match = 0;
		$index = "";

#			if ($pair_match5{$volume}{$page} ==1 || $pair_match6{$volume}{$year} == 1 ||
#				$pair_match7{$page}{$year} == 1 || $pair_match8{$last_name}{$year} ==1 ||
#				$pair_match9{$last_name}{$page} == 1 || $pair_match10{$last_name}{$volume} == 1) {

		if ($pair_match10{$last_name}{$volume} == 1) {		
			if ($triple_match1{$last_name}{$volume}{$page} ne "") {
				$index = $triple_match1{$last_name}{$volume}{$page};
				$match = 1;
			}
   			if ($triple_match2{$last_name}{$volume}{$year} ne "") {
				if ($index eq "") {
					$index = $triple_match2{$last_name}{$volume}{$year};
				} else {
					$index = $triple_match2{$last_name}{$volume}{$year}."|".$index;
				}
				$match = 2;
			}
		}
		if ($pair_match7{$page}{$year} == 1) {
   			if ($triple_match3{$last_name}{$year}{$page} ne "") {
				if ($index eq "") {
					$index = $triple_match3{$last_name}{$year}{$page};
				} else {
    	           	$index = $triple_match3{$last_name}{$year}{$page}."|".$index;
  			   }
				$match = 3;
			}
			if ($triple_match4{$year}{$volume}{$page} ne "") {
				if ($index eq "") {
					$index = $triple_match4{$year}{$volume}{$page};
				} else {
					$index = $triple_match4{$year}{$volume}{$page}."|".$index;
				}
				$match = 4;
			}
		}

		if (length($title) > 10) {

			#			if ($pair_match5{$volume}{$page} ==1 || $pair_match6{$volume}{$year} == 1 ||
#			$pair_match7{$page}{$year} == 1 || $pair_match8{$last_name}{$year} ==1 ||
#			$pair_match9{$last_name}{$page} == 1 || $pair_match10{$last_name}{$volume} == 1) {
#
			$title = substr(clean_title($title),0,10);
			if ($title_list{$title} == 1) {		
				if ($pair_match5{$volume}{$page} == 1) {
		            if ($triple_match5{$title}{$volume}{$page} ne "") {
  			   	    	if ($index eq "") {
      			       		$index = $triple_match5{$title}{$volume}{$page};
           			    } else {
               			   	$index = $triple_match5{$title}{$volume}{$page}."|".$index;
                		}
	                	$match = 5;
		     		}
   				}
   				if ($pair_match6{$volume}{$year} == 1) {
          			if ($triple_match6{$title}{$volume}{$year} ne "") {
		   				if ($index eq "") {
	    	       			$index = $triple_match6{$title}{$volume}{$year};
		               	} else {
		          	     	$index = $triple_match6{$title}{$volume}{$year}."|".$index;
	   		           	}
       					$match = 6;
           			}	
       			}

 	      		if ($pair_match7{$page}{$year} == 1) {
		          	if ($triple_match7{$title}{$page}{$year} ne "") {
    		       		if ($index eq "") {
	    		           	$index = $triple_match7{$title}{$page}{$year};
       	    		    } else {
           	    		    $index = $triple_match7{$title}{$page}{$year}."|".$index;
	               		}
			            $match = 7;
  	    		   	}
				}
			
				if ($pair_match8{$last_name}{$year} == 1) {
	        	   if ($triple_match8{$title}{$last_name}{$year} ne "") {
   					   	if ($index eq "") {
  	    	       			$index = $triple_match8{$title}{$last_name}{$year};
	        	    	} else {
      	        	   		$index = $triple_match8{$title}{$last_name}{$year}."|".$index;
	               		}
	               		$match = 8;
    		       }
	       		}
		   		if ($pair_match9{$last_name}{$page} == 1) {
	    	    	if ($triple_match9{$title}{$last_name}{$page} ne "") {
		    	       	if ($index eq "") {
		        	       	$index = $triple_match9{$title}{$last_name}{$page};
  	    	       		} else {
        	    	       $index = $triple_match9{$title}{$last_name}{$page}."|".$index;
  	        	   		}
       	       			$match = 9;
        	   		}
   	    		}
        		if ($pair_match10{$last_name}{$volume} == 1) {
	        	   if ($triple_match10{$title}{$last_name}{$volume} ne "") {
		        	   	if ($index eq "") {
	    	        	   	$index = $triple_match10{$title}{$last_name}{$volume};
		    	        } else {
		        	       	$index = $triple_match10{$title}{$last_name}{$volume}."|".$index;
		            	}
		    	       	$match = 10;
		           }
  	    	   	}

				if (length($title1) > 30) {
					$title30 = substr(clean_title30($title1),0,30);
					if ($triple_match11{$title30} ne "") {
						if ($index eq "") {
              	    		$index = $triple_match11{$title30};
                    	} else {
  	                		$index = $triple_match11{$title30}."|".$index;
    	  	            }
   	    	      	    $match = 11;
					}
				}
			}
		





			if ($match > 4) {
				$title_matches++;
			}
	
			if ($match != 0) {
				if ($index !~ /\|/) {
					print F_OUT $index."|".$line."\n";
				} else {
					@indexes = split(/\|/,$index);
					%index_seen = ();
					for($k=0;$k<scalar(@indexes);$k++) {
						$index = $indexes[$k];
						if ($index_seen{$index} eq "") {
							print F_OUT $index."|".$line."\n";
							$index_seen{$index} = 1;
						}
					}
					$index = "";
				}
			}
		}
	}
	

	
}

print "Title matches: $title_matches\n";

sub clean_title() {
	@temp = (@_);
	$title_temp = uc(substr($temp[0],0,20));
       while($title_temp =~ s/\&[^ ]+\;//g) {}
 while($title_temp =~ s/[\[\]\.\:\;\,\"\'\-\?\(\)\`\>\>]//g) {}
#	while($title_temp =~ s/\.//g) {}
#	while($title_temp =~ s/\://g) {}
 #      while($title_temp =~ s/\;//g) {}
  #     while($title_temp =~ s/\,//g) {}
   #    while($title_temp =~ s/\"//g) {}
    #   while($title_temp =~ s/\'//g) {}
     #  while($title_temp =~ s/\-//g) {}
      # while($title_temp =~ s/\?//g) {}
       while($title_temp =~ s/  / /g) {}
       while($title_temp =~ s/ //g) {}
#       while($title_temp =~ s/\(//g) {}
 #      while($title_temp =~ s/\)//g) {}
  #     while($title_temp =~ s/\[//g) {}
   #    while($title_temp =~ s/\]//g) {}
    #   while($title_temp =~ s/\`//g) {}
     #  while($title_temp =~ s/\>//g) {}
      # while($title_temp =~ s/\<//g) {}
	while($title_temp =~ s/\.SUP\.//ig) {}
	while($title_temp =~ s/\.SUB\.//ig) {}			
#	$title_temp =~ s/^. +//;
#	$title_temp =~ s/ +.$//;
 #      $title_temp =~ s/^ +//;
  #     $title_temp =~ s/ +$//;
	return $title_temp;
}

sub clean_title30() {
        @temp = (@_);
        $title_temp = uc(substr($temp[0],0,40));
       while($title_temp =~ s/\&[^ ]+\;//g) {}
 while($title_temp =~ s/[\[\]\.\:\;\,\"\'\-\?\(\)\`\>\>]//g) {}
        while($title_temp =~ s/\.SUP\.//ig) {}
        while($title_temp =~ s/\.SUB\.//ig) {}
       while($title_temp =~ s/  / /g) {}
       while($title_temp =~ s/ //g) {}

        return $title_temp;
}

