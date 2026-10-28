# S&R Zones + PSY Levels, Pivot & EMA by Lazyhacker

- url: https://www.tradingview.com/script/qbzL331v-S-R-Zones-PSY-Levels-Pivot-EMA-by-Lazyhacker/
- type: indicator
- pine_id: PUB;4f730d8481d341e8b5c8a3d369af03c9
- version: 1.0

## Description

[b]PSY · S&R Zones · Pivot & EMA[/b]

What This Script Does & Why It's One Indicator

This tool is purpose-built for Nifty and BankNifty intraday traders who need a single, clean overlay covering the five most critical price-context layers: psychological levels, dynamic support/resistance zones, previous day levels, EMAs, and pivot points. Each component is chosen because it answers a specific question at the same moment:

[list]
[*]Where are the big round-number magnets? → PSY Levels
[*]Where has price historically reversed and is that zone still valid? → S&R Zones
[*]What are the key reference prices from yesterday? → PDH / PDL / PDC
[*]What is the current momentum structure? → EMA stack
[*]What are the mathematically derived support/resistance targets for today? → Pivot Points + Fibonacci
[/list]

Having these on separate indicators produces cluttered, difficult-to-read charts and requires switching between settings panels. This script integrates them with a unified settings panel and consistent visual design.

[b] How Each Component Works[/b]
[b]S&R Zones (Dynamic, Auto-Flipping)[/b]
Uses ta.pivothigh() and ta.pivotlow() with a configurable lookback period to identify confirmed swing highs and lows. Each pivot is drawn as a price zone (a box) rather than a line, because price rarely reacts to exact levels — zones are more realistic. Two filters prevent noise:

[list]
[*]Zone Width (%): merges nearby pivots so overlapping zones don't clutter the chart.
[*]Min Pivot Strength (%): requires the price to have moved a minimum % away from the pivot, ensuring only significant reversals qualify.
[/list]

Zones automatically flip when price closes through them: a broken support becomes resistance (turns red) and vice versa (turns green). Zones being actively tested turn gray.

🔢 PSY (Psychological) Levels

Draws equidistant horizontal bands at psychologically significant round numbers:

[list]
[*]BankNifty: Major levels at every 500 points, minor at every 250 points.
[*]Nifty: Major levels at every 100 points, minor at every 50 points.
[/list]

The anchor (Base Level) and number of levels above/below are fully configurable. Zone width for each level type is independently adjustable. These levels act as price magnets and are among the most reliable intraday reference points for Indian index derivatives.

📅 Previous Day High / Low / Close (PDH / PDL / PDC)

Fetches the prior session's high, low, and close using request.security() with high[1], low[1], close[1] — properly offset expressions that carry no lookahead bias. These three levels are widely watched by institutional and retail participants and often act as the first intraday support/resistance.

📈 EMA Stack (Chart + Higher Timeframe)


[list]
[*]Chart EMAs: Two EMAs computed directly on the current chart timeframe (default 9 and 15). Used for immediate momentum and crossover signals.
[*]HTF EMAs: Two EMAs computed on a higher timeframe (default 5-minute, configurable). These smooth out lower-timeframe noise and show the broader intraday trend direction. When price is above both HTF EMAs, the bias is long; below both, the bias is short.
[/list]

HTF data uses barmerge.gaps_off without lookahead_on to ensure values only step at each completed HTF bar with no future data leakage.

🌀 Fibonacci Intraday Levels

Tracks the session high and low within a configurable session window (default 09:15–15:30 IST) and draws two intraday Fibonacci retracement levels:

[list]
[*]50%: The midpoint of the day's range — a natural mean-reversion target.
[*]61.8%: The golden ratio retracement — the most widely respected Fibonacci level.
[*]
[/list]

These update dynamically as the day's range expands. They are most useful for identifying pullback entry zones within a trending day.

🔵 Pivot Points

Calculates standard pivot point levels (P, R1–R5, S1–S5) using TradingView's built-in ta.pivot_point_levels(). Supports six calculation methods: Traditional, Fibonacci, Woodie, Classic, DM, and Camarilla. The anchor timeframe auto-selects based on chart timeframe (Daily pivots for intraday, Weekly for daily charts, etc.) but is manually overridable. Up to 5 historical pivot periods can be displayed simultaneously.

