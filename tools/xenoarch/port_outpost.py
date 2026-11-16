"""Port the 2013 ATMTA research outpost onto the current mining asteroid.

Source: ExcidiumStation/ATMTA commit c7bd71244aa2ea6c5d8d951cba87b9c47750c21f,
maps/tgstation.2.1.0.0.1.dmm, z-level 5. The outpost occupies the same
coordinates on both maps (x 143..191, y 183..213).

Usage (from the repository root):
    python tools/xenoarch/port_outpost.py OLD_MAP BASE_MAP OUT_MAP

BASE_MAP must be a mining asteroid map without the outpost (for example
`git show 96d8fc1f:_maps/map_files/generic/MiningAsteroid.dmm`). The script
never edits its inputs. It prints every dropped or unknown atom.
"""
import sys
from collections import Counter, defaultdict
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from dmm import DMM, atom_type, atom_vars, make_atom  # noqa: E402
from typeindex import load_types  # noqa: E402

OLD_Z = 5
OUTPOST_AREA = '/area/research_outpost'
SHUTTLE_AREA = '/area/shuttle/research/outpost'
XENOARCH = 65
RESEARCH = 47
ENGINEERING = 10
ATMOSPHERICS = 24
NORTH, SOUTH, EAST, WEST = 1, 2, 4, 8
DIRS = (NORTH, SOUTH, EAST, WEST)
STEP = {NORTH: (0, 1), SOUTH: (0, -1), EAST: (1, 0), WEST: (-1, 0)}
REVERSE = {NORTH: SOUTH, SOUTH: NORTH, EAST: WEST, WEST: EAST}

dropped = Counter()
unknown = Counter()


def q(text):
    return '"' + text + '"'


def unq(value):
    if value is None:
        return None
    value = value.strip()
    if value.startswith('"') and value.endswith('"'):
        return value[1:-1]
    return value


def wall_side(v):
    """Direction of the wall a wall-mounted object hangs on, from its pixel offsets."""
    px = int(float(v.get('pixel_x', '0') or 0))
    py = int(float(v.get('pixel_y', '0') or 0))
    if abs(py) >= abs(px) and py:
        return NORTH if py > 0 else SOUTH
    if px:
        return EAST if px > 0 else WEST
    return None


def keep(v, *names):
    return {k: v[k] for k in names if k in v}


def pixels(v):
    out = {}
    for k in ('pixel_x', 'pixel_y'):
        if k in v and v[k] not in ('0', '0.0'):
            out[k] = v[k]
    return out


def with_dir(v, default=None):
    d = v.get('dir', default)
    return {'dir': d} if d not in (None, '2') else {}


PIPE_HEX = {'blue': '#1010dd', 'red': '#dd1010', 'cyan': '#10ddcc', 'green': '#10dd10', 'yellow': '#dddd10'}
TYPES = set()

PIPE_COLOURS = {'blue': 'blue', 'red': 'red', 'cyan': 'cyan', 'green': 'green', 'yellow': 'yellow'}

