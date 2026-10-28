# Poopy Dev Levels

- url: https://www.tradingview.com/script/UFNHMBRj-Poopy-Dev-Levels/
- type: indicator
- pine_id: PUB;5053c85554884e4f918e3130a4e88a0e
- version: 1.0

## Description

In this indciator we are able to foracst where the chart finna move due ot std dev or whatnot lol

## Source Code

````pine
//@version=6
// ══════════════════════════════════════════════════════════════════════════════
//  STANDARD DEVIATION PROJECTION LEVELS  (HTF + LTF Manipulation Legs)
// ──────────────────────────────────────────────────────────────────────────────
//  Auto-detects liquidity sweeps (manipulation) on both a high timeframe and
//  the current chart, waits for a market-structure shift (MSS) confirming the
//  distribution direction, then projects standard deviation levels:
//      -2.0, -2.5, -4.0, -4.5  (optional: 0 and -1)
//
//  LOGIC
//  ─────
//      Anchor  (=-1) : swing point BEFORE the sweep  (start of manipulation leg)
//      Sweep   ( 0)  : the liquidity grab            (end of manipulation leg)
//      Range         : |sweep - anchor|
//      Level price   : sweep + dir * mult * range
//                          dir = +1 for bullish distribution (sweep low)
//                          dir = -1 for bearish distribution (sweep high)
//
//      MSS : price closes back through the anchor (confirming the manipulation
//            is over and distribution has begun).
// ══════════════════════════════════════════════════════════════════════════════

indicator("Standard Deviation Projection Levels", "Dev Levels",
     overlay          = true,
     max_lines_count  = 500,
     max_labels_count = 500)

// ═══════════════════════════ INPUTS ═══════════════════════════

// ── High Timeframe ──
g_htf = "High Timeframe (HTF) Manipulation"
i_htf_on   = input.bool(true,       "Enable HTF",              group=g_htf)
i_htf_tf   = input.timeframe("240", "HTF Timeframe",           group=g_htf,
     tooltip="Timeframe to scan for HTF manipulation legs (e.g. 240 = 4H, D = daily).")
i_htf_piv  = input.int(2, "HTF Pivot Strength", minval=1, maxval=20, group=g_htf,
     tooltip="Bars on each side needed to confirm an HTF swing. Higher = bigger swings only.")
