#!/bin/bash

################################################################
# This script checks existence of ssl.crt on host.             #
# Script returns 0 if both ssl.crt and rootca.cer are present  #
# Script returns 1 if neither ssl.crt nor rootca.cer is present#
# Author: xsougha Date: <>				       #
################################################################

om_infra_secondary=$1

# On om_infra_secondary
ssh $om_infra_secondary 'ls -lrt /var/tmp | grep "ssl.crt"' >/dev/null || echo $?;exit
ssh $om_infra_secondary 'ls -lrt /var/tmp | grep "rootca.cer"' >/dev/null || echo $?;exit
