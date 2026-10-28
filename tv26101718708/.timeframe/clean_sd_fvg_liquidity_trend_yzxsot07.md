# Clean S&D + FVG + Liquidity + Trend

- url: https://www.tradingview.com/script/YzxsOt07-Clean-S-D-FVG-Liquidity-Trend/
- type: indicator
- pine_id: PUB;25a60cb1847f47b0a1c056ce28f7a75e
- version: 1.0

## Description

# Clean Supply & Demand + FVG + Liquidity + Trend

A clean, multi-feature price action indicator designed to help traders identify key market areas and understand market structure without overcrowding their charts.

This indicator combines **Supply & Demand Zones, Fair Value Gaps (FVGs), Liquidity Levels, and Trend Detection** into one customizable tool.

### Key Features

**Supply & Demand Zones**
- Identifies potential supply and demand areas using base candles and price displacement.
- Customizable zone timeframe, base candle search, and displacement settings.
- Option to remove invalidated zones automatically.
- Adjustable zone limits and visual settings.

**Fair Value Gaps (FVGs)**
- Detects bullish and bearish fair value gaps.
- Can filter FVGs based on their proximity to identified supply and demand zones.
- Adjustable minimum gap size and maximum number of displayed FVGs.
- Option to remove filled gaps.

**Liquidity Levels**
- Highlights potential liquidity around swing highs and swing lows.
- Identifies equal highs (EQH) and equal lows (EQL), where liquidity may accumulate.
- Customizable pivot sensitivity and equal-level tolerance.

**Market Trend Detection**
- Analyzes market structure using higher highs, higher lows, lower highs, and lower lows.
- Optional EMA filter to help confirm directional bias.
- Customizable trend timeframe.
- Compact trend panel for quick reference.

### Customization

Adjust timeframes, detection sensitivity, zone boundaries, FVG settings, liquidity levels, trend filters, and colours to suit your trading approach.

### Intended Use

This indicator can be used as a technical analysis aid for traders who incorporate supply and demand, market structure, fair value gaps, and liquidity concepts into their strategies.

**Important:** The indicator identifies potential areas of interest, not guaranteed trade entries. Signals and zones should be evaluated alongside price action, risk management, and your own trading rules. This tool does not guarantee profitable results and should be tested before use in live markets.

## Source Code

````pine

 //@version=6
indicator("Clean S&D + FVG + Liquidity + Trend", overlay=true, max_boxes_count=150, max_lines_count=150, max_labels_count=50)

// ─────────────────────────────────────
// SETTINGS
// ─────────────────────────────────────

g1 = "Supply & Demand"
zoneTF = input.timeframe("60", "Zone timeframe", group=g1)
baseSearch = input.int(5, "Base candle search", minval=1, maxval=20, group=g1)
displacementBars = input.int(3, "Displacement candles", minval=1, maxval=10, group=g1)
atrLength = input.int(14, "ATR length", minval=1, group=g1)
minDispATR = input.float(1.0, "Minimum displacement (ATR)", minval=0.1, step=0.1, group=g1)
zoneBoundary = input.string("Wick", "Zone boundaries", options=["Wick", "Body"], group=g1)
maxZones = input.int(3, "Zones per direction", minval=1, maxval=10, group=g1)
deleteInvalid = input.bool(true, "Remove broken zones", group=g1)
showZones = input.bool(true, "Show zones", group=g1)

g2 = "Fair Value Gaps"
showFVG = input.bool(true, "Show FVGs near zones", group=g2)
fvgDistanceATR = input.float(1.5, "Maximum distance from zone (ATR)", minval=0.1, step=0.1, group=g2)
minFVGticks = input.float(0, "Minimum FVG size (ticks)", minval=0, group=g2)
maxFVGs = input.int(5, "Maximum visible FVGs", minval=1, maxval=20, group=g2)
removeFilledFVG = input.bool(true, "Remove filled FVGs", group=g2)

