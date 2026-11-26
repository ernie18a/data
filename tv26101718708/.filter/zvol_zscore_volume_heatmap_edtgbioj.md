# ZVOL — Z-Score Volume Heatmap

- url: https://www.tradingview.com/script/EDTGBIoJ-ZVOL-Z-Score-Volume-Heatmap/
- type: indicator
- pine_id: PUB;2c50a18e79c84c118c2e91b1d42cf48b
- version: 1.0

## Description

ⓩ ZVOL transforms raw volume into a statistically calibrated heatmap using Z-score thresholds. Unlike classic volume indicators that rely on fixed MA comparisons, ZVOL calculates how many standard deviations each volume bar deviates from its mean. This makes the reading adaptive across timeframes and assets, in order to distinguish meaningful crowd behavior from random volatility.  
  
📊 The core display is a five-zone histogram, each encoded by color and statistical depth. Optional background shading mirrors these zones across the entire pane, revealing subtle compression or structural rhythm shifts across time. By grounding the volume reading in volatility-adjusted context, ZVOL inhibits impulsive trading tactics by compelling the structure, not the sentiment, to dictate the signal.  
  
🥵 [b]Heatmap Coloration:[/b]
  
🌚 Suppressed volume — [i]congestion, coiling phases[/i]
🩱 Stable flow — [i]early trend or resting volume[/i]
🏀 High activity — [i]emerging pressure[/i]
💔 Extreme — [i]possible climax or institutional print[/i]
  
🎗️ A dynamic Fibonacci-based 21:34-period EMA ribbon overlays the histogram. The fill area inverts color on crossover, providing a real-time read on tempo, expansion, or divergence between price structure and crowd effort.  
  
💡 [b]LTF Usage Suggestions:[/b]
  
• Confirm breakout legs when orange or red zones align with range exits  
• Fade overextended moves when red bars appear into resistance  
• Watch for rising EMAs and orange volume to front-run impulsive moves  
• Combine with volatility suppression (e.g. ATR) to catch compression → expansion transitions  
  
🥂 [b]Ideal Pairings:[/b]
  
• OBVX Conviction Bias — [i]to confirm directional intent behind volume shifts[/i]
• SUPeR TReND 2.718 — [i]for directional filters[/i]
• ATR Turbulence Ribbon — [i]to detect compression phases[/i]
  
👥 The OBVX Conviction Bias adds a second dimension to ZVOL by revealing whether crowd effort is aligning with price direction or diverging beneath the surface. While ZVOL identifies statistical anomalies in raw volume, OBVX tracks directional commitment using cumulative volume and moving average cross logic. Use them together to spot fake-outs, anticipate structure-confirmed breakouts, or time pullbacks with volume-based conviction.  
  
🔬 ZVOL isn’t just a volume filter — it’s a structural lens. It reveals when crowd effort is meaningful, when it's fading, and when something is about to shift. Designed for structure-aware traders who care about context, not noise.

## Source Code

````pine
// Open Source | Designed by Adrian Dyer for "The Leading Indicator", Engineered by PineForge Laboratory  (2025)
//@version=6
indicator("ZVOL — Z-Score Volume Heatmap", shorttitle="ZVOL", overlay=false, format=format.volume, precision=1)

// ——— INPUTS ——— //
groupInput = "Heatmap Settings"
maLen = input.int(100, "Moving Average Length", minval=2, group=groupInput)
stdLen = input.int(100, "Standard Deviation Length", minval=2, group=groupInput)

thresholdLow     = input.float(0.0, "Low Threshold (σ)", group=groupInput)
thresholdMed     = input.float(1.0, "Medium Threshold (σ)", group=groupInput)
thresholdHigh    = input.float(2.5, "High Threshold (σ)", group=groupInput)
thresholdExtreme = input.float(4.0, "Extreme Threshold (σ)", group=groupInput)

// ——— COLORS ——— //
groupColors = "Zone Colors"
colLow     = input.color(color.gray, "Low", group=groupColors)
colMed     = input.color(color.teal, "Medium", group=groupColors)
colHigh    = input.color(color.orange, "High", group=groupColors)
colExtreme = input.color(color.red, "Extreme", group=groupColors)

// ——— Z-SCORE CALC ——— //
volMA = ta.sma(volume, maLen)
volStdev = ta.stdev(volume, stdLen)
zScore = (volume - volMA) / volStdev

zone = zScore < thresholdLow ? 0 : zScore < thresholdMed ? 1 : zScore < thresholdHigh ? 2 : zScore < thresholdExtreme ? 3 : 4

zoneColor = zone == 0 ? colLow : zone == 1 ? colMed : zone == 2 ? colHigh : colExtreme

// ——— PLOTS ——— //

// Ribbon shading control
ribbonOpacity = input.int(20, "Ribbon Shading Opacity (0–100)", minval=0, maxval=100, group="Heatmap Settings")

showBG = input.bool(true, "Show Background Heatmap", group="Heatmap Settings")

// Background band logic
bgCol = zone == 4 ? color.new(colExtreme, 65) :
         zone == 3 ? color.new(colHigh, 65) :
         zone == 2 ? color.new(colMed, 65) :
         zone == 1 ? color.new(colLow, 65) : na

bgcolor(showBG ? bgCol : na)

// Volume bars by zone
plot(volume, "Volume", style=plot.style_columns, color=zoneColor)

// Fill between EMA 21 and EMA 34
ema21 = ta.ema(volume, 21)
ema34 = ta.ema(volume, 34)
emaColor = ema21 > ema34 ? color.new(#b5feed, ribbonOpacity) : color.new(#06706d, ribbonOpacity)
p1 = plot(ema21, "EMA 21", color=color.new(#b5feed, 0), linewidth=1)
p2 = plot(ema34, "EMA 34", color=color.new(#089590, 0), linewidth=1)
fill(p1, p2, color=emaColor, title="EMA Fill")

// Future expansions: background zones, structure overlays, directional modes
````
