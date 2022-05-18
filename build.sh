#!/bin/bash

test -f "$(dirname ${0})/.env" && {
  set -a
  source "$(dirname ${0})/.env"
  set +a
}

rm -rf "./dist"

python3 setup.py sdist

VERSION=$(grep -m1 -Po '(?<=^Version:\s).*$' ./pgpkms.egg-info/PKG-INFO)
: "${VERSION:?Version could not be determined}"

umask 022

mkdir -p "./dist/deb/usr/lib/python3/dist-packages"

tar --extract \
	--strip-components=1 \
	--directory="./dist/deb/usr/lib/python3/dist-packages" \
	--file="./dist/pgpkms-${VERSION}.tar.gz" \
	"pgpkms-${VERSION}/pgpkms" \
	"pgpkms-${VERSION}/pgpkms.egg-info"

mv --force \
	"./dist/deb/usr/lib/python3/dist-packages/pgpkms.egg-info" \
	"./dist/deb/usr/lib/python3/dist-packages/pgpkms-${VERSION}.egg-info"

mkdir -p "./dist/deb/DEBIAN"
mkdir -p "./dist/deb/usr/bin"
mkdir -p "./dist/deb/etc/default"
mkdir -p "./dist/deb/usr/share/doc/python3-pgpkms"

install --mode=755 pgpkms.sh "./dist/deb/usr/bin/pgpkms"
install --mode=644 README.md "./dist/deb/usr/share/doc/python3-pgpkms/README.md"
install --mode=644 NOTICE.md "./dist/deb/usr/share/doc/python3-pgpkms/NOTICE.md"
install --mode=644 LICENSE.md "./dist/deb/usr/share/doc/python3-pgpkms/LICENSE.md"

cat >> "./dist/deb/etc/default/pgpkms" <<-EOF
	# PGP_KMS_KEY specifies the default key ID for "pgpkms"
	#PGP_KMS_KEY=alias/MyPgpKey
	# PGP_KMS_HASH specifies the hashing algorithm used by "pgpkms"
	#PGP_KMS_HASH=sha256
	EOF

cat >> "./dist/deb/DEBIAN/control" <<-EOF
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

cat >> "./dist/deb/DEBIAN/conffiles" <<-EOF
	/etc/default/pgpkms
	EOF

dpkg-deb --root-owner-group -b "./dist/deb" "./python3-pgpkms_${VERSION}-1_all.deb"

if test "${1}" = "upload"; then
	twine upload "./dist/pgpkms-${VERSION}.tar.gz"
fi
