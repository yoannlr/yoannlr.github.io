---
title: Récupérez la clé Windows d'un ordinateur
date: 2021-08-20
---
# Récupérez la clé Windows d'un ordinateur

Sous Windows, en cmd admin :

```
wmic path softwarelicensingservice get OA3xOriginalProductKey
```

Sous Linux en root :

```
sudo grep -Eo '([A-Za-z0-9]{5}-){4}[A-Za-z0-9]{5}' /sys/firmware/acpi/tables/MSDM
```
