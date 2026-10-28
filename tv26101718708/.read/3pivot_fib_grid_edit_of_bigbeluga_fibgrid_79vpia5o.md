# 3-Pivot Fib Grid, edit of BigBeluga 'FibGrid'

- url: https://www.tradingview.com/script/79vpia5O-3-Pivot-Fib-Grid-edit-of-BigBeluga-FibGrid/
- type: indicator
- pine_id: PUB;b34e0c738344412db805ef43782cee3a
- version: 1.0

## Description

With max flex inputs for styling, testing, and Market Conditions, with help from K2.6

## Source Code

````pine
//@version=6
indicator("3-Pivot Fib Grid [T3/MA Pivot Origin] v6", "3PivGrid T3 v6", overlay=true, max_lines_count=500)

// ═══════════════════════════════════════════════════════════════
// MAXFLEX MA INPUTS
// ═══════════════════════════════════════════════════════════════

grpMA = "TREND MA — PIVOT FILTER / MA PIVOT SOURCE"
maType = input.string("T3", "MA Type", options=["SMA","EMA","WMA","VWMA","HMA","ALMA","T3"], group=grpMA)
maLen  = input.int(55, "MA Length", minval=5, maxval=500, group=grpMA)
showMA = input.bool(true, "Show Trend MA on Chart?", group=grpMA)

// Smoothing layer
smoothMA = input.bool(false, "Smooth the MA Output?", group=grpMA, tooltip="ON = applies a secondary smoothing pass to the selected MA. Good for reducing noise on HMA/T3.")
smoothType = input.string("EMA", "Smoothing Type", options=["SMA","EMA","WMA","VWMA"], group=grpMA)
smoothLen = input.int(5, "Smoothing Length", minval=2, maxval=50, group=grpMA)

// MA-specific params
t3Vol  = input.float(0.7, "T3 Volume Factor", minval=0.1, maxval=10.0, step=0.1, group=grpMA)
almaOff = input.float(0.85, "ALMA Offset", minval=0.0, maxval=1.0, step=0.05, group=grpMA)
almaSig = input.float(6.0, "ALMA Sigma", minval=1.0, maxval=50.0, step=1.0, group=grpMA)

// ═══════════════════════════════════════════════════════════════
// PIVOT INPUTS
// ═══════════════════════════════════════════════════════════════

grpPivot = "PIVOT DETECTION"
pivotMode = input.string("Trend MA Pivots", "Pivot Detection Source", options=["Price Pivots", "Trend MA Pivots"], group=grpPivot, tooltip="Trend MA Pivots makes the grid/fan originate from T3/MA pivot turns instead of raw price pivots.")
pivLen = input.int(5, "Pivot Length", minval=2, group=grpPivot)
pivSrc = input.string("Low/High", "Price Pivot Source", options=["Low/High", "Close"], group=grpPivot)
useMATrendFilter = input.bool(false, "Price Pivots Only: Filter By MA Direction?", group=grpPivot, tooltip="Only applies when Pivot Detection Source = Price Pivots. MA pivots are already selected from the MA itself.")
originSrc = input.string("Pivot Source Value", "Fan Origin Point", options=["Pivot Source Value","Trend MA","Wick Low","Wick High","Body Low","Body High","Body Mid"], group=grpPivot, tooltip="Pivot Source Value uses the actual value returned by the pivot detector. For Trend MA Pivots, this is the T3/MA pivot y-value, which aligns the fan with the MA dot.")

// ═══════════════════════════════════════════════════════════════
// GRID SETTINGS
// ═══════════════════════════════════════════════════════════════

grpGrid = "GRID SETTINGS"
gridLevels = input.int(8, "Fib Levels Per Pivot", minval=3, maxval=13, group=grpGrid)
maxFansOnChart = input.int(5, "Max Fans On Chart", minval=1, maxval=5, group=grpGrid)
gridExtend = input.int(100, "Grid Projection Bars", minval=5, maxval=500, group=grpGrid, tooltip="Controls the fan slope. If Extend Right is ON, the lines continue beyond this projection.")
gridExtendRight = input.bool(true, "Extend Fib Lines Right Through Next Wave?", group=grpGrid)
freezeAtrAtPivot = input.bool(true, "Freeze Grid ATR At Pivot?", group=grpGrid, tooltip="ON = each fan keeps the ATR value from its origin pivot bar. This stops old fans from changing slope as current ATR changes.")
gridAtrLen = input.int(14, "Grid ATR Length", group=grpGrid)
gridAtrMult = input.float(1.0, "Grid ATR Multiplier", step=0.1, group=grpGrid)

