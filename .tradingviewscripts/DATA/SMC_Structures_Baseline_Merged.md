<!-- tradingview-pine-id: PUB;8438d0ba9f3745efbebb5bacab2a2210 -->
<!-- tradingviewscripts-format: 1 -->
# SMC Structures + Baseline [Merged]

Source: https://www.tradingview.com/script/5NHS9eqO/

## Description

SMC Structures + Baseline pro Tuấn Anh
etLineStyle(lineOption) =>
    lineOption == "┈" ? line.style_dotted : lineOption == "╌" ? line.style_dashed : line.style_solid

get_structure_highest_bar(lookback) =>
    var int idx = 0
    maxBar = bar_index > lookback ? ta.highestbars(high, lookback) : ta.highestbars(high, bar_index + 1)
    for i = 0 to lookback - 1 by 1
        if high[i+1] > high[i+2] and high <= high[i+1] and ((i+1) * -1) >= maxBar
            idx := (i+1) * -1
    idx := idx == 0 ? maxBar : idx

get_structure_lowest_bar(lookback) =>
    var int idx = 0
    minBar = bar_index > lookback ? ta.lowestbars(low, lookback) : ta.lowestbars(low, bar_index + 1)
    for i = 0 to lookback - 1 by 1
        if low[i+1] < low[i+2] and low >= low[i+1] and ((i+1) * -1) >= minBar
            idx := (i+1) * -1
    idx := idx == 0 ? minBar : idx

// ── JMA (Jurik Moving Average) ──────────────────────────────────
jma(src, length, power, phase) =>
    phaseRatio = phase < -100 ? 0.5 : phase > 100 ? 2.5 : phase / 100 + 1.5
    beta  = 0.45 * (length - 1) / (0.45 * (length - 1) + 2)
    alpha = math.pow(beta, power)
    var float jmaVal = 0.0
    var float e0     = 0.0
    var float e1     = 0.0
    var float e2     = 0.0
    e0    := (1 - alpha) * src + alpha * nz(e0[1])
    e1    := (src - e0) * (1 - beta) + beta * nz(e1[1])
    e2    := (e0 + phaseRatio * e1 - nz(jmaVal[1])) * math.pow(1 - alpha, 2) + math.pow(alpha, 2) * nz(e2[1])
    jmaVal := e2 + nz(jmaVal[1])
    jmaVal

---

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © LudoGH68 | Merged with Baseline-C [ID: AC-P] concepts by Auroagwei
//@version=6
indicator("SMC Structures + Baseline [Merged]", overlay = true)
import LudoGH68/Drawings_public/1 as d

// ==========================================================================================
//                                   HELPER FUNCTIONS
// ==========================================================================================

getLineStyle(lineOption) =>
    lineOption == "┈" ? line.style_dotted : lineOption == "╌" ? line.style_dashed : line.style_solid

get_structure_highest_bar(lookback) =>
    var int idx = 0
    maxBar = bar_index > lookback ? ta.highestbars(high, lookback) : ta.highestbars(high, bar_index + 1)
    for i = 0 to lookback - 1 by 1
        if high[i+1] > high[i+2] and high[i] <= high[i+1] and ((i+1) * -1) >= maxBar
            idx := (i+1) * -1
    idx := idx == 0 ? maxBar : idx

get_structure_lowest_bar(lookback) =>
    var int idx = 0
    minBar = bar_index > lookback ? ta.lowestbars(low, lookback) : ta.lowestbars(low, bar_index + 1)
    for i = 0 to lookback - 1 by 1
        if low[i+1] < low[i+2] and low[i] >= low[i+1] and ((i+1) * -1) >= minBar
            idx := (i+1) * -1
    idx := idx == 0 ? minBar : idx

// ── JMA (Jurik Moving Average) ──────────────────────────────────
jma(src, length, power, phase) =>
    phaseRatio = phase < -100 ? 0.5 : phase > 100 ? 2.5 : phase / 100 + 1.5
    beta  = 0.45 * (length - 1) / (0.45 * (length - 1) + 2)
    alpha = math.pow(beta, power)
    var float jmaVal = 0.0
    var float e0     = 0.0
    var float e1     = 0.0
    var float e2     = 0.0
    e0    := (1 - alpha) * src + alpha * nz(e0[1])
    e1    := (src - e0) * (1 - beta) + beta * nz(e1[1])
    e2    := (e0 + phaseRatio * e1 - nz(jmaVal[1])) * math.pow(1 - alpha, 2) + math.pow(alpha, 2) * nz(e2[1])
    jmaVal := e2 + nz(jmaVal[1])
    jmaVal

// ── Universal MA dispatcher ──────────────────────────────────────
ma(maType, src, len, pw, ph) =>
    float result = 0.0
    if maType == "SMA"
        result := ta.sma(src, len)
    else if maType == "EMA"
        result := ta.ema(src, len)
    else if maType == "DEMA"
        e = ta.ema(src, len)
        result := 2 * e - ta.ema(e, len)
    else if maType == "TEMA"
        e = ta.ema(src, len)
        result := 3 * (e - ta.ema(e, len)) + ta.ema(ta.ema(e, len), len)
    else if maType == "WMA"
        result := ta.wma(src, len)
    else if maType == "VWMA"
        result := ta.vwma(src, len)
    else if maType == "HMA"
        result := ta.wma(2 * ta.wma(src, len / 2) - ta.wma(src, len), math.round(math.sqrt(len)))
    else if maType == "Kijun"
        result := math.avg(ta.lowest(len), ta.highest(len))
    else if maType == "McGinley"
        var float mg = 0.0
        mgSeed = ta.ema(src, len)
        mg := na(mg[1]) ? mgSeed : mg[1] + (src - mg[1]) / (len * math.pow(src / mg[1], 4))
        result := mg
    else if maType == "JMA"
        result := jma(src, len, pw, ph)
    result

