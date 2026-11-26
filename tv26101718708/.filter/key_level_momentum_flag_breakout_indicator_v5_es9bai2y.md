# Key Level Momentum Flag Breakout Indicator V5

- url: https://www.tradingview.com/script/es9BAI2y-Key-Level-Momentum-Flag-Breakout-Indicator-V5/
- type: indicator
- pine_id: PUB;fb96a63292374f35817e5dcb1c3e0101
- version: 1.0

## Description

Bull/Bear Flag entries
A+ Continuation entries
Momentum Ignition entries
Key level labels
Long/short exits
VWAP, 9 EMA, 20 EMA
Premarket high/low
Yesterday high/low
Bull/Bear/Chop dashboard

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © alexmauer

//@version=6
indicator("Key Level Momentum Flag Breakout Indicator V5", overlay=true, max_labels_count=500)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Inputs
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

showPremarketLevels = input.bool(true, "Show Premarket High/Low")
showYesterdayLevels = input.bool(true, "Show Yesterday High/Low")
showVWAP            = input.bool(true, "Show VWAP")
showEMAs            = input.bool(true, "Show 9 EMA / 20 EMA")
showLevelLabels     = input.bool(true, "Label Key Levels")
showEntryLabels     = input.bool(true, "Show Entry Labels")
showExitLabels      = input.bool(true, "Show Exit Labels")

pmSession = input.session("0400-0929", "Premarket Session")
pmTZ      = input.string("America/New_York", "Premarket Timezone")

tradeSession = input.session("0730-1000", "Signal Window")
tradeTZ      = input.string("America/Denver", "Signal Window Timezone")

emaFastLen = input.int(9, "Fast EMA", minval=1)
emaSlowLen = input.int(20, "Slow EMA", minval=1)

volLen      = input.int(20, "Volume SMA Length", minval=1)
volMult     = input.float(1.15, "Breakout Volume Multiplier", step=0.1)
contVolMult = input.float(1.0, "Continuation Volume Multiplier", step=0.1)

atrLen      = input.int(14, "ATR Length", minval=1)
nearATRMult = input.float(1.0, "How Close To Key Level? ATR Multiplier", step=0.25)

impulseLookback = input.int(5, "Impulse Lookback Bars", minval=1)
impulseATRMult  = input.float(0.5, "Impulse Strength ATR Multiplier", step=0.1)

flagLookback = input.int(6, "Flag Breakout Lookback", minval=2)
setupWindow  = input.int(30, "Bars After Key Level Break", minval=1)

useMACDFilter   = input.bool(true, "Use MACD Momentum Filter")
useVolumeFilter = input.bool(true, "Use Volume Filter")
useSessionOnly  = input.bool(true, "Only Signal During Trade Window")

useBearContinuation = input.bool(true, "Add Bear Continuation Entries")
useBullContinuation = input.bool(true, "Add Bull Continuation Entries")

pullbackLookback       = input.int(10, "Continuation Pullback Lookback", minval=2)
rejectionATR           = input.float(0.5, "EMA/VWAP Rejection ATR Distance", step=0.1)
microStructureLookback = input.int(3, "Micro Break Lookback", minval=2)

requireRejectionCandle = input.bool(true, "Require Rejection Candle For Continuation")
requirePullbackFirst   = input.bool(true, "Require Pullback Before Continuation")

useMomentumIgnition = input.bool(true, "Add Momentum Ignition Entries")
ignitionLookback    = input.int(8, "Ignition Range Lookback", minval=3)
bodyATRMult         = input.float(0.35, "Ignition Body ATR Strength", step=0.05)

exitOnEMA9Loss   = input.bool(true, "Exit On 9 EMA Loss/Reclaim")
exitOnVWAPLoss   = input.bool(false, "Exit On VWAP Loss/Reclaim")
exitOnMACDFade   = input.bool(true, "Exit On MACD Momentum Fade")
exitOnOppSignal  = input.bool(true, "Exit On Opposite Signal")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Core Indicators
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

ema9  = ta.ema(close, emaFastLen)
ema20 = ta.ema(close, emaSlowLen)
vwap  = ta.vwap(close)