SIMPLE_MAP = {
    '/obj/machinery/hologram/holopad': '/obj/machinery/hologram/holopad',
    '/obj/machinery/vending/coffee': '/obj/machinery/vending/coffee',
    '/obj/machinery/vending/snack': '/obj/machinery/vending/snack',
    '/obj/machinery/chem_master': '/obj/machinery/chem_master',
    '/obj/machinery/reagentgrinder': '/obj/machinery/reagentgrinder',
    '/obj/machinery/recharge_station': '/obj/machinery/recharge_station',
    '/obj/machinery/space_heater': '/obj/machinery/space_heater',
    '/obj/machinery/floodlight': '/obj/machinery/floodlight',
    '/obj/machinery/hydroponics/soil': '/obj/machinery/hydroponics/soil',
    '/obj/machinery/mech_bay_recharge_port': '/obj/machinery/mech_bay_recharge_port',
    '/obj/machinery/computer/mech_bay_power_console': '/obj/machinery/computer/mech_bay_power_console',
    '/obj/machinery/portable_atmospherics/canister': '/obj/machinery/portable_atmospherics/canister',
    '/obj/machinery/portable_atmospherics/canister/air': '/obj/machinery/portable_atmospherics/canister/air',
    '/obj/machinery/portable_atmospherics/canister/carbon_dioxide': '/obj/machinery/portable_atmospherics/canister/carbon_dioxide',
    '/obj/machinery/portable_atmospherics/canister/nitrogen': '/obj/machinery/portable_atmospherics/canister/nitrogen',
    '/obj/machinery/portable_atmospherics/canister/toxins': '/obj/machinery/portable_atmospherics/canister/toxins',
    '/obj/machinery/portable_atmospherics/scrubber': '/obj/machinery/portable_atmospherics/scrubber',
    '/obj/machinery/power/smes': '/obj/machinery/power/smes',
    '/obj/machinery/power/emitter': '/obj/machinery/power/emitter',
    '/obj/machinery/artifact_analyser': '/obj/machinery/xenoarch/analyser',
    '/obj/machinery/artifact_harvester': '/obj/machinery/xenoarch/harvester',
    '/obj/machinery/artifact_scanpad': '/obj/structure/xenoarch_scanpad',
    '/obj/machinery/suspension_gen': '/obj/machinery/xenoarch/suspension',
    '/obj/machinery/atmospherics/valve': '/obj/machinery/atmospherics/binary/valve',
    '/obj/machinery/meter': '/obj/machinery/atmospherics/meter',
    '/obj/structure/closet/crate': '/obj/structure/closet/crate',
    '/obj/structure/closet/crate/hydroponics': '/obj/structure/closet/crate/hydroponics',
    '/obj/structure/closet/emcloset': '/obj/structure/closet/emcloset',
    '/obj/structure/closet/secure_closet/xenoarchaeologist': '/obj/structure/closet/secure_closet/xenoarchaeologist',
    '/obj/structure/dispenser': '/obj/structure/dispenser',
    '/obj/structure/dispenser/oxygen': '/obj/structure/dispenser/oxygen',
    '/obj/structure/grille': '/obj/structure/grille',
    '/obj/structure/ore_box': '/obj/structure/ore_box',
    '/obj/structure/plasticflaps/mining': '/obj/structure/plasticflaps',
    '/obj/structure/rack': '/obj/structure/rack',
    '/obj/structure/table': '/obj/structure/table',
    '/obj/structure/reagent_dispensers/fueltank': '/obj/structure/reagent_dispensers/fueltank',
    '/obj/structure/reagent_dispensers/watertank': '/obj/structure/reagent_dispensers/watertank',
    '/obj/structure/stool': '/obj/structure/chair/stool',
    '/obj/structure/stool/bed': '/obj/structure/bed',
    '/obj/structure/sign/greencross': '/obj/structure/sign/medbay/greencross',
    '/mob/living/carbon/monkey': '/mob/living/carbon/human/lesser/monkey',
    # Items
    '/obj/item/clothing/glasses/science': '/obj/item/clothing/glasses/science',
    '/obj/item/clothing/gloves/latex': '/obj/item/clothing/gloves/color/latex',
    '/obj/item/clothing/head/bio_hood/anomaly': '/obj/item/clothing/head/bio_hood/scientist',
    '/obj/item/clothing/suit/bio_suit/anomaly': '/obj/item/clothing/suit/bio_suit/scientist',
    '/obj/item/clothing/head/welding': '/obj/item/clothing/head/welding',
    '/obj/item/clothing/mask/breath': '/obj/item/clothing/mask/breath',
    '/obj/item/device/analyzer/plant_analyzer': '/obj/item/plant_analyzer',
    '/obj/item/device/camera': '/obj/item/camera',
    '/obj/item/device/flashlight/lamp': '/obj/item/flashlight/lamp',
    '/obj/item/nutrient/ez': '/obj/item/reagent_containers/cup/bottle/nutrient/ez',
    '/obj/item/stack/sheet/glass': '/obj/item/stack/sheet/glass',
    '/obj/item/stack/sheet/metal': '/obj/item/stack/sheet/metal',
    '/obj/item/weapon/anobattery': '/obj/item/xenoarch_battery',
    '/obj/item/weapon/anodevice': '/obj/item/xenoarch_utilizer',
    '/obj/item/weapon/bedsheet/brown': '/obj/item/bedsheet/brown',
    '/obj/item/weapon/cable_coil/random': '/obj/item/stack/cable_coil',
    '/obj/item/weapon/cell': '/obj/item/stock_parts/cell',
    '/obj/item/weapon/clipboard': '/obj/item/clipboard',
    '/obj/item/weapon/crowbar': '/obj/item/crowbar',
    '/obj/item/weapon/folder': '/obj/item/folder',
    '/obj/item/weapon/lighter/random': '/obj/item/lighter',
    '/obj/item/weapon/melee/baton': '/obj/item/melee/baton',
    '/obj/item/weapon/minihoe': '/obj/item/cultivator',
    '/obj/item/weapon/paper_bin': '/obj/item/paper_bin',
    '/obj/item/weapon/pen': '/obj/item/pen',
    '/obj/item/weapon/pickaxe': '/obj/item/pickaxe',
    '/obj/item/weapon/reagent_containers/dropper': '/obj/item/reagent_containers/dropper',
    '/obj/item/weapon/reagent_containers/glass/beaker/large': '/obj/item/reagent_containers/cup/beaker/large',
    '/obj/item/weapon/reagent_containers/glass/bottle/toxin': '/obj/item/reagent_containers/cup/bottle/toxin',
    '/obj/item/weapon/reagent_containers/glass/bucket': '/obj/item/reagent_containers/cup/bucket',
    '/obj/item/weapon/reagent_containers/spray/cleaner': '/obj/item/reagent_containers/spray/cleaner',
    '/obj/item/weapon/reagent_containers/spray/plantbgone': '/obj/item/reagent_containers/spray/plantbgone',
    '/obj/item/weapon/shovel/spade': '/obj/item/shovel/spade',
    '/obj/item/weapon/stamp': '/obj/item/stamp',
    '/obj/item/weapon/storage/belt/archaeology': '/obj/item/storage/belt/archaeology',
    '/obj/item/weapon/storage/belt/utility': '/obj/item/storage/belt/utility',
    '/obj/item/weapon/storage/box/beakers': '/obj/item/storage/box/beakers',
    '/obj/item/weapon/storage/box/excavation': '/obj/item/storage/box/excavation',
    '/obj/item/weapon/storage/box/gloves': '/obj/item/storage/box/gloves',
    '/obj/item/weapon/storage/box/lights/bulbs': '/obj/item/storage/box/lights',
    '/obj/item/weapon/storage/box/lights/mixed': '/obj/item/storage/box/lights/mixed',
    '/obj/item/weapon/storage/box/lights/tubes': '/obj/item/storage/box/lights/tubes',
    '/obj/item/weapon/storage/box/monkeycubes': '/obj/item/storage/box/monkeycubes',
    '/obj/item/weapon/storage/firstaid/fire': '/obj/item/storage/firstaid/fire',
    '/obj/item/weapon/storage/firstaid/o2': '/obj/item/storage/firstaid/o2',
    '/obj/item/weapon/storage/firstaid/regular': '/obj/item/storage/firstaid/regular',
    '/obj/item/weapon/storage/firstaid/toxin': '/obj/item/storage/firstaid/toxin',
    '/obj/item/weapon/storage/toolbox/emergency': '/obj/item/storage/toolbox/emergency',
    '/obj/item/weapon/storage/toolbox/mechanical': '/obj/item/storage/toolbox/mechanical',
    '/obj/item/weapon/weldingtool': '/obj/item/weldingtool',
}

BEAKERS = ('/obj/item/weapon/reagent_containers/glass/beaker',)

