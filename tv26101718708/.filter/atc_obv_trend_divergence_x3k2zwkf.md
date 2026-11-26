# ATC OBV Trend Divergence

- url: https://www.tradingview.com/script/X3k2ZWkf-ATC-OBV-Trend-Divergence/
- type: indicator
- pine_id: PUB;9945e4eb27fd49da8a009b4aa99665f7
- version: 1.0

## Description

What It Is

The ATC OBV Trend Divergence indicator is a structurally engineered version of On-Balance Volume — one of the oldest and most misunderstood volume tools in technical analysis. Where the standard retail OBV is a raw cumulative line that traders attempt to manually draw trend lines on (a subjective and unreliable process). This version replaces that guesswork with a fully objective, pivot-based structural analysis engine.

The result is an OBV indicator that tells you, with no manual interpretation required, whether volume flow is building in a bullish structure, breaking down in a bearish one, expanding out of a range, or contracting into one — and it flags only the highest-quality divergences between volume flow and price, confirmed by strict multi-condition logic before a signal ever appears on your chart.

________________________________________

Who It's Built For

This indicator is designed for traders who understand that price alone doesn't tell the full story. If you've ever used a standard OBV and found yourself staring at a messy cumulative line with no clear way to interpret it — this is what OBV should have been from the start.

It works best for:

•	Swing traders and intraday traders who want volume-flow confirmation before entering trend trades

•	Traders who use divergence as part of a reversal or exhaustion framework and need a tool they can actually trust


•	Anyone learning to think beyond price and understand what smart money participation looks like beneath the surface

Recommended instruments: ES, NQ, YM, SPY, QQQ, large-cap equities, major forex pairs Recommended timeframes: 15-minute, 1-hour, 4-hour, daily

________________________________________

The Core Concept

On-Balance Volume works on a simple principle: when price closes up, the entire bar's volume is added to a running total; when price closes down, that volume is subtracted. Over time, this creates a directional volume-flow line that should trend in the same direction as price if buying and selling pressure are in agreement.

The problem with standard OBV is threefold. First, the raw line is extremely noisy. Second, there's no objective way to define trend structure on it without drawing trend lines manually — which are subjective, brittle, and inconsistent from trader to trader. Third, most retail divergence tools flag anything that remotely resembles a divergence pattern, flooding the chart with signals that don't hold up.

The ATC OBV Trend Divergence solves all three.

________________________________________

ATC OBV Trend Divergence Enhancements

1. HMA Smoothing Raw OBV is passed through a Hull Moving Average before any calculations are performed. HMA is ATC's standard smoothing method because it reduces noise significantly without introducing the lag bias that plagues SMA or EMA smoothing. The result is a cleaner OBV line that tracks true directional flow without reacting to bar-to-bar noise.

2. Pivot-Based Structure State Engine Instead of asking you to draw trend lines on OBV, the indicator does it objectively. It detects confirmed swing highs and lows on the smoothed OBV using a configurable left/right pivot lookback, then classifies the current volume flow structure into one of eight states:

•	Uptrend (HH/HL) — volume flow is making higher highs and higher lows: the cleanest bullish structure

•	Downtrend (LH/LL) — volume flow is making lower highs and lower lows: confirmed bearish structure

•	Higher High / Lower High — partial structure information as the trend develops


•	Higher Low / Lower Low — partial low-side structure

•	Expanding — volume flow is making higher highs and lower lows simultaneously: a widening, volatile structure

•	Contracting — volume flow is making lower highs and higher lows: compression, often preceding a breakout

•	Forming — not enough pivot history yet to classify
This replaces subjective trend line drawing with a discrete, reproducible, rules-based classification you can read at a glance from the HUD.

3. Z-Score Normalized Slope Bias The indicator measures the rate of change in OBV slope over a configurable lookback, then normalizes that slope reading against its own rolling distribution using a Z-score calculation. This means the slope bias (Bullish / Neutral / Bearish) is not based on a fixed threshold — it adapts to the current instrument's behavior over time. When OBV momentum is statistically elevated above its own recent norm, slope bias reads Bullish. When it's statistically suppressed, it reads Bearish. Everything in between is Neutral. No hardcoded levels, no round numbers.

