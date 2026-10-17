# ATC Bollinger Band Percentile v1.1

- url: https://www.tradingview.com/script/aS5qVzSq-ATC-Bollinger-Band-Percentile-v1-1/
- type: indicator
- pine_id: PUB;83977cd1ce6e44078ee4e98cdfcae892
- version: 1.0

## Description

[b]What It Is[/b]

The ATC Bollinger Band Percentile (ATC BBP) is a dual-layer oscillator that tells you two things simultaneously: where price sits inside its Bollinger envelope right now, and whether the current volatility environment is compressing, neutral, or expanding — measured against real historical data, not a hardcoded threshold.

Most Bollinger Band tools give you the bands. This one gives you the context behind the bands.

________________________________________

[b]Who It's Built For[/b]


ATC BBP is designed for retail traders who already use Bollinger Bands or have tried them but found the raw %B reading too noisy or too vague to act on. If you've ever looked at a squeeze setup and wondered whether the bands were actually tight or just tighter than yesterday, this indicator was built to answer that question directly.

It works best for traders who use volatility as a filter before entering trend or breakout trades, want a cleaner and less reactive version of %B, or are building toward understanding normalized, statistically-grounded indicators. 

________________________________________

[b]Core Concept[/b]

Bollinger Bands place price in a dynamic envelope built from a moving average and standard deviation. The %B reading converts that envelope into a 0–100 scale: 100 means price is sitting on the upper band, 0 means price is on the lower band, and 50 means price is at the midpoint.

That's useful, but the raw reading is noisy and the bands themselves don't tell you whether they're wide or narrow relative to history. A band can look visually compressed on your chart and still be wider than it's been 75% of the time — or vice versa.

ATC BBP solves both problems. It smooths %B with a Hull Moving Average to reduce reactive noise, and it scores the current bandwidth as a percentile against a rolling window of its own history — so you always know objectively whether compression is real.

________________________________________

[b]ATC Upgrades Over Standard %B[/b]

HMA Smoothing on %B The raw %B line reacts sharply to every candle. ATC BBP applies a Hull Moving Average to %B before it's plotted, cutting noise while preserving responsiveness. The raw %B is still available in the data window for comparison, but the smoothed version drives everything you see. You can adjust the smoothing length or disable it entirely.

Bandwidth Percentile Scoring This is the core ATC enhancement. Instead of asking "are the bands narrow?", ATC BBP asks "are the bands narrow relative to the last 125 bars of bandwidth history?" The bandwidth percentile is computed by ranking the current bandwidth against every value in the lookback window. A reading of 8% means the bands are tighter right now than they've been on 92% of recent bars. That's a real squeeze signal — not an eyeball call.

Empirical Zone Thresholds with Hysteresis The %B zone boundaries are not hardcoded round numbers. The defaults are set at empirically sensible levels and are fully adjustable. More importantly, every state transition — both the squeeze state and the %B zone — uses a configurable hysteresis band so the indicator doesn't flicker at the edges. Once a state is entered, it takes a meaningful move to exit it.

________________________________________

[b]What's on the Chart[/b]

ATC BBP plots in a separate pane below your price chart.

The %B Line The smoothed %B oscillator on a 0–100 scale. The line changes color dynamically to reflect the current zone: green shades when price is in the lower portion of the bands, red shades in the upper portion, neutral grey for mid-range. When price tags or exceeds either band, the color deepens to full intensity. A fill between the %B line and the 50-level midline gives an immediate read on whether price is in the upper or lower half of the range.

Horizontal Reference Lines Five levels mark the key zones: lower extreme (0), lower quartile (20), midline (50), upper quartile (80), and upper extreme (100). Low-opacity colored background shading tints each zone — red above the upper quartile, green below the lower quartile, neutral in the middle.

Squeeze Pressure Bar Along the bottom of the pane, a colored bar marks the current squeeze state. Amber indicates a tight squeeze — bandwidth in the lowest percentile tier. Light yellow indicates a developing or loose squeeze. Blue indicates active volatility expansion. When no state is active, the bar disappears — the absence of color is meaningful. Diamond markers appear at the bar when a squeeze begins and again when expansion starts, so state transitions are never missed on a busy chart.

________________________________________

[b]HUD Breakdown[/b]

The corner HUD (top right by default) gives you a live read of both indicator layers without having to inspect chart values:

