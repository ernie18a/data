# Kalman Auction Ribbon [JOAT]

- url: https://www.tradingview.com/script/nj6iZq59-Kalman-Auction-Ribbon-JOAT/
- type: indicator
- pine_id: PUB;00364a9be1864a74805f87b433da17be
- version: 1.0

## Description

Kalman Auction Ribbon is an open-source Pine Script v6 overlay that builds a six-layer adaptive ribbon from a zero-lag source and Kalman-style velocity smoothing. The goal is to show trend alignment, slope strength, deviation zones, and confirmed retest behavior in one restrained chart layer.

The script focuses on auction behavior around a dynamic ribbon. When the ribbon layers align and slope together, the state becomes directional. When price stretches beyond the deviation envelope and then returns, the script can mark supply or demand zones for later retests.

[image]https://www.tradingview.com/x/DdosXHpR/[/image]

[b]Core Concepts[/b]

[b]1. Zero-Lag Source[/b]

The source is adjusted by comparing current price with a half-length historical value. This produces a more responsive input for the ribbon calculations.

[pine]
zeroLagOffset = math.max(1, int(math.round(baseLength * 0.50)))
zeroLagSource = src + (src - nz(src[zeroLagOffset], src))
[/pine]

[b]2. Kalman-Style Velocity Estimate[/b]

Each ribbon layer uses a compact velocity smoother that maintains an estimate and speed component. The speed term helps the estimate respond to directional movement without relying on future bars.

[pine]
prior = na(estimate[1]) ? value : estimate[1] + nz(speed[1]) * gain
error = value - prior
speed := nz(speed[1]) * (1.0 - alpha * 0.50) + error * alpha * gain
estimate := prior + error * alpha
[/pine]

[b]3. Six-Layer Ribbon Alignment[/b]

The script calculates six different ribbon lengths. Alignment and slope scores are combined into a trend score from -100 to +100. This score controls the ribbon color and dashboard power reading.

[b]4. Deviation Zones[/b]

Upper and lower deviation levels are built around the ribbon midpoint using ATR. If price pushes beyond a deviation level and closes back inside, the script creates a compact supply or demand zone.

[b]5. Retest Logic[/b]

Retest signals occur when price interacts with a live zone or the ribbon itself while the ribbon state remains directional. These signals are confirmed on closed bars.

[b]Features[/b]

[list]
[*][b]Six-layer adaptive ribbon:[/b] Multiple Kalman-style layers reveal alignment and spread
[*][b]Velocity weighting:[/b] Gain input changes how aggressively the smoother responds
[*][b]Deviation envelope:[/b] ATR-based upper and lower zones around the ribbon midpoint
[*][b]Soft supply and demand boxes:[/b] Created only on confirmed deviation rejection behavior, with overlap suppression so the chart does not stack redundant boxes
[*][b]Labeled deviation boxes:[/b] Supply and Demand Deviation boxes include midpoint guide lines and fade after invalidation
[*][b]Confirmed buy/sell markers:[/b] Compact BUY and SELL dots appear only after confirmed ribbon or zone retest behavior
[*][b]Trend-state candles:[/b] Optional bar coloring by ribbon state
[*][b]Dashboard:[/b] Shows state, power, distance, and retest status
[*][b]Alerts:[/b] Confirmed buy, confirmed sell, lower deviation zone, and upper deviation zone
[/list]

[b]Input Parameters[/b]

[b]Core:[/b]
[list]
[*]Source: Price source used by the ribbon
[*]Base Length: Main length from which all ribbon layers are derived
[*]Velocity Weight: Strength of the speed component
[*]Deviation ATR Length: ATR length for deviation zones
[*]Deviation Width: ATR multiplier for the envelope
[/list]

[b]Zones:[/b]
[list]
[*]Show Deviation Zones: Toggles supply and demand boxes
[*]Zone Extension Bars: How far active boxes extend to the right
[*]Maximum Zones Per Side: Caps active supply and demand boxes
[/list]

