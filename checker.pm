use lib 'E:/Programs/xampp/htdocs/perl-seo-optimizer';
use dbi_seo;

package checker::SEO;
use strict;

use JSON;
use Switch;

BEGIN
{
use Exporter ();
our ($VERSION, @ISA, @EXPORT, @EXPORT_OK, %EXPORT_TAGS);

# set the version for version checking
$VERSION     = 1.00;

@ISA         = qw(Exporter);
@EXPORT      = qw( &rules );
%EXPORT_TAGS = ( );     # eg: TAG => [ qw!name1 name2! ],

# your exported package globals go here,
# as well as any optionally exported functions
@EXPORT_OK   = qw();
}
our @EXPORT_OK;

use base 'dbi_seo::DBI';

local $/;

open(FH, '<', 'optimizer_settings.json');
my $perl_scalar   = <FH>;


checker::SEO->table('sites');
checker::SEO->columns(All => qw/id link content depth vis_cr/);

my $row = checker::SEO->retrieve( '13282098997907355' );
my $cont= $row->content;

open(SET, '<', 'optimizer_messages.json');
my $error_messages = <SET>;

my $domain = 'www.abv.bg'; # current website

# json decode
$perl_scalar = decode_json($perl_scalar);
$error_messages = decode_json($error_messages);

#my $js_max_size = $perl_scalar->{'settings'}{'content'}{'js'}{'max_size'}; # max_size
#print $js_max_size;

#foreach (keys %{$perl_scalar->{'settings'}{'content'}{'js'}})
#{
#	print $perl_scalar->{'settings'}{'content'}{'js'}{$_};
#}

sub printer
{
	my ($message, $rule, $number_of_problems) = @_;

	$message=~s/\$\$/$rule/g;
	$message=~s/\@\@/$number_of_problems/g;

	print $message;
}

sub rules
{
  my ($content, $rules) = @_;

	foreach (keys %{$rules->{'settings'}{'content'}} )
	{
		switch ( $_ )
		{
			case "urls"
			{
				my %urls;
				foreach( $content=~m/href="(.*?)"/ixg )
				{
					$urls{$_} = 1;
					#my $link = $_;
					#print $_;
					#print "ne" if ( length($link) > $rules->{'settings'}{'content'}{'urls'}{'max_length'});
					#print "ne2", length($link=~s/[\w\d_\/-:\.]*//g), "\n";
				}

				foreach(keys %{$rules->{'settings'}{'content'}{'urls'}})
				{
					switch($_)
					{
						my $max = $rules->{'settings'}{'content'}{'urls'}{$_};
						my $problems = 0;

						case "max_length"
						{
							foreach(keys %urls)
							{
								if(length($_) > $max)
								{
									$problems++;
								}
							}

							if($problems)
							{
								&printer($error_messages->{'settings'}{'content'}{'urls'}{'max_length'}, $max, $problems);
							}
						}
						case "max_special_chars"
						{
							foreach(keys %urls)
							{
								my $link = $_;
								if(length($link) - length($link=~s/[\w\d_\/-:]*//g) > $max)
								{
									$problems++;
								}
							}

							if($problems)
							{
								&printer($error_messages->{'settings'}{'content'}{'urls'}{'max_special_chars'}, $max, $problems);
							}
						}
						case "max_slashes"
						{
							foreach(keys %urls)
							{
								my $link = $_;
								if(length($link) - length($link=~s/\\\///g) > $max)
								{
									$problems++;
								}
							}

							if($problems)
							{
								&printer($error_messages->{'settings'}{'content'}{'urls'}{'max_slashes'}, $max, $problems);
							}
						}
						case "max_outgoing"
						{
							foreach(keys %urls)
							{
								#my $link = $_;
#print $link=~m/http(s?):\/\/$domain\/*/i;
								#print $_;
								#if(!$link=~m/http(s?):\/\/$domain\/*/i)
								#{
								#	print 1;
								#	$problems++;
								#}
								#else
								#{
								#	print 2;
								#}
							}
						}
					}
				}
			}	
		}
	}
}

END {} #global destructor

1; #do not forget to return a true value
