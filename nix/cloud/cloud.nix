{ config, lib, pkgs, home-manager, jonah-id, unstable, system, self, ... }: {
  imports = [ ./configuration.nix jonah-id.nixosModules.jonah-id ];

  networking.hostName = lib.mkForce "cloud";
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 80 443 ];
  };

  security.acme = {
    acceptTerms = true;
    defaults.email = "admin@jonah.id";
    certs."jonah.id" = {
      webroot = "/var/lib/acme/acme-challenge";
      extraDomainNames = [ "vault.jonah.id" "jonah.name" ];
    };
  };
  users.users.nginx.extraGroups = [ "acme" ];

  services = {
    openssh.settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "prohibit-password";
    };

    vaultwarden = {
      enable = true;
      package = unstable.vaultwarden;

      config = {
        DOMAIN = "https://vault.jonah.id/";
        # Temporarily set to true when setting up to create own account.
        # SIGNUPS_ALLOWED = false;
        SIGNUPS_ALLOWED = true;
        ROCKET_ADDRESS = "127.0.0.1";
        ROCKET_PORT = 8222;
      };
    };

    nginx = {
      enable = true;
      recommendedProxySettings = true;

      # TODO add in old nucleussystems.com links

      virtualHosts."vault.jonah.id" = {
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://127.0.0.1:${
              toString config.services.vaultwarden.config.ROCKET_PORT
            }";
          proxyWebsockets = true;
        };
        useACMEHost = "jonah.id";
      };
    };
  };

  # Override the established by the setup.
  users.users = {
    # Override root to only allow the CI key.
    root.openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPpOBwcJ12ai+v++7ITh4YUGaSOsQo/QZTa4KAiWRXwm jonah@wslnixos"
    ];
    dcode.openssh.authorizedKeys.keys = [
      # Desktop key.
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCkoJxpX9p3XNrWV05NtPz8scmEgYS2gQyo7sYQxWO1p4z9lsKEqrG/ut1VXDohPQPUVjjjRWolrKUoRVxabkzCRvnEpKrWoMRe9sW+Y6V6mq9TPDFSXh8bfm/zh2IuYgaUdEcxkRexpqhemCbm9YAprZc3LEBz9ilUzzreibgzyn+PdV2O3fP2vUL/nxGh1KoC660SCtkyq/Ql8KMdpWyrZqoVR1QMg+Wg/tShjkQ2moklY5dyTuDXEBKxCrY8I/twp5WN4Eemu/i2H3VsTt0pyljsmRgwmqVnNdF9TQwFD6eHIaCEKEL3PnaFOsZdAgn9MnOFbp01ntwzGvFhncu3zjMeNgSuJzmz7gC/CMubLZ1iSOJRc5hFmYIe/sxiq9O6d1yqrciQlFAv4yWNnBIkSaXmGD1Whw60t3ZUBO7fjvwSgfJeqpFqmr1EmYwZ4pBTA6I5x4av+YEwKlF7yNlqnNBeLTSdy/tToCWgSvgaIgPs7VOipY1n24jtK5HywPU= jonah@wslnixos"
      # Pixel 8 Pro key.
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDs+S1XkdNB6cZXBBc0KCknxc97b6Ra6lo+SSq2sSHwe nix-on-droid@localhost"
      # Duet 11 Chromebook
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEGOpWc8U4aEzvwjFjttGWSazGhIHyckn67m+p95exfW jonah@penguin"
    ];
  };

  fileSystems = {
    # Mount the `data` block volume.
    "/mnt/data" = {
      device = "/dev/disk/by-uuid/79a44d9a-f56d-4750-9ff8-85b4816f5ea3";
      fsType = "xfs";
    };
  } // (pkgs.lib.attrsets.genAttrs [
    # Paths that need to be persisted to the block volume.
    "bitwarden_rs"
  ] (dir: {
    mountPoint = "/var/lib/${dir}";
    device = "/mnt/data/${dir}";
    options = [ "bind" ];
  }));

  # Boot partition isn't big enough for more than one kernel.
  boot.loader.grub.configurationLimit = 1;

  # Pin kernel version to avoid updating it.
  # https://github.com/elitak/nixos-infect/issues/192#issuecomment-2354201289
  # boot.kernelPackages = pkgs.linuxPackagesFor (pkgs.linux_6_1.override {
  #   argsOverride = rec {
  #     src = pkgs.fetchurl {
  #       url = "mirror://kernel/linux/kernel/v6.x/linux-6.1.75.tar.xz";
  #       sha256 = "sha256-bNGUEDMME+xMGP0oqD0+QPwSoVKBX7fD4bB2QykJOlY=";
  #     };
  #     version = "6.1.75";
  #     modDirVersion = "6.1.75";
  #   };
  # });
}
