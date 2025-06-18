---
title: Trouvez l'équipement réseau et le port auxquels vous êtes connecté
date: 2024-11-28
description: Utilisez l'utilitaire tcpdump pour capturer les informations que vous envoie le switch
keywords:
  - reseau
  - tcpdump
  - cdp
  - lldp
  - switch
  - port
  - vlan
---
# Trouvez l'équipement réseau et le port auxquels vous êtes connecté

Le programme [Link Discovery for Windows](https://github.com/chall32/LDWin) remonte les infos du lien auquel on est connecté (nom du switch, port, numéro de vlan...).
Il utilise tcpdump pour capturer un paquet LLDP ou CDP émis par le switch toutes les 60 secondes max.

Sous Linux, la commande suivante fait la même chose (à exécuter en root) :

```
tcpdump -i eno1 '(ether[12:2]=0x88cc or ether[20:2]=0x2000)' -c 1 -s 1500 -v
```

(`eno1` à remplacer par l'interface réseau concernée)

Exemple de sortie :

```
root@localhost:~# tcpdump -i eno1 '(ether[12:2]=0x88cc or ether[20:2]=0x2000)' -c 1 -s 1500 -v
tcpdump: listening on eno1, link-type EN10MB (Ethernet), snapshot length 1500 bytes
09:26:57.257496 CDPv2, ttl: 180s, checksum: 0x9274 (unverified), length 447
	Device-ID (0x01), value length: 32 bytes: 'c9300x.xxxxxx.net'
	Version String (0x05), value length: 250 bytes: 
	  Cisco IOS Software [Amsterdam], Catalyst L3 Switch Software (CAT9K_IOSXE), Version xxx, RELEASE SOFTWARE xxx
	  Technical Support: http://www.cisco.com/techsupport
	  Copyright (c) 1986-2022 by Cisco Systems, Inc.
	  Compiled xxx by xxx
	Platform (0x06), value length: 17 bytes: 'cisco C9300-xxx'
	Address (0x02), value length: 13 bytes: IPv4 (1) c9300x.xxxxxx.net
	Port-ID (0x03), value length: 24 bytes: 'TwoGigabitEthernet1/0/25'
	Capability (0x04), value length: 4 bytes: (0x00000028): L2 Switch, IGMP snooping
	VTP Management Domain (0x09), value length: 6 bytes: 'xxxxxx'
	Native VLAN ID (0x0a), value length: 2 bytes: 70
	Duplex (0x0b), value length: 1 byte: full
	Management Addresses (0x16), value length: 13 bytes: IPv4 (1) c9300x.xxxxxx.net
	unknown field type (0x1009), value length: 37 bytes: 
	  0x0000:  xxxx xxxx xxxx xxxx xxxx xxxx xxxx xxxx
	  0x0010:  xxxx xxxx xxxx xxxx xxxx xxxx xxxx xxxx
	  0x0020:  xxxx xxxx xx
1 packet captured
1 packet received by filter
0 packets dropped by kernel
```
