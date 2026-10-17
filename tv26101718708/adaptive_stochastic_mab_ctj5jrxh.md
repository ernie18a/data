# Adaptive Stochastic+ [MAB]

- url: https://www.tradingview.com/script/Ctj5jRxH-Adaptive-Stochastic-MAB/
- type: indicator
- pine_id: PUB;8d6bc3e92525428482ffae0ecf5ad9ba
- version: 1.0

## Description

Adaptive Stochastic+ is a self-optimizing momentum oscillator that dynamically selects the most effective stochastic settings

Instead of relying on fixed %K periods and smoothing values, this indicator continuously evaluates multiple configurations and automatically selects the ones that have been performing best on recent price action — delivering a stochastic oscillator that adapts to changing market conditions and momentum cycles.

[b]🔶 HOW IT WORKS[/b]

Traditional Stochastic indicators use fixed parameters, which can become unreliable as market conditions shift. Adaptive Stochastic+ solves this by running two parallel optimization processes:

K Period Selection → Tests multiple %K lengths to determine the most responsive momentum structure
Smoothing Selection → Evaluates different smoothing levels to balance noise and stability

Each configuration is scored using an exponential performance model that tracks whether momentum is consistently aligning with price movement.

On every bar:

The best-performing %K period is selected
The best-performing smoothing level is selected
Both are combined to form a final adaptive %K line
A %D signal line is derived using standard smoothing

This creates a stochastic oscillator that continuously adjusts its sensitivity based on current market behavior.

[b]🔶 USAGE[/b]

🔹 Momentum Structure

%K Line — Primary adaptive momentum line
%D Line — Smoothed signal line used for confirmation

Green %K — Oversold region (potential upward momentum)
Red %K — Overbought region (potential downward momentum)
Gray %K — Neutral zone

🔹 Key Levels

Overbought Zone — Indicates strong upward momentum that may be overextended
Oversold Zone — Indicates strong downward momentum that may be exhausted
Midline (50) — Separates bullish and bearish momentum bias

🔹 Trade Signals

Green crossover — Bullish signal. %K crosses above %D below the midline, indicating potential upside momentum
Red crossover — Bearish signal. %K crosses below %D above the midline, indicating potential downside momentum

Because both %K period and smoothing are dynamically selected, signals reflect momentum conditions optimized for recent price action — not static parameters.

[b]🔶 SETTINGS[/b]

🔹 Adaptive Engine

Perf EMA Length — Controls how quickly the performance scoring adapts to new conditions. Lower values react faster; higher values are smoother.

🔹 Stochastic Settings

D Smoothing — Fixed smoothing applied to the final %K to create the %D line

🔹 Levels

Overbought Level — Upper threshold for momentum extremes
Oversold Level — Lower threshold for momentum extremes

[b]🔶 NOTES[/b]

Suitable for all markets and timeframes.
Works best as a momentum timing and reversal confirmation tool.
Adaptive parameter selection helps reduce false signals in choppy markets while staying responsive in trends.
Can be combined with trend indicators for higher-probability setups.
Past performance of any selected configuration does not guarantee future results — always apply proper risk management.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © MarketAlgoBot

//@version=6
indicator("Adaptive Stochastic+", overlay=false)

// ─────────────────────────────────────────────
// INPUTS
// ─────────────────────────────────────────────
perfAlpha = input.int(10, "Perf EMA Length", minval=2, maxval=50, group="Adaptive Engine")
dPeriod   = input.int(3,  "D Smoothing (fixed)", minval=1, maxval=10, group="Stochastic Settings")
obLevel   = input.int(80, "Overbought Level", minval=60, maxval=95, group="Levels")
osLevel   = input.int(20, "Oversold Level",   minval=5,  maxval=40,  group="Levels")

// ─────────────────────────────────────────────
// PRE-COMPUTE ALL %K SERIES AT GLOBAL SCOPE
// K Period variants: 5,7,9,11,13,15,17,19  (fixed smooth=3)
// Smoothing variants: 1,2,3,4,5,6,7,8     (fixed K=14)
// Rule 1: NO ta.* inside loops
// ─────────────────────────────────────────────

