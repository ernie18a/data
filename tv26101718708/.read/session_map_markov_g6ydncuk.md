# Session Map [Markov]

- url: https://www.tradingview.com/script/G6YDNCUK-Session-Map-Markov/
- type: indicator
- pine_id: PUB;28e3752036f74347a82bc05c2b003e2e
- version: 1.0

## Description

What it does
Draws the structure an index-futures session is actually organised around: prior day high/low/close, the overnight (Globex) range, the initial balance, the opening range, and a session-anchored VWAP with 1σ and 2σ bands.

How it works
Every level is built from timestamps rather than session strings, so the same window resolves identically on any intraday timeframe. The opening range and initial balance are measured in minutes from the RTH open, in the timezone you choose. VWAP is computed directly from price × volume, anchored to the RTH open, the Globex open, or the daily open; on symbols without volume it falls back to an unweighted mean rather than failing.

How to use it
Set your session windows once. The panel reports the current regime, where price sits against VWAP, the opening-range width, and the nearest level.

Settings: Session · VWAP · Regime engine · Session structure · Levels · Alerts

Alerts: Opening-range break, initial-balance break, VWAP 2σ tag. All alerts in the Markov suite emit the same JSON payload, so one webhook consumes them all.

Notes: Levels are session structure, not predictions. This is a chart tool and educational material, not investment advice.

## Source Code

````pine
// Markov · Session Map — the futures session skeleton: prior day, overnight,
// initial balance, opening range and an anchored VWAP, drawn one way on every
// chart in the suite. Free tier; the front door to everything else.
// © joshionchain

//@version=6
indicator("Session Map [Markov]", "MKV Map", overlay = true, max_lines_count = 100, max_labels_count = 100)

M_ID   = "session-map"
M_NAME = "Session Map"

// >>> MARKOV:KERNEL v1.0.0 (ace21668) — generated from pine/kernel/markov-kernel.pine. Do not edit here; run `pnpm pine:sync`.
// ── brand ────────────────────────────────────────────────────────────────────
M_BRAND   = "MARKOV"
M_VER     = "1.0.0"
M_SITE    = "markov.io"

// Chart palette. Derived from the site tokens in apps/web/app/globals.css and
// lifted for legibility on dark chart backgrounds (site --accent #2b50ff is too
// dark against #0a0c10). Keep these two in sync by hand when the brand moves.
color M_C_ACCENT = #5a78ff  // site --accent, lifted
color M_C_UP     = #14c08a  // site --up, lifted
color M_C_DOWN   = #f0555a  // site --down, lifted
color M_C_INK    = #e8ecf2
color M_C_DIM    = #8a93a0
color M_C_LINE   = #2a2f3a
color M_C_PANEL  = #0a0c10

// ── session ──────────────────────────────────────────────────────────────────
g_mv_ses = "Session (futures-native)"
i_tz  = input.string("America/New_York", "Timezone", options = ["America/New_York", "America/Chicago", "Europe/London", "Asia/Tokyo", "UTC"], group = g_mv_ses, tooltip = "All session windows below are evaluated in this timezone, not the chart's.")
i_rth = input.session("0930-1600", "Regular hours (RTH)", group = g_mv_ses)
i_on  = input.session("1800-0930", "Overnight (Globex)", group = g_mv_ses)

mvInRTH  = not na(time(timeframe.period, i_rth, i_tz))
mvInON   = not na(time(timeframe.period, i_on, i_tz))
mvNewRTH = mvInRTH and not mvInRTH[1]
mvEndRTH = not mvInRTH and mvInRTH[1]
mvNewON  = mvInON and not mvInON[1]

// ── anchored VWAP (computed by hand: `ta.vwap` errors on volume-less symbols) ─
g_mv_vwap = "VWAP"
i_vwapAnchor = input.string("RTH open", "Anchor", options = ["RTH open", "Globex open", "Daily"], group = g_mv_vwap)

mvNewAnchor = i_vwapAnchor == "RTH open" ? mvNewRTH : i_vwapAnchor == "Globex open" ? mvNewON : timeframe.change("D")

var float _mvPV  = 0.0
var float _mvVV  = 0.0
var float _mvP2V = 0.0
_mvW = nz(volume) > 0 ? volume : 1.0
if mvNewAnchor
    _mvPV  := 0.0
    _mvVV  := 0.0
    _mvP2V := 0.0
_mvPV  += hlc3 * _mvW
_mvVV  += _mvW
_mvP2V += hlc3 * hlc3 * _mvW
mvVwap   = _mvVV > 0 ? _mvPV / _mvVV : na
_mvVar   = _mvVV > 0 ? math.max(0.0, _mvP2V / _mvVV - mvVwap * mvVwap) : na
mvVwapSd = math.sqrt(_mvVar)

