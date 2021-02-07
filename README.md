# Using a non-NixOS distro as a nixos-container host #

1. Install Nix in multi-user mode (https://nixos.org/nix/manual/#sect-multi-user-installation)

2. Install required packages for `systemd-nspawn`

  e.g. on debian: `apt install systemd-container`

3. Clone repository and cd into it

4. As root install container-system

  `nix-build container-system.nix`

5. Symlink systemd units into host system.

  ```
  sudo ln -fs result/etc/systemd/system/{nat,container@}.service /etc/systemd/system
  systemctl daemon-reload
  ```

6. Start and enable nat service (required for containers to have network access)

  ```
  systemctl start nat
  mkdir -p /etc/systemd/system/network.target.wants
  ln -s result/etc/systemd/system/nat.service /etc/systemd/system/network.target.wants
  ```

7. Create containers using `nixos-container` or by deploying with `nixops`

  ```
  sudo -E result/bin/nixos-container create [NAME]
  ```

7. Permanently enable a container

  `sudo ln -s /etc/systemd/system/container@.service /etc/systemd/system/multi-user.target.wants/container@[NAME].service`

8. Expose ports

  Edit `/etc/containers/[NAME].conf` and add to `HOST_PORT`.  Each word will correspond to the value of a `systemd-nspawn` `--port` argument.

  You must restart the container for configuration changes to have an effect `systemctl restart container@[NAME]`.

  **WARNING** these ports may not be forwarded from the loopback interface.

9. Configure `systemd-nspawn`

  Edit `/etc/containers/[NAME].conf` and add `EXTRA_NSPAWN_FLAGS`.  This variable will be appended to the nspawn arguments, and can contain anything from `man systemd-nspawn`.

  e.g. to create a bind mount: `--bind=/mnt/container/var:/var`

  `systemd-nspawn` may also be configured using `/etc/systemd/nspawn/[NAME].nspawn` according to the manual.
