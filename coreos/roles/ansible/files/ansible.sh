#/bin/bash

set -e

if [ -f /opt/bin/python ]; then
  exit 0
fi

mkdir -p /srv/pypy
cd /srv/pypy

echo "73014c3840609a62c0984b9c383652097f0a8c52fb74dd9de70d9df2a9a743ff  pypy-5.3.1-linux_x86_64-portable.tar.bz2" > /srv/pypy/shas.txt
wget -q https://bitbucket.org/squeaky/portable-pypy/downloads/pypy-5.3.1-linux_x86_64-portable.tar.bz2
sha256sum -c /srv/pypy/shas.txt
tar -xf pypy-5.3.1-linux_x86_64-portable.tar.bz2 

mkdir -p /opt/bin
ln -sf /srv/pypy/pypy-5.3.1-linux_x86_64-portable/bin/pypy /opt/bin/python
chmod +x /opt/bin/python
/opt/bin/python --version

