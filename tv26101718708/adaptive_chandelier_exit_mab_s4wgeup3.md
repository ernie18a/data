# Adaptive Chandelier Exit+ [MAB]

- url: https://www.tradingview.com/script/S4WGeup3-Adaptive-Chandelier-Exit-MAB/
- type: indicator
- pine_id: PUB;a4f7a9ec077143db845407ca75de0787
- version: 1.0

## Description

Adaptive Chandelier Exit+ is a self-optimizing ATR-based trailing stop that dynamically adjusts to market conditions.
Instead of relying on a fixed ATR multiplier like the traditional Chandelier Exit, this indicator continuously evaluates multiple multiplier values and automatically selects the one that has been performing best on recent price action — delivering a trailing stop that adapts to volatility, trend strength, and structure in real time.

[b]🔶 HOW IT WORKS[/b]

The standard Chandelier Exit uses a fixed ATR multiplier to determine trailing stops, which can be too tight in volatile trends or too loose in consolidating markets. Adaptive Chandelier Exit+ solves this by testing a range of ATR multipliers simultaneously.

Each multiplier generates its own trailing stop and trend state. These are continuously scored using an exponential performance model that evaluates how well each configuration aligns with directional price movement.

On every bar:

The highest-performing multiplier is selected
That multiplier is smoothed using an EMA to prevent sudden shifts
The final trailing stop is calculated using this smoothed optimal multiplier

This creates a stop level that is not static, but continuously optimized based on recent market behavior.

[b]🔶 USAGE[/b]

[b]🔹 Stop & Trend State[/b]

Teal trailing stop — Bullish trend active. Price is above the stop, and the indicator is tracking upward movement.
Red trailing stop — Bearish trend active. Price is below the stop, and the indicator is tracking downward movement.

The stop dynamically adjusts based on both volatility and trend efficiency, making it suitable for trailing positions or defining market bias.

[b]🔹 Trade Signals[/b]

Teal triangle (▲) below bar — Bullish signal. Trend flips from bearish to bullish as price closes above the adaptive stop.
Red triangle (▼) above bar — Bearish signal. Trend flips from bullish to bearish as price closes below the adaptive stop.

Because the multiplier is selected based on recent performance and smoothed before application, signals reflect a stop level that has been validated against current market conditions — not a fixed parameter.

[b]🔶 SETTINGS[/b]

[b]🔹 Core Settings[/b]

ATR Length — Lookback period used for ATR calculation and highest high / lowest low reference. Controls how reactive the stop is to price movement.

[b]🔹 Multiplier Range[/b]

Min ATR Multiplier — The smallest multiplier included in the test range. Produces tighter stops.
Max ATR Multiplier — The largest multiplier included in the test range. Produces wider stops.
Multiplier Step — Increment between tested multipliers. Smaller steps improve precision but increase computation.

[b]🔹 Smoothing[/b]

Multiplier Smooth Length — EMA length applied to the selected best multiplier before calculating the final stop. Prevents abrupt jumps when the optimal multiplier changes between bars. Higher values result in smoother, slower adjustments.

[b]🔶 NOTES[/b]

Suitable for all markets and timeframes.
Can be used as a trailing stop, trend filter, or dynamic support/resistance level.
Works especially well in trending environments where volatility shifts over time.
Adaptive logic helps reduce premature stop-outs compared to fixed ATR systems.
Past performance of any selected multiplier does not guarantee future results — always apply proper risk management.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © MarketAlgoBot

//@version=6
indicator("Adaptive Chandelier Exit+", overlay=true)

//────────────────────────────
// Inputs
//────────────────────────────
atrLen    = input.int(22,    "ATR Length",               tooltip="Lookback for ATR and Highest High / Lowest Low.")
minMult   = input.float(1.0, "Min ATR Multiplier",       tooltip="Smallest multiplier tested.")
maxMult   = input.float(4.0, "Max ATR Multiplier",       tooltip="Largest multiplier tested.")
stepMult  = input.float(0.25,"Multiplier Step",          tooltip="Increment between tested multipliers.")
smoothLen = input.int(5,     "Multiplier Smooth Length", tooltip="EMA length applied to the winning multiplier to prevent abrupt stop jumps.")

perfAlpha = 10

//────────────────────────────
// Base ATR Components
//────────────────────────────
atr      = ta.atr(atrLen)
highestH = ta.highest(high, atrLen)
lowestL  = ta.lowest(low,  atrLen)

//────────────────────────────
// Global-scope prev stop references (fixes CW0018)
//────────────────────────────
var float prevLongStop  = na
var float prevShortStop = na

//────────────────────────────
// Storage Arrays
//────────────────────────────
var multipliers = array.new<float>()
var perf        = array.new<float>()
var trends      = array.new<int>()

if barstate.isfirst
    stepsCount = int((maxMult - minMult) / stepMult)
    for i = 0 to stepsCount
        m = minMult + i * stepMult
        array.push(multipliers, m)
        array.push(perf, 0.)
        array.push(trends, 1)

//────────────────────────────
// Per-Multiplier Scoring
//────────────────────────────
for i = 0 to array.size(multipliers) - 1
    m         = array.get(multipliers, i)
    longStop  = highestH - atr * m
    shortStop = lowestL  + atr * m

    trend_i = array.get(trends, i)
    trend_i := close > nz(prevShortStop, shortStop) ? 1 : close < nz(prevLongStop, longStop) ? 0 : trend_i

    diff = trend_i == 1 ? close - nz(close[1], close) : nz(close[1], close) - close
    diff := math.sign(diff)

    p  = array.get(perf, i)
    p += 2 / (perfAlpha + 1) * (diff - p)

    array.set(trends, i, trend_i)
    array.set(perf,   i, p)

//────────────────────────────
// Best Multiplier Selection
//────────────────────────────
bestIdx = 0
bestVal = array.get(perf, 0)

for i = 1 to array.size(perf) - 1
    val = array.get(perf, i)
    if val > bestVal
        bestVal := val
        bestIdx  := i

targetMult = array.get(multipliers, bestIdx)

//────────────────────────────
// Multiplier Smoothing
//────────────────────────────
smoothMult = ta.ema(targetMult, smoothLen)

//────────────────────────────
// Final Stop Calculation
//────────────────────────────
finalLongStop  = highestH - atr * smoothMult
finalShortStop = lowestL  + atr * smoothMult

//────────────────────────────
// Update global prev references
//────────────────────────────
prevLongStop  := finalLongStop
prevShortStop := finalShortStop

//────────────────────────────
// Trend State
//────────────────────────────
var int os = 1
os := close > nz(prevShortStop[1], finalShortStop) ? 1 : close < nz(prevLongStop[1], finalLongStop) ? 0 : os[1]

//────────────────────────────
// Active Stop Line
//────────────────────────────
stop = os == 1 ? finalLongStop : finalShortStop

//────────────────────────────
// Plots
//────────────────────────────
plot(stop, "Stop",
     color     = os == 1 ? color.teal : color.red,
     linewidth = 2,
     style     = plot.style_linebr)

//────────────────────────────
// Signals
//────────────────────────────
buy  = os == 1 and os[1] == 0
sell = os == 0 and os[1] == 1

plotshape(buy,  "Buy",  shape.triangleup,   location.belowbar, color.teal, size=size.tiny)
plotshape(sell, "Sell", shape.triangledown, location.abovebar, color.red,  size=size.tiny)
````
