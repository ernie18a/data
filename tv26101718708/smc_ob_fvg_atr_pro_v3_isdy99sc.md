# SMC OB + FVG ATR Pro v3

- url: https://www.tradingview.com/script/ISDy99Sc/
- type: indicator
- pine_id: PUB;1aae0abfcac94212b1c8cf300c3f2f9d
- version: 1.0

## Description

# SMC Order Blocks + FVG ATR Pro v3

**Smart Money Concepts | Order Blocks | Fair Value Gaps | Break of Structure | ATR-Based Filtering**

## Overview

SMC Order Blocks + FVG ATR Pro v3 is an advanced market structure indicator designed to identify potential institutional reaction zones using Smart Money Concepts (SMC).

The indicator combines **Order Blocks (OB), Fair Value Gaps (FVG), Break of Structure (BOS), and three independent ATR-based filters** into a single, customizable charting tool.

Its main objective is to help traders identify significant price areas, filter out weaker market structures, and maintain a clean visual representation of active supply and demand imbalances.

Designed for cryptocurrencies, forex, indices, and other liquid markets, the indicator can be used across multiple timeframes, including scalping, intraday trading, and swing trading.

## Key Features

### 1. Smart Money Order Blocks

Automatically detects bullish and bearish Order Blocks following a confirmed Break of Structure.

- **Bullish Order Blocks (Green):** Identify the last bearish candle before a qualifying bullish structure break.
- **Bearish Order Blocks (Red):** Identify the last bullish candle before a qualifying bearish structure break.
- Optional candle-body or full-wick zone calculation.
- Automatic zone extension until invalidation.
- Configurable invalidation using candle closes or wicks.
- First-retest detection and alerts.
- Overlapping zones of the same type are filtered.

### 2. Fair Value Gaps (FVG)

Automatically identifies three-candle price imbalances.

- **Bullish FVG (Cyan):** Detected when the current candle's low is above the high from two candles earlier.
- **Bearish FVG (Orange):** Detected when the current candle's high is below the low from two candles earlier.
- Optional momentum confirmation using the middle candle.
- Independent ATR-based minimum gap filtering.
- Automatic extension of active FVG zones.

FVG mitigation options include:

- **Full Fill:** Removes the zone after the gap has been completely filled.
- **50% Fill:** Removes the zone when its midpoint is reached.
- **First Touch:** Removes the zone upon the first qualifying interaction.

Mitigation can be calculated using candle wicks or closing prices.

### 3. Three Independent ATR Filters

One of the main features of this indicator is its volatility-adaptive filtering system.

**BOS ATR Filter**

Requires the structure-breaking candle body to meet a minimum ATR-based threshold.

**Order Block ATR Filter**

Filters Order Blocks according to their size relative to the ATR of the original OB candle.

Both minimum and maximum zone sizes are adjustable.

**FVG ATR Filter**

Requires the detected price gap to meet a minimum ATR-based size. An additional filter can validate the strength of the middle candle.

Each filter can be enabled or disabled independently, allowing traders to adjust detection sensitivity to different assets and market conditions.

### 4. Order Block + FVG Confluence

The indicator automatically detects overlapping bullish OB and bullish FVG zones, as well as overlapping bearish OB and bearish FVG zones.

Diamond markers highlight newly detected confluence conditions.

These areas represent the intersection of two technical structures and may be useful for identifying potential reaction zones.

Confluence is not automatically considered a trade entry signal.

### 5. Clean Chart Visualization

To improve readability, the indicator includes an adjustable horizontal zone extension.

- Move active zones and their text labels further to the right.
- Keep important candlestick formations visible.
- Customize bullish and bearish colors.
- Enable or disable FVG labels, BOS markers, and retest signals.
- Control the maximum number of active zones.

This is especially useful when multiple Order Blocks and Fair Value Gaps are present simultaneously.

### 6. TradingView Alerts

Built-in alert conditions are provided for:

- Bullish and bearish BOS
- New bullish and bearish Order Blocks
- New bullish and bearish FVGs
- First Order Block retests
- First FVG retests
- FVG mitigation events
- Bullish and bearish OB + FVG confluences