Volatility — current squeeze state label: Tight Squeeze, Loose Squeeze, Expansion, or Neutral, color-coded to match the pressure bar

BW %-ile — the bandwidth percentile as a number, followed by a 10-block progress bar showing where current bandwidth sits on a visual scale from fully compressed to fully expanded

%B Zone — a text label for where price is in the envelope: Below Lower Band, Lower Quartile, Mid Range, Upper Quartile, or Above Upper Band

%B Reading — the smoothed %B value as a number

The HUD supports dark and light themes and can be repositioned to any corner of the pane.
________________________________________

[b]Logic Layers[/b]

The indicator runs two independent state machines, each with its own hysteresis logic.

Squeeze State Machine Four states: Tight Squeeze (bandwidth percentile below the tight threshold), Loose Squeeze (between tight and loose thresholds), Neutral (mid-range bandwidth), and Expansion (above the expansion threshold). State transitions require the bandwidth percentile to move beyond the threshold by the hysteresis amount before the state flips. This prevents toggling at the boundary on marginal readings.

%B Zone State Machine Five zones tracking price location within the envelope: Below Lower Band, Lower Quartile, Mid Range, Upper Quartile, and Above Upper Band. The same hysteresis logic applies — once price enters a zone, it stays classified there until it moves decisively into the next zone.

The two machines run independently. You can be in a tight squeeze while price is in the upper quartile — which is a very different setup than a tight squeeze with price at the midline. The HUD shows both readings simultaneously so you always have the full picture.

________________________________________

[b]Alerts[/b]

Seven alert conditions are built in.

BBP: Tight Squeeze Started — fires when the squeeze state first enters the tight tier. Use this to monitor compression setups across instruments before they break.

BBP: Tight Squeeze Released — fires when the tight squeeze breaks. This is the exit from compression, which may precede expansion or resolve back to neutral — both are meaningful.

BBP: Expansion Started — fires when bandwidth percentile crosses above the expansion threshold, confirming that volatility is breaking out of compression.

BBP: Price Above Upper Band — fires when %B reaches or exceeds 100, meaning price has tagged or broken through the upper band.

BBP: Price Below Lower Band — fires when %B reaches or falls below 0, meaning price has tagged or broken through the lower band.

BBP: %B Cross Above 50 — fires when smoothed %B crosses above the midline. Price location bias has shifted to the upper half of the envelope.

BBP: %B Cross Below 50 — fires when smoothed %B crosses below the midline. Price location bias has shifted to the lower half.

________________________________________

[b]How to Trade With It[/b]

ATC BBP is a context indicator, not a signal generator. It tells you the volatility environment and price location so you can filter and frame your setups — it does not issue buy or sell signals on its own.

Step 1 — Check the Squeeze State First Before anything else, look at the HUD Volatility row and the pressure bar. Tight Squeeze means the market is coiling. Expansion means it's already moving. Neutral means neither is happening. This single read tells you what kind of market you're in before you look at anything else.

Step 2 — Use Squeeze Context to Filter Breakout Setups A tight squeeze is the setup condition for a potential expansion — it does not tell you which direction. When bandwidth is in the lowest 8–10 percentile of its history, start watching price action for the break, but wait for directional confirmation from your primary setup criteria before trading it. The squeeze tells you energy is building. Your edge tells you which way it breaks.

Step 3 — Use %B to Read Location Within the Setup Once you have a directional bias, %B tells you where price currently sits in the envelope. If you're looking for a long entry and %B is already above 80, price is extended toward the top of the range — it may be better to wait for a pullback toward the 50 midline. If %B is mid-range or lower quartile heading into a long setup, there's more room to run before hitting band resistance.

Step 4 — Look for Squeeze-Plus-Zone Confluence The highest-value reads come when both layers line up. A tight squeeze with %B at mid-range or lower quartile means compression is present and price has room to move higher if the break is bullish — watch for expansion to confirm with %B rising through 50. Expansion with %B crossing above 50 means volatility is moving and location bias is shifting bullish simultaneously — often the clearest confirmation that a breakout is real. Expansion with %B above 100 means price is already through the upper band in an expanding environment — valid in strong trends, a caution flag in range conditions.

Step 5 — Use Alerts for Multi-Instrument Monitoring If you're running ATC BBP across multiple instruments or timeframes, set the Tight Squeeze Started and Expansion Started alerts. These fire the moment a state changes so you're never watching the wrong chart while a setup develops elsewhere.

