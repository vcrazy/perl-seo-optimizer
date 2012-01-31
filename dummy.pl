#! /usr/bin/perl
# use strict;

use JSON; # тука май ползвам JSON ДЖЕЙСОООООУУУУЪН

local $/;
open(my $fh, '<', 'optimizer_settings.json');
my $json_text   = <$fh>;

my $perl_scalar = decode_json($json_text);

#my $js_max_size = $perl_scalar->{'settings'}{'content'}{'js'}{'max_size'}; # max_size
#print $js_max_size;

#foreach $key (keys %{$perl_scalar->{'settings'}{'content'}{'js'}})
#{
#	print $perl_scalar->{'settings'}{'content'}{'js'}{$key};
#}


sub rules($ $)
{
	my ($param, $hash) = @_;
	foreach (keys %hash) {print $_;}

	if(UNIVERSAL::isa($hash, "HASH"))
	{
		foreach $key (keys %hash)
		{
			&rules($key, $hash{$key}); # how to call the function
		}
	}
	else # is scalar..
	{
		print $param;
	}
}

&rules('1', $perl_scalar->{'settings'});

