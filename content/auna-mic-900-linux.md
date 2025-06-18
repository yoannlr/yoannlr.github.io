---
title: "Auna Mic 900 sous Linux ?"
date: 2025-02-16T14:55:54+01:00
draft: false
description: Configurer le chargement du bon module noyau pour rendre ce microphone plug and play
keywords:
  - linux
  - kernel
  - noyau
  - usb
  - driver
  - micro
  - casque
  - son
  - snd-usb-audio
  - sysfs
  - hid
  - auna mic 900
  - udev
  - modprobe
---

# Comment faire fonctionner le microphone Auna Mic 900 sous Linux

***... ou tout autre périphérique de son USB non reconnu  !***

Ce microphone USB, supposément plug-and-play n'est pas reconnu nativement sous Linux.
J'ai essayé sous Debian, sous Arch et sous Fedora : même résultat.
Même sous Windows, rien n'est détecté !

Il est pourtant détecté par le noyau (`sudo dmesg -Tw` pour voir les messages du noyau en direct) :

```
[Sun Feb 16 12:23:24 2025] usb 2-1.1: new full-speed USB device number 14 using ehci-pci
[Sun Feb 16 12:23:24 2025] usb 2-1.1: New USB device found, idVendor=0d8c, idProduct=0134, bcdDevice= 1.00
[Sun Feb 16 12:23:24 2025] usb 2-1.1: New USB device strings: Mfr=1, Product=2, SerialNumber=0
[Sun Feb 16 12:23:24 2025] usb 2-1.1: Product: USB PnP Audio Device
[Sun Feb 16 12:23:24 2025] usb 2-1.1: Manufacturer: C-Media Electronics Inc.
[Sun Feb 16 12:23:24 2025] hid-generic 0003:0D8C:0134.000C: No inputs registered, leaving
[Sun Feb 16 12:23:24 2025] hid-generic 0003:0D8C:0134.000C: hidraw5: USB HID v1.11 Device [C-Media Electronics Inc. USB PnP Audio Device] on usb-0000:00:1d.0-1.1/input2
```

Cependant, si on compare cette sortie à celle d'un micro fonctionnel (exemple avec un Blue Snowball), on constate une différence :

```
[Sun Feb 16 14:41:05 2025] usb 2-1.2.1: new full-speed USB device number 7 using ehci-pci
[Sun Feb 16 14:41:06 2025] usb 2-1.2.1: New USB device found, idVendor=0d8c, idProduct=0005, bcdDevice= 1.00
[Sun Feb 16 14:41:06 2025] usb 2-1.2.1: New USB device strings: Mfr=1, Product=2, SerialNumber=3
[Sun Feb 16 14:41:06 2025] usb 2-1.2.1: Product: Blue Snowball 
[Sun Feb 16 14:41:06 2025] usb 2-1.2.1: Manufacturer: BLUE MICROPHONE
[Sun Feb 16 14:41:06 2025] usb 2-1.2.1: SerialNumber: XXX
[Sun Feb 16 14:41:06 2025] hid-generic 0003:0D8C:0005.0006: No inputs registered, leaving
[Sun Feb 16 14:41:06 2025] hid-generic 0003:0D8C:0005.0006: hidraw5: USB HID v1.11 Device [BLUE MICROPHONE Blue Snowball ] on usb-0000:00:1d.0-1.2.1/input2
[Sun Feb 16 14:41:06 2025] usbcore: registered new interface driver snd-usb-audio
```

Voici ce qu'il se passe :

