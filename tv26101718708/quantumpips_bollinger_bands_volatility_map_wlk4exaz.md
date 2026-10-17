# QuantumPips Bollinger Bands Volatility Map

- url: https://www.tradingview.com/script/WLk4EXaZ-QuantumPips-Bollinger-Bands-Volatility-Map/
- type: indicator
- pine_id: PUB;5ec799e6e08042888dd3bcc7aadac171
- version: 1.0

## Description

QuantumPips Bollinger Bands  Volatility Map is a Bollinger Bands volatility visualizer designed to help traders quickly identify volatility regimes:
[b]compression (quiet) vs expansion (active).[/b]

[b]What the indicator shows[/b]
[b]1) Bollinger Bands (Structure)[/b]
[list]
[*]Basis (middle line): SMA of price (default length 20)
[*]Upper/Lower bands: basis ± standard deviation × multiplier (default 2.0)
[/list]
The bands adapt to market volatility:
[list]
[*]Wider bands = more volatility
[*]Tighter bands = less volatility
[/list]

[b]2) Volatility Heat Fill (Inside the bands)[/b]

The space between the upper and lower bands is filled with a heat color that reacts to volatility:
[list]
[*]Duller colors = lower volatility
[*]Brighter colors = higher volatility
[*]Very bright color = strong volatility expansion
[/list]
This is based on bandwidth, a standard volatility measure:
[list]
[*]Bandwidth % = (Upper − Lower) / Basis × 100
[/list]
Bandwidth is normalized over a window so the heat remains consistent across symbols/timeframes.

[b]3) Bandwidth Strip Overlay (Mini volatility panel on chart)[/b]

The strip is a compact “volatility meter” mapped into a small area on the chart:
[list]
[*]The white line represents current bandwidth level
[/list]
The strip includes two reference zones:
[list]
[*]Squeeze zone (low volatility)
[*]Expansion zone (high volatility)
[/list]
This lets you read volatility conditions without looking down to another pane.

[b]4) Optional SQ / EXP Markers[/b]
[list]
[*]SQ = Squeeze start (volatility enters the low zone)
[*]EXP = Expansion burst (volatility enters the high zone)
[/list]
These markers are intended to highlight regime changes. They do not force direction by themselves.

[b]How traders can use it [/b]
[b]A) Identify “quiet → active” transitions[/b]
[list=1]
[*]Look for a squeeze (bands tighten + strip moves into squeeze zone)
[*]Watch for price leaving the range and volatility increasing
[*]When volatility expands (strip rises / EXP appears), the market is typically in a more active phase
[/list]
[b]B) Decide whether conditions are worth trading[/b]
[list]
[*]Mostly squeeze / dull heat = slower conditions (often range-like)
[*]Rising strip / brighter heat = more active conditions (often trend legs or breakouts)
[/list]

[b]Settings (how users can customize)[/b]
[b]Bollinger Bands[/b]
[list]
[*]Length: lower = faster & more sensitive; higher = smoother
[*]Multiplier: higher = wider bands; lower = tighter bands
[/list]
[b]Volatility Heat[/b]
[list]
[*]Normalize window: higher = smoother heat changes; lower = faster changes
[*]Heat opacity: visual only (reduce for a cleaner chart)
[/list]
[b]Squeeze / Expansion Zones[/b]
[list]
[*]Squeeze threshold: increase to detect more squeezes, decrease for only the tightest compressions
[*]Expansion threshold: decrease to trigger earlier expansions, increase for only strong volatility bursts
[/list]
[b]Strip Placement (Overlay)[/b]
[list]
[*]Strip offset / height: controls where the strip sits on the chart and how tall it is
[*]Use this to keep the strip readable without covering price.
[/list]


**This tool is intended for analysis and education. It does not guarantee outcomes and should be combined with your own entry/exit rules and risk management.**

## Source Code

````pine
//@version=6
indicator("QuantumPips Bollinger Bands Volatility Map", shorttitle="QP BB VOL MAP", overlay=true, max_labels_count=200)

//────────────────────────────────────────────
// Inputs
//────────────────────────────────────────────
grpBB = "Bollinger Bands"
len   = input.int(20, "Length", minval=1, group=grpBB)
src   = input.source(close, "Source", group=grpBB)
mult  = input.float(2.0, "StdDev Mult", step=0.1, group=grpBB)

grpVol = "Volatility Map"
normLen      = input.int(200, "Normalize window", minval=20, group=grpVol)
heatOpacity  = input.int(85, "Heat opacity (0-100)", minval=0, maxval=100, group=grpVol)
showHeatFill = input.bool(true, "Heat fill between bands", group=grpVol)

grpBW = "Bandwidth Strip (Overlay)"
bwMaLen      = input.int(50, "Bandwidth MA length", minval=5, group=grpBW)
squeezePct   = input.float(0.20, "Squeeze threshold (0–1 of range)", step=0.05, minval=0.05, maxval=0.95, group=grpBW)
expandPct    = input.float(0.80, "Expansion threshold (0–1 of range)", step=0.05, minval=0.05, maxval=0.95, group=grpBW)

