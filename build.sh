#!/bin/bash

rm -rf "./dist"
mkdir -p "./dist"

pip install --target="./dist/usr/lib/python3/dist-packages" .
find "./dist" -name "__pycache__" -type d -print0 | xargs -r -0 rm -rf

mkdir -p "./dist/usr/share/doc/python3-pgpkms"
cp README.md LICENSE.md NOTICE.md "./dist/usr/share/doc/python3-pgpkms"

mkdir -p "./dist/usr/bin"
install --mode=755 pgpkms.sh "./dist/usr/bin/pgpkms"

VERSION="$(find dist -type f -name METADATA | xargs grep '^Version:' | cut -d: -f2 | xargs echo)"
test -z "${VERSION}" && {
	echo "No version found"
	exit 1
}

mkdir -p "./dist/DEBIAN"
cat >> "./dist/DEBIAN/control" <<-EOF
	Package: python3-pgpkms
	Architecture: all
	Priority: optional
	Section: python
	Version: ${VERSION}-1
	Maintainer: Juit Developers <developers@juit.com>
	Homepage: https://github.com/juitnow/pgpkms
	Depends: python3:any, python3-botocore (>= 1.23.34), python3-pyasn1 (>= 0.4.8), python3-pyasn1-modules (>= 0.2.1)
	Description: Use AWS KMS keys to generate GnuPG/OpenPGP compatible signatures
	EOF

dpkg-deb -b "./dist" "./python3-pgpkms_${VERSION}-1_all.deb"
