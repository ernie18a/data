# Stochastic Histogram Regime [Gabremoku]

- url: https://www.tradingview.com/script/Culh5Xyl-Stochastic-Histogram-Regime-Gabremoku/
- type: indicator
- pine_id: PUB;d431c4f4c368426384f5c068a7c83d1d
- version: 1.0

## Description

[b]Stochastic Histogram Regime [Gabremoku] [/b]is a refined Stochastic-based momentum oscillator that transforms classic %K / %D logic into a mid-centered histogram regime model with adaptive zones, squeeze detection, and sequential BUY/SELL signaling.

Instead of using the traditional 0–100 Stochastic layout alone, this script recenters the oscillator around its midline and highlights:

momentum expansion and recovery phases

adaptive extreme zones

K/D compression regimes

sequential crossover signals

squeeze-aware signal styling

a compact live dashboard

The Stochastic Oscillator measures where the current close sits relative to its recent price range, and its two core lines — %K and %D — are commonly used to spot momentum shifts, overbought/oversold conditions, and crossover signals.

What it shows
📊 Mid-centered stochastic histogram — instead of plotting Stochastic only in its standard form, the script centers the histogram around the 50 level so bullish and bearish pressure become easier to compare visually.

📈 %K line and ghost %D line — the main momentum line stays visually dominant, while %D acts as a softer confirmation layer.

🎯 Adaptive zones — rather than relying only on static 80/20 thresholds, the script calculates percentile-based extreme zones from recent Stochastic behavior. Traditional Stochastic readings above 80 are often considered overbought and readings below 20 oversold, but adaptive thresholds can better reflect changing market behavior.

🗜️ Combined squeeze regime — the script measures both:

compression around the midline

compression between %K and %D

This creates a composite squeeze state that helps identify low-momentum contraction phases before expansion.

🚦 Sequential BUY/SELL state machine — primary signals are filtered through K/D crossover logic, slope confirmation, and optional extreme-zone requirements.

🔺 Follow-up triangles — repeated same-direction confirmations after the first primary signal can be shown as lighter continuation markers.

🪧 Minimal dashboard — displays state, K/D values, adaptive zone range, slope, and squeeze status.

Core logic
The script is built around the idea that the Stochastic Oscillator is not just an overbought/oversold tool, but a momentum regime detector.

Classic Stochastic compares the latest close to the recent high-low range and is typically interpreted through:

%K and %D crossovers

movement around 80/20 zones

and changes in momentum before price fully reacts

Your script extends that by:

recentering the oscillator around 50

using histogram structure for directional emphasis

adapting extreme zones to recent behavior

and combining crossover quality with slope and squeeze context

This makes it more structured than a standard Stochastic display.

State model
The indicator classifies momentum into five readable states:

Bull Impulse

Bull Recovery

Bear Impulse

Bear Recovery

Neutral

This adds nuance to the usual Stochastic reading because it separates:

strong directional continuation

weaker recovery phases

and non-directional compression

In practice:

Bull Impulse suggests K is above D, above the mid-neutral area, and still rising

Bear Impulse suggests K is below D, below the mid-neutral area, and still falling

recovery states identify improving momentum before full expansion

Signal logic
The script uses a filtered signal engine based on %K / %D crossovers, which are among the most common Stochastic signals.

Primary BUY and SELL signals can be filtered by:

extreme zone location

K slope confirmation

signal mode: Aggressive, Balanced, or Strict

This helps reduce the classic problem of noisy Stochastic crossovers in sideways conditions. Stochastic crossovers are useful, but they generally become more meaningful when combined with trend or momentum context rather than taken in isolation.

How to read it
A practical reading method is:

Use the histogram around the midline to read directional pressure.

Use adaptive zones to identify statistically stretched momentum.

Use %K / %D crossovers for trigger logic.

Use the squeeze state to identify contraction before expansion.

Treat follow-up triangles as continuation confirmation, not as fresh primary entries.

In general:

positive histogram with rising K = improving bullish momentum

negative histogram with falling K = improving bearish momentum

squeeze ON = compressed momentum regime

BUY/SELL labels = primary filtered crossover signals

Features
✅ Mid-centered stochastic histogram

✅ %K and ghost %D structure

✅ Percentile-based adaptive extreme zones

✅ Neutral zone around the 50 midline

✅ Composite squeeze detection

✅ Sequential BUY / SELL state machine

✅ Optional follow-up continuation markers

✅ Overlay and pane signal display options

✅ Minimal live dashboard

