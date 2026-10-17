# Structure Delivery Radar [JOAT]

- url: https://www.tradingview.com/script/PNkuanza-Structure-Delivery-Radar-JOAT/
- type: indicator
- pine_id: PUB;e0da2a6835204fb89b60a4bc6a5bc719
- version: 1.0

## Description

[b]Structure Delivery Radar [JOAT][/b]

[b]Introduction[/b]

SDR Structure Delivery Radar is an open-source market structure overlay that classifies short-term, intermediate-term, and long-term delivery using confirmed pivots, break events, sweep events, session position, and ATR compression.

The indicator is designed as a structural context layer. It does not try to predict every candle. Instead, it tracks whether price is delivering through meaningful structure levels and whether multiple structure tiers are aligned.

[image]https://www.tradingview.com/x/oxNXryvY/[/image]

[b]Core Concepts[/b]

[b]1. Three-Tier Structure[/b]
The script tracks ST, IT, and LT swing highs and lows from confirmed pivots. Each tier keeps its own bias state.

[b]2. Confirmed Breaks[/b]
A bullish break requires a confirmed close above the tracked swing high. A bearish break requires a confirmed close below the tracked swing low.

[b]3. Sweep Detection[/b]
The script recognizes when price trades beyond a swing level but closes back through it, marking potential liquidity behavior without using future bars.

[b]4. Delivery Score[/b]
The dashboard score blends structure alignment, break activity, sweep activity, session location, and ATR compression into a 0-100 reading.

[b]5. Clean Structure Cloud[/b]
The visual output uses transparent clouds and dashboard states rather than cluttered arrows or excessive labels.

[b]Features[/b]

[list]
[*][b]ST/IT/LT structure tracking:[/b] Three independent confirmed-pivot layers
[*][b]Break and sweep logic:[/b] Official events require confirmed bars
[*][b]Delivery score:[/b] Quantifies structure alignment and current delivery state
[*][b]Session cloud:[/b] Adds session range context
[*][b]Structure cloud:[/b] Shades the active upper/lower structure region
[*][b]Top-right dashboard:[/b] Shows tier bias, events, ranges, compression, ATR, and signal state
[*][b]Alerts:[/b] Includes bullish and bearish delivery confirmations
[/list]

[b]Input Parameters[/b]

[b]Structure:[/b]
[list]
[*]ST Pivot Length
[*]IT Pivot Length
[*]LT Pivot Length
[*]ATR Length
[/list]

[b]Session and Visuals:[/b]
[list]
[*]Use Session Window
[*]Show Session Cloud
[*]Show Structure Cloud
[*]Show Bias Tint
[*]Cloud and background transparency
[/list]

[b]How to Use[/b]

[b]Step 1:[/b] Check whether the dashboard shows BULL, BEAR, or NEUT for the dominant structure state.

[b]Step 2:[/b] Read the delivery score. Higher scores indicate stronger alignment across the internal model.

[b]Step 3:[/b] Treat sweep events as context for failed breaks or liquidity reactions.

[b]Step 4:[/b] Use the structure cloud as a map of active structural boundaries.

[b]Limitations[/b]

[list]
[*]Pivot-based structure confirms after the pivot length has passed
[*]The score is a context reading, not a guarantee of trade outcome
[*]Compressed markets can delay structure continuation
[*]The script should be combined with risk management and execution rules
[/list]

[b]Originality Statement[/b]

SDR is an original JOAT implementation combining multi-tier confirmed structure, sweep recognition, session context, ATR compression, and a delivery score into one Pine Script v6 overlay.

[b]Disclaimer[/b]

This script is for educational and informational purposes only. It is not financial advice and does not guarantee future results. Trading involves risk, and users should apply their own risk management.

Made with passion by jackofalltrades

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
indicator("Structure Delivery Radar [JOAT]", shorttitle="SDR [JOAT]", overlay=true, max_lines_count=120, max_boxes_count=20, max_labels_count=50)

//------------------------------------------------------------------------------
// JOAT Structure Delivery Radar
// - Builds a three-tier market structure map from confirmed pivots.
// - Tracks confirmed break and sweep events only on closed bars.
// - Blends structure, session position, and ATR compression into a delivery score.
// - Uses only clean chart objects: fills, lines, and a medium dashboard.
//------------------------------------------------------------------------------

