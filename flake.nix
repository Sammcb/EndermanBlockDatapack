{
	description = "Enderman block datapack";

	inputs = {
		# Commit does not correspond to a tag.
		# Updating to latest commit generally follows unstable branch.
		nixpkgs.url = "github:NixOS/nixpkgs/d7041843af2d12f729502888094984d3e0ff7e54";
		# Commit does not correspond to a tag.
		flake-parts.url = "github:hercules-ci/flake-parts/f4330d22f1c5d2ba72d3d22df5597d123fdb60a9";
		flake-checker = {
			# Commit corresponds to tag v0.2.4.
			url = "github:DeterminateSystems/flake-checker/93ec61a573f9980b480f514132073233bf8eceb9";
			inputs.nixpkgs.follows = "nixpkgs";
		};
	};

	outputs = inputs@{self, nixpkgs, flake-parts, flake-checker}: flake-parts.lib.mkFlake {inherit inputs;} {
		systems = ["aarch64-darwin" "aarch64-linux" "x86_64-linux" "x86_64-darwin"];
		perSystem = {pkgs, system, ...}:
			let
				flakeCheckerPackage = flake-checker.packages.${system}.default;
			in {
				devShells.default = pkgs.mkShell {
					nativeBuildInputs = [flakeCheckerPackage] ++ (with pkgs; [gnumake zip editorconfig-checker zizmor]);
				};

				devShells.build = pkgs.mkShell {
					nativeBuildInputs = with pkgs; [gnumake zip];
				};

				devShells.lintWorkflows = pkgs.mkShell {
					nativeBuildInputs = with pkgs; [zizmor];
				};

				devShells.lintEditorconfig = pkgs.mkShell {
					nativeBuildInputs = with pkgs; [editorconfig-checker];
				};

				devShells.releaseArtifact = pkgs.mkShell {
					nativeBuildInputs = with pkgs; [gh];
				};
			};
	};
}
