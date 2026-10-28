# Trend Signals

- url: https://www.tradingview.com/script/MB8aiOj0-Trend-Signals/
- type: indicator
- pine_id: PUB;60cb990ee0a94143b060c14ae372f0cc
- version: 1.0

## Description

This indicator is a multi-layered price-action signal system that combines EMA-based trend filtering, liquidity sweeps, and momentum confirmation to identify high-probability trade setups. It first detects rejections of the 50 EMA, confirming directional bias with optional higher-timeframe EMA alignment, then looks for 3-candle sweep patterns or strong momentum breakouts occurring shortly after the rejection. Additional filters such as wick-to-body strength and EMA slope help reduce noise, ensuring signals only print when market conditions show clear intent. The result is a structured, rule-based tool designed to highlight clean continuation entries after pullbacks, while avoiding low-quality or choppy setups.

## Source Code

````pine
//@version=6
indicator("Signals", overlay=true, behind_chart=true)

// =========================
// Inputs
// =========================
showSweepSignals    = input.bool(true, "Show 3 Candle Sweep Signals")
showRejectSignals   = input.bool(true, "Show EMA Rejection Signals")
showMomentumSignals = input.bool(true, "Show Momentum Confirmation Signals")

filterChoice        = input.string("15m", "Filtering EMA Timeframe", options=["Off", "15m", "1h", "4h"])

useWickBodyFilter   = input.bool(true, "Use Wick > Body Filter")
useSlopeFilter      = input.bool(true, "Use Chart EMA Slope Filter")
useMomentumConfirm  = input.bool(true, "Use Momentum Confirmation")

sweepLookbackBars   = input.int(5, "Sweep After Rejection Lookback Bars", minval=1, maxval=20)

showChartEMA        = input.bool(true, "Plot Chart EMA")
showFilterEMA       = input.bool(true, "Plot Filtering EMA")

// =========================
// Timeframe mapping
// =========================
filterEnabled = filterChoice != "Off"
filterTF = filterChoice == "15m" ? "15" : filterChoice == "1h" ? "60" : filterChoice == "4h" ? "240" : timeframe.period

// =========================
// EMAs
// =========================
chartEMA = ta.ema(close, 50)
filterEMA = request.security(syminfo.tickerid, filterTF, ta.ema(close, 50), barmerge.gaps_off, barmerge.lookahead_off)

// =========================
// Candle measurements
// =========================
body = math.abs(close - open)
prevBody = math.abs(close[1] - open[1])
upperWick = high - math.max(open, close)
lowerWick = math.min(open, close) - low

chartEMARising = chartEMA > chartEMA[1]
chartEMAFalling = chartEMA < chartEMA[1]

// =========================
// Filter conditions
// =========================
buyFilterPass = not filterEnabled or close > filterEMA
sellFilterPass = not filterEnabled or close < filterEMA

// =========================
// EMA rejection logic
// Retest is always based on chart EMA
// =========================
buyRejectBase = close[1] > chartEMA[1] and low <= chartEMA and close > chartEMA and close > open
sellRejectBase = close[1] < chartEMA[1] and high >= chartEMA and close < chartEMA and close < open

buyRejectWick = lowerWick > body
sellRejectWick = upperWick > body

buyRejectSlope = chartEMARising
sellRejectSlope = chartEMAFalling

buyReject = buyRejectBase and buyFilterPass and (not useWickBodyFilter or buyRejectWick) and (not useSlopeFilter or buyRejectSlope)
sellReject = sellRejectBase and sellFilterPass and (not useWickBodyFilter or sellRejectWick) and (not useSlopeFilter or sellRejectSlope)

// =========================
// 3 Candle Sweep Logic
// Must happen AFTER chart EMA rejection
// =========================
bullSweepBase = close[2] < open[2] and close[1] > open[1] and low < close[2] and close > open
bearSweepBase = close[2] > open[2] and close[1] < open[1] and high > close[2] and close < open

barsSinceBuyReject = ta.barssince(buyReject)
barsSinceSellReject = ta.barssince(sellReject)

recentBullReject = not na(barsSinceBuyReject) and barsSinceBuyReject <= sweepLookbackBars
recentBearReject = not na(barsSinceSellReject) and barsSinceSellReject <= sweepLookbackBars

bullSweep = bullSweepBase and recentBullReject and close > chartEMA and buyFilterPass
bearSweep = bearSweepBase and recentBearReject and close < chartEMA and sellFilterPass

// =========================
// Momentum after rejection
// =========================
bullMomentumCandle = close > open and body > prevBody and close > high[1]
bearMomentumCandle = close < open and body > prevBody and close < low[1]

var bool waitForBullMomentum = false
var bool waitForBearMomentum = false

if buyReject
    waitForBullMomentum := true
    waitForBearMomentum := false

if sellReject
    waitForBearMomentum := true
    waitForBullMomentum := false

buyMomentumSignal = useMomentumConfirm and waitForBullMomentum and bullMomentumCandle and close > chartEMA and buyFilterPass
sellMomentumSignal = useMomentumConfirm and waitForBearMomentum and bearMomentumCandle and close < chartEMA and sellFilterPass

if buyMomentumSignal
    waitForBullMomentum := false

if sellMomentumSignal
    waitForBearMomentum := false

if close < chartEMA
    waitForBullMomentum := false

if close > chartEMA
    waitForBearMomentum := false

// =========================
// Plots
// =========================
plot(showChartEMA ? chartEMA : na, title="Chart 50 EMA", color=color.blue, linewidth=2)
plot(showFilterEMA and filterEnabled ? filterEMA : na, title="Filtering 50 EMA", color=color.orange, linewidth=2)

// =========================
// Signals
// =========================
plotshape(showSweepSignals and bullSweep, title="Bull Sweep", style=shape.triangleup, location=location.belowbar, color=color.green, size=size.small)
plotshape(showSweepSignals and bearSweep, title="Bear Sweep", style=shape.triangledown, location=location.abovebar, color=color.red, size=size.small)

plotshape(showRejectSignals and buyReject, title="Buy Reject", style=shape.circle, location=location.belowbar, color=color.lime, size=size.tiny)
plotshape(showRejectSignals and sellReject, title="Sell Reject", style=shape.circle, location=location.abovebar, color=color.maroon, size=size.tiny)

plotshape(showMomentumSignals and buyMomentumSignal, title="Buy Momentum", style=shape.circle, location=location.belowbar, color=color.aqua, size=size.tiny)
plotshape(showMomentumSignals and sellMomentumSignal, title="Sell Momentum", style=shape.circle, location=location.abovebar, color=color.orange, size=size.tiny)

// =========================
// Alerts
// =========================
alertcondition(bullSweep, title="Bullish Sweep", message="Bullish 3 candle sweep after chart EMA retest/rejection")
alertcondition(bearSweep, title="Bearish Sweep", message="Bearish 3 candle sweep after chart EMA retest/rejection")
alertcondition(buyReject, title="Buy Rejection", message="Bullish chart EMA rejection with filter EMA confirmation")
alertcondition(sellReject, title="Sell Rejection", message="Bearish chart EMA rejection with filter EMA confirmation")
alertcondition(buyMomentumSignal, title="Buy Momentum Confirm", message="Bullish momentum confirmation after chart EMA rejection")
alertcondition(sellMomentumSignal, title="Sell Momentum Confirm", message="Bearish momentum confirmation after chart EMA rejection")
````
