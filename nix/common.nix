{ config, self, lib, pkgs, unstable, home-manager, ... }:

{
  imports = [ home-manager.nixosModules.default ];

  # Setup own user
  users.users.dcode = {
    shell = unstable.nushell;
    isNormalUser = true;
    extraGroups = [
      "wheel"
      # Needed to talk to serial devices
      "dialout"
    ];
  };

  # Install packages needed for normal use.
  environment.systemPackages = with pkgs; [ git direnv bash nvim ];
  environment.variables.EDITOR = "vim";

  # Enable flakes.
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Automatic scheduled store optimization.
  nix.optimise.automatic = true;
  nix.gc.automatic = true;

  home-manager.extraSpecialArgs.unstable = unstable;
  home-manager.users.dcode = self.homeModules.common;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system inherit system; were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?
}
