#!/bin/bash

#
# usage: activate.sh
#
# Fetch and activate vault/archive sclo repositories for current/older CentOS 7
# version which will have deprecated packages e.g. devtoolset-6.
#
# Will also download/update required dependencies if missing:
#
# - tar, i.e. for CentOS 7.1 where curl will be updated so it can
#   also pull/download from GitHub (requires more modern NSS).
# - yum-config-manager, for CentOS 7.1 and 7.2
#
# CentOS 7.7 and newer will actually activate 7.6's archive repository, which
# is the latest CentOS 7 before older packages like devtoolset-6 got removed.
#
# ENVIRONMENT VARIABLES
#
#   SCL_TAR_SHA: Custom commit SHA to pull from GitHub,
#                instead of the default master branch.
#                Didn't use GITHUB_SHA directly here in-case this
#                script was called from other project's CI.
#
set -eu -o pipefail


# Bash array's "${VAR[@]}" quoted expansion better for arguments to commands
declare -a DEPS_NEEDED
command -v tar || DEPS_NEEDED+=("tar" "curl")  # missing/needs updating for 7.1
command -v yum-config-manager || DEPS_NEEDED+=("yum-utils")  # missing for 7.1 and 7.2
test -z "${DEPS_NEEDED}" || ( echo "Installing dependencies and updating curl..." && yum install -y "${DEPS_NEEDED[@]}")

CENTOS_VAULT_SCL_TAR="https://github.com/wwfxuk/centos-vault-scl/archive/${SCL_TAR_SHA:-master}.tar.gz"
cd /etc/yum.repos.d/
echo "Extracting *.repo files from ${CENTOS_VAULT_SCL_TAR}"
echo "into $(pwd)..."
curl -sL "${CENTOS_VAULT_SCL_TAR}" | tar -v --strip-components=1 -xz '*.repo'
ls -lah


# Enable older archives if CentOS 7.7 and newer (test via build number)
# e.g. CENTOS_RELEASE=7.7.1908, "${CENTOS_RELEASE##*.}" = 1908
CENTOS_RELEASE=${CENTOS_RELEASE:-$(grep -oP '[\d\.]+' /etc/centos-release)}
[ "${CENTOS_RELEASE##*.}" -le 1810 ] || CENTOS_RELEASE="7.6.1810"
for SUFFIX in sclo rh
do
    REPO="C${CENTOS_RELEASE}-centos-sclo-${SUFFIX}"
    echo "Enabling ${REPO}..."
    yum-config-manager --enable "${REPO}" | grep -q '^enabled = '
done

echo '========================================================================'
echo 'You shoud also be able to install older packages like devtoolset-3 now!'
