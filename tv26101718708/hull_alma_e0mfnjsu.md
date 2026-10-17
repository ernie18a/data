# Hull ALMA

- url: https://www.tradingview.com/script/E0mFNjSu-Hull-ALMA/
- type: indicator
- pine_id: PUB;bc3616e40fb24df8ad960914c3caa6ef
- version: 1.0

## Description

[b]Hull ALMA | MisinkoMaster[/b]

[b]The Hull ALMA (HALMA)[/b] is a low-lag, hybrid moving average engineered to solve one of technical analysis's oldest trade-offs: lag versus smoothness. Classical moving averages like the SMA or EMA suffer from heavy lag during fast trend changes, while ultra-responsive averages like the standard Hull Moving Average (HMA) are notoriously prone to overshooting and producing sharp noise during sideways consolidation.

By replacing the weighted moving average core of the classic Hull algorithm with Arnaud Legoux Moving Averages (ALMA), the Hull ALMA eliminates lag through Gaussian-weighted smoothing rather than simple linear weighting. The result is a fluid, low-latency trend line that tracks price shifts rapidly while filtering out false breakouts and market noise.

How It Works (The Core Architecture)

The indicator combines the mathematical structure of the Hull transformation with Gaussian curve filtering:

    Half-Length and Full-Length Gaussian Smoothing: The algorithm calculates two baseline ALMAs—one over half the lookback period (hln_halma) and one over the full lookback period (len_halma).

    Lag Reduction Transformation: Following the classic Hull formulation, the full-period ALMA is subtracted from twice the half-period ALMA (2 * ALMA_half - ALMA_full) to project price direction forward and neutralize lag.

    Square-Root Gaussian Smoothing: The projected series is smoothed a final time using an ALMA calculated over the square root of the lookback period (sln_halma), producing an ultra-smooth curve without introducing phase delay.

    Dual-Confirmation Trend Filter: The algorithm concurrently tracks standard HMA slope alongside HALMA slope to ensure structural alignment before confirming regime shifts.

Key Features

    Gaussian-Weighted Lag Elimination: Replaces linear weighting with ALMA's Gaussian curve distribution, providing superior smoothness and reduced overshoot.

    Dual-Moving-Average Confluence: Evaluates both HALMA and HMA slope agreement to confirm high-probability trend direction.

    On-Chart Candle Morphing: Automatically recolors main price candles (vibrant cyan for bullish trends, vivid red for bearish trends) to maintain clear visual alignment with active indicator state.

    Multi-Line Overlay: Plots both the primary HALMA curve and the complementary HMA baseline directly on your price pane for easy visualization of moving average dynamics.

Input Parameters & Optimization Guide

    Source: Sets the input price series used for calculations (Default: OHLC4).

    HALMA Length: Sets the baseline lookback window. A default of 70 bars balances macro trend tracking with short-term responsiveness (Default: 70).

    Offset: Controls the Gaussian distribution offset within the ALMA engine. Higher values increase responsiveness to recent price changes (Default: 0.85).

    Sigma: Controls the width of the Gaussian filter. Higher values sharpen the smoothing focus, while lower values broaden the window (Default: 6).

Trading Strategies & Execution

    Dual-Slope Regime Shifts

    Bullish Alignment: Confirmed when both the HALMA and standard HMA are sloping upward, turning price chart candles cyan.

    Bearish Alignment: Confirmed when both the HALMA and standard HMA are sloping downward, turning price chart candles red.

    Dynamic Support & Resistance
    In established trends, the HALMA line serves as dynamic trailing support during bull moves and dynamic resistance during bear moves. Look for pullbacks toward the HALMA curve for low-risk continuation entries in the direction of the active trend state.

Disclaimer: Trading financial markets involves high risk. This technical script is designed as an informational analytical tool to support your rule-based mechanical execution system and does not constitute financial advice.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © MisinkoMaster

//@version=6
indicator("Hull ALMA", "HALMA", true, behind_chart = false)
//////////////////////////////////////////////////////////////////////////////////////////
//Import Libraries
import TradingView/ta/14
//////////////////////////////////////////////////////////////////////////////////////////
//Get User Defined Inputs
src = input.source(ohlc4, "Source", group = "Hull ALMA")
len_halma = input.int(70, "HALMA Length", 3, group = "Hull ALMA")
offset = input.float(0.85, "Offest", step = 0.01, group = "EXTRA")
sigma = input.float(6, "Sigma", step = 0.25, group = "EXTRA")
//////////////////////////////////////////////////////////////////////////////////////////
//Calculations
hln_halma = math.round(len_halma/2)
sln_halma = math.round(math.sqrt(len_halma))

alma1 = ta.alma(src, hln_halma, offset, sigma)
alma2 = ta.alma(src, len_halma, offset, sigma)

halma = ta.alma ( alma1 * 2 - alma2 , sln_halma , offset , sigma )
hma = ta.hma(src, len_halma)
////////////////////////////////////////////////////////////////////////////////////////////////////////
//Trend Logic
var trend = 0

L = halma > halma [1] and hma > hma[1]
S = halma < halma [1] and hma < hma[1]

if L
    trend := 1
if S
    trend := -1
////////////////////////////////////////////////////////////////////////////////////////////////////////
//Plotting
var col = color.rgb(72, 72, 72)
var colT = color.rgb(72, 72, 72, 50)
if trend == 1
    col := color.rgb(8, 190, 214)
    colT := color.rgb(8, 190, 214, 35)
if trend == -1
    col := color.rgb(241, 40, 26)
    colT := color.rgb(241, 40, 26, 35)

p = plot(halma, "HALMA", col, 2)
ps = plot(hma, "HMA", colT, 2)

plotcandle(open, high, low, close, bordercolor = col, color = col, wickcolor = col, display = display.pane, force_overlay = true)
````
