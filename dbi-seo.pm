package dbi_seo::DBI;
use lib 'E:/Programs/xampp/htdocs/perl-seo-optimizer';
use base 'Class::DBI';
use globalvars;
use strict;

dbi_seo::DBI->connection("dbi:Pg:dbname=$globalvars::dbname;host=$globalvars::host;port=$globalvars::port", $globalvars::dbuser, $globalvars::dbpass);