// — K Period leaderboard (smooth fixed = 3) —
kK5  = ta.sma(ta.stoch(close, high, low, 5),  3)
kK7  = ta.sma(ta.stoch(close, high, low, 7),  3)
kK9  = ta.sma(ta.stoch(close, high, low, 9),  3)
kK11 = ta.sma(ta.stoch(close, high, low, 11), 3)
kK13 = ta.sma(ta.stoch(close, high, low, 13), 3)
kK15 = ta.sma(ta.stoch(close, high, low, 15), 3)
kK17 = ta.sma(ta.stoch(close, high, low, 17), 3)
kK19 = ta.sma(ta.stoch(close, high, low, 19), 3)

// — Smoothing leaderboard (K fixed = 14) —
kS1 = ta.sma(ta.stoch(close, high, low, 14), 1)
kS2 = ta.sma(ta.stoch(close, high, low, 14), 2)
kS3 = ta.sma(ta.stoch(close, high, low, 14), 3)
kS4 = ta.sma(ta.stoch(close, high, low, 14), 4)
kS5 = ta.sma(ta.stoch(close, high, low, 14), 5)
kS6 = ta.sma(ta.stoch(close, high, low, 14), 6)
kS7 = ta.sma(ta.stoch(close, high, low, 14), 7)
kS8 = ta.sma(ta.stoch(close, high, low, 14), 8)

// ─────────────────────────────────────────────
// PERFORMANCE SCORING — K PERIOD LEADERBOARD
// Score = EMA of (+1 if %K rising, -1 if %K falling)
// ─────────────────────────────────────────────
var float perfKK5  = 0.0
var float perfKK7  = 0.0
var float perfKK9  = 0.0
var float perfKK11 = 0.0
var float perfKK13 = 0.0
var float perfKK15 = 0.0
var float perfKK17 = 0.0
var float perfKK19 = 0.0

emaW = 2.0 / (perfAlpha + 1)

perfKK5  += emaW * (math.sign(kK5  - kK5[1])  - perfKK5)
perfKK7  += emaW * (math.sign(kK7  - kK7[1])  - perfKK7)
perfKK9  += emaW * (math.sign(kK9  - kK9[1])  - perfKK9)
perfKK11 += emaW * (math.sign(kK11 - kK11[1]) - perfKK11)
perfKK13 += emaW * (math.sign(kK13 - kK13[1]) - perfKK13)
perfKK15 += emaW * (math.sign(kK15 - kK15[1]) - perfKK15)
perfKK17 += emaW * (math.sign(kK17 - kK17[1]) - perfKK17)
perfKK19 += emaW * (math.sign(kK19 - kK19[1]) - perfKK19)

// Best K Period — chained ternary (no array.get in critical path)
bestKPerf = math.max(perfKK5, perfKK7, perfKK9, perfKK11, perfKK13, perfKK15, perfKK17, perfKK19)

bestKVal = bestKPerf == perfKK5  ? kK5  :
           bestKPerf == perfKK7  ? kK7  :
           bestKPerf == perfKK9  ? kK9  :
           bestKPerf == perfKK11 ? kK11 :
           bestKPerf == perfKK13 ? kK13 :
           bestKPerf == perfKK15 ? kK15 :
           bestKPerf == perfKK17 ? kK17 : kK19

bestKPeriod = bestKPerf == perfKK5  ? 5  :
              bestKPerf == perfKK7  ? 7  :
              bestKPerf == perfKK9  ? 9  :
              bestKPerf == perfKK11 ? 11 :
              bestKPerf == perfKK13 ? 13 :
              bestKPerf == perfKK15 ? 15 :
              bestKPerf == perfKK17 ? 17 : 19