[b]Signals:[/b]
[list]
[*]Show Confirmed Buy/Sell: Toggles compact confirmed signal dots
[*]Signal Spacing Bars: Minimum spacing between signal markers
[*]Zone Extension Bars: Forward box extension length
[*]Maximum Zones Per Side: Object cap for zone storage
[/list]

[b]Visual:[/b]
[list]
[*]Palette: Selects the color pair
[*]Show Ribbon: Toggles ribbon plots and fill
[*]Trend-State Candles: Enables candle coloring
[*]Dashboard: Shows the top-right panel
[/list]

[b]How to Use This Indicator[/b]

[b]Step 1: Read Ribbon Alignment[/b]
A strongly stacked ribbon with a high dashboard power value indicates directional alignment. A mixed ribbon shows a less decisive state.

[b]Step 2: Watch Deviation Zones[/b]
Zones are created when price rejects beyond an ATR deviation envelope. These boxes represent areas where price stretched away from the ribbon and returned.

[b]Step 3: Use Retests With Context[/b]
Retest dots identify confirmed interactions with the ribbon or zones. They should be evaluated with trend state, market structure, and risk placement.

[b]Indicator Limitations[/b]

[list]
[*]Kalman-style smoothing is reactive and does not know future price direction
[*]Strong news bars can move through deviation zones without meaningful retests
[*]Object limits require older zones to be removed when the maximum is exceeded
[*]The ribbon can compress during range conditions and produce mixed readings
[/list]

[b]Originality Statement[/b]

Kalman Auction Ribbon is original in its combination of zero-lag preprocessing, six independent Kalman-style layers, ATR deviation boxes, and confirmed retest tracking. It uses public Pine primitives in a custom structure and does not paste or disguise another author's source.

[b]Disclaimer[/b]

This script is provided for educational and informational use only. It is not financial advice or a recommendation to buy or sell any financial instrument. Trading involves substantial risk of loss. Ribbon states and zones can fail during unusual volatility or thin liquidity. Always use independent analysis and proper risk management.

-Made with passion by jackofalltrades

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
indicator("Kalman Auction Ribbon [JOAT]", shorttitle="Kalman Auction Ribbon [JOAT]", overlay=true, max_boxes_count=120, max_lines_count=120, max_labels_count=40)

groupCore = "Core"
src = input.source(close, "Source", group=groupCore)
baseLength = input.int(34, "Base Length", minval=5, maxval=240, group=groupCore)
velocityGain = input.float(0.62, "Velocity Weight", minval=0.05, maxval=1.50, step=0.05, group=groupCore)
atrLength = input.int(21, "Deviation ATR Length", minval=3, maxval=200, group=groupCore)
deviationMult = input.float(1.55, "Deviation Width", minval=0.20, maxval=6.00, step=0.05, group=groupCore)

groupZones = "Zones"
showZones = input.bool(true, "Show Deviation Zones", group=groupZones)
zoneBars = input.int(70, "Zone Extension Bars", minval=5, maxval=400, group=groupZones)
maxZones = input.int(14, "Maximum Zones Per Side", minval=1, maxval=50, group=groupZones)

groupSignals = "Signals"
showSignals = input.bool(true, "Show Confirmed Buy/Sell", group=groupSignals)
signalSpacingBars = input.int(8, "Signal Spacing Bars", minval=0, maxval=100, group=groupSignals)

groupVisual = "Visual"
palettePreset = input.string("Aqua Rose", "Palette", options=["Aqua Rose", "Neon Desk", "Mint Pulse", "VWAP Field"], group=groupVisual)
showRibbon = input.bool(true, "Show Ribbon", group=groupVisual)
showCandles = input.bool(true, "Trend-State Candles", group=groupVisual)
showDashboard = input.bool(true, "Dashboard", group=groupVisual)

bullBase = switch palettePreset
    "Neon Desk" => #00ff00
    "Mint Pulse" => #00FFD5
    "VWAP Field" => #1ac200
    => #00C8FF