// ═══════════════════════════════════════════════════════════════
// VISUALS
// ═══════════════════════════════════════════════════════════════

grpVis = "VISIBILITY"
showBullGrid = input.bool(true, "Show Bull Grid From MA/Pivot Lows?", group=grpVis)
showBearGrid = input.bool(true, "Show Bear Grid From MA/Pivot Highs?", group=grpVis)
showConfluence = input.bool(true, "Highlight Grid Confluence Zones?", group=grpVis)
showPivotDots = input.bool(true, "Show Pivot Markers?", group=grpVis)
bullCol = input.color(color.new(color.lime, 5), "Bull Grid Color", group=grpVis)
bearCol = input.color(color.new(color.orange, 5), "Bear Grid Color", group=grpVis)
confCol = input.color(color.new(color.yellow, 65), "Confluence Color", group=grpVis)
pivotBullCol = input.color(color.new(color.lime, 0), "Pivot Low Marker Color", group=grpVis)
pivotBearCol = input.color(color.new(color.orange, 0), "Pivot High Marker Color", group=grpVis)
maCol = input.color(color.new(color.teal, 0), "Trend MA Color", group=grpVis)

// ═══════════════════════════════════════════════════════════════
// MAXFLEX FAN STYLE INPUTS
// Each fan slot has independent bull color, bear color, width, and line type.
// Fan 1 = newest pivot fan. Fan 5 = oldest displayed pivot fan.
// ═══════════════════════════════════════════════════════════════

grpFan1 = "FAN 1 STYLE — NEWEST"
fan1BullCol = input.color(color.new(color.lime, 5), "Fan 1 Bull Color", group=grpFan1)
fan1BearCol = input.color(color.new(color.orange, 5), "Fan 1 Bear Color", group=grpFan1)
fan1Width = input.int(2, "Fan 1 Width", minval=1, maxval=5, group=grpFan1)
fan1StyleIn = input.string("Solid", "Fan 1 Line Type", options=["Solid","Dashed","Dotted"], group=grpFan1)

grpFan2 = "FAN 2 STYLE"
fan2BullCol = input.color(color.new(color.lime, 20), "Fan 2 Bull Color", group=grpFan2)
fan2BearCol = input.color(color.new(color.orange, 20), "Fan 2 Bear Color", group=grpFan2)
fan2Width = input.int(2, "Fan 2 Width", minval=1, maxval=5, group=grpFan2)
fan2StyleIn = input.string("Solid", "Fan 2 Line Type", options=["Solid","Dashed","Dotted"], group=grpFan2)

grpFan3 = "FAN 3 STYLE"
fan3BullCol = input.color(color.new(color.lime, 35), "Fan 3 Bull Color", group=grpFan3)
fan3BearCol = input.color(color.new(color.orange, 35), "Fan 3 Bear Color", group=grpFan3)
fan3Width = input.int(2, "Fan 3 Width", minval=1, maxval=5, group=grpFan3)
fan3StyleIn = input.string("Dashed", "Fan 3 Line Type", options=["Solid","Dashed","Dotted"], group=grpFan3)

grpFan4 = "FAN 4 STYLE"
fan4BullCol = input.color(color.new(color.lime, 50), "Fan 4 Bull Color", group=grpFan4)
fan4BearCol = input.color(color.new(color.orange, 50), "Fan 4 Bear Color", group=grpFan4)
fan4Width = input.int(1, "Fan 4 Width", minval=1, maxval=5, group=grpFan4)
fan4StyleIn = input.string("Dashed", "Fan 4 Line Type", options=["Solid","Dashed","Dotted"], group=grpFan4)

grpFan5 = "FAN 5 STYLE — OLDEST"
fan5BullCol = input.color(color.new(color.lime, 65), "Fan 5 Bull Color", group=grpFan5)
fan5BearCol = input.color(color.new(color.orange, 65), "Fan 5 Bear Color", group=grpFan5)
fan5Width = input.int(1, "Fan 5 Width", minval=1, maxval=5, group=grpFan5)
fan5StyleIn = input.string("Dotted", "Fan 5 Line Type", options=["Solid","Dashed","Dotted"], group=grpFan5)

