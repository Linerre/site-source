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
              # For developing
              ghc     # 9.4.6 (LTS Stackage)
              ghcid   # 0.8.9
              hlint   # 3.5
              hindent # 6.0.0

              # Blog
              hakyll      # 4.16.0.0 (latest 4.16.2.0)
              pandoc-cli  # 0.1.1.1
            ];

            shellHook = ''
              alias e="emacs -nw"
            '';
          };
        }
    );

  # Optional
  nixConfig = {
    bash-prompt = "[B]λ ";
  };
}
