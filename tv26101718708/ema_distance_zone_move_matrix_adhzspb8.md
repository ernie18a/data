# EMA Distance  Zone Move Matrix

- url: https://www.tradingview.com/script/aDhzspB8-EMA-Distance-Zone-Move-Matrix/
- type: indicator
- pine_id: PUB;d1c105c995bc4f268baca3dfee4644e9
- version: 1.0

## Description

This indicator answers one of the most practical questions in trading: "When price is X% away from the EMA, how likely is it to move at least Y% from that point?"
It builds a live probability matrix from historical data — no repainting, no predictions — just raw statistics from how price has actually behaved.

How It Works
The indicator measures the percentage distance between price and a selected EMA at every bar. It then groups historical bars into user-defined zones (e.g. "price is 3–5% above EMA") and tracks how often price made a significant move after entering each zone.
Example read:
If the 3 to 5% zone shows ▲≥5%: 62.3% — that means 62.3% of the time, after price entered that zone, it subsequently rallied at least 5% from the entry price within the tracking window.

Settings
EMA

EMA Length — period of the EMA (default: 20)
EMA Timeframe — use the chart timeframe or any higher timeframe
Lookback Bars — how many historical bars to analyse (default: 1000)
Bars to Track — how many bars after zone entry to watch for the move (default: 50)

From Zones (Rows) — 8 zones, each with:

Enable/disable toggle
Lo% and Hi% — the EMA distance band (supports negative values for below-EMA zones)
Label — custom name shown in the table row

Move Thresholds (Columns) — 10 thresholds, each with:

Enable/disable toggle
Direction — ▲ Up (price rises), ▼ Down (price falls), ↕ Either (either direction)
≥ % — minimum move size to count as a hit

Display

Show % or raw count
Heatmap color mode
Table position and text size


The Matrix Table
Rows = FROM zones (where price was when it entered)
Columns = move thresholds (how far it moved after)
Last column = total number of visits to that zone
Each cell shows the probability (%) or count of times price achieved that move after entering that zone.
Color coding (heatmap mode):

Red — highest probability (≥75% of max)
Orange — high (50–75%)
Yellow — moderate (25–50%)
Teal — low (below 25%)
Gray — zero / no data

Column headers are color-coded by direction:

Teal = Up move ▲
Red = Down move ▼
Purple = Either direction ↕

The footer row shows the currently active zone and the indicator settings summary.

Chart Background
The chart background is lightly shaded to show which zone price is currently in — making it easy to spot your current EMA distance zone at a glance without looking at the table.

Use Cases

Find which EMA distance zones historically lead to strong reversals or continuations
Identify asymmetric zones where up-move probability is much higher than down
Compare behavior at oversold vs overbought EMA distances
Build mean-reversion or momentum setups backed by historical statistics
Use with any EMA (20, 50, 100, 200) on any timeframe


Notes