// ═══════════════════════════════════════════════════════════════
// BODY CALCULATIONS
// ═══════════════════════════════════════════════════════════════

bodyHigh = math.max(open, close)
bodyLow  = math.min(open, close)
bodyMid  = (bodyHigh + bodyLow) / 2.0

// ═══════════════════════════════════════════════════════════════
// MAXFLEX MA CALCULATOR + SMOOTHING
// ═══════════════════════════════════════════════════════════════

f_t3(_src, _len, _v) =>
    float e1 = ta.ema(_src, _len)
    float e2 = ta.ema(e1, _len)
    float e3 = ta.ema(e2, _len)
    float e4 = ta.ema(e3, _len)
    float e5 = ta.ema(e4, _len)
    float e6 = ta.ema(e5, _len)
    float a = _v
    float c1 = -a * a * a
    float c2 = 3 * a * a + 3 * a * a * a
    float c3 = -6 * a * a - 3 * a - 3 * a * a * a
    float c4 = 1 + 3 * a + a * a * a + 3 * a * a
    c1 * e6 + c2 * e5 + c3 * e4 + c4 * e3

f_ma(_src, _len, _type) =>
    float result = na
    if _type == "SMA"
        result := ta.sma(_src, _len)
    else if _type == "EMA"
        result := ta.ema(_src, _len)
    else if _type == "WMA"
        result := ta.wma(_src, _len)
    else if _type == "VWMA"
        result := ta.vwma(_src, _len)
    else if _type == "HMA"
        result := ta.hma(_src, _len)
    else if _type == "ALMA"
        result := ta.alma(_src, _len, almaOff, almaSig)
    else if _type == "T3"
        result := f_t3(_src, _len, t3Vol)
    result

f_smooth(_src, _len, _type) =>
    float result = na
    if _type == "SMA"
        result := ta.sma(_src, _len)
    else if _type == "EMA"
        result := ta.ema(_src, _len)
    else if _type == "WMA"
        result := ta.wma(_src, _len)
    else if _type == "VWMA"
        result := ta.vwma(_src, _len)
    result

rawMA = f_ma(close, maLen, maType)
trendMA = smoothMA ? f_smooth(rawMA, smoothLen, smoothType) : rawMA
trendUp = close > trendMA
trendDn = close < trendMA

// ═══════════════════════════════════════════════════════════════
// FIBONACCI SEQUENCE — PRECOMPUTED ARRAY
// ═══════════════════════════════════════════════════════════════

f_fibSeq(_idx) =>
    float seq = 0.0
    if _idx == 0
        seq := 0
    else if _idx == 1 or _idx == 2
        seq := 1
    else
        float a = 0.0
        float b = 1.0
        for i = 2 to _idx
            float c = a + b
            a := b
            b := c
        seq := b
    seq

var float[] fibArray = array.new_float(13, 0.0)
if bar_index == 0
    for i = 0 to 12
        array.set(fibArray, i, f_fibSeq(i))

f_lineStyle(_style) =>
    _style == "Solid" ? line.style_solid : _style == "Dashed" ? line.style_dashed : line.style_dotted

f_fanColor(_isBull, _slot) =>
    color result = na
    if _slot == 1
        result := _isBull ? fan1BullCol : fan1BearCol
    else if _slot == 2
        result := _isBull ? fan2BullCol : fan2BearCol
    else if _slot == 3
        result := _isBull ? fan3BullCol : fan3BearCol
    else if _slot == 4
        result := _isBull ? fan4BullCol : fan4BearCol
    else
        result := _isBull ? fan5BullCol : fan5BearCol
    result

f_fanWidth(_slot) =>
    int result = fan1Width
    if _slot == 2
        result := fan2Width
    else if _slot == 3
        result := fan3Width
    else if _slot == 4
        result := fan4Width
    else if _slot == 5
        result := fan5Width
    result

