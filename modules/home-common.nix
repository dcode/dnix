{ pkgs, unstable, ... }: {
  imports = [ ];

  home.stateVersion = "24.11";
  programs.nushell = {
    enable = true;
    configFile.source = ./../nix/config/nushell/config.nu;
    envFile.source = ./../nix/config/nushell/env.nu;
    package = unstable.nushell;

    # enableNushellIntegration on home-manager is outdated, pulled manually.
    extraConfig = ''
      $env.config = ($env | default {} config).config
      $env.config = ($env.config | default {} hooks)
      $env.config = ($env.config | update hooks ($env.config.hooks | default [] pre_prompt))
      $env.config = ($env.config | update hooks.pre_prompt ($env.config.hooks.pre_prompt | append {
        code: "
          let direnv = (${pkgs.direnv}/bin/direnv export json | from json)
          let direnv = if not ($direnv | is-empty) { $direnv } else { {} }
          $direnv | load-env
          "
      }))
    '';
  };
  programs.bash = {
    enable = true;
    profileExtra = ''
      nu
    '';
  };
  programs.git = {
    enable = true;
    userName = "Derek Ditch";
    userEmail = "dcode@norepy.users.github.com";
    extraConfig = {
      core.editor = "vim";
      pull.rebase = true;
      push.autoSetupRemote = true;
      init.defaultBranch = "main";
    };
  };
  programs.direnv = {
    enable = true;
    enableNushellIntegration = false;
    nix-direnv.enable = true;
  };
  programs.ssh = { enable = true; };
  services.ssh-agent = { enable = true; };
}