These alerts can help traders monitor important technical events without constantly watching their charts.

## Suggested Starting Settings

For BTCUSDT on the 15-minute timeframe:

| Parameter | Suggested Value |
|---|---|
| Pivot Length | 5 |
| ATR Length | 14 |
| BOS Body / ATR | 0.50 |
| OB Minimum Size / ATR | 0.30 |
| OB Maximum Size / ATR | 2.00 |
| FVG Minimum Gap / ATR | 0.30 |
| FVG Middle Body / ATR | 0.50 |
| FVG Mitigation | Full Fill |
| FVG Fill Detection | Wick |
| Zone Extension | 10 bars |

These settings are starting points for experimentation and have not been independently optimized or validated for profitability.

## How to Use

**Bullish scenario:**

Identify a bullish Break of Structure, locate the resulting bullish Order Block, and observe whether an active bullish FVG overlaps that area.

When price returns to the zone, look for additional confirmation from price action, market structure, or volume analysis.

**Bearish scenario:**

Identify a bearish Break of Structure and the corresponding bearish Order Block.

An overlapping bearish FVG may provide additional technical context. Monitor how price behaves when revisiting the zone.

## Important Notes

This indicator identifies algorithmically defined Order Blocks and Fair Value Gaps. It does not directly track institutional orders, order-book liquidity, or actual executed buy and sell order flow.

Structure pivots require confirmation, which introduces some detection delay. BOS and new FVG conditions are confirmed at candle close, while active zones continue to update as new price data becomes available.

The indicator is intended for technical analysis and educational purposes. It does not guarantee profitable trading signals and should be used with appropriate risk management.

---

**SMC Order Blocks + FVG ATR Pro v3**

*Combining market structure, volatility filtering, and price imbalances into one streamlined technical analysis tool.*

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Armindo-Azevedo


 //@version=6
indicator("SMC OB + FVG ATR Pro v3", shorttitle="SMC OB FVG v3", overlay=true, max_boxes_count=400, max_labels_count=300)

// ─────────────────────────────────────────
// 1. MARKET STRUCTURE
// ─────────────────────────────────────────

g1 = "1. Market Structure"

pivotLen = input.int(5, "Pivot Length", minval=1, maxval=30, group=g1)
lookbackOB = input.int(20, "Search Last Opposite Candle", minval=1, maxval=100, group=g1)
showBOS = input.bool(true, "Show BOS", group=g1)

// ─────────────────────────────────────────
// 2. ORDER BLOCKS
// ─────────────────────────────────────────

g2 = "2. Order Blocks"

showBull = input.bool(true, "Bullish OB", group=g2)
showBear = input.bool(true, "Bearish OB", group=g2)
maxOB = input.int(10, "Max OB Per Side", minval=1, maxval=50, group=g2)

obBody = input.bool(false, "Use Candle Body", group=g2)
obMitigation = input.string("Close", "OB Invalidation", options=["Close", "Wick"], group=g2)

// Independent OB ATR filter
useOBATR = input.bool(true, "Enable OB ATR Filter", group=g2)
obMinATR = input.float(0.30, "OB Minimum Size / ATR", minval=0, step=0.05, group=g2)
obMaxATR = input.float(2.00, "OB Maximum Size / ATR", minval=0.1, step=0.1, group=g2)

obBullCol = input.color(color.new(color.lime, 85), "Bullish OB Color", group=g2)
obBearCol = input.color(color.new(color.red, 85), "Bearish OB Color", group=g2)

// ─────────────────────────────────────────
// 3. FAIR VALUE GAPS
// ─────────────────────────────────────────

g3 = "3. Fair Value Gaps"

showFVG = input.bool(true, "Show FVG", group=g3)
showBullFVG = input.bool(true, "Bullish FVG", group=g3)
showBearFVG = input.bool(true, "Bearish FVG", group=g3)

maxFVG = input.int(15, "Max FVG Per Side", minval=1, maxval=50, group=g3)

