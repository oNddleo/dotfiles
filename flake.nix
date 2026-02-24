{
  description = "LongND's Home Manager config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    home-manager.url = "github:nix-community/home-manager/release-24.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { nixpkgs, home-manager, ... }:
  let
    lib = nixpkgs.lib;

    systems = [
      "x86_64-linux"
      "aarch64-linux"
      "x86_64-darwin"
      "aarch64-darwin"
    ];

    mkHome = system:
      home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs { inherit system; };
        modules = [ ./home.nix ];
      };

    homesBySystem = lib.genAttrs systems mkHome;

    hostName =
      let
        hn = builtins.getEnv "HOSTNAME";
        h = builtins.getEnv "HOST";
        cn = builtins.getEnv "COMPUTERNAME";
      in
      if hn != "" then hn else if h != "" then h else cn;

    currentSystem =
      if builtins ? currentSystem then builtins.currentSystem else "";

    defaultSystem =
      if currentSystem != "" && builtins.hasAttr currentSystem homesBySystem
      then currentSystem
      else "x86_64-linux";
  in {
    homeConfigurations =
      homesBySystem
      // { default = homesBySystem.${defaultSystem}; }
      // lib.optionalAttrs (hostName != "" && currentSystem != "" && builtins.hasAttr currentSystem homesBySystem) {
        "${hostName}" = homesBySystem.${currentSystem};
      };
  };
}
