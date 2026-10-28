# Captain Profits Core V5

- url: https://www.tradingview.com/script/pciCoQu7-Captain-Profits-Core-V5/
- type: indicator
- pine_id: PUB;1289a728b66447dabeeeb6c5ba03819b
- version: 1.0

## Description

Confluence futures indicator designed for 5min edge

## Source Code

````pine
//@version=6
indicator("Captain Profits ES Core Indicator V5", overlay=true, max_labels_count=500)

//────────────────────────────────────────────
// Inputs
//────────────────────────────────────────────

groupUT = "1. UT Bot / ATR"
keyValue = input.float(1.0, "UT Bot Key Value / Sensitivity", minval=0.1, step=0.1, group=groupUT)
atrPeriod = input.int(10, "ATR Period", minval=1, group=groupUT)
useHA = input.bool(false, "Use Heikin Ashi Source", group=groupUT)
showTrail = input.bool(true, "Show UT Bot Trail", group=groupUT)

groupTrend = "2. ES Trend Filter"
useEmaTrend = input.bool(true, "Use EMA Trend Filter", group=groupTrend)
emaFastLen = input.int(21, "Fast EMA", minval=1, group=groupTrend)
emaSlowLen = input.int(200, "Slow EMA", minval=1, group=groupTrend)
showEMAs = input.bool(true, "Show EMAs", group=groupTrend)

groupVol = "3. Volume / Candle Strength"
useDominanceFilter = input.bool(true, "Use Candle Dominance Filter", group=groupVol)
dominanceThreshold = input.float(0.61, "Dominance Threshold", minval=0.50, maxval=0.95, step=0.01, group=groupVol)
useRelVolumeFilter = input.bool(true, "Use Real Volume Strength Filter", group=groupVol)
volumeMaLen = input.int(20, "Volume MA Length", minval=1, group=groupVol)
minVolumeMultiplier = input.float(1.00, "Minimum Volume vs Volume MA", minval=0.10, step=0.05, group=groupVol)
useVolumeFadeExit = input.bool(true, "Use Volume Fade Exit Warning", group=groupVol)
fadeBars = input.int(3, "Volume Fade Bars", minval=2, maxval=10, group=groupVol)

groupBreakout = "4. Breakout Confirmation"
breakoutMode = input.string("Close Break Only", "Breakout Filter", options=["Strict", "Close Break Only", "Off"], group=groupBreakout)

groupSignals = "5. Signals"
signalSide = input.string("Both", "Signal Direction", options=["Both", "Long Only", "Short Only"], group=groupSignals)
showExitLabels = input.bool(true, "Show Exit Labels", group=groupSignals)

//────────────────────────────────────────────
// Source
//────────────────────────────────────────────

