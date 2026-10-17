# EQH/EQL Liquidity Sweep | AlphaScript

- url: https://www.tradingview.com/script/POVOTqyb-EQH-EQL-Liquidity-Sweep-AlphaScript/
- type: indicator
- pine_id: PUB;3c18468526f64a60a3dfce7c62896ea6
- version: 1.0

## Description

[b]⚖️ EQH/EQL Liquidity Sweep[/b]
Detects clusters of equal highs (EQH) and equal lows (EQL) the resting-liquidity pools that price hunts and tracks exactly what happens to each one: swept, broken, or still active. Then it measures the real sweep rate so you can see your actual edge.

[b]🎯 Why equal highs and lows matter[/b]
When price makes a high, pulls back, then makes another high at the same level, stops pile up just beyond that level — breakout orders, protective stops, resting liquidity. 
The more times price taps the same level, the more orders accumulate there. Those pools are what larger participants hunt. This tool maps them automatically and then tells you whether each pool got raided or genuinely failed.

[b]🔍 How pools form[/b]
The indicator finds swing highs and lows, then groups any that sit within a configurable tolerance of each other into a single pool. 
A pool needs at least a minimum number of touches (default 2) to display. The pool line is drawn at the extreme of the cluster — the highest of the equal highs, or lowest of the equal lows — because that is where the stops actually rest. A small × marks each individual swing that built the pool, and the line thickness and badge show the touch count.

[b]Each pool resolves in one of these ways:[/b]

[b]⚡ SWEPT —[/b] price wicks through the pool extreme but the bar closes back on the original side. Stops were taken, but the level held on a closing basis. A liquidity raid.

[b]💥 BROKEN —[/b] a bar closes through the pool extreme. The level genuinely failed — continuation, not a raid. Breaks are shown separately and never labeled as sweeps.

[b]🛡️ Active —[/b] the pool has neither been swept nor broken and is still in play. Pools that go too long without resolving expire and are removed.
First qualifying event wins: one outcome per pool. If a bar both wicks through and closes through, it counts as a break — a close through the level can never be a sweep.

[b]📊 Sweep-rate table | know your real edge[/b]
This is what separates the tool from every other equal-highs indicator: instead of just drawing levels, it measures what actually happens to them. The table breaks down every resolved pool by touch count (2 / 3 / 4+) and shows the real sweep and break percentages for each group — computed live from your own instrument, timeframe, and history.

[b]That means you can answer the question that matters before taking a trade: do the pools you're watching actually get swept, or do they break?[/b] If 3-touch pools on your instrument sweep far more often than they break, that's a measured edge you can trade around. If 2-touch pools are a coin flip, you know to demand more confluence. The numbers come from the chart, not from a claim on a marketing page.

Only fully resolved pools are counted, active pools are excluded, so the rates can never be inflated by in-progress levels. The denominator is honest: what you see is what actually happened.

[b]⚙️ Settings[/b]

-Swing lookback, and equal tolerance in ATR multiples (instrument-independent) or fixed ticks.
-Minimum touches to form a pool, maximum pool age, and how many active pools to track per side.
-Optional minimum wick penetration (ATR-based) to filter marginal sweeps. Does not apply to breaks.
-Optional "Strict Virgin Liquidity" mode: discards a forming level if price closes decisively beyond it before a second touch, so only levels that were never truly broken can pair. Off by default.
-Full display control: pool zones, touch badges, × touch markers, colors, line styles and widths, and how many resolved pools remain on the chart.
-Sweep-rate table with position options.

[b]🔔 Alerts[/b]
Per-side sweep alerts (EQH and EQL), separate break alerts, and a combined "Any Pool Swept" alert. All alerts fire on the close of the event bar.

[b]📌 Notes and limitations[/b]

-Designed for intraday and swing timeframes. Very low timeframes produce many small pools; adjust tolerance and swing lookback to suit.
-Detection uses standard swing pivots. A peak whose neighboring bar wicks slightly higher may not register as a separate pivot, so not every visual high becomes a pool — tune the swing lookback and tolerance to match how you read structure.
-The equal tolerance is the single most important setting. Too tight and genuine equal levels are missed; too loose and unrelated highs merge. Start moderate and adjust to your instrument.
-The sweep-rate table describes the pools on your loaded chart history. It is a measurement of what happened, not a prediction of what the next pool will do.