The pivot request.security() call uses timeframe.change() as the trigger — a safe offset pattern that prevents lookahead bias on historical bars.

[b]How to Use[/b]

[list=1]
[*]Set your instrument (Nifty or BankNifty) and PSY anchor base level to match current market price range.
[*]On a 1–5 minute chart, all five components will activate with sensible defaults.
[*]Use PSY levels + Pivots as your primary S/R map for the session.
[*]Use S&R Zones to identify zones with historical significance and watch for flip behavior.
[*]Use PDH/PDL/PDC as the first intraday breakout or rejection reference.
[*]Use EMA stack for momentum bias — enter in the direction the chart EMAs are sloping when price is on the correct side of HTF EMAs.
[*]Use Fibonacci levels for intraday pullback targets once the day's range is established (typically after the first 30–60 minutes).
[/list]


[b] Notes[/b]
[list]
[*]Designed primarily for NSE index derivatives (Nifty, BankNifty) on intraday timeframes (1m–15m).
[*]All components are independently toggleable.
[*]No repainting: S&R zones are drawn at confirmed pivot bars (lookback bars in the past); Fibonacci and EMAs are real-time but non-predictive; pivot levels use closed HTF bars only.
[/list]

## Source Code

````pine
//@version=6
indicator("S&R Zones + PSY Levels, Pivot & EMA by Lazyhacker", overlay=true, max_boxes_count=500, max_lines_count=500, max_labels_count=500)

// ============================================================
// SECTION 1: SUPPORT & RESISTANCE ZONES
// ============================================================

// --- S&R Settings ---
lookback       = input.int(15,    title="Pivot Lookback",         minval=5,   maxval=100,  group="⚙️ S&R General")
zonePct        = input.float(0.1, title="Zone Width (%)",         minval=0.05,maxval=1.0,  step=0.05, group="⚙️ S&R General")
maxZones       = input.int(20,    title="Max Zones to Show",      minval=5,   maxval=50,   group="⚙️ S&R General")
filterStrength = input.float(0.2, title="Min Pivot Strength (%)", minval=0.0, maxval=2.0,  step=0.05, group="⚙️ S&R General",
                              tooltip="Minimum % move away from pivot to count as significant. Higher = fewer, stronger zones.")

colorSupport  = input.color(color.new(color.green, 80), title="Support Zone",      group="🎨 S&R Colors")
colorResist   = input.color(color.new(color.red,   80), title="Resistance Zone",   group="🎨 S&R Colors")
colorFlipped  = input.color(color.new(color.gray,  75), title="Flipped Zone",      group="🎨 S&R Colors")
borderSupport = input.color(color.new(color.green, 30), title="Support Border",    group="🎨 S&R Colors")
borderResist  = input.color(color.new(color.red,   30), title="Resistance Border", group="🎨 S&R Colors")

// --- Pivot Detection ---
ph = ta.pivothigh(high, lookback, lookback)
pl = ta.pivotlow(low,   lookback, lookback)

// --- Storage ---
var box[]   drawnBoxes  = array.new<box>()
var float[] drawnLevels = array.new<float>()
var bool[]  drawnIsSup  = array.new<bool>()

// --- Helpers ---
isTooClose(price) =>
    result = false
    n = array.size(drawnLevels)
    if n > 0
        for i = 0 to n - 1
            if math.abs(price - array.get(drawnLevels, i)) < close * zonePct / 100 * 2.0
                result := true
    result

isStrongPivot(price, isSup) =>
    move = isSup ? (close - price) / price * 100 : (price - close) / price * 100
    move >= filterStrength

// --- Draw zone at confirmed pivot bar ---
pivotBarIdx = bar_index - lookback