atr = ta.atr(atrLen)
volSMA = ta.sma(volume, volLen)

[macdLine, macdSignal, macdHist] = ta.macd(close, 12, 26, 9)

inTradeSession = not na(time(timeframe.period, tradeSession, tradeTZ))
allowSignal = useSessionOnly ? inTradeSession : true

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Premarket High / Low
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

inPremarket = not na(time(timeframe.period, pmSession, pmTZ))
newPremarket = inPremarket and not inPremarket[1]

var float pmHigh = na
var float pmLow  = na

if newPremarket
    pmHigh := high
    pmLow  := low
else if inPremarket
    pmHigh := math.max(pmHigh, high)
    pmLow  := math.min(pmLow, low)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Yesterday High / Low
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

yHigh = request.security(syminfo.tickerid, "D", high[1], lookahead=barmerge.lookahead_on)
yLow  = request.security(syminfo.tickerid, "D", low[1], lookahead=barmerge.lookahead_on)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Key Level Logic
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

nearLevel(level) =>
    not na(level) and math.abs(close - level) <= atr * nearATRMult

breakAbove(level) =>
    not na(level) and close > level and close[1] <= level

breakBelow(level) =>
    not na(level) and close < level and close[1] >= level

aboveAnyBullKey =
     close > pmHigh or
     close > yHigh

belowAnyBearKey =
     close < pmLow or
     close < yLow

nearBullKey =
     nearLevel(pmHigh) or
     nearLevel(yHigh) or
     aboveAnyBullKey or
     close > vwap

nearBearKey =
     nearLevel(pmLow) or
     nearLevel(yLow) or
     belowAnyBearKey or
     close < vwap

bullKeyBreak =
     breakAbove(pmHigh) or
     breakAbove(yHigh)

bearKeyBreak =
     breakBelow(pmLow) or
     breakBelow(yLow)

barsSinceBullBreak = ta.barssince(bullKeyBreak)
barsSinceBearBreak = ta.barssince(bearKeyBreak)

recentBullKeyBreak = not na(barsSinceBullBreak) and barsSinceBullBreak <= setupWindow
recentBearKeyBreak = not na(barsSinceBearBreak) and barsSinceBearBreak <= setupWindow

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Momentum Filters
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

bullTrend =
     close > vwap and
     ema9 > ema20 and
     close > ema9

bearTrend =
     close < vwap and
     ema9 < ema20 and
     close < ema9

bullMACD = macdHist > 0 and macdHist > macdHist[1]
bearMACD = macdHist < 0 and macdHist < macdHist[1]

volumeOK = volume > volSMA * volMult
continuationVolumeOK = volume >= volSMA * contVolMult

bullImpulse =
     close > close[impulseLookback] + atr * impulseATRMult and
     close > open

bearImpulse =
     close < close[impulseLookback] - atr * impulseATRMult and
     close < open

bullMomentumOK =
     bullTrend and
     bullImpulse and
     (useMACDFilter ? bullMACD : true) and
     (useVolumeFilter ? volumeOK : true)

bearMomentumOK =
     bearTrend and
     bearImpulse and
     (useMACDFilter ? bearMACD : true) and
     (useVolumeFilter ? volumeOK : true)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Main Bull Flag / Bear Flag Logic
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

flagHigh = ta.highest(high, flagLookback)[1]
flagLow  = ta.lowest(low, flagLookback)[1]

controlledBullPullback =
     ta.lowest(low, flagLookback) > ema20 and
     close > vwap

controlledBearPullback =
     ta.highest(high, flagLookback) < ema20 and
     close < vwap

bullFlagBreakout =
     allowSignal and
     recentBullKeyBreak and
     nearBullKey and
     bullMomentumOK and
     controlledBullPullback and
     close > flagHigh

bearFlagBreakdown =
     allowSignal and
     recentBearKeyBreak and
     nearBearKey and
     bearMomentumOK and
     controlledBearPullback and
     close < flagLow

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// A+ Continuation Entry Logic
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

recentTouchEMA9Long =
     ta.lowest(math.abs(low - ema9), pullbackLookback) <= atr * rejectionATR

