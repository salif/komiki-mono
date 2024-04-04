{
  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs/nixos-23.11;
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system: let
        pkgs = nixpkgs.legacyPackages.${system};

        cousine-font = pkgs.fetchurl {
          url = "https://github.com/google/fonts/raw/main/apache/cousine/Cousine-Regular.ttf";
          sha256 = "sha256-aeHqWet3ABQgTlF0+AV1D5p5PbSiUx5lFrMLdGDUcLM=";
        };

        comic-shans-font = pkgs.fetchurl {
          url = "https://github.com/shannpersand/comic-shanns/raw/master/v2/comic%20shanns.otf";
          sha256 = "sha256-ogAILIIBbTnwUYzUSdX6VIbbSo7kuXihDUOZpVo1fVQ=";
        };

        lig = pkgs.fetchFromGitHub {
          owner = "ToxicFrog";
          repo = "Ligaturizer";
          rev = "c4065187a544a8fab40826fc91db1c6180a2d342";
          sha256 = "sha256-89/6xEBybIG9OfeOkwh8bwvQpp8+SOCbUxIlqbdkvqU=";
        };

      in {
        packages.komisch-mono = pkgs.stdenv.mkDerivation rec {
          pname = "Komisch Mono";
          version = "1.0.0";
          src = ./.;

          nativeBuildInputs = with pkgs; [
            python311
            python311Packages.fontforge
            fontforge
          ];

          buildPhase = ''
            mkdir -p vendor build output

            ln -sf "${cousine-font}" vendor/Cousine-Regular.ttf
            ln -sf "${comic-shans-font}" vendor/comic-shanns.otf

            python generate.py output

          '';

          # installPhase = ''
          #   install -m444 -Dt "$out" "build/"*.ttf
          # '';
        };

        defaultPackage = self.packages.${system}.komisch-mono;
      }
    );
}
