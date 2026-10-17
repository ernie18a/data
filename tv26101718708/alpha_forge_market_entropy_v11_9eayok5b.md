# Alpha Forge Market Entropy v1.1

- url: https://www.tradingview.com/script/9EAYoK5b-Alpha-Forge-Market-Entropy-v1-1/
- type: indicator
- pine_id: PUB;6c9997f25c3542f092ebbff2dfbf452b
- version: 1.0

## Description

Market Entropy is a regime-detection oscillator designed to help traders understand whether the current market environment is clean, chaotic, compressing, or transitioning.

Most indicators focus on direction.

Market Entropy focuses on **market behavior**.

Is price moving efficiently?
Is the market chopping sideways?
Is volatility expanding?
Is price coiling before a larger move?
Is the current environment worth trading at all?

This indicator was built to answer those questions.

---

What Market Entropy Measures

Market Entropy combines two core concepts:

1. Entropy

Entropy measures how random or unpredictable recent price movement has become.

In simple terms:

* **High Entropy** = noisy, unstable, choppy, less predictable price action
* **Low Entropy** = more ordered, cleaner, compressed, or directional price action

A high entropy reading often appears when price is moving erratically, fakeouts are common, and trend-following signals may become less reliable.

A low entropy reading often appears when price behavior becomes more structured. This can happen during clean trends, tight compression, or orderly price movement.

2. Directional Efficiency

Directional Efficiency measures how effectively price is moving from point A to point B.

A market can move a lot without going anywhere. That is inefficient movement.

Efficiency helps separate:

* Clean directional movement
* Tight compression
* Random chop
* Volatility expansion

This makes the tool more useful than a basic entropy reading alone.


Market Regime States

Market Entropy classifies the market into easy-to-read conditions:

Clean

A cleaner market environment where entropy is lower and price movement is more efficient.

This is often the best environment for directional continuation signals.

Coil

A compressed environment where entropy is low but efficiency is also low.

This can suggest price is tightening, consolidating, or preparing for expansion.

Noisy

A high-entropy, low-efficiency environment.

This is often where traders get chopped up. Fakeouts, failed breakouts, and poor follow-through are more common.

Expand

A high-entropy environment with stronger directional movement or range expansion.

This can appear during sharp moves, exhaustion phases, volatility bursts, or breakout-style conditions.

Mixed

A transitional state where the market does not strongly favor clean trend, compression, chaos, or expansion.

---

How to Use It

Market Entropy is not designed to be a blind buy/sell indicator.

It is designed to act as a **market condition filter**.

The goal is to help traders decide when signals from other tools deserve more trust, and when the environment is too unstable.

Example use cases:

* Avoid low-quality entries when entropy is high and efficiency is low
* Confirm trend setups when the market is clean and efficient
* Watch for expansion after compression
* Reduce position size or wait for confirmation in noisy conditions
* Use chaos readings as a warning that fakeouts may increase

---

Reading the Dashboard

The dashboard displays:

Entropy

Shows the current normalized entropy reading.

Higher values suggest more randomness or disorder.

Efficiency

Shows how efficiently price is moving.

Higher values suggest cleaner directional movement.

Lower values suggest chop, back-and-forth movement, or compression.

Regime

Displays the current market state:

* Clean
* Coil
* Noisy
* Expand
* Mixed

Trade Quality

Provides a simple interpretation of the current environment:

* **Clean** — stronger environment for directional setups
* **Caution** — conditions may be developing, but confirmation matters
* **Poor** — choppy or noisy environment
* **Neutral** — mixed or unclear conditions

Reason

Explains why the current trade-quality state is being shown.

---

Visual Guide

The oscillator uses branded colors:

* **Cyan / Blue** = cleaner, more ordered conditions
* **Red / Magenta** = chaotic or noisy conditions
* **Slate / Neutral** = transitional or mixed conditions

Columns display entropy behavior, while the efficiency line helps show whether the market is moving cleanly or inefficiently.

Optional regime markers can highlight major shifts between clean, coiling, noisy, expanding, and mixed conditions.

---

Why Entropy Matters

Many traders only ask:

“Is price going up or down?”