DROP = {
    '/obj/machinery/computer/research_shuttle',  # The research shuttle is not part of this port.
    '/obj/machinery/sleep_console',  # Modern sleepers have a built-in console.
    '/obj/machinery/mineral/input',  # Unloading machines use input_dir/output_dir.
    '/obj/machinery/mineral/output',
    '/obj/machinery/driver_button',  # No mass driver ever existed on this side.
    '/obj/machinery/bunsen_burner',
    '/obj/item/weedkiller/triclopyr',
    '/obj/item/weapon/storage/box/samplebags',
    '/obj/item/weapon/storage/box/solution_trays',
    '/obj/item/clothing/head/helmet/space/anomaly',  # Expedition lockers hold hardsuits.
    '/obj/item/clothing/suit/space/anomaly',
}


def access_list(*codes):
    return 'list(' + ','.join(str(c) for c in codes) + ')'


def convert_airlock(t, v):
    name = v.get('name')
    base = {
        '/obj/machinery/door/airlock': '/obj/machinery/door/airlock',
        '/obj/machinery/door/airlock/atmos': '/obj/machinery/door/airlock/atmos',
        '/obj/machinery/door/airlock/glass_atmos': '/obj/machinery/door/airlock/atmos/glass',
        '/obj/machinery/door/airlock/engineering': '/obj/machinery/door/airlock/engineering',
        '/obj/machinery/door/airlock/external': '/obj/machinery/door/airlock/external',
        '/obj/machinery/door/airlock/glass_medical': '/obj/machinery/door/airlock/medical/glass',
        '/obj/machinery/door/airlock/glass_mining': '/obj/machinery/door/airlock/mining/glass',
        '/obj/machinery/door/airlock/glass_research': '/obj/machinery/door/airlock/research/glass',
        '/obj/machinery/door/airlock/maintenance': '/obj/machinery/door/airlock/maintenance',
        '/obj/machinery/door/airlock/research': '/obj/machinery/door/airlock/research',
    }[t]
    out = {}
    if name and unq(name):
        out['name'] = q(unq(name).replace('Specotroscopy', 'Spectroscopy').replace('Isolation room', 'Isolation Room'))
    tag = unq(v.get('id_tag'))
    if tag:
        out['id_tag'] = q(tag)
    one = unq(v.get('req_one_access_txt'))
    req = unq(v.get('req_access_txt'))
    if one and one != '0':
        codes = [int(c) for c in one.split(';') if c]
        codes = [XENOARCH if c == RESEARCH else c for c in codes]
        if 11 in codes or 12 in codes:  # maintenance doors: outpost staff only
            codes = [XENOARCH]
        out['req_access'] = access_list(*sorted(set(codes)))
    elif req and req not in ('0', 'null'):
        out['req_access'] = access_list(XENOARCH)
    if base == '/obj/machinery/door/airlock' and tag and tag.startswith('r'):
        out.pop('req_access', None)  # dorms and bathroom
    return [make_atom(base, out)]


