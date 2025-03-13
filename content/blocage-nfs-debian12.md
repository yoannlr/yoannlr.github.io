---
title: "Blocage NFS sous Debian 12"
date: 2025-03-13T16:49:08+01:00
---
# Résoudre les blocages du serveur NFS sous Debian 12 (nfsd stuck in D state)

Si vous utilisez `nfs-kernel-server` avec le noyau Linux par défaut sous Debian 12 (6.1.94 au moment de l'écriture de cet article), vous avez peut-être constaté des blocages du serveur.
En cas de forte charge, il se peut que tous les threads `nfsd` passent en état `D` (uninterruptible sleep) et n'en sortent jamais.
Lorsque cela se produit, vous ne pouvez rien faire : tenter de tous les tuer avec `kill -9` ou d'arrêter les services nfs (`nfs-server`, `rpcbind` etc) ne rédoudra rien.

La seule chose à faire est alors de redémarrer l'OS... ce qui rend indisponible quelques minutes d'autres services parfaitement fonctionnels sur le serveur (Samba par exemple).
Le bug peut arriver assez fréquemment, jusqu'à plusieurs fois par semaine si le serveur est beaucoup sollicité.

Dans un premier temps, on peut penser qu'il n'y a pas assez de threads nfsd pour répondre à la demande.
Il est possible d'augmenter leur nombre : 

- à la volée avec la commande `rpc.nfsd nproc` (où nproc est le nouveau nombre de threads nfsd)
- dans `/etc/nfs.conf` (qui remplace `/etc/default/nfs-kernel-server`, désormais ignoré), section `[threads]`, pour rendre le changement persistent

Hélas, si ce changement peut retarder un peu l'échéance à laquelle le serveur freeze, il ne résoud pas le problème.

La consultation des messages noyau (`dmesg -T`) révèle le bug suivant (message répété pour chaque thread nfsd) :

```
Feb 05 14:02:15 xxx-fs kernel: INFO: task nfsd:1271 blocked for more than 120 seconds.
Feb 05 14:02:15 xxx-fs kernel:       Not tainted 6.1.0-22-amd64 #1 Debian 6.1.94-1
Feb 05 14:02:15 xxx-fs kernel: "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
Feb 05 14:02:15 xxx-fs kernel: task:nfsd            state:D stack:0     pid:1271  ppid:2      flags:0x00004000
Feb 05 14:02:15 xxx-fs kernel: Call Trace:
Feb 05 14:02:15 xxx-fs kernel:  <TASK>
Feb 05 14:02:15 xxx-fs kernel:  __schedule+0x34d/0x9e0
Feb 05 14:02:15 xxx-fs kernel:  schedule+0x5a/0xd0
Feb 05 14:02:15 xxx-fs kernel:  schedule_timeout+0x118/0x150
Feb 05 14:02:15 xxx-fs kernel:  wait_for_completion+0x86/0x160
Feb 05 14:02:15 xxx-fs kernel:  __flush_workqueue+0x152/0x420
Feb 05 14:02:15 xxx-fs kernel:  nfsd4_destroy_session+0x1b6/0x250 [nfsd]
Feb 05 14:02:15 xxx-fs kernel:  nfsd4_proc_compound+0x352/0x660 [nfsd]
Feb 05 14:02:15 xxx-fs kernel:  nfsd_dispatch+0x19e/0x2b0 [nfsd]
Feb 05 14:02:15 xxx-fs kernel:  svc_process_common+0x286/0x5e0 [sunrpc]
Feb 05 14:02:15 xxx-fs kernel:  ? svc_recv+0x48e/0x810 [sunrpc]
Feb 05 14:02:15 xxx-fs kernel:  ? nfsd_svc+0x360/0x360 [nfsd]
Feb 05 14:02:15 xxx-fs kernel:  ? nfsd_shutdown_threads+0x90/0x90 [nfsd]
Feb 05 14:02:15 xxx-fs kernel:  svc_process+0xad/0x100 [sunrpc]
Feb 05 14:02:15 xxx-fs kernel:  nfsd+0x99/0x140 [nfsd]
Feb 05 14:02:15 xxx-fs kernel:  kthread+0xd7/0x100
Feb 05 14:02:15 xxx-fs kernel:  ? kthread_complete_and_exit+0x20/0x20
Feb 05 14:02:15 xxx-fs kernel:  ret_from_fork+0x1f/0x30
Feb 05 14:02:15 xxx-fs kernel:  </TASK>
```

En recherchant longuement sur internet, on finit par tomber sur [ce thread](https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=1071562) du traqueur de bug de Debian et en particulier sur [ce message](https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=1071562;msg=53).

La solution proposée est d'installer une version du noyau qui résoud ce bug.
Cette version n'est pas disponible dans les dépots principaux de Debian 12, mais elle l'est dans les [backports](https://backports.debian.org/).
Une des versions du noyau qui n'est pas impactée par le bug est la 6.11.5.

Il est possible de l'installer en suivant ces étapes :

1. Ajouter les backports aux dépots APT : `echo deb http://deb.debian.org/debian bookworm-backports main | sudo tee -a /etc/apt/sources.list`
2. Mettre à jour le cache APT : `sudo apt update`
3. Installer la version du noyau ci-dessus : `sudo apt install linux-image-6.11.5+bpo-amd64 linux-headers-6.11.5+bpo-amd64`
4. Redémarrer le serveur

L'opération peut s'effectuer rapidement et n'occasionner que quelques minutes d'indisponibilité.
Quelques minutes une fois c'est toujours mieux que quelques minutes plusieurs fois par semaine !

Après plusieurs semaines avec ce fix, le problème de freeze NFS ne se présente plus.
