<!-- tradingview-pine-id: PUB;f6a4793c77f94651bfdcdc1143c9952c -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Phoenix Ascending 2.6

Source: https://www.tradingview.com/script/1TNKGfkP-Phoenix-Ascending-2-6/

## Description

Overview
This is a modernized Pine Script v6 update of the original "Phoenix Ascending 2.201" indicator, originally published by WyckoffMode (with script contributions from LazyBear, xSilas, and Ni6HTH4wK). Since the original script appears to no longer be actively maintained, I have updated the code to the latest Pine Script version to ensure it continues running efficiently, while keeping the original mathematical logic exactly the same.

What is Phoenix Ascending?
Phoenix Ascending is a comprehensive, multi-component momentum and money-flow oscillator. Rather than relying on a single metric, it aggregates several popular momentum indicators to create a smoothed, high-conviction market gauge. 

At its core, the script calculates two main averages:

[*]The "Tradition" Index: An average of TCI (Trade Channel Index), Money Flow (MF), and the Relative Strength Index (RSI).
[*]The "Phoenix" Index: An average of TCI, CSI, Money Flow, and a Williams %R derivative (Willy).

By blending these components, the indicator filters out market noise and provides a clearer view of underlying buying and selling pressure.

How to Read the Indicator
The indicator plots several distinct visual elements on the oscillator panel:

[*]Green Line (Tradition): Acts as the primary fast signal line tracking current price momentum. 
[*]Red Line (Smoothed RSI): A slower moving average of the Green Line. 
[*]LSMA (Least Squares Moving Average): A regression line that helps identify the true underlying trend direction.
[*]Energy (Area/Histogram): A shaded region that visualizes the spread and momentum intensity between the fast and slow signal lines.
[*]Pressure Dots (Circles): These appear at the extreme bands (below 20 or above 80) to signal extreme overbought or oversold conditions where a reversal is highly probable.

How to Use It in Trading

[*]Trend Reversals: Watch for the Green Line to cross over the Red Line and LSMA from below 20 (oversold) for a bullish entry signal. Conversely, a cross downward from above 80 (overbought) signals a bearish reversal.
[*]Momentum Strength: Use the shaded "Energy" area to gauge the strength of a move. Expanding energy confirms the trend, while contracting energy warns of consolidation or a fading move.
[*]Extreme Zones: Pay close attention to the "Pressure" dots. When these populate at the top or bottom of the oscillator, it suggests the current move is exhausted and a mean-reversion setup is forming.

