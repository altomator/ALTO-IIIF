## Extracting illustrations from ALTO files with IIIF


### Synopsis
 

### Installation
You will need 4 scripts :

1. filterIMG.sh (shell)

2. processURLs.pl (Perl)

3. extractIMG.pl (Perl)

4. extractMD.pl (Perl)

A batch.sh script chains the commands.

The documents must be stored in a "DOCS" folder.
The images will be generated in a "IMG" folder.


### Tests
1. Open a command line.
2. > filterIMG.sh
2. > perl traiterURLs.pl illustrations.txt
3. > perl extractIMG.pl illustrations.txt_URL 200   -- 
4. > perl extractMD.pl illustrations.txt_URL


## License
CC0

<a href="http://creativecommons.org/publicdomain/zero/1.0/"><img src="https://camo.githubusercontent.com/4df6de8c11e31c357bf955b12ab8c55f55c48823/68747470733a2f2f6c6963656e7365627574746f6e732e6e65742f702f7a65726f2f312e302f38387833312e706e67" alt="CC0" data-canonical-src="https://licensebuttons.net/p/zero/1.0/88x31.png" style="max-width:100%;"></a>
