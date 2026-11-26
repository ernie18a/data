# Bollinger Bands Gradient [Gabremoku]

- url: https://www.tradingview.com/script/R8aACAgt-Bollinger-Bands-Gradient-Gabremoku/
- type: indicator
- pine_id: PUB;9d6a116add504cffb915e49d0a6569b8
- version: 2.0

## Description

Bollinger Bands Gradient [Gabremoku] is an enhanced Bollinger Band overlay designed to turn classic volatility bands into a richer visual and signal-based trading framework.

The indicator keeps the core structure of Bollinger Bands — Upper Band, Basis, and Lower Band — but adds a dynamic gradient fill, squeeze detection, state-based bar coloring, strategy-side signal logic, and an optional dashboard for fast chart interpretation. Bollinger Bands are widely used to read volatility compression, expansion, and breakout behavior, especially when traders want more context than a standard three-line display can offer.

This script is built for traders who want Bollinger Bands to feel more alive: clearer transitions, better volatility awareness, and cleaner breakout mapping directly on price.

What it shows
🌈 Dynamic Gradient Fill — the area between Upper/Basis and Basis/Lower is filled with adaptive color intensity that changes according to price distance from the basis.

🗜️ Squeeze Detection — the script monitors Bollinger Band compression and flags low-volatility states when band width contracts relative to its recent range. Bollinger squeezes are commonly used to identify volatility contraction before a possible breakout.

🎨 State-Based Coloring — basis line, bands, bars, and optional background can all shift visually depending on whether the market is bullish, bearish, neutral, or in squeeze mode.

📍 Breakout Signals — optional labels for:

BUY / SELL in Long mode

SHORT / CLOSE in Short mode

🪧 Dashboard — a compact panel showing current state, strategy mode, sequence status, band width, range position, and squeeze condition.

🏷️ Last Value Labels — optional live labels for Upper, Basis, and Lower band values.

Core logic
This script combines volatility structure and signal sequence control.

At the core, Bollinger Bands define the dynamic range around a moving average using standard deviation, which helps visualize whether price is relatively stretched or compressed versus its recent behavior. Narrow bands usually reflect low volatility, while wide bands reflect expansion.

On top of that, this version introduces:

a basis color gradient tied to price position inside the band structure,

a fill intensity model tied to distance from the basis,

and a state machine that prevents repeated entry signals in the same sequence.

That makes the indicator more structured than a plain breakout marker, especially for traders who want cleaner signal flow.

Signal logic
The indicator supports two operating modes:

Long Mode

BUY = breakout above the Upper Band

SELL = breakdown below the Lower Band

Short Mode

SHORT = breakdown below the Lower Band

CLOSE = breakout above the Upper Band

This logic reflects one of the most common ways traders use Bollinger Bands: watching for volatility compression, then responding to expansion outside the bands. At the same time, Bollinger-based strategies can also be used for mean reversion, which is why breakout signals generally work best when confirmed by price structure, momentum, or volume.

Features
✅ Classic Bollinger Bands with selectable basis type

✅ Dynamic gradient fill above and below the basis

✅ Adaptive basis coloring based on price position

✅ Squeeze detection using band-width normalization

✅ Optional squeeze background highlighting

✅ Optional bar coloring by state

✅ Strategy-side selector: Long or Short

✅ Breakout signal state machine

✅ BUY / SELL / SHORT / CLOSE labels

✅ On-chart dashboard

✅ Optional last-value labels

✅ Fully customizable colors and style inputs

How to use
A practical reading flow is:

Watch for band contraction and squeeze conditions.

Treat that as a volatility compression phase.

Monitor for price expansion outside the bands.

Use the selected strategy mode to interpret the resulting signal sequence.

In practice:

tight bands + squeeze on = market compression

break above upper band = bullish expansion candidate

break below lower band = bearish expansion candidate

That said, Bollinger breakouts can fail in choppy environments, so many traders confirm them with momentum, volume, or higher timeframe structure rather than using them in isolation.

Notes
This indicator is designed as an enhanced Bollinger workflow tool, not as a complete trading system with full risk management. Bollinger Bands can support both breakout and mean-reversion approaches, so the best interpretation depends on market regime and confirmation methods.

Author: Gabremoku
Pine Script v6

## Source Code

````pine
//@version=6
//Bollinger Bands Gradient [Gabremoku]

