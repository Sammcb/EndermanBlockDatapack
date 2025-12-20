.PHONY: build build-datapack clean lint
.DEFAULT_GOAL := build

DATAPACK_ZIP_NAME := enderman-block.zip

build: build-datapack

build-datapack: clean
	(cd datapack && zip -q -r "../$(DATAPACK_ZIP_NAME)" data pack.mcmeta pack.png)

clean:
	rm -f $(DATAPACK_ZIP_NAME)

lint:
	zizmor .
	editorconfig-checker
	flake-checker --no-telemetry
	nix flake check