4. Conservative, Pivot-Confirmed Divergence Detection The divergence engine is the indicator's most technically demanding component, and it was built to be strict by design. A divergence signal is only issued when all of the following conditions are met simultaneously:

•	Price and OBV each have two confirmed structural pivots of the same type (two highs for bearish divergence, two lows for bullish)

•	The price pivots are separated by a minimum number of bars (configurable, default 10) to prevent noise on adjacent swings

•	The price pivots are not too far apart (configurable, default 80 bars) to prevent flagging stale patterns

•	The price pivot and OBV pivot are temporally close to each other — they're measuring the same swing

•	Optionally, the slope bias must not be contradicting the divergence direction (the "Same-Side Slope" filter)

The result is that divergence signals are rare, which is exactly what you want. When the indicator prints a divergence, it means something.

________________________________________

Reading the Chart

The OBV Line The smoothed OBV line is the primary visual. Its color reflects the current slope bias: green when bullish, red when bearish, grey when neutral. This gives you an at-a-glance read on whether volume flow momentum is trending or flat.

The Baseline A softer line tracks the rolling mean of OBV over the Z-score window. Think of this as the "neutral equilibrium" for OBV on that instrument. When OBV is above the baseline, volume flow is in net positive territory relative to its own recent history. When below, it's in net negative territory. OBV crossing the baseline is one of the six available alerts.

The Fill The area between the OBV line and the baseline is shaded in the current bias color at low opacity. This makes it visually easy to see how far volume flow has extended from equilibrium, and when it's beginning to revert.

Pivot Markers Small triangles appear on the OBV panel at each confirmed structural pivot. Red downward triangles mark OBV swing highs. Green upward triangles mark OBV swing lows. These are the same pivots the structure engine and divergence engine use — seeing them lets you visually confirm what the HUD is reporting.

Divergence Lines When a divergence is confirmed, a dashed line is drawn across the two OBV pivots that created the pattern, and a label is placed at the most recent pivot. Bear divergence lines are red with a "Bear Div" label. Bull divergence lines are green with a "Bull Div" label. Lines only appear after full confirmation — there are no provisional signals on this indicator.

________________________________________

The HUD

The heads-up display in the corner of the panel gives you a real-time read of the indicator's full state without requiring you to inspect the chart visually. Every field updates on each bar close.

Slope Bias — The current directional read on OBV momentum: Bullish, Bearish, or Neutral. Colored to match the chart.

Slope Z — The raw Z-score driving the slope bias classification. Positive values indicate above-average upward momentum. Negative values indicate below-average, downward-leaning momentum. The threshold for Bullish/Bearish classification is configurable (default ±1.0).

Structure — The current OBV structural state: Uptrend (HH/HL), Downtrend (LH/LL), Expanding, Contracting, or a partial structure label as the pattern develops.

Last Div — The type and age of the most recent confirmed divergence signal. Displayed as "Bull (X bars)" or "Bear (X bars)" where X is how many bars ago the signal fired. Shows a dash if no divergence has been detected.

Div Engine — On or Off, reflecting whether the divergence detection module is enabled in settings.

OBV — Whether smoothed OBV is currently above or below the rolling baseline.

________________________________________

How to Trade With It

The ATC OBV Trend Divergence indicator is a confirmation and context tool. It is not a standalone entry signal generator. Use it alongside your price action, levels, and primary trend framework.

Step 1 — Establish the volume flow structure. Before considering any trade, check the Structure field in the HUD. An Uptrend (HH/HL) structure on OBV is the highest-confidence bullish volume environment. A Downtrend (LH/LL) is the highest-confidence bearish environment. If the structure reads Expanding, Contracting, or is still Forming, treat that as a low-conviction volume environment and apply higher selectivity to your trade entries.

Step 2 — Check slope bias alignment. The Slope Bias and Slope Z fields tell you whether current OBV momentum is statistically elevated or suppressed. For long bias trades, you want Bullish slope bias. For short bias trades, you want Bearish slope bias. A Neutral reading doesn't cancel a trade but should reduce your conviction — volume flow momentum is not supporting a directional move right now.