haTicker = ticker.heikinashi(syminfo.tickerid)
haClose = request.security(haTicker, timeframe.period, close, gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
src = useHA ? haClose : close

//────────────────────────────────────────────
// UT Bot ATR Trailing Stop
//────────────────────────────────────────────

xATR = ta.atr(atrPeriod)
nLoss = keyValue * xATR

var float trail = na
prevTrail = nz(trail[1], src)

if src > prevTrail and src[1] > prevTrail
    trail := math.max(prevTrail, src - nLoss)
else if src < prevTrail and src[1] < prevTrail
    trail := math.min(prevTrail, src + nLoss)
else if src > prevTrail
    trail := src - nLoss
else
    trail := src + nLoss

utBull = src > trail
utBear = src < trail

//────────────────────────────────────────────
// EMA Trend Filter
//────────────────────────────────────────────

emaFast = ta.ema(close, emaFastLen)
emaSlow = ta.ema(close, emaSlowLen)

emaBull = close > emaSlow and emaFast > emaSlow
emaBear = close < emaSlow and emaFast < emaSlow

trendLongOk = not useEmaTrend or emaBull
trendShortOk = not useEmaTrend or emaBear

//────────────────────────────────────────────
// Candle Dominance + Real Volume Strength
//────────────────────────────────────────────

barRange = high - low
buyDominancePct = barRange == 0.0 ? 0.50 : (close - low) / barRange
sellDominancePct = barRange == 0.0 ? 0.50 : (high - close) / barRange

buyDominanceOk = not useDominanceFilter or buyDominancePct >= dominanceThreshold
sellDominanceOk = not useDominanceFilter or sellDominancePct >= dominanceThreshold

volumeMa = ta.sma(volume, volumeMaLen)
relativeVolumeOk = not useRelVolumeFilter or volume >= volumeMa * minVolumeMultiplier

isVolumeFading = true
for i = 0 to fadeBars - 1
    isVolumeFading := isVolumeFading and volume[i] < volume[i + 1]

//────────────────────────────────────────────
// Breakout Filter
//────────────────────────────────────────────

bullStrict = not na(open[1]) and low > open[1] and close > high[1] and close > open
bearStrict = not na(open[1]) and high < open[1] and close < low[1] and close < open

bullCloseBreak = not na(high[1]) and close > high[1] and close > open
bearCloseBreak = not na(low[1]) and close < low[1] and close < open

breakoutLongOk = breakoutMode == "Off" ? true : breakoutMode == "Strict" ? bullStrict : bullCloseBreak
breakoutShortOk = breakoutMode == "Off" ? true : breakoutMode == "Strict" ? bearStrict : bearCloseBreak

//────────────────────────────────────────────
// Final Signal Logic
//────────────────────────────────────────────

allowLong = signalSide == "Both" or signalSide == "Long Only"
allowShort = signalSide == "Both" or signalSide == "Short Only"

rawBuy = allowLong and utBull and trendLongOk and buyDominanceOk and relativeVolumeOk and breakoutLongOk
rawSell = allowShort and utBear and trendShortOk and sellDominanceOk and relativeVolumeOk and breakoutShortOk

var int positionState = 0

buySignal = rawBuy and positionState != 1
sellSignal = rawSell and positionState != -1

exitLong = positionState == 1 and not buySignal and (src < trail or (useVolumeFadeExit and isVolumeFading and close < open))
exitShort = positionState == -1 and not sellSignal and (src > trail or (useVolumeFadeExit and isVolumeFading and close > open))

if buySignal
    positionState := 1
else if sellSignal
    positionState := -1
else if exitLong or exitShort
    positionState := 0

//────────────────────────────────────────────
// Plots
//────────────────────────────────────────────

trailColor = utBull ? color.green : color.red

plot(showTrail ? trail : na, title="UT Bot ATR Trail", color=trailColor, linewidth=2)
plot(showEMAs ? emaFast : na, title="Fast EMA", color=color.new(color.blue, 0), linewidth=1)
plot(showEMAs ? emaSlow : na, title="Slow EMA", color=color.new(color.orange, 0), linewidth=2)

plotshape(buySignal, title="Buy Signal", text="BUY", style=shape.labelup, location=location.belowbar, color=color.new(color.green, 0), textcolor=color.white, size=size.small)
plotshape(sellSignal, title="Sell Signal", text="SELL", style=shape.labeldown, location=location.abovebar, color=color.new(color.red, 0), textcolor=color.white, size=size.small)
plotshape(showExitLabels and exitLong, title="Exit Long", text="EXIT L", style=shape.labeldown, location=location.abovebar, color=color.new(color.orange, 0), textcolor=color.white, size=size.tiny)
plotshape(showExitLabels and exitShort, title="Exit Short", text="EXIT S", style=shape.labelup, location=location.belowbar, color=color.new(color.orange, 0), textcolor=color.white, size=size.tiny)

//────────────────────────────────────────────
// Alerts
//────────────────────────────────────────────

alertcondition(buySignal, title="Captain Buy Alert", message="Captain Profits ES Core BUY signal")
alertcondition(sellSignal, title="Captain Sell Alert", message="Captain Profits ES Core SELL signal")
alertcondition(exitLong, title="Captain Exit Long Alert", message="Captain Profits ES Core EXIT LONG warning")
alertcondition(exitShort, title="Captain Exit Short Alert", message="Captain Profits ES Core EXIT SHORT warning")
````
