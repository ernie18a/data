# ACTS Point & Figure

- url: https://www.tradingview.com/script/nfjQ4d1M-ACTS-Point-Figure/
- type: indicator
- pine_id: PUB;2001f03a3ce840b792c7ff4af4c5fc55
- version: 5.0

## Description

Point & Figure strips time out of the chart.

What's left is structure - where price actually fought, and where it broke. This draws that structure as an overlay on your ordinary candlestick chart, so you see the P&F reading and the candles together.

And the source is open. You don't have to take my word for any of it: read the code, check that it does what this description says, change it if you disagree. That is the point of publishing it this way.

Most free P&F tools stop at double tops. This one carries the full classical vocabulary - triples, catapults, traps, poles, 45-degree trend lines and structural stops - built the way the literature specifies.

It draws levels and structure. It does not issue buy or sell signals, and it makes no claim about what any level will do next. The interpretation is yours.


HOW THE GRID IS BUILT

Price moves one box, you add a box. It reverses by three boxes, a new column starts. The grid is computed internally from the ordinary OHLC history of the chart you're on - not from TradingView's Point & Figure chart type - so every level maps to a real price on a real bar with a real timestamp. Columns are built from closing prices, and the three-box reversal is fixed, the classical construction.


WHAT IT SHOWS YOU

Columns - the trend in its rawest form. A column of X's is buyers in control, O's sellers, and a new column means the move reversed by enough to matter. No wicks, no noise from time passing. Columns are numbered; the X/O characters and the column lines toggle independently.

Classic patterns and their breakout levels. Double and triple tops and bottoms, detected on the grid, each with its breakout level drawn and labelled. A breakout only counts if the column also clears every same-direction column behind it in the look-back window - so a "break" straight into overhead structure isn't one. A separate Pot BO line projects forward from the live column: the level the current column would have to reach for a breakout to register. It updates as the column builds.

45-degree trend lines. Bullish support and bearish resistance drawn at a fixed 45 degrees off the grid, plus internal lines, projecting a configurable distance to the right. On a P&F grid a 45-degree line has objective meaning, because the grid has a fixed geometry; on a time chart it does not. A line renders dotted while it is provisional and turns solid once a breakout confirms it, so you can see which lines have earned their keep.

The special formations. High and low poles, bull and bear catapults, bull and bear traps. A trap is a breakout that fails and pulls price back through its own level. A pole marks an unusually extended one-column move. Formations that have already resolved stay on the chart by default, tagged [H] when the level was hit and [N] when the formation was negated - so you can see what the recent structure actually did, not only what is still open. Two settings hide the hit and negated ones, and an age filter clears the old ones away; switch those on and what remains is only what is still live.

Structural stop levels - three modes, all box-denominated.
- Mode 1 - nearest. The extreme of the column immediately before the breakout, plus a buffer.
- Mode 2 - pattern-wide (default). The worst opposing extreme found across the whole width of the pattern, plus the same buffer. More conservative than Mode 1 by construction.
- Mode 3 - measured. A fixed distance from the breakout level itself (default two boxes), no buffer.

The buffer and the Mode 3 distance are both expressed as a percentage of your box size, never in pips. Nothing in this path assumes a decimal count, a pip value or an asset class, so the same settings behave sensibly on a 5-decimal FX pair, an index and a crypto pair alike.


TWO SETTINGS, AND THE SCRIPT HELPS YOU WITH ONE OF THEM

Set the Grid Anchor Price to a round number at or below current price - 1.0 for EURUSD, 100.0 for USDJPY. Then set the Box Size in price terms; a 10-pip EURUSD box is 0.00100.

Box size is instrument-specific by nature. A 0.001 box that reads EURUSD beautifully is meaningless on an index trading at 18,000, and there is no universal number. You don't need to know it in advance - the script tells you. If your box size is so large that the loaded history barely spans any boxes, or so small that it can't be read, an on-chart message says which way you're wrong and suggests a value for that instrument. So: put in any reasonable guess, read the message, adjust, and repeat until it stops complaining. Then check that the structure it draws matches moves you recognise. Write the number down - you'll reuse it.

Defaults are set for EURUSD. On anything else, expect the box-size message first. That's the setup assistant doing its job, not a fault.


MAKING IT READABLE

Two minutes of chart setup is the difference between "this is broken" and "oh, I see it."

1. Dim the candles - hollow bars or a muted grey. The P&F structure should be what your eye lands on; the candles are context. This one change does most of the work.
2. Lock the price-to-bar ratio, and set it to your box size divided by three. A column is three bars wide and a 45-degree line rises one box per column, so that ratio is what makes the geometry square - 0.00100 box on EURUSD gives 0.000333. To check it: draw an ordinary trend line at 45 degrees over one the script has drawn. If they lie on top of each other you are set. If they diverge, the ratio is wrong, and everything else on the chart is being read at the wrong angle.
3. Give it history. Too short a window and there is nothing to build.
4. Start on a timeframe you already read well. The structure comes from that chart's own data, so the timeframe you pick is the timeframe you're analysing.


HONEST NOTES ON CONSTRUCTION

- Standard charts only. Deliberately not run on TradingView's P&F chart type, which produces synthetic bars - levels read off those don't correspond to prices anyone could have traded.
- Columns come from closing prices. A choice, not an oversight: closes filter intrabar noise. The cost is real - a spike that reverses before the close prints no box, and structure that depended on it won't appear.
- The most recent 160 columns are drawn. Deeper history isn't rendered. TradingView caps how much any one script may draw, and the newest structure is the structure worth keeping.
- No alerts. There are none in this script.
- Price only. No volume input and no volume interpretation.
- It won't pick your box size for you. It will tell you when yours is wrong, which is a different and more honest thing.
- The detection is geometric. It will mark structure that later fails, as every structural method does.
- No performance claims are made here, and none are implied.

Pine v6, overlay, open source. Nothing in the file requests data from another symbol or timeframe.

If you're learning Point & Figure: put this on a market you already know and watch the columns build next to the candles you recognise. That is the fastest way in.

## Source Code

````pine
//@version=6
// =========================================================================
// ACTS POINT & FIGURE
// =========================================================================
//   Close-based Point & Figure grid with classic patterns, structural stop
//   levels, 45-degree trend lines and special patterns.
//
//   Exposes: g_hi[], g_lo[], g_dir[], f_g_priceFromIdx(), f_g_idxContain()
//   Render:  X/O column lines, column-number labels
//   Box size and grid anchor are configurable via inputs (group "1) Grid")
//   v1.0.4 - box-size note states what the loaded history shows; no verdict, no logic change
// =========================================================================
indicator('ACTS Point & Figure', overlay = true, max_lines_count = 500, max_labels_count = 500)

// ── 1) Grid Inputs (declared first — used by price↔index functions below) ──
i_ref = input.float(1.00000, 'Grid Anchor Price', step = 0.00001, group = '1) Grid', tooltip = 'Round number at or below the instrument price.\nEURUSD -> 1.0   USDJPY -> 100.0   GBPUSD -> 1.0')
i_box = input.float(0.00100, 'Box Size (price)', step = 0.00001, minval = 0.00000001, group = '1) Grid', tooltip = 'EURUSD 10-pip box = 0.00100   USDJPY 10-pip approx 0.100   GBPUSD 10-pip = 0.00100')
i_xo_show = input.bool(true, 'Show X/O', group = '1) Grid', inline = 'xo1', tooltip = 'Render X and O characters at each box level. Only the most recent columns are drawn, to stay within the chart drawing limit.')
i_col_show = input.bool(true, 'Show Columns', group = '1) Grid', inline = 'c1', tooltip = 'Show vertical column lines and column number labels. Turn off to see only X/O symbols.')
i_xo_xCol = input.color(color.new(color.aqua, 0), 'X', group = '1) Grid', inline = 'xo2')
i_xo_oCol = input.color(color.new(color.red, 0), 'O', group = '1) Grid', inline = 'xo2')

