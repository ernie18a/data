# Gold Grid 2  Grid, Price Zones, MA and Market Structure

- url: https://www.tradingview.com/script/K5GbOItI/
- type: indicator
- pine_id: PUB;90850201e1514a7bb24daddbff20c9ce
- version: 10.0

## Description

Gold Grid 2 – Grid, Price Zones, MA & Market Structure

Gold Grid 2 is a visual trading indicator designed for XAUUSD/Gold traders who focus on key price levels, market structure, trend direction, and reaction zones.

The main idea behind this script is to automatically visualize important Gold price levels such as 4600, 4625, 4650, 4675, 4700, etc. Many Gold traders pay close attention to these round and quarter levels because they often act as psychological zones where liquidity, stop hunts, rejections, breakouts, retests, or reversals can occur.

The indicator combines multiple analysis tools into one clean chart setup:

Dynamic price grid with customizable spacing
Optional price zones around every level
Two configurable moving averages (EMA or HMA)
CHoCH and BOS market structure detection
Optional support and resistance projection lines
Optional market structure dashboard
Core Idea

Gold often reacts strongly around major price levels like:

xx00
xx25
xx50
xx75

These levels frequently behave as liquidity zones or reaction areas during London and New York sessions.

Instead of manually drawing these levels every day, the script automatically creates a dynamic grid around the current market price.

The optional price zones extend each level into a small area (for example ±5$), helping traders visualize that markets rarely react to an exact line. This can be useful for identifying:

Rejections
Liquidity sweeps
Retests
False breakouts
Reaction zones
Moving Averages

The indicator includes two fully customizable moving averages.

Each MA can independently use:

EMA (Exponential Moving Average)
HMA (Hull Moving Average)

Possible use cases:

Trend filtering
Dynamic support/resistance
Momentum confirmation
Trend direction analysis
MA crossover analysis

Example:

Price above both MAs = bullish market context
Price below both MAs = bearish market context
CHoCH & BOS Market Structure

The script also detects market structure shifts using fractal-based logic.

BOS – Break of Structure

A BOS indicates continuation of the current market structure.

Examples:

Price breaking a previous swing high in an uptrend
Price breaking a previous swing low in a downtrend
CHoCH – Change of Character

A CHoCH indicates a potential shift in market behavior or possible trend reversal.

Examples:

Bearish structure suddenly breaking bullish
Bullish structure suddenly breaking bearish

These structure signals can help traders better understand trend continuation and possible reversals.

How To Use

This indicator is not designed as a standalone buy/sell signal system.
It is intended as a visual market analysis tool.

A possible workflow:

Identify the higher timeframe trend using EMA/HMA
Watch key grid levels and price zones
Wait for rejection, breakout, sweep, or retest reactions
Use CHoCH/BOS as additional confirmation
Plan entries, stop-losses, and take-profits around structure and zones
Best Use Cases

This indicator is especially useful for traders focusing on:

XAUUSD / Gold
Intraday trading
Scalping
London session trading
New York session trading
Liquidity-based trading
Structure-based analysis
Breakout and retest setups
Credits

The CHoCH/BOS calculation and fractal market structure logic used in this script is based on the indicator:

Market Structure CHoCH/BOS (Fractal) [LuxAlgo]

Credits for the original market structure logic and concept go to LuxAlgo.

The structure logic has been integrated and adapted into this custom Gold Grid system together with price zones and moving averages.

Disclaimer

This indicator does not provide financial advice and should not be used as a standalone trading system.
All levels, zones, and structure signals should always be combined with proper risk management, market context, liquidity understanding, and personal analysis.

## Source Code

````pine
//@version=6
indicator("Gold Grid 2.2", overlay=true, max_lines_count=500, max_labels_count=500, max_boxes_count=500)

// ─────────────────────────────
// MAJOR GRID
// ─────────────────────────────

