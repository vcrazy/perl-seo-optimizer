package crawler::DBI;
use lib 'E:/AppServ/www/perl-seo-optimizer/';
use base 'Class::DBI';
use globalvars;
use strict;

crawler::DBI->connection("dbi:Pg:dbname=$globalvars::dbname;host=$globalvars::host;port=$globalvars::port", $globalvars::dbuser, $globalvars::dbpass);


package crawler::SEO;

use lib 'E:/AppServ/www/perl-seo-optimizer/';
use strict;
use WWW::Mechanize;
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
  use strict;
  my $id="";

  #ID
  $id=time();
  $id.=int(rand(10)) while ( length($id)<17 );

  return ($id);
}

sub IsLink
{
  use strict;
  my ($link)=@_;
  my $bul=$globalvars::bul_alphabet;
  return ($link=~m/^(((((https?)|(ftp)):\/\/)|(www)) #to begin with http: https or www
               ([\-\w$bul]+\.)+                 #to catch the domain
               ([\w{2,6}$bul]+)                 #to catch the area bg com
               (\/[%\-\w$bul]+(\.\w{2,})?)*     #to catch files
               (([\w$bul\-\.\?\\\/+@&#;`~=%!]*) #to catch varaiables
               (\.\w{2,}$bul)?)*\/?)$/ix);
}

sub GetDomain
{
  use strict;
  my ($link)=@_;
  my $bul=$globalvars::bul_alphabet;
  if ( $link=~m/^(((((https?)|(ftp)):\/\/)|(www)) #to begin with http: https or www
               ([\-\w$bul]+\.)+                 #to catch the domain
               ([\w{2,6}$bul]+)                 #to catch the area bg com
               (\/[%\-\w$bul]+(\.\w{2,})?)*     #to catch files
               (([\w$bul\-\.\?\\\/+@&#;`~=%!]*) #to catch varaiables
               (\.\w{2,}$bul)?)*\/?$)/ix)
    {
      return substr($8,0,-1);
    }
}

sub UniqueUrl
{
  use strict;
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
  my @files_lib=('.mp3','.exe','.pdf','.doc','.ico','.css');

  foreach (@files_lib)
    {
       return 0 if ($link=~m/$_/);
    }
  return 1 ;
}


sub Crawler
{
  use strict;
  use base 'crawler::DBI';
  use Encode;
  my ($uri,$depth,$unique_urls)=@_;
  my $mech = WWW::Mechanize->new( agent => 'perl-seo-optimizer 1.00' );
  
  crawler::SEO->table('sites');
  crawler::SEO->columns(All => qw/id link content depth vis_cr/);
  
  #initialize the list of urls
  if ($#{$unique_urls} == -1)
    {
      $unique_urls->[0]=$uri;
    }
  
  $mech->get( $uri );
  my @page_urls=$mech->links;
  #my $content= encode("utf8", $mech->content());
  my $content= $mech->content();
  my $id= &GenerateID();
  
  my $result=crawler::SEO->insert
  ({ 
    id       => $id,
    link     => $uri,
    content  => $content,
    depth    => $depth,
    vis_cr   => 1
   });
  crawler::SEO->dbi_commit();
  
  
  my $domain= &GetDomain($uri);

  foreach (@page_urls)
  {
    if (&IsLink($_->[0]))
      {
        if ( (&GetDomain($_->[0])=~m/$domain/) and (&UniqueUrl($_->[0],$unique_urls)) and (&IsNotFile($_->[0])) )
          {
            if ( $depth==0 )
              {
                $unique_urls->[$#{$unique_urls}+1]=$_->[0];
              }
            else
              {
                #print $_->[0], "-nivo $depth\n";
                $unique_urls->[$#{$unique_urls}+1]=$_->[0];
                &Crawer($_->[0],$depth-1,$unique_urls);
              }
          }
      }
  }  
}



my @list_url;

print "--------------------------------------------\n";
&Crawler("http://probook.bg",0, \@list_url);

#print $_, "\n" foreach (@list_url);

print "\n $#list_url";