But a better question is:

“Is this market environment clean enough to trust the move?”

A breakout in a clean market is very different from a breakout in a chaotic market.

A reclaim in a structured environment is very different from a reclaim during high-entropy chop.

Market Entropy helps traders understand the difference.

---

Best Used With

Market Entropy can be used on its own, but it is especially powerful when paired with:

* Liquidity sweep tools
* Trend-following indicators
* Breakout systems
* Support/resistance strategies
* Volume confirmation tools
* Alpha Forge Liquidity Matrix Pro

For example:

A liquidity reclaim during a clean or improving entropy regime may deserve more attention.

A liquidity reclaim during high-entropy chop may require extra confirmation or be ignored entirely.

---

Key Features

* Shannon-style normalized entropy oscillator
* Directional efficiency calculation
* Market regime detection
* Clean / Coil / Noisy / Expand / Mixed states
* Trade Quality dashboard
* Reason-based dashboard explanation
* Optional background regime shading
* Optional regime markers
* Alpha Forge branded visuals
* Alerts for key regime shifts


Important Notes

Market Entropy does not predict the future.

It does not know where price must go next.

Instead, it evaluates the **quality of the current trading environment**.

The purpose is to help traders avoid forcing trades during poor conditions and recognize when market structure becomes cleaner, more compressed, more chaotic, or more explosive.

As always, this tool should be used with proper risk management and in combination with a complete trading plan.

---

Summary

Market Entropy is a market regime oscillator built to help traders identify when the market is clean, chaotic, compressed, expanding, or transitioning.

It brings information theory into a simple visual format so traders can better understand whether current conditions support confidence, caution, or patience.

**Trade the signal. Respect the environment.**

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Alpha Forge

//@version=6
indicator("Alpha Forge Market Entropy v1.1", "AF Market Entropy v1.1", overlay = false, max_labels_count = 100)

//──────────────────────────────────────────────────────────────────────────────
// ALPHA FORGE MARKET ENTROPY v1.1
// Regime/filter oscillator using normalized Shannon-style entropy plus
// directional efficiency. Designed to separate clean/orderly markets from
// noisy/choppy conditions and help filter Liquidity Matrix signals.
//
// v1.1 Updates:
// - Added Trade Quality row to dashboard
// - Added regime marker cooldown
// - Added option to hide regime markers
// - Renamed marker language to CLEAN / NOISY / COMPRESS / EXPAND
// - Added optional filter mode labels and cleaner visual states
// - Softer marker defaults for mobile
//──────────────────────────────────────────────────────────────────────────────
//──────────────────────────────────────────────────────────────────────────────
// Inputs
//──────────────────────────────────────────────────────────────────────────────
groupMain   = "Entropy Engine"
groupRegime = "Regime Detection"
groupVisual = "Visuals"
groupDash   = "Dashboard"
groupAlert  = "Alerts"

length     = input.int(30, "Entropy Lookback Length", minval = 10, maxval = 300, tooltip = "Window size for entropy distribution.", group = groupMain)
bins       = input.int(8, "Number of Bins", minval = 2, maxval = 50, tooltip = "Distribution granularity. Higher = more sensitive/noisy.", group = groupMain)
smoothLen  = input.int(5, "Entropy Smoothing", minval = 1, maxval = 50, group = groupMain)
effLen     = input.int(30, "Efficiency Length", minval = 5, maxval = 300, group = groupMain)

highThresh = input.float(0.85, "High Entropy Threshold", minval = 0.10, maxval = 1.00, step = 0.05, group = groupRegime)
lowThresh  = input.float(0.65, "Low Entropy Threshold", minval = 0.10, maxval = 1.00, step = 0.05, group = groupRegime)
effTrend   = input.float(0.45, "Trend Efficiency Threshold", minval = 0.05, maxval = 1.00, step = 0.05, group = groupRegime)
effChop    = input.float(0.25, "Low Efficiency / Chop Threshold", minval = 0.01, maxval = 0.80, step = 0.05, group = groupRegime)

