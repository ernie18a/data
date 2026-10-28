# Sphinx Gamma Terrain

- url: https://www.tradingview.com/script/br9iu2eD-Sphinx-Gamma-Terrain/
- type: indicator
- pine_id: PUB;e06525571ddb462b83ca43366aa1bc90
- version: 2.0

## Description

Sphinx Gamma Terrain renders options dealer-gamma positioning - gamma flip
levels and call/put walls across multiple expiries - as a structural map on
your chart. It is a context layer that shows where the gamma structure sits
and which regime price is trading inside. It does not generate buy/sell
signals, predictions, or automated trades.

Why it is original

Pine Script cannot fetch external options data such as dealer gamma exposure,
flip levels, or wall strikes. This tool solves that by taking a compact text
export of gamma levels and turning it into on-chart terrain. Two things make
it distinct from a plain level-drawing script:

1. A symbol-aware parser reads a full multi-instrument, multi-expiry gamma
   export in a single paste and locks onto the current chart's instrument
   (an ES/MES chart pulls the ES block), so a stacked NQ or GC block cannot
   overwrite it.

2. A graduated, count-based regime model. Instead of a flat two-colour zone,
   the shading deepens according to how many flip levels price sits above or
   below, split at the median flip - so the depth of the positive- or
   negative-gamma regime is readable as tone rather than a single on/off band.

It is provider-agnostic: it works with any gamma/GEX source. Either paste a
string in the documented format, or type the levels in manually. Nothing is
hard-wired to one vendor.

The three layers

- Flip ladder: gamma flip levels for near, mid and far expiries. The reactive
  near-term flip is dashed; the more stable mid/far flips are dotted and drawn
  thicker, because they define the regime frame.
- Regime shading: green (fade) above the flips, where positive gamma tends to
  suppress moves and mean-revert; red (trend) below, where negative gamma
  tends to amplify. Tone deepens with regime depth, and the green/red split
  lands on the median flip so the two never overlap.
- Confluence walls: call and put walls across expiries, clustered so walls
  within a tolerance band merge into a single reversal zone. A multi-strike
  cluster is drawn as a translucent band spanning its strikes, tagged with the
  number of hits - the heavy multi-expiry shelves stand out from lone walls.

How to use it

1. Choose an input mode. Paste string auto-parses an export of the form
   SYM.DTE:F<flip>|CW<call walls>|PW<put walls>, with expiries separated by
   semicolons. Manual levels lets you type each flip and wall set yourself;
   any field left blank is simply not drawn.
2. The tool locks to your chart's instrument and draws that instrument's
   flips, regime zones and walls.
3. Read the terrain as a frame, not a trigger: note which regime price is in,
   where the nearest flip or wall reversal zone sits, and how the tenors
   stack. Combine it with your own timing and execution method.

Inputs

Flips, regime zones and walls each have independent visibility, colour,
opacity and width controls. The regime shading exposes six opacity tiers
(three each direction) so you can tune how strongly depth reads. Wall cluster
tolerance is adjustable - widen it to treat a band of strikes as one reversal
zone, tighten it for per-strike reads. Defaults are tuned for a dark theme and
can be dialled back for live use.

Limitations

- The data is external and static: the tool draws whatever you last pasted or
  typed. It does not auto-update - refresh your gamma export when the structure
  changes (for example at the open, mid-session, or on a flip crossing).
- It is a positioning and context map, not a signal engine. There are no
  alerts, entries, or performance claims, and gamma levels always require
  judgement in context.
- Level accuracy depends entirely on your data source.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0
// © Sphinx Gamma Terrain
//
//   A dealer-positioning TERRAIN map, not a signal generator. It shows WHERE the gamma
//   structure sits and WHICH regime price is in — the frame that SMT (timing) and VWAP/
//   volume-profile (execution) get read inside. No entries, no cards, no automation.
//
//   Three layers:
//     1. Flip ladder      — 0/7/30 DTE flips. 0D reactive (dashed), 7/30 stable (dotted).
//     2. Regime zones      — FADE shading above the stable (7/30) flips (positive gamma,
//                            suppress / mean-revert), TREND shading below (negative gamma,
//                            amplify / follow). The gamma asymmetry made visible as space.
//     3. Confluence walls  — call / put walls across all three tenors, WEIGHTED by how many
//                            tenors stack at a strike (×2 / ×3). Multi-tenor stacks are the
//                            heavy structural magnets; lone walls stay thin.
//
//   Data: paste per tenor as  flip | call1,call2,... | put1,put2,...   (no spaces).
//   SPHINX GAMMA TERRAIN v2.0
//@version=6
indicator("Sphinx Gamma Terrain", shorttitle = "Sphinx Gamma Terrain", overlay = true, max_lines_count = 200, max_labels_count = 200, max_boxes_count = 60)

