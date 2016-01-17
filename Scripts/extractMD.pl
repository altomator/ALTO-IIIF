#!/usr/bin/perl -w

# Génération des métadonnées bibliographiques à partir d'un fichier txt :

# 5816291-1	http://gallica.bnf.fr/iiif/ark:/12148/bpt6k58162911/f1/649,1374,285,410/full/0/native.jpg
# 5816291-9	http://gallica.bnf.fr/iiif/ark:/12148/bpt6k58162911/f9/649,1374,285,410/full/0/native.jpg
# 6253037-12	http://gallica.bnf.fr/iiif/ark:/12148/bpt6k62530371/f12/349,272,923,1346/full/0/native.jpg
# champ 1: ID document-n° de page-n° d'image
# champ 2: URL IIIF
# séparateur de champ : TAB

# use strict;
use warnings; 
use 5.010;

#use LWP::Simple;
use Data::Dumper; 
use XML::Twig;
use Path::Class;


# Pour avoir un affichage correct sur STDOUT
binmode(STDOUT, ":utf8");

# URL Gallica de base 
my $baseURL="http://gallica.bnf.fr/";

# répertoire de stockage des MD extraites
my $OUT = "MD";

# répertoire de stockage des documents
my $DOCS = "DOCS";

my $fic;
my $nbURL=0;
my $nbDoc=0;


# table de hashage métadonnées/valeurs
my %hash = ();	

# filter sur la balise <bibliographie> du refNum 
my $handlerRefnum = {               
  'bibliographie' => \&getMD	, 
};                                    
      
                                                                                                                                                                                                                                                                                                                                                                                                    
                                                                     
# ----------------------                                             
# récupération des métadonnées biblio	d'un refNum                    
sub getMD {my ($t, $elt) = @_;                                       
	                                                                   
	   #my $id = $elt->att('id');                                                                                    
	   $hash{"genre"} = $elt->child(0)->text_only();	 # name='genre' ?                               
	   $hash{"titre"} = $elt->child(1)->text_only();	                 
	   $hash{"auteur"} = $elt->child(2)->text_only();                  
	   $hash{"editeur"} = $elt->child(3)->text_only();                   
	   $hash{"dateEdition"} = $elt->child(4)->text_only();              
	}                                                                  



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
open(FIC, "$fic") or die "Pas de fichier !\n";
print "...\n";

my $txt;
while(<FIC>){
	$txt=$_;
  $nbURL++;
	print "\n$nbURL : ";	
	$nbDoc=$nbDoc + genereMD($txt,$handlerRefnum);
}

print "\n\t$nbURL URL traitees.\n";	
print "\t$nbDoc documents traités.\n";	

close FIC;			
print "=============================\n";




  	

# ----------------------
# traitement des MD d'un document via son refNum
sub genereMD {
	my $ligne=shift;
  my $handler=shift;
  
  # séparateur de champ : TAB
  my @tokens = split /[-\t]+/, $ligne;

	# le nom du fichier en sortie = identifiant du document 
	my $ficDoc = $tokens[0];
	if (length($ficDoc) == 6) {
	    $ficDoc ="0".$ficDoc;}
	print "$ficDoc";
	
	# le numéro de page 
	my $page = $tokens[1];
	print ", page $page\n"; 
	
	my $nomFic = $OUT."/".$ficDoc.".txt";
  
  
  # s'il existe déjà, ne rien faire
  if(-e $nomFic){
		print "$nomFic existe déjà !\n";
		return 0;
	} 
	else{
		my $nomRefnum = $DOCS."/".$ficDoc."/X".$ficDoc.".xml";	
	  if(-e $nomRefnum){   
		   return lireMD($nomRefnum,$nomFic,$tokens[0],$page,$handler);
	     }
	   else{
		   print "$nomRefnum n'existe pas !\n";
		   return 0;
	   }
  
   }
}
                                                                                                             
                                                        
	
# ----------------------
# parsing d'un refNum et ecriture du fichier des MD 
sub lireMD {
	my $nomRefnum=shift;
	my $nomFic=shift; # fichier en sortie
	my $idDoc=shift; # ID document
	my $handler=shift;
	
	my $t;
	
	# raz hash
	%hash = ();
	
	print "Chargement de $nomRefnum...\n";
   
  # fichier des MD en sortie
  open my $fh, '>', $nomFic;  
  
  $t = XML::Twig -> new(output_filter=>'safe'); 
  $t -> setTwigHandlers($handlerRefnum); # parser avec un gestionnaire 
  print "parsefile ...\n ";
  $t -> parsefile($nomRefnum);
  

  # say Dumper(\%hash);
  
  # Titre   
  print {$fh} "Titre : "; print {$fh} $hash{"titre"}; print {$fh} "\n"; 
    
  # Genre                        
  $tmp =       
  print {$fh} "Genre : "; print {$fh} $hash{"genre"};print {$fh} "\n";
    
  # Auteur : rechercher l'association 'auteur'      
	if (exists $hash{"auteur"})
	        {  print {$fh} "Auteur : "; print {$fh} $hash{"auteur"};print {$fh} "\n";} 
	   else
	        {  print {$fh} "Auteur : inconnu\n";}
	
	# Editeur     
	if (exists $hash{"editeur"})
	        {  print {$fh} "Editeur : "; print {$fh} $hash{"editeur"}; print {$fh} "\n";} 
	
	# Date     
	if (exists $hash{"dateEdition"})
	        {  print {$fh} "Date d'édition : ";print {$fh} $hash{"dateEdition"}; print {$fh} "\n";} 
	           
	          
	# URL du document Gallica                    
	$hash{"url"} = $baseURL.calculeArk($idDoc,$page); 
	$tmp =   $hash{"url"} ;
  print {$fh} "Gallica : $tmp\n"; 
  close $fh;   
     
  $t -> purge(); # décharger le contenu parsé
	return 1;
}








# ----------------------                            
# calcul d'un ark  à partir d'un ID de document BnF 
    sub calculeArk {my $id=shift;                      
    	                                                  
    	my $ark="1";                                      
    	my $type="NUMM"; #                                
    	                                                  
    	print substr($id, 0, 5);                          
    	print  "\n";                                      
    	if ($type ne "IFN"){                              
    		$ark="ark:/12148/bpt6k".$id.arkControle($id);    
    	} else                                            
    	{                                                 
    	  $ark="ark:/12148/btv1b".$id.arkControle($id);    
    	}                                                 
    	                                                  
    	return $ark;                                      
    	                                                  
    }  
         
                                                     
# calcul d'un caractère de controle ark à partir d'un nom ark
sub arkControle {my $txt=shift;                              
	                                                           
	my $ctrl="";                                               
	my $tableCar="0123456789bcdfghjkmnpqrstvwxz";              
	                                                           

     return "n";
}                                                            