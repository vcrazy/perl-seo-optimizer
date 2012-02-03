use lib 'E:/Programs/xampp/htdocs/perl-seo-optimizer';
use dbi_seo;

package checker;

use strict;
use globalvars;

use JSON;
use Switch;

BEGIN
{
use Exporter ();
our ($VERSION, @ISA, @EXPORT, @EXPORT_OK, %EXPORT_TAGS);

# set the version for version checking
$VERSION     = 1.00;

@ISA         = qw(Exporter);
@EXPORT      = qw( &CheckSite );
%EXPORT_TAGS = ( );     # eg: TAG => [ qw!name1 name2! ],

# your exported package globals go here,
# as well as any optionally exported functions
@EXPORT_OK   = qw();
}
our @EXPORT_OK;

local $/;

open(FH, '<', 'optimizer_settings.json');
my $rules   = <FH>;

open(SET, '<', 'optimizer_messages.json');
my $error_messages = <SET>;

my $domain = 'www.abv.bg'; # current website

# json decode
$rules = decode_json($rules);
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
  my ($content) = @_;

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

use base 'dbi_seo::DBI';

sub CheckSite
{
	checker->table('sites');
	checker->columns(All => qw/id link content depth vis_cr/);

	my @cont = checker->retrieve_all();

	foreach (@cont)
	{
		&rules($_->content);
	}

	# after finishing delete all
	checker::SEO->delete_all;
	checker::SEO->dbi_commit();
}

#temp
&CheckSite();

END {} #global destructor

1; #do not forget to return a true value
