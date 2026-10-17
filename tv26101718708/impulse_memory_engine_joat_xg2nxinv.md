# Impulse Memory Engine [JOAT]

- url: https://www.tradingview.com/script/XG2Nxinv-Impulse-Memory-Engine-JOAT/
- type: indicator
- pine_id: PUB;ed23bca93834461e872110b0c6baa537
- version: 1.0

## Description

Impulse Memory Engine is an open-source Pine Script v6 overlay that measures fresh displacement, stores directional memory with exponential decay, and displays adaptive retest rails after significant impulse bars. It is built to answer a simple question: is the most recent meaningful impulse still fresh enough to matter?

The script blends MAD-style distance, ATR, trend basis, and decay memory. This creates a visual layer that distinguishes fresh impulse, fading impulse, and reset conditions while keeping the chart clean.

[image]https://www.tradingview.com/x/RNaJ7B8l/[/image]

[b]Core Concepts[/b]

[b]1. MAD and ATR Normalized Displacement[/b]

The script estimates a robust distance unit using median absolute deviation and ATR. The impulse score is the one-bar displacement divided by this unit.

[pine]
medianSource = ta.median(sourceInput, madLengthInput)
madDistance = ta.median(math.abs(sourceInput - medianSource), madLengthInput)
unitDistance = math.max(atrValue * 0.35, madDistance * 1.4826)
impulseRaw = safeRatio(sourceInput - sourceInput[1], unitDistance)
[/pine]

[b]2. Trend Basis and Fast Track[/b]

A slower EMA defines the trend basis while a faster EMA tracks near-term movement. The distance between them contributes to the heat score.

[b]3. Freshness Decay[/b]

When a bullish or bearish impulse appears, the script measures bars since that impulse and applies exponential decay. Fresh impulses have more weight; older impulses fade naturally.

[pine]
bullBars = ta.barssince(bullImpulse)
bearBars = ta.barssince(bearImpulse)
bullFresh = na(bullBars) ? 0.0 : math.exp(-bullBars / decayLengthInput)
bearFresh = na(bearBars) ? 0.0 : math.exp(-bearBars / decayLengthInput)
memorySigned = bullFresh - bearFresh
[/pine]

[b]4. Adaptive Bands[/b]

The trend band widens when memory strength increases. This helps separate quiet reset states from active impulse regimes.

[b]5. Retest Rails[/b]

After a fresh impulse, the script stores a rail near the impulse bar. A confirmed retest occurs when price revisits the rail while memory remains directionally active.

[b]Features[/b]

[list]
[*][b]Impulse score:[/b] Measures displacement relative to MAD and ATR distance
[*][b]Memory decay model:[/b] Tracks whether the last strong impulse is fresh or fading
[*][b]Adaptive trend cloud:[/b] EMA basis and fast track are filled by memory state
[*][b]Dynamic bands:[/b] Band width expands with volatility and impulse memory
[*][b]Retest rails:[/b] Bull and bear rails remain visible for a configurable window
[*][b]Rail labels:[/b] Active bull and bear rails are labeled at the right edge with spacing protection when both rails are close
[*][b]Confirmed buy/sell labels:[/b] Compact BUY and SELL labels mark fresh impulse continuation or rail retest continuation on confirmed bars
[*][b]Heat candles:[/b] Optional candle coloring by impulse and memory strength
[*][b]Dashboard:[/b] Top-right panel shows impulse, memory, state, and rail status
[*][b]Alerts:[/b] Fresh impulse, rail retest, confirmed buy, and confirmed sell conditions
[/list]

[b]Input Parameters[/b]

[list]
[*]Source: Price source used for calculations
[*]Trend Length: Slow EMA basis length
[*]Fast Track Length: Faster EMA used inside the cloud
[*]MAD Length: Median distance length
[*]ATR Length: ATR distance length
[*]Band Multiplier: Scales adaptive bands
[*]Impulse Threshold: Minimum normalized displacement for a fresh impulse
[*]Memory Half Window: Controls decay speed
[*]Rail Visibility: Bars a rail remains eligible for retests
[*]Heat Candles: Enables candle coloring
[*]Dashboard: Shows or hides the top-right dashboard
[*]Rail Labels: Shows active bull and bear rail labels
[*]Buy/Sell Signals: Shows confirmed continuation signal labels
[*]Palette: Selects the local JOAT color preset
[*]Dashboard: Shows the panel
[*]Palette: Selects color pair
[/list]

[b]How to Use This Indicator[/b]

[b]Step 1: Read the Memory State[/b]
The dashboard state shows whether the script is tracking bull memory, bear memory, or resetting.

[b]Step 2: Watch Fresh Impulse Events[/b]
Fresh impulse alerts show that displacement exceeded the configured threshold in the direction of the trend basis.

