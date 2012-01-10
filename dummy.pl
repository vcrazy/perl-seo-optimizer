#! /usr/bin/perl
use strict;

# try to parse xml
use XML::Simple;
use Data::Dumper;

my $xml = XML::Simple->new();
my $settings_file = $xml->XMLin('optimizer_settings.xml'); # the name of the file with the settings
my $settings = Dumper($settings_file);


