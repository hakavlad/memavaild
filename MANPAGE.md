% memavaild(8) | Linux System Administrator's Manual

# NAME
`memavaild` - Daemon that keeps amount of available memory

# SYNOPSIS
**memavaild** [**OPTION**]...

# DESCRIPTION
`memavaild` is a daemon that tries to keep amount of available memory to improve system responsiveness during heavy swapping.

Default behavior: the control groups specified in the config (`user.slice` and `system.slice`) are swapped out when MemAvailable is low by reducing `memory.high` (values change dynamically). memavaild tries to keep about 3% available memory.

Effects: tasks are performed at less I/O and memory pressure (and this may be detected by PSI metrics). At the same time, performance may be increased in tasks that requires heavy swapping, especially in I/O bound tasks. Using memavaild has no effect without swap space.

# COMMAND-LINE OPTIONS

#### -c CONFIG
path to the config file

# REQUIREMENTS
- Python (>= 3.3)
- systemd with unified cgroup hierarchy

# Known problems
- The documentation is terrible (no config keys description, for example);
- The ZFS ARC cache is memory-reclaimable, like the Linux buffer cache. However, in contrast to the buffer cache, it currently does not count to MemAvailable (see <https://github.com/openzfs/zfs/issues/10255>). Don't use `memavaild` with ZFS;
- Seems like `memavaild` violates [the second rule](https://systemd.io/CGROUP_DELEGATION/): `memavaild` manipulates the attributes of cgroups created by systemd (`memavaild` changes `memory.high` values).

# FILES

#### :SYSCONFDIR:/memavaild.conf
path to configuration file

#### :DATADIR:/memavaild/memavaild.conf
path to file with *default* `memavaild.conf` values

# RESTORE DEFAULT CONFIG
To resore config file with default values execute
```bash
sudo cp :DATADIR:/memavaild/memavaild.conf :SYSCONFDIR:/memavaild.conf
```

# HOW TO CONFIGURE
Edit the config and restart the service.

# REPORTING BUGS
Feel free to ask any questions and report bugs at <https://github.com/hakavlad/memavaild/issues>.

# AUTHOR
Written by Alexey Avramov <hakavlad@gmail.com>.

# HOMEPAGE
Homepage is <https://github.com/hakavlad/memavaild>.
