
setDesignMode -process 250
source /data/cmk91/mc_pdk/pdk_gen/techfile.tcl
set DESIGN_NAME top
set SYN_PATH /data/cmk91/mc_pdk/run/syn_out/
# disable warnings for the liberty file lacking power model
suppressMessage TECHLIB-1329
