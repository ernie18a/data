# ICT with EMAs, ORB for certain index

- url: https://www.tradingview.com/script/2yjIJXOq-ICT-with-EMAs-ORB-for-certain-index/
- type: indicator
- pine_id: PUB;ea682eaa60a14099acd5b3d93e8c1212
- version: 2.0

## Description

use this indicator for wilth almost anything, any stock index try orb setting for better results there too

## Source Code

````pine
//@version=6
indicator("TrendCraft ICT SwiftEdge + 5 MAs + 0.09", overlay=true)

// --- Brugerinput ---
// SMA Input
smaLength = input.int(20, "SMA Length", minval=1)

// ICT Struktur Input
var STRU = "ICT Structure Settings"
showBos = input.bool(true, "Show Continuation (BOS)", group=STRU)
showMss = input.bool(true, "Show Breaker (MSS)", group=STRU)
tfStructure = input.timeframe("", "Structure Timeframe", group=STRU, tooltip="Select the timeframe used to calculate breakers.")
chartTimeframe = input.string("30M", "Chart Timeframe", ["1M", "5M", "15M", "30M", "1H", "4H", "1D"], group=STRU)
signalType = input.string("BoS", "Signal Type", ["BoS", "MSS"], group=STRU, tooltip="Choose whether signals are based on Break of Structure (BoS) or Market Structure Shift (MSS).")

// Farveindstillinger
bosBullCol = input.color(color.teal, "Bull BOS Color", group=STRU)
bosBearCol = input.color(color.red, "Bear BOS Color", group=STRU)
mssBullCol = input.color(color.blue, "Bull MSS Color", group=STRU)
mssBearCol = input.color(color.orange, "Bear MSS Color", group=STRU)

// --- 5 Customizable Moving Averages Settings ---
var string MA_GRP = "5 Custom Moving Averages"

ma_show1 = input.bool(true, "Show MA 1", group=MA_GRP)
ma_type1 = input.string("EMA", "MA 1 Type", options=["SMA", "EMA", "WMA", "HMA"], group=MA_GRP)
ma_len1  = input.int(9, "MA 1 Length", minval=1, group=MA_GRP)
ma_col1  = input.color(color.blue, "MA 1 Color", group=MA_GRP)

ma_show2 = input.bool(true, "Show MA 2", group=MA_GRP)
ma_type2 = input.string("EMA", "MA 2 Type", options=["SMA", "EMA", "WMA", "HMA"], group=MA_GRP)
ma_len2  = input.int(21, "MA 2 Length", minval=1, group=MA_GRP)
ma_col2  = input.color(color.yellow, "MA 2 Color", group=MA_GRP)

ma_show3 = input.bool(true, "Show MA 3", group=MA_GRP)
ma_type3 = input.string("EMA", "MA 3 Type", options=["SMA", "EMA", "WMA", "HMA"], group=MA_GRP)
ma_len3  = input.int(50, "MA 3 Length", minval=1, group=MA_GRP)
ma_col3  = input.color(color.orange, "MA 3 Color", group=MA_GRP)

ma_show4 = input.bool(true, "Show MA 4", group=MA_GRP)
ma_type4 = input.string("EMA", "MA 4 Type", options=["SMA", "EMA", "WMA", "HMA"], group=MA_GRP)
ma_len4  = input.int(100, "MA 4 Length", minval=1, group=MA_GRP)
ma_col4  = input.color(color.purple, "MA 4 Color", group=MA_GRP)

ma_show5 = input.bool(true, "Show MA 5", group=MA_GRP)
ma_type5 = input.string("EMA", "MA 5 Type", options=["SMA", "EMA", "WMA", "HMA"], group=MA_GRP)
ma_len5  = input.int(200, "MA 5 Length", minval=1, group=MA_GRP)
ma_col5  = input.color(color.white, "MA 5 Color", group=MA_GRP)

// --- Dynamisk Parameterjustering ---
var int rlBars = 2
switch chartTimeframe
    "1M" => rlBars := 1
    "5M" => rlBars := 1
    "15M" => rlBars := 2
    "30M" => rlBars := 2
    "1H" => rlBars := 3
    "4H" => rlBars := 4
    "1D" => rlBars := 5

// --- SMA Logik ---
smaLow = ta.sma(low, smaLength)
smaHigh = ta.sma(high, smaLength)

// Bestem prisens position
isAboveBoth = close > smaHigh and close > smaLow
isBelowBoth = close < smaHigh and close < smaLow
isBetween = close > smaLow and close < smaHigh

// Farve baseret på prisposition
lineColor = isAboveBoth ? color.green : isBelowBoth ? color.red : color.purple

// Plot SMA'er
p1 = plot(smaLow, "SMA Low", color=lineColor, linewidth=2)
p2 = plot(smaHigh, "SMA High", color=lineColor, linewidth=2)

