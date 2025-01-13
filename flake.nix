{
  description = "One Flake to Rule them All";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Import flake that makes NixOS work under WSL.
    NixOS-WSL = {
      url = "github:nix-community/NixOS-WSL";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, unstable, home-manager, NixOS-WSL }@attrs:
    let
      forAllSystems = function:
        nixpkgs.lib.genAttrs [ "x86_64-linux" "aarch64-linux" ]
        (system: function (import unstable { inherit system; }));
    in {
      packages = forAllSystems (pkgs:
        {

        });
      # Shell enviornment with useful tools available.
      devShells = forAllSystems
        (pkgs: { default = pkgs.mkShell { buildInputs = [ ]; }; });

      # homeModules.helixConfig = ./modules/helix.nix;
      homeModules.common = ./modules/home-common.nix;

      # NixOS System config for the installation on my main machine.
      # nixosConfigurations.wslnixos = nixpkgs.lib.nixosSystem
      #   (let system = "x86_64-linux";
      #   in {
      #     inherit system;
      #     specialArgs = attrs // {
      #       unstable = import unstable { inherit system; };
      #     };
      #     modules = [
      #       {
      #         nix.registry.nixpkgs.flake = nixpkgs;
      #       }
      #       # Setup own NixOS configuration.
      #       ./nix/common.nix
      #     ];
      #   });

      # NixOS System config for the installation on a Chrome OS machine.
      homeConfigurations."dcode@dvirt" =
        home-manager.lib.homeManagerConfiguration (let system = "x86_64-linux";
        in {
          pkgs = import unstable { inherit system; };
          extraSpecialArgs = attrs // {
            inherit system;
            unstable = import unstable { inherit system; };
          };
          modules = [
            { nix.registry.nixpkgs.flake = nixpkgs; }
            self.homeModules.common
          ];
        });

      # NixOS System config for the installation on a server box.
      nixosConfigurations.cloud = nixpkgs.lib.nixosSystem
        (let system = "aarch64-linux";
        in {
          inherit system;
          specialArgs = attrs // {
            inherit system;
            unstable = import unstable { inherit system; };
          };
          modules = [
            {
              nix.registry.nixpkgs.flake = nixpkgs;
            }
            # Setup own NixOS configuration.
            ./nix/common.nix
            ./nix/cloud/cloud.nix
          ];
        });
    };
}
