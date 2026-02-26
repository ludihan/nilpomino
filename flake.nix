{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs =
    { self, nixpkgs }:
    let
      forAllSystems = with nixpkgs; lib.genAttrs lib.systems.flakeExposed;
      nixpkgsFor = forAllSystems (system: import nixpkgs { inherit system; });
    in
    {
      packages = forAllSystems (
        system:
        let
          pkgs = nixpkgsFor.${system};
        in
        rec {
          default = nilpomino;
          nilpomino = pkgs.stdenv.mkDerivation rec {
            pname = "nilpomino";
            version = "0.1.0";

            src = ./.;

            nativeBuildInputs = [
              pkgs.zip
              pkgs.copyDesktopItems
              pkgs.makeWrapper
            ];

            runtimeLibs = [
              pkgs.love
            ];

            desktopItems = [
              (pkgs.makeDesktopItem rec {
                name = "nilpomino";
                desktopName = name;
                exec = name;
                comment = "tetris clone";
                categories = [ "Game" ];
              })

            ];

            installPhase = ''
              runHook preInstall

              zip -9 -r ${pname}.love .
              mkdir -p $out/bin $out/share/${pname}
              cp ${pname}.love $out/share/${pname}

              runHook postInstall
            '';

            preFixup = ''
              makeWrapper ${pkgs.love}/bin/love $out/bin/${pname} \
                --add-flags $out/share/${pname}/${pname}.love
            '';

          };
        }
      );

      devShells = forAllSystems (
        system:
        let
          pkgs = nixpkgsFor.${system};
        in
        rec {
          default = nilpomino;
          nilpomino = pkgs.mkShell {
            buildInputs = with pkgs; [
              love
              luajit
              luajitPackages.lua-lsp
            ];
            shellHook = ''
              export PS1="(nilpomino) $PS1"
            '';
          };
        }
      );

    };
}
