# Trend Structure & Untested Levels

- url: https://www.tradingview.com/script/nfRtCzUb-Trend-Structure-Untested-Levels/
- type: indicator
- pine_id: PUB;e634c919691248d8b5a47887dd52a60d
- version: 5.0

## Description

Trend Structure & Tested Levels
Draws the swing trend as a zigzag, turns every swing into a support/resistance level, and tracks whether price has closed through it ("tested") or not ("untested").

Overview
A market-structure tool. It connects confirmed swing highs and lows into a clean zigzag trend line, then projects a horizontal level from each swing. Every level is classified by state — untested until a candle closes through it, after which the most recent break in each direction is flagged as Last Gained or Last Lost. The result is an at-a-glance map of the active structure and which levels are still in play.

What it does
Swing trend (zigzag). Connects confirmed pivot highs/lows into a trend line. A live, provisional leg always runs from the last confirmed pivot to the current price, so the structure reaches the current bar.
Automatic levels. Each swing high/low becomes a horizontal level — highs above price act as resistance, lows below price as support.
Tested vs untested. A level stays untested until a candle closes through it; a wick touch alone does not count.
Last Gained / Last Lost. The most recent resistance price closed above is tagged Last Gained (bullish break of structure); the most recent support price closed below is tagged Last Lost (bearish break).
Multi-timeframe
Levels — and the zigzag, in follow mode — can be drawn from the chart timeframe or any higher timeframe (e.g. D / W / M), labelled with a suffix such as (W). Higher-timeframe pivots are read without repainting forward-filled values and are anchored at the real pivot time, so an HTF level sits where it actually formed and runs horizontally across the whole chart.

Key settings
Pivot length — the master sensitivity control. Lower = a finer zigzag and more, smaller levels; higher = only the major structure.
Swing source — wicks (high/low) or candle bodies (open/close) to ignore wick spikes.
Zigzag follows levels timeframe — keep trend line and levels on one structure, or decouple the zigzag onto the chart timeframe.
Independent colours, line styles, widths, and a per-side cap on untested levels.
Notes
This is a visualisation of structure, not a signal or strategy — it says nothing about profitability; validate separately.
Repainting. Swings confirm pivot length bars after the fact, and the live leg moves with price until a new pivot confirms.
Not financial advice.

## Source Code

````pine
//@version=6
// ════════════════════════════════════════════════════════════════════════════
//  Trend Structure & Tested Levels
//  - ZigZag swing structure (the trend line)
//  - Automatic horizontal levels at each confirmed swing high/low
//  - "Tested" = close-through (a candle closes through the level)
//      • untested  : price has not closed through it yet
//      • Last Gained: last resistance price closed above  (break up)
//      • Last Lost  : last support price closed below      (break down)
//  - Levels timeframe selectable (blank = chart, or D / W / M / ...)
// ════════════════════════════════════════════════════════════════════════════
indicator("Trend Structure & Tested Levels", "TSL", overlay = true, max_lines_count = 500, max_labels_count = 500)

