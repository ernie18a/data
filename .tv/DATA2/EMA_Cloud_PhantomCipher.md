<!-- tradingview-pine-id: PUB;4f96992eac9145d08038899914eae255 -->
<!-- tradingview-pine-version: 2.0 -->
<!-- tradingviewscripts-format: 1 -->
# EMA Cloud [PhantomCipher]

Source: https://www.tradingview.com/script/C4qHyn8A-EMA-Cloud-PhantomCipher/

## Description

EMA Cloud

EMA Cloud shows the trend as a shaded band between two exponential moving averages, with a third EMA drawn as a longer-term reference line.

SNAPSHOT: the indicator on a clean chart, with the cloud in both colours and the 200 EMA line visible

How it works

[*]Cloud: the area between a fast EMA (50 by default) and a slow EMA (100 by default) is filled. It's green while the fast EMA is at or above the slow EMA (uptrend) and red while it's below (downtrend).
[*]EMA lines: the fast and slow EMAs are also drawn as lines that change colour with the trend.
[*]Reference line: a separate EMA (200 by default) is drawn as a single line. It's not part of the cloud and its colour doesn't change with the trend. Use it to see where price sits against the longer-term trend.

Settings

[*]Inputs tab: the length of each EMA, grouped into "EMA Cloud" (fast and slow) and "EMA Line" (the reference EMA).
[*]Style tab: every colour, line width and on/off switch, including separate uptrend and downtrend colours for the cloud and for each EMA line.

Alerts

[*]EMA Trend Up: fires when the fast EMA crosses above the slow EMA.
[*]EMA Trend Down: fires when the fast EMA crosses below the slow EMA.

Create the alert with Once Per Bar Close. A cross that happens part-way through a bar can reverse before the bar closes.

The trend flip comes from comparing the two EMAs:
[pine]
EMA_UpTrend = ta.ema(close, 50) >= ta.ema(close, 100)
[/pine]

SNAPSHOT: close-up of a trend flip, with the cloud changing colour where the two EMAs cross

How to use it
A change in cloud colour marks a shift in trend between the two EMAs. The 200 EMA adds context. For example, you might take only uptrend signals while price is above it, and only downtrend signals while price is below it.

Example chart: [symbol="BYBIT:BTCUSDT.P"]BYBIT:BTCUSDT.P[/symbol]

This indicator shows trend conditions. It's not a trading signal on its own, so combine it with your own analysis and risk management.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © phantomcipher
//
// A trend cloud between two EMAs (50/100 by default) plus a longer EMA (200) drawn as a line.

//@version=6
// explicit_plot_zorder: plots and fills stack in the order declared, so the cloud sits under the lines.
// It is also the only setting that might move the cloud to the top of the Style tab.
indicator("EMA Cloud [PhantomCipher]", overlay=true, explicit_plot_zorder=true)

// Inputs hold lengths only. Every colour and every show/hide lives in the Style tab,
// which is why no plot or fill below takes a colour computed at runtime: TradingView
// hides the colour picker for any plot whose colour is a series.
GRP_CLOUD = "EMA Cloud"
emaS_value = input.int(50, minval=1, title="EMA Small - Value", group=GRP_CLOUD)
emaB_value = input.int(100, minval=1, title="EMA Big - Value", group=GRP_CLOUD)

// Third EMA - drawn as a line only, never part of the cloud
GRP_LINE   = "EMA Line"
emaL_value = input.int(200, minval=1, title="EMA Line - Value", group=GRP_LINE)

emaS = ta.ema(close, emaS_value)
emaB = ta.ema(close, emaB_value)
emaL = ta.ema(close, emaL_value)

// Trend state
EMA_UpTrend   = emaS >= emaB
EMA_DownTrend = emaS < emaB

// Crossover detection
var float crossover = na
if crossover == 1
    crossover := na
else if EMA_UpTrend[1] and EMA_DownTrend
    crossover := -1
else if crossover == -1
    crossover := na
else if EMA_DownTrend[1] and EMA_UpTrend
    crossover := 1

// Cloud - one fill per trend, each with a fixed colour. Outside its own trend a fill's
// edges collapse onto emaB, so it has zero height rather than na: a crossover bar is
// then split between the two fills instead of left as a gap.
upTop   = plot(EMA_UpTrend ? emaS : emaB,   title="Cloud Up Edge",   display=display.none, editable=false)
downTop = plot(EMA_DownTrend ? emaS : emaB, title="Cloud Down Edge", display=display.none, editable=false)
cloudB  = plot(emaB,                        title="Cloud Base",      display=display.none, editable=false)
fill(upTop,   cloudB, color=color.new(color.green, 70), title="Cloud UpTrend")
fill(downTop, cloudB, color=color.new(#ff0000, 70),     title="Cloud DownTrend")

// EMA lines - shown by default, switched off from the Style tab. Split by trend so each
// keeps a fixed colour; the previous bar is included so a line has no break at a cross.
upBar   = EMA_UpTrend or EMA_UpTrend[1]
downBar = EMA_DownTrend or EMA_DownTrend[1]
plot(upBar ? emaS : na,   title="EMA Small UpTrend",   color=color.new(color.green, 70), linewidth=1, style=plot.style_linebr)
plot(downBar ? emaS : na, title="EMA Small DownTrend", color=color.new(#ff0000, 70),     linewidth=1, style=plot.style_linebr)
plot(upBar ? emaB : na,   title="EMA Big UpTrend",     color=color.new(color.green, 70), linewidth=2, style=plot.style_linebr)
plot(downBar ? emaB : na, title="EMA Big DownTrend",   color=color.new(#ff0000, 70),     linewidth=2, style=plot.style_linebr)

plot(emaL, title="EMA Line", color=color.new(#f23645, 35), linewidth=2)

// Alerts
alertcondition(crossover == 1,  title="EMA Trend Up",   message="EMA Trend Up - {{ticker}} - {{interval}}")
alertcondition(crossover == -1, title="EMA Trend Down", message="EMA Trend Down - {{ticker}} - {{interval}}")
````
