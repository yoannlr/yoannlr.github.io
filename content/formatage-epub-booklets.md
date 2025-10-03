---
title: "Convertir un ePub en PDF puis en livre imprimable"
date: 2025-10-03T11:48:58+02:00
draft: false
keywords:
  - epub
  - pdf
  - pandoc
  - conversion
  - booklets
  - livre
  - impression
  - signatures
  - pdfjam
description: Comment convertir un document ePub en document PDF, puis en livrets/cahiers imprimables, avec des outils libres.
---
# Convertir un ePub en PDF puis en livre imprimable

Avec rien d'autre que des outils libres, il est possible de convertir/formater un livre ePub en joli document PDF, puis d'en créer des livrets/cahiers imprimables.

## Conversion ePub en PDF avec pandoc

[Pandoc](https://pandoc.org/) permet la conversion de documents avec des formats d'entée et de sortie divers (HTML vers PDF, Markdown vers HTML, Markdown vers PDF etc).

Avec la commande basique suivante, on peut convertir un ePub en PDF.
Ici avec un fichier d'exemple ePub :

```
pandoc livre.epub -o livre.pdf
```

![Résultat de la conversion](/img/pandoc_epub_1.webp)

Le résultat obtenu n'est pas des plus jolis, mais pandoc est très paramétrable.
Avec les options suivantes, on peut changer le format du papier, la police, les marges :

```
pandoc livre.epub -V geometry:a4paper -V geometry:margin=1.5cm -V mainfont="DejaVu Serif" -V fontsize=12pt --pdf-engine=xelatex -o livre.pdf
```

![Résultat de la conversion avec des options de style](/img/pandoc_epub_2.webp)

Enfin, en rajoutant un peu de LaTeX, on peut formater les pages du livre de sorte à avoir des marges différentes entre les pages paires et impaires.

Commençons par créer le fichier `margins.tex` :

```tex
\usepackage{geometry}
\geometry{
    left=2cm,
    right=1.5cm,
    top=1.5cm,
    bottom=1.5cm,
    headheight=1cm,
    headsep=1cm,
    footskip=1cm,
    twoside,
    bindingoffset=1cm
}
```

Puis on indique à pandoc qu'on souhaite inclure ce fichier LaTeX lors de la conversion du document :

```
pandoc livre.epub -V geometry:a4paper -V geometry:margin=1.5cm -V mainfont="DejaVu Serif" -V fontsize=12pt --pdf-engine=xelatex -H margins.tex -o livre.pdf
```

Le PDF généré est parfait pour être consulté sur ordinateur, mais il ne convient pas à la création d'un livre dont on souhaite agrafer les pages en leur centre.
Il faut donc un moyen de générer des "booklets" : des livrets/cahiers.

## Génération de livrets imprimables

Si le document PDF est assez court, il sera peut-être possible d'en créer directement un livre.
Pour cela, on peut utiliser l'utilitaire `pdfbook2` sur notre PDF :

```
pdfbook2 --paper=a4paper livre.pdf
```

À la sortie, on obtient le fichier `livre-book.pdf`, qui contient un seul cahier, agrafable en son centre, de 2 pages A5 par page A4, soit 4 pages par feuille recto-verso.
Le fichier `livre-book.pdf` peut être directement imprimé en recto-verso avec retourement sur le bord long (c'est pour cela que certaines pages sont à l'envers dans le PDF !).

Avec cet outil, les livre conséquents (200 pages par exemple) seront transformés en un seul cahier qu'il sera difficile voire impossible d'agrafer en son centre.
Il nous faut donc un outil pour paramétrer la taille de cahiers, et malheureusement `pdfbook2` ne le permet pas.
L'utilitaire `pdfjam`, en revanche, offre cette possibilité :

```
pdfjam --paper a4paper --landscape --signature 40 livre.pdf
```

![Résultat de la séparation en cahiers](/img/booklets.webp)

Cette commande produit le fichier `livre-pdfjam.pdf` qui contient l'ensemble des pages arrangées en cahiers de 40 pages (soit 10 feuilles à agrafer).
À nouveau, le PDF est imprimable en recto-verso avec retournement sur le bord long.

En graphique, le programme [Boomaga](https://www.boomaga.org/) permet de faire la même chose, de manière visuelle et interactive.

![Interface de Boomaga](/img/boomaga.webp)
