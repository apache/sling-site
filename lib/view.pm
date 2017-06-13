package view;

#
# BUILD CONSTRAINT:  all views must return $content, $extension.
# additional return values (as seen below) are optional.  However,
# careful use of symlinks and dependency management in path.pm can
# resolve most issues with this constraint.
#

use strict;
use warnings;
use Dotiac::DTL qw/Template/;
use Dotiac::DTL::Addon::markup;
use ASF::Util qw/read_text_file shuffle/;
use File::Temp qw/tempfile/;
use LWP::Simple;
use SVN::Client;
use File::Find;
use File::Basename;

push @Dotiac::DTL::TEMPLATE_DIRS, "templates";

# This is most widely used view.  It takes a
# 'template' argument and a 'path' argument.
# Assuming the path ends in foo.mdtext, any files
# like foo/bar.mdtext will be parsed and
# passed to the template in the "bar" (hash)
# variable.

sub single_narrative {
    my %args = @_;
    my $file = "content$args{path}";
    my $template = $args{template};
    $args{path} =~ s/\.mdtext$/\.html/;
    $args{breadcrumbs} = breadcrumbs($args{path});
    $args{svninfo} = svninfo($file);

    read_text_file $file, \%args;

    $args{refs} = {};

    # render tip box with reference to Confluence export
    # if translation for a page is still pending
    if($args{headers}->{translation_pending}) {
        $args{oldpage} = "/site/" . basename($args{path});
    }

    # ensure loading child pages
    my $page_path = $file;
    $page_path =~ s/\.[^.]+$//;
    if (-d $page_path) {
        $args{children} = {};
        for my $f (grep -f, glob "$page_path/*.mdtext") {
            $f =~ m!/([^/]+)\.mdtext$! or die "Bad filename: $f\n";
            $args{children}->{$1} = read_ref_page_data($f);
            $args{refs}->{$1} = $args{children}->{$1};
        }
    }

    # ensure loading pages referenced with ref.XXX.*    
    while( $args{content} =~ /refs\.([^.]+)\./g ) {
        my $label = $1;
        if(!$args{refs}->{$label}) {
            my $refPagePath;
            find(sub {
                if(!$refPagePath && $_ eq "$label.mdtext") {
                    $refPagePath = $File::Find::name;
                }
            }, "content");
            
            if($refPagePath) {
                $args{refs}->{$label} = read_ref_page_data($refPagePath);
            }
        }
    }

#	$args{sidenav} = {};
#	read_text_file "templates/sidenav.mdtext", $args{sidenav} ;

#	select STDOUT ;
#	$| = 1 ;
#	for my $ke (keys %args) {
#		print STDOUT "$ke \n";
#	}

    # use the content as a template if it contains Django templates
    if ($args{content} =~ /\{[{%][^}]*[%}]\}/) {
        print STDOUT "Applying $args{path} as a Django template\n";
        $args{content} = Dotiac::DTL->new(\$args{content})->render(\%args);
    }
    
    return Dotiac::DTL::Template($template)->render(\%args), html => \%args;
}