// Udfyld baggrund mellem SMA'er
fill(p1, p2, color=isAboveBoth ? color.new(color.green, 80) : isBelowBoth ? color.new(color.red, 80) : color.new(color.purple, 80))

// --- 5 Custom Moving Averages Logic & Plots ---
get_ma(string type, int len) =>
    switch type
        "SMA" => ta.sma(close, len)
        "EMA" => ta.ema(close, len)
        "WMA" => ta.wma(close, len)
        "HMA" => ta.hma(close, len)
        => ta.ema(close, len)

ma1 = get_ma(ma_type1, ma_len1)
ma2 = get_ma(ma_type2, ma_len2)
ma3 = get_ma(ma_type3, ma_len3)
ma4 = get_ma(ma_type4, ma_len4)
ma5 = get_ma(ma_type5, ma_len5)

plot(ma_show1 ? ma1 : na, "Custom MA 1", color=ma_col1, linewidth=1)
plot(ma_show2 ? ma2 : na, "Custom MA 2", color=ma_col2, linewidth=1)
plot(ma_show3 ? ma3 : na, "Custom MA 3", color=ma_col3, linewidth=1)
plot(ma_show4 ? ma4 : na, "Custom MA 4", color=ma_col4, linewidth=1)
plot(ma_show5 ? ma5 : na, "Custom MA 5", color=ma_col5, linewidth=1)

// --- ICT BoS/MSS Logik ---
var line[] lin = array.new_line(0)
var bool bull = false
var float nPh1 = na
var float nPl1 = na

// Custom pivot struktur
type piv
    float pp
    int pi

// Track pivots
var piv pH = na
var piv pL = na
var piv nPh = na
var piv nPl = na

// Funktion til at hente pivotpunkter
Fmtf() =>
    phPs = ta.pivothigh(rlBars, rlBars)
    plPs = ta.pivotlow(rlBars, rlBars)
    int phBi = na
    int plBi = na
    if not na(phPs)
        phBi := time[rlBars]
    if not na(plPs)
        plBi := time[rlBars]
    [phPs, phBi, plPs, plBi]

// Hent HTF pivots
[phPs, phBi, plPs, plBi] = request.security(syminfo.tickerid, tfStructure, Fmtf(), lookahead=barmerge.lookahead_on)

if not na(phPs)
    nPh := piv.new(phPs, phBi)
    if na(pH)
        pH := piv.new(phPs, phBi)

if not na(plPs)
    nPl := piv.new(plPs, plBi)
    if na(pL)
        pL := piv.new(plPs, plBi)

bosBull = false
bosBear = false
mssBull = false
mssBear = false

var mssBullVar = false
var mssBearVar = false

// Hent HTF close og tid
[htfClose, htfTime] = request.security(syminfo.tickerid, tfStructure, [close[1], time[1]], lookahead=barmerge.lookahead_on)

highCond = bull ? high : htfClose
timeHighCond = bull ? time : htfTime

if (plPs > nPl1 and bull) or na(nPl1) or plPs < nPl1
    nPl1 := plPs

// Bullish logik
var float tempBosBullLevel = na
var float tempMssBullLevel = na
breakHighCond = not na(pH) and highCond > pH.pp
if breakHighCond
    if bull
        bosBull := true
        tempBosBullLevel := pH.pp
        if not mssBullVar and lin.size() > 0
            lin.shift().delete()
        mssBullVar := false
    else
        mssBull := true
        tempMssBullLevel := pH.pp
        mssBullVar := true

    linCon = bull ? showBos : showMss
    linCol = bull ? bosBullCol : mssBullCol
    newLin = line.new(pH.pi, pH.pp, timeHighCond, pH.pp, color=linCon ? linCol : na, xloc=xloc.bar_time, style=line.style_dotted, width=2)

    bull := true
    mssBearVar := false
    pH := na
    pL := na
    if not na(nPl1) and not na(nPl)
        pL := piv.new(nPl.pp, nPl.pi)
    lin.unshift(newLin)

lowCond = bull ? htfClose : low
timeLowCond = bull ? htfTime : time

if (phPs < nPh1 and not bull) or na(nPh1) or phPs > nPh1
    nPh1 := phPs

// Bearish logik
var float tempBosBearLevel = na
var float tempMssBearLevel = na
breakLowCond = not na(pL) and lowCond < pL.pp
if breakLowCond
    if not bull
        bosBear := true
        tempBosBearLevel := pL.pp
        if not mssBearVar and lin.size() > 0
            lin.shift().delete()
        mssBearVar := false
    else
        mssBear := true
        tempMssBearLevel := pL.pp
        mssBearVar := true

    linCon = bull ? showMss : showBos
    linCol = bull ? mssBearCol : bosBearCol
    newLin = line.new(pL.pi, pL.pp, timeLowCond, pL.pp, color=linCon ? linCol : na, xloc=xloc.bar_time, style=line.style_dotted, width=2)

    bull := false
    mssBullVar := false
    pH := na
    pL := na
    if not na(nPh1) and not na(nPh)
        pH := piv.new(nPh.pp, nPh.pi)
    lin.unshift(newLin)