// Independent FVG ATR filters
useFVGATR = input.bool(true, "Enable FVG ATR Filter", group=g3)
fvgATRMult = input.float(0.30, "Minimum Gap / ATR", minval=0, step=0.05, group=g3)

useFVGImpulse = input.bool(true, "Require Middle Candle Impulse", group=g3)
fvgImpulseMult = input.float(0.50, "Middle Body / ATR", minval=0, step=0.1, group=g3)

fvgMitigation = input.string("Full Fill", "FVG Mitigation", options=["Full Fill", "50% Fill", "First Touch"], group=g3)
fvgFillMode = input.string("Wick", "FVG Fill Detection", options=["Wick", "Close"], group=g3)

fvgBullCol = input.color(color.new(color.aqua, 83), "Bullish FVG Color", group=g3)
fvgBearCol = input.color(color.new(color.orange, 83), "Bearish FVG Color", group=g3)

// ─────────────────────────────────────────
// 4. ATR FILTERS
// ─────────────────────────────────────────

g4 = "4. ATR Filters"

atrLen = input.int(14, "ATR Length", minval=1, group=g4)

useBOSATR = input.bool(true, "Filter BOS With ATR", group=g4)
bosATRMult = input.float(0.50, "BOS Body / ATR", minval=0, step=0.1, group=g4)

// ─────────────────────────────────────────
// 5. DISPLAY
// ─────────────────────────────────────────

g5 = "5. Display"

showRetests = input.bool(true, "Show First Retests", group=g5)
showConfluence = input.bool(true, "Highlight OB + FVG Confluence", group=g5)
showFVGLabels = input.bool(true, "Show FVG Labels", group=g5)

// NEW: Move boxes and their texts to the right
labelOffset = input.int(10, "Décalage des zones vers la droite", minval=1, maxval=100, group=g5)

// ─────────────────────────────────────────
// CALCULATIONS
// ─────────────────────────────────────────

atr = ta.atr(atrLen)
body = math.abs(close - open)
middleBody = math.abs(close[1] - open[1])

ph = ta.pivothigh(high, pivotLen, pivotLen)
pl = ta.pivotlow(low, pivotLen, pivotLen)

var float lastHigh = na
var float lastLow = na
var int highIdx = na
var int lowIdx = na

var bool highBroken = false
var bool lowBroken = false

if not na(ph)
    lastHigh := ph
    highIdx := bar_index - pivotLen
    highBroken := false

if not na(pl)
    lastLow := pl
    lowIdx := bar_index - pivotLen
    lowBroken := false

// ─────────────────────────────────────────
// BREAK OF STRUCTURE + ATR
// ─────────────────────────────────────────

bosATRValid = not useBOSATR or (not na(atr) and body >= atr * bosATRMult)

bullBOS = barstate.isconfirmed and not na(lastHigh) and not highBroken and close > lastHigh and bosATRValid
bearBOS = barstate.isconfirmed and not na(lastLow) and not lowBroken and close < lastLow and bosATRValid

if bullBOS
    highBroken := true

if bearBOS
    lowBroken := true

// ─────────────────────────────────────────
// ZONE DATA TYPE
// ─────────────────────────────────────────

type Zone
    box bx
    float top
    float bot
    int born
    bool tested

var array<Zone> bullOB = array.new<Zone>()
var array<Zone> bearOB = array.new<Zone>()

var array<Zone> bullFVG = array.new<Zone>()
var array<Zone> bearFVG = array.new<Zone>()

// ─────────────────────────────────────────
// FUNCTIONS
// ─────────────────────────────────────────

findOB(bool bullish, int limit) =>
    int result = na
    for i = 1 to limit
        if i <= bar_index
            bool opposite = bullish ? close[i] < open[i] : close[i] > open[i]
            if opposite
                result := i
                break
    result

hasOverlap(float top, float bot, array<Zone> zones) =>
    bool result = false
    if array.size(zones) > 0
        for i = 0 to array.size(zones) - 1
            Zone z = array.get(zones, i)
            if bot <= z.top and top >= z.bot
                result := true
                break
    result

