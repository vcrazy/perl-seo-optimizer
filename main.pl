use strict;

use lib 'E:/Programs/xampp/htdocs/perl-seo-optimizer';
use globalvars;
use crawler;
use checker;

my $link;

while (!&IsLink($link))
  {
    print "enter valid link:";
    $link=<>;
    $link=~s/\s//;
    $link='http://'.$link if($link!~m/^http:\/\//);
  }

my $host= $link;
$host=~ s/https?:\/\///;  

print $link, " = ", $host, "\n";
use Net::Telnet;
my $connection;
eval {$connection=Net::Telnet->new(Timeout => 100, Host => $host, Port=>80)};



if ( defined($connection) )
  {
    my @list_urls;
    &Crawlersub($link,1,\@list_urls);
	#&CheckSite();
  }
else
  {
    print "Not reachable or timeout";
  }