if not na(ph)
    if not isTooClose(ph) and isStrongPivot(ph, false)
        half = ph * zonePct / 200
        zTop = ph + half
        zBot = ph - half
        b = box.new(
             left         = pivotBarIdx,
             top          = zTop,
             right        = bar_index,
             bottom       = zBot,
             border_color = borderResist,
             border_width  = 1,
             bgcolor       = colorResist,
             extend        = extend.right,
             xloc          = xloc.bar_index)
        array.push(drawnBoxes,  b)
        array.push(drawnLevels, ph)
        array.push(drawnIsSup,  false)

if not na(pl)
    if not isTooClose(pl) and isStrongPivot(pl, true)
        half = pl * zonePct / 200
        zTop = pl + half
        zBot = pl - half
        b = box.new(
             left         = pivotBarIdx,
             top          = zTop,
             right        = bar_index,
             bottom       = zBot,
             border_color = borderSupport,
             border_width  = 1,
             bgcolor       = colorSupport,
             extend        = extend.right,
             xloc          = xloc.bar_index)
        array.push(drawnBoxes,  b)
        array.push(drawnLevels, pl)
        array.push(drawnIsSup,  true)

// --- S/R Flip ---
srCount = array.size(drawnBoxes)
if srCount > 0
    for i = 0 to srCount - 1
        lvl   = array.get(drawnLevels, i)
        isSup = array.get(drawnIsSup,  i)
        b     = array.get(drawnBoxes,  i)
        half  = lvl * zonePct / 200

        isInsideZone = close >= lvl - half and close <= lvl + half
        brokeBelow   = isSup      and close < lvl - half * 3
        brokeAbove   = not isSup  and close > lvl + half * 3

        if isInsideZone
            box.set_bgcolor(b,      colorFlipped)
            box.set_border_color(b, color.gray)
        else if brokeBelow
            array.set(drawnIsSup, i, false)
            box.set_bgcolor(b,      colorResist)
            box.set_border_color(b, borderResist)
        else if brokeAbove
            array.set(drawnIsSup, i, true)
            box.set_bgcolor(b,      colorSupport)
            box.set_border_color(b, borderSupport)

// --- Trim oldest zones beyond maxZones ---
if array.size(drawnBoxes) > maxZones
    box.delete(array.shift(drawnBoxes))
    array.shift(drawnLevels)
    array.shift(drawnIsSup)


// ============================================================
// SECTION 2: PSY LEVELS, PIVOT & EMA
// ============================================================

// ===== Instrument Selection =====
instrument = input.string("Nifty", "Instrument", options=["BankNifty", "Nifty"], group="⚙️ PSY General")
baseLevel  = input.int(23000, "Base Level (PSY Anchor)", group="⚙️ PSY General")
levels     = input.int(10, "Levels Above/Below", minval=1, group="⚙️ PSY General")

// ===== BankNifty Settings =====
bnShow500 = input.bool(true, "Show 500 Levels", group="BankNifty Levels")
bnShow250 = input.bool(true, "Show 250 Levels", group="BankNifty Levels")
bnZone500 = input.int(50,    "Zone Width ± 500", group="BankNifty Levels")
bnZone250 = input.int(10,    "Zone Width ± 250", group="BankNifty Levels")

// ===== Nifty Settings =====
nfShow100 = input.bool(false, "Show 100 Levels", group="Nifty Levels")
nfShow50  = input.bool(false, "Show 50 Levels",  group="Nifty Levels")
nfZone100 = input.int(5,     "Zone Width ± 100", group="Nifty Levels")
nfZone50  = input.int(3,     "Zone Width ± 50",  group="Nifty Levels")

// ===== PSY Level Colors & Opacity =====
majorLineColor   = input.color(color.red,    "Major Level Line Color",    group="PSY Level Appearance")
majorLineOpacity = input.int(20,             "Major Line Opacity (0=solid, 100=transparent)", group="PSY Level Appearance", minval=0, maxval=100)
majorFillColor   = input.color(color.red,    "Major Zone Fill Color",     group="PSY Level Appearance")
majorFillOpacity = input.int(95,             "Major Zone Fill Opacity (0=solid, 100=transparent)", group="PSY Level Appearance", minval=0, maxval=100)