// ============================================================
// PALETTE
// ============================================================
C_GOLD    = #C9A85E
C_PALE    = #E6D49B
C_BONE    = #ECE7DA
C_MATRIX  = #5FB187
C_RUST    = #D2603C
C_BLUE    = #7FA8C6
C_OBS     = #14110D

// ============================================================
// INPUTS
// ============================================================
g_d = "⠀Gamma Data"
input_mode = input.string("Paste string", "⠀Input mode", group = g_d, options = ["Paste string", "Manual levels"], tooltip = "Paste string: auto-parse a provider export in the SYM.DTE:F..|CW..|PW.. form (locks to this chart's instrument). Manual levels: type the numbers yourself — works with ANY gamma provider. Any field left blank is simply not drawn.")
gex_str = input.string("ES.0:F7516|CW7525,7510,7500|PW7525,7530;ES.7:F7598|CW7550,7575,7530|PW7500,7550,7450;ES.30:F7679|CW7600,7680,7550|PW7500,7400,7450", "⠀Paste GEX string", group = g_d, tooltip = "Paste the FULL gamma/GEX export here — all tenors and all instruments, exactly as copied. The tool locks onto THIS chart's instrument (e.g. MES → ES) and pulls the 0 / 7 / 30 DTE flips and walls out itself. One paste, no splitting.")

g_m = "⠀Manual Levels  (used when Input mode = Manual)"
_mt = "Type the level(s). Blank = not drawn. Walls are comma-separated, e.g. 7600,7550,7575."
m_f0  = input.string("", "⠀0DTE flip",       group = g_m, inline = "m0")
m_cw0 = input.string("", "CW",               group = g_m, inline = "m0", tooltip = _mt)
m_pw0 = input.string("", "PW",               group = g_m, inline = "m0")
m_f7  = input.string("", "⠀7DTE flip",       group = g_m, inline = "m7")
m_cw7 = input.string("", "CW",               group = g_m, inline = "m7", tooltip = _mt)
m_pw7 = input.string("", "PW",               group = g_m, inline = "m7")
m_f30 = input.string("", "⠀30DTE flip",      group = g_m, inline = "m30")
m_cw30= input.string("", "CW",               group = g_m, inline = "m30", tooltip = _mt)
m_pw30= input.string("", "PW",               group = g_m, inline = "m30")

g_f = "⠀Flips"
show_flips = input.bool(true,     "⠀Show flip lines",     group = g_f)
col_0d     = input.color(C_PALE,  "⠀0DTE (reactive)",     group = g_f)
col_htf    = input.color(C_BONE,  "⠀7D / 30D (stable)",   group = g_f)

g_z = "⠀Regime Zones"
show_zones  = input.bool(true,     "⠀Show regime shading",         group = g_z)
zone_use_0d = input.bool(true,     "⠀Include 0DTE in depth count", group = g_z, tooltip = "On: all 3 flips drive depth, so the deepest tier needs price beyond all three. Off: only the stable 7/30 flips shade the regime (closer to the original binary frame).")
col_fade    = input.color(C_MATRIX, "⠀Fade hue (above flips)",     group = g_z)
col_trend   = input.color(C_RUST,   "⠀Trend hue (below flips)",    group = g_z)
op_fade_3   = input.int(80, "⠀Fade — above all 3 (deep)", group = g_z, minval = 0, maxval = 100)
op_fade_2   = input.int(86, "⠀Fade — above 2 (med)",      group = g_z, minval = 0, maxval = 100)
op_fade_1   = input.int(92, "⠀Fade — above 1 (faint)",    group = g_z, minval = 0, maxval = 100)
op_trend_3  = input.int(80, "⠀Trend — below all 3 (deep)",group = g_z, minval = 0, maxval = 100)
op_trend_2  = input.int(86, "⠀Trend — below 2 (med)",     group = g_z, minval = 0, maxval = 100)
op_trend_1  = input.int(92, "⠀Trend — below 1 (faint)",   group = g_z, minval = 0, maxval = 100)

