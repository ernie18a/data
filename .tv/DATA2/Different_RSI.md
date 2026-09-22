<!-- tradingview-pine-id: PUB;c2c07cd6f57a497fa6845bfdc0aaa7b1 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Different RSI

Source: https://www.tradingview.com/script/LDmNsXmZ-Different-RSI/

## Description

Different RSI | MisinkoMaster

The Different RSI is a modified, noise-filtered variation of the classical Relative Strength Index designed to measure trend strength and structural momentum with greater precision. Standard RSI relies on simple average gains and losses over a lookback window, which can make it vulnerable to choppy false turns during range-bound conditions.

This indicator upgrades the traditional calculation by measuring squared price changes across a user-defined lookback window. By calculating the square root of aggregated squared gains versus losses, it gives greater mathematical weight to larger directional moves while dampening minor intrabar noise.

How It Works (The Core Architecture)

The script computes momentum through a three-stage mathematical framework:

    Squared Deviation Distance: The algorithm iterates across the lookback window (len) to evaluate price changes relative to historical bars. Positive price differences are squared to build a cumulative gain value (g), while negative price differences are squared to build a cumulative loss value (l).

    Root Mean Square RSI Calculation: By using the square root of the total squared gains and losses, the script derives a custom bounded oscillator scaled strictly between 0 and 100.

    Dual-Filter Trend Logic: An Exponential Moving Average (ma) is calculated over the RSI series. A bullish regime (1) requires RSI to be both above 50 and above its EMA. A bearish regime (-1) requires RSI to be both below 50 and below its EMA.

Key Features

    Root Mean Square Momentum Engine: Emphasizes strong directional thrusts while smoothing out minor price fluctuations.

    Dual-Confirmation Regime Filter: Combines baseline threshold filtering (>50/<50) with moving average slope confirmation to eliminate premature trend flips.

    On-Chart Candle Morphing: Automatically recolors main price candles (vibrant neon teal for bullish trends, vivid magenta for bearish trends) to keep your visual focus aligned with active oscillator state.

    Integrated Signal Overlay: Displays a smooth yellow EMA signal line alongside the primary RSI line, highlighting momentum crossovers in real time.

Input Parameters & Optimization Guide

    Source: Sets the input price series used for calculations (Default: Close).

    Lookback: Sets the evaluation window for calculating squared gain and loss sums. The default of 45 provides stable macro trend tracking (Default: 45).

    Smoothing: Sets the period of the Exponential Moving Average applied to the RSI series for trend confirmation (Default: 12).

Trading Strategies & Execution

    Dual-Condition Regime Shifts

    Bullish Alignment: Confirmed when RSI crosses above 50 AND trades above its yellow signal line, turning price chart candles neon teal.

    Bearish Alignment: Confirmed when RSI crosses below 50 AND trades below its yellow signal line, turning price chart candles vivid magenta.

    Overbought & Oversold Zones

    Overbought Threshold (80): Signals that bullish momentum has reached extreme levels. Watch for potential mean-reversion pullbacks when RSI drops back below 80.

    Oversold Threshold (20): Signals that bearish momentum is heavily saturated. Watch for potential bullish bounces when RSI crosses back above 20.

Disclaimer: Trading financial markets involves high risk. This technical script is designed as an informational analytical tool to support your rule-based mechanical execution system and does not constitute financial advice.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © MisinkoMaster

//@version=6
indicator("Different RSI", overlay = false)
////////////////////////////////////////////////////////////////////////
//Import Libraries
import TradingView/ta/14
////////////////////////////////////////////////////////////////////////
//Get User Defined Inputs
src = input.source(close, "Source", group = "Different RSI")
len = input.int(45, "Lookback", minval = 2, group = "Different RSI")
sml = input.int(12, "Smoothing", minval = 2, group = "Different RSI")
////////////////////////////////////////////////////////////////////////
//Calculations
g = 0.0
l = 0.0
for i = 1 to len-1
    g += math.pow(math.max(0, src-src[i]), 2)
    l += math.pow(math.abs(math.min(0, src-src[i])), 2)

rsi = g == 0 ? 0 : l == 0 ? 100 : 100 - 100 / (1 + math.sqrt(g)/math.sqrt(l))
ma = ta.ema(rsi, sml)
////////////////////////////////////////////////////////////////////////
//Trend Logic
var trend = 0
if rsi > 50 and rsi > ma
    trend := 1
if rsi < 50 and rsi < ma
    trend := -1
////////////////////////////////////////////////////////////////////////
//Plotting
var col = color.rgb(72, 72, 72)
var colT = color.rgb(72, 72, 72, 50)
if trend == 1
    col := color.rgb(0, 255, 187)
    colT := color.rgb(0, 255, 187, 50)
if trend == -1
    col := color.rgb(255, 0, 157)
    colT := color.rgb(255, 0, 157, 50)

n = plot(50, title = "Middle", color = color.rgb(71, 70, 70), display = display.pane, linewidth = 3)
obp = plot(80, title = "OB Treshhold", color = color.rgb(0, 255, 187), display = display.pane, linewidth = 3)
osp = plot(20, title = "OS Treshhold", color = color.rgb(255, 0, 157), display = display.pane, linewidth = 3)

fill(n, obp, color.rgb(0, 195, 237, 85))
fill(n, osp, color.rgb(255, 0, 157, 85))

plotcandle(open, high, low, close, bordercolor = col, color = col, force_overlay = true, display = display.pane)

rsip = plot(rsi, "Different RSI | MisinkoMaster", color = col, linewidth = 2)
plot(ma, "MA", color = color.yellow, linewidth = 1)
````