addZone(array<Zone> zones, int leftBar, float top, float bot, color bg, color border, string name, color txt, int maxCount) =>
    box b = box.new(left=leftBar, top=top, right=bar_index + labelOffset, bottom=bot, xloc=xloc.bar_index, bgcolor=bg, border_color=border, text=name, text_color=txt, text_size=size.tiny, text_halign=text.align_right)
    Zone z = Zone.new(b, top, bot, bar_index, false)
    array.push(zones, z)
    if array.size(zones) > maxCount
        Zone old = array.shift(zones)
        box.delete(old.bx)

// ─────────────────────────────────────────
// OB ATR SIZE VALIDATION
// ─────────────────────────────────────────

obSizeValid(float top, float bot, int offset) =>
    float sizeOB = top - bot
    float sourceATR = atr[offset]
    bool result = not useOBATR or (not na(sourceATR) and sizeOB >= sourceATR * obMinATR and sizeOB <= sourceATR * obMaxATR)
    result

// ─────────────────────────────────────────
// CREATE ORDER BLOCKS
// ─────────────────────────────────────────

bool newBullOB = false
bool newBearOB = false

if bullBOS and showBull
    int searchLimit = na(highIdx) ? lookbackOB : math.min(lookbackOB, math.max(1, bar_index - highIdx))
    int offset = findOB(true, searchLimit)
    if not na(offset)
        float top = obBody ? math.max(open[offset], close[offset]) : high[offset]
        float bot = obBody ? math.min(open[offset], close[offset]) : low[offset]
        bool sizeOK = obSizeValid(top, bot, offset)
        if sizeOK and close > bot and not hasOverlap(top, bot, bullOB)
            addZone(bullOB, bar_index - offset, top, bot, obBullCol, color.new(color.lime, 30), "Bull OB", color.lime, maxOB)
            newBullOB := true

if bearBOS and showBear
    int searchLimit = na(lowIdx) ? lookbackOB : math.min(lookbackOB, math.max(1, bar_index - lowIdx))
    int offset = findOB(false, searchLimit)
    if not na(offset)
        float top = obBody ? math.max(open[offset], close[offset]) : high[offset]
        float bot = obBody ? math.min(open[offset], close[offset]) : low[offset]
        bool sizeOK = obSizeValid(top, bot, offset)
        if sizeOK and close < top and not hasOverlap(top, bot, bearOB)
            addZone(bearOB, bar_index - offset, top, bot, obBearCol, color.new(color.red, 30), "Bear OB", color.red, maxOB)
            newBearOB := true

// ─────────────────────────────────────────
// FVG DETECTION WITH ATR
// ─────────────────────────────────────────

bullGap = low - high[2]
bearGap = low[2] - high

bullImpulse = close[1] > open[1] and not na(atr[1]) and middleBody >= atr[1] * fvgImpulseMult
bearImpulse = close[1] < open[1] and not na(atr[1]) and middleBody >= atr[1] * fvgImpulseMult

bullGapValid = not useFVGATR or (not na(atr) and bullGap >= atr * fvgATRMult)
bearGapValid = not useFVGATR or (not na(atr) and bearGap >= atr * fvgATRMult)

bullFVGCondition = barstate.isconfirmed and showFVG and showBullFVG and bullGap > 0 and bullGapValid and (not useFVGImpulse or bullImpulse)
bearFVGCondition = barstate.isconfirmed and showFVG and showBearFVG and bearGap > 0 and bearGapValid and (not useFVGImpulse or bearImpulse)

bool newBullFVG = false
bool newBearFVG = false

if bullFVGCondition
    float top = low
    float bot = high[2]
    if not hasOverlap(top, bot, bullFVG)
        string txt = showFVGLabels ? "FVG +" : ""
        addZone(bullFVG, bar_index - 2, top, bot, fvgBullCol, color.new(color.aqua, 35), txt, color.aqua, maxFVG)
        newBullFVG := true