✅ Alert conditions for BUY, SELL, and squeeze state

Notes
This indicator is designed to improve the readability of Stochastic momentum structure, especially in transitions between compression, recovery, and impulse phases. Like all Stochastic-based tools, it can produce noisy signals in choppy markets, and overbought/oversold readings should generally be interpreted as momentum context rather than automatic reversal calls.

[i]Author: Gabremoku
Pine Script v6[/i]

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Gabremoku

//@version=6
indicator("Stochastic Histogram Regime [Gabremoku]", overlay=false, max_labels_count=500)

// Stochastic Histogram Regime Gabremoku
// Refined edition:
// - Mid-centered stochastic histogram
// - Adaptive zones
// - Combined squeeze regime
// - Sequential BUY/SELL state machine
// - Squeeze-aware labels and triangles
// - Ghost %D line
// - Histogram edge line for stronger hierarchy
// - Minimal dashboard

//------------------------------------------------------------------------------
// INPUTS
//------------------------------------------------------------------------------
grp0 = "Core"
grp1 = "Adaptive Zones"
grp2 = "Colors"
grp3 = "Style"
grp4 = "Signals"
grp5 = "Squeeze"
grp6 = "Dashboard"

kLen         = input.int(14, "%K Length", minval=1, group=grp0)
kSmooth      = input.int(3, "%K Smoothing", minval=1, group=grp0)
dLen         = input.int(3, "%D Length", minval=1, group=grp0)
src          = input.source(close, "Source", group=grp0)

zoneLookback = input.int(100, "Adaptive Lookback", minval=20, group=grp1)
zonePct      = input.float(0.20, "Extreme Zone Percentile", minval=0.05, maxval=0.40, step=0.01, group=grp1)
midNeutral   = input.float(6.0, "Neutral Zone Around 50", minval=0.0, maxval=20.0, step=0.5, group=grp1)

bullColor    = input.color(color.rgb(33, 150, 243), "Bullish Color Blue", group=grp2)
bearColor    = input.color(color.rgb(241, 255, 48), "Bearish Color Yellow", group=grp2)
squeezeColor = input.color(color.rgb(156, 39, 176), "Squeeze Color Purple", group=grp2)
neutralColor = input.color(color.gray, "Neutral Color", group=grp2)

showHistogram        = input.bool(true, "Show Histogram", group=grp3)
showHistogramEdge    = input.bool(true, "Show Histogram Edge", group=grp3)
showKLine            = input.bool(true, "Show %K Line", group=grp3)
showDLine            = input.bool(true, "Show %D Ghost Line", group=grp3)
showAdaptive         = input.bool(true, "Show Adaptive Zones", group=grp3)
showOverlaySignals   = input.bool(true, "Show Overlay Signals", group=grp3)
showPaneSignals      = input.bool(false, "Show Pane Signals", group=grp3)
histWidth            = input.int(4, "Histogram Width", minval=1, maxval=8, group=grp3)
edgeWidth            = input.int(2, "Histogram Edge Width", minval=1, maxval=4, group=grp3)
kWidth               = input.int(2, "K Width", minval=1, maxval=5, group=grp3)
dWidth               = input.int(1, "D Width", minval=1, maxval=3, group=grp3)
fillAggressive       = input.float(1.8, "Gradient Aggressiveness", minval=0.5, maxval=4.0, step=0.1, group=grp3)
maxOpacityNear       = input.int(92, "Opacity Near Midline", minval=0, maxval=100, group=grp3)
minOpacityFar        = input.int(18, "Opacity Far From Midline", minval=0, maxval=100, group=grp3)
ghostOpacity         = input.int(68, "%D Ghost Opacity", minval=40, maxval=95, group=grp3)
zoneOpacity          = input.int(86, "Adaptive Zone Opacity", minval=60, maxval=98, group=grp3)

signalMode           = input.string("Balanced", "Signal Filter", options=["Aggressive", "Balanced", "Strict"], group=grp4)
requireExtreme       = input.bool(true, "Require Extreme Zone", group=grp4)
requireSlope         = input.bool(true, "Require K Slope Confirmation", group=grp4)
minSlope             = input.float(1.5, "Min K Slope", minval=0.0, maxval=20.0, step=0.1, group=grp4)
showFollowUpMarkers  = input.bool(true, "Show Follow-Up Triangles", group=grp4)