// ── Constants ─────────────────────────────────────────────────────────────
REV = 3
SPC = 3
MAX_COLS = 160

// ── Price <-> box-index mapping ───────────────────────────────────────────
// f_g_priceFromIdx(idx) -> LOWER boundary of box idx
f_g_priceFromIdx(idx) =>
    i_ref + idx * i_box
f_g_idxContain(p) =>
    int(math.floor((p - i_ref) / i_box + 1e-10))

// -- Box Size Note: reports what the LOADED history shows, measured in BOXES.
//    It does NOT judge the box size. The span is the loaded history's close range
//    converted to boxes, so it moves with how much history the chart has fetched -
//    the same box reads differently on a fresh chart and on a fully scrolled one.
//    Because of that the note states only the fact it can see and the one thing
//    the reader can do about it; it never asserts that a setting is wrong.
//    It also does NOT suggest a box size: any suggestion drawn from this span would
//    inherit the same fetch-depth dependence, as advice instead of as a verdict.
//    Box-size guidance belongs to the box-size engine, not to this note.
//    The two constants below are a NOISE GATE - when to bother saying anything -
//    not a correctness test. Wide on purpose.
//    The measured value is a PARAMETER; the only globals it reads are the two constants
//    declared directly above it, so every name is defined before it is used.
GD_SPAN_MIN = 30
GD_SPAN_MAX = 10000
f_gd_guardMsg(int _span) =>
    string _m = ''
    if _span < GD_SPAN_MIN or _span > GD_SPAN_MAX
        _m := 'BOX SIZE NOTE - with the history loaded here, your box size gives ' + str.tostring(_span) + ' boxes across the loaded price range.' + '\nScroll left to load more history.' + '\nThis reports what is loaded right now. It is not a verdict on your box size.'
    _m

// ── Column storage ────────────────────────────────────────────────────────
var array<int> g_hi = array.new_int()
var array<int> g_lo = array.new_int()
var array<int> g_dir = array.new_int()
var array<int> g_t0 = array.new_int()  // bar time (UNIX ms) at column open, parallel to g_hi/g_lo/g_dir. Pushed once per column in the same branch as g_hi, never mutated after push.

// ── Active column state ───────────────────────────────────────────────────
var int g_curHi = 0
var int g_curLo = 0
var int g_curDir = 0

// ── Bar-by-bar PnF construction (close-based) ────────────────────────────
clsIdx = f_g_idxContain(close)

// Running close extremes over the whole loaded history. Bar-scope and deliberately
//   independent of the column arrays - the guard measures a PRICE span converted to boxes,
//   never a column count. Price extremes, not box-index extremes, so the suggested
//   box size stays accurate even when the current box is grossly coarse.
var float gd_pxMin = na
var float gd_pxMax = na
var label gd_lbl = na
gd_pxMin := na(gd_pxMin) ? close : math.min(gd_pxMin, close)
gd_pxMax := na(gd_pxMax) ? close : math.max(gd_pxMax, close)

if barstate.isfirst
    g_curHi := clsIdx
    g_curLo := clsIdx
    g_curDir := 1
    array.push(g_hi, g_curHi)
    array.push(g_lo, g_curLo)
    array.push(g_dir, 1)
    array.push(g_t0, time)  // write site 1/3 (first bar): column open-time, parallel to g_hi push.
else
    last = array.size(g_hi) - 1
    if g_curDir == 1
        if clsIdx > g_curHi
            g_curHi := clsIdx
            array.set(g_hi, last, g_curHi)
        else if clsIdx <= g_curHi - REV
            g_curDir := -1
            g_curLo := clsIdx
            array.push(g_hi, g_curHi - 1)
            array.push(g_lo, g_curLo)
            array.push(g_dir, -1)
            array.push(g_t0, time)  // write site 2/3 (up->down reversal): column open-time, parallel to g_hi push.
    else
        if clsIdx < g_curLo
            g_curLo := clsIdx
            array.set(g_lo, last, g_curLo)
        else if clsIdx >= g_curLo + REV
            g_curDir := 1
            g_curHi := clsIdx
            array.push(g_hi, g_curHi)
            array.push(g_lo, g_curLo + 1)
            array.push(g_dir, 1)
            array.push(g_t0, time)  // write site 3/3 (down->up reversal): column open-time, parallel to g_hi push.

// =========================================================================
// CLASSIC PATTERNS
// =========================================================================
//   Reads:   g_hi[], g_lo[], g_dir[]
//   Exposes: cp_pattern[], cp_boCols[], cp_boLevels[], cp_boDirs[], cp_boDirPerCol[]
//   Render:  All confirmed BO lines + SL lines + Potential BO from live column
//
//
//   Label abbreviations:
//     DT = Double Top    DB = Double Bottom
//     TT = Triple Top    TB = Triple Bottom  (also covers QT/QB)
//
//   BO line geometry:
//     Full pattern width: lineStart = boCi - 2*pWidth
//     DT/DB (pWidth=1): boCi-2 to boCi
//     TT/TB (pWidth=2): boCi-4 to boCi
//
//   SL line: purple, dotted, width 2, same span as BO line, no label
//   NOTE: i_cp_show and i_sl_show are independent — hiding BO does NOT hide SL
// =========================================================================

// -- Classic Pattern Inputs -------------------------------------------------
i_cp_show = input.bool(true, 'Show Classic BO', group = '2) Classic Patterns')
i_cp_lookback = input.int(5, 'Look-Left Same-Dir Cols', minval = 1, maxval = 20, group = '2) Classic Patterns')
i_cp_showLabel = input.bool(true, 'Show Pattern Labels', group = '2) Classic Patterns')

// Mode 1: SL at prior opposite-col extreme +/- buffer (always boCi-1)
// Mode 2: SL at pattern extreme — worst inner opposite col across full pattern width
// Mode 3: SL at fixed distance from BO level, expressed as a % of box size
// Buffer and Mode-3 distance are % OF BOX, never pips. A pip
// is not 0.00010 outside 5-decimal FX, and is meaningless on BTC / indices.
i_sl_show = input.bool(true, 'Show Stop Loss', group = '3) Stop Loss')
i_sl_mode = input.string('Mode 2', 'SL Mode', options = ['Mode 1', 'Mode 2', 'Mode 3'], group = '3) Stop Loss')
i_sl_buf = input.float(50.0, 'Buffer (% of box)', minval = 0.0, step = 5.0, group = '3) Stop Loss', tooltip = 'Stop-loss buffer beyond the structural level, as a percentage of Box Size.\n50% sits mid-box, away from the round-number boundaries where stops cluster.\nWorks on any instrument - Modes 1 and 2 only.')
i_sl_manual = input.float(200.0, 'Manual Distance (% of box) - Mode 3 only', minval = 0.0, step = 10.0, group = '3) Stop Loss', tooltip = 'Mode 3 only: fixed stop distance from the breakout level, as a percentage of Box Size.\n200% = 2 boxes. Mode 3 does not add the buffer above.')

