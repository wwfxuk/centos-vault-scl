#!/bin/bash

#
# usage: activate.sh
#
# Fetch and activate vault/archive sclo repositories for current CentOS 7
# version. Will also download required dependencies if missing:
#
# - tar, e.g. missing on CentOS 7.1
# - yum-config-manager, e.g. missing on CentOS 7.1
#
# If any of the required dependencies are installed, curl will also be updated
# so it can also pull/download from GitHub (more modern NSS).
#
# ENVIRONMENT VARIABLES
#
#   GITHUB_SHA: Custom commit SHA to pull from GitHub,
#               instead of the default master branch.
#
set -eu -o pipefail

cd /etc/yum.repos.d/
CENTOS_VAULT_SCL_TAR="https://github.com/wwfxuk/centos-vault-scl/archive/${GITHUB_SHA:-master}.tar.gz"

DEPS_NEEDED=""
command -v tar || DEPS_NEEDED+=" tar"
command -v yum-config-manager || DEPS_NEEDED+=" yum-utils"
test -z "${DEPS_NEEDED}" || ( echo "Installing dependencies and updating curl..." && yum install -y $DEPS_NEEDED curl)

echo "Extracting *.repo files from ${CENTOS_VAULT_SCL_TAR}"
echo "into $(pwd)..."
curl -sL "${CENTOS_VAULT_SCL_TAR}" | tar -v --strip-components=1 -xz '*.repo'
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

echo '========================================================================'
echo 'You shoud be able to install packages like devtoolset-3 now!'
