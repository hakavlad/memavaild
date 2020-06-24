
# memavaild

A new way to improve responsiveness during intense swapping.

## Install
```
$ git clone https://github.com/hakavlad/memavaild.git && cd memavaild
$ sudo make install
$ sudo systemctl enable --now memavaild.service
```

## Uninstall
```
$ sudo make uninstall
```

## Demo
`stress -m 9 --vm-bytes 99G` without full freezing (with swap on zram): https://www.youtube.com/watch?v=DJq00pEt4xg
