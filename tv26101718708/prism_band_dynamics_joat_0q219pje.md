# Prism Band Dynamics [JOAT]

- url: https://www.tradingview.com/script/0q219pjE-Prism-Band-Dynamics-JOAT/
- type: indicator
- pine_id: PUB;1499a70a69ec477fbca8b10a60d3f9f6
- version: 1.0

## Description

[b]Prism Band Dynamics [JOAT] - Bollinger-Style Bands with Force Detection[/b]

[b]Introduction and Purpose[/b]

Prism Band Dynamics is an open-source overlay indicator that creates dynamic Bollinger-style bands with an innovative "force detection" system. The core problem this indicator solves is that standard Bollinger Bands show volatility but don't indicate directional momentum. When all three band components (upper, lower, basis) move in the same direction, it indicates strong directional force that standard bands don't highlight.

This indicator addresses that by detecting when all band components align directionally, providing a clear signal of market force.

[b]Why Force Detection Matters[/b]

Standard Bollinger Bands expand and contract based on volatility, but they don't tell you about directional momentum. Force detection adds this dimension:

1. [b]Bullish Force[/b] - Upper band, lower band, AND basis all moving up together. This indicates strong upward momentum where even the lower support level is rising.

2. [b]Bearish Force[/b] - Upper band, lower band, AND basis all moving down together. This indicates strong downward momentum where even the upper resistance level is falling.

3. [b]Neutral[/b] - Mixed movement indicates consolidation or uncertainty.

[b]How Force Detection Works[/b]

[pine]
bool upperUp = upper > upper[1]
bool lowerUp = lower > lower[1]
bool basisUp = basis > basis[1]

int forceFull = if upperUp and lowerUp and basisUp
    1  // Bullish force
else if upperDn and lowerDn and basisDn
    -1  // Bearish force
else
    0  // Neutral
[/pine]

[b]Additional Features[/b]

[list]
[*][b]Squeeze Detection[/b] - Identifies when band width contracts below threshold, often preceding large moves
[*][b]Gradient Fills[/b] - Color intensity reflects force strength
[*][b]Direction Change Arrows[/b] - Visual markers when force direction shifts
[/list]

[b]Dashboard Information[/b]
[list]
[*][b]Force[/b] - Current force status (BULLISH/BEARISH/NEUTRAL)
[*][b]Position[/b] - Price location within bands (Upper/Mid/Lower Zone)
[*][b]Band Width[/b] - Current width percentage with expansion/contraction label
[*][b]Volatility[/b] - Squeeze status (SQUEEZE/NORMAL)
[*][b]Force Count[/b] - Bars since last force change
[/list]

[b]How to Use This Indicator[/b]

[b]For Trend Following:[/b]
1. Enter long when force turns BULLISH
2. Enter short when force turns BEARISH
3. Exit or reduce when force turns NEUTRAL

[b]For Squeeze Breakouts:[/b]
1. Watch for SQUEEZE status in dashboard
2. Prepare for breakout in either direction
3. Enter when force confirms direction after squeeze

[b]For Mean Reversion:[/b]
1. Only trade mean-reversion when force is NEUTRAL
2. Avoid fading moves when force is active
3. Use band touches as entry points during neutral force

[b]Input Parameters[/b]
[list]
[*]Length (20) - Period for basis and standard deviation
[*]Multiplier (2.0) - Standard deviation multiplier for bands
[*]MA Type (SMA) - Basis calculation method
[*]Squeeze Threshold (0.5) - Band width percentage for squeeze detection
[/list]

[b]Timeframe Recommendations[/b]
[list]
[*]4H-Daily: Cleanest force signals
[*]1H: Good balance of signals and reliability
[*]15m: More signals but more noise
[/list]

[b]Limitations[/b]
[list]
[*]Force detection can lag during rapid reversals
[*]Squeeze breakouts can fail (false breakouts)
[*]Works best in markets with clear trending/ranging phases
[/list]

[b]Open-Source and Disclaimer[/b]

This script is published as open-source under the Mozilla Public License 2.0 for educational purposes.

This indicator does not constitute financial advice. Force detection does not guarantee trend continuation. Always use proper risk management.

