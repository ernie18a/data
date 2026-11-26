# NG Trendlines & Market Structure

- url: https://www.tradingview.com/script/lSDCPKE5-NG-Trendlines-Market-Structure/
- type: indicator
- pine_id: PUB;1a71d98f04094d2b9d8def8e4aef9463
- version: 4.0

## Description

# NG Trendlines & Market Structure

NG Trendlines & Market Structure is a proprietary trading indicator designed to identify high-probability market structure, trendline compression, and breakout opportunities.

The indicator combines dynamic trendlines, higher-timeframe directional bias, support and resistanceand market structure analysis to help traders identify periods of consolidation before momentum expansion.

## Features

* Automatic trendline detection
* Compression and breakout identification
* Multi-timeframe trend bias (5m, 15m, 1H, 4H)
* Dynamic support and resistance zones
* Market state identification (Bull, Bear, Range, Breakout)
* VWAP touch detection with customizable alerts
* Visual breakout confirmation
* Clean, non-repainting signals based on confirmed price action

## Alerts

Alerts can be configured for:

* Price touching VWAP
* Bullish breakout confirmation
* Bearish breakout confirmation
* Trend direction changes
* Market state transitions

This indicator is designed to assist traders in understanding market structure and improving trade timing. It is intended as a decision-support tool and should be used alongside proper risk management and trade confirmation.

**Disclaimer:** This indicator does not guarantee profits or trading success and should not be considered financial advice. Trading financial markets involves substantial risk, and past performance is not indicative of future results.

## Source Code

````pine
//@version=6
indicator("NG Trendlines & Market Structure", overlay=true)

// =====================
// SESSION INPUTS
// =====================
asianSession  = input.session("1900-0400", "Asian")
londonSession = input.session("0300-1200", "London")
nySession     = input.session("0800-1700", "New York")

showAsian  = input.bool(true)
showLondon = input.bool(true)
showNY     = input.bool(true)

// =====================
// INFO BOX SETTINGS
// =====================
tablePosInput = input.string("Bottom Left", "Info Box Position", options=["Top Right","Top Left","Middle Right","Middle Left","Bottom Right","Bottom Left"])
showInfoBox   = input.bool(true, "Show Info Box")

tablePos = tablePosInput == "Top Right" ? position.top_right :
           tablePosInput == "Top Left" ? position.top_left :
           tablePosInput == "Middle Right" ? position.middle_right :
           tablePosInput == "Middle Left" ? position.middle_left :
           tablePosInput == "Bottom Right" ? position.bottom_right :
           position.bottom_left

// =====================
// VWAP
// =====================
vwapValue = ta.vwap(close)
plot(vwapValue, color=color.orange, linewidth=2)

// =====================
// EMA SETTINGS
// =====================
showEMA20  = input.bool(true, "Show EMA 20")
showEMA50  = input.bool(true, "Show EMA 50")
showEMA200 = input.bool(true, "Show EMA 200")

ema20  = ta.ema(close, 20)
ema50  = ta.ema(close, 50)
ema200 = ta.ema(close, 200)

plot(showEMA20 ? ema20 : na,  title="EMA 20",  color=color.yellow, linewidth=2)
plot(showEMA50 ? ema50 : na,  title="EMA 50",  color=color.aqua, linewidth=2)
plot(showEMA200 ? ema200 : na, title="EMA 200", color=color.fuchsia, linewidth=2)

// =====================
// COLORS
// =====================
asianColor  = color.new(color.green, 85)
londonColor = color.new(color.red, 85)
nyColor     = color.new(color.blue, 85)

// =====================
// SESSION DETECTION
// =====================
inAsian  = not na(time(timeframe.period, asianSession))
inLondon = not na(time(timeframe.period, londonSession))
inNY     = not na(time(timeframe.period, nySession))

// =====================
// SESSION VARIABLES
// =====================
var float highA = na
var float lowA  = na
var box boxA    = na
var label labelA = na
var int startA = na

var float highL = na
var float lowL  = na
var box boxL    = na
var label labelL = na
var int startL = na

var float highN = na
var float lowN  = na
var box boxN    = na
var label labelN = na
var int startN = na

