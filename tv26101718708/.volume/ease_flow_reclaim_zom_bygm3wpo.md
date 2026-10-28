# Ease Flow Reclaim [ZOM]

- url: https://www.tradingview.com/script/BYGM3wpO-Ease-Flow-Reclaim-ZOM/
- type: indicator
- pine_id: PUB;f0cf4894207e484e8a95bf39d3acfc43
- version: 1.0

## Description

Ease Flow Reclaim [ZOM] is a clean overlay for spotting reclaim and rejection behavior when movement efficiency returns after localized stress.

The script combines a lesser-used Ease of Movement style pressure read with Ulcer Index stress relaxation and light VWMA/HMA trend context. The goal is to identify moments where price begins moving more efficiently after a drawdown or upside stress phase starts easing.

What it uses:
- Ease of Movement / EMV-style flow pressure
- Ulcer Index downside stress for bullish reclaims
- Inverted upside stress context for bearish rejections
- VWMA trend ribbon for volume-weighted direction
- HMA reclaim/rejection spine for cleaner confirmation
- Signal Mode: Early, Balanced, Strict
- Cooldown filtering to reduce repeated chop signals
- Price-locked watch and confirmed markers

Signal logic:
- Small amber watch circles mark setups that are close to confirmation.
- Teal crosses mark bullish ease-flow reclaim signals.
- Magenta crosses mark bearish ease-flow rejection signals.
- The ribbon shifts with VWMA/HMA trend context while staying subtle enough to keep candles readable.

Best use cases:
- ES, NQ, and other liquid futures
- BTCUSD and ETHUSD
- Liquid equities and ETFs
- Intraday continuation/reclaim review
- Spotting efficiency returning after stressful swings

Visuals:
The default Neon Slate template uses a slim VWMA flow ribbon, muted HMA spine, and compact price-series markers. No labels, boxes, lines, dashboards, or static drawings are used, so the plots stay attached to chart time and price while panning or zooming.

This script is not a prediction engine. It is a context and confirmation tool for traders studying movement efficiency, volume-weighted trend, Ulcer Index stress relief, and reclaim/rejection behavior.

Open-source Pine Script by ZenOutMan.

Keywords: Ease of Movement indicator, EMV, Ulcer Index, VWMA, HMA, reclaim signal, rejection signal, movement efficiency, volume weighted trend, futures trading, crypto indicator, TradingView overlay, Pine Script, ZOM.

## Source Code

````pine
// This Pine Script code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// (c) ZenOutMan

//@version=6
indicator("Ease Flow Reclaim [ZOM]", shorttitle="EFR [ZOM]", overlay=true)

grpSignal = "Signal Settings"
signalMode = input.string("Balanced", "Signal Mode", options=["Early", "Balanced", "Strict"], group=grpSignal)
showWatch = input.bool(true, "Show Watch Markers", group=grpSignal)
showSignals = input.bool(true, "Show Confirmed Signals", group=grpSignal)
cooldownBars = input.int(6, "Signal Cooldown", minval=0, group=grpSignal)
atrOffset = input.float(0.42, "Marker ATR Offset", minval=0.05, step=0.05, group=grpSignal)

grpEase = "Ease of Movement"
emvLen = input.int(13, "EMV Smoothing", minval=2, group=grpEase)
emvImpulseLen = input.int(5, "EMV Impulse Lookback", minval=2, group=grpEase)

grpStress = "Ulcer Stress"
ulcerLen = input.int(18, "Ulcer Length", minval=5, group=grpStress)
stressFloor = input.float(1.35, "Stress Floor", minval=0.1, step=0.05, group=grpStress)

grpTrend = "Trend Context"
trendLen = input.int(55, "VWMA Trend Length", minval=5, group=grpTrend)
hmaLen = input.int(34, "HMA Reclaim Length", minval=5, group=grpTrend)

grpStyle = "Aesthetic Template"
template = input.string("Neon Slate", "Template", options=["Neon Slate", "Ocean Glass", "Solar Noir"], group=grpStyle)

bullBase = template == "Ocean Glass" ? color.rgb(35, 211, 198) : template == "Solar Noir" ? color.rgb(255, 196, 77) : color.rgb(44, 220, 190)
bearBase = template == "Ocean Glass" ? color.rgb(244, 96, 119) : template == "Solar Noir" ? color.rgb(231, 84, 128) : color.rgb(238, 84, 154)
watchBase = template == "Ocean Glass" ? color.rgb(246, 214, 92) : template == "Solar Noir" ? color.rgb(145, 212, 255) : color.rgb(231, 205, 72)
neutralBase = template == "Ocean Glass" ? color.rgb(92, 126, 150) : template == "Solar Noir" ? color.rgb(112, 104, 96) : color.rgb(90, 104, 128)
ribbonBull = color.new(bullBase, 90)
ribbonBear = color.new(bearBase, 90)
ribbonNeutral = color.new(neutralBase, 94)