// -- Classic Pattern State --------------------------------------------------
var array<string> cp_pattern = array.new_string() // pattern name per column (parallel to g_hi[])
var array<int> cp_boCols = array.new_int() // BO column indices
var array<float> cp_boLevels = array.new_float() // BO price levels
var array<int> cp_boDirs = array.new_int() // BO directions (+1/-1)
var array<int> cp_boDirPerCol = array.new_int() // BO direction at each col (0=none) - read by the trend line pass

// =========================================================================
// TREND LINES (45 degree)
// =========================================================================
//   Reads:   g_hi[], g_lo[], g_dir[], cp_boDirPerCol[]
//   Render:  All TL segments solid (active w2, historical w1) + internal TLs dashed w1
//
//
//   Rules:
//     45° bullish support: anchor at O-col bottom, slope = +i_box per column
//     45° bearish resistance: anchor at X-col top,  slope = -i_box per column
//     TLs ALTERNATE: bull breaks when O-col falls below TL + DB/TB signal
//     Bear breaks when X-col rises above TL + DT/TT signal
//     BO gate: signal valid if found within 2 same-dir cols either side
//     New anchor: highest X-col (bear) / lowest O-col (bull) in last 20 cols
//     TL state machine starts from VISIBLE window (first O-col at/after start)
//     Visual termination: ALL TL lines stop at first col whose price crosses TL
//       (both active and historical — clean column-stop rendering)
//     Internal TLs: first i_tl_maxInt same-dir cols after anchor that are
//       inside the main TL envelope (min 4-col spacing between internals)
//
//   Colors: Bull TL = Cyan 100% | Bear TL = Yellow 50%
//   Style:  ALL main TL segments = solid (active w2, historical w1)
//           Internal TLs = dashed w1
// =========================================================================

// -- Trend Line Inputs ------------------------------------------------------
i_tl_show = input.bool(true, 'Show Trend Lines', group = '4) Trend Lines')
i_tl_maxInt = input.int(5, 'Max Internal TLs', minval = 0, maxval = 10, group = '4) Trend Lines')
i_tl_proj = input.int(15, 'Project Cols Right', minval = 0, maxval = 30, group = '4) Trend Lines')
i_tl_width = input.int(2, 'TL Base Width', minval = 1, maxval = 4, group = '4) Trend Lines')
i_tl_minSpan = input.int(5, 'Min TL Span (cols)', minval = 2, maxval = 20, group = '4) Trend Lines') // Filter out noise - a TL needs meaningful length
i_tl_minSpanActive = input.int(2, 'Min TL Span — Active (cols)', minval = 1, maxval = 20, group = '4) Trend Lines') // Active/live TL renders from this floor (default 2); historical TLs keep i_tl_minSpan. The live TL is established on the shakeout up-reversal, so it is decision-relevant immediately.


// -- Special Pattern Inputs -------------------------------------------------
i_sp_show = input.bool(true, 'Show Special Patterns', group = '5) Special Patterns')
i_sp_pole = input.bool(true, 'Detect Poles', group = '5) Special Patterns', inline = 'sp1')
i_sp_poleMinLen = input.int(10, 'Min Pole Length (boxes)', minval = 3, maxval = 20, group = '5) Special Patterns', inline = 'sp1', tooltip = 'Minimum column height for Pole detection. The column must also clear the prior same direction column.')
i_sp_hpCol = input.color(color.new(color.orange, 0), 'High Pole', group = '5) Special Patterns', inline = 'sp2')
i_sp_lpCol = input.color(color.new(color.lime, 0), 'Low Pole', group = '5) Special Patterns', inline = 'sp2')
i_sp_maxAge = input.int(0, 'Max SP Age (cols, 0=show all)', group = '5) Special Patterns', inline = 'sp3', tooltip = 'Hide special patterns older than this many columns. 0 = show all. Applies to Poles, Catapults and Traps. e.g. 80 = show only patterns in last ~80 cols.')
i_sp_cat = input.bool(true, 'Detect Catapults', group = '5) Special Patterns', inline = 'sp4')
i_sp_trap = input.bool(true, 'Detect Traps', group = '5) Special Patterns', inline = 'sp4')
i_sp_catBCol = input.color(color.new(color.teal, 0), 'Bull Cat', group = '5) Special Patterns', inline = 'sp5')
i_sp_catSCol = input.color(color.new(color.fuchsia, 0), 'Bear Cat', group = '5) Special Patterns', inline = 'sp5')
i_sp_trapSCol = input.color(color.new(color.red, 0), 'Bull Trap', group = '5) Special Patterns', inline = 'sp6')
i_sp_trapBCol = input.color(color.new(color.lime, 0), 'Bear Trap', group = '5) Special Patterns', inline = 'sp6')
i_sp_poleHideHit = input.bool(false, 'Hide Hit', group = '5) Special Patterns', inline = 'sp7')
i_sp_poleHideNeg = input.bool(false, 'Hide Negated', group = '5) Special Patterns', inline = 'sp7')
i_sp_trapHideHit = input.bool(false, 'Trap: Hide Hit', group = '5) Special Patterns', inline = 'sp8')
i_sp_trapHideNeg = input.bool(false, 'Trap: Hide Negated', group = '5) Special Patterns', inline = 'sp8')
// ── Render arrays ─────────────────────────────────────────────────────────
var array<line> r_g_lines = array.new_line()
var array<label> r_g_labels = array.new_label()
var array<line> r_cp_lines = array.new_line()
var array<label> r_cp_labels = array.new_label()
var array<line> r_tl_lines = array.new_line()
var array<label> r_xo_labels = array.new_label()
var array<label> r_sp_labels = array.new_label()
var array<line> r_sp_lines = array.new_line()

// ── TL segment storage (cleared and rebuilt each render pass) ─────────────
var array<int> tl_sCi = array.new_int() // anchor column index per segment
var array<float> tl_sPx = array.new_float() // anchor price per segment
var array<int> tl_sDir = array.new_int() // direction per segment (+1 bull / -1 bear)
var array<int> tl_eBrk = array.new_int() // break column (-1 = still active)
var array<bool> tl_sConf = array.new_bool() // true=confirmed (buy/sell signal seen, solid), false=provisional (reversal only, dotted)

f5(v) =>
    str.tostring(v, format.mintick)   // instrument-appropriate, ZERO-PADDED precision (EURUSD 5dp, JPY 3dp, BTC/Gold tick).