def convert(atom, ctx):
    """Return modern atoms for one old atom. ctx carries per-tile facts."""
    t = atom_type(atom)
    v = atom_vars(atom)
    if t in DROP:
        dropped[t] += 1
        return []
    if t in SIMPLE_MAP:
        out = {}
        out.update(pixels(v))
        if t in ('/obj/structure/stool/bed/chair',):
            out.update(with_dir(v))
        if t == '/obj/machinery/power/port_gen/pacman':
            out['anchored'] = '1'
        return [make_atom(SIMPLE_MAP[t], out)]
    if t.startswith(BEAKERS):
        return [make_atom('/obj/item/reagent_containers/cup/beaker', pixels(v))]
    if t == '/obj/item/weapon/reagent_containers/glass/beaker/large':
        return [make_atom('/obj/item/reagent_containers/cup/beaker/large', pixels(v))]
    if t == '/obj/machinery/power/port_gen/pacman':
        return [make_atom('/obj/machinery/power/port_gen/pacman', {'anchored': '1'})]
    if t == '/obj/structure/stool/bed/chair':
        return [make_atom('/obj/structure/chair', with_dir(v))]
    if t.startswith('/obj/machinery/atmospherics/pipe/'):
        kind = t.rsplit('/', 1)[1]
        if kind == 'tank':
            pass
        colour = PIPE_COLOURS.get(unq(v.get('color', '')) or '', None)
        visible = v.get('level') == '2'
        if t == '/obj/machinery/atmospherics/pipe/tank/air':
            return [make_atom('/obj/machinery/atmospherics/unary/tank/air', with_dir(v))]
        path = f'/obj/machinery/atmospherics/pipe/{kind}/{"visible" if visible else "hidden"}'
        out = with_dir(v)
        if colour and path + '/' + colour in TYPES:
            path += '/' + colour
        elif colour:
            out['color'] = q(PIPE_HEX[colour])
        return [make_atom(path, out)]
    if t == '/obj/machinery/atmospherics/binary/pump/on':
        on = v.get('on', '1') != '0'
        return [make_atom('/obj/machinery/atmospherics/binary/pump' + ('/on' if on else ''), with_dir(v))]
    if t == '/obj/machinery/atmospherics/portables_connector':
        return [make_atom('/obj/machinery/atmospherics/unary/portables_connector', with_dir(v))]
    if t == '/obj/machinery/atmospherics/trinary/filter':
        gas = {'1': 'oxygen', '2': 'nitrogen'}[v['filter_type']]
        out = with_dir(v)
        out['filter_type'] = q(gas)
        out['on'] = '1'
        out['name'] = q(f'gas filter ({"O2" if gas == "oxygen" else "N2"} recovery)')
        return [make_atom('/obj/machinery/atmospherics/trinary/filter', out)]
    if t == '/obj/machinery/atmospherics/unary/cold_sink/freezer':
        return [make_atom('/obj/machinery/atmospherics/unary/thermomachine/freezer', with_dir(v))]
    if t == '/obj/machinery/atmospherics/unary/heat_reservoir/heater':
        return [make_atom('/obj/machinery/atmospherics/unary/thermomachine/heater', with_dir(v))]
    if t == '/obj/machinery/atmospherics/unary/vent_pump':
        out = with_dir(v)
        on = v.get('on', '0') == '1'
        if v.get('pressure_checks') == '0':
            out['pressure_checks'] = '0'
        return [make_atom('/obj/machinery/atmospherics/unary/vent_pump' + ('/on' if on else ''), out)]
    if t == '/obj/machinery/atmospherics/unary/vent_pump/high_volume':
        return []  # the airlock assembly is taken from the current map
    if t == '/obj/machinery/atmospherics/unary/vent_scrubber':
        out = with_dir(v) if v.get('dir') != '0' else {'dir': 'AUTO'}
        on = v.get('on', '0') == '1'
        return [make_atom('/obj/machinery/atmospherics/unary/vent_scrubber' + ('/on' if on else ''), out)]
    if t.startswith('/obj/machinery/door/airlock'):
        return convert_airlock(t, v)
    if t == '/obj/machinery/door/firedoor/border_only':
        return [make_atom('/obj/machinery/door/firedoor/border_only', with_dir(v))]
    if t == '/obj/machinery/door/window/westleft':
        out = {}
        d = v.get('dir', '8')
        if d != '8':
            out['dir'] = d
        if v.get('name'):
            out['name'] = v['name']
        if unq(v.get('req_access_txt')) not in (None, '0'):
            out['req_access'] = access_list(XENOARCH)
        return [make_atom('/obj/machinery/door/window/westleft', out)]
    if t == '/obj/machinery/door_control':
        out = {'id': v['id'], 'name': q('door bolt control'), 'normaldoorcontrol': '1', 'specialfunctions': '4'}
        out.update(pixels(v))
        return [make_atom('/obj/machinery/door_control', out)]
    if t in ('/obj/machinery/access_button', '/obj/machinery/airlock_sensor',
             '/obj/machinery/embedded_controller/radio/airlock_controller'):
        return []  # the airlock assembly is taken from the current map
    if t in ('/obj/machinery/alarm', '/obj/machinery/alarm/isolation'):
        out = {}
        side = wall_side(v)
        if side and side != SOUTH:
            out['dir'] = str(side)
        elif side == SOUTH:
            out['dir'] = '2'
        out.update(pixels(v))
        return [make_atom('/obj/machinery/alarm', out)]
    if t == '/obj/machinery/firealarm':
        out = {}
        side = wall_side(v)
        if side:
            out['dir'] = str(side)
        out.update(pixels(v))
        return [make_atom('/obj/machinery/firealarm', out)]
    if t == '/obj/machinery/power/apc':
        side = wall_side(v) or SOUTH
        out = {'dir': str(side), 'name': v['name']}
        out.update(pixels(v))
        return [make_atom('/obj/machinery/power/apc', out)]
    if t == '/obj/machinery/power/terminal':
        return [make_atom('/obj/machinery/power/terminal', with_dir(v))]
    if t == '/obj/machinery/camera':
        out = with_dir(v)
        tag = unq(v.get('c_tag'))
        out['c_tag'] = q(tag)
        net = v.get('network', 'list("SS13")')
        if 'isolation' in net:
            out['network'] = 'list("Isolation")'
        else:
            out['network'] = 'list("Research","SS13")'
        out.update(pixels(v))
        return [make_atom('/obj/machinery/camera', out)]
    if t == '/obj/machinery/computer/security/telescreen':
        out = {'name': q('isolation room telescreen'), 'desc': q('Used for watching the isolation room cameras.'),
               'network': 'list("Isolation")'}
        out.update(pixels(v))
        return [make_atom('/obj/machinery/computer/security/telescreen', out)]
    if t in ('/obj/machinery/light', '/obj/machinery/light/small'):
        return [make_atom(t, with_dir(v))]
    if t == '/obj/machinery/status_display':
        return [make_atom('/obj/machinery/status_display', pixels(v))]
    if t == '/obj/machinery/sleeper':
        return [make_atom('/obj/machinery/sleeper', {'dir': '4'})]
    if t == '/obj/machinery/shower':
        return [make_atom('/obj/machinery/shower', with_dir(v))]
    if t == '/obj/structure/toilet':
        return [make_atom('/obj/structure/toilet', with_dir(v))]
    if t == '/obj/structure/sink':
        return [make_atom('/obj/structure/sink', pixels(v))]
    if t == '/obj/structure/mirror':
        return [make_atom('/obj/structure/mirror', pixels(v))]
    if t in ('/obj/machinery/conveyor',):
        return [make_atom('/obj/machinery/conveyor', {**with_dir(v), 'id': v['id']})]
    if t in ('/obj/machinery/conveyor_switch', '/obj/machinery/conveyor_switch/oneway'):
        out = {'id': v['id']}
        out.update(pixels(v))
        return [make_atom(t, out)]
    if t == '/obj/machinery/mineral/unloading_machine':
        return [make_atom('/obj/machinery/mineral/unloading_machine', {})]
    if t == '/obj/machinery/disposal/deliveryChute':
        return [make_atom('/obj/machinery/disposal/deliveryChute', with_dir(v))]
    if t == '/obj/structure/disposaloutlet':
        return [make_atom('/obj/structure/disposaloutlet', with_dir(v))]
    if t == '/obj/structure/disposalpipe/segment':
        out = with_dir(v)
        if 'pipe-c' in v.get('icon_state', ''):
            out['icon_state'] = q('pipe-c')
        return [make_atom('/obj/structure/disposalpipe/segment', out)]
    if t == '/obj/structure/disposalpipe/trunk':
        return [make_atom('/obj/structure/disposalpipe/trunk', with_dir(v))]
    if t == '/obj/structure/bookcase/manuals/xenoarchaeology':
        return ['/obj/structure/bookcase', '/obj/item/book/manual/xenoarchaeology', '/obj/item/book/manual/xenoarchaeology']
    if t == '/obj/structure/closet/excavation':
        return [make_atom('/obj/structure/closet', {'name': q('excavation equipment closet')}),
                '/obj/item/storage/box/excavation', '/obj/item/storage/belt/archaeology',
                '/obj/item/xenoarch_tool/depth_scanner']
    if t == '/obj/structure/closet/hydrant':
        return [make_atom('/obj/structure/extinguisher_cabinet', pixels(v))]
    if t == '/obj/structure/closet/walllocker/emerglocker/north':
        return [make_atom('/obj/structure/closet/walllocker/emerglocker', {'pixel_y': '32'})]
    if t == '/obj/structure/closet/walllocker/emerglocker/west':
        return [make_atom('/obj/structure/closet/walllocker/emerglocker', {'pixel_x': '-32'})]
    if t == '/obj/structure/extinguisher_cabinet':
        return [make_atom('/obj/structure/extinguisher_cabinet', pixels(v))]
    if t.startswith('/obj/structure/sign/'):
        out = keep(v, 'name', 'desc', 'icon_state')
        out.update(pixels(v))
        path = '/obj/structure/sign/medbay/greencross' if t.endswith('greencross') else t
        return [make_atom(path, out)]
    if t == '/obj/structure/window/reinforced':
        if v.get('dir') == '5':
            return ['/obj/structure/window/full/reinforced']
        return [make_atom('/obj/structure/window/reinforced', with_dir(v))]
    if t == '/obj/structure/cable':
        ctx['cables'].append((int(v.get('d1', '0')), int(v.get('d2', '1'))))
        return []
    if t.startswith('/obj/structure/transit_tube') or t == '/obj/structure/transit_tube_pod':
        ctx['tubes'].append(atom)
        return []
    if t.startswith('/obj/machinery/anomaly/'):
        ctx['anomaly'] = True
        return []
    if t == '/obj/machinery/power/smes':
        return ['/obj/machinery/power/smes']
    unknown[t] += 1
    return []


