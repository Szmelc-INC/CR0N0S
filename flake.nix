{
  description = "cr0 (CR0N0S): a better cron with conditions, hooks, reminders, history ledger and TUI";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
    let
      systems = [ "x86_64-linux" "aarch64-linux" ];
      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f nixpkgs.legacyPackages.${system});
    in
    {
      packages = forAllSystems (pkgs: rec {
        cr0 = pkgs.buildGoModule {
          pname = "cr0";
          version = "0-unstable-${self.shortRev or self.dirtyShortRev or "dirty"}";
          src = ./.;
          vendorHash = pkgs.lib.fakeHash;
          subPackages = [ "cmd/cr0" ];
          env.CGO_ENABLED = 0;
          ldflags = [ "-s" "-w" "-X github.com/sernik77/CR0N0S/internal/cli.Version=${self.shortRev or "dirty"}" ];
          nativeBuildInputs = [ pkgs.installShellFiles ];
          postInstall = ''
            for sh in bash zsh fish; do HOME=$TMPDIR $out/bin/cr0 completion $sh > cr0.$sh; done
            installShellCompletion cr0.{bash,zsh,fish}
            install -Dm644 README.md -t $out/share/doc/cr0
            install -Dm644 examples/*.toml -t $out/share/doc/cr0/examples
          '';
          meta = {
            description = "A better cron: dynamic job scheduler with conditions, hooks, reminders, history ledger and TUI";
            homepage = "https://github.com/Szmelc-INC/CR0N0S";
            license = pkgs.lib.licenses.mit;
            mainProgram = "cr0";
            platforms = pkgs.lib.platforms.linux;
          };
        };
        default = cr0;
      });

      apps = forAllSystems (pkgs: {
        default = {
          type = "app";
          program = "${self.packages.${pkgs.stdenv.hostPlatform.system}.default}/bin/cr0";
        };
      });

      devShells = forAllSystems (pkgs: {
        default = pkgs.mkShell {
          inputsFrom = [ self.packages.${pkgs.stdenv.hostPlatform.system}.default ];
          packages = with pkgs; [ gopls gotools ];
        };
      });
    };
}