showColumns = input.bool(true, "Show Entropy Columns", group = groupVisual)
showEntropyLine = input.bool(true, "Show Smoothed Entropy Line", group = groupVisual)
showEfficiency = input.bool(true, "Show Efficiency Line", group = groupVisual)
showBg = input.bool(true, "Show Regime Background", group = groupVisual)
bgTrans = input.int(91, "Background Transparency", minval = 80, maxval = 100, group = groupVisual)
showMarkers = input.bool(true, "Show Regime Markers", group = groupVisual)
markerCooldown = input.int(12, "Regime Marker Cooldown Bars", minval = 0, maxval = 100, group = groupVisual)
markerTextMode = input.string("Clean", "Marker Text Mode", options = ["Clean", "Classic"], group = groupVisual)
markerSizeIn = input.string("Tiny", "Marker Size", options = ["Tiny", "Small", "Normal"], group = groupVisual)

showDash = input.bool(true, "Show Dashboard", group = groupDash)
dashPos = input.string("Top Right", "Dashboard Position", options = ["Top Right", "Top Center", "Top Left", "Middle Right", "Middle Left", "Bottom Right", "Bottom Center", "Bottom Left"], group = groupDash)
dashTextIn = input.string("Tiny", "Dashboard Text Size", options = ["Tiny", "Small", "Normal"], group = groupDash)
dashShowQuality = input.bool(true, "Show Trade Quality Row", group = groupDash)
dashShowReason = input.bool(true, "Show Reason Row", group = groupDash)

alertOnChaos = input.bool(true, "Alert: Chaos Rising", group = groupAlert)
alertOnOrder = input.bool(true, "Alert: Order Returning", group = groupAlert)
alertOnCompression = input.bool(true, "Alert: Compression", group = groupAlert)
alertOnExpansion = input.bool(true, "Alert: Chaos Expansion", group = groupAlert)

//──────────────────────────────────────────────────────────────────────────────
// Alpha Forge Colors
//──────────────────────────────────────────────────────────────────────────────
bullCol     = color.rgb(41, 211, 255)
logoBlue    = color.rgb(0, 145, 255)
silverCol   = color.rgb(185, 195, 205)
slateCol    = color.rgb(93, 107, 122)
neutralCol  = color.rgb(80, 95, 115)
chaosCol    = color.rgb(255, 55, 95)
warnCol     = color.rgb(255, 180, 60)
blackSoft   = color.rgb(8, 12, 18)

markerSize = markerSizeIn == "Tiny" ? size.tiny : markerSizeIn == "Small" ? size.small : size.normal
dashTextSize = dashTextIn == "Tiny" ? size.tiny : dashTextIn == "Small" ? size.small : size.normal

//──────────────────────────────────────────────────────────────────────────────
// Helpers
//──────────────────────────────────────────────────────────────────────────────
f_clamp(float x, float lo, float hi) =>
    math.max(lo, math.min(hi, x))

f_dash_pos(string p) =>
    p == "Top Left" ? position.top_left :
     p == "Top Center" ? position.top_center :
     p == "Middle Right" ? position.middle_right :
     p == "Middle Left" ? position.middle_left :
     p == "Bottom Right" ? position.bottom_right :
     p == "Bottom Center" ? position.bottom_center :
     p == "Bottom Left" ? position.bottom_left : position.top_right

f_regime_color(string r) =>
    r == "Ordered Trend" ? bullCol :
     r == "Compression" ? logoBlue :
     r == "Chaos / Chop" ? chaosCol :
     r == "Chaos Expansion" ? warnCol : slateCol

f_quality_color(string q) =>
    q == "Clean" ? bullCol :
     q == "Caution" ? warnCol :
     q == "Poor" ? chaosCol : slateCol

//──────────────────────────────────────────────────────────────────────────────
// Entropy Calculation
//──────────────────────────────────────────────────────────────────────────────
ret = ta.change(close)
meanRet = ta.sma(ret, length)
stdevRet = ta.stdev(ret, length)

var float[] binCounts = array.new_float(0)
if barstate.isfirst or array.size(binCounts) != bins
    array.clear(binCounts)
    for i = 0 to bins - 1
        array.push(binCounts, 0.0)

array.fill(binCounts, 0.0)

