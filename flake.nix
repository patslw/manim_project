{
  description = "Manim dev environment for stock-picking videos";

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
        buildInputs = [
          pkgs.python312
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

        shellHook = ''
          export LD_LIBRARY_PATH="${pkgs.lib.makeLibraryPath [
            pkgs.stdenv.cc.cc.lib
            pkgs.zlib
            # pkgs.libGL
            # pkgs.glib
          ]}:$LD_LIBRARY_PATH"
          export PATH="$PWD/.venv/bin:$PATH"
          echo "Manim dev environment ready — python: $(python3 --version)"
        '';
      };
    };
}
