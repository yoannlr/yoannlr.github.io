---
title: "Curseurs et Flatpak"
date: 2025-03-19T13:48:44+01:00
---
# Configurer Flatpak pour utiliser le curseur du bureau

![C'est plus joli quand ça respecte le thème !](/img/flatpak-curseur.png)

Pour que les applications installées en flatpak respectent la configuration de votre curseur (thème et taille), il faut leur autoriser l'accès à `~/.icons`.

Exemple avec Dino :

```
flatpak --user override im.dino.Dino --filesystem=${HOME}/.icons/:ro
```
