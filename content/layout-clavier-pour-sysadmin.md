---
title: "Une disposition de clavier pour les admin sys"
date: 2024-12-02
draft: false
description: Utiliser xkb ou xmodmap pour changer le layout du clavier afin de rendre certains caractères plus faciles à taper
---
# Une disposition de clavier pour les admin sys

Certains caractères sont pénibles à taper, par exemple : @ | - \_ \`.
Sous Linux, il est possible de changer la combinaison de touches qui les produit pour éviter les mouvements de mains compliqués.

Pour ma part :

- @ = AltGr + A
- | = AltGr + P
- \_ = Maj + Espace
- \- = AltGr + S
- \` = AltGr + œ (la touche en dessous de Echap)

Deux possibilités pour faire ça :

Sous Xorg, au runtime avec xmodmap (exemple de script) :

```sh
#!/bin/sh
# reset to default layout
setxkbmap fr
# altgr+a = @
xmodmap -e 'keycode 24 = a A a A at adiaeresis acircumflex'
# altr+p = |
xmodmap -e 'keycode 33 = p P p P bar grave paragraph'
# altgr+oe = `
xmodmap -e 'keycode 49 = oe OE oe OE grave'
# altgr+s = -
xmodmap -e 'keycode 39 = s S s S minus Oslash oslash'
# shift+space = _
xmodmap -e 'keycode  65 = space underscore space NoSymbol space'
```

Sous Wayland (et Xorg), en modifiant le fichier de layout : `/usr/share/X11/xkb/symbols/fr` (par exemple)

```
# ordre dans les tableaux : touche, shift+touche, altgr+touche, shift+altgr+touche
key <AD01> { [ a, A, at, adiaeresis ] };
key <AD10> { [ p, P, bar, grave ] };
key <SPCE> { [ space, underscore, space, space ] };
key <AC02> { [ s, S, minus, Ooblique ] };
key <TLDE> { [ oe, OE, grave, rightdoublequotemark ] };
```
