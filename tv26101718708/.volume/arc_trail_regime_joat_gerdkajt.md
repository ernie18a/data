# Arc Trail Regime [JOAT]

- url: https://www.tradingview.com/script/GErdkajt-Arc-Trail-Regime-JOAT/
- type: indicator
- pine_id: PUB;4aeea260219c45faa622ae1fb3a1ece5
- version: 1.0

## Description

Arc Trail Regime is an open-source Pine Script v6 overlay that builds an accelerating trail around an adaptive EMA arc and gates directional flips with VWAP location. It is designed to show when price has crossed a dynamic trailing level while the broader value anchor agrees with the new side.

The script focuses on a smooth regime trail rather than many signal markers. It displays the active arc, a soft cloud, optional gradient candles, and right-edge shelf levels created after confirmed flips.

[image]https://www.tradingview.com/x/9JWp671C/[/image]

[b]Core Concepts[/b]

[b]1. Adaptive Arc Core[/b]

The core blends fast and slow EMA curves. The blend weight increases when recent speed and volatility expansion increase, which makes the arc respond faster during active movement.

[pine]
speedRaw = math.abs(ta.ema(ta.change(sourceInput), 4)) / atrValue
volRatio = nz(ta.ema(atrValue, 5) / ta.ema(atrValue, 55), 1.0)
curveWeight = f_clamp(0.38 + speedNorm * 0.18 + volSpeed * 0.22, 0.25, 0.82)
arcCore = ta.ema(slowArc + (fastArc - slowArc) * curveWeight, 3)
[/pine]

[b]2. VWAP Gate[/b]

Bull flips require price to be above VWAP. Bear flips require price to be below VWAP. This keeps the trail aligned with a basic value-location filter.

[b]3. Accelerating Trail Width[/b]

The trail distance uses ATR and a volatility speed boost. During active movement, the trail can tighten within bounds so it reacts faster to regime changes.

[b]4. Confirmed Flip Shelves[/b]

When a confirmed regime flip occurs, the script draws a shelf line near the flip bar. The shelf remains active until price invalidates it.

[b]5. Distance Candles[/b]

Candles can be colored from bearish to bullish based on their normalized distance from the active trail.

[b]Features[/b]

[list]
[*][b]Adaptive arc core:[/b] Blends fast and slow curves by speed and volatility
[*][b]VWAP-gated flips:[/b] Direction changes require price location agreement
[*][b]ATR trail:[/b] Trail distance scales with chart volatility
[*][b]Arc cloud:[/b] Soft band around the active trail
[*][b]Active shelves:[/b] Right-edge support/resistance references after confirmed flips
[*][b]Confirmed buy/sell flip markers:[/b] Compact BUY and SELL dots are offset away from candles and only print after confirmed regime flips
[*][b]Gradient candles:[/b] Optional candle coloring by trail distance
[*][b]Dashboard:[/b] Shows regime, VWAP side, distance, speed, and shelf status
[*][b]Alerts:[/b] Confirmed bull flip and confirmed bear flip
[/list]

[b]Input Parameters[/b]

[b]Visuals:[/b]
[list]
[*]Palette Preset: Selects bull and bear colors
[*]Arc Cloud: Shows the trail cloud
[*]Gradient Candles: Enables candle coloring
[*]Confirmed Flip Signals: Shows compact BUY and SELL flip markers
[*]Active Shelves: Shows flip shelf lines and labels
[/list]

[b]Engine:[/b]
[list]
[*]Source: Price source
[*]Inner Curve Length: Fast EMA length
[*]Outer Curve Length: Slow EMA length
[*]ATR Length: Volatility length
[*]Base Trail Width: Starting ATR trail multiplier
[*]Volatility Speed Boost: Controls how much expansion affects the trail
[/list]

[b]How to Use This Indicator[/b]

[b]Step 1: Read the Active Regime[/b]
The dashboard shows Bull or Bear based on the active trail side.

[b]Step 2: Confirm VWAP Location[/b]
The VWAP row shows whether price is above or below the value gate used by the script.

[b]Step 3: Monitor Shelves[/b]
Shelf lines are created after flips and can act as visual invalidation references.

[b]Indicator Limitations[/b]

[list]
[*]Trail systems can whipsaw during sideways markets
[*]VWAP behavior varies across sessions and symbols
[*]A shelf is a visual reference, not a complete stop model
[*]Fast volatility shifts can temporarily widen or tighten the trail abruptly
[/list]

[b]Originality Statement[/b]

Arc Trail Regime is original in its adaptive arc weighting, VWAP-gated regime flips, speed-sensitive trail width, and active shelf visualization. It is built with original Pine v6 code and public chart data.

[b]Disclaimer[/b]

This script is provided for educational and informational use only. It is not financial advice or a recommendation to buy or sell any financial instrument. Trading involves substantial risk of loss. Trail flips can fail in range conditions or during abrupt volatility changes. Always use independent analysis and proper risk management.

-Made with passion by jackofalltrades

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
indicator("Arc Trail Regime [JOAT]", overlay = true, max_lines_count = 20, max_labels_count = 20, max_boxes_count = 5)

f_clamp(float value, float lo, float hi) =>
    math.max(lo, math.min(hi, value))

f_bullColor(string preset) =>
    switch preset
        "Neon Desk" => #00ff00
        "Mint Pulse" => #00FFD5
        "VWAP Field" => #1ac200
        => #00C8FF

f_bearColor(string preset) =>
    switch preset
        "Neon Desk" => #ff0000
        "Mint Pulse" => #FF0066
        "VWAP Field" => #ff4040
        => #FF005D

paletteInput = input.string("Aqua Rose", "Palette preset", options = ["Aqua Rose", "Neon Desk", "Mint Pulse", "VWAP Field"], group = "Visuals")
showCloudInput = input.bool(true, "Arc cloud", group = "Visuals")
showCandlesInput = input.bool(true, "Gradient candles", group = "Visuals")
showSignalsInput = input.bool(true, "Confirmed flip signals", group = "Visuals")
showShelvesInput = input.bool(true, "Active shelves", group = "Visuals")

sourceInput = input.source(hlc3, "Source", group = "Engine")
fastLenInput = input.int(13, "Inner curve length", minval = 2, group = "Engine")
slowLenInput = input.int(34, "Outer curve length", minval = 5, group = "Engine")
atrLenInput = input.int(14, "ATR length", minval = 1, group = "Engine")
baseMultInput = input.float(2.2, "Base trail width", minval = 0.3, step = 0.1, group = "Engine")
speedBoostInput = input.float(0.7, "Volatility speed boost", minval = 0.0, maxval = 2.0, step = 0.05, group = "Engine")

bullBase = f_bullColor(paletteInput)
bearBase = f_bearColor(paletteInput)
neutralColor = color.rgb(210, 215, 225)

atrSeed = math.max(high - low, syminfo.mintick)
atrValue = math.max(nz(ta.atr(atrLenInput), atrSeed), syminfo.mintick)
vwapRaw = ta.vwap(sourceInput)
vwapLine = nz(vwapRaw, ta.ema(sourceInput, slowLenInput))

fastArc = ta.ema(sourceInput, fastLenInput)
slowArc = ta.ema(sourceInput, slowLenInput)
speedRaw = math.abs(ta.ema(ta.change(sourceInput), 4)) / atrValue
speedNorm = f_clamp(speedRaw, 0.0, 2.5)
volRatio = nz(ta.ema(atrValue, 5) / ta.ema(atrValue, 55), 1.0)
volSpeed = f_clamp((volRatio - 1.0) * speedBoostInput, 0.0, 1.3)
curveWeight = f_clamp(0.38 + speedNorm * 0.18 + volSpeed * 0.22, 0.25, 0.82)
arcCore = ta.ema(slowArc + (fastArc - slowArc) * curveWeight, 3)

bandMult = f_clamp(baseMultInput * (1.0 - volSpeed * 0.22), baseMultInput * 0.55, baseMultInput * 1.25)
arcSlope = ta.ema(ta.change(arcCore), 3)
longBand = arcCore - atrValue * bandMult + math.max(arcSlope, 0.0) * (2.0 + volSpeed)
shortBand = arcCore + atrValue * bandMult + math.min(arcSlope, 0.0) * (2.0 + volSpeed)

var int regime = 0
var float arcTrail = na

previousRegime = nz(regime[1], close >= arcCore ? 1 : -1)
previousTrail = nz(arcTrail[1], close)
curveUp = arcCore >= nz(arcCore[1], arcCore)
curveDown = arcCore <= nz(arcCore[1], arcCore)
filterBull = close >= vwapLine
filterBear = close <= vwapLine
flipBullRaw = previousRegime <= 0 and close > previousTrail and filterBull and curveUp
flipBearRaw = previousRegime >= 0 and close < previousTrail and filterBear and curveDown

if na(arcTrail[1])
    regime := close >= arcCore ? 1 : -1
    arcTrail := regime == 1 ? longBand : shortBand
else if previousRegime == 1
    if flipBearRaw
        regime := -1
        arcTrail := shortBand
    else
        regime := 1
        arcTrail := math.max(longBand, previousTrail)
else
    if flipBullRaw
        regime := 1
        arcTrail := longBand
    else
        regime := -1
        arcTrail := math.min(shortBand, previousTrail)

confirmedBullFlip = barstate.isconfirmed and regime == 1 and previousRegime == -1
confirmedBearFlip = barstate.isconfirmed and regime == -1 and previousRegime == 1

distanceAtr = f_clamp((close - arcTrail) / atrValue, -2.5, 2.5)
trailColor = regime == 1 ? bullBase : bearBase
candleColor = color.from_gradient(distanceAtr, -2.5, 2.5, color.new(bearBase, 12), color.new(bullBase, 12))
cloudWidth = atrValue * (0.34 + volSpeed * 0.26)

upperPlot = plot(showCloudInput ? arcTrail + cloudWidth : na, "Arc upper", color = color.new(trailColor, 86), linewidth = 1)
lowerPlot = plot(showCloudInput ? arcTrail - cloudWidth : na, "Arc lower", color = color.new(trailColor, 86), linewidth = 1)
trailPlot = plot(arcTrail, "Arc trail", color = color.new(trailColor, 0), linewidth = 2)
corePlot = plot(arcCore, "Arc center", color = color.new(neutralColor, 72), linewidth = 1)
plot(vwapLine, "VWAP gate", color = color.new(neutralColor, 78), linewidth = 1)
fill(upperPlot, lowerPlot, color.new(trailColor, 89), "Arc cloud")
fill(trailPlot, corePlot, color.new(trailColor, 92), "Arc shade")
barcolor(showCandlesInput ? candleColor : na)

signalOffset = atrValue * (0.34 + volSpeed * 0.18)
plotshape(showSignalsInput and confirmedBullFlip ? low - signalOffset : na, "Confirmed Buy [JOAT]", text = "BUY", style = shape.circle, location = location.absolute, color = color.new(bullBase, 0), textcolor = color.white, size = size.tiny)
plotshape(showSignalsInput and confirmedBearFlip ? high + signalOffset : na, "Confirmed Sell [JOAT]", text = "SELL", style = shape.circle, location = location.absolute, color = color.new(bearBase, 0), textcolor = color.white, size = size.tiny)

var line bullShelfLine = na
var line bearShelfLine = na
var label bullShelfLabel = na
var label bearShelfLabel = na
var float bullShelf = na
var float bearShelf = na

if showShelvesInput and confirmedBullFlip
    if not na(bullShelfLine)
        line.delete(bullShelfLine)
    if not na(bullShelfLabel)
        label.delete(bullShelfLabel)
    bullShelf := low - atrValue * 0.15
    bullShelfLine := line.new(bar_index, bullShelf, bar_index + 1, bullShelf, xloc = xloc.bar_index, extend = extend.right, color = color.new(bullBase, 18), width = 2)
    bullShelfLabel := label.new(bar_index + 1, bullShelf, "B shelf", xloc = xloc.bar_index, style = label.style_label_left, color = color.new(bullBase, 16), textcolor = color.white, size = size.tiny)

if showShelvesInput and confirmedBearFlip
    if not na(bearShelfLine)
        line.delete(bearShelfLine)
    if not na(bearShelfLabel)
        label.delete(bearShelfLabel)
    bearShelf := high + atrValue * 0.15
    bearShelfLine := line.new(bar_index, bearShelf, bar_index + 1, bearShelf, xloc = xloc.bar_index, extend = extend.right, color = color.new(bearBase, 18), width = 2)
    bearShelfLabel := label.new(bar_index + 1, bearShelf, "S shelf", xloc = xloc.bar_index, style = label.style_label_left, color = color.new(bearBase, 16), textcolor = color.white, size = size.tiny)

if barstate.isconfirmed and not na(bullShelf) and close < bullShelf
    if not na(bullShelfLine)
        line.delete(bullShelfLine)
    if not na(bullShelfLabel)
        label.delete(bullShelfLabel)
    bullShelf := na
    bullShelfLine := na
    bullShelfLabel := na

if barstate.isconfirmed and not na(bearShelf) and close > bearShelf
    if not na(bearShelfLine)
        line.delete(bearShelfLine)
    if not na(bearShelfLabel)
        label.delete(bearShelfLabel)
    bearShelf := na
    bearShelfLine := na
    bearShelfLabel := na

if not na(bullShelfLabel)
    label.set_x(bullShelfLabel, bar_index + 1)
if not na(bearShelfLabel)
    label.set_x(bearShelfLabel, bar_index + 1)

var table dash = table.new(position.top_right, 2, 5, border_color = color.new(neutralColor, 78), border_width = 1)

if barstate.islast
    regimeText = regime == 1 ? "Bull" : "Bear"
    vwapText = filterBull ? "Above" : filterBear ? "Below" : "At gate"
    distText = str.tostring(distanceAtr, "#.##") + " ATR"
    speedText = str.tostring(speedNorm + volSpeed, "#.##")
    table.cell(dash, 0, 0, "Arc Trail", text_color = color.white, bgcolor = color.new(trailColor, 15), text_size = size.small)
    table.cell(dash, 1, 0, regimeText, text_color = color.white, bgcolor = color.new(trailColor, 15), text_size = size.small)
    table.cell(dash, 0, 1, "VWAP", text_color = neutralColor, bgcolor = color.new(color.black, 72), text_size = size.small)
    table.cell(dash, 1, 1, vwapText, text_color = filterBull ? bullBase : bearBase, bgcolor = color.new(color.black, 72), text_size = size.small)
    table.cell(dash, 0, 2, "Distance", text_color = neutralColor, bgcolor = color.new(color.black, 72), text_size = size.small)
    table.cell(dash, 1, 2, distText, text_color = candleColor, bgcolor = color.new(color.black, 72), text_size = size.small)
    table.cell(dash, 0, 3, "Speed", text_color = neutralColor, bgcolor = color.new(color.black, 72), text_size = size.small)
    table.cell(dash, 1, 3, speedText, text_color = color.from_gradient(speedNorm + volSpeed, 0.0, 3.0, neutralColor, bullBase), bgcolor = color.new(color.black, 72), text_size = size.small)
    table.cell(dash, 0, 4, "Shelf", text_color = neutralColor, bgcolor = color.new(color.black, 72), text_size = size.small)
    table.cell(dash, 1, 4, not na(bullShelf) or not na(bearShelf) ? "Active" : "None", text_color = not na(bullShelf) ? bullBase : not na(bearShelf) ? bearBase : neutralColor, bgcolor = color.new(color.black, 72), text_size = size.small)

alertcondition(confirmedBullFlip, "Arc Trail Bull Flip [JOAT]", "Arc Trail Regime [JOAT]: confirmed bull flip")
alertcondition(confirmedBearFlip, "Arc Trail Bear Flip [JOAT]", "Arc Trail Regime [JOAT]: confirmed bear flip")
````
