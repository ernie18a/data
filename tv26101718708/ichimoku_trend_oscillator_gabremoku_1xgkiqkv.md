# Ichimoku Trend Oscillator [Gabremoku]

- url: https://www.tradingview.com/script/1xGkiQKv-Ichimoku-Trend-Oscillator-Gabremoku/
- type: indicator
- pine_id: PUB;a35898a0673741f5aed3f52dbe9fa33a
- version: 2.0

## Description

Ichimoku Trend Oscillator [Gabremoku] is a custom trend-following oscillator that transforms core Ichimoku components into a normalized trend force model, designed to make bullish and bearish pressure easier to read in a single lower-panel view.

Instead of plotting the full traditional Ichimoku Cloud on price, this script converts the relationship between Tenkan, Kijun, Kumo structure, and price location vs cloud into a smoothed oscillator with:

a central zero line

trend force scoring

histogram confirmation

momentum shift detection

optional Tenkan force overlay on the main chart

The Ichimoku framework is commonly used to evaluate trend, momentum, and support/resistance at a glance, especially through the relationship between price and cloud position, plus the Tenkan/Kijun structure.

What it shows
📉 Trend Force Line — the main oscillator line represents a normalized force score derived from:

Tenkan vs Kijun spread

price location relative to the cloud

bullish or bearish cloud structure

📊 Histogram — visualizes the difference between the force line and its signal line, helping show momentum acceleration or deceleration.

🌈 Soft Gradient Fill — the oscillator fill changes intensity depending on how far trend force is from zero.

📍 Tenkan Force Overlay — optionally plots the Tenkan line on the main chart with dynamic color logic tied to trend condition.

🚦 Signals — the script can display:

LONG on bullish zero-line cross

SHORT on bearish zero-line cross

SHIFT markers when momentum changes sharply without a fresh zero cross

🪧 Dashboard — displays state, force value, trend bias, Tenkan/Kijun relation, price vs Kumo position, and momentum-shift status.

Core logic
The script compresses several Ichimoku readings into one oscillator.

It combines:

Tenkan/Kijun directional spread

price above / inside / below cloud

cloud directional structure

ATR-based normalization

and smoothing for cleaner force transitions

This matters because in standard Ichimoku interpretation:

price above the cloud is usually read as bullish context

price below the cloud is usually read as bearish context

Tenkan above Kijun supports bullish alignment, while the opposite supports bearish alignment

By translating those conditions into a normalized oscillator, the script gives traders a faster way to read trend quality and directional pressure without plotting the full classic system every time.

State model
The oscillator classifies the market into states such as:

Bullish Expansion

Bullish Pressure

Bearish Expansion

Bearish Pressure

Neutral

This is useful because it separates simple directional bias from stronger “expansion” conditions where multiple Ichimoku elements are aligned.

For example:

force above zero suggests bullish pressure

force below zero suggests bearish pressure

stronger positive or negative readings reflect stronger directional alignment

SHIFT signals are used to highlight sudden changes in momentum before a full regime flip

How to use
A practical workflow is:

Use the zero line as the primary directional divider.

Use the force line to judge strength.

Use the histogram to evaluate acceleration or fading momentum.

Watch for SHIFT markers when force changes quickly.

Use the Tenkan overlay on the main chart as an additional structure guide.

In general:

cross above zero = bullish transition

cross below zero = bearish transition

force staying far from zero = stronger trend persistence

shift signals = possible early momentum change without full bias reversal yet

Features
✅ Ichimoku-based lower-panel oscillator

✅ Trend force model built from Tenkan, Kijun, Kumo, and price/cloud relationship

✅ ATR-normalized force engine

✅ Smoothed force line

✅ Signal line and histogram

✅ Soft gradient fill around zero

✅ LONG / SHORT zero-cross signals

✅ Bullish / bearish momentum shift markers

✅ Optional Tenkan force overlay on the main chart

✅ Live dashboard with state and bias information

Notes
This indicator is designed to turn Ichimoku structure into a more compact trend momentum oscillator, not to replace full discretionary Ichimoku analysis. It works best as a directional filter or timing aid when combined with price structure, support/resistance, or a broader trend framework.

Author: Gabremoku
Pine Script v6

## Source Code

````pine
//  Ichimoku Trend Oscillator [Gabremoku]
//  Oscillatore trend-following Ichimoku con force overlay Tenkan,
//  trend force normalizzata, gradient fill morbido e dashboard integrata
//  Bull = Blu | Bear = Giallo
// ═══════════════════════════════════════════════════════════════
//@version=6
indicator("Ichimoku Trend Oscillator [Gabremoku]", overlay=false, max_labels_count=500, max_lines_count=500)