Step 3 — Check OBV vs. baseline. For long entries, OBV above the baseline is supportive. For short entries, OBV below the baseline is supportive. A divergence between price position and OBV baseline position — price near highs but OBV below baseline, for example — is worth noting even without a formal divergence signal.

Step 4 — Let divergence signals add weight, not replace analysis. When a Bull Div or Bear Div label appears, treat it as a significant weight-of-evidence addition to a trade you were already building a case for. Bull Div at a key support level, with a Higher Low structure printing on OBV and slope bias turning Bullish, is a high-confidence confluence setup. Bull Div in isolation, in the middle of a trending move with no structural or level support, is just a data point.

Step 5 — Use the alerts to stay hands-free. Set alerts for the events that matter most to your process — divergence confirmations, slope bias flips, or baseline crossovers — so you don't need to watch the panel continuously. The alerts fire only when conditions are fully confirmed.

What a strong long setup looks like: OBV Structure shows Uptrend (HH/HL) or a fresh Higher Low. Slope Bias reads Bullish. OBV is above baseline. Price is pulling back to a known level. Entry on the next confirmed price structure signal from your primary framework.

What a strong short setup looks like: OBV Structure shows Downtrend (LH/LL) or a fresh Lower High. Slope Bias reads Bearish. OBV is below baseline. Price is rallying into a known resistance zone. Entry on the next confirmed rejection signal from your primary framework.

What a high-quality divergence trade looks like: A Bear Div signal prints after price makes a new high but OBV fails to confirm. Structure has been degrading — recent pivots showing Lower High. Slope Z is declining toward neutral. Price is approaching a prior distribution zone. This is an exhaustion setup worth engaging with appropriate risk sizing.

________________________________________

Alerts

Six alert conditions are available. Configure them in TradingView's alert panel using "Once Per Bar Close" for all divergence and flip alerts.

•	Bullish Divergence — Fires when a fully confirmed bull divergence condition is met (price LL, OBV HL, all confirmation filters passed)

•	Bearish Divergence — Fires when a fully confirmed bear divergence condition is met (price HH, OBV LH, all confirmation filters passed)

•	Slope Flipped Bullish — Fires on the first bar where slope bias crosses above the Bullish threshold

•	Slope Flipped Bearish — Fires on the first bar where slope bias crosses below the Bearish threshold

•	OBV Crossed Above Baseline — Fires when smoothed OBV crosses above the rolling mean

•	OBV Crossed Below Baseline — Fires when smoothed OBV crosses below the rolling mean

•	New Higher High on OBV — Fires when a new structural higher high pivot confirms on OBV

•	New Lower Low on OBV — Fires when a new structural lower low pivot confirms on OBV

________________________________________

Settings Reference

OBV Core

•	HMA Smoothing Length (default 14) — Controls the degree of noise reduction applied to raw OBV before any calculations. Increase for smoother, slower-reacting output. Decrease for faster but noisier response.

Pivot Structure

•	Pivot Left Bars (default 5) — Number of bars to the left of a swing point that must be lower (for a high) or higher (for a low) for the pivot to confirm.

•	Pivot Right Bars (default 5) — Number of bars to the right required for confirmation. Increasing this adds lag but improves signal quality. This is the primary control for how conservative the structure and divergence engines are.

Slope Bias (Z-Score)

•	Slope Lookback (default 20) — Bars over which OBV momentum is measured.

•	Z-Score Window (default 200) — Rolling history used to build the normalization distribution. Larger values create a more stable baseline against which current slope is measured.

•	Slope Z Threshold (default 1.0) — The Z-score magnitude required to classify slope as Bullish or Bearish rather than Neutral. Higher values mean fewer directional readings; lower values are more sensitive.

Divergence Detection

•	Enable Divergence Detection — Toggle the divergence engine on or off.

•	Minimum Bars Between Pivots (default 10) — Prevents divergence from flagging on two adjacent swings that are too close to represent a meaningful structural comparison.

•	Maximum Bars Between Pivots (default 80) — Prevents the engine from connecting pivots that are so far apart the comparison is no longer meaningful.

•	Require Same-Side OBV Slope (default on) — An additional confirmation filter. When active, a bullish divergence also requires that OBV slope not be strongly negative at the time of the signal, and vice versa. Recommended to leave on for conservative operation.

