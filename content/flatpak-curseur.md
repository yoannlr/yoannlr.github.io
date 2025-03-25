---
title: "Curseurs et Flatpak"
date: 2025-03-19T13:48:44+01:00
---
# Configurer Flatpak pour utiliser le curseur du bureau

![C'est plus joli quand ça respecte le thème !](/img/flatpak-curseur.png)

Pour que les applications installées en flatpak respectent la configuration de votre curseur (thème et taille), il faut leur autoriser l'accès à `~/.icons`.
C'est dans `~/.icons` que la configuration du curseur (taille et apparence) est définie.

Exemple avec Dino :

```
flatpak --user override im.dino.Dino --filesystem=${HOME}/.icons/:ro
```

Une autre solution, possiblement meilleure, consiste à créer un lien symbolique de `~/.local/share/icons` vers `~/.icons` :

```
ls -s ~/.icons ~/.local/share/icons
```

Il semble en effet que la plupart des flatpak ont déjà accès à ce répertoire.
