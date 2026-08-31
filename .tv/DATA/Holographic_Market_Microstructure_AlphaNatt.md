<!-- tradingview-pine-id: PUB;08e9430a2f294382a0219b51beadc053 -->
<!-- tradingviewscripts-format: 1 -->
# Holographic Market Microstructure | AlphaNatt

Source: https://www.tradingview.com/script/0Nz4M9e7-Holographic-Market-Microstructure-AlphaNatt/

## Description

Holographic Market Microstructure | AlphaNatt

A multidimensional, holographically-rendered framework designed to expose the invisible forces shaping every candle — liquidity voids, smart money footprints, order flow imbalances, and structural evolution — in real time.

---

📘 Overview
The Holographic Market Microstructure (HMS) is not a traditional indicator. It’s a visual architecture built to interpret the true anatomy of the market — a living data structure that fuses price, volume, and liquidity into one coherent holographic layer.
Instead of reacting to candles, HMS visualizes the market’s underlying micro-dynamics: where liquidity hides, where volume flows, and how structure morphs as smart money accumulates or distributes.

Designed for system-based traders, volume analysts, and liquidity theorists who demand to see the unseen — the invisible grid driving every price movement.

---

🔬 Core Analytical Modules

[] Microstructure Analysis
Deconstructs each bar’s internal composition to identify imbalance between aggressive buying and selling. Using a configurable Imbalance Ratio and Liquidity Threshold, the algorithm marks low-liquidity zones and price inefficiencies as “liquidity voids.”
• Detects hidden supply/demand gaps.
• Quantifies micro-level absorption and exhaustion.
• Reveals flow compression and expansion phases.

[] Smart Money Tracking
Applies advanced volume-rate-of-change and price momentum relationships to map institutional activity.
• Accumulation Zones – Where price rises on expanding volume.
• Distribution Zones – Where price declines on rising volume.
• Automatically visualized as glowing boxes, layered through time to simulate footprint persistence.

[] Fractal Structure Mapping
Reveals the recursive nature of price formation. HMS detects fractal highs/lows, then connects them into an evolving structure.
• Defines nested market structure across multiple scales.
• Maps trend progression and transition points.
• Renders with adaptive glow lines to reflect depth and strength.

[] Volume Heat Map
Transforms historical volume data into a 3D holographic heat projection.
• Each band represents a volume-weighted price level.
• Gradient brightness = relative participation intensity.
• Helps identify volume nodes, voids, and liquidity corridors.

[] HUD Display System
Real-time analytical dashboard summarizing the system’s internal metrics directly on the chart.
• Flow, Structure, Smart$, Liquidity, and Divergence — all live.
• Designed for both scalpers and swing traders to assess micro-context instantly.

---

🧠 Smart Money Intelligence Layer
The Smart Money Index dynamically evaluates the harmony (or conflict) between price momentum and volume acceleration. When institutions accumulate or distribute discreetly, volume surges ahead of price. HMS detects this divergence and overlays it as glowing smart money zones.

[] ◈ ACCUM → Institutional absorption, early uptrend formation.
[] ◈ DISTRIB → Distribution and top-heavy conditions.
[] ○ IDLE → Neutral flow equilibrium.

Divergences between price and volume are signaled using holographic alerts (⚠ ALERT) to highlight exhaustion or trap conditions — often precursors to structural reversals.

---

🌀 Fractal Market Structure Engine
The fractal subsystem recursively identifies local pivot symmetry, connecting micro-structural highs and lows into a holographic skeleton.
• Bullish Structure — Higher highs & higher lows align (▲ BULLISH).
• Bearish Structure — Lower highs & lower lows dominate (▼ BEARISH).
• Ranging — Fractal symmetry balance (◆ RANGING).
Each transition is visually represented through adaptive glow intensity, producing a living contour of market evolution.

---

🔥 Volume Heat Map Projection
The heatmap acts as a volumetric X-ray of the recent 100–300 bars. Each horizontal segment reflects liquidity density, rendered with gradient opacity from cold (inactive) to hot (highly active).
• Detects hidden accumulation shelves and distribution ridges.
• Identifies imbalanced liquidity corridors (voids).
• Reveals the invisible scaffolding of the order book.

When combined with smart money zones and structure lines, it creates a multi-layered holographic perspective — allowing traders to see liquidity clusters and their interaction with evolving structure in real time.

---

💎 Holographic Visual Engine
Every element of HMS is dynamically color-mapped to its visual theme. Each theme carries a distinct personality:

