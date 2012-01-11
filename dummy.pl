#! /usr/bin/perl
use strict;

# try to parse xml
use XML::Simple;
use Data::Dumper;

#това ти е примерно извикване
#my $xml = XML::Simple->new();
#my $settings_file = $xml->XMLin('
#<employee>
#        <name>John Doe</name>
#        <age>43</age>
#        <sex>M</sex>
#        <department>Operations</department>
#</employee>'); # the name of the file with the settings
#my $settings = Dumper($settings_file);
#с дъмпа прави някакви промеливи който не успях да достъпя
#ако ти трябват стойностите от файла след прочитане може да ги дотъпиш така
#print $settings_file->{'name'},"\n";
#print $settings_file->{'age'};

#ето ти и пример с твоя файл
my $xml = XML::Simple->new();
my $settings_file = $xml->XMLin('E:\AppServ\www\perl-seo-optimizer\optimizer_settings.xml'); # the name of the file with the settings
my $settings = Dumper($settings_file);

print $settings;
print "\n\n\n-----------------------------\n това е името му: ",$settings_file->{'book'}{'bk111'}{'author'},"\n";