sdrGroupStructure = "Structure"
sdrGroupSession = "Session"
sdrGroupVisuals = "Visuals"
sdrGroupSignals = "Signal Engine"

stLen = input.int(3, "ST Pivot Length", minval=1, group=sdrGroupStructure)
itLen = input.int(6, "IT Pivot Length", minval=2, group=sdrGroupStructure)
ltLen = input.int(12, "LT Pivot Length", minval=3, group=sdrGroupStructure)
atrLen = input.int(14, "ATR Length", minval=1, group=sdrGroupStructure)

useSessionWindow = input.bool(true, "Use Session Window", group=sdrGroupSession)
sessionWindow = input.session("0930-1600", "Session Window", group=sdrGroupSession)
showSessionCloud = input.bool(true, "Show Session Cloud", group=sdrGroupVisuals)
showStructureCloud = input.bool(true, "Show Structure Cloud", group=sdrGroupVisuals)
showDashboard = input.bool(true, "Show Dashboard", group=sdrGroupVisuals)
showBackgroundBias = input.bool(true, "Show Bias Tint", group=sdrGroupVisuals)
showEventLabels = input.bool(true, "Show Clean Event Labels", group=sdrGroupVisuals)
showLiveLevels = input.bool(true, "Show Live Structure Levels", group=sdrGroupVisuals)

bullColor = input.color(color.rgb(8, 153, 129), "Bull Color", group=sdrGroupVisuals)
bearColor = input.color(color.rgb(242, 54, 69), "Bear Color", group=sdrGroupVisuals)
neutralColor = input.color(color.rgb(160, 166, 178), "Neutral Color", group=sdrGroupVisuals)
accentColor = input.color(color.rgb(91, 156, 246), "Level Accent", group=sdrGroupVisuals)
cloudTransp = input.int(86, "Cloud Transparency", minval=0, maxval=100, group=sdrGroupVisuals)
bgTransp = input.int(94, "Background Transparency", minval=0, maxval=100, group=sdrGroupVisuals)

signalThreshold = input.int(65, "Signal Threshold", minval=1, maxval=100, group=sdrGroupSignals)

f_clamp(float x, float lo, float hi) =>
    math.max(lo, math.min(hi, x))

f_pick_high(float a, float b, float c) =>
    float out = na
    if not na(a)
        out := a
    if not na(b)
        out := na(out) ? b : math.max(out, b)
    if not na(c)
        out := na(out) ? c : math.max(out, c)
    out

f_pick_low(float a, float b, float c) =>
    float out = na
    if not na(a)
        out := a
    if not na(b)
        out := na(out) ? b : math.min(out, b)
    if not na(c)
        out := na(out) ? c : math.min(out, c)
    out

f_bias_text(int bias) =>
    bias > 0 ? "BULL" : bias < 0 ? "BEAR" : "NEUT"

f_event_text(bool bullBreak, bool bearBreak, bool bullSweep, bool bearSweep) =>
    bullBreak ? "Bull Break" : bearBreak ? "Bear Break" : bullSweep ? "Bull Sweep" : bearSweep ? "Bear Sweep" : "Idle"

f_tint(int bias, int transp) =>
    bias > 0 ? color.new(bullColor, transp) : bias < 0 ? color.new(bearColor, transp) : color.new(neutralColor, transp)

f_score_tint(float score) =>
    score >= 70 ? bullColor : score <= 30 ? bearColor : neutralColor

f_score_text(float score) =>
    str.tostring(int(math.round(score)))

//------------------------------------------------------------------------------
// Session context.
//------------------------------------------------------------------------------
inSession = useSessionWindow ? not na(time(timeframe.period, sessionWindow)) : true
prevInSession = bar_index > 0 ? inSession[1] : false
newSession = inSession and not prevInSession

var float sessionOpen = na
var float sessionHigh = na
var float sessionLow = na
var int sessionBars = 0

if newSession
    sessionOpen := open
    sessionHigh := high
    sessionLow := low
    sessionBars := 1
else if inSession
    sessionHigh := na(sessionHigh) ? high : math.max(sessionHigh, high)
    sessionLow := na(sessionLow) ? low : math.min(sessionLow, low)
    sessionBars += 1