[] Aeon — Neon blue plasma aesthetic; futuristic and fluid.
[] Cyber — High-contrast digital energy; circuit-like clarity.
[] Quantum — Deep space gradients; reflective of non-linear flow.
[] Neural — Organic transitions; biological intelligence simulation.
[] Plasma — Vapor-bright gradients; high-energy reactive feedback.
[] Crystal — Minimalist, transparent geometry; pristine data visibility.

Optional Glow Effects and Pulse Animations create a living hologram that responds to real-time market conditions.

---

🧭 HUD Analytics Table
A live data matrix placed anywhere on-screen (top, middle, or side). It summarizes five critical systems:

[] Flow: Order flow bias — ▲ BUYING / ▼ SELLING / ◆ NEUTRAL.
[] Struct: Microstructure direction — ▲ BULLISH / ▼ BEARISH / ◆ RANGING.
[] Smart$: Institutional behavior — ◈ ACCUM / ◈ DISTRIB / ○ IDLE.
[] Liquid: Market efficiency — ⚡ VOID / ● NORMAL.
[] Diverg: Price/Volume correlation — ⚠ ALERT / ✓ CLEAR.

Each metric’s color dynamically adjusts according to live readings, effectively serving as a neural HUD layer for rapid interpretation.

---

🚨 Alert Conditions
Stay informed in real time with built-in alerts that trigger under specific structural or liquidity conditions.

[] Liquidity Void Detected — Market inefficiency or thin volume region identified.
[] Strong Order Flow Detected — Aggressive buying or selling momentum shift.
[] Smart Money Activity — Institutional accumulation or distribution underway.
[] Price/Volume Divergence — Volume fails to confirm price trend.
[] Market Structure Shift — Fractal structure flips directional bias.

---

⚙️ Customization Parameters

[] Adjustable Microstructure Depth (20–200 bars).
[] Configurable Imbalance Ratio and Liquidity Threshold.
[] Adaptive Smart Money Sensitivity via Accumulation Threshold (%).
[] Multiple Fractal Depth Layers for precise structural analysis.
[] Scalable Heatmap Resolution (5–20 levels) and opacity control.
[] Selectable HUD Position to suit personal layout preferences.

Each parameter adjusts the balance between visual clarity and data density, ensuring optimal performance across intraday and macro timeframes alike.

---

🧩 Trading Application

[] Identify early signs of institutional activity before breakouts.
[] Track structure transitions with fractal precision.
[] Locate hidden liquidity voids and high-value areas.
[] Confirm strength of trends using order-flow bias.
[] Detect volume-based divergences that often precede reversals.

HMS is designed not just for observation — but for contextual understanding. Its purpose is to help traders anchor strategies in liquidity and flow dynamics rather than surface-level price action.

---

🪞 Philosophy
Markets are holographic. Each candle contains a reflection of every other candle — a fractal within a fractal, a structure within a structure. The HMS is built to reveal that reflection, allowing traders to see through the market’s multidimensional fabric.

---

Developed by: AlphaNatt
Version: v6
Category: Market Microstructure | Volume Intelligence
Framework: PineScript v6 | Holographic Visualization System
Not financial advice

---

## Source Code

````pine
//@version=6
indicator("Holographic Market Microstructure | AlphaNatt", "HMS | AlphaNatt", overlay=true, max_labels_count=500, max_lines_count=500, max_boxes_count=500)

// ══════════════════════════════════════════════════════════════════════════════
// INPUTS
// ══════════════════════════════════════════════════════════════════════════════
grpMicro            = "🔬 Microstructure Analysis"
microDepth          = input.int(50,   "Analysis Depth",         minval=20,   maxval=200, step=1,  group=grpMicro)
liquidityThreshold  = input.float(1.5,"Liquidity Threshold",    minval=1.0,  maxval=3.0,   step=0.1,group=grpMicro)
imbalanceRatio      = input.float(2.0,"Imbalance Ratio",        minval=1.5,  maxval=5.0,   step=0.1,group=grpMicro)
showLiquidityVoids  = input.bool(true,"Show Liquidity Voids",  group=grpMicro)
showOrderFlow       = input.bool(false,"Show Order Flow",       group=grpMicro)

grpSmart            = "🧠 Smart Money Tracking"
smartMoneyLength    = input.int(20,  "Smart Money Period",     minval=10,  maxval=100, group=grpSmart)
accumThreshold      = input.float(70, "Accumulation Threshold %",minval=50,  maxval=90,  group=grpSmart)
showSmartMoney      = input.bool(true,"Show Smart Money Zones",group=grpSmart)
showDivergence      = input.bool(true,"Show Price/Volume Divergence", group=grpSmart)

