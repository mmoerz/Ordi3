#!/usr/bin/perl -w 
use strict;
use File::Basename;

sub usage()
{
  print "USAGE: $0 <filename>\n\n";
  print "$0 replaces the necessary amp stuff in the html file\n\n";
  print "\tfilename must be a html file\n";
}

if ($#ARGV < 0) {
  print $#ARGV;
  &usage();
  exit 1;
}

my $file=shift(@ARGV);
open(INFO, $file) or die("Could not open file: $file\n");

open(OUTHTML, '>', "$file.ampfixed") or die("Could not open file: $file.ampfixed\n");

my $dirname = dirname($file);

my $count = 0;
my $line;
my ($stylesheet, $cssline);
foreach $line (<INFO>)  {   
    $count += 1;
    
    if ($line =~ m%\s*<link rel="stylesheet" href="([a-zA-Z0-9\./_]*)">\s*%)
    {
      $stylesheet = $1;
      print "stylesheet is: $stylesheet\n";
    } elsif ($line =~ m%\s*<!-- replace -->\s*%) 
    {
      print "removed a comment - replace tag\n";
    } elsif ($line =~ m%\s*<style amp-custom>\s*%)
    {
      print OUTHTML $line;
      open(CSS, "$dirname/$stylesheet");
      foreach $cssline (<CSS>) {
        print OUTHTML $cssline;
      }
      close(CSS);
    } else {
      print OUTHTML $line;
    }
}
close(INFO);

close(OUTHTML);