Visuals

•	Toggle OBV line, baseline, state fill, pivot markers, and divergence lines individually

•	Full color control for bullish, bearish, neutral, accent, and pivot marker colors
________________________________________

Instruments and Timeframes

This indicator has been validated for use on US equity index futures (ES, NQ, YM), their ETF equivalents (SPY, QQQ), large-cap individual equities, and major forex pairs. It is designed for the 15-minute, 1-hour, 4-hour, and daily timeframes. Performance on lower timeframes or low-liquidity instruments is not guaranteed, as OBV structure analysis requires sufficient volume history to produce meaningful pivot sequences.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © ATConcepts

// ==========================================================================
//@version=6
indicator("ATC OBV Trend Divergence", shorttitle="ATC OBV",
     overlay=false, precision=2, max_bars_back=1500,
     max_labels_count=100, max_lines_count=50)

// ==========================================================================
// Section B — Inputs
// ==========================================================================
grpOBV = "OBV Core"
smoothLen = input.int(28, "HMA Smoothing Length", minval=3, maxval=100, group=grpOBV,
     tooltip="HMA length applied to raw OBV to reduce noise without introducing lag bias. Optimized default for QQQ 5-minute reliability profile.")

grpPivot = "Pivot Structure"
pivLeft = input.int(4, "Pivot Left Bars", minval=2, maxval=20, group=grpPivot,
     tooltip="Bars to the left of a pivot that must be lower for high pivots or higher for low pivots.")
pivRight = input.int(4, "Pivot Right Bars", minval=2, maxval=20, group=grpPivot,
     tooltip="Bars to the right of a pivot that must be lower for high pivots or higher for low pivots. Larger values are more conservative but add more lag.")

grpSlope = "Slope Bias (Z-Score)"
slopeLen = input.int(30, "Slope Lookback", minval=5, maxval=100, group=grpSlope,
     tooltip="Bars used to measure OBV slope for the bias engine. Optimized default for QQQ 5-minute reliability profile.")
slopeZWindow = input.int(300, "Z-Score Window", minval=50, maxval=1000, group=grpSlope,
     tooltip="Rolling window used to normalize slope against its own recent distribution. Optimized default for QQQ 5-minute reliability profile.")
slopeZThresh = input.float(1.0, "Slope Z Threshold", minval=0.25, maxval=3.0, step=0.25, group=grpSlope,
     tooltip="Absolute Z-score magnitude above which slope is considered directional versus neutral.")

grpDiv = "Divergence Detection"
enableDiv = input.bool(true, "Enable Divergence Detection", group=grpDiv)
minDivBars = input.int(10, "Minimum Bars Between Pivots", minval=5, maxval=100, group=grpDiv,
     tooltip="Divergence requires pivots separated by at least this many bars to prevent noise on adjacent swings.")
maxDivBars = input.int(30, "Maximum Bars Between Pivots", minval=20, maxval=300, group=grpDiv,
     tooltip="Divergence pivots farther apart than this are considered stale and ignored. Optimized default for QQQ 5-minute reliability profile.")
requireSameSide = input.bool(true, "Require Same-Side OBV Slope", group=grpDiv,
     tooltip="When true, bullish divergence requires OBV slope to be non-strongly-negative and bearish divergence requires OBV slope to be non-strongly-positive.")

grpVis = "Visuals"
showObvLine = input.bool(true, "Show OBV Line", group=grpVis)
showFill = input.bool(true, "Show OBV-to-Baseline Fill", group=grpVis)
showPivots = input.bool(true, "Show Pivot Markers", group=grpVis)
showDivLines = input.bool(true, "Show Divergence Lines", group=grpVis)
showZeroLine = input.bool(true, "Show OBV Baseline", group=grpVis,
     tooltip="Draws a reference baseline at the rolling OBV mean.")
showGlow = input.bool(true, "Show Premium OBV Glow", group=grpVis)
showPaneTint = input.bool(true, "Show Subtle Bias Pane Tint", group=grpVis)
showBaseRibbon = input.bool(true, "Show Baseline Ribbon", group=grpVis)
showConfirmMarks = input.bool(true, "Show Divergence Confirmation Dots", group=grpVis)