________________________________________

[b]Settings Reference[/b]

Bollinger Bands BB Length (default 30) — period for the moving average and standard deviation calculation. Optimized default for QQQ. Increase for slower, more structural readings; decrease for more reactive readings on faster instruments.

BB StdDev Multiplier (default 1.6) — number of standard deviations for the band width. Optimized default for QQQ. Lower values tighten the bands and will increase the frequency of upper/lower extreme readings.

BB Source (default Close) — price source for the band calculation.

Smoothing %B HMA Smoothing (default 8) — Hull Moving Average length applied to %B. Set to 1 to disable smoothing and plot the raw %B line.

Squeeze Quality Bandwidth Percentile Window (default 125) — rolling lookback used to rank the current bandwidth. Larger windows produce more stable percentile readings against longer historical context. 

Tight Squeeze Threshold (default 8) — bandwidth percentile below this level is classified as a tight squeeze.

Loose Squeeze Threshold (default 25) — bandwidth percentile between the tight threshold and this level is classified as a developing squeeze.

Expansion Threshold (default 75) — bandwidth percentile above this level is classified as active expansion. 

State Hysteresis (default 3.0) — neutral band around each threshold. A state must be exceeded by this amount before the classification changes, preventing flicker on marginal readings.

%B Zones Upper Quartile (default 80) — %B above this is classified as Upper Quartile zone. 

Lower Quartile (default 20) — %B below this is classified as Lower Quartile zone. 

Upper Extreme (default 100) — %B at or above this is classified as Above Upper Band. Lower 

Extreme (default 0) — %B at or below this is classified as Below Lower Band.

Visuals Shade %B Zones — toggles the background zone tinting on the oscillator pane. Show Squeeze Pressure Bar — toggles the colored state bar and diamond markers at the bottom of the pane. Color inputs for all states are fully adjustable if you prefer a different palette.

________________________________________

[b]Recommended Instruments and Timeframes[/b]

ATC BBP is tested and validated on ES, NQ, CL, GC, SPY, QQQ, major equities, and major FX pairs. Recommended timeframes are 5m, 15m, 1h, 4h, and 1D. Default settings are optimized for QQQ. When applying to other instruments, the BB Length, StdDev Multiplier, and Bandwidth Percentile Window are the primary settings to adjust for the instrument's typical volatility profile.
________________________________________

## Source Code

````pine
// ==========================================================================
// ATC Bollinger Band Percentile — v1.1
//
// Author:   Ascend Trading Concepts
// License:  Redistribution requires attribution.
//
// Description:
//   A premium %B oscillator paired with an empirical squeeze-quality reading.
//   %B shows price location within the Bollinger envelope (0 = lower band,
//   100 = upper band). Bandwidth is scored as a percentile against its own
//   rolling history so the squeeze is measured, not guessed. HMA smoothing
//   replaces SMA to reduce noise without adding lag.
//
// ATC Enhancement:
//   Bandwidth percentile scoring over a rolling window replaces hardcoded
//   "squeeze width" constants. HMA-smoothed %B. Empirical quartile zones
//   replace generic 80/20 overbought/oversold thresholds.
//
// Intended Instruments: ES, NQ, CL, GC, SPY, QQQ, major equities, major FX
// Intended Timeframes:  5m, 15m, 1h, 4h, 1D
// ==========================================================================
//@version=6
indicator("ATC Bollinger Band Percentile v1.1", shorttitle="ATC BBP", overlay=false, max_labels_count=50, max_boxes_count=50, scale=scale.right)

// ==========================================================================
// Section B — User Inputs
// ==========================================================================

// --- Core Bollinger inputs ---
grpBB   = "Bollinger Bands"
bbLen   = input.int(30, "BB Length", minval=5, maxval=200, tooltip="Period for the Bollinger Band moving average and standard deviation. Optimized default for QQQ = 30.", group=grpBB)
bbMult  = input.float(1.6, "BB StdDev Multiplier", minval=0.5, maxval=5.0, step=0.1, tooltip="Number of standard deviations for the band width. Optimized default for QQQ = 1.6.", group=grpBB)
bbSrc   = input.source(close, "BB Source", tooltip="Price source used for the bands. Close is the standard.", group=grpBB)

