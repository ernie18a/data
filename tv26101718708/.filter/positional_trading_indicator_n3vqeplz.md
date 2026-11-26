# Positional Trading Indicator

- url: https://www.tradingview.com/script/n3vQEPlZ-Positional-Trading-Indicator/
- type: indicator
- pine_id: PUB;7a80ee4a1ff34c88902552d5187f4259
- version: 2.0

## Description

What it shows:
1. Vol Val (Volume Value)
A liquidity filter. Computes the volume-weighted average price (VWAP) of the last 7 bars multiplied by total volume over the same period, expressed in Indian Rupee Crores. Colour-coded for quick reads:

🔴 Red — below ₹5 Cr (illiquid, avoid)
🟡 Yellow — ₹5–20 Cr (moderate liquidity)
🟢 Green — above ₹20 Cr (sufficient liquidity for positional sizing)

2. Trend (Pivot Structure)
Classifies the current trend using confirmed Pivot Highs and Lows (default 5/5 left-right, adjustable). Compares the last two confirmed pivot highs and lows to determine market structure:

🟢 Positive — Higher High + Higher Low (uptrend structure)
🟡 Neutral — Mixed structure (consolidation or transition)
🔴 Negative — Lower High + Lower Low (downtrend structure)

3. Mansfield Relative Strength
Plots the stock's performance relative to a benchmark index (default: NSE:CNX500) as a ratio, smoothed by a 52-week SMA — adapted from the classic Mansfield RS methodology used in Stage Analysis. Indicates whether the stock is outperforming or underperforming the broader market:

🟢 RS Positive — Stock ratio is above its 52W MA (outperforming)
🔴 RS Negative — Stock ratio is at or below its 52W MA (underperforming)

4. Demand Zones
Automatically identifies and draws the most recent active demand zone on the chart. A zone is defined by a minimum of 3 touch points (wick entries or closes inside the zone), with at least 2 bars between consecutive touches. Zone width is ATR-based (default 0.5× ATR), anchored at the low of the zone. Overlapping zones are merged into a single clean box. Zones are invalidated and removed once price closes below them.
5. Pivot Level Lines
Draws dashed horizontal lines from the most recent confirmed Pivot High (light blue) and Pivot Low (red), extending to the right — giving you instant visual reference for key structural levels.

Inputs & Customisation:
All parameters are adjustable — Vol Val lookback, liquidity thresholds, pivot left/right lengths, ATR multiplier, demand zone lookback, minimum touches, gap between touches, RS benchmark symbol, and RS MA length.

## Source Code

````pine
//@version=6
indicator("Positional Trading Indicator", shorttitle="PTI", overlay=true, max_labels_count=500, max_boxes_count=500, max_lines_count=500)

// ══════════════════════════════════════════════
// INPUTS
// ══════════════════════════════════════════════

grpVolVal  = "Vol Val Settings"
grpPivot   = "Pivot Trend Settings"
grpDemand  = "Demand Zone Settings"
grpRS      = "Mansfield RS Settings"

volValBars = input.int(7,    "Lookback Bars (Vol Val)",           minval=1,   group=grpVolVal)
lowThresh  = input.float(5,  "Low Threshold (Cr)",                minval=0,   group=grpVolVal)
highThresh = input.float(20, "High Threshold (Cr)",               minval=0,   group=grpVolVal)

pivLeftH   = input.int(5,   "Pivot High – Left Bars",             minval=1,   group=grpPivot)
pivRightH  = input.int(5,   "Pivot High – Right Bars",            minval=1,   group=grpPivot)
pivLeftL   = input.int(5,   "Pivot Low  – Left Bars",             minval=1,   group=grpPivot)
pivRightL  = input.int(5,   "Pivot Low  – Right Bars",            minval=1,   group=grpPivot)

atrLen     = input.int(14,   "ATR Length",                        minval=1,   group=grpDemand)
atrMult    = input.float(0.5,"ATR Multiplier (Zone Height)",      minval=0.1, step=0.1, group=grpDemand)
lookback   = input.int(200,  "Lookback Bars (Demand Zones)",      minval=50,  group=grpDemand)
minTouches = input.int(3,    "Min Touches to Qualify Zone",       minval=2,   group=grpDemand)
minGap     = input.int(2,    "Min Bars Between Touches",          minval=1,   group=grpDemand)
zoneColor  = input.color(color.new(color.green, 80), "Zone Fill Color",   group=grpDemand)
zoneBorder = input.color(color.new(color.green, 20), "Zone Border Color", group=grpDemand)

