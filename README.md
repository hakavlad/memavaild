
# memavaild

[![Total alerts](https://img.shields.io/lgtm/alerts/g/hakavlad/memavaild.svg?logo=lgtm&logoWidth=18)](https://lgtm.com/projects/g/hakavlad/memavaild/alerts/)
[![Language grade: Python](https://img.shields.io/lgtm/grade/python/g/hakavlad/memavaild.svg?logo=lgtm&logoWidth=18)](https://lgtm.com/projects/g/hakavlad/memavaild/context:python)

Improve responsiveness during heavy swapping: keep amount of available memory.

## Requirements

- Python 3.3+
- systemd with unified cgroup hierarchy

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

Edit the config: $SYSCONFDIR/memavaild.conf

## Demo
`stress -m 9 --vm-bytes 99G` without full freezing (with swap on zram): https://www.youtube.com/watch?v=DJq00pEt4xg