// ── INPUTS ─────────────────────────────────────────────────────
grp0 = "⚙️ Core Ichimoku"
tenkanLen = input.int(9, "Tenkan Length", minval=1, group=grp0)
kijunLen  = input.int(26, "Kijun Length", minval=1, group=grp0)
senkouBLen = input.int(52, "Senkou B Length", minval=1, group=grp0)
src = input.source(close, "Source", group=grp0)

grp1 = "🎨 Colors"
bullColor    = input.color(color.rgb(33, 150, 243), "Bullish Color (Blue)", group=grp1)
bearColor    = input.color(color.rgb(241, 255, 48), "Bearish Color (Yellow)", group=grp1)
neutralColor = input.color(color.gray, "Neutral Color", group=grp1)

grp2 = "📐 Style"
showTenkanOverlay = input.bool(true, "Show Tenkan Force Overlay", group=grp2)
showForceLine     = input.bool(true, "Show Force Line", group=grp2)
showHistogram     = input.bool(true, "Show Histogram", group=grp2)
showFill          = input.bool(true, "Show Soft Gradient Fill", group=grp2)
showSignals       = input.bool(true, "Show LONG / SHORT / SHIFT Signals", group=grp2)
showDashboard     = input.bool(true, "Show Dashboard", group=grp2)


grp3 = "🌈 Force Logic"
forceSmoothLen    = input.int(5, "Force Smoothing", minval=1, group=grp3)
forceScale        = input.float(100.0, "Force Scale", minval=10.0, step=5.0, group=grp3)
neutralZone       = input.float(8.0, "Neutral Zone", minval=0.0, step=0.5, group=grp3)
fillAggressive    = input.float(2.35, "Fill Softness Curve", minval=1.0, maxval=5.0, step=0.05, group=grp3)
maxOpacityNear    = input.int(78, "Fill Opacity Near Zero", minval=0, maxval=100, group=grp3)
midOpacity        = input.int(90, "Fill Opacity Mid Zone", minval=0, maxval=100, group=grp3)
minOpacityFar     = input.int(96, "Fill Opacity Far From Zero", minval=0, maxval=100, group=grp3)

grp4 = "🚦 Signals"
useZeroCross      = input.bool(true, "Use Zero Cross Signals", group=grp4)
useShiftSignals   = input.bool(true, "Use Momentum Shift Signals", group=grp4)
shiftThreshold    = input.float(12.0, "Shift Threshold", minval=1.0, step=1.0, group=grp4)

grp5 = "🪧 Dashboard"
dashPosInput = input.string("Bottom Right", "Dashboard Position", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group=grp5)
dashTextSizeInput = input.string("Small", "Dashboard Text Size", options=["Tiny", "Small", "Normal"], group=grp5)

dashTextSize = size.small
if dashTextSizeInput == "Tiny"
    dashTextSize := size.tiny
else if dashTextSizeInput == "Normal"
    dashTextSize := size.normal

// ── DASHBOARD POSITION ────────────────────────────────────────
dashPos = position.bottom_right
if dashPosInput == "Top Right"
    dashPos := position.top_right
else if dashPosInput == "Top Left"
    dashPos := position.top_left
else if dashPosInput == "Bottom Left"
    dashPos := position.bottom_left

// ── FUNCTIONS ──────────────────────────────────────────────────
clamp(_x, _min, _max) =>
    math.max(_min, math.min(_max, _x))

donchian(_len) =>
    (ta.highest(high, _len) + ta.lowest(low, _len)) / 2.0

f_dashPos(_pos) =>
    _pos == "Top Right" ? position.top_right :
     _pos == "Top Left" ? position.top_left :
     _pos == "Bottom Left" ? position.bottom_left :
     position.bottom_right

// ── ICHIMOKU CORE ──────────────────────────────────────────────
tenkan  = donchian(tenkanLen)
kijun   = donchian(kijunLen)
senkouA = (tenkan + kijun) / 2.0
senkouB = donchian(senkouBLen)

cloudTop  = math.max(senkouA, senkouB)
cloudBot  = math.min(senkouA, senkouB)
cloudSize = math.abs(senkouA - senkouB)

priceVsCloud =
     src > cloudTop ? 1.0 :
     src < cloudBot ? -1.0 : 0.0

tkBias =
     tenkan > kijun ? 1.0 :
     tenkan < kijun ? -1.0 : 0.0

cloudBias =
     senkouA > senkouB ? 1.0 :
     senkouA < senkouB ? -1.0 : 0.0

// ── FORCE ENGINE ───────────────────────────────────────────────
atrBase = ta.atr(kijunLen)
normBase = math.max(atrBase, cloudSize, syminfo.mintick)

tkSpreadRaw = ((tenkan - kijun) / normBase) * forceScale
priceCloudRaw =
     src > cloudTop ? ((src - cloudTop) / normBase) * (forceScale * 0.45) :
     src < cloudBot ? ((src - cloudBot) / normBase) * (forceScale * 0.45) :
     0.0