minorLineColor   = input.color(color.orange, "Minor Level Line Color",    group="PSY Level Appearance")
minorLineOpacity = input.int(20,             "Minor Line Opacity (0=solid, 100=transparent)", group="PSY Level Appearance", minval=0, maxval=100)
minorFillColor   = input.color(color.orange, "Minor Zone Fill Color",     group="PSY Level Appearance")
minorFillOpacity = input.int(97,             "Minor Zone Fill Opacity (0=solid, 100=transparent)", group="PSY Level Appearance", minval=0, maxval=100)

// ===== PDH / PDL / PDC =====
showPDH = input.bool(true, "Show PDH (Prev Day High)",  group="Previous Day Levels")
showPDL = input.bool(true, "Show PDL (Prev Day Low)",   group="Previous Day Levels")
showPDC = input.bool(true, "Show PDC (Prev Day Close)", group="Previous Day Levels")

// ===== EMA Chart-Based =====
showCEMA1  = input.bool(true,  "Enable Chart EMA 1", inline="ce1", group="EMA (Chart Based)")
cEma1Len   = input.int(9,      "Length",             inline="ce1", group="EMA (Chart Based)", minval=1)
cEma1Color = input.color(color.new(color.yellow, 0), "Color",      inline="ce1", group="EMA (Chart Based)")
cEma1Width = input.int(2, "Width", options=[1,2,3,4],              inline="ce1", group="EMA (Chart Based)")
showCEMA2  = input.bool(true,  "Enable Chart EMA 2", inline="ce2", group="EMA (Chart Based)")
cEma2Len   = input.int(15,     "Length",             inline="ce2", group="EMA (Chart Based)", minval=1)
cEma2Color = input.color(color.new(color.orange, 0), "Color",      inline="ce2", group="EMA (Chart Based)")
cEma2Width = input.int(2, "Width", options=[1,2,3,4],              inline="ce2", group="EMA (Chart Based)")

// ===== EMA HTF =====
showHTFEMA1  = input.bool(true,  "Enable HTF EMA 1", inline="he1", group="EMA (HTF)")
hEma1Len     = input.int(9,      "Length",           inline="he1", group="EMA (HTF)", minval=1)
hEma1TF      = input.timeframe("5", "Timeframe",     inline="he1", group="EMA (HTF)")
hEma1Color   = input.color(color.new(color.lime, 0), "Color",      inline="he1", group="EMA (HTF)")
hEma1Width   = input.int(2, "Width", options=[1,2,3,4],            inline="he1", group="EMA (HTF)")
showHTFEMA2  = input.bool(true,  "Enable HTF EMA 2", inline="he2", group="EMA (HTF)")
hEma2Len     = input.int(15,     "Length",           inline="he2", group="EMA (HTF)", minval=1)
hEma2TF      = input.timeframe("5", "Timeframe",     inline="he2", group="EMA (HTF)")
hEma2Color   = input.color(color.new(color.aqua, 0), "Color",      inline="he2", group="EMA (HTF)")
hEma2Width   = input.int(2, "Width", options=[1,2,3,4],            inline="he2", group="EMA (HTF)")

// ===== Fibonacci Settings =====
showFib     = input.bool(true,           "Enable Fibonacci Levels", group="Fibonacci Levels")
showFib50   = input.bool(true,           "Show Fib 50%",            group="Fibonacci Levels")
showFib618  = input.bool(true,           "Show Fib 0.618",          group="Fibonacci Levels")
fibSession  = input.session("0915-1530", "Fib Session",             group="Fibonacci Levels")
fib50Color  = input.color(color.orange,  "Fib 50% Color",           group="Fibonacci Levels")
fib618Color = input.color(color.blue,    "Fib 0.618 Color",         group="Fibonacci Levels")

