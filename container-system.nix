let
  configuration = { config, pkgs, ... }: {
    imports = [
      <nixpkgs/nixos/modules/virtualisation/docker-image.nix>
    ];
    system.stateVersion = "21.05";
    time.timeZone = "Europe/Amsterdam";
    boot.enableContainers = true;
    systemd.services."container@" = {
      preStart = ''
        if [ -d $root ]; then
          rm $root/etc/{os-release,machine-id}
        fi
      '';
    };
    networking.nat = {
      enable = true;
      internalInterfaces = ["ve-+"];
      externalInterface = "eno1";
    };
  };
  nixos = import <nixpkgs/nixos> {
    inherit configuration;
    system = builtins.currentSystem;
  };
  system = nixos.config.system.build.toplevel;
  nixos-container =
    (import (builtins.fetchTarball https://github.com/NixOS/nixpkgs/archive/nixos-20.09.tar.gz) { }).nixos-container;
in
{ pkgs ? import <nixpkgs> { } }: with pkgs;
stdenv.mkDerivation {
  name = "container-system";
  unpackPhase = ":";
  installPhase = ''
    mkdir -p $out/bin $out/etc/systemd/system
    ln -s ${nixos-container}/bin/nixos-container $out/bin/nixos-container
    ln -s ${system}/etc/systemd/system/{nat,container@}.service $out/etc/systemd/system/
  '';
}