cloudStructureRaw = cloudBias * ((cloudSize / normBase) * (forceScale * 0.30))

rawForce = tkSpreadRaw + priceCloudRaw + cloudStructureRaw
forcePre = clamp(rawForce, -forceScale, forceScale)
force = ta.ema(forcePre, forceSmoothLen)
forceClamped = clamp(force, -100.0, 100.0)

signalLine = ta.ema(forceClamped, math.max(2, forceSmoothLen * 2))
hist = forceClamped - signalLine
momentumShift = forceClamped - forceClamped[1]

// ── STATES ─────────────────────────────────────────────────────
state =
     forceClamped > neutralZone and priceVsCloud >= 0 and tkBias > 0 ? "Bullish Expansion" :
     forceClamped > neutralZone and tkBias > 0 ? "Bullish Pressure" :
     forceClamped < -neutralZone and priceVsCloud <= 0 and tkBias < 0 ? "Bearish Expansion" :
     forceClamped < -neutralZone and tkBias < 0 ? "Bearish Pressure" :
     "Neutral"

stateCol =
     forceClamped > neutralZone ? bullColor :
     forceClamped < -neutralZone ? bearColor :
     neutralColor

trendBiasTxt =
     tkBias > 0 and priceVsCloud >= 0 ? "Bull Bias" :
     tkBias < 0 and priceVsCloud <= 0 ? "Bear Bias" :
     "Mixed"

kumoTxt =
     priceVsCloud > 0 ? "Above Kumo" :
     priceVsCloud < 0 ? "Below Kumo" :
     "Inside Kumo"

tkTxt =
     tenkan > kijun ? "Tenkan > Kijun" :
     tenkan < kijun ? "Tenkan < Kijun" :
     "Tenkan = Kijun"

shiftTxt =
     momentumShift > shiftThreshold ? "Bull Shift" :
     momentumShift < -shiftThreshold ? "Bear Shift" :
     "Stable"

// ── COLORS ─────────────────────────────────────────────────────
forceColorRaw =
     forceClamped >= 0
     ? color.from_gradient(forceClamped, neutralZone, 100, color.new(bullColor, 35), bullColor)
     : color.from_gradient(forceClamped, -100, -neutralZone, bearColor, color.new(bearColor, 35))

forceColor = math.abs(forceClamped) <= neutralZone ? neutralColor : forceColorRaw

histColor =
     hist >= 0
     ? (hist > hist[1] ? color.new(bullColor, 28) : color.new(bullColor, 72))
     : (hist < hist[1] ? color.new(bearColor, 28) : color.new(bearColor, 72))

tenkanOverlayColor =
     tenkan > kijun and src >= tenkan ? color.new(bullColor, 0) :
     tenkan < kijun and src <= tenkan ? color.new(bearColor, 0) :
     color.new(neutralColor, 15)

distNorm = clamp(math.pow(math.abs(forceClamped) / 100.0, fillAggressive), 0.0, 1.0)

// Fill molto più delicato: vicino allo zero più visibile,
// poi si dissolve gradualmente invece di diventare pesante.
softBullA = color.new(bullColor, maxOpacityNear)
softBullB = color.new(bullColor, midOpacity)
softBullC = color.new(bullColor, minOpacityFar)

softBearA = color.new(bearColor, maxOpacityNear)
softBearB = color.new(bearColor, midOpacity)
softBearC = color.new(bearColor, minOpacityFar)

bullFillSoft = distNorm < 0.5
     ? color.from_gradient(distNorm, 0.0, 0.5, softBullA, softBullB)
     : color.from_gradient(distNorm, 0.5, 1.0, softBullB, softBullC)

bearFillSoft = distNorm < 0.5
     ? color.from_gradient(distNorm, 0.0, 0.5, softBearA, softBearB)
     : color.from_gradient(distNorm, 0.5, 1.0, softBearB, softBearC)

// ── SIGNALS ────────────────────────────────────────────────────
longSignal  = useZeroCross and ta.crossover(forceClamped, 0)
shortSignal = useZeroCross and ta.crossunder(forceClamped, 0)

bullShiftSignal = useShiftSignals and momentumShift > shiftThreshold and forceClamped > 0 and not longSignal
bearShiftSignal = useShiftSignals and momentumShift < -shiftThreshold and forceClamped < 0 and not shortSignal