def convert_turf(atom, ctx):
    t = atom_type(atom)
    v = atom_vars(atom)
    gas = keep(v, 'oxygen', 'nitrogen', 'temperature')
    if t == '/turf/simulated/floor':
        out = keep(v, 'dir', 'icon_state')
        if out.get('dir') == '2':
            out.pop('dir')
        if unq(out.get('icon_state')) == 'floor':
            out.pop('icon_state')
        out.update(gas)
        if 'name' in v and unq(v['name']) not in ('floor',):
            out['name'] = v['name']
        return make_atom('/turf/simulated/floor/plasteel', out)
    if t == '/turf/simulated/floor/plating':
        out = keep(v, 'dir', 'icon_state')
        out.update(gas)
        return make_atom('/turf/simulated/floor/plating', out)
    if t == '/turf/simulated/floor/airless':
        return make_atom('/turf/simulated/floor/plasteel/airless', keep(v, 'icon_state'))
    if t == '/turf/simulated/floor/plating/airless':
        return make_atom('/turf/simulated/floor/plating/airless', keep(v, 'icon_state'))
    if t == '/turf/simulated/floor/mech_bay_recharge_floor':
        return '/turf/simulated/floor/mech_bay_recharge_floor'
    if t in ('/turf/simulated/floor/bluegrid', '/turf/simulated/floor/carpet', '/turf/simulated/floor/grass',
             '/turf/simulated/floor/wood', '/turf/simulated/wall', '/turf/simulated/wall/r_wall'):
        return t
    if t == '/turf/space':
        return '/turf/simulated/floor/plating/airless'
    unknown[t] += 1
    return '/turf/simulated/floor/plating'


def tile_area(atoms):
    return [atom_type(a) for a in atoms if atom_type(a).startswith('/area')][0]


def tile_turf(atoms):
    return [a for a in atoms if atom_type(a).startswith('/turf')][0]


# Transit tubes: old icon states name the connected directions.
LETTER = {'N': NORTH, 'S': SOUTH, 'E': EAST, 'W': WEST}


def tube_atom(old):
    t = atom_type(old)
    v = atom_vars(old)
    state = unq(v.get('icon_state')) or 'E-W'
    if t == '/obj/structure/transit_tube_pod':
        return '/obj/structure/transit_tube_pod'
    if t == '/obj/structure/transit_tube/station':
        return ('station', int(v.get('dir', '2')))
    if state.startswith('D-'):
        return None  # decorative diagonal fillers; modern tubes draw these themselves
    pieces = {
        'N-S': ('/obj/structure/transit_tube', None),
        'E-W': ('/obj/structure/transit_tube/horizontal', None),
        'NE-SW': ('/obj/structure/transit_tube/diagonal', None),
        'NW-SE': ('/obj/structure/transit_tube/diagonal/topleft', None),
        'N-SW': ('/obj/structure/transit_tube/curved', NORTH),
        'N-SE': ('/obj/structure/transit_tube/curved/flipped', NORTH),
        'S-NE': ('/obj/structure/transit_tube/curved', SOUTH),
        'S-NW': ('/obj/structure/transit_tube/curved/flipped', SOUTH),
        'E-NW': ('/obj/structure/transit_tube/curved', EAST),
        'E-SW': ('/obj/structure/transit_tube/curved/flipped', EAST),
        'W-SE': ('/obj/structure/transit_tube/curved', WEST),
        'W-NE': ('/obj/structure/transit_tube/curved/flipped', WEST),
    }
    path, d = pieces[state]
    return make_atom(path, {'dir': str(d)} if d and d != SOUTH else ({'dir': '2'} if d == SOUTH else {}))


