#!/bin/bash

################################################################
# This script checks existence of ssl.crt on host.             #
# Script returns 0 if both ssl.crt and rootca.cer are present  #
# Script returns 1 if neither ssl.crt nor rootca.cer is present#
# Author: xsougha Date: <>				       #
################################################################

om_infra_primary=$1

# On om_infra_primary
ssh $om_infra_primary 'ls -lrt /var/tmp | grep "ssl.crt"' >/dev/null || echo "ssl.crt is not present on omsrvm";exit $?
ssh $om_infra_primary 'ls -lrt /var/tmp | grep "rootca.cer"' >/dev/null || echo "rootca.cer is not present on omsrvs";exit $?
