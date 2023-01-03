[![FreeFem AUR package](https://github.com/gdolle/podman.freefem/actions/workflows/build.yml/badge.svg)](https://github.com/gdolle/podman.freefem/actions/workflows/build.yml)

# Archlinux AUR Freefem podman


This repository provides a script to build [freefem AUR package](https://aur.archlinux.org/packages/freefem/)  using [**Podman**.](https://podman.io/)


## Usage from archlinux

```
pacman -S podman
./build_arch_ff_container.sh
```

## Develop

### Test the CI locally


Install [act](https://github.com/nektos/act) a tool for github action. Just type `act` to test the CI.
