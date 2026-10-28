# Anchored VWAP Bands Strategy [Gabremoku]

- url: https://www.tradingview.com/script/uVpMMhar-Anchored-VWAP-Bands-Strategy-Gabremoku/
- type: indicator
- pine_id: PUB;1359fd5a964b475c85a9f5c421bf081f
- version: 1.0

## Description

Anchored VWAP Bands Strategy [Gabremoku] is a context-driven fair value indicator that combines Anchored VWAP, deviation bands, directional bias, and retest/stretch-based entry logic into a single overlay.

The script uses Anchored VWAP as its core reference line, allowing the user to define a custom starting point by time or bars back. Unlike standard VWAP, which resets on a regular session basis, Anchored VWAP starts from a specific event or pivot selected by the trader, making it especially useful for tracking price behavior relative to an important market reference point.

On top of that, the indicator adds sigma-style bands, dynamic fair value coloring, directional state reading, and optional entry signals built around AVWAP retests and band reversals.

What it shows
⚓ Anchored VWAP — the volume-weighted average price from a user-defined anchor point. Anchored VWAP is commonly used to estimate fair value from a specific event and to monitor whether price is trading above or below that reference.

📐 Deviation Bands — up to three upper and lower bands built from either:

anchored standard deviation

or rolling standard deviation

These bands help show how far price has deviated from anchored fair value and can be used to identify balance, expansion, or stretch conditions.

🌈 Dynamic Gradient Bias — AVWAP and its fills change color based on price location and directional pressure relative to the center.

🧭 Directional State — the script classifies price into states such as:

Fair Value

Bullish Balance

Bullish Expansion

Bullish Stretch

Bearish Balance

Bearish Expansion

Bearish Stretch

🎯 Entry and Target Logic — optional long/short signals and dynamic target markers based on AVWAP retests or outer-band reversals.

🪧 Dashboard — displays state, bias, AVWAP slope, distance from fair value, anchor age, and Long-S status.

Core logic
The main idea behind this script is simple:

AVWAP defines fair value from a chosen event

bands define statistical distance from that fair value

slope helps determine directional bias

signals look for retests or stretched reversals

Anchored VWAP is often used to analyze where the market’s volume-weighted average price sits from a meaningful point in time, and many traders use it as a dynamic support/resistance or bias line. Price above AVWAP is often interpreted as relatively stronger positioning, while price below it can imply weaker positioning.

By adding deviation bands, this script gives a clearer structure for distinguishing between:

normal pullbacks,

balanced price action,

and statistically extended moves.

Signal logic
The script supports Both, Long, or Short directional modes, with three signal styles:

Retest AVWAP

Band Reversal

Hybrid

Long ideas
Long signals can trigger when:

price retests AVWAP and closes back above it

or price reacts from the lower band and reclaims it

Short ideas
Short signals can trigger when:

price retests AVWAP from below and closes back under it

or price reacts from the upper band and falls back below it

There is also a Long-S logic tied to reactions around Lower Band 1, with AVWAP used as a potential target when enabled.

This makes the tool useful both for:

trend continuation via AVWAP retests

and mean-reversion or snapback setups from band extremes

Why it matters
One of the biggest strengths of Anchored VWAP is that it adds context.

Instead of asking “is price high or low?” in a generic way, AVWAP asks:
“Is price rich or discounted relative to a meaningful market event and its volume?”

That is why Anchored VWAP is commonly anchored to:

breakout bars

swing highs or lows

earnings events

gaps

major session turning points

In that framework:

AVWAP becomes fair value

slope becomes directional bias

bands become expansion/stretch zones

retests become opportunity areas

Features
✅ Anchored VWAP with time-based or bars-back anchoring

✅ Optional anchor reset logic

✅ Anchored or rolling standard deviation bands

✅ Up to three sigma-style upper/lower bands

✅ Dynamic center-line and fill coloring

✅ Fair value / expansion / stretch state classification

✅ Long / Short / Both strategy modes

✅ Retest AVWAP, Band Reversal, or Hybrid signal modes

✅ Optional slope filter

✅ Optional close-confirmation filter

✅ Dynamic target plotting

✅ Long-S lower-band reaction logic

✅ Bias background shading

✅ AVWAP label and dashboard

✅ Built-in alert conditions

How to use
A practical workflow is:

Choose a meaningful anchor point.

Use AVWAP as the fair value reference.

Read slope for directional bias.

Use the bands to identify balance vs expansion vs stretch.