bearBase = switch palettePreset
    "Neon Desk" => #ff0000
    "Mint Pulse" => #FF0066
    "VWAP Field" => #ff4040
    => #FF005D

neutralBase = color.rgb(150, 156, 166)

clamp(value, lowLimit, highLimit) =>
    math.min(math.max(value, lowLimit), highLimit)

kalmanVelocity(value, length, gain) =>
    alpha = 2.0 / (length + 1.0)
    var float estimate = na
    var float speed = 0.0
    prior = na(estimate[1]) ? value : estimate[1] + nz(speed[1]) * gain
    error = value - prior
    speed := nz(speed[1]) * (1.0 - alpha * 0.50) + error * alpha * gain
    estimate := prior + error * alpha
    estimate

zeroLagOffset = math.max(1, int(math.round(baseLength * 0.50)))
zeroLagSource = src + (src - nz(src[zeroLagOffset], src))

layer1Length = math.max(2, int(math.round(baseLength * 0.48)))
layer2Length = math.max(3, int(math.round(baseLength * 0.68)))
layer3Length = math.max(4, int(math.round(baseLength * 0.90)))
layer4Length = math.max(5, int(math.round(baseLength * 1.16)))
layer5Length = math.max(6, int(math.round(baseLength * 1.48)))
layer6Length = math.max(7, int(math.round(baseLength * 1.90)))

k1 = kalmanVelocity(zeroLagSource, layer1Length, velocityGain)
k2 = kalmanVelocity(zeroLagSource, layer2Length, velocityGain * 0.92)
k3 = kalmanVelocity(zeroLagSource, layer3Length, velocityGain * 0.84)
k4 = kalmanVelocity(zeroLagSource, layer4Length, velocityGain * 0.76)
k5 = kalmanVelocity(zeroLagSource, layer5Length, velocityGain * 0.68)
k6 = kalmanVelocity(zeroLagSource, layer6Length, velocityGain * 0.60)

atrValue = ta.atr(atrLength)
ribbonMid = (k3 + k4) * 0.50
upperDeviation = ribbonMid + atrValue * deviationMult
lowerDeviation = ribbonMid - atrValue * deviationMult

alignmentScore = (k1 > k2 ? 1 : -1) + (k2 > k3 ? 1 : -1) + (k3 > k4 ? 1 : -1) + (k4 > k5 ? 1 : -1) + (k5 > k6 ? 1 : -1)
slopeScore = (k1 > k1[1] ? 1 : -1) + (k2 > k2[1] ? 1 : -1) + (k3 > k3[1] ? 1 : -1) + (k4 > k4[1] ? 1 : -1) + (k5 > k5[1] ? 1 : -1) + (k6 > k6[1] ? 1 : -1)
spreadScore = clamp(math.abs(k1 - k6) / math.max(atrValue, syminfo.mintick) * 18.0, 0.0, 28.0)
trendScore = clamp((alignmentScore * 10.0) + (slopeScore * 5.0) + (k1 > k6 ? spreadScore : -spreadScore), -100.0, 100.0)
ribbonColor = color.from_gradient(trendScore, -100.0, 100.0, color.new(bearBase, 0), color.new(bullBase, 0))
ribbonSoft = color.new(ribbonColor, 78)

upperDistance = clamp((high - upperDeviation) / math.max(atrValue, syminfo.mintick), 0.0, 2.5)
lowerDistance = clamp((lowerDeviation - low) / math.max(atrValue, syminfo.mintick), 0.0, 2.5)
upperColor = color.from_gradient(upperDistance, 0.0, 2.5, color.new(neutralBase, 75), color.new(bearBase, 20))
lowerColor = color.from_gradient(lowerDistance, 0.0, 2.5, color.new(neutralBase, 75), color.new(bullBase, 20))
supplyZoneFill = color.new(bearBase, 90)
demandZoneFill = color.new(bullBase, 90)
supplyZoneBorder = color.new(bearBase, 18)
demandZoneBorder = color.new(bullBase, 18)
supplyZoneText = color.new(bearBase, 0)
demandZoneText = color.new(bullBase, 0)

