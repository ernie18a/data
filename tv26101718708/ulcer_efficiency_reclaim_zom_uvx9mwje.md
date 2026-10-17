# Ulcer Efficiency Reclaim [ZOM]

- url: https://www.tradingview.com/script/uvX9MWje-Ulcer-Efficiency-Reclaim-ZOM/
- type: indicator
- pine_id: PUB;98cc772de3f04cb89280792a8cb7ca30
- version: 1.0

## Description

Ulcer Efficiency Reclaim [ZOM] is a clean overlay signal system built around three ideas that work well together: VWAP location, Kaufman-style Efficiency Ratio, and Ulcer Index pressure resets.

The goal is simple: highlight moments where price reclaims or rejects VWAP while directional efficiency is improving and drawdown pressure is cooling or building. It is designed for traders who want a lightweight trend continuation and pullback confirmation tool without a crowded dashboard.

What it uses:
- VWAP anchor for intraday fair-value context
- Efficiency Ratio to filter cleaner directional movement
- Ulcer Index pressure logic to separate panic, reset, and continuation phases
- ATR-based efficiency bands around VWAP
- Optional bar coloring for momentum and pressure shifts
- Simple price-locked signal markers that stay attached to the chart

Signal logic:
- Long markers appear when price reclaims VWAP or rejects the lower efficiency band while efficiency improves and pressure resets.
- Short markers appear when price loses VWAP or rejects the upper efficiency band while efficiency improves and downside pressure builds.
- A cooldown filter reduces repeated signals in noisy chop.

Best use cases:
- Futures such as ES, NQ, YM, and RTY
- Forex majors
- Crypto trend sessions
- Liquid equities and ETFs
- Intraday VWAP continuation and pullback trading

Visuals:
The script includes multiple aesthetic templates, including Ice Pop, Terminal, Solar, and Mono. The default view keeps the overlay readable, with soft VWAP bands and small price-anchored signal dots.

This is not meant to predict every move. It is a context and confirmation tool for spotting cleaner reclaim/reject conditions around VWAP when efficiency and pressure agree.

Open-source Pine Script by ZenOutMan.

Keywords: VWAP indicator, Efficiency Ratio, Ulcer Index, trend continuation, pullback trading, TradingView overlay, futures trading, forex indicator, crypto indicator, Pine Script, ZOM.

## Source Code

````pine
//@version=6
indicator("Ulcer Efficiency Reclaim [ZOM]", shorttitle="UER [ZOM]", overlay=true, max_labels_count=80)

// Ulcer Efficiency Reclaim [ZOM]
// Simple hybrid: VWAP reclaim/reject + Kaufman-style Efficiency Ratio + Ulcer Index pressure reset.

signalMode = input.string("Balanced", "Signal Mode", options=["Early", "Balanced", "Strict"], group="Signals")
erLen = input.int(18, "Efficiency Length", minval=5, maxval=100, group="Core")
ulcerLen = input.int(21, "Ulcer Length", minval=5, maxval=120, group="Core")
ulcerBaseLen = input.int(55, "Ulcer Baseline", minval=10, maxval=200, group="Core")
atrLen = input.int(14, "ATR Length", minval=5, maxval=100, group="Core")
bandMult = input.float(0.85, "Band ATR Multiplier", minval=0.1, maxval=4.0, step=0.05, group="Visuals")
cooldownBars = input.int(12, "Signal Cooldown Bars", minval=0, maxval=100, group="Signals")
showBands = input.bool(true, "Efficiency Bands", group="Visuals")
showSignals = input.bool(true, "Signal Labels", group="Visuals")
showBarColor = input.bool(true, "Bar Color", group="Visuals")
theme = input.string("Ice Pop", "Aesthetic Template", options=["Ice Pop", "Terminal", "Solar", "Mono"], group="Visuals")

bull = theme == "Terminal" ? color.rgb(50, 230, 145) : theme == "Solar" ? color.rgb(255, 184, 77) : theme == "Mono" ? color.rgb(230, 230, 230) : color.rgb(40, 220, 210)
bear = theme == "Terminal" ? color.rgb(255, 82, 115) : theme == "Solar" ? color.rgb(236, 88, 84) : theme == "Mono" ? color.rgb(125, 125, 125) : color.rgb(255, 88, 148)
calm = theme == "Terminal" ? color.rgb(80, 150, 120) : theme == "Solar" ? color.rgb(111, 145, 210) : theme == "Mono" ? color.rgb(170, 170, 170) : color.rgb(126, 154, 255)
soft = color.rgb(18, 24, 34)

