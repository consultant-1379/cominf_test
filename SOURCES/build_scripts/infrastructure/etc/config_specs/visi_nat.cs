#### -----------------------------------------------------------------------------
####
####                       platform config spec
####
####               CIF - development, R5 Config Spec
####                            Based on R4 shipment J.2 code base
####                   Unix version
####Visibroker
#### -----------------------------------------------------------------------------
element *       CHECKEDOUT

# IMPORTANT! Don't make changes to the following section
# It selects the template for this config-spec.
# =================================================================================
element -directory      /vobs/config_svz/...                                    /main/LATEST
element                 /vobs/config_svz/cif/ossrc_r5/dev/...                   /main/LATEST
element                 /vobs/config_svz/cif/ossrc_r5/include/...               /main/LATEST
element                 /vobs/config_svz/script/...                             /main/LATEST
element                 /vobs/config_svz/bin/...                                /main/LATEST
element                 /vobs/config_svz/adm/...                                /main/LATEST
element                 /vobs/config_svz/doc/...                                /main/LATEST
# ==================================================================================
# Rule to provide access to deliver_ossrc and CO scripts

element                 /vobs/wds/cc_support/...                                /main/LATEST

# ==================================================================================

#element           /vobs/fw/fw_support/...               /main/LATEST
element           /vobs/fw/cif2_derived                 /main/LATEST
element         /vobs/fw/cif2_derived/stored/...      /main/LATEST
element           /vobs/fw/cif2_derived/internal_release/...  /main/LATEST



# CIF tools
# ---------------------------------------------------------------------------------


element          /vobs/fw/cif2_adm/...                .../dev_r7a01_tools/LATEST
element          /vobs/fw/cif2_makesystem/tools/...   .../dev_r7a01_tools/LATEST
mkbranch dev_r7a01_tools
  element            /vobs/fw/cif2_adm/...            R4_BASE
  element        /vobs/fw/cif2_adm/...                /main/0
  element        /vobs/fw/cif2_makesystem/tools/...   R4_BASE
  element        /vobs/fw/cif2_makesystem/tools/...   /main/0
end mkbranch



# CIF product documentation
# ---------------------------------------------------------------------------------


element                  /vobs/fw/cif2_doc/...        .../dev_r7a01_doc/LATEST
mkbranch dev_r7a01_doc
  element                /vobs/fw/cif2_doc/...        R4_BASE
  element -directory     /vobs/fw/cif2_doc/...        CIF_R3A03
  element -file          /vobs/fw/cif2_doc/...        CIF_R3A03  -nocheckout
  element                /vobs/fw/cif2_doc/...         /main/0
end mkbranch



# RanosDocs for NSA/DSA work
# ----------------------------

element -directory       /vobs/ranos/RanosDoc         /main/LATEST
element                  /vobs/ranos/RanosDoc/...     /main/LATEST

# 3pp:s, CD images
# ---------------------------------------------------------------------------------
#element -directory       /vobs/fw/cif2_CDimage                    /main/LATEST
#element                  /vobs/fw/cif2_CDimage/cd_images/...      /main/LATEST

#Configuration done for 3pp hub testing

element                  /vobs/3pp/...                            .../3pp_ossrc_design/LATEST
element                  /vobs/3pp/...                            .../wip_ba_ossrc_dev/LATEST -mkbranch 3pp_ossrc_design
element                  /vobs/3pp/...                            .../3pp_ossrc_design/LATEST
element                  /vobs/3pp/...                            .../at_ossrc_dev_r5/LATEST -mkbranch 3pp_ossrc_design
element                  /vobs/3pp/...                            .../3pp_ossrc_design/LATEST
element                  /vobs/3pp/...                            .../at_ossrc_dev/LATEST -mkbranch 3pp_ossrc_design
element                  /vobs/3pp/...                            .../3pp_ossrc_design/LATEST
element                  /vobs/3pp/...                            /main/LATEST -mkbranch 3pp_ossrc_design


## Include 3pp and Jars rules
## --------------------------------------------------------------------------------
#include /vobs/config_svz/cif/ossrc_r5/include/3pp_rules.cs

## CIF development
## --------------------------------------------------------------------------------




#element -directory  /vobs/oss_rc3/cif/rc3_cifLMI_delivery/container/...     /main/LATEST
element *  NEW_CSIDLS
element .../nms_cs/...                  ERICFCS-R5_R1B08        -nocheckout
element .../nms_cif_mp/...                  ERICFMP-R5_R1B05        -nocheckout
element            *                                    .../old_cif_build/LATEST
element            *                                    PRE_SWDI_MOVE -mkbranch old_cif_build
element            *                                        .../at_ossrc_dev/LATEST
element           /vobs/ext_platform_r5_delivery/...      /main/LATEST -mkbranch at_ossrc_dev
element            *                                        /main/0 -mkbranch at_ossrc_dev



#elements for 3PP HUB migration testing

#element * .../wip_ba_ossrc_dev/LATEST
#element * .../3pp_ossrc_design/LATEST
#element * .../wip_ba_ossrc_dev/LATEST -mkbranch 3pp_ossrc_design
#element * /main/LATEST