- Lorsqu'un de ces micros est branché, il est détecté comme appareil HID (Human Interface Device) par Linux.
  Concrètement, cela signifie que Linux le voit comme un appareil avec lequel un humain va interagir, constitué de boutons physiques (même si aucun de ces micros n'en est équipé), donc il charge le module noyau `usbhid` pour recevoir les inputs de ces boutons.
- Dans le cas du Snowball, il est ensuite détecté comme un équipement de son branché en USB, donc Linux charge le module `snd-usb-audio` pour s'en servir à cette fin.
  Ça n'est pas le cas pour le micro Auna.

## Ajouter le micro à la volée grâce à sysfs

On peut indiquer à `snd-usb-audio` qu'il est capable de supporter le micro Auna.
Pour cela, il faut lui indiquer qu'il supporte un nouveau produit identifié par un vendor id et un product id.

1. S'il n'y pas d'autre équipement audio USB connecté à votre ordinateur, commencez par charger le module `snd-usb-audio` :

```
sudo modprobe snd-usb-audio
```

2. Indiquez lui qu'il supporte le micro Auna :

```
echo 0d8c 0134 | sudo tee /sys/bus/usb/drivers/snd-usb-audio/new_id
```

## Persistance au reboot

Pour que le support du micro persiste au reboot, créez les fichiers suivants :

`/etc/udev/rules.d/aunamic.rules` :

```
# load snd-usb-audio when this device is plugged in
# (also needs to register new_id for this device, see /etc/modprobe.d/aunamic.conf)
ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="0d8c", ATTR{idProduct}=="0134", RUN+="/sbin/modprobe -qba snd-usb-audio"
```

`/etc/modprobe.d/aunamic.conf` :

```
# make snd-usb-audio automatically bind to auna mic 900
install snd-usb-audio /sbin/modprobe --ignore-install snd-usb-audio $CMDLINE_OPTS; /bin/echo "0d8c 0134" > /sys/bus/usb/drivers/snd-usb-audio/new_id
```

Le fichier de règles udev indique que, si le périphérique usb d'id vendeur `0d8c` et d'id produit `0134` est branché, Linux doit charger le module noyau `snd-usb-audio`.

Le fichier de configuration modprobe indique qu'au chargement du module, la commande echo précédente doit être exécutée.

Grâce à ces configurations, nous avons rendu ce micro plug and play !

## Pour aller plus loin

En exécutant la commande `usb-devices` (en root, sous Debian), on peut voir quel module noyau est associé à quel appareil (ou subsystem) USB.
C'est l'équivalent de `lspci -k` pour les cartes PCI.

```
T:  Bus=02 Lev=02 Prnt=02 Port=00 Cnt=01 Dev#=  8 Spd=12  MxCh= 0
D:  Ver= 1.10 Cls=00(>ifc ) Sub=00 Prot=00 MxPS=16 #Cfgs=  1
P:  Vendor=0d8c ProdID=0134 Rev=01.00
S:  Manufacturer=C-Media Electronics Inc.
S:  Product=USB PnP Audio Device
C:  #Ifs= 3 Cfg#= 1 Atr=a0 MxPwr=100mA
I:  If#= 0 Alt= 0 #EPs= 0 Cls=01(audio) Sub=21 Prot=00 Driver=snd-usb-audio
I:  If#= 1 Alt= 1 #EPs= 1 Cls=01(audio) Sub=02 Prot=00 Driver=snd-usb-audio
E:  Ad=82(I) Atr=05(Isoc) MxPS= 100 Ivl=1ms
I:  If#= 2 Alt= 0 #EPs= 1 Cls=03(HID  ) Sub=00 Prot=00 Driver=usbhid
E:  Ad=87(I) Atr=03(Int.) MxPS=  16 Ivl=1ms
```

En exécutant la commande `modinfo snd-usb-audio` (en root, sous Debian), on peut confirmer ou infirmer le support d'un appareil par un module

```
filename:       /lib/modules/6.1.0-18-amd64/kernel/sound/usb/snd-usb-audio.ko
license:        GPL
description:    USB Audio
author:         Takashi Iwai <tiwai@suse.de>
alias:          usb:v*p*d*dc*dsc*dp*ic01isc01ip*in*
alias:          usb:vFFADpA001d*dc*dsc*dp*icFFisc*ip*in*
alias:          usb:v2B53p0031d*dc*dsc*dp*ic*isc*ip*in*
alias:          usb:v2B53p0024d*dc*dsc*dp*ic*isc*ip*in*
alias:          usb:v2B53p0023d*dc*dsc*dp*ic*isc*ip*in*
alias:          usb:v1395p0300d*dc*dsc*dp*ic*isc*ip*in*
...
```

Si ce micro était supporté, on aurait normalement une ligne d'alias ou on retrouverait `usb:v0d8cp0134`.

Encore un bon exemple de la facilité avec laquelle on peut interagir avec Linux et de sa flexibilité !
