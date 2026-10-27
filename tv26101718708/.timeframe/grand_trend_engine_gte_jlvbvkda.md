#  Grand Trend Engine (GTE)

- url: https://www.tradingview.com/script/jlvBVKDA/
- type: indicator
- pine_id: PUB;d2db321cd90e41ae8fceeb41e1951f06
- version: 3.0

## Description

Grand Trend Engine (GTE)

## Overview

Omega Grand Trend Engine (GTE) is a multi-engine trend intelligence framework designed to identify the broader market direction rather than generating frequent buy and sell signals.

Unlike traditional indicators that focus on short-term entries and exits, GTE combines multiple market dimensions into a single unified power model to help traders understand where the dominant trend is developing, strengthening, weakening, or potentially reversing.

The indicator is especially effective on instruments with consistently high trading volume, where price movement, volume participation, and market structure tend to produce cleaner and more reliable signals.

For this reason, GTE generally performs best on highly liquid stocks, major indices, large-cap cryptocurrencies, commodities, and actively traded forex pairs.

---

## Core Philosophy

GTE should not be viewed as a simple buy/sell indicator.

Its primary purpose is to answer three important questions:

* What is the current dominant market direction?
* How strong is the current trend?
* Is the trend strengthening or losing momentum?

The system is built to help traders stay aligned with larger market movements instead of reacting to every short-term fluctuation.

---

## Integrated Engines

### PI Energy Engine

The PI Energy Engine measures market energy using a custom mathematical model based on ATR and OBV acceleration.

Its purpose is to estimate whether underlying market energy is expanding or contracting beneath price movement.

This helps identify hidden strength and weakness that may not yet be visible on the chart.

---

### Flow Engine

The Flow Engine combines Delta Flow, CVD Flow, and OBV Flow into a single directional pressure model.

Rather than focusing on price alone, it attempts to measure the actual participation behind market movement.

Strong trends are usually supported by strong flow participation.

---

### Power Zone Engine

Power Zones analyze volume behavior, candle structure, and Fibonacci reaction areas.

These zones are designed to identify areas where institutional activity and directional pressure may be concentrated.

---

### Harmonic Structure Engine

The Harmonic Engine evaluates XABCD relationships and Fibonacci proportionality.

Instead of acting as a standalone pattern detector, harmonic information becomes part of the overall trend assessment process.

---

### Vertex Matrix Engine

The Vertex Engine evaluates volatility, momentum, directional pressure, and volume interaction simultaneously.

Its purpose is to measure the internal state of the market and determine whether conditions favor continuation or exhaustion.

---

### Multi-Timeframe Engine

GTE continuously evaluates multiple timeframes simultaneously.

A trend receives higher confidence when multiple timeframes align in the same direction.

This helps reduce noise and improves trend confirmation.

---

### 5D Box Memory Engine

The 5D Box Engine acts as a long-term trend memory system.

When a box is formed, the market enters an observation phase.

If price breaks above the box structure, the engine applies a persistent bullish influence to the trend model.

If price breaks below the box structure, the engine applies a persistent bearish influence.

This influence remains active until a new box structure is created.

The objective is to capture major trend transitions rather than temporary fluctuations.

---

## Trend Bands

The upper and lower bands represent the current structural market boundaries.

These bands are not simple support and resistance levels.

Instead, they reflect the active range where trend pressure is currently developing.

A breakout above the upper band suggests expanding bullish conditions.

A breakdown below the lower band suggests expanding bearish conditions.

The bands also help identify areas where the market is transitioning from consolidation into directional movement.

---

## Trend Line

The main trend line is the visual representation of the GTE power model.

The line adapts dynamically using market volatility and trend strength.

As the underlying trend becomes stronger, the line gains confidence and stability.

When the line begins to weaken, flatten, or lose structure, it often indicates that the existing trend is losing momentum.

In many cases, these weakening phases can act as early warnings before major trend reversals occur.

For this reason, traders should pay attention not only to the direction of the line but also to changes in its overall strength and behavior.

---

## Unified Power Score

All engines contribute to a single unified Power Score.

The Power Score represents the combined assessment of:

* Market Energy
* Flow Participation
* Volume Pressure
* Harmonic Structure
* Trend Alignment
* Volatility Conditions
* Multi-Timeframe Confirmation
* 5D Box Trend Memory

Higher values indicate stronger bullish conditions.

Lower values indicate stronger bearish conditions.

The objective is to simplify a large amount of market information into one readable trend framework.

---

## Best Use Cases

GTE is most effective for:

* Trend following
* Swing trading
* Position trading
* Market regime analysis
* Trend strength evaluation
* Multi-timeframe confirmation

It is not intended to generate constant buy and sell signals.

Instead, it is designed to help traders stay aligned with the dominant market trend and avoid trading against the broader market direction.

---

## Final Notes

Grand Trend Engine (GTE) is a trend intelligence system rather than a signal generator.

Its purpose is to combine multiple analytical frameworks into one coherent model capable of identifying trend direction, trend quality, and trend persistence.

The strongest results are typically achieved on high-volume instruments where market participation is deep and directional moves are supported by real liquidity.

Use GTE as a guide for understanding the larger market picture, not merely as a source of isolated trading signals.

## Source Code

````pine
//@version=6
indicator("GAE + SMC + FORMATION MAP • NO KAMA", overlay=true, max_lines_count=500, max_labels_count=300, max_boxes_count=100)

//━━━━━━━━━━━━━━━━━━━
// GAE INPUTS
//━━━━━━━━━━━━━━━━━━━
fastLen = input.int(38, "Fast Grand Length", minval=1, group="GAE")
slowLen = input.int(62, "Slow Grand Length", minval=1, group="GAE")
atrLen  = input.int(14, "ATR Length", minval=1, group="GAE")
atrMult = input.float(2.4, "Rail Power", step=0.1, group="GAE")

tf1 = input.timeframe("15", "TF 1", group="GAE")
tf2 = input.timeframe("60", "TF 2", group="GAE")
tf3 = input.timeframe("240", "TF 3", group="GAE")
tf4 = input.timeframe("D", "TF 4", group="GAE")

showPanel   = input.bool(true, "Show GAE Panel", group="GAE")
showFill    = input.bool(true, "Show Rail Fill", group="GAE")
showSignals = input.bool(true, "Show B/S Signals", group="GAE")