// ===== Pivot Point Settings =====
showPivots       = input.bool(true,            "Enable Pivot Points",   group="Pivot Points")
pivotTypeInput   = input.string("Traditional", "Type",                  group="Pivot Points", options=["Traditional", "Fibonacci", "Woodie", "Classic", "DM", "Camarilla"])
pivotAnchorInput = input.string("Auto",        "Pivots Timeframe",      group="Pivot Points", options=["Auto", "Daily", "Weekly", "Monthly", "Quarterly", "Yearly"])
maxPivotsBack    = input.int(5,               "Number of Pivots Back",  group="Pivot Points", minval=1, maxval=50)
isDailyBased     = input.bool(true,           "Use Daily-based Values", group="Pivot Points")
showPivotLabels  = input.bool(true,           "Show Labels",            group="Pivot Points")
showPivotPrices  = input.bool(true,           "Show Prices",            group="Pivot Points")
pivotLabelPos    = input.string("Left",       "Labels Position",        group="Pivot Points", options=["Left", "Right"])
pivotLineWidth   = input.int(1,               "Line Width",             group="Pivot Points", minval=1, maxval=5)

DEFAULT_PIVOT_COLOR = #FB8C00
pCol  = input.color(DEFAULT_PIVOT_COLOR, "P",  inline="pvP",  group="Pivot Points")
pShow = input.bool(true, "",             inline="pvP",  group="Pivot Points")
r1Col = input.color(DEFAULT_PIVOT_COLOR, "R1", inline="pvR1", group="Pivot Points")
r1Show= input.bool(true, "",             inline="pvR1", group="Pivot Points")
s1Col = input.color(DEFAULT_PIVOT_COLOR, "S1", inline="pvS1", group="Pivot Points")
s1Show= input.bool(true, "",             inline="pvS1", group="Pivot Points")
r2Col = input.color(DEFAULT_PIVOT_COLOR, "R2", inline="pvR2", group="Pivot Points")
r2Show= input.bool(true, "",             inline="pvR2", group="Pivot Points")
s2Col = input.color(DEFAULT_PIVOT_COLOR, "S2", inline="pvS2", group="Pivot Points")
s2Show= input.bool(true, "",             inline="pvS2", group="Pivot Points")
r3Col = input.color(DEFAULT_PIVOT_COLOR, "R3", inline="pvR3", group="Pivot Points")
r3Show= input.bool(true, "",             inline="pvR3", group="Pivot Points")
s3Col = input.color(DEFAULT_PIVOT_COLOR, "S3", inline="pvS3", group="Pivot Points")
s3Show= input.bool(true, "",             inline="pvS3", group="Pivot Points")
r4Col = input.color(DEFAULT_PIVOT_COLOR, "R4", inline="pvR4", group="Pivot Points")
r4Show= input.bool(true, "",             inline="pvR4", group="Pivot Points")
s4Col = input.color(DEFAULT_PIVOT_COLOR, "S4", inline="pvS4", group="Pivot Points")
s4Show= input.bool(true, "",             inline="pvS4", group="Pivot Points")
r5Col = input.color(DEFAULT_PIVOT_COLOR, "R5", inline="pvR5", group="Pivot Points")
r5Show= input.bool(true, "",             inline="pvR5", group="Pivot Points")
s5Col = input.color(DEFAULT_PIVOT_COLOR, "S5", inline="pvS5", group="Pivot Points")
s5Show= input.bool(true, "",             inline="pvS5", group="Pivot Points")

// ===== Resolve PSY settings =====
isBN      = instrument == "BankNifty"
minorStep = isBN ? 250  : 50
showMajor = isBN ? bnShow500 : nfShow100
showMinor = isBN ? bnShow250 : nfShow50
zoneMajor = isBN ? bnZone500 : nfZone100
zoneMinor = isBN ? bnZone250 : nfZone50

// ===== PSY Colors =====
colorMajorLine = color.new(majorLineColor, majorLineOpacity)
fillColorMajor = color.new(majorFillColor, majorFillOpacity)
colorMinorLine = color.new(minorLineColor, minorLineOpacity)
fillColorMinor = color.new(minorFillColor, minorFillOpacity)

// ===== PSY Storage =====
var box[]  levelBoxes = array.new<box>()
var line[] levelLines = array.new<line>()