Trigger entries on:

AVWAP retests in trend

band reversals after extension

In general:

above a rising AVWAP often supports bullish continuation logic

below a falling AVWAP often supports bearish continuation logic

far from AVWAP near outer bands can signal stretch or reaction zones rather than efficient price

Notes
This indicator is designed as a fair value and execution-context tool, not as a full standalone strategy with complete trade management. Anchored VWAP is highly dependent on anchor quality, so the usefulness of the line improves when the anchor is tied to a genuinely meaningful price event.

Author: Gabremoku
Pine Script v6

## Source Code

````pine

//@version=6
indicator("Anchored VWAP Bands Strategy [Gabremoku]", overlay=true, max_labels_count=500, max_lines_count=500)


// ═══════════════════════════════════════════════════════════════
//  Anchored VWAP Bands Strategy [Gabremoku]
//  Fair value ancorato + bande sigma + retest / stretch signals
//  Bull = Blu | Bear = Giallo
// ═══════════════════════════════════════════════════════════════


// ── INPUTS ─────────────────────────────────────────────────────
grp6 = "🧭 Strategy Mode"
strategySide = input.string("Both", "Strategy Side", options=["Both", "Long", "Short"], group=grp6)
signalMode   = input.string("Retest AVWAP", "Signal Mode", options=["Retest AVWAP", "Band Reversal", "Hybrid"], group=grp6)
showSignals  = input.bool(true, "Show Entry Signals", group=grp6)
showTargets  = input.bool(true, "Show Dynamic Targets", group=grp6)
showBiasBg   = input.bool(true, "Show Bias Background", group=grp6)

grp0 = "⚙️ Core"
src               = input.source(ohlc4, "Source", group=grp0)
anchorMode        = input.string("Time", "Anchor Mode", options=["Time", "Bars Back"], group=grp0)
anchorTime        = input.time(timestamp("2025-01-01 00:00 +0000"), "Anchor Time", confirm=true, group=grp0)
anchorBarsBack    = input.int(150, "Anchor Bars Back", minval=1, group=grp0)
resetOnNewAnchor  = input.bool(true, "Reinitialize on New Anchor", group=grp0)

grp1 = "📐 Bands"
stdevMode  = input.string("Anchored", "Deviation Mode", options=["Anchored", "Rolling"], group=grp1)
stdevLen   = input.int(80, "Rolling StdDev Length", minval=5, group=grp1)
mult1      = input.float(1.0, "Band 1 Mult", step=0.25, group=grp1)
mult2      = input.float(2.0, "Band 2 Mult", step=0.25, group=grp1)
mult3      = input.float(3.0, "Band 3 Mult", step=0.25, group=grp1)
showBand1  = input.bool(true, "Show Band 1", group=grp1)
showBand2  = input.bool(true, "Show Band 2", group=grp1)
showBand3  = input.bool(true, "Show Band 3", group=grp1)

grp2 = "🎨 Colors"
bullColor    = input.color(color.rgb(33, 150, 243), "Bullish Color (Blue)", group=grp2)
bearColor    = input.color(color.rgb(242, 255, 66), "Bearish Color (Yellow)", group=grp2)
neutralColor = input.color(color.gray, "Neutral Color", group=grp2)

grp3 = "🌈 Gradient Logic"
neutralZone    = input.float(0.0015, "Neutral Zone % Around AVWAP", minval=0.0, step=0.0005, group=grp3)
fillAggressive = input.float(1.60, "Fill Aggressiveness", minval=0.5, maxval=4.0, step=0.1, group=grp3)
maxOpacityNear = input.int(90, "Fill Opacity Near Center", minval=0, maxval=100, group=grp3)
minOpacityFar  = input.int(18, "Fill Opacity Far From Center", minval=0, maxval=100, group=grp3)

grp4 = "🚦 Signal Logic"
retestTolerancePct = input.float(0.15, "Retest Tolerance %", minval=0.01, step=0.01, group=grp4)
confirmClose       = input.bool(true, "Require Candle Close Confirmation", group=grp4)
useSlopeFilter     = input.bool(true, "Use AVWAP Slope Filter", group=grp4)
slopeLen           = input.int(5, "Slope Lookback", minval=1, group=grp4)
useBandTargets     = input.bool(true, "Use Bands As Targets", group=grp4)
enableLongS        = input.bool(true, "Enable Long-S On Lower Band 1", group=grp4)

