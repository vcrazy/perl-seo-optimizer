use strict;

use JSON; # -Ç-É-›-› -+-›-› -+-+-+-+-›-›-+ JSON -î-ñ-ï-ô-°-P-P-P-P-P-£-£-£-£-™-ù
use Switch;

local $/;
open(my $fh, '<', 'E:/AppServ/www/perl-seo-optimizer/optimizer_settings.json');
my $json_text   = <$fh>;

open(CON, '<', 'E:/AppServ/www/perl-seo-optimizer/content.txt');
my $cont   = <CON>;

my $perl_scalar = decode_json($json_text);

#my $js_max_size = $perl_scalar->{'settings'}{'content'}{'js'}{'max_size'}; # max_size
#print $js_max_size;

#foreach (keys %{$perl_scalar->{'settings'}{'content'}{'js'}})
#{
#	print $perl_scalar->{'settings'}{'content'}{'js'}{$_};
#}

sub rules
{
  my ($content,$rules) =@_;
  #print $rules->{'settings'}{'content'};
  foreach (keys %{$rules->{'settings'}{'content'}} )
  {
    switch ( $_ )
      {
         case "urls"
           {
           

              foreach( $content=~m/href="(.*?)"/ixg )
                {
                 my $link=$_;
                 print $_;
                 print "ne" if ( length($link) > $rules->{'settings'}{'content'}{'urls'}{'max_length'});
                 print "ne2", length($link=~s/[\w\d_\/-:\.]*//g), "\n";
                }
           }
      }
  }
}

&rules($cont,$perl_scalar);