[b]Step 3: Use Retest Rails[/b]
Rails act as reference levels after impulse. A retest is most meaningful when the dashboard memory state still agrees with the rail direction.

[b]Indicator Limitations[/b]

[list]
[*]Impulse detection is sensitive to the selected source and threshold
[*]Very low volatility can make normalized movement appear larger
[*]A rail retest is contextual and does not define risk by itself
[*]The memory model fades old impulses; it does not predict the next impulse
[/list]

[b]Originality Statement[/b]

Impulse Memory Engine is original in its use of robust distance normalization, exponential impulse decay, adaptive bands, and retest rails in one compact overlay. It is built with original Pine v6 logic and public mathematical functions.

[b]Disclaimer[/b]

This script is provided for educational and informational use only. It is not financial advice or a recommendation to buy or sell any financial instrument. Trading involves substantial risk of loss. Impulse readings can fail during choppy markets or sudden volatility shifts. Always use independent analysis and proper risk management.

-Made with passion by jackofalltrades

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
indicator("Impulse Memory Engine [JOAT]", shorttitle = "Impulse Memory [JOAT]", overlay = true, max_labels_count = 80)

sourceInput = input.source(close, "Source")
trendLengthInput = input.int(34, "Trend Length", minval = 5)
fastLengthInput = input.int(13, "Fast Track Length", minval = 2)
madLengthInput = input.int(21, "MAD Length", minval = 5)
atrLengthInput = input.int(14, "ATR Length", minval = 2)
bandMultInput = input.float(1.55, "Band Multiplier", minval = 0.25, step = 0.05)
impulseThresholdInput = input.float(1.25, "Impulse Threshold", minval = 0.25, step = 0.05)
decayLengthInput = input.int(12, "Memory Half Window", minval = 2)
railWindowInput = input.int(28, "Rail Visibility", minval = 5)
heatBarsInput = input.bool(true, "Heat Candles")
dashboardInput = input.bool(true, "Dashboard")
railLabelsInput = input.bool(true, "Rail Labels")
signalLabelsInput = input.bool(true, "Buy/Sell Signals")
paletteInput = input.string("Aqua Rose", "Palette", options = ["Aqua Rose", "Neon Desk", "Mint Pulse", "VWAP Field"])

paletteBull(string preset) =>
    switch preset
        "Aqua Rose" => #00C8FF
        "Neon Desk" => #00ff00
        "Mint Pulse" => #00FFD5
        "VWAP Field" => #1ac200
        => #00C8FF

paletteBear(string preset) =>
    switch preset
        "Aqua Rose" => #FF005D
        "Neon Desk" => #ff0000
        "Mint Pulse" => #FF0066
        "VWAP Field" => #ff4040
        => #FF005D

clamp(float value, float floorValue, float ceilingValue) =>
    math.min(math.max(value, floorValue), ceilingValue)

safeRatio(float numerator, float denominator) =>
    denominator == 0.0 ? 0.0 : numerator / denominator

fade(color baseColor, float strength, int calmAlpha, int strongAlpha) =>
    int alpha = int(math.round(calmAlpha - (calmAlpha - strongAlpha) * clamp(strength, 0.0, 1.0)))
    color.new(baseColor, alpha)

bullColor = paletteBull(paletteInput)
bearColor = paletteBear(paletteInput)
neutralColor = color.rgb(128, 136, 146)

medianSource = ta.median(sourceInput, madLengthInput)
madDistance = ta.median(math.abs(sourceInput - medianSource), madLengthInput)
atrValue = ta.atr(atrLengthInput)
unitDistance = math.max(atrValue * 0.35, madDistance * 1.4826)
impulseRaw = safeRatio(sourceInput - sourceInput[1], unitDistance)

trendBasis = ta.ema(sourceInput, trendLengthInput)
fastTrack = ta.ema(sourceInput, fastLengthInput)
trendSpread = fastTrack - trendBasis
spreadScore = safeRatio(trendSpread, unitDistance)

bullImpulse = impulseRaw > impulseThresholdInput and sourceInput > trendBasis
bearImpulse = impulseRaw < -impulseThresholdInput and sourceInput < trendBasis
bullBars = ta.barssince(bullImpulse)
bearBars = ta.barssince(bearImpulse)
bullFresh = na(bullBars) ? 0.0 : math.exp(-bullBars / decayLengthInput)
bearFresh = na(bearBars) ? 0.0 : math.exp(-bearBars / decayLengthInput)
memorySigned = bullFresh - bearFresh
memoryStrength = clamp(memorySigned * 100.0, -100.0, 100.0)
absMemory = math.abs(memorySigned)