// ==========================================================================================
//                              INPUT GROUPS
// ==========================================================================================

// ── MA 1 (formerly EMA 1) ───────────────────────────────────────
var string GRP_MA1 = "MA Line 1"
isMa1ToShow     = input.bool  (true,    title="Display MA 1",    group=GRP_MA1)
ma1Type         = input.string("EMA",   title="MA 1 Type",       group=GRP_MA1, options=["SMA","EMA","DEMA","TEMA","WMA","VWMA","HMA","Kijun","McGinley","JMA"])
ma1Length       = input.int   (21,      title="Length",          group=GRP_MA1, minval=1)
ma1Source       = input.source(close,   title="Source",          group=GRP_MA1)
ma1Phase        = input.float (5.0,     title="Phase (JMA)",     group=GRP_MA1, step=0.1, minval=-100, maxval=100)
ma1Power        = input.int   (2,       title="Power (JMA)",     group=GRP_MA1, minval=1)
ma1Color        = input.color (color.new(color.orange, 0), title="Color", group=GRP_MA1)
ma1StyleOpt     = input.string("─",    title="Style",           group=GRP_MA1, options=["─","┈","╌"])
ma1Width        = input.int   (2,       title="Width",           group=GRP_MA1, minval=1, maxval=5)
showMa1Glow     = input.bool  (false,   title="Show MA 1 Glow",  group=GRP_MA1)
showMa1Cross    = input.bool  (true,    title="Cross Signals (shapes)", group=GRP_MA1)
showMa1BarColor = input.bool  (false,   title="Bar Color on Cross", group=GRP_MA1)

// ── MA 2 (formerly EMA 2) ───────────────────────────────────────
var string GRP_MA2 = "MA Line 2"
isMa2ToShow     = input.bool  (true,    title="Display MA 2",    group=GRP_MA2)
ma2Type         = input.string("JMA",   title="MA 2 Type",       group=GRP_MA2, options=["SMA","EMA","DEMA","TEMA","WMA","VWMA","HMA","Kijun","McGinley","JMA"])
ma2Length       = input.int   (70,      title="Length",          group=GRP_MA2, minval=1)
ma2Source       = input.source(close,   title="Source",          group=GRP_MA2)
ma2Phase        = input.float (5.0,     title="Phase (JMA)",     group=GRP_MA2, step=0.1, minval=-100, maxval=100)
ma2Power        = input.int   (2,       title="Power (JMA)",     group=GRP_MA2, minval=1)
ma2Color        = input.color (color.new(color.yellow, 0), title="Color", group=GRP_MA2)
ma2StyleOpt     = input.string("─",    title="Style",           group=GRP_MA2, options=["─","┈","╌"])
ma2Width        = input.int   (2,       title="Width",           group=GRP_MA2, minval=1, maxval=5)
showMa2Glow     = input.bool  (true,    title="Show MA 2 Glow",  group=GRP_MA2)
showMa2Cross    = input.bool  (true,    title="Cross Signals (shapes)", group=GRP_MA2)
showMa2BarColor = input.bool  (true,    title="Bar Color on Cross", group=GRP_MA2)

// ── EMA 3 ───────────────────────────────────────────────────────
var string GRP_EMA3 = "EMA Line 3"
isEma3ToShow    = input.bool  (true,    title="Display EMA 3",   group=GRP_EMA3)
ema3Length      = input.int   (100,     title="Length",          group=GRP_EMA3, minval=1)
ema3Source      = input.source(close,   title="Source",          group=GRP_EMA3)
ema3Color       = input.color (color.new(color.aqua, 0), title="Color", group=GRP_EMA3)
ema3StyleOpt    = input.string("─",    title="Style",           group=GRP_EMA3, options=["─","┈","╌"])
ema3Width       = input.int   (1,       title="Width",           group=GRP_EMA3, minval=1, maxval=5)

// ── EMA 4 ───────────────────────────────────────────────────────
var string GRP_EMA4 = "EMA Line 4"
isEma4ToShow    = input.bool  (true,    title="Display EMA 4",   group=GRP_EMA4)
ema4Length      = input.int   (200,     title="Length",          group=GRP_EMA4, minval=1)
ema4Source      = input.source(close,   title="Source",          group=GRP_EMA4)
ema4Color       = input.color (color.new(color.fuchsia, 0), title="Color", group=GRP_EMA4)
ema4StyleOpt    = input.string("─",    title="Style",           group=GRP_EMA4, options=["─","┈","╌"])
ema4Width       = input.int   (1,       title="Width",           group=GRP_EMA4, minval=1, maxval=5)

// ── ATR ─────────────────────────────────────────────────────────
var string GRP_ATR = "ATR Bands"
showAtrPrice    = input.bool  (false,   title="Show ATR Bands (Price-based)", group=GRP_ATR)
showAtrBl       = input.bool  (true,    title="Show ATR Bands 1x (MA2-based)", group=GRP_ATR)
showAtrBl15     = input.bool  (true,    title="Show ATR Bands 1.5x (MA2-based)", group=GRP_ATR)
showAtrRule     = input.bool  (false,   title="Show ATR Violation Marker",    group=GRP_ATR)
atrMultViol     = input.float (1.0,     title="ATR Violation Multiplier",     group=GRP_ATR, step=0.1)
atrLength       = input.int   (14,      title="ATR Length",                   group=GRP_ATR, minval=1)
atrSmoothing    = input.string("JMA",   title="ATR Smoothing",                group=GRP_ATR, options=["RMA","SMA","EMA","WMA","JMA"])
atrPhase        = input.float (0.0,     title="ATR Phase (JMA)",              group=GRP_ATR, step=0.1, minval=-100, maxval=100)
atrPower        = input.int   (1,       title="ATR Power (JMA)",              group=GRP_ATR, minval=1)
atrBandColor    = input.color (color.new(color.navy, 50),   title="ATR 1x Band Color",   group=GRP_ATR)
atrBand15Color  = input.color (color.new(color.orange, 80), title="ATR 1.5x Band Color", group=GRP_ATR)