// ── regime engine ────────────────────────────────────────────────────────────
// Price-derived only. This is an expansion/compression proxy — it is NOT dealer
// gamma and must never be described as such. Three orthogonal reads, blended:
//   volatility percentile  · where is realised vol against its own history
//   efficiency ratio       · how much travel per unit of movement (Kaufman)
//   persistence            · variance ratio; >1 trends, <1 mean-reverts
g_mv_reg = "Regime engine"
i_regAtr   = input.int(14,  "ATR length",            minval = 2,  group = g_mv_reg)
i_regRank  = input.int(200, "Percentile lookback",   minval = 20, group = g_mv_reg, tooltip = "History used to rank current volatility and to normalise persistence.")
i_regEff   = input.int(20,  "Efficiency length",     minval = 2,  group = g_mv_reg)
i_regPer   = input.int(10,  "Persistence length",    minval = 2,  group = g_mv_reg)
i_regThr   = input.int(25,  "State threshold",       minval = 5, maxval = 90, group = g_mv_reg, tooltip = "Score above +threshold reads EXPANSION, below -threshold reads COMPRESSION.")

// ta.* must be evaluated on every bar to keep its internal state correct,
// so it is hoisted out of the ternary rather than called conditionally.
_mvAtr    = ta.atr(i_regAtr)
_mvAtrPct = close > 0 ? _mvAtr / close * 100 : na
mvVolPct  = ta.percentrank(_mvAtrPct, i_regRank)

_mvDir = math.abs(close - close[i_regEff])
_mvPath = math.sum(math.abs(ta.change(close)), i_regEff)
mvEff = _mvPath > 0 ? _mvDir / _mvPath : 0.0

_mvR1  = ta.change(math.log(close))
_mvRN  = ta.change(math.log(close), i_regPer)
_mvSd1 = ta.stdev(_mvR1, i_regRank)
_mvSdN = ta.stdev(_mvRN, i_regRank)
mvPersist = _mvSd1 > 0 ? _mvSdN / (_mvSd1 * math.sqrt(i_regPer)) : 1.0

f_mvClamp(float v, float lo, float hi) => math.max(lo, math.min(hi, v))

_mvZVol = nz(mvVolPct, 50.0) - 50.0
_mvZEff = f_mvClamp((mvEff - 0.35) * 200.0, -100.0, 100.0)
_mvZPer = f_mvClamp((nz(mvPersist, 1.0) - 1.0) * 150.0, -100.0, 100.0)
mvRegime = f_mvClamp(0.40 * _mvZVol + 0.35 * _mvZEff + 0.25 * _mvZPer, -100.0, 100.0)

mvState = mvRegime >= i_regThr ? "EXPANSION" : mvRegime <= -i_regThr ? "COMPRESSION" : "NEUTRAL"
mvStateColor = mvState == "EXPANSION" ? M_C_UP : mvState == "COMPRESSION" ? M_C_ACCENT : M_C_DIM
mvFlip = mvState != mvState[1]

// ── alert contract ───────────────────────────────────────────────────────────
// One JSON shape across the whole suite so a single webhook (and the Markov MCP
// surface) can consume every script. Bump "v" if the shape ever changes.
f_mvAlert(string kind, string dir, float px, string note) =>
    '{"v":1,"src":"markov","script":"' + M_ID + '","ver":"' + M_VER + '","sym":"' + syminfo.tickerid + '","tf":"' + timeframe.period + '","t":' + str.tostring(time_close) + ',"kind":"' + kind + '","dir":"' + dir + '","px":' + str.tostring(px, format.mintick) + ',"regime":"' + mvState + '","score":' + str.tostring(math.round(mvRegime)) + ',"note":"' + note + '"}'

// ── panel ────────────────────────────────────────────────────────────────────
g_mv_ui = "Panel"
i_panel    = input.bool(true, "Show panel", group = g_mv_ui)
i_panelPos = input.string("Bottom right", "Position", options = ["Top right", "Middle right", "Bottom right", "Bottom left"], group = g_mv_ui)

f_mvPanelPos() =>
    switch i_panelPos
        "Top right"    => position.top_right
        "Middle right" => position.middle_right
        "Bottom left"  => position.bottom_left
        => position.bottom_right

f_mvPanelNew(simple int rows) =>
    table.new(f_mvPanelPos(), 2, rows + 2, bgcolor = color.new(M_C_PANEL, 12), border_color = color.new(M_C_LINE, 30), border_width = 1, frame_color = color.new(M_C_LINE, 30), frame_width = 1)