// ===== PSY Drawing =====
if barstate.islast
    for b in levelBoxes
        box.delete(b)
    array.clear(levelBoxes)
    for ln in levelLines
        line.delete(ln)
    array.clear(levelLines)

    for i = -(levels * 2) to (levels * 2)
        currentLevel = baseLevel + (i * minorStep)
        isMajor      = (i % 2 == 0)
        shouldDraw   = isMajor ? showMajor : showMinor
        drawColor    = isMajor ? colorMajorLine : colorMinorLine
        fillColor    = isMajor ? fillColorMajor : fillColorMinor
        zoneW        = isMajor ? zoneMajor : zoneMinor
        if shouldDraw
            array.push(levelBoxes, box.new(
                 left         = bar_index - 1,
                 top          = currentLevel + zoneW,
                 right        = bar_index,
                 bottom       = currentLevel - zoneW,
                 xloc         = xloc.bar_index,
                 extend       = extend.both,
                 bgcolor      = fillColor,
                 border_width = 0))
            array.push(levelLines, line.new(
                 x1     = bar_index - 1,
                 y1     = currentLevel,
                 x2     = bar_index,
                 y2     = currentLevel,
                 xloc   = xloc.bar_index,
                 extend = extend.both,
                 color  = drawColor,
                 width  = 1))

// ===== PDH / PDL / PDC =====
[prevHigh, prevLow, prevClose] = request.security(syminfo.tickerid, "D", [high[1], low[1], close[1]], lookahead=barmerge.lookahead_on)

// FIX: Renamed vars to avoid reserved keyword conflicts (line/label as prefix).
// Pine v6 parser confuses "lineXxx" / "labelXxx" identifiers near built-in calls.
var pdh_ln  = line.new(na, na, na, na)
var pdl_ln  = line.new(na, na, na, na)
var pdc_ln  = line.new(na, na, na, na)
var pdh_lb  = label.new(na, na, "")
var pdl_lb  = label.new(na, na, "")
var pdc_lb  = label.new(na, na, "")

if barstate.islast
    line.delete(pdh_ln)
    line.delete(pdl_ln)
    line.delete(pdc_ln)
    label.delete(pdh_lb)
    label.delete(pdl_lb)
    label.delete(pdc_lb)
    if showPDH
        pdh_ln := line.new(bar_index - 500, prevHigh, bar_index, prevHigh, extend=extend.right, color=color.new(color.lime, 0), width=2, style=line.style_dashed)
        pdh_lb := label.new(bar_index + 2, prevHigh, "PDH: " + str.tostring(prevHigh), color=color.new(color.lime, 85), textcolor=color.lime, style=label.style_label_left, size=size.small)
    if showPDL
        pdl_ln := line.new(bar_index - 500, prevLow, bar_index, prevLow, extend=extend.right, color=color.new(color.red, 0), width=2, style=line.style_dashed)
        pdl_lb := label.new(bar_index + 2, prevLow, "PDL: " + str.tostring(prevLow), color=color.new(color.red, 85), textcolor=color.red, style=label.style_label_left, size=size.small)
    if showPDC
        pdc_ln := line.new(bar_index - 500, prevClose, bar_index, prevClose, extend=extend.right, color=color.new(color.orange, 0), width=2, style=line.style_dashed)
        pdc_lb := label.new(bar_index + 2, prevClose, "PDC: " + str.tostring(prevClose), color=color.new(color.orange, 85), textcolor=color.orange, style=label.style_label_left, size=size.small)

// ===== EMA Chart Based =====
plot(showCEMA1 ? ta.ema(close, cEma1Len) : na, title="Chart EMA 1", color=cEma1Color, linewidth=cEma1Width)
plot(showCEMA2 ? ta.ema(close, cEma2Len) : na, title="Chart EMA 2", color=cEma2Color, linewidth=cEma2Width)

// ===== EMA HTF =====
hEma1Smooth = request.security(syminfo.tickerid, hEma1TF, ta.ema(close, hEma1Len), gaps=barmerge.gaps_on)
hEma2Smooth = request.security(syminfo.tickerid, hEma2TF, ta.ema(close, hEma2Len), gaps=barmerge.gaps_on)

