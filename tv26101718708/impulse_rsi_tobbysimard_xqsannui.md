# Impulse RSI - TobbySimard

- url: https://www.tradingview.com/script/XqSAnnui-Impulse-RSI-TobbySimard/
- type: indicator
- pine_id: PUB;32375f67d37e45c08e74cbe568831b9a
- version: 5.0

## Description

Overview

Impulse RSI is a custom oscillator that combines two classical concepts — momentum and the Relative Strength Index — into a single, unified reading. Rather than applying RSI to raw price as traditionally done, this indicator applies RSI mathematics directly to price momentum, creating a smoother and more context-aware measure of trend strength and direction. The result is a 0–100 bounded oscillator that tells you not just whether price is moving, but how much conviction sits behind that move.



How It Works

The calculation happens in three stages. First, raw momentum is measured by subtracting the price N bars ago from the current price, capturing how far price has traveled over your chosen lookback window. Second, the bar-to-bar acceleration of that momentum is computed — essentially measuring whether momentum is speeding up or slowing down. Third, Wilder's smoothing (RMA) is applied to the gains and losses of that acceleration, exactly as a standard RSI would, producing a normalized value between 0 and 100. That raw value is then smoothed with an EMA to create the final signal line you see plotted on the chart.

The key distinction from a traditional RSI is that this indicator measures the strength of momentum change, not price change. This makes it particularly sensitive to trend shifts and sustained directional moves.



The 50 Line & Direction

The 50 level is the central axis of the indicator and the most important reference point. When the signal is above 50, the indicator considers the market to be in a bullish state. When below 50, bearish. This binary directional read is also available in the Data Window as the Direction value, outputting 1 for bullish, -1 for bearish, and 0 when exactly at the midline.



Zone System

The oscillator is divided into four distinct zones, each with its own color, giving you an immediate visual read of where strength currently sits.

Zone 1 (30–40) — Red represents weak or deteriorating bearish momentum. Zone 2 (40–50) — Blue is the bearish side but showing signs of hesitation or recovery. Zone 3 (50–60) — Green is the bullish side with moderate strength. Zone 4 (60–70) — Orange reflects elevated bullish momentum and stronger conviction.

These zones are filled directly on the oscillator panel, and if bar coloring is enabled, the chart candles themselves will reflect whichever zone the signal currently occupies, giving you an at-a-glance trend context directly on your price chart without needing to look down at the indicator.



Entry Signal

Beyond simple directional bias, the indicator includes a rising signal confirmation layer. A long entry is only highlighted when two conditions are simultaneously true — the signal must be above 50 (bullish direction), and it must be higher now than it was N bars ago, confirming that the signal is actively climbing rather than simply sitting above the midline. This filters out flat or stalling bullish conditions and focuses attention on moments where momentum is genuinely building. The lookback period for this confirmation is fully adjustable, allowing you to require either a short-term or long-term rising confirmation depending on your trading style.

When enabled, these entry conditions are highlighted directly on your price chart as a background color, making them easy to spot without any manual analysis.



Alerts

A comprehensive set of alerts is built in to support both discretionary and automated trading workflows. You can be notified when the signal crosses above or below 50 for general directional conditions, when a confirmed long entry triggers, when the signal crosses into any of the four zones, and when the signal recovers from a lower zone or pulls back from a higher one. This covers the full spectrum of scenarios from trend initiation to zone transitions.



Settings

All key parameters are adjustable. The Momentum Length controls how far back the raw price momentum is measured. The RSI Length controls the smoothing applied to the acceleration gains and losses. The Signal Length controls the EMA smoothing on the final output. The Signal Lookback in the Rising Signal group controls how many bars back the indicator looks when confirming the signal is rising. Zone colors, bar coloring, and entry highlighting are all fully customizable to fit your chart setup.

## Source Code

````pine
// This Source Code Form is subject to the terms of the Mozilla Public License 2.0
// at https://mozilla.org/MPL/2.0/
// © TobbySimard

//@version=6
indicator("Impulse RSI", overlay=false, precision=2)

//  I N P U T S
var string GRP1 = "Core Settings"
src             = input.source(close,        "Source",                  group=GRP1)
momLen          = input.int(88,              "Momentum Length",         group=GRP1, minval=1, maxval=200, tooltip="Period used to calculate price momentum (current price minus price N bars ago). Higher values smooth out short-term noise but react slower to changes")
rsiLen          = input.int(41,              "RSI Length",              group=GRP1, minval=2, maxval=200, tooltip="Smoothing period for the RSI calculation applied to momentum changes. Higher values create a smoother, less reactive signal. Lower values respond faster but may generate more false signals")
sigLen          = input.int(14,              "Smoothing Length",        group=GRP1, minval=1, maxval=200, tooltip="EMA smoothing period applied to the momentum RSI to create the final signal line. Higher values produce a smoother signal with fewer whipsaws but slower reaction time. Lower values are more responsive but noisier")
threshold       = input.int(0,               "Threshold Buffer",        group=GRP1, minval=0, maxval=25,  tooltip="Creates a neutral zone around 50. For example, 5 creates a neutral zone between 45-55.")

var string GRP2 = "Rising Signal"
SigLook         = input.int(50,              "Signal Lookback",         group=GRP2, minval=1, maxval=200, tooltip="Number of bars to look back when confirming the signal is rising. A higher value requires a stronger sustained uptrend before highlighting an entry, while a lower value reacts faster but may catch weaker moves")
entryCol        = input.color(#00e5ff,       "Signal Rising Color",     group=GRP2)
showEntry       = input.bool(false,          "Show Signal Rising",      group=GRP2)

var string GRP3 = "Bar Coloring"
barColoring     = input.bool(true,           "Color Bars by Zone",      group=GRP3)

var string GRP4 = "Zone Colors"
z1Col           = input.color(#ef5350,       "Zone 1 · 30–40 · Red",    group=GRP4)
z2Col           = input.color(#2196F3,       "Zone 2 · 40–50 · Blue",   group=GRP4)
z3Col           = input.color(#26a69a,       "Zone 3 · 50–60 · Green",  group=GRP4)
z4Col           = input.color(#ff9800,       "Zone 4 · 60–70 · Orange", group=GRP4)
neutralCol      = input.color(#808080,       "Neutral Zone · Gray",     group=GRP4)

var string GRP5 = "Table"
showTable       = input.bool(true,           "Show Table",              group=GRP5)
tablePos        = input.string("Top Right",  "Position",                group=GRP5, options=["Top Right", "Top Left", "Bottom Right", "Bottom Left", "Top Center", "Bottom Center"])

// ─────────────────────────────────────────────────────────────────────────────
//   C A L C U L A T I O N S
f_calculations(_src, _momLen, _rsiLen) =>
    _momentum = _src - _src[_momLen]
    _delta    = _momentum - _momentum[1]
    _gain     = math.max(_delta,  0.0)
    _loss     = math.max(-_delta, 0.0)
    _avgGain  = ta.rma(_gain, _rsiLen)
    _avgLoss  = ta.rma(_loss, _rsiLen)
    _avgLoss == 0.0 ? 100.0 : _avgGain == 0.0 ? 0.0 : 100.0 - (100.0 / (1.0 + _avgGain / _avgLoss))

// Calculate threshold levels
upperThreshold = 50.0 + threshold
lowerThreshold = 50.0 - threshold

//  S I G N A L
f_signal(_momRsi, _upper, _lower) =>
    _momRsi > _upper ? 1 : _momRsi < _lower ? -1 : 0

//  C O L O R S
f_colors(_signal, _z1Col, _z2Col, _z3Col, _z4Col, _neutralCol, _upper, _lower) =>
    _signal >= 60.0 and _signal < 70.0 ? _z4Col :
     _signal >= _upper and _signal < 60.0 ? _z3Col :
     _signal >= _lower and _signal <= _upper ? _neutralCol :
     _signal >= 40.0 and _signal < _lower ? _z2Col :
     _signal >= 30.0 and _signal < 40.0 ? _z1Col : na

//  Z O N E  L A B E L
f_zoneLabel(_signal, _upper, _lower) =>
    _signal >= 60.0 and _signal < 70.0 ? "Zone 4 · 60–70" :
     _signal >= _upper and _signal < 60.0 ? "Zone 3 · " + str.tostring(_upper, "#") + "–60" :
     _signal >= _lower and _signal <= _upper ? "Neutral · " + str.tostring(_lower, "#") + "–" + str.tostring(_upper, "#") :
     _signal >= 40.0 and _signal < _lower ? "Zone 2 · 40–" + str.tostring(_lower, "#") :
     _signal >= 30.0 and _signal < 40.0 ? "Zone 1 · 30–40" : "—"

//  T A B L E  P O S I T I O N
f_tablePos(_pos) =>
    switch _pos
        "Top Left"      => position.top_left
        "Bottom Right"  => position.bottom_right
        "Bottom Left"   => position.bottom_left
        "Top Center"    => position.top_center
        "Bottom Center" => position.bottom_center
        =>                 position.top_right

// ─────────────────────────────────────────────────────────────────────────────
//  E X E C U T I O N
momRsi    = f_calculations(src, momLen, rsiLen)
signal    = ta.ema(momRsi, sigLen)
direction = f_signal(momRsi, upperThreshold, lowerThreshold)
sigColor  = f_colors(signal, z1Col, z2Col, z3Col, z4Col, neutralCol, upperThreshold, lowerThreshold)
isGoingUp = signal > signal[SigLook]

longCondition  = direction ==  1
shortCondition = direction == -1
longEntry      = longCondition and isGoingUp

//   B A R  C O L O R I N G
var color coloring = na
if longCondition
    coloring := sigColor
else if shortCondition
    coloring := sigColor
else if direction == 0
    coloring := neutralCol
barColor = barColoring ? coloring : na
plotcandle(open, high, low, close, "BarColor", color=barColor, bordercolor=barColor, wickcolor=barColor, force_overlay=true)

//  L E V E L S  &  Z O N E  F I L L S
l70 = hline(70, "70", color=color.new(color.gray, 65), linestyle=hline.style_dashed)
l60 = hline(60, "60", color=color.new(color.gray, 65), linestyle=hline.style_dashed)

// Dynamic threshold lines
lUpper = hline(upperThreshold, "Upper Threshold", color=color.new(color.gray, 40), linestyle=hline.style_solid, linewidth=2)
lLower = hline(lowerThreshold, "Lower Threshold", color=color.new(color.gray, 40), linestyle=hline.style_solid, linewidth=2)

l40 = hline(40, "40", color=color.new(color.gray, 65), linestyle=hline.style_dashed)
l30 = hline(30, "30", color=color.new(color.gray, 65), linestyle=hline.style_dashed)

fill(l70, l60, color=color.new(z4Col, 85), title="Zone 4 · 60–70")
fill(l60, lUpper, color=color.new(z3Col, 85), title="Zone 3 · Upper–60")
fill(lUpper, lLower, color=color.new(neutralCol, 85), title="Neutral Zone")
fill(lLower, l40, color=color.new(z2Col, 85), title="Zone 2 · 40–Lower")
fill(l40, l30, color=color.new(z1Col, 85), title="Zone 1 · 30–40")

//  P L O T S
plot(signal,    "Signal",    color=sigColor,                   linewidth=2)
plot(direction, "Direction", color=color.new(color.gray, 100), display=display.data_window)

bgcolor(showEntry and longEntry ? color.new(entryCol, 80) : na, title="Long Entry", force_overlay=true)

// ─────────────────────────────────────────────────────────────────────────────
//  T A B L E
zoneLabel  = f_zoneLabel(signal, upperThreshold, lowerThreshold)
risingText = isGoingUp ? "▲  Yes" : "▼  No"
risingCol  = isGoingUp ? color.new(#26a69a, 0) : color.new(#ef5350, 0)
labelCol   = na(sigColor) ? color.new(color.gray, 30) : sigColor

// Market Condition
marketCondition = signal > upperThreshold ? "🟢 Bullish" : signal < lowerThreshold ? "🔴 Bearish" : "⚪ Neutral"
conditionColor = signal > upperThreshold ? color.new(#26a69a, 70) : signal < lowerThreshold ? color.new(#ef5350, 70) : color.new(#808080, 70)

if barstate.islast and showTable
    tbl = table.new(
         f_tablePos(tablePos), 2, 6,
         bgcolor      = color.new(color.black, 85),
         border_color = color.new(color.gray,  60),
         border_width = 1,
         frame_color  = color.new(color.gray,  50),
         frame_width  = 1)

    // Row 0 — Header
    table.cell(tbl, 0, 0, "IMPULSE RSI",
         text_color  = color.white,
         text_size   = size.small,
         bgcolor     = color.new(color.gray, 65),
         text_halign = text.align_center)
    table.merge_cells(tbl, 0, 0, 1, 0)

    // Row 1 — Market Condition
    table.cell(tbl, 0, 1, "Condition",
         text_color  = color.new(color.gray, 20),
         text_size   = size.small,
         bgcolor     = color.new(color.black, 85),
         text_halign = text.align_left)
    table.cell(tbl, 1, 1, marketCondition,
         text_color  = color.white,
         text_size   = size.small,
         bgcolor     = conditionColor,
         text_halign = text.align_right)

    // Row 2 — Asset
    table.cell(tbl, 0, 2, "Asset",
         text_color  = color.new(color.gray, 20),
         text_size   = size.small,
         bgcolor     = color.new(color.black, 85),
         text_halign = text.align_left)
    table.cell(tbl, 1, 2, syminfo.ticker,
         text_color  = color.white,
         text_size   = size.small,
         bgcolor     = color.new(color.black, 85),
         text_halign = text.align_right)

    // Row 3 — Signal Value
    table.cell(tbl, 0, 3, "Signal",
         text_color  = color.new(color.gray, 20),
         text_size   = size.small,
         bgcolor     = color.new(color.black, 85),
         text_halign = text.align_left)
    table.cell(tbl, 1, 3, str.tostring(signal, "#.##"),
         text_color  = labelCol,
         text_size   = size.small,
         bgcolor     = color.new(color.black, 85),
         text_halign = text.align_right)

    // Row 4 — Zone Label
    table.cell(tbl, 0, 4, "Zone",
         text_color  = color.new(color.gray, 20),
         text_size   = size.small,
         bgcolor     = color.new(color.black, 85),
         text_halign = text.align_left)
    table.cell(tbl, 1, 4, zoneLabel,
         text_color  = labelCol,
         text_size   = size.small,
         bgcolor     = color.new(color.black, 85),
         text_halign = text.align_right)

    // Row 5 — Is Rising
    table.cell(tbl, 0, 5, "Rising",
         text_color  = color.new(color.gray, 20),
         text_size   = size.small,
         bgcolor     = color.new(color.black, 85),
         text_halign = text.align_left)
    table.cell(tbl, 1, 5, risingText,
         text_color  = risingCol,
         text_size   = size.small,
         bgcolor     = color.new(color.black, 85),
         text_halign = text.align_right)

// ─────────────────────────────────────────────────────────────────────────────
//  A L E R T S
// ─────────────────────────────────────────────────────────────────────────────
//  A L E R T S
alertcondition(longCondition,                         "🟢 Long Condition",  "ImpulseRSI: Long signal triggered")
alertcondition(shortCondition,                        "🔴 Short Condition", "ImpulseRSI: Short signal triggered")
alertcondition(longEntry,                             "🟢 Long Entry",      "ImpulseRSI: Long entry with rising signal")
alertcondition(ta.crossunder(signal, 40),             "🔴 Zone 1 Entry (30–40)",   "Signal crossed into Zone 1 (30–40) — Red")
alertcondition(ta.crossunder(signal, lowerThreshold), "🔵 Zone 2 Entry (40–Lower)",   "Signal crossed into Zone 2 — Blue")
alertcondition(ta.crossover(signal,  upperThreshold), "🟢 Zone 3 Entry (Upper–60)",   "Signal crossed into Zone 3 — Green")
alertcondition(ta.crossover(signal,  60),             "🟠 Zone 4 Entry (60–70)",   "Signal crossed into Zone 4 (60–70) — Orange")
alertcondition(ta.crossover(signal,  40),             "🔵 Zone 2 Recovery",        "Signal recovered from Zone 1 into Zone 2")
alertcondition(ta.crossunder(signal, 60),             "🟢 Zone 3 Pullback",        "Signal pulled back from Zone 4 into Zone 3")
alertcondition(ta.crossover(signal, lowerThreshold),  "⚪ Neutral Zone Entry", "Signal entered Neutral Zone from below")
alertcondition(ta.crossunder(signal, upperThreshold) and signal > lowerThreshold, "⚪ Neutral Zone Entry from Above", "Signal entered Neutral Zone from above")
````
