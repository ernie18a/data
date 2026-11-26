# Volume Flames (hotchkiss)

- url: https://www.tradingview.com/script/Oicv1R3A-Volume-Flames-hotchkiss/
- type: indicator
- pine_id: PUB;7a413b35c85b407ea5fb0d0e4b8367c1
- version: 1.0

## Description

Volume Flames is a volume analysis indicator designed to visualize the intensity and momentum of market volume as a layered flame structure. Rather than displaying raw volume bars, it transforms volume data into a multi-layered heat gradient that rises and falls like fire — making it immediately intuitive to read at a glance how "hot" or "cold" volume pressure is at any given moment.

How it works:
The indicator stacks multiple exponential moving averages of volume on top of each other, each smoothed at a progressively faster rate. This creates a flame body with a dense dark core at the base, rising through deep reds and oranges into bright yellows and a white-hot tip. The outermost layer represents raw unsmoothed volume, giving the flame its sharp reactive spikes on high-volume bars. Gradient fills between each layer produce the signature fire glow effect.
What the signals mean:
White circles appear above the flame tip whenever volume surges significantly above its recent average — these are your burn signals, flagging explosive volume events that often precede sharp price moves. Yellow dots cluster near the base of the flame when volume momentum is building across consecutive bars, giving early warning that heat is rising before a full burn triggers. The dark maroon core columns underneath indicate baseline volume density, helping you distinguish genuine spikes from noise.

How to use it:
Watch for white circles breaking well above the flame body — that's a volume surge worth paying attention to. When yellow dots begin clustering and the flame layers start widening and brightening, it means momentum is accumulating. The taller and brighter the flame, the more volume pressure is building. A sudden spike of the white raw-volume tip far above the smoothed layers signals an aggressive market participant entering or exiting a position.
Best used on: Any liquid asset on any timeframe. Works particularly well on 1m–1h charts for intraday momentum reading, and daily charts for spotting accumulation and distribution phases.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © LuxAlgo

//@version=6
indicator("Volume Flames V3", shorttitle="Flames", overlay=false, format=format.volume)

// --- Groups & Inputs ---
G_FLAME = "Flame Dynamics"
baseLen    = input.int(20, "Flame Smoothness", minval=1, group=G_FLAME)
heightMult = input.float(1.0, "Flame Height Scale", minval=0.1, step=0.1, group=G_FLAME)
sens       = input.float(2.0, "Burn Sensitivity", minval=1.0, step=0.1, group=G_FLAME)

G_STYLE = "Visual Styles"
showCore   = input.bool(true, "Show Flame Core", group=G_STYLE)
c_hot      = input.color(#ffffff, "Flame Tip", group=G_STYLE)
c_high     = input.color(#ffeb3b, "High Flame", group=G_STYLE)
c_mid      = input.color(#ff9800, "Mid Flame", group=G_STYLE)
c_low      = input.color(#f23645, "Flame Base", group=G_STYLE)
c_core     = input.color(#ff3545, "Flame Core", group=G_STYLE)

// --- Core Calculations ---
volMa = ta.sma(volume, 50)
rvol  = volume / (volMa == 0 ? 1 : volMa)

// Logic for "Burn" (Explosive push)
isBurn = rvol > sens and volume > volume[1]

// Layered Volume Smoothing
vBase = volume * heightMult
l1 = ta.ema(vBase, baseLen)
l2 = ta.ema(vBase, math.max(1, int(baseLen * 0.75)))
l3 = ta.ema(vBase, math.max(1, int(baseLen * 0.50)))
l4 = ta.ema(vBase, math.max(1, int(baseLen * 0.25)))
l5 = vBase

// Heat Building
heatRising = ta.rising(l1, 2) and rvol > 1.1

// --- Visuals ---
// Core Background
plot(showCore ? l1 * 0.5 : na, "Core Density", color.new(c_core, 60), style=plot.style_columns)

// Flame Layers
p1 = plot(l1, "Layer 1", color.new(c_core, 30), style=plot.style_line)
p2 = plot(l2, "Layer 2", color.new(c_low, 40),  style=plot.style_line)
p3 = plot(l3, "Layer 3", color.new(c_mid, 50),  style=plot.style_line)
p4 = plot(l4, "Layer 4", color.new(c_high, 60), style=plot.style_line)
p5 = plot(l5, "Layer 5", color.new(c_hot, 70),  style=plot.style_line)

// Gradient Fills
fill(p1, p2, l2, l1, color.new(c_low, 50), color.new(c_core, 20))
fill(p2, p3, l3, l2, color.new(c_mid, 50), color.new(c_low, 50))
fill(p3, p4, l4, l3, color.new(c_high, 50), color.new(c_mid, 50))
fill(p4, p5, l5, l4, color.new(c_hot, 50), color.new(c_high, 50))

// Signals
plot(isBurn ? l5 * 1.1 : na, "Burn Signal", c_hot, 3, plot.style_circles)
plot(heatRising ? l1 * 0.1 : na, "Heat Rising", c_high, 2, plot.style_circles)

// Edge
plot(l5, "Flame Edge", isBurn ? c_hot : c_high, 1, plot.style_linebr)

// Reference (Using hline for dashed style)
hline(0, "Zero Line", color.new(color.gray, 90))
// Since hline requires a constant, we use plot for dynamic volMa
plot(volMa * heightMult, "Avg Vol", color.new(color.gray, 70), 1, plot.style_line)

// Alerts
alertcondition(isBurn, "Burn", "Volume spike!")
alertcondition(heatRising, "Rising", "Momentum building!")
````