g_w = "⠀Walls"
show_walls = input.bool(true,     "⠀Show walls",              group = g_w)
col_cw     = input.color(C_GOLD,  "⠀Call walls",              group = g_w)
col_pw     = input.color(C_BLUE,  "⠀Put walls",               group = g_w)
wall_tol   = input.float(10.0,    "⠀Cluster tolerance (pts)", group = g_w, minval = 0.25, maxval = 20.0, step = 0.25, tooltip = "Walls within this band merge into one reversal zone. 10 ≈ 2–3 ES strikes. Drop to ~2 for per-strike live reads.")
wall_zone  = input.bool(true,     "⠀Clusters as zone bands",  group = g_w, tooltip = "On: a multi-strike cluster draws a translucent band spanning its strikes (the reversal-zone width). Off: a single line at the cluster mean.")
wall_zop   = input.int(82,        "⠀Zone band opacity",       group = g_w, minval = 0, maxval = 100)

// ============================================================
// PARSE — full GEX string, symbol-aware, all three tenors
// ============================================================
_gex_after(s, marker) =>
    int p = str.pos(s, marker)
    na(p) ? "" : str.substring(s, p + str.length(marker), str.length(s))

// The GEX string separates fields with '|' and expiries with ';' (sometimes newlines). Normalise
// both to '|', walk the segments, lock onto THIS chart's root (MES→ES) so a stacked NQ/GC
// block can't overwrite it, and route each expiry's flip + walls into its tenor bucket.
gex_parse(s, target) =>
    float f0 = na
    float f7 = na
    float f30 = na
    float[] c0  = array.new_float()
    float[] c7  = array.new_float()
    float[] c30 = array.new_float()
    float[] p0  = array.new_float()
    float[] p7  = array.new_float()
    float[] p30 = array.new_float()
    if str.length(s) > 0
        string _norm = str.replace_all(str.replace_all(s, ';', '|'), '\n', '|')
        string[] segs = str.split(_norm, '|')
        if array.size(segs) > 0
            int  cur_dte   = -1
            bool cur_match = false
            for i = 0 to array.size(segs) - 1
                string seg = str.replace_all(array.get(segs, i), ' ', '')
                if str.contains(seg, ':F')
                    int dotp = str.pos(seg, '.')
                    int colp = str.pos(seg, ':')
                    string _sym  = (not na(dotp) and dotp > 0) ? str.substring(seg, 0, dotp) : ''
                    float  _dtef = (not na(dotp) and not na(colp) and colp > dotp + 1) ? str.tonumber(str.substring(seg, dotp + 1, colp)) : na
                    cur_dte   := na(_dtef) ? -1 : int(_dtef)
                    cur_match := str.length(_sym) > 0 and (str.endswith(target, _sym) or target == _sym)
                    if cur_match
                        float _fv = str.tonumber(_gex_after(seg, ':F'))
                        if cur_dte == 0
                            f0 := _fv
                        else if cur_dte == 7
                            f7 := _fv
                        else if cur_dte == 30
                            f30 := _fv
                else if str.startswith(seg, 'CW') and cur_match
                    string[] parts = str.split(_gex_after(seg, 'CW'), ',')
                    if array.size(parts) > 0
                        for j = 0 to array.size(parts) - 1
                            float v = str.tonumber(array.get(parts, j))
                            if not na(v)
                                if cur_dte == 0
                                    array.push(c0, v)
                                else if cur_dte == 7
                                    array.push(c7, v)
                                else if cur_dte == 30
                                    array.push(c30, v)
                else if str.startswith(seg, 'PW') and cur_match
                    string[] parts = str.split(_gex_after(seg, 'PW'), ',')
                    if array.size(parts) > 0
                        for j = 0 to array.size(parts) - 1
                            float v = str.tonumber(array.get(parts, j))
                            if not na(v)
                                if cur_dte == 0
                                    array.push(p0, v)
                                else if cur_dte == 7
                                    array.push(p7, v)
                                else if cur_dte == 30
                                    array.push(p30, v)
    [f0, f7, f30, c0, c7, c30, p0, p7, p30]

// manual-mode helpers — empty input yields na / empty array (so blank = not drawn)
_mnum(s) =>
    string _s = str.replace_all(s, ' ', '')
    str.length(_s) > 0 ? str.tonumber(_s) : na
_mcsv(s) =>
    float[] out = array.new_float()
    string _s = str.replace_all(s, ' ', '')
    if str.length(_s) > 0
        string[] parts = str.split(_s, ',')
        if array.size(parts) > 0
            for j = 0 to array.size(parts) - 1
                float v = str.tonumber(array.get(parts, j))
                if not na(v)
                    array.push(out, v)
    out

