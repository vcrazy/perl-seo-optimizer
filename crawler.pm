package crawler::DBI;
use lib 'E:/AppServ/www/perl-seo-optimizer/';
use base 'Class::DBI';
use globalvars;
use strict;

crawler::DBI->connection("dbi:Pg:dbname=$globalvars::dbname;host=$globalvars::host;port=$globalvars::port", $globalvars::dbuser, $globalvars::dbpass);


package crawler::SEO;

use lib 'E:/AppServ/www/perl-seo-optimizer/';
use strict;
use globalvars;

BEGIN
{
use Exporter ();
our ($VERSION, @ISA, @EXPORT, @EXPORT_OK, %EXPORT_TAGS);

# set the version for version checking
$VERSION     = 1.00;

@ISA         = qw(Exporter);
@EXPORT      = qw( &IsLink &GetDomain &IsNotFile &Crawler &GenerateID );
%EXPORT_TAGS = ( );     # eg: TAG => [ qw!name1 name2! ],

# your exported package globals go here,
# as well as any optionally exported functions
@EXPORT_OK   = qw();
}
our @EXPORT_OK;

sub GenerateID
{
  my $id="";

  #ID
  $id=time();
  $id.=int(rand(10)) while ( length($id)<17 );                       #generate id with 10 digits from the time and
                                                                     #7 random digits
  return ($id);
}

sub IsLink
{
  my ($link)=@_;
  my $bul=$globalvars::bul_alphabet;
  if ($link=~m/^(((((https?)|(ftp)):\/\/)|(www)) #to begin with http: https or www
               ([\-\w$bul]+\.)                  #to catch the domain
               ([\w{2,6}$bul]+)                 #to catch the area bg com
               (\/[%\-\w$bul]+(\.\w{2,})?)*     #to catch files
               (([\w$bul\-\.\?\\\/+@&#;`~=%!]*) #to catch varaiables
               (\.\w{2,}$bul)?)*\/?)$/ix)
    {
      return 1;
    }
  else
    {
      return 0;
    }
}
sub IsSubLink
{
  my ($page, $link)=@_;
  
  if ($page =~ m/(((https?:\/\/)|(www)).*?\?)/ and $$link!~m/^(\#)/  )#not greedy to the first ?
    {
      $page=substr($&,0,-1);                                          #we remove the ? mark colud also do it with group
    }
    
  if ($page =~ m/(((https?:\/\/)|(www)).*\/)/ and $$link!~m/^(\#)/ )  #remove the current page and link do not begin with #
    {
      $page=$&;
    }
  else
    {
      $page.="/";                                                     #if it is the remote domain without the /
    }

  if ($$link=~m/^(\/)/)                                               #if the link begin with the / then we put the remote domain
    {
      if($page=~ m/(((https?:\/\/)|(www)).*?\/)/)
       {
         $$link=substr($&,0,-1).$$link;
         return 1;
       }
    }
  #elsif ($$link=~m/^(\#)/ and $page!~m/#/)                             #for kotva :D
  #  {
  #    $$link=substr($page,0,-1).$$link;
  #    return 1;
  #  }
  else
    {
      my @files_lib=('.php','.html','.asp','.cgi');                    #all pages shoud be here
      foreach (@files_lib)
        {
          if ($$link=~m/$_/)
            {
               $$link="$page$$link";
               return 1
            }
        }
    }
  return 0;
}
sub GetDomain
{
  my ($link)=@_;
  $$link.="/" if($$link!~ m/(((https?:\/\/)|(www)).*?\/)/);           #we put the / in the edn if there is not / after the https?://
  if ( $$link=~m/(((https?:\/\/)|(www))(.*?)\/)/ix)                   #extract the domain from the link
    {
      return $5;
    }
}

sub UniqueUrl
{
  my ($link, $unique_urls)=@_;
  
  foreach (@{$unique_urls})
    {
      return 0 if ( ($link eq $_) );
    }
  return 1;
}

sub IsNotFile
{
  my ($link)=@_;
  my @files_lib=('.mp3','.exe','.pdf','.doc','.ico','.css','.pic');

  foreach (@files_lib)
    {
       return 0 if ($link=~m/$_/);
    }
  return 1 ;
}

sub Save
{
  use base 'crawler::DBI';
  use WWW::Mechanize;
  
  my($link, $depth) =@_;
  my $mech= WWW::Mechanize->new( agent => 'perl seo optimizer v 1.1');    #Creates object, hereafter referred to as the "agent".
  eval {$mech->get($link)};
  
  my $content= $mech->content();                                          #Take the content

  crawler::SEO->table('sites');
  crawler::SEO->columns(All => qw/id link content depth vis_cr/);

  my $id= &GenerateID();

  my $result=crawler::SEO->insert
    ({
      id       => $id,
      link     => $link,
      content  => $content,
      depth    => $depth,
      vis_cr   => 1
    });
    crawler::SEO->dbi_commit();
}
sub GetLinksFromPage
{
  use WWW::Mechanize;
  my ($link, $unique_urls, $depth)=@_;
  my $mech= WWW::Mechanize->new( agent => 'perl seo optimizer v 1.1');    #Creates object, hereafter referred to as the "agent".
  eval {$mech->get($link)};                                               #returns the HTTP::Response object

  my $domain=&GetDomain(\$link);
  foreach ( $mech->links )
    {
      if ( &IsLink($_->[0])or &IsSubLink($link,\$_->[0]) )                 #find if is really a link or is sublink. In case sublink we make it full link.
        {
          if( (&GetDomain(\$_->[0])=~m/^$domain$/) and (&UniqueUrl($_->[0],$unique_urls)) and (&IsNotFile($_->[0])) )
            {
                 $unique_urls->[$#{$unique_urls}+1]=$_->[0];              #save the link
                 $unique_urls->[$#{$unique_urls}+1]=0;                    #flag for the crawler 1 visited 0 not visited
                 $unique_urls->[$#{$unique_urls}+1]=$depth;               #flag for the crawler $depth
                 &Save($_->[0], $depth);                                  #save the content
            }
        }
    }
}

sub Crawler
{
  my ($uri, $depth, $unique_urls)=@_;
  if ($#{$unique_urls} == -1)                                             #for first time save the first url
    {
      $unique_urls->[0]=$uri;
      $unique_urls->[1]=1;
      $unique_urls->[2]=$depth;
      &Save($uri, $depth);
    }

  if ($depth!=0)
    {
      &GetLinksFromPage($uri,$unique_urls,$depth);                       #generate the links from the page
      for (my $i=0; $i<=$#{$unique_urls}; $i+=3)                         #for all links
        {
          if ($unique_urls->[$i+1]==0)                                   #if the link is not searched
            {
              $unique_urls->[$i+1]=1;                                    #we set the flag for searched link
              &GetLinksFromPage($unique_urls->[$i],$unique_urls,$depth-1) if (($unique_urls->[$i+2]-1)!=0); #and we set the recursion for those uls which
            }                                                                                               #depth is diferent from 0 / we do not need the liks from them/
        }
    }
}

my @list_url;

#print "--------------------------------------------\n";
#&Crawler("http://www.mobile.bg/",1, \@list_url);

#&Crawler("http://probook.bg/",3, \@list_url);

&Crawler("http://itschool.ganev.bg/",1, \@list_url);
my $i=3;
foreach (@list_url)
  {
    if ( ($i%3)==0 )
      {
        print $_."\n";
      }
    $i++;
  }
print "\n", ($#list_url+1)/3;
