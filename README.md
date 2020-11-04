
# memavaild

[![Total alerts](https://img.shields.io/lgtm/alerts/g/hakavlad/memavaild.svg?logo=lgtm&logoWidth=18)](https://lgtm.com/projects/g/hakavlad/memavaild/alerts/)
[![Language grade: Python](https://img.shields.io/lgtm/grade/python/g/hakavlad/memavaild.svg?logo=lgtm&logoWidth=18)](https://lgtm.com/projects/g/hakavlad/memavaild/context:python)

Improve responsiveness during heavy swapping: keep amount of available memory.

> "If you actually tried to use the memory it says in MemAvailable, you may very well already get bad side effects as the kernel needs to reclaim memory used for other purposes (file caches, mmap'ed executables, heap, …). Depending on the workload, this may already cause the system to start thrashing."

— [Benjamin Berg](https://lists.fedoraproject.org/archives/list/devel@lists.fedoraproject.org/message/3VNHWVRSGPYCFC6LUCNGUBUPSLZJT7OE/)

Default behavior: the control groups specified in the config (`user.slice` and `system.slice`) are swapped out when `MemAvailable` is low by reducing `memory.high` (values change dynamically). `memavaild` tries to keep about 3% available memory.

Effects: tasks are performed at less I/O and memory pressure (and this may be detected by PSI metrics). At the same time, performance may be increased in tasks that requires heavy swapping, especially in I/O bound tasks. Using `memavaild` has no effect without swap space.

## Requirements

- Python 3.3+
- systemd with unified cgroup hierarchy

## How to enable unified cgroup hierarchy

Unified cgroup hierarchy is enabled by default on Fedora 31+. On other distros pass `systemd.unified_cgroup_hierarchy=1` in the kernel boot cmdline.

## Known problems

- The documentation is terrible (config keys description and man page may be added later).
- The ZFS ARC cache is memory-reclaimable, like the Linux buffer cache. However, in contrast to the buffer cache, it currently does not count to MemAvailable (see openzfs/zfs#10255). Don't use memavaild with ZFS.

## Install

#### On [Fedora/CentOS 8](https://src.fedoraproject.org/rpms/memavaild):
```bash
$ sudo dnf install memavaild
$ sudo systemctl enable --now memavaild.service
```

#### For Arch Linux there's an [AUR package](https://aur.archlinux.org/packages/memavaild-git/)

Use your favorite [AUR helper](https://wiki.archlinux.org/index.php/AUR_helpers). For example,
```bash
$ yay -S memavaild-git
$ sudo systemctl enable --now memavaild.service
```

#### To install on Debian and Ubuntu-based systems:

It's easy to build a deb package with the latest git snapshot. Install build dependencies:
```bash
$ sudo apt install make fakeroot
```

Clone the latest git snapshot and run the build script to build the package:
```bash
$ git clone https://github.com/hakavlad/memavaild.git && cd memavaild
$ deb/build.sh
```

Install the package:
```bash
$ sudo apt install --reinstall ./deb/package.deb
```

Start and enable `memavaild.service` after installing the package:
```bash
$ sudo systemctl enable --now memavaild.service
```

#### On other distros:

Install:
```bash
$ git clone https://github.com/hakavlad/memavaild.git && cd memavaild
$ sudo make install
$ sudo systemctl enable --now memavaild.service
```

Uninstall:
```bash
$ sudo make uninstall
```

## How to configure

Edit the config (`/etc/memavaild.conf` or `/usr/local/etc/memavaild.conf`) and restart the service.

## Demo

- `stress -m 9 --vm-bytes 99G` without full freezing (with swap on zram): https://www.youtube.com/watch?v=DJq00pEt4xg. This is an old demo that demonstrates how memavaild can keep available memory.
- `stress -m 8 --vm-bytes 32G` with no freeze: `prelockd` + `memavaild` + `nohang-desktop` + `zram`, system on HDD: https://www.youtube.com/watch?v=veY606v57Hk

