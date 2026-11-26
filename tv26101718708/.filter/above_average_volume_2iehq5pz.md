# Above Average Volume

- url: https://www.tradingview.com/script/2IEHQ5pz-Above-Average-Volume/
- type: indicator
- pine_id: PUB;316cb29f566c4abbbbd428792ddf022f
- version: 1.0

## Description

What It Does:

FeatureDetailThresholdDefault = 1.5× the 20-bar SMA of volume

Bright barsSpike bars are vivid green/red; normal bars are muted

Yellow lineRolling average volume

Orange lineAlert threshold

LabelsShows how many times above average (e.g. 2.3x)

3 alert typesAny spike / Bullish spike / Bearish spike

## Source Code

````pine
//@version=5
indicator("Above Average Volume", overlay=false, shorttitle="AAV")

// ── Inputs ──────────────────────────────────────────────────────────────────
length      = input.int(20,    "Lookback Period (bars)",   minval=1)
multiplier  = input.float(1.5, "Volume Multiplier",        minval=1.0, step=0.1)
showLabels  = input.bool(true, "Show Labels on Spikes")

// ── Calculations ─────────────────────────────────────────────────────────────
avgVol      = ta.sma(volume, length)
threshold   = avgVol * multiplier
isAboveAvg  = volume >= threshold

// ── Colors ───────────────────────────────────────────────────────────────────
volColor    = isAboveAvg ? (close >= open ? color.new(color.lime, 10) : color.new(color.red, 10)) : (close >= open ? color.new(color.green, 60) : color.new(color.red, 60))

// ── Plots ────────────────────────────────────────────────────────────────────
plot(volume,    "Volume",    style=plot.style_columns, color=volColor)
plot(avgVol,    "Avg Vol",   color=color.yellow, linewidth=1)
plot(threshold, "Threshold", color=color.orange, linewidth=1, style=plot.style_line)

// ── Labels ───────────────────────────────────────────────────────────────────
if isAboveAvg and showLabels
    label.new(bar_index, volume, text=str.tostring(math.round(volume / avgVol, 2)) + "x", style=label.style_label_down, color=color.new(color.orange, 20), textcolor=color.white, size=size.small)

// ── Alerts ───────────────────────────────────────────────────────────────────
alertcondition(isAboveAvg, title="Above Average Volume", message="⚡ Above Avg Volume: {{ticker}} | Vol: {{volume}} | TF: {{interval}}")
alertcondition(isAboveAvg and close >= open, title="Bullish Above Average Volume", message="🟢 Bullish Vol Spike: {{ticker}} | Vol: {{volume}} | TF: {{interval}}")
alertcondition(isAboveAvg and close < open, title="Bearish Above Average Volume", message="🔴 Bearish Vol Spike: {{ticker}} | Vol: {{volume}} | TF: {{interval}}")
````