g3 = "Liquidity"
showSwing = input.bool(true, "Show swing liquidity", group=g3)
showEqual = input.bool(true, "Show equal highs/lows", group=g3)
pivotLen = input.int(3, "Pivot sensitivity", minval=1, maxval=20, group=g3)
equalTolATR = input.float(0.15, "Equal level tolerance (ATR)", minval=0.01, step=0.01, group=g3)
maxLiq = input.int(8, "Maximum visible liquidity lines", minval=1, maxval=30, group=g3)

g4 = "Trend"
showTrend = input.bool(true, "Show trend panel", group=g4)
trendTF = input.timeframe("60", "Trend timeframe", group=g4)
trendPivot = input.int(3, "Structure sensitivity", minval=1, maxval=20, group=g4)
useEMA = input.bool(true, "Require EMA confirmation", group=g4)
fastLen = input.int(20, "Fast EMA", minval=1, group=g4)
slowLen = input.int(50, "Slow EMA", minval=2, group=g4)
showEMAs = input.bool(false, "Plot EMAs", group=g4)

g5 = "Appearance"
supplyCol = input.color(color.new(color.red, 88), "Supply", group=g5)
demandCol = input.color(color.new(color.green, 88), "Demand", group=g5)
bullFVGCol = input.color(color.new(color.teal, 85), "Bullish FVG", group=g5)
bearFVGCol = input.color(color.new(color.orange, 85), "Bearish FVG", group=g5)

// ─────────────────────────────────────
// SUPPLY & DEMAND
// ─────────────────────────────────────

f_zones() =>
    float a = ta.atr(atrLength)
    bool bull = close > open and close - close[displacementBars] >= a * minDispATR
    bool bear = close < open and close[displacementBars] - close >= a * minDispATR

    bool df = false
    bool sf = false
    float dt = na
    float db = na
    int dtime = na
    float st = na
    float sb = na
    int stime = na

    if bull
        for i = 1 to baseSearch
            if not df and close[i] < open[i]
                df := true
                dt := zoneBoundary == "Wick" ? high[i] : math.max(open[i], close[i])
                db := zoneBoundary == "Wick" ? low[i] : math.min(open[i], close[i])
                dtime := time[i]

    if bear
        for i = 1 to baseSearch
            if not sf and close[i] > open[i]
                sf := true
                st := zoneBoundary == "Wick" ? high[i] : math.max(open[i], close[i])
                sb := zoneBoundary == "Wick" ? low[i] : math.min(open[i], close[i])
                stime := time[i]

    [df[1], dt[1], db[1], dtime[1], sf[1], st[1], sb[1], stime[1]]

[df, dt, db, dtime, sf, st, sb, stime] = request.security(syminfo.tickerid, zoneTF, f_zones(), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)

var box[] dBoxes = array.new_box()
var box[] sBoxes = array.new_box()
var float[] dTops = array.new_float()
var float[] dBots = array.new_float()
var float[] sTops = array.new_float()
var float[] sBots = array.new_float()
var int lastD = na
var int lastS = na

bool newD = showZones and df and not na(dtime) and (na(lastD) or dtime != lastD)
bool newS = showZones and sf and not na(stime) and (na(lastS) or stime != lastS)

if newD and not na(dt) and not na(db)
    box b = box.new(dtime, dt, time, db, xloc=xloc.bar_time, extend=extend.right, bgcolor=demandCol, border_color=color.new(color.green, 35), text="D", text_color=color.green, text_size=size.tiny)
    array.push(dBoxes, b)
    array.push(dTops, dt)
    array.push(dBots, db)
    lastD := dtime
    if array.size(dBoxes) > maxZones
        box.delete(array.shift(dBoxes))
        array.shift(dTops)
        array.shift(dBots)

if newS and not na(st) and not na(sb)
    box b = box.new(stime, st, time, sb, xloc=xloc.bar_time, extend=extend.right, bgcolor=supplyCol, border_color=color.new(color.red, 35), text="S", text_color=color.red, text_size=size.tiny)
    array.push(sBoxes, b)
    array.push(sTops, st)
    array.push(sBots, sb)
    lastS := stime
    if array.size(sBoxes) > maxZones
        box.delete(array.shift(sBoxes))
        array.shift(sTops)
        array.shift(sBots)