// ── SSL Channel ─────────────────────────────────────────────────
var string GRP_SSL = "SSL Channel"
showSsl         = input.bool  (false,   title="Show SSL Channel",   group=GRP_SSL)
sslLength       = input.int   (20,      title="SSL Length",         group=GRP_SSL, minval=1)
sslUpColor      = input.color (color.new(color.lime, 50),  title="SSL Up Color",   group=GRP_SSL)
sslDownColor    = input.color (color.new(color.red,  50),  title="SSL Down Color", group=GRP_SSL)

// ── Volume POC ──────────────────────────────────────────────────
var string GRP_POC = "Volume POC"
showPoc         = input.bool  (true,    title="Show POC (Current TF)",   group=GRP_POC)
showPoc12       = input.bool  (true,    title="Show POC (12H TF)",       group=GRP_POC)
pocPeriods      = input.int   (25,      title="POC Volume Periods",      group=GRP_POC, minval=1)
poc12Periods    = input.int   (25,      title="POC Volume Periods (12H)",group=GRP_POC, minval=1)
pocColor        = input.color (color.new(color.gray,  0), title="POC Color",     group=GRP_POC)
poc12Color      = input.color (color.new(color.white, 0), title="POC 12H Color", group=GRP_POC)

// ── FVG ─────────────────────────────────────────────────────────
var string GRP_FVG = "Fair Value Gap (FVG)"
isFvgToShow           = input.bool  (true,  title="Display FVG",         group=GRP_FVG)
bullishFvgColor       = input.color (color.new(color.green, 50), title="Bullish FVG Color",   group=GRP_FVG)
bearishFvgColor       = input.color (color.new(color.red,   50), title="Bearish FVG Color",   group=GRP_FVG)
mitigatedFvgColor     = input.color (color.new(color.gray,  50), title="Mitigated FVG Color", group=GRP_FVG)
fvgHistoryNbr         = input.int   (5,     title="Max FVG to show",     group=GRP_FVG, minval=1, maxval=50)
isMitigatedFvgToReduce= input.bool  (false, title="Reduce mitigated FVG",group=GRP_FVG)

// ── Structures ──────────────────────────────────────────────────
var string GRP_STR = "Structures"
isStructBodyCandleBreak   = input.bool   (true,          title="Break with candle body",       group=GRP_STR)
isCurrentStructToShow     = input.bool   (true,          title="Display current structure",     group=GRP_STR)
bullishBosColor           = input.color  (color.silver,  title="Bullish BOS Color",             group=GRP_STR)
bearishBosColor           = input.color  (color.silver,  title="Bearish BOS Color",             group=GRP_STR)
bosLineStyleOption        = input.string ("─",           title="BOS Style",                     group=GRP_STR, options=["─","┈","╌"])
bosLineWidth              = input.int    (1,             title="BOS Width",                     group=GRP_STR, minval=1, maxval=5)
bullishChochColor         = input.color  (color.yellow,  title="Bullish CHoCH Color",           group=GRP_STR)
bearishChochColor         = input.color  (color.yellow,  title="Bearish CHoCH Color",           group=GRP_STR)
chochLineStyleOption      = input.string ("─",           title="CHoCH Style",                   group=GRP_STR, options=["─","┈","╌"])
chochLineWidth            = input.int    (1,             title="CHoCH Width",                   group=GRP_STR, minval=1, maxval=5)
currentStructColor        = input.color  (color.blue,    title="Current Structure Color",       group=GRP_STR)
currentStructLineStyleOpt = input.string ("─",           title="Current Structure Style",       group=GRP_STR, options=["─","┈","╌"])
currentStructLineWidth    = input.int    (1,             title="Current Structure Width",       group=GRP_STR, minval=1, maxval=5)
structHistoryNbr          = input.int    (10,            title="Max breaks to show",            group=GRP_STR, minval=1, maxval=50)

