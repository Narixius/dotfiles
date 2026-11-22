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
        linux = mkHome { system = "x86_64-linux"; username = "narixius"; };
        mac   = mkHome { system = "aarch64-darwin"; username = "narixius"; };
      };
    };
}
