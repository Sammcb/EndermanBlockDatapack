nix run .#clean

mkdir "${build_directory}"

datapack_directory="datapack"

if [ -d "${datapack_directory}" ]; then
	datapack_zip_name="${datapack_name}-${version}-${minecraft_version}.zip"

	echo "Zipping datapack '${datapack_zip_name}' into build directory '${build_directory}'..."

	(
		cd ${datapack_directory} || exit 1
		zip -q -r "../${build_directory}/${datapack_zip_name}" data pack.mcmeta pack.png
	)
fi
