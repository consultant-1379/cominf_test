element * CHECKEDOUT

# Some standard paths, where we want ppl to work on /main/LATEST
element /vobs/oss_sck/isobuild/... /main/LATEST
element /vobs/oss_sck/html/... /main/LATEST
element /vobs/oss_sck/tools/... /main/LATEST

element * .../dmr-ombs/LATEST
element * ERICDMR-R3V01 -mkbranch dmr-ombs
element * .../dmr-r3/LATEST -mkbranch dmr-ombs
element * .../dmr-r2/LATEST -mkbranch dmr-r3

element * /main/LATEST -mkbranch dmr-r3