// =====================
// SESSIONS (FIXED)
// =====================
if showAsian
    if inAsian and not inAsian[1]
        highA := high
        lowA := low
        startA := bar_index
        boxA := box.new(bar_index, high, bar_index, low, bgcolor=asianColor)
        labelA := label.new(bar_index, low, "Asian", style=label.style_none, textcolor=color.green)

    if inAsian
        highA := math.max(highA, high)
        lowA := math.min(lowA, low)
        box.set_top(boxA, highA)
        box.set_bottom(boxA, lowA)
        box.set_right(boxA, bar_index)
        label.set_x(labelA, math.floor((startA + bar_index) / 2))
        label.set_y(labelA, lowA)

    // 🔒 LOCK ASIAN BOX
    if not inAsian and inAsian[1]
        box.set_right(boxA, bar_index - 1)


if showLondon
    if inLondon and not inLondon[1]
        highL := high
        lowL := low
        startL := bar_index
        boxL := box.new(bar_index, high, bar_index, low, bgcolor=londonColor)
        labelL := label.new(bar_index, low, "London", style=label.style_none, textcolor=color.red)

    if inLondon
        highL := math.max(highL, high)
        lowL := math.min(lowL, low)
        box.set_top(boxL, highL)
        box.set_bottom(boxL, lowL)
        box.set_right(boxL, bar_index)
        label.set_x(labelL, math.floor((startL + bar_index) / 2))
        label.set_y(labelL, lowL)

    // 🔒 LOCK LONDON BOX
    if not inLondon and inLondon[1]
        box.set_right(boxL, bar_index - 1)


if showNY
    if inNY and not inNY[1]
        highN := high
        lowN := low
        startN := bar_index
        boxN := box.new(bar_index, high, bar_index, low, bgcolor=nyColor)
        labelN := label.new(bar_index, low, "New York", style=label.style_none, textcolor=color.blue)

    if inNY
        highN := math.max(highN, high)
        lowN := math.min(lowN, low)
        box.set_top(boxN, highN)
        box.set_bottom(boxN, lowN)
        box.set_right(boxN, bar_index)
        label.set_x(labelN, math.floor((startN + bar_index) / 2))
        label.set_y(labelN, lowN)

    // 🔒 LOCK NY BOX
    if not inNY and inNY[1]
        box.set_right(boxN, bar_index - 1)

// =====================
// TRENDLINES (NO ERROR)
// =====================
length = input.int(7)

ph = ta.pivothigh(high, length, length)
pl = ta.pivotlow(low, length, length)

var float h1 = na
var float h2 = na
var int hb1 = na
var int hb2 = na

var float l1 = na
var float l2 = na
var int lb1 = na
var int lb2 = na

if not na(ph)
    h2 := h1
    hb2 := hb1
    h1 := ph
    hb1 := bar_index - length

if not na(pl)
    l2 := l1
    lb2 := lb1
    l1 := pl
    lb1 := bar_index - length

var line downTrend = na
var line upTrend   = na

// 🔻 Downtrend line (to current bar)
if not na(h1) and not na(h2) and not na(hb1) and not na(hb2)
    if not na(downTrend)
        line.delete(downTrend)
    downTrend := line.new(hb2, h2, bar_index, h1, color=color.red, width=2)

// 🔺 Uptrend line (to current bar)
if not na(l1) and not na(l2) and not na(lb1) and not na(lb2)
    if not na(upTrend)
        line.delete(upTrend)
    upTrend := line.new(lb2, l2, bar_index, l1, color=color.green, width=2)

// =====================
// RANGE (REAL CONSOLIDATION)
// =====================
lookback = input.int(20, "Range Lookback")

var float rangeHigh = na
var float rangeLow  = na

if barstate.isconfirmed
    rangeHigh := ta.highest(high, lookback)
    rangeLow  := ta.lowest(low, lookback)

// =====================
// FIB + LIQUIDITY FILTER
// =====================
fib50 = rangeLow + (rangeHigh - rangeLow) * 0.5

premiumZone  = close > fib50
discountZone = close < fib50

tolerance = (rangeHigh - rangeLow) * 0.02