Credits
All credit for the original concept, mathematics, and logic goes to [WyckoffMode](https://www.tradingview.com/u/WyckoffMode/), along with the original open-source contributors ([LazyBear](https://www.tradingview.com/u/LazyBear/), [xSilas](https://www.tradingview.com/u/xSilas/), [Ni6HTH4wK](https://www.tradingview.com/u/Ni6HTH4wK/)). You can view the legacy version of this script here: [Phoenix Ascending 2.201 by WyckoffMode](https://www.tradingview.com/script/ay9QX4dy-Phoenix-Ascending-2-201/).

You can also find some helpful videos on how to use the script there.

---

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// authors: @LazyBear @xSilas @Ni6HTH4wK ©WyckoffMode @tuxxilla

//@version=6
// Migrated from v4 to v6:
//   study()           → indicator()
//   input()           → input.int() / input.bool()
//   avg()             → explicit arithmetic average
//   abs()             → math.abs()
//   sum()             → ta.sum()
//   rsi()             → ta.rsi()  (two-series form expanded to formula)
//   tsi()             → ta.tsi()
//   sma()             → ta.sma()
//   ema()             → ta.ema()
//   highest/lowest()  → ta.highest() / ta.lowest()
//   linreg()          → ta.linreg()
//   stoch()           → ta.stoch()
//   change()          → ta.change()
//   tr                → ta.tr
//   transp=           → color.new(color, alpha)
indicator("Phoenix Ascending 2.6", shorttitle="", overlay=false)

//-----------------------------------------------------------------------------------------------------------------------------------------------------------------
// Sources
src0 = open
src1 = high
src2 = low
src3 = close
src4 = hl2
src5 = hlc3
src6 = ohlc4
src7 = ta.tr
vol  = volume

// Inputs
n1 = input.int(9,  "Phx master")
n2 = input.int(6,  "Phx time 1")
n3 = input.int(3,  "Phx time 2")
n4 = input.int(32, "LSMA 1")
n5 = input.int(0,  "LSMA 1")

//-----------------------------------------------------------------------------------------------------------------------------------------------------------------
// Indicator Functions

// tci: trend/cycle index normalised to 0–100
tci(src) =>
    ta.ema((src - ta.ema(src, n1)) / (0.025 * ta.ema(math.abs(src - ta.ema(src, n1)), n1)), n2) + 50

// mf: money-flow RSI  (v4 two-series rsi(x,y) expanded to formula: 100 - 100/(1 + x/y))
// ta.sum() removed in v6; ta.sma() * length = rolling sum, but the length cancels in the ratio
mf(src) =>
    upMF   = ta.sma(volume * (ta.change(src) <= 0 ? 0.0 : src), n3)
    downMF = ta.sma(volume * (ta.change(src) >= 0 ? 0.0 : src), n3)
    downMF == 0.0 ? 100.0 : 100.0 - 100.0 / (1.0 + upMF / downMF)

// willy: Williams %R variant normalised to 0–100
willy(src) =>
    60.0 * (src - ta.highest(src, n2)) / (ta.highest(src, n2) - ta.lowest(src, n2)) + 80.0

// csi: composite strength index
csi(src) =>
    (ta.rsi(src, n3) + ta.tsi(src0, n1, n2) * 50.0 + 50.0) / 2.0

// "Phoenix Ascending" — average of tci, csi, mf, willy
phoenix(src) =>
    (tci(src) + csi(src) + mf(src) + willy(src)) / 4.0

// "Tradition" — average of tci, mf, rsi
tradition(src) =>
    (tci(src) + mf(src) + ta.rsi(src, n3)) / 3.0

//-----------------------------------------------------------------------------------------------------------------------------------------------------------------
// Calculations

wt1  = tradition(src5)
wt2  = ta.sma(wt1, 6)

// Pressure dots: extend beyond overbought/oversold zones
ext1 = wt2 < 20 ? wt2 + 5.0 : wt2 > 80 ? wt2 - 5.0 : na

// LSMA
wt3  = ta.linreg(wt1, n4, n5)

// Energy histogram centred on 50
wt4  = ta.ema((wt1 - wt2) * 2.0 + 50.0, n3)

//-----------------------------------------------------------------------------------------------------------------------------------------------------------------
// Plots

plot(wt1,  "Green Line", color=color.green,                                          linewidth=3)
plot(wt2,  "Red RSI",    color=color.red,                                            linewidth=3)
plot(wt3,  "LSMA",       color=color.blue,                                           linewidth=3)
plot(wt4,  "Energy",     color=color.new(color.white, 65), style=plot.style_area,    histbase=50)
plot(ext1, "Pressure",   color=color.orange,               style=plot.style_circles, linewidth=2)

hline(120, color=color.purple, linewidth=1, linestyle=hline.style_solid)
hline(110, color=color.red,    linewidth=1, linestyle=hline.style_solid)
hline(100, color=color.orange, linewidth=2, linestyle=hline.style_solid)
hline(100, color=color.blue,   linewidth=2, linestyle=hline.style_dashed)
hline(90,  color=color.blue,   linewidth=1, linestyle=hline.style_solid)
hline(80,  color=color.white,  linewidth=2, linestyle=hline.style_solid)
hline(80,  color=color.blue,   linewidth=2, linestyle=hline.style_dashed)
hline(70,  color=color.white,  linewidth=1, linestyle=hline.style_solid)
hline(60,  color=color.gray,   linewidth=2, linestyle=hline.style_solid)
hline(60,  color=color.yellow, linewidth=2, linestyle=hline.style_dashed)
hline(50,  color=color.yellow, linewidth=2, linestyle=hline.style_solid)
hline(40,  color=color.gray,   linewidth=2, linestyle=hline.style_solid)
hline(40,  color=color.yellow, linewidth=2, linestyle=hline.style_dashed)
hline(30,  color=color.white,  linewidth=1, linestyle=hline.style_solid)
hline(20,  color=color.white,  linewidth=2, linestyle=hline.style_solid)
hline(20,  color=color.blue,   linewidth=2, linestyle=hline.style_dashed)
hline(10,  color=color.blue,   linewidth=1, linestyle=hline.style_solid)
hline(0,   color=color.orange, linewidth=2, linestyle=hline.style_solid)
hline(0,   color=color.blue,   linewidth=2, linestyle=hline.style_dashed)
hline(-10, color=color.red,    linewidth=1, linestyle=hline.style_solid)
hline(-20, color=color.purple, linewidth=1, linestyle=hline.style_solid)

//-----------------------------------------------------------------------------------------------------------------------------------------------------------------
// Optional Stochastic RSI overlay

dRSI        = input.bool(false, "Draw sRSI")
periodK     = input.int(14, title="K",                  minval=1)
periodD     = input.int(3,  title="D",                  minval=1)
smoothK     = input.int(3,  "K smoothing",              minval=1)
smoothD     = input.int(3,  "D smoothing",              minval=1)
lengthRSI   = input.int(14, "RSI Length",               minval=1)
lengthStoch = input.int(14, "Stochastic Length",        minval=1)

h0 = hline(80, "Upper Band", color=color.green)
h1 = hline(20, "Lower Band", color=color.red)

rsi1 = ta.rsi(close, lengthRSI)
k    = ta.sma(ta.stoch(rsi1, rsi1, rsi1, lengthStoch), smoothK)
d    = ta.sma(k, smoothD)

plot(dRSI ? k : na, "K", color=#f5f114)
plot(dRSI ? d : na, "D", color=#e314a8)
````