recentTouchEMA20Long =
     ta.lowest(math.abs(low - ema20), pullbackLookback) <= atr * rejectionATR

recentTouchVWAPLong =
     ta.lowest(math.abs(low - vwap), pullbackLookback) <= atr * rejectionATR

recentTouchEMA9Short =
     ta.lowest(math.abs(high - ema9), pullbackLookback) <= atr * rejectionATR

recentTouchEMA20Short =
     ta.lowest(math.abs(high - ema20), pullbackLookback) <= atr * rejectionATR

recentTouchVWAPShort =
     ta.lowest(math.abs(high - vwap), pullbackLookback) <= atr * rejectionATR

bullPullbackToSupport =
     recentTouchEMA9Long or
     recentTouchEMA20Long or
     recentTouchVWAPLong

bearPullbackToResistance =
     recentTouchEMA9Short or
     recentTouchEMA20Short or
     recentTouchVWAPShort

bullRejectionCandle =
     close > open and
     close > ema9 and
     low <= ema9 and
     close > close[1]

bearRejectionCandle =
     close < open and
     close < ema9 and
     high >= ema9 and
     close < close[1]

microHigh = ta.highest(high, microStructureLookback)[1]
microLow  = ta.lowest(low, microStructureLookback)[1]

bullMicroBreak =
     close > microHigh and
     close > open

bearMicroBreak =
     close < microLow and
     close < open

bullMACDContinuation =
     macdHist > 0 and
     macdHist >= macdHist[1]

bearMACDContinuation =
     macdHist < 0 and
     macdHist <= macdHist[1]

bullContinuationBreakout =
     allowSignal and
     useBullContinuation and
     bullTrend and
     nearBullKey and
     (requirePullbackFirst ? bullPullbackToSupport : true) and
     (requireRejectionCandle ? bullRejectionCandle : true) and
     bullMicroBreak and
     (useMACDFilter ? bullMACDContinuation : true) and
     (useVolumeFilter ? continuationVolumeOK : true)

bearContinuationBreakdown =
     allowSignal and
     useBearContinuation and
     bearTrend and
     nearBearKey and
     (requirePullbackFirst ? bearPullbackToResistance : true) and
     (requireRejectionCandle ? bearRejectionCandle : true) and
     bearMicroBreak and
     (useMACDFilter ? bearMACDContinuation : true) and
     (useVolumeFilter ? continuationVolumeOK : true)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Momentum Ignition Entry Logic
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

rangeHigh = ta.highest(high, ignitionLookback)[1]
rangeLow  = ta.lowest(low, ignitionLookback)[1]

candleBody = math.abs(close - open)
strongBody = candleBody >= atr * bodyATRMult

bullIgnition =
     allowSignal and
     useMomentumIgnition and
     close > vwap and
     ema9 > ema20 and
     close > ema9 and
     close > rangeHigh and
     close > open and
     strongBody and
     (useVolumeFilter ? continuationVolumeOK : true) and
     (useMACDFilter ? macdHist > macdHist[1] : true)

bearIgnition =
     allowSignal and
     useMomentumIgnition and
     close < vwap and
     ema9 < ema20 and
     close < ema9 and
     close < rangeLow and
     close < open and
     strongBody and
     (useVolumeFilter ? continuationVolumeOK : true) and
     (useMACDFilter ? macdHist < macdHist[1] : true)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Final Entry Signals
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

longSignal = bullFlagBreakout or bullContinuationBreakout or bullIgnition
shortSignal = bearFlagBreakdown or bearContinuationBreakdown or bearIgnition

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Trade State For Exit Labels
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

var int tradeState = 0
// 0 = flat
// 1 = long
// -1 = short

newLongEntry = longSignal and tradeState != 1
newShortEntry = shortSignal and tradeState != -1

longExitCondition =
     tradeState == 1 and
     (
         (exitOnEMA9Loss and close < ema9) or
         (exitOnVWAPLoss and close < vwap) or
         (exitOnMACDFade and macdHist < macdHist[1] and macdHist > 0) or
         (exitOnOppSignal and shortSignal)
     )

