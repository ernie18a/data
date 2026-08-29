<!-- tradingview-pine-id: PUB;aeee9d258dc048d4b29ef4cdd220bafd -->
<!-- tradingviewscripts-format: 1 -->
# MHIDa Volume-Dry Pullback

Source: https://www.tradingview.com/script/sKohePTk/

## Description

A context tool that highlights a pullback (a dip) inside an uptrend where volume has dried up, i.e. it dropped below its own moving average.

WHAT IT DOES
It looks for three things together, all read on closed bars: (1) an uptrend, defined as price above a 50-period EMA; (2) a dip, defined as price below a 20-period EMA (the mean price tends to revert toward) while RSI(14) is below 45; (3) volume that dried up, meaning the current bar's volume is below a configurable fraction (default 0.7) of its own 20-bar average. Optionally it also requires the current bar to close higher than the previous one, as a sign the dip is turning up. When all conditions align, a small triangle marks the bar and the dip bars are shaded gray.

WHY VOLUME MATTERS HERE
The idea: a pullback on low volume often carries less selling conviction than a pullback on heavy volume, so it can be read as a quieter dip inside the broader uptrend rather than the start of a real reversal. This is not a proven edge on its own -- it is a lens to read what the chart already shows.

HOW TO USE IT
All lengths and thresholds are inputs, grouped as Trend gate, Volume dried up, and Dip read -- tune them to the symbol and timeframe you watch, they are a starting point, not a finished setup. The background is lightly shaded while price is above the trend EMA, the two EMAs are plotted for reference, and the marker/alert only fire on confirmed, closed bars (no repainting, no lookahead).

DISCLAIMER
This is a context tool meant to support your own reading of the chart. It is NOT a buy/sell signal, NOT financial advice, and NOT a standalone trading system. Always do your own analysis and manage your own risk.

---

## Source Code

````pine
//@version=6
// Volume-Dry Pullback — a tool to support your reading of what you
// already see on the chart. It is NOT a signal, NOT advice, and NOT a winner on its own.
// You always decide.
//
// WHAT IT DOES
// It highlights a pullback (a dip) inside an uptrend where VOLUME has "dried up",
// i.e. it dropped below its own average. The idea, to be read together with the chart:
// a dip WITHOUT volume is often more "harmless" (little conviction behind the move down)
// than a dip on strong volume. This is context for WHAT YOU ALREADY SEE on the chart,
// not a promise and not financial advice.
//
// ABOUT THE LOGIC (honest framing)
// The building blocks come from a classic mean-reversion reading: an EMA as a trend/mean
// reference, a "dip" read (RSI 14 in low territory turning back up, price pulled back below
// a moving average), and a round-trip cost assumption. Note: the "volume dried up" part is
// not an optimized parameter — it is a configurable STARTING POINT, not "the" winning setup.
// Tune the thresholds yourself against what you observe.
//
// No lookahead: everything is read on closed bars.

indicator("MHIDa Volume-Dry Pullback", shorttitle="VolDryPB", overlay=true)

// ----------------------------- INPUTS (defaults = STARTING POINT, not truth) -----------------------------
grpTrend = "Trend gate (bull)"
emaGateLen   = input.int(50,  "EMA-gate (uptrend if price above)", minval=2, group=grpTrend)
emaMeanLen   = input.int(20,  "EMA mean (pullback reference)",     minval=2, group=grpTrend)

grpVol = "Volume dried up"
volMaLen     = input.int(20,  "Volume average (bars)", minval=2, group=grpVol)
volDryMult   = input.float(0.7, "Volume-dry threshold (fraction of its average)", minval=0.1, maxval=1.0, step=0.05, group=grpVol)

grpDip = "Dip read"
rsiLen       = input.int(14,  "RSI length",                 minval=2, group=grpDip)
rsiDipLevel  = input.float(45, "RSI 'in dip' threshold (below =)", minval=1, maxval=99, group=grpDip)
useRsiTurn   = input.bool(true, "Also require price to turn up (close > close[1])", group=grpDip)

// ----------------------------- CALCULATIONS -----------------------------
emaGate = ta.ema(close, emaGateLen)   // "we are in a bull" reference
emaMean = ta.ema(close, emaMeanLen)   // mean the price tends to pull back toward
rsiV    = ta.rsi(close, rsiLen)
volMa   = ta.sma(volume, volMaLen)    // volume average

// 1) we are inside a bull: price above the EMA-gate
inToro    = close > emaGate

// 2) it is a dip/pullback: price below the mean reference and RSI below the threshold
isPullback = (close < emaMean) and (not na(rsiV) and rsiV < rsiDipLevel)

// 3) volume has dried up: current volume below a fraction of its average
volDry    = not na(volMa) and volume < volMa * volDryMult

// 4) (optional) price turns up on the current bar
turnUp    = (not useRsiTurn) or (close > close[1])

// Full highlight: all conditions true
flag = inToro and isPullback and volDry and turnUp

// ----------------------------- DRAWING (highlight only, no orders) -----------------------------
plot(emaGate, "EMA-gate (bull)", color=color.new(color.teal,   0), linewidth=2)
plot(emaMean, "EMA mean",        color=color.new(color.orange, 0), linewidth=1)

// light background while we are in a bull, to frame the context you observe
bgcolor(inToro ? color.new(color.teal, 92) : na, title="Bull context")

// marker for the dry-volume pullback
plotshape(flag and chart.is_standard, title="Dry-volume pullback",
     style=shape.triangleup, location=location.belowbar,
     color=color.new(color.lime, 0), size=size.small,
     text="dry")

// small visual aid: color the dry-volume bars inside a dip (even without all conditions)
barcolor((isPullback and volDry) ? color.new(color.gray, 30) : na, title="Dry-volume dip")

// purely informational alert: it is only a reminder to look at the chart, not an order
alertcondition(flag, title="MHIDa VolDryPB - look at the chart",
     message="MHIDa Volume-Dry Pullback: possible dry-volume dip in a bull. Context to support your own judgment, not a signal. You decide.")
````