sessionMid = na(sessionHigh) or na(sessionLow) ? na : (sessionHigh + sessionLow) / 2.0
sessionRange = na(sessionHigh) or na(sessionLow) ? na : sessionHigh - sessionLow
sessionAtr = ta.atr(atrLen)
sessionCompression = na(sessionRange) or na(sessionAtr) or sessionAtr <= 0.0 ? 0.5 : 1.0 - f_clamp(sessionRange / math.max(sessionAtr * 2.5, syminfo.mintick), 0.0, 1.0)

//------------------------------------------------------------------------------
// Tier state. Each tier keeps its own most recent confirmed swing and bias.
//------------------------------------------------------------------------------
var float stHigh = na
var float stLow = na
var int stHighBar = na
var int stLowBar = na
var int stBias = 0
var bool stBullBreak = false
var bool stBearBreak = false
var bool stBullSweep = false
var bool stBearSweep = false

var float itHigh = na
var float itLow = na
var int itHighBar = na
var int itLowBar = na
var int itBias = 0
var bool itBullBreak = false
var bool itBearBreak = false
var bool itBullSweep = false
var bool itBearSweep = false

var float ltHigh = na
var float ltLow = na
var int ltHighBar = na
var int ltLowBar = na
var int ltBias = 0
var bool ltBullBreak = false
var bool ltBearBreak = false
var bool ltBullSweep = false
var bool ltBearSweep = false

// Confirmed pivots only. This keeps the tier map non-repainting.
stPH = ta.pivothigh(high, stLen, stLen)
stPL = ta.pivotlow(low, stLen, stLen)
itPH = ta.pivothigh(high, itLen, itLen)
itPL = ta.pivotlow(low, itLen, itLen)
ltPH = ta.pivothigh(high, ltLen, ltLen)
ltPL = ta.pivotlow(low, ltLen, ltLen)

if not na(stPH)
    stHigh := stPH
    stHighBar := bar_index - stLen
if not na(stPL)
    stLow := stPL
    stLowBar := bar_index - stLen

if not na(itPH)
    itHigh := itPH
    itHighBar := bar_index - itLen
if not na(itPL)
    itLow := itPL
    itLowBar := bar_index - itLen

if not na(ltPH)
    ltHigh := ltPH
    ltHighBar := bar_index - ltLen
if not na(ltPL)
    ltLow := ltPL
    ltLowBar := bar_index - ltLen

// Break and sweep logic is only official on closed bars.
stBullBreak := barstate.isconfirmed and not na(stHigh) and close > stHigh and close[1] <= stHigh
stBearBreak := barstate.isconfirmed and not na(stLow) and close < stLow and close[1] >= stLow
stBullSweep := barstate.isconfirmed and not na(stHigh) and high > stHigh and close < stHigh
stBearSweep := barstate.isconfirmed and not na(stLow) and low < stLow and close > stLow

itBullBreak := barstate.isconfirmed and not na(itHigh) and close > itHigh and close[1] <= itHigh
itBearBreak := barstate.isconfirmed and not na(itLow) and close < itLow and close[1] >= itLow
itBullSweep := barstate.isconfirmed and not na(itHigh) and high > itHigh and close < itHigh
itBearSweep := barstate.isconfirmed and not na(itLow) and low < itLow and close > itLow

ltBullBreak := barstate.isconfirmed and not na(ltHigh) and close > ltHigh and close[1] <= ltHigh
ltBearBreak := barstate.isconfirmed and not na(ltLow) and close < ltLow and close[1] >= ltLow
ltBullSweep := barstate.isconfirmed and not na(ltHigh) and high > ltHigh and close < ltHigh
ltBearSweep := barstate.isconfirmed and not na(ltLow) and low < ltLow and close > ltLow

if stBullBreak
    stBias := 1
else if stBearBreak
    stBias := -1

if itBullBreak
    itBias := 1
else if itBearBreak
    itBias := -1

if ltBullBreak
    ltBias := 1
else if ltBearBreak
    ltBias := -1

//------------------------------------------------------------------------------
// Composite delivery score.
//------------------------------------------------------------------------------
bullVotes = (stBias > 0 ? 1 : 0) + (itBias > 0 ? 1 : 0) + (ltBias > 0 ? 1 : 0)
bearVotes = (stBias < 0 ? 1 : 0) + (itBias < 0 ? 1 : 0) + (ltBias < 0 ? 1 : 0)

dominantBias = bullVotes > bearVotes ? 1 : bearVotes > bullVotes ? -1 : 0
alignmentScore = bullVotes == 3 or bearVotes == 3 ? 1.0 : bullVotes == 2 or bearVotes == 2 ? 0.66 : bullVotes == 1 or bearVotes == 1 ? 0.33 : 0.0

anyBreak = stBullBreak or stBearBreak or itBullBreak or itBearBreak or ltBullBreak or ltBearBreak
anySweep = stBullSweep or stBearSweep or itBullSweep or itBearSweep or ltBullSweep or ltBearSweep

breakScore = anyBreak ? 1.0 : 0.0
sweepScore = anySweep ? 1.0 : 0.0
sessionScore = na(sessionMid) ? 0.5 : dominantBias > 0 ? (close >= sessionMid ? 1.0 : 0.35) : dominantBias < 0 ? (close <= sessionMid ? 1.0 : 0.35) : 0.5
compressionScore = sessionCompression

deliveryScore = 100.0 * (
     0.32 * alignmentScore +
     0.26 * breakScore +
     0.18 * sweepScore +
     0.14 * sessionScore +
     0.10 * compressionScore)

deliveryScore := f_clamp(deliveryScore, 0.0, 100.0)

longSignal = barstate.isconfirmed and dominantBias > 0 and deliveryScore >= signalThreshold and (stBullBreak or itBullBreak or ltBullBreak or stBearSweep or itBearSweep or ltBearSweep)
shortSignal = barstate.isconfirmed and dominantBias < 0 and deliveryScore >= signalThreshold and (stBearBreak or itBearBreak or ltBearBreak or stBullSweep or itBullSweep or ltBullSweep)

eventName = stBullBreak or itBullBreak or ltBullBreak ? "BOS Up" : stBearBreak or itBearBreak or ltBearBreak ? "BOS Down" : stBearSweep or itBearSweep or ltBearSweep ? "Sweep Low" : stBullSweep or itBullSweep or ltBullSweep ? "Sweep High" : "Idle"
eventColor = longSignal ? bullColor : shortSignal ? bearColor : anySweep ? accentColor : neutralColor
var label eventLabel = na

if showEventLabels and (longSignal or shortSignal or anySweep)
    label.delete(eventLabel)
    labelY = longSignal or stBearSweep or itBearSweep or ltBearSweep ? low : high
    labelStyle = longSignal or stBearSweep or itBearSweep or ltBearSweep ? label.style_label_up : label.style_label_down
    eventLabel := label.new(bar_index, labelY, eventName + "\n" + f_score_text(deliveryScore), color=color.new(eventColor, 10), textcolor=color.white, style=labelStyle, size=size.normal)

//------------------------------------------------------------------------------
// Clean visual layers.
//------------------------------------------------------------------------------
structureUpper = f_pick_high(ltHigh, itHigh, stHigh)
structureLower = f_pick_low(ltLow, itLow, stLow)

pStructureUpper = plot(showStructureCloud ? structureUpper : na, "Structure Upper", color=color.new(neutralColor, 100), display=display.none)
pStructureLower = plot(showStructureCloud ? structureLower : na, "Structure Lower", color=color.new(neutralColor, 100), display=display.none)
fill(pStructureUpper, pStructureLower, color=showStructureCloud and not na(structureUpper) and not na(structureLower) ? color.new(f_tint(dominantBias, cloudTransp), cloudTransp) : na)

plot(showLiveLevels ? stHigh : na, "ST High", color=color.new(bearColor, 68), linewidth=1, style=plot.style_linebr)
plot(showLiveLevels ? stLow : na, "ST Low", color=color.new(bullColor, 68), linewidth=1, style=plot.style_linebr)
plot(showLiveLevels ? itHigh : na, "IT High", color=color.new(bearColor, 45), linewidth=1, style=plot.style_linebr)
plot(showLiveLevels ? itLow : na, "IT Low", color=color.new(bullColor, 45), linewidth=1, style=plot.style_linebr)
plot(showLiveLevels ? ltHigh : na, "LT High", color=color.new(bearColor, 12), linewidth=2, style=plot.style_linebr)
plot(showLiveLevels ? ltLow : na, "LT Low", color=color.new(bullColor, 12), linewidth=2, style=plot.style_linebr)
plot(longSignal ? low : na, "Confirmed Bullish Delivery", color=color.new(bullColor, 0), linewidth=4, style=plot.style_circles)
plot(shortSignal ? high : na, "Confirmed Bearish Delivery", color=color.new(bearColor, 0), linewidth=4, style=plot.style_circles)