def main(old_path, base_path, out_path):
    types = load_types()
    TYPES.update(types)
    old = DMM.load(old_path)
    cur = DMM.load(base_path)
    region = set()
    for (x, y, z), key in old.grid.items():
        if z == OLD_Z and tile_area(old.keys[key]).startswith(OUTPOST_AREA):
            region.add((x, y))
    assert len(region) > 900, 'outpost not found in the old map'
    assert not any(tile_area(cur.tile(x, y)).startswith(OUTPOST_AREA) for (x, y) in region), \
        'base map already contains the outpost'
    # Hull walls outside the outpost areas, touching the outpost.
    hull = set()
    for (x, y) in region:
        for dx in (-1, 0, 1):
            for dy in (-1, 0, 1):
                p = (x + dx, y + dy)
                if p in region:
                    continue
                atoms = old.tile(p[0], p[1], OLD_Z)
                if 'wall' in atom_type(tile_turf(atoms)) and tile_area(atoms) != SHUTTLE_AREA:
                    hull.add(p)
    # The current small north mining post is replaced by the outpost.
    leftovers = set()
    for (x, y), key in ((k[:2], v) for k, v in cur.grid.items()):
        if tile_area(cur.keys[key]) == '/area/mine/north_outpost' and (x, y) not in region and (x, y) not in hull:
            leftovers.add((x, y))
    # Keep the current map's working airlock assembly for the south entrance.
    airlock = {(x, y) for x in range(153, 156) for y in range(182, 187)}

    tiles = {}
    cable_dirs = {}
    tubes = {}
    for (x, y) in sorted(region | hull):
        if (x, y) in airlock:
            continue
        atoms = old.tile(x, y, OLD_Z)
        ctx = {'cables': [], 'tubes': [], 'anomaly': False}
        objs = []
        for a in atoms:
            t = atom_type(a)
            if t.startswith('/area') or t.startswith('/turf'):
                continue
            objs.extend(convert(a, ctx))
        turf = convert_turf(tile_turf(atoms), ctx)
        old_turf = atom_type(tile_turf(atoms))
        if ctx['anomaly']:
            if old_turf == '/turf/space':
                objs.append('/obj/structure/xenoarch_chamber')
                turf = '/turf/simulated/floor/plating/airless'
            else:
                objs.append('/obj/machinery/xenoarch/spectrometer')
        dirs = 0
        for d1, d2 in ctx['cables']:
            dirs |= d1 | d2
        if ctx['cables']:
            cable_dirs[(x, y)] = dirs
        if ctx['tubes']:
            tubes[(x, y)] = ctx['tubes']
        area = tile_area(atoms) if (x, y) in region else tile_area(cur.tile(x, y))
        if area == '/area/mine/north_outpost':
            area = '/area/mine/explored'
        tiles[(x, y)] = [objs, turf, area]
    # Transit tube runs outside the outpost: carve a tunnel through the rock for them.
    for (x, y, z), key in old.grid.items():
        if z != OLD_Z or (x, y) in tiles or (x, y) in airlock:
            continue
        olds = [a for a in old.keys[key] if 'transit_tube' in atom_type(a)]
        if not olds:
            continue
        cur_atoms = cur.tile(x, y)
        cur_turf = tile_turf(cur_atoms)
        area = tile_area(cur_atoms)
        objs = [a for a in cur_atoms if not atom_type(a).startswith(('/area', '/turf'))]
        # Only bore through solid rock: never lay tubes over the current map's walkways or windows.
        if 'mineral' not in atom_type(cur_turf) or objs or area == '/area/mine/north_outpost':
            continue
        cur_turf = '/turf/simulated/floor/plating/asteroid/airless'
        if area == '/area/mine/unexplored':
            area = '/area/mine/explored'
        tubes[(x, y)] = olds
        tiles[(x, y)] = [objs, cur_turf, area]
    # The kept airlock belongs to the outpost; its outer apron to the asteroid.
    for (x, y) in airlock:
        cur_atoms = cur.tile(x, y)
        objs = [a for a in cur_atoms if not atom_type(a).startswith(('/area', '/turf'))]
        area = '/area/mine/explored' if y == 182 else '/area/research_outpost/gearstore'
        tiles[(x, y)] = [objs, tile_turf(cur_atoms), area]
    button = [a for a in cur.tile(154, 187) if atom_type(a) == '/obj/machinery/access_button']
    assert button, 'current interior airlock button not found'
    tiles[(154, 187)][0].extend(button)
    # Leftover tiles of the old north post become explored asteroid.
    for (x, y) in leftovers:
        if (x, y) in airlock:
            continue
        cur_atoms = cur.tile(x, y)
        cur_turf = atom_type(tile_turf(cur_atoms))
        turf = '/turf/simulated/floor/plating/asteroid/airless' if 'wall' not in cur_turf else '/turf/simulated/mineral'
        tiles[(x, y)] = [[], turf, '/area/mine/explored']
    apply_patches(tiles)
    route_apc_cables(tiles, cable_dirs)
    # Cables: one smart cable per tile, linked only where the old cables were.
    for (x, y), dirs in cable_dirs.items():
        banned = 15 & ~dirs
        tiles[(x, y)][0].insert(0, make_atom('/obj/structure/cable', {'banned_links': str(banned)} if banned else {}))
    # Transit tubes.
    tube_report = place_tubes(tiles, tubes)
    # Fix vent scrubbers mapped without a direction: face the adjacent pipe.
    for (x, y), (objs, turf, area) in tiles.items():
        for i, a in enumerate(objs):
            if "dir = AUTO" in a:
                d = find_pipe_dir(tiles, x, y)
                objs[i] = a.replace('{dir = AUTO}', '' if d == SOUTH else '{dir = %d}' % d)
    # Write out.
    for (x, y), (objs, turf, area) in tiles.items():
        atoms = objs + [turf, area]
        for a in atoms:
            path = atom_type(a)
            if path not in types:
                unknown['MISSING TYPE ' + path] += 1
        cur.grid[(x, y, 1)] = cur.new_key(atoms)
    cur.save_tgm(out_path)
    print(f'region {len(region)}, hull {len(hull)}, leftovers {len(leftovers)}, cables {len(cable_dirs)}')
    print('tubes:', tube_report)
    print('dropped:', dict(dropped))
    print('unknown:', dict(unknown))