//━━━━━━━━━━━━━━━━━━━
// SMC INPUTS
//━━━━━━━━━━━━━━━━━━━
useSmcStrong = input.bool(true, "Show SMC Strong Signals", group="SMC QUALITY")
liqLen       = input.int(20, "Liquidity Lookback", minval=5, group="SMC QUALITY")
smcPivotLen  = input.int(3, "SMC Swing Pivot Length", minval=1, group="SMC QUALITY")
smcAtrMult   = input.float(1.0, "Strong Move ATR Mult", step=0.1, group="SMC QUALITY")
smcStrongMin = input.int(50, "SMC Strong Min Score", minval=0, maxval=100, group="SMC QUALITY")
showSmcLine  = input.bool(true, "Show OB / BOS Lines", group="SMC QUALITY")
keepLevels   = input.int(3, "Keep Last Levels", minval=1, maxval=10, group="SMC QUALITY")

//━━━━━━━━━━━━━━━━━━━
// FORMATION INPUTS — KAMA YOK
//━━━━━━━━━━━━━━━━━━━
showFormationPanel = input.bool(true, "Show Formation Panel", group="FORMATION MAP")
fLookback = input.int(80, "Pattern Lookback", minval=30, maxval=200, group="FORMATION MAP")
fAroonLen = input.int(25, "Aroon Length", minval=5, group="FORMATION MAP")
fVolLen   = input.int(20, "Volume Average", minval=5, group="FORMATION MAP")
fPivotLen = input.int(5, "Formation Pivot Length", minval=2, maxval=20, group="FORMATION MAP")
minClassicFinal  = input.float(60.0, "Min Classic Quality", minval=0, maxval=100, step=1, group="FORMATION MAP")
minHarmonicFinal = input.float(60.0, "Min Harmonic Quality", minval=0, maxval=100, step=1, group="FORMATION MAP")
syncBars = input.int(2, "Classic + Harmonic Sync Bars", minval=0, maxval=10, group="FORMATION MAP")

showFormationDraw = input.bool(false, "Draw Formation Lines", group="FORMATION MAP")
showFormationLabels = input.bool(false, "Show Formation Labels", group="FORMATION MAP")

//━━━━━━━━━━━━━━━━━━━
// TEST INPUTS
//━━━━━━━━━━━━━━━━━━━
testBars    = input.int(2000, "Test Bars", minval=100, group="ALIGNMENT FLIP TEST")
testForward = input.int(60, "Forward Bars", minval=1, group="ALIGNMENT FLIP TEST")
hitTarget   = input.float(5.0, "🎯 TARGET %", minval=0.1, step=0.1, group="ALIGNMENT FLIP TEST")
showTest    = input.bool(true, "Show Alignment Test Panel", group="ALIGNMENT FLIP TEST")

//━━━━━━━━━━━━━━━━━━━
// COLORS
//━━━━━━━━━━━━━━━━━━━
RED    = color.rgb(255, 40, 40)
ORANGE = color.rgb(255, 171, 64)
YELLOW = color.rgb(255, 215, 0)
LIME   = color.rgb(0, 255, 120)
AQUA   = color.rgb(0, 245, 212)
GRAY   = color.rgb(120, 120, 120)
DARK   = color.rgb(22, 22, 22)
DARKER = color.rgb(16, 16, 16)

//━━━━━━━━━━━━━━━━━━━
// HELPERS
//━━━━━━━━━━━━━━━━━━━
atr = ta.atr(atrLen)

f_between(v, a, b) =>
    v >= math.min(a, b) and v <= math.max(a, b)

f_near(v, t, tol) =>
    math.abs(v - t) <= tol

f_grade(q) =>
    q < 30 ? "WEAK" :
     q < 60 ? "NORMAL" :
     q < 80 ? "STRONG" :
     "VERY STRONG"

f_gradeColor(q) =>
    q < 30 ? RED :
     q < 60 ? ORANGE :
     q < 80 ? LIME :
     AQUA

rowBg(rowIdx) =>
    rowIdx % 2 == 0 ? DARK : DARKER

//━━━━━━━━━━━━━━━━━━━
// GRAND STATE FUNCTION
//━━━━━━━━━━━━━━━━━━━
f_grand_state(_fastLen, _slowLen, _atrLen, _atrMult) =>
    _atr = ta.atr(_atrLen)
    _fastCore = ta.linreg(hl2, _fastLen, 0)
    _fastBull = _fastCore - _atr * _atrMult
    _fastBear = _fastCore + _atr * _atrMult

    var int _dir = na
    var float _rail = na

    if na(_dir)
        _dir := close >= _fastCore ? 1 : -1
        _rail := _dir == 1 ? _fastBull : _fastBear

    _buyFlip  = barstate.isconfirmed and close > nz(_rail[1], _rail) and _dir == -1
    _sellFlip = barstate.isconfirmed and close < nz(_rail[1], _rail) and _dir == 1

    if _buyFlip
        _dir := 1
        _rail := _fastBull
    else if _sellFlip
        _dir := -1
        _rail := _fastBear
    else
        if _dir == 1
            _rail := math.max(nz(_rail[1], _fastBull), _fastBull)
        else
            _rail := math.min(nz(_rail[1], _fastBear), _fastBear)

    _dir

//━━━━━━━━━━━━━━━━━━━
// LOCAL GAE RAILS
//━━━━━━━━━━━━━━━━━━━
fastCore = ta.linreg(hl2, fastLen, 0)
slowRail = ta.linreg(hl2, slowLen, 0)

fastBullBase = fastCore - atr * atrMult
fastBearBase = fastCore + atr * atrMult

var int fastDir = na
var float fastRail = na

if na(fastDir)
    fastDir := close >= fastCore ? 1 : -1
    fastRail := fastDir == 1 ? fastBullBase : fastBearBase

buyFlip  = barstate.isconfirmed and close > nz(fastRail[1], fastRail) and fastDir == -1
sellFlip = barstate.isconfirmed and close < nz(fastRail[1], fastRail) and fastDir == 1

if buyFlip
    fastDir := 1
    fastRail := fastBullBase
else if sellFlip
    fastDir := -1
    fastRail := fastBearBase
else
    if fastDir == 1
        fastRail := math.max(nz(fastRail[1], fastBullBase), fastBullBase)
    else
        fastRail := math.min(nz(fastRail[1], fastBearBase), fastBearBase)

localBull = fastDir == 1