rangeSafe = math.max(high - low, syminfo.mintick)
midMove = hl2 - hl2[1]
boxRatio = volume > 0 ? (volume / 100000.0) / rangeSafe : 1.0 / rangeSafe
emvRaw = midMove / math.max(boxRatio, 0.000001)
emv = ta.ema(emvRaw, emvLen)
emvImpulse = emv - emv[emvImpulseLen]

highestClose = ta.highest(close, ulcerLen)
lowestClose = ta.lowest(close, ulcerLen)
downDraw = highestClose != 0.0 ? 100.0 * (close - highestClose) / highestClose : 0.0
upDraw = lowestClose != 0.0 ? 100.0 * (close - lowestClose) / lowestClose : 0.0
ulcerDown = math.sqrt(ta.sma(downDraw * downDraw, ulcerLen))
ulcerUp = math.sqrt(ta.sma(upDraw * upDraw, ulcerLen))
downStressEasing = ulcerDown < ulcerDown[1] and ulcerDown[1] > stressFloor
upStressEasing = ulcerUp < ulcerUp[1] and ulcerUp[1] > stressFloor

vwmaSlow = ta.vwma(close, trendLen)
vwmaFast = ta.vwma(close, math.max(2, math.round(trendLen * 0.5)))
hmaReclaim = ta.hma(close, hmaLen)
trendBull = vwmaFast > vwmaSlow and hmaReclaim > hmaReclaim[1]
trendBear = vwmaFast < vwmaSlow and hmaReclaim < hmaReclaim[1]

priceBullReclaim = close > hmaReclaim and close[1] <= hmaReclaim[1]
priceBearReject = close < hmaReclaim and close[1] >= hmaReclaim[1]
easeBull = emv > 0 and emvImpulse > 0
easeBear = emv < 0 and emvImpulse < 0

bullScore = (easeBull ? 1 : 0) + (downStressEasing ? 1 : 0) + (trendBull ? 1 : 0) + (priceBullReclaim ? 1 : 0)
bearScore = (easeBear ? 1 : 0) + (upStressEasing ? 1 : 0) + (trendBear ? 1 : 0) + (priceBearReject ? 1 : 0)
scoreNeed = signalMode == "Strict" ? 4 : signalMode == "Early" ? 2 : 3

rawLong = bullScore >= scoreNeed
rawShort = bearScore >= scoreNeed
watchLong = showWatch and bullScore == scoreNeed - 1 and not rawLong
watchShort = showWatch and bearScore == scoreNeed - 1 and not rawShort

var int lastSignal = na
cooldownOk = na(lastSignal) or bar_index - lastSignal > cooldownBars
longSignal = rawLong and cooldownOk
shortSignal = rawShort and cooldownOk
if longSignal or shortSignal
    lastSignal := bar_index

ribbonColor = trendBull ? ribbonBull : trendBear ? ribbonBear : ribbonNeutral
fastPlot = plot(vwmaFast, "Fast VWMA Flow", color=color.new(trendBull ? bullBase : trendBear ? bearBase : neutralBase, 18), linewidth=1)
slowPlot = plot(vwmaSlow, "Slow VWMA Flow", color=color.new(trendBull ? bullBase : trendBear ? bearBase : neutralBase, 68), linewidth=1)
fill(fastPlot, slowPlot, title="Ease Flow Ribbon", color=ribbonColor)
plot(hmaReclaim, "HMA Reclaim Spine", color=color.new(neutralBase, 52), linewidth=1)

atr = ta.atr(14)
longWatchMarker = low - atr * atrOffset * 0.55
shortWatchMarker = high + atr * atrOffset * 0.55
longMarker = low - atr * atrOffset
shortMarker = high + atr * atrOffset

plot(watchLong ? longWatchMarker : na, "EFR Long Watch", color=color.new(watchBase, 22), style=plot.style_circles, linewidth=1)
plot(watchShort ? shortWatchMarker : na, "EFR Short Watch", color=color.new(watchBase, 22), style=plot.style_circles, linewidth=1)
plot(showSignals and longSignal ? longMarker : na, "EFR Long Reclaim", color=color.new(bullBase, 0), style=plot.style_cross, linewidth=3)
plot(showSignals and shortSignal ? shortMarker : na, "EFR Short Rejection", color=color.new(bearBase, 0), style=plot.style_cross, linewidth=3)

barcolor(longSignal ? color.new(bullBase, 0) : shortSignal ? color.new(bearBase, 0) : na)

alertcondition(watchLong, "Ease Flow Reclaim Long Watch [ZOM]", "EFR [ZOM]: bullish ease-flow watch setup.")
alertcondition(watchShort, "Ease Flow Reclaim Short Watch [ZOM]", "EFR [ZOM]: bearish ease-flow watch setup.")
alertcondition(longSignal, "Ease Flow Reclaim Long [ZOM]", "EFR [ZOM]: confirmed bullish ease-flow reclaim.")
alertcondition(shortSignal, "Ease Flow Reclaim Short [ZOM]", "EFR [ZOM]: confirmed bearish ease-flow rejection.")
````
