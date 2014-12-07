#/bin/bash

set -e

mkdir -p /srv/pypy/bin

if [ -e /srv/pypy/.bootstrapped ]; then
  exit 0
fi

cd /srv/pypy

PYPY_VERSION=2.4.0

wget https://bitbucket.org/pypy/pypy/downloads/pypy-$PYPY_VERSION-linux64.tar.bz2
tar -xf pypy-$PYPY_VERSION-linux64.tar.bz2
ln -s pypy-$PYPY_VERSION-linux64 pypy

## library fixup
mkdir pypy/lib
ln -s /lib64/libncurses.so.5.9 /srv/pypy/pypy/lib/libtinfo.so.5

cat > /srv/pypy/bin/python <<EOF
#!/bin/bash
LD_LIBRARY_PATH=/srv/pypy/pypy/lib:$LD_LIBRARY_PATH /srv/pypy/pypy/bin/pypy "\$@"
EOF

chmod +x /srv/pypy/bin/python
/srv/pypy/bin/python --version

touch /srv/pypy/.bootstrapped
