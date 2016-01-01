#!/usr/bin/perl -w

# Génération d'images à partir d'un fichier d'URL :

# 5816291-1	http://gallica.bnf.fr/iiif/ark:/12148/bpt6k58162911/f1/649,1374,285,410/full/0/native.jpg
# 5816291-9	http://gallica.bnf.fr/iiif/ark:/12148/bpt6k58162911/f9/649,1374,285,410/full/0/native.jpg
# 6253037-12	http://gallica.bnf.fr/iiif/ark:/12148/bpt6k62530371/f12/349,272,923,1346/full/0/native.jpg
# champ 1: ID document-n° de page-n° d'image
# champ 2: URL IIIF
# séparateur de champ : TAB

use strict;
use warnings;
use LWP::Simple;
use Data::Dumper; 



# Pour avoir un affichage correct sur STDOUT
binmode(STDOUT, ":utf8");

# output directory for extracted images
my $OUT = "IMG";



my $fic;
my $tailleIMG;
my $nbURL=0;
my $nbIMG=0;


if(scalar(@ARGV)!=2){
	die "Usage : perl extraireIMG.pl URLs_file min_image_size (Ko)
	";
}
while(@ARGV){
	$fic=shift;
	$tailleIMG=shift;
	if(-e $fic){
		#print "$fic existe !\n";
	}
	else{
		die "$fic doesn't exists!\n";
	}
}


print "Opening $fic...\n";
open(FIC, "$fic") or die "No file $fic !\n";
print "...\n";

my $txt;
while(<FIC>){
	$txt=$_;
  $nbURL++;
	print "\n - $nbURL - \n";	
	$nbIMG=$nbIMG + genereIMG($txt);
}

print "\n\t$nbURL URLs analysed.\n";	
print "\t$nbIMG images generated.\n";	

close FIC;
			
print "=============================\n";



# ----------------------
sub genereIMG {
	my $ligne=shift;
  my $numImg=1;
  
  # field separator : TAB
  my @tokens = split /[\t]+/, $ligne;

	# file name = id-n° page-n° image 
	my $nomFic = $OUT."/".$tokens[0]."-".$numImg.".jpg";
  
  # cas plusieurs images dans une meme page : incrementer le numero img
  while(-e $nomFic){
		$numImg=$numImg+1;
		$nomFic = $OUT."/".$tokens[0]."-".$numImg.".jpg";
	}
	
  # URL IIIF 
	my $URL = $tokens[1];
  print "URL: $URL";
  
  my $content = get($URL);
  #return 0 unless defined $content;
  if (defined $content){
  	# filtrer les images trop petites
  	if (length($content) > ($tailleIMG*1024)){	
  		open my $fh, '>', $nomFic;
  		binmode $fh;
  		print {$fh} $content;
  		close $fh;
  		print "--> OK : $nomFic\n";
    return 1;}
    else {
  		print "--> Ko size\n";
  		return 0;
  	}
  } else {
  	print "--> Ko URL\n";
  	return 0;
  }
  
  
}