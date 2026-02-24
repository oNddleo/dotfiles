{ config, pkgs, ... }:

let
  # Workaround: direnv tests fail on your macOS; disable checks
  direnvNoCheck = pkgs.direnv.overrideAttrs (_old: {
    doCheck = false;
  });

in
{
  home.username = "vsf-longnd56-l";
  home.homeDirectory =
    if pkgs.stdenv.isDarwin
    then "/Users/${config.home.username}"
    else "/home/${config.home.username}";
  home.stateVersion = "24.11";
  home.enableNixpkgsReleaseCheck = false;

  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    git
    curl
    jq
    neovim
    tmux
    tree
    gh
    jless
    wget

    # AWS CLI v2
    awscli2
    aws-vault

    # K8s
    kubectl

    # Go
    go

    # Rust toolchain
    rustc
    cargo
    rustfmt
    clippy

    # Java
    jdk21
    maven
    gradle

    # NodeJS
    nodejs

    # Build deps (useful for native modules / rust crates)
    pkg-config
    openssl

    # modern CLI toolbox
    bat
    eza
    ripgrep
    fd
    zoxide
    delta
    tree
    htop
    gnumake

    btop
    neofetch
    fastfetch
    lazygit
    k9s

    # Shell enhancements
    fzf
    starship
    atuin
  ];

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    # Useful defaults
    dotDir = ".config/zsh";

    history = {
      size = 100000;
      save = 100000;
      path = "${config.home.homeDirectory}/.zsh_history";
      ignoreDups = true;
      share = true;
    };

    # Aliases
    shellAliases = {
      ll = "ls -alF";
      la = "ls -A";
      l = "ls -CF";

      cat = "bat";
      grep = "rg";
      find = "fd";
      g = "git";

      k = "kubectl";
      k9 = "k9s";
      kg = "kubectl get";
      kgp = "kubectl get pods";
      kgs = "kubectl get services";
      kgd = "kubectl get deployments";
      kgn = "kubectl get nodes";
      kd = "kubectl describe";
      kdp = "kubectl describe pod";
      kl = "kubectl logs";
      ke = "kubectl exec -it";
      kaf = "kubectl apply -f";
      kdf = "kubectl delete -f";
      kctx = "kubectl config use-context";
      kns = "kubectl config set-context --current --namespace";
      kp = "kubectl port-forward";
      kcc = "kubectl config current-context";
    };

    profileExtra = pkgs.lib.optionalString pkgs.stdenv.isDarwin ''
      export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"
    '';

    # Extra init (runs after HM config)
    initExtra = ''
      # Ensure Nix profile is in PATH (macOS safety)
      export PATH="$HOME/.nix-profile/bin:$PATH"
      export PATH="$HOME/.local/state/nix/profiles/profile/bin:$PATH"
      export PATH="$HOME/.local/state/nix/profiles/home-manager/home-path/bin:$PATH"
      export PATH="$(npm config get prefix)/bin:$PATH"

      # Starship prompt
      eval "$(starship init zsh)"

      # zoxide (smart cd)
      eval "$(zoxide init zsh)"

      # fzf keybindings + completion
      source ${pkgs.fzf}/share/fzf/key-bindings.zsh
      source ${pkgs.fzf}/share/fzf/completion.zsh

      # Better fzf defaults (ripgrep + fd)
      export FZF_DEFAULT_COMMAND='fd --hidden --follow --exclude .git'
      export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
      export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'

      # Use bat for fzf preview (files)
      export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border --preview 'bat --style=numbers --color=always --line-range :500 {}'"

      # Atuin (history search)
      eval "$(atuin init zsh)"

      # Load IBus (Vietnamese Keyboard) on Ubuntu only
      if [ -f /etc/os-release ] && grep -q '^ID=ubuntu$' /etc/os-release; then
        export GTK_IM_MODULE=ibus
        export QT_IM_MODULE=ibus
        export XMODIFIERS=@im=ibus
      fi
    '';
  };

  programs.git = {
    enable = true;
    userName = "Nguyễn Đức Long";
    userEmail = "nguyenduclong12a2nd@gmail.com";
  };

  programs.direnv = {
    enable = true;
    package = direnvNoCheck;
    nix-direnv.enable = true;
  };
  # ---- Starship prompt ----
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      add_newline = false;
      git_branch.disabled = false;
      git_status.disabled = false;
      kubernetes.disabled = false;
      kubernetes.format = "on [$context\\($namespace\\)]($style) ";
      format = "$time$directory$git_branch$git_status$aws$kubernetes$cmd_duration$character";
      time = {
        disabled = false;
        format = "[$time]($style) ";
        time_format = "%H:%M";
        style = "bold yellow";
      };
      aws = {
        disabled = false;
        format = "on [$profile]($style) ";
      };
      custom.cpu = {
        command =
          if pkgs.stdenv.isDarwin
          then "top -l 1 | grep 'CPU usage' | awk '{print $3}'"
          else "top -bn1 | awk '/Cpu\\(s\\)/ {print $2}'";
        when = "true";
        format = "[CPU $output]($style) ";
        style = "bold red";
      };
    };
    
  };

  # ---- Atuin (history sync/search) ----
  programs.atuin = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      # auto_sync = true;
      # sync_frequency = "5m";
      # search_mode = "fuzzy";
    };
  };

  # ---- fzf ----
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };
}