// --- %B smoothing ---
grpSmooth = "Smoothing"
pbSmooth  = input.int(8, "%B HMA Smoothing", minval=1, maxval=30, tooltip="HMA length applied to %B. Set to 1 to disable smoothing. Optimized default for QQQ = 8.", group=grpSmooth)

// --- Squeeze quality ---
grpSqz      = "Squeeze Quality"
sqzLookback = input.int(125, "Bandwidth Percentile Window", minval=50, maxval=500, tooltip="Rolling window used to compute the bandwidth percentile. Optimized default for QQQ = 125.", group=grpSqz)
sqzTight    = input.float(8.0, "Tight Squeeze Threshold (percentile)", minval=1.0, maxval=40.0, step=1.0, tooltip="Bandwidth percentile below this level marks a tight squeeze. Optimized default for QQQ = 8.", group=grpSqz)
sqzLoose    = input.float(25.0, "Loose Squeeze Threshold (percentile)", minval=10.0, maxval=60.0, step=1.0, tooltip="Bandwidth percentile between this and the tight threshold is a developing squeeze. Optimized default for QQQ = 25.", group=grpSqz)
expThresh   = input.float(75.0, "Expansion Threshold (percentile)", minval=60.0, maxval=95.0, step=1.0, tooltip="Bandwidth percentile above this level marks volatility expansion. Optimized default for QQQ = 75.", group=grpSqz)
hystPct     = input.float(3.0, "State Hysteresis (percentile)", minval=0.0, maxval=10.0, step=0.5, tooltip="Neutral band around each state threshold to prevent flicker. Optimized default for QQQ = 3.0.", group=grpSqz)

// --- %B zone thresholds (empirical) ---
grpZone = "%B Zones"
pbUpper = input.float(80.0, "Upper Quartile", minval=55.0, maxval=95.0, step=1.0, tooltip="Upper quartile boundary. Above this is elevated; default 80.", group=grpZone)
pbLower = input.float(20.0, "Lower Quartile", minval=5.0, maxval=45.0, step=1.0, tooltip="Lower quartile boundary. Below this is depressed; default 20.", group=grpZone)
pbExtUp = input.float(100.0, "Upper Extreme", minval=90.0, maxval=120.0, step=1.0, tooltip="Price at or above the upper band. Default 100 (= upper band).", group=grpZone)
pbExtDn = input.float(0.0, "Lower Extreme", minval=-20.0, maxval=10.0, step=1.0, tooltip="Price at or below the lower band. Default 0 (= lower band).", group=grpZone)