f_fanStyle(_slot) =>
    string styleIn = fan1StyleIn
    if _slot == 2
        styleIn := fan2StyleIn
    else if _slot == 3
        styleIn := fan3StyleIn
    else if _slot == 4
        styleIn := fan4StyleIn
    else if _slot == 5
        styleIn := fan5StyleIn
    f_lineStyle(styleIn)

// ═══════════════════════════════════════════════════════════════
// PIVOT DETECTION — PRICE OR TREND MA
// ═══════════════════════════════════════════════════════════════

priceLowSrc = pivSrc == "Low/High" ? low : close
priceHighSrc = pivSrc == "Low/High" ? high : close

pivotLowSeries = pivotMode == "Trend MA Pivots" ? trendMA : priceLowSrc
pivotHighSeries = pivotMode == "Trend MA Pivots" ? trendMA : priceHighSrc

ph = ta.pivothigh(pivotHighSeries, pivLen, pivLen)
pl = ta.pivotlow(pivotLowSeries, pivLen, pivLen)

int pivOffset = pivLen

newBullPivot = not na(pl)
newBearPivot = not na(ph)

// MA trend filter is only useful for price pivots.
// If using Trend MA Pivots, do not block the MA pivot with another MA direction filter.
bullPivotValid = newBullPivot and (pivotMode == "Trend MA Pivots" or not useMATrendFilter or trendUp)
bearPivotValid = newBearPivot and (pivotMode == "Trend MA Pivots" or not useMATrendFilter or trendDn)

// Origin price helper.
f_originPrice(_pivotValue) =>
    float result = na
    if originSrc == "Pivot Source Value"
        result := _pivotValue
    else if originSrc == "Trend MA"
        result := trendMA[pivOffset]
    else if originSrc == "Wick Low"
        result := low[pivOffset]
    else if originSrc == "Wick High"
        result := high[pivOffset]
    else if originSrc == "Body Low"
        result := bodyLow[pivOffset]
    else if originSrc == "Body High"
        result := bodyHigh[pivOffset]
    else
        result := bodyMid[pivOffset]
    result

// ═══════════════════════════════════════════════════════════════
// SEPARATE BULL / BEAR PIVOT STORAGE
// ═══════════════════════════════════════════════════════════════

var float b1_price = na
var float b2_price = na
var float b3_price = na
var float b4_price = na
var float b5_price = na
var float b1_atr = na
var float b2_atr = na
var float b3_atr = na
var float b4_atr = na
var float b5_atr = na
var int b1_bar = na
var int b2_bar = na
var int b3_bar = na
var int b4_bar = na
var int b5_bar = na

var float r1_price = na
var float r2_price = na
var float r3_price = na
var float r4_price = na
var float r5_price = na
var float r1_atr = na
var float r2_atr = na
var float r3_atr = na
var float r4_atr = na
var float r5_atr = na
var int r1_bar = na
var int r2_bar = na
var int r3_bar = na
var int r4_bar = na
var int r5_bar = na

gridAtrNow = ta.atr(gridAtrLen) * gridAtrMult

bullOriginNow = bullPivotValid ? f_originPrice(pl) : na
bearOriginNow = bearPivotValid ? f_originPrice(ph) : na
pivotAtrNow = gridAtrNow[pivOffset]

if bullPivotValid
    b5_price := b4_price
    b5_bar   := b4_bar
    b5_atr   := b4_atr
    b4_price := b3_price
    b4_bar   := b3_bar
    b4_atr   := b3_atr
    b3_price := b2_price
    b3_bar   := b2_bar
    b3_atr   := b2_atr
    b2_price := b1_price
    b2_bar   := b1_bar
    b2_atr   := b1_atr
    b1_price := bullOriginNow
    b1_bar   := bar_index - pivOffset
    b1_atr   := pivotAtrNow

if bearPivotValid
    r5_price := r4_price
    r5_bar   := r4_bar
    r5_atr   := r4_atr
    r4_price := r3_price
    r4_bar   := r3_bar
    r4_atr   := r3_atr
    r3_price := r2_price
    r3_bar   := r2_bar
    r3_atr   := r2_atr
    r2_price := r1_price
    r2_bar   := r1_bar
    r2_atr   := r1_atr
    r1_price := bearOriginNow
    r1_bar   := bar_index - pivOffset
    r1_atr   := pivotAtrNow