i_htf_col  = input.color(#ff9800, "HTF Color", group=g_htf)
i_htf_wid  = input.int(2, "HTF Line Width", minval=1, maxval=5, group=g_htf)

// ── Low Timeframe ──
g_ltf = "Low Timeframe (LTF — current chart)"
i_ltf_on   = input.bool(true, "Enable LTF", group=g_ltf)
i_ltf_piv  = input.int(5, "LTF Pivot Strength", minval=1, maxval=20, group=g_ltf)
i_ltf_col  = input.color(#00bcd4, "LTF Color", group=g_ltf)
i_ltf_wid  = input.int(1, "LTF Line Width", minval=1, maxval=5, group=g_ltf)

// ── Levels ──
g_lv = "Deviation Levels"
i_s_0   = input.bool(false, "Show 0 (Sweep Point)", group=g_lv, inline="a")
i_s_n1  = input.bool(false, "Show -1 (Range Base)", group=g_lv, inline="a")
i_s_n2  = input.bool(true,  "Show -2.0",            group=g_lv, inline="b")
i_s_n25 = input.bool(true,  "Show -2.5",            group=g_lv, inline="b")
i_s_n4  = input.bool(true,  "Show -4.0",            group=g_lv, inline="c")
i_s_n45 = input.bool(true,  "Show -4.5",            group=g_lv, inline="c")

// ── Behavior ──
g_b = "Behavior"
i_require_mss = input.bool(true, "Require MSS before drawing", group=g_b,
     tooltip="Wait for price to close back through the anchor (confirming distribution) before drawing levels.")
i_max         = input.int(2, "Max Active Setups per Timeframe", minval=1, maxval=5, group=g_b)
i_invalidate  = input.bool(true, "Remove setup when sweep is violated", group=g_b,
     tooltip="If price closes back past the sweep point, the setup is treated as failed.")
i_show_leg    = input.bool(true, "Draw manipulation leg", group=g_b)
i_style_s     = input.string("Solid", "Line Style", options=["Solid","Dashed","Dotted"], group=g_b)
i_lsize_s     = input.string("Small", "Label Size",  options=["Tiny","Small","Normal"],  group=g_b)

LSTYLE = i_style_s == "Dashed" ? line.style_dashed : i_style_s == "Dotted" ? line.style_dotted : line.style_solid
LSIZE  = i_lsize_s == "Tiny"   ? size.tiny        : i_lsize_s == "Normal" ? size.normal       : size.small

// ═══════════════════════════ TYPE ═══════════════════════════

type DevSetup
    int    anchor_time
    int    sweep_time
    float  anchor_price
    float  sweep_price
    int    dir
    float  mss_level
    bool   confirmed
    bool   drawn
    bool   is_htf
    array<line>  lns
    array<label> lbs
    line   leg

// ═══════════════════════════ METHODS ═══════════════════════════

method clearAll(DevSetup s) =>
    if array.size(s.lns) > 0
        for i = 0 to array.size(s.lns) - 1
            line.delete(array.get(s.lns, i))
        array.clear(s.lns)
    if array.size(s.lbs) > 0
        for i = 0 to array.size(s.lbs) - 1
            label.delete(array.get(s.lbs, i))
        array.clear(s.lbs)
    if not na(s.leg)
        line.delete(s.leg)
        s.leg := na

method addLevel(DevSetup s, float mult, string txt, color col, int width) =>
    float rng = math.abs(s.sweep_price - s.anchor_price)
    float p   = s.sweep_price + s.dir * mult * rng
    line ln   = line.new(s.sweep_time, p, s.sweep_time + 1, p,
         xloc=xloc.bar_time, color=col, width=width, style=LSTYLE, extend=extend.right)
    array.push(s.lns, ln)
    label lb  = label.new(s.sweep_time, p, txt,
         xloc=xloc.bar_time,
         color=color.new(color.black, 100),
         textcolor=col,
         style=label.style_label_left,
         size=LSIZE)
    array.push(s.lbs, lb)

method drawAll(DevSetup s, color col, int width) =>
    if i_show_leg
        s.leg := line.new(s.anchor_time, s.anchor_price, s.sweep_time, s.sweep_price,
             xloc=xloc.bar_time, color=color.new(col, 40), width=1, style=line.style_dashed)
    if i_s_0
        s.addLevel(0.0, "0",    col, width)
    if i_s_n1
        s.addLevel(1.0, "-1",   col, width)
    if i_s_n2
        s.addLevel(2.0, "-2.0", col, width)
    if i_s_n25
        s.addLevel(2.5, "-2.5", col, width)
    if i_s_n4
        s.addLevel(4.0, "-4.0", col, width)
    if i_s_n45
        s.addLevel(4.5, "-4.5", col, width)
    s.drawn := true

method isViolated(DevSetup s) =>
    s.dir == -1 ? close > s.sweep_price : close < s.sweep_price

// ═══════════════════════════ HELPERS ═══════════════════════════

f_capList(array<DevSetup> arr, int mx) =>
    while array.size(arr) > mx
        DevSetup old = array.shift(arr)
        old.clearAll()

f_updateLabels(array<DevSetup> arr) =>
    int t = time + timeframe.in_seconds() * 1000 * 3
    if array.size(arr) > 0
        for i = 0 to array.size(arr) - 1
            DevSetup s = array.get(arr, i)
            if array.size(s.lbs) > 0
                for j = 0 to array.size(s.lbs) - 1
                    label.set_x(array.get(s.lbs, j), t)

f_invalidate(array<DevSetup> arr) =>
    if array.size(arr) > 0
        int i = array.size(arr) - 1
        while i >= 0
            DevSetup s = array.get(arr, i)
            if s.isViolated()
                s.clearAll()
                array.remove(arr, i)
            i -= 1

// ═══════════════════════════ LTF DETECTION ═══════════════════════════

float ltf_ph = ta.pivothigh(i_ltf_piv, i_ltf_piv)
float ltf_pl = ta.pivotlow (i_ltf_piv, i_ltf_piv)

var float ltf_last_ph   = na
var float ltf_prev_ph   = na
var int   ltf_last_ph_t = na
var float ltf_last_pl   = na
var float ltf_prev_pl   = na
var int   ltf_last_pl_t = na

if not na(ltf_ph)
    ltf_prev_ph   := ltf_last_ph
    ltf_last_ph   := ltf_ph
    ltf_last_ph_t := time[i_ltf_piv]

if not na(ltf_pl)
    ltf_prev_pl   := ltf_last_pl
    ltf_last_pl   := ltf_pl
    ltf_last_pl_t := time[i_ltf_piv]

var DevSetup ltf_pend_bear = na
var DevSetup ltf_pend_bull = na
var array<DevSetup> ltf_active = array.new<DevSetup>()

bool ltf_new_sweep_high = i_ltf_on and not na(ltf_ph) and not na(ltf_prev_ph) and ltf_ph > ltf_prev_ph and not na(ltf_last_pl_t)
bool ltf_new_sweep_low  = i_ltf_on and not na(ltf_pl) and not na(ltf_prev_pl) and ltf_pl < ltf_prev_pl and not na(ltf_last_ph_t)

if ltf_new_sweep_high
    if not na(ltf_pend_bear)
        ltf_pend_bear.clearAll()
    int sweep_t = time[i_ltf_piv]
    if ltf_last_pl_t < sweep_t
        DevSetup s = DevSetup.new(
             anchor_time  = ltf_last_pl_t,
             sweep_time   = sweep_t,
             anchor_price = ltf_last_pl,
             sweep_price  = ltf_ph,
             dir          = -1,
             mss_level    = ltf_last_pl,
             confirmed    = false,
             drawn        = false,
             is_htf       = false,
             lns          = array.new<line>(),
             lbs          = array.new<label>(),
             leg          = na)
        if not i_require_mss
            s.drawAll(i_ltf_col, i_ltf_wid)
            s.confirmed := true
            array.push(ltf_active, s)
            f_capList(ltf_active, i_max)
            ltf_pend_bear := na
        else
            ltf_pend_bear := s

if ltf_new_sweep_low
    if not na(ltf_pend_bull)
        ltf_pend_bull.clearAll()
    int sweep_t = time[i_ltf_piv]
    if ltf_last_ph_t < sweep_t
        DevSetup s = DevSetup.new(
             anchor_time  = ltf_last_ph_t,
             sweep_time   = sweep_t,
             anchor_price = ltf_last_ph,
             sweep_price  = ltf_pl,
             dir          = +1,
             mss_level    = ltf_last_ph,
             confirmed    = false,
             drawn        = false,
             is_htf       = false,
             lns          = array.new<line>(),
             lbs          = array.new<label>(),
             leg          = na)
        if not i_require_mss
            s.drawAll(i_ltf_col, i_ltf_wid)
            s.confirmed := true
            array.push(ltf_active, s)
            f_capList(ltf_active, i_max)
            ltf_pend_bull := na
        else
            ltf_pend_bull := s

bool ltf_bear_mss_fired = false
bool ltf_bull_mss_fired = false

if not na(ltf_pend_bear) and close < ltf_pend_bear.mss_level
    ltf_pend_bear.drawAll(i_ltf_col, i_ltf_wid)
    ltf_pend_bear.confirmed := true
    array.push(ltf_active, ltf_pend_bear)
    f_capList(ltf_active, i_max)
    ltf_pend_bear := na
    ltf_bear_mss_fired := true

if not na(ltf_pend_bull) and close > ltf_pend_bull.mss_level
    ltf_pend_bull.drawAll(i_ltf_col, i_ltf_wid)
    ltf_pend_bull.confirmed := true
    array.push(ltf_active, ltf_pend_bull)
    f_capList(ltf_active, i_max)
    ltf_pend_bull := na
    ltf_bull_mss_fired := true

if i_invalidate
    f_invalidate(ltf_active)

// ═══════════════════════════ HTF DETECTION ═══════════════════════════

f_htfPiv() =>
    ph   = ta.pivothigh(i_htf_piv, i_htf_piv)
    pl   = ta.pivotlow (i_htf_piv, i_htf_piv)
    ph_t = not na(ph) ? time[i_htf_piv] : na
    pl_t = not na(pl) ? time[i_htf_piv] : na
    [ph, pl, ph_t, pl_t]

[htf_ph, htf_pl, htf_ph_t, htf_pl_t] = request.security(syminfo.tickerid, i_htf_tf, f_htfPiv(), lookahead=barmerge.lookahead_off)

var int   htf_seen_ph_t = 0
var int   htf_seen_pl_t = 0
var float htf_last_ph   = na
var float htf_prev_ph   = na
var int   htf_last_ph_t = na
var float htf_last_pl   = na
var float htf_prev_pl   = na
var int   htf_last_pl_t = na

bool new_htf_ph = i_htf_on and not na(htf_ph_t) and htf_ph_t != htf_seen_ph_t
bool new_htf_pl = i_htf_on and not na(htf_pl_t) and htf_pl_t != htf_seen_pl_t

if new_htf_ph
    htf_seen_ph_t := htf_ph_t
    htf_prev_ph   := htf_last_ph
    htf_last_ph   := htf_ph
    htf_last_ph_t := htf_ph_t

if new_htf_pl
    htf_seen_pl_t := htf_pl_t
    htf_prev_pl   := htf_last_pl
    htf_last_pl   := htf_pl
    htf_last_pl_t := htf_pl_t

var DevSetup htf_pend_bear = na
var DevSetup htf_pend_bull = na
var array<DevSetup> htf_active = array.new<DevSetup>()

bool htf_new_sweep_high = new_htf_ph and not na(htf_prev_ph) and htf_ph > htf_prev_ph and not na(htf_last_pl_t)
bool htf_new_sweep_low  = new_htf_pl and not na(htf_prev_pl) and htf_pl < htf_prev_pl and not na(htf_last_ph_t)

if htf_new_sweep_high
    if not na(htf_pend_bear)
        htf_pend_bear.clearAll()
    if htf_last_pl_t < htf_ph_t
        DevSetup s = DevSetup.new(
             anchor_time  = htf_last_pl_t,
             sweep_time   = htf_ph_t,
             anchor_price = htf_last_pl,
             sweep_price  = htf_ph,
             dir          = -1,
             mss_level    = htf_last_pl,
             confirmed    = false,
             drawn        = false,
             is_htf       = true,
             lns          = array.new<line>(),
             lbs          = array.new<label>(),
             leg          = na)
        if not i_require_mss
            s.drawAll(i_htf_col, i_htf_wid)
            s.confirmed := true
            array.push(htf_active, s)
            f_capList(htf_active, i_max)
            htf_pend_bear := na
        else
            htf_pend_bear := s

if htf_new_sweep_low
    if not na(htf_pend_bull)
        htf_pend_bull.clearAll()
    if htf_last_ph_t < htf_pl_t
        DevSetup s = DevSetup.new(
             anchor_time  = htf_last_ph_t,
             sweep_time   = htf_pl_t,
             anchor_price = htf_last_ph,
             sweep_price  = htf_pl,
             dir          = +1,
             mss_level    = htf_last_ph,
             confirmed    = false,
             drawn        = false,
             is_htf       = true,
             lns          = array.new<line>(),
             lbs          = array.new<label>(),
             leg          = na)
        if not i_require_mss
            s.drawAll(i_htf_col, i_htf_wid)
            s.confirmed := true
            array.push(htf_active, s)
            f_capList(htf_active, i_max)
            htf_pend_bull := na
        else
            htf_pend_bull := s

bool htf_bear_mss_fired = false
bool htf_bull_mss_fired = false

if not na(htf_pend_bear) and close < htf_pend_bear.mss_level
    htf_pend_bear.drawAll(i_htf_col, i_htf_wid)
    htf_pend_bear.confirmed := true
    array.push(htf_active, htf_pend_bear)
    f_capList(htf_active, i_max)
    htf_pend_bear := na
    htf_bear_mss_fired := true

if not na(htf_pend_bull) and close > htf_pend_bull.mss_level
    htf_pend_bull.drawAll(i_htf_col, i_htf_wid)
    htf_pend_bull.confirmed := true
    array.push(htf_active, htf_pend_bull)
    f_capList(htf_active, i_max)
    htf_pend_bull := na
    htf_bull_mss_fired := true

if i_invalidate
    f_invalidate(htf_active)

// ═══════════════════════════ LABEL POSITION UPDATE ═══════════════════════════

f_updateLabels(ltf_active)
f_updateLabels(htf_active)

// ═══════════════════════════ ALERTS ═══════════════════════════

alertcondition(ltf_bear_mss_fired, "LTF Bearish Distribution Confirmed",  "LTF sweep of high + MSS. Dev levels drawn.")
alertcondition(ltf_bull_mss_fired, "LTF Bullish Distribution Confirmed",  "LTF sweep of low + MSS. Dev levels drawn.")
alertcondition(htf_bear_mss_fired, "HTF Bearish Distribution Confirmed",  "HTF sweep of high + MSS. Dev levels drawn.")
alertcondition(htf_bull_mss_fired, "HTF Bullish Distribution Confirmed",  "HTF sweep of low + MSS. Dev levels drawn.")
````
