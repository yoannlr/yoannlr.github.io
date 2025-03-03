---
title: "Plusieurs versions de la libstdc++"
date: 2025-02-28T19:16:31+01:00
---
# Comment installer plusieurs versions de la libstdc++

Il n'est pas rare de vouloir exécuter un programme et d'obtenir une erreur du type :

`libxxx.so: /lib/x86_64-linux-gnu/libstdc++.so.6: version GLIBCXX_3.4.32 not found (required by .../libxxx.so)`

La libstdc++ est fournie par gcc (le compilateur GNU).
Pour trouver la version de gcc qui fournit la version GLIBCXX qui vous manque, vous pouvez vous référer à [son ABI](https://gcc.gnu.org/onlinedocs/libstdc++/manual/abi.html).

Dans mon exemple, l'ABI indique qu'il faut installer gcc 13.2.0 minimum.
Malheureusement, cette version n'est pas installable avec apt sous Debian 12.

Je vais donc compiler moi-même gcc et la bibliothèque dans un répertoire séparé des bibliothèques du système, puis exécuter le programme en lui indiquant d'aller y chercher les bibliothèques.

La compilation peut prendre une trentaine de minutes (la durée varie selon la puissance de votre machine).
Elle peut être effectuée en suivant les étapes suivantes :

1. Télécharger le code source de gcc dans la version qui nous convient [depuis le serveur de GNU](https://ftp.gnu.org/gnu/gcc/).
  Exemple : `wget https://ftp.gnu.org/gnu/gcc/gcc-13.2.0/gcc-13.2.0.tar.gz`.

2. Extraire l'archive : `tar zxf gcc-13.2.0.tar.gz` et s'y rendre `cd gcc-13.2.0`.
3. Télécharger les pré-requis à la compilation.
  Heureusement, un script qui s'en charge est fournit ! `./contrib/download_prerequisites`.

4. Créer un dossier build en dehors du répertoire des sources de gcc et s'y rendre : `mkdir ../gccbuild ; cd ../gccbuild`.

5. Pour s'assurer que les configurations de notre environnement n'interfèreront pas avec le build, désaffecter les variables suivantes dans le shell courant : `unset LIBRARY_PATH CPATH C_INCLUDE_PATH PKG_CONFIG_PATH CPLUS_INCLUDE_PATH INCLUDE LD_LIBRARY_PATH CFLAGS CXXFLAGS`

6. Configurer le build : `../gcc-13.2.0/configure --prefix=/usr/local/lib/gcc13.2.0 --disable-multilib`.
  On indique ici l'emplacement de la future installation de gcc et des bibliothèques avec l'option prefix.
  On indique aussi qu'on ne souhaite pas supporter l'architecture 32 bits (ajustez selon votre besoin).
  À l'issue de cette commande, un fichier `Makefile` est généré dans le répertoire de build.

7. Lancer la compilation avec `make`.
  Pour l'accélérer, on peut indiquer à make de paralléliser les jobs : `make -j4` par exemple pour lancer 4 jobs ; `make -j$(nproc)` pour utiliser tous vos coeurs de processeur.
  C'est de loin l'étape la plus longue (environ 30 minutes avec 10 jobs sur ma machine).
  Avec un seul job, j'ai annulé la compilation au bout d'1h30...

8. Installer le résultat de la compilation dans le préfixe : `sudo make install`.

À la fin du processus, on nous indique l'emplacement de "LIBDIR", c'est-à-dire le répertoire où se trouve notre installation de la bibliothèque dans sa version souhaitée.
On peut indiquer à notre programme en erreur de l'utiliser :

```
$ LD_LIBRARY_PATH=/usr/local/lib/gcc13.2.0/lib64:$LD_LIBRARY_PATH ./prog
```  

Ici, vous l'aurez déduit, LIBDIR est `/usr/local/lib/gcc13.2.0/lib64`.

## Pour aller plus loin

Afin de savoir quelle version fournit votre installation de cette bibliothèque, vous pouvez exécuter la commande suivante :

```
$ strings /lib/x86_64-linux-gnu/libstdc++.so.6 | grep GLIBCXX
GLIBCXX_3.4
GLIBCXX_3.4.1
GLIBCXX_3.4.2
GLIBCXX_3.4.3
GLIBCXX_3.4.4
```

Pour en apprendre davantage sur la compilation de gcc, je vous recommande la lecture de [cet article de Dominic Meiser](https://d-meiser.github.io/2015/11/30/building-gcc-trunk.html).
Certains flags y sont présentés qui peuvent s'avérer pertinents lors de la compilation, comme `--disable-bootstrap` par exemple.

La lecture de [cet autre article du même auteur](https://d-meiser.github.io/2015/12/10/build-times.html) peut aussi être intéressante si vous cherchez à optimiser le temps de compilation.