float entropy = 0.0
bool canCalcEntropy = not na(stdevRet) and stdevRet > 0 and bar_index >= length

if canCalcEntropy
    for i = 0 to length - 1
        float val = nz(ret[i])
        float z = (val - meanRet) / stdevRet
        float normZ = 1.0 / (1.0 + math.exp(-z))
        int binIdx = int(math.floor(normZ * bins))
        binIdx := int(f_clamp(binIdx, 0, bins - 1))
        float oldCount = array.get(binCounts, binIdx)
        array.set(binCounts, binIdx, oldCount + 1.0)

    for i = 0 to bins - 1
        float count = array.get(binCounts, i)
        if count > 0
            float p = count / length
            entropy -= p * math.log(p) / math.log(2)

maxEntropy = math.log(bins) / math.log(2)
normalizedEntropy = maxEntropy > 0 ? entropy / maxEntropy : 0.0
entropySmooth = ta.ema(normalizedEntropy, smoothLen)

//──────────────────────────────────────────────────────────────────────────────
// Directional Efficiency
//──────────────────────────────────────────────────────────────────────────────
moveAbs = math.abs(close - close[effLen])
pathAbs = math.sum(math.abs(ta.change(close)), effLen)
efficiency = pathAbs > 0 ? moveAbs / pathAbs : 0.0
efficiency := f_clamp(efficiency, 0.0, 1.0)

//──────────────────────────────────────────────────────────────────────────────
// Regime Engine
//──────────────────────────────────────────────────────────────────────────────
lowEntropy = entropySmooth < lowThresh
highEntropy = entropySmooth > highThresh
highEfficiency = efficiency >= effTrend
lowEfficiency = efficiency <= effChop

orderedTrend = lowEntropy and highEfficiency
compression = lowEntropy and not highEfficiency
chaosChop = highEntropy and lowEfficiency
chaosExpansion = highEntropy and not lowEfficiency
transition = not orderedTrend and not compression and not chaosChop and not chaosExpansion

regime = orderedTrend ? "Ordered Trend" : compression ? "Compression" : chaosChop ? "Chaos / Chop" : chaosExpansion ? "Chaos Expansion" : "Transition"

tradeQuality = orderedTrend ? "Clean" : compression ? "Caution" : chaosExpansion ? "Caution" : chaosChop ? "Poor" : "Neutral"
qualityReason = orderedTrend ? "Low Entropy / Efficient" : compression ? "Low Entropy / Coiling" : chaosChop ? "High Entropy / Low Efficiency" : chaosExpansion ? "High Entropy / Expansion" : "Mixed Conditions"

regimeCol = f_regime_color(regime)
qualityCol = f_quality_color(tradeQuality)

//──────────────────────────────────────────────────────────────────────────────
// Visuals
//──────────────────────────────────────────────────────────────────────────────
plotColor = highEntropy ? chaosCol : lowEntropy ? bullCol : slateCol
plot(showColumns ? normalizedEntropy : na, "Entropy Columns", color = color.new(plotColor, 5), style = plot.style_columns)
plot(showEntropyLine ? entropySmooth : na, "Smoothed Entropy", color = color.new(silverCol, 0), linewidth = 2)
plot(showEfficiency ? efficiency : na, "Directional Efficiency", color = color.new(bullCol, 10), linewidth = 2)

hline(highThresh, "Chaos Threshold", color = color.new(chaosCol, 45), linestyle = hline.style_dashed)
hline(lowThresh, "Order Threshold", color = color.new(bullCol, 45), linestyle = hline.style_dashed)
hline(effTrend, "Efficiency Trend Threshold", color = color.new(logoBlue, 70), linestyle = hline.style_dotted)
hline(effChop, "Efficiency Chop Threshold", color = color.new(slateCol, 75), linestyle = hline.style_dotted)

bgcolor(showBg ? color.new(regimeCol, bgTrans) : na, title = "Regime Background")

//──────────────────────────────────────────────────────────────────────────────
// Regime Markers with Cooldown
//──────────────────────────────────────────────────────────────────────────────
regimeChanged = regime != regime[1]
var int lastMarkerBar = na
canMark = na(lastMarkerBar) or bar_index - lastMarkerBar > markerCooldown

markerTxt = markerTextMode == "Classic" ?
     (orderedTrend ? "ORDER" : compression ? "COMPRESS" : chaosChop ? "CHAOS" : chaosExpansion ? "EXPAND" : "TRANSITION") :
     (orderedTrend ? "CLEAN" : compression ? "COIL" : chaosChop ? "NOISY" : chaosExpansion ? "EXPAND" : "MIXED")

markerY = orderedTrend or compression ? 0.08 : 0.92
markerStyle = orderedTrend or compression ? label.style_label_up : label.style_label_down

if showMarkers and regimeChanged and canMark
    label.new(bar_index, markerY, markerTxt, style = markerStyle, textcolor = color.white, color = color.new(regimeCol, 5), size = markerSize)
    lastMarkerBar := bar_index

//──────────────────────────────────────────────────────────────────────────────
// Dashboard
//──────────────────────────────────────────────────────────────────────────────
var table dash = table.new(f_dash_pos(dashPos), 2, 6, border_width = 1, frame_color = color.new(slateCol, 50), border_color = color.new(slateCol, 60))

f_cell(int c, int r, string txt, color bg, color tc) =>
    table.cell(dash, c, r, txt, bgcolor = bg, text_color = tc, text_size = dashTextSize)

if barstate.islast and showDash
    f_cell(0, 0, "AF ENTROPY", color.new(blackSoft, 0), bullCol)
    f_cell(1, 0, "v1.1", color.new(blackSoft, 0), silverCol)
    f_cell(0, 1, "Entropy", color.new(blackSoft, 10), color.white)
    f_cell(1, 1, str.tostring(entropySmooth, "#.##"), color.new(plotColor, 80), color.white)
    f_cell(0, 2, "Efficiency", color.new(blackSoft, 10), color.white)
    f_cell(1, 2, str.tostring(efficiency, "#.##"), color.new(bullCol, 85), color.white)
    f_cell(0, 3, "Regime", color.new(blackSoft, 10), color.white)
    f_cell(1, 3, regime, color.new(regimeCol, 75), color.white)
    if dashShowQuality
        f_cell(0, 4, "Trade Quality", color.new(blackSoft, 10), color.white)
        f_cell(1, 4, tradeQuality, color.new(qualityCol, 75), color.white)
    else
        f_cell(0, 4, "", color.new(blackSoft, 100), color.white)
        f_cell(1, 4, "", color.new(blackSoft, 100), color.white)
    if dashShowReason
        f_cell(0, 5, "Reason", color.new(blackSoft, 10), color.white)
        f_cell(1, 5, qualityReason, color.new(blackSoft, 10), color.white)
    else
        f_cell(0, 5, "", color.new(blackSoft, 100), color.white)
        f_cell(1, 5, "", color.new(blackSoft, 100), color.white)

if barstate.islast and not showDash
    table.clear(dash, 0, 0, 1, 5)

//──────────────────────────────────────────────────────────────────────────────
// Alerts
//──────────────────────────────────────────────────────────────────────────────
chaosRising = alertOnChaos and regimeChanged and (chaosChop or chaosExpansion)
orderReturning = alertOnOrder and regimeChanged and orderedTrend
compressionAlert = alertOnCompression and regimeChanged and compression
expansionAlert = alertOnExpansion and regimeChanged and chaosExpansion

alertcondition(chaosRising, "AF Entropy Chaos Rising", "AF Market Entropy: Chaos/noise regime detected on {{ticker}}.")
alertcondition(orderReturning, "AF Entropy Order Returning", "AF Market Entropy: Ordered trend regime detected on {{ticker}}.")
alertcondition(compressionAlert, "AF Entropy Compression", "AF Market Entropy: Compression/coiling regime detected on {{ticker}}.")
alertcondition(expansionAlert, "AF Entropy Chaos Expansion", "AF Market Entropy: High entropy expansion detected on {{ticker}}.")
alertcondition(regimeChanged, "AF Entropy Regime Change", "AF Market Entropy: Regime changed on {{ticker}}.")

// End v1.1
````