if bearFVGCondition
    float top = low[2]
    float bot = high
    if not hasOverlap(top, bot, bearFVG)
        string txt = showFVGLabels ? "FVG -" : ""
        addZone(bearFVG, bar_index - 2, top, bot, fvgBearCol, color.new(color.orange, 35), txt, color.orange, maxFVG)
        newBearFVG := true

// ─────────────────────────────────────────
// UPDATE ORDER BLOCKS
// ─────────────────────────────────────────

bool bullOBRetest = false
bool bearOBRetest = false

if array.size(bullOB) > 0
    for i = array.size(bullOB) - 1 to 0
        Zone z = array.get(bullOB, i)
        bool invalid = obMitigation == "Close" ? close < z.bot : low < z.bot
        if barstate.isconfirmed and invalid
            box.delete(z.bx)
            array.remove(bullOB, i)
        else
            box.set_right(z.bx, bar_index + labelOffset)
            bool touch = low <= z.top and high >= z.bot
            if barstate.isconfirmed and bar_index > z.born and touch and not z.tested
                bullOBRetest := true
                z.tested := true
                array.set(bullOB, i, z)

if array.size(bearOB) > 0
    for i = array.size(bearOB) - 1 to 0
        Zone z = array.get(bearOB, i)
        bool invalid = obMitigation == "Close" ? close > z.top : high > z.top
        if barstate.isconfirmed and invalid
            box.delete(z.bx)
            array.remove(bearOB, i)
        else
            box.set_right(z.bx, bar_index + labelOffset)
            bool touch = high >= z.bot and low <= z.top
            if barstate.isconfirmed and bar_index > z.born and touch and not z.tested
                bearOBRetest := true
                z.tested := true
                array.set(bearOB, i, z)

// ─────────────────────────────────────────
// UPDATE FVG + MITIGATION
// ─────────────────────────────────────────

bool bullFVGRetest = false
bool bearFVGRetest = false
bool bullFVGFill = false
bool bearFVGFill = false

if array.size(bullFVG) > 0
    for i = array.size(bullFVG) - 1 to 0
        Zone z = array.get(bullFVG, i)
        float testPrice = fvgFillMode == "Close" ? close : low
        bool touched = testPrice <= z.top
        float midpoint = (z.top + z.bot) / 2
        bool filled = switch fvgMitigation
            "Full Fill" => testPrice <= z.bot
            "50% Fill" => testPrice <= midpoint
            => touched
        bool eligible = barstate.isconfirmed and bar_index > z.born
        if eligible and filled
            bullFVGFill := true
            box.delete(z.bx)
            array.remove(bullFVG, i)
        else
            box.set_right(z.bx, bar_index + labelOffset)
            if eligible and touched and not z.tested
                bullFVGRetest := true
                z.tested := true
                array.set(bullFVG, i, z)

if array.size(bearFVG) > 0
    for i = array.size(bearFVG) - 1 to 0
        Zone z = array.get(bearFVG, i)
        float testPrice = fvgFillMode == "Close" ? close : high
        bool touched = testPrice >= z.bot
        float midpoint = (z.top + z.bot) / 2
        bool filled = switch fvgMitigation
            "Full Fill" => testPrice >= z.top
            "50% Fill" => testPrice >= midpoint
            => touched
        bool eligible = barstate.isconfirmed and bar_index > z.born
        if eligible and filled
            bearFVGFill := true
            box.delete(z.bx)
            array.remove(bearFVG, i)
        else
            box.set_right(z.bx, bar_index + labelOffset)
            if eligible and touched and not z.tested
                bearFVGRetest := true
                z.tested := true
                array.set(bearFVG, i, z)

// ─────────────────────────────────────────
// OB + FVG CONFLUENCE
// ─────────────────────────────────────────

bool bullConfluence = false
bool bearConfluence = false

