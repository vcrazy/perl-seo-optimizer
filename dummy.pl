#! /usr/bin/perl
use strict;

# try to parse xml
use XML::Simple;
use Data::Dumper;

#⮢� � � �ਬ�୮ ���������
#my $xml = XML::Simple->new();
#my $settings_file = $xml->XMLin('
#<employee>
#        <name>John Doe</name>
#        <age>43</age>
#        <sex>M</sex>
#        <department>Operations</department>
#</employee>'); # the name of the file with the settings
#my $settings = Dumper($settings_file);
#� �꬯� �ࠢ� �猪��� �஬����� ���� �� ���� �� ������
#��� � ���� �⮩����� �� 䠩�� ᫥� ���⠭� ���� �� �� ���ꯨ� ⠪�
#print $settings_file->{'name'},"\n";
#print $settings_file->{'age'};

#�� � � �ਬ�� � ⢮� 䠩�
my $xml = XML::Simple->new();
my $settings_file = $xml->XMLin('E:\AppServ\www\perl-seo-optimizer\optimizer_settings.xml'); # the name of the file with the settings
my $settings = Dumper($settings_file);

print $settings;
print "\n\n\n-----------------------------\n ⮢� � ���� ��: ",$settings_file->{'book'}{'bk111'}{'author'},"\n";
