{
  description = "My Home Manager config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, ... }:
    let
      mkHome = { system, username }:
        let pkgs = nixpkgs.legacyPackages.${system}; in
        home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [
            ./home.nix
            {
              home.username = username;
              home.homeDirectory =
                if pkgs.stdenv.hostPlatform.isDarwin then "/Users/${username}" else "/home/${username}";
            }
          ];
        };
    in {
      homeConfigurations = {
        darwin-arm64  = mkHome { system = "aarch64-darwin"; username = "narixius"; };
        darwin-x86_64 = mkHome { system = "x86_64-darwin";  username = "narixius"; };
        linux-aarch64 = mkHome { system = "aarch64-linux";  username = "narixius"; };
        linux-arm64   = mkHome { system = "arm64-linux";    username = "narixius"; };
        linux-x86_64  = mkHome { system = "x86_64-linux";   username = "narixius"; };
      };
    };
}