grpFractal          = "🌀 Fractal Structure"
fractalPeriod       = input.int(5,   "Fractal Period",         minval=3,   maxval=15, group=grpFractal)
structureDepth      = input.int(3,   "Structure Depth",        minval=1,   maxval=5,  group=grpFractal)
showFractals        = input.bool(true,"Show Fractal Levels",    group=grpFractal)
showStructure       = input.bool(true,"Show Market Structure",  group=grpFractal)

grpHeat             = "🔥 Volume Heat Map"
heatmapBars         = input.int(100, "Heat Map Bars",          minval=50,  maxval=300,group=grpHeat)
heatmapLevels       = input.int(10,  "Heat Map Levels",        minval=5,   maxval=20, group=grpHeat)
showHeatmap         = input.bool(true,"Show Volume Heat Map",   group=grpHeat)
heatmapOpacity      = input.int(95,  "Heat Map Opacity",       minval=50,  maxval=100,group=grpHeat)

grpVisual           = "💎 Holographic Visuals"
theme               = input.string("Aeon","Visual Theme", options=["Aeon", "Cyber","Quantum","Neural","Plasma","Crystal"], group=grpVisual)
glowEffect          = input.bool(true,"Enable Glow Effects",   group=grpVisual)
pulseAnimation      = input.bool(true,"Enable Pulse Animation",group=grpVisual)
showHUD             = input.bool(true,"Show HUD Display",       group=grpVisual)
hudPosition         = input.string("middle_right","HUD Position", options=["top_left","top_right","middle_left","middle_right"], group=grpVisual)
//    "Aeon"   => [#4cc9f0, #f72585, #4361ee, #7209b7, #3a0ca3]

// ══════════════════════════════════════════════════════════════════════════════
// COLOR THEMES
// ══════════════════════════════════════════════════════════════════════════════
[primary, secondary, accent, glow, dark] = switch theme
    "Aeon"   => [#4cc9f0, #f72585, #4361ee, #7209b7, #3a0ca3]
    "Cyber"   => [#00ffff, #ff00ff, #ffff00, #00ff00, #000033]
    "Quantum" => [#4169e1, #ff1493, #00ff7f, #ffa500, #000022]
    "Neural"  => [#7fff00, #ff69b4, #00ced1, #ffd700, #001122]
    "Plasma"  => [#ff00ff, #00ffff, #ff69b4, #7fff00, #110022]
    =>           [#00bfff, #ff6347, #32cd32, #ffd700, #000044]

holo1 = color.from_gradient(50, 0, 100, color.new(primary, 90), color.new(secondary, 70))
holo2 = color.from_gradient(70, 0, 100, color.new(secondary, 85), color.new(accent, 75))
holo3 = color.from_gradient(30, 0, 100, color.new(accent, 95),   color.new(glow,    80))

// ══════════════════════════════════════════════════════════════════════════════
// CALCULATIONS
// ══════════════════════════════════════════════════════════════════════════════
var float[] volumeProfile   = array.new_float(heatmapLevels, 0)
var float[] priceProfile    = array.new_float(heatmapLevels, 0)

highest     = ta.highest(high, heatmapBars)
lowest      = ta.lowest(low,   heatmapBars)
priceRange  = highest - lowest
levelHeight = priceRange / heatmapLevels

if barstate.isconfirmed
    for i = 0 to heatmapLevels - 1
        array.set(volumeProfile, i, 0)
        array.set(priceProfile,  i, lowest + (i * levelHeight) + levelHeight/2)

for j = 0 to math.min(heatmapBars - 1, bar_index)
    barPrice   = (high[j] + low[j]) / 2
    barVol     = volume[j]
    levelIndex = int((barPrice - lowest) / levelHeight)
    if levelIndex >= 0 and levelIndex < heatmapLevels
        array.set(volumeProfile, levelIndex, array.get(volumeProfile, levelIndex) + barVol)

buyVolume   = volume * (close - low)  / (high - low)
sellVolume  = volume * (high - close) / (high - low)
orderFlowImbalance = buyVolume - sellVolume
ofi            = ta.cum(orderFlowImbalance)
ofiMA          = ta.sma(ofi, smartMoneyLength)

avgRange       = ta.atr(14)
voidThreshold  = avgRange * liquidityThreshold
smaVol20       = ta.sma(volume, 20)
isLiquidityVoid= (high - low) > voidThreshold and volume < smaVol20 * 0.7

priceROC       = ta.roc(close,  smartMoneyLength)
volumeROC      = ta.roc(volume, smartMoneyLength)
smartMoneyIndex= (priceROC > 0 and volumeROC > accumThreshold) ? 1 : (priceROC < 0 and volumeROC > accumThreshold) ? -1 : 0

fractalHigh    = high[fractalPeriod] == ta.highest(high, fractalPeriod * 2 + 1)
fractalLow     = low[fractalPeriod]  == ta.lowest(low,  fractalPeriod * 2 + 1)

var float[] structureHighs     = array.new_float(structureDepth, na)
var float[] structureLows      = array.new_float(structureDepth, na)
var int[]   structureHighTimes = array.new_int(structureDepth, 0)
var int[]   structureLowTimes  = array.new_int(structureDepth, 0)

if fractalHigh
    array.shift(structureHighs)
    array.push( structureHighs,    high[fractalPeriod])
    array.shift(structureHighTimes)
    array.push( structureHighTimes, bar_index - fractalPeriod)

if fractalLow
    array.shift(structureLows)
    array.push( structureLows,     low[fractalPeriod])
    array.shift(structureLowTimes)
    array.push( structureLowTimes,  bar_index - fractalPeriod)

microTrend = 0
for i = 0 to structureDepth - 2
    if not na(array.get(structureHighs, i)) and not na(array.get(structureHighs, i+1))
        microTrend += array.get(structureHighs, i) > array.get(structureHighs, i+1) ? 1 : -1
    if not na(array.get(structureLows, i))  and not na(array.get(structureLows, i+1))
        microTrend += array.get(structureLows,  i) > array.get(structureLows,  i+1) ? 1 : -1

var bool isDivergence = false
priceTrend   = ta.linreg(close,  smartMoneyLength, 0)
volumeTrend  = ta.linreg(volume, smartMoneyLength, 0)
isDivergence := showDivergence and ((priceTrend > 0 and volumeTrend < 0) or (priceTrend < 0 and volumeTrend > 0))

// ══════════════════════════════════════════════════════════════════════════════
// VISUALIZATION
// ══════════════════════════════════════════════════════════════════════════════
if showHeatmap
    maxVolume = array.max(volumeProfile)
    for i = 0 to heatmapLevels - 1
        levelVol   = array.get(volumeProfile, i)
        levelPrice = array.get(priceProfile,  i)
        volRatio   = levelVol / maxVolume
        heatColor  = color.from_gradient(volRatio * 100, 0, 100, color.new(dark,95), color.new(glow,heatmapOpacity))
        boxWidth   = int(volRatio * 40)
        if levelVol > 0
            box.new(bar_index - boxWidth, levelPrice + levelHeight/2,bar_index,                   levelPrice - levelHeight/2,bgcolor=heatColor, border_color=color.new(primary,90))

if showLiquidityVoids and isLiquidityVoid[1]
    box.new(bar_index - 1, high[1], bar_index, low[1],bgcolor=color.new(accent,95), border_color=color.new(accent,50))
    if pulseAnimation
        box.new(bar_index - 1, high[1], bar_index, low[1],bgcolor=color.new(accent,98), border_color=color.new(accent,80))

ofiNormalized = (ofi - ofiMA) / ta.stdev(ofi - ofiMA, smartMoneyLength)

plot(showOrderFlow ? ofi   : na, "Order Flow",     color=color.new(primary,100), display=display.none)
plot(showOrderFlow ? ofiMA : na, "Order Flow MA",  color=color.new(secondary,100), display=display.none)
bgcolor(showOrderFlow ? color.new(ofiNormalized > 0 ? primary : secondary, 95 - math.abs(ofiNormalized)*10) : na)

if showSmartMoney and smartMoneyIndex != 0
    zoneColor = smartMoneyIndex == 1 ? primary : secondary
    for i = 0 to 4
        alpha = 95 - i * 5
        box.new(bar_index - smartMoneyLength + i*5, high,bar_index - smartMoneyLength + i*5 + 5, low,bgcolor=color.new(zoneColor,alpha), border_color=na)

if showStructure
    for i = 0 to structureDepth - 2
        if not na(array.get(structureHighs, i)) and not na(array.get(structureHighs, i+1))
            line.new(array.get(structureHighTimes, i),   array.get(structureHighs, i),
                     array.get(structureHighTimes, i+1), array.get(structureHighs, i+1),
                     color=color.new(primary,70), width=2, style=line.style_dashed)
            if glowEffect
                line.new(array.get(structureHighTimes, i),   array.get(structureHighs, i),
                         array.get(structureHighTimes, i+1), array.get(structureHighs, i+1),
                         color=color.new(glow,90),   width=4, style=line.style_dashed)
        if not na(array.get(structureLows, i))  and not na(array.get(structureLows, i+1))
            line.new(array.get(structureLowTimes, i),    array.get(structureLows, i),
                     array.get(structureLowTimes, i+1),  array.get(structureLows, i+1),
                     color=color.new(secondary,70), width=2, style=line.style_dashed)
            if glowEffect
                line.new(array.get(structureLowTimes, i),    array.get(structureLows, i),
                         array.get(structureLowTimes, i+1),  array.get(structureLows, i+1),
                         color=color.new(glow,90),     width=4, style=line.style_dashed)

plotshape(showFractals and fractalHigh,title="Fractal High", location=location.abovebar,color=color.new(primary,30), size=size.tiny, offset=-fractalPeriod)
plotshape(showFractals and fractalLow,title="Fractal Low",   location=location.belowbar,color=color.new(secondary,30), size=size.tiny, offset=-fractalPeriod)

if showDivergence and isDivergence
    label.new(bar_index, high, "⚠",color=color.new(accent,0), textcolor=accent,style=label.style_none, size=size.large)

// ══════════════════════════════════════════════════════════════════════════════
// HUD DISPLAY
// ══════════════════════════════════════════════════════════════════════════════
if showHUD
    hudPos = switch hudPosition
        "top_left"     => position.top_left
        "top_right"    => position.top_right
        "middle_left"  => position.middle_left
        =>               position.middle_right

    var table hud = table.new(hudPos, 2, 6)
    hudBg     = color.new(dark,90)
    hudBorder = color.new(primary,50)

    table.cell(hud, 0, 0, "MICROSTRUCTURE", bgcolor=hudBg, text_color=primary,   text_size=size.normal)

    ofiStatus = ofiNormalized > 1 ? "▲ BUYING" : ofiNormalized < -1 ? "▼ SELLING" : "◆ NEUTRAL"
    ofiCol    = ofiNormalized > 1 ? primary       : ofiNormalized < -1 ? secondary    : accent
    table.cell(hud, 0, 1, "Flow:", bgcolor=hudBg, text_color=color.gray, text_size=size.small)
    table.cell(hud, 1, 1, ofiStatus, bgcolor=hudBg, text_color=ofiCol,   text_size=size.small)

    structStatus = microTrend > 2 ? "▲ BULLISH" : microTrend < -2 ? "▼ BEARISH" : "◆ RANGING"
    structCol    = microTrend > 2 ? primary     : microTrend < -2 ? secondary    : accent
    table.cell(hud, 0, 2, "Struct:", bgcolor=hudBg, text_color=color.gray, text_size=size.small)
    table.cell(hud, 1, 2, structStatus, bgcolor=hudBg, text_color=structCol, text_size=size.small)

    smStatus = smartMoneyIndex == 1  ? "◈ ACCUM" : smartMoneyIndex == -1 ? "◈ DISTRIB" : "○ IDLE"
    smCol    = smartMoneyIndex == 1  ? primary       : smartMoneyIndex == -1 ? secondary     : color.gray
    table.cell(hud, 0, 3, "Smart$:", bgcolor=hudBg, text_color=color.gray, text_size=size.small)
    table.cell(hud, 1, 3, smStatus,  bgcolor=hudBg, text_color=smCol,    text_size=size.small)

    liqStatus = isLiquidityVoid ? "⚡ VOID" : "● NORMAL"
    table.cell(hud, 0, 4, "Liquid:", bgcolor=hudBg, text_color=color.gray, text_size=size.small)
    table.cell(hud, 1, 4, liqStatus, bgcolor=hudBg, text_color=isLiquidityVoid ? accent : color.gray, text_size=size.small)

    divStatus = isDivergence ? "⚠ ALERT" : "✓ CLEAR"
    table.cell(hud, 0, 5, "Diverg:", bgcolor=hudBg, text_color=color.gray, text_size=size.small)
    table.cell(hud, 1, 5, divStatus, bgcolor=hudBg, text_color=isDivergence ? glow : color.gray, text_size=size.small)

// ══════════════════════════════════════════════════════════════════════════════
// ALERTS
// ══════════════════════════════════════════════════════════════════════════════
alertcondition(isLiquidityVoid,                    "Liquidity Void Detected",      "HMS: Liquidity void formed")
alertcondition(math.abs(ofiNormalized) > 2,       "Strong Order Flow",            "HMS: Strong order flow detected")
alertcondition(smartMoneyIndex != 0,              "Smart Money Activity",         "HMS: Smart money accumulation/distribution")
alertcondition(isDivergence,                      "Price/Volume Divergence",      "HMS: Divergence detected")
alertcondition(microTrend > 3 or microTrend < -3, "Structure Change",             "HMS: Market structure shift")
````