// ── Fibonacci ───────────────────────────────────────────────────
var string GRP_FIBO = "Structure Fibonacci"
isFibo1ToShow = input.bool  (true,    title="", group=GRP_FIBO, inline="Fibo1")
fibo1Value    = input.float (0.786,   title="", group=GRP_FIBO, inline="Fibo1")
fibo1Color    = input.color (#64b5f6, title="", group=GRP_FIBO, inline="Fibo1")
fibo1StyleOpt = input.string("─",    title="", group=GRP_FIBO, options=["─","┈","╌"], inline="Fibo1")
fibo1Width    = input.int   (1,       title="", group=GRP_FIBO, minval=1, maxval=5, inline="Fibo1")

isFibo2ToShow = input.bool  (true,    title="", group=GRP_FIBO, inline="Fibo2")
fibo2Value    = input.float (0.705,   title="", group=GRP_FIBO, inline="Fibo2")
fibo2Color    = input.color (#f23645, title="", group=GRP_FIBO, inline="Fibo2")
fibo2StyleOpt = input.string("─",    title="", group=GRP_FIBO, options=["─","┈","╌"], inline="Fibo2")
fibo2Width    = input.int   (1,       title="", group=GRP_FIBO, minval=1, maxval=5, inline="Fibo2")

isFibo3ToShow = input.bool  (true,    title="", group=GRP_FIBO, inline="Fibo3")
fibo3Value    = input.float (0.618,   title="", group=GRP_FIBO, inline="Fibo3")
fibo3Color    = input.color (#089981, title="", group=GRP_FIBO, inline="Fibo3")
fibo3StyleOpt = input.string("─",    title="", group=GRP_FIBO, options=["─","┈","╌"], inline="Fibo3")
fibo3Width    = input.int   (1,       title="", group=GRP_FIBO, minval=1, maxval=5, inline="Fibo3")

isFibo4ToShow = input.bool  (true,    title="", group=GRP_FIBO, inline="Fibo4")
fibo4Value    = input.float (0.5,     title="", group=GRP_FIBO, inline="Fibo4")
fibo4Color    = input.color (#4caf50, title="", group=GRP_FIBO, inline="Fibo4")
fibo4StyleOpt = input.string("─",    title="", group=GRP_FIBO, options=["─","┈","╌"], inline="Fibo4")
fibo4Width    = input.int   (1,       title="", group=GRP_FIBO, minval=1, maxval=5, inline="Fibo4")

isFibo5ToShow = input.bool  (true,    title="", group=GRP_FIBO, inline="Fibo5")
fibo5Value    = input.float (0.382,   title="", group=GRP_FIBO, inline="Fibo5")
fibo5Color    = input.color (#81c784, title="", group=GRP_FIBO, inline="Fibo5")
fibo5StyleOpt = input.string("─",    title="", group=GRP_FIBO, options=["─","┈","╌"], inline="Fibo5")
fibo5Width    = input.int   (1,       title="", group=GRP_FIBO, minval=1, maxval=5, inline="Fibo5")

// ==========================================================================================
//                                   CALCULATIONS
// ==========================================================================================

// ── MA Values ───────────────────────────────────────────────────
ma1Val  = ma(ma1Type, ma1Source, ma1Length, ma1Power, ma1Phase)
ma2Val  = ma(ma2Type, ma2Source, ma2Length, ma2Power, ma2Phase)
ema3Val = ta.ema(ema3Source, ema3Length)
ema4Val = ta.ema(ema4Source, ema4Length)

// ── ATR ─────────────────────────────────────────────────────────
atrVal = ma(atrSmoothing, ta.tr(true), atrLength, atrPower, atrPhase)

// ── SSL Channel ─────────────────────────────────────────────────
sslSmaHigh = ta.sma(high, sslLength)
sslSmaLow  = ta.sma(low,  sslLength)
var float sslHlv = na
sslHlv := close > sslSmaHigh ? 1 : close < sslSmaLow ? -1 : nz(sslHlv[1])
sslDown = sslHlv < 0 ? sslSmaHigh : sslSmaLow
sslUp   = sslHlv < 0 ? sslSmaLow  : sslSmaHigh

// ── Volume POC ──────────────────────────────────────────────────
poc2     = ta.barssince(volume == math.max(ta.highest(volume, pocPeriods), 0))
vol12h   = request.security(syminfo.tickerid, "720", volume, barmerge.gaps_off, barmerge.lookahead_on)
close12h = request.security(syminfo.tickerid, "720", close,  barmerge.gaps_off, barmerge.lookahead_on)
poc12bar = ta.barssince(vol12h == math.max(ta.highest(vol12h, poc12Periods), 0))

// ── MA Cross Signals ─────────────────────────────────────────────
ma1CrossLong  = ta.crossover (ma1Source, ma1Val) and barstate.isconfirmed
ma1CrossShort = ta.crossover (ma1Val, ma1Source) and barstate.isconfirmed
ma1CrossColor = ma1CrossLong ? color.green : ma1CrossShort ? color.red : na

ma2CrossLong  = ta.crossover (ma2Source, ma2Val) and barstate.isconfirmed
ma2CrossShort = ta.crossover (ma2Val, ma2Source) and barstate.isconfirmed
ma2CrossColor = ma2CrossLong ? color.green : ma2CrossShort ? color.red : na

// ── ATR Violation (MA2-based) ────────────────────────────────────
distFromMa2   = math.abs(ma2Val - ma2Source)
atrFail       = distFromMa2 > atrVal * atrMultViol
ma2TrendLong  = ma2Val < ma2Source
ma2TrendShort = ma2Val > ma2Source
atrViolLoc    = atrFail and ma2TrendLong ? ma2Val - atrVal * 0.5 : atrFail and ma2TrendShort ? ma2Val + atrVal * 0.5 : na

// ── ATR Bands around MA2 ─────────────────────────────────────────
upperAtrBl    = ma2Val + atrVal
lowerAtrBl    = ma2Val - atrVal
upperAtrBl15  = ma2Val + atrVal * 1.5
lowerAtrBl15  = ma2Val - atrVal * 1.5

// ── ATR Bands around Price ───────────────────────────────────────
atrTopPrice   = ma2Source + atrVal
atrBotPrice   = ma2Source - atrVal
atrTop15Price = ma2Source + atrVal * 1.5
atrBot15Price = ma2Source - atrVal * 1.5

// ==========================================================================================
//                                   FVG DRAW FUNCTION
// ==========================================================================================

FVGDraw(_boxes, _fvgTypes, _isFvgMitigated, _fvgLabels) =>
    for [index, value] in _boxes
        if array.get(_fvgTypes, index)
            if low <= box.get_bottom(value)
                array.remove(_boxes, index)
                array.remove(_fvgTypes, index)
                array.remove(_isFvgMitigated, index)
                label.delete(array.get(_fvgLabels, index))
                array.remove(_fvgLabels, index)
                box.delete(value)
            else
                if low < box.get_top(value)
                    box.set_bgcolor(value, mitigatedFvgColor)
                    if not array.get(_isFvgMitigated, index)
                        alert("FVG has been mitigated", alert.freq_once_per_bar)
                        array.set(_isFvgMitigated, index, true)
                    if isMitigatedFvgToReduce
                        box.set_top(value, low)
                box.set_right(value, bar_index)
                label.set_x(array.get(_fvgLabels, index), (box.get_left(value) + box.get_right(value)) / 2)
                label.set_y(array.get(_fvgLabels, index), box.get_top(value) - (box.get_top(value) - box.get_bottom(value)) / 2)
        else
            if high >= box.get_top(value)
                array.remove(_boxes, index)
                array.remove(_fvgTypes, index)
                array.remove(_isFvgMitigated, index)
                label.delete(array.get(_fvgLabels, index))
                array.remove(_fvgLabels, index)
                box.delete(value)
            else
                if high > box.get_bottom(value)
                    box.set_bgcolor(value, mitigatedFvgColor)
                    if not array.get(_isFvgMitigated, index)
                        alert("FVG has been mitigated", alert.freq_once_per_bar)
                        array.set(_isFvgMitigated, index, true)
                    if isMitigatedFvgToReduce
                        box.set_bottom(value, high)
                box.set_right(value, bar_index)
                label.set_x(array.get(_fvgLabels, index), (box.get_left(value) + box.get_right(value)) / 2)
                label.set_y(array.get(_fvgLabels, index), box.get_top(value) - (box.get_top(value) - box.get_bottom(value)) / 2)

// ==========================================================================================
//                                   STATE VARIABLES
// ==========================================================================================

var array<line>  structureLines  = array.new_line(0)
var array<label> structureLabels = array.new_label(0)
var array<box>   fvgBoxes        = array.new_box(0)
var array<bool>  fvgTypes        = array.new_bool(0)
var array<label> fvgLabels       = array.new_label(0)
var array<bool>  isFvgMitigated  = array.new_bool(0)

var float structureHigh          = 0.0
var float structureLow           = 0.0
var float fibo1Price = 0.0
var float fibo2Price = 0.0
var float fibo3Price = 0.0
var float fibo4Price = 0.0
var float fibo5Price = 0.0

var int structureHighStartIndex  = 0
var int structureLowStartIndex   = 0
var int structureDirection       = 0
var int fibo1StartIndex = 0
var int fibo2StartIndex = 0
var int fibo3StartIndex = 0
var int fibo4StartIndex = 0
var int fibo5StartIndex = 0

var line structureHighLine = na
var line structureLowLine  = na
var line fibo1Line = na
var line fibo2Line = na
var line fibo3Line = na
var line fibo4Line = na
var line fibo5Line = na

var label fibo1Label = na
var label fibo2Label = na
var label fibo3Label = na
var label fibo4Label = na
var label fibo5Label = na

var bool isBOSAlert   = false
var bool isCHOCHAlert = false

// ==========================================================================================
//                                   PLOTS
// ==========================================================================================

// ── Volume POC ──────────────────────────────────────────────────
plot(showPoc12 ? close12h[poc12bar] : na, title="POC 12H", color=poc12Color, style=plot.style_circles)
plot(showPoc   ? close[poc2]        : na, title="POC",     color=pocColor,   style=plot.style_circles)

// ── SSL Channel ─────────────────────────────────────────────────
plot(showSsl ? sslDown : na, title="SSL Down", color=sslDownColor, linewidth=2)
plot(showSsl ? sslUp   : na, title="SSL Up",   color=sslUpColor,   linewidth=2)

// ── ATR Bands (Price-based) ──────────────────────────────────────
plot(showAtrPrice ? atrTopPrice   : na, title="ATR Top 1x",   color=color.new(color.blue,   55), linewidth=1)
plot(showAtrPrice ? atrBotPrice   : na, title="ATR Bot 1x",   color=color.new(color.blue,   55), linewidth=1)
plot(showAtrPrice ? atrTop15Price : na, title="ATR Top 1.5x", color=color.new(color.orange, 55), linewidth=1)
plot(showAtrPrice ? atrBot15Price : na, title="ATR Bot 1.5x", color=color.new(color.orange, 55), linewidth=1)

// ── ATR Bands (MA2-based) ────────────────────────────────────────
plot(showAtrBl   ? upperAtrBl   : na, title="MA2 ATR Upper 1x",   color=atrBandColor,   linewidth=2)
plot(showAtrBl   ? lowerAtrBl   : na, title="MA2 ATR Lower 1x",   color=atrBandColor,   linewidth=2)
plot(showAtrBl15 ? upperAtrBl15 : na, title="MA2 ATR Upper 1.5x", color=atrBand15Color, linewidth=2)
plot(showAtrBl15 ? lowerAtrBl15 : na, title="MA2 ATR Lower 1.5x", color=atrBand15Color, linewidth=2)

// ── ATR Violation Marker ─────────────────────────────────────────
plotshape(showAtrRule ? atrViolLoc : na, title="ATR Violation", style=shape.diamond, location=location.absolute, color=color.new(color.white, 20), size=size.auto)

// ── MA 1 ─────────────────────────────────────────────────────────
// Unconfirmed (thin, dimmed) + confirmed (full color)
plot(isMa1ToShow ? ma1Val : na,
     title="MA 1 (unconfirmed)", color=color.new(ma1Color, 60),
     linewidth=ma1Width, style=plot.style_line)
plot(isMa1ToShow and barstate.isconfirmed ? ma1Val : na,
     title="MA 1", color=ma1Color,
     linewidth=ma1Width, style=plot.style_line)

// ── MA 1 Glow ────────────────────────────────────────────────────
ma1GlowColor = ma1Source > ma1Val ? color.new(color.green, 0) : color.new(color.red, 0)
p_ma1_glow = plot(showMa1Glow ? ma1Val      : na, color=ma1GlowColor, linewidth=4, display=display.none, title="MA1 glow base")
p_ma1_src  = plot(showMa1Glow ? ma1Source   : na, color=color.new(color.white, 100), display=display.none, title="MA1 src ref")
fill(p_ma1_glow, p_ma1_src, color=color.new(ma1GlowColor, 90))

// ── MA 1 Cross Signals ───────────────────────────────────────────
plotshape(showMa1Cross and ma1CrossLong,  title="MA1 Cross Long",  style=shape.triangleup,   location=location.belowbar, color=color.green, size=size.small)
plotshape(showMa1Cross and ma1CrossShort, title="MA1 Cross Short", style=shape.triangledown, location=location.abovebar, color=color.red,   size=size.small)
barcolor(showMa1BarColor ? ma1CrossColor : na, title="Bar Color MA1 Cross")

// ── MA 2 ─────────────────────────────────────────────────────────
plot(isMa2ToShow ? ma2Val : na,
     title="MA 2 (unconfirmed)", color=color.new(ma2Color, 60),
     linewidth=ma2Width, style=plot.style_line)
plot(isMa2ToShow and barstate.isconfirmed ? ma2Val : na,
     title="MA 2", color=ma2Color,
     linewidth=ma2Width, style=plot.style_line)

// ── MA 2 Glow ────────────────────────────────────────────────────
ma2GlowColor = ma2Source > ma2Val ? color.new(color.green, 0) : color.new(color.red, 0)
p_ma2_glow = plot(showMa2Glow ? ma2Val    : na, color=ma2GlowColor, linewidth=4, display=display.none, title="MA2 glow base")
p_ma2_src  = plot(showMa2Glow ? ma2Source : na, color=color.new(color.white, 100), display=display.none, title="MA2 src ref")
fill(p_ma2_glow, p_ma2_src, color=color.new(ma2GlowColor, 90))

// ── MA 2 Cross Signals ───────────────────────────────────────────
plotshape(showMa2Cross and ma2CrossLong,  title="MA2 Cross Long",  style=shape.triangleup,   location=location.abovebar, color=color.blue,   size=size.small)
plotshape(showMa2Cross and ma2CrossShort, title="MA2 Cross Short", style=shape.triangledown, location=location.belowbar, color=color.purple, size=size.small)
barcolor(showMa2BarColor ? ma2CrossColor : na, title="Bar Color MA2 Cross")

// ── EMA 3 ─────────────────────────────────────────────────────────
plot(isEma3ToShow ? ema3Val : na,
     title="EMA 3 (unconfirmed)", color=color.new(ema3Color, 60),
     linewidth=ema3Width, style=plot.style_line)
plot(isEma3ToShow and barstate.isconfirmed ? ema3Val : na,
     title="EMA 3", color=ema3Color,
     linewidth=ema3Width, style=plot.style_line)

// ── EMA 4 ─────────────────────────────────────────────────────────
plot(isEma4ToShow ? ema4Val : na,
     title="EMA 4 (unconfirmed)", color=color.new(ema4Color, 60),
     linewidth=ema4Width, style=plot.style_line)
plot(isEma4ToShow and barstate.isconfirmed ? ema4Val : na,
     title="EMA 4", color=ema4Color,
     linewidth=ema4Width, style=plot.style_line)

// ==========================================================================================
//                              FAIR VALUE GAP PROCESSING
// ==========================================================================================

isBullishFVG = high[3] < low[1]
isBearishFVG = low[3]  > high[1]

if isBullishFVG and isFvgToShow
    _box   = box.new(left=bar_index - 2, top=low[1], right=bar_index - 1, bottom=high[3], border_style=line.style_solid, border_width=1, bgcolor=bullishFvgColor, border_color=color.new(color.green, 100))
    _label = label.new(math.ceil((_box.get_left() + _box.get_right()) / 2), _box.get_top() - (_box.get_top() - _box.get_bottom()) / 2, text="FVG", style=label.style_none, textcolor=color.white)
    array.push(fvgBoxes, _box)
    array.push(fvgTypes, true)
    array.push(isFvgMitigated, false)
    array.push(fvgLabels, _label)
    if array.size(fvgBoxes) > fvgHistoryNbr + 1
        box.delete(array.get(fvgBoxes, 0))
        label.delete(array.get(fvgLabels, 0))
        array.remove(fvgLabels, 0)
        array.remove(fvgBoxes, 0)
        array.remove(fvgTypes, 0)
        array.remove(isFvgMitigated, 0)

if isBearishFVG and isFvgToShow
    _box   = box.new(left=bar_index - 2, top=low[3], right=bar_index - 1, bottom=high[1], border_style=line.style_solid, border_width=1, bgcolor=bearishFvgColor, border_color=color.new(color.red, 100))
    _label = label.new(math.ceil((_box.get_left() + _box.get_right()) / 2), _box.get_top() - (_box.get_top() - _box.get_bottom()) / 2, text="FVG", style=label.style_none, textcolor=color.white)
    array.push(fvgBoxes, _box)
    array.push(fvgTypes, false)
    array.push(isFvgMitigated, false)
    array.push(fvgLabels, _label)
    if array.size(fvgBoxes) > fvgHistoryNbr + 1
        box.delete(array.get(fvgBoxes, 0))
        label.delete(array.get(fvgLabels, 0))
        array.remove(fvgLabels, 0)
        array.remove(fvgBoxes, 0)
        array.remove(fvgTypes, 0)
        array.remove(isFvgMitigated, 0)

FVGDraw(fvgBoxes, fvgTypes, isFvgMitigated, fvgLabels)

// ==========================================================================================
//                                   STRUCTURES PROCESSING
// ==========================================================================================

if bar_index == 0
    structureHighStartIndex := bar_index
    structureLowStartIndex  := bar_index
    structureHigh           := high
    structureLow            := low

structureMaxBar = bar_index + get_structure_highest_bar(10)
structureMinBar = bar_index + get_structure_lowest_bar(10)

lowStructBreakPrice  = isStructBodyCandleBreak ? close : low
highStructBreakPrice = isStructBodyCandleBreak ? close : high

isStrucLowBroken  = (lowStructBreakPrice  < structureLow  and lowStructBreakPrice[1]  >= structureLow  and lowStructBreakPrice[2]  >= structureLow  and lowStructBreakPrice[3]  >= structureLow  and bar_index[1] > structureLowStartIndex  and bar_index[2] > structureLowStartIndex  and bar_index[3] > structureLowStartIndex)  or (structureDirection == 2 and lowStructBreakPrice  < structureLow)
isStrucHighBroken = (highStructBreakPrice > structureHigh and highStructBreakPrice[1] <= structureHigh and highStructBreakPrice[2] <= structureHigh and highStructBreakPrice[3] <= structureHigh and bar_index[1] > structureHighStartIndex and bar_index[2] > structureHighStartIndex and bar_index[3] > structureHighStartIndex) or (structureDirection == 1 and highStructBreakPrice > structureHigh)

bosLineStyle   = getLineStyle(bosLineStyleOption)
chochLineStyle = getLineStyle(chochLineStyleOption)
currentStructLineStyle = getLineStyle(currentStructLineStyleOpt)

if isStrucLowBroken
    if array.size(structureLines) >= structHistoryNbr
        d.delete_line(array.get(structureLines, 0), array.get(structureLabels, 0))
        array.remove(structureLabels, 0)
        array.remove(structureLines, 0)
    if structureDirection == 1
        array.push(structureLines,  line.new(structureLowStartIndex, structureLow, bar_index, structureLow, xloc=xloc.bar_index, extend=extend.none, color=bearishBosColor,  style=bosLineStyle,   width=bosLineWidth))
        array.push(structureLabels, label.new((bar_index + structureLowStartIndex) / 2, structureLow, text="BOS",   style=label.style_none, textcolor=bearishBosColor))
        isBOSAlert := true
    else
        array.push(structureLines,  line.new(structureLowStartIndex, structureLow, bar_index, structureLow, xloc=xloc.bar_index, extend=extend.none, color=bearishChochColor, style=chochLineStyle, width=chochLineWidth))
        array.push(structureLabels, label.new((bar_index + structureLowStartIndex) / 2, structureLow, text="CHoCH", style=label.style_none, textcolor=bearishChochColor))
        isCHOCHAlert := true
    structureDirection      := 1
    structureHighStartIndex := structureMaxBar
    structureLowStartIndex  := bar_index
    structureHigh           := high[bar_index - structureHighStartIndex]
    structureLow            := low

else if isStrucHighBroken
    if array.size(structureLines) >= structHistoryNbr
        d.delete_line(array.get(structureLines, 0), array.get(structureLabels, 0))
        array.remove(structureLabels, 0)
        array.remove(structureLines, 0)
    if structureDirection == 2
        array.push(structureLines,  line.new(structureHighStartIndex, structureHigh, bar_index, structureHigh, xloc=xloc.bar_index, extend=extend.none, color=bullishBosColor,  style=bosLineStyle,   width=bosLineWidth))
        array.push(structureLabels, label.new((bar_index + structureHighStartIndex) / 2, structureHigh, text="BOS",   style=label.style_none, textcolor=bullishBosColor))
        isBOSAlert := true
    else
        array.push(structureLines,  line.new(structureHighStartIndex, structureHigh, bar_index, structureHigh, xloc=xloc.bar_index, extend=extend.none, color=bullishChochColor, style=chochLineStyle, width=chochLineWidth))
        array.push(structureLabels, label.new((bar_index + structureHighStartIndex) / 2, structureHigh, text="CHoCH", style=label.style_none, textcolor=bullishChochColor))
        isCHOCHAlert := true
    structureDirection      := 2
    structureHighStartIndex := bar_index
    structureLowStartIndex  := structureMinBar
    structureHigh           := high
    structureLow            := low[bar_index - structureLowStartIndex]

else
    isBOSAlert   := false
    isCHOCHAlert := false
    if high > structureHigh and (structureDirection == 0 or structureDirection == 2)
        if not isStructBodyCandleBreak or not (isStructBodyCandleBreak and bar_index[1] > structureHighStartIndex and bar_index[2] > structureHighStartIndex and bar_index[3] > structureHighStartIndex)
            structureHigh           := high
            structureHighStartIndex := bar_index
    else if low < structureLow and (structureDirection == 0 or structureDirection == 1)
        if not isStructBodyCandleBreak or not (isStructBodyCandleBreak and bar_index[1] > structureLowStartIndex and bar_index[2] > structureLowStartIndex and bar_index[3] > structureLowStartIndex)
            structureLow           := low
            structureLowStartIndex := bar_index

structureRange = math.abs(structureHigh - structureLow)

fiboCalc(dir, hi, lo, rng, val) =>
    dir == 1 ? hi - (rng - rng * val) : lo + (rng - rng * val)
fiboIdx(dir, hiIdx, loIdx) =>
    dir == 1 ? hiIdx : loIdx

if isCurrentStructToShow
    d.delete_line(structureHighLine, na)
    d.delete_line(structureLowLine, na)
    structureHighLine := line.new(structureHighStartIndex, structureHigh, bar_index, structureHigh, xloc.bar_index, color=currentStructColor, style=currentStructLineStyle, width=currentStructLineWidth)
    structureLowLine  := line.new(structureLowStartIndex,  structureLow,  bar_index, structureLow,  xloc.bar_index, color=currentStructColor, style=currentStructLineStyle, width=currentStructLineWidth)

    if isFibo1ToShow
        d.delete_line(fibo1Line, fibo1Label)
        fibo1Price      := fiboCalc(structureDirection, structureHigh, structureLow, structureRange, fibo1Value)
        fibo1StartIndex := fiboIdx(structureDirection, structureHighStartIndex, structureLowStartIndex)
        fibo1Line  := line.new(fibo1StartIndex, fibo1Price, bar_index, fibo1Price, xloc.bar_index, color=fibo1Color, style=getLineStyle(fibo1StyleOpt), width=fibo1Width)
        fibo1Label := label.new(bar_index + 20, fibo1Price, text=str.tostring(fibo1Value) + "(" + str.tostring(fibo1Price) + ")", style=label.style_none, textcolor=fibo1Color)

    if isFibo2ToShow
        d.delete_line(fibo2Line, fibo2Label)
        fibo2Price      := fiboCalc(structureDirection, structureHigh, structureLow, structureRange, fibo2Value)
        fibo2StartIndex := fiboIdx(structureDirection, structureHighStartIndex, structureLowStartIndex)
        fibo2Line  := line.new(fibo2StartIndex, fibo2Price, bar_index, fibo2Price, xloc.bar_index, color=fibo2Color, style=getLineStyle(fibo2StyleOpt), width=fibo2Width)
        fibo2Label := label.new(bar_index + 20, fibo2Price, text=str.tostring(fibo2Value) + "(" + str.tostring(fibo2Price) + ")", style=label.style_none, textcolor=fibo2Color)

    if isFibo3ToShow
        d.delete_line(fibo3Line, fibo3Label)
        fibo3Price      := fiboCalc(structureDirection, structureHigh, structureLow, structureRange, fibo3Value)
        fibo3StartIndex := fiboIdx(structureDirection, structureHighStartIndex, structureLowStartIndex)
        fibo3Line  := line.new(fibo3StartIndex, fibo3Price, bar_index, fibo3Price, xloc.bar_index, color=fibo3Color, style=getLineStyle(fibo3StyleOpt), width=fibo3Width)
        fibo3Label := label.new(bar_index + 20, fibo3Price, text=str.tostring(fibo3Value) + "(" + str.tostring(fibo3Price) + ")", style=label.style_none, textcolor=fibo3Color)

    if isFibo4ToShow
        d.delete_line(fibo4Line, fibo4Label)
        fibo4Price      := fiboCalc(structureDirection, structureHigh, structureLow, structureRange, fibo4Value)
        fibo4StartIndex := fiboIdx(structureDirection, structureHighStartIndex, structureLowStartIndex)
        fibo4Line  := line.new(fibo4StartIndex, fibo4Price, bar_index, fibo4Price, xloc.bar_index, color=fibo4Color, style=getLineStyle(fibo4StyleOpt), width=fibo4Width)
        fibo4Label := label.new(bar_index + 20, fibo4Price, text=str.tostring(fibo4Value) + "(" + str.tostring(fibo4Price) + ")", style=label.style_none, textcolor=fibo4Color)

    if isFibo5ToShow
        d.delete_line(fibo5Line, fibo5Label)
        fibo5Price      := fiboCalc(structureDirection, structureHigh, structureLow, structureRange, fibo5Value)
        fibo5StartIndex := fiboIdx(structureDirection, structureHighStartIndex, structureLowStartIndex)
        fibo5Line  := line.new(fibo5StartIndex, fibo5Price, bar_index, fibo5Price, xloc.bar_index, color=fibo5Color, style=getLineStyle(fibo5StyleOpt), width=fibo5Width)
        fibo5Label := label.new(bar_index + 20, fibo5Price, text=str.tostring(fibo5Value) + "(" + str.tostring(fibo5Price) + ")", style=label.style_none, textcolor=fibo5Color)

// ==========================================================================================
//                                   ALERTS
// ==========================================================================================

alertcondition(isBOSAlert,           title="BOS",              message="BOS")
alertcondition(isCHOCHAlert,         title="CHoCH",            message="CHoCH")
alertcondition(ma1CrossLong,         title="MA1 Cross Long",   message="MA1 Cross Long")
alertcondition(ma1CrossShort,        title="MA1 Cross Short",  message="MA1 Cross Short")
alertcondition(ma2CrossLong,         title="MA2 Cross Long",   message="MA2 Cross Long (Baseline)")
alertcondition(ma2CrossShort,        title="MA2 Cross Short",  message="MA2 Cross Short (Baseline)")
alertcondition(atrFail,              title="ATR Violation",    message="Price too far from MA2 Baseline")
````
