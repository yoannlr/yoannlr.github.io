---
title: "Kdenlive"
date: 2025-08-03T18:47:00+02:00
draft: false
keywords:
  - cheatsheet
  - kdenlive
description: Cheatsheet Kdenlive
icon: /img/kdenlive.webp
---
# Cheatsheet Kdenlive

Shift + drag un clip permet de le redimensionner lui seul au sein d'un groupe

Si on sélectionne une piste, on peut appliquer des effets pour toute la piste

Effet "color overlay" ≃ recoloriser l'image sans trop perdre les couleurs, comme un calque transparent de couleur par dessus

## Décaler les guides en même temps que les clips

- Clic droit sur les graduations de la timeline, décocher "Guides locked"
- Passer en mode "Spacer tool"
- Cliquer sur un clip et commencer le déplacement

[Référence](https://docs.kdenlive.org/en/cutting_and_assembling/guides.html#move-guides-with-spacer-tool)

## Appliquer un effet sur une région

Pile de 3 effets (dans l'ordre) :

- Effet Alpha Shapes (Mask), Rotoscoping (Mask), ou tout autre effet de création d'un masque
- L'effet à appliquer sur la région (flou par exemple)
- Effet Mask Apply

Pour définir plusieurs régions sur un même clip, rajouter cet ensemble de 3 effets par dessus les 3 précédents.
Pour du rotoscoping, il faut mettre l'opération alpha sur "Minimum" sur le premier effet, puis sur "Write on clear" sur les suivants.