if showConfluence and barstate.isconfirmed
    if array.size(bullOB) > 0 and array.size(bullFVG) > 0
        for i = 0 to array.size(bullOB) - 1
            Zone ob = array.get(bullOB, i)
            for j = 0 to array.size(bullFVG) - 1
                Zone gap = array.get(bullFVG, j)
                if ob.bot <= gap.top and ob.top >= gap.bot
                    bullConfluence := true

    if array.size(bearOB) > 0 and array.size(bearFVG) > 0
        for i = 0 to array.size(bearOB) - 1
            Zone ob = array.get(bearOB, i)
            for j = 0 to array.size(bearFVG) - 1
                Zone gap = array.get(bearFVG, j)
                if ob.bot <= gap.top and ob.top >= gap.bot
                    bearConfluence := true

newBullConfluence = bullConfluence and not bullConfluence[1]
newBearConfluence = bearConfluence and not bearConfluence[1]

// ─────────────────────────────────────────
// VISUAL SIGNALS
// ─────────────────────────────────────────

plotshape(showBOS and bullBOS, title="Bullish BOS", style=shape.labelup, location=location.belowbar, color=color.green, text="BOS+", textcolor=color.white, size=size.tiny)
plotshape(showBOS and bearBOS, title="Bearish BOS", style=shape.labeldown, location=location.abovebar, color=color.red, text="BOS-", textcolor=color.white, size=size.tiny)

plotshape(showRetests and bullOBRetest, title="Bull OB Retest", style=shape.triangleup, location=location.belowbar, color=color.lime, size=size.tiny)
plotshape(showRetests and bearOBRetest, title="Bear OB Retest", style=shape.triangledown, location=location.abovebar, color=color.red, size=size.tiny)

plotshape(showRetests and bullFVGRetest, title="Bull FVG Retest", style=shape.circle, location=location.belowbar, color=color.aqua, size=size.tiny)
plotshape(showRetests and bearFVGRetest, title="Bear FVG Retest", style=shape.circle, location=location.abovebar, color=color.orange, size=size.tiny)

plotshape(showConfluence and newBullConfluence, title="Bullish OB FVG Confluence", style=shape.diamond, location=location.belowbar, color=color.aqua, size=size.small)
plotshape(showConfluence and newBearConfluence, title="Bearish OB FVG Confluence", style=shape.diamond, location=location.abovebar, color=color.orange, size=size.small)

// ─────────────────────────────────────────
// ALERTS
// ─────────────────────────────────────────

alertcondition(newBullOB, "New Bullish OB", "Bullish Order Block - {{ticker}} {{interval}}")
alertcondition(newBearOB, "New Bearish OB", "Bearish Order Block - {{ticker}} {{interval}}")

alertcondition(bullBOS, "Bullish BOS", "Bullish BOS - {{ticker}} {{interval}}")
alertcondition(bearBOS, "Bearish BOS", "Bearish BOS - {{ticker}} {{interval}}")

alertcondition(newBullFVG, "New Bullish FVG", "Bullish FVG - {{ticker}} {{interval}}")
alertcondition(newBearFVG, "New Bearish FVG", "Bearish FVG - {{ticker}} {{interval}}")

alertcondition(bullOBRetest, "Bullish OB Retest", "Bullish OB retest - {{ticker}} {{interval}}")
alertcondition(bearOBRetest, "Bearish OB Retest", "Bearish OB retest - {{ticker}} {{interval}}")

alertcondition(bullFVGRetest, "Bullish FVG Retest", "Bullish FVG retest - {{ticker}} {{interval}}")
alertcondition(bearFVGRetest, "Bearish FVG Retest", "Bearish FVG retest - {{ticker}} {{interval}}")

alertcondition(bullFVGFill, "Bullish FVG Filled", "Bullish FVG mitigated - {{ticker}} {{interval}}")
alertcondition(bearFVGFill, "Bearish FVG Filled", "Bearish FVG mitigated - {{ticker}} {{interval}}")

alertcondition(newBullConfluence, "Bullish OB + FVG", "Bullish OB and FVG confluence - {{ticker}} {{interval}}")
alertcondition(newBearConfluence, "Bearish OB + FVG", "Bearish OB and FVG confluence - {{ticker}} {{interval}}")
````
