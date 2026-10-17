# Prism Moving Average Trend

- url: https://www.tradingview.com/script/r7AkHuuh-Prism-Moving-Average-Trend/
- type: indicator
- pine_id: PUB;b4901e7ae12a4648b532a7af3005ccfc
- version: 1.0

## Description

[b]Prism Moving Average Trend | MisinkoMaster[/b]

[b]The Prism Moving Average Trend (PriMAT)[/b] is an advanced trend-following overlay engineered to capture market regimes with high precision and low latency. By blending sinusoidal weighting mechanics with exponential smoothing, PriMAT creates a fluid, wave-like moving average baseline that dynamically adapts to structural price shifts while filtering out market noise.

Rather than relying solely on price crossovers or raw slope direction, PriMAT incorporates volatility-adjusted bands alongside Rate of Change (ROC) slope confirmation to validate trend transitions, preventing whipsaws during low-volatility consolidation.

[b]How does it work?[/b]

Dual-Stage Prism Smoothing Engine:

Sinusoidal Weighting: The inner PRISM algorithm calculates a custom weighted moving average using a trigonometric weighting function ((sin(angle) + cos(angle) + 1) / 2) applied across the lookback window. This distributes weights in a smooth, wave-like curve across historical bars.

Exponential Blending: The weighted base calculation is blended with immediate price action using an exponential factor (alpha = 2 / (1 + len)).

Cascade Smoothing: The script calculates a primary PRISM baseline over the main lookback period (len), followed by a secondary PRISM pass over the square root of the lookback period (sqrtlen) for ultra-smooth tracking without phase lag.

ATR Volatility Bands:

Upper and lower bands are expanded around the double-smoothed Prism line using average true range scaled by a customizable multiplier (vol = ta.atr(len) * mul).

Dual-Condition Regime Logic:

Bullish Shift (1): Triggered when price closes above the upper volatility band (src > upper) AND the Prism line slope is positive (change > 0).

Bearish Shift (-1): Triggered when price closes below the lower volatility band (src < lower) AND the Prism line slope is negative (change < 0).

Integrated Reversal Warning System (Danger Alert):

The indicator measures distance between price and the Prism baseline relative to active trend direction ((src - prism) * trend).

When this metric reaches its lowest point over the lookback window, it highlights the chart background with a bright yellow warning. This alerts you to extreme momentum deceleration or structural exhaustion where price may reverse before the main indicator trend state flips.

[b]Key Features[/b]

Hybrid Wave Smoothing: Combines sinusoidal weighting with exponential blending for smooth curve tracking and minimal lag.

Volatility Band Filtering: Requires price to break beyond ATR volatility channels before confirming regime changes, eliminating false signals in tight ranges.

Dynamic Reversal Warnings: Built-in background highlights warn of potential trend exhaustion prior to trend flips.

On-Chart Candle Morphing: Recolors main price candles (vibrant neon teal for bullish regimes, vivid magenta for bearish regimes) to maintain clean visual alignment.

[b]Input Parameters & Optimization Guide[/b]

Source: Sets the input price series used for calculations.

Lookback: Sets the evaluation window for the primary Prism calculation and ATR channels. A default of 31 provides strong macro trend stability.

Multiplier: Controls the width of the ATR volatility bands around the Prism line.

[b]Trading Strategies & Execution[/b]

Volatility Band Trend Entries

Bullish Alignment: Confirmed when price breaks above the upper Prism band while the Prism slope is positive, flipping price chart candles neon teal.

Bearish Alignment: Confirmed when price breaks below the lower Prism band while the Prism slope is negative, flipping price chart candles vivid magenta.

Divergence & Reversal Alerts (Danger Warnings)

When a yellow background highlight appears during an active trend, it indicates price has moved excessively close to or against the Prism line relative to the lookback period.

[b]Disclaimer: Trading financial markets involves high risk. This technical script is designed as an informational analytical tool to support your rule-based mechanical execution system and does not constitute financial advice.[/b]

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © MisinkoMaster

//@version=6
indicator("Prism Moving Average Trend", "PriMAT │ MisinkoMaster", overlay = true, behind_chart = false)
////////////////////////////////////////////////////////////////////////////////////////////////////
// Get User Defined Inputs
src = input.source(close, "Source", group = "Prism Moving Average Trend")
len = input.int(31, "Lookback", tooltip = "Changes the amount of data used.", minval = 2,
     group = "Prism Moving Average Trend")
mul = input.float(0.85, "Multiplier", step = 0.05,
     group = "Prism Moving Average Trend")
////////////////////////////////////////////////////////////////////////////////////////////////////
// Calculations
sqrtlen = math.round(math.sqrt(len))
PRISM(source, length) =>
    alpha = 2 / (1 + len)
    sum = 0.0
    w = 0.0
    for i = 0 to length - 1
        angle = (i + 1) * math.pi / (length + 1)
        weight = (math.sin(angle) + math.cos(angle) + 1) / 2
        sum += source[i] * weight
        w += weight

    base = w != 0 ? sum / w : source

    prism = base * (1 - alpha) + source * alpha
    prism

base = PRISM(src, len)
prism = PRISM(base, sqrtlen)

vol = ta.atr(len)*mul
upper = prism + vol
lower = prism - vol

change = prism - prism[1]
////////////////////////////////////////////////////////////////////////////////////////////////////
// Trend Logic
var trend = 0
if src > upper and change > 0
    trend := 1
if src < lower and change < 0
    trend := -1
////////////////////////////////////////////////////////////////////////////////////////////////////
// Plotting
var col = color.rgb(72, 72, 72)
var colT = color.rgb(72, 72, 72, 60)
if trend == 1
    col := color.rgb(0, 255, 187)
    colT := color.rgb(0, 255, 187, 60)
if trend == -1
    col := color.rgb(255, 0, 157)
    colT := color.rgb(255, 0, 157, 60)

var colC = color.rgb(72, 72, 72)
if change > 0
    colC := color.rgb(0, 255, 187)
if change < 0
    colC := color.rgb(255, 0, 157)

plotcandle(open, high, low, close, color = col, bordercolor = col, wickcolor = col, display = display.pane)
p = plot(prism, "Prism Moving Average", col, 3)
u = plot(upper, "Prism Upper Band", col, 2)
l = plot(lower, "Prism Lower Band", col, 2)
plot(change, "Change", color = colC, display = display.status_line)
fill(u, l, colT, "Band Filling")

colDanger = (src-prism)*trend == ta.lowest((src-prism)*trend, len) ? color.rgb(253, 249, 57, 65) : na
bgcolor(colDanger, title = "Potential Trend Reversal Warning")
````
