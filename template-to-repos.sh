#!/bin/bash
set -eu -o pipefail

for VARIANT in sclo rh
do
    SUB_EXPR="s/<VARIANT>/$VARIANT/"
    sed -n "1, 5 { $SUB_EXPR; p }" CentOS-Vault-SCLo-scl-TEMPLATE.repo > CentOS-Vault-SCLo-${VARIANT}.repo
    for I in 7.1.1503 7.2.1511 7.3.1611 7.4.1708 7.5.1804 7.6.1810
    do
        sed -n "6, $ { $SUB_EXPR; s/<VERSION>/$I/g; p }" CentOS-Vault-SCLo-scl-TEMPLATE.repo >> CentOS-Vault-SCLo-${VARIANT}.repo
    done
done