// Opdater swing points
if not na(pH) and not na(nPh) and not na(nPh[1]) and lin.size() > 0 and not bull and nPh.pp != (nPh[1]).pp and nPh.pi <= line.get_x2(lin.first())
    pH := piv.new(nPh.pp, nPh.pi)

if not na(pL) and not na(nPl) and not na(nPl[1]) and lin.size() > 0 and bull and nPl.pp != (nPl[1]).pp and nPl.pi <= line.get_x2(lin.first())
    pL := piv.new(nPl.pp, nPl.pi)

// Nulstil brudte pivots
if not na(nPh) and high > nPh.pp
    nPh := na

if not na(nPl) and low < nPl.pp
    nPl := na

// --- Signal Logik ---
// Spor seneste BoS- og MSS-niveauer
var float lastBosBullLevel = na
var float lastBosBearLevel = na
var float lastMssBullLevel = na
var float lastMssBearLevel = na

if bosBull and not na(tempBosBullLevel)
    lastBosBullLevel := tempBosBullLevel
if bosBear and not na(tempBosBearLevel)
    lastBosBearLevel := tempBosBearLevel
if mssBull and not na(tempMssBullLevel)
    lastMssBullLevel := tempMssBullLevel
if mssBear and not na(tempMssBearLevel)
    lastMssBearLevel := tempMssBearLevel

// Køb- og salg-betingelser baseret på signalType
buyCondition = signalType == "BoS" ? ta.crossover(close, lastBosBullLevel) and close > smaHigh and close > smaLow : ta.crossover(close, lastMssBullLevel) and close > smaHigh and close > smaLow
sellCondition = signalType == "BoS" ? ta.crossunder(close, lastBosBearLevel) and close < smaHigh and close < smaLow : ta.crossunder(close, lastMssBearLevel) and close < smaHigh and close < smaLow

// Spor trendtilstand
var int trendState = 0
buySignal = buyCondition and trendState != 1
sellSignal = sellCondition and trendState != -1

// Opdater trendtilstand
if buySignal
    trendState := 1
if sellSignal
    trendState := -1
if isBetween
    trendState := 0

// --- Labels ---
if buySignal
    label.new(bar_index, high, "Buy", color=color.green, textcolor=color.white, style=label.style_label_down, size=size.normal)

if sellSignal
    label.new(bar_index, low, "Sell", color=color.red, textcolor=color.white, style=label.style_label_up, size=size.normal)



// Define market open and close times
market_open_time = timestamp(year, month, dayofmonth, 9, 15)
market_end_time = timestamp(year, month, dayofmonth, 15, 25)

// Identify the first 5-minute candle of the day
is_first_five_min_candle = (time >= market_open_time and time < market_open_time + 300000)

// Variables to store the levels
var float first_upper_level = na
var float first_lower_level = na
var line first_upper_line = na
var line first_lower_line = na

// Set levels from the first 5-minute candle
if is_first_five_min_candle
    first_upper_level := close * 1.0009
    first_lower_level := close * 0.9991
    // Upper and lower level lines (solid style)
    first_upper_line := line.new(x1=bar_index, y1=first_upper_level, x2=bar_index + 100, y2=first_upper_level, width=2, color=color.green)
    first_lower_line := line.new(x1=bar_index, y1=first_lower_level, x2=bar_index + 100, y2=first_lower_level, width=2, color=color.red)

// Extend the first upper and lower level lines until 3:25 PM
if time < market_end_time
    line.set_x2(first_upper_line, bar_index)
    line.set_x2(first_lower_line, bar_index)




// ===== INPUTS =====
src = input.source(hlc3, "Source")
vwapColor = input.color(color.blue, "VWAP Color")
vwapWidth = input.int(2, "Line Width", minval=1, maxval=5)
vwapStyle = input.string("Solid", "Line Style", options=["Solid", "Dashed", "Dotted"])


// ===== VWAP =====
vwapColour = input.color(color.blue, "VWAP Color", group="VWAP")
vapWidth = input.int(2, "VWAP Width", minval=1, maxval=5, group="VWAP")

bool vwapNewSession = timeframe.change("D")
float myVWAP = na

[VWAP, _, _] = ta.vwap(hlc3, vwapNewSession, 1)

plot(VWAP, title="VWAP", color=vwapColour, linewidth=vapWidth)
````
