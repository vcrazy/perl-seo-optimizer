#! /usr/bin/perl
use strict;
use WWW::Mechanize;

sub IsLink
{
  my ($link)=@_;
  my ($bul)=(' ¡¢£¤¥¦§¨©ª«¬­®¯àáâãäåæçèéêìîï');
  return ($link=~m/^(((((https?)|(ftp)):\/\/)|(www)) #to begin with http: https or www
               ([\-\w$bul]+\.)+                 #to catch the domain
               ([\w{2,6}$bul]+)                 #to catch the area bg com
               (\/[%\-\w$bul]+(\.\w{2,})?)*     #to catch files
               (([\w$bul\-\.\?\\\/+@&#;`~=%!]*) #to catch varaiables
               (\.\w{2,}$bul)?)*\/?)$/ix);
}

sub GetDomain
{
  my ($link)=@_;
  my ($bul)=(' ¡¢£¤¥¦§¨©ª«¬­®¯àáâãäåæçèéêìîï');
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


sub Crawer
{
  my ($uri,$depth,$unique_urls)=@_;
  my $mech = WWW::Mechanize->new( agent => 'perl-seo-optimizer 1.00' );


  #initialize the list of urls
  if ($#{$unique_urls} == -1)
    {
      $unique_urls->[0]=$uri;
    }
  
  $mech->get( $uri );
  my @page_urls=$mech->links;
  my $content= $mech->content();
 
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
&Crawer("http://mobile.bg",0, \@list_url);

#print $_, "\n" foreach (@list_url);

print "\n $#list_url";