// Remove invalidated zones
if deleteInvalid and array.size(dBoxes) > 0
    for i = array.size(dBoxes) - 1 to 0
        if close < array.get(dBots, i)
            box.delete(array.get(dBoxes, i))
            array.remove(dBoxes, i)
            array.remove(dTops, i)
            array.remove(dBots, i)

if deleteInvalid and array.size(sBoxes) > 0
    for i = array.size(sBoxes) - 1 to 0
        if close > array.get(sTops, i)
            box.delete(array.get(sBoxes, i))
            array.remove(sBoxes, i)
            array.remove(sTops, i)
            array.remove(sBots, i)

// ─────────────────────────────────────
// FVG PROXIMITY TO ZONES
// ─────────────────────────────────────

float nearest = na

if array.size(dBoxes) > 0
    for i = 0 to array.size(dBoxes) - 1
        float top = array.get(dTops, i)
        float bot = array.get(dBots, i)
        float dist = close > top ? close - top : close < bot ? bot - close : 0.0
        nearest := na(nearest) ? dist : math.min(nearest, dist)

if array.size(sBoxes) > 0
    for i = 0 to array.size(sBoxes) - 1
        float top = array.get(sTops, i)
        float bot = array.get(sBots, i)
        float dist = close > top ? close - top : close < bot ? bot - close : 0.0
        nearest := na(nearest) ? dist : math.min(nearest, dist)

bool nearZone = not na(nearest) and nearest <= ta.atr(atrLength) * fvgDistanceATR

// ─────────────────────────────────────
// FVG DETECTION
// ─────────────────────────────────────

bool bullFVG = low > high[2] and low - high[2] >= minFVGticks * syminfo.mintick
bool bearFVG = high < low[2] and low[2] - high >= minFVGticks * syminfo.mintick

var box[] fvgBoxes = array.new_box()
var float[] fvgTops = array.new_float()
var float[] fvgBots = array.new_float()
var bool[] fvgBull = array.new_bool()

if showFVG and nearZone and bullFVG
    box b = box.new(bar_index - 2, low, bar_index, high[2], extend=extend.right, bgcolor=bullFVGCol, border_color=color.new(color.teal, 55), text="FVG", text_color=color.teal, text_size=size.tiny)
    array.push(fvgBoxes, b)
    array.push(fvgTops, low)
    array.push(fvgBots, high[2])
    array.push(fvgBull, true)

if showFVG and nearZone and bearFVG
    box b = box.new(bar_index - 2, low[2], bar_index, high, extend=extend.right, bgcolor=bearFVGCol, border_color=color.new(color.orange, 55), text="FVG", text_color=color.orange, text_size=size.tiny)
    array.push(fvgBoxes, b)
    array.push(fvgTops, low[2])
    array.push(fvgBots, high)
    array.push(fvgBull, false)

// Remove filled FVGs and keep the object count limited.
if array.size(fvgBoxes) > 0
    for i = array.size(fvgBoxes) - 1 to 0
        bool filled = array.get(fvgBull, i) ? low <= array.get(fvgBots, i) : high >= array.get(fvgTops, i)
        if removeFilledFVG and filled
            box.delete(array.get(fvgBoxes, i))
            array.remove(fvgBoxes, i)
            array.remove(fvgTops, i)
            array.remove(fvgBots, i)
            array.remove(fvgBull, i)

while array.size(fvgBoxes) > maxFVGs
    box.delete(array.shift(fvgBoxes))
    array.shift(fvgTops)
    array.shift(fvgBots)
    array.shift(fvgBull)

// ─────────────────────────────────────
// LIQUIDITY: MINIMAL LINES
// Swing levels use dashed lines.
// Equal highs/lows use yellow lines.
// ─────────────────────────────────────

float atrNow = ta.atr(atrLength)
float ph = ta.pivothigh(high, pivotLen, pivotLen)
float pl = ta.pivotlow(low, pivotLen, pivotLen)

var float prevHigh = na
var float prevLow = na
var line[] liqLines = array.new_line()

