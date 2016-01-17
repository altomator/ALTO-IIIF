#!/bin/bash
# bash script

# Entrée : documents BnF dans le dossier DOCS

echo " "

rm illustrations.txt
rm illustrations_legende.txt
rm illustrations_pub.txt
rm annotations.txt
rm cartes.txt

echo "Searching for illustrations..."
grep  "<Illustration" DOCS/*/X/* >>  illustrations.txt

echo "Searching for illustrations with caption..."
grep  -B1 "<Illustration" DOCS/*/X/* | fgrep "<ComposedBlock" >> illustrations_legende.txt

echo "Searching for illustrations in ads..."
grep -E "(\<\<Illustration\>.*\<TYPE=\"ad\>)" DOCS/*/X/* >> illustrations_pub.txt # verifier le typage
grep -B1 -A5 -E "(\<\<TextBlock\>.*\<TYPE=\"ad\>)" DOCS/*/X/* | fgrep  "<Illustration" >> illustrations_pub.txt

echo "Searching for maps..."
grep -E "(\<\<Illustration\>.*\<TYPE=\"map\>)" DOCS/*/X/* >> cartes.txt
grep -E "(\<\<Illustration\>.*\<TYPE=\"carte\>)" DOCS/*/X/* >> cartes.txt

echo "Searching for annotations..."
grep -E "(\<\<GraphicalElement\>.*\<TYPE=\"manuscript\>)" DOCS/*/X/* >> annotations.txt

echo " "
echo "Results :" 
wc -l illustrations.txt
wc -l illustrations_legende.txt
wc -l illustrations_pub.txt
wc -l cartes.txt
wc -l annotations.txt