showMajorGrid = input.bool(true, "Show Major Grid", group="Major Grid")
majorStep = input.float(25.0, "Major Grid Spacing ($)", minval=0.01, group="Major Grid")
majorLinesAboveBelow = input.int(50, "Major Lines Above/Below", minval=1, maxval=80, group="Major Grid")
gridLengthBars = input.int(100, "Grid Line Length (Bars)", minval=1, maxval=9999, group="Major Grid")

color00 = input.color(color.new(#ff0000, 20), "00 Level Color", group="Major Grid")
color50 = input.color(color.new(#000000, 35), "50 Level Color", group="Major Grid")
color2575 = input.color(color.new(#000000, 65), "25 / 75 Level Color", group="Major Grid")

width00 = input.int(2, "00 Level Width", minval=1, maxval=5, group="Major Grid")
width50 = input.int(2, "50 Level Width", minval=1, maxval=5, group="Major Grid")
width2575 = input.int(1, "25 / 75 Level Width", minval=1, maxval=5, group="Major Grid")

// ─────────────────────────────
// MINOR GRID
// ─────────────────────────────

showMinorGrid = input.bool(true, "Show Minor Grid", group="Minor Grid")
minorStep = input.float(5.0, "Minor Grid Spacing ($)", minval=0.1, group="Minor Grid")
minorLinesAboveBelow = input.int(80, "Minor Lines Above/Below", minval=1, maxval=200, group="Minor Grid")
minorGridColor = input.color(color.new(color.gray, 88), "Minor Grid Color", group="Minor Grid")
minorGridWidth = input.int(1, "Minor Grid Width", minval=1, maxval=3, group="Minor Grid")

// ─────────────────────────────
// LABELS / ZONES
// ─────────────────────────────

showLabels = input.bool(true, "Show Major Price Labels", group="Labels")
labelOffset = input.int(20, "Label Offset Right", minval=1, maxval=200, group="Labels")
labelColor = input.color(#808080, "Label Background", group="Labels")
labelTextColor = input.color(#ffffff, "Label Text", group="Labels")

showPriceZones = input.bool(true, "Show Major Price Zones", group="Price Zones")
zoneDistance = input.float(5.0, "Price Zone Distance ($)", minval=0.01, group="Price Zones")
zoneColor = input.color(color.new(#6ba583, 88), "Price Zone Color", group="Price Zones")

// ─────────────────────────────
// MOVING AVERAGES
// ─────────────────────────────

showMA1 = input.bool(false, "Show MA 1", group="Moving Averages")
ma1Type = input.string("EMA", "MA 1 Type", options=["EMA", "HMA"], group="Moving Averages")
ma1Length = input.int(50, "MA 1 Length", minval=1, group="Moving Averages")
ma1Color = input.color(color.aqua, "MA 1 Color", group="Moving Averages")

showMA2 = input.bool(false, "Show MA 2", group="Moving Averages")
ma2Type = input.string("EMA", "MA 2 Type", options=["EMA", "HMA"], group="Moving Averages")
ma2Length = input.int(200, "MA 2 Length", minval=1, group="Moving Averages")
ma2Color = input.color(color.fuchsia, "MA 2 Color", group="Moving Averages")

maWidth = input.int(2, "MA Width", minval=1, maxval=5, group="Moving Averages")

// ─────────────────────────────
// CHOCH / BOS SETTINGS
// ─────────────────────────────

showStructure = input.bool(true, "Show CHoCH / BOS", group="CHoCH / BOS")
structureLength = input.int(5, "Fractal Length", minval=3, step=2, group="CHoCH / BOS")

showBull = input.bool(true, "Bullish Structures", inline="bull", group="CHoCH / BOS")
bullCss = input.color(#089981, "", inline="bull", group="CHoCH / BOS")

showBear = input.bool(true, "Bearish Structures", inline="bear", group="CHoCH / BOS")
bearCss = input.color(#f23645, "", inline="bear", group="CHoCH / BOS")

showSupport = input.bool(false, "Support", inline="s", group="CHoCH / BOS")
supCss = input.color(#089981, "", inline="s", group="CHoCH / BOS")

showResistance = input.bool(false, "Resistance", inline="r", group="CHoCH / BOS")
resCss = input.color(#f23645, "", inline="r", group="CHoCH / BOS")

showFractals = input.bool(false, "Debug: Show Fractals", group="CHoCH / BOS")

// ─────────────────────────────
// FUNCTIONS
// ─────────────────────────────

getMA(src, length, maType) =>
    maType == "EMA" ? ta.ema(src, length) : ta.hma(src, length)

getLevelMod(level) =>
    math.round(math.abs(level % 100))

getMajorColor(level) =>
    mod100 = getLevelMod(level)
    mod100 == 0 ? color00 : mod100 == 50 ? color50 : color2575

getMajorWidth(level) =>
    mod100 = getLevelMod(level)
    mod100 == 0 ? width00 : mod100 == 50 ? width50 : width2575

isSameAsMajor(level) =>
    rounded = math.round(level / majorStep) * majorStep
    math.abs(level - rounded) <= syminfo.mintick

// ─────────────────────────────
// MOVING AVERAGES
// ─────────────────────────────

ma1 = getMA(close, ma1Length, ma1Type)
ma2 = getMA(close, ma2Length, ma2Type)

plot(showMA1 ? ma1 : na, "MA 1", ma1Color, maWidth)
plot(showMA2 ? ma2 : na, "MA 2", ma2Color, maWidth)

// ─────────────────────────────
// GRID ARRAYS
// ─────────────────────────────

var line[] gridLines = array.new_line()
var label[] gridLabels = array.new_label()
var box[] priceZones = array.new_box()

// ─────────────────────────────
// DRAW GRID
// ─────────────────────────────

if barstate.islast

    for l in gridLines
        line.delete(l)
    array.clear(gridLines)

    for lb in gridLabels
        label.delete(lb)
    array.clear(gridLabels)

    for bz in priceZones
        box.delete(bz)
    array.clear(priceZones)

    // Gemeinsame X-Koordinaten
    // Einstellbare Grid-Länge mit Schutz vor negativem bar_index
    gridLeftX  = math.max(0, bar_index - gridLengthBars)
    labelX     = bar_index + labelOffset
    gridRightX = labelX

    // ─────────────────────────────
    // MINOR GRID
    // ─────────────────────────────

    if showMinorGrid
        minorBase = math.round(close / minorStep) * minorStep

        for i = -minorLinesAboveBelow to minorLinesAboveBelow
            level = minorBase + i * minorStep

            if not isSameAsMajor(level)
                ln = line.new(
                     gridLeftX,
                     level,
                     gridRightX,
                     level,
                     extend=extend.none,
                     color=minorGridColor,
                     width=minorGridWidth,
                     style=line.style_dotted
                 )

                array.push(gridLines, ln)

    // ─────────────────────────────
    // MAJOR GRID + ZONES + LABELS
    // ─────────────────────────────

    if showMajorGrid
        majorBase = math.round(close / majorStep) * majorStep

        for i = -majorLinesAboveBelow to majorLinesAboveBelow
            level = majorBase + i * majorStep

            lvlColor = getMajorColor(level)
            lvlWidth = getMajorWidth(level)

            if showPriceZones
                bz = box.new(
                     left=gridLeftX,
                     top=level + zoneDistance,
                     right=gridRightX,
                     bottom=level - zoneDistance,
                     bgcolor=zoneColor,
                     border_color=color.new(zoneColor, 100)
                 )

                array.push(priceZones, bz)

            ln = line.new(
                 gridLeftX,
                 level,
                 gridRightX,
                 level,
                 extend=extend.none,
                 color=lvlColor,
                 width=lvlWidth,
                 style=line.style_solid
             )

            array.push(gridLines, ln)

            if showLabels
                lb = label.new(
                     labelX,
                     level,
                     str.tostring(level, format.mintick),
                     style=label.style_label_left,
                     textcolor=labelTextColor,
                     color=labelColor,
                     size=size.small
                 )

                array.push(gridLabels, lb)

// ─────────────────────────────
// CHOCH / BOS LOGIC
// ─────────────────────────────

type fractal
    float value
    int loc
    bool iscrossed

p = int(structureLength / 2)
n = bar_index

dh = math.sum(math.sign(high - high[1]), p)
dl = math.sum(math.sign(low - low[1]), p)

highestStructure = ta.highest(high, structureLength)
lowestStructure = ta.lowest(low, structureLength)

bullf = not na(high[p]) and dh == -p and dh[p] == p and high[p] >= highestStructure
bearf = not na(low[p]) and dl == p and dl[p] == -p and low[p] <= lowestStructure

plotshape(showFractals and bullf, "Bullish Fractal", shape.triangledown, location.abovebar, bullCss, offset=-p, size=size.tiny)
plotshape(showFractals and bearf, "Bearish Fractal", shape.triangleup, location.belowbar, bearCss, offset=-p, size=size.tiny)

var upper = fractal.new(na, na, false)
var lower = fractal.new(na, na, false)

var line lower_lvl = na
var line upper_lvl = na

var bool broken_sup = false
var bool broken_res = false

var int os = 0

if bullf
    upper.value := high[p]
    upper.loc := n - p
    upper.iscrossed := false

if showStructure and not na(upper.value) and ta.crossover(close, upper.value) and not upper.iscrossed

    if showBull
        line.new(upper.loc, upper.value, n, upper.value, color=bullCss, width=1)

        label.new(
             int(math.avg(n, upper.loc)),
             upper.value,
             os == -1 ? "CHoCH" : "BOS",
             color=color.new(color.black, 100),
             textcolor=bullCss,
             style=label.style_label_down,
             size=size.tiny
         )

    barsBack = math.max(2, n - upper.loc)
    k = 2
    minLevel = low[1]

    for i = 2 to barsBack - 1
        minLevel := math.min(low[i], minLevel)
        k := low[i] == minLevel ? i : k

    if showSupport
        lower_lvl := line.new(n - k, minLevel, n, minLevel, color=supCss, style=line.style_dashed)
        broken_sup := false

    upper.iscrossed := true
    os := 1

else if showStructure and showSupport and not broken_sup and not na(lower_lvl)

    lower_lvl.set_x2(n)

    if close < lower_lvl.get_y2()
        broken_sup := true

if bearf
    lower.value := low[p]
    lower.loc := n - p
    lower.iscrossed := false

if showStructure and not na(lower.value) and ta.crossunder(close, lower.value) and not lower.iscrossed

    if showBear
        line.new(lower.loc, lower.value, n, lower.value, color=bearCss, width=1)

        label.new(
             int(math.avg(n, lower.loc)),
             lower.value,
             os == 1 ? "CHoCH" : "BOS",
             color=color.new(color.black, 100),
             textcolor=bearCss,
             style=label.style_label_up,
             size=size.tiny
         )

    barsBack = math.max(2, n - lower.loc)
    k = 2
    maxLevel = high[1]

    for i = 2 to barsBack - 1
        maxLevel := math.max(high[i], maxLevel)
        k := high[i] == maxLevel ? i : k

    if showResistance
        upper_lvl := line.new(n - k, maxLevel, n, maxLevel, color=resCss, style=line.style_dashed)
        broken_res := false

    lower.iscrossed := true
    os := -1

else if showStructure and showResistance and not broken_res and not na(upper_lvl)

    upper_lvl.set_x2(n)

    if close > upper_lvl.get_y2()
        broken_res := true

// ─────────────────────────────
// SUPPORT / RESISTANCE BREAKOUT MARKERS
// ─────────────────────────────

plot(showStructure and broken_res and not broken_res[1] ? low : na, "Resistance Breakout", #089981, 2, plot.style_circles)
plot(showStructure and broken_sup and not broken_sup[1] ? high : na, "Support Breakout", #f23645, 2, plot.style_circles)
````
