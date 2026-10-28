# Pymander's EZ VWAP

- url: https://www.tradingview.com/script/bUB8bxrE-Pymander-s-EZ-VWAP/
- type: indicator
- pine_id: PUB;9cd0920b3eff462bb4725f500e4619dd
- version: 1.0

## Description

Pymander's EZ VWAP
Standard VWAP indicators are great, but let’s be honest—they can be a bit "static." They show you where the price is relative to an average, but they don't tell you the story of the price action. That’s why I built EZ VWAP.

This isn't just a line on your chart; it’s a complete decision-making system designed to help you distinguish between a healthy trend and a trap.

What makes EZ VWAP stand out?
Most VWAPs just give you ±1, ±2, and ±3 standard deviations and call it a day. EZ VWAP is smarter. It classifies the market into logical zones:

The Fair Value Zone (±0.5σ): This is the "Chop Zone." If price is hanging out here, there’s no clear edge. We stay patient.
The Extension Zone (±1σ to ±2σ): This is where the magic happens for mean reversion.
The Exhaustion Zone (Beyond ±3σ): The "Danger Zone" where trends either blow off or reverse violently.
🛠️ Key Features You Won't Find in a Basic VWAP:
Acceptance vs. Rejection Logic: The biggest VWAP trap is shorting a "stretch" only for the price to keep mooning. Our Sweep + Reclaim signals only trigger when the price fails to hold above a band. It asks: "Did price accept the new high, or did it reject it?"
Momentum Dashboard: A quick-glance table in the corner tells you if the VWAP slope is Accelerating (momentum is expanding) or Decelerating (trend is weakening).
Dynamic Slope Coloring: The VWAP line itself changes color based on its "speed." Bright colors for strong trends, and neutral colors for weakening moves—perfect for timing your entries.
Three Modes in One: Whether you want a standard Session reset, a specific Anchored point (like a news event), or a Rolling window for a more responsive feel, we’ve got you covered.
Tailored Entries: Choose between Aggressive, Balanced, or Conservative entry models to match your personal risk tolerance.
How it helps you:
EZ VWAP stops you from "catching falling knives" by waiting for price to actually reclaim a level before signaling an entry. It helps you stay out of the chop and focus on the high-probability "stretch" areas where the big moves happen.

I’d love to hear how it’s working for you! If you have ideas for new features or tweaks, drop some feedback in the comments.

Wishing you all tons of luck and many, many green days! 

-Pymander

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © LuxAlgo

//@version=6
indicator("Pymander's EZ VWAP", shorttitle="EZ VWAP", overlay=true, max_labels_count=500)

// --- Constants & Inputs ---
// Group: Calculation Settings
G_CALC = "Calculation Settings"
modeInput     = input.string("Session", "VWAP Mode", options=["Session", "Anchored", "Rolling"], group=G_CALC, tooltip="Session: Resets daily. Anchored: Starts from a specific date/time. Rolling: Uses a moving window.")
anchorInput   = input.time(timestamp("2024-01-01 00:00"), "Anchor Time", group=G_CALC, tooltip="Only used if Mode is 'Anchored'")
rollingInput  = input.int(20, "Rolling Period", minval=1, group=G_CALC, tooltip="Only used if Mode is 'Rolling'")
srcInput      = input.source(hlc3, "Source", group=G_CALC)

// Group: Band Settings
G_BANDS = "Band Settings"
showB1 = input.bool(true, "Show 0.5σ (Chop Zone)", group=G_BANDS)
mult1  = input.float(0.5, "Band 1 Multiplier", minval=0, step=0.1, group=G_BANDS)
showB2 = input.bool(true, "Show 1.0σ (Stretch)", group=G_BANDS)
mult2  = input.float(1.0, "Band 2 Multiplier", minval=0, step=0.1, group=G_BANDS)
showB3 = input.bool(true, "Show 2.0σ (Extension)", group=G_BANDS)
mult3  = input.float(2.0, "Band 3 Multiplier", minval=0, step=0.1, group=G_BANDS)
showB4 = input.bool(true, "Show 3.0σ (Exhaustion)", group=G_BANDS)
mult4  = input.float(3.0, "Band 4 Multiplier", minval=0, step=0.1, group=G_BANDS)

// Group: Signals & Entry Models
G_SIGS = "Signal Logic"
entryModelInput = input.string("Balanced", "Entry Model", options=["Aggressive", "Balanced", "Conservative"], group=G_SIGS, tooltip="Aggressive: Signal on sweep candle. Balanced: Signal on next candle confirmation. Conservative: Signal after a minor pull-back/momentum shift.")
rsiFilterInput  = input.bool(true, "RSI Filter", group=G_SIGS, tooltip="Adds RSI overbought/oversold filtering for signals")

// --- VWAP Core Calculation ---
var float sumVol  = 0.0
var float sumSrcVol = 0.0
var float sumSrc2Vol = 0.0

isNewPeriod = switch modeInput
    "Session"  => ta.change(time("D")) != 0
    "Anchored" => time >= anchorInput and time[1] < anchorInput
    "Rolling"  => false

if isNewPeriod
    sumVol := 0.0
    sumSrcVol := 0.0
    sumSrc2Vol := 0.0

if modeInput == "Rolling"
    sumVol := ta.sma(volume, rollingInput) * rollingInput
    sumSrcVol := ta.sma(srcInput * volume, rollingInput) * rollingInput
    sumSrc2Vol := ta.sma(math.pow(srcInput, 2) * volume, rollingInput) * rollingInput
else
    if not (modeInput == "Anchored" and time < anchorInput)
        sumVol := nz(sumVol) + volume
        sumSrcVol := nz(sumSrcVol) + srcInput * volume
        sumSrc2Vol := nz(sumSrc2Vol) + math.pow(srcInput, 2) * volume

vwapVal = sumSrcVol / sumVol
variance = math.max(0, (sumSrc2Vol / sumVol) - math.pow(vwapVal, 2))
stdev = math.sqrt(variance)

// --- Bands Calculation ---
b1Upper = vwapVal + stdev * mult1
b1Lower = vwapVal - stdev * mult1
b2Upper = vwapVal + stdev * mult2
b2Lower = vwapVal - stdev * mult2
b3Upper = vwapVal + stdev * mult3
b3Lower = vwapVal - stdev * mult3
b4Upper = vwapVal + stdev * mult4
b4Lower = vwapVal - stdev * mult4

// --- Slope & Compression Logic ---
vwapSlope = vwapVal - vwapVal[1]
vwapAccel = vwapSlope - vwapSlope[1]

slopeColor = vwapSlope > 0 ? (vwapAccel > 0 ? #089981 : #5b9cf6) : (vwapSlope < 0 ? (vwapAccel < 0 ? #f23645 : #5b9cf6) : color.gray)

// --- Signal Logic: Deviation Sweep + Reclaim ---
rsi = ta.rsi(close, 14)
lowest2 = ta.lowest(low, 2)
highest2 = ta.highest(high, 2)

// Short Signal: Price sweeps above B3 (2σ) or B4 (3σ) and reclaims
upperTarget = b3Upper
lowerTarget = b3Lower

sweepUpper = high > upperTarget and close < upperTarget
sweepLower = low < lowerTarget and close > lowerTarget

// Confirmation for Entry Models
aggShort = sweepUpper
aggLong  = sweepLower

balShort = sweepUpper[1] and close < low[1]
balLong  = sweepLower[1] and close > high[1]

conShort = sweepUpper[2] and close < lowest2 and (not rsiFilterInput or rsi < 70)
conLong  = sweepLower[2] and close > highest2 and (not rsiFilterInput or rsi > 30)

finalShort = switch entryModelInput
    "Aggressive"   => aggShort
    "Balanced"     => balShort
    "Conservative" => conShort

finalLong = switch entryModelInput
    "Aggressive"   => aggLong
    "Balanced"     => balLong
    "Conservative" => conLong

// Prevent repeating signals in the same stretch
var int lastSignalBar = 0
signalCooldown = bar_index - lastSignalBar > 5

bool triggerShort = finalShort and signalCooldown
bool triggerLong  = finalLong and signalCooldown

if triggerShort or triggerLong
    lastSignalBar := bar_index

// --- Visuals ---
// Plot VWAP
vwapPlot = plot(vwapVal, "VWAP", color=slopeColor, linewidth=2)

// Plot Bands
p1u = plot(showB1 ? b1Upper : na, "0.5σ Upper", color=color.new(chart.fg_color, 80), style=plot.style_linebr)
p1l = plot(showB1 ? b1Lower : na, "0.5σ Lower", color=color.new(chart.fg_color, 80), style=plot.style_linebr)
p2u = plot(showB2 ? b2Upper : na, "1σ Upper", color=color.new(chart.fg_color, 60), style=plot.style_linebr)
p2l = plot(showB2 ? b2Lower : na, "1σ Lower", color=color.new(chart.fg_color, 60), style=plot.style_linebr)
p3u = plot(showB3 ? b3Upper : na, "2σ Upper", color=color.new(#f23645, 40), style=plot.style_linebr, linewidth=1)
p3l = plot(showB3 ? b3Lower : na, "2σ Lower", color=color.new(#089981, 40), style=plot.style_linebr, linewidth=1)
p4u = plot(showB4 ? b4Upper : na, "3σ Upper", color=color.new(#f23645, 20), style=plot.style_linebr, linewidth=1)
p4l = plot(showB4 ? b4Lower : na, "3σ Lower", color=color.new(#089981, 20), style=plot.style_linebr, linewidth=1)

// Shading Zones
fill(p1u, p1l, showB1 ? color.new(color.gray, 90) : na, "Fair Value Zone")
fill(p2u, p3u, showB2 and showB3 ? color.new(#f23645, 90) : na, "Upper extension")
fill(p2l, p3l, showB2 and showB3 ? color.new(#089981, 90) : na, "Lower extension")

// Signals
plotshape(triggerShort, "Short Signal", shape.labeldown, location.abovebar, #f23645, text="SELL", textcolor=color.white, size=size.small)
plotshape(triggerLong, "Long Signal", shape.labelup, location.belowbar, #089981, text="BUY", textcolor=color.white, size=size.small)

// Labels for Zones (Last Bar only)
if barstate.islast
    if showB1
        label.new(bar_index + 2, b1Upper, "Fair Value", color=#00000000, textcolor=chart.fg_color, style=label.style_label_left, size=size.small)
    if showB3
        label.new(bar_index + 2, b3Upper, "Extension", color=#00000000, textcolor=#f23645, style=label.style_label_left, size=size.small)
    if showB4
        label.new(bar_index + 2, b4Upper, "Exhaustion", color=#00000000, textcolor=#f23645, style=label.style_label_left, size=size.small)

// --- Dashboard Table ---
var table statusTable = table.new(position.top_right, 2, 2, border_width = 1, frame_color=chart.fg_color, frame_width=1)
if barstate.islast
    trendStr = vwapSlope > 0 ? "Slope UP" : vwapSlope < 0 ? "Slope DOWN" : "FLAT"
    accelStr = vwapAccel > 0 ? "Accelerating" : vwapAccel < 0 ? "Decelerating" : "Steady"
    
    table.cell(statusTable, 0, 0, "VWAP Trend", text_color=chart.fg_color, bgcolor=color.new(chart.bg_color, 0))
    table.cell(statusTable, 1, 0, trendStr, text_color=color.white, bgcolor=vwapSlope > 0 ? #089981 : vwapSlope < 0 ? #f23645 : color.gray)
    table.cell(statusTable, 0, 1, "Momentum", text_color=chart.fg_color, bgcolor=color.new(chart.bg_color, 0))
    table.cell(statusTable, 1, 1, accelStr, text_color=chart.fg_color, bgcolor=color.new(chart.bg_color, 0))
````
