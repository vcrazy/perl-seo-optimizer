#! /usr/bin/perl
use LWP::UserAgent;

  my $ua = LWP::UserAgent->new;
  $ua->agent("perl-SEO-optimizer");

  my $req = HTTP::Request->new(POST => 'http://probook.bg');
  #$req->content_type('application/x-www-form-urlencoded');   #explain
  #$req->content('query=libwww-perl&mode=dist');              #explain

  my $res = $ua->request($req);

  my $result;
  if ($res->is_success) {
      $result=$res->content;
  }
  else {
      $result=$res->status_line, "\n";
  }

print "Content-type: text/html\n\n";
print $result;

  
