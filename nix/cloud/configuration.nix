# Pulled directly from /etc/nixos/configuration.nix from a fresh system.
{ ... }: {
  imports = [ ./hardware-configuration.nix ];

  boot.tmp.cleanOnBoot = true;
  zramSwap.enable = true;
  networking.hostName = "instance-20240130-0135";
  networking.domain = "subnet11121025.vcn11121025.oraclevcn.com";
  services.openssh.enable = true;
  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCkoJxpX9p3XNrWV05NtPz8scmEgYS2gQyo7sYQxWO1p4z9lsKEqrG/ut1VXDohPQPUVjjjRWolrKUoRVxabkzCRvnEpKrWoMRe9sW+Y6V6mq9TPDFSXh8bfm/zh2IuYgaUdEcxkRexpqhemCbm9YAprZc3LEBz9ilUzzreibgzyn+PdV2O3fP2vUL/nxGh1KoC660SCtkyq/Ql8KMdpWyrZqoVR1QMg+Wg/tShjkQ2moklY5dyTuDXEBKxCrY8I/twp5WN4Eemu/i2H3VsTt0pyljsmRgwmqVnNdF9TQwFD6eHIaCEKEL3PnaFOsZdAgn9MnOFbp01ntwzGvFhncu3zjMeNgSuJzmz7gC/CMubLZ1iSOJRc5hFmYIe/sxiq9O6d1yqrciQlFAv4yWNnBIkSaXmGD1Whw60t3ZUBO7fjvwSgfJeqpFqmr1EmYwZ4pBTA6I5x4av+YEwKlF7yNlqnNBeLTSdy/tToCWgSvgaIgPs7VOipY1n24jtK5HywPU= jonah@wslnixos"
  ];
}