plot(showHTFEMA1 ? hEma1Smooth : na, title="HTF EMA 1", color=hEma1Color, linewidth=hEma1Width)
plot(showHTFEMA2 ? hEma2Smooth : na, title="HTF EMA 2", color=hEma2Color, linewidth=hEma2Width)

// ===== FIBONACCI LEVELS =====
isNewDay  = ta.change(time("D")) != 0
fibInSess = not na(time(timeframe.period, fibSession + ":1234567"))

var float fibHigh = na
var float fibLow  = na

if isNewDay
    fibHigh := na
    fibLow  := na

if fibInSess
    fibHigh := na(fibHigh) ? high : math.max(fibHigh, high)
    fibLow  := na(fibLow)  ? low  : math.min(fibLow,  low)

fib50Val  = not na(fibHigh) ? (fibHigh + fibLow) / 2              : na
fib618Val = not na(fibHigh) ? fibLow + 0.618 * (fibHigh - fibLow) : na

plot(showFib and showFib50  ? fib50Val  : na, title="Fib 50%",   color=fib50Color,  linewidth=2)
plot(showFib and showFib618 ? fib618Val : na, title="Fib 0.618", color=fib618Color, linewidth=2)

// ===== PIVOT POINTS =====
autoAnchor = timeframe.isintraday ? (timeframe.multiplier <= 15 ? "1D" : "1W") : timeframe.isdaily ? "1M" : "12M"
pivotTF    = pivotAnchorInput == "Auto" ? autoAnchor : pivotAnchorInput == "Daily" ? "1D" : pivotAnchorInput == "Weekly" ? "1W" : pivotAnchorInput == "Monthly" ? "1M" : pivotAnchorInput == "Quarterly" ? "3M" : "12M"

pivotColors = array.from(pCol,  r1Col, s1Col, r2Col, s2Col, r3Col, s3Col, r4Col, s4Col, r5Col, s5Col)
pivotShows  = array.from(pShow, r1Show,s1Show,r2Show,s2Show,r3Show,s3Show,r4Show,s4Show,r5Show,s5Show)
pivotNames  = array.from(" P",  "R1",  "S1",  "R2",  "S2",  "R3",  "S3",  "R4",  "S4",  "R5",  "S5")

pivotTFChange = timeframe.change(pivotTF)

[secPivots, secCounter] = request.security(syminfo.tickerid, pivotTF,[ta.pivot_point_levels(pivotTypeInput, timeframe.change(timeframe.period)), pivotTFChange ? 1 : 0])
pivotPointsArray = isDailyBased ? secPivots : ta.pivot_point_levels(pivotTypeInput, pivotTFChange)

secCounterChange = int(ta.change(secCounter))

var line[]  pvLines  = array.new<line>()
var label[] pvLabels = array.new<label>()

drawPivots(startT) =>
    if showPivots
        for idx = 0 to array.size(pivotPointsArray) - 1
            coord = array.get(pivotPointsArray, idx)
            if not na(coord) and array.get(pivotShows, idx)
                lvlColor = array.get(pivotColors, idx)
                lvlName  = array.get(pivotNames,  idx)
                endT     = startT + timeframe.in_seconds(pivotTF) * 1000
                labelTxt = (showPivotLabels ? lvlName + " " : "") + (showPivotPrices ? "(" + str.tostring(coord, format.mintick) + ")" : "")
                newLn    = line.new(startT, coord, endT, coord, xloc=xloc.bar_time, extend=extend.none, color=lvlColor, width=pivotLineWidth)
                newLb    = label.new(x=pivotLabelPos == "Left" ? startT : endT, y=coord, text=labelTxt, style=pivotLabelPos == "Left" ? label.style_label_right : label.style_label_left, textcolor=lvlColor, color=#00000000, xloc=xloc.bar_time)
                array.push(pvLines,  newLn)
                array.push(pvLabels, newLb)

clearOldPivots() =>
    if array.size(pvLines) > maxPivotsBack * 11
        line.delete(array.shift(pvLines))
        label.delete(array.shift(pvLabels))

if showPivots and (pivotTFChange or (isDailyBased and secCounterChange != 0))
    drawPivots(time)
    clearOldPivots()
````