def remove(objs, prefix, count=1):
    for i, a in enumerate(list(objs)):
        if atom_type(a) == prefix or atom_type(a).startswith(prefix + '/'):
            objs.remove(a)
            count -= 1
            if not count:
                return
    raise AssertionError(f'{prefix} not found in {objs}')


def apply_patches(tiles):
    """Fixes for defects of the 2013 map and for pieces that no longer exist around it."""
    T = lambda x, y: tiles[(x, y)][0]  # noqa: E731
    # Two simple pipes stacked under manifolds created asymmetric pipe networks.
    remove(T(179, 195), '/obj/machinery/atmospherics/pipe/simple')
    remove(T(180, 194), '/obj/machinery/atmospherics/pipe/simple')
    # A scrubber line stub ended in the middle of the secure storage: give it a scrubber.
    remove(T(161, 204), '/obj/machinery/atmospherics/pipe/simple')
    T(161, 204).append('/obj/machinery/atmospherics/unary/vent_scrubber/on')
    # The supply line had no pipe under the loading door.
    T(167, 205).append('/obj/machinery/atmospherics/pipe/simple/hidden/blue')
    # The cooler faced away from its supply pipe.
    for i, a in enumerate(T(164, 187)):
        if atom_type(a) == '/obj/machinery/atmospherics/unary/thermomachine/freezer':
            T(164, 187)[i] = make_atom(atom_type(a), {'dir': '1'})
    # The waste line used to vent into open space, which is now solid rock: cap it.
    remove(T(179, 202), '/obj/machinery/atmospherics/pipe/simple')
    remove(T(178, 202), '/obj/machinery/atmospherics/pipe/simple')
    T(178, 202).append(make_atom('/obj/machinery/atmospherics/pipe/cap/visible', {'dir': '8', 'color': q(PIPE_HEX['red'])}))
    # Disposal pipes missing under two doors.
    T(165, 199).append('/obj/structure/disposalpipe/segment')
    T(165, 205).append('/obj/structure/disposalpipe/segment')
    # The trash line ended in an outlet facing space; it now empties into the tube tunnel.
    T(180, 200).extend([make_atom('/obj/structure/disposalpipe/trunk', {'dir': '8'}),
                        '/obj/structure/disposaloutlet'])
    # The mining base pneumatic tube (x=156) used to end in the old north post: bring it inside.
    for y in range(182, 187):
        T(156, y).append('/obj/structure/disposalpipe/segment')
    T(156, 187).append(make_atom('/obj/structure/disposalpipe/segment', {'icon_state': q('pipe-c')}))
    print('chute tile before:', T(155, 187))
    for a in list(T(155, 187)):
        if atom_type(a) in ('/obj/structure/rack', '/obj/structure/table'):
            T(155, 187).remove(a)
    T(155, 187).extend([make_atom('/obj/structure/disposalpipe/trunk', {'dir': '4'}),
                        make_atom('/obj/machinery/disposal/deliveryChute', {'dir': '8', 'name': q('pneumatic tube to mining')})])
    # No research shuttle docks here any more: seal its airlock.
    tiles[(147, 197)][0] = []
    tiles[(147, 197)][1] = '/turf/simulated/wall/r_wall'
    # Atmospherics never had its own APC; the filters and thermomachines need one.
    T(175, 206).append(make_atom('/obj/machinery/power/apc', {'dir': '8', 'name': q('Outpost Atmospherics APC'), 'pixel_x': '-24'}))
    # Fossil reconstitution: flora beside the soil trays, fauna and its growth tank at the old monkey pen.
    remove(T(162, 207), '/obj/structure/table')
    T(162, 207).append('/obj/machinery/computer/fossil_reconstitutor/flora')
    remove(T(165, 197), '/mob/living/carbon/human/lesser/monkey')
    T(165, 197).append('/obj/machinery/fossil_incubator')
    T(163, 198).append(make_atom('/obj/machinery/computer/fossil_reconstitutor/fauna', {'dir': '8'}))
    T(163, 197).append('/obj/item/storage/box/monkeycubes')


def route_apc_cables(tiles, cable_dirs):
    """Old APCs that were never wired get a cable run to the nearest distribution cable."""
    def has(p, prefix):
        return any(atom_type(a).startswith(prefix) for a in tiles.get(p, [[]])[0])
    smes = {p for p in tiles if has(p, '/obj/machinery/power/smes')}
    terminals = {p for p in tiles if has(p, '/obj/machinery/power/terminal')}

    def neighbours(p):
        for d in DIRS:
            q_ = (p[0] + STEP[d][0], p[1] + STEP[d][1])
            yield d, q_

    def linked(p, d, q_):
        if q_ not in cable_dirs or not (cable_dirs[p] & d) or not (cable_dirs[q_] & REVERSE[d]):
            return False
        return not ((p in smes and q_ in terminals) or (p in terminals and q_ in smes))

    def network(start):
        seen, todo = {start}, [start]
        while todo:
            c = todo.pop()
            for d, n in neighbours(c):
                if n not in seen and linked(c, d, n):
                    seen.add(n)
                    todo.append(n)
        return seen

    start = next(iter(smes))
    output = network(start)
    inputs = network(next(iter(terminals)))

    def walkable(p):
        if p not in tiles:
            return False
        objs, turf, area = tiles[p]
        if 'wall' in turf or not area.startswith(OUTPOST_AREA):
            return False
        return not any(atom_type(a) == '/obj/structure/xenoarch_chamber' for a in objs) and p not in inputs

    routed = []
    for p in sorted(tiles):
        if not has(p, '/obj/machinery/power/apc') or p in output:
            continue
        # Breadth-first search over floor tiles to the distribution circuit.
        prev = {p: None}
        todo = [p]
        found = None
        while todo and not found:
            nxt = []
            for c in todo:
                for d, n in neighbours(c):
                    if n in prev or not walkable(n):
                        continue
                    prev[n] = (c, d)
                    if n in output:
                        found = n
                        break
                    nxt.append(n)
                if found:
                    break
            todo = nxt
        assert found, f'no cable route for APC at {p}'
        c = found
        length = 0
        while prev[c]:
            back, d = prev[c]
            cable_dirs[back] = cable_dirs.get(back, 0) | d
            cable_dirs[c] = cable_dirs.get(c, 0) | REVERSE[d]
            output.add(back)
            c = back
            length += 1
        routed.append((p, length))
    print('routed APC cables:', routed)


