---
title: installit, des scripts pour faciliter l'installation de programmes Debian
date: 2024-11-29
---
# installit, des scripts pour faciliter l'installation de programmes Debian

{{< repo url="https://github.com/yoannlr/installit" name="yoannlr/installit : Easy installation of some Debian programs" type="github" >}}

Se chargent d'ajouter automatiquement les dépots à APT, et de certaines configurations si nécessaire.

Avec curl :

```
curl https://raw.githubusercontent.com/yoannlr/installit/main/<script>.sh | sh
```

Avec wget :

```
wget -q https://raw.githubusercontent.com/yoannlr/installit/main/<script>.sh -O - | sh
```