// --- Visuals (premium palette) ---
grpVis       = "Visuals"
colBlue      = input.color(#1F4E79, "ATC Blue (primary line)", group=grpVis)
colAccent    = input.color(#2E75B6, "ATC Accent (bands)", group=grpVis)
colBull      = input.color(#3D9970, "Bullish Zone", group=grpVis)
colBear      = input.color(#D64545, "Bearish Zone", group=grpVis)
colNeutral   = input.color(#7A7A7A, "Neutral", group=grpVis)
colSqzTight  = input.color(#F5A623, "Tight Squeeze (warning amber)", group=grpVis)
colSqzLoose  = input.color(#F0C96B, "Loose Squeeze", group=grpVis)
colExpand    = input.color(#2E75B6, "Expansion", group=grpVis)
showZones    = input.bool(true, "Shade %B Zones", tooltip="Fills the oscillator pane with low-opacity zone tints for visual depth.", group=grpVis)
showPressure = input.bool(true, "Show Squeeze Pressure Bar", tooltip="Renders a state-colored bar at the bottom of the pane showing squeeze intensity.", group=grpVis)

// --- HUD ---
grpHUD   = "HUD"
showHUD  = input.bool(true, "Show HUD", group=grpHUD)
hudPos   = input.string("Top Right", "HUD Position", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group=grpHUD)
hudTheme = input.string("Dark", "HUD Theme", options=["Dark", "Light"], group=grpHUD)

// ==========================================================================
// Section C — Core Calculations
// ==========================================================================

bbBasis = ta.sma(bbSrc, bbLen)
bbStd   = ta.stdev(bbSrc, bbLen)
bbUpper = bbBasis + bbMult * bbStd
bbLower = bbBasis - bbMult * bbStd

bandRange = bbUpper - bbLower
pbRaw     = bandRange != 0.0 ? ((bbSrc - bbLower) / bandRange) * 100.0 : 50.0

bandwidth = bbBasis != 0.0 ? ((bbUpper - bbLower) / bbBasis) * 100.0 : na

// ==========================================================================
// Section D — Enhancement Layer
// ==========================================================================

pb = pbSmooth > 1 ? ta.hma(pbRaw, pbSmooth) : pbRaw

float bwPctRaw = na
if not na(bandwidth) and bar_index >= sqzLookback
    int count = 0
    for i = 0 to sqzLookback - 1
        histBw = bandwidth[i]
        if not na(histBw) and histBw <= bandwidth
            count += 1
    bwPctRaw := (float(count) / float(sqzLookback)) * 100.0

bwPct = nz(bwPctRaw, 50.0)

// --- Squeeze state with hysteresis ---
// -2 = tight squeeze, -1 = loose squeeze, 0 = neutral, +1 = expansion
var int sqzState = 0
prevSqzState = sqzState

if not na(bwPctRaw)
    if prevSqzState == -2
        if bwPct > sqzTight + hystPct
            if bwPct < sqzLoose
                sqzState := -1
            else if bwPct > expThresh
                sqzState := 1
            else
                sqzState := 0
    else if prevSqzState == -1
        if bwPct < sqzTight - hystPct
            sqzState := -2
        else if bwPct > sqzLoose + hystPct
            if bwPct > expThresh
                sqzState := 1
            else
                sqzState := 0
    else if prevSqzState == 1
        if bwPct < expThresh - hystPct
            if bwPct < sqzLoose
                if bwPct < sqzTight
                    sqzState := -2
                else
                    sqzState := -1
            else
                sqzState := 0
    else
        if bwPct < sqzTight - hystPct
            sqzState := -2
        else if bwPct < sqzLoose - hystPct
            sqzState := -1
        else if bwPct > expThresh + hystPct
            sqzState := 1

// --- %B zone classification with hysteresis ---
// -2 = extreme low, -1 = depressed, 0 = neutral, +1 = elevated, +2 = extreme high
var int pbZone = 0
prevPbZone = pbZone

if not na(pb)
    if prevPbZone == 2
        if pb < pbExtUp - hystPct
            if pb > pbUpper
                pbZone := 1
            else
                pbZone := 0
    else if prevPbZone == 1
        if pb > pbExtUp
            pbZone := 2
        else if pb < pbUpper - hystPct
            pbZone := 0
    else if prevPbZone == -1
        if pb < pbExtDn
            pbZone := -2
        else if pb > pbLower + hystPct
            pbZone := 0
    else if prevPbZone == -2
        if pb > pbExtDn + hystPct
            if pb < pbLower
                pbZone := -1
            else
                pbZone := 0
    else
        if pb > pbExtUp + hystPct
            pbZone := 2
        else if pb > pbUpper + hystPct
            pbZone := 1
        else if pb < pbExtDn - hystPct
            pbZone := -2
        else if pb < pbLower - hystPct
            pbZone := -1

// ==========================================================================
// Section E — Plotting & Visual Rendering
// ==========================================================================

hline(pbExtUp, "Upper Extreme", color=color.new(colNeutral, 50), linestyle=hline.style_solid)
hline(pbUpper, "Upper Quartile", color=color.new(colNeutral, 70), linestyle=hline.style_dashed)
hMid = hline(50.0, "Midline", color=color.new(colNeutral, 80), linestyle=hline.style_dotted)
hline(pbLower, "Lower Quartile", color=color.new(colNeutral, 70), linestyle=hline.style_dashed)
hline(pbExtDn, "Lower Extreme", color=color.new(colNeutral, 50), linestyle=hline.style_solid)

// --- Premium zone background tints ---
var box zoneExtUp = na
var box zoneUp    = na
var box zoneMid   = na
var box zoneDn    = na
var box zoneExtDn = na

if showZones and barstate.islast
    if not na(zoneExtUp)
        box.delete(zoneExtUp)
    if not na(zoneUp)
        box.delete(zoneUp)
    if not na(zoneMid)
        box.delete(zoneMid)
    if not na(zoneDn)
        box.delete(zoneDn)
    if not na(zoneExtDn)
        box.delete(zoneExtDn)

    leftIdx  = math.max(bar_index - 500, 0)
    rightIdx = bar_index + 20

    zoneExtUp := box.new(left=leftIdx, top=150.0, right=rightIdx, bottom=pbExtUp, border_color=color.new(colBear, 100), bgcolor=color.new(colBear, 92))
    zoneUp    := box.new(left=leftIdx, top=pbExtUp, right=rightIdx, bottom=pbUpper, border_color=color.new(colBear, 100), bgcolor=color.new(colBear, 96))
    zoneMid   := box.new(left=leftIdx, top=pbUpper, right=rightIdx, bottom=pbLower, border_color=color.new(colNeutral, 100), bgcolor=color.new(colNeutral, 97))
    zoneDn    := box.new(left=leftIdx, top=pbLower, right=rightIdx, bottom=pbExtDn, border_color=color.new(colBull, 100), bgcolor=color.new(colBull, 96))
    zoneExtDn := box.new(left=leftIdx, top=pbExtDn, right=rightIdx, bottom=-50.0, border_color=color.new(colBull, 100), bgcolor=color.new(colBull, 92))

color pbLineColor = colBlue
if pbZone == 2
    pbLineColor := colBear
else if pbZone == 1
    pbLineColor := color.new(colBear, 30)
else if pbZone == -1
    pbLineColor := color.new(colBull, 30)
else if pbZone == -2
    pbLineColor := colBull

p_pb  = plot(pb, "%B", color=pbLineColor, linewidth=2)
p_mid = plot(50.0, "Midline", color=color.new(colNeutral, 100), display=display.none)
plot(pbRaw, "%B (raw)", color=color.new(colBlue, 65), linewidth=1, display=display.none)

color fillColor = na
if pb > 50
    fillColor := color.new(pbLineColor, 82)
else if pb < 50
    fillColor := color.new(pbLineColor, 82)

fill(p_pb, p_mid, color=fillColor, title="%B Fill")

// --- Squeeze pressure bar ---
pressureLevel = -10.0
plot(showPressure and sqzState == -2 ? pressureLevel : na, "Pressure Tight", color=colSqzTight, linewidth=6, style=plot.style_linebr)
plot(showPressure and sqzState == -1 ? pressureLevel : na, "Pressure Loose", color=colSqzLoose, linewidth=4, style=plot.style_linebr)
plot(showPressure and sqzState == 1 ? pressureLevel : na, "Pressure Expansion", color=colExpand, linewidth=4, style=plot.style_linebr)

// --- Squeeze signal markers ---
sqzEntered = (sqzState == -2 and prevSqzState != -2) or (sqzState == -1 and prevSqzState >= 0)
expEntered = sqzState == 1 and prevSqzState != 1

plotshape(showPressure ? (sqzEntered ? pressureLevel : na) : na, title="Squeeze Start", style=shape.diamond, location=location.absolute, color=colSqzTight, size=size.tiny)
plotshape(showPressure ? (expEntered ? pressureLevel : na) : na, title="Expansion Start", style=shape.diamond, location=location.absolute, color=colExpand, size=size.tiny)

// ==========================================================================
// Section F — HUD
// ==========================================================================

string sqzText = "Neutral"
if sqzState == -2
    sqzText := "Tight Squeeze"
else if sqzState == -1
    sqzText := "Loose Squeeze"
else if sqzState == 1
    sqzText := "Expansion"

color sqzTextColor = colNeutral
if sqzState == -2
    sqzTextColor := colSqzTight
else if sqzState == -1
    sqzTextColor := colSqzLoose
else if sqzState == 1
    sqzTextColor := colExpand

string pbText = "Mid Range"
if pbZone == 2
    pbText := "Above Upper Band"
else if pbZone == 1
    pbText := "Upper Quartile"
else if pbZone == -1
    pbText := "Lower Quartile"
else if pbZone == -2
    pbText := "Below Lower Band"

color pbTextColor = colNeutral
if pbZone >= 1
    pbTextColor := colBear
else if pbZone <= -1
    pbTextColor := colBull

buildBar(float pct) =>
    int filled = int(math.round(pct / 10.0))
    filled := math.max(math.min(filled, 10), 0)
    string bar = ""
    for i = 0 to 9
        bar += i < filled ? "█" : "░"
    bar

var table hud = na

if showHUD and barstate.islast
    if not na(hud)
        table.delete(hud)

    string bwBar = buildBar(bwPct)

    hudPosition = position.bottom_left
    if hudPos == "Top Right"
        hudPosition := position.top_right
    else if hudPos == "Top Left"
        hudPosition := position.top_left
    else if hudPos == "Bottom Right"
        hudPosition := position.bottom_right

    bgColor    = hudTheme == "Dark" ? #1E1E1E : #FAFAFA
    txColor    = hudTheme == "Dark" ? color.white : #222222
    subColor   = hudTheme == "Dark" ? #AAAAAA : #555555
    dividerCol = hudTheme == "Dark" ? #2A2A2A : #E5E5E5

    hud := table.new(hudPosition, 2, 8, bgcolor=bgColor, border_width=1, border_color=color.new(subColor, 60), frame_width=1, frame_color=color.new(subColor, 70))

    table.cell(hud, 0, 0, "Volatility", text_color=subColor, bgcolor=bgColor, text_size=size.small, text_halign=text.align_left)
    table.cell(hud, 1, 0, sqzText, text_color=sqzTextColor, bgcolor=bgColor, text_size=size.small, text_halign=text.align_right)

    table.cell(hud, 0, 1, "BW %-ile", text_color=subColor, bgcolor=bgColor, text_size=size.small, text_halign=text.align_left)
    table.cell(hud, 1, 1, str.tostring(bwPct, "##0.0") + "%", text_color=txColor, bgcolor=bgColor, text_size=size.small, text_halign=text.align_right)

    table.cell(hud, 0, 2, "", text_color=subColor, bgcolor=bgColor, text_size=size.tiny)
    table.cell(hud, 1, 2, bwBar, text_color=sqzTextColor, bgcolor=bgColor, text_size=size.tiny, text_halign=text.align_right)

    table.cell(hud, 0, 3, "", bgcolor=dividerCol, text_size=size.tiny)
    table.cell(hud, 1, 3, "", bgcolor=dividerCol, text_size=size.tiny)

    table.cell(hud, 0, 4, "%B Zone", text_color=subColor, bgcolor=bgColor, text_size=size.small, text_halign=text.align_left)
    table.cell(hud, 1, 4, pbText, text_color=pbTextColor, bgcolor=bgColor, text_size=size.small, text_halign=text.align_right)

    table.cell(hud, 0, 5, "%B Reading", text_color=subColor, bgcolor=bgColor, text_size=size.small, text_halign=text.align_left)
    table.cell(hud, 1, 5, str.tostring(pb, "##0.0"), text_color=txColor, bgcolor=bgColor, text_size=size.small, text_halign=text.align_right)

    table.cell(hud, 0, 6, "", bgcolor=dividerCol, text_size=size.tiny)
    table.cell(hud, 1, 6, "", bgcolor=dividerCol, text_size=size.tiny)

    table.cell(hud, 0, 7, "Percentile", text_color=color.new(subColor, 25), bgcolor=bgColor, text_size=size.tiny, text_halign=text.align_left)
    table.cell(hud, 1, 7, "", text_color=color.new(subColor, 25), bgcolor=bgColor, text_size=size.tiny, text_halign=text.align_right)

// ==========================================================================
// Section G — Alerts
// ==========================================================================

tightEntered   = sqzState == -2 and prevSqzState != -2
tightReleased  = prevSqzState == -2 and sqzState != -2
expansionStart = sqzState == 1 and prevSqzState != 1

pbExtUpEntered = pbZone == 2 and prevPbZone != 2
pbExtDnEntered = pbZone == -2 and prevPbZone != -2
pbMidCrossUp   = ta.crossover(pb, 50)
pbMidCrossDown = ta.crossunder(pb, 50)

alertcondition(tightEntered, "BBP: Tight Squeeze Started", "BBP entered tight squeeze — bandwidth in lowest percentile band")
alertcondition(tightReleased, "BBP: Tight Squeeze Released", "BBP tight squeeze released — watch for expansion follow-through")
alertcondition(expansionStart, "BBP: Expansion Started", "BBP volatility expansion started — bandwidth above expansion threshold")
alertcondition(pbExtUpEntered, "BBP: Price Above Upper Band", "BBP %B reached upper extreme — price tagged/exceeded upper band")
alertcondition(pbExtDnEntered, "BBP: Price Below Lower Band", "BBP %B reached lower extreme — price tagged/exceeded lower band")
alertcondition(pbMidCrossUp, "BBP: %B Cross Above 50", "BBP %B crossed above midline — location bias turned bullish")
alertcondition(pbMidCrossDown, "BBP: %B Cross Below 50", "BBP %B crossed below midline — location bias turned bearish")
````