p1 = plot(showRibbon ? k1 : na, "Ribbon Layer 1 [JOAT]", color=color.new(ribbonColor, 0), linewidth=2)
p2 = plot(showRibbon ? k2 : na, "Ribbon Layer 2 [JOAT]", color=color.new(ribbonColor, 20), linewidth=1)
p3 = plot(showRibbon ? k3 : na, "Ribbon Layer 3 [JOAT]", color=color.new(ribbonColor, 34), linewidth=1)
p4 = plot(showRibbon ? k4 : na, "Ribbon Layer 4 [JOAT]", color=color.new(ribbonColor, 48), linewidth=1)
p5 = plot(showRibbon ? k5 : na, "Ribbon Layer 5 [JOAT]", color=color.new(ribbonColor, 60), linewidth=1)
p6 = plot(showRibbon ? k6 : na, "Ribbon Layer 6 [JOAT]", color=color.new(ribbonColor, 0), linewidth=2)
fill(p1, p6, color=showRibbon ? ribbonSoft : na, title="Ribbon Body [JOAT]")

plot(upperDeviation, "Upper Deviation [JOAT]", color=upperColor, linewidth=1)
plot(lowerDeviation, "Lower Deviation [JOAT]", color=lowerColor, linewidth=1)

bullTrend = trendScore > 24.0 and k1 > k6
bearTrend = trendScore < -24.0 and k1 < k6
calmState = not bullTrend and not bearTrend
candleColor = bullTrend ? color.new(bullBase, 15) : bearTrend ? color.new(bearBase, 15) : color.new(neutralBase, 55)
barcolor(showCandles ? candleColor : na)

supplyZoneTrigger = showZones and barstate.isconfirmed and high > upperDeviation and close < upperDeviation
demandZoneTrigger = showZones and barstate.isconfirmed and low < lowerDeviation and close > lowerDeviation

var supplyZones = array.new_box(0)
var demandZones = array.new_box(0)
var supplyMidlines = array.new_line(0)
var demandMidlines = array.new_line(0)
var supplyInvalidated = array.new_bool(0)
var demandInvalidated = array.new_bool(0)
var supplyFrozenRight = array.new_int(0)
var demandFrozenRight = array.new_int(0)

if supplyZoneTrigger
    supplyTop = high
    supplyMaxHeight = math.max(atrValue * 0.45, syminfo.mintick * 8.0)
    supplyBottom = math.min(supplyTop - syminfo.mintick, math.max(math.max(open, close), supplyTop - supplyMaxHeight))
    zoneOverlapBuffer = math.max(atrValue * 0.10, syminfo.mintick * 4.0)
    overlapsSupplyZone = false
    if array.size(supplyZones) > 0
        for i = 0 to array.size(supplyZones) - 1
            activeCandidate = not array.get(supplyInvalidated, i)
            candidate = array.get(supplyZones, i)
            candidateTop = box.get_top(candidate)
            candidateBottom = box.get_bottom(candidate)
            overlapsSupplyZone := overlapsSupplyZone or (activeCandidate and supplyBottom <= candidateTop + zoneOverlapBuffer and supplyTop >= candidateBottom - zoneOverlapBuffer)
    if not overlapsSupplyZone
        supplyMid = (supplyTop + supplyBottom) * 0.50
        createdSupply = box.new(left=bar_index, top=supplyTop, right=bar_index + zoneBars, bottom=supplyBottom, border_color=supplyZoneBorder, border_width=1, border_style=line.style_solid, bgcolor=supplyZoneFill, text="Supply Deviation", text_color=supplyZoneText, text_size=size.tiny, text_halign=text.align_center, text_valign=text.align_top, text_wrap=text.wrap_none, text_formatting=text.format_bold)
        createdSupplyMid = line.new(bar_index, supplyMid, bar_index + zoneBars, supplyMid, color=color.new(bearBase, 45), style=line.style_dotted, width=1)
        array.push(supplyZones, createdSupply)
        array.push(supplyMidlines, createdSupplyMid)
        array.push(supplyInvalidated, false)
        array.push(supplyFrozenRight, bar_index + zoneBars)
        if array.size(supplyZones) > maxZones
            oldSupply = array.shift(supplyZones)
            oldSupplyMid = array.shift(supplyMidlines)
            array.shift(supplyInvalidated)
            array.shift(supplyFrozenRight)
            box.delete(oldSupply)
            line.delete(oldSupplyMid)

if demandZoneTrigger
    demandBottom = low
    demandMaxHeight = math.max(atrValue * 0.45, syminfo.mintick * 8.0)
    demandTop = math.max(demandBottom + syminfo.mintick, math.min(math.min(open, close), demandBottom + demandMaxHeight))
    zoneOverlapBuffer = math.max(atrValue * 0.10, syminfo.mintick * 4.0)
    overlapsDemandZone = false
    if array.size(demandZones) > 0
        for i = 0 to array.size(demandZones) - 1
            activeCandidate = not array.get(demandInvalidated, i)
            candidate = array.get(demandZones, i)
            candidateTop = box.get_top(candidate)
            candidateBottom = box.get_bottom(candidate)
            overlapsDemandZone := overlapsDemandZone or (activeCandidate and demandBottom <= candidateTop + zoneOverlapBuffer and demandTop >= candidateBottom - zoneOverlapBuffer)
    if not overlapsDemandZone
        demandMid = (demandTop + demandBottom) * 0.50
        createdDemand = box.new(left=bar_index, top=demandTop, right=bar_index + zoneBars, bottom=demandBottom, border_color=demandZoneBorder, border_width=1, border_style=line.style_solid, bgcolor=demandZoneFill, text="Demand Deviation", text_color=demandZoneText, text_size=size.tiny, text_halign=text.align_center, text_valign=text.align_top, text_wrap=text.wrap_none, text_formatting=text.format_bold)
        createdDemandMid = line.new(bar_index, demandMid, bar_index + zoneBars, demandMid, color=color.new(bullBase, 45), style=line.style_dotted, width=1)
        array.push(demandZones, createdDemand)
        array.push(demandMidlines, createdDemandMid)
        array.push(demandInvalidated, false)
        array.push(demandFrozenRight, bar_index + zoneBars)
        if array.size(demandZones) > maxZones
            oldDemand = array.shift(demandZones)
            oldDemandMid = array.shift(demandMidlines)
            array.shift(demandInvalidated)
            array.shift(demandFrozenRight)
            box.delete(oldDemand)
            line.delete(oldDemandMid)

bool supplyRetest = false
bool demandRetest = false

if array.size(supplyZones) > 0
    for i = 0 to array.size(supplyZones) - 1
        activeSupply = array.get(supplyZones, i)
        activeSupplyMid = array.get(supplyMidlines, i)
        top = box.get_top(activeSupply)
        bottom = box.get_bottom(activeSupply)
        mid = (top + bottom) * 0.50
        wasInvalidated = array.get(supplyInvalidated, i)
        overlap = high >= bottom and low <= top
        broken = not wasInvalidated and close > top and barstate.isconfirmed
        invalidated = wasInvalidated or broken
        retested = not invalidated and overlap and bearTrend and close < bottom and barstate.isconfirmed
        if broken
            array.set(supplyInvalidated, i, true)
            array.set(supplyFrozenRight, i, bar_index)
        rightEdge = invalidated ? array.get(supplyFrozenRight, i) : bar_index + zoneBars
        box.set_right(activeSupply, rightEdge)
        line.set_xy1(activeSupplyMid, box.get_left(activeSupply), mid)
        line.set_xy2(activeSupplyMid, rightEdge, mid)
        supplyRetest := supplyRetest or retested
        if invalidated
            box.set_bgcolor(activeSupply, color.new(neutralBase, 94))
            box.set_border_color(activeSupply, color.new(neutralBase, 72))
            box.set_border_style(activeSupply, line.style_dotted)
            box.set_text_color(activeSupply, color.new(neutralBase, 62))
            line.set_color(activeSupplyMid, color.new(neutralBase, 75))
            line.set_style(activeSupplyMid, line.style_dotted)
        else if retested
            box.set_bgcolor(activeSupply, color.new(bearBase, 88))
            box.set_border_color(activeSupply, color.new(bearBase, 8))
            box.set_border_style(activeSupply, line.style_dashed)
            box.set_text_color(activeSupply, supplyZoneText)
            line.set_color(activeSupplyMid, color.new(bearBase, 22))
            line.set_style(activeSupplyMid, line.style_dashed)
        else
            box.set_bgcolor(activeSupply, supplyZoneFill)
            box.set_border_color(activeSupply, supplyZoneBorder)
            box.set_border_style(activeSupply, line.style_solid)
            box.set_text_color(activeSupply, supplyZoneText)
            line.set_color(activeSupplyMid, color.new(bearBase, 45))
            line.set_style(activeSupplyMid, line.style_dotted)

if array.size(demandZones) > 0
    for i = 0 to array.size(demandZones) - 1
        activeDemand = array.get(demandZones, i)
        activeDemandMid = array.get(demandMidlines, i)
        top = box.get_top(activeDemand)
        bottom = box.get_bottom(activeDemand)
        mid = (top + bottom) * 0.50
        wasInvalidated = array.get(demandInvalidated, i)
        overlap = high >= bottom and low <= top
        broken = not wasInvalidated and close < bottom and barstate.isconfirmed
        invalidated = wasInvalidated or broken
        retested = not invalidated and overlap and bullTrend and close > top and barstate.isconfirmed
        if broken
            array.set(demandInvalidated, i, true)
            array.set(demandFrozenRight, i, bar_index)
        rightEdge = invalidated ? array.get(demandFrozenRight, i) : bar_index + zoneBars
        box.set_right(activeDemand, rightEdge)
        line.set_xy1(activeDemandMid, box.get_left(activeDemand), mid)
        line.set_xy2(activeDemandMid, rightEdge, mid)
        demandRetest := demandRetest or retested
        if invalidated
            box.set_bgcolor(activeDemand, color.new(neutralBase, 94))
            box.set_border_color(activeDemand, color.new(neutralBase, 72))
            box.set_border_style(activeDemand, line.style_dotted)
            box.set_text_color(activeDemand, color.new(neutralBase, 62))
            line.set_color(activeDemandMid, color.new(neutralBase, 75))
            line.set_style(activeDemandMid, line.style_dotted)
        else if retested
            box.set_bgcolor(activeDemand, color.new(bullBase, 88))
            box.set_border_color(activeDemand, color.new(bullBase, 8))
            box.set_border_style(activeDemand, line.style_dashed)
            box.set_text_color(activeDemand, demandZoneText)
            line.set_color(activeDemandMid, color.new(bullBase, 22))
            line.set_style(activeDemandMid, line.style_dashed)
        else
            box.set_bgcolor(activeDemand, demandZoneFill)
            box.set_border_color(activeDemand, demandZoneBorder)
            box.set_border_style(activeDemand, line.style_solid)
            box.set_text_color(activeDemand, demandZoneText)
            line.set_color(activeDemandMid, color.new(bullBase, 45))
            line.set_style(activeDemandMid, line.style_dotted)

ribbonBullRetest = bullTrend and low <= k3 and close > k2 and close > open and barstate.isconfirmed
ribbonBearRetest = bearTrend and high >= k3 and close < k2 and close < open and barstate.isconfirmed
bullRetestSignal = ribbonBullRetest or demandRetest
bearRetestSignal = ribbonBearRetest or supplyRetest