[b]✅ Why no repaint[/b]
-Pivots are confirmed only after the swing lookback completes, and all pool detection runs on closed bars only. A sweep or break tag will never appear intrabar and then vanish.
-A pool is only evaluated for sweep or break once it has fully formed. A level still building cannot be resolved.
-No request.security() calls are used anywhere. All detection is chart-timeframe state.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © AlphaScript

//@version=6
indicator("EQH/EQL Liquidity Sweep | AlphaScript", shorttitle = "EQH/EQL Sweep | AlphaScript",
     overlay = true, max_lines_count = 500, max_labels_count = 500, max_boxes_count = 500)

// ═══════════════════════════════════════════════════════════════════
//  INPUTS
// ═══════════════════════════════════════════════════════════════════
var string GRP_DET = "Detection"
swingLen  = input.int(10, "Swing Lookback", minval = 3, maxval = 50, group = GRP_DET,
     tooltip = "Bars on each side required to confirm a pivot. A pivot is confirmed this many bars after it prints.")
tolMode   = input.string("ATR", "Tolerance Mode", options = ["ATR", "Ticks"], group = GRP_DET, inline = "tol")
tolAtr    = input.float(0.25, "ATR ×", minval = 0.01, maxval = 2.0, step = 0.05, group = GRP_DET, inline = "tol",
     tooltip = "Two swing highs (or lows) count as EQUAL when they sit within this distance of each other. ATR mode is instrument-independent; Ticks mode is absolute.")
tolTicks  = input.int(10, "or Ticks", minval = 1, maxval = 500, group = GRP_DET, inline = "tol")
minTouch  = input.int(2, "Min Touches to Form Pool", minval = 2, maxval = 5, group = GRP_DET)
strictVirgin = input.bool(false, "Strict Virgin Liquidity", group = GRP_DET,
     tooltip = "OFF (default): two pivots within tolerance form a pool, standard behavior. ON: discard a forming level if price closes decisively beyond it (more than tolerance past) before a second touch — only levels that were never truly broken can pair. Stricter, produces fewer pools.")
maxAge    = input.int(500, "Max Pool Age (bars)", minval = 50, maxval = 5000, group = GRP_DET,
     tooltip = "A pool that is neither swept nor broken within this many bars of its FIRST touch expires and is removed.")
maxPools  = input.int(6, "Max Active Pools per Side", minval = 1, maxval = 20, group = GRP_DET)

var string GRP_SWP = "Sweep Logic"
minPenAtr = input.float(0.0, "Min Penetration (ATR mult)", minval = 0.0, maxval = 2.0, step = 0.05, group = GRP_SWP,
     tooltip = "Wick must pierce the pool extreme by at least this multiple of ATR to qualify as a sweep. 0 = any touch beyond. Instrument-independent. Does not apply to breaks — a close through is always a break.")

var string GRP_DSP  = "Display"
showZones   = input.bool(true, "Show Pool Zones",         group = GRP_DSP)
showBadges  = input.bool(true, "Show Touch-Count Badges",  group = GRP_DSP)
showTouchX  = input.bool(true, "Mark Each Touch (×)",     group = GRP_DSP,
     tooltip = "Small × on each swing high/low that built the pool. Removed when the pool resolves.")
extBars     = input.int(20, "Extend Pools Right (bars)", minval = 1, maxval = 200, group = GRP_DSP)
keepDone    = input.int(6,  "Resolved Pools to Keep",    minval = 0, maxval = 30, group = GRP_DSP,
     tooltip = "Swept/broken pools kept on the chart, per side. 0 = remove immediately on resolution.")
lblSizeIn   = input.string("Small", "Text Size", options = ["Tiny", "Small", "Normal", "Large"], group = GRP_DSP)