adaptiveDistance = (atrValue * 0.65 + madDistance * 1.4826 * 0.35) * bandMultInput * (1.0 + absMemory * 0.55)
upperBand = trendBasis + adaptiveDistance
lowerBand = trendBasis - adaptiveDistance
cloudTop = math.max(fastTrack, trendBasis)
cloudBottom = math.min(fastTrack, trendBasis)

heatScore = clamp((impulseRaw * 38.0) + (spreadScore * 30.0) + (memorySigned * 32.0), -100.0, 100.0)
heatBase = color.from_gradient(heatScore, -100.0, 100.0, bearColor, bullColor)
barcolor(heatBarsInput ? fade(heatBase, math.abs(heatScore) / 100.0, 72, 18) : na)

var float bullRail = na
var float bearRail = na
if bullImpulse
    bullRail := close - adaptiveDistance * 0.38
if bearImpulse
    bearRail := close + adaptiveDistance * 0.38

bullRailLive = not na(bullBars) and bullBars <= railWindowInput ? bullRail : na
bearRailLive = not na(bearBars) and bearBars <= railWindowInput ? bearRail : na
bullRetest = not na(bullRailLive) and low <= bullRailLive and close > bullRailLive and memorySigned > 0.20
bearRetest = not na(bearRailLive) and high >= bearRailLive and close < bearRailLive and memorySigned < -0.20
bullMemoryTrend = memorySigned > 0.18 and fastTrack > trendBasis and close > trendBasis
bearMemoryTrend = memorySigned < -0.18 and fastTrack < trendBasis and close < trendBasis
buySignalRaw = (bullImpulse and bullMemoryTrend) or (bullRetest and bullMemoryTrend)
sellSignalRaw = (bearImpulse and bearMemoryTrend) or (bearRetest and bearMemoryTrend)
confirmedBuySignal = signalLabelsInput and barstate.isconfirmed and buySignalRaw and not buySignalRaw[1]
confirmedSellSignal = signalLabelsInput and barstate.isconfirmed and sellSignalRaw and not sellSignalRaw[1]

cloudColor = memorySigned >= 0.0 ? fade(bullColor, absMemory, 91, 72) : fade(bearColor, absMemory, 91, 72)
bandColor = color.from_gradient(memoryStrength, -100.0, 100.0, color.new(bearColor, 18), color.new(bullColor, 18))
railBullColor = color.from_gradient(safeRatio(close - bullRailLive, adaptiveDistance) * 100.0, -100.0, 100.0, color.new(bearColor, 35), color.new(bullColor, 8))
railBearColor = color.from_gradient(safeRatio(bearRailLive - close, adaptiveDistance) * 100.0, -100.0, 100.0, color.new(bullColor, 35), color.new(bearColor, 8))

fastPlot = plot(fastTrack, "Fast Track", color = color.new(bandColor, 0), linewidth = 2)
basisPlot = plot(trendBasis, "Trend Basis", color = color.new(neutralColor, 20), linewidth = 2)
upperPlot = plot(upperBand, "Adaptive Upper Band", color = color.new(bandColor, 42))
lowerPlot = plot(lowerBand, "Adaptive Lower Band", color = color.new(bandColor, 42))
plot(bullRailLive, "Bull Retest Rail", color = railBullColor, linewidth = 2, style = plot.style_linebr)
plot(bearRailLive, "Bear Retest Rail", color = railBearColor, linewidth = 2, style = plot.style_linebr)

fill(fastPlot, basisPlot, color = cloudColor, title = "Trend Cloud")
fill(upperPlot, lowerPlot, color = memorySigned >= 0.0 ? color.new(bullColor, 93) : color.new(bearColor, 93), title = "Adaptive Band Field")

labelPad = math.max(atrValue * 0.24, syminfo.mintick * 8.0)
railsCrowded = not na(bullRailLive) and not na(bearRailLive) and math.abs(bullRailLive - bearRailLive) < labelPad * 2.0
bullRailLabelY = railsCrowded ? bullRailLive - labelPad : bullRailLive
bearRailLabelY = railsCrowded ? bearRailLive + labelPad : bearRailLive

