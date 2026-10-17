# Ichimoku Adaptive [Gabremoku]

- url: https://www.tradingview.com/script/22z6Gtpy-Ichimoku-Adaptive-Gabremoku/
- type: indicator
- pine_id: PUB;09ae2ea3e13348c1a55c350d46fb5c34
- version: 1.0

## Description

Ichimoku Adaptive [Gabremoku] is a full Ichimoku Cloud framework that combines the traditional Classic settings with an optional Adaptive mode that automatically scales the core Ichimoku periods according to market volatility.

The script keeps the original logic of the Ichimoku system — Tenkan, Kijun, Senkou Span A, Senkou Span B, Chikou, and Kumo structure — while adding a volatility-based adjustment engine that can make the framework more reactive or more stable depending on current conditions. The classical Ichimoku model is designed to show trend direction, momentum, and dynamic support/resistance in a single view.

What it shows
☁️ Full Ichimoku structure — Tenkan-sen, Kijun-sen, Senkou Span A, Senkou Span B, optional Chikou Span, and forward Kumo projection.

🧠 Classic or Adaptive mode — use standard Ichimoku parameters or let the indicator adjust its internal lengths according to ATR-based volatility behavior. Adaptive indicators are commonly designed to become more responsive or more conservative depending on changing volatility conditions.

🌈 Dynamic Kumo gradient — the cloud color and fill intensity vary based on bullish/bearish structure and cloud thickness.

🏷️ TK Cross signals — optional LONG and SHORT labels appear when Tenkan crosses above or below Kijun. Tenkan/Kijun crosses are widely used as Ichimoku signals and are often considered stronger when aligned with price position relative to the cloud.

🪧 Dashboard — displays mode, trend state, price vs Kumo location, Tenkan/Kijun relationship, active parameters, and ATR percentage.

📍 Last value labels — optional labels for Tenkan, Kijun, Span A, and Span B.

Core logic
This script is built around the classic Ichimoku reading process:

price vs cloud

Tenkan vs Kijun

future cloud structure

optional Chikou confirmation

In standard Ichimoku interpretation:

price above the cloud suggests bullish structure

price below the cloud suggests bearish structure

price inside the cloud suggests transition or indecision

This indicator keeps that framework intact, then extends it with an adaptive period engine.

Adaptive mode
In Classic mode, the script uses the traditional fixed settings:

Tenkan

Kijun

Senkou B

displacement

In Adaptive mode, those core lengths are scaled according to an ATR-based volatility ratio.

The idea is straightforward:

when volatility changes, fixed settings may become less efficient

adaptive scaling can make the Ichimoku framework more flexible across different environments

higher or changing volatility can justify a different sensitivity profile than calm market conditions

This does not replace classic Ichimoku logic — it simply changes the speed of the framework while keeping the same structural interpretation.

How to read it
A practical reading sequence is:

Check whether price is above, below, or inside the cloud.

Check whether Tenkan is above or below Kijun.

Observe whether the cloud is bullish or bearish.

Use TK crosses as triggers only after checking context.

In Adaptive mode, monitor how the active parameters shift as volatility changes.

In general:

Above Kumo + Tenkan > Kijun supports bullish trend logic.

Below Kumo + Tenkan < Kijun supports bearish trend logic.

Inside Kumo usually suggests weaker trend clarity or transition.

Features
✅ Full Ichimoku Cloud framework

✅ Classic fixed-parameter mode

✅ Adaptive ATR-based mode

✅ Configurable Tenkan / Kijun / Senkou B / displacement

✅ Dynamic Kumo gradient visualization

✅ Optional Tenkan, Kijun, Senkou A, Senkou B, and Chikou display

✅ TK cross signal labels

✅ Dashboard with live state information

✅ Last-value labels for key lines

✅ Built-in alert conditions for bullish and bearish TK crosses

Notes
This indicator is best used as a context and structure tool, not just as a crossover script. Ichimoku signals are generally stronger when multiple elements align, especially price position relative to the cloud, Tenkan/Kijun direction, and overall Kumo structure.

Author: Gabremoku
Pine Script v6

## Source Code

````pine

