#!/usr/bin/perl -w

# Génération d'une liste d'URLs IIIF à partir d'une liste de blocs ALTO de la forme :
# DOCS/5816291/X/X0000001.xml:	<Illustration ID="PAG_00000001_IL000001" HEIGHT="410" WIDTH="285" HPOS="649" VPOS="1374"/>
# DOCS/6253037/X/X0000012.xml: <Illustration ID="PAG_00000012_IL000001" HPOS="349" VPOS="272" HEIGHT="1346" WIDTH="923"/>

# Format des URL IIIF Gallica : 
# http://gallica.bnf.fr/iiif/ark:/12148/bpt6k62530371/f12/349,233,923,1450/full/0/native.jpg

# Format du fichier généré : 
# champ 1: ID document-n° de page-n° d'image
# champ 2: URL IIIF
# séparateur de champ : TAB

use Data::Dumper; 

# Pour avoir un affichage correct sur STDOUT
binmode(STDOUT, ":utf8");

# Constante : URL IIIF Gallica de base
my $baseURL="http://gallica.bnf.fr/iiif/";

# variables globales
my $fic;
my $ficout;
my $nbLignes=0;
my $ligne;


if(scalar(@ARGV)!=1){
	die "Un argument obligatoire :
	1 - fichier à traiter
	";
}
while(@ARGV){
	$fic=shift;
	if(-e $fic){
		#print "$fic existe !\n";
	}
	else{
		die "$fic n'existe pas !\n";
	}
}


print "Ouverture et chargement de $fic...\n";
open(IN, "$fic") or die "Pas de fichier !\n";
my $txt;


# récupérer le nom de fichier
$ficout=$fic;
$ficout=~s/^(.*)\.xhtml.*$/$1/;
$ficout=$ficout."_URL";

open(OUT, ">$ficout");			

print "...\n";

while(<IN>){
	$txt=$_;
  $nbLignes++;
	print "\n\n$nbLignes : \n";	
	$ligne=genereURL($txt);
	print OUT "$ligne\n";
	
}

print "\n\t$nbLignes URL traitees.\n";		

close OUT;
close IN;
			
print "Sortie : $ficout.\n";
print "=============================\n";


# ----------------------
sub genereURL {
	my $ligne=shift;
	
	my $URL=$baseURL;
	
	# décomposer les tokens 
	# / pour DOCS/5816291/X/X0000001.xml
	# : (ou -)  pour 5816291/X/X0000001.xml:	
	my @tokens = split /[-:.\/]+/, $ligne;

	# traitement de l'identifiant du document
	my $UD = $tokens[1];
  
  # supprimer le 0 en tete de l'identifiant 
  $UD = $UD*1;
  print "ID : $UD\n";
  
  my $ark = calculeArk($UD);
  $URL=$URL.$ark;
  
  # traitement du numéro de page
  my $numPage =  substr $tokens[3], 1; # supprimer le X devant X0000001.xml
  $numPage = $numPage*1; # convertir en entier pour supprimer les 00000
  print "page : $numPage \n";
  $URL=$URL."/f$numPage/";
  
  # Traitement de l'emprise à découper
  my $xml = $tokens[5];
  print "XML : $xml\n";
  
  # 1. se débarasser de <Illustration 
  my @tmp = split(/(ID=)/, $xml);
  
  #print Dumper \@tmp;
  # 2. reconstruire les paires xxx="valeur" : ID="..." VPOS="..."
  my $geo = $tmp[1].$tmp[2];
  #print $geo;
  
  # 3. extraire les informations géométriques xxx="valeur" dans un hash
	my %eltsXML = split /[\s=]/, $geo;
	#print Dumper \%eltsXML; 
  
	# 4. placer les informations géométriques dans la requete :  x,y,largeur,hauteur
	
	$URL=$URL.$eltsXML{"HPOS"}.",".$eltsXML{"VPOS"}.",".$eltsXML{"WIDTH"}.",".$eltsXML{"HEIGHT"};
	
	# 5. supprimer les " autour des valeurs
	$URL=~ s/"//g; 
	# 5. supprimer les > parasites de fin d'élément XML
	$URL=~ s/>//g; 
	
	# finalisation de l'URL IIIF
  $URL=$URL."/full/0/native.jpg";
  
	return "$UD-$numPage\t$URL";
}

# -------- à faire
# calcul de la clé ark
sub calculeArk {
	my $ID=shift;
	my $ark="n"; 
		
	return "ark:/12148/bpt6k".$ID.$ark;
	
	}