# The specially crafted download page
# Input is a list of artifacts formatted as:
#
#   <title>|<id>|<version>[|<qualifier>]
#
# Special handling if title is "sling": This denotes the
# version of the Sling Launchpad distribution whie is
# rendered specially: The id is actually the launchpad
# distribution version
sub downloads {
	my %args = @_;	
    my $file = "content$args{path}";
    my $template = $args{template};
    $args{path} =~ s/\.list$/\.html/;
    $args{breadcrumbs} = breadcrumbs($args{path});
    $args{svninfo} = svninfo($file);
	
    read_text_file $file, \%args;

    my $result = "|Artifact | Version | Binary | Source|\n|--|--|--|--|\n";
    my $maven = "|Artifact | Version | Binary | Source|\n|--|--|--|--|\n";
    my $launchpad = "| Artifact | Version | Provides | Package |\n|-|-|-|-|\n";
    my $ide = "|Artifact | Version | Provides | Update site |\n|--|--|--|--|\n";

    my @lines = split( /\n/, $args{content} );
    @lines = sort @lines;
    for my $line (@lines) {
    	next if (!$line || $line =~ /^\s*#/);
    	
    	my ($title, $artifact, $version, $classifier, $ext) = split(/\|/, $line);
    	$ext = "jar" unless ($ext);
    	$classifier = ($classifier) ? "-$classifier" : "";
    	
    	if ($title eq "sling") {
    		
            $launchpad .="| Sling Standalone Application | $artifact | A self-runnable Sling jar. | " . downloadLink("org.apache.sling.launchpad-$artifact.jar"). "|\n";
            $launchpad .="| Sling Web Application | $artifact | A ready-to run Sling webapp as a war file. | " . downloadLink("org.apache.sling.launchpad-$artifact-webapp.war"). "|\n";
            $launchpad .="| Sling Source Release | $artifact | The released Sling source code. | " . downloadLink("org.apache.sling.launchpad-$artifact-source-release.zip")." |\n";
        } elsif ( $title eq "sling-ide-tooling" ) {

            $ide .= "| Sling IDE Tooling for Eclipse | $artifact | A p2 update site which can be installed in Eclipse. | " . downloadLinkWithoutSigs("eclipse/$artifact", "Update site") . " " . downloadLink("org.apache.sling.ide.p2update-$artifact.zip", "(zip download)") ." |\n";
    	} else {
	    	
	    	my $target = \$result;
	    	my $artifactLabel;
	    	if ($ext eq "war") {
                $artifactLabel = "Web Application";
	    	} elsif ($classifier eq "-app") {
                $artifactLabel = "Java Application";
	    	} elsif ($artifact =~/^maven-.*-plugin|.*-maven-plugin/) {
	    		$target = \$maven;
                $artifactLabel = "Maven Plugin";
	    	} else {
	    		$artifactLabel = "Bundle";
	    	}
	    	
	        ${$target} .= "|$title|$version|" . downloadLink("$artifact-$version$classifier.$ext", $artifactLabel) . " | " . downloadLink("$artifact-$version-source-release.zip", "Source ZIP") . "|\n";
    	}
    }

    $args{launchpad} = $launchpad;
    $args{content} = $result;
    $args{maven} = $maven;
    $args{ide} = $ide;
    
    return Dotiac::DTL::Template($template)->render(\%args), html => \%args;
}

# Has the same behavior as the above for foo/bar.txt
# files, parsing them into a bar variable for the template.
# Otherwise presumes the template is the path.

sub news_page {
    my %args = @_;
    my $template = "content$args{path}";
    $args{breadcrumbs} = breadcrumbs($args{path});

    my $page_path = $template;
    $page_path =~ s/\.[^.]+$//;
    if (-d $page_path) {
        for my $f (grep -f, glob "$page_path/*.mdtext") {
            $f =~ m!/([^/]+)\.mdtext$! or die "Bad filename: $f\n";
            $args{$1} = {};
            read_text_file $f, $args{$1};
        }
    }

    for ((fetch_doap_url_list())[0..2]) {
        push @{$args{projects}}, parse_doap($_);
    }

    return Dotiac::DTL::Template($template)->render(\%args), html => \%args;
}

# Recursive Sitemap generation
# Taken from: http://svn.apache.org/repos/asf/chemistry/site/trunk/lib/view.pm
sub sitemap {
   my %args = @_;
   my $template = "content$args{path}";
   my $file = $template;

   # Find the list of files
   my ($dir) = ($file =~ /^(.*)\/.*?/);
   my $entries = {};
   sitemapFind($dir, $entries);

   my $sitemap = "<ul>\n";
   $sitemap = sitemapRender($sitemap, $entries, "");
   $sitemap .= "</ul>\n";
   $args{sitemap} = $sitemap;
   
   return Dotiac::DTL::Template($template)->render(\%args), html => \%args;   
}

sub sitemapFind {
   my ($dir, $entries) = @_;
   $entries->{"title"} = "";
   $entries->{"entries"} = {};
   my %entries = ( "title"=>"", "entries"=>{} );

   foreach my $item (<$dir/*>) {
      my ($rel) = ($item =~ /^.*\/(.*?)$/);

      if(-d $item) {
      	 # Only consider folders which have content page by them
      	 if(-f "$item.mdtext") {
            $rel .= ".mdtext" ;
            $entries->{"entries"}->{$rel} = {};
            sitemapFind($item, $entries->{"entries"}->{$rel});
      	 }
      } elsif($item =~ /\.(html|mdtext)$/) {
         # Grab the title
         my $title = $rel;
         if($rel =~ /\.mdtext$/) {
             my %args;
             read_text_file $item, \%args;
             $title = $args{"headers"}->{"title"};
         } elsif ($rel =~ /\.png$/ || $rel =~ /\.jpg$/) {
            next;
         } else {
             open F, "<$item";
             my $file = "";
             while(my $line = <F>) {
                $file .= $line;
             }
             close F;

             if($file =~ /block\s+title\s*\%\}(.*?)\{/) {
                $title = $1;
             } elsif($file =~ /title\>(.*?)\</) {
                $title = $1;
             }
         }

         # Process
         if($rel =~ /^index\.(html|mdtext)$/) {
            $entries->{"title"} = $title;
         } else {
            $entries->{entries}->{$rel}->{title} = $title;
         }
      }
   }
   return %entries;
}

sub sitemapRender {
   my ($sitemap, $dir, $path) = @_;
   my %entries = %{$dir->{"entries"}};

   foreach my $e (sort keys %entries) {
      my $fn = $e;
      $fn =~ s/\.mdtext/.html/;
      if($fn eq "images/" or $fn eq "resources/") {
         next;
      }

      my $title = $entries{$e}->{title};
      unless($title) {
         $title = $e;
      }

      $sitemap .= "<li><a href=\"$path/$fn\">".$title."</a>";
      if($entries{$e}->{entries}) {
         my $parent = $e;
         $parent =~ s/\.mdtext$//;
         $sitemap .= "<ul>\n";
         $sitemap = sitemapRender($sitemap, $entries{$e}, "$path/$parent");
         $sitemap .= "</ul>\n";
      }
      $sitemap .= "</li>\n";
   }
   return $sitemap;
}



sub exports {
    my %args = @_;
    my $template = "content$args{path}";
    $args{breadcrumbs} = breadcrumbs($args{path});

    my $page_path = $template;
    $page_path =~ s/\.[^.]+$/.page/;
    if (-d $page_path) {
        for my $f (grep -f, glob "$page_path/*.mdtext") {
            $f =~ m!/([^/]+)\.mdtext$! or die "Bad filename: $f\n";
            $args{$1} = {};
            read_text_file $f, $args{$1};
        }
        $args{table} = `xsltproc $page_path/eccnmatrix.xsl $page_path/eccnmatrix.xml`;

    }

    return Dotiac::DTL::Template($template)->render(\%args), html => \%args;
}

sub parse_doap {
    my $url = shift;
    my $doap = get $url or die "Can't get $url: $!\n";
    my ($fh, $filename) = tempfile("XXXXXX");
    print $fh $doap;
    close $fh;
    my $result = eval `xsltproc lib/doap2perl.xsl $filename`;
    unlink $filename;
    return $result;
}

sub fetch_doap_url_list {
    my $xml = get "http://svn.apache.org/repos/asf/infrastructure/site-tools/trunk/projects/files.xml"
        or die "Can't get doap file list: $!\n";
    my ($fh, $filename) = tempfile("XXXXXX");
    print $fh $xml;
    close $fh;
    chomp(my @urls = grep /^http/, `xsltproc lib/list2urls.xsl $filename`);
    unlink $filename;
    shuffle \@urls;
    return @urls;
}

1;


# Reads data of a referenced page
sub read_ref_page_data {
    my $file = shift;
    my $out = {};
    
    read_text_file $file, $out;
    $out->{path} = "$file";
    $out->{path} =~ s/content(\/.*)\.mdtext/$1.html/;
    
    return $out;
}

sub downloadLink {
	my ($artifact, $label) = @_;
    my $dp = "http://www.apache.org/dist";
    $label = $artifact unless ($label);
    return "[$label]([preferred]sling/$artifact) ([asc]($dp/sling/$artifact.asc), [md5]($dp/sling/$artifact.md5))";
}

sub downloadLinkWithoutSigs {

	my ($artifact, $label) = @_;
    $label = $artifact unless ($label);
    return "[$label]([preferred]sling/$artifact)";
}

sub breadcrumbs {
    my @path = split m!/!, shift;
    pop @path;
    my @rv;
    my $relpath = "";
    my $ext;
    my $sep = "/";
    for (@path) {
        $relpath .= "$sep$_";
        if ($_) {
            $_ = "";
            my $datafile = "content$relpath.mdtext";
            my %data;
            if (-f $datafile) {
                read_text_file $datafile, \%data;
                $ext = ".html";
                $sep = "/";
                my $title = ${data{headers}}{title};
                if ($title) {
                    $_ = $title;
                }
            }
        } else {
            $_ = "Home";
            $ext = "";
            $sep = "";
        }
        push @rv, qq(<a href="$relpath$ext">$_</a>) if $_;
    }
    return join "&nbsp;&raquo&nbsp;", @rv;
}


# Returns information on the last change to the file
# as a reference to a has with three properties
# - rev The SVN Revision
# - date The last modification date (seconds since the epoch)
# - author of the revision
sub svninfo {
  my $source = $_[0];
  my %info;
  my $receiver = sub {
    my $svninfo = $_[1];
    $info{rev} = $svninfo->last_changed_rev;
    $info{date} = $svninfo->last_changed_date / 1000000;
    $info{author} = $svninfo->last_changed_author;
  };

  my $ctx = SVN::Client->new;
  $ctx->info($source, undef, undef, $receiver, 0);
  return \%info;
}


=head1 LICENSE

           Licensed to the Apache Software Foundation (ASF) under one
           or more contributor license agreements.  See the NOTICE file
           distributed with this work for additional information
           regarding copyright ownership.  The ASF licenses this file
           to you under the Apache License, Version 2.0 (the
           "License"); you may not use this file except in compliance
           with the License.  You may obtain a copy of the License at

             http://www.apache.org/licenses/LICENSE-2.0

           Unless required by applicable law or agreed to in writing,
           software distributed under the License is distributed on an
           "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
           KIND, either express or implied.  See the License for the
           specific language governing permissions and limitations
           under the License.