//━━━━━━━━━━━━━━━━━━━
// MTF CONFIRMATION
//━━━━━━━━━━━━━━━━━━━
s1 = request.security(syminfo.tickerid, tf1, f_grand_state(fastLen, slowLen, atrLen, atrMult), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
s2 = request.security(syminfo.tickerid, tf2, f_grand_state(fastLen, slowLen, atrLen, atrMult), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
s3 = request.security(syminfo.tickerid, tf3, f_grand_state(fastLen, slowLen, atrLen, atrMult), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
s4 = request.security(syminfo.tickerid, tf4, f_grand_state(fastLen, slowLen, atrLen, atrMult), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
 
bullVotes = (s1 == 1 ? 1 : 0) + (s2 == 1 ? 1 : 0) + (s3 == 1 ? 1 : 0) + (s4 == 1 ? 1 : 0)
bearVotes = 4 - bullVotes 

mtfDir = bullVotes > bearVotes ? 1 : bearVotes > bullVotes ? -1 : localBull ? 1 : -1
voteCount = math.max(bullVotes, bearVotes)

trendText =
     voteCount == 4 ? "FULL ALIGNMENT" :
     voteCount == 3 ? "STRONG TREND" :
     voteCount == 2 ? "NORMAL TREND" :
     "WEAK"

//━━━━━━━━━━━━━━━━━━━
// SMC ARRAYS
//━━━━━━━━━━━━━━━━━━━
var line[] bullObLines  = array.new_line()
var line[] bearObLines  = array.new_line()
var line[] bullBosLines = array.new_line()
var line[] bearBosLines = array.new_line()

var label[] bullObLabs  = array.new_label()
var label[] bearObLabs  = array.new_label()
var label[] bullBosLabs = array.new_label()
var label[] bearBosLabs = array.new_label()

f_add_level(_lines, _labs, _price, _txt, _col, _txtCol, _width) =>
    ln = line.new(bar_index, _price, bar_index + 1, _price, extend=extend.right, color=_col, width=_width)
    lb = label.new(bar_index, _price, _txt, style=label.style_label_left, color=_col, textcolor=_txtCol, size=size.tiny)
    array.push(_lines, ln)
    array.push(_labs, lb)
    if array.size(_lines) > keepLevels
        oldLn = array.shift(_lines)
        oldLb = array.shift(_labs)
        line.delete(oldLn)
        label.delete(oldLb)

//━━━━━━━━━━━━━━━━━━━
// SMC QUALITY ENGINE
//━━━━━━━━━━━━━━━━━━━
liqLow  = ta.lowest(low, liqLen)
liqHigh = ta.highest(high, liqLen)

bullSweep = low < liqLow[1] and close > liqLow[1]
bearSweep = high > liqHigh[1] and close < liqHigh[1]

ph = ta.pivothigh(high, smcPivotLen, smcPivotLen)
pl = ta.pivotlow(low, smcPivotLen, smcPivotLen)

var float lastSwingHigh = na
var float lastSwingLow  = na

if not na(ph)
    lastSwingHigh := ph

if not na(pl)
    lastSwingLow := pl

bullBOS = not na(lastSwingHigh) and close > lastSwingHigh and close[1] <= lastSwingHigh
bearBOS = not na(lastSwingLow) and close < lastSwingLow and close[1] >= lastSwingLow

strongBullMove = close > high[1] and math.abs(close - open) > atr * smcAtrMult
strongBearMove = close < low[1] and math.abs(close - open) > atr * smcAtrMult

bullOBFound = close[1] < open[1] and strongBullMove
bearOBFound = close[1] > open[1] and strongBearMove

var float bullOBHigh = na
var float bullOBLow  = na
var float bearOBHigh = na
var float bearOBLow  = na

if bullOBFound
    bullOBHigh := open[1]
    bullOBLow  := low[1]
    bullOBMid = (bullOBHigh + bullOBLow) / 2.0
    if showSmcLine
        f_add_level(bullObLines, bullObLabs, bullOBMid, "BULL OB", color.new(YELLOW, 70), color.black, 1)

if bearOBFound
    bearOBHigh := high[1]
    bearOBLow  := open[1]
    bearOBMid = (bearOBHigh + bearOBLow) / 2.0
    if showSmcLine
        f_add_level(bearObLines, bearObLabs, bearOBMid, "BEAR OB", color.new(AQUA, 70), color.black, 1)

bullOBRetest = not na(bullOBHigh) and not na(bullOBLow) and low <= bullOBHigh and close >= bullOBLow
bearOBRetest = not na(bearOBHigh) and not na(bearOBLow) and high >= bearOBLow and close <= bearOBHigh

ema100 = ta.ema(close, 100)
ema200 = ta.ema(close, 200)

smcTrendBull = close > ema100 and close > ema200
smcTrendBear = close < ema100 and close < ema200

bullSmcScore =
     (bullSweep ? 20 : 0) +
     (bullOBRetest ? 30 : 0) +
     (bullBOS ? 40 : 0) +
     (smcTrendBull ? 10 : 0)

bearSmcScore =
     (bearSweep ? 20 : 0) +
     (bearOBRetest ? 30 : 0) +
     (bearBOS ? 40 : 0) +
     (smcTrendBear ? 10 : 0)

activeSmcScore = mtfDir == 1 ? bullSmcScore : bearSmcScore

if bullBOS and showSmcLine
    f_add_level(bullBosLines, bullBosLabs, lastSwingHigh, "BULL BOS", YELLOW, color.black, 4)

if bearBOS and showSmcLine
    f_add_level(bearBosLines, bearBosLabs, lastSwingLow, "BEAR BOS", AQUA, color.black, 4)

//━━━━━━━━━━━━━━━━━━━
// FORMATION ENGINE — NO KAMA
//━━━━━━━━━━━━━━━━━━━
fEnoughBars = bar_index > fLookback + 20

// HEIKIN ASHI SOURCE
haClose = (open + high + low + close) / 4.0
var float haOpen = na
haOpen := na(haOpen[1]) ? (open + close) / 2.0 : (haOpen[1] + haClose[1]) / 2.0
haHigh = math.max(high, math.max(haOpen, haClose))
haLow  = math.min(low, math.min(haOpen, haClose))

// AROON + VOLUME SCORE
barsHigh = ta.highestbars(high, fAroonLen)
barsLow  = ta.lowestbars(low, fAroonLen)

aroonUp   = 100 * (fAroonLen + barsHigh) / fAroonLen
aroonDown = 100 * (fAroonLen + barsLow) / fAroonLen

volAvg = ta.sma(nz(volume), fVolLen)
volRatio = volAvg > 0 ? volume / volAvg : 0.0

bullAroonPower = math.max(0.0, aroonUp - aroonDown)
bearAroonPower = math.max(0.0, aroonDown - aroonUp)

aroonBullScore = math.min(10.0, bullAroonPower / 5.5)
aroonBearScore = math.min(10.0, bearAroonPower / 5.5)

volumeScore =
     volRatio >= 1.8 ? 10.0 :
     volRatio >= 1.3 ? 7.0 :
     volRatio >= 1.0 ? 5.0 :
     0.0

contextBullScore = aroonBullScore + volumeScore
contextBearScore = aroonBearScore + volumeScore

// PIVOT ARRAYS
var float[] haP = array.new_float()
var int[]   haX = array.new_int()
var int[]   haT = array.new_int()

var float[] realP = array.new_float()
var int[]   realX = array.new_int()
var int[]   realT = array.new_int()

f_addPivot(_pArr, _xArr, _tArr, _x, _p, _t) =>
    n = array.size(_pArr)
    if n > 0
        lastT = array.get(_tArr, n - 1)
        lastP = array.get(_pArr, n - 1)
        replaceSame = lastT == _t and ((_t == 1 and _p > lastP) or (_t == -1 and _p < lastP))
        if replaceSame
            array.set(_pArr, n - 1, _p)
            array.set(_xArr, n - 1, _x)
            array.set(_tArr, n - 1, _t)
        else if lastT != _t
            array.push(_pArr, _p)
            array.push(_xArr, _x)
            array.push(_tArr, _t)
    else
        array.push(_pArr, _p)
        array.push(_xArr, _x)
        array.push(_tArr, _t)

    if array.size(_pArr) > 80
        array.shift(_pArr)
        array.shift(_xArr)
        array.shift(_tArr)

// HA PIVOTS
haPH = ta.pivothigh(haHigh, fPivotLen, fPivotLen)
haPL = ta.pivotlow(haLow, fPivotLen, fPivotLen)

var float lastHaPH = na
var int lastHaPHX = na
var float lastHaPL = na
var int lastHaPLX = na

if not na(haPH)
    nx = bar_index - fPivotLen
    ny = haPH
    lastHaPH := ny
    lastHaPHX := nx
    f_addPivot(haP, haX, haT, nx, ny, 1)

if not na(haPL)
    nx = bar_index - fPivotLen
    ny = haPL
    lastHaPL := ny
    lastHaPLX := nx
    f_addPivot(haP, haX, haT, nx, ny, -1)

// REAL PIVOTS
realPH = ta.pivothigh(high, fPivotLen, fPivotLen)
realPL = ta.pivotlow(low, fPivotLen, fPivotLen)

if not na(realPH)
    f_addPivot(realP, realX, realT, bar_index - fPivotLen, realPH, 1)

if not na(realPL)
    f_addPivot(realP, realX, realT, bar_index - fPivotLen, realPL, -1)

// FIB FROM HA SWINGS
fibReady = not na(lastHaPH) and not na(lastHaPL) and lastHaPH != lastHaPL
fibHigh = fibReady ? math.max(lastHaPH, lastHaPL) : na
fibLow  = fibReady ? math.min(lastHaPH, lastHaPL) : na
fibRange = fibReady ? fibHigh - fibLow : na

swingBull = fibReady and lastHaPLX < lastHaPHX
swingBear = fibReady and lastHaPHX < lastHaPLX

fib236 = fibReady ? fibHigh - fibRange * 0.236 : na
fib382 = fibReady ? fibHigh - fibRange * 0.382 : na
fib500 = fibReady ? fibHigh - fibRange * 0.500 : na
fib618 = fibReady ? fibHigh - fibRange * 0.618 : na
fib786 = fibReady ? fibHigh - fibRange * 0.786 : na

fibZoneBull = fibReady and swingBull and haClose <= fib382 and haClose >= fib618
fibDeepBull = fibReady and swingBull and haClose < fib618 and haClose >= fib786
fibZoneBear = fibReady and swingBear and haClose >= fib618 and haClose <= fib382
fibDeepBear = fibReady and swingBear and haClose > fib382 and haClose <= fib236

fibBullScore = fibZoneBull ? 30.0 : fibDeepBull ? 18.0 : 6.0
fibBearScore = fibZoneBear ? 30.0 : fibDeepBear ? 18.0 : 6.0

// CLASSIC FORMATIONS — KAMA YOK
leftX = bar_index - fLookback + 1
rightX = bar_index

hiNow = ta.highest(haHigh, fLookback)
loNow = ta.lowest(haLow, fLookback)

upperLeft  = ta.linreg(haHigh, fLookback, fLookback - 1)
upperRight = ta.linreg(haHigh, fLookback, 0)
lowerLeft  = ta.linreg(haLow, fLookback, fLookback - 1)
lowerRight = ta.linreg(haLow, fLookback, 0)

upperSlope = upperRight - upperLeft
lowerSlope = lowerRight - lowerLeft
widthLeft  = upperLeft - lowerLeft
widthRight = upperRight - lowerRight
compression = widthLeft > 0 ? 100 * (1 - widthRight / widthLeft) : 0

symTriangle  = fEnoughBars and upperSlope < 0 and lowerSlope > 0 and compression > 12
ascTriangle  = fEnoughBars and math.abs(upperSlope) < atr * 0.05 and lowerSlope > 0 and compression > 8
descTriangle = fEnoughBars and upperSlope < 0 and math.abs(lowerSlope) < atr * 0.05 and compression > 8

impulseUp = haClose[fLookback] > 0 and (haClose - haClose[fLookback]) / haClose[fLookback] * 100 > 6
impulseDn = haClose[fLookback] > 0 and (haClose[fLookback] - haClose) / haClose[fLookback] * 100 > 6

flagBull = fEnoughBars and impulseUp and math.abs(upperSlope) < atr * 0.25 and math.abs(lowerSlope) < atr * 0.25 and compression < 25
flagBear = fEnoughBars and impulseDn and math.abs(upperSlope) < atr * 0.25 and math.abs(lowerSlope) < atr * 0.25 and compression < 25

pennantBull = fEnoughBars and impulseUp and symTriangle
pennantBear = fEnoughBars and impulseDn and symTriangle

recentHigh = ta.highest(haHigh, fLookback)
recentLow  = ta.lowest(haLow, fLookback)

doubleTop = fEnoughBars and math.abs(haHigh - recentHigh) < atr * 0.8 and haClose < ta.sma(haClose, 20)
doubleBottom = fEnoughBars and math.abs(haLow - recentLow) < atr * 0.8 and haClose > ta.sma(haClose, 20)

idxLS = int(math.round(fLookback * 0.75))
idxRS = int(math.round(fLookback * 0.25))

lsH = haHigh[idxLS]
rsH = haHigh[idxRS]
headHigh = hiNow
obo = fEnoughBars and headHigh > lsH + atr and headHigh > rsH + atr and math.abs(lsH - rsH) < atr * 2

lsL = haLow[idxLS]
rsL = haLow[idxRS]
headLow = loNow
tobo = fEnoughBars and headLow < lsL - atr and headLow < rsL - atr and math.abs(lsL - rsL) < atr * 2

haHas5 = array.size(haP) >= 5
hp0 = haHas5 ? array.get(haP, array.size(haP) - 5) : na
hp1 = haHas5 ? array.get(haP, array.size(haP) - 4) : na
hp2 = haHas5 ? array.get(haP, array.size(haP) - 3) : na
hp3 = haHas5 ? array.get(haP, array.size(haP) - 2) : na
hp4 = haHas5 ? array.get(haP, array.size(haP) - 1) : na

ht0 = haHas5 ? array.get(haT, array.size(haT) - 5) : na
ht1 = haHas5 ? array.get(haT, array.size(haT) - 4) : na
ht2 = haHas5 ? array.get(haT, array.size(haT) - 3) : na
ht3 = haHas5 ? array.get(haT, array.size(haT) - 2) : na
ht4 = haHas5 ? array.get(haT, array.size(haT) - 1) : na

wPattern = haHas5 and ht0 == -1 and ht1 == 1 and ht2 == -1 and ht3 == 1 and ht4 == -1 and math.abs(hp0 - hp2) < atr * 2 and hp3 > hp1 * 0.98
mPattern = haHas5 and ht0 == 1 and ht1 == -1 and ht2 == 1 and ht3 == -1 and ht4 == 1 and math.abs(hp0 - hp2) < atr * 2 and hp3 < hp1 * 1.02

shapeTri   = math.min(55.0, math.max(0.0, math.abs(compression) + math.abs(upperSlope / atr) * 12 + math.abs(lowerSlope / atr) * 12))
shapeBase  = 45.0

noneTxt = "NONE"

classicName = noneTxt
classicBias = "WAIT"
classicShape = 0.0
classicFib = 0.0
classicContext = 0.0
classicFinal = 0.0
classicCol = DARK
float classicTarget = na
float classicInvalid = na

if ascTriangle
    classicName := "ASCENDING TRIANGLE"
    classicBias := "BULL"
    classicShape := shapeTri
    classicFib := fibBullScore
    classicContext := contextBullScore
    classicTarget := upperRight + widthLeft
    classicInvalid := lowerRight - atr
    classicCol := LIME
else if descTriangle
    classicName := "DESCENDING TRIANGLE"
    classicBias := "BEAR"
    classicShape := shapeTri
    classicFib := fibBearScore
    classicContext := contextBearScore
    classicTarget := lowerRight - widthLeft
    classicInvalid := upperRight + atr
    classicCol := RED
else if symTriangle
    classicName := "SYMMETRIC TRIANGLE"
    classicBias := "MIXED"
    classicShape := shapeTri
    classicFib := math.max(fibBullScore, fibBearScore)
    classicContext := math.max(contextBullScore, contextBearScore)
    classicTarget := close + widthLeft
    classicInvalid := loNow - atr
    classicCol := YELLOW
else if pennantBull or pennantBear
    classicName := "PENNANT"
    classicBias := pennantBull ? "BULL" : "BEAR"
    classicShape := shapeTri
    classicFib := pennantBull ? fibBullScore : fibBearScore
    classicContext := pennantBull ? contextBullScore : contextBearScore
    classicTarget := pennantBull ? close + widthLeft : close - widthLeft
    classicInvalid := pennantBull ? lowerRight - atr : upperRight + atr
    classicCol := pennantBull ? LIME : RED
else if flagBull or flagBear
    classicName := "FLAG"
    classicBias := flagBull ? "BULL" : "BEAR"
    classicShape := shapeBase
    classicFib := flagBull ? fibBullScore : fibBearScore
    classicContext := flagBull ? contextBullScore : contextBearScore
    classicTarget := flagBull ? close + widthLeft : close - widthLeft
    classicInvalid := flagBull ? lowerRight - atr : upperRight + atr
    classicCol := flagBull ? LIME : RED
else if wPattern or doubleBottom
    classicName := wPattern ? "W PATTERN" : "DOUBLE BOTTOM"
    classicBias := "BULL"
    classicShape := shapeBase
    classicFib := fibBullScore
    classicContext := contextBullScore
    classicTarget := close + (close - recentLow)
    classicInvalid := recentLow - atr
    classicCol := LIME
else if mPattern or doubleTop
    classicName := mPattern ? "M PATTERN" : "DOUBLE TOP"
    classicBias := "BEAR"
    classicShape := shapeBase
    classicFib := fibBearScore
    classicContext := contextBearScore
    classicTarget := close - (recentHigh - close)
    classicInvalid := recentHigh + atr
    classicCol := RED
else if tobo
    classicName := "TOBO"
    classicBias := "BULL"
    classicShape := shapeBase
    classicFib := fibBullScore
    classicContext := contextBullScore
    classicTarget := close + (lsL - headLow)
    classicInvalid := headLow - atr
    classicCol := LIME
else if obo
    classicName := "OBO"
    classicBias := "BEAR"
    classicShape := shapeBase
    classicFib := fibBearScore
    classicContext := contextBearScore
    classicTarget := close - (headHigh - lsH)
    classicInvalid := headHigh + atr
    classicCol := RED

classicFinal := math.min(100.0, classicShape + classicFib + classicContext)
classicFound = classicName != noneTxt

//━━━━━━━━━━━━━━━━━━━
// HARMONIC ENGINE
//━━━━━━━━━━━━━━━━━━━
realHas5 = array.size(realP) >= 5

X = realHas5 ? array.get(realP, array.size(realP) - 5) : na
A = realHas5 ? array.get(realP, array.size(realP) - 4) : na
B = realHas5 ? array.get(realP, array.size(realP) - 3) : na
C = realHas5 ? array.get(realP, array.size(realP) - 2) : na
D = realHas5 ? array.get(realP, array.size(realP) - 1) : na

Xx = realHas5 ? array.get(realX, array.size(realX) - 5) : na
Ax = realHas5 ? array.get(realX, array.size(realX) - 4) : na
Bx = realHas5 ? array.get(realX, array.size(realX) - 3) : na
Cx = realHas5 ? array.get(realX, array.size(realX) - 2) : na
Dx = realHas5 ? array.get(realX, array.size(realX) - 1) : na

Xt = realHas5 ? array.get(realT, array.size(realT) - 5) : na
At = realHas5 ? array.get(realT, array.size(realT) - 4) : na
Bt = realHas5 ? array.get(realT, array.size(realT) - 3) : na
Ct = realHas5 ? array.get(realT, array.size(realT) - 2) : na
Dt = realHas5 ? array.get(realT, array.size(realT) - 1) : na

bullXABCD = realHas5 and Xt == -1 and At == 1 and Bt == -1 and Ct == 1 and Dt == -1
bearXABCD = realHas5 and Xt == 1 and At == -1 and Bt == 1 and Ct == -1 and Dt == 1

xa = realHas5 ? math.abs(A - X) : na
ab = realHas5 ? math.abs(B - A) : na
bc = realHas5 ? math.abs(C - B) : na
cd = realHas5 ? math.abs(D - C) : na
xc = realHas5 ? math.abs(C - X) : na

rAB_XA = xa > 0 ? ab / xa : na
rBC_AB = ab > 0 ? bc / ab : na
rD_XA  = xa > 0 ? math.abs(D - X) / xa : na
rC_XA  = xa > 0 ? math.abs(C - X) / xa : na
rD_XC  = xc > 0 ? math.abs(D - X) / xc : na
rCD_AB = ab > 0 ? cd / ab : na

harmonicDir = bullXABCD ? 1 : bearXABCD ? -1 : 0

isABCD = realHas5 and (bullXABCD or bearXABCD) and f_between(rBC_AB, 0.382, 0.886) and f_between(rCD_AB, 0.85, 1.15)
isGartley = realHas5 and (bullXABCD or bearXABCD) and f_near(rAB_XA, 0.618, 0.12) and f_between(rBC_AB, 0.382, 0.886) and f_near(rD_XA, 0.786, 0.12)
isBat = realHas5 and (bullXABCD or bearXABCD) and f_between(rAB_XA, 0.382, 0.50) and f_between(rBC_AB, 0.382, 0.886) and f_near(rD_XA, 0.886, 0.12)
isButterfly = realHas5 and (bullXABCD or bearXABCD) and f_near(rAB_XA, 0.786, 0.12) and f_between(rD_XA, 1.20, 1.75)
isCrab = realHas5 and (bullXABCD or bearXABCD) and f_between(rAB_XA, 0.382, 0.618) and f_near(rD_XA, 1.618, 0.20)
isCypher = realHas5 and (bullXABCD or bearXABCD) and f_between(rAB_XA, 0.382, 0.618) and f_between(rC_XA, 1.20, 1.55) and f_near(rD_XC, 0.786, 0.15)

harmonicName = noneTxt
harmonicScore = 0.0

if isGartley
    harmonicName := "GARTLEY"
    harmonicScore := 72.0
else if isBat
    harmonicName := "BAT"
    harmonicScore := 70.0
else if isButterfly
    harmonicName := "BUTTERFLY"
    harmonicScore := 68.0
else if isCrab
    harmonicName := "CRAB"
    harmonicScore := 70.0
else if isCypher
    harmonicName := "CYPHER"
    harmonicScore := 66.0
else if isABCD
    harmonicName := "ABCD"
    harmonicScore := 60.0

harmonicFound = harmonicName != noneTxt
harmonicContext = harmonicFound ? (harmonicDir == 1 ? contextBullScore : contextBearScore) : 0.0
harmonicFinal = harmonicFound ? math.min(100.0, harmonicScore + harmonicContext) : 0.0
harmonicCol = harmonicDir == 1 ? LIME : harmonicDir == -1 ? RED : GRAY

harmonicBias =
     harmonicFound ? harmonicDir == 1 ? "BULLISH HARMONIC" : "BEARISH HARMONIC" :
     "NO HARMONIC"

ratioText =
     harmonicFound ? "AB/XA " + str.tostring(rAB_XA, "#.###") + " | BC/AB " + str.tostring(rBC_AB, "#.###") + " | D/XA " + str.tostring(rD_XA, "#.###") :
     "-"

//━━━━━━━━━━━━━━━━━━━
// FORMATION CONSENSUS
//━━━━━━━━━━━━━━━━━━━
classicBull = ascTriangle or pennantBull or flagBull or wPattern or doubleBottom or tobo
classicBear = descTriangle or pennantBear or flagBear or mPattern or doubleTop or obo

classicGreen = classicBull and classicFinal >= minClassicFinal
classicRed   = classicBear and classicFinal >= minClassicFinal

harmonicGreen = harmonicFound and harmonicDir == 1 and harmonicFinal >= minHarmonicFinal
harmonicRed   = harmonicFound and harmonicDir == -1 and harmonicFinal >= minHarmonicFinal

barsClassicGreen = ta.barssince(classicGreen)
barsHarmGreen    = ta.barssince(harmonicGreen)
barsClassicRed   = ta.barssince(classicRed)
barsHarmRed      = ta.barssince(harmonicRed)

bullSync = not na(barsClassicGreen) and not na(barsHarmGreen) and barsClassicGreen <= syncBars and barsHarmGreen <= syncBars
bearSync = not na(barsClassicRed) and not na(barsHarmRed) and barsClassicRed <= syncBars and barsHarmRed <= syncBars

formationTxt = "WAIT"
formationCol = GRAY

if bullSync and not bearSync
    formationTxt := "BULL SYNC"
    formationCol := LIME
else if bearSync and not bullSync
    formationTxt := "BEAR SYNC"
    formationCol := RED
else if bullSync and bearSync
    formationTxt := "CONFLICT"
    formationCol := ORANGE
else if classicGreen and not classicRed
    formationTxt := "CLASSIC BULL"
    formationCol := LIME
else if classicRed and not classicGreen
    formationTxt := "CLASSIC BEAR"
    formationCol := RED
else if harmonicGreen and not harmonicRed
    formationTxt := "HARMONIC BULL"
    formationCol := LIME
else if harmonicRed and not harmonicGreen
    formationTxt := "HARMONIC BEAR"
    formationCol := RED
else if (classicGreen and harmonicRed) or (classicRed and harmonicGreen)
    formationTxt := "CONFLICT"
    formationCol := ORANGE

formationScore = math.max(classicFinal, harmonicFinal)

//━━━━━━━━━━━━━━━━━━━
// GAE COLORS
//━━━━━━━━━━━━━━━━━━━
bullCol = voteCount == 4 ? color.rgb(255, 215, 0) : voteCount == 3 ? YELLOW : color.new(YELLOW, 35)
bearCol = voteCount == 4 ? color.rgb(0, 191, 255) : voteCount == 3 ? AQUA : color.new(AQUA, 35)

mainCol = mtfDir == 1 ? bullCol : bearCol
slowCol = mtfDir == 1 ? color.new(YELLOW, 45) : color.new(AQUA, 45)

fillCol =
     mtfDir == 1 ? color.new(YELLOW, voteCount == 4 ? 82 : voteCount == 3 ? 88 : 92) :
     color.new(AQUA, voteCount == 4 ? 82 : voteCount == 3 ? 88 : 92)

//━━━━━━━━━━━━━━━━━━━
// PLOTS
//━━━━━━━━━━━━━━━━━━━
plot(voteCount == 4 ? fastRail : na, "Grand Fast Rail 4/4", color=mainCol, linewidth=6, style=plot.style_linebr)
plot(voteCount == 3 ? fastRail : na, "Grand Fast Rail 3/4", color=mainCol, linewidth=4, style=plot.style_linebr)
plot(voteCount <= 2 ? fastRail : na, "Grand Fast Rail 2/4", color=mainCol, linewidth=2, style=plot.style_linebr)

pFastFill = plot(fastRail, "Grand Fast Fill Base", color=color.new(mainCol, 100), linewidth=1, style=plot.style_linebr)
pSlow = plot(slowRail, "Grand Slow Rail", color=slowCol, linewidth=2, style=plot.style_linebr)

fill(pFastFill, pSlow, color=showFill ? fillCol : na, title="MTF Grand Cloud")

// Formation drawing optional
var line[] formLines = array.new_line()
var label[] formLabels = array.new_label()

f_clear_forms() =>
    while array.size(formLines) > 0
        line.delete(array.pop(formLines))
    while array.size(formLabels) > 0
        label.delete(array.pop(formLabels))

f_form_line(x1, y1, x2, y2, col, w) =>
    ln = line.new(x1, y1, x2, y2, xloc=xloc.bar_index, color=col, width=w)
    array.push(formLines, ln)
    ln

f_form_label(x, y, txt, col, isUp) =>
    sty = isUp ? label.style_label_up : label.style_label_down
    lb = label.new(x, y, txt, xloc=xloc.bar_index, style=sty, color=col, textcolor=color.white, size=size.small)
    array.push(formLabels, lb)
    lb

if barstate.islast
    f_clear_forms()

    if showFormationDraw and (symTriangle or ascTriangle or descTriangle or pennantBull or pennantBear or flagBull or flagBear)
        f_form_line(leftX, upperLeft, rightX, upperRight, classicCol, 2)
        f_form_line(leftX, lowerLeft, rightX, lowerRight, classicCol, 2)

    if showFormationDraw and harmonicFound
        f_form_line(Xx, X, Ax, A, harmonicCol, 2)
        f_form_line(Ax, A, Bx, B, harmonicCol, 2)
        f_form_line(Bx, B, Cx, C, harmonicCol, 2)
        f_form_line(Cx, C, Dx, D, harmonicCol, 3)

    if showFormationLabels and classicFound
        f_form_label(bar_index, classicGreen ? low - atr : high + atr, classicName + "\nQ: " + str.tostring(math.round(classicFinal)) + "/100", classicCol, classicGreen)

    if showFormationLabels and harmonicFound
        f_form_label(Dx, D, harmonicName + "\nQ: " + str.tostring(math.round(harmonicFinal)) + "/100", harmonicCol, harmonicDir == 1)

//━━━━━━━━━━━━━━━━━━━
// SIGNALS
//━━━━━━━━━━━━━━━━━━━
buySignal  = showSignals and buyFlip and bullVotes >= 3
sellSignal = showSignals and sellFlip and bearVotes >= 3

strongBuy  = buySignal and useSmcStrong and bullSmcScore >= smcStrongMin
strongSell = sellSignal and useSmcStrong and bearSmcScore >= smcStrongMin

plotshape(buySignal and not strongBuy, title="MTF Buy", style=shape.labelup, location=location.belowbar, color=YELLOW, text="B", textcolor=color.black, size=size.small)
plotshape(sellSignal and not strongSell, title="MTF Sell", style=shape.labeldown, location=location.abovebar, color=AQUA, text="S", textcolor=color.black, size=size.small)

plotshape(strongBuy, title="SMC Strong Buy", style=shape.labelup, location=location.belowbar, color=color.rgb(0,255,120), text="SB", textcolor=color.black, size=size.normal)
plotshape(strongSell, title="SMC Strong Sell", style=shape.labeldown, location=location.abovebar, color=color.rgb(255,40,40), text="SS", textcolor=color.white, size=size.normal)

//━━━━━━━━━━━━━━━━━━━
// ALIGNMENT TEST
//━━━━━━━━━━━━━━━━━━━
validTest = bar_index > testForward
entryPrice = close[testForward]

flipAlign = buySignal ? bullVotes : sellSignal ? bearVotes : 0

pastBuyFlip  = validTest and buySignal[testForward]
pastSellFlip = validTest and sellSignal[testForward]
pastAlign    = flipAlign[testForward]

pastFlip3 = (pastBuyFlip or pastSellFlip) and pastAlign >= 3
pastFlip4 = (pastBuyFlip or pastSellFlip) and pastAlign == 4

forwardHigh = ta.highest(high, testForward)
forwardLow  = ta.lowest(low, testForward)

allExc =
     pastBuyFlip and entryPrice > 0 ? (forwardHigh - entryPrice) / entryPrice * 100.0 :
     pastSellFlip and entryPrice > 0 ? (entryPrice - forwardLow) / entryPrice * 100.0 :
     na

exc3 = pastFlip3 ? allExc : na
exc4 = pastFlip4 ? allExc : na

allCount = math.sum((pastBuyFlip or pastSellFlip) ? 1.0 : 0.0, testBars)
allHits  = math.sum(not na(allExc) and allExc >= hitTarget ? 1.0 : 0.0, testBars)
allMove  = math.sum(nz(allExc, 0.0), testBars)

align3Count = math.sum(pastFlip3 ? 1.0 : 0.0, testBars)
align3Hits  = math.sum(not na(exc3) and exc3 >= hitTarget ? 1.0 : 0.0, testBars)
align3Move  = math.sum(nz(exc3, 0.0), testBars)

align4Count = math.sum(pastFlip4 ? 1.0 : 0.0, testBars)
align4Hits  = math.sum(not na(exc4) and exc4 >= hitTarget ? 1.0 : 0.0, testBars)
align4Move  = math.sum(nz(exc4, 0.0), testBars)

allRate = allCount > 0 ? allHits / allCount * 100.0 : 0.0
align3Rate = align3Count > 0 ? align3Hits / align3Count * 100.0 : 0.0
align4Rate = align4Count > 0 ? align4Hits / align4Count * 100.0 : 0.0

allAvg = allCount > 0 ? allMove / allCount : 0.0
align3Avg = align3Count > 0 ? align3Move / align3Count : 0.0
align4Avg = align4Count > 0 ? align4Move / align4Count : 0.0

//━━━━━━━━━━━━━━━━━━━
// GAE PANEL
//━━━━━━━━━━━━━━━━━━━
var table pan = table.new(position.top_right, 2, 7, border_width=1)

if showPanel and barstate.islast
    table.cell(pan, 0, 0, "GRAND MTF", text_color=color.white, bgcolor=color.black)
    table.cell(pan, 1, 0, trendText, text_color=mainCol, bgcolor=color.black)

    table.cell(pan, 0, 1, tf1, text_color=color.white)
    table.cell(pan, 1, 1, s1 == 1 ? "BULL" : "BEAR", text_color=s1 == 1 ? YELLOW : AQUA)

    table.cell(pan, 0, 2, tf2, text_color=color.white)
    table.cell(pan, 1, 2, s2 == 1 ? "BULL" : "BEAR", text_color=s2 == 1 ? YELLOW : AQUA)

    table.cell(pan, 0, 3, tf3, text_color=color.white)
    table.cell(pan, 1, 3, s3 == 1 ? "BULL" : "BEAR", text_color=s3 == 1 ? YELLOW : AQUA)

    table.cell(pan, 0, 4, tf4, text_color=color.white)
    table.cell(pan, 1, 4, s4 == 1 ? "BULL" : "BEAR", text_color=s4 == 1 ? YELLOW : AQUA)

    voteTxt = mtfDir == 1 ? str.tostring(bullVotes) + "/4 BULL" : str.tostring(bearVotes) + "/4 BEAR"
    table.cell(pan, 0, 5, "VOTE", text_color=color.white)
    table.cell(pan, 1, 5, voteTxt, text_color=mainCol)

    smcTxt = mtfDir == 1 ? str.tostring(bullSmcScore) + "/100 BULL" : str.tostring(bearSmcScore) + "/100 BEAR"
    smcCol = activeSmcScore >= smcStrongMin ? ORANGE : activeSmcScore >= 30 ? mainCol : GRAY
    table.cell(pan, 0, 6, "SMC", text_color=color.white)
    table.cell(pan, 1, 6, smcTxt, text_color=smcCol)

//━━━━━━━━━━━━━━━━━━━
// FORMATION PANEL — ORTA BOŞLUK
//━━━━━━━━━━━━━━━━━━━
var table formPan = table.new(position.middle_left, 2, 8, border_width=1)

if showFormationPanel and barstate.islast
    table.cell(formPan, 0, 0, "FORMATION", text_color=color.white, bgcolor=color.black)
    table.cell(formPan, 1, 0, formationTxt, text_color=formationCol, bgcolor=color.black)

    table.cell(formPan, 0, 1, "Classic", text_color=color.white, bgcolor=rowBg(1))
    table.cell(formPan, 1, 1, classicName, text_color=color.white, bgcolor=color.new(classicCol, 20))

    table.cell(formPan, 0, 2, "C Bias", text_color=color.white, bgcolor=rowBg(2))
    table.cell(formPan, 1, 2, classicBias, text_color=color.white, bgcolor=color.new(classicCol, 35))

    table.cell(formPan, 0, 3, "C Score", text_color=color.white, bgcolor=rowBg(3))
    table.cell(formPan, 1, 3, str.tostring(math.round(classicFinal)) + "/100", text_color=color.white, bgcolor=color.new(f_gradeColor(classicFinal), 25))

    table.cell(formPan, 0, 4, "Harmonic", text_color=color.white, bgcolor=rowBg(4))
    table.cell(formPan, 1, 4, harmonicName, text_color=color.white, bgcolor=color.new(harmonicCol, 25))

    table.cell(formPan, 0, 5, "H Score", text_color=color.white, bgcolor=rowBg(5))
    table.cell(formPan, 1, 5, harmonicFound ? str.tostring(math.round(harmonicFinal)) + "/100" : "-", text_color=color.white, bgcolor=color.new(harmonicCol, 25))

    table.cell(formPan, 0, 6, "Sync", text_color=color.white, bgcolor=rowBg(6))
    table.cell(formPan, 1, 6, formationTxt, text_color=color.white, bgcolor=color.new(formationCol, 10))

    table.cell(formPan, 0, 7, "Final", text_color=color.white, bgcolor=color.black)
    table.cell(formPan, 1, 7, f_grade(formationScore), text_color=color.white, bgcolor=color.new(f_gradeColor(formationScore), 15))

//━━━━━━━━━━━━━━━━━━━
// TEST PANEL
//━━━━━━━━━━━━━━━━━━━
var table testPan = table.new(position.bottom_right, 3, 5, border_width=1)

if showTest and barstate.islast
    table.cell(testPan, 0, 0, "FLIP TEST", text_color=color.white, bgcolor=color.black)
    table.cell(testPan, 1, 0, "HIT", text_color=color.white, bgcolor=color.black)
    table.cell(testPan, 2, 0, "AVG", text_color=color.white, bgcolor=color.black)

    table.cell(testPan, 0, 1, "ALL / " + str.tostring(allCount, "#"), text_color=color.white)
    table.cell(testPan, 1, 1, str.tostring(allRate, "#.0") + "%", text_color=YELLOW)
    table.cell(testPan, 2, 1, str.tostring(allAvg, "#.##") + "%", text_color=YELLOW)

    table.cell(testPan, 0, 2, "3/4 / " + str.tostring(align3Count, "#"), text_color=color.white)
    table.cell(testPan, 1, 2, str.tostring(align3Rate, "#.0") + "%", text_color=YELLOW)
    table.cell(testPan, 2, 2, str.tostring(align3Avg, "#.##") + "%", text_color=YELLOW)

    table.cell(testPan, 0, 3, "4/4 / " + str.tostring(align4Count, "#"), text_color=color.white)
    table.cell(testPan, 1, 3, str.tostring(align4Rate, "#.0") + "%", text_color=AQUA)
    table.cell(testPan, 2, 3, str.tostring(align4Avg, "#.##") + "%", text_color=AQUA)

    table.cell(testPan, 0, 4, "Target", text_color=color.white)
    table.cell(testPan, 1, 4, str.tostring(hitTarget, "#.##") + "%", text_color=YELLOW)
    table.cell(testPan, 2, 4, str.tostring(testForward) + " bars", text_color=YELLOW)

//━━━━━━━━━━━━━━━━━━━
// ALERTS
//━━━━━━━━━━━━━━━━━━━
alertcondition(buySignal, "Grand MTF Buy", "Grand MTF bullish buy signal")
alertcondition(sellSignal, "Grand MTF Sell", "Grand MTF bearish sell signal")
alertcondition(strongBuy, "SMC Strong Buy", "Grand MTF bullish signal with SMC quality")
alertcondition(strongSell, "SMC Strong Sell", "Grand MTF bearish signal with SMC quality")
alertcondition(formationTxt == "BULL SYNC", "Formation Bull Sync", "Classic and Harmonic bullish sync")
alertcondition(formationTxt == "BEAR SYNC", "Formation Bear Sync", "Classic and Harmonic bearish sync")
````