showSqueeze          = input.bool(true, "Show Squeeze", group=grp5)
sqzLookback          = input.int(100, "Squeeze Lookback", minval=20, group=grp5)
sqzThreshold         = input.float(0.18, "Squeeze Percentile Threshold", minval=0.01, maxval=0.50, step=0.01, group=grp5)
sqzWeightMid         = input.float(0.60, "Weight Mid Compression", minval=0.0, maxval=1.0, step=0.05, group=grp5)
sqzWeightSpread      = input.float(0.40, "Weight K-D Compression", minval=0.0, maxval=1.0, step=0.05, group=grp5)

showDashboard        = input.bool(true, "Show Dashboard", group=grp6)

//------------------------------------------------------------------------------
// FUNCTIONS
//------------------------------------------------------------------------------
clamp(x, minVal, maxVal) =>
    math.max(minVal, math.min(maxVal, x))

safeNorm(val, lo, hi) =>
    hi != lo ? (val - lo) / (hi - lo) : 0.0

stochRaw(_src, _len) =>
    hh = ta.highest(high, _len)
    ll = ta.lowest(low, _len)
    rng = hh - ll
    rng != 0 ? (_src - ll) / rng * 100.0 : 50.0

//------------------------------------------------------------------------------
// STOCHASTIC CORE
//------------------------------------------------------------------------------
rawK = stochRaw(src, kLen)
k    = ta.sma(rawK, kSmooth)
d    = ta.sma(k, dLen)

histValue  = k - 50.0
dHistValue = d - 50.0

//------------------------------------------------------------------------------
// ADAPTIVE ZONES
//------------------------------------------------------------------------------
adaptiveUpper = ta.percentile_linear_interpolation(k, zoneLookback, 100 * (1 - zonePct))
adaptiveLower = ta.percentile_linear_interpolation(k, zoneLookback, 100 * zonePct)

upperZone = na(adaptiveUpper) ? 80.0 : adaptiveUpper
lowerZone = na(adaptiveLower) ? 20.0 : adaptiveLower
midUpper  = 50 + midNeutral
midLower  = 50 - midNeutral

upperZoneHist = upperZone - 50.0
lowerZoneHist = lowerZone - 50.0

//------------------------------------------------------------------------------
// STATE
//------------------------------------------------------------------------------
kSlope = k - k[1]
distMid = k - 50.0
distMidAbs = math.abs(distMid)

bullImpulse  = k > d and k > midUpper and kSlope > 0
bullRecovery = k > d and k >= lowerZone and k <= midUpper and kSlope > 0
bearImpulse  = k < d and k < midLower and kSlope < 0
bearRecovery = k < d and k <= upperZone and k >= midLower and kSlope < 0

state =
     bullImpulse  ? "Bull Impulse"  :
     bullRecovery ? "Bull Recovery" :
     bearImpulse  ? "Bear Impulse"  :
     bearRecovery ? "Bear Recovery" : "Neutral"

stateColor =
     bullImpulse  ? bullColor :
     bullRecovery ? bullColor :
     bearImpulse  ? bearColor :
     bearRecovery ? bearColor :
     neutralColor

//------------------------------------------------------------------------------
// COMBINED SQUEEZE
//------------------------------------------------------------------------------
midCompression    = math.abs(k - 50.0)
spreadCompression = math.abs(k - d)

midMin    = ta.lowest(midCompression, sqzLookback)
midMax    = ta.highest(midCompression, sqzLookback)
spreadMin = ta.lowest(spreadCompression, sqzLookback)
spreadMax = ta.highest(spreadCompression, sqzLookback)

midNormRaw    = safeNorm(midCompression, midMin, midMax)
spreadNormRaw = safeNorm(spreadCompression, spreadMin, spreadMax)

midNormInv    = 1.0 - clamp(midNormRaw, 0.0, 1.0)
spreadNormInv = 1.0 - clamp(spreadNormRaw, 0.0, 1.0)

sqzComposite = clamp(midNormInv * sqzWeightMid + spreadNormInv * sqzWeightSpread, 0.0, 1.0)
isSqueeze    = showSqueeze and sqzComposite >= (1.0 - sqzThreshold)

//------------------------------------------------------------------------------
// COLORS
//------------------------------------------------------------------------------
neutralHi = midNeutral
neutralLo = -midNeutral
kPosNorm  = clamp(distMid / 50.0, -1.0, 1.0)

kColorRaw =
     kPosNorm >= 0
     ? color.from_gradient(kPosNorm, neutralHi / 50.0, 1.0, neutralColor, bullColor)
     : color.from_gradient(kPosNorm, -1.0, neutralLo / 50.0, bearColor, neutralColor)

kColorBase = math.abs(distMid) <= midNeutral ? neutralColor : kColorRaw
kColor     = isSqueeze ? squeezeColor : kColorBase
dColor     = color.new(kColor, ghostOpacity)

distNorm = clamp(math.pow(clamp(distMidAbs, 0.0, 50.0) / 50.0, fillAggressive), 0.0, 1.0)

bullNear = color.new(bullColor, maxOpacityNear)
bullFar  = color.new(bullColor, minOpacityFar)
bearNear = color.new(bearColor, maxOpacityNear)
bearFar  = color.new(bearColor, minOpacityFar)
sqzNear  = color.new(squeezeColor, maxOpacityNear)
sqzFar   = color.new(squeezeColor, minOpacityFar)

histColorBase =
     histValue >= 0
     ? color.from_gradient(distNorm, 0.0, 1.0, bullNear, bullFar)
     : color.from_gradient(distNorm, 0.0, 1.0, bearNear, bearFar)

histColor = isSqueeze
     ? color.from_gradient(distNorm, 0.0, 1.0, sqzNear, sqzFar)
     : histColorBase

edgeColor =
     isSqueeze ? color.new(squeezeColor, 0) :
     histValue >= 0 ? color.new(bullColor, 0) : color.new(bearColor, 0)

upperZoneColor = color.new(bearColor, zoneOpacity)
lowerZoneColor = color.new(bullColor, zoneOpacity)
midZoneColor   = color.new(neutralColor, 88)

//------------------------------------------------------------------------------
// SIGNALS + STATE MACHINE
//------------------------------------------------------------------------------
minSlopeMode = signalMode == "Aggressive" ? minSlope * 0.75 : signalMode == "Strict" ? minSlope * 1.5 : minSlope

buyExtreme  = k <= lowerZone or d <= lowerZone
sellExtreme = k >= upperZone or d >= upperZone

buySlopeOk  = not requireSlope or kSlope >= minSlopeMode
sellSlopeOk = not requireSlope or kSlope <= -minSlopeMode

buyZoneOk   = not requireExtreme or buyExtreme
sellZoneOk  = not requireExtreme or sellExtreme

rawBuy  = ta.crossover(k, d)
rawSell = ta.crossunder(k, d)

buyReady  = rawBuy and buyZoneOk and buySlopeOk and k < midUpper
sellReady = rawSell and sellZoneOk and sellSlopeOk and k > midLower

var int signalState = 0
//  0 = neutral
//  1 = last primary signal was BUY
// -1 = last primary signal was SELL

primaryBuy  = false
primarySell = false
followBuy   = false
followSell  = false

if buyReady
    if signalState != 1
        primaryBuy := true
        signalState := 1
    else
        followBuy := true

if sellReady
    if signalState != -1
        primarySell := true
        signalState := -1
    else
        followSell := true

//------------------------------------------------------------------------------
// SIGNAL COLORS
//------------------------------------------------------------------------------
primaryBuyColor     = isSqueeze ? squeezeColor : bullColor
primarySellColor    = isSqueeze ? squeezeColor : bearColor
followBuyColor      = isSqueeze ? squeezeColor : bullColor
followSellColor     = isSqueeze ? squeezeColor : bearColor
primaryBuyTxtColor  = color.white
primarySellTxtColor = isSqueeze ? color.white : color.black

//------------------------------------------------------------------------------
// REFERENCE LINES
//------------------------------------------------------------------------------
hline(50,  "Top",    color=color.new(chart.fg_color, 96))
hline(30,  "Upper",  color=upperZoneColor, linestyle=hline.style_dotted)
hline(0,   "Median", color=color.new(neutralColor, 35))
hline(-30, "Lower",  color=lowerZoneColor, linestyle=hline.style_dotted)
hline(-50, "Bottom", color=color.new(chart.fg_color, 96))

//------------------------------------------------------------------------------
// PLOTS
//------------------------------------------------------------------------------
plot(showAdaptive ? upperZoneHist : na, "Adaptive Upper", color=upperZoneColor, linewidth=1, style=plot.style_line)
plot(showAdaptive ? lowerZoneHist : na, "Adaptive Lower", color=lowerZoneColor, linewidth=1, style=plot.style_line)
plot(showAdaptive ? (midUpper - 50.0) : na, "Mid Upper", color=midZoneColor, linewidth=1, style=plot.style_circles)
plot(showAdaptive ? (midLower - 50.0) : na, "Mid Lower", color=midZoneColor, linewidth=1, style=plot.style_circles)