// ═══════════════════════════════════════════════════════════════
// GRID LINE ARRAYS
// ═══════════════════════════════════════════════════════════════

var line[] bullGrid1Lines = array.new_line(gridLevels, na)
var line[] bullGrid2Lines = array.new_line(gridLevels, na)
var line[] bullGrid3Lines = array.new_line(gridLevels, na)
var line[] bullGrid4Lines = array.new_line(gridLevels, na)
var line[] bullGrid5Lines = array.new_line(gridLevels, na)

var line[] bearGrid1Lines = array.new_line(gridLevels, na)
var line[] bearGrid2Lines = array.new_line(gridLevels, na)
var line[] bearGrid3Lines = array.new_line(gridLevels, na)
var line[] bearGrid4Lines = array.new_line(gridLevels, na)
var line[] bearGrid5Lines = array.new_line(gridLevels, na)

// ═══════════════════════════════════════════════════════════════
// GRID DRAWING FUNCTION
// ═══════════════════════════════════════════════════════════════

f_drawGrid(_p_price, _p_bar, _gridNum, _isBull, _atr) =>
    if not na(_p_price) and not na(_p_bar) and not na(_atr)
        color col = f_fanColor(_isBull, _gridNum)
        int fanWidth = f_fanWidth(_gridNum)
        fanStyle = f_fanStyle(_gridNum)
        line[] targetArray = _isBull ? (_gridNum == 1 ? bullGrid1Lines : _gridNum == 2 ? bullGrid2Lines : _gridNum == 3 ? bullGrid3Lines : _gridNum == 4 ? bullGrid4Lines : bullGrid5Lines) : (_gridNum == 1 ? bearGrid1Lines : _gridNum == 2 ? bearGrid2Lines : _gridNum == 3 ? bearGrid3Lines : _gridNum == 4 ? bearGrid4Lines : bearGrid5Lines)
        line_extend = gridExtendRight ? extend.right : extend.none
        for i = 0 to gridLevels - 1
            float fib = array.get(fibArray, i)
            int x1 = _p_bar
            float y1 = _p_price
            int x2 = _p_bar + gridExtend
            float y2 = _isBull ? _p_price + _atr * fib : _p_price - _atr * fib
            line target = array.get(targetArray, i)
            if na(target)
                target := line.new(x1, y1, x2, y2, color=col, width=fanWidth, style=fanStyle, extend=line_extend)
                array.set(targetArray, i, target)
            else
                line.set_xy1(target, x1, y1)
                line.set_xy2(target, x2, y2)
                line.set_color(target, col)
                line.set_width(target, fanWidth)
                line.set_style(target, fanStyle)
                line.set_extend(target, line_extend)

// ═══════════════════════════════════════════════════════════════
// DRAW GRIDS
// ═══════════════════════════════════════════════════════════════

if showBullGrid
    if maxFansOnChart >= 1
        f_drawGrid(b1_price, b1_bar, 1, true, freezeAtrAtPivot ? b1_atr : gridAtrNow)
    if maxFansOnChart >= 2
        f_drawGrid(b2_price, b2_bar, 2, true, freezeAtrAtPivot ? b2_atr : gridAtrNow)
    if maxFansOnChart >= 3
        f_drawGrid(b3_price, b3_bar, 3, true, freezeAtrAtPivot ? b3_atr : gridAtrNow)
    if maxFansOnChart >= 4
        f_drawGrid(b4_price, b4_bar, 4, true, freezeAtrAtPivot ? b4_atr : gridAtrNow)
    if maxFansOnChart >= 5
        f_drawGrid(b5_price, b5_bar, 5, true, freezeAtrAtPivot ? b5_atr : gridAtrNow)

if showBearGrid
    if maxFansOnChart >= 1
        f_drawGrid(r1_price, r1_bar, 1, false, freezeAtrAtPivot ? r1_atr : gridAtrNow)
    if maxFansOnChart >= 2
        f_drawGrid(r2_price, r2_bar, 2, false, freezeAtrAtPivot ? r2_atr : gridAtrNow)
    if maxFansOnChart >= 3
        f_drawGrid(r3_price, r3_bar, 3, false, freezeAtrAtPivot ? r3_atr : gridAtrNow)
    if maxFansOnChart >= 4
        f_drawGrid(r4_price, r4_bar, 4, false, freezeAtrAtPivot ? r4_atr : gridAtrNow)
    if maxFansOnChart >= 5
        f_drawGrid(r5_price, r5_bar, 5, false, freezeAtrAtPivot ? r5_atr : gridAtrNow)