def find_pipe_dir(tiles, x, y):
    for d in DIRS:
        dx, dy = STEP[d]
        objs = tiles.get((x + dx, y + dy), [[]])[0]
        if any('/pipe/' in a for a in objs):
            return d
    return SOUTH


def tube_dirs(atom):
    """Directions a placed modern tube connects to (cardinal and diagonal as bitflags)."""
    t = atom_type(atom)
    d = int(atom_vars(atom).get('dir', '2'))
    NE, NW, SE, SW = NORTH | EAST, NORTH | WEST, SOUTH | EAST, SOUTH | WEST
    if t == '/obj/structure/transit_tube':
        return {NORTH, SOUTH}
    if t == '/obj/structure/transit_tube/horizontal':
        return {EAST, WEST}
    if t == '/obj/structure/transit_tube/diagonal':
        return {NE, SW}
    if t == '/obj/structure/transit_tube/diagonal/topleft':
        return {NW, SE}
    curved = {NORTH: {NORTH, SW}, SOUTH: {SOUTH, NE}, EAST: {EAST, NW}, WEST: {SE, WEST}}
    flipped = {NORTH: {NORTH, SE}, SOUTH: {SOUTH, NW}, EAST: {EAST, SW}, WEST: {NE, WEST}}
    if t == '/obj/structure/transit_tube/curved':
        return curved[d]
    if t == '/obj/structure/transit_tube/curved/flipped':
        return flipped[d]
    if t.startswith('/obj/structure/transit_tube/station'):
        if t.endswith('reverse'):
            return {{NORTH: WEST, SOUTH: EAST, EAST: NORTH, WEST: SOUTH}[d]}  # turn(dir, -90)
        return {EAST, WEST} if d in (NORTH, SOUTH) else {NORTH, SOUTH}
    return set()


def offset(d):
    dx = (1 if d & EAST else 0) - (1 if d & WEST else 0)
    dy = (1 if d & NORTH else 0) - (1 if d & SOUTH else 0)
    return dx, dy


def opposite(d):
    o = 0
    for a, b in ((NORTH, SOUTH), (EAST, WEST)):
        if d & a:
            o |= b
        elif d & b:
            o |= a
    return o


def place_tubes(tiles, tubes):
    placed = {}
    stations = {}
    for p, olds in tubes.items():
        for o in olds:
            r = tube_atom(o)
            if r is None:
                continue
            if isinstance(r, tuple):
                stations[p] = r[1]
            elif r == '/obj/structure/transit_tube_pod':
                tiles[p][0].append(r)
            else:
                placed[p] = r
    # Prune branches cut off where the old network left the converted area.
    def station_ends(p, d):
        return {EAST, WEST} if d in (NORTH, SOUTH) else {NORTH, SOUTH}
    pruned = 0
    while True:
        dead = []
        for p, a in placed.items():
            for dd in tube_dirs(a):
                dx, dy = offset(dd)
                q_ = (p[0] + dx, p[1] + dy)
                if q_ in stations and opposite(dd) in station_ends(q_, stations[q_]):
                    continue
                if q_ not in placed or opposite(dd) not in tube_dirs(placed[q_]):
                    dead.append(p)
                    break
        if not dead:
            break
        for p in dead:
            del placed[p]
            pruned += 1
    for p in [p for p, d in stations.items()
              if not any((p[0] + offset(s)[0], p[1] + offset(s)[1]) in placed for s in station_ends(p, d))]:
        del stations[p]
        pruned += 1
    # Stations: plain stations need tubes on both sides, otherwise a terminus.
    for p, d in stations.items():
        sides = [EAST, WEST] if d in (NORTH, SOUTH) else [NORTH, SOUTH]
        linked = []
        for s in sides:
            dx, dy = offset(s)
            q_ = (p[0] + dx, p[1] + dy)
            if q_ in placed or q_ in stations:
                linked.append(s)
        if len(linked) == 2:
            placed[p] = make_atom('/obj/structure/transit_tube/station', {'dir': str(d)} if d != SOUTH else {})
        else:
            # A terminus launches pods along turn(dir, -90); pick the orientation that faces the tube.
            want = linked[0] if linked else sides[0]
            for nd in DIRS:
                if {NORTH: WEST, SOUTH: EAST, EAST: NORTH, WEST: SOUTH}[nd] == want and nd in ((NORTH, SOUTH) if want in (EAST, WEST) else (EAST, WEST)):
                    pass
            # turn(dir,-90) == want  ->  dir = turn(want, 90)
            nd = {NORTH: EAST, EAST: SOUTH, SOUTH: WEST, WEST: NORTH}[want]
            # boarding side must stay the old one (opposite of dir): keep closest match
            placed[p] = make_atom('/obj/structure/transit_tube/station/reverse', {'dir': str(nd)} if nd != SOUTH else {})
    for p, a in placed.items():
        tiles[p][0].append(a)
    # Audit connectivity.
    broken = []
    for p, a in placed.items():
        for d in tube_dirs(a):
            dx, dy = offset(d)
            q_ = (p[0] + dx, p[1] + dy)
            other = placed.get(q_)
            if not other or opposite(d) not in tube_dirs(other):
                broken.append((p, d, atom_type(a)))
    return {'pieces': len(placed), 'stations': len(stations), 'broken_links': broken}


if __name__ == '__main__':
    main(*sys.argv[1:4])
