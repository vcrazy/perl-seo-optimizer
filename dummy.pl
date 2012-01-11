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
#с дъмпа прави цялата структура как ти изглежда
#ако ти трябват стойностите от файла след прочитане може да ги достъпиш така
#print $settings_file->{'name'},"\n";
#print $settings_file->{'age'};

#ето ти и пример с твоя файл
my $xml = XML::Simple->new();
my $settings_file = $xml->XMLin('E:\AppServ\www\perl-seo-optimizer\optimizer_settings.xml'); # the name of the file with the settings
my $settings = Dumper($settings_file);

#print $settings; #тук можеш да видиш цялата структира с dump
print "\n\n\n-----------------------------\n автор: ",$settings_file->{'book'}{'bk111'}{'author'}," книга:", $settings_file->{'book'}{'bk111'}{'author'},"\n";

#ако искаш да обходиш всички книги правиш така

print "\n\n\n-----------------------------\n автор: ",$settings_file->{'book'}{"$_"}{'author'}," книга:", $settings_file->{'book'}{"$_"}{'author'},"\n" foreach (keys %{$settings_file->{'book'}} );

# какво прави   %{$settings_file->{'book'}} първо $settings_file->{'book'} това ти сочи хеш, затова  казваш на perl ок щом е хеш погледни стойностите в този хеш %{$settings_file->{'book'}} /което дефакто е дереференсване/
# и след това му казваш за всички ключове в този хеш ти ми принтирай еди какво си например $settings_file->{'book'}{"$_"}{'author'} тук автор е дъното на структурата за това няма нужда да му казваш като какво да го разглежда


#ако това ти беше върнало $settings_file->{'book'} array щеше да го дереференсваш в array @{$settings_file->{'book'}} скаларите не се нуждаят от дереференция
