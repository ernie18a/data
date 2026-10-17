# Noise Adaptive RSI

- url: https://www.tradingview.com/script/1LWx5Ank-Noise-Adaptive-RSI/
- type: indicator
- pine_id: PUB;d651e84092e5422da26b7e46d8e5edcd
- version: 1.0

## Description

Noise Adaptive RSI | MisinkoMaster

The Noise Adaptive RSI is an advanced momentum oscillator engineered to solve one of the most persistent problems in technical analysis: outlier spikes and market noise corrupting momentum calculations. Traditional RSI algorithms treat every sharp price spike as a genuine surge in strength or weakness. This often leads to false overbought or oversold readings during brief liquidity sweeps or news-driven spikes.

By integrating statistical Z-score thresholding and dynamic noise attenuation, the Noise Adaptive RSI identifies abnormal price spikes in real time and dampens their distortive effects. The result is a clean, highly reliable, and adaptive oscillator line that reflects true structural momentum without the lag or false breakouts caused by erratic market noise.

How It Works (The Core Architecture)

The indicator filters raw price changes through a three-stage statistical filter:

    Statistical Outlier Detection: The algorithm evaluates localized price changes over a short correction lookback window, calculating moving standard deviations and tracking how far current price swings deviate from their rolling statistical averages using Z-score metrics.

    Dynamic Noise Suppression: When a gain or loss exceeds a specified Z-score threshold (indicating a statistically anomalous spike or noise event), the engine applies a corrective square-root smoothing filter to temper that outlier move before it can distort the underlying indicator state.

    Smoothed Relative Strength & Trend Tracking: The sanitized gains and losses are processed through a standard relative strength engine to plot a smooth, adaptive RSI line bounded between 0 and 100. A companion Exponential Moving Average (EMA) acts as an adaptive baseline signal line to confirm structural regime shifts.

Key Features

    Outlier-Dampened Momentum: Prevents false momentum breakouts by automatically filtering out brief liquidity sweeps and erratic market spikes.

    Dual-Confirmation Signal Line: Incorporates an adjustable signal line alongside the primary RSI curve to confirm trend shifts through signal line crossovers rather than relying solely on raw levels.

    On-Chart Candlestick Synchronization: Automatically morphs the main price chart's candle colors (vibrant green for bullish trends, pink for bearish trends) based on oscillator and signal line alignment.

    Velocity Divergence Histogram: Features a integrated rate-of-change histogram centered at the 50 level to highlight subtle shifts in momentum speed before they show up in price action.

Input Parameters & Optimization Guide

    Source: Selects the price series used for calculations (Default: Close).

    Length: The lookback period for the main Relative Strength smoothing engine (Default: 14).

    Correction Lookback & Threshold: Controls how aggressively the script identifies and dampens statistical noise spikes. Decreasing the threshold increases noise filtering for erratic markets, while increasing it lets more raw price action through (Default: 8 / 1.5).

    Moving Average Length: The lookback window for the EMA signal line, used to confirm momentum direction and filter out chop (Default: 14).

Trading Strategies & Execution

    Dual-Confirmation Trend Shifts
    Instead of depending on simple 50-level mid-line crosses, the Noise Adaptive RSI combines level positioning with signal line interaction to define high-probability trends:

    Bullish Regime: Confirmed when the Noise Adaptive RSI is above 50 AND trading above its EMA signal line (turning chart candles green).

    Bearish Regime: Confirmed when the Noise Adaptive RSI is below 50 AND trading below its EMA signal line (turning chart candles pink).

    Signal Line Reversals & Pullbacks
    In a strong trend, the yellow EMA signal line acts as dynamic support or resistance for the RSI line. During pullbacks, look for the RSI curve to bounce off the EMA line in the direction of the dominant trend for low-risk continuation entries.

    Outlier-Filtered Extreme Zones
    Because extreme spikes are statistically dampened, readings above 80 (Overbought) or below 20 (Oversold) represent true structural market overextension rather than short-lived liquidity traps, providing dependable signals for mean-reversion setups.

Disclaimer: Trading financial markets involves high risk. This technical script is designed as an informational analytical tool to support your rule-based mechanical execution system and does not constitute financial advice.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © MisinkoMaster

