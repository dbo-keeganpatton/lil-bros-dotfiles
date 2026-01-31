{ config, pkgs, ... }:

{
  imports =
    [ 
      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelParams = ["video=DP-1:1920x1080@60D"];

  networking.hostName = "nixos"; 

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/Chicago";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;
  services.xserver.displayManager.gdm.wayland = true;

  # Automatically login since this system is only accessed remotely
  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = "eyelady";

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    #media-session.enable = true;
  };

  # services.xserver.libinput.enable = true;
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.eyelady = {
    isNormalUser = true;
    description = "eyelady";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
    ];
  };

  users.users.keegan = {
  	isNormalUser = true;
	extraGroups = ["wheel"];
  };

  # Install firefox.
  programs.firefox.enable = true;
  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # These are the packages that will be installed globally,
  # If I want user specific packages add them above to each user.
  environment.systemPackages = with pkgs; [
	  fastfetch
	  alacritty
	  hyprpaper
	  openssl
	  neovim
	  waybar
	  kitty
	  btop
	  git
	  gcc
	  fzf
  ];

  nix.settings.experimental-features = ["nix-command"  "flakes"];


  # Hyprland base enablement 
  programs.hyprland = {
	enable = true;
	xwayland.enable = true;
  };


  # Enable the OpenSSH daemon.
  services.openssh = {
	enable = true;
	settings = {
		PasswordAuthentication = true;
		KbdInteractiveAuthentication = false;
		PermitRootLogin = "no";
	};
  };

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [ 3389 ];
  networking.firewall.allowedUDPPorts = [ 3389 ];

  # This is a bunch of crap needed for Gnome remote access tow work,
  # Major pain in the ass and I hate it.
  services.gnome.gnome-remote-desktop.enable = true;
  systemd.services.gnome-remote-desktop.wantedBy = [ "graphical.target" ];
  programs.dconf.enable = true;
  services.logind.lidSwitch = "ignore";
  services.logind.lidSwitchDocked = "ignore";
  systemd.sleep.extraConfig = "AllowSuspend=no\nAllowHibernation=no";


  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11"; # Did you read the comment?
}
