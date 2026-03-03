{ host, ... }:
{
  networking.hostName = host.hostname; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Enable networking
  networking.networkmanager.enable = true;
  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [
    22
    1922
    1999
    1988
    8080
    41999
  ];
  networking.firewall.allowedUDPPorts = [
    22
    1922
    1999
    1988
    8080
    41999
  ];
  services.openssh = {
    enable = true;
    settings = {
      UseDns = false;
      UsePAM = false;
      X11Forwarding = true;
    };
    extraConfig = ''
      ClientAliveInterval 60
      ClientAliveCountMax 3
    '';
  };
}