var label bullRailLabel = na
var label bearRailLabel = na
if barstate.islast
    if railLabelsInput and not na(bullRailLive)
        if na(bullRailLabel)
            bullRailLabel := label.new(x = bar_index + 1, y = bullRailLabelY, text = "Bull Rail", xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = color.new(bullColor, 18), textcolor = chart.fg_color, size = size.tiny)
        else
            label.set_xy(bullRailLabel, bar_index + 1, bullRailLabelY)
            label.set_text(bullRailLabel, "Bull Rail")
            label.set_color(bullRailLabel, color.new(bullColor, 18))
            label.set_textcolor(bullRailLabel, chart.fg_color)
            label.set_size(bullRailLabel, size.tiny)
    else if not na(bullRailLabel)
        label.delete(bullRailLabel)
        bullRailLabel := na
    if railLabelsInput and not na(bearRailLive)
        if na(bearRailLabel)
            bearRailLabel := label.new(x = bar_index + 1, y = bearRailLabelY, text = "Bear Rail", xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = color.new(bearColor, 18), textcolor = chart.fg_color, size = size.tiny)
        else
            label.set_xy(bearRailLabel, bar_index + 1, bearRailLabelY)
            label.set_text(bearRailLabel, "Bear Rail")
            label.set_color(bearRailLabel, color.new(bearColor, 18))
            label.set_textcolor(bearRailLabel, chart.fg_color)
            label.set_size(bearRailLabel, size.tiny)
    else if not na(bearRailLabel)
        label.delete(bearRailLabel)
        bearRailLabel := na

var array<label> signalLabels = array.new_label()
if confirmedBuySignal
    buyLabel = label.new(x = bar_index, y = low - labelPad, text = "BUY", xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_center, color = color.new(bullColor, 4), textcolor = chart.fg_color, size = size.tiny)
    array.push(signalLabels, buyLabel)
if confirmedSellSignal
    sellLabel = label.new(x = bar_index, y = high + labelPad, text = "SELL", xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_center, color = color.new(bearColor, 4), textcolor = chart.fg_color, size = size.tiny)
    array.push(signalLabels, sellLabel)
while array.size(signalLabels) > 24
    oldSignalLabel = array.shift(signalLabels)
    label.delete(oldSignalLabel)

freshBullAlert = bullImpulse and barstate.isconfirmed
freshBearAlert = bearImpulse and barstate.isconfirmed
bullRetestAlert = bullRetest and barstate.isconfirmed
bearRetestAlert = bearRetest and barstate.isconfirmed
confirmedBuyAlert = confirmedBuySignal
confirmedSellAlert = confirmedSellSignal
alertcondition(freshBullAlert, "Fresh Bull Impulse [JOAT]", "Fresh bull impulse confirmed on {{ticker}} {{interval}}.")
alertcondition(freshBearAlert, "Fresh Bear Impulse [JOAT]", "Fresh bear impulse confirmed on {{ticker}} {{interval}}.")
alertcondition(bullRetestAlert, "Bull Rail Retest [JOAT]", "Bull rail retest confirmed on {{ticker}} {{interval}}.")
alertcondition(bearRetestAlert, "Bear Rail Retest [JOAT]", "Bear rail retest confirmed on {{ticker}} {{interval}}.")
alertcondition(confirmedBuyAlert, "Confirmed Buy [JOAT]", "Confirmed impulse memory buy on {{ticker}} {{interval}}.")
alertcondition(confirmedSellAlert, "Confirmed Sell [JOAT]", "Confirmed impulse memory sell on {{ticker}} {{interval}}.")

var table dash = table.new(position.top_right, 2, 4, frame_color = color.new(neutralColor, 45), border_color = color.new(neutralColor, 70), border_width = 1)
if dashboardInput and barstate.islast
    stateText = memorySigned > 0.18 ? "Bull Memory" : memorySigned < -0.18 ? "Bear Memory" : "Resetting"
    railText = confirmedBuySignal ? "Buy" : confirmedSellSignal ? "Sell" : bullRetest ? "Bull Retest" : bearRetest ? "Bear Retest" : "Waiting"
    strengthText = str.tostring(math.round(memoryStrength)) + "%"
    impulseText = str.tostring(impulseRaw, "#.##")
    table.cell(dash, 0, 0, "Impulse", bgcolor = color.new(neutralColor, 80), text_color = chart.fg_color, text_size = size.small)
    table.cell(dash, 1, 0, impulseText, bgcolor = fade(heatBase, math.abs(heatScore) / 100.0, 88, 58), text_color = chart.fg_color, text_size = size.small)
    table.cell(dash, 0, 1, "Memory", bgcolor = color.new(neutralColor, 80), text_color = chart.fg_color, text_size = size.small)
    table.cell(dash, 1, 1, strengthText, bgcolor = fade(bandColor, absMemory, 88, 55), text_color = chart.fg_color, text_size = size.small)
    table.cell(dash, 0, 2, "State", bgcolor = color.new(neutralColor, 80), text_color = chart.fg_color, text_size = size.small)
    table.cell(dash, 1, 2, stateText, bgcolor = cloudColor, text_color = chart.fg_color, text_size = size.small)
    table.cell(dash, 0, 3, "Rail", bgcolor = color.new(neutralColor, 80), text_color = chart.fg_color, text_size = size.small)
    table.cell(dash, 1, 3, railText, bgcolor = color.new(neutralColor, 84), text_color = chart.fg_color, text_size = size.small)
````