nearLow  = low <= (rangeLow + tolerance)
nearHigh = high >= (rangeHigh - tolerance)
sweepHigh = high > rangeHigh and close < rangeHigh
sweepLow  = low < rangeLow  and close > rangeLow
// =====================
// VOLUME LOGIC
// =====================
var float rangeVolSum = 0.0
var int   rangeBars   = 0
var float lockedAvgVol = na
var bool  breakoutHappened = false

// Current bar's range status
inRange = not na(rangeHigh) and not na(rangeLow) and high <= rangeHigh and low >= rangeLow

// Accumulate volume from PREVIOUS bars inside the range
if inRange[1] and not breakoutHappened
    rangeVolSum += volume[1]
    rangeBars   += 1

// Calculate average excluding current candle
float currentAvgVol = rangeBars > 0 ? rangeVolSum / rangeBars : ta.sma(volume, lookback)

// Breakout detection
bullBreakRaw = close > rangeHigh and close > vwapValue
bearBreakRaw = close < rangeLow  and close < vwapValue

confirmBullBreak = bullBreakRaw[1] and close > rangeHigh and volume >= currentAvgVol
confirmBearBreak = bearBreakRaw[1] and close < rangeLow  and volume >= currentAvgVol


// TRUE fake = price comes back inside range
fakeBearBreak = bearBreakRaw and close > rangeLow
fakeBullBreak = bullBreakRaw and close < rangeHigh

if (bullBreakRaw or bearBreakRaw) and not breakoutHappened
    lockedAvgVol := currentAvgVol
    breakoutHappened := true

// =====================
// DISPLACEMENT (NEW)
// =====================
bodySize = math.abs(close - open)
avgBody  = ta.sma(math.abs(close - open), 10)

bearDisplacement = close < open and bodySize > avgBody * 1.5 and close < low[1]
bullDisplacement = close > open and bodySize > avgBody * 1.5 and close > high[1]

earlyBearBreak = bearBreakRaw and bearDisplacement
earlyBullBreak = bullBreakRaw and bullDisplacement
// Reset when range changes
var float prevHigh = na
var float prevLow  = na

if barstate.isconfirmed
    if not na(prevHigh) and not na(prevLow)
        if (rangeHigh != prevHigh or rangeLow != prevLow)
            breakoutHappened := false
            rangeVolSum := 0.0
            rangeBars   := 0
            lockedAvgVol := na

    prevHigh := rangeHigh
    prevLow  := rangeLow


var string marketState = "CONSOLIDATION"
var bool waitConfirmShort = false
var bool waitConfirmLong  = false
// =====================
// STATUS
// =====================

strongVol = not na(lockedAvgVol) and volume > lockedAvgVol * 1.05
weakVol   = not na(lockedAvgVol) and volume <= lockedAvgVol * 1.05

// =====================
// REVERSAL LOGIC (FIXED)
// =====================
mid = rangeLow + (rangeHigh - rangeLow) * 0.5

reversalShortStrong = (premiumZone and nearHigh and close < open and close < low[1] and volume >= currentAvgVol)

reversalShortWeak   = (premiumZone and nearHigh and close < open and close < low[1] and volume < currentAvgVol)

reversalLongStrong  = (discountZone and nearLow and close > open and close > high[1] and volume >= currentAvgVol)

reversalLongWeak    = (discountZone and nearLow and close > open and close > high[1] and volume < currentAvgVol)

// =====================
// REJECTION LOGIC (ADD THIS)
// =====================
rejectionShortStrong = (premiumZone and nearHigh and close < open and volume >= currentAvgVol)

rejectionShortWeak   = (premiumZone and nearHigh and close < open and volume < currentAvgVol)

rejectionLongStrong  = (discountZone and nearLow and close > open and volume >= currentAvgVol)

rejectionLongWeak    = (discountZone and nearLow and close > open and volume < currentAvgVol)
// =====================
// CONFIRMATION LOGIC
// =====================

// detect potential reversal
if reversalShortStrong or reversalShortWeak
    waitConfirmShort := true

if reversalLongStrong or reversalLongWeak
    waitConfirmLong := true

// confirm on next candle
confirmShort = waitConfirmShort[1] and close < low[1]
confirmLong  = waitConfirmLong[1] and close > high[1]

// reset after confirmation
if confirmShort or confirmLong
    waitConfirmShort := false
    waitConfirmLong  := false

