
# memavaild

[![Total alerts](https://img.shields.io/lgtm/alerts/g/hakavlad/memavaild.svg?logo=lgtm&logoWidth=18)](https://lgtm.com/projects/g/hakavlad/memavaild/alerts/)
[![Language grade: Python](https://img.shields.io/lgtm/grade/python/g/hakavlad/memavaild.svg?logo=lgtm&logoWidth=18)](https://lgtm.com/projects/g/hakavlad/memavaild/context:python)

Improve responsiveness during heavy swapping: keep amount of available memory.

> "If you actually tried to use the memory it says in MemAvailable, you may very well already get bad side effects as the kernel needs to reclaim memory used for other purposes (file caches, mmap'ed executables, heap, …). Depending on the workload, this may already cause the system to start thrashing."

— [Benjamin Berg](https://lists.fedoraproject.org/archives/list/devel@lists.fedoraproject.org/message/3VNHWVRSGPYCFC6LUCNGUBUPSLZJT7OE/)

`memavaild` is yet another tool to improve responsiveness during heavy swapping. How it works: slices are swapped out when `MemAvailable` is low by reducing `memory.max` (values change dynamically). Effects: performance increases in tasks that requires heavy swapping, especially in io-bound tasks. At the same time, tasks are performed at less io and memory pressure. `memavaild` tries to keep about 3% available memory by default. Using `memavaild` has no effect without swap space.

## Requirements

- Python 3.3+
- systemd with unified cgroup hierarchy

## How to enable unified cgroup hierarchy

Unified cgroup hierarchy is enabled by default on Fedora 32+. On other distros pass `systemd.unified_cgroup_hierarchy=1` in kernel boot cmdline.

## Known problems

- The documentation is terrible.
- The ZFS ARC cache is memory-reclaimable, like the Linux buffer cache. However, in contrast to the buffer cache, it currently does not count to MemAvailable (see openzfs/zfs#10255). Don't use memavaild with ZFS.

## Install

#### On rpm-based:

See https://copr.fedorainfracloud.org/coprs/elxreno/memavaild/

#### On other distros:

```
$ git clone https://github.com/hakavlad/memavaild.git && cd memavaild
$ sudo make install
$ sudo systemctl enable --now memavaild.service
```

#### Uninstall
```
$ sudo make uninstall
```

## How to configure

Edit the config: `$SYSCONFDIR/memavaild.conf` (`/etc/memavaild.conf` or `/usr/local/etc/memavaild.conf`).

## Demo

- `stress -m 9 --vm-bytes 99G` without full freezing (with swap on zram): https://www.youtube.com/watch?v=DJq00pEt4xg
- `stress -m 8 --vm-bytes 32G` with no freeze: `prelockd` + `memavaild` + `nohang-desktop` + `zram`: https://www.youtube.com/watch?v=veY606v57Hk
