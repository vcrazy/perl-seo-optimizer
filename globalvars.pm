package globalvars;

use strict;

BEGIN
{
use Exporter ();
our ($VERSION, @ISA, @EXPORT, @EXPORT_OK, %EXPORT_TAGS);

# set the version for version checking
$VERSION     = 1.00;

@ISA         = qw(Exporter);
@EXPORT      = qw(  );
%EXPORT_TAGS = ( );     # eg: TAG => [ qw!name1 name2! ],

# your exported package globals go here,
# as well as any optionally exported functions
@EXPORT_OK   = qw( $host $dbname $port $dbuser $dbpass );
}

our @EXPORT_OK;

our $host    = "localhost";
our $dbname  = "perlseo";
our $port    = 15432;
our $dbuser  = "postgres";
our $dbpass  = "";
