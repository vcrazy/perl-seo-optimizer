my $site = "http://wdadawdaw.mobile.bg";
my ($bul)=(' ΅Ά£¤¥¦§¨©ª«¬­®―ΰαβγδεζηθικμξο');
if ($site=~m/(((((https?)|(ftp)):\/\/)|(www)) #to begin with http: https or www
             ([\-\w$bul]+\.)+                 #to catch the domain
             ([\w{2,6}$bul]+)                 #to catch the aria bg com
             (\/[%\-\w$bul]+(\.\w{2,})?)*     #to catch files
             (([\w$bul\-\.\?\\\/+@&#;`~=%!]*) #to catch varaiables
             (\.\w{2,}$bul)?)*\/?)/ix)
  {
    print substr($8,0,-1), "\n";
    print $9;
  }
