# Fisher Sweep Trap [ZOM]

- url: https://www.tradingview.com/script/0XrAfSRJ-Fisher-Sweep-Trap-ZOM/
- type: indicator
- pine_id: PUB;b3ff550beb0948e2887387ffe42e8d00
- version: 1.0

## Description

Fisher Sweep Trap [ZOM] is a clean liquidity-sweep reversal overlay built to spot failed breakout conditions around recent Donchian structure.

The script watches for price to sweep above or below a prior range, reject with an ATR-normalized wick, and then score the setup with Fisher Transform pressure, Money Flow Index exhaustion, and optional EMA bias context. The result is a practical failed-breakout / trap signal tool that shows both early watch conditions and stronger confirmed trap signals.

What it uses:
- Donchian high/low sweep context
- ATR-normalized wick rejection
- Ehlers-style Fisher Transform pressure and snapback
- Money Flow Index exhaustion or turn behavior
- Optional EMA bias scoring
- Signal Mode: Early, Balanced, Strict
- Price-locked watch dots and confirmed crosses

Signal logic:
- Amber watch dots mark sweep-rejection setups that are forming but not fully confirmed.
- Teal confirmed crosses mark bullish sweep traps.
- Coral confirmed crosses mark bearish sweep traps.
- A cooldown filter helps reduce repeated signals during noisy chop.

Best use cases:
- Futures such as ES, NQ, YM, and RTY
- Crypto pairs such as BTCUSD and ETHUSD
- Forex majors
- Liquid equities and ETFs
- Intraday failed breakout, liquidity sweep, and stop-run reversal review

Visuals:
The default Slate Ember template uses a subtle Donchian sweep zone with small amber watch markers and stronger teal/coral confirmation markers. All markers are plotted as price-series outputs so they stay attached to chart time and price while panning or zooming.

This script is not a prediction engine. It is a context and confirmation tool for traders studying failed breakouts, liquidity sweeps, wick rejection, and trap-style reversals.

Open-source Pine Script by ZenOutMan.

Keywords: liquidity sweep indicator, failed breakout, bull trap, bear trap, Fisher Transform, Money Flow Index, Donchian channel, wick rejection, TradingView overlay, futures trading, crypto indicator, forex indicator, Pine Script, ZOM.

## Source Code

````pine
// This Pine Script code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// Copyright ZenOutMan

//@version=6
indicator("Fisher Sweep Trap [ZOM]", shorttitle="FST [ZOM]", overlay=true)

grpCore = "Liquidity Sweep"
signalMode = input.string("Balanced", "Signal Mode", options=["Early", "Balanced", "Strict"], group=grpCore)
donLen = input.int(20, "Donchian Lookback", minval=5, maxval=200, group=grpCore)
cooldownBars = input.int(8, "Signal Cooldown Bars", minval=0, maxval=100, group=grpCore)

grpMomentum = "Momentum & Flow"
fishLen = input.int(9, "Fisher Length", minval=3, maxval=50, group=grpMomentum)
fishExtreme = input.float(1.45, "Fisher Extreme", minval=0.5, maxval=4.0, step=0.05, group=grpMomentum)
mfiLen = input.int(14, "MFI Length", minval=3, maxval=80, group=grpMomentum)
mfiOb = input.int(78, "MFI Overbought", minval=50, maxval=100, group=grpMomentum)
mfiOs = input.int(22, "MFI Oversold", minval=0, maxval=50, group=grpMomentum)

grpReject = "Wick Rejection"
atrLen = input.int(14, "ATR Length", minval=3, maxval=100, group=grpReject)
wickMult = input.float(0.42, "Wick / ATR Threshold", minval=0.05, maxval=2.0, step=0.05, group=grpReject)

grpFilter = "Regime Filter"
useEma = input.bool(false, "Use EMA Bias Score", group=grpFilter)
emaLen = input.int(200, "EMA Length", minval=20, maxval=500, group=grpFilter)

grpStyle = "Visuals"
theme = input.string("Slate Ember", "Aesthetic Template", options=["Slate Ember", "Forest", "Mono"], group=grpStyle)
showChannel = input.bool(true, "Donchian Channel", group=grpStyle)
showMidline = input.bool(true, "Channel Midline", group=grpStyle)
showWatch = input.bool(true, "Sweep Watch Dots", group=grpStyle)
showSignals = input.bool(true, "Signal Crosses", group=grpStyle)
showBarColor = input.bool(true, "Signal Bar Color", group=grpStyle)

bull = theme == "Forest" ? color.rgb(64, 188, 132) : theme == "Mono" ? color.rgb(230, 230, 230) : color.rgb(37, 188, 172)
bear = theme == "Forest" ? color.rgb(232, 118, 72) : theme == "Mono" ? color.rgb(115, 115, 115) : color.rgb(255, 117, 92)
watch = theme == "Forest" ? color.rgb(224, 176, 79) : theme == "Mono" ? color.rgb(185, 185, 185) : color.rgb(239, 178, 92)
mid = theme == "Forest" ? color.rgb(136, 166, 118) : theme == "Mono" ? color.rgb(160, 160, 160) : color.rgb(134, 148, 162)
wash = theme == "Forest" ? color.rgb(16, 34, 28) : color.rgb(18, 24, 31)

upperChannel = ta.highest(high, donLen)[1]
lowerChannel = ta.lowest(low, donLen)[1]
midChannel = math.avg(upperChannel, lowerChannel)