f_mvPanelHead(table t) =>
    table.cell(t, 0, 0, M_BRAND, text_color = M_C_ACCENT, text_size = size.tiny, text_halign = text.align_left)
    table.cell(t, 1, 0, M_NAME, text_color = M_C_DIM, text_size = size.tiny, text_halign = text.align_right)

f_mvPanelRow(table t, int row, string k, string v, color vc) =>
    table.cell(t, 0, row, k, text_color = M_C_DIM, text_size = size.tiny, text_halign = text.align_left)
    table.cell(t, 1, row, v, text_color = vc, text_size = size.tiny, text_halign = text.align_right)

f_mvPanelFoot(table t, int row) =>
    table.cell(t, 0, row, M_SITE, text_color = color.new(M_C_DIM, 35), text_size = size.tiny, text_halign = text.align_left)
    table.cell(t, 1, row, "context, not advice", text_color = color.new(M_C_DIM, 35), text_size = size.tiny, text_halign = text.align_right)
// <<< MARKOV:KERNEL
// >>> MARKOV:LEVELS v1.0.0 (0bf6c7a8) — generated from pine/kernel/markov-kernel.pine. Do not edit here; run `pnpm pine:sync`.
// ── level rendering ──────────────────────────────────────────────────────────
// Shared by every script that draws horizontal levels, so a Markov level looks
// the same whether it came from the session structure or from the positioning
// feed. Drawings are rebuilt only on the last bar — constant object count.
type MvLevel
    float  price
    string name
    color  col
    bool   dashed

f_mvLevel(array<MvLevel> a, float price, string name, color col, bool dashed, bool show) =>
    if show and not na(price)
        array.push(a, MvLevel.new(price, name, col, dashed))

f_mvDrawLevels(array<MvLevel> lv, int x1, bool showLabels) =>
    var array<line>  _ln = array.new<line>()
    var array<label> _lb = array.new<label>()
    if barstate.islast
        while array.size(_ln) > 0
            line.delete(array.pop(_ln))
        while array.size(_lb) > 0
            label.delete(array.pop(_lb))
        _n = array.size(lv)
        if _n > 0
            for i = 0 to _n - 1
                l = array.get(lv, i)
                array.push(_ln, line.new(x1, l.price, time, l.price, xloc = xloc.bar_time, extend = extend.right, color = l.col, width = 1, style = l.dashed ? line.style_dashed : line.style_solid))
                if showLabels
                    array.push(_lb, label.new(time, l.price, l.name + "  " + str.tostring(l.price, format.mintick), xloc = xloc.bar_time, style = label.style_label_left, color = color.new(M_C_PANEL, 100), textcolor = l.col, size = size.tiny))

f_mvNearest(array<MvLevel> lv, float px) =>
    float best = na
    string nm = ""
    _n = array.size(lv)
    if _n > 0
        for i = 0 to _n - 1
            l = array.get(lv, i)
            d = math.abs(px - l.price)
            if na(best) or d < best
                best := d
                nm := l.name
    [nm, best]
// <<< MARKOV:LEVELS
// >>> MARKOV:RANGE v1.0.0 (0b260e32) — generated from pine/kernel/markov-kernel.pine. Do not edit here; run `pnpm pine:sync`.
// ── opening range & initial balance ──────────────────────────────────────────
// One definition of "the opening range" for the whole suite: what Session Map
// draws is exactly what the ORB strategy trades. Built from timestamps rather
// than session strings so any intraday timeframe resolves the same window.
g_mv_rng = "Session structure"
i_ibMin = input.int(60, "Initial balance (minutes)", minval = 5, maxval = 240, group = g_mv_rng)
i_orMin = input.int(15, "Opening range (minutes)",   minval = 1, maxval = 120, group = g_mv_rng)

var float mvRthOpen = na
var int   mvAnchor  = na
var float mvIbH = na
var float mvIbL = na
var float mvOrH = na
var float mvOrL = na

if mvNewRTH
    mvRthOpen := open
    mvAnchor  := time
    mvIbH := high
    mvIbL := low
    mvOrH := high
    mvOrL := low

mvInIB = mvInRTH and not na(mvAnchor) and time < mvAnchor + i_ibMin * 60000
mvInOR = mvInRTH and not na(mvAnchor) and time < mvAnchor + i_orMin * 60000

if mvInIB and not mvNewRTH
    mvIbH := math.max(nz(mvIbH, high), high)
    mvIbL := math.min(nz(mvIbL, low), low)
