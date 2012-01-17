#! /usr/bin/perl
use strict;
use WWW::Mechanize;

sub GetDomain
{
  my ($link)=@_;
  my ($bul)=(' ¡¢£¤¥¦§¨©ª«¬­®¯àáâãäåæçèéêìîï');
  if ($link=~m/(((((https?)|(ftp)):\/\/)|(www)) #to begin with http: https or www
               ([\-\w$bul]+\.)+                 #to catch the domain
               ([\w{2,6}$bul]+)                 #to catch the area bg com
               (\/[%\-\w$bul]+(\.\w{2,})?)*     #to catch files
               (([\w$bul\-\.\?\\\/+@&#;`~=%!]*) #to catch varaiables
               (\.\w{2,}$bul)?)*\/?)/ix)
    {
      return substr($8,0,-1);
    }
}

sub UniqueUrl
{
  my ($link, @unique_urls)=@_;
  
  foreach (@unique_urls)
    {
      return 0 if ( ($link eq $_) );
    }
  return 1;
}

sub IsNotFile
{
  my ($link)=@_;
  my @files_lib=('.mp3','.exe','.pdf','.doc','.ico');

  foreach (@files_lib)
    {
       return 0 if ($link=~m/$_/);
    }
  return 1 ;
}
my $mech = WWW::Mechanize->new( agent => 'perl-seo-optimizer 1.00' );

my $uri=qq(http://www.mobile.bg);

$mech->get( $uri );
my @page_urls=$mech->links;
my $content= $mech->content();

my ($domain,@unique_urls)= (&GetDomain($uri),$uri);

foreach (@page_urls)
{
  if ( (&GetDomain($_->[0])=~m/$domain/) and (&UniqueUrl($_->[0],@unique_urls)) and (&IsNotFile($_->[0])) )
    {
      #print $_->[0] ,"\n";
      $unique_urls[$#unique_urls]=$_->[0];
    }
}