sweepHigh = high > upperChannel
sweepLow = low < lowerChannel

fishHigh = ta.highest(hl2, fishLen)
fishLow = ta.lowest(hl2, fishLen)
fishRange = math.max(fishHigh - fishLow, syminfo.mintick)

var float fishValue = 0.0
fishValue := 0.66 * ((hl2 - fishLow) / fishRange - 0.5) + 0.67 * nz(fishValue[1])
fishValue := math.max(math.min(fishValue, 0.99), -0.99)

var float fisher = 0.0
fisher := 0.5 * math.log((1.0 + fishValue) / (1.0 - fishValue)) + 0.5 * nz(fisher[1])
fisherSignal = fisher[1]

fishBearTurn = fisher < fisherSignal and fisherSignal > fishExtreme
fishBullTurn = fisher > fisherSignal and fisherSignal < -fishExtreme
fishBearPressure = fisher > fishExtreme * 0.72 or fishBearTurn
fishBullPressure = fisher < -fishExtreme * 0.72 or fishBullTurn

mfi = ta.mfi(hlc3, mfiLen)
mfiBear = mfi > mfiOb or mfi[1] > mfiOb
mfiBull = mfi < mfiOs or mfi[1] < mfiOs
mfiBearTurn = mfi[1] > mfiOb - 4 and mfi < mfi[1]
mfiBullTurn = mfi[1] < mfiOs + 4 and mfi > mfi[1]

atr = ta.atr(atrLen)
upperWick = high - math.max(open, close)
lowerWick = math.min(open, close) - low
body = math.max(math.abs(close - open), syminfo.mintick)

bearRejection = upperWick > atr * wickMult and upperWick > body * 0.55 and close < upperChannel
bullRejection = lowerWick > atr * wickMult and lowerWick > body * 0.55 and close > lowerChannel

ema = ta.ema(close, emaLen)
emaSlope = ema - ema[3]
bullBias = close > ema or emaSlope > 0
bearBias = close < ema or emaSlope < 0

baseShort = sweepHigh and bearRejection
baseLong = sweepLow and bullRejection

shortScore = (fishBearPressure ? 1 : 0) + ((mfiBear or mfiBearTurn) ? 1 : 0) + (useEma and bearBias ? 1 : 0)
longScore = (fishBullPressure ? 1 : 0) + ((mfiBull or mfiBullTurn) ? 1 : 0) + (useEma and bullBias ? 1 : 0)
scoreNeeded = signalMode == "Strict" ? 3 : signalMode == "Early" ? 1 : 2

watchShort = baseShort and shortScore < scoreNeeded
watchLong = baseLong and longScore < scoreNeeded
rawShort = baseShort and shortScore >= scoreNeeded
rawLong = baseLong and longScore >= scoreNeeded

var int lastSignal = na
cooldownOk = na(lastSignal) or bar_index - lastSignal > cooldownBars
longSignal = cooldownOk and rawLong
shortSignal = cooldownOk and rawShort
if longSignal or shortSignal
    lastSignal := bar_index

upperPlot = plot(showChannel ? upperChannel : na, "Sweep High Boundary", color=color.new(mid, 40), style=plot.style_linebr, linewidth=1)
lowerPlot = plot(showChannel ? lowerChannel : na, "Sweep Low Boundary", color=color.new(mid, 40), style=plot.style_linebr, linewidth=1)
plot(showMidline ? midChannel : na, "Trap Midline", color=color.new(mid, 72), linewidth=1)
fill(upperPlot, lowerPlot, color=showChannel ? color.new(wash, 88) : na, title="Sweep Zone")

longMarker = low - atr * 0.18
shortMarker = high + atr * 0.18
watchLongMarker = low - atr * 0.08
watchShortMarker = high + atr * 0.08
plot(showWatch and watchLong ? watchLongMarker : na, "FST Long Watch", color=color.new(watch, 0), style=plot.style_circles, linewidth=2)
plot(showWatch and watchShort ? watchShortMarker : na, "FST Short Watch", color=color.new(watch, 0), style=plot.style_circles, linewidth=2)
plot(showSignals and longSignal ? longMarker : na, "FST Long Sweep Trap", color=color.new(bull, 0), style=plot.style_cross, linewidth=4)
plot(showSignals and shortSignal ? shortMarker : na, "FST Short Sweep Trap", color=color.new(bear, 0), style=plot.style_cross, linewidth=4)

barTone = longSignal ? color.new(bull, 0) : shortSignal ? color.new(bear, 0) : na
barcolor(showBarColor ? barTone : na)

alertcondition(longSignal, "Fisher Sweep Trap Long [ZOM]", "Fisher Sweep Trap [ZOM]: bullish sweep trap on {{ticker}} {{interval}}.")
alertcondition(shortSignal, "Fisher Sweep Trap Short [ZOM]", "Fisher Sweep Trap [ZOM]: bearish sweep trap on {{ticker}} {{interval}}.")
alertcondition(watchLong, "Fisher Sweep Trap Long Watch [ZOM]", "Fisher Sweep Trap [ZOM]: bullish sweep watch on {{ticker}} {{interval}}.")
alertcondition(watchShort, "Fisher Sweep Trap Short Watch [ZOM]", "Fisher Sweep Trap [ZOM]: bearish sweep watch on {{ticker}} {{interval}}.")
````