grp5 = "🪟 Display"
showAVWAPLabel = input.bool(true, "Show AVWAP Label", group=grp5)
showDashboard  = input.bool(true, "Show Dashboard", group=grp5)
showSiteRef    = input.bool(true, "Show Site Ref", group=grp5)


// ── FUNCTIONS ──────────────────────────────────────────────────
clamp(_x, _min, _max) =>
    math.max(_min, math.min(_max, _x))

f_inLongMode() =>
    strategySide == "Both" or strategySide == "Long"

f_inShortMode() =>
    strategySide == "Both" or strategySide == "Short"


// ── ANCHOR LOGIC ───────────────────────────────────────────────
var int anchorBar = na

barsBackAnchorBar = math.max(0, bar_index - anchorBarsBack)
timeAnchorHit     = time >= anchorTime and time[1] < anchorTime

if anchorMode == "Bars Back"
    anchorBar := barsBackAnchorBar
else
    if na(anchorBar) and time >= anchorTime
        anchorBar := bar_index
    else if resetOnNewAnchor and timeAnchorHit
        anchorBar := bar_index

isAnchored = not na(anchorBar) and bar_index >= anchorBar
barsFromAnchor = isAnchored ? (bar_index - anchorBar) : na


// ── ANCHORED VWAP CORE ────────────────────────────────────────
var float cumPV = na
var float cumV  = na

newAnchorStart = isAnchored and (bar_index == anchorBar)

if newAnchorStart
    cumPV := src * volume
    cumV  := volume
else if isAnchored
    cumPV += src * volume
    cumV  += volume
else
    cumPV := na
    cumV  := na

avwap = isAnchored and cumV != 0 ? cumPV / cumV : na


// ── DEVIATION ENGINE ───────────────────────────────────────────
var float cumSq = na
anchoredDevInput = math.pow(src, 2) * volume

if newAnchorStart
    cumSq := anchoredDevInput
else if isAnchored
    cumSq += anchoredDevInput
else
    cumSq := na

anchoredMeanSq = isAnchored and cumV != 0 ? cumSq / cumV : na
anchoredVar    = isAnchored ? math.max(anchoredMeanSq - math.pow(avwap, 2), 0.0) : na
anchoredStdev  = isAnchored ? math.sqrt(anchoredVar) : na

rollingStdev = ta.stdev(src, stdevLen)
stdev = stdevMode == "Anchored" ? anchoredStdev : rollingStdev

upper1 = avwap + stdev * mult1
lower1 = avwap - stdev * mult1
upper2 = avwap + stdev * mult2
lower2 = avwap - stdev * mult2
upper3 = avwap + stdev * mult3
lower3 = avwap - stdev * mult3


// ── TREND / STATE ──────────────────────────────────────────────
slope = not na(avwap[slopeLen]) ? avwap - avwap[slopeLen] : na
bullSlope = not na(slope) and slope > 0
bearSlope = not na(slope) and slope < 0

distPct = not na(avwap) and avwap != 0 ? ((close - avwap) / avwap) * 100.0 : na
neutralBandPct = neutralZone * 100.0

state =
     not isAnchored ? "Waiting Anchor" :
     math.abs(distPct) <= neutralBandPct ? "Fair Value" :
     close > avwap and close <= upper1 ? "Bullish Balance" :
     close > upper1 and close <= upper2 ? "Bullish Expansion" :
     close > upper2 ? "Bullish Stretch" :
     close < avwap and close >= lower1 ? "Bearish Balance" :
     close < lower1 and close >= lower2 ? "Bearish Expansion" :
     close < lower2 ? "Bearish Stretch" :
     "Neutral"

baseRange = ta.highest(math.abs(close - avwap), 200)
pressure   = not na(baseRange) and baseRange != 0 ? clamp(math.abs(close - avwap) / baseRange, 0.0, 1.0) : 0.0

stateCol =
     not isAnchored ? neutralColor :
     close > avwap ? bullColor :
     close < avwap ? bearColor :
     neutralColor


// ── GRADIENT COLOR STYLE ───────────────────────────────────────
centerZone = not na(avwap) ? avwap * neutralZone : na

avwapColorRaw =
     not isAnchored ? neutralColor :
     close >= avwap
     ? color.from_gradient(close - avwap, centerZone, baseRange * 0.6, neutralColor, bullColor)
     : color.from_gradient(close - avwap, -baseRange * 0.6, -centerZone, bearColor, neutralColor)

avwapColor = not isAnchored ? neutralColor : math.abs(close - avwap) <= centerZone ? neutralColor : avwapColorRaw