var float f0  = na
var float f7  = na
var float f30 = na
var float[] cw0  = array.new_float()
var float[] cw7  = array.new_float()
var float[] cw30 = array.new_float()
var float[] pw0  = array.new_float()
var float[] pw7  = array.new_float()
var float[] pw30 = array.new_float()
if barstate.isfirst
    if input_mode == "Manual levels"
        f0 := _mnum(m_f0), f7 := _mnum(m_f7), f30 := _mnum(m_f30)
        cw0 := _mcsv(m_cw0), cw7 := _mcsv(m_cw7), cw30 := _mcsv(m_cw30)
        pw0 := _mcsv(m_pw0), pw7 := _mcsv(m_pw7), pw30 := _mcsv(m_pw30)
    else
        [_f0, _f7, _f30, _c0, _c7, _c30, _p0, _p7, _p30] = gex_parse(gex_str, str.upper(syminfo.root))
        f0 := _f0, f7 := _f7, f30 := _f30
        cw0 := _c0, cw7 := _c7, cw30 := _c30
        pw0 := _p0, pw7 := _p7, pw30 := _p30

// ============================================================
// WALL CLUSTERING — count how many tenors stack at each strike
// ============================================================
// Mutates lo/hi/cnt (passed by reference): for each wall in arr, merge into an existing
// cluster whose midpoint sits within tol (++count, widen the lo..hi span) or start a new
// one. cnt = wall-hits in the band; lo..hi = the reversal-zone span drawn on chart.
_cluster_add(lo, hi, cnt, arr, tol) =>
    if array.size(arr) > 0
        for i = 0 to array.size(arr) - 1
            float w = array.get(arr, i)
            if not na(w)
                int hit = -1
                if array.size(lo) > 0
                    for j = 0 to array.size(lo) - 1
                        float mid = (array.get(lo, j) + array.get(hi, j)) / 2
                        if math.abs(mid - w) <= tol
                            hit := j
                            break
                if hit >= 0
                    array.set(cnt, hit, array.get(cnt, hit) + 1)
                    if w < array.get(lo, hit)
                        array.set(lo, hit, w)
                    if w > array.get(hi, hit)
                        array.set(hi, hit, w)
                else
                    array.push(lo, w)
                    array.push(hi, w)
                    array.push(cnt, 1)

// ============================================================
// DRAW HANDLES + TEARDOWN
// ============================================================
var line[]  _lns = array.new_line()
var label[] _lbs = array.new_label()
var box[]   _bxs = array.new_box()
_wipe() =>
    if array.size(_lns) > 0
        for i = 0 to array.size(_lns) - 1
            line.delete(array.get(_lns, i))
        array.clear(_lns)
    if array.size(_lbs) > 0
        for i = 0 to array.size(_lbs) - 1
            label.delete(array.get(_lbs, i))
        array.clear(_lbs)
    if array.size(_bxs) > 0
        for i = 0 to array.size(_bxs) - 1
            box.delete(array.get(_bxs, i))
        array.clear(_bxs)

_flip_line(px, col, sty, xr, wd) =>
    if not na(px) and px > 0
        array.push(_lns, line.new(bar_index - 1500, px, xr, px, color = col, width = wd, style = sty, extend = extend.left))

_flip_lbl(px, txt, col, xoff) =>
    if not na(px) and px > 0
        array.push(_lbs, label.new(bar_index + xoff, px, txt, style = label.style_label_left, color = color.new(C_OBS, 100), textcolor = col, size = size.small))

_wall_row(lo, hi, cnt, col, tag, xr, gap) =>
    if array.size(lo) > 0
        float[] _placed = array.new_float()
        for i = 0 to array.size(lo) - 1
            float _lo = array.get(lo, i)
            float _hi = array.get(hi, i)
            int   c   = array.get(cnt, i)
            float mid = (_lo + _hi) / 2
            int   wd  = c >= 3 ? 3 : c == 2 ? 2 : 1
            // multi-strike cluster → translucent band spanning the reversal zone
            if wall_zone and _hi > _lo
                array.push(_bxs, box.new(bar_index - 1500, _hi, xr, _lo, bgcolor = color.new(col, wall_zop), border_color = color.new(col, 60)))
            // center line at the cluster mid — full opacity, width scales with stack count
            array.push(_lns, line.new(bar_index - 1500, mid, xr, mid, color = color.new(col, 0), width = wd, style = line.style_dotted, extend = extend.left))
            // stagger label right if it would collide with one already placed in this column
            int _nud = 0
            if array.size(_placed) > 0
                for k = 0 to array.size(_placed) - 1
                    if math.abs(array.get(_placed, k) - mid) < gap
                        _nud += 1
            array.push(_lbs, label.new(xr + _nud * 12, mid, tag + (c > 1 ? " ×" + str.tostring(c) : ""), style = label.style_label_left, color = color.new(C_OBS, 100), textcolor = col, size = size.small))
            array.push(_placed, mid)