// ──────────────────────────────────────────────── INPUTS ───────────────────
//  Trend (ZigZag)
gZ        = "Trend (ZigZag)"
showZig   = input.bool(true,    "Show zigzag",                 group = gZ)
lvlLen    = input.int(2,        "Pivot length (zigzag + levels)", minval = 1, group = gZ, tooltip = "The main sensitivity control. Legs for reversal detection: drives both the zigzag (when it turns) and the levels. Lower = turns more often + more (smaller) levels.")
zigUpCol  = input.color(#ffeb3b, "Up leg",   inline = "zc",    group = gZ)
zigDnCol  = input.color(#ffeb3b, "Down leg", inline = "zc",    group = gZ)
zigWidth  = input.int(2,        "Width",                       minval = 1, maxval = 6, group = gZ)
zigMax    = input.int(60,       "Max segments kept",           minval = 5, maxval = 480, group = gZ)

//  Levels
gL          = "Levels"
showLevels  = input.bool(true,  "Show levels",                 group = gL)
lvlTf       = input.timeframe("", "Levels timeframe",          group = gL, tooltip = "Blank = chart timeframe. Pick D / W / M / etc. to draw higher-timeframe swing levels (with a suffix on the label).")
levelSrc    = input.string("Wicks (high/low)", "Level source", options = ["Wicks (high/low)", "Bodies (open/close)"], group = gL, tooltip = "Wicks = swings on high/low (as now). Bodies = swings on the candle body (max/min of open & close); ignores wick spikes. The zigzag line always stays on wicks.")
maxUntested = input.int(6,      "Max untested levels / side",  minval = 1, maxval = 50, group = gL)
extendR     = input.bool(true,  "Extend levels to the right",  group = gL)
showPrice   = input.bool(true,  "Show price labels",           group = gL)
showSuffix  = input.bool(true,  "Timeframe suffix on labels",  group = gL)

//  Untested levels
gU       = "Untested levels"
unResCol = input.color(#e040fb,  "Resistance (above price)",   group = gU)
unSupCol = input.color(#26c6da,  "Support (below price)",      group = gU)
unStyleS = input.string("Solid", "Line style (untested)", options = ["Solid", "Dashed", "Dotted"], group = gU)
unWidth  = input.int(1,          "Width", minval = 1, maxval = 5, group = gU)
markTested  = input.bool(true,   "Mark 'tested' on wick touch", group = gU, tooltip = "As soon as a wick first touches the level (without closing through it) it becomes 'tested' → different line style. The level stays active until a close breaks through it (→ Last Gained/Lost).")
testedStyle = input.string("Dotted", "Line style after touch (tested)", options = ["Solid", "Dashed", "Dotted"], group = gU)

//  Broken levels (Last Gained / Last Lost)
gB         = "Broken levels (Last Gained/Lost)"
showBroken = input.bool(true,    "Show last broken levels",             group = gB)
showStruct = input.bool(true,    "'Last Lost' / 'Last Gained' labels",  group = gB)
gainCol    = input.color(#00e676, "Last Gained (closed above)",         group = gB)
gainStyleS = input.string("Solid",  "Gained style", options = ["Solid", "Dashed", "Dotted"], group = gB)
lostCol    = input.color(#ff5252, "Last Lost (closed below)",           group = gB)
lostStyleS = input.string("Dotted", "Lost style",   options = ["Solid", "Dashed", "Dotted"], group = gB)
brokWidth  = input.int(1,        "Width", minval = 1, maxval = 5,        group = gB)

// ──────────────────────────────────────────── HELPERS / TYPES ──────────────
styleOf(string s) => s == "Dashed" ? line.style_dashed : s == "Dotted" ? line.style_dotted : line.style_solid
tfTxt()           => lvlTf == "" ? timeframe.period : lvlTf
suffix()          => showSuffix ? " (" + tfTxt() + ")" : ""

type Lvl
    float price
    bool  isHigh
    line  ln
    label lb
    bool  tested
    int   bornBar

newLvl(float price, bool isHigh, int xt) =>
    color c = isHigh ? unResCol : unSupCol
    line ln = line.new(xt, price, time, price, xloc = xloc.bar_time, color = c, width = unWidth, style = styleOf(unStyleS), extend = extendR ? extend.right : extend.none)
    label lb = na
    if showPrice
        lb := label.new(time, price, str.tostring(price, format.mintick) + suffix(), xloc = xloc.bar_time, style = label.style_label_left, color = color.new(c, 80), textcolor = c, size = size.small)
    Lvl.new(price, isHigh, ln, lb, false, bar_index)

// ──────────────────────────────────────────────── STATE ────────────────────
var array<line> zlines   = array.new<line>()   // confirmed zigzag segments
var line        liveLeg  = na                   // tentative (current) leg
var int         zdir     = 0                     // 1 = up-leg, -1 = down-leg, 0 = init
var float       zext     = na                    // running extreme of the current leg
var int         zextT    = na
var float       zanchP   = na                    // last confirmed turning point (price)
var int         zanchT   = na                    // ... and time
var array<Lvl>  resists  = array.new<Lvl>()
var array<Lvl>  supports = array.new<Lvl>()

var line  gLine = na
var label gLab  = na
var line  lLine = na
var label lLab  = na

// ──────────────────────────────────────────────── PIVOTS ───────────────────
// Level source: wicks or bodies. Pivots are ALWAYS detected on the wicks (high/low) →
// identical swing structure. The ZIGZAG always stays on the wick extremes; only the LEVELS
// shift to the body (max/min of open & close) of that same pivot bar when 'Bodies'.
bool  lvlBody = levelSrc == "Bodies (open/close)"
bool  useHTF  = lvlTf != "" and lvlTf != timeframe.period

// Chart TF: detection on high/low. Per pivot we keep the WICK value (zigzag), the
// LEVEL value (wick or body) and the TIME of the pivot bar (x-anchor, bar_time).
float phWick = ta.pivothigh(high, lvlLen, lvlLen)
float plWick = ta.pivotlow(low,  lvlLen, lvlLen)
float phLcL  = na(phWick) ? na : (lvlBody ? math.max(open[lvlLen], close[lvlLen]) : phWick)
float plLcL  = na(plWick) ? na : (lvlBody ? math.min(open[lvlLen], close[lvlLen]) : plWick)
int   phLcT  = na(phWick) ? na : time[lvlLen]
int   plLcT  = na(plWick) ? na : time[lvlLen]

// HTF levels via security (gaps_on → once per pivot). 4 values:
//   level-high, level-low (wick or body) | time-high, time-low.
[phLS, plLS, phST, plST] = request.security(syminfo.tickerid, lvlTf == "" ? timeframe.period : lvlTf, [na(ta.pivothigh(high, lvlLen, lvlLen)) ? na : (lvlBody ? math.max(open[lvlLen], close[lvlLen]) : ta.pivothigh(high, lvlLen, lvlLen)), na(ta.pivotlow(low, lvlLen, lvlLen)) ? na : (lvlBody ? math.min(open[lvlLen], close[lvlLen]) : ta.pivotlow(low, lvlLen, lvlLen)), na(ta.pivothigh(high, lvlLen, lvlLen)) ? na : time[lvlLen], na(ta.pivotlow(low, lvlLen, lvlLen)) ? na : time[lvlLen]], lookahead = barmerge.lookahead_off, gaps = barmerge.gaps_on)

float phLvl = useHTF ? phLS : phLcL     // level point = wick or body
float plLvl = useHTF ? plLS : plLcL
int   phT   = useHTF ? phST : phLcT
int   plT   = useHTF ? plST : plLcT

// ──────────────────── ZIGZAG (true-extreme state machine) ───────────────────
// One running extreme per direction. An OPPOSITE pivot confirms the turn and commits
// the REAL top/bottom of the finished leg — also catches small swings within a larger
// move (a pivot-high inside a down-leg closes that down-leg).
if zdir == 1 and (na(zext) or high > zext)
    zext  := high
    zextT := time
if zdir == -1 and (na(zext) or low < zext)
    zext  := low
    zextT := time
if barstate.isconfirmed
    if zdir == 0
        // init: first confirmed pivot sets the start point + direction
        if not na(phWick)
            zanchP := phWick
            zanchT := time[lvlLen]
            zdir   := -1
            zext   := low
            zextT  := time
        else if not na(plWick)
            zanchP := plWick
            zanchT := time[lvlLen]
            zdir   := 1
            zext   := high
            zextT  := time
    else if zdir == 1 and not na(plWick) and zextT <= time[lvlLen]
        // up-leg done (pivot LOW confirms, and the top is before that low) → commit, turn down
        if showZig and not na(zanchT) and not na(zextT)
            line s = line.new(zanchT, zanchP, zextT, zext, xloc = xloc.bar_time, color = zigUpCol, width = zigWidth)
            array.push(zlines, s)
            if array.size(zlines) > zigMax
                line.delete(array.shift(zlines))
        zanchP := zext
        zanchT := zextT
        zdir   := -1
        zext   := plWick
        zextT  := time[lvlLen]
    else if zdir == -1 and not na(phWick) and zextT <= time[lvlLen]
        // down-leg done (pivot HIGH confirms, and the bottom is before that high) → commit, turn up
        if showZig and not na(zanchT) and not na(zextT)
            line s = line.new(zanchT, zanchP, zextT, zext, xloc = xloc.bar_time, color = zigDnCol, width = zigWidth)
            array.push(zlines, s)
            if array.size(zlines) > zigMax
                line.delete(array.shift(zlines))
        zanchP := zext
        zanchT := zextT
        zdir   := 1
        zext   := phWick
        zextT  := time[lvlLen]

// ── Tentative leg: last turning point → current running extreme (repaints) ──
if showZig and barstate.islast and not na(zanchT) and not na(zextT)
    color tc = zdir == 1 ? zigUpCol : zigDnCol
    if na(liveLeg)
        liveLeg := line.new(zanchT, zanchP, zextT, zext, xloc = xloc.bar_time, color = tc, width = zigWidth)
    else
        line.set_xy1(liveLeg, zanchT, zanchP)
        line.set_xy2(liveLeg, zextT, zext)
        line.set_color(liveLeg, tc)

// ──────────────────────────────────────── NEW LEVELS ────────────────────────
if showLevels and barstate.isconfirmed
    if not na(phLvl) and not na(phT) and close <= phLvl   // new, fresh resistance (price below)
        array.push(resists, newLvl(phLvl, true, phT))
        if array.size(resists) > maxUntested
            Lvl o = array.shift(resists)
            line.delete(o.ln)
            label.delete(o.lb)
    if not na(plLvl) and not na(plT) and close >= plLvl   // new, fresh support (price above)
        array.push(supports, newLvl(plLvl, false, plT))
        if array.size(supports) > maxUntested
            Lvl o = array.shift(supports)
            line.delete(o.ln)
            label.delete(o.lb)

// ──────────────────────── BREAK DETECTION (close-through) ───────────────────
bool gainedEvent = false   // a resistance was reclaimed this bar (drives alerts)
bool lostEvent   = false   // a support was lost this bar
if showLevels and barstate.isconfirmed
    // resistances breaking UP → Gained
    if array.size(resists) > 0
        for i = array.size(resists) - 1 to 0
            Lvl L = array.get(resists, i)
            if close > L.price
                array.remove(resists, i)
                gainedEvent := true
                alert("TSL Last Gained — resistance " + str.tostring(L.price, format.mintick) + suffix() + " reclaimed @ " + str.tostring(close, format.mintick), alert.freq_once_per_bar)
                if showBroken
                    if not na(gLine)
                        line.delete(gLine)
                    if not na(gLab)
                        label.delete(gLab)
                    line.set_color(L.ln, gainCol)
                    line.set_style(L.ln, styleOf(gainStyleS))
                    line.set_width(L.ln, brokWidth)
                    gLine := L.ln
                    if not na(L.lb)
                        label.set_color(L.lb, color.new(gainCol, 80))
                        label.set_textcolor(L.lb, gainCol)
                        label.set_text(L.lb, (showStruct ? "Last Gained" : str.tostring(L.price, format.mintick)) + suffix())
                        gLab := L.lb
                else
                    line.delete(L.ln)
                    label.delete(L.lb)
            else if markTested and not L.tested and bar_index > L.bornBar and high >= L.price
                L.tested := true
                line.set_style(L.ln, styleOf(testedStyle))   // wick touched the level → tested
    // supports breaking DOWN → Lost
    if array.size(supports) > 0
        for j = array.size(supports) - 1 to 0
            Lvl L = array.get(supports, j)
            if close < L.price
                array.remove(supports, j)
                lostEvent := true
                alert("TSL Last Lost — support " + str.tostring(L.price, format.mintick) + suffix() + " lost @ " + str.tostring(close, format.mintick), alert.freq_once_per_bar)
                if showBroken
                    if not na(lLine)
                        line.delete(lLine)
                    if not na(lLab)
                        label.delete(lLab)
                    line.set_color(L.ln, lostCol)
                    line.set_style(L.ln, styleOf(lostStyleS))
                    line.set_width(L.ln, brokWidth)
                    lLine := L.ln
                    if not na(L.lb)
                        label.set_color(L.lb, color.new(lostCol, 80))
                        label.set_textcolor(L.lb, lostCol)
                        label.set_text(L.lb, (showStruct ? "Last Lost" : str.tostring(L.price, format.mintick)) + suffix())
                        lLab := L.lb
                else
                    line.delete(L.ln)
                    label.delete(L.lb)
            else if markTested and not L.tested and bar_index > L.bornBar and low <= L.price
                L.tested := true
                line.set_style(L.ln, styleOf(testedStyle))   // wick touched the level → tested

// ──────────────────────────────────────── ALERTS ───────────────────────────
// Named conditions → create separate alerts (pick "Last Gained" / "Last Lost" in the
// alert dialog). The dynamic alert() calls above also fire on "Any alert() function call".
alertcondition(gainedEvent, "Last Gained", "TSL Last Gained: resistance reclaimed on {{ticker}} {{interval}}")
alertcondition(lostEvent,   "Last Lost",   "TSL Last Lost: support lost on {{ticker}} {{interval}}")

// ──────────── Keep labels pinned to the right edge (level objects = bar_time) ──
if barstate.islast
    if array.size(resists) > 0
        for k = 0 to array.size(resists) - 1
            Lvl L = array.get(resists, k)
            if not na(L.lb)
                label.set_x(L.lb, time)
            if not extendR
                line.set_x2(L.ln, time)
    if array.size(supports) > 0
        for k = 0 to array.size(supports) - 1
            Lvl L = array.get(supports, k)
            if not na(L.lb)
                label.set_x(L.lb, time)
            if not extendR
                line.set_x2(L.ln, time)
    if not na(gLab)
        label.set_x(gLab, time)
    if not na(lLab)
        label.set_x(lLab, time)
````