shortExitCondition =
     tradeState == -1 and
     (
         (exitOnEMA9Loss and close > ema9) or
         (exitOnVWAPLoss and close > vwap) or
         (exitOnMACDFade and macdHist > macdHist[1] and macdHist < 0) or
         (exitOnOppSignal and longSignal)
     )

if newLongEntry
    tradeState := 1
else if newShortEntry
    tradeState := -1
else if longExitCondition or shortExitCondition
    tradeState := 0

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Plot Levels
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

plot(showPremarketLevels ? pmHigh : na, "PM High", color=color.new(color.green, 0), linewidth=2)
plot(showPremarketLevels ? pmLow  : na, "PM Low",  color=color.new(color.red, 0), linewidth=2)

plot(showYesterdayLevels ? yHigh : na, "Yesterday High", color=color.new(color.yellow, 0), linewidth=2)
plot(showYesterdayLevels ? yLow  : na, "Yesterday Low",  color=color.new(color.yellow, 0), linewidth=2)

plot(showVWAP ? vwap : na, "VWAP", color=color.new(color.orange, 0), linewidth=2)

plot(showEMAs ? ema9  : na, "9 EMA",  color=color.new(color.blue, 0), linewidth=2)
plot(showEMAs ? ema20 : na, "20 EMA", color=color.new(color.purple, 0), linewidth=2)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Key Level Labels
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

var label pmHighLabel = na
var label pmLowLabel  = na
var label yHighLabel  = na
var label yLowLabel   = na

if barstate.islast and showLevelLabels
    label.delete(pmHighLabel)
    label.delete(pmLowLabel)
    label.delete(yHighLabel)
    label.delete(yLowLabel)

    if showPremarketLevels and not na(pmHigh)
        pmHighLabel := label.new(bar_index + 2, pmHigh, "PM HIGH", style=label.style_label_left, textcolor=color.white, color=color.green)

    if showPremarketLevels and not na(pmLow)
        pmLowLabel := label.new(bar_index + 2, pmLow, "PM LOW", style=label.style_label_left, textcolor=color.white, color=color.red)

    if showYesterdayLevels and not na(yHigh)
        yHighLabel := label.new(bar_index + 2, yHigh, "YEST HIGH", style=label.style_label_left, textcolor=color.black, color=color.yellow)

    if showYesterdayLevels and not na(yLow)
        yLowLabel := label.new(bar_index + 2, yLow, "YEST LOW", style=label.style_label_left, textcolor=color.black, color=color.yellow)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Entry + Exit Shapes
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

plotshape(
     showEntryLabels and newLongEntry and bullFlagBreakout,
     title="Long Bull Flag Entry",
     style=shape.labelup,
     location=location.belowbar,
     color=color.new(color.lime, 0),
     textcolor=color.black,
     size=size.normal,
     text="LONG\nBULL FLAG"
)

plotshape(
     showEntryLabels and newLongEntry and bullContinuationBreakout and not bullFlagBreakout,
     title="Long A+ Continuation Entry",
     style=shape.labelup,
     location=location.belowbar,
     color=color.new(color.green, 0),
     textcolor=color.white,
     size=size.normal,
     text="LONG\nA+ CONT"
)

plotshape(
     showEntryLabels and newLongEntry and bullIgnition and not bullFlagBreakout and not bullContinuationBreakout,
     title="Long Momentum Ignition",
     style=shape.labelup,
     location=location.belowbar,
     color=color.new(color.teal, 0),
     textcolor=color.white,
     size=size.normal,
     text="LONG\nIGNITION"
)

plotshape(
     showEntryLabels and newShortEntry and bearFlagBreakdown,
     title="Short Bear Flag Entry",
     style=shape.labeldown,
     location=location.abovebar,
     color=color.new(color.red, 0),
     textcolor=color.white,
     size=size.normal,
     text="SHORT\nBEAR FLAG"
)

plotshape(
     showEntryLabels and newShortEntry and bearContinuationBreakdown and not bearFlagBreakdown,
     title="Short A+ Continuation Entry",
     style=shape.labeldown,
     location=location.abovebar,
     color=color.new(color.maroon, 0),
     textcolor=color.white,
     size=size.normal,
     text="SHORT\nA+ CONT"
)

