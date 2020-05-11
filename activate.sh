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

declare -a DEPS_NEEDED
DEPS_NEEDED=(curl)
command -v tar || DEPS_NEEDED+=("tar")
command -v yum-config-manager || DEPS_NEEDED+=("yum-utils")
test -z "${DEPS_NEEDED}" || ( echo "Installing dependencies and updating curl..." && yum install -y "${DEPS_NEEDED[@]}")

echo "Extracting *.repo files from ${CENTOS_VAULT_SCL_TAR}"
echo "into $(pwd)..."
curl -sL "${CENTOS_VAULT_SCL_TAR}" | tar -v --strip-components=1 -xz '*.repo'
ls -lah

# e.g. 7.7.1908
CENTOS_RELEASE=${CENTOS_RELEASE:-$(grep -oP '[\d\.]+' /etc/centos-release)}

# Enable older archives for devtoolset-3, devtoolset-6, etc
# if CentOS 7.7 and newer (test via build number)
[ "${CENTOS_RELEASE##*.}" -le 1810 ] || CENTOS_RELEASE="7.6.1810"

for SUFFIX in sclo rh
do
    REPO="C${CENTOS_RELEASE}-centos-sclo-${SUFFIX}"
    echo "Enabling ${REPO}..."
    yum-config-manager --enable "${REPO}" | grep -q '^enabled = '
done

echo '========================================================================'
echo 'You shoud be able to install packages like devtoolset-3 now!'