//  Ichimoku Adaptive Classic [Gabremoku]
//  Classic Ichimoku framework with standard and adaptive modes
//  Bull = Blue | Bear = Bright Yellow
// ═══════════════════════════════════════════════════════════════
//@version=6
indicator("Ichimoku Adaptive [Gabremoku]", overlay=true, max_labels_count=500)

// ── INPUTS ─────────────────────────────────────────────────────
grp0 = "⚙️ Core"
mode = input.string("Classic", "Mode", options=["Classic", "Adaptive"], group=grp0)
src  = input.source(close, "Source", group=grp0)

classicTenkan  = input.int(9,  "Classic Tenkan", minval=1, group=grp0)
classicKijun   = input.int(26, "Classic Kijun", minval=1, group=grp0)
classicSenkouB = input.int(52, "Classic Senkou B", minval=1, group=grp0)
displacement   = input.int(26, "Displacement", minval=1, group=grp0)

grp1 = "🧠 Adaptive Logic"
atrLen         = input.int(14, "ATR Length", minval=1, group=grp1)
adaptiveFactor = input.float(1.0, "Adaptive Intensity", minval=0.2, maxval=3.0, step=0.1, group=grp1)
minScale       = input.float(0.80, "Min Adaptive Scale", minval=0.5, maxval=1.0, step=0.01, group=grp1)
maxScale       = input.float(1.35, "Max Adaptive Scale", minval=1.0, maxval=2.0, step=0.01, group=grp1)

grp2 = "🎨 Colors"
bullColor      = input.color(color.rgb(33, 150, 243), "Bullish Color (Blue)", group=grp2)
bearColor      = input.color(color.rgb(255, 242, 0), "Bearish Color (Bright Yellow)", group=grp2)
neutralColor   = input.color(color.gray, "Neutral Color", group=grp2)
tenkanColor    = input.color(color.rgb(255, 255, 255), "Tenkan Color", group=grp2)
kijunColor     = input.color(color.rgb(255, 170, 0), "Kijun Color", group=grp2)
chikouColor    = input.color(color.rgb(180, 180, 180), "Chikou Color", group=grp2)

grp3 = "📐 Style"
showTenkan     = input.bool(true, "Show Tenkan", group=grp3)
showKijun      = input.bool(true, "Show Kijun", group=grp3)
showCloud      = input.bool(true, "Show Kumo", group=grp3)
showSenkouA    = input.bool(true, "Show Senkou A", group=grp3)
showSenkouB    = input.bool(true, "Show Senkou B", group=grp3)
showChikou     = input.bool(false, "Show Chikou", group=grp3)
showSignals    = input.bool(true, "Show TK Cross Signals", group=grp3)
showDashboard  = input.bool(true, "Show Dashboard", group=grp3)
showLabels     = input.bool(true, "Show Last Value Labels", group=grp3)
showSiteRef    = input.bool(true, "Show Site Ref", group=grp3)

grp4 = "🌈 Kumo Gradient"
gradientStrength = input.float(1.55, "Gradient Strength", minval=0.5, maxval=4.0, step=0.05, group=grp4)
maxOpacityNear   = input.int(84, "Opacity Near Kumo Edge", minval=0, maxval=100, group=grp4)
midOpacity       = input.int(90, "Opacity Mid Kumo", minval=0, maxval=100, group=grp4)
minOpacityFar    = input.int(95, "Opacity Far Kumo", minval=0, maxval=100, group=grp4)

grp5 = "📊 Dashboard"
dashPosition = input.string("Top Right", "Dashboard Position", options=["Top Right", "Bottom Right", "Top Left", "Bottom Left"], group=grp5)

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

// ── ADAPTIVE ENGINE ────────────────────────────────────────────
atrPct = close != 0 ? (ta.atr(atrLen) / close) * 100.0 : 0.0
atrBase = ta.sma(atrPct, 100)
volRatioRaw = atrBase != 0 ? atrPct / atrBase : 1.0
volRatio = clamp(volRatioRaw, 0.50, 1.80)

adaptiveScaleRaw = 1.0 + ((volRatio - 1.0) * 0.60 * adaptiveFactor)
adaptiveScale = clamp(adaptiveScaleRaw, minScale, maxScale)

