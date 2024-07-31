#!/bin/sh

VERSION=1.1.1
MINECRAFT_VERSION=1.21.0

ZIP_NAME="enderman-block-${VERSION}-${MINECRAFT_VERSION}.zip"

print_info() {
	printf "\e[1;35m$1\e[0m - \e[0;37m$2\e[0m\n"
}

help() {
	print_info help "Display callable targets"
	print_info build "Create a datapack zip file"
	print_info clean "Remove build artifacts"
}

build() {
	clean
	zip -q -r ${ZIP_NAME} data pack.mcmeta pack.png
}

clean() {
	rm -f ${ZIP_NAME}
}

if [ ${1:+x} ]; then
	$1
else
	help
fi
	