- Made with passion by officialjackofalltrades

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades

//@version=6
indicator("Prism Band Dynamics", shorttitle=" [JOAT]", overlay=true, max_labels_count=500)

// ══════════════════════════════════════════════════════════════════════════════
// PRISM BAND DYNAMICS - Advanced Volatility & Force Detection System
// Dynamic bands with gradient fills and directional force arrows
// ══════════════════════════════════════════════════════════════════════════════

// ─────────────────────────────────────────────────────────────────────────────
// INPUTS
// ─────────────────────────────────────────────────────────────────────────────

var grpBands = " Band Settings"
int bandLength = input.int(26, "Band Period", minval=5, maxval=100, group=grpBands)
float bandMult = input.float(2.0, "Standard Deviation", minval=0.5, maxval=5.0, step=0.1, group=grpBands)
string bandSource = input.string("Close", "Source", options=["Close", "HL2", "HLC3", "OHLC4"], group=grpBands)

var grpForce = " Force Detection"
bool showForceArrows = input.bool(true, "Show Force Arrows", group=grpForce)
bool showMiniArrows = input.bool(true, "Show Direction Change Arrows", group=grpForce)
bool showForceLabels = input.bool(false, "Show Force Labels", group=grpForce)

var grpColors = " Prism Colors"
color upperBandColor = input.color(color.new(#00BCD4, 0), "Upper Band", group=grpColors)
color lowerBandColor = input.color(color.new(#FF4081, 0), "Lower Band", group=grpColors)
color basisColor = input.color(color.new(#FFD54F, 0), "Basis Line", group=grpColors)
color bullFillColor = input.color(color.new(#00E676, 85), "Bull Cloud", group=grpColors)
color bearFillColor = input.color(color.new(#FF5252, 85), "Bear Cloud", group=grpColors)
color neutralFillColor = input.color(color.new(#9E9E9E, 90), "Neutral Cloud", group=grpColors)

// Custom blend palette for stylistic lines/fills
color bullEdgeColor = color.rgb(12, 18, 36)
color bullGlowColor = color.rgb(0, 180, 255)
color bearEdgeColor = color.rgb(40, 8, 24)
color bearGlowColor = color.rgb(255, 64, 160)
color bullBlendFill = color.new(color.rgb(16, 46, 90), 75)
color bearBlendFill = color.new(color.rgb(90, 12, 44), 75)
color neutralBlendFill = color.new(color.rgb(45, 45, 45), 85)

var grpArrows = " Arrow Colors"
color forceUpColor = input.color(color.new(#00E676, 0), "Force Up", group=grpArrows)
color forceDownColor = input.color(color.new(#FF5252, 0), "Force Down", group=grpArrows)
color miniUpColor = input.color(color.new(#FFEB3B, 0), "Mini Up", group=grpArrows)
color miniDownColor = input.color(color.new(#FF9800, 0), "Mini Down", group=grpArrows)

var grpExtras = " Extra Features"
bool showSqueeze = input.bool(true, "Show Squeeze Detection", group=grpExtras)
bool showBandWidth = input.bool(false, "Show Band Width", group=grpExtras)
float squeezeThreshold = input.float(0.05, "Squeeze Threshold %", minval=0.01, maxval=0.2, step=0.01, group=grpExtras)

// ─────────────────────────────────────────────────────────────────────────────
// SOURCE SELECTION
// ─────────────────────────────────────────────────────────────────────────────

float src = switch bandSource
    "Close" => close
    "HL2" => hl2
    "HLC3" => hlc3
    "OHLC4" => ohlc4
    => close

// ─────────────────────────────────────────────────────────────────────────────
// BAND CALCULATIONS
// ─────────────────────────────────────────────────────────────────────────────

// Core Band Components
float basis = ta.sma(src, bandLength)
float deviation = bandMult * ta.stdev(src, bandLength)
float upper = basis + deviation
float lower = basis - deviation

// Band Width Analysis
float bandWidth = (upper - lower) / basis * 100
float avgBandWidth = ta.sma(bandWidth, bandLength)
bool isSqueeze = bandWidth < avgBandWidth * squeezeThreshold * 10

// ─────────────────────────────────────────────────────────────────────────────
// FORCE DETECTION SYSTEM
// ─────────────────────────────────────────────────────────────────────────────

// Full Force: All three band components moving in same direction
bool upperUp = upper > upper[1]
bool upperDn = upper < upper[1]
bool lowerUp = lower > lower[1]
bool lowerDn = lower < lower[1]
bool basisUp = basis > basis[1]
bool basisDn = basis < basis[1]

// Force Conditions
int forceFull = if upperUp and lowerUp and basisUp
    1
else if upperDn and lowerDn and basisDn
    -1
else
    0

// Track existing force direction
var int existingForce = 0
int forceMini = 0

if forceFull != existingForce and forceFull != 0
    forceMini := forceFull
    existingForce := forceFull

// Prism State Determination
bool prismBullish = forceFull == 1
bool prismBearish = forceFull == -1
bool prismNeutral = forceFull == 0

// ─────────────────────────────────────────────────────────────────────────────
// DYNAMIC FILL COLORS
// ─────────────────────────────────────────────────────────────────────────────

color dynamicFill = prismBullish ? bullBlendFill : prismBearish ? bearBlendFill : neutralBlendFill

// Band strength gradient (based on price position)
float pricePosition = (close - lower) / (upper - lower)
color upperDynamic = pricePosition > 0.5 ? color.new(bullGlowColor, 0) : color.new(bullEdgeColor, 40)
color lowerDynamic = pricePosition < 0.5 ? color.new(bearGlowColor, 0) : color.new(bearEdgeColor, 40)

// ─────────────────────────────────────────────────────────────────────────────
// VISUALIZATION
// ─────────────────────────────────────────────────────────────────────────────

// Band Plots
p1 = plot(upper, "Prism Upper", color=upperDynamic, linewidth=2, style=plot.style_line)
p2 = plot(lower, "Prism Lower", color=lowerDynamic, linewidth=2, style=plot.style_line)
pBasis = plot(basis, "Prism Core", color=basisColor, linewidth=2, style=plot.style_line)

// Dynamic Fill
fill(p1, p2, color=dynamicFill, title="Prism Cloud")

// Force Arrows (Full)
plotarrow(showForceArrows ? forceFull : na, "Force Direction", colorup=forceUpColor, colordown=forceDownColor, maxheight=15, minheight=10)

// Mini Direction Change Arrows
plotshape(showMiniArrows and forceMini == 1 ? low : na, "Direction Up", shape.triangleup, location.belowbar, miniUpColor, size=size.tiny)
plotshape(showMiniArrows and forceMini == -1 ? high : na, "Direction Down", shape.triangledown, location.abovebar, miniDownColor, size=size.tiny)

// Squeeze Indicators
plotshape(showSqueeze and isSqueeze ? basis : na, "Squeeze", shape.diamond, location.absolute, color.new(#AB47BC, 0), size=size.tiny)

// ─────────────────────────────────────────────────────────────────────────────
// FORCE LABELS
// ─────────────────────────────────────────────────────────────────────────────

if showForceLabels and forceMini != 0
    string labelText = forceMini == 1 ? "⬆ FORCE" : "⬇ FORCE"
    color labelColor = forceMini == 1 ? forceUpColor : forceDownColor
    labelStyle = forceMini == 1 ? label.style_label_up : label.style_label_down
    label.new(bar_index, forceMini == 1 ? low : high, labelText, color=labelColor, textcolor=color.white, style=labelStyle, size=size.tiny)

// ─────────────────────────────────────────────────────────────────────────────
// INFO TABLE
// ─────────────────────────────────────────────────────────────────────────────

var table prismTable = table.new(position.top_right, 3, 6, bgcolor=color.new(#05050A, 15), border_width=2, border_color=color.new(#5E2E91, 40))

if barstate.islast
    string forceStatus = forceFull == 1 ? "BULLISH" : forceFull == -1 ? "BEARISH" : "NEUTRAL"
    string squeezeStatus = isSqueeze ? "SQUEEZE" : "NORMAL"
    color forceColor = forceFull == 1 ? forceUpColor : forceFull == -1 ? forceDownColor : color.gray
    
    string positionText = pricePosition > 0.8 ? "Upper Zone" : pricePosition < 0.2 ? "Lower Zone" : "Mid Zone"
    color posColor = pricePosition > 0.8 ? upperBandColor : pricePosition < 0.2 ? lowerBandColor : basisColor
    
    table.cell(prismTable, 0, 0, "PRISM BANDS", text_color=color.white, text_size=size.large, bgcolor=color.new(#7C4DFF, 10))
    table.cell(prismTable, 1, 0, "Value", text_color=color.white, text_size=size.small, bgcolor=color.new(#311B92, 40))
    table.cell(prismTable, 2, 0, "State", text_color=color.white, text_size=size.small, bgcolor=color.new(#311B92, 40))
    
    table.cell(prismTable, 0, 1, "Force", text_color=color.gray, text_size=size.small, bgcolor=color.new(#101021, 60))
    table.cell(prismTable, 1, 1, forceStatus, text_color=forceColor, text_size=size.normal, bgcolor=color.new(#080815, 80))
    table.cell(prismTable, 2, 1, forceFull == 1 ? "UPTREND" : forceFull == -1 ? "DOWNTREND" : "MIXED", text_color=forceColor, text_size=size.small, bgcolor=color.new(#080815, 80))
    
    table.cell(prismTable, 0, 2, "Position", text_color=color.gray, text_size=size.small, bgcolor=color.new(#0C0C19, 60))
    table.cell(prismTable, 1, 2, positionText, text_color=posColor, text_size=size.normal, bgcolor=color.new(#060612, 80))
    table.cell(prismTable, 2, 2, str.tostring(pricePosition * 100, "#.#") + "%", text_color=posColor, text_size=size.small, bgcolor=color.new(#060612, 80))
    
    table.cell(prismTable, 0, 3, "Band Width", text_color=color.gray, text_size=size.small, bgcolor=color.new(#101021, 60))
    table.cell(prismTable, 1, 3, str.tostring(bandWidth, "#.##") + "%", text_color=color.white, text_size=size.normal, bgcolor=color.new(#080815, 80))
    table.cell(prismTable, 2, 3, bandWidth > avgBandWidth ? "EXPAND" : "CALM", text_color=bandWidth > avgBandWidth ? color.new(#00E676, 0) : color.gray, text_size=size.small, bgcolor=color.new(#080815, 80))
    
    table.cell(prismTable, 0, 4, "Volatility", text_color=color.gray, text_size=size.small, bgcolor=color.new(#0C0C19, 60))
    table.cell(prismTable, 1, 4, squeezeStatus, text_color=isSqueeze ? color.orange : color.new(#00E676, 0), text_size=size.normal, bgcolor=color.new(#060612, 80))
    table.cell(prismTable, 2, 4, isSqueeze ? "TIGHT" : "FLOW", text_color=isSqueeze ? color.orange : color.new(#00E676, 0), text_size=size.small, bgcolor=color.new(#060612, 80))
    
    table.cell(prismTable, 0, 5, "Force Count", text_color=color.gray, text_size=size.small, bgcolor=color.new(#1A1A2F, 70))
    table.cell(prismTable, 1, 5, str.tostring(forceFull == 1 ? ta.barssince(forceFull != 1) : ta.barssince(forceFull != -1)), text_color=color.white, text_size=size.normal, bgcolor=color.new(#080815, 80))
    table.cell(prismTable, 2, 5, forceFull == 1 ? "BULL RUN" : forceFull == -1 ? "BEAR RUN" : "NEUTRAL", text_color=forceColor, text_size=size.small, bgcolor=color.new(#080815, 80))

// ─────────────────────────────────────────────────────────────────────────────
// ALERTS
// ─────────────────────────────────────────────────────────────────────────────

alertcondition(forceMini == 1, "Prism Bull Force", "Bullish force alignment detected!")
alertcondition(forceMini == -1, "Prism Bear Force", "Bearish force alignment detected!")
alertcondition(isSqueeze, "Prism Squeeze", "Volatility squeeze detected - breakout imminent!")
alertcondition(pricePosition > 0.95, "Upper Band Touch", "Price touching upper Prism band!")
alertcondition(pricePosition < 0.05, "Lower Band Touch", "Price touching lower Prism band!")
````