// =====================
// EARLY REVERSAL FLAGS (ADD THIS)
// =====================
earlyShort = reversalShortStrong or reversalShortWeak
earlyLong  = reversalLongStrong or reversalLongWeak
// =====================
// STATE ENGINE (TRADE DECISION)
// =====================

// Strong bullish trend
if close > ema20 and ema20 > ema50 and ema50 > ema200

    if confirmBullBreak
        marketState := "WAIT RETEST LONG"

    else if reversalLongStrong
        marketState := "LONG SETUP"

    else if confirmLong
        marketState := "ENTER LONG"

    else if inRange and nearLow
        marketState := "WATCH LONG"

    else if inRange
        marketState := "WAIT FOR LONG"

// Strong bearish trend
else if close < ema20 and ema20 < ema50 and ema50 < ema200

    if confirmBearBreak
        marketState := "WAIT RETEST SHORT"

    else if reversalShortStrong
        marketState := "SHORT SETUP"

    else if confirmShort
        marketState := "ENTER SHORT"

    else if inRange and nearHigh
        marketState := "WATCH SHORT"

    else if inRange
        marketState := "WAIT FOR SHORT"

// Mixed trend
else

    if confirmBullBreak
        marketState := "BREAKOUT LONG"

    else if confirmBearBreak
        marketState := "BREAKOUT SHORT"

    else if nearLow and rejectionLongStrong
        marketState := "WATCH LONG"

    else if nearHigh and rejectionShortStrong
        marketState := "WATCH SHORT"

    else
        marketState := "WAIT"

trendText =
     close > ema20 and ema20 > ema50 and ema50 > ema200 ? "STRONG BULL | " :
     close < ema20 and ema20 < ema50 and ema50 < ema200 ? "STRONG BEAR | " :
     close > ema200 ? "BULL | " :
     close < ema200 ? "BEAR | " :
     "NEUTRAL | "

finalStatus = trendText + marketState

statusColor =
     str.contains(finalStatus, "ENTER") ? color.lime :
     str.contains(finalStatus, "SETUP") ? color.aqua :
     str.contains(finalStatus, "WATCH") ? color.yellow :
     str.contains(finalStatus, "RETEST") ? color.orange :
     str.contains(finalStatus, "BREAKOUT") ? color.green :
     str.contains(finalStatus, "WAIT") ? color.gray :
     color.white
// =====================
// VOLUME COLOR
// =====================
isBullVol = close > open


// =====================
// TABLE (Small Excel Style - Bottom Left + HTF Bias + STRUCTURE S/R)
// =====================
var table infoTable = table.new(tablePos, 2, 10, 
     bgcolor = color.new(color.black, 75),
     border_width = 1,
     frame_width = 1,
     frame_color = color.gray,
     border_color = color.gray)

// =====================
// HTF BIAS
// =====================
f_getBias(tf, emaLen) =>
    emaVal = ta.ema(close, emaLen)
    bias = close > emaVal + (emaVal * 0.0005) ? "BULL" :
           close < emaVal - (emaVal * 0.0005) ? "BEAR" :
           "NEUT"
    bias

htfBias5m  = request.security(syminfo.tickerid, "5",  f_getBias("5", 50))
htfBias15m = request.security(syminfo.tickerid, "15", f_getBias("15", 50))
htfBias1H  = request.security(syminfo.tickerid, "60",  f_getBias("60", 89))
htfBias4H  = request.security(syminfo.tickerid, "240", f_getBias("240", 89))

// =====================
// STRUCTURE S/R (FIXED)
// =====================
pivotLenSR = 5

ph_sr = ta.pivothigh(high, pivotLenSR, pivotLenSR)
pl_sr = ta.pivotlow(low, pivotLenSR, pivotLenSR)

var float lastSupport = na
var float lastResistance = na

// store latest structure levels
if not na(pl_sr) and pl_sr < close
    lastSupport := pl_sr

if not na(ph_sr) and ph_sr > close
    lastResistance := ph_sr

// distance from current price
supDist = not na(lastSupport) ? math.abs(close - lastSupport) : na
resDist = not na(lastResistance) ? math.abs(close - lastResistance) : na

// format (2 decimals)
supportText = not na(lastSupport) 
     ? str.tostring(lastSupport, "#.##") + " (" + str.tostring(supDist, "#") + ")" 
     : "—"

