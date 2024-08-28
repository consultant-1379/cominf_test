element * CHECKEDOUT

# Some standard paths, where we want ppl to work on /main/LATEST
element /vobs/oss_sck/isobuild/... /main/LATEST
element /vobs/oss_sck/html/... /main/LATEST
element /vobs/oss_sck/tools/... /main/LATEST

element * .../o14.2/LATEST
mkbranch o14.2
#updates to ensure that the 13B latest changes are in 14A for infra products
element * ERICBLADE-O14.0_R5A02
element * ERICJUMP-O14.1_R5A02
element * ERICLU-O12.2_R1A01
element * ERICSOL-O13.2_R19C01
element * ERICSTMNAS-R1M01
element * ERICSTMAPI-R1S01
element * ERICIPTOOL-O13.0_R1B01_EC02
element * JASSCUSTM-O14.1_R9A01
element * ERICGEORED-O13.0_R1A02
element * ERICMIRVM-O13.0_R1A02
element * CXP9017501_R6A01
element * CXP9022190_R1B01_EC02
element * CXP9017928_R5A03
element * CXP9018679_R1N01
element * CXP9017509_R7A03
element * CXP9017500_R6B01
element * CXP9018684_R2A01
element * CXP9017505_R5A01
element * CXP9017654_R2A01
element * .../o14.1/LATEST
element * .../o14.0/LATEST
element * .../o13.2.scalar/LATEST
element * .../o13.2/LATEST
element * .../o13.0/LATEST
element * .../o12.2/LATEST
element * .../o12.1/LATEST
element * .../o12.0/LATEST
element * .../o11.3/LATEST
element * .../o11.2/LATEST
element .../ERIClusck/... .../r6.3/LATEST

# This is branching off O11.1.1
element * .../o11.1/LATEST
element * .../o11.0/LATEST
element * .../o10.3/LATEST
element * .../o10.2/LATEST
element * .../o10.1/LATEST
element * .../r10.0/LATEST
element * .../r7.2/LATEST
element * .../r7.1/LATEST
element * .../r7.0/LATEST
element * .../r6.3/LATEST
element * .../r6.2/LATEST
element * .../r6.1/LATEST
element * .../r6.0/LATEST
element * .../r5.3/LATEST 
element * .../r5/LATEST 
element * .../r5_0/LATEST

element * /main/LATEST
end mkbranch
