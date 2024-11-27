import os
import siliconcompiler
from lambdapdk import register_data_source


####################################################
# PDK Setup
####################################################
def setup():
    foundry = 'virtual'
    process = 'mc1'
    rev = 'r0p0'
    stackup = '10M'
    libtype = '10t'
    node = 1000
    wafersize = 256 * 1000
    hscribe = 1
    vscribe = 1
    edgemargin = 1
    d0 = 1.25

    pdkdir = "./pdk_gen"

    pdk = siliconcompiler.PDK(process, package='lambdapdk')
    register_data_source(pdk)

    # process name
    pdk.set('pdk', process, 'foundry', foundry)
    pdk.set('pdk', process, 'node', node)
    pdk.set('pdk', process, 'version', rev)
    pdk.set('pdk', process, 'stackup', stackup)
    pdk.set('pdk', process, 'wafersize', wafersize)
    pdk.set('pdk', process, 'edgemargin', edgemargin)
    pdk.set('pdk', process, 'scribe', (hscribe, vscribe))
    pdk.set('pdk', process, 'd0', d0)

    # APR Setup
    for tool in ('openroad', 'magic'):
        pdk.set('pdk', process, 'aprtech', tool, stackup, libtype, 'lef',
                pdkdir + '/tech.lef')

    pdk.set('pdk', process, 'minlayer', stackup, 'metal1')
    pdk.set('pdk', process, 'maxlayer', stackup, 'metal9')

    # Klayout setup file
    # pdk.set('pdk', process, 'layermap', 'klayout', 'def', 'klayout', stackup,
    #         pdkdir + '/setup/klayout/freepdk45.lyt')

    # pdk.set('pdk', process, 'display', 'klayout', stackup, pdkdir + '/setup/klayout/freepdk45.lyp')

    # Openroad global routing grid derating
    openroad_layer_adjustments = {
        'metal1': 1.0,
        'metal2': 1.0,
        'metal3': 1.0,
        'metal4': 1.0,
        'metal5': 1.0,
        'metal6': 1.0,
        'metal7': 1.0,
        'metal8': 1.0,
        'metal9': 1.0,
    }
    for layer, adj in openroad_layer_adjustments.items():
        pdk.set('pdk', process, 'var', 'openroad', f'{layer}_adjustment', stackup, str(adj))

    pdk.set('pdk', process, 'var', 'openroad', 'rclayer_signal', stackup, 'metal3')
    pdk.set('pdk', process, 'var', 'openroad', 'rclayer_clock', stackup, 'metal5')

    pdk.set('pdk', process, 'var', 'openroad', 'pin_layer_vertical', stackup, 'metal6')
    pdk.set('pdk', process, 'var', 'openroad', 'pin_layer_horizontal', stackup, 'metal5')

    # PEX
    pdk.set('pdk', process, 'pexmodel', 'openroad', stackup, 'typical',
            pdkdir + '/pex/openroad/typical.tcl')
    pdk.set('pdk', process, 'pexmodel', 'openroad-openrcx', stackup, 'typical',
            pdkdir + '/pex/openroad/typical.rules')

    return pdk


# #########################
# if __name__ == "__main__":
#     pdk = setup()
#     register_data_source(pdk)
#     pdk.check_filepaths()