# Aureon Pressure Lens [JOAT]

- url: https://www.tradingview.com/script/kTbzkWin-Aureon-Pressure-Lens-JOAT/
- type: indicator
- pine_id: PUB;5895d9529dcd48d080bbe5bc0a29ff36
- version: 1.0

## Description

[b]Aureon Pressure Lens [JOAT][/b]

[b]Introduction[/b]

Aureon Pressure Lens is an open-source pressure oscillator designed to classify directional participation, conviction, and transition states in a separate pane. It blends price impulse, EMA structure, momentum, range location, candle body pressure, and relative volume into one bounded score.

The problem it solves is signal quality. A single oscillator can fire during weak, low-participation moves. Aureon Pressure Lens requires pressure, signal-line behavior, relative volume, and component consensus to align before confirmed buy or sell labels appear.

[image]https://www.tradingview.com/x/5AkSEdSS/[/image]

[b]Core Concepts[/b]

[b]1. Multi-Component Pressure Blend[/b]

The oscillator uses several independent inputs: impulse from prior price, fast/slow structural slope, normalized momentum, range position, and candle body direction.

[b]2. Tanh Normalization[/b]

Each component is normalized into a stable bounded range so one volatile input does not dominate the entire reading.

[pine]
pressureScore = f_tanh(pressureBlend * 1.60) * 100.0
signalLine    = ta.ema(pressureScore, signalLength)
[/pine]

[b]3. Consensus Filter[/b]

The confidence reading measures how closely the components agree. A signal must satisfy the minimum conviction threshold before it can print.

[b]4. Relative Volume Participation[/b]

The script measures current volume against a moving average and uses that reading as a participation gate. The default is permissive enough for broad use while still filtering extremely quiet conditions.

[b]Features[/b]

[list]
[*][b]Separate-pane pressure score:[/b] Bounded -100 to +100 directional pressure reading
[*][b]Signal line:[/b] Smoothed reference for pressure resets and crossovers
[*][b]Gradient pressure color:[/b] Score color transitions between bearish, neutral, and bullish states
[*][b]Pressure cloud:[/b] Optional fill between pressure and signal line
[*][b]Confirmed BUY/SELL labels:[/b] Closed-bar events filtered by consensus and RVOL
[*][b]Top-right dashboard:[/b] State, bias, pressure, signal, RVOL/conviction, and action
[*][b]Alerts:[/b] Bullish and bearish confirmed pressure resets
[/list]

[b]Input Parameters[/b]

[b]Calculation:[/b]
[list]
[*]Core Lookback: Main analysis window for impulse and range context
[*]Fast Lens / Slow Lens: EMA structure lengths
[*]Signal Lens: Smoothing length for the signal line
[*]Pressure Sensitivity: Normalization intensity
[*]Min Relative Volume: Participation gate for labels
[*]Min Conviction: Minimum component agreement required for labels
[/list]

[b]How to Use This Indicator[/b]

[b]Step 1:[/b] Read the pressure score relative to zero.
[b]Step 2:[/b] Use the cloud and signal line to identify pressure resets.
[b]Step 3:[/b] Check dashboard conviction and RVOL before acting on labels.
[b]Step 4:[/b] Combine with an overlay structure or regime tool for full chart context.

[b]Indicator Limitations[/b]

[list]
[*]The oscillator measures current pressure, not future price direction
[*]Relative volume can behave differently on symbols with limited volume data
[*]Choppy markets can create repeated signal-line crosses
[*]Confirmed labels appear only after the bar closes
[/list]

[b]Originality Statement[/b]

Aureon Pressure Lens is original because it combines impulse, structure, momentum, range position, candle body pressure, relative volume, and component consensus into a single closed-bar pressure engine with a dedicated dashboard. It does not copy third-party source code.

[b]Disclaimer[/b]

This open-source indicator is for educational and informational purposes only. It is not financial advice. Markets can change quickly, and no pressure reading guarantees a future move. Use risk controls and independent analysis.

-Made with passion by jackofalltrades

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
indicator("Aureon Pressure Lens [JOAT]", "APL [JOAT]", overlay = false, precision = 2, max_labels_count = 100)

//------------------------------------------------------------------------------
// Original JOAT implementation
// - Separate-pane pressure oscillator
// - Confirmed-bar signal logic
// - Dashboard summary in the top-right corner
//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
// Helpers
//------------------------------------------------------------------------------
f_clamp(float x, float lo, float hi) =>
    math.max(lo, math.min(hi, x))

f_tanh(float x) =>
    float e2x = math.exp(2.0 * x)
    (e2x - 1.0) / (e2x + 1.0)

f_safe_den(float x) =>
    math.max(math.abs(x), syminfo.mintick)

f_table_pos(string choice) =>
    switch choice
        "Top Right" => position.top_right
        "Bottom Right" => position.bottom_right
        => position.bottom_left

f_table_size(string choice) =>
    switch choice
        "Tiny" => size.tiny
        "Small" => size.small
        "Large" => size.large
        "Huge" => size.huge
        => size.normal

//------------------------------------------------------------------------------
// Inputs
//------------------------------------------------------------------------------
groupCalc = "Calculation"
lenInput = input.int(28, "Core Lookback", minval = 5, group = groupCalc)
fastInput = input.int(8, "Fast Lens", minval = 2, group = groupCalc)
slowInput = input.int(34, "Slow Lens", minval = 5, group = groupCalc)
signalInput = input.int(9, "Signal Lens", minval = 2, group = groupCalc)
sensInput = input.float(1.35, "Pressure Sensitivity", minval = 0.1, step = 0.05, group = groupCalc)
minRvolInput = input.float(0.90, "Min Relative Volume", minval = 0.1, step = 0.05, group = groupCalc)
minAgreeInput = input.float(0.55, "Min Conviction", minval = 0.0, maxval = 1.0, step = 0.05, group = groupCalc)

groupVis = "Visual"
showSignalInput = input.bool(true, "Show Buy/Sell Labels", group = groupVis)
showCloudInput = input.bool(true, "Show Pressure Cloud", group = groupVis)
showZonesInput = input.bool(true, "Show Extreme Zones", group = groupVis)

