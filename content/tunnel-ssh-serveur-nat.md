---
title: "Utiliser SSH pour exposer un serveur derrière un NAT"
date: 2025-06-05T00:00:00+02:00
draft: false
description: SSH permet d'utiliser un VPS comme intermédiaire pour exposer une machine de votre LAN sur Internet
keywords:
  - tunnel
  - ssh
  - cloudflare tunnel
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

On peut imaginer un script similaire à celui-ci pour rouvrir le tunnel en cas d'incident réseau.

```sh
#!/bin/sh
while true
do
    if nc -z vps ssh; then
        echo "opening tunnel"
        ssh -N -R 0.0.0.0:1234:localhost:1234 tunneluser@vps
        echo "tunnel closed"
    else
        echo "vps currently unreachable, trying again in 20 seconds"
        sleep 20
    fi
done
```
