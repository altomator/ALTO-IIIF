#!/bin/bash
# bash script

echo " "
      
# gunzip DOCS/*/X/*.gz

# filtres éléments de contenu dans les fichiers ALTO
./filterIMG.sh

# génération des URL IIIF
perl processURLs.pl illustrations.txt

# génération des images à partir des URL IIIF
perl extractIMG.pl illustrations.txt_URL 100

# extraction des métadonnées des refNum
perl extractMD.pl illustrations.txt_URL