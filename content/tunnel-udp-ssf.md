---
title: "Créer un tunnel UDP avec SSF (Secure Socket Funneling)"
date: 2025-07-04T11:31:19+02:00
draft: false
keywords:
  - ssf
  - ssh
  - tunnel
  - udp
  - nat
  - exposer
description: À l'instar de SSH pour les tunnels TCP, il est possible d'utiliser SSF pour exposer le traffic UDP d'un serveur derrière un NAT.
---
# Créer un tunnel UDP avec SSF (Secure Socket Funneling) pour exposer un service derrière un NAT

Dans [cet article précédent](/tunnel-ssh-serveur-nat/), je vous expliquais comment créer un tunnel SSH pour exposer les services d'une machine de votre LAN, publiquement sur Internet en passant par un VPS.
Cette méthode présente une limite principale : seuls les tunnels TCP fonctionnent.

Des hacks[^1] basés sur `socat` ou `netcat` existent pour embarquer des datagrammes UDP dans des trames TCP qui transitent dans le tunnel, mais les protocoles sont fondamentalement différents donc rien ne garantit la fiabilité des tunnels.
Notamment, TCP s'assure que les données sont acheminées alors qu'UDP peut renvoyer des données.
On pourrait donc recevoir plusieurs fois les mêmes données.

Il nous faut donc utiliser un autre outil, comme [SSF (Secure Socket Funneling)](https://securesocketfunneling.github.io/ssf/#home).

SSF peut être exécuté comme serveur sur votre VPS.
Le serveur attend les demandes d'ouverture de tunnels de la part des clients.
SSF supporte TCP et UDP, mais induit davantage de latence en comparaison avec SSH (140 ms contre 40 ms pour un tunnel TCP dans la même configuration).

## Configuration de SSF

1. Sur le client (machine du LAN) et le serveur (VPS), télécharger ssf, l'extraire dans `/opt/ssf`

```
wget https://github.com/securesocketfunneling/ssf/releases/download/3.0.0/ssf-linux-x86_64-3.0.0.zip && unzip ssf*.zip /opt/ssf && cd /opt/ssf
```

2. Des deux côtés, générer les paramètres Diffie-Hellman

```
rm -rf /opt/ssf/certs/*
mkdir /opt/ssf/certs/trusted
cd /opt/ssf/certs
openssl dhparam -outform PEM -out dh4096.pem 4096 # peut prendre plusieurs minutes
```

3. Sur le client uniquement, générer les certificats d'une autorité de certification et les copier sur le serveur

```
openssl req -x509 -nodes -newkey rsa:4096 -keyout ca.key -out ca.crt -days 3650
scp ca.* myuser@vps:/opt/ssf/certs/
```

4. Des deux côtés, créer le fichier `extfile.txt`, qui permettra la génération de certificats intermédiaires si nécessaires

```
[ v3_req_p ]
basicConstraints = CA:FALSE
keyUsage = nonRepudiation, digitalSignature, keyEncipherment

[ v3_ca_p ]
basicConstraints = CA:TRUE
keyUsage = nonRepudiation, digitalSignature, keyEncipherment, keyCertSign
```

5. Des deux côtés, générer une clé privée et un certificat

```
openssl req -newkey rsa:4096 -nodes -keyout private.key -out certificate.csr
openssl x509 -extfile extfile.txt -extensions v3_req_p -req -sha1 -days 3650 -CA ca.crt -CAkey ca.key -CAcreateserial -in certificate.csr -out certificate.crt
cat ca.crt >> certificate.crt
```

6. Ajouter une passphrase à chaque clé privée

```
openssl rsa -in private.key -out private.key -aes256 -passout pass:mypassword
```

7. Et déplacer `ca.crt` dans `trusted`

```
mv /opt/ssf/certs/ca.crt /opt/ssf/certs/trusted/ca.crt
```

8. Créer le fichier de configuration de SSF `/opt/ssf/config.json`. La configuration est identique des deux côtés.

```json
{
  "ssf": {
    "arguments": "",
    "circuit": [],
    "tls" : {
      "ca_cert_path": "/opt/ssf/certs/trusted/ca.crt",
      "cert_path": "/opt/ssf/certs/certificate.crt",
      "key_path": "/opt/ssf/certs/private.key",
      "key_password": "mypassword",
      "dh_path": "/opt/ssf/certs/dh4096.pem",
      "cipher_alg": "DHE-RSA-AES256-GCM-SHA384"
    },
    "services": {
      "datagram_forwarder": { "enable": true },
      "datagram_listener": {
        "enable": true,
        "gateway_ports": true
      }
    }
  }
}
```

Pour qu'une connexion puisse être établie entre client et serveur, il faut

- que les clés privées soient sécurisées par mot de passe
- que l'autorité de certification soit connue des deux côtés.
  Les certificats des autorités sont à placer dans `trusted`.
  C'est pour cela qu'on a copié les fichiers `ca.*` du client sur le serveur.

## Lancement du serveur SSF

```
/opt/ssf/ssfd -c /opt/ssf/config.json -g
```

L'option `-g` active les gateway ports : pouvoir écouter sur 0.0.0.0, comme avec SSH.
Le paramètre configuré dans le fichier de configuration semble ne pas avoir d'effet, il faut rajouter l'otion à la ligne de commande.

## Ouverture du tunnel depuis le client

```
/opt/ssf/ssf -c /opt/ssf/config.json -V 0.0.0.0:1234:127.0.0.1:1234
```

Cette commande ouvre, si possible, le socket UDP `0.0.0.0:1234` sur le VPS et transmet les paquets reçus à notre client, sur le socket `127.0.0.1:1234`.

SSF est robuste aux pannes. Si un incident réseau survient, le tunnel sera automatiquement rouvert au rétablissement.

[^1]: [https://superuser.com/questions/53103/udp-traffic-through-ssh-tunnel](https://superuser.com/questions/53103/udp-traffic-through-ssh-tunnel)