// ─────────────────────────────────────────────
// PERFORMANCE SCORING — SMOOTHING LEADERBOARD
// ─────────────────────────────────────────────
var float perfKS1 = 0.0
var float perfKS2 = 0.0
var float perfKS3 = 0.0
var float perfKS4 = 0.0
var float perfKS5 = 0.0
var float perfKS6 = 0.0
var float perfKS7 = 0.0
var float perfKS8 = 0.0

perfKS1 += emaW * (math.sign(kS1 - kS1[1]) - perfKS1)
perfKS2 += emaW * (math.sign(kS2 - kS2[1]) - perfKS2)
perfKS3 += emaW * (math.sign(kS3 - kS3[1]) - perfKS3)
perfKS4 += emaW * (math.sign(kS4 - kS4[1]) - perfKS4)
perfKS5 += emaW * (math.sign(kS5 - kS5[1]) - perfKS5)
perfKS6 += emaW * (math.sign(kS6 - kS6[1]) - perfKS6)
perfKS7 += emaW * (math.sign(kS7 - kS7[1]) - perfKS7)
perfKS8 += emaW * (math.sign(kS8 - kS8[1]) - perfKS8)

// Best Smoothing — chained ternary
bestSPerf = math.max(perfKS1, perfKS2, perfKS3, perfKS4, perfKS5, perfKS6, perfKS7, perfKS8)

bestSVal = bestSPerf == perfKS1 ? kS1 :
           bestSPerf == perfKS2 ? kS2 :
           bestSPerf == perfKS3 ? kS3 :
           bestSPerf == perfKS4 ? kS4 :
           bestSPerf == perfKS5 ? kS5 :
           bestSPerf == perfKS6 ? kS6 :
           bestSPerf == perfKS7 ? kS7 : kS8

bestSmooth = bestSPerf == perfKS1 ? 1 :
             bestSPerf == perfKS2 ? 2 :
             bestSPerf == perfKS3 ? 3 :
             bestSPerf == perfKS4 ? 4 :
             bestSPerf == perfKS5 ? 5 :
             bestSPerf == perfKS6 ? 6 :
             bestSPerf == perfKS7 ? 7 : 8

// ─────────────────────────────────────────────
// FINAL %K — BLEND BOTH WINNERS
// Average the two best-performing series
// ─────────────────────────────────────────────
finalK = (bestKVal + bestSVal) / 2.0

// %D — SMA of finalK
finalD = ta.sma(finalK, dPeriod)

// ─────────────────────────────────────────────
// ZONE DETECTION
// ─────────────────────────────────────────────
isOB = finalK >= obLevel
isOS = finalK <= osLevel
isMid = not isOB and not isOS

kColor = isOB ? color.new(#ef5350, 0) :
          isOS ? color.new(#26a69a, 0) :
                 color.new(#90a4ae, 0)

// ─────────────────────────────────────────────
// CROSSOVER SIGNALS
// ─────────────────────────────────────────────
bullCross = ta.crossover(finalK, finalD)  and finalK < 50
bearCross = ta.crossunder(finalK, finalD) and finalK > 50

// ─────────────────────────────────────────────
// PLOTS
// ─────────────────────────────────────────────

// OB / OS zone fills (hlines + linefill via plots)
obLine = hline(obLevel, "Overbought", color=color.new(#ef5350, 60), linestyle=hline.style_dashed, linewidth=1)
osLine = hline(osLevel, "Oversold",   color=color.new(#26a69a, 60), linestyle=hline.style_dashed, linewidth=1)
midLine = hline(50,     "Midline",    color=color.new(#ffffff, 80), linestyle=hline.style_dotted,  linewidth=1)
hline(100, color=color.new(#ffffff, 90))
hline(0,   color=color.new(#ffffff, 90))

// Fill OB and OS zones
fill(obLine, midLine, color=color.new(#ef5350, 90), title="OB Zone Fill")
fill(osLine, midLine, color=color.new(#26a69a, 90), title="OS Zone Fill")

// %K line
plot(finalK, title="%K", color=kColor, linewidth=2)

// %D signal line
plot(finalD, title="%D", color=color.new(#ff9800, 60), linewidth=2)
````