// ═══════════════════════════════════════════════════════════════
// PIVOT MARKERS
// ═══════════════════════════════════════════════════════════════

plotshape(showPivotDots and bullPivotValid ? bullOriginNow : na, "Selected Bull Origin", shape.triangleup, location.absolute, pivotBullCol, size=size.small, offset=-pivOffset)
plotshape(showPivotDots and bearPivotValid ? bearOriginNow : na, "Selected Bear Origin", shape.triangledown, location.absolute, pivotBearCol, size=size.small, offset=-pivOffset)

// ═══════════════════════════════════════════════════════════════
// MA PLOT
// ═══════════════════════════════════════════════════════════════

plot(showMA ? trendMA : na, "Trend MA", color=maCol, linewidth=2)

// ═══════════════════════════════════════════════════════════════
// SIMPLE GRID CONFLUENCE
// ═══════════════════════════════════════════════════════════════

bool inBullConf = false
bool inBearConf = false

float bAtr1 = freezeAtrAtPivot ? b1_atr : gridAtrNow
float bAtr2 = freezeAtrAtPivot ? b2_atr : gridAtrNow
float rAtr1 = freezeAtrAtPivot ? r1_atr : gridAtrNow
float rAtr2 = freezeAtrAtPivot ? r2_atr : gridAtrNow

if showConfluence and showBullGrid
    for i = 0 to gridLevels - 1
        fib_i = f_fibSeq(i)
        level1 = not na(b1_price) and not na(bAtr1) ? b1_price + bAtr1 * fib_i : na
        level2 = not na(b2_price) and not na(bAtr2) ? b2_price + bAtr2 * fib_i : na
        if not na(level1) and not na(level2)
            upper = math.max(level1, level2)
            lower = math.min(level1, level2)
            gap = upper - lower
            if close >= lower and close <= upper and gap <= gridAtrNow * 0.5
                inBullConf := true

if showConfluence and showBearGrid
    for i = 0 to gridLevels - 1
        fib_i = f_fibSeq(i)
        level1 = not na(r1_price) and not na(rAtr1) ? r1_price - rAtr1 * fib_i : na
        level2 = not na(r2_price) and not na(rAtr2) ? r2_price - rAtr2 * fib_i : na
        if not na(level1) and not na(level2)
            upper = math.max(level1, level2)
            lower = math.min(level1, level2)
            gap = upper - lower
            if close >= lower and close <= upper and gap <= gridAtrNow * 0.5
                inBearConf := true

bgcolor(showConfluence and (inBullConf or inBearConf) ? confCol : na, title="Grid Confluence")

// ═══════════════════════════════════════════════════════════════
// DEBUG / DATA WINDOW
// ═══════════════════════════════════════════════════════════════

plot(na(b1_price) ? na : 1, "Bull P1 Valid", display=display.data_window)
plot(na(b2_price) ? na : 1, "Bull P2 Valid", display=display.data_window)
plot(na(b3_price) ? na : 1, "Bull P3 Valid", display=display.data_window)
plot(na(b4_price) ? na : 1, "Bull P4 Valid", display=display.data_window)
plot(na(b5_price) ? na : 1, "Bull P5 Valid", display=display.data_window)

plot(na(r1_price) ? na : 1, "Bear P1 Valid", display=display.data_window)
plot(na(r2_price) ? na : 1, "Bear P2 Valid", display=display.data_window)
plot(na(r3_price) ? na : 1, "Bear P3 Valid", display=display.data_window)
plot(na(r4_price) ? na : 1, "Bear P4 Valid", display=display.data_window)
plot(na(r5_price) ? na : 1, "Bear P5 Valid", display=display.data_window)

plot(trendMA, "Trend MA Value", display=display.data_window)
plot(b1_price, "Bull P1 Origin Y", display=display.data_window)
plot(r1_price, "Bear P1 Origin Y", display=display.data_window)
plot(gridAtrNow, "Current Grid ATR", display=display.data_window)
````