distNorm = not na(baseRange) and baseRange != 0 ? clamp(math.pow(math.abs(close - avwap) / baseRange, fillAggressive), 0.0, 1.0) : 0.0

bullNear = color.new(bullColor, maxOpacityNear)
bullFar  = color.new(bullColor, minOpacityFar)
bearNear = color.new(bearColor, maxOpacityNear)
bearFar  = color.new(bearColor, minOpacityFar)

band1UpperColor = color.new(bullColor, 15)
band1LowerColor = color.new(bearColor, 15)
band2UpperColor = color.new(bullColor, 35)
band2LowerColor = color.new(bearColor, 35)
band3UpperColor = color.new(bullColor, 55)
band3LowerColor = color.new(bearColor, 55)

fillBull = color.from_gradient(distNorm, 0.0, 1.0, bullNear, bullFar)
fillBear = color.from_gradient(distNorm, 0.0, 1.0, bearNear, bearFar)
dynamicFill = not isAnchored ? color.new(neutralColor, 92) : close >= avwap ? fillBull : fillBear


// ── SIGNAL LOGIC ───────────────────────────────────────────────
tol = avwap * (retestTolerancePct * 0.01)
bandTol = lower1 * (retestTolerancePct * 0.01)

retestBullRaw = isAnchored and low <= avwap + tol and close > avwap and close[1] <= avwap[1]
retestBearRaw = isAnchored and high >= avwap - tol and close < avwap and close[1] >= avwap[1]

bandRevBullRaw = isAnchored and low <= lower1 and close > lower1
bandRevBearRaw = isAnchored and high >= upper1 and close < upper1

closeConfirmBull = not confirmClose or close > open
closeConfirmBear = not confirmClose or close < open

slopeBullOk = not useSlopeFilter or bullSlope
slopeBearOk = not useSlopeFilter or bearSlope

longSignal =
     f_inLongMode() and
     (
         signalMode == "Retest AVWAP" ? retestBullRaw :
         signalMode == "Band Reversal" ? bandRevBullRaw :
         (retestBullRaw or bandRevBullRaw)
     ) and closeConfirmBull and slopeBullOk

longSReaction = close > open or close >= (low + (high - low) * 0.30)

longSignalS =
     f_inLongMode() and
     enableLongS and
     isAnchored and
     low <= lower1 + bandTol and
     longSReaction

shortSignal =
     f_inShortMode() and
     (
         signalMode == "Retest AVWAP" ? retestBearRaw :
         signalMode == "Band Reversal" ? bandRevBearRaw :
         (retestBearRaw or bandRevBearRaw)
     ) and closeConfirmBear and slopeBearOk

longTarget  = useBandTargets ? upper1 : na
longSTarget = useBandTargets ? avwap : na
shortTarget = useBandTargets ? lower1 : na


// ── PLOTS ──────────────────────────────────────────────────────
plotAVWAP = plot(avwap, "Anchored VWAP", color=avwapColor, linewidth=3)

pU1 = plot(showBand1 ? upper1 : na, "Upper Band 1", color=band1UpperColor, linewidth=1, style=plot.style_line)
pL1 = plot(showBand1 ? lower1 : na, "Lower Band 1", color=band1LowerColor, linewidth=1, style=plot.style_line)

pU2 = plot(showBand2 ? upper2 : na, "Upper Band 2", color=band2UpperColor, linewidth=1, style=plot.style_line)
pL2 = plot(showBand2 ? lower2 : na, "Lower Band 2", color=band2LowerColor, linewidth=1, style=plot.style_line)

pU3 = plot(showBand3 ? upper3 : na, "Upper Band 3", color=band3UpperColor, linewidth=1, style=plot.style_line)
pL3 = plot(showBand3 ? lower3 : na, "Lower Band 3", color=band3LowerColor, linewidth=1, style=plot.style_line)

fill(plotAVWAP, pU1, color=showBand1 ? dynamicFill : na, title="Upper Gradient Fill 1")
fill(plotAVWAP, pL1, color=showBand1 ? dynamicFill : na, title="Lower Gradient Fill 1")
fill(pU1, pU2, color=showBand2 ? color.new(bullColor, 88) : na, title="Upper Fill 2")
fill(pL1, pL2, color=showBand2 ? color.new(bearColor, 88) : na, title="Lower Fill 2")
fill(pU2, pU3, color=showBand3 ? color.new(bullColor, 93) : na, title="Upper Fill 3")
fill(pL2, pL3, color=showBand3 ? color.new(bearColor, 93) : na, title="Lower Fill 3")

