#! /usr/bin/perl
use strict;

use JSON;

local $/;
open(my $fh, '<', 'optimizer_settings.json');
my $json_text   = <$fh>;

my $perl_scalar = decode_json($json_text);

print %{$perl_scalar};