rsSym      = input.symbol("NSE:CNX500", "RS Benchmark Symbol",   group=grpRS)
rsMaLen    = input.int(52, "RS MA Length",      minval=1,         group=grpRS)

// ══════════════════════════════════════════════
// VOL VAL  (chart timeframe)
// ══════════════════════════════════════════════

sumVol      = math.sum(volume, volValBars)
sumVolClose = math.sum(volume * close, volValBars)
vwap7       = sumVol > 0 ? sumVolClose / sumVol : close
volVal      = (vwap7 * sumVol) / 10000000

volValColor = volVal <= lowThresh  ? color.red :
              volVal <  highThresh ? color.yellow :
              color.lime

// ══════════════════════════════════════════════
// MANSFIELD RS  (chart timeframe, live bar)
// ══════════════════════════════════════════════

benchClose  = request.security(rsSym,             timeframe.period, close, lookahead=barmerge.lookahead_on)
stockClose  = request.security(syminfo.tickerid,  timeframe.period, close, lookahead=barmerge.lookahead_on)
rsRatio     = stockClose / benchClose * 100
rsMa        = ta.sma(rsRatio, rsMaLen)

rsPositive  = rsRatio > rsMa
rsLabel     = rsPositive ? "RS Positive ▲" : "RS Negative ▼"
rsColor     = rsPositive ? color.lime       : color.red

// ══════════════════════════════════════════════
// PIVOT TREND LOGIC  (hard-fixed Weekly)
// ══════════════════════════════════════════════

[wHigh, wLow] = request.security(syminfo.tickerid, "1W", [high, low], lookahead=barmerge.lookahead_on)

wPh = request.security(syminfo.tickerid, "1W",
     ta.pivothigh(pivLeftH, pivRightH), lookahead=barmerge.lookahead_on)
wPl = request.security(syminfo.tickerid, "1W",
     ta.pivotlow (pivLeftL, pivRightL), lookahead=barmerge.lookahead_on)

var float wPh1 = na
var float wPh2 = na
var float wPl1 = na
var float wPl2 = na

if not na(wPh)
    wPh2 := wPh1
    wPh1 := wPh

if not na(wPl)
    wPl2 := wPl1
    wPl1 := wPl

trendLabel = ""
trendColor = color.gray

if not na(wPh1) and not na(wPh2) and not na(wPl1) and not na(wPl2)
    higherHigh = wPh1 > wPh2
    higherLow  = wPl1 > wPl2
    lowerHigh  = wPh1 < wPh2
    lowerLow   = wPl1 < wPl2

    if higherHigh and higherLow
        trendLabel := "Positive ▲"
        trendColor  := color.lime
    else if lowerHigh and lowerLow
        trendLabel := "Negative ▼"
        trendColor  := color.red
    else
        trendLabel := "Neutral ◆"
        trendColor  := color.yellow
else
    trendLabel := "Insufficient Data"
    trendColor  := color.gray

// ══════════════════════════════════════════════
// DASHBOARD TABLE
// ══════════════════════════════════════════════

var table dash = table.new(
     position.top_right, 2, 4,
     bgcolor      = color.new(color.black, 20),
     border_width = 1,
     border_color = color.new(color.white, 60),
     frame_width  = 1,
     frame_color  = color.new(color.white, 40))

if barstate.islast
    table.cell(dash, 0, 0, "METRIC",       text_color=color.new(color.white,20), text_size=size.small,  bgcolor=color.new(color.black,30))
    table.cell(dash, 1, 0, "VALUE",        text_color=color.new(color.white,20), text_size=size.small,  bgcolor=color.new(color.black,30))

    volValStr = str.tostring(math.round(volVal, 2)) + " Cr"
    table.cell(dash, 0, 1, "Vol Val",      text_color=color.white, text_size=size.normal, bgcolor=color.new(color.black,40))
    table.cell(dash, 1, 1, volValStr,      text_color=volValColor,  text_size=size.normal, bgcolor=color.new(color.black,40))

    table.cell(dash, 0, 2, "Trend (W)",    text_color=color.white, text_size=size.normal, bgcolor=color.new(color.black,40))
    table.cell(dash, 1, 2, trendLabel,     text_color=trendColor,   text_size=size.normal, bgcolor=color.new(color.black,40))

    table.cell(dash, 0, 3, "Mansfield RS", text_color=color.white, text_size=size.normal, bgcolor=color.new(color.black,40))
    table.cell(dash, 1, 3, rsLabel,        text_color=rsColor,      text_size=size.normal, bgcolor=color.new(color.black,40))

// ══════════════════════════════════════════════
// PIVOT HORIZONTAL LINES  (chart timeframe)
// ══════════════════════════════════════════════