plot(showHistogram ? histValue : na, "Histogram", style=plot.style_columns, color=histColor, linewidth=histWidth)
plot(showHistogram and showHistogramEdge ? histValue : na, "Histogram Edge", color=color.new(edgeColor, 0), linewidth=edgeWidth, style=plot.style_line)

plot(showKLine ? histValue : na, "%K Mid-Centered", color=kColor, linewidth=kWidth)
plot(showDLine ? dHistValue : na, "%D Ghost", color=dColor, linewidth=dWidth)

//------------------------------------------------------------------------------
// SIGNAL VISUALS
//------------------------------------------------------------------------------
plotshape(
     showPaneSignals and primaryBuy ? -44 : na,
     title="BUY Pane",
     text="BUY",
     style=shape.labelup,
     location=location.absolute,
     color=primaryBuyColor,
     textcolor=primaryBuyTxtColor,
     size=size.tiny)

plotshape(
     showPaneSignals and primarySell ? 44 : na,
     title="SELL Pane",
     text="SELL",
     style=shape.labeldown,
     location=location.absolute,
     color=primarySellColor,
     textcolor=primarySellTxtColor,
     size=size.tiny)

plotshape(
     showOverlaySignals and primaryBuy,
     title="BUY Overlay",
     text="BUY",
     style=shape.labelup,
     location=location.belowbar,
     color=primaryBuyColor,
     textcolor=primaryBuyTxtColor,
     size=size.tiny,
     force_overlay=true)

plotshape(
     showOverlaySignals and primarySell,
     title="SELL Overlay",
     text="SELL",
     style=shape.labeldown,
     location=location.abovebar,
     color=primarySellColor,
     textcolor=primarySellTxtColor,
     size=size.tiny,
     force_overlay=true)

plotshape(
     showFollowUpMarkers and followBuy,
     title="BUY Follow-Up",
     style=shape.triangleup,
     location=location.belowbar,
     color=followBuyColor,
     size=size.tiny,
     force_overlay=true)

plotshape(
     showFollowUpMarkers and followSell,
     title="SELL Follow-Up",
     style=shape.triangledown,
     location=location.abovebar,
     color=followSellColor,
     size=size.tiny,
     force_overlay=true)

//------------------------------------------------------------------------------
// DASHBOARD
//------------------------------------------------------------------------------
var table dash = table.new(position.bottom_right, 2, 5, border_width=1)

if barstate.islast and showDashboard
    table.cell(dash, 0, 0, "State", text_color=chart.fg_color, text_halign=text.align_left, text_size=size.small)
    table.cell(dash, 1, 0, state, text_color=stateColor, text_halign=text.align_right, text_size=size.small)

    table.cell(dash, 0, 1, "K/D", text_color=chart.fg_color, text_halign=text.align_left, text_size=size.small)
    table.cell(dash, 1, 1, str.tostring(k, "#.0") + " / " + str.tostring(d, "#.0"), text_color=chart.fg_color, text_halign=text.align_right, text_size=size.small)

    table.cell(dash, 0, 2, "Zone", text_color=chart.fg_color, text_halign=text.align_left, text_size=size.small)
    table.cell(dash, 1, 2, str.tostring(lowerZone, "#.0") + " - " + str.tostring(upperZone, "#.0"), text_color=chart.fg_color, text_halign=text.align_right, text_size=size.small)

    table.cell(dash, 0, 3, "Slope", text_color=chart.fg_color, text_halign=text.align_left, text_size=size.small)
    table.cell(dash, 1, 3, str.tostring(kSlope, "#.0"), text_color=kSlope >= 0 ? bullColor : bearColor, text_halign=text.align_right, text_size=size.small)

    table.cell(dash, 0, 4, "Sqz", text_color=chart.fg_color, text_halign=text.align_left, text_size=size.small)
    table.cell(dash, 1, 4, isSqueeze ? "ON" : "OFF", text_color=isSqueeze ? squeezeColor : chart.fg_color, text_halign=text.align_right, text_size=size.small)

//------------------------------------------------------------------------------
// ALERTS
//------------------------------------------------------------------------------
alertcondition(primaryBuy, "SHR Buy", "Stochastic Histogram Regime Gabremoku BUY")
alertcondition(primarySell, "SHR Sell", "Stochastic Histogram Regime Gabremoku SELL")
alertcondition(isSqueeze, "SHR Squeeze", "Stochastic Histogram Regime Gabremoku SQUEEZE ON")
````