//@version=6
indicator("Noise Adaptive RSI", "Noise Adaptive RSI | MisinkoMaster", overlay = false)
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Import Library
import TradingView/ta/13
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Get User Defined inputs
src = input.source(close, "Source", group = "Noise Adaptive RSI | MisinkoMaster")
len = input.int(14, "Length", step = 1, minval = 2, group = "Noise Adaptive RSI | MisinkoMaster")

clen = input.int(8, "Correction Lookback", step = 1, minval = 2, group = "Noise Adaptive RSI | MisinkoMaster")
ct = input.float(1.5, "Correction Treshhold", step = 0.05, minval = 0, group = "Noise Adaptive RSI | MisinkoMaster")

malen = input.int(14, "Moving Average Length", step = 1, minval = 2, group = "Noise Adaptive RSI | MisinkoMaster")
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Calculations
change = src-src[1]

gain_ = math.max(0, change)
loss_ = math.abs(math.min(0, change))

stdev = ta.stdev(change, clen)
avg_gain_ = ta.sma(gain_, clen)
avg_loss_ = ta.sma(loss_, clen)
zsg_ = (gain_-avg_gain_)/stdev
zsl_ = (loss_-avg_loss_)/stdev

agm = gain_ - math.sqrt(gain_ - avg_gain_)
alm = loss_ - math.sqrt(loss_ - avg_loss_)

bgp = gain_+math.sqrt(avg_gain_-gain_)
blp = loss_+math.sqrt(avg_loss_-loss_)

gain = zsg_ > ct ? alm : gain_
loss = zsl_ > ct ? agm : loss_

ag = ta.rma(gain, len)
al = ta.rma(loss, len)

rs = ag/al

rsi = 100 - 100/(1+rs)
ma = ta.ema(rsi, malen)
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Trend Logic 
long = rsi > 50 and rsi > ma
short = rsi < 50 and rsi < ma

var trend = 0
if long
    trend := 1
if short
    trend := -1
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Plotting
divergence = 50+(rsi-rsi[1])

var col = color.rgb(72, 72, 72)
var colT = color.rgb(72, 72, 72, 50)
if trend == 1
    col := color.rgb(0, 255, 187)
    colT := color.rgb(0, 255, 187, 50)
if trend == -1
    col := color.rgb(255, 0, 157)
    colT := color.rgb(255, 0, 157, 50)

var colD = color.rgb(0, 255, 187, 70)
if divergence > 50
    colD := color.rgb(0, 255, 187, 70)
if divergence < 50
    colD := color.rgb(255, 0, 157, 70)

bc = rsi > 80
sc = rsi < 20

var colOB = rsi > 80 ? color.rgb(255, 0, 157, 70) : color.rgb(0, 0, 0, 100)
var colOS = rsi > 20 ? color.rgb(255, 0, 157, 70) : color.rgb(0, 0, 0, 100)


bgcolor(colOB, force_overlay = true)
bgcolor(colOB, force_overlay = false)
bgcolor(colOS, force_overlay = true)
bgcolor(colOS, force_overlay = false)

lp = plot(50, title = "Long Treshhold", color = color.rgb(71, 70, 70), display = display.pane, linewidth = 3)
sp = plot(50, title = "Short Treshhold", color = color.rgb(71, 70, 70), display = display.pane, linewidth = 3)
obp = plot(80, title = "OB Treshhold", color = color.rgb(0, 255, 187), display = display.pane, linewidth = 3)
osp = plot(20, title = "OS Treshhold", color = color.rgb(255, 0, 157), display = display.pane, linewidth = 3)

fill(sp, osp, color.rgb(255, 0, 157, 85))
fill(lp, obp, color.rgb(0, 255, 187, 85))
fill(lp, sp, color.rgb(71, 70, 70, 75))

plotcandle(open, high, low, close, bordercolor = col, color = col, force_overlay = true, display = display.pane)

rsip = plot(rsi, "Self-Correcting RSI | MisinkoMaster", color = col, linewidth = 2)
plot(divergence, "Divergence", color = colD, style = plot.style_histogram, histbase = 50)

fill(rsip, obp, colOB)
fill(rsip, osp, colOS)

plot(ma, "Moving Average", linewidth = 2, color = color.yellow)
````
