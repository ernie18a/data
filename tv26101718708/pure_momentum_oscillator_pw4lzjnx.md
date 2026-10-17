# Pure Momentum Oscillator

- url: https://www.tradingview.com/script/pW4lZJNx-Pure-Momentum-Oscillator/
- type: indicator
- pine_id: PUB;8e4448b8a61f4fa4878f8b7000c6fa16
- version: 1.0

## Description

[b]Pure Momentum Oscillator | MisinkoMaster[/b]

The [b]Pure Momentum Oscillator[/b] is a sophisticated, volatility-normalized momentum indicator engineered to capture clean structural trend acceleration. Traditional momentum oscillators often rely on raw price changes or standard percentage differences, which can become heavily distorted during high-volatility expansions or low-liquidity market regimes.

By integrating a double-smoothed price projection engine (combining exponential smoothing, de-trending mechanics, and weighted moving average smoothing) with Average True Range (ATR) normalization, the Pure Momentum Oscillator isolates pure directional velocity across varying market conditions.

How It Works (The Core Architecture)

    Double-Smoothed Price Projection Engine:

    De-trended Smoothing: The algorithm calculates exponential moving averages across open, high, low, and close prices (oa, ha, la, ca), then computes de-trended price projections (2×Price−EMA) to minimize phase lag.

    Weighted Secondary Smoothing: These projected price streams are further smoothed using a Weighted Moving Average (oda, hda, lda, cda) matching the lookback length to produce an ultra-clean, synthetic price action profile.

    Volatility-Normalized Rate of Change:

    The momentum rate of change is calculated using the difference in the smoothed close (cda - cda[1]) normalized directly against the current Average True Range (atr). This scales momentum values consistently across different volatility environments and asset classes.

    Threshold-Based Trend Logic:

    Long State (1): Triggered when the volatility-normalized momentum exceeds the positive upper threshold (change > l).

    Short State (-1): Triggered when momentum drops below the negative lower threshold (change < s).

Key Features

    Volatility-Normalized Momentum: Divides price change by ATR to ensure momentum readings remain reliable during sudden volatility shifts.

    Synthetic Smoothed Price Overlay: Plots a mirrored, smoothed representation of price action (oda, hda, lda, cda) directly on your chart pane alongside original candles.

    Dual-Threshold Execution Bands: Features clear upper and lower threshold lines (l, s) with dynamic background fills highlighting momentum strength.

    Adaptive Candle Morphing: Automatically recolors both the original price candles and the smoothed price candles (vibrant green for bullish momentum, vivid red for bearish momentum).

Input Parameters & Optimization Guide

    Lookback: Sets the lookback period for the moving averages, ATR normalization, and momentum velocity calculations (Default: 45).

    Long Threshold: Sets the positive momentum boundary required to lock in a bullish trend state (Default: 0.05).

    Short Threshold: Sets the negative momentum boundary required to lock in a bearish trend state (Default: -0.05).

Trading Strategies & Execution

    Threshold Cross Momentum Entries

    Bullish Execution: Confirmed when normalized momentum crosses cleanly above the positive Long Threshold, flipping chart candles green.

    Bearish Execution: Confirmed when normalized momentum crosses below the negative Short Threshold, flipping chart candles red.

    Momentum Acceleration Fills

    Observe the shaded histogram fills between the momentum oscillator line and the threshold boundaries. Expanding fills indicate accelerating structural momentum, while contracting fills warn of momentum deceleration and potential range consolidation.

Disclaimer: Trading financial markets involves high risk. This technical script is designed as an informational analytical tool to support your rule-based mechanical execution system and does not constitute financial advice.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © MisinkoMaster

//@version=6
indicator("Pure Momentum Oscillator", overlay = false, behind_chart = false)
///////////////////////////////////////////////////////////////////////
//Import Libraries
import TradingView/ta/14
///////////////////////////////////////////////////////////////////////
//Get User Defined Inputs
len = input.int(45, "Lookback", step = 1, minval = 2,
     group = "Pure Momentum Oscillator")
l = input.float(0.05, "Long Treshhold", step = 0.001,
     group = "Pure Momentum Oscillator")
s = input.float(-0.05, "Short Treshhold", step = 0.001,
     group = "Pure Momentum Oscillator")
///////////////////////////////////////////////////////////////////////
//Calculations
oa = ta.ema(open, len)
ha = ta.ema(high, len)
la = ta.ema(low, len)
ca = ta.ema(close, len)

od = open * 2 - oa
hd = high * 2 - ha
ld = low * 2 - la
cd = close * 2 - ca

oda = ta.wma(od, len)
hda = ta.wma(hd, len)
lda = ta.wma(ld, len)
cda = ta.wma(cd, len)

atr = ta.atr(len)
change = (cda - cda[1]) / atr
///////////////////////////////////////////////////////////////////////
//Trend Logic
var trend = 0

long = change > l  
short = change < s

if long
    trend := 1
if short 
    trend := -1
///////////////////////////////////////////////////////////////////////
//Plotting
colC = trend == 1 ? color.rgb(0, 255, 0, 60) : color.rgb(255, 0, 0, 60)
col = trend == 1 ? color.rgb(0, 255, 0) : color.rgb(255, 0, 0)

plotcandle(oda, hda, lda, cda, "Smoothed Price", color = colC, wickcolor = colC, bordercolor = colC, display = display.pane, force_overlay = true)
plotcandle(open, high, low, close, "Original Price", color = col, wickcolor = col, bordercolor = col, display = display.pane, force_overlay = true)
plot(cda, "Smoothed Close", col, 2, force_overlay = true)

lp = plot(l, "Long Treshhold", color.rgb(0, 255, 0, 30), linewidth = 2, display = display.pane, force_overlay = false)
sp = plot(s, "Short Treshhold", color.rgb(255, 0, 0, 30), linewidth = 2, display = display.pane, force_overlay = false)
io = plot(change, "Momentum", col, 2, force_overlay = false)

fill(lp, sp, color.rgb(44, 42, 42, 70))

colFl = change > l and trend == 1 ? color.rgb(0, 255, 0, 50) : change < l and trend == 1 ? color.rgb(0, 255, 0, 70) : na 
colFs = change < s and trend == -1 ? color.rgb(255, 0, 0, 50) : change > s and trend == -1 ? color.rgb(255, 0, 0, 70) : na

fill(io, lp, colFl)
fill(io, sp, colFs)
````