var int lastSignalBar = na
rawBuySignal = bullRetestSignal and not bearRetestSignal and barstate.isconfirmed
rawSellSignal = bearRetestSignal and not bullRetestSignal and barstate.isconfirmed
signalSpacingReady = na(lastSignalBar) or bar_index - lastSignalBar > signalSpacingBars
confirmedBuySignal = rawBuySignal and signalSpacingReady
confirmedSellSignal = rawSellSignal and signalSpacingReady
if confirmedBuySignal or confirmedSellSignal
    lastSignalBar := bar_index

signalPad = math.max(atrValue * 0.22, syminfo.mintick * 10.0)
plotshape(showSignals and confirmedBuySignal ? low - signalPad : na, title="Confirmed Buy [JOAT]", style=shape.circle, location=location.absolute, color=color.new(bullBase, 0), text="BUY", textcolor=color.white, size=size.tiny)
plotshape(showSignals and confirmedSellSignal ? high + signalPad : na, title="Confirmed Sell [JOAT]", style=shape.circle, location=location.absolute, color=color.new(bearBase, 0), text="SELL", textcolor=color.white, size=size.tiny)

alertcondition(confirmedBuySignal, title="Kalman Auction Confirmed Buy [JOAT]", message="Kalman Auction Ribbon [JOAT]: confirmed buy retest.")
alertcondition(confirmedSellSignal, title="Kalman Auction Confirmed Sell [JOAT]", message="Kalman Auction Ribbon [JOAT]: confirmed sell retest.")
alertcondition(demandZoneTrigger, title="Lower Deviation Zone [JOAT]", message="Kalman Auction Ribbon [JOAT]: lower deviation zone confirmed.")
alertcondition(supplyZoneTrigger, title="Upper Deviation Zone [JOAT]", message="Kalman Auction Ribbon [JOAT]: upper deviation zone confirmed.")

var dash = table.new(position=position.top_right, columns=2, rows=4, bgcolor=color.new(color.black, 84), border_color=color.new(color.white, 82), border_width=1)

if barstate.islast
    stateText = bullTrend ? "Rising" : bearTrend ? "Falling" : calmState ? "Neutral" : "Mixed"
    stateColor = bullTrend ? color.new(bullBase, 0) : bearTrend ? color.new(bearBase, 0) : color.new(neutralBase, 0)
    distanceText = str.tostring((close - ribbonMid) / math.max(atrValue, syminfo.mintick), "#.00") + " ATR"
    retestText = confirmedBuySignal ? "Buy" : confirmedSellSignal ? "Sell" : "None"
    retestColor = confirmedBuySignal ? color.new(bullBase, 0) : confirmedSellSignal ? color.new(bearBase, 0) : color.new(neutralBase, 0)
    table.cell(dash, 0, 0, showDashboard ? "State" : "", text_color=color.new(color.white, 15), bgcolor=color.new(color.black, 80), text_size=size.small)
    table.cell(dash, 1, 0, showDashboard ? stateText : "", text_color=stateColor, bgcolor=color.new(color.black, 80), text_size=size.small)
    table.cell(dash, 0, 1, showDashboard ? "Power" : "", text_color=color.new(color.white, 15), bgcolor=color.new(color.black, 88), text_size=size.small)
    table.cell(dash, 1, 1, showDashboard ? str.tostring(math.abs(trendScore), "#") : "", text_color=ribbonColor, bgcolor=color.new(color.black, 88), text_size=size.small)
    table.cell(dash, 0, 2, showDashboard ? "Distance" : "", text_color=color.new(color.white, 15), bgcolor=color.new(color.black, 88), text_size=size.small)
    table.cell(dash, 1, 2, showDashboard ? distanceText : "", text_color=color.new(color.white, 5), bgcolor=color.new(color.black, 88), text_size=size.small)
    table.cell(dash, 0, 3, showDashboard ? "Retest" : "", text_color=color.new(color.white, 15), bgcolor=color.new(color.black, 88), text_size=size.small)
    table.cell(dash, 1, 3, showDashboard ? retestText : "", text_color=retestColor, bgcolor=color.new(color.black, 88), text_size=size.small)
````