// Strip placement (on price chart)
mapLen        = input.int(200, "Strip mapping lookback", minval=50, group=grpBW)
stripOffsetPct= input.float(0.06, "Strip offset from bottom (range %)", step=0.01, minval=0.0, maxval=0.5, group=grpBW)
stripHeightPct= input.float(0.18, "Strip height (range %)", step=0.01, minval=0.05, maxval=0.6, group=grpBW)

grpMarks = "Markers"
showSqueezeMark = input.bool(true, "Mark squeezes on chart", group=grpMarks)
showExpandMark  = input.bool(true, "Mark expansion bursts on chart", group=grpMarks)

//────────────────────────────────────────────
// Helpers
//────────────────────────────────────────────
f_clamp(x, lo, hi) =>
    x < lo ? lo : x > hi ? hi : x

//────────────────────────────────────────────
// Core BB
//────────────────────────────────────────────
basis = ta.sma(src, len)
dev   = ta.stdev(src, len) * mult
upper = basis + dev
lower = basis - dev

pBasis = plot(basis, "Basis", color=color.new(color.white, 0), linewidth=2)
pUpper = plot(upper, "Upper", color=color.new(color.aqua, 0), linewidth=1)
pLower = plot(lower, "Lower", color=color.new(color.aqua, 0), linewidth=1)

//────────────────────────────────────────────
// Bandwidth (volatility measure)
//────────────────────────────────────────────
bw = (upper - lower) / math.max(basis, syminfo.mintick) * 100.0
bwMa = ta.sma(bw, bwMaLen)

// Normalize BW for heat intensity (0..1)
bwMin = ta.lowest(bw, normLen)
bwMax = ta.highest(bw, normLen)
bwRange = math.max(bwMax - bwMin, 0.000001)
bwNorm = f_clamp((bw - bwMin) / bwRange, 0.0, 1.0)

// Squeeze / Expansion thresholds
sqLevel = bwMin + bwRange * squeezePct
exLevel = bwMin + bwRange * expandPct

isSqueeze = bw <= sqLevel
isExpand  = bw >= exLevel

expandBurst  = isExpand and not isExpand[1]
squeezeStart = isSqueeze and not isSqueeze[1]

//────────────────────────────────────────────
// Heat fill between bands (vibrant)
//────────────────────────────────────────────
heatCol =
     bwNorm >= 0.80 ? color.new(color.fuchsia, heatOpacity) :
     bwNorm >= 0.55 ? color.new(color.blue,    heatOpacity) :
     bwNorm >= 0.35 ? color.new(color.teal,    heatOpacity) :
                      color.new(color.gray,    heatOpacity)

fill(pUpper, pLower, color = showHeatFill ? heatCol : na, title="Volatility Heat Fill")

//────────────────────────────────────────────
// Bandwidth Strip Overlay (mapped onto price chart)
//────────────────────────────────────────────
loP = ta.lowest(low, mapLen)
hiP = ta.highest(high, mapLen)
rngP = math.max(hiP - loP, syminfo.mintick * 100)

base = loP + rngP * stripOffsetPct
height = rngP * stripHeightPct

f_map01(x01) =>
    base + x01 * height

// Convert BW into 0..1 using bwMin/bwMax (same normalization window)
bw01 = f_clamp((bw - bwMin) / bwRange, 0.0, 1.0)
sq01 = f_clamp((sqLevel - bwMin) / bwRange, 0.0, 1.0)
ex01 = f_clamp((exLevel - bwMin) / bwRange, 0.0, 1.0)

yBW = f_map01(bw01)
ySQ = f_map01(sq01)
yEX = f_map01(ex01)
y0  = base
y1  = base + height

pBW = plot(yBW, "BW Strip", color=color.new(color.white, 0), linewidth=2)
pSQ = plot(ySQ, "Squeeze line", color=color.new(color.yellow, 10), linewidth=1)
pEX = plot(yEX, "Expansion line", color=color.new(color.fuchsia, 10), linewidth=1)
p0  = plot(y0, "Strip Bottom", color=color.new(color.gray, 100))
p1  = plot(y1, "Strip Top", color=color.new(color.gray, 100))

// Shade strip zones
fill(p0, pSQ, color=color.new(color.yellow, 88), title="Squeeze Strip Fill")
fill(pEX, p1, color=color.new(color.fuchsia, 88), title="Expansion Strip Fill")

//────────────────────────────────────────────
// Chart markers (minimal + clean)
//────────────────────────────────────────────
plotshape(showExpandMark and expandBurst, title="Expansion Burst",
     style=shape.triangleup, location=location.belowbar, size=size.tiny,
     color=color.new(color.fuchsia, 0), text="EXP", textcolor=color.white)

plotshape(showSqueezeMark and squeezeStart, title="Squeeze Start",
     style=shape.circle, location=location.belowbar, size=size.tiny,
     color=color.new(color.yellow, 0), text="SQ", textcolor=color.black)
````