overlay=true — draws directly on the main chart, no separate pane needed
A move is counted once per zone visit per threshold (first time it's hit within the tracking window)
Works on any instrument: stocks, crypto, forex, futures, indices
The matrix updates live on every bar — no need to refresh
Use a lookback of at least 500 bars for statistically meaningful results
Ensure the chart timeframe has enough history to cover the lookback window


Settings Quick Start (recommended defaults):
Zones: -10 to -5 · -5 to -3 · -3 to 0 · 0 to 3 · 3 to 5 · 5 to 10
Moves: ▲≥1% · ▲≥2% · ▲≥5% · ▲≥10% · ▼≥1% · ▼≥2% · ▼≥5% · ▼≥10%
Lookback: 1000 · Track window: 50 bars

## Source Code

````pine
//@version=6
indicator('EMA Distance % — Zone Move Matrix', shorttitle = 'EMA Zone Matrix', overlay = true)

// ══════════════════════════════════════════════════════════════════
//  EMA
// ══════════════════════════════════════════════════════════════════
ema_len = input.int(20, title = 'EMA Length', group = 'EMA', minval = 1)
ema_tf = input.timeframe('', title = 'EMA Timeframe', group = 'EMA')
lookback = input.int(1000, title = 'Lookback Bars', group = 'EMA', minval = 100, maxval = 5000)
max_track = input.int(50, title = 'Bars to Track Move After Entry', group = 'EMA', minval = 5, maxval = 500)

// ══════════════════════════════════════════════════════════════════
//  FROM ZONES  (rows) — 8 zones, each fully independent
// ══════════════════════════════════════════════════════════════════
z1_en = input.bool(true, title = 'Z1 On', group = 'From Zones', inline = 'z1')
z1_lo = input.float(-10.0, title = 'Lo%', group = 'From Zones', inline = 'z1', step = 0.5)
z1_hi = input.float(-5.0, title = 'Hi%', group = 'From Zones', inline = 'z1', step = 0.5)
z1_lbl = input.string('-10 to -5', title = 'Label', group = 'From Zones', inline = 'z1')

z2_en = input.bool(true, title = 'Z2 On', group = 'From Zones', inline = 'z2')
z2_lo = input.float(-5.0, title = 'Lo%', group = 'From Zones', inline = 'z2', step = 0.5)
z2_hi = input.float(-3.0, title = 'Hi%', group = 'From Zones', inline = 'z2', step = 0.5)
z2_lbl = input.string('-5 to -3', title = 'Label', group = 'From Zones', inline = 'z2')

z3_en = input.bool(true, title = 'Z3 On', group = 'From Zones', inline = 'z3')
z3_lo = input.float(-3.0, title = 'Lo%', group = 'From Zones', inline = 'z3', step = 0.5)
z3_hi = input.float(0.0, title = 'Hi%', group = 'From Zones', inline = 'z3', step = 0.5)
z3_lbl = input.string('-3 to 0', title = 'Label', group = 'From Zones', inline = 'z3')

z4_en = input.bool(true, title = 'Z4 On', group = 'From Zones', inline = 'z4')
z4_lo = input.float(0.0, title = 'Lo%', group = 'From Zones', inline = 'z4', step = 0.5)
z4_hi = input.float(3.0, title = 'Hi%', group = 'From Zones', inline = 'z4', step = 0.5)
z4_lbl = input.string('0 to 3', title = 'Label', group = 'From Zones', inline = 'z4')

z5_en = input.bool(true, title = 'Z5 On', group = 'From Zones', inline = 'z5')
z5_lo = input.float(3.0, title = 'Lo%', group = 'From Zones', inline = 'z5', step = 0.5)
z5_hi = input.float(5.0, title = 'Hi%', group = 'From Zones', inline = 'z5', step = 0.5)
z5_lbl = input.string('3 to 5', title = 'Label', group = 'From Zones', inline = 'z5')

z6_en = input.bool(true, title = 'Z6 On', group = 'From Zones', inline = 'z6')
z6_lo = input.float(5.0, title = 'Lo%', group = 'From Zones', inline = 'z6', step = 0.5)
z6_hi = input.float(10.0, title = 'Hi%', group = 'From Zones', inline = 'z6', step = 0.5)
z6_lbl = input.string('5 to 10', title = 'Label', group = 'From Zones', inline = 'z6')

z7_en = input.bool(false, title = 'Z7 On', group = 'From Zones', inline = 'z7')
z7_lo = input.float(10.0, title = 'Lo%', group = 'From Zones', inline = 'z7', step = 0.5)
z7_hi = input.float(20.0, title = 'Hi%', group = 'From Zones', inline = 'z7', step = 0.5)
z7_lbl = input.string('10 to 20', title = 'Label', group = 'From Zones', inline = 'z7')

z8_en = input.bool(false, title = 'Z8 On', group = 'From Zones', inline = 'z8')
z8_lo = input.float(20.0, title = 'Lo%', group = 'From Zones', inline = 'z8', step = 0.5)
z8_hi = input.float(30.0, title = 'Hi%', group = 'From Zones', inline = 'z8', step = 0.5)
z8_lbl = input.string('20 to 30', title = 'Label', group = 'From Zones', inline = 'z8')

// ══════════════════════════════════════════════════════════════════
//  MOVE THRESHOLDS  (columns)
//  Direction: "Up ▲"  = price rose at least X% from entry
//             "Down ▼" = price fell at least X% from entry
//             "Either ↕" = either direction at least X%
// ══════════════════════════════════════════════════════════════════
m1_en = input.bool(true, title = 'M1 On', group = 'Move Thresholds', inline = 'm1')
m1_dir = input.string('Up ▲', title = 'Dir', group = 'Move Thresholds', inline = 'm1', options = ['Up ▲', 'Down ▼', 'Either ↕'])
m1_val = input.float(1.0, title = '≥ %', group = 'Move Thresholds', inline = 'm1', step = 0.5, minval = 0.1)

m2_en = input.bool(true, title = 'M2 On', group = 'Move Thresholds', inline = 'm2')
m2_dir = input.string('Up ▲', title = 'Dir', group = 'Move Thresholds', inline = 'm2', options = ['Up ▲', 'Down ▼', 'Either ↕'])
m2_val = input.float(2.0, title = '≥ %', group = 'Move Thresholds', inline = 'm2', step = 0.5, minval = 0.1)

m3_en = input.bool(true, title = 'M3 On', group = 'Move Thresholds', inline = 'm3')
m3_dir = input.string('Up ▲', title = 'Dir', group = 'Move Thresholds', inline = 'm3', options = ['Up ▲', 'Down ▼', 'Either ↕'])
m3_val = input.float(5.0, title = '≥ %', group = 'Move Thresholds', inline = 'm3', step = 0.5, minval = 0.1)

m4_en = input.bool(true, title = 'M4 On', group = 'Move Thresholds', inline = 'm4')
m4_dir = input.string('Up ▲', title = 'Dir', group = 'Move Thresholds', inline = 'm4', options = ['Up ▲', 'Down ▼', 'Either ↕'])
m4_val = input.float(10.0, title = '≥ %', group = 'Move Thresholds', inline = 'm4', step = 0.5, minval = 0.1)

m5_en = input.bool(true, title = 'M5 On', group = 'Move Thresholds', inline = 'm5')
m5_dir = input.string('Down ▼', title = 'Dir', group = 'Move Thresholds', inline = 'm5', options = ['Up ▲', 'Down ▼', 'Either ↕'])
m5_val = input.float(1.0, title = '≥ %', group = 'Move Thresholds', inline = 'm5', step = 0.5, minval = 0.1)

m6_en = input.bool(true, title = 'M6 On', group = 'Move Thresholds', inline = 'm6')
m6_dir = input.string('Down ▼', title = 'Dir', group = 'Move Thresholds', inline = 'm6', options = ['Up ▲', 'Down ▼', 'Either ↕'])
m6_val = input.float(2.0, title = '≥ %', group = 'Move Thresholds', inline = 'm6', step = 0.5, minval = 0.1)

m7_en = input.bool(true, title = 'M7 On', group = 'Move Thresholds', inline = 'm7')
m7_dir = input.string('Down ▼', title = 'Dir', group = 'Move Thresholds', inline = 'm7', options = ['Up ▲', 'Down ▼', 'Either ↕'])
m7_val = input.float(5.0, title = '≥ %', group = 'Move Thresholds', inline = 'm7', step = 0.5, minval = 0.1)

m8_en = input.bool(true, title = 'M8 On', group = 'Move Thresholds', inline = 'm8')
m8_dir = input.string('Down ▼', title = 'Dir', group = 'Move Thresholds', inline = 'm8', options = ['Up ▲', 'Down ▼', 'Either ↕'])
m8_val = input.float(10.0, title = '≥ %', group = 'Move Thresholds', inline = 'm8', step = 0.5, minval = 0.1)

m9_en = input.bool(false, title = 'M9 On', group = 'Move Thresholds', inline = 'm9')
m9_dir = input.string('Either ↕', title = 'Dir', group = 'Move Thresholds', inline = 'm9', options = ['Up ▲', 'Down ▼', 'Either ↕'])
m9_val = input.float(3.0, title = '≥ %', group = 'Move Thresholds', inline = 'm9', step = 0.5, minval = 0.1)

m10_en = input.bool(false, title = 'M10 On', group = 'Move Thresholds', inline = 'm10')
m10_dir = input.string('Either ↕', title = 'Dir', group = 'Move Thresholds', inline = 'm10', options = ['Up ▲', 'Down ▼', 'Either ↕'])
m10_val = input.float(5.0, title = '≥ %', group = 'Move Thresholds', inline = 'm10', step = 0.5, minval = 0.1)

// ══════════════════════════════════════════════════════════════════
//  DISPLAY
// ══════════════════════════════════════════════════════════════════
tbl_pos = input.string('Top Right', title = 'Table Position', group = 'Display', options = ['Top Right', 'Top Left', 'Bottom Right', 'Bottom Left', 'Top Center', 'Bottom Center'])
show_pct = input.bool(true, title = 'Show % (else count)', group = 'Display')
heat_mode = input.bool(true, title = 'Heatmap Colors', group = 'Display')
text_sz = input.string('Tiny', title = 'Text Size', group = 'Display', options = ['Tiny', 'Small', 'Normal'])

// ══════════════════════════════════════════════════════════════════
//  EMA + DISTANCE
// ══════════════════════════════════════════════════════════════════
ema_val = request.security(syminfo.tickerid, ema_tf == '' ? timeframe.period : ema_tf, ta.ema(close, ema_len), lookahead = barmerge.lookahead_off)
dist = not na(ema_val) and ema_val != 0.0 ? (close - ema_val) / ema_val * 100.0 : na

// ══════════════════════════════════════════════════════════════════
//  ZONE HELPERS
// ══════════════════════════════════════════════════════════════════
zone_lo(int i) =>
    float v = na
    if i == 0
        v := z1_lo
        v
    else if i == 1
        v := z2_lo
        v
    else if i == 2
        v := z3_lo
        v
    else if i == 3
        v := z4_lo
        v
    else if i == 4
        v := z5_lo
        v
    else if i == 5
        v := z6_lo
        v
    else if i == 6
        v := z7_lo
        v
    else if i == 7
        v := z8_lo
        v
    v

zone_hi(int i) =>
    float v = na
    if i == 0
        v := z1_hi
        v
    else if i == 1
        v := z2_hi
        v
    else if i == 2
        v := z3_hi
        v
    else if i == 3
        v := z4_hi
        v
    else if i == 4
        v := z5_hi
        v
    else if i == 5
        v := z6_hi
        v
    else if i == 6
        v := z7_hi
        v
    else if i == 7
        v := z8_hi
        v
    v

zone_lbl(int i) =>
    string s = ''
    if i == 0
        s := z1_lbl
        s
    else if i == 1
        s := z2_lbl
        s
    else if i == 2
        s := z3_lbl
        s
    else if i == 3
        s := z4_lbl
        s
    else if i == 4
        s := z5_lbl
        s
    else if i == 5
        s := z6_lbl
        s
    else if i == 6
        s := z7_lbl
        s
    else if i == 7
        s := z8_lbl
        s
    s

zone_en(int i) =>
    bool b = false
    if i == 0
        b := z1_en
        b
    else if i == 1
        b := z2_en
        b
    else if i == 2
        b := z3_en
        b
    else if i == 3
        b := z4_en
        b
    else if i == 4
        b := z5_en
        b
    else if i == 5
        b := z6_en
        b
    else if i == 6
        b := z7_en
        b
    else if i == 7
        b := z8_en
        b
    b

// ══════════════════════════════════════════════════════════════════
//  MOVE HELPERS
// ══════════════════════════════════════════════════════════════════
move_en(int i) =>
    bool b = false
    if i == 0
        b := m1_en
        b
    else if i == 1
        b := m2_en
        b
    else if i == 2
        b := m3_en
        b
    else if i == 3
        b := m4_en
        b
    else if i == 4
        b := m5_en
        b
    else if i == 5
        b := m6_en
        b
    else if i == 6
        b := m7_en
        b
    else if i == 7
        b := m8_en
        b
    else if i == 8
        b := m9_en
        b
    else if i == 9
        b := m10_en
        b
    b

move_dir(int i) =>
    string s = 'Up ▲'
    if i == 0
        s := m1_dir
        s
    else if i == 1
        s := m2_dir
        s
    else if i == 2
        s := m3_dir
        s
    else if i == 3
        s := m4_dir
        s
    else if i == 4
        s := m5_dir
        s
    else if i == 5
        s := m6_dir
        s
    else if i == 6
        s := m7_dir
        s
    else if i == 7
        s := m8_dir
        s
    else if i == 8
        s := m9_dir
        s
    else if i == 9
        s := m10_dir
        s
    s

move_thr(int i) =>
    float v = na
    if i == 0
        v := m1_val
        v
    else if i == 1
        v := m2_val
        v
    else if i == 2
        v := m3_val
        v
    else if i == 3
        v := m4_val
        v
    else if i == 4
        v := m5_val
        v
    else if i == 5
        v := m6_val
        v
    else if i == 6
        v := m7_val
        v
    else if i == 7
        v := m8_val
        v
    else if i == 8
        v := m9_val
        v
    else if i == 9
        v := m10_val
        v
    v

move_lbl(int i) =>
    string d = move_dir(i)
    float v = move_thr(i)
    string sym = d == 'Up ▲' ? '▲≥' : d == 'Down ▼' ? '▼≥' : '↕≥'
    sym + str.tostring(v) + '%'

move_col(int i) =>
    string d = move_dir(i)
    color c = d == 'Up ▲' ? color.new(color.teal, 25) : d == 'Down ▼' ? color.new(color.red, 25) : color.new(color.purple, 25)
    c

// ══════════════════════════════════════════════════════════════════
//  GET ZONE  (0-based index, -1 = none)
// ══════════════════════════════════════════════════════════════════
get_zone(float v) =>
    int z = -1
    if not na(v)
        for i = 0 to 7 by 1
            if zone_en(i) and v >= zone_lo(i) and v <= zone_hi(i)
                z := i
                break
    z

// ══════════════════════════════════════════════════════════════════
//  COUNTERS
// ══════════════════════════════════════════════════════════════════
var array<int> visits = array.new_int(8, 0) // visits per zone
var array<int> hits = array.new_int(80, 0) // 8 zones × 10 moves

// Active slot tracking (10 concurrent)
var array<int> act_zone = array.new_int(10, -1)
var array<float> act_price = array.new_float(10, na)
var array<int> act_bar = array.new_int(10, -1)
var array<bool> slot_hit = array.new_bool(100, false) // 10 slots × 10 moves

var int prev_zone = -1
in_window = bar_index >= last_bar_index - lookback
cur_zone = get_zone(dist)

if in_window
    // Zone entry
    if cur_zone != prev_zone and cur_zone >= 0
        array.set(visits, cur_zone, array.get(visits, cur_zone) + 1)
        for si = 0 to 9 by 1
            if array.get(act_zone, si) < 0
                array.set(act_zone, si, cur_zone)
                array.set(act_price, si, close)
                array.set(act_bar, si, bar_index)
                for mi = 0 to 9 by 1
                    array.set(slot_hit, si * 10 + mi, false)
                break

    // Check moves
    for si = 0 to 9 by 1
        int az = array.get(act_zone, si)
        float ap = array.get(act_price, si)
        int ab = array.get(act_bar, si)
        if az >= 0 and not na(ap)
            if bar_index - ab > max_track
                array.set(act_zone, si, -1)
                array.set(act_bar, si, -1)
            else
                float mu = ap > 0 ? (high - ap) / ap * 100.0 : 0.0
                float md = ap > 0 ? (ap - low) / ap * 100.0 : 0.0
                for mi = 0 to 9 by 1
                    if move_en(mi) and not array.get(slot_hit, si * 10 + mi)
                        float thr = move_thr(mi)
                        string dir = move_dir(mi)
                        bool hit = dir == 'Up ▲' ? mu >= thr : dir == 'Down ▼' ? md >= thr : mu >= thr or md >= thr
                        if hit
                            array.set(slot_hit, si * 10 + mi, true)
                            int hidx = az * 10 + mi
                            array.set(hits, hidx, array.get(hits, hidx) + 1)

    prev_zone := cur_zone
    prev_zone

// ══════════════════════════════════════════════════════════════════
//  UTILITY
// ══════════════════════════════════════════════════════════════════
get_pos(string p) =>
    string r = position.top_right
    if p == 'Top Left'
        r := position.top_left
        r
    else if p == 'Bottom Right'
        r := position.bottom_right
        r
    else if p == 'Bottom Left'
        r := position.bottom_left
        r
    else if p == 'Top Center'
        r := position.top_center
        r
    else if p == 'Bottom Center'
        r := position.bottom_center
        r
    r

get_sz(string s) =>
    string r = size.tiny
    if s == 'Small'
        r := size.small
        r
    else if s == 'Normal'
        r := size.normal
        r
    r

heat_color(float pct, float mx) =>
    color c = color.new(color.gray, 80)
    if mx > 0 and pct > 0
        float r = pct / mx
        if r >= 0.75
            c := color.new(color.red, 10)
            c
        else if r >= 0.50
            c := color.new(color.orange, 25)
            c
        else if r >= 0.25
            c := color.new(color.yellow, 40)
            c
        else
            c := color.new(color.teal, 55)
            c
    c

// ══════════════════════════════════════════════════════════════════
//  DRAW TABLE
// ══════════════════════════════════════════════════════════════════
var table mtx = na

if barstate.islast
    if not na(mtx)
        table.delete(mtx)

    // Collect enabled zones + moves
    array<int> vz = array.new_int(0)
    for i = 0 to 7 by 1
        if zone_en(i)
            array.push(vz, i)

    array<int> vm = array.new_int(0)
    for i = 0 to 9 by 1
        if move_en(i)
            array.push(vm, i)

    int nz = array.size(vz)
    int nm = array.size(vm)

    if nz >= 1 and nm >= 1
        string tsz = get_sz(text_sz)
        int n_cols = nm + 2
        int n_rows = nz + 2

        mtx := table.new(get_pos(tbl_pos), n_cols, n_rows, border_color = color.new(color.white, 60), border_width = 1, frame_color = color.new(color.white, 50), frame_width = 1)

        // Header
        table.cell(mtx, 0, 0, 'Zone \\ Move', bgcolor = color.new(color.navy, 20), text_color = color.white, text_size = tsz)
        for ci = 0 to nm - 1 by 1
            int mi = array.get(vm, ci)
            table.cell(mtx, ci + 1, 0, move_lbl(mi), bgcolor = move_col(mi), text_color = color.white, text_size = tsz)
        table.cell(mtx, n_cols - 1, 0, 'Visits', bgcolor = color.new(color.gray, 30), text_color = color.white, text_size = tsz)

        // Global max for heatmap
        float gmax = 0.0
        for ri = 0 to nz - 1 by 1
            int zi = array.get(vz, ri)
            int vis = array.get(visits, zi)
            for ci = 0 to nm - 1 by 1
                int mi = array.get(vm, ci)
                int cnt = array.get(hits, zi * 10 + mi)
                float pv = vis > 0 ? cnt / vis * 100.0 : 0.0
                if pv > gmax
                    gmax := pv
                    gmax

        // Zone rows
        for ri = 0 to nz - 1 by 1
            int zi = array.get(vz, ri)
            int vis = array.get(visits, zi)
            bool is_cur = cur_zone == zi
            color lbl_bg = is_cur ? color.new(color.orange, 20) : color.new(color.blue, 40)
            table.cell(mtx, 0, ri + 1, (is_cur ? '► ' : '') + zone_lbl(zi), bgcolor = lbl_bg, text_color = color.white, text_size = tsz)

            for ci = 0 to nm - 1 by 1
                int mi = array.get(vm, ci)
                int cnt = array.get(hits, zi * 10 + mi)
                float pv = vis > 0 ? math.round(cnt / vis * 1000.0) / 10.0 : 0.0
                string ctxt = show_pct ? str.tostring(pv) + '%' : str.tostring(cnt)
                color cbg = heat_mode ? heat_color(pv, gmax) : move_col(mi)
                table.cell(mtx, ci + 1, ri + 1, ctxt, bgcolor = cbg, text_color = color.white, text_size = tsz)

            table.cell(mtx, n_cols - 1, ri + 1, str.tostring(vis), bgcolor = color.new(color.gray, 40), text_color = color.white, text_size = tsz)

        // Footer
        string now_txt = cur_zone >= 0 ? '► ' + zone_lbl(cur_zone) : 'Outside zones'
        color foot_bg = cur_zone >= 0 ? color.new(color.orange, 30) : color.new(color.gray, 50)
        string info = 'EMA' + str.tostring(ema_len) + ' · LB:' + str.tostring(lookback) + ' · Track:' + str.tostring(max_track) + 'b'
        table.cell(mtx, 0, n_rows - 1, now_txt, bgcolor = foot_bg, text_color = color.white, text_size = tsz)
        for ci = 0 to nm - 1 by 1
            table.cell(mtx, ci + 1, n_rows - 1, ci == 0 ? info : '', bgcolor = color.new(color.navy, 55), text_color = color.new(color.white, 40), text_size = tsz)
        table.cell(mtx, n_cols - 1, n_rows - 1, '', bgcolor = color.new(color.navy, 55), text_color = color.white, text_size = tsz)

// ══════════════════════════════════════════════════════════════════
//  BG HIGHLIGHT
// ══════════════════════════════════════════════════════════════════
bg_c = cur_zone == 0 ? color.new(color.red, 93) : cur_zone == 1 ? color.new(color.orange, 93) : cur_zone == 2 ? color.new(color.yellow, 94) : cur_zone == 3 ? color.new(color.gray, 97) : cur_zone == 4 ? color.new(color.gray, 97) : cur_zone == 5 ? color.new(color.teal, 93) : cur_zone == 6 ? color.new(color.teal, 90) : cur_zone == 7 ? color.new(color.teal, 86) : na
bgcolor(bg_c, title = 'Zone Highlight')
````