tenkanLen  = mode == "Classic" ? classicTenkan  : math.max(2, int(math.round(classicTenkan * adaptiveScale)))
kijunLen   = mode == "Classic" ? classicKijun   : math.max(2, int(math.round(classicKijun * adaptiveScale)))
senkouBLen = mode == "Classic" ? classicSenkouB : math.max(2, int(math.round(classicSenkouB * adaptiveScale)))

// ── ICHIMOKU CORE ──────────────────────────────────────────────
tenkan  = donchian(tenkanLen)
kijun   = donchian(kijunLen)
senkouA = (tenkan + kijun) / 2.0
senkouB = donchian(senkouBLen)
chikou  = close

cloudTop = math.max(senkouA, senkouB)
cloudBot = math.min(senkouA, senkouB)
cloudThickness = math.abs(senkouA - senkouB)
thicknessBase = ta.highest(cloudThickness, 200)
thicknessNorm = thicknessBase != 0 ? clamp(math.pow(cloudThickness / thicknessBase, gradientStrength), 0.0, 1.0) : 0.0

priceVsKumo =
     close > cloudTop ? "Above Kumo" :
     close < cloudBot ? "Below Kumo" :
     "Inside Kumo"

tkState =
     tenkan > kijun ? "Tenkan > Kijun" :
     tenkan < kijun ? "Tenkan < Kijun" :
     "Tenkan = Kijun"

trendState =
     close > cloudTop and tenkan > kijun ? "Bullish Trend" :
     close < cloudBot and tenkan < kijun ? "Bearish Trend" :
     "Neutral / Transition"

stateColor =
     trendState == "Bullish Trend" ? bullColor :
     trendState == "Bearish Trend" ? bearColor :
     neutralColor

// ── DYNAMIC COLORS ─────────────────────────────────────────────
spanAColor =
     senkouA >= senkouB
     ? color.from_gradient(thicknessNorm, 0.0, 1.0, color.new(bullColor, 25), color.new(bullColor, 0))
     : color.from_gradient(thicknessNorm, 0.0, 1.0, color.new(bullColor, 55), color.new(bullColor, 20))

spanBColor =
     senkouA < senkouB
     ? color.from_gradient(thicknessNorm, 0.0, 1.0, color.new(bearColor, 12), color.new(bearColor, 0))
     : color.from_gradient(thicknessNorm, 0.0, 1.0, color.new(bearColor, 45), color.new(bearColor, 12))

bullNear = color.new(bullColor, maxOpacityNear)
bullMid  = color.new(bullColor, midOpacity)
bullFar  = color.new(bullColor, minOpacityFar)

bearNear = color.new(bearColor, maxOpacityNear)
bearMid  = color.new(bearColor, midOpacity)
bearFar  = color.new(bearColor, minOpacityFar)

bullKumoFill =
     thicknessNorm < 0.5
     ? color.from_gradient(thicknessNorm, 0.0, 0.5, bullNear, bullMid)
     : color.from_gradient(thicknessNorm, 0.5, 1.0, bullMid, bullFar)

bearKumoFill =
     thicknessNorm < 0.5
     ? color.from_gradient(thicknessNorm, 0.0, 0.5, bearNear, bearMid)
     : color.from_gradient(thicknessNorm, 0.5, 1.0, bearMid, bearFar)

kumoFillColor = senkouA >= senkouB ? bullKumoFill : bearKumoFill

// ── PLOTS ──────────────────────────────────────────────────────
tenkanPlot = plot(showTenkan ? tenkan : na, "Tenkan", color=tenkanColor, linewidth=2)
kijunPlot  = plot(showKijun ? kijun : na, "Kijun", color=kijunColor, linewidth=2)

senkouAPlot = plot(showSenkouA ? senkouA : na, "Senkou A", color=spanAColor, linewidth=1, offset=displacement)
senkouBPlot = plot(showSenkouB ? senkouB : na, "Senkou B", color=spanBColor, linewidth=1, offset=displacement)

fill(senkouAPlot, senkouBPlot, color=showCloud ? kumoFillColor : na, title="Kumo Gradient Fill")