groupStyle = "Style"
bullInput = input.color(#089981, "Bull Color", group = groupStyle)
bearInput = input.color(#f23645, "Bear Color", group = groupStyle)
neutralInput = input.color(#787b86, "Neutral Color", group = groupStyle)
accentInput = input.color(#7f8c98, "Signal Line", group = groupStyle)

groupDash = "Dashboard"
dashInput = input.bool(true, "Enable Dashboard", group = groupDash)
dashPosInput = input.string("Top Right", "Position", options = ["Top Right", "Bottom Right", "Bottom Left"], group = groupDash)
dashSizeInput = input.string("Normal", "Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = groupDash)

//------------------------------------------------------------------------------
// Core calculations
//------------------------------------------------------------------------------
atrCore = ta.atr(fastInput)
atrMean = ta.ema(atrCore, slowInput)
atrRatio = atrMean > 0.0 ? atrCore / atrMean : 1.0

rangeHi = ta.highest(high, lenInput)
rangeLo = ta.lowest(low, lenInput)
rangeSpan = f_safe_den(rangeHi - rangeLo)
rangeMid = (rangeHi + rangeLo) * 0.5

impulseRaw = (close - nz(close[lenInput], close)) / f_safe_den(atrCore * math.sqrt(lenInput))
slopeRaw = (ta.ema(close, fastInput) - ta.ema(close, slowInput)) / f_safe_den(atrCore)
momentumRaw = ta.roc(close, fastInput) / f_safe_den(ta.stdev(ta.roc(close, fastInput), lenInput))
rangeRaw = ((close - rangeMid) / (rangeSpan * 0.5))
rangeRaw := f_clamp(rangeRaw, -1.0, 1.0)
bodyRaw = (close - open) / f_safe_den(high - low)

volBase = ta.sma(volume, lenInput)
rvol = na(volBase) or volBase <= 0.0 ? 1.0 : volume / volBase
participation = f_clamp((rvol - 0.70) / 2.00, 0.0, 1.0)

normImpulse = f_tanh(impulseRaw * sensInput)
normSlope = f_tanh(slopeRaw * sensInput)
normMomentum = f_tanh(momentumRaw * sensInput)
normRange = f_tanh(rangeRaw * sensInput)
normBody = f_tanh(bodyRaw * sensInput)

// Pressure blend: momentum, structure, range position, candle body, and confirmation weight.
pressureBlend = normImpulse * 0.28 + normSlope * 0.24 + normMomentum * 0.18 + normRange * 0.18 + normBody * 0.12
pressureBlend := pressureBlend + (participation - 0.50) * 0.10

pressureScore = f_tanh(pressureBlend * 1.60) * 100.0
signalLine = ta.ema(pressureScore, signalInput)

consensusRaw = 1.0 - (
     math.abs(normImpulse - normSlope) +
     math.abs(normSlope - normMomentum) +
     math.abs(normMomentum - normRange) +
     math.abs(normRange - normBody)
 ) / 8.0
consensus = f_clamp(consensusRaw, 0.0, 1.0)

expansion = f_clamp(atrRatio, 0.0, 2.5)

biasText = pressureScore > 12.0 ? "Bull Bias" : pressureScore < -12.0 ? "Bear Bias" : "Neutral Bias"
regimeText = consensus > 0.70 and math.abs(pressureScore) > 60.0 ? "Conviction" : math.abs(pressureScore) < 18.0 ? "Balance" : expansion > 1.15 ? "Expansion" : "Transition"
actionText = pressureScore > signalLine and pressureScore > 0 ? "Long Watch" : pressureScore < signalLine and pressureScore < 0 ? "Short Watch" : "Wait"

bullSignal = barstate.isconfirmed and ta.crossover(pressureScore, signalLine) and pressureScore > 0.0 and consensus >= minAgreeInput and rvol >= minRvolInput and pressureScore > 15.0
bearSignal = barstate.isconfirmed and ta.crossunder(pressureScore, signalLine) and pressureScore < 0.0 and consensus >= minAgreeInput and rvol >= minRvolInput and pressureScore < -15.0

//------------------------------------------------------------------------------
// Color system
//------------------------------------------------------------------------------
scoreColor = color.from_gradient(pressureScore, -100.0, 100.0, bearInput, bullInput)
signalColor = color.new(accentInput, 0)
cloudBull = color.new(bullInput, 84)
cloudBear = color.new(bearInput, 84)
zeroColor = color.new(chart.fg_color, 78)

//------------------------------------------------------------------------------
// Oscillator visuals
//------------------------------------------------------------------------------
upperZone = hline(70, "Upper Extreme", color = color.new(chart.fg_color, 82), linestyle = hline.style_dashed)
midZone = hline(0, "Zero", color = zeroColor, linestyle = hline.style_dotted)
lowerZone = hline(-70, "Lower Extreme", color = color.new(chart.fg_color, 82), linestyle = hline.style_dashed)

fill(midZone, upperZone, top_color = showZonesInput ? color.new(bullInput, 93) : na, bottom_color = showZonesInput ? color.new(bullInput, 100) : na, title = "Bull Pressure Zone")
fill(lowerZone, midZone, top_color = showZonesInput ? color.new(bearInput, 100) : na, bottom_color = showZonesInput ? color.new(bearInput, 93) : na, title = "Bear Pressure Zone")

pScore = plot(pressureScore, "Pressure", color = scoreColor, linewidth = 2)
pSignal = plot(signalLine, "Signal", color = signalColor, linewidth = 1)

fill(pScore, pSignal, color = showCloudInput ? (pressureScore >= signalLine ? cloudBull : cloudBear) : na, title = "Pressure Cloud")

plot(0, "Zero Guide", color = color.new(chart.fg_color, 100))
bgcolor(showCloudInput ? color.new(scoreColor, 94) : na, title = "Pressure Pane Aura")

//------------------------------------------------------------------------------
// Buy / Sell labels
//------------------------------------------------------------------------------
if showSignalInput and bullSignal
    label.new(bar_index, pressureScore, "BUY", xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = color.new(bullInput, 88), textcolor = bullInput, size = size.tiny)

if showSignalInput and bearSignal
    label.new(bar_index, pressureScore, "SELL", xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = color.new(bearInput, 88), textcolor = bearInput, size = size.tiny)

alertcondition(bullSignal, "Bullish Pressure Reset", "Aureon Pressure Lens [JOAT] produced a bullish confirmed signal.")
alertcondition(bearSignal, "Bearish Pressure Reset", "Aureon Pressure Lens [JOAT] produced a bearish confirmed signal.")

//------------------------------------------------------------------------------
// Dashboard
//------------------------------------------------------------------------------
var table dash = table.new(f_table_pos(dashPosInput), 2, 7, bgcolor = color.new(#161616, 0), frame_color = color.new(#2E2E2E, 0), frame_width = 1, border_color = color.new(#2E2E2E, 0), border_width = 1)

if dashInput and barstate.islast
    table.cell(dash, 0, 0, "Aureon Pressure Lens [JOAT]", text_color = color.new(#DBDBDB, 0), bgcolor = color.new(#161616, 0), text_halign = text.align_center, text_size = f_table_size(dashSizeInput))
    table.cell(dash, 1, 0, "", bgcolor = color.new(#161616, 0), text_size = f_table_size(dashSizeInput))

    table.cell(dash, 0, 1, "State", text_color = color.new(#808080, 0), bgcolor = color.new(#161616, 0), text_size = f_table_size(dashSizeInput))
    table.cell(dash, 1, 1, regimeText, text_color = pressureScore >= 0 ? bullInput : bearInput, bgcolor = color.new(#161616, 0), text_size = f_table_size(dashSizeInput))

    table.cell(dash, 0, 2, "Bias", text_color = color.new(#808080, 0), bgcolor = color.new(#161616, 0), text_size = f_table_size(dashSizeInput))
    table.cell(dash, 1, 2, biasText, text_color = pressureScore >= 0 ? bullInput : bearInput, bgcolor = color.new(#161616, 0), text_size = f_table_size(dashSizeInput))

    table.cell(dash, 0, 3, "Pressure", text_color = color.new(#808080, 0), bgcolor = color.new(#161616, 0), text_size = f_table_size(dashSizeInput))
    table.cell(dash, 1, 3, str.tostring(pressureScore, "0.00"), text_color = color.new(#DBDBDB, 0), bgcolor = color.new(#161616, 0), text_size = f_table_size(dashSizeInput))

    table.cell(dash, 0, 4, "Signal", text_color = color.new(#808080, 0), bgcolor = color.new(#161616, 0), text_size = f_table_size(dashSizeInput))
    table.cell(dash, 1, 4, str.tostring(signalLine, "0.00"), text_color = color.new(#DBDBDB, 0), bgcolor = color.new(#161616, 0), text_size = f_table_size(dashSizeInput))

    table.cell(dash, 0, 5, "RVOL / Conf.", text_color = color.new(#808080, 0), bgcolor = color.new(#161616, 0), text_size = f_table_size(dashSizeInput))
    table.cell(dash, 1, 5, str.tostring(rvol, "0.00") + " / " + str.tostring(consensus * 100.0, "0.0") + "%", text_color = color.new(#DBDBDB, 0), bgcolor = color.new(#161616, 0), text_size = f_table_size(dashSizeInput))

    table.cell(dash, 0, 6, "Action", text_color = color.new(#808080, 0), bgcolor = color.new(#161616, 0), text_size = f_table_size(dashSizeInput))
    table.cell(dash, 1, 6, actionText, text_color = pressureScore >= signalLine ? bullInput : bearInput, bgcolor = color.new(#161616, 0), text_size = f_table_size(dashSizeInput))
````
