# OBV StdDev Trend Breakout

- url: https://www.tradingview.com/script/5w1ven0X-OBV-StdDev-Trend-Breakout/
- type: indicator
- pine_id: PUB;ea12551d47a34dc6b4d7047ba5ac7c6d
- version: 2.0

## Description

Overview

OBV StdDev Trend Breakout is a volume-based trend indicator built on On-Balance Volume. It compares OBV against its moving average and applies standard deviation bands to identify meaningful breakout conditions, then uses the OBV relationship to its average as the trend filter to confirm bullish or bearish bias.

How It Works

The indicator calculates upper and lower standard deviation bands around OBV. A bullish signal is triggered when OBV breaks above the prior upper band while remaining above its moving average, indicating expanding upside volume pressure with trend confirmation. A bearish signal is triggered when OBV breaks below the prior lower band while remaining below its moving average, indicating expanding downside volume pressure with trend confirmation. Once a bias is established, it persists until the opposing condition is met.

Visual Features

OBV line color updates dynamically based on the current bullish or bearish state.

Upper and lower standard deviation bands are calculated and used internally for breakout logic.

A normalized OBV baseline at 1 provides a clean reference for whether OBV is above or below its average.

Candle colors update to reflect the current OBV bias on the chart.

Inputs

SMA Period - controls the moving average length used as the trend baseline.

Standard Deviation Length - controls the lookback for standard deviation band calculation.

Standard Deviation Multiplier - adjusts the width of the bands.

Alerts
Bullish OBV Breakout: OBV breaks above the upper standard deviation band and remains above its moving average.

Bearish OBV Breakout: OBV breaks below the lower standard deviation band and remains below its moving average.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Nick_Joan
//@version=6 
indicator(title="OBV StdDev Trend Breakout | NickJoan", precision=4)

// ─── Inputs ───────────────────────────────────────────────────────────────────
obvSmaLen      = input.int(89,'SMA Period')
obvStdevLength = input.int(13,'Standard Deviation Length')
obvMultiplier  = input.float(1.00,'Standard Deviation Multiplier', step = 0.01)

// ─── Calculations ─────────────────────────────────────────────────────────────
obv      = ta.obv
obvSma   = ta.sma(obv,obvSmaLen)
obvStdev = ta.stdev(obv, obvStdevLength)

// Upper/Lower bands
upperBand = obv + obvMultiplier * obvStdev
lowerBand = obv - obvMultiplier * obvStdev

// Long/Short Conditions
obvlong  = (obv > upperBand[1]) and obv > obvSma
obvshort = (obv < lowerBand[1]) and obv < obvSma

// Normalization
normalizedObv       = obv / obvSma
normalizedUpperBand = upperBand / obvSma
normalizedLowerBand = lowerBand / obvSma

// ─── Coloring ─────────────────────────────────────────────────────────────
var bullish = false
if obvlong
    bullish := true
if obvshort
    bullish := false

obvColor = bullish ? color.rgb(174, 112, 255) : color.rgb(133, 95, 0)


// ─── Plots ─────────────────────────────────────────────────────────────
plot(normalizedObv,'OBV', color= obvColor, style = plot.style_line, linewidth = 2)
plot(1, color = color.gray, title = 'Normalized OBV SMA')

upperplot = plot(normalizedUpperBand, title = 'Upper Band', display = display.none, color = color.yellow)
lowerplot = plot(normalizedLowerBand, title = 'Lower Band', display = display.none, color = color.yellow)

fill(upperplot, lowerplot, color=color.new(color.blue,60), title = 'Fill Bands', display = display.none)

plotcandle(open,high,low,close, 'Chart Coloring', color = obvColor, bordercolor = obvColor, wickcolor = obvColor, force_overlay = true, display = display.pane)

// ─── Alerts ─────────────────────────────────────────────────────────────
alertcondition(obvlong, title ="Bullish OBV Breakout", message ="OBV broke above the upper StdDev band and is above its average.")
alertcondition(obvshort, title ="Bearish OBV Breakout", message ="OBV broke below the lower StdDev band and is below its average.")
````
