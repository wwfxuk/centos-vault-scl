#!/bin/bash
set -eu -o pipefail

cd /etc/yum.repos.d/
echo "Extracting into $(pwd)..."
curl -sL https://github.com/wwfxuk/centos-vault-scl/archive/${GITHUB_SHA:-master}.tar.gz \
    | tar -v --strip-components=1 -xz '*.repo'
ls -lah

CENTOS_RELEASE=$(grep -oP '[\d\.]+' /etc/centos-release)

echo "Enabling C${CENTOS_RELEASE}-centos-sclo-sclo..."
yum-config-manager --enable C${CENTOS_RELEASE}-centos-sclo-sclo | grep -q '^enabled = '

echo "Enabling C${CENTOS_RELEASE}-centos-sclo-rh..."
yum-config-manager --enable C${CENTOS_RELEASE}-centos-sclo-rh | grep -q '^enabled = '


echo "Disabling centos-sclo-sclo..."
yum-config-manager --disable centos-sclo-sclo | grep -q '^enabled = '


echo "Disabling centos-sclo-rh..."
yum-config-manager --disable centos-sclo-rh | grep -q '^enabled = '

echo "========================================================================"
echo "You shoud be able to install packages like devtoolset-3 now!"