resistanceText = not na(lastResistance) 
     ? str.tostring(lastResistance, "#.##") + " (" + str.tostring(resDist, "#") + ")" 
     : "—"

// =====================
// TABLE
// =====================
if barstate.islast and showInfoBox
    table.cell(infoTable, 0, 0, "TYPE",  text_color = color.white, text_size = size.small, bgcolor = color.new(color.gray, 60))
    table.cell(infoTable, 1, 0, "VALUE", text_color = color.white, text_size = size.small, bgcolor = color.new(color.gray, 60))

    table.cell(infoTable, 0, 1, "RANGE", text_color = color.white, text_size = size.small)
    table.cell(infoTable, 1, 1, 
         (na(rangeLow) ? "—" : str.tostring(rangeLow, "#.##")) + " - " + 
         (na(rangeHigh) ? "—" : str.tostring(rangeHigh, "#.##")), 
         text_color = color.yellow, text_size = size.small)

    table.cell(infoTable, 0, 2, "5m Bias",  text_color = color.white, text_size = size.small)
    table.cell(infoTable, 1, 2, htfBias5m,  text_color = htfBias5m == "BULL" ? color.lime : htfBias5m == "BEAR" ? color.red : color.gray, text_size = size.small)

    table.cell(infoTable, 0, 3, "15m Bias", text_color = color.white, text_size = size.small)
    table.cell(infoTable, 1, 3, htfBias15m, text_color = htfBias15m == "BULL" ? color.lime : htfBias15m == "BEAR" ? color.red : color.gray, text_size = size.small)

    table.cell(infoTable, 0, 4, "1H Bias",  text_color = color.white, text_size = size.small)
    table.cell(infoTable, 1, 4, htfBias1H,  text_color = htfBias1H == "BULL" ? color.lime : htfBias1H == "BEAR" ? color.red : color.gray, text_size = size.small)

    table.cell(infoTable, 0, 5, "4H Bias",  text_color = color.white, text_size = size.small)
    table.cell(infoTable, 1, 5, htfBias4H,  text_color = htfBias4H == "BULL" ? color.lime : htfBias4H == "BEAR" ? color.red : color.gray, text_size = size.small)

    // ✅ SUPPORT (REAL)
    table.cell(infoTable, 0, 6, "Support", text_color = color.white, text_size = size.small)
    table.cell(infoTable, 1, 6, supportText, text_color = color.lime, text_size = size.small)

    // ✅ RESISTANCE (REAL)
    table.cell(infoTable, 0, 7, "Resistance", text_color = color.white, text_size = size.small)
    table.cell(infoTable, 1, 7, resistanceText, text_color = color.red, text_size = size.small)

    table.cell(infoTable, 0, 8, "STATUS", text_color = color.white, text_size = size.small)
    table.cell(infoTable, 1, 8, finalStatus, text_color = statusColor, text_size = size.small)

    table.cell(infoTable, 0, 9, "VOLUME", text_color = color.white, text_size = size.small)
    table.cell(infoTable, 1, 9,
         str.tostring(math.round(volume)) + " / " + str.tostring(math.round(nz(lockedAvgVol, currentAvgVol))),
         text_color = isBullVol ? color.green : color.red, 
         text_size = size.small)
// =====================
// ALERTS
// =====================
bullBreakAlert = bullBreakRaw and strongVol
bearBreakAlert = bearBreakRaw and strongVol
volumeSpike    = not na(lockedAvgVol) and volume > lockedAvgVol * 1.5
vwapTouch      = low <= vwapValue and high >= vwapValue

triggerAlert = bullBreakAlert or bearBreakAlert or volumeSpike or vwapTouch

alertMessage =
     bullBreakAlert ? "BUY BREAKOUT (STRONG VOL)" :
     bearBreakAlert ? "SELL BREAKDOWN (STRONG VOL)" :
     volumeSpike and close > open ? "BUY SIDE VOLUME SPIKE" :
     volumeSpike and close < open ? "SELL SIDE VOLUME SPIKE" :
     vwapTouch ? "PRICE TOUCHED VWAP" :
     "MOVE"

if triggerAlert
    alert(alertMessage, alert.freq_once_per_bar_close)
````