plotshape(
     showEntryLabels and newShortEntry and bearIgnition and not bearFlagBreakdown and not bearContinuationBreakdown,
     title="Short Momentum Ignition",
     style=shape.labeldown,
     location=location.abovebar,
     color=color.new(color.fuchsia, 0),
     textcolor=color.white,
     size=size.normal,
     text="SHORT\nIGNITION"
)

plotshape(
     showExitLabels and longExitCondition,
     title="Long Exit",
     style=shape.xcross,
     location=location.abovebar,
     color=color.new(color.orange, 0),
     size=size.normal,
     text="EXIT\nLONG"
)

plotshape(
     showExitLabels and shortExitCondition,
     title="Short Exit",
     style=shape.xcross,
     location=location.belowbar,
     color=color.new(color.orange, 0),
     size=size.normal,
     text="EXIT\nSHORT"
)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Dashboard
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

bullDay = close > vwap and ema9 > ema20 and macdHist > 0
bearDay = close < vwap and ema9 < ema20 and macdHist < 0

dayText = bullDay ? "BULL DAY" : bearDay ? "BEAR DAY" : "CHOP"
dayColor = bullDay ? color.green : bearDay ? color.red : color.gray

var table dash = table.new(position.top_right, 2, 9, border_width=1)

if barstate.islast
    table.cell(dash, 0, 0, "Market", bgcolor=color.black, text_color=color.white)
    table.cell(dash, 1, 0, dayText, bgcolor=dayColor, text_color=color.white)

    table.cell(dash, 0, 1, "VWAP", bgcolor=color.black, text_color=color.white)
    table.cell(dash, 1, 1, close > vwap ? "Above" : "Below", bgcolor=close > vwap ? color.green : color.red, text_color=color.white)

    table.cell(dash, 0, 2, "EMA Trend", bgcolor=color.black, text_color=color.white)
    table.cell(dash, 1, 2, ema9 > ema20 ? "Bull" : "Bear", bgcolor=ema9 > ema20 ? color.green : color.red, text_color=color.white)

    table.cell(dash, 0, 3, "MACD", bgcolor=color.black, text_color=color.white)
    table.cell(dash, 1, 3, macdHist > 0 ? "Bull" : "Bear", bgcolor=macdHist > 0 ? color.green : color.red, text_color=color.white)

    table.cell(dash, 0, 4, "Volume", bgcolor=color.black, text_color=color.white)
    table.cell(dash, 1, 4, volumeOK ? "Strong" : "Weak", bgcolor=volumeOK ? color.green : color.gray, text_color=color.white)

    table.cell(dash, 0, 5, "Bull Cont.", bgcolor=color.black, text_color=color.white)
    table.cell(dash, 1, 5, useBullContinuation ? "ON" : "OFF", bgcolor=useBullContinuation ? color.green : color.gray, text_color=color.white)

    table.cell(dash, 0, 6, "Bear Cont.", bgcolor=color.black, text_color=color.white)
    table.cell(dash, 1, 6, useBearContinuation ? "ON" : "OFF", bgcolor=useBearContinuation ? color.green : color.gray, text_color=color.white)

    table.cell(dash, 0, 7, "Ignition", bgcolor=color.black, text_color=color.white)
    table.cell(dash, 1, 7, useMomentumIgnition ? "ON" : "OFF", bgcolor=useMomentumIgnition ? color.green : color.gray, text_color=color.white)

    table.cell(dash, 0, 8, "Position", bgcolor=color.black, text_color=color.white)
    table.cell(dash, 1, 8, tradeState == 1 ? "Long" : tradeState == -1 ? "Short" : "Flat", bgcolor=tradeState == 1 ? color.green : tradeState == -1 ? color.red : color.gray, text_color=color.white)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Alerts
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

alertcondition(newLongEntry, title="Long Entry", message="Long flag, A+ continuation, or ignition entry")
alertcondition(newShortEntry, title="Short Entry", message="Short flag, A+ continuation, or ignition entry")
alertcondition(longExitCondition, title="Exit Long", message="Exit long signal")
alertcondition(shortExitCondition, title="Exit Short", message="Exit short signal")
````