//What it does / what it’s for:
//- Plots Bollinger Bands (Upper, Basis, Lower) and fills the space between the bands with a dynamic gradient.
//- The fill intensity adapts to the distance from the Basis and reacts to “Squeeze” conditions (band-width compression).
//- Adds optional squeeze background shading, bar coloring, and breakout signals (BUY/SELL/SHORT/CLOSE).
//- Includes a dashboard showing current state/mode/sequence/squeeze status and optional last-value labels.

//Integrated features:
//- Dynamic gradient fill between Upper/Basis and Basis/Lower
//- Squeeze detection (band-width percentile threshold)
//- Optional squeeze background highlighting
//- Optional bar coloring (squeeze + breakout/bull/bear states)
//- Signal state machine with selectable Strategy Side (Long/Short)
//- Optional BUY/SELL/SHORT/CLOSE plotshapes
//- Optional on-chart dashboard (last bar)
//- Optional last value labels for Upper/Basis/Lower

indicator("Bollinger Bands Gradient [Gabremoku]", overlay=true, max_labels_count=500)


// ═══════════════════════════════════════════════════════════════
//  Bollinger Bands Gradient [Gabremoku]
//  Dynamic gradient fill + squeeze coloring + breakout signals
//  Bull = Blue | Bear = Yellow
// ═══════════════════════════════════════════════════════════════


// ── INPUTS ─────────────────────────────────────────────────────
grp6 = "🧭 Strategy Mode"
strategySide = input.string("Long", "Strategy Side", options=["Long", "Short"], group=grp6)

grp0 = "⚙️ Core"
length   = input.int(20, "BB Length", group=grp0, minval=1)
mult     = input.float(2.0, "StdDev Multiplier", group=grp0, minval=0.1, step=0.1)
src      = input.source(close, "Source", group=grp0)
maType   = input.string("SMA", "Basis Type", options=["SMA", "EMA", "RMA", "WMA", "VWMA"], group=grp0)

grp1 = "🎨 Colors"
bullColor    = input.color(color.rgb(33, 150, 243), "Bullish Color (Blue)", group=grp1)
bearColor    = input.color(color.rgb(241, 255, 48), "Bearish Color (Yellow)", group=grp1)
squeezeColor = input.color(color.rgb(156, 39, 176), "Squeeze Color", group=grp1)
neutralColor = input.color(color.gray, "Neutral Basis Color", group=grp1)

grp2 = "📐 Style"
showBasis      = input.bool(true, "Show Basis", group=grp2)
showBandLines  = input.bool(true, "Show Upper/Lower Bands", group=grp2)
showBarColors  = input.bool(true, "Color Bars", group=grp2)
showSignals    = input.bool(true, "Show Signals", group=grp2)
showLabels     = input.bool(true, "Show Last Value Labels", group=grp2)
basisWidth     = input.int(2, "Basis Width", group=grp2, minval=1, maxval=5)
bandsWidth     = input.int(1, "Band Width", group=grp2, minval=1, maxval=5)

grp3 = "🌈 Gradient Logic"
neutralZonePct = input.float(0.10, "Neutral Zone %", group=grp3, minval=0.0, maxval=1.0, step=0.01)
fillAggressive = input.float(1.60, "Fill Aggressiveness", group=grp3, minval=0.5, maxval=4.0, step=0.1)
maxOpacityNear = input.int(92, "Fill Opacity Near Basis", group=grp3, minval=0, maxval=100)
minOpacityFar  = input.int(20, "Fill Opacity Far From Basis", group=grp3, minval=0, maxval=100)

grp4 = "🗜️ Squeeze"
sqzLookback    = input.int(100, "Squeeze Lookback", group=grp4, minval=10)
sqzThreshold   = input.float(0.15, "Squeeze Threshold Percentile", group=grp4, minval=0.01, maxval=0.50, step=0.01)
highlightSqzBg = input.bool(false, "Highlight Squeeze Background", group=grp4)

grp5 = "🪧 Dashboard"
showDashboard = input.bool(true, "Show Dashboard", group=grp5)



// ── FUNCTIONS ──────────────────────────────────────────────────
ma(_src, _len, _type) =>
    switch _type
        "SMA"  => ta.sma(_src, _len)
        "EMA"  => ta.ema(_src, _len)
        "RMA"  => ta.rma(_src, _len)
        "WMA"  => ta.wma(_src, _len)
        "VWMA" => ta.vwma(_src, _len)

clamp(_x, _min, _max) =>
    math.max(_min, math.min(_max, _x))


// ── BOLLINGER BANDS ────────────────────────────────────────────
basis = ma(src, length, maType)
dev   = ta.stdev(src, length) * mult
upper = basis + dev
lower = basis - dev