plot(showChikou ? chikou : na, "Chikou Span", color=chikouColor, linewidth=1, offset=-displacement)

// ── SIGNALS ────────────────────────────────────────────────────
bullTkCross = ta.crossover(tenkan, kijun)
bearTkCross = ta.crossunder(tenkan, kijun)

plotshape(showSignals and bullTkCross, title="Bull TK Cross", text="LONG", style=shape.labelup, location=location.belowbar, color=bullColor, textcolor=color.white, size=size.tiny)
plotshape(showSignals and bearTkCross, title="Bear TK Cross", text="SHORT", style=shape.labeldown, location=location.abovebar, color=bearColor, textcolor=color.black, size=size.tiny)

// ── DASHBOARD ──────────────────────────────────────────────────
var table dash = table.new(f_dashPos(dashPosition), 2, 6, border_width=1)

if barstate.islast and showDashboard
    table.cell(dash, 0, 0, "Mode", text_color=chart.fg_color, text_halign=text.align_left)
    table.cell(dash, 1, 0, mode, text_color=chart.fg_color, text_halign=text.align_center)

    table.cell(dash, 0, 1, "State", text_color=chart.fg_color, text_halign=text.align_left)
    table.cell(dash, 1, 1, trendState, text_color=stateColor, text_halign=text.align_center)

    table.cell(dash, 0, 2, "Price/Kumo", text_color=chart.fg_color, text_halign=text.align_left)
    table.cell(dash, 1, 2, priceVsKumo, text_color=close > cloudTop ? bullColor : close < cloudBot ? bearColor : neutralColor, text_halign=text.align_center)

    table.cell(dash, 0, 3, "Tenkan/Kijun", text_color=chart.fg_color, text_halign=text.align_left)
    table.cell(dash, 1, 3, tkState, text_color=tenkan > kijun ? bullColor : tenkan < kijun ? bearColor : neutralColor, text_halign=text.align_center)

    table.cell(dash, 0, 4, "Params", text_color=chart.fg_color, text_halign=text.align_left)
    table.cell(dash, 1, 4, str.tostring(tenkanLen) + " / " + str.tostring(kijunLen) + " / " + str.tostring(senkouBLen), text_color=chart.fg_color, text_halign=text.align_center)

    table.cell(dash, 0, 5, "ATR %", text_color=chart.fg_color, text_halign=text.align_left)
    table.cell(dash, 1, 5, str.tostring(atrPct, "#.00"), text_color=chart.fg_color, text_halign=text.align_center)


// ── LAST VALUE LABELS ──────────────────────────────────────────
var label tenkanLabel = na
var label kijunLabel  = na
var label spanALabel  = na
var label spanBLabel  = na

if barstate.islast and showLabels
    label.delete(tenkanLabel)
    label.delete(kijunLabel)
    label.delete(spanALabel)
    label.delete(spanBLabel)

    tenkanLabel := label.new(bar_index, tenkan, "Tenkan " + str.tostring(tenkan, format.mintick), style=label.style_label_left, color=color.new(color.black, 100), textcolor=tenkanColor, force_overlay=true)
    kijunLabel  := label.new(bar_index, kijun, "Kijun " + str.tostring(kijun, format.mintick), style=label.style_label_left, color=color.new(color.black, 100), textcolor=kijunColor, force_overlay=true)
    spanALabel  := label.new(bar_index + displacement, senkouA, "Span A " + str.tostring(senkouA, format.mintick), style=label.style_label_left, color=color.new(color.black, 100), textcolor=bullColor, force_overlay=true)
    spanBLabel  := label.new(bar_index + displacement, senkouB, "Span B " + str.tostring(senkouB, format.mintick), style=label.style_label_left, color=color.new(color.black, 100), textcolor=bearColor, force_overlay=true)

// ── ALERTS ─────────────────────────────────────────────────────
alertcondition(bullTkCross, title="Bull TK Cross", message="Ichimoku Adaptive Classic [Gabremoku] Bull TK Cross")
alertcondition(bearTkCross, title="Bear TK Cross", message="Ichimoku Adaptive Classic [Gabremoku] Bear TK Cross")
````