pSessionHigh = plot(showSessionCloud ? sessionHigh : na, "Session High", color=color.new(neutralColor, 100), display=display.none)
pSessionLow = plot(showSessionCloud ? sessionLow : na, "Session Low", color=color.new(neutralColor, 100), display=display.none)
fill(pSessionHigh, pSessionLow, color=showSessionCloud and not na(sessionHigh) and not na(sessionLow) ? color.new(color.rgb(94, 129, 172), cloudTransp) : na)

bgcolor(showBackgroundBias and barstate.isconfirmed ? color.new(f_score_tint(deliveryScore), bgTransp) : na)

//------------------------------------------------------------------------------
// Dashboard.
//------------------------------------------------------------------------------
var table dash = table.new(position.top_right, 4, 10, frame_color=color.new(color.rgb(65, 70, 84), 20), frame_width=1, border_color=color.new(color.rgb(65, 70, 84), 35))

if showDashboard and barstate.islast
    table.cell(dash, 0, 0, "SDR Radar", text_color=color.white, bgcolor=color.new(color.rgb(16, 20, 28), 0))
    table.cell(dash, 1, 0, "Bias", text_color=color.silver, bgcolor=color.new(color.rgb(16, 20, 28), 0))
    table.cell(dash, 2, 0, "State", text_color=color.silver, bgcolor=color.new(color.rgb(16, 20, 28), 0))
    table.cell(dash, 3, 0, "Value", text_color=color.silver, bgcolor=color.new(color.rgb(16, 20, 28), 0))

    table.cell(dash, 0, 1, "Delivery", text_color=color.white, bgcolor=color.new(color.rgb(16, 20, 28), 0))
    table.cell(dash, 1, 1, f_bias_text(dominantBias), text_color=color.white, bgcolor=color.new(f_tint(dominantBias, 0), 10))
    table.cell(dash, 2, 1, "Score", text_color=color.white, bgcolor=color.new(f_score_tint(deliveryScore), 10))
    table.cell(dash, 3, 1, f_score_text(deliveryScore), text_color=color.white, bgcolor=color.new(f_score_tint(deliveryScore), 0))

    table.cell(dash, 0, 2, "ST", text_color=color.white, bgcolor=color.new(color.rgb(16, 20, 28), 0))
    table.cell(dash, 1, 2, f_bias_text(stBias), text_color=color.white, bgcolor=color.new(f_tint(stBias, 12), 12))
    table.cell(dash, 2, 2, f_event_text(stBullBreak, stBearBreak, stBullSweep, stBearSweep), text_color=color.white, bgcolor=color.new(color.rgb(16, 20, 28), 0))
    table.cell(dash, 3, 2, na(stHigh) or na(stLow) ? "n/a" : str.tostring(stHigh - stLow, format.mintick), text_color=color.white, bgcolor=color.new(color.rgb(16, 20, 28), 0))

    table.cell(dash, 0, 3, "IT", text_color=color.white, bgcolor=color.new(color.rgb(16, 20, 28), 0))
    table.cell(dash, 1, 3, f_bias_text(itBias), text_color=color.white, bgcolor=color.new(f_tint(itBias, 12), 12))
    table.cell(dash, 2, 3, f_event_text(itBullBreak, itBearBreak, itBullSweep, itBearSweep), text_color=color.white, bgcolor=color.new(color.rgb(16, 20, 28), 0))
    table.cell(dash, 3, 3, na(itHigh) or na(itLow) ? "n/a" : str.tostring(itHigh - itLow, format.mintick), text_color=color.white, bgcolor=color.new(color.rgb(16, 20, 28), 0))

    table.cell(dash, 0, 4, "LT", text_color=color.white, bgcolor=color.new(color.rgb(16, 20, 28), 0))
    table.cell(dash, 1, 4, f_bias_text(ltBias), text_color=color.white, bgcolor=color.new(f_tint(ltBias, 12), 12))
    table.cell(dash, 2, 4, f_event_text(ltBullBreak, ltBearBreak, ltBullSweep, ltBearSweep), text_color=color.white, bgcolor=color.new(color.rgb(16, 20, 28), 0))
    table.cell(dash, 3, 4, na(ltHigh) or na(ltLow) ? "n/a" : str.tostring(ltHigh - ltLow, format.mintick), text_color=color.white, bgcolor=color.new(color.rgb(16, 20, 28), 0))

    table.cell(dash, 0, 5, "Session", text_color=color.white, bgcolor=color.new(color.rgb(16, 20, 28), 0))
    table.cell(dash, 1, 5, inSession ? "OPEN" : "OFF", text_color=color.white, bgcolor=inSession ? color.new(color.rgb(94, 129, 172), 12) : color.new(color.rgb(56, 60, 72), 12))
    table.cell(dash, 2, 5, "Range", text_color=color.white, bgcolor=color.new(color.rgb(16, 20, 28), 0))
    table.cell(dash, 3, 5, na(sessionRange) ? "n/a" : str.tostring(sessionRange, format.mintick), text_color=color.white, bgcolor=color.new(color.rgb(16, 20, 28), 0))

    table.cell(dash, 0, 6, "Compression", text_color=color.white, bgcolor=color.new(color.rgb(16, 20, 28), 0))
    table.cell(dash, 1, 6, str.tostring(math.round(sessionCompression * 100)), text_color=color.white, bgcolor=color.new(color.rgb(94, 129, 172), 12))
    table.cell(dash, 2, 6, "ATR", text_color=color.white, bgcolor=color.new(color.rgb(16, 20, 28), 0))
    table.cell(dash, 3, 6, str.tostring(sessionAtr, format.mintick), text_color=color.white, bgcolor=color.new(color.rgb(16, 20, 28), 0))

    table.cell(dash, 0, 7, "Signals", text_color=color.white, bgcolor=color.new(color.rgb(16, 20, 28), 0))
    table.cell(dash, 1, 7, longSignal ? "LONG" : shortSignal ? "SHORT" : "WAIT", text_color=color.white, bgcolor=longSignal ? color.new(bullColor, 8) : shortSignal ? color.new(bearColor, 8) : color.new(color.rgb(56, 60, 72), 8))
    table.cell(dash, 2, 7, "Event", text_color=color.white, bgcolor=color.new(color.rgb(16, 20, 28), 0))
    table.cell(dash, 3, 7, longSignal ? "Bullish delivery" : shortSignal ? "Bearish delivery" : "No confirmation", text_color=color.white, bgcolor=color.new(color.rgb(16, 20, 28), 0))

    table.cell(dash, 0, 8, "Last Event", text_color=color.white, bgcolor=color.new(color.rgb(16, 20, 28), 0))
    table.cell(dash, 1, 8, eventName, text_color=color.white, bgcolor=color.new(eventColor, 14))
    table.cell(dash, 2, 8, "Align", text_color=color.white, bgcolor=color.new(color.rgb(16, 20, 28), 0))
    table.cell(dash, 3, 8, str.tostring(math.round(alignmentScore * 100)) + "%", text_color=color.white, bgcolor=color.new(f_tint(dominantBias, 12), 12))

    table.cell(dash, 0, 9, "Upper/Lower", text_color=color.white, bgcolor=color.new(color.rgb(16, 20, 28), 0))
    table.cell(dash, 1, 9, na(structureUpper) ? "n/a" : str.tostring(structureUpper, format.mintick), text_color=color.white, bgcolor=color.new(bearColor, 18))
    table.cell(dash, 2, 9, "Lower", text_color=color.white, bgcolor=color.new(color.rgb(16, 20, 28), 0))
    table.cell(dash, 3, 9, na(structureLower) ? "n/a" : str.tostring(structureLower, format.mintick), text_color=color.white, bgcolor=color.new(bullColor, 18))

alertcondition(longSignal, "SDR Bullish Delivery", "SDR bullish delivery confirmed on a closed bar.")
alertcondition(shortSignal, "SDR Bearish Delivery", "SDR bearish delivery confirmed on a closed bar.")
````