f_clamp(v, lo, hi) =>
    math.max(lo, math.min(hi, v))

movement = math.abs(close - close[erLen])
noise = math.sum(math.abs(ta.change(close)), erLen)
efficiency = noise > 0 ? movement / noise : 0.0
effBase = ta.ema(efficiency, math.max(5, int(erLen * 1.7)))
effRising = efficiency > effBase and efficiency > efficiency[1]

peak = ta.highest(close, ulcerLen)
drawdownPct = peak > 0 ? 100.0 * (close - peak) / peak : 0.0
ulcer = math.sqrt(ta.sma(math.pow(drawdownPct, 2.0), ulcerLen))
ulcerBase = ta.ema(ulcer, ulcerBaseLen)
painReset = ulcer < ulcerBase and ulcer < ulcer[1]
painBuild = ulcer > ulcerBase and ulcer > ulcer[1]

vwap = ta.vwap(hlc3)
atr = ta.atr(atrLen)
effWidth = atr * bandMult * (1.55 - f_clamp(efficiency, 0.0, 1.0) * 0.72)
upperBand = vwap + effWidth
lowerBand = vwap - effWidth

strictEr = signalMode == "Strict" ? 0.42 : signalMode == "Early" ? 0.24 : 0.32
strictUlcer = signalMode == "Strict" ? 0.84 : signalMode == "Early" ? 1.18 : 1.0
longSetup = ta.crossover(close, vwap) and efficiency >= strictEr and ulcer <= ulcerBase * strictUlcer
shortSetup = ta.crossunder(close, vwap) and efficiency >= strictEr and painBuild
pullbackLong = low <= lowerBand and close > lowerBand and close > open and effRising and painReset
pullbackShort = high >= upperBand and close < upperBand and close < open and effRising and painBuild

var int lastSignal = na
cooldownOk = na(lastSignal) or bar_index - lastSignal > cooldownBars
longSignal = cooldownOk and (longSetup or pullbackLong)
shortSignal = cooldownOk and (shortSetup or pullbackShort)
if longSignal or shortSignal
    lastSignal := bar_index

quality = f_clamp(efficiency * 64.0 + (1.0 - f_clamp(ulcer / math.max(ulcerBase, 0.01), 0.0, 2.0) / 2.0) * 36.0, 0.0, 100.0)

plotVwap = plot(vwap, "VWAP Anchor", color=color.new(calm, 0), linewidth=2)
plotUpper = plot(showBands ? upperBand : na, "Efficiency Upper Band", color=color.new(bear, 78), linewidth=1)
plotLower = plot(showBands ? lowerBand : na, "Efficiency Lower Band", color=color.new(bull, 78), linewidth=1)
fill(plotUpper, plotLower, color=showBands ? color.new(efficiency > effBase ? calm : soft, 92) : na, title="Efficiency Corridor")

longMarkerPrice = low - atr * 0.12
shortMarkerPrice = high + atr * 0.12
plot(showSignals and longSignal ? longMarkerPrice : na, "UER Long Marker", color=color.new(bull, 0), style=plot.style_circles, linewidth=4)
plot(showSignals and shortSignal ? shortMarkerPrice : na, "UER Short Marker", color=color.new(bear, 0), style=plot.style_circles, linewidth=4)

barTone = longSignal ? color.new(bull, 0) : shortSignal ? color.new(bear, 0) : close > vwap and painReset ? color.new(bull, 62) : close < vwap and painBuild ? color.new(bear, 62) : na
barcolor(showBarColor ? barTone : na)

alertcondition(longSignal, "Ulcer Efficiency Reclaim Long [ZOM]", "Ulcer Efficiency Reclaim [ZOM]: long reclaim on {{ticker}} {{interval}}.")
alertcondition(shortSignal, "Ulcer Efficiency Reclaim Short [ZOM]", "Ulcer Efficiency Reclaim [ZOM]: short reject on {{ticker}} {{interval}}.")
````
