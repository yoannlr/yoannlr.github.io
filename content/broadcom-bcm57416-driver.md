---
title: Résoudre le problème de compatibilité entre Linux et les cartes Broadcom BCM57416
date: 2024-11-30
draft: true
keywords:
  - linux
  - kernel
  - noyau
  - bug
  - firmware
  - broadcom bcm57416
  - bnxt_en bnxt_re
  - timeout
  - fw_stall
---
# Résoudre le problème de compatibilité entre Linux et les cartes Broadcom BCM57416

Les versions récentes du noyau Linux (apparemment 6.5+) ne reconnaissent pas correctement ces cartes réseau qu'on peut acheter par exemple chez HPE.
En Linux 6.2, aucun souci.

Messages d'erreur type dans dmesg :

```
todo
```

À cause de ce timeout, le service `systemd-udev-settle` échoue, et le service networking aussi, donc votre serveur se retrouve sans réseau.

La raison : deux pilotes s'associent aux interfaces réseau de ces cartes : dans un premier temps, `bnxt_en` qui fonctionne correctement, puis `bnxt_re` qui ne fonctionne pas correctement et timeout.
`bnxt_re` permet à priori de faire du ["RDMA over Converged Ethernet"](https://en.wikipedia.org/wiki/RDMA_over_Converged_Ethernet), ce dont on n'a pas besoin dans la plupart des cas.

Le fix consiste à empêcher le chargement de `bnxt_re`, pour cela : 

```
sudo echo "blacklist bnxt_re" > /etc/modprobe.d/blacklist_bnxt_re.conf
```

Pour plus d'infos : [https://utcc.utoronto.ca/~cks/space/blog/linux/BroadcomNetworkDriverAndRDMA](https://utcc.utoronto.ca/~cks/space/blog/linux/BroadcomNetworkDriverAndRDMA).
