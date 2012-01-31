package crawler::DBI;
use lib 'E:/AppServ/www/perl-seo-optimizer/';
#use base 'Class::DBI';
use globalvars;
use strict;

#crawler::DBI->connection("dbi:Pg:dbname=$globalvars::dbname;host=$globalvars::host;port=$globalvars::port", $globalvars::dbuser, $globalvars::dbpass);


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
  if ($link=~m/^(((((https?)|(ftp)):\/\/)|(www)) #to begin with http: https or www
               ([\-\w$bul]+\.)                  #to catch the subdomain
               ([\-\w$bul]+\.)                  #to catch the domain
               ([\w{2,6}$bul]+)                 #to catch the area bg com
               (\/[%\-\w$bul]+(\.\w{2,})?)*     #to catch files
               (([\w$bul\-\.\?\\\/+@&#;`~=%!]*) #to catch varaiables
               (\.\w{2,}$bul)?)*\/?)$/ix)
    {
      if( ($8 ne "") and ($9 ne "") )
        {
          return 0;
        }
      return 1;
    }
}
sub IsSubLink
{
  use strict;
  my ($page, $link)=@_;
  if ($page =~ m/(((https?:\/\/)|(www)).*\/)/)
    {
      $page=$&;
    }
  else
    {
      $page.="/";
    }
  
  if ($$link=~m/^(\/)/)
    {
      $page=substr($page,0,-1) if($page=~m/\/$/);
      $$link="$page$$link";
      return 1;
    }
  elsif ($$link=~m/^(\#)/ and $page!~m/#/)
    {
      $$link="$page$$link";
      return 1;
    }
  else
    {
      my @files_lib=('.php','.html','.asp');
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

sub GetLinksFromPage
{
  use strict;
  use WWW::Mechanize;
  my ($link, $unique_urls, $depth)=@_;
  my $mech= WWW::Mechanize->new( agent => 'perl seo optimizer v 1.1');    #Creates object, hereafter referred to as the "agent".
  eval {$mech->get($link)};                                                      #returns the HTTP::Response object

  my $domain=&GetDomain($link);
  foreach ( $mech->links )
    {
      if ( &IsLink($_->[0]) or &IsSubLink($link,\$_->[0]) )                 #find if is really a link or is sublink. In case sublink we make it full link.
        {
          if( (&GetDomain($_->[0])=~m/$domain/) and (&UniqueUrl($_->[0],$unique_urls)) and (&IsNotFile($_->[0])) )
            {
                 $unique_urls->[$#{$unique_urls}+1]=$_->[0];              #save the link
                 $unique_urls->[$#{$unique_urls}+1]=0;                    #flag for the crawler 1 visited 0 not visited
                 $unique_urls->[$#{$unique_urls}+1]=$depth;               #flag for the crawler $depth
            }
        }
    }
  
}

sub Crawler
{
  use strict;
  my ($uri, $depth, $unique_urls)=@_;
  if ($#{$unique_urls} == -1)                                             #for first time save the first url
    {
      $unique_urls->[0]=$uri;
      $unique_urls->[1]=1;
      $unique_urls->[2]=$depth;
    }
  
  if ($depth!=0)
    {
      &GetLinksFromPage($uri,$unique_urls,$depth);
      for (my $i=0; $i<=$#{$unique_urls}; $i+=3)
        {

          if ($unique_urls->[$i+1]==0)
            {
              $unique_urls->[$i+1]=1;
              &GetLinksFromPage($unique_urls->[$i],$unique_urls,$depth-1) if (($unique_urls->[$i+2]-1)!=0);
            }
        }
      print "@{$unique_urls}";
    }
}
#  use WWW::Mechanize;
#
#  my ($uri,$depth,$unique_urls)=@_;
#  my $mech = WWW::Mechanize->new( agent => 'perl-seo-optimizer 1.00' );
#
#  #crawler::SEO->table('sites');
#  #crawler::SEO->columns(All => qw/id link content depth vis_cr/);
#
#  #initialize the list of urls
#
#  $mech->get( $uri );
#  my @page_urls=$mech->links;
#  my $content= encode("utf8", $mech->content());
#  #my $content= $mech->content();
#  my $id= &GenerateID();
#
#  if ($#{$unique_urls} == -1)
#    {
#      $unique_urls->[0]=$uri;
#      $unique_urls->[1]=0;
#    }
#
#
#  print $unique_urls."\n---------------------------\n";
#
#
#
# # my $result=crawler::SEO->insert
# # ({
# #   id       => $id,
# #   link     => $uri,
# #   content  => $content,
# #   depth    => $depth,
# #   vis_cr   => 1
# #  });
# # crawler::SEO->dbi_commit();
#
#
# my $domain= &GetDomain($uri);
#
#  foreach (@page_urls)
#  {
#   if (&IsLink($_->[0]))
#     {
#        if ( (&GetDomain($_->[0])=~m/$domain/) and (&UniqueUrl($_->[0],$unique_urls)) and (&IsNotFile($_->[0])) )
#         {
#            #print "da\n";
#            if ( $depth!=0 )
#              {
#                $unique_urls->[$#{$unique_urls}+1]=$_->[0];
#                $unique_urls->[$#{$unique_urls}+2]=0;
#             }
#          }
#      }
#  }
#  for (my $i=0; $i<=$#{$unique_urls}; $i+=2)
#    {
#      if ($unique_urls->[$i+1]==0)
#        {
#          $unique_urls->[$i+1]=1;
#    #      &Crawler($unique_urls->[$i],$depth-1,$unique_urls)
#        }
#    }
#
#  print $_."\n" foreach ( @{$unique_urls} );
#
#}



my @list_url;

#print "--------------------------------------------\n";
&Crawler("http://mobile.bg/",2, \@list_url);

#print $_, "\n" foreach (@list_url);

print "\n", ($#list_url+1)/3;