if not na(ph)
    if showSwing
        line l = line.new(bar_index - pivotLen, ph, bar_index, ph, extend=extend.right, color=color.new(color.red, 30), style=line.style_dashed)
        array.push(liqLines, l)

    if showEqual and not na(prevHigh) and not na(atrNow[pivotLen]) and math.abs(ph - prevHigh) <= atrNow[pivotLen] * equalTolATR
        line l = line.new(bar_index - pivotLen, ph, bar_index, ph, extend=extend.right, color=color.yellow, width=2)
        array.push(liqLines, l)
        label.new(bar_index - pivotLen, ph, "EQH", style=label.style_none, textcolor=color.yellow, size=size.tiny)

    prevHigh := ph

if not na(pl)
    if showSwing
        line l = line.new(bar_index - pivotLen, pl, bar_index, pl, extend=extend.right, color=color.new(color.green, 30), style=line.style_dashed)
        array.push(liqLines, l)

    if showEqual and not na(prevLow) and not na(atrNow[pivotLen]) and math.abs(pl - prevLow) <= atrNow[pivotLen] * equalTolATR
        line l = line.new(bar_index - pivotLen, pl, bar_index, pl, extend=extend.right, color=color.yellow, width=2)
        array.push(liqLines, l)
        label.new(bar_index - pivotLen, pl, "EQL", style=label.style_none, textcolor=color.yellow, size=size.tiny)

    prevLow := pl

while array.size(liqLines) > maxLiq
    line.delete(array.shift(liqLines))

// ─────────────────────────────────────
// TREND DETECTION
// Confirmed market structure + optional EMA.
// ─────────────────────────────────────

f_trend() =>
    float highPivot = ta.pivothigh(high, trendPivot, trendPivot)
    float lowPivot = ta.pivotlow(low, trendPivot, trendPivot)

    float h1 = ta.valuewhen(not na(highPivot), highPivot, 0)
    float h2 = ta.valuewhen(not na(highPivot), highPivot, 1)
    float l1 = ta.valuewhen(not na(lowPivot), lowPivot, 0)
    float l2 = ta.valuewhen(not na(lowPivot), lowPivot, 1)

    float fast = ta.ema(close, fastLen)
    float slow = ta.ema(close, slowLen)

    bool bullStruct = not na(h1) and not na(h2) and not na(l1) and not na(l2) and h1 > h2 and l1 > l2
    bool bearStruct = not na(h1) and not na(h2) and not na(l1) and not na(l2) and h1 < h2 and l1 < l2

    int structure = bullStruct ? 1 : bearStruct ? -1 : 0
    int emaDir = fast > slow ? 1 : fast < slow ? -1 : 0
    int direction = useEMA ? (structure == emaDir ? structure : 0) : structure

    [direction[1], fast[1], slow[1]]

[trend, fastEMA, slowEMA] = request.security(syminfo.tickerid, trendTF, f_trend(), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)

string trendText = trend == 1 ? "UPTREND" : trend == -1 ? "DOWNTREND" : "UNCONFIRMED"
color trendCol = trend == 1 ? color.green : trend == -1 ? color.red : color.gray

var table panel = table.new(position.top_right, 1, 1, border_width=0)

if barstate.islast
    if showTrend
        table.cell(panel, 0, 0, "TREND  " + trendTF + "\n" + trendText, bgcolor=color.new(trendCol, 15), text_color=color.white, text_size=size.small)
    else
        table.clear(panel, 0, 0, 0, 0)

plot(showEMAs ? fastEMA : na, "Fast EMA", color=color.teal)
plot(showEMAs ? slowEMA : na, "Slow EMA", color=color.orange)

// ─────────────────────────────────────
// ALERTS
// ─────────────────────────────────────

alertcondition(newD, "New Demand Zone", "New demand zone detected")
alertcondition(newS, "New Supply Zone", "New supply zone detected")
alertcondition(showFVG and nearZone and bullFVG, "Bullish FVG Near Zone", "Bullish FVG near a zone")
alertcondition(showFVG and nearZone and bearFVG, "Bearish FVG Near Zone", "Bearish FVG near a zone")
alertcondition(ta.change(trend) != 0 and trend == 1, "Trend Bullish", "Trend changed to bullish")
alertcondition(ta.change(trend) != 0 and trend == -1, "Trend Bearish", "Trend changed to bearish")
````
