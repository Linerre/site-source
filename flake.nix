{
  description = "My blog site";

  inputs = {
    # My top-level flake and all my projects `follows` (inherit) it
    korin.url = "github:Linerre/korin";
    nixpkgs.follows = "korin/nixpkgs";
    flake-utils.follows = "korin/flake-utils";
  };

  outputs = { self, flake-utils, nixpkgs, ... }:
    flake-utils.lib.eachSystem [ "x86_64-linux" ] (system:
      let
        pkgs = import nixpkgs { inherit system; };
        hpkgs = pkgs.haskellPackages;
      in
        {
          devShells.default = pkgs.mkShell {
            LANG = "en_US.UTF-8";

            buildInputs = with hpkgs; [
              # GHC 946
              (ghcWithPackages (p: with p; [
                # libs
                hakyll
                hlint   # 3.5
                hindent # 6.0.0
                pandoc
                # tools
                cabal-install
              ]))

              # Bins
              ghcid   # 0.8.9
              pandoc-cli  # 0.1.1.1
              haskell-language-server
            ];

            shellHook = ''
              alias e="emacs -nw"
              alias ll="ls -alh"
              alias b="ghc -O2 -dynamic --make"
              alias site="./site"
            '';
          };
        }
    );

  # Optional
  nixConfig = {
    bash-prompt = "[B]λ ";
  };
}