if mvInOR and not mvNewRTH
    mvOrH := math.max(nz(mvOrH, high), high)
    mvOrL := math.min(nz(mvOrL, low), low)

mvOrReady = mvInRTH and not mvInOR and not na(mvOrH)
mvIbReady = mvInRTH and not mvInIB and not na(mvIbH)
mvOrWidth = na(mvOrH) or na(mvOrL) ? na : mvOrH - mvOrL
mvMinFromOpen = na(mvAnchor) ? na : (time - mvAnchor) / 60000.0  // int/int truncates in Pine
// <<< MARKOV:RANGE
// ── inputs ───────────────────────────────────────────────────────────────────
g_lv = "Levels"
i_pd    = input.bool(true,  "Prior day H / L / C", group = g_lv)
i_showON = input.bool(true, "Overnight high / low", group = g_lv)
i_open  = input.bool(true,  "RTH open", group = g_lv)
i_ib    = input.bool(true,  "Initial balance", group = g_lv)
i_or    = input.bool(true,  "Opening range", group = g_lv)
i_mids  = input.bool(false, "Midpoints (IB / OR / overnight)", group = g_lv)
i_labels= input.bool(true,  "Price labels", group = g_lv)
i_orBox = input.bool(true,  "Shade the opening range", group = g_lv)

g_vw = "VWAP display"
i_vwShow = input.bool(true, "Line", inline = "v", group = g_vw)
i_vwB1   = input.bool(true, "1σ", inline = "v", group = g_vw)
i_vwB2   = input.bool(true, "2σ", inline = "v", group = g_vw)

g_al = "Alerts"
i_alOR   = input.bool(true, "Opening-range break", group = g_al)
i_alIB   = input.bool(true, "Initial-balance break", group = g_al)
i_alVW   = input.bool(false, "VWAP 2σ tag", group = g_al)

// ── session structure ────────────────────────────────────────────────────────
[pdH, pdL, pdC] = request.security(syminfo.tickerid, "D", [high[1], low[1], close[1]], lookahead = barmerge.lookahead_off)

var float onH = na
var float onL = na
if mvNewON
    onH := high
    onL := low
else if mvInON
    onH := math.max(nz(onH, high), high)
    onL := math.min(nz(onL, low), low)

var bool orUpDone = false
var bool orDnDone = false
var bool ibUpDone = false
var bool ibDnDone = false
if mvNewRTH
    orUpDone := false
    orDnDone := false
    ibUpDone := false
    ibDnDone := false


// ── draw ─────────────────────────────────────────────────────────────────────
color c_pd  = color.new(M_C_DIM, 0)
color c_on  = color.new(M_C_ACCENT, 0)
color c_op  = color.new(M_C_INK, 0)
color c_ib  = color.new(M_C_ACCENT, 35)
color c_or  = color.new(M_C_UP, 0)

var array<MvLevel> lv = array.new<MvLevel>()
array.clear(lv)
f_mvLevel(lv, pdH,  "PDH",  c_pd, false, i_pd)
f_mvLevel(lv, pdL,  "PDL",  c_pd, false, i_pd)
f_mvLevel(lv, pdC,  "PDC",  c_pd, true,  i_pd)
f_mvLevel(lv, onH,  "ONH",  c_on, false, i_showON)
f_mvLevel(lv, onL,  "ONL",  c_on, false, i_showON)
f_mvLevel(lv, mvRthOpen, "RTH OPEN", c_op, true, i_open)
f_mvLevel(lv, mvIbH,  "IBH",  c_ib, false, i_ib)
f_mvLevel(lv, mvIbL,  "IBL",  c_ib, false, i_ib)
f_mvLevel(lv, mvOrH,  "ORH",  c_or, false, i_or)
f_mvLevel(lv, mvOrL,  "ORL",  c_or, false, i_or)
f_mvLevel(lv, na(onH) or na(onL) ? na : (onH + onL) / 2, "ON MID", color.new(c_on, 45), true, i_showON and i_mids)
f_mvLevel(lv, na(mvIbH) or na(mvIbL) ? na : (mvIbH + mvIbL) / 2, "IB MID", color.new(c_ib, 25), true, i_ib and i_mids)
f_mvLevel(lv, na(mvOrH) or na(mvOrL) ? na : (mvOrH + mvOrL) / 2, "OR MID", color.new(c_or, 45), true, i_or and i_mids)

f_mvDrawLevels(lv, nz(mvAnchor, time), i_labels)

var box orShade = na
if i_orBox
    if mvNewRTH
        box.delete(orShade)
        orShade := box.new(time, high, time, low, xloc = xloc.bar_time, border_color = color.new(c_or, 70), bgcolor = color.new(c_or, 92))
    else if mvInOR and not na(orShade)
        box.set_rightbottom(orShade, time, mvOrL)
        box.set_lefttop(orShade, box.get_left(orShade), mvOrH)