bgcolor(showBiasBg and isAnchored ? color.new(stateCol, 94) : na)

plotshape(showSignals and longSignal,  title="Long Signal",   style=shape.labelup,   location=location.belowbar, color=bullColor, text="LONG",   textcolor=color.white, size=size.tiny)
plotshape(showSignals and longSignalS, title="Long-S Signal", style=shape.labelup,   location=location.belowbar, color=color.new(bullColor, 0), text="Long-S", textcolor=color.white, size=size.tiny)
plotshape(showSignals and shortSignal, title="Short Signal",  style=shape.labeldown, location=location.abovebar, color=bearColor, text="SHORT",  textcolor=color.black, size=size.tiny)

plot(showTargets and longSignal ? longTarget : na, "Long Target", color=color.new(bullColor, 0), linewidth=2, style=plot.style_circles)
plot(showTargets and longSignalS ? longSTarget : na, "Long-S Target", color=color.new(color.white, 0), linewidth=2, style=plot.style_circles)
plot(showTargets and shortSignal ? shortTarget : na, "Short Target", color=color.new(bearColor, 0), linewidth=2, style=plot.style_circles)


// ── LABELS ─────────────────────────────────────────────────────
if showAVWAPLabel and barstate.islast and isAnchored
    label.new(bar_index, avwap, "AVWAP", style=label.style_label_left, color=color.new(avwapColor, 0), textcolor=color.white)

    


// ── DASHBOARD ──────────────────────────────────────────────────
if showDashboard and barstate.islast
    var table dash = table.new(position.top_right, 2, 7, border_width=1)
    table.cell(dash, 0, 0, "AVWAP Bands", text_color=color.white, bgcolor=color.new(color.black, 0))
    table.cell(dash, 1, 0, "Gabremoku", text_color=color.white, bgcolor=color.new(color.black, 0))

    table.cell(dash, 0, 1, "State", text_color=color.white, bgcolor=color.new(color.black, 15))
    table.cell(dash, 1, 1, state, text_color=color.black, bgcolor=stateCol)

    table.cell(dash, 0, 2, "Bias", text_color=color.white, bgcolor=color.new(color.black, 15))
    table.cell(dash, 1, 2, close >= avwap ? "Bullish" : "Bearish", text_color=color.black, bgcolor=close >= avwap ? bullColor : bearColor)

    table.cell(dash, 0, 3, "Slope", text_color=color.white, bgcolor=color.new(color.black, 15))
    table.cell(dash, 1, 3, bullSlope ? "Rising" : bearSlope ? "Falling" : "Flat", text_color=color.black, bgcolor=bullSlope ? bullColor : bearSlope ? bearColor : neutralColor)

    table.cell(dash, 0, 4, "Distance %", text_color=color.white, bgcolor=color.new(color.black, 15))
    table.cell(dash, 1, 4, na(distPct) ? "na" : str.tostring(distPct, "#.##") + "%", text_color=color.white, bgcolor=color.new(color.black, 45))

    table.cell(dash, 0, 5, "Anchor Bars", text_color=color.white, bgcolor=color.new(color.black, 15))
    table.cell(dash, 1, 5, na(barsFromAnchor) ? "na" : str.tostring(barsFromAnchor), text_color=color.white, bgcolor=color.new(color.black, 45))

    table.cell(dash, 0, 6, "Long-S", text_color=color.white, bgcolor=color.new(color.black, 15))
    table.cell(dash, 1, 6, enableLongS ? "Enabled" : "Disabled", text_color=color.white, bgcolor=enableLongS ? color.new(bullColor, 25) : color.new(color.gray, 50))


// ── ALERT CONDITIONS ───────────────────────────────────────────
alertcondition(longSignal, "Long Signal", "Anchored VWAP Bands Strategy [Gabremoku] - LONG")
alertcondition(longSignalS, "Long-S Signal", "Anchored VWAP Bands Strategy [Gabremoku] - LONG-S")
alertcondition(shortSignal, "Short Signal", "Anchored VWAP Bands Strategy [Gabremoku] - SHORT")
alertcondition(ta.crossover(close, avwap), "Cross Above AVWAP", "Price crossed above Anchored VWAP")
alertcondition(ta.crossunder(close, avwap), "Cross Below AVWAP", "Price crossed below Anchored VWAP")
````
