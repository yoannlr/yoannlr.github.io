---
title: "Comprendre l'audio sous Linux"
date: 2024-12-05
draft: false
---
# Comprendre l'audio sous Linux

Cet article est aussi disponible en vidéo 👇

{{< youtube videoid="lTv2jJDcPns" title="PulseAudio, ALSA, Jack, Pipewire... comprendre l'audio sous Linux" >}}

## Problématique du son

Gérer du son pour un ordinateur, c'est simplement acheminer des données binaires aux bons endroits : d'une application à la carte son, ou dans l'autre sens.
La carte son, c'est le périphérique capable de convertir les données binaires en audio et vice-versa.

Pour que le système soit capable de parler à la carte son dans une langue qu'elle comprend, il lui faut un driver.
Ce driver, sous Linux, c'est ALSA : Advanced Linux Sound Architecture.

## Multiplexage

ALSA peut être utilisé tout seul pour permettre à une application d'émettre ou de recevoir de l'audio.
Par exemple, VLC est tout à fait capable de s'adresser à ALSA.

En revanche, avec ALSA la carte son ne peut être utilisée que par une application à la fois.
Si VLC utilise la carte son et que Firefox en a besoin aussi, Firefox devra attendre que VLC la libère.

En d'autres termes, il n'y a pas de multiplexage.
C'est là qu'interviennent les serveurs de son : PulseAudio, JACK et PipeWire.

Le principe est simple : le serveur de son est **le seul** programme qui parle à la carte son par l'intermédiaire de ALSA.
Les autres applications parlent au serveur, qui combine tous les flux audio en un seul.
C'est ce mécanisme qui vous permet d'écouter VLC et Firefox en même temps.

### PulseAudio

C'était le serveur de son principal pour le grand public jusqu'à récemment.
Toutes les applications sont capables de communiquer avec lui, c'était le standard.
Depuis l'arrivée de PipeWire et son adoption, il tombe peu à peu en désuetude.

### JACK

Un serveur de son dédié aux musiciens !
JACK fonctionne en temps réel et permet de faire du routage audio, difficilement réalisable avec PulseAudio.

### PipeWire

PipeWire combine le meilleur des deux mondes d'une façon élégante.
Il offre les fonctionnalités temps réel de JACK, le routage audio et le support des applications programmées pour Pulse en se faisant passer pour ce dernier.

## Fonctionnement de PipeWire

La simplicité de PipeWire réside dans le fait que c'est un programme très simple.
Son unique objectif est de router l'audio (des données binaires) d'un noeud du graphe au suivant.
Un noeud peut être une source (micro ou application) ou un puits (haut-parleur ou application).

PipeWire ne fait rien d'autre, il ne se charge même pas d'ajouter les nouvelles applications ou nouveaux périphériques audio au graphe.
Ces fonctions sont déléguées à deux daemons : `pipewire-pulse` pour l'ajout des clients Pulse et `wireplumber` pour l'ajout des périphériques audio.

Pour que PipeWire supporte les clients JACK, une petite manipulation est nécessaire.
Il faut lancer ces applications en changeant les chemins de leurs bibliothèques afin qu'elles se connectent au graphe PipeWire plutôt qu'au graphe JACK.
On pourrait le faire à la main, avec la variable d'environnement `LD_LIBRARY_PATH`, mais PipeWire fournit le script `pw-jack` (dans le paquet `pipewire-audio-client-libraries` sous Debian).
Pour lancer Qtractor sous PipeWire, on exécuterait par exemple `pw-jack qtractor`.

L'utilitaire `pw-link` permet de manipuler le graphe PipeWire.
qpwgraph propose la même chose en graphique.

Pour plus d'infos, je recommande la lecture de [cet excellent article de Bootlin](https://bootlin.com/blog/an-introduction-to-pipewire/) sur le sujet.

### Bluetooth et PipeWire

Pour permettre à PipeWire de gérer les équipements Bluetooth, le paquet `libspa-0.2-bluetooth` (Debian) est requis.
Une fois ce paquet installé, votre environnement de bureau devrait vous permettre de connecter vos écouteurs bluetooth à l'audio de votre système.
