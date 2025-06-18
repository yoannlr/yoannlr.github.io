---
title: Résoudre le problème de compatibilité entre Linux et les cartes Broadcom BCM57416
date: 2024-12-03
draft: false
description: Investigation et résolution d'un problème de modules noyaux pour cette carte réseau
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
Nov 29 13:04:29 pve2-xxx kernel: bnxt_en 0000:12:00.0 (unnamed net_device) (uninitialized): Device requests max timeout of 100 seconds, may trigger hung task watchdog
Nov 29 13:04:29 pve2-xxx kernel: bnxt_en 0000:12:00.0 eth0: Broadcom BCM57416 NetXtreme-E 10GBase-T Ethernet found at mem de610000, node addr aa:bb:cc:dd:ee:11
Nov 29 13:04:29 pve2-xxx kernel: bnxt_en 0000:12:00.0: 63.008 Gb/s available PCIe bandwidth (8.0 GT/s PCIe x8 link)
Nov 29 13:04:29 pve2-xxx kernel: bnxt_en 0000:12:00.1 (unnamed net_device) (uninitialized): Device requests max timeout of 100 seconds, may trigger hung task watchdog
Nov 29 13:04:29 pve2-xxx kernel: bnxt_en 0000:12:00.1 eth1: Broadcom BCM57416 NetXtreme-E 10GBase-T Ethernet found at mem de600000, node addr aa:bb:cc:dd:ee:22
Nov 29 13:04:29 pve2-xxx kernel: bnxt_en 0000:12:00.1: 63.008 Gb/s available PCIe bandwidth (8.0 GT/s PCIe x8 link)
Nov 29 13:04:29 pve2-xxx kernel: bnxt_en 0000:d8:00.0 (unnamed net_device) (uninitialized): Device requests max timeout of 100 seconds, may trigger hung task watchdog
Nov 29 13:04:29 pve2-xxx kernel: bnxt_en 0000:d8:00.0 eth2: Broadcom BCM57416 NetXtreme-E 10GBase-T Ethernet found at mem f7e10000, node addr aa:bb:cc:dd:ee:33
Nov 29 13:04:29 pve2-xxx kernel: bnxt_en 0000:d8:00.0: 63.008 Gb/s available PCIe bandwidth (8.0 GT/s PCIe x8 link)
Nov 29 13:04:29 pve2-xxx kernel: bnxt_en 0000:d8:00.1 (unnamed net_device) (uninitialized): Device requests max timeout of 100 seconds, may trigger hung task watchdog
Nov 29 13:04:29 pve2-xxx kernel: bnxt_en 0000:d8:00.1 eth3: Broadcom BCM57416 NetXtreme-E 10GBase-T Ethernet found at mem f7e00000, node addr aa:bb:cc:dd:ee:44
Nov 29 13:04:29 pve2-xxx kernel: bnxt_en 0000:d8:00.1: 63.008 Gb/s available PCIe bandwidth (8.0 GT/s PCIe x8 link)
Nov 29 13:04:29 pve2-xxx kernel: bnxt_en 0000:12:00.0 ens1f0np0: renamed from eth0
Nov 29 13:04:29 pve2-xxx kernel: bnxt_en 0000:12:00.1 ens1f1np1: renamed from eth1
Nov 29 13:04:29 pve2-xxx kernel: bnxt_en 0000:d8:00.1 ens3f1np1: renamed from eth3
Nov 29 13:04:29 pve2-xxx kernel: bnxt_en 0000:d8:00.0 ens3f0np0: renamed from eth2
Nov 29 13:05:31 pve2-xxx systemd-udevd[1226]: bnxt_en.rdma.0: Worker [1285] processing SEQNUM=8551 is taking a long time
Nov 29 13:05:31 pve2-xxx systemd-udevd[1226]: bnxt_en.rdma.3: Worker [1354] processing SEQNUM=8827 is taking a long time
Nov 29 13:05:31 pve2-xxx systemd-udevd[1226]: bnxt_en.rdma.2: Worker [1338] processing SEQNUM=8825 is taking a long time
Nov 29 13:05:31 pve2-xxx systemd-udevd[1226]: bnxt_en.rdma.1: Worker [1269] processing SEQNUM=8553 is taking a long time
Nov 29 13:06:13 pve2-xxx kernel: bnxt_en 0000:12:00.0: QPLIB: bnxt_re_is_fw_stalled: FW STALL Detected. cmdq[0xe]=0x3 waited (103641 > 100000) msec active 1 
Nov 29 13:06:13 pve2-xxx kernel: bnxt_en 0000:12:00.0 bnxt_re0: Failed to modify HW QP
Nov 29 13:06:13 pve2-xxx kernel: infiniband bnxt_re0: Couldn't change QP1 state to INIT: -110
Nov 29 13:06:13 pve2-xxx kernel: infiniband bnxt_re0: Couldn't start port
Nov 29 13:06:13 pve2-xxx kernel: bnxt_en 0000:12:00.0 bnxt_re0: Failed to destroy HW QP
Nov 29 13:06:13 pve2-xxx kernel: ------------[ cut here ]------------
Nov 29 13:06:13 pve2-xxx kernel: WARNING: CPU: 8 PID: 1285 at drivers/infiniband/core/cq.c:322 ib_free_cq+0x109/0x150 [ib_core]
Nov 29 13:06:13 pve2-xxx kernel: Modules linked in: intel_rapl_msr intel_rapl_common intel_uncore_frequency intel_uncore_frequency_common ipmi_ssif isst_if_common nfit x86_pkg_temp_thermal intel_powerclamp coretemp kvm_intel inp>
Nov 29 13:06:13 pve2-xxx kernel: CPU: 8 PID: 1285 Comm: (udev-worker) Tainted: P           O       6.8.12-4-pve #1
Nov 29 13:06:13 pve2-xxx kernel: Hardware name: HPE ProLiant xxx/ProLiant xxx, BIOS Uxx xx/xx/xxxx
Nov 29 13:06:13 pve2-xxx kernel: RIP: 0010:ib_free_cq+0x109/0x150 [ib_core]
...
Nov 29 13:06:13 pve2-xxx kernel: Call Trace:
Nov 29 13:06:13 pve2-xxx kernel:  <TASK>
Nov 29 13:06:13 pve2-xxx kernel:  ? show_regs+0x6d/0x80
Nov 29 13:06:13 pve2-xxx kernel:  ? __warn+0x89/0x160
Nov 29 13:06:13 pve2-xxx kernel:  ? ib_free_cq+0x109/0x150 [ib_core]
Nov 29 13:06:13 pve2-xxx kernel:  ? report_bug+0x17e/0x1b0
Nov 29 13:06:13 pve2-xxx kernel:  ? handle_bug+0x46/0x90
Nov 29 13:06:13 pve2-xxx kernel:  ? exc_invalid_op+0x18/0x80
Nov 29 13:06:13 pve2-xxx kernel:  ? asm_exc_invalid_op+0x1b/0x20
Nov 29 13:06:13 pve2-xxx kernel:  ? ib_free_cq+0x109/0x150 [ib_core]
Nov 29 13:06:13 pve2-xxx kernel:  ? ib_mad_init_device+0x54c/0x8a0 [ib_core]
Nov 29 13:06:13 pve2-xxx kernel:  add_client_context+0x127/0x1c0 [ib_core]
Nov 29 13:06:13 pve2-xxx kernel:  enable_device_and_get+0xe6/0x1e0 [ib_core]
Nov 29 13:06:13 pve2-xxx kernel:  ib_register_device+0x506/0x610 [ib_core]
Nov 29 13:06:13 pve2-xxx kernel:  ? alloc_port_data+0x59/0x130 [ib_core]
Nov 29 13:06:13 pve2-xxx kernel:  ? ib_device_set_netdev+0x160/0x1b0 [ib_core]
Nov 29 13:06:13 pve2-xxx kernel:  bnxt_re_probe+0xe7d/0x11a0 [bnxt_re]
Nov 29 13:06:13 pve2-xxx kernel:  ? __pfx_bnxt_re_probe+0x10/0x10 [bnxt_re]
Nov 29 13:06:13 pve2-xxx kernel:  auxiliary_bus_probe+0x3e/0xa0
Nov 29 13:06:13 pve2-xxx kernel:  really_probe+0x1c9/0x430
Nov 29 13:06:13 pve2-xxx kernel:  __driver_probe_device+0x8c/0x190
Nov 29 13:06:13 pve2-xxx kernel:  driver_probe_device+0x24/0xd0
Nov 29 13:06:13 pve2-xxx kernel:  __driver_attach+0x10b/0x210
Nov 29 13:06:13 pve2-xxx kernel:  ? __pfx___driver_attach+0x10/0x10
Nov 29 13:06:13 pve2-xxx kernel:  bus_for_each_dev+0x8a/0xf0
Nov 29 13:06:13 pve2-xxx kernel:  driver_attach+0x1e/0x30
Nov 29 13:06:13 pve2-xxx kernel:  bus_add_driver+0x14e/0x290
Nov 29 13:06:13 pve2-xxx kernel:  driver_register+0x5e/0x130
Nov 29 13:06:13 pve2-xxx kernel:  __auxiliary_driver_register+0x73/0xf0
Nov 29 13:06:13 pve2-xxx kernel:  ? __pfx_bnxt_re_mod_init+0x10/0x10 [bnxt_re]
Nov 29 13:06:13 pve2-xxx kernel:  bnxt_re_mod_init+0x3e/0xff0 [bnxt_re]
Nov 29 13:06:13 pve2-xxx kernel:  ? __pfx_bnxt_re_mod_init+0x10/0x10 [bnxt_re]
Nov 29 13:06:13 pve2-xxx kernel:  do_one_initcall+0x5b/0x340
Nov 29 13:06:13 pve2-xxx kernel:  do_init_module+0x97/0x290
Nov 29 13:06:13 pve2-xxx kernel:  load_module+0x213a/0x22a0
Nov 29 13:06:13 pve2-xxx kernel:  init_module_from_file+0x96/0x100
Nov 29 13:06:13 pve2-xxx kernel:  ? init_module_from_file+0x96/0x100
Nov 29 13:06:13 pve2-xxx kernel:  idempotent_init_module+0x11c/0x2b0
Nov 29 13:06:13 pve2-xxx kernel:  __x64_sys_finit_module+0x64/0xd0
Nov 29 13:06:13 pve2-xxx kernel:  x64_sys_call+0x169c/0x24b0
Nov 29 13:06:13 pve2-xxx kernel:  do_syscall_64+0x81/0x170
Nov 29 13:06:13 pve2-xxx kernel:  ? syscall_exit_to_user_mode+0x86/0x260
Nov 29 13:06:13 pve2-xxx kernel:  ? do_syscall_64+0x8d/0x170
Nov 29 13:06:13 pve2-xxx kernel:  ? do_flush_tlb_all+0xe/0x20
Nov 29 13:06:13 pve2-xxx kernel:  ? __flush_smp_call_function_queue+0x9f/0x450
Nov 29 13:06:13 pve2-xxx kernel:  ? irqentry_exit_to_user_mode+0x7b/0x260
Nov 29 13:06:13 pve2-xxx kernel:  ? clear_bhb_loop+0x15/0x70
Nov 29 13:06:13 pve2-xxx kernel:  ? clear_bhb_loop+0x15/0x70
Nov 29 13:06:13 pve2-xxx kernel:  ? clear_bhb_loop+0x15/0x70
Nov 29 13:06:13 pve2-xxx kernel:  entry_SYSCALL_64_after_hwframe+0x78/0x80
...
Nov 29 13:06:13 pve2-xxx kernel:  </TASK>
Nov 29 13:06:13 pve2-xxx kernel: ---[ end trace 0000000000000000 ]---
Nov 29 13:06:13 pve2-xxx kernel: bnxt_en 0000:12:00.0 bnxt_re0: Free MW failed: 0xffffff92
Nov 29 13:06:13 pve2-xxx kernel: infiniband bnxt_re0: Couldn't open port 1
Nov 29 13:06:13 pve2-xxx kernel: infiniband bnxt_re0: Device registered with IB successfully
Nov 29 13:06:30 pve2-xxx udevadm[1230]: Timed out for waiting the udev queue being empty.
Nov 29 13:06:30 pve2-xxx udevadm[1231]: Timed out for waiting the udev queue being empty.
Nov 29 13:06:30 pve2-xxx systemd[1]: ifupdown2-pre.service: Main process exited, code=exited, status=1/FAILURE
Nov 29 13:06:30 pve2-xxx systemd[1]: ifupdown2-pre.service: Failed with result 'exit-code'.
Nov 29 13:06:30 pve2-xxx systemd[1]: Failed to start ifupdown2-pre.service - Helper to synchronize boot up for ifupdown.
Nov 29 13:06:30 pve2-xxx systemd[1]: Dependency failed for networking.service - Network initialization.
Nov 29 13:06:30 pve2-xxx systemd[1]: networking.service: Job networking.service/start failed with result 'dependency'.
Nov 29 13:06:30 pve2-xxx systemd[1]: systemd-udev-settle.service: Main process exited, code=exited, status=1/FAILURE
Nov 29 13:06:30 pve2-xxx systemd[1]: systemd-udev-settle.service: Failed with result 'exit-code'.
Nov 29 13:06:30 pve2-xxx systemd[1]: Failed to start systemd-udev-settle.service - Wait for udev To Complete Device Initialization.
Nov 29 13:06:30 pve2-xxx systemd[1]: Dependency failed for zfs-import-cache.service - Import ZFS pools by cache file.
Nov 29 13:06:30 pve2-xxx systemd[1]: zfs-import-cache.service: Job zfs-import-cache.service/start failed with result 'dependency'.
Nov 29 13:06:30 pve2-xxx systemd[1]: Dependency failed for zfs-import-scan.service - Import ZFS pools by device scanning.
Nov 29 13:06:30 pve2-xxx systemd[1]: zfs-import-scan.service: Job zfs-import-scan.service/start failed with result 'dependency'.
```

À cause de ce timeout (qui rend le démarrage du système anormalement long), le service `systemd-udev-settle` échoue, et le service networking aussi, donc votre serveur se retrouve sans réseau.

On peut aussi constater, à l'arrêt du système, plein de messages d'erreur DMAR (PTE Read Access is not set) qui concernent cette carte réseau.

La raison : deux pilotes s'associent aux interfaces réseau de ces cartes : dans un premier temps, `bnxt_en` (pilote réseau) qui fonctionne correctement, puis `bnxt_re` qui ne fonctionne pas correctement et timeout.
`bnxt_re` permet à priori de faire du ["RDMA over Converged Ethernet"](https://en.wikipedia.org/wiki/RDMA_over_Converged_Ethernet), ce dont on n'a pas besoin dans la plupart des cas.

Le fix consiste à empêcher le chargement de `bnxt_re`, pour cela : 

```
sudo echo "blacklist bnxt_re" > /etc/modprobe.d/blacklist_bnxt_re.conf
```

Pour plus d'infos : [https://utcc.utoronto.ca/~cks/space/blog/linux/BroadcomNetworkDriverAndRDMA](https://utcc.utoronto.ca/~cks/space/blog/linux/BroadcomNetworkDriverAndRDMA).
