#!/usr/bin/python
import sys
sys.path.append('/var/tmp/platform_taf/harness/lib/')
import atnfdlib   # imports atnfdlib.py
shipment=sys.argv[1]
product_number=sys.argv[2]
version=sys.argv[3]
atnfdlib.assertCpStatus(shipment,product_number,version)

