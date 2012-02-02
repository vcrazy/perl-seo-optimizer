use strict;

use lib 'E:/Programs/xampp/htdocs/perl-seo-optimizer';
use globalvars;
use crawler;
use checker;
use IO::SOCKET::INET;

my @list_urls;
my $link=<>;
$link=~s/\s//;


sub check_site {
  my $host           = shift; # hostname or hostname:port
  my $timeoutseconds = shift || 1;
  my $proto          = "tcp";
  my $handle = IO::Socket::INET->new('PeerAddr'=>$host,'Timeout'=>$timeoutseconds, 'Proto'=>$proto);

  if (defined $handle && $handle) {
    $handle->close();
    return 1; # port in use
  }

  return 0; # not reachable or timeout
}

if (&check_site($link,50))
  {
    &Crawlersub($link,1,\@list_urls);
  }
else
  {
	print "Not reachable or timeout";
  }
