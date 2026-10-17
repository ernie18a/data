# RSI StdDev Trend Breakout

- url: https://www.tradingview.com/script/6kYtXsLz-RSI-StdDev-Trend-Breakout/
- type: indicator
- pine_id: PUB;f8e0fe925d564df7bb23d3a0abbcc1fb
- version: 2.0

## Description

Overview

RSI StdDev Trend Breakout is a hybrid momentum and trend indicator built on the Relative Strength Index. It applies dynamic standard deviation bands directly to the RSI to detect meaningful breakout conditions, then uses the RSI midline as a trend filter to confirm bullish or bearish bias.

How It Works

The indicator calculates upper and lower standard deviation bands around the RSI. A bullish signal is triggered when the RSI breaks above the prior upper band while remaining above the midline, indicating upside momentum with trend confirmation. A bearish signal is triggered when the RSI breaks below the prior lower band while remaining below the midline, indicating downside momentum with trend confirmation. Once a bias is established, it persists until the opposing condition is met.

Visual Features

RSI line and candle colors update dynamically based on the current bullish or bearish state

Upper and lower standard deviation bands plotted with a filled channel for quick visual reference

Midline reference at 50 for trend context

Inputs

RSI Length - controls the RSI calculation period

StdDev Period - controls the lookback for standard deviation band calculation

StdDev Multiplier - adjusts the width of the bands

Alerts

Bullish: RSI > 50 and breaks above the upper standard deviation band

Bearish: RSI < 50 and breaks below the lower standard deviation band

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Nick_Joan
//@version=6 
indicator(title="RSI StdDev Trend Breakout | NickJoan", precision=2)

// ─── Inputs ───────────────────────────────────────────────────────────────────
rsiLen  = input.int(33,    minval=1,   title="RSI Length")
sdLen   = input.int(14,    minval=1,   title="StdDev Period")
sdMult  = input.float(1.70, minval=0.1, title="StdDev Multiplier", step=0.01) 

// ─── Calculations ─────────────────────────────────────────────────────────────
rsi       = ta.rsi(close, rsiLen)
sd        = ta.stdev(rsi, sdLen)
upperBand = rsi + sdMult * sd
lowerBand = rsi - sdMult * sd

// ─── Signal Logic ─────────────────────────────────────────────────────────────
isAbove = rsi > upperBand[1]
isBelow = rsi < lowerBand[1]
rsilong = isAbove and rsi > 50
rsishort = isBelow and rsi < 50

var bullish = false
if rsilong
    bullish := true
if rsishort
    bullish := false

rsiColor = bullish ? color.new(color.green, 0) : color.new(color.red, 0)

// ─── Plots ────────────────────────────────────────────────────────────────────
p_rsi   = plot(rsi,    title="RSI",        color=rsiColor,                  linewidth=1)
p_upper = plot(upperBand, title="Upper Band", color=color.new(color.blue, 60), linewidth=2, display = display.none )
p_lower = plot(lowerBand, title="Lower Band", color=color.new(color.blue, 60), linewidth=2, display = display.none)
fill(p_upper, p_lower, color=color.new(color.blue, 88), title="Band Fill")

// Reference lines
hline(50, "Midline",    color=color.new(color.gray,  50), linestyle=hline.style_dashed)

// Plot Candles
plotcandle(open, high, low, close, "Candle color", color =rsiColor, wickcolor = rsiColor, bordercolor = rsiColor, force_overlay = true, display = display.pane)

// ─── Alerts ───────────────────────────────────────────────────────────────────
alertcondition(rsilong, title="RSI Broke Above Upper Band", message="RSI crossed above upper StdDev band — Bullish")
alertcondition(rsishort, title="RSI Broke Below Lower Band", message="RSI crossed below lower StdDev band — Bearish")
````
