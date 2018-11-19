{ pkgs, config, ... }:
{
  nixpkgs.config = {

    packageOverrides = pkgs: rec {
      yarn = pkgs.yarn.override { nodejs = pkgs.nodejs-10_x; };

      haskellPackages = pkgs.haskellPackages.override {
        overrides = haskellPackagesNew: haskellPackagesOld: rec {
          beans = haskellPackagesNew.callPackage ./beans.nix {};
          xmonad = haskellPackagesNew.callPackage ./xmonad.nix {};
          xmonad-contrib = haskellPackagesNew.callPackage ./xmonad-contrib.nix {};
        };
      };

      gw = pkgs.callPackage ./gradlew.nix {};

      gradle = gradleGen.gradle_latest;

      gradleGen = pkgs.gradleGen.override {
        jdk = pkgs.openjdk10;
      };

      html2text = pkgs.html2text.overrideAttrs (oldAttrs: rec {
        patches = [
          ./html2text/100-fix-makefile.patch
          ./html2text/200-close-files-inside-main-loop.patch
          ./html2text/400-remove-builtin-http-support.patch
          ./html2text/500-utf8-support.patch
          ./html2text/510-disable-backspaces.patch
          ./html2text/550-skip-numbers-in-html-tag-attributes.patch
          ./html2text/600-multiple-meta-tags.patch
          ./html2text/611-recognize-input-encoding.patch
          ./html2text/630-recode-output-to-locale-charset.patch
          ./html2text/800-replace-zeroes-with-null.patch
          ./html2text/810-fix-deprecated-conversion-warnings.patch
          ./html2text/900-complete-utf8-entities-table.patch
          ./html2text/950-validate-width-parameter.patch
          ./html2text/960-fix-utf8-mode-quadratic-runtime.patch
        ];
      }
      );
    };
  };

  environment.systemPackages = with pkgs; [
    # flashplayer
    # skypeforlinux
    ack
    ansible
    arandr
    beancount
    chromium
    darktable
    dmenu
    docker_compose
    emacs
    evince
    firefox
    fdupes
    git-review
    gitAndTools.gitFull
    gw
    # flashplayer
    gnome3.eog
    gnome3.nautilus
    gradle
    gthumb
    hplip
    html2text
    i3lock
    icedtea8_web
    imagemagick7
    ispell
    isync
    jetbrains.datagrip
    jetbrains.idea-community
    keepassx2
    keepassxc
    libreoffice
    libressl
    libxml2
    mitscheme
    mu
    nix-index
    nodejs-10_x
    notmuch
    offlineimap
    openjdk10
    pavucontrol
    pandoc
    phantomjs
    python3
    protonmail-bridge
    restic
    rofi
    rubber
    sbcl
    shared_mime_info
    silver-searcher
    spotify
    termite
    texlive.combined.scheme-full
    thunderbird
    exiftool
    vanilla-dmz
    virtmanager
    virtmanager
    vlc
    wpa_supplicant
    xautolock
    xiccd
    unstable.haskellPackages.xmobar
    w3m
    xorg.xbacklight
    xorg.xcursorthemes
    xorg.xdpyinfo
    xorg.xev
    xorg.xkill
    xsel
    xss-lock
    unstable.yarn
    zbar
    zip
  ]

  ++ (with pkgs.haskellPackages; [
    # beans
    cabal-install
    apply-refact
    cabal2nix
    # hasktags
    hindent
    # hlint
    hpack
    stylish-haskell
  ]);

  virtualisation.libvirtd.enable = true;

  hardware.pulseaudio.enable = true;

  services.udisks2.enable = true;

  boot.kernel.sysctl = {
    "vm.swappiness" = 10;
  };

  services.xserver = {
    enable = true;
    layout = "us(altgr-intl)";
    xkbOptions = "compose:ralt,terminate:ctrl_alt_bksp";
    libinput = {
      enable = true;
      naturalScrolling = true;
    };
    displayManager = {
      sessionCommands = ''
          xset s 600 0
          xset r rate 440 50
          xss-lock -l -- i3lock -n &
      '';
    };
    desktopManager = {
      xterm = {
        enable = false;
      };
    };
    windowManager = {
      default = "xmonad";
      xmonad = {
        enable = true;
        enableContribAndExtras = false;
        extraPackages = haskellPackages: [
          haskellPackages.hostname
          haskellPackages.xmonad-contrib
        ];
      };
    };
  };

  networking.extraHosts = ''
    127.0.0.1	portal.test
    127.0.0.1	truewealth.test
    127.0.0.1 s3mock
  '';
  services.interception-tools.enable = true;
  services.redshift = {
    enable = true;
    provider = "manual";
    temperature = {
      night = 3400;
      day = 6500;
    };
    latitude = "47.3673";
    longitude = "8.55";
  };

  services.emacs.enable = true;

  fonts = {
    enableDefaultFonts = true;
    fonts = with pkgs; [
      corefonts
      dejavu_fonts
      source-code-pro
      google-fonts
      liberation_ttf
      carlito
      inconsolata
    ];
  };

  services.printing = {
    enable = true;
    drivers = [pkgs.hplip];
  };

  services.colord = {
    enable = true;
  };
}