plot(i_vwShow ? mvVwap : na, "VWAP", color = M_C_ACCENT, linewidth = 2)
p_u1 = plot(i_vwShow and i_vwB1 ? mvVwap + mvVwapSd : na, "VWAP +1σ", color = color.new(M_C_ACCENT, 55))
p_l1 = plot(i_vwShow and i_vwB1 ? mvVwap - mvVwapSd : na, "VWAP -1σ", color = color.new(M_C_ACCENT, 55))
plot(i_vwShow and i_vwB2 ? mvVwap + 2 * mvVwapSd : na, "VWAP +2σ", color = color.new(M_C_ACCENT, 75), style = plot.style_linebr)
plot(i_vwShow and i_vwB2 ? mvVwap - 2 * mvVwapSd : na, "VWAP -2σ", color = color.new(M_C_ACCENT, 75), style = plot.style_linebr)
fill(p_u1, p_l1, color = color.new(M_C_ACCENT, 95), title = "VWAP 1σ fill")

bgcolor(mvInRTH ? na : color.new(M_C_LINE, 92), title = "Outside RTH")

// ── alerts ───────────────────────────────────────────────────────────────────
orUp = mvOrReady and not orUpDone and close > mvOrH
orDn = mvOrReady and not orDnDone and close < mvOrL
ibUp = mvIbReady and not ibUpDone and close > mvIbH
ibDn = mvIbReady and not ibDnDone and close < mvIbL

if barstate.isconfirmed
    // The once-per-session latch is set whether or not alerts are enabled —
    // otherwise the marker repeats on every bar beyond the level.
    if orUp
        orUpDone := true
        if i_alOR
            alert(f_mvAlert("range_break", "long", close, "opening range high"), alert.freq_once_per_bar_close)
    if orDn
        orDnDone := true
        if i_alOR
            alert(f_mvAlert("range_break", "short", close, "opening range low"), alert.freq_once_per_bar_close)
    if ibUp
        ibUpDone := true
        if i_alIB
            alert(f_mvAlert("range_break", "long", close, "initial balance high"), alert.freq_once_per_bar_close)
    if ibDn
        ibDnDone := true
        if i_alIB
            alert(f_mvAlert("range_break", "short", close, "initial balance low"), alert.freq_once_per_bar_close)
    if i_alVW and not na(mvVwapSd) and mvVwapSd > 0
        if high >= mvVwap + 2 * mvVwapSd
            alert(f_mvAlert("vwap_tag", "short", close, "upper 2 sigma"), alert.freq_once_per_bar_close)
        if low <= mvVwap - 2 * mvVwapSd
            alert(f_mvAlert("vwap_tag", "long", close, "lower 2 sigma"), alert.freq_once_per_bar_close)

plotshape(orUp and barstate.isconfirmed, "OR break up", shape.triangleup, location.belowbar, M_C_UP, size = size.tiny)
plotshape(orDn and barstate.isconfirmed, "OR break down", shape.triangledown, location.abovebar, M_C_DOWN, size = size.tiny)

// ── panel ────────────────────────────────────────────────────────────────────
// Hoisted: Pine does not accept a tuple declaration inside a local block.
[nearName, nearDist] = f_mvNearest(lv, close)

var table pnl = f_mvPanelNew(5)
if i_panel and barstate.islast
    _vwDist = na(mvVwap) ? na : close - mvVwap
    _orW = mvOrWidth
    f_mvPanelHead(pnl)
    f_mvPanelRow(pnl, 1, "regime", mvState + "  " + str.tostring(math.round(mvRegime)), mvStateColor)
    f_mvPanelRow(pnl, 2, "session", mvInRTH ? "RTH" : mvInON ? "GLOBEX" : "CLOSED", mvInRTH ? M_C_UP : M_C_DIM)
    f_mvPanelRow(pnl, 3, "vs VWAP", na(_vwDist) ? "—" : str.tostring(_vwDist, format.mintick), na(_vwDist) ? M_C_DIM : _vwDist >= 0 ? M_C_UP : M_C_DOWN)
    f_mvPanelRow(pnl, 4, "OR width", na(_orW) ? "—" : str.tostring(_orW, format.mintick), M_C_INK)
    f_mvPanelRow(pnl, 5, "nearest", nearName == "" ? "—" : nearName + "  " + str.tostring(nearDist, format.mintick), M_C_INK)
    f_mvPanelFoot(pnl, 6)
````