var string GRP_CLR = "Colors"
colEQH     = input.color(color.new(#FF9F1C, 0), "EQH Color",   group = GRP_CLR)
colEQL     = input.color(color.new(#00B4D8, 0), "EQL Color",   group = GRP_CLR)
colSweep   = input.color(color.new(#FF4444, 0), "Sweep Color", group = GRP_CLR)
colBreak   = input.color(color.new(#00FF88, 0), "Break Color", group = GRP_CLR)
zoneTransp = input.int(85, "Zone Transparency", minval = 50, maxval = 98, group = GRP_CLR)

var string GRP_LINE = "Line Style"
lineStyleIn  = input.string("Solid",  "Active Pool Line Style",   options = ["Solid", "Dashed", "Dotted"], group = GRP_LINE)
lineWidthIn  = input.int(2,            "Active Pool Line Width",   minval = 1, maxval = 4, group = GRP_LINE)
doneStyleIn  = input.string("Dashed", "Resolved Pool Line Style", options = ["Solid", "Dashed", "Dotted"], group = GRP_LINE)
borderTransp = input.int(70, "Zone Border Transparency", minval = 0, maxval = 98, group = GRP_LINE)

var string GRP_TBL = "Stats Table"
showTable = input.bool(true, "Show Sweep-Rate Table", group = GRP_TBL,
     tooltip = "Measured outcomes of RESOLVED pools only, split by touch count. Active pools are not counted, so the rates cannot be inflated by in-progress levels. Rates reflect the loaded chart history.")
tablePos  = input.string("Top Right", "Position", options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group = GRP_TBL)

// ═══════════════════════════════════════════════════════════════════
//  HELPERS
// ═══════════════════════════════════════════════════════════════════
f_txtSize(string s) =>
    s == "Tiny" ? size.tiny : s == "Small" ? size.small : s == "Large" ? size.large : size.normal

f_lineStyle(string s) =>
    s == "Dashed" ? line.style_dashed : s == "Dotted" ? line.style_dotted : line.style_solid

f_tablePos(string s) =>
    s == "Top Left" ? position.top_left : s == "Bottom Right" ? position.bottom_right : s == "Bottom Left" ? position.bottom_left : position.top_right

f_msPerBar() =>
    bar_index > 0 ? int(time - time[1]) : timeframe.in_seconds() * 1000

f_bucket(int touches) =>
    touches >= 4 ? 2 : touches == 3 ? 1 : 0

// ═══════════════════════════════════════════════════════════════════
//  SHARED CALCS
// ═══════════════════════════════════════════════════════════════════
atrVal    = ta.atr(14)
tolerance = tolMode == "ATR" ? atrVal * tolAtr : syminfo.mintick * tolTicks
minPen    = atrVal * minPenAtr

ph = ta.pivothigh(high, swingLen, swingLen)
pl = ta.pivotlow(low,  swingLen, swingLen)

// ═══════════════════════════════════════════════════════════════════
//  POOL TYPE
// ═══════════════════════════════════════════════════════════════════
type Pool
    bool    isHigh
    float   extreme
    float   zoneInner
    int     firstBar
    int     firstTime
    int     touches
    line    ln     = na
    box     bx     = na
    label   badge  = na
    label[] touchX = na

// ── Storage ────────────────────────────────────────────────────────
var Pool[]  highPools = array.new<Pool>()
var Pool[]  lowPools  = array.new<Pool>()
var line[]  doneLines  = array.new<line>()
var box[]   doneBoxes  = array.new<box>()
var label[] doneLabels = array.new<label>()

// ── Stats: resolved-pool counters split by touch bucket (2 / 3 / 4+)
var int[] statSweep = array.new<int>(3, 0)
var int[] statBreak = array.new<int>(3, 0)

// ═══════════════════════════════════════════════════════════════════
//  POOL METHODS
// ═══════════════════════════════════════════════════════════════════
f_pruneDone() =>
    while doneLines.size() > keepDone * 2
        line.delete(doneLines.shift())
    while doneBoxes.size() > keepDone * 2
        box.delete(doneBoxes.shift())
    while doneLabels.size() > keepDone * 4
        label.delete(doneLabels.shift())

method f_clearTouchX(Pool p) =>
    if not na(p.touchX) and p.touchX.size() > 0
        for i = 0 to p.touchX.size() - 1
            label.delete(p.touchX.get(i))
        p.touchX.clear()

method f_markTouch(Pool p, float px, int t) =>
    if showTouchX and not na(p.touchX)
        color pc = p.isHigh ? colEQH : colEQL
        p.touchX.push(label.new(t, px, "×", xloc = xloc.bar_time, yloc = yloc.price, style = label.style_none, textcolor = pc, size = f_txtSize(lblSizeIn)))

method f_erasePool(Pool p) =>
    line.delete(p.ln)
    box.delete(p.bx)
    label.delete(p.badge)
    p.f_clearTouchX()

method f_resolvePoolVisual(Pool p, bool isSweep) =>
    color evCol = isSweep ? colSweep : colBreak
    if not na(p.ln)
        line.set_x2(p.ln, time)
        line.set_color(p.ln, evCol)
        line.set_style(p.ln, f_lineStyle(doneStyleIn))
        doneLines.push(p.ln)
    if not na(p.bx)
        box.set_right(p.bx, time)
        box.set_border_color(p.bx, color.new(evCol, 60))
        doneBoxes.push(p.bx)
    if not na(p.badge)
        doneLabels.push(p.badge)
    p.f_clearTouchX()
    string tag = (p.isHigh ? "EQH" : "EQL") + " ×" + str.tostring(p.touches) + (isSweep ? " SWEPT" : (p.isHigh ? " BREAK ▲" : " BREAK ▼"))
    label evTag = label.new(time, p.isHigh ? high : low, tag, xloc = xloc.bar_time, yloc = p.isHigh ? yloc.abovebar : yloc.belowbar, style = p.isHigh ? label.style_label_down : label.style_label_up, color = color.new(evCol, 20), textcolor = isSweep ? color.white : color.black, size = f_txtSize(lblSizeIn))
    doneLabels.push(evTag)
    f_pruneDone()

method f_drawPool(Pool p) =>
    color pc     = p.isHigh ? colEQH : colEQL
    int   msBar  = f_msPerBar()
    int   rightT = time + extBars * msBar
    int   w      = math.min(lineWidthIn + p.touches - minTouch, 4)
    if na(p.ln)
        p.ln := line.new(p.firstTime, p.extreme, rightT, p.extreme, xloc = xloc.bar_time, color = pc, style = f_lineStyle(lineStyleIn), width = w)
    else
        line.set_xy1(p.ln, p.firstTime, p.extreme)
        line.set_xy2(p.ln, rightT, p.extreme)
        line.set_width(p.ln, w)
    if showZones
        float zTop = math.max(p.extreme, p.zoneInner)
        float zBot = math.min(p.extreme, p.zoneInner)
        if na(p.bx)
            p.bx := box.new(p.firstTime, zTop, rightT, zBot, xloc = xloc.bar_time, bgcolor = color.new(pc, zoneTransp), border_color = color.new(pc, borderTransp))
        else
            box.set_lefttop(p.bx, p.firstTime, zTop)
            box.set_rightbottom(p.bx, rightT, zBot)
    if showBadges
        string btxt = (p.isHigh ? "EQH" : "EQL") + " ×" + str.tostring(p.touches) + "  " + str.tostring(p.extreme, format.mintick)
        if na(p.badge)
            p.badge := label.new(rightT + msBar, p.extreme, btxt, xloc = xloc.bar_time, style = label.style_label_left, color = color.new(color.white, 100), textcolor = pc, size = f_txtSize(lblSizeIn))
        else
            label.set_xy(p.badge, rightT + msBar, p.extreme)
            label.set_text(p.badge, btxt)
    int _done = 0

// ═══════════════════════════════════════════════════════════════════
//  PIVOT → POOL AGGREGATION (confirmed bars only)
// ═══════════════════════════════════════════════════════════════════
if barstate.isconfirmed and not na(ph)
    float px = high[swingLen]
    int   pt = int(time[swingLen])
    bool  joined = false
    if highPools.size() > 0
        for i = 0 to highPools.size() - 1
            Pool p = highPools.get(i)
            if not joined and math.abs(px - p.extreme) <= tolerance
                p.touches   += 1
                p.zoneInner := math.min(p.zoneInner, math.min(px, p.extreme))
                p.extreme   := math.max(p.extreme, px)
                p.f_markTouch(px, pt)
                joined := true
    if not joined
        Pool np = Pool.new(isHigh = true, extreme = px, zoneInner = px, firstBar = bar_index - swingLen, firstTime = pt, touches = 1, touchX = array.new<label>())
        np.f_markTouch(px, pt)
        highPools.push(np)
        if highPools.size() > maxPools * 2
            highPools.shift().f_erasePool()

if barstate.isconfirmed and not na(pl)
    float px = low[swingLen]
    int   pt = int(time[swingLen])
    bool  joined = false
    if lowPools.size() > 0
        for i = 0 to lowPools.size() - 1
            Pool p = lowPools.get(i)
            if not joined and math.abs(px - p.extreme) <= tolerance
                p.touches   += 1
                p.zoneInner := math.max(p.zoneInner, math.max(px, p.extreme))
                p.extreme   := math.min(p.extreme, px)
                p.f_markTouch(px, pt)
                joined := true
    if not joined
        Pool np = Pool.new(isHigh = false, extreme = px, zoneInner = px, firstBar = bar_index - swingLen, firstTime = pt, touches = 1, touchX = array.new<label>())
        np.f_markTouch(px, pt)
        lowPools.push(np)
        if lowPools.size() > maxPools * 2
            lowPools.shift().f_erasePool()

// ═══════════════════════════════════════════════════════════════════
//  POOL RESOLUTION — sweep / break / expiry (confirmed bars only)
//  Qualified pools (>= minTouch): break / sweep / expire.
//  Pending pools (< minTouch): expire on age, and — ONLY if Strict
//  Virgin Liquidity is ON — discard on a decisive close beyond the
//  level (> tolerance past). With the toggle OFF (default), pending
//  candidates are never purged on close-through; they just wait for
//  a second touch. Break precedence: a close through is never a sweep.
// ═══════════════════════════════════════════════════════════════════
bool eqhSweepNow = false
bool eqhBreakNow = false
bool eqlSweepNow = false
bool eqlBreakNow = false

if barstate.isconfirmed
    // ── EQH pools ──────────────────────────────────────────────────
    if highPools.size() > 0
        for i = highPools.size() - 1 to 0
            Pool p = highPools.get(i)
            int  b = f_bucket(p.touches)
            if p.touches >= minTouch
                if close > p.extreme
                    statBreak.set(b, statBreak.get(b) + 1)
                    eqhBreakNow := true
                    p.f_resolvePoolVisual(false)
                    highPools.remove(i)
                else if high >= p.extreme + minPen and close <= p.extreme
                    statSweep.set(b, statSweep.get(b) + 1)
                    eqhSweepNow := true
                    p.f_resolvePoolVisual(true)
                    highPools.remove(i)
                else if bar_index - p.firstBar > maxAge
                    p.f_erasePool()
                    highPools.remove(i)
            else
                bool violated = strictVirgin and close > p.extreme + tolerance
                if violated or bar_index - p.firstBar > maxAge
                    p.f_erasePool()
                    highPools.remove(i)

    // ── EQL pools ──────────────────────────────────────────────────
    if lowPools.size() > 0
        for i = lowPools.size() - 1 to 0
            Pool p = lowPools.get(i)
            int  b = f_bucket(p.touches)
            if p.touches >= minTouch
                if close < p.extreme
                    statBreak.set(b, statBreak.get(b) + 1)
                    eqlBreakNow := true
                    p.f_resolvePoolVisual(false)
                    lowPools.remove(i)
                else if low <= p.extreme - minPen and close >= p.extreme
                    statSweep.set(b, statSweep.get(b) + 1)
                    eqlSweepNow := true
                    p.f_resolvePoolVisual(true)
                    lowPools.remove(i)
                else if bar_index - p.firstBar > maxAge
                    p.f_erasePool()
                    lowPools.remove(i)
            else
                bool violated = strictVirgin and close < p.extreme - tolerance
                if violated or bar_index - p.firstBar > maxAge
                    p.f_erasePool()
                    lowPools.remove(i)

// ═══════════════════════════════════════════════════════════════════
//  DRAW QUALIFIED ACTIVE POOLS
// ═══════════════════════════════════════════════════════════════════
if highPools.size() > 0
    for i = 0 to highPools.size() - 1
        Pool p = highPools.get(i)
        if p.touches >= minTouch
            p.f_drawPool()
if lowPools.size() > 0
    for i = 0 to lowPools.size() - 1
        Pool p = lowPools.get(i)
        if p.touches >= minTouch
            p.f_drawPool()

// ═══════════════════════════════════════════════════════════════════
//  SWEEP / BREAK RATE TABLE — resolved pools only, split by touches
// ═══════════════════════════════════════════════════════════════════
var table tbl = na

f_pct(int num, int den) =>
    den > 0 ? str.tostring(100.0 * num / den, "#.#") + "%" : "—"

f_statRow(int row, string name, int b) =>
    int sw  = statSweep.get(b)
    int bk  = statBreak.get(b)
    int res = sw + bk
    table.cell(tbl, 0, row, name,              text_color = color.white, text_size = size.small)
    table.cell(tbl, 1, row, str.tostring(res), text_color = color.white, text_size = size.small)
    table.cell(tbl, 2, row, str.tostring(sw),  text_color = colSweep,    text_size = size.small)
    table.cell(tbl, 3, row, str.tostring(bk),  text_color = colBreak,    text_size = size.small)
    table.cell(tbl, 4, row, f_pct(sw, res),    text_color = colSweep,    text_size = size.small)
    table.cell(tbl, 5, row, f_pct(bk, res),    text_color = colBreak,    text_size = size.small)

if barstate.islast and showTable
    if na(tbl)
        tbl := table.new(f_tablePos(tablePos), 6, 4, bgcolor = color.new(#1e222d, 10), border_width = 1, border_color = color.new(color.gray, 70))
    table.cell(tbl, 0, 0, "Pool",     text_color = color.white, text_size = size.small)
    table.cell(tbl, 1, 0, "Resolved", text_color = color.white, text_size = size.small)
    table.cell(tbl, 2, 0, "Swept",    text_color = colSweep,    text_size = size.small)
    table.cell(tbl, 3, 0, "Broken",   text_color = colBreak,    text_size = size.small)
    table.cell(tbl, 4, 0, "Sweep %",  text_color = colSweep,    text_size = size.small)
    table.cell(tbl, 5, 0, "Break %",  text_color = colBreak,    text_size = size.small)
    f_statRow(1, "2-touch",  0)
    f_statRow(2, "3-touch",  1)
    f_statRow(3, "4+ touch", 2)

// ═══════════════════════════════════════════════════════════════════
//  ALERTS
// ═══════════════════════════════════════════════════════════════════
alertcondition(eqhSweepNow, "EQH Pool Swept",  "Equal Highs liquidity pool swept on {{ticker}} — wick through, close back below at {{close}}")
alertcondition(eqlSweepNow, "EQL Pool Swept",  "Equal Lows liquidity pool swept on {{ticker}} — wick through, close back above at {{close}}")
alertcondition(eqhBreakNow, "EQH Pool Broken", "Equal Highs pool broken (close through) on {{ticker}} at {{close}}")
alertcondition(eqlBreakNow, "EQL Pool Broken", "Equal Lows pool broken (close through) on {{ticker}} at {{close}}")
alertcondition(eqhSweepNow or eqlSweepNow, "Any Pool Swept", "Equal High/Low liquidity pool swept on {{ticker}} at {{close}}")

// Sweep = wick through the pool extreme, close back inside → raid.
// Break = close through → pool failed. One outcome per pool.
// Strict Virgin Liquidity (optional) discards forming levels closed
// through before a second touch. Stats count RESOLVED pools only.
````
