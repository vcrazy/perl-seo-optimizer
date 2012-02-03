use strict;

use lib 'E:/AppServ/www/perl-seo-optimizer';
use globalvars;
use crawler;
#use checker;

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

print $link, " = ", $host;
use Net::Telnet;
my $connection;
eval {$connection=Net::Telnet->new(Timeout => 100, Host => $host, Port=>80)};



if ( defined($connection) )
  {
    my @list_urls;
    &Crawlersub($link,1,\@list_urls);
  }
else
  {
    print "Not reachable or timeout";
  }
