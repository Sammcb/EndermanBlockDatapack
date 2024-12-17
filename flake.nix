{
	description = "Enderman block datapack";

	inputs = {
		# Commit does not correspond to a tag.
		# Updating to latest commit generally follows unstable branch.
		nixpkgs.url = "github:NixOS/nixpkgs/8edf06bea5bcbee082df1b7369ff973b91618b8d";
		# Commit does not correspond to a tag.
		flake-utils.url = "github:numtide/flake-utils/11707dc2f618dd54ca8739b309ec4fc024de578b";
		flake-checker = {
			# Commit corresponds to tag v0.2.0.
			url = "github:DeterminateSystems/flake-checker/6ba8ec538e8b959957932c3416ea9384b7cef170";
			inputs.nixpkgs.follows = "nixpkgs";
		};
	};

	outputs = {self, nixpkgs, flake-utils, flake-checker}: flake-utils.lib.eachDefaultSystem (system:
		let
			pkgs = import nixpkgs {inherit system;};
			lib = pkgs.lib;

			buildDirectory = ".build";
			datapackName = "enderman-block";
			version = "1.3.0";
			minecraftVersion = "1.21.4";

			buildScript = pkgs.writeShellApplication {
				name = "build";
				runtimeInputs = with pkgs; [zip];
				text = lib.strings.concatStringsSep "\n" [
					"build_directory='${buildDirectory}'"
					"datapack_name='${datapackName}'"
					"version='${version}'"
					"minecraft_version='${minecraftVersion}'"
					"${builtins.readFile ./commands/build.sh}"
				];
			};

			flakeCheckerPackage = flake-checker.packages.${system}.default;
		in {
			devShells.default = pkgs.mkShell {
				nativeBuildInputs = [flakeCheckerPackage] ++ (with pkgs; [zip editorconfig-checker zizmor]);
			};

			checks = {
				editorconfig = pkgs.stdenvNoCC.mkDerivation {
					name = "editorconfig-lint";
					src = self;
					dontBuild = true;
					doCheck = true;
					nativeBuildInputs = with pkgs; [editorconfig-checker];
					checkPhase = "editorconfig-checker";
					installPhase = "touch $out";
				};

				zizmor = pkgs.stdenvNoCC.mkDerivation {
					name = "zizmor";
					src = self;
					dontBuild = true;
					doCheck = true;
					nativeBuildInputs = with pkgs; [zizmor];
					checkPhase = "zizmor -n .";
					installPhase = "touch $out";
				};

				# This takes a long time to install in a runner
				# Disabling till nix hopefully allows running individual checks

				# flake = pkgs.stdenvNoCC.mkDerivation {
				# 	name = "flake-checker";
				# 	src = self;
				# 	dontBuild = true;
				# 	doCheck = true;
				# 	nativeBuildInputs = [flakeCheckerPackage];
				# 	checkPhase = "flake-checker --no-telemetry";
				# 	installPhase = "touch $out";
				# };
			};

			packages = {
				default = buildScript;

				build = buildScript;
			};

			apps.clean = {
				type = "app";
				program = lib.getExe (
					pkgs.writeShellApplication {
						name = "clean";
						runtimeInputs = [];
						text = lib.strings.concatStringsSep "\n" [
							"build_directory='${buildDirectory}'"
							"${builtins.readFile ./commands/clean.sh}"
						];
					}
				);
				meta.description = "Cleans up build artifacts";
			};

			apps.build = {
				type = "app";
				program = lib.getExe buildScript;
				meta.description = "Zips up the datapack";
			};
		}
	);
}