bandWidthAbs = upper - lower
bandWidthPct = basis != 0 ? (bandWidthAbs / basis) * 100 : 0.0

halfBand = dev
bbPos = halfBand != 0 ? (src - basis) / halfBand : 0.0
bbPosClamped = clamp(bbPos, -2.0, 2.0)


// ── SQUEEZE LOGIC ──────────────────────────────────────────────
widthMin  = ta.lowest(bandWidthAbs, sqzLookback)
widthMax  = ta.highest(bandWidthAbs, sqzLookback)
widthNorm = widthMax != widthMin ? (bandWidthAbs - widthMin) / (widthMax - widthMin) : 0.0
isSqueeze = widthNorm <= sqzThreshold


// ── STATE ──────────────────────────────────────────────────────
state =
     src > upper ? "Bull Breakout" :
     src < lower ? "Bear Breakout" :
     src > basis ? "Bullish" :
     src < basis ? "Bearish" : "Neutral"

stateCol =
     src > upper ? bullColor :
     src < lower ? bearColor :
     src > basis ? color.new(bullColor, 0) :
     src < basis ? color.new(bearColor, 0) : neutralColor


// ── BASIS COLOR GRADIENT ───────────────────────────────────────
neutralHi = neutralZonePct
neutralLo = -neutralZonePct

basisColorRaw =
     bbPosClamped >= 0
     ? color.from_gradient(bbPosClamped, neutralHi, 1.0, neutralColor, bullColor)
     : color.from_gradient(bbPosClamped, -1.0, neutralLo, bearColor, neutralColor)

basisColor =
     isSqueeze ? squeezeColor :
     math.abs(bbPosClamped) <= neutralZonePct ? neutralColor :
     basisColorRaw


// ── BAND COLORS ────────────────────────────────────────────────
upperColor =
     isSqueeze ? color.new(squeezeColor, 5) :
     color.from_gradient(clamp(widthNorm, 0.0, 1.0), 0.0, 1.0, color.new(bullColor, 75), color.new(bullColor, 0))

lowerColor =
     isSqueeze ? color.new(squeezeColor, 5) :
     color.from_gradient(clamp(widthNorm, 0.0, 1.0), 0.0, 1.0, color.new(bearColor, 75), color.new(bearColor, 0))


// ── AGGRESSIVE FILL BY DISTANCE FROM BASIS ─────────────────────
distRaw  = math.abs(bbPosClamped)
distNorm = clamp(math.pow(clamp(distRaw, 0.0, 1.5) / 1.5, fillAggressive), 0.0, 1.0)

bullNear = color.new(bullColor, maxOpacityNear)
bullFar  = color.new(bullColor, minOpacityFar)
bearNear = color.new(bearColor, maxOpacityNear)
bearFar  = color.new(bearColor, minOpacityFar)

bullFillTop    = color.from_gradient(distNorm, 0.0, 1.0, bullNear, bullFar)
bullFillBottom = color.new(color.black, 100)

bearFillTop    = color.new(color.black, 100)
bearFillBottom = color.from_gradient(distNorm, 0.0, 1.0, bearNear, bearFar)


// ── RAW BREAKOUT CONDITIONS ────────────────────────────────────
// Long:
// - BUY   = breakout sopra upper
// - SELL  = breakdown sotto lower
//
// Short:
// - SHORT = breakdown sotto lower
// - CLOSE = breakout sopra upper

rawLongEntry  = ta.crossover(src, upper)
rawLongExit   = ta.crossunder(src, lower)

rawShortEntry = ta.crossunder(src, lower)
rawShortExit  = ta.crossover(src, upper)


// ── SIGNAL STATE MACHINE ───────────────────────────────────────
var bool inLongSequence  = false
var bool inShortSequence = false

longEntrySignal  = false
longExitSignal   = false
shortEntrySignal = false
shortExitSignal  = false

if strategySide == "Long"
    longEntrySignal := rawLongEntry and not inLongSequence
    longExitSignal  := rawLongExit and inLongSequence

    if longEntrySignal
        inLongSequence := true
    if longExitSignal
        inLongSequence := false

    inShortSequence := false

if strategySide == "Short"
    shortEntrySignal := rawShortEntry and not inShortSequence
    shortExitSignal  := rawShortExit and inShortSequence

    if shortEntrySignal
        inShortSequence := true
    if shortExitSignal
        inShortSequence := false

    inLongSequence := false


