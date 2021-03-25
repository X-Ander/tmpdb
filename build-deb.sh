#!/bin/sh

DEBFULLNAME="$1"
DEBEMAIL="$2"

if [ -z "$DEBFULLNAME" ]; then
	echo "No full name specified"
	exit 1
fi

if [ -z "$DEBEMAIL" ]; then
	echo "No email specified"
	exit 1
fi

export DEBFULLNAME
export DEBEMAIL

WORKDIR='/tmp/build-deb'
[ -d "$WORKDIR" ] || mkdir "$WORKDIR" || exit 1

MAIN_PM='lib/DBIx/TmpDB.pm'
VERSION=`grep -m 1 '^our \$VERSION' "$MAIN_PM" | grep -o '[0-9.]\+'`

if [ -z "$VERSION" ]; then
	echo "Can't get the package version"
	exit 1
fi

SRC_DIR_NAME="DBIx-TmpDB-$VERSION"
SRC_DIR="$WORKDIR/$SRC_DIR_NAME"

if [ -d "$SRC_DIR" ]; then
	rm -rf "$SRC_DIR"
fi
if [ -e "$SRC_DIR" ]; then
	echo "$SRC_DIR exists and I can't remove it"
	exit 1
fi

mkdir "$SRC_DIR" || exit 1

cat MANIFEST | while read SRC_FILE; do
	case "$SRC_FILE" in
		*/*)
			DIR=${SRC_FILE%/*}
			mkdir -p "$SRC_DIR/$DIR" || exit 1
			;;
	esac
	cp "$SRC_FILE" "$SRC_DIR/$SRC_FILE" || exit 1
done

cd "$WORKDIR"

PKG_NAME='libdbix-tmpdb-perl'

tar czf "${PKG_NAME}_$VERSION.orig.tar.gz" "$SRC_DIR_NAME"

dh-make-perl "$SRC_DIR_NAME"
cd "$SRC_DIR_NAME"
debuild