ph = ta.pivothigh(pivLeftH, pivRightH)
pl = ta.pivotlow (pivLeftL, pivRightL)

var float ph1    = na
var float ph2    = na
var float pl1    = na
var float pl2    = na
var int   ph1Bar = na
var int   pl1Bar = na

if not na(ph)
    ph2    := ph1
    ph1    := ph
    ph1Bar := bar_index[pivRightH]

if not na(pl)
    pl2    := pl1
    pl1    := pl
    pl1Bar := bar_index[pivRightL]

var line phLine = na
var line plLine = na

if barstate.islast
    if not na(phLine)
        line.delete(phLine)
    if not na(plLine)
        line.delete(plLine)

    if not na(ph1)
        phLine := line.new(
             x1=ph1Bar, y1=ph1, x2=bar_index, y2=ph1,
             color=color.new(color.aqua, 20), width=2,
             style=line.style_dashed, extend=extend.right)

    if not na(pl1)
        plLine := line.new(
             x1=pl1Bar, y1=pl1, x2=bar_index, y2=pl1,
             color=color.new(color.red, 20), width=2,
             style=line.style_dashed, extend=extend.right)

// ══════════════════════════════════════════════
// DEMAND ZONES  (chart timeframe)
// ══════════════════════════════════════════════

atr = ta.atr(atrLen)
var box demandBox = na

if barstate.islast

    var float[] rawTops = array.new_float(0)
    var float[] rawBots = array.new_float(0)
    array.clear(rawTops)
    array.clear(rawBots)

    for i = pivRightL to lookback
        anchorLow = low[i]
        anchorAtr = atr[i]
        zoneBot   = anchorLow
        zoneTop   = anchorLow + atrMult * anchorAtr

        touches      = 0
        lastTouchBar = -999

        for j = lookback to 0
            barLow     = low[j]
            barClose   = close[j]
            isTouching = (barLow <= zoneTop and barLow >= zoneBot) or
                         (barClose >= zoneBot and barClose <= zoneTop)
            if isTouching
                gapOk = (lastTouchBar == -999) or ((lastTouchBar - j) >= minGap)
                if gapOk
                    touches      += 1
                    lastTouchBar  := j

        breached = false
        for k = 0 to i - 1
            if close[k] < zoneBot
                breached := true
                break

        if touches >= minTouches and not breached
            array.push(rawTops, zoneTop)
            array.push(rawBots, zoneBot)

    int n = array.size(rawTops)

    var float[] mergedTops = array.new_float(0)
    var float[] mergedBots = array.new_float(0)
    array.clear(mergedTops)
    array.clear(mergedBots)

    if n == 1
        array.push(mergedTops, array.get(rawTops, 0))
        array.push(mergedBots, array.get(rawBots, 0))

    else if n > 1
        var float[] sortedTops = array.copy(rawTops)
        var float[] sortedBots = array.copy(rawBots)

        for i = 1 to n - 1
            keyTop = array.get(sortedTops, i)
            keyBot = array.get(sortedBots, i)
            j = i - 1
            while j >= 0 and array.get(sortedBots, j) > keyBot
                array.set(sortedTops, j+1, array.get(sortedTops, j))
                array.set(sortedBots, j+1, array.get(sortedBots, j))
                j -= 1
            array.set(sortedTops, j+1, keyTop)
            array.set(sortedBots, j+1, keyBot)

        curTop = array.get(sortedTops, 0)
        curBot = array.get(sortedBots, 0)

        for i = 1 to n - 1
            nextTop = array.get(sortedTops, i)
            nextBot = array.get(sortedBots, i)
            if nextBot <= curTop
                curTop := math.max(curTop, nextTop)
                curBot := math.min(curBot, nextBot)
            else
                array.push(mergedTops, curTop)
                array.push(mergedBots, curBot)
                curTop := nextTop
                curBot := nextBot

        array.push(mergedTops, curTop)
        array.push(mergedBots, curBot)

    if not na(demandBox)
        box.delete(demandBox)

    int mCount = array.size(mergedTops)
    if mCount > 0
        int   bestIdx = 0
        float bestBot = array.get(mergedBots, 0)

        if mCount > 1
            for i = 1 to mCount - 1
                b = array.get(mergedBots, i)
                if b > bestBot
                    bestBot := b
                    bestIdx := i

        demandBox := box.new(
             left         = bar_index[lookback],
             top          = array.get(mergedTops, bestIdx),
             right        = bar_index,
             bottom       = array.get(mergedBots, bestIdx),
             border_color = zoneBorder,
             border_width = 1,
             bgcolor      = zoneColor,
             extend       = extend.right)
````
