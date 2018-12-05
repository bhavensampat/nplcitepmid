#!/usr/bin/perl
#!c:/perl/bin/
#!/usr/local/bin/perl/

# path to Medline XML files
$path = "/mnt/nfs4/d_li/medline/2011/";

@files = `ls $path`;

open(F_OUT,">citations_data.txt");

print "Start!\n";
$no_issn = 0;
$no_mesh = 0;
for($ij=0; $j<scalar(@files); $j++) {

	$file_name = $files[$j];

	chomp($file_name);
	open(F_MED,"<".$path."$file_name");
	
	while(<F_MED>) {
		$line = $_;

		chomp($line);
		if ($line =~ /\<MedlineCitation[ |\>]/)	{
			$line = <F_MED>;
			chomp($line);
			if ($line =~ /\<MedlineID/) {
				$line =~ /\>(.*)\</;
				$MedlineID = $1;
			}
			if ($line =~ /\<PMID/) {
				$line =~ /\>(.*)\</;
				$MedlineID = $1;
			}
		}
		if ($line =~ /\<Volume/) {
			$line =~ /\>(.*)\</;
			$volume = $1;
		}
		if ($line =~ /\<Issue/) {
			$line =~ /\>(.*)\</;
			$issue = $1;
		}
		if ($line =~ /\<MedlinePgn/) {
			$line =~ /\>(.*)\</;
			$pages = $1;
		}
		if ($line =~ /\<ArticleTitle/i) {
        	        $line =~ /\>(.*)\</;
                	$title = $1;
		}
		if ($line =~ /\<NlmUniqueID/i) {
			$line =~ /\>(.*)\</;
			$NlmUniqueID = $1;
		}
	
		if ($line =~ /\<\/MedlineCitation\>/) {
			$counter_xmls = $counter_xmls + 1;
			$discard = 0;
			$out = "$MedlineID|$file_name|$ISSN,$NlmUniqueID|$grants|$year|$volume|$issue|$pages|";

			for($i=0;$i<scalar(@mesh_terms)-1;$i++) {
				$out = $out.$mesh_terms[$i]."@";
			}			
			$temp = scalar(@mesh_terms)-1;
			$out = $out.$mesh_terms[$temp]."|";
			
			for($i=0;$i<scalar(@authors)-1;$i++) {
				$out = $out.$authors[$i]."@";
			}			
			$temp = scalar(@authors)-1;
			$out = $out.$authors[$temp];
			$out = $out."|".$title;
			print F_OUT "$out\n";

			@authors = ();
			@mesh_terms=();
			$title = "";
			$grants = "";
			$year = "";
			$ISSN = "";
			$volume = "";
			$issue = "";
			$MedlineID = "";
			$NlmUniqueID = "";
			print "$counter_xmls\n";
		}

		if ($line =~ /\<ISSN/) {
			 $line =~ /\>(.*)\</;
			 $ISSN = $1;
		}
		if ($line =~ /\<GrantList/) {
			$grants = "";
                	$end = 0;
	                while($end == 0) {
	                        if ($grants =~ /\<\/GrantList/) {
	                                $end = 1;
        	                } else {
                	                $line = <F_MED>;
                        	        chomp($line);
                                	$grants = $grants.$line;
	                        }

        	        }
	
		}
		if ($line =~ /\<PubDate/) {
			$date = "";
			$end = 0;
			while($end == 0) {
				if ($date =~ /\<\/PubDate/) {
					$end = 1;
				} else {
					$line = <F_MED>;
					chomp($line);
					$date = $date.$line;				
				}
			
			}
			if ($date =~ /\<MedlineDate\>/) {
				$date =~ /\>(.*)\</;
				$date1 = $1;
				$year = substr $date1,0,4;
			} else {
				if ($date =~ /\<Year/) {
				
					$date =~ /Year\>(.*)\<\/Year/;
					$year = $1;
				}
			}
		}

		if ($line =~ /\<\/Author\>/) {
			if ($lastname ne "") {
				push @authors,"$lastname\@$forename\@$initials";
			}
		}
		if ($line =~ /\<LastName/) {
			$line =~ /\>(.*)\</;
			$lastname = $1;
		}
		if ($line =~ /\<ForeName/) {
			$line =~ /\>(.*)\</;
			$forename = $1;
		}
		if ($line =~ /\<Initials/) {
			$line =~ /\>(.*)\</;
			$initials = $1;
		}
	
	
		
		if ($line =~ /\<MeshHeading\>/) {
			$mesh = <F_MED>;
			chomp($mesh);
			$end = 0;
			while($end == 0) {
				if ($mesh =~ /\<\/MeshHeading\>/) {
					$end = 1;
				} else {
					$line = <F_MED>;
					chomp($line);
					$mesh = $mesh.$line;
				}					
			}
			if ($mesh =~ /MajorTopicYN=\"Y\"/) {
				$mesh =~ /\<DescriptorName.*\>(.*)\<\/Descrip/;
				$mesh_term = $1;
				push @mesh_terms,$mesh_term;
			}
		
		}
	
	}

}

print "Total XMLs parsed: $counter_xmls\n";

close(F_OUT);