bullCol = input.color(#00FF66, "Electric Bullish Color", group=grpVis)
bearCol = input.color(#FF1744, "Electric Bearish Color", group=grpVis)
neutCol = input.color(#8A8A8A, "Neutral Color", group=grpVis)
accCol = input.color(#00BFFF, "Electric Accent Color", group=grpVis)
pivotHiCol = input.color(#FF1744, "High Pivot Marker", group=grpVis)
pivotLoCol = input.color(#00FF66, "Low Pivot Marker", group=grpVis)

grpHUD = "HUD"
showHUD = input.bool(true, "Show HUD", group=grpHUD)
hudPos = input.string("Top Right", "HUD Position",
     options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group=grpHUD)
hudTheme = input.string("Dark", "HUD Theme", options=["Dark", "Light"], group=grpHUD)
hudAccentCol = input.color(#D4AF37, "HUD Accent Color", group=grpHUD)

// ==========================================================================
// Section C — Core Calculations
// ==========================================================================
// C1 — Raw OBV + HMA smoothing
rawObv = ta.cum(nz(math.sign(ta.change(close)), 0.0) * nz(volume, 0.0))
obvSmooth = ta.hma(rawObv, smoothLen)

// Rolling baseline for visual zero reference. OBV is cumulative, so absolute
// zero is not meaningful here; the rolling mean is used as a reference.
obvBaseline = ta.sma(obvSmooth, slopeZWindow)

// C2 — Slope bias engine
rawSlope = obvSmooth - obvSmooth[slopeLen]
slopeMean = ta.sma(rawSlope, slopeZWindow)
slopeStd = ta.stdev(rawSlope, slopeZWindow)
slopeZ = slopeStd > 0 ? (rawSlope - slopeMean) / slopeStd : 0.0

string slopeBias = "Neutral"
if slopeZ > slopeZThresh
    slopeBias := "Bullish"
else if slopeZ < -slopeZThresh
    slopeBias := "Bearish"

isBullBias = slopeBias == "Bullish"
isBearBias = slopeBias == "Bearish"

// C3 — Pivot detection on OBV and price
obvPivHigh = ta.pivothigh(obvSmooth, pivLeft, pivRight)
obvPivLow = ta.pivotlow(obvSmooth, pivLeft, pivRight)
pricePivHigh = ta.pivothigh(high, pivLeft, pivRight)
pricePivLow = ta.pivotlow(low, pivLeft, pivRight)

// C4 — Track last two confirmed pivots
var float lastObvHigh = na
var int lastObvHighBar = na
var float prevObvHigh = na
var int prevObvHighBar = na

var float lastObvLow = na
var int lastObvLowBar = na
var float prevObvLow = na
var int prevObvLowBar = na

var float lastPriceHigh = na
var int lastPriceHighBar = na
var float prevPriceHigh = na
var int prevPriceHighBar = na

var float lastPriceLow = na
var int lastPriceLowBar = na
var float prevPriceLow = na
var int prevPriceLowBar = na

if not na(obvPivHigh)
    prevObvHigh := lastObvHigh
    prevObvHighBar := lastObvHighBar
    lastObvHigh := obvPivHigh
    lastObvHighBar := bar_index - pivRight

if not na(obvPivLow)
    prevObvLow := lastObvLow
    prevObvLowBar := lastObvLowBar
    lastObvLow := obvPivLow
    lastObvLowBar := bar_index - pivRight

if not na(pricePivHigh)
    prevPriceHigh := lastPriceHigh
    prevPriceHighBar := lastPriceHighBar
    lastPriceHigh := pricePivHigh
    lastPriceHighBar := bar_index - pivRight

if not na(pricePivLow)
    prevPriceLow := lastPriceLow
    prevPriceLowBar := lastPriceLowBar
    lastPriceLow := pricePivLow
    lastPriceLowBar := bar_index - pivRight

// C5 — OBV structure state
higherHigh = not na(lastObvHigh) and not na(prevObvHigh) and lastObvHigh > prevObvHigh
lowerHigh = not na(lastObvHigh) and not na(prevObvHigh) and lastObvHigh < prevObvHigh
higherLow = not na(lastObvLow) and not na(prevObvLow) and lastObvLow > prevObvLow
lowerLow = not na(lastObvLow) and not na(prevObvLow) and lastObvLow < prevObvLow

string obvStructure = "Forming"
mostRecentIsHigh = not na(lastObvHighBar) and (na(lastObvLowBar) or lastObvHighBar > lastObvLowBar)

if higherHigh and higherLow
    obvStructure := "Uptrend (HH/HL)"
else if lowerHigh and lowerLow
    obvStructure := "Downtrend (LH/LL)"
else if higherHigh and lowerLow
    obvStructure := "Expanding"
else if lowerHigh and higherLow
    obvStructure := "Contracting"
else if mostRecentIsHigh and higherHigh
    obvStructure := "Higher High"
else if mostRecentIsHigh and lowerHigh
    obvStructure := "Lower High"
else if not mostRecentIsHigh and higherLow
    obvStructure := "Higher Low"
else if not mostRecentIsHigh and lowerLow
    obvStructure := "Lower Low"

// C6 — Conservative divergence detection
var bool bearDiv = false
var bool bullDiv = false
var int lastBearDivBar = na
var int lastBullDivBar = na

bearDiv := false
bullDiv := false

haveBearDivData = enableDiv and not na(lastPriceHigh) and not na(prevPriceHigh) and not na(lastObvHigh) and not na(prevObvHigh)
if haveBearDivData
    priceHigherHigh = lastPriceHigh > prevPriceHigh
    obvLowerHigh = lastObvHigh < prevObvHigh
    highBarsApart = math.abs(lastPriceHighBar - lastObvHighBar)
    pivotSeparation = lastPriceHighBar - prevPriceHighBar
    pivotInRange = pivotSeparation >= minDivBars and pivotSeparation <= maxDivBars
    slopeOk = not requireSameSide or slopeZ < slopeZThresh
    triggerNow = not na(pricePivHigh) and (na(lastBearDivBar) or bar_index - lastBearDivBar > pivRight + 1)

    if priceHigherHigh and obvLowerHigh and pivotInRange and highBarsApart <= pivRight * 2 and slopeOk and triggerNow
        bearDiv := true
        lastBearDivBar := bar_index

haveBullDivData = enableDiv and not na(lastPriceLow) and not na(prevPriceLow) and not na(lastObvLow) and not na(prevObvLow)
if haveBullDivData
    priceLowerLow = lastPriceLow < prevPriceLow
    obvHigherLow = lastObvLow > prevObvLow
    lowBarsApart = math.abs(lastPriceLowBar - lastObvLowBar)
    pivotSeparation = lastPriceLowBar - prevPriceLowBar
    pivotInRange = pivotSeparation >= minDivBars and pivotSeparation <= maxDivBars
    slopeOk = not requireSameSide or slopeZ > -slopeZThresh
    triggerNow = not na(pricePivLow) and (na(lastBullDivBar) or bar_index - lastBullDivBar > pivRight + 1)

    if priceLowerLow and obvHigherLow and pivotInRange and lowBarsApart <= pivRight * 2 and slopeOk and triggerNow
        bullDiv := true
        lastBullDivBar := bar_index

// ==========================================================================
// Section E — Premium Plotting
// ==========================================================================
color obvCol = neutCol
if isBullBias
    obvCol := bullCol
else if isBearBias
    obvCol := bearCol

bgcolor(showPaneTint ? color.new(obvCol, 94) : na, title="Subtle Bias Pane Tint")

baselineBandWidth = ta.stdev(obvSmooth, slopeZWindow) * 0.18
baselineUpper = obvBaseline + baselineBandWidth
baselineLower = obvBaseline - baselineBandWidth

baseUpperPlot = plot(showBaseRibbon ? baselineUpper : na, "Baseline Ribbon Upper",
     color=color.new(accCol, 100), linewidth=1)
baseLowerPlot = plot(showBaseRibbon ? baselineLower : na, "Baseline Ribbon Lower",
     color=color.new(accCol, 100), linewidth=1)

fill(baseUpperPlot, baseLowerPlot,
     color=showBaseRibbon ? color.new(accCol, 92) : na,
     title="Baseline Ribbon Fill")

plot(showGlow and showObvLine ? obvSmooth : na, "OBV Premium Glow",
     color=color.new(obvCol, 76), linewidth=5)

obvPlot = plot(showObvLine ? obvSmooth : na, "OBV (HMA)",
     color=obvCol, linewidth=3)

basePlot = plot(showZeroLine ? obvBaseline : na, "OBV Baseline",
     color=color.new(accCol, 35), linewidth=2, style=plot.style_line)

fill(obvPlot, basePlot,
     color=showFill ? color.new(obvCol, 80) : na,
     title="OBV-to-Baseline Fill")

plotshape(showPivots and not na(obvPivHigh) ? obvPivHigh : na,
     title="OBV High Pivot", location=location.absolute, style=shape.triangledown,
     color=pivotHiCol, size=size.tiny, offset=-pivRight)

plotshape(showPivots and not na(obvPivLow) ? obvPivLow : na,
     title="OBV Low Pivot", location=location.absolute, style=shape.triangleup,
     color=pivotLoCol, size=size.tiny, offset=-pivRight)

plotshape(showConfirmMarks and bearDiv ? obvSmooth : na,
     title="Bearish Divergence Confirmation", location=location.absolute,
     style=shape.circle, color=bearCol, size=size.small)

plotshape(showConfirmMarks and bullDiv ? obvSmooth : na,
     title="Bullish Divergence Confirmation", location=location.absolute,
     style=shape.circle, color=bullCol, size=size.small)

// Divergence lines — drawn only after full confirmation
if showDivLines and bearDiv
    line.new(prevObvHighBar, prevObvHigh, lastObvHighBar, lastObvHigh,
         color=bearCol, width=2, style=line.style_dashed, xloc=xloc.bar_index)
    label.new(lastObvHighBar, lastObvHigh, "BEAR\nDIV",
         style=label.style_label_down, color=bearCol, textcolor=color.white,
         size=size.small, xloc=xloc.bar_index)

if showDivLines and bullDiv
    line.new(prevObvLowBar, prevObvLow, lastObvLowBar, lastObvLow,
         color=bullCol, width=2, style=line.style_dashed, xloc=xloc.bar_index)
    label.new(lastObvLowBar, lastObvLow, "BULL\nDIV",
         style=label.style_label_up, color=bullCol, textcolor=color.white,
         size=size.small, xloc=xloc.bar_index)

// ==========================================================================
// Section F — HUD
// ==========================================================================
var table hud = na

if showHUD and barstate.islast
    if not na(hud)
        table.delete(hud)

    hudPosition = position.top_right
    if hudPos == "Top Left"
        hudPosition := position.top_left
    else if hudPos == "Bottom Right"
        hudPosition := position.bottom_right
    else if hudPos == "Bottom Left"
        hudPosition := position.bottom_left

    bgColor = hudTheme == "Dark" ? #1E1E1E : #FAFAFA
    txColor = hudTheme == "Dark" ? color.white : #222222
    dimColor = hudTheme == "Dark" ? color.new(color.white, 40) : color.new(#222222, 40)
    headerBg = hudTheme == "Dark" ? color.new(hudAccentCol, 88) : color.new(hudAccentCol, 82)

    hud := table.new(hudPosition, 2, 8, bgcolor=bgColor,
         frame_color=hudAccentCol, frame_width=1,
         border_width=1, border_color=color.new(hudAccentCol, 55))

    table.cell(hud, 0, 0, "OBV Trend", text_color=hudAccentCol, bgcolor=headerBg, text_size=size.small)
    table.cell(hud, 1, 0, "Divergence", text_color=hudAccentCol, bgcolor=headerBg, text_size=size.small)

    color biasCol = dimColor
    if isBullBias
        biasCol := bullCol
    else if isBearBias
        biasCol := bearCol

    table.cell(hud, 0, 1, "Slope Bias", text_color=dimColor, bgcolor=bgColor, text_size=size.small)
    table.cell(hud, 1, 1, slopeBias, text_color=biasCol, bgcolor=bgColor, text_size=size.small)

    table.cell(hud, 0, 2, "Slope Z", text_color=dimColor, bgcolor=bgColor, text_size=size.small)
    table.cell(hud, 1, 2, str.tostring(slopeZ, "#.00"), text_color=txColor, bgcolor=bgColor, text_size=size.small)

    color structCol = dimColor
    if str.contains(obvStructure, "Up") or str.contains(obvStructure, "Higher")
        structCol := bullCol
    else if str.contains(obvStructure, "Down") or str.contains(obvStructure, "Lower")
        structCol := bearCol

    table.cell(hud, 0, 3, "Structure", text_color=dimColor, bgcolor=bgColor, text_size=size.small)
    table.cell(hud, 1, 3, obvStructure, text_color=structCol, bgcolor=bgColor, text_size=size.small)

    barsSinceBear = na(lastBearDivBar) ? na : bar_index - lastBearDivBar
    barsSinceBull = na(lastBullDivBar) ? na : bar_index - lastBullDivBar

    divText = "—"
    color divColor = dimColor

    if not na(barsSinceBear) and (na(barsSinceBull) or barsSinceBear < barsSinceBull)
        divText := "Bear (" + str.tostring(barsSinceBear) + " bars)"
        divColor := bearCol
    else if not na(barsSinceBull)
        divText := "Bull (" + str.tostring(barsSinceBull) + " bars)"
        divColor := bullCol

    table.cell(hud, 0, 4, "Last Div", text_color=dimColor, bgcolor=bgColor, text_size=size.small)
    table.cell(hud, 1, 4, divText, text_color=divColor, bgcolor=bgColor, text_size=size.small)

    divStatus = enableDiv ? "On" : "Off"
    table.cell(hud, 0, 5, "Div Engine", text_color=dimColor, bgcolor=bgColor, text_size=size.small)
    table.cell(hud, 1, 5, divStatus, text_color=txColor, bgcolor=bgColor, text_size=size.small)

    vsBase = "Forming"
    color vsCol = dimColor

    if not na(obvBaseline)
        if obvSmooth > obvBaseline
            vsBase := "Above Baseline"
            vsCol := bullCol
        else
            vsBase := "Below Baseline"
            vsCol := bearCol

    table.cell(hud, 0, 6, "OBV", text_color=dimColor, bgcolor=bgColor, text_size=size.small)
    table.cell(hud, 1, 6, vsBase, text_color=vsCol, bgcolor=bgColor, text_size=size.small)

    table.cell(hud, 0, 7, "Timing", text_color=color.new(hudAccentCol, 15), bgcolor=bgColor, text_size=size.tiny)
    table.cell(hud, 1, 7, "Confirmed Only", text_color=color.new(hudAccentCol, 15), bgcolor=bgColor, text_size=size.tiny)

// ==========================================================================
// Section G — Alerts
// ==========================================================================
bullBiasFlip = isBullBias and not isBullBias[1]
bearBiasFlip = isBearBias and not isBearBias[1]
obvCrossAboveBaseline = ta.crossover(obvSmooth, obvBaseline)
obvCrossBelowBaseline = ta.crossunder(obvSmooth, obvBaseline)

alertcondition(bullDiv, "Bullish Divergence",
     "ATC OBV: Confirmed bullish divergence (price LL / OBV HL)")
alertcondition(bearDiv, "Bearish Divergence",
     "ATC OBV: Confirmed bearish divergence (price HH / OBV LH)")
alertcondition(bullBiasFlip,
     "Slope Flipped Bullish", "ATC OBV: Slope bias flipped to Bullish")
alertcondition(bearBiasFlip,
     "Slope Flipped Bearish", "ATC OBV: Slope bias flipped to Bearish")
alertcondition(obvCrossAboveBaseline,
     "OBV Crossed Above Baseline", "ATC OBV: OBV crossed above rolling baseline")
alertcondition(obvCrossBelowBaseline,
     "OBV Crossed Below Baseline", "ATC OBV: OBV crossed below rolling baseline")
alertcondition(higherHigh and not na(obvPivHigh),
     "New Higher High on OBV", "ATC OBV: New structural higher high printed")
alertcondition(lowerLow and not na(obvPivLow),
     "New Lower Low on OBV", "ATC OBV: New structural lower low printed")
````