// ============================================================
// RENDER  (last bar only)
// ============================================================
if barstate.islast
    _wipe()
    int _xr_cw  = bar_index + 28
    int _xr_pw  = bar_index + 44
    int _xr_f   = bar_index + 62
    int _xr_box = bar_index + 80
    float _lbl_gap = close * 0.0018

    // — REGIME ZONES: graduated depth shading. Sort the present flips, then for every band
    //   between them count how many flips price sits above vs below. The larger count sets
    //   both direction (green fade above the median flip / red trend below) and depth
    //   (deeper stack → deeper tone). Split at the median so green and red never overlap;
    //   the faint tier auto-engages when fewer flips are present. 0DTE optionally joins.
    if show_zones
        float[] _fs = array.new_float()
        if zone_use_0d and not na(f0)
            array.push(_fs, f0)
        if not na(f7)
            array.push(_fs, f7)
        if not na(f30)
            array.push(_fs, f30)
        int _n = array.size(_fs)
        if _n > 0
            array.sort(_fs, order.ascending)
            float _big = 1000.0
            for r = 0 to _n
                float _rlo = r == 0  ? array.get(_fs, 0) - _big      : array.get(_fs, r - 1)
                float _rhi = r == _n ? array.get(_fs, _n - 1) + _big : array.get(_fs, r)
                int   _below = r
                int   _above = _n - r
                if _below != _above
                    bool  _green = _below > _above
                    int   _depth = _green ? _below : _above
                    color _hue   = _green ? col_fade : col_trend
                    int   _op    = _depth >= 3 ? (_green ? op_fade_3 : op_trend_3) : _depth == 2 ? (_green ? op_fade_2 : op_trend_2) : (_green ? op_fade_1 : op_trend_1)
                    array.push(_bxs, box.new(bar_index - 1500, _rhi, _xr_box, _rlo, bgcolor = color.new(_hue, _op), border_color = color.new(C_OBS, 100)))

    // — WALLS: clustered across tenors, weighted by stack count. CW and PW each get their OWN
    //   aligned column so a call wall and put wall at the same price don't collide.
    if show_walls
        float[] _clo = array.new_float()
        float[] _chi = array.new_float()
        int[]   _ccn = array.new_int()
        _cluster_add(_clo, _chi, _ccn, cw0,  wall_tol)
        _cluster_add(_clo, _chi, _ccn, cw7,  wall_tol)
        _cluster_add(_clo, _chi, _ccn, cw30, wall_tol)
        _wall_row(_clo, _chi, _ccn, col_cw, "CW", _xr_cw, _lbl_gap)
        float[] _plo = array.new_float()
        float[] _phi = array.new_float()
        int[]   _pcn = array.new_int()
        _cluster_add(_plo, _phi, _pcn, pw0,  wall_tol)
        _cluster_add(_plo, _phi, _pcn, pw7,  wall_tol)
        _cluster_add(_plo, _phi, _pcn, pw30, wall_tol)
        _wall_row(_plo, _phi, _pcn, col_pw, "PW", _xr_pw, _lbl_gap)

    // — FLIP LADDER: 0D reactive (dashed), 7/30 stable (dotted) — flips get their own far
    //   column, all aligned at the same offset. 30DTE is nudged right ONLY when it lands close
    //   enough to 7DTE or 0DTE that the labels would overlap; otherwise it stays column-aligned.
    if show_flips
        _flip_line(f0,  col_0d,  line.style_dashed, _xr_f, 1)
        _flip_line(f7,  col_htf, line.style_dotted, _xr_f, 2)
        _flip_line(f30, col_htf, line.style_dotted, _xr_f, 2)
        bool  _f30_clash = (not na(f30) and not na(f7) and math.abs(f30 - f7) < _lbl_gap) or (not na(f30) and not na(f0) and math.abs(f30 - f0) < _lbl_gap)
        _flip_lbl(f0,  "0DTE",  col_0d,  64)
        _flip_lbl(f7,  "7DTE",  col_htf, 64)
        _flip_lbl(f30, "30DTE", col_htf, _f30_clash ? 74 : 64)
````
