#!/bin/bash
set -eu -o pipefail

TEMPLATE=${TEMPLATE:-CentOS-Vault-SCLo-scl.template}
VERSIONS=${@:-7.1.1503 7.2.1511 7.3.1611 7.4.1708 7.5.1804 7.6.1810 7.7.1908}

for VARIANT in sclo rh
do
    SUB_EXPR=""
    if [ "${VARIANT}" == "rh" ]
    then
        REPO_FILE=CentOS-Vault-SCLo-scl-rh.repo
    else
        REPO_FILE=CentOS-Vault-SCLo-scl.repo
    fi

    sed -n "1, 5 { s/<FILE>/${REPO_FILE/-Vault/}/; p }" ${TEMPLATE} > ${REPO_FILE}
    for I in ${VERSIONS}
    do
        sed -n "6, $ { s/<VARIANT>/$VARIANT/; s/<VERSION>/$I/g; p }" ${TEMPLATE} >> ${REPO_FILE}
    done
done