// ── PLOTS OSCILLATOR ───────────────────────────────────────────
hline(0, "Zero Line", color=color.new(#666666, 55))
hline(100, "Upper Limit", color=color.new(#666666, 88))
hline(-100, "Lower Limit", color=color.new(#666666, 88))
hline(neutralZone, "Neutral Upper", color=color.new(neutralColor, 84), linestyle=hline.style_dotted)
hline(-neutralZone, "Neutral Lower", color=color.new(neutralColor, 84), linestyle=hline.style_dotted)

histPlot  = plot(showHistogram ? hist : na, "Histogram", style=plot.style_columns, color=histColor, linewidth=1)
forcePlot = plot(showForceLine ? forceClamped : na, "Trend Force", color=forceColor, linewidth=2)
zeroPlot  = plot(showFill ? 0 : na, "Zero Fill Anchor", color=color.new(color.black, 100))

fillColor = forceClamped >= 0 ? bullFillSoft : bearFillSoft
fill(forcePlot, zeroPlot, color=showFill ? fillColor : na, title="Soft Force Fill")

// ── TENKAN FORCE OVERLAY ───────────────────────────────────────
plot(showTenkanOverlay ? tenkan : na, "Tenkan Force Overlay", color=tenkanOverlayColor, linewidth=1, force_overlay=true)

// ── SIGNAL MARKERS ─────────────────────────────────────────────
plotshape(showSignals and longSignal, location=location.belowbar, title="LONG", text="LONG", style=shape.labelup, color=color.new(bullColor, 8), textcolor=color.white, size=size.tiny, force_overlay=true)
plotshape(showSignals and shortSignal, location=location.abovebar, title="SHORT", text="SHORT", style=shape.labeldown, color=color.new(bearColor, 8), textcolor=color.black, size=size.tiny, force_overlay=true)
plotshape(showSignals and bullShiftSignal, title="SHIFT UP", text="SHIFT", style=shape.circle, location=location.bottom, color=color.new(bullColor, 12), size=size.tiny)
plotshape(showSignals and bearShiftSignal, title="SHIFT DOWN", text="SHIFT", style=shape.circle, location=location.top, color=color.new(bearColor, 12), size=size.tiny)

// ── DASHBOARD ──────────────────────────────────────────────────
var table dash = table.new(dashPos, 2, 6, border_width=1)

if barstate.isfirst
    dash := table.new(dashPos, 2, 6, border_width=1)

if barstate.islast and showDashboard
    table.cell(dash, 0, 0, "State", text_color=chart.fg_color, text_halign=text.align_left, text_size=dashTextSize)
    table.cell(dash, 1, 0, state, text_color=stateCol, text_halign=text.align_center, text_size=dashTextSize)

    table.cell(dash, 0, 1, "Force", text_color=chart.fg_color, text_halign=text.align_left, text_size=dashTextSize)
    table.cell(dash, 1, 1, str.tostring(forceClamped, "#.0"), text_color=forceColor, text_halign=text.align_center, text_size=dashTextSize)

    table.cell(dash, 0, 2, "Trend Bias", text_color=chart.fg_color, text_halign=text.align_left, text_size=dashTextSize)
    table.cell(dash, 1, 2, trendBiasTxt, text_color=chart.fg_color, text_halign=text.align_center, text_size=dashTextSize)

    table.cell(dash, 0, 3, "Tenkan/Kijun", text_color=chart.fg_color, text_halign=text.align_left, text_size=dashTextSize)
    table.cell(dash, 1, 3, tkTxt, text_color=tenkan > kijun ? bullColor : tenkan < kijun ? bearColor : neutralColor, text_halign=text.align_center, text_size=dashTextSize)

    table.cell(dash, 0, 4, "Price/Kumo", text_color=chart.fg_color, text_halign=text.align_left, text_size=dashTextSize)
    table.cell(dash, 1, 4, kumoTxt, text_color=priceVsCloud > 0 ? bullColor : priceVsCloud < 0 ? bearColor : neutralColor, text_halign=text.align_center, text_size=dashTextSize)

    table.cell(dash, 0, 5, "Momentum Shift", text_color=chart.fg_color, text_halign=text.align_left, text_size=dashTextSize)
    table.cell(dash, 1, 5, shiftTxt, text_color=momentumShift > shiftThreshold ? bullColor : momentumShift < -shiftThreshold ? bearColor : neutralColor, text_halign=text.align_center, text_size=dashTextSize)

if barstate.islast and not showDashboard
    table.clear(dash, 0, 0, 1, 5)

// ── ALERTS ─────────────────────────────────────────────────────
alertcondition(longSignal, title="LONG Signal", message="Ichimoku Trend Plus [Gabremoku] LONG signal")
alertcondition(shortSignal, title="SHORT Signal", message="Ichimoku Trend Plus [Gabremoku] SHORT signal")
alertcondition(bullShiftSignal, title="Bullish Shift", message="Ichimoku Trend Plus [Gabremoku] bullish momentum shift")
alertcondition(bearShiftSignal, title="Bearish Shift", message="Ichimoku Trend Plus [Gabremoku] bearish momentum shift")
````