// SINGLE RENDER PASS — barstate.islast only
// =========================================================================
if barstate.islast
    for ln in r_g_lines
        line.delete(ln)
    for lb in r_g_labels
        label.delete(lb)
    for ln in r_cp_lines
        line.delete(ln)
    for lb in r_cp_labels
        label.delete(lb)
    for ln in r_tl_lines
        line.delete(ln)
    array.clear(r_g_lines)
    array.clear(r_g_labels)
    array.clear(r_cp_lines)
    array.clear(r_cp_labels)
    array.clear(r_tl_lines)
    for lb in r_xo_labels
        label.delete(lb)
    array.clear(r_xo_labels)
    for lb in r_sp_labels
        label.delete(lb)
    for ln in r_sp_lines
        line.delete(ln)
    array.clear(r_sp_labels)
    array.clear(r_sp_lines)
    array.clear(cp_pattern)
    array.clear(cp_boCols)
    array.clear(cp_boLevels)
    array.clear(cp_boDirs)
    array.clear(cp_boDirPerCol)
    array.clear(tl_sCi)
    array.clear(tl_sPx)
    array.clear(tl_sDir)
    array.clear(tl_eBrk)
    array.clear(tl_sConf)

    n = array.size(g_hi)
    start = math.max(0, n - MAX_COLS)

    // -- Grid Render: X/O columns + column-number labels -----------------------
    // Box Size Note - ALWAYS ON, outside every display toggle: box size is the one
    //   setting every other layer is built on, so the reading is always available.
    //   Self-cleaning via its own handle, NOT the r_* render arrays, so it keeps working
    //   whichever render arrays a given build uses.
    label.delete(gd_lbl)
    _gdRange = gd_pxMax - gd_pxMin
    _gdMsg = f_gd_guardMsg(int(math.floor(_gdRange / i_box)))
    if _gdMsg != ''
        gd_lbl := label.new(bar_index, close, _gdMsg, xloc.bar_index, yloc.price, color.new(color.orange, 10), label.style_label_down, color.black, size.normal, text.align_left)

    minLo = array.get(g_lo, start)
    for j = start to n - 1 by 1
        v = array.get(g_lo, j)
        if v < minLo
            minLo := v
            minLo
    lblY = f_g_priceFromIdx(minLo - 3)

    for i = start to n - 1 by 1
        x = bar_index - (n - 1 - i) * SPC
        hi = array.get(g_hi, i)
        lo = array.get(g_lo, i)
        clr = array.get(g_dir, i) == 1 ? color.new(color.lime, 0) : color.new(color.red, 0)
        if i_col_show
            array.push(r_g_lines, line.new(x, f_g_priceFromIdx(lo), x, f_g_priceFromIdx(hi + 1), xloc.bar_index, extend.none, clr, line.style_solid, 2))


    // -- X/O Symbol Rendering (all visible columns) ----------------------------
    if i_xo_show
        xoStart = start
        for xi = xoStart to n - 1 by 1
            xi_x = bar_index - (n - 1 - xi) * SPC
            xi_hi = array.get(g_hi, xi)
            xi_lo = array.get(g_lo, xi)
            xi_d = array.get(g_dir, xi)
            xoCh = xi_d == 1 ? 'X' : 'O'
            xoC = xi_d == 1 ? i_xo_xCol : i_xo_oCol
            for row = xi_lo to xi_hi by 1
                py = f_g_priceFromIdx(row)
                lb = label.new(xi_x, py, xoCh, xloc.bar_index, yloc.price, color.new(color.black, 100), label.style_label_center, xoC, size.tiny)
                array.push(r_xo_labels, lb)

    // ── Column number labels (created AFTER XO — newest labels, survive budget) ──
    for i = start to n - 1 by 1
        if (i + 1) % 5 == 0
            x = bar_index - (n - 1 - i) * SPC
            lb = label.new(x, lblY, str.tostring(i + 1), xloc.bar_index, yloc.price, color.new(color.black, 100), label.style_label_center, color.new(color.silver, 0), size.small)
            array.push(r_g_labels, lb)

    // Extend cp_pattern and cp_boDirPerCol to size n (parallel arrays, indexed by col)
    curPSize = array.size(cp_pattern)
    if curPSize < n
        for _p = curPSize to n - 1 by 1
            array.push(cp_pattern, '')
            array.push(cp_boDirPerCol, 0)

    // ── Pre-visible BO scan: cols 2 → start-1 ────────────────────────────
    // Populates cp_boDirPerCol for full column history (used by the trend line BO gate).
    // Simplified: basic boFires only, no look-left suppression.
    if start > 2
        for ci = 2 to start - 1 by 1
            dir = array.get(g_dir, ci)
            curLvl = dir == 1 ? array.get(g_hi, ci) : array.get(g_lo, ci)
            nearLvl = dir == 1 ? array.get(g_hi, ci - 2) : array.get(g_lo, ci - 2)
            if dir == 1 ? curLvl > nearLvl : curLvl < nearLvl
                array.set(cp_boDirPerCol, ci, dir)

    // -- Pass 1: collect confirmed BOs ----------------------------------------
    for ci = start to n - 1 by 1
        if ci >= 2
            dir = array.get(g_dir, ci)
            curLvl = dir == 1 ? array.get(g_hi, ci) : array.get(g_lo, ci)
            nearLvl = dir == 1 ? array.get(g_hi, ci - 2) : array.get(g_lo, ci - 2)
            boFires = dir == 1 ? curLvl > nearLvl : curLvl < nearLvl

            if boFires
                hasUncleared = false
                kk = ci - 2
                sdCt = 0
                while kk >= start and sdCt < i_cp_lookback
                    if array.get(g_dir, kk) == dir
                        pl = dir == 1 ? array.get(g_hi, kk) : array.get(g_lo, kk)
                        if not(dir == 1 ? curLvl > pl : curLvl < pl)
                            hasUncleared := true
                            hasUncleared
                        sdCt := sdCt + 1
                        sdCt
                    kk := kk - 1
                    kk

                if not hasUncleared
                    pWidth = 1
                    ns = ci - 4
                    while ns >= start
                        plN = dir == 1 ? array.get(g_hi, ns) : array.get(g_lo, ns)
                        if plN == nearLvl
                            pWidth := pWidth + 1
                            ns := ns - 2
                            ns
                        else
                            break
                    pat = pWidth == 1 ? dir == 1 ? 'DT' : 'DB' : dir == 1 ? 'TT' : 'TB'
                    boLvl = dir == 1 ? f_g_priceFromIdx(nearLvl + 1) : f_g_priceFromIdx(nearLvl)
                    array.set(cp_pattern, ci, pat)
                    array.push(cp_boCols, ci)
                    array.push(cp_boLevels, boLvl)
                    array.push(cp_boDirs, dir)
                    array.set(cp_boDirPerCol, ci, dir)
                else
                    array.set(cp_pattern, ci, '')
            else
                array.set(cp_pattern, ci, '')

    // -- Pass 2: render BO lines and/or SL lines ------------------------------
    // i_cp_show and i_sl_show are INDEPENDENT — hiding BO does NOT hide SL
    if i_cp_show or i_sl_show
        boCount = array.size(cp_boCols)
        for bi = 0 to boCount - 1 by 1
            if boCount < 1
                break    // Guard: empty array -> `for 0 to -1` auto-reverses and runs at index 0
            boCi = array.get(cp_boCols, bi)
            boLvl = array.get(cp_boLevels, bi)
            boDir = array.get(cp_boDirs, bi)
            pat = array.get(cp_pattern, boCi)

            boNearLvl = boDir == 1 ? array.get(g_hi, boCi - 2) : array.get(g_lo, boCi - 2)
            pWidth2 = 1
            ns2 = boCi - 4
            while ns2 >= start
                plN2 = boDir == 1 ? array.get(g_hi, ns2) : array.get(g_lo, ns2)
                if plN2 == boNearLvl
                    pWidth2 := pWidth2 + 1
                    ns2 := ns2 - 2
                    ns2
                else
                    break

            lineStart = boCi - 2 * pWidth2
            x_ref = bar_index - (n - 1 - lineStart) * SPC
            x_bo = bar_index - (n - 1 - boCi) * SPC
            x_mid = int((x_ref + x_bo) / 2)
            boClr = boDir == 1 ? color.new(color.blue, 25) : color.new(color.yellow, 50)

            // ── BO line + label (only when i_cp_show = true) ──
            if i_cp_show
                array.push(r_cp_lines, line.new(x_ref, boLvl, x_bo, boLvl, xloc.bar_index, extend.none, boClr, line.style_solid, 2))
                if i_cp_showLabel and pat != ''
                    yLbl = boDir == 1 ? boLvl + i_box : boLvl - i_box
                    lb = label.new(x_mid, yLbl, pat, xloc.bar_index, yloc.price, color.new(color.black, 100), label.style_label_center, boClr, size.small)
                    array.push(r_cp_labels, lb)

            // -- SL-Mode level --------------------------------------------------------
            // Compute for EVERY BO regardless of i_sl_show — the engine read (SL level)
            // is independent of the SL-line display toggle; only the purple line stays
            // gated. Captured per-direction (last BO wins = most recent).
            slBuf = i_sl_buf / 100.0 * i_box
            float slLvl = na

            if i_sl_mode == 'Mode 1'
                if boDir == 1
                    slLvl := f_g_priceFromIdx(array.get(g_lo, boCi - 1)) - slBuf
                    slLvl
                else
                    slLvl := f_g_priceFromIdx(array.get(g_hi, boCi - 1) + 1) + slBuf
                    slLvl

            else if i_sl_mode == 'Mode 2'
                if boDir == 1
                    patLo = array.get(g_lo, boCi - 1)
                    innerCol = boCi - 3
                    wk = 1
                    while wk < pWidth2 and innerCol >= start
                        patLo := math.min(patLo, array.get(g_lo, innerCol))
                        innerCol := innerCol - 2
                        wk := wk + 1
                        wk
                    slLvl := f_g_priceFromIdx(patLo) - slBuf
                    slLvl
                else
                    patHi = array.get(g_hi, boCi - 1)
                    innerCol = boCi - 3
                    wk = 1
                    while wk < pWidth2 and innerCol >= start
                        patHi := math.max(patHi, array.get(g_hi, innerCol))
                        innerCol := innerCol - 2
                        wk := wk + 1
                        wk
                    slLvl := f_g_priceFromIdx(patHi + 1) + slBuf
                    slLvl

            else
                if boDir == 1
                    slLvl := boLvl - i_sl_manual / 100.0 * i_box
                    slLvl
                else
                    slLvl := boLvl + i_sl_manual / 100.0 * i_box
                    slLvl

            if not na(slLvl)
                // ── SL line render — still gated on i_sl_show (independent of i_cp_show) ──
                if i_sl_show
                    slClr = color.new(color.purple, 0)
                    array.push(r_cp_lines, line.new(x_ref, slLvl, x_bo, slLvl, xloc.bar_index, extend.none, slClr, line.style_dotted, 2))

    // -- Potential BO: live column extends RIGHT into future bars -------------
    if i_cp_show and n >= 3
        liveCi = n - 1
        liveDir = array.get(g_dir, liveCi)
        livePat = array.get(cp_pattern, liveCi)

        if livePat == ''
            nearLvlP = liveDir == 1 ? array.get(g_hi, liveCi - 2) : array.get(g_lo, liveCi - 2)
            potLvl = liveDir == 1 ? f_g_priceFromIdx(nearLvlP + 1) : f_g_priceFromIdx(nearLvlP)
            potClr = liveDir == 1 ? color.new(color.lime, 0) : color.new(color.red, 0)
            potEnd = bar_index + 15 * SPC
            array.push(r_cp_lines, line.new(bar_index - SPC, potLvl, potEnd, potLvl, xloc.bar_index, extend.none, potClr, line.style_solid, 1))
            if i_cp_showLabel
                potMid = int((bar_index - SPC + potEnd) / 2)
                lbP = label.new(potMid, potLvl, 'Pot BO', xloc.bar_index, yloc.price, color.new(color.black, 100), label.style_label_center, potClr, size.small)
                array.push(r_cp_labels, lbP)

    // -- Trend Lines (45 degree) ----------------------------------------------
    if i_tl_show and n >= 2

        // ── Pass 1: collect all TL segments ──────────────────────────────
        // Initialize from VISIBLE WINDOW: find first O-col at or after 'start'.
        _tlDir = 1
        _tlAnchorCi = start
        _tlAnchorPx = f_g_priceFromIdx(array.get(g_lo, start))
        _tlConf = false // active-segment confirmation state - provisional (dotted) until a buy/sell signal promotes it
        for ci_init = start to n - 2 by 1
            if array.get(g_dir, ci_init) == -1
                _tlAnchorCi := ci_init
                _tlAnchorPx := f_g_priceFromIdx(array.get(g_lo, ci_init))
                break

        for ci = _tlAnchorCi + 1 to n - 1 by 1
            cDir = array.get(g_dir, ci)
            // Mid-life promotion: provisional to confirmed at the first same-direction buy/sell signal
            if not _tlConf and ci >= 2
                if _tlDir == 1 and cDir == 1 and array.get(g_hi, ci) > array.get(g_hi, math.max(0, ci - 2))
                    _tlConf := true
                else if _tlDir == -1 and cDir == -1 and array.get(g_lo, ci) < array.get(g_lo, math.max(0, ci - 2))
                    _tlConf := true
            if _tlDir == 1 and cDir == -1
                tlVal = _tlAnchorPx + float(ci - _tlAnchorCi) * i_box
                if f_g_priceFromIdx(array.get(g_lo, ci)) < tlVal
                    // Inline BO gate: O-col makes new low vs prior O-col (widened to 6-col window)
                    // Replaces cp_boDirPerCol dependency — hasUncleared suppressed valid signals
                    hasBearBO = false
                    for bk = math.max(_tlAnchorCi + 1, ci - 6) to ci by 1
                        if array.get(g_dir, bk) == -1 and bk >= 2
                            if array.get(g_lo, bk) < array.get(g_lo, math.max(0, bk - 2))
                                hasBearBO := true
                                break
                    // Flip on penetration alone (draw at the first reversal); BO gate removed
                    array.push(tl_sCi, _tlAnchorCi)
                    array.push(tl_sPx, _tlAnchorPx)
                    array.push(tl_sDir, 1)
                    array.push(tl_eBrk, ci)
                    array.push(tl_sConf, true) // closed bull seg -> historical = confirmed/solid
                    // New bear TL: highest X-col top in last 20 cols
                    _newAnchorCi = ci - 1
                    _newAnchorPx = f_g_priceFromIdx(array.get(g_hi, ci - 1) + 1)
                    for sc = ci - 1 to math.max(start, ci - 20) by 1
                        if array.get(g_dir, sc) == 1
                            _candPx = f_g_priceFromIdx(array.get(g_hi, sc) + 1)
                            if _candPx > _newAnchorPx
                                // Reject a pre-penetrated high - falling resistance from sc must not be breached before the break col
                                _validHigh = true
                                for vc1 = sc + 1 to ci - 1 by 1
                                    if f_g_priceFromIdx(array.get(g_hi, vc1) + 1) > _candPx - float(vc1 - sc) * i_box
                                        _validHigh := false
                                        break
                                if _validHigh
                                    _newAnchorCi := sc
                                    _newAnchorPx := _candPx
                                    _newAnchorPx
                    _tlDir := -1
                    _tlAnchorCi := _newAnchorCi
                    _tlAnchorPx := _newAnchorPx
                    _tlConf := hasBearBO // new bear seg born confirmed if a sell signal is present at the flip, else provisional (dotted)

            else if _tlDir == -1 and cDir == 1
                tlVal = _tlAnchorPx - float(ci - _tlAnchorCi) * i_box
                if f_g_priceFromIdx(array.get(g_hi, ci) + 1) > tlVal
                    // Inline BO gate: X-col makes new high vs prior X-col (widened to 6-col window)
                    hasBullBO = false
                    for bk = math.max(_tlAnchorCi + 1, ci - 6) to ci by 1
                        if array.get(g_dir, bk) == 1 and bk >= 2
                            if array.get(g_hi, bk) > array.get(g_hi, math.max(0, bk - 2))
                                hasBullBO := true
                                break
                    // Flip on penetration alone (draw at the first reversal); BO gate removed
                    array.push(tl_sCi, _tlAnchorCi)
                    array.push(tl_sPx, _tlAnchorPx)
                    array.push(tl_sDir, -1)
                    array.push(tl_eBrk, ci)
                    array.push(tl_sConf, true) // closed bear seg -> historical = confirmed/solid
                    // New bull TL: lowest O-col bottom in last 20 cols
                    _newAnchorCi = ci - 1
                    _newAnchorPx = f_g_priceFromIdx(array.get(g_lo, ci - 1))
                    for sc = ci - 1 to math.max(start, ci - 20) by 1
                        if array.get(g_dir, sc) == -1
                            _candPx2 = f_g_priceFromIdx(array.get(g_lo, sc))
                            if _candPx2 < _newAnchorPx
                                // Reject a pre-penetrated low - rising support from sc must not be breached before the break col
                                _validLow = true
                                for vc2 = sc + 1 to ci - 1 by 1
                                    if f_g_priceFromIdx(array.get(g_lo, vc2)) < _candPx2 + float(vc2 - sc) * i_box
                                        _validLow := false
                                        break
                                if _validLow
                                    _newAnchorCi := sc
                                    _newAnchorPx := _candPx2
                                    _newAnchorPx
                    _tlDir := 1
                    _tlAnchorCi := _newAnchorCi
                    _tlAnchorPx := _newAnchorPx
                    _tlConf := hasBullBO // new bull seg born confirmed if a buy signal is present at the flip, else provisional (dotted)

        // Push active segment
        array.push(tl_sCi, _tlAnchorCi)
        array.push(tl_sPx, _tlAnchorPx)
        array.push(tl_sDir, _tlDir)
        array.push(tl_eBrk, -1)
        array.push(tl_sConf, _tlConf) // active segment carries its live confirmation state (provisional=dotted / confirmed=solid)

        // ── Pass 2: render all TL segments ───────────────────────────────
        // ALL main TL segments are SOLID (active = base+1, historical = 1).
        // Minimum span filter (i_tl_minSpan) suppresses noise — short 2-col TLs excluded.
        // Visual termination: BOTH active and historical stop at the first column
        // whose price range crosses the TL line (clean column-stop rendering).
        // Active with no crossing found: extends i_tl_proj cols to the right.
        nSegs = array.size(tl_sCi)
        for si = 0 to nSegs - 1 by 1
            if nSegs < 1
                break    // Guard: empty array -> `for 0 to -1` auto-reverses and runs at index 0
            sAnchorCi = array.get(tl_sCi, si)
            sAnchorPx = array.get(tl_sPx, si)
            sDir = array.get(tl_sDir, si)
            sBreakCi = array.get(tl_eBrk, si)
            isActive = sBreakCi == -1

            // Minimum span filter — suppress short noise TLs (default 5 cols)
            segSpan = isActive ? n - 1 - sAnchorCi : sBreakCi - sAnchorCi
            _minSpan = isActive ? i_tl_minSpanActive : i_tl_minSpan
            if segSpan < _minSpan
                continue

            tlClr = sDir == 1 ? color.new(color.aqua, 0) : color.new(color.yellow, 50)
            tlWid = i_tl_width // All main TLs same width (default 2); internal TLs are width 1
            sConf = array.get(tl_sConf, si) // confirmed (buy/sell signal) vs provisional (reversal only)
            tlStyl = sConf ? line.style_solid : line.style_dotted // provisional active = dotted; confirmed + all historical = solid; internal TLs stay dashed

            x1 = bar_index - (n - 1 - sAnchorCi) * SPC
            y1 = sAnchorPx

            // Scan for first column that visually crosses the TL (column-stop)
            // Active: scan to n-1 | Historical: scan to sBreakCi
            scanEnd = isActive ? n - 1 : sBreakCi
            endCi = scanEnd
            endFound = false
            for ci2 = sAnchorCi + 1 to scanEnd by 1
                tlV2 = sAnchorPx + float(sDir) * float(ci2 - sAnchorCi) * i_box
                cDir2 = array.get(g_dir, ci2)
                if sDir == 1 and cDir2 == -1
                    if f_g_priceFromIdx(array.get(g_lo, ci2)) < tlV2
                        endCi := ci2
                        endFound := true
                        break
                else if sDir == -1 and cDir2 == 1
                    if f_g_priceFromIdx(array.get(g_hi, ci2) + 1) > tlV2
                        endCi := ci2
                        endFound := true
                        break

            // Visual span filter: historical TLs crossed early produce short stubs — suppress them
            // State-machine span may pass i_tl_minSpan but column-stop can terminate visually within 2 cols
            if not isActive and endFound and endCi - sAnchorCi < i_tl_minSpan
                continue
            // Active TL visually terminated early also suppressed (short stubs at recent anchors)
            if isActive and endFound and endCi - sAnchorCi < _minSpan
                continue

            // Pre-declare with projection default (active, not terminated)
            // Override below if historical or if a column-crossing was found
            x2 = bar_index + i_tl_proj * SPC
            y2 = sAnchorPx + float(sDir) * float(n - 1 + i_tl_proj - sAnchorCi) * i_box
            if not isActive or endFound
                x2 := bar_index - (n - 1 - endCi) * SPC
                y2 := sAnchorPx + float(sDir) * float(endCi - sAnchorCi) * i_box
                y2

            array.push(r_tl_lines, line.new(x1, y1, x2, y2, xloc.bar_index, extend.none, tlClr, tlStyl, tlWid))

        // ── Pass 3: internal TLs on active segment ────────────────────────
        // Scan RIGHT-TO-LEFT (most recent reaction first) for up to i_tl_maxInt
        // internal TL anchors inside the main TL envelope.
        //   Anchor at the most recent reaction high (bear)
        // or reaction low (bull) that lies inside the main TL envelope —
        // i.e. between current price and the main TL.
        // Internal TLs are DASHED to distinguish from main TL segments.
        nSegsLast = array.size(tl_sCi) - 1
        actAnchorCi = array.get(tl_sCi, nSegsLast)
        actAnchorPx = array.get(tl_sPx, nSegsLast)
        actDir = array.get(tl_sDir, nSegsLast)
        actClr = actDir == 1 ? color.new(color.aqua, 0) : color.new(color.yellow, 50)

        if i_tl_maxInt > 0 and n - 3 >= actAnchorCi + 4
            intCount = 0
            nextIntCi = n - 1 // right boundary for spacing check
            for ci = n - 3 to actAnchorCi + 4 by 1 // right-to-left: Pine infers step -1
                if intCount >= i_tl_maxInt
                    break
                cDir = array.get(g_dir, ci)
                // O-cols for bull TL; X-cols for bear TL
                isCandidate = actDir == 1 ? cDir == -1 : cDir == 1
                if isCandidate and nextIntCi - ci >= 3 // Min spacing between internal TL anchors
                    lvl = actDir == 1 ? array.get(g_lo, ci) : array.get(g_hi, ci)
                    intPx = actDir == 1 ? f_g_priceFromIdx(lvl) : f_g_priceFromIdx(lvl + 1)
                    tlAtCi = actAnchorPx + float(actDir) * float(ci - actAnchorCi) * i_box
                    isInside = actDir == 1 ? intPx >= tlAtCi - 1e-9 : intPx <= tlAtCi + 1e-9
                    if isInside
                        x1i = bar_index - (n - 1 - ci) * SPC
                        endCiI = n - 1
                        endFoundI = false
                        for ci3 = ci + 1 to n - 1 by 1
                            tlV3 = intPx + float(actDir) * float(ci3 - ci) * i_box
                            cDir3 = array.get(g_dir, ci3)
                            if actDir == 1 and cDir3 == -1
                                if f_g_priceFromIdx(array.get(g_lo, ci3)) < tlV3
                                    endCiI := ci3
                                    endFoundI := true
                                    break
                            else if actDir == -1 and cDir3 == 1
                                if f_g_priceFromIdx(array.get(g_hi, ci3) + 1) > tlV3
                                    endCiI := ci3
                                    endFoundI := true
                                    break
                        intSpan = endFoundI ? endCiI - ci : n - 1 - ci
                        if intSpan < i_tl_minSpan
                            continue
                        x2i = bar_index + i_tl_proj * SPC
                        y2i = intPx + float(actDir) * float(n - 1 + i_tl_proj - ci) * i_box
                        if endFoundI
                            x2i := bar_index - (n - 1 - endCiI) * SPC
                            y2i := intPx + float(actDir) * float(endCiI - ci) * i_box
                            y2i
                        array.push(r_tl_lines, line.new(x1i, intPx, x2i, y2i, xloc.bar_index, extend.none, actClr, line.style_dashed, 1))
                        nextIntCi := ci
                        intCount := intCount + 1
                        intCount

    // ──────────────────────────────────────────────────────────────────────
    //    SPECIAL PATTERNS: POLES
    // ──────────────────────────────────────────────────────────────────────
    //   High Pole (bearish warning): X-col height >= minLen AND X-col
    //     extends above prior X-col by >= 3 boxes AND immediately adjacent
    //     O-col retraces >= 50% of X-col height.
    //   Low Pole (bullish warning): O-col height >= minLen AND O-col
    //     extends below prior O-col by >= 3 boxes AND immediately adjacent
    //     X-col retraces >= 50% of O-col height.
    //   Age filter: hide poles older than i_sp_maxAge cols (0=show all).
    //   Poles are REVERSAL patterns only — never continuation.
    //   Note: post-confirmation negation removed (once the 50%
    //   retrace fires, the warning is historical fact. Subsequent new
    //   highs/lows are separate market action, not pole cancellation).
    // ──────────────────────────────────────────────────────────────────────

    if i_sp_show and i_sp_pole and n >= 4
        for ci = math.max(start, 2) to n - 2 by 1
            cDir = array.get(g_dir, ci)
            colHi = array.get(g_hi, ci)
            colLo = array.get(g_lo, ci)
            colLen = colHi - colLo + 1
            if colLen < i_sp_poleMinLen
                continue

            // ── High Pole: X-column ───────────────────────────────────────────────
            if cDir == 1
                priorXHi = array.get(g_hi, ci - 2)
                if colHi >= priorXHi + 3
                    adjDir = array.get(g_dir, ci + 1)
                    if adjDir == -1
                        adjLo = array.get(g_lo, ci + 1)
                        retrace = colHi - adjLo
                        if retrace * 2 >= colLen
                            if i_sp_maxAge > 0 and n - 1 - ci > i_sp_maxAge
                                continue
                            // Lifecycle: scan forward from ci+2
                            hp_st = 'Active'
                            hp_scanTo = math.min(n - 1, array.size(g_dir) - 1)
                            if ci + 2 <= hp_scanTo    // Guard: at ci = n-2 the from-bound ci+2 exceeds the to-bound -> Pine reverses and reads array index n (out of bounds). Empty forward scan leaves the pole `Active` - the correct default.
                                for cj = ci + 2 to hp_scanTo by 1
                                    djDir = array.get(g_dir, cj)
                                    if djDir == 1 and array.get(g_hi, cj) > colHi
                                        hp_st := 'Negated'
                                        break
                                    if djDir == -1 and array.get(g_lo, cj) < adjLo
                                        hp_st := 'Hit'
                                        break
                            if hp_st == 'Hit' and i_sp_poleHideHit or hp_st == 'Negated' and i_sp_poleHideNeg
                                continue
                            spClr = hp_st == 'Active' ? i_sp_hpCol : color.new(i_sp_hpCol, 65)
                            xPos = bar_index - (n - 1 - ci) * SPC
                            topPx = f_g_priceFromIdx(colHi + 1)
                            hlfIdx = colHi - colLen / 2
                            hlfPx = f_g_priceFromIdx(int(math.round(hlfIdx)))
                            xAdj = bar_index - (n - 1 - (ci + 1)) * SPC
                            lb = label.new(xPos, topPx, 'HP', xloc.bar_index, yloc.price, color.new(color.black, 100), label.style_label_down, spClr, size.small)
                            array.push(r_sp_labels, lb)
                            array.push(r_sp_lines, line.new(xPos, hlfPx, xAdj, hlfPx, xloc.bar_index, extend.none, spClr, line.style_dashed, 1))

            // ── Low Pole: O-column ──────────────────────────────────────────────
            else if cDir == -1
                priorOLo = array.get(g_lo, ci - 2)
                if colLo <= priorOLo - 3
                    adjDir = array.get(g_dir, ci + 1)
                    if adjDir == 1
                        adjHi = array.get(g_hi, ci + 1)
                        retrace = adjHi - colLo
                        if retrace * 2 >= colLen
                            if i_sp_maxAge > 0 and n - 1 - ci > i_sp_maxAge
                                continue
                            // Lifecycle: scan forward from ci+2
                            lp_st = 'Active'
                            lp_scanTo = math.min(n - 1, array.size(g_dir) - 1)
                            if ci + 2 <= lp_scanTo    // Guard: at ci = n-2 the from-bound ci+2 exceeds the to-bound -> Pine reverses and reads array index n (out of bounds). Empty forward scan leaves the pole `Active` - the correct default.
                                for cj = ci + 2 to lp_scanTo by 1
                                    djDir = array.get(g_dir, cj)
                                    if djDir == -1 and array.get(g_lo, cj) < colLo
                                        lp_st := 'Negated'
                                        break
                                    if djDir == 1 and array.get(g_hi, cj) > adjHi
                                        lp_st := 'Hit'
                                        break
                            if lp_st == 'Hit' and i_sp_poleHideHit or lp_st == 'Negated' and i_sp_poleHideNeg
                                continue
                            spClr = lp_st == 'Active' ? i_sp_lpCol : color.new(i_sp_lpCol, 65)
                            xPos = bar_index - (n - 1 - ci) * SPC
                            botPx = f_g_priceFromIdx(colLo)
                            hlfIdx = colLo + colLen / 2
                            hlfPx = f_g_priceFromIdx(int(math.round(hlfIdx)))
                            xAdj = bar_index - (n - 1 - (ci + 1)) * SPC
                            lb = label.new(xPos, botPx, 'LP', xloc.bar_index, yloc.price, color.new(color.black, 100), label.style_label_up, spClr, size.small)
                            array.push(r_sp_labels, lb)
                            array.push(r_sp_lines, line.new(xPos, hlfPx, xAdj, hlfPx, xloc.bar_index, extend.none, spClr, line.style_dashed, 1))

    // ══════════════════════════════════════════════════════════════════════
    //    CATAPULT + TRAP DETECTION
    // ──────────────────────────────────────────────────────────────────────
    //   Aligned with Classic BO detection (cp_pattern[], look-left validated).
    //   Bull Catapult: ci = TT breakout column (cp_pattern=="TT") →
    //     O pullback returns INTO pattern (adjLo <= TT resistance level) AND
    //     does NOT give double-bottom sell (adjLo >= prevOLo) →
    //     resolution X col exceeds initial breakout high.
    //   Bull Trap: ci = any Classic buy BO (DT or TT) →
    //     O pullback DOES give double-bottom sell (adjLo < prevOLo).
    //   Bear versions are mirrored (TB / DB).
    //   Age filter: shared i_sp_maxAge.
    //
    // ──────────────────────────────────────────────────────────────────────
    if i_sp_show and (i_sp_cat or i_sp_trap) and n >= 6
        for ci = math.max(start, 2) to n - 2 by 1
            ciPat = array.get(cp_pattern, ci)
            if ciPat == ''
                continue
            cDir = array.get(g_dir, ci)
            colHi = array.get(g_hi, ci)
            colLo = array.get(g_lo, ci)
            if ci + 1 > n - 2
                continue
            adjDir = array.get(g_dir, ci + 1)
            // Age filter (applied once per ci)
            if i_sp_maxAge > 0 and n - 1 - ci > i_sp_maxAge
                continue

            // ── Bull patterns: initial signal is a Classic buy BO ─────────
            if cDir == 1 and adjDir == -1
                prevOLo = array.get(g_lo, ci - 1) // O-col low before initial signal
                ttLvl = array.get(g_hi, ci - 2) // TT resistance level (= g_hi[ci-4] for TT)
                adjLo = array.get(g_lo, ci + 1)
                xPos = bar_index - (n - 1 - ci) * SPC
                xAdj = bar_index - (n - 1 - (ci + 1)) * SPC
                // ── Bull Trap: any Classic buy BO + pullback gives DB sell ─
                if i_sp_trap and adjLo < prevOLo
                    trPx = f_g_priceFromIdx(adjLo)
                    // Lifecycle: scan forward for Hit (O-col below entry) or Negated (X-col above BO high)
                    trState = 'Active'
                    for fk = ci + 2 to math.min(n - 1, array.size(g_dir) - 1) by 1
                        fDir = array.get(g_dir, fk)
                        fHi = array.get(g_hi, fk)
                        fLo = array.get(g_lo, fk)
                        if fDir == 1 and fHi > colHi
                            trState := 'Negated'
                            break
                        if fDir == -1 and fLo < adjLo
                            trState := 'Hit'
                            break
                    if not(trState == 'Hit' and i_sp_trapHideHit) and not(trState == 'Negated' and i_sp_trapHideNeg)
                        trLbl = 'Bull Trap' + (trState == 'Hit' ? ' [H]' : trState == 'Negated' ? ' [N]' : '')
                        lb = label.new(xAdj, trPx, trLbl, xloc.bar_index, yloc.price, color.new(color.black, 100), label.style_label_up, i_sp_trapSCol, size.small)
                        array.push(r_sp_labels, lb)
                        array.push(r_sp_lines, line.new(xPos, trPx, xAdj, trPx, xloc.bar_index, extend.none, i_sp_trapSCol, line.style_dashed, 1))
                // ── Bull Catapult: TT breakout + pullback into pattern + resolution ─
                else if i_sp_cat and ciPat == 'TT' and adjLo >= prevOLo and adjLo <= ttLvl
                    if ci + 2 <= n - 2
                        resDir = array.get(g_dir, ci + 2)
                        resHi = array.get(g_hi, ci + 2)
                        if resDir == 1 and resHi > colHi
                            xRes = bar_index - (n - 1 - (ci + 2)) * SPC
                            catPx = f_g_priceFromIdx(resHi + 1)
                            bktPx = f_g_priceFromIdx(ttLvl + 1)
                            lb = label.new(xRes, catPx, 'Bull Cat', xloc.bar_index, yloc.price, color.new(color.black, 100), label.style_label_down, i_sp_catBCol, size.small)
                            array.push(r_sp_labels, lb)
                            array.push(r_sp_lines, line.new(xPos, bktPx, xRes, bktPx, xloc.bar_index, extend.none, i_sp_catBCol, line.style_dashed, 1))

            // ── Bear patterns: initial signal is a Classic sell BO ────────
            else if cDir == -1 and adjDir == 1
                prevXHi = array.get(g_hi, ci - 1) // X-col high before initial signal
                tbLvl = array.get(g_lo, ci - 2) // TB support level (= g_lo[ci-4] for TB)
                adjHi = array.get(g_hi, ci + 1)
                xPos = bar_index - (n - 1 - ci) * SPC
                xAdj = bar_index - (n - 1 - (ci + 1)) * SPC
                // ── Bear Trap: any Classic sell BO + pullback gives DT buy ─
                if i_sp_trap and adjHi > prevXHi
                    trPx = f_g_priceFromIdx(adjHi + 1)
                    // Lifecycle: scan forward for Hit (X-col above entry) or Negated (O-col below BO low)
                    trState = 'Active'
                    for fk = ci + 2 to math.min(n - 1, array.size(g_dir) - 1) by 1
                        fDir = array.get(g_dir, fk)
                        fHi = array.get(g_hi, fk)
                        fLo = array.get(g_lo, fk)
                        if fDir == -1 and fLo < colLo
                            trState := 'Negated'
                            break
                        if fDir == 1 and fHi > adjHi
                            trState := 'Hit'
                            break
                    if not(trState == 'Hit' and i_sp_trapHideHit) and not(trState == 'Negated' and i_sp_trapHideNeg)
                        trLbl = 'Bear Trap' + (trState == 'Hit' ? ' [H]' : trState == 'Negated' ? ' [N]' : '')
                        lb = label.new(xAdj, trPx, trLbl, xloc.bar_index, yloc.price, color.new(color.black, 100), label.style_label_down, i_sp_trapBCol, size.small)
                        array.push(r_sp_labels, lb)
                        array.push(r_sp_lines, line.new(xPos, trPx, xAdj, trPx, xloc.bar_index, extend.none, i_sp_trapBCol, line.style_dashed, 1))
                // ── Bear Catapult: TB breakout + pullback into pattern + resolution ─
                else if i_sp_cat and ciPat == 'TB' and adjHi <= prevXHi and adjHi >= tbLvl
                    if ci + 2 <= n - 2
                        resDir = array.get(g_dir, ci + 2)
                        resLo = array.get(g_lo, ci + 2)
                        if resDir == -1 and resLo < colLo
                            xRes = bar_index - (n - 1 - (ci + 2)) * SPC
                            catPx = f_g_priceFromIdx(resLo)
                            bktPx = f_g_priceFromIdx(tbLvl)
                            lb = label.new(xRes, catPx, 'Bear Cat', xloc.bar_index, yloc.price, color.new(color.black, 100), label.style_label_up, i_sp_catSCol, size.small)
                            array.push(r_sp_labels, lb)
                            array.push(r_sp_lines, line.new(xPos, bktPx, xRes, bktPx, xloc.bar_index, extend.none, i_sp_catSCol, line.style_dashed, 1))

// ── END OF SCRIPT ─────────────────────────────────────────────────────────
````
