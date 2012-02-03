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

my $domain = 'ganev.bg'; # current website
my @errors; # all errors

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

sub max_length
{
	my $problems = 0;

	my ($max, $key, %urls) = @_;

	foreach(keys %urls)
	{
		if(length($_) > $max)
		{
			$problems++;
		}
	}

	if($problems)
	{
		&printer($error_messages->{'settings'}{'content'}{$key}{'max_length'}, $max, $problems);
	}
}

sub max_chars
{
	my $problems = 0;

	my ($max, $chars, $chars_text, %urls) = @_;

	foreach(keys %urls)
	{
		my $link = $_;
		if(length($link) - length($link=~s/$chars//g) > $max)
		{
			$problems++;
		}
	}

	if($problems)
	{
		&printer($error_messages->{'settings'}{'content'}{'urls'}{$chars_text}, $max, $problems);
	}
}

sub case_use
{
	my ($use, $key, $must, $content) = @_;

	my $save_content = $content;

	if((!$must && $content=~s/\<$use//g) || ($must && !($save_content=~s/\<$use//g)))
	{
		&printer($error_messages->{'settings'}{'content'}{$key}{'use'}, $must ? '' : 'not');
	}
}

sub rules
{
  my ($content) = @_;

	foreach (keys %{$rules->{'settings'}{'content'}} )
	{
		switch ( $_ )
		{
			case 'flash'
			{
				foreach(keys %{$rules->{'settings'}{'content'}{'flash'}})
				{
					switch($_)
					{
						case "use"
						{
							&case_use('object', 'flash', $rules->{'settings'}{'content'}{'flash'}{$_}, $content);
						}
					}
				}
			}
			case "urls"
			{
				my %urls;
				foreach( $content=~m/href="(.*?)"/ixg )
				{
					$urls{$_} = 1;
				}

				foreach(keys %{$rules->{'settings'}{'content'}{'urls'}})
				{
					switch($_)
					{
						my $max = $rules->{'settings'}{'content'}{'urls'}{$_};

						case "max_length"
						{
							&max_length($max, 'urls', %urls);
						}
						case "max_special_chars"
						{
							&max_chars($max, '[\w\d_\/-:]*', $_, %urls);
						}
						case "max_slashes"
						{
							&max_chars($max, '\\\/', $_, %urls);
						}
					}
				}
			}
		}
	}
}

sub CheckSite
{
	use base 'dbi_seo::DBI';

	checker->table('sites');
	checker->columns(All => qw/id link content depth vis_cr/);

	my @cont = checker->retrieve_all();

	foreach (@cont)
	{
		&rules($_->content);
	}

	# after finishing delete all
	#checker::SEO->delete_all;
	#checker::SEO->dbi_commit();
}

#temp
&CheckSite();

END {} #global destructor

1; #do not forget to return a true value