// ── PLOTS ──────────────────────────────────────────────────────
basisPlot = plot(showBasis ? basis : na, "Basis", color=basisColor, linewidth=basisWidth)
upperPlot = plot(showBandLines ? upper : na, "Upper Band", color=upperColor, linewidth=bandsWidth)
lowerPlot = plot(showBandLines ? lower : na, "Lower Band", color=lowerColor, linewidth=bandsWidth)

fill(upperPlot, basisPlot, upper, basis, bullFillTop, bullFillBottom)
fill(basisPlot, lowerPlot, basis, lower, bearFillTop, bearFillBottom)

bgcolor(highlightSqzBg and isSqueeze ? color.new(squeezeColor, 90) : na, title="Squeeze Background")

barcolor(
     showBarColors ?
     isSqueeze ? color.new(squeezeColor, 40) :
     src > upper ? color.new(bullColor, 0) :
     src < lower ? color.new(bearColor, 0) :
     src > basis ? color.new(bullColor, 65) :
     src < basis ? color.new(bearColor, 65) : na
     : na)


// ── SIGNALS ────────────────────────────────────────────────────
plotshape(showSignals and longEntrySignal, title="BUY", text="BUY", style=shape.labelup,
     location=location.belowbar, color=bullColor, textcolor=color.white, size=size.small)

plotshape(showSignals and longExitSignal, title="SELL", text="SELL", style=shape.labeldown,
     location=location.abovebar, color=bearColor, textcolor=color.black, size=size.small)

plotshape(showSignals and shortEntrySignal, title="SHORT", text="SHORT", style=shape.labeldown,
     location=location.abovebar, color=bearColor, textcolor=color.black, size=size.small)

plotshape(showSignals and shortExitSignal, title="CLOSE", text="CLOSE", style=shape.labelup,
     location=location.belowbar, color=bullColor, textcolor=color.white, size=size.small)


// ── DASHBOARD ──────────────────────────────────────────────────
rangePos = bandWidthAbs != 0 ? (src - lower) / bandWidthAbs : 0.5
pressure = distNorm
sqzState = isSqueeze ? "ON" : "OFF"

seqState = strategySide == "Long"
     ? (inLongSequence ? "Long Active" : "Flat / Ready BUY")
     : (inShortSequence ? "Short Active" : "Flat / Ready SHORT")

var table dash = table.new(position.bottom_right, 2, 6, border_width=1)

if barstate.islast and showDashboard
    table.cell(dash, 0, 0, "State", text_color=chart.fg_color, text_halign=text.align_left)
    table.cell(dash, 1, 0, state, text_color=stateCol, text_halign=text.align_center)

    table.cell(dash, 0, 1, "Mode", text_color=chart.fg_color, text_halign=text.align_left)
    table.cell(dash, 1, 1, strategySide, text_color=chart.fg_color, text_halign=text.align_center)

    table.cell(dash, 0, 2, "Sequence", text_color=chart.fg_color, text_halign=text.align_left)
    table.cell(dash, 1, 2, seqState, text_color=chart.fg_color, text_halign=text.align_center)

    table.cell(dash, 0, 3, "Band Width", text_color=chart.fg_color, text_halign=text.align_left)
    table.cell(dash, 1, 3, str.tostring(bandWidthPct, "#.##") + "%", text_color=chart.fg_color, text_halign=text.align_center)

    table.cell(dash, 0, 4, "Range Pos", text_color=chart.fg_color, text_halign=text.align_left)
    table.cell(dash, 1, 4, str.tostring(rangePos * 100, "#") + "%", text_color=chart.fg_color, text_halign=text.align_center)

    table.cell(dash, 0, 5, "Squeeze", text_color=chart.fg_color, text_halign=text.align_left)
    table.cell(dash, 1, 5, sqzState, text_color=isSqueeze ? squeezeColor : chart.fg_color, text_halign=text.align_center)


// ── LAST VALUE LABELS ──────────────────────────────────────────
if barstate.islast and showLabels
    label.delete(label.new(
         bar_index, upper,
         "◀ Upper: " + str.tostring(upper, format.mintick),
         color=color.new(color.black, 100),
         textcolor=upperColor,
         force_overlay=true,
         style=label.style_label_left
     )[1])

    label.delete(label.new(
         bar_index, basis,
         "◀ Basis: " + str.tostring(basis, format.mintick),
         color=color.new(color.black, 100),
         textcolor=basisColor,
         force_overlay=true,
         style=label.style_label_left
     )[1])

    label.delete(label.new(
         bar_index, lower,
         "◀ Lower: " + str.tostring(lower, format.mintick),
         color=color.new(color.black, 100),
         textcolor=lowerColor,
         force_overlay=true,
         style=label.style_label_left
     )[1])
````
