---
title: "Utiliser SSH pour exposer un serveur derrière un NAT"
date: 2025-06-05T00:00:00+02:00
draft: false
description: SSH permet d'utiliser un VPS comme intermédiaire pour exposer une machine de votre LAN sur Internet
keywords:
  - tunnel
  - ssh
  - cloudflare tunnel
  - tcp
  - udp
  - autossh
  - robuste
  - resilient
  - automatique
  - nat
  - forwarding
  - transfert
  - remote
---
# Utiliser SSH pour exposer un serveur derrière un NAT

À l'aide d'un petit VPS et de rien de plus que SSH, il est possible d'exposer une machine derrière un NAT ou dans un LAN sans devoir configurer un mapping de port (aka "ouvrir les ports de la box").
La manip' consiste à initier un tunnel SSH depuis la machine que l'on souhaite exposer sur internet, vers le VPS qui dispose d'une adresse IP publique.
Ensuite, sur le VPS, il suffit d'ouvrir un socket et de rediriger le traffic dans le tunnel.
Excellente nouvelle : openssh fait tout cela de manière transparente, en une commande.

Depuis la machine que l'on souhaite exposer :

```
ssh -R 0.0.0.0:1234:localhost:1234 tunneluser@vps
```

Cette commande ouvre un tunnel de notre machine locale port 1234 vers un socket créé automatiquement sur le VPS port 1234, à l'écoute de toutes les adresses.

{{< notice >}}
**Important !** Pour pouvoir écouter sur toutes les adresses (dont 0.0.0.0), il faut d'abord configurer l'option `GatewayPorts` du daemon SSH du VPS :

`/etc/ssh/sshd_config` :

```
GatewayPorts clientspecified
```

Puis `systemctl restart ssh`
{{< /notice >}}

Pour que ssh ne lance pas de shell et se contente de gérer le tunnel, on peut ajouter l'option `-N` à la commande.
Si on souhaite exécuter le tunnel en arrière plan, on peut aussi rajouter l'option `-f`.

```
ssh -Nf -R 0.0.0.0:1234:localhost:1234 tunneluser@vps
```

L'avantage principal, selon moi, de cette manipulation, est de louer un petit VPS comme point d'entrée vers un gros serveur qu'on auto-héberge.
On peut utiliser n'importe quel protocole basé sur TCP.

### Un exemple

Un exemple pour rendre publiquement accessible un serveur Minecraft (port 25565 par défaut) hébergé sur son propre LAN :

```
ssh -Nf -R 0.0.0.0:25565:localhost:25565 tunneluser@vps
```

Les clients indiqueront alors qu'il souhaitent se connecter au VPS, mais le VPS ne servira que d'intermédiaire entre eux et la machine du LAN.

J'ai testé cette solution et la latence est tout à fait acceptable : 40ms avec une box fibre optique et un VPS loué chez un hébergeur bien connu.

## Sécurisation côté VPS

Pour limiter les risques, je vous recommande de créer un utilisateur dédié au tunnel, avec `/bin/true` comme shell :

```
useradd -m -s /bin/true tunneluser
```

Malgré cette configuration, notre `tunneluser` peut toujours spécifier une commande à lancer (`ssh tunneluser@vps ls /` par exemple).

On va donc configurer le daemon SSH pour vraiment restreindre `tunneluser`.

Édition de `/etc/ssh/sshd_config` :

```
Match User tunneluser
	X11Forwarding no
	AllowAgentForwarding no
	PermitTTY no
	AllowTcpForwarding yes
```

Puis `systemctl restart ssh`

## Clé SSH

La nécessité de saisir un mot de passe à la connexion SSH empêche d'ouvrir le tunnel automatiquement (avec un service par exemple).
Pour résoudre ce problème, on va générer une clé SSH pour notre `tunneluser`.

```
ssh-keygen -f tunneluser_rsa -t rsa -b 4096
```

Puis copier la clé sur son compte, sur le VPS (d'où la nécessité de lui avoir créé un homedir).

```
ssh-copy-id -i tunneluser_rsa.pub tunneluser@vps
```

## Résilience aux pannes

Plusieurs options SSH sont intéressantes pour détecter les pannes réseau et rouvrir le tunnel dès le rétablissement.

Dans `man ssh_config` (options côté client) :

- l'option `ServerAliveInterval` permet d'envoyer des paquets pour tester la connexion à intervalle régulier (défini en secondes)

- l'option `ServerAliveCountMax` définit le nombre de paquets sans réponse toléré avant de considérer que la connexion a timeout et de rendre la main

- l'option `ExitOnForwardFailure` (définir à yes) rend la main si le tunnel ne s'est pas ouvert correctement

Ces options nous donnent la commande suivante, plus robuste, que l'on pourrait exéctuer dans une boucle pour toujours rouvrir le tunnel :

```sh
ssh -N -o ServerAliveInterval=10 -o ServerAliveCountMax=3 -o ExitOnForwardFailure=yes -R 0.0.0.0:1234:localhost:1234 tunneluser@vps
```

Avec ces options, le client SSH rendra la main au bout de 30 secondes d'incident réseau (3 × 10 secondes) ou si la connexion SSH s'est bien passée mais pas l'ouverture du tunnel.

On peut aussi s'intéresser aux options côté serveur (`man sshd_config`) :

- les options `ClientAliveInterval` et `ClientAliveCountMax`, mécanisme équivalent côté serveur.
  On peut les définir aux mêmes valeurs que côté client.

- l'option `StreamLocalBindUnlink` (définir à yes) s'assure que les sockets "zombies" ouverts par des tunnels précédents sont nettoyés avant de créer des nouveaux sockets.
  Ça permet d'éviter des erreurs "cannot listen on port 1234" car un socket existe toujours !

  Si vous n'aviez pas activé cette option et que des sockets "zombies" vous bloquent, utilisez `ss` pour les fermer : `ss --kill state close-wait src :1234`

Ces trois dernières options sont à définir dans `/etc/ssh/sshd_config`.

Côté client, on peut imaginer un script similaire à celui-ci pour un tunnel résilient aux incidents réseau :

```sh
#!/bin/sh
while true; do
    echo "opening tunnel"
    ssh -N -o ServerAliveInterval=10 -o ServerAliveCountMax=3 -o ExitOnForwardFailure=yes -R 0.0.0.0:1234:localhost:1234 tunneluser@vps
    echo "tunnel closed, trying again in 20 seconds"
done
```

## Et pour le traffic UDP ?

Cette méthode est limitée à l'ouverture de tunnels TCP.
Des hacks basés sur `socat` ou `netcat` existent pour faire transiter les datagrammes UDP dans des paquets TCP, mais la nature totalement différente des protocoles n'offre aucune garantie quand à la fiabilité de ces méthodes.

L'outil [ssf](https://securesocketfunneling.github.io/ssf/#home) répond au besoin, avec une latence plus importante (140 ms dans le même contexte).
Un article est à venir au sujet de sa configuration et de son utilisation.
