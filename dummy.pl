#! /usr/bin/perl
use strict;

# try to parse xml
use XML::Simple;
use Data::Dumper;

#tova ti e primerno izvikvane
#my $xml = XML::Simple->new();
#my $settings_file = $xml->XMLin('
#<employee>
#        <name>John Doe</name>
#        <age>43</age>
#        <sex>M</sex>
#        <department>Operations</department>
#</employee>'); # the name of the file with the settings
#my $settings = Dumper($settings_file);
#s dympa vijdash kak ti izglejda structurata
#ako ti trqbvat stoinostite se dostypvat aka
#print $settings_file->{'name'},"\n";
#print $settings_file->{'age'};

#eto primera s tvoq fail
my $xml = XML::Simple->new();
my $settings_file = $xml->XMLin('E:\AppServ\www\perl-seo-optimizer\optimizer_settings.xml'); # the name of the file with the settings
my $settings = Dumper($settings_file);

#print $settings; #tuk mojesh da vidish cqlata structura s dump
print "\n\n\n-----------------------------\n автор: ",$settings_file->{'book'}{'bk111'}{'author'}," книга:", $settings_file->{'book'}{'bk111'}{'author'},"\n";

#ako iskash da obhodish vsichki knigi pravish taka

print "\n\n\n-----------------------------\n автор: ",$settings_file->{'book'}{"$_"}{'author'}," книга:", $settings_file->{'book'}{"$_"}{'author'},"\n" foreach (keys %{$settings_file->{'book'}} );

# kakvo pravi   %{$settings_file->{'book'}} ? pyrvo $settings_file->{'book'} tova ti sochi hesh, zatova kazvash na  perl ok shtom e hesh pogledni stoinostite v nego %{$settings_file->{'book'}} /koeto defakto e dereference/
# i sled tova mu kazvash za vsichki kliuchove v tozi hesh ti mi printira edi kakwo si naprimern $settings_file->{'book'}{"$_"}{'author'} tuk avtor e dynoto na strukturata za tova nqma nujda da gledash v neq kakvo ima /da q dereference-vash/


#ako tova ti beshe vyrnalo $settings_file->{'book'} array shteshe da go dereferensvash v konteskt na array @{$settings_file->{'book'}}
# na bg beshe napisano ama neshto gita ne go haresa
