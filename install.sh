#!/bin/sh

# This script installs the Nix package manager on your system by
# downloading a binary distribution and running its installer script
# (which in turn creates and populates /nix).

{ # Prevent execution if this script was only partially downloaded
oops() {
    echo "$0:" "$@" >&2
    exit 1
}

umask 0022

tmpDir="$(mktemp -d -t nix-binary-tarball-unpack.XXXXXXXXXX || \
          oops "Can't create temporary directory for downloading the Nix binary tarball")"
cleanup() {
    rm -rf "$tmpDir"
}
trap cleanup EXIT INT QUIT TERM

require_util() {
    command -v "$1" > /dev/null 2>&1 ||
        oops "you do not have '$1' installed, which I need to $2"
}

case "$(uname -s).$(uname -m)" in
    Linux.x86_64)
        hash=60c4efec34866dea8fe8f42bfdd878cf6557b9c3035cc5f2208aa0133d404736
        path=w6qyjm5zvbjfldsabakyq7dlgby6zxbl/nix-2.19.1-x86_64-linux.tar.xz
        system=x86_64-linux
        ;;
    Linux.i?86)
        hash=a406537103476e46216558b8b2598f39b4483ec5bc0111e5e07630992f3d4bec
        path=1l3nz9l6yjzyr5mfir19zz8gyiw21dks/nix-2.19.1-i686-linux.tar.xz
        system=i686-linux
        ;;
    Linux.aarch64)
        hash=32ca11367a2ab6bb7704d993b2d5928b9914e284256b85795c21b02248d72a8e
        path=4zr6sfxslhshzp6k4fizjfx2149j5l9a/nix-2.19.1-aarch64-linux.tar.xz
        system=aarch64-linux
        ;;
    Linux.armv6l)
        hash=7153bcf69d3620027700433b10ff1dac92b9c0d9840126261ee0c9ae403a856c
        path=0267276lykscggv332ya2z92vlw0g6yd/nix-2.19.1-armv6l-linux.tar.xz
        system=armv6l-linux
        ;;
    Linux.armv7l)
        hash=64c5b45303c1de5319be3eb85b5502f918dbd55aaa00f62b4a792defa63714f2
        path=6nmsqx7hlqbvxh5bii74ayahd6v7n3qa/nix-2.19.1-armv7l-linux.tar.xz
        system=armv7l-linux
        ;;
    Darwin.x86_64)
        hash=0e5d64e2b3a789263af553a3dd2e0a9445b1ec9c2e1c5e864ec178e107626eb7
        path=1ncnlwhjbkif6hh906zibc12kvx2i6ri/nix-2.19.1-x86_64-darwin.tar.xz
        system=x86_64-darwin
        ;;
    Darwin.arm64|Darwin.aarch64)
        hash=ae7a0511f380bb125542f03c4482ddf760ebf51d037d28cd2ed73272621a7a9f
        path=48jw1dqf9g7skns8hmd4ahzx3lhijfcy/nix-2.19.1-aarch64-darwin.tar.xz
        system=aarch64-darwin
        ;;
    *) oops "sorry, there is no binary distribution of Nix for your platform";;
esac

# Use this command-line option to fetch the tarballs using nar-serve or Cachix
if [ "${1:-}" = "--tarball-url-prefix" ]; then
    if [ -z "${2:-}" ]; then
        oops "missing argument for --tarball-url-prefix"
    fi
    url=${2}/${path}
    shift 2
else
    url=https://releases.nixos.org/nix/nix-2.19.1/nix-2.19.1-$system.tar.xz
fi

tarball=$tmpDir/nix-2.19.1-$system.tar.xz

require_util tar "unpack the binary tarball"
if [ "$(uname -s)" != "Darwin" ]; then
    require_util xz "unpack the binary tarball"
fi

if command -v curl > /dev/null 2>&1; then
    fetch() { curl --fail -L "$1" -o "$2"; }
elif command -v wget > /dev/null 2>&1; then
    fetch() { wget "$1" -O "$2"; }
else
    oops "you don't have wget or curl installed, which I need to download the binary tarball"
fi

echo "downloading Nix 2.19.1 binary tarball for $system from '$url' to '$tmpDir'..."
fetch "$url" "$tarball" || oops "failed to download '$url'"

if command -v sha256sum > /dev/null 2>&1; then
    hash2="$(sha256sum -b "$tarball" | cut -c1-64)"
elif command -v shasum > /dev/null 2>&1; then
    hash2="$(shasum -a 256 -b "$tarball" | cut -c1-64)"
elif command -v openssl > /dev/null 2>&1; then
    hash2="$(openssl dgst -r -sha256 "$tarball" | cut -c1-64)"
else
    oops "cannot verify the SHA-256 hash of '$url'; you need one of 'shasum', 'sha256sum', or 'openssl'"
fi

if [ "$hash" != "$hash2" ]; then
    oops "SHA-256 hash mismatch in '$url'; expected $hash, got $hash2"
fi

unpack=$tmpDir/unpack
mkdir -p "$unpack"
tar -xJf "$tarball" -C "$unpack" || oops "failed to unpack '$url'"

script=$(echo "$unpack"/*/install)

[ -e "$script" ] || oops "installation script is missing from the binary tarball!"
export INVOKED_FROM_INSTALL_IN=1
"$script" "$@"

} # End of wrapping
