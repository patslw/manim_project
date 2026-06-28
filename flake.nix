{
  description = "System dependencies for Manim video development";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      devShells.${system}.default = pkgs.mkShell {
        packages = [
          pkgs.uv
          pkgs.ffmpeg
          pkgs.pango
          pkgs.cairo
          pkgs.pkg-config
          pkgs.gobject-introspection
          pkgs.stdenv.cc.cc.lib
          pkgs.texlive.combined.scheme-medium
          pkgs.texlivePackages.xecjk
          pkgs.texlivePackages.ctex
        ];

        UV_PROJECT_ENVIRONMENT = ".venv";

        shellHook = ''
          export LD_LIBRARY_PATH="${pkgs.lib.makeLibraryPath [
            pkgs.stdenv.cc.cc.lib
            pkgs.zlib
          ]}:$LD_LIBRARY_PATH"
          echo "Manim system environment ready. Run: uv sync"
        '';
      };
    };
}
