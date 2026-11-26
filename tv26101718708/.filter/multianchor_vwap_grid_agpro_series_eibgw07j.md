# Multi-Anchor VWAP Grid [AGPro Series]

- url: https://www.tradingview.com/script/eIbGW07J-Multi-Anchor-VWAP-Grid-AGPro-Series/
- type: indicator
- pine_id: PUB;56b1c0c9a842430ba98d4f06ce12e552
- version: 4.0

## Description

Multi-Anchor VWAP Grid [AGPro Series]

🔹  Overview

Multi-Anchor VWAP Grid is a volume-weighted analysis tool that plots five independently anchored VWAP lines on the same chart — anchored from swing high, swing low, higher-timeframe pivot, all-time high, and session open. Each anchored VWAP includes optional ±1σ and ±2σ standard deviation bands, forming a dynamic grid of volume-weighted support and resistance levels. When three or more VWAPs converge within a tight ATR-based band, the indicator draws a rectangular confluence zone highlighting the area as a higher-probability price reaction region.

The script is fully automatic. All five anchors are detected by internal engines (pivot detection, session detection, timeframe change detection, all-time-high tracker) and require no manual date picking or retroactive anchor placement. Install the indicator, select which anchors you want active, and the grid builds itself.

🔹  What It Does Differently

Most anchored VWAP tools plot one anchor at a time and require the user to manually place the anchor each time a new swing or event is identified. This script plots five anchors simultaneously and lets them compete for relevance. When multiple independent anchors agree on a price level, that agreement itself becomes the signal — visualized as a confluence zone. A single VWAP is one data point. Five VWAPs intersecting within 0.5 ATR of each other is a structural event.

The confluence detection engine tests each active VWAP as a reference point, counts how many others fall within the user-defined ATR tolerance, and picks the densest cluster on each bar. A minimum VWAP count threshold (default 3) prevents noise, and a lifecycle manager extends, adaptively resizes, and expires zones based on bar age and midpoint drift.

🔹  Methodology

**Anchor engines**
Swing High and Swing Low VWAPs reset on each confirmed pivot using the standard ta.pivothigh / ta.pivotlow detector with a configurable lookback length. HTF Pivot VWAP resets at the start of each selected higher-timeframe period (daily, weekly, or monthly) using timeframe.change. ATH VWAP resets whenever a new all-time high is printed on the visible chart. Session Open VWAP resets at the first bar of each trading session defined by the session window input.

**VWAP calculation**
Each anchor maintains three running accumulators since its last reset: sum of (price × volume), sum of volume, and sum of (price² × volume). VWAP is computed as the first divided by the second. Standard deviation is derived from the variance identity: sqrt(E[X²] − E[X]²), where E[X²] and E[X] are computed from the running accumulators. Bands are plotted at configurable multipliers of this running standard deviation.

**Confluence engine**
On each bar, the script evaluates every active VWAP as a potential cluster center. For each candidate center, it counts how many other active VWAPs fall within ATR × tolerance distance. The cluster with the highest count wins. If the winning count meets or exceeds the minimum threshold, the bar is marked as confluence-active.

**Zone lifecycle**
When confluence becomes active, a new rectangular zone is created spanning the min/max of the clustered VWAPs. As long as confluence remains active and the cluster midpoint drifts less than 0.5 ATR from its original midpoint, the zone extends to the current bar and adaptively resizes with rate-limited expansion (maximum 1 ATR growth per bar per direction, preventing erratic stretching). If the midpoint drifts more than 0.5 ATR, a new zone is created. A 5-bar debounce prevents micro-breaks in confluence from prematurely closing active zones. Zones auto-expire after a configurable age limit (default 120 bars).

🔹  Signals and Panel Readouts

The information panel in the top-right corner (position and theme configurable) displays:

- **Price Bias** — count of VWAPs price is currently above vs below, with an overall BULL / BEAR / MIXED classification
- **Confluence** — current status (active with cluster count, or none) and the minimum-count threshold in use
- **Closest VWAP** — which of the five VWAPs is currently closest to price, and the distance in ATR units
- **Active VWAPs** — each enabled VWAP's current value and percent distance from close

Two alert conditions are built in: new confluence zone detection, and price crossing any active VWAP line.

🔹  Key Inputs

**Anchor Points group** — toggle each of the five VWAPs on or off, set swing pivot lookback length, choose HTF timeframe (D/W/M), define the session window for intraday anchoring.

**Deviation Bands group** — toggle bands on or off, configure band 1 and band 2 multipliers, enable or disable gradient fills between VWAP and the first band.

**Confluence Zones group** — toggle zones on or off, set minimum VWAPs required for a confluence (2 to 5), adjust the ATR-based tolerance, define maximum zone age in bars.

**Panel group** — toggle panel, choose location (six positions), select Dark or Light theme, set font size (Small / Normal / Large).

**Labels group** — toggle the compact end-of-line labels that identify each VWAP at the right edge of the chart.

🔹  How to Use

This indicator is designed as a context layer, not a standalone entry signal. Suggested workflow:

**1. Identify structural bias.** Check the Price Bias row in the panel. If 4 or 5 VWAPs sit below price (BULL), the market is trading above its most relevant volume-weighted averages across multiple timeframes and event contexts. The opposite applies for BEAR.

**2. Watch for confluence formation.** When the panel shows Confluence ACTIVE with 3 or more VWAPs clustered, a meaningful volume-weighted support or resistance area is forming. These zones often precede reaction or reversal behavior.

**3. Use bands for context.** When price trades near the ±1σ band of a single VWAP, reversion back toward that VWAP is statistically more likely. ±2σ extensions indicate volatility outliers.

**4. Cross-reference with your own tools.** This script is most useful combined with price action, volume profile, or a trend filter of your choice. It does not generate entries or exits on its own.

🔹  Tips

- On crypto 24h markets, set Session Window to 0000-2359 for a full-day session VWAP.
- Higher Swing Pivot Length values (30–50) filter noise on higher timeframes; lower values (10–15) are better for intraday.
- If the chart feels visually crowded, disable the ±2σ bands or reduce the number of active anchors. All five are rarely needed simultaneously.
- For the strongest confluence signals, increase Min VWAPs for Confluence to 4 — rarer but higher conviction.

🔹  Limitations and Transparency

- The script uses standard Pine Script pivot detection for swing anchors. Pivots are confirmed only after the pivot length has passed, which means swing VWAP anchors are placed retrospectively by that many bars. This is an inherent limitation of all pivot-based tools, not a bug.
- ATH tracking is limited to the visible chart range. On timeframes or symbols where the chart does not load full history, the "ATH" anchor represents the highest point within loaded data, not the true all-time high.
- Standard deviation bands assume price dispersion around each VWAP is approximately normal over the anchored period. In strongly trending markets, this assumption weakens and bands may widen significantly.
- Confluence zones are descriptive, not predictive. They mark areas where multiple volume-weighted averages happen to agree. They do not guarantee price reaction, only indicate where reaction is more plausible than average.
- Session Window input must match the instrument's trading hours to produce a meaningful intraday VWAP. Incorrect session definitions will produce misleading anchor points.

🔹  Risk Disclosure

This indicator is provided for educational and analytical purposes only. It is not financial advice, investment advice, or a recommendation to buy, sell, or hold any asset. All trading involves substantial risk of loss. Past chart behavior and historical VWAP reactions do not guarantee future results. Users are solely responsible for their own trading decisions and risk management. Always combine indicator output with independent analysis and appropriate position sizing. The author accepts no responsibility for any financial outcome resulting from the use of this script.

## Source Code

````pine
// -------------------------------------------------
// Multi-Anchor VWAP Grid [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 1.5
//
// Multi-Anchor VWAP Grid maps five anchored VWAP references into a cleaner
// volume-weighted support and resistance framework. It tracks confirmed swing
// high, confirmed swing low, higher-timeframe, all-time-high, and session
// anchors, then highlights VWAP confluence clusters where multiple fair-value
// references compress into the same price area. Version 1.5 aligns swing
// accumulation with the confirmed pivot bar and hardens confluence-hold proof.
// -------------------------------------------------

//@version=6
indicator("Multi-Anchor VWAP Grid [AGPro Series]",
     shorttitle = "AG MAVG",
     overlay = true,
     max_lines_count = 10,
     max_labels_count = 40,
     max_boxes_count = 6)

// -------------------------------------------------
// AGPro Color Palette
// -------------------------------------------------
headerBg      = color.rgb(37, 99, 235)
headerText    = color.rgb(245, 247, 250)
panelBg       = color.rgb(15, 23, 42)
panelBorder   = color.rgb(51, 65, 85)
panelLabelCol = color.rgb(148, 163, 184)
panelValueCol = color.rgb(226, 232, 240)
bullColor     = color.rgb(34, 197, 166)
bearColor     = color.rgb(244, 114, 182)
neutralColor  = color.rgb(245, 189, 92)
accentColor   = color.rgb(129, 140, 248)
sessionColor  = color.rgb(96, 165, 250)

colSwingHigh = bearColor
colSwingLow  = bullColor
colHtf       = accentColor
colAth       = neutralColor
colSession   = sessionColor

// -------------------------------------------------
// Input groups
// -------------------------------------------------
gAnchors = "Anchor Points"
gBands   = "Deviation Bands"
gConf    = "Confluence Engine"
gVisual  = "Visual Layer"
gLabels  = "Labels"
gPanel   = "Panel"
gAlerts  = "Alerts"

// -------------------------------------------------
// Inputs
// -------------------------------------------------
showSwingH  = input.bool(true, "Swing High VWAP", group = gAnchors, tooltip = "Anchors VWAP from the latest confirmed swing high. Confirmation waits for the pivot window to close, which keeps the anchor stable.")
showSwingL  = input.bool(true, "Swing Low VWAP", group = gAnchors, tooltip = "Anchors VWAP from the latest confirmed swing low. Confirmation waits for the pivot window to close, which keeps the anchor stable.")
showHtf     = input.bool(true, "HTF Pivot VWAP", group = gAnchors, tooltip = "Anchors VWAP from the selected higher-timeframe period open.")
showAth     = input.bool(true, "ATH VWAP", group = gAnchors, tooltip = "Anchors VWAP from the highest high observed in the loaded chart history.")
showSession = input.bool(true, "Session VWAP", group = gAnchors, tooltip = "Anchors VWAP from the selected session start.")

pivotLen   = input.int(20, "Swing Pivot Length", minval = 3, maxval = 100, group = gAnchors, tooltip = "Pivot confirmation window used for swing high and swing low anchors.")
htfTf      = input.string("D", "HTF Anchor Timeframe", options = ["D", "W", "M"], group = gAnchors, tooltip = "Higher-timeframe anchor reset used by the HTF Pivot VWAP.")
sessionDef = input.session("0000-2359", "Session Window", group = gAnchors, tooltip = "Session window used by the Session VWAP. Use 0000-2359 for crypto and forex, or a regular session such as 0930-1600 for equities.")

bandMode  = input.string("Primary Only", "Band Display", options = ["Off", "Primary Only", "All Anchors"], group = gBands, tooltip = "Controls deviation band visibility. Primary Only shows bands for the HTF and Session VWAPs to keep the chart readable.")
band1Mult = input.float(1.0, "Band 1 Multiplier", minval = 0.1, maxval = 5.0, step = 0.1, group = gBands, tooltip = "First standard-deviation multiplier around each displayed VWAP.")
band2Mult = input.float(2.0, "Band 2 Multiplier", minval = 0.1, maxval = 8.0, step = 0.1, group = gBands, tooltip = "Second standard-deviation multiplier around each displayed VWAP.")
fillBands = input.bool(true, "Fill Primary Bands", group = gBands, tooltip = "Adds a subtle fill to the primary band set for visual depth without overwhelming the chart.")

showConfZones = input.bool(true, "Show Confluence Zones", group = gConf, tooltip = "Draws a zone when enough active VWAPs cluster within the selected ATR tolerance.")
confMinCount  = input.int(3, "Min VWAPs for Confluence", minval = 2, maxval = 5, group = gConf, tooltip = "Minimum number of active VWAPs required to form a confluence zone.")
confTolAtr    = input.float(0.45, "Confluence Tolerance (ATR)", minval = 0.10, maxval = 2.00, step = 0.05, group = gConf, tooltip = "Maximum ATR-scaled vertical distance allowed between clustered VWAPs.")
zoneExtend    = input.int(22, "Zone Projection Bars", minval = 5, maxval = 160, group = gConf, tooltip = "How far active confluence zones project to the right.")
zoneMaxAge    = input.int(90, "Zone Max Age", minval = 20, maxval = 500, group = gConf, tooltip = "Maximum number of bars a confluence zone remains visible.")
zoneCooldown  = input.int(50, "Zone Cooldown Bars", minval = 1, maxval = 160, group = gConf, tooltip = "Minimum spacing between independent confluence zones. The longer default prevents repeated cluster labels around the same structure.")
holdWindow    = input.int(20, "Confluence Hold Proof Window (bars)", minval = 4, maxval = 200, group = gConf, tooltip = "Number of bars a fresh confluence zone has to hold as support or resistance within. Hold Proof measures historical reaction only and is not a forecast.")

lineWidth       = input.int(2, "VWAP Line Width", minval = 1, maxval = 4, group = gVisual, tooltip = "Line width used for the main VWAP grid.")
showZoneText    = input.bool(true, "Show Centered Zone Text", group = gVisual, tooltip = "Displays a centered label inside the active confluence zone.")
showBarTint     = input.bool(false, "Tint Bars by Grid Bias", group = gVisual, tooltip = "Applies a subtle bar tint when price is above or below most active VWAPs.")
hideInactiveAth = input.bool(false, "Hide ATH VWAP on Intraday", group = gVisual, tooltip = "Optionally hides the ATH VWAP on intraday charts when it is too far from current price.")

showEndLabels   = input.bool(true, "Show VWAP End Labels", group = gLabels, tooltip = "Displays compact right-side labels for active VWAPs.")
showEventLabels = input.bool(true, "Show Confluence Event Labels", group = gLabels, tooltip = "Displays a compact label when a fresh confluence zone appears.")
labelDensity    = input.string("Balanced", "Label Density", options = ["Minimal", "Balanced", "Detailed"], group = gLabels, tooltip = "Controls how many event labels are retained on the chart.")
labelTextInput  = input.string("Normal", "Label Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = gLabels, tooltip = "Text size used for chart labels.")
labelOffsetATR  = input.float(0.90, "Label Offset (ATR)", minval = 0.10, maxval = 3.00, step = 0.05, group = gLabels, tooltip = "ATR-based label spacing used to keep labels away from candles and nearby VWAP lines.")

showPanel      = input.bool(true, "Show Panel", group = gPanel, tooltip = "Displays the AG Pro VWAP grid panel.")
panelPos       = input.string("Top Right", "Panel Position", options = ["Top Right", "Top Left", "Middle Right", "Middle Left", "Bottom Right", "Bottom Left"], group = gPanel, tooltip = "Panel placement on the chart.")
panelTheme     = input.string("Auto", "Panel Theme", options = ["Auto", "Dark", "Light"], group = gPanel, tooltip = "Panel theme. Auto adapts to the chart background.")
panelTextInput = input.string("Normal", "Panel Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = gPanel, tooltip = "Text size used inside the panel.")

alertConfluence = input.bool(true, "Alert: New Confluence Zone", group = gAlerts, tooltip = "Triggers when a fresh VWAP confluence zone appears.")
alertGridFlip   = input.bool(true, "Alert: Grid Bias Flip", group = gAlerts, tooltip = "Triggers when price flips from above most active VWAPs to below most active VWAPs, or the reverse.")
alertVwapTouch  = input.bool(false, "Alert: VWAP Touch", group = gAlerts, tooltip = "Optional alert when price touches any active VWAP reference.")

// -------------------------------------------------
// Helpers
// -------------------------------------------------
f_size(string value) =>
    switch value
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Large"  => size.large
        => size.normal

f_panel_pos(string value) =>
    switch value
        "Top Left"     => position.top_left
        "Middle Right" => position.middle_right
        "Middle Left"  => position.middle_left
        "Bottom Right" => position.bottom_right
        "Bottom Left"  => position.bottom_left
        => position.top_right

f_dark_mode(string mode) =>
    lum = color.r(chart.bg_color) * 0.299 + color.g(chart.bg_color) * 0.587 + color.b(chart.bg_color) * 0.114
    mode == "Dark" ? true : mode == "Light" ? false : lum < 140

f_text_on(color bgColor) =>
    bright = (color.r(bgColor) * 299 + color.g(bgColor) * 587 + color.b(bgColor) * 114) / 1000
    bright >= 145 ? color.rgb(15, 23, 42) : color.rgb(248, 250, 252)

f_trim_labels(array<label> items, int keep) =>
    while array.size(items) > keep
        oldItem = array.shift(items)
        if not na(oldItem)
            label.delete(oldItem)

f_fmt(float value) =>
    na(value) ? "n/a" : str.tostring(value, format.mintick)

f_pct(float value) =>
    na(value) ? "n/a" : str.tostring(value, "#.##") + "%"

f_active(bool enabled, float value) =>
    enabled and not na(value)

f_stdev(float pv, float vv, float p2v) =>
    vv > 0 ? math.sqrt(math.max(0.0, (p2v / vv) - math.pow(pv / vv, 2))) : na

f_count_cluster(float ref, float tolv, bool useSH, float sh, bool useSL, float sl, bool useHT, float ht, bool useAT, float at, bool useSS, float ss) =>
    int count = 0
    float lowV = na
    float highV = na
    if useSH and not na(sh) and math.abs(sh - ref) <= tolv
        count += 1
        lowV := na(lowV) ? sh : math.min(lowV, sh)
        highV := na(highV) ? sh : math.max(highV, sh)
    if useSL and not na(sl) and math.abs(sl - ref) <= tolv
        count += 1
        lowV := na(lowV) ? sl : math.min(lowV, sl)
        highV := na(highV) ? sl : math.max(highV, sl)
    if useHT and not na(ht) and math.abs(ht - ref) <= tolv
        count += 1
        lowV := na(lowV) ? ht : math.min(lowV, ht)
        highV := na(highV) ? ht : math.max(highV, ht)
    if useAT and not na(at) and math.abs(at - ref) <= tolv
        count += 1
        lowV := na(lowV) ? at : math.min(lowV, at)
        highV := na(highV) ? at : math.max(highV, at)
    if useSS and not na(ss) and math.abs(ss - ref) <= tolv
        count += 1
        lowV := na(lowV) ? ss : math.min(lowV, ss)
        highV := na(highV) ? ss : math.max(highV, ss)
    [count, lowV, highV]

// -------------------------------------------------
// Core data
// -------------------------------------------------
txtSize = f_size(labelTextInput)
panelSize = f_size(panelTextInput)
atr = nz(ta.atr(14), syminfo.mintick * 20.0)
src = hlc3
vol = nz(volume, 0.0)

// -------------------------------------------------
// Anchor detection
// -------------------------------------------------
ph = ta.pivothigh(high, pivotLen, pivotLen)
pl = ta.pivotlow(low, pivotLen, pivotLen)

var int swingHAnchorBar = na
var int swingLAnchorBar = na

if not na(ph)
    swingHAnchorBar := bar_index - pivotLen
if not na(pl)
    swingLAnchorBar := bar_index - pivotLen

resetSwingH = not na(ph)
resetSwingL = not na(pl)
resetHtf = timeframe.change(htfTf)

var float athValue = na
resetAth = false
if na(athValue) or high > athValue
    athValue := high
    resetAth := true

inSession = not na(time(timeframe.period, sessionDef))
sessStart = inSession and (bar_index == 0 or inSession[1] == false)

// -------------------------------------------------
// VWAP accumulators
// -------------------------------------------------
var float shPV = 0.0
var float shV = 0.0
var float shP2V = 0.0
var float slPV = 0.0
var float slV = 0.0
var float slP2V = 0.0
var float htPV = 0.0
var float htV = 0.0
var float htP2V = 0.0
var float atPV = 0.0
var float atV = 0.0
var float atP2V = 0.0
var float ssPV = 0.0
var float ssV = 0.0
var float ssP2V = 0.0

float pvBar = src * vol
float p2vBar = src * src * vol

// A confirmed pivot belongs pivotLen bars back. Rebuild that short confirmed
// segment once so the VWAP starts at the pivot itself, not at confirmation.
if resetSwingH
    shPV := math.sum(pvBar, pivotLen + 1)
    shV := math.sum(vol, pivotLen + 1)
    shP2V := math.sum(p2vBar, pivotLen + 1)
else if not na(swingHAnchorBar)
    shPV += pvBar
    shV += vol
    shP2V += p2vBar
if resetSwingL
    slPV := math.sum(pvBar, pivotLen + 1)
    slV := math.sum(vol, pivotLen + 1)
    slP2V := math.sum(p2vBar, pivotLen + 1)
else if not na(swingLAnchorBar)
    slPV += pvBar
    slV += vol
    slP2V += p2vBar

if resetHtf or htV <= 0.0
    htPV := pvBar
    htV := vol
    htP2V := p2vBar
else
    htPV += pvBar
    htV += vol
    htP2V += p2vBar
if resetAth or atV <= 0.0
    atPV := pvBar
    atV := vol
    atP2V := p2vBar
else
    atPV += pvBar
    atV += vol
    atP2V += p2vBar
if sessStart
    ssPV := pvBar
    ssV := vol
    ssP2V := p2vBar
else if inSession
    ssPV += pvBar
    ssV += vol
    ssP2V += p2vBar

vwapSH = not na(swingHAnchorBar) and shV > 0 ? shPV / shV : na
vwapSL = not na(swingLAnchorBar) and slV > 0 ? slPV / slV : na
vwapHT = htV > 0 ? htPV / htV : na
vwapATRaw = atV > 0 ? atPV / atV : na
vwapSS = inSession and ssV > 0 ? ssPV / ssV : na
showAthResolved = showAth and not (hideInactiveAth and timeframe.isintraday)
vwapAT = showAthResolved ? vwapATRaw : na

devSH = f_stdev(shPV, shV, shP2V)
devSL = f_stdev(slPV, slV, slP2V)
devHT = f_stdev(htPV, htV, htP2V)
devAT = f_stdev(atPV, atV, atP2V)
devSS = f_stdev(ssPV, ssV, ssP2V)

useSH = f_active(showSwingH, vwapSH)
useSL = f_active(showSwingL, vwapSL)
useHT = f_active(showHtf, vwapHT)
useAT = f_active(showAthResolved, vwapAT)
useSS = f_active(showSession, vwapSS)

// -------------------------------------------------
// Plot layer
// -------------------------------------------------
plot(useSH ? vwapSH : na, "Swing High VWAP", color = colSwingHigh, linewidth = lineWidth)
plot(useSL ? vwapSL : na, "Swing Low VWAP", color = colSwingLow, linewidth = lineWidth)
plot(useHT ? vwapHT : na, "HTF Pivot VWAP", color = colHtf, linewidth = lineWidth)
plot(useAT ? vwapAT : na, "ATH VWAP", color = colAth, linewidth = lineWidth)
plot(useSS ? vwapSS : na, "Session VWAP", color = colSession, linewidth = lineWidth)

bandsOn = bandMode != "Off"
allBands = bandMode == "All Anchors"
primaryBands = bandMode == "Primary Only"

shU1 = useSH and bandsOn and allBands ? vwapSH + devSH * band1Mult : na
shL1 = useSH and bandsOn and allBands ? vwapSH - devSH * band1Mult : na
shU2 = useSH and bandsOn and allBands ? vwapSH + devSH * band2Mult : na
shL2 = useSH and bandsOn and allBands ? vwapSH - devSH * band2Mult : na
slU1 = useSL and bandsOn and allBands ? vwapSL + devSL * band1Mult : na
slL1 = useSL and bandsOn and allBands ? vwapSL - devSL * band1Mult : na
slU2 = useSL and bandsOn and allBands ? vwapSL + devSL * band2Mult : na
slL2 = useSL and bandsOn and allBands ? vwapSL - devSL * band2Mult : na
htU1 = useHT and bandsOn ? vwapHT + devHT * band1Mult : na
htL1 = useHT and bandsOn ? vwapHT - devHT * band1Mult : na
htU2 = useHT and bandsOn and allBands ? vwapHT + devHT * band2Mult : na
htL2 = useHT and bandsOn and allBands ? vwapHT - devHT * band2Mult : na
atU1 = useAT and bandsOn and allBands ? vwapAT + devAT * band1Mult : na
atL1 = useAT and bandsOn and allBands ? vwapAT - devAT * band1Mult : na
ssU1 = useSS and bandsOn ? vwapSS + devSS * band1Mult : na
ssL1 = useSS and bandsOn ? vwapSS - devSS * band1Mult : na
ssU2 = useSS and bandsOn and allBands ? vwapSS + devSS * band2Mult : na
ssL2 = useSS and bandsOn and allBands ? vwapSS - devSS * band2Mult : na

pSHU1 = plot(shU1, "SH +1 SD", color = color.new(colSwingHigh, 70), linewidth = 1)
pSHL1 = plot(shL1, "SH -1 SD", color = color.new(colSwingHigh, 70), linewidth = 1)
plot(shU2, "SH +2 SD", color = color.new(colSwingHigh, 84), linewidth = 1)
plot(shL2, "SH -2 SD", color = color.new(colSwingHigh, 84), linewidth = 1)
pSLU1 = plot(slU1, "SL +1 SD", color = color.new(colSwingLow, 70), linewidth = 1)
pSLL1 = plot(slL1, "SL -1 SD", color = color.new(colSwingLow, 70), linewidth = 1)
plot(slU2, "SL +2 SD", color = color.new(colSwingLow, 84), linewidth = 1)
plot(slL2, "SL -2 SD", color = color.new(colSwingLow, 84), linewidth = 1)
pHTU1 = plot(htU1, "HTF +1 SD", color = color.new(colHtf, 68), linewidth = 1)
pHTL1 = plot(htL1, "HTF -1 SD", color = color.new(colHtf, 68), linewidth = 1)
plot(htU2, "HTF +2 SD", color = color.new(colHtf, 84), linewidth = 1)
plot(htL2, "HTF -2 SD", color = color.new(colHtf, 84), linewidth = 1)
pATU1 = plot(atU1, "ATH +1 SD", color = color.new(colAth, 72), linewidth = 1)
pATL1 = plot(atL1, "ATH -1 SD", color = color.new(colAth, 72), linewidth = 1)
pSSU1 = plot(ssU1, "Session +1 SD", color = color.new(colSession, 68), linewidth = 1)
pSSL1 = plot(ssL1, "Session -1 SD", color = color.new(colSession, 68), linewidth = 1)
plot(ssU2, "Session +2 SD", color = color.new(colSession, 84), linewidth = 1)
plot(ssL2, "Session -2 SD", color = color.new(colSession, 84), linewidth = 1)

fill(pHTU1, pHTL1, color = fillBands and bandsOn ? color.new(colHtf, 93) : na, title = "HTF Band Fill")
fill(pSSU1, pSSL1, color = fillBands and bandsOn ? color.new(colSession, 93) : na, title = "Session Band Fill")
fill(pSHU1, pSHL1, color = fillBands and allBands ? color.new(colSwingHigh, 94) : na, title = "Swing High Band Fill")
fill(pSLU1, pSLL1, color = fillBands and allBands ? color.new(colSwingLow, 94) : na, title = "Swing Low Band Fill")
fill(pATU1, pATL1, color = fillBands and allBands ? color.new(colAth, 95) : na, title = "ATH Band Fill")

// -------------------------------------------------
// Grid bias and confluence
// -------------------------------------------------
int activeCount = 0
int aboveCount = 0
if useSH
    activeCount += 1
    aboveCount += close > vwapSH ? 1 : 0
if useSL
    activeCount += 1
    aboveCount += close > vwapSL ? 1 : 0
if useHT
    activeCount += 1
    aboveCount += close > vwapHT ? 1 : 0
if useAT
    activeCount += 1
    aboveCount += close > vwapAT ? 1 : 0
if useSS
    activeCount += 1
    aboveCount += close > vwapSS ? 1 : 0

belowCount = activeCount - aboveCount
gridBias = activeCount == 0 ? 0 : aboveCount > belowCount ? 1 : aboveCount < belowCount ? -1 : 0
gridScore = activeCount > 0 ? int(math.round(math.abs(aboveCount - belowCount) / activeCount * 100.0)) : 0
gridState = activeCount == 0 ? "WAIT" : gridBias == 1 and gridScore >= 60 ? "READY UP" : gridBias == -1 and gridScore >= 60 ? "READY DOWN" : gridBias == 1 ? "LEAN UP" : gridBias == -1 ? "LEAN DOWN" : "BALANCED"
gridColor = gridBias == 1 ? bullColor : gridBias == -1 ? bearColor : neutralColor

tol = atr * confTolAtr
int bestCount = 0
float bestLo = na
float bestHi = na

if useSH
    [c1, lo1, hi1] = f_count_cluster(vwapSH, tol, useSH, vwapSH, useSL, vwapSL, useHT, vwapHT, useAT, vwapAT, useSS, vwapSS)
    if c1 > bestCount
        bestCount := c1
        bestLo := lo1
        bestHi := hi1
if useSL
    [c2, lo2, hi2] = f_count_cluster(vwapSL, tol, useSH, vwapSH, useSL, vwapSL, useHT, vwapHT, useAT, vwapAT, useSS, vwapSS)
    if c2 > bestCount
        bestCount := c2
        bestLo := lo2
        bestHi := hi2
if useHT
    [c3, lo3, hi3] = f_count_cluster(vwapHT, tol, useSH, vwapSH, useSL, vwapSL, useHT, vwapHT, useAT, vwapAT, useSS, vwapSS)
    if c3 > bestCount
        bestCount := c3
        bestLo := lo3
        bestHi := hi3
if useAT
    [c4, lo4, hi4] = f_count_cluster(vwapAT, tol, useSH, vwapSH, useSL, vwapSL, useHT, vwapHT, useAT, vwapAT, useSS, vwapSS)
    if c4 > bestCount
        bestCount := c4
        bestLo := lo4
        bestHi := hi4
if useSS
    [c5, lo5, hi5] = f_count_cluster(vwapSS, tol, useSH, vwapSH, useSL, vwapSL, useHT, vwapHT, useAT, vwapAT, useSS, vwapSS)
    if c5 > bestCount
        bestCount := c5
        bestLo := lo5
        bestHi := hi5

confluenceActive = showConfZones and bestCount >= confMinCount and not na(bestLo) and not na(bestHi)
zonePad = atr * 0.06
zoneTop = confluenceActive ? bestHi + zonePad : na
zoneBot = confluenceActive ? bestLo - zonePad : na
zoneMid = confluenceActive ? (zoneTop + zoneBot) * 0.5 : na
confScore = confluenceActive ? int(math.round(math.min(100.0, (bestCount / math.max(activeCount, 1)) * 70.0 + math.max(0.0, 30.0 - ((bestHi - bestLo) / math.max(atr, syminfo.mintick)) * 30.0)))) : 0

var box confBox = na
var label confLabel = na
var int confBornBar = na
var int confLeftBar = na
var int lastZoneBar = na
var float lastZoneMid = na
var label[] eventLabels = array.new_label()

newZoneAllowed = na(lastZoneBar) or bar_index - lastZoneBar >= zoneCooldown
newZoneTrigger = confluenceActive and newZoneAllowed and (na(confBox) or na(lastZoneMid) or math.abs(zoneMid - lastZoneMid) > atr * 0.35)

if newZoneTrigger
    if not na(confBox)
        box.delete(confBox)
    if not na(confLabel)
        label.delete(confLabel)
        confLabel := na
    confBox := box.new(left = bar_index, top = zoneTop, right = bar_index + zoneExtend, bottom = zoneBot, xloc = xloc.bar_index, bgcolor = color.new(accentColor, 86), border_color = color.new(accentColor, 24), border_width = 1)
    confBornBar := bar_index
    confLeftBar := bar_index
    lastZoneBar := bar_index
    lastZoneMid := zoneMid
else if confluenceActive and not na(confBox)
    box.set_right(confBox, bar_index + zoneExtend)
    box.set_top(confBox, zoneTop)
    box.set_bottom(confBox, zoneBot)

// Centered solid-badge label inside the zone (never plain text on the translucent box,
// which would be invisible on a light chart background).
if showZoneText and not na(confBox) and not na(confLeftBar) and not na(zoneMid)
    int zCenterX = int(math.round((confLeftBar + bar_index + zoneExtend) / 2.0))
    string zText = "VWAP CLUSTER | " + str.tostring(bestCount) + "/" + str.tostring(activeCount) + " | Q " + str.tostring(confScore)
    if na(confLabel)
        confLabel := label.new(zCenterX, zoneMid, zText, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_center, color = color.new(accentColor, 0), textcolor = f_text_on(accentColor), size = txtSize, textalign = text.align_center)
    else
        label.set_xy(confLabel, zCenterX, zoneMid)
        label.set_text(confLabel, zText)
        label.set_color(confLabel, color.new(accentColor, 0))
        label.set_textcolor(confLabel, f_text_on(accentColor))
        label.set_size(confLabel, txtSize)
else if not showZoneText and not na(confLabel)
    label.delete(confLabel)
    confLabel := na

if not na(confBox) and not na(confBornBar) and bar_index - confBornBar > zoneMaxAge
    box.delete(confBox)
    confBox := na
    confBornBar := na
    confLeftBar := na
    lastZoneMid := na
    if not na(confLabel)
        label.delete(confLabel)
        confLabel := na

eventKeep = labelDensity == "Detailed" ? 6 : labelDensity == "Balanced" ? 4 : 2
if showEventLabels and newZoneTrigger
    yEvent = close >= zoneMid ? zoneTop + atr * labelOffsetATR : zoneBot - atr * labelOffsetATR
    eventStyle = close >= zoneMid ? label.style_label_down : label.style_label_up
    ev = label.new(bar_index, yEvent, "CLUSTER " + str.tostring(bestCount) + "x | Q " + str.tostring(confScore), xloc = xloc.bar_index, yloc = yloc.price, style = eventStyle, color = color.new(accentColor, 0), textcolor = headerText, size = txtSize)
    array.push(eventLabels, ev)
    f_trim_labels(eventLabels, eventKeep)

barcolor(showBarTint ? color.new(gridColor, gridBias == 0 ? 86 : 78) : na)

// -------------------------------------------------
// Confluence-hold proof
// -------------------------------------------------
// When a fresh confluence zone forms, does price hold it as support or
// resistance (react 0.6 ATR in the zone-respecting direction) before slicing
// through (close 0.3 ATR beyond the far side)? Counted once per zone. Breaking
// through first, or a window expiry with no clean reaction, is a not-held.
bool zoneCreatedNow = not na(lastZoneBar) and lastZoneBar == bar_index

var int   chTotal = 0
var int   chWon    = 0
var bool  chPend    = false
var int   chSide     = 0
var float chFav       = na
var float chAdv        = na
var int   chLeft        = 0

if barstate.isconfirmed
    if chPend and not na(chFav) and not na(chAdv)
        if chSide > 0
            if close < chAdv
                chTotal += 1
                chPend := false
            else if close >= chFav
                chTotal += 1
                chWon += 1
                chPend := false
            else
                chLeft -= 1
                if chLeft <= 0
                    chTotal += 1
                    chPend := false
        else
            if close > chAdv
                chTotal += 1
                chPend := false
            else if close <= chFav
                chTotal += 1
                chWon += 1
                chPend := false
            else
                chLeft -= 1
                if chLeft <= 0
                    chTotal += 1
                    chPend := false
    if zoneCreatedNow and not na(zoneTop) and not na(zoneBot)
        // A new independent zone closes any still-pending predecessor as a
        // transparent non-hold instead of silently excluding the new sample.
        if chPend
            chTotal += 1
            chPend := false
        chSide := close > zoneTop ? 1 : close < zoneBot ? -1 : gridBias != 0 ? gridBias : close >= zoneMid ? 1 : -1
        if chSide > 0
            chFav := zoneTop + atr * 0.60
            chAdv := zoneBot - atr * 0.30
        else
            chFav := zoneBot - atr * 0.60
            chAdv := zoneTop + atr * 0.30
        chLeft := holdWindow
        chPend := true

float chRate = chTotal > 0 ? chWon / chTotal * 100.0 : na
string holdRead = chTotal > 0 ? str.tostring(math.round(chRate)) + "% (" + str.tostring(chWon) + "/" + str.tostring(chTotal) + ")" : "Building"

// -------------------------------------------------
// End labels
// -------------------------------------------------
var label lblSH = na
var label lblSL = na
var label lblHT = na
var label lblAT = na
var label lblSS = na
var array<float> labelVals = array.new<float>()
var array<string> labelNames = array.new<string>()
var array<color> labelCols = array.new<color>()
var array<float> labelY = array.new<float>()

if barstate.islast
    if not na(lblSH)
        label.delete(lblSH)
        lblSH := na
    if not na(lblSL)
        label.delete(lblSL)
        lblSL := na
    if not na(lblHT)
        label.delete(lblHT)
        lblHT := na
    if not na(lblAT)
        label.delete(lblAT)
        lblAT := na
    if not na(lblSS)
        label.delete(lblSS)
        lblSS := na

    if showEndLabels
        array.clear(labelVals)
        array.clear(labelNames)
        array.clear(labelCols)
        array.clear(labelY)
        if useSH
            array.push(labelVals, vwapSH)
            array.push(labelNames, "SH")
            array.push(labelCols, colSwingHigh)
        if useSL
            array.push(labelVals, vwapSL)
            array.push(labelNames, "SL")
            array.push(labelCols, colSwingLow)
        if useHT
            array.push(labelVals, vwapHT)
            array.push(labelNames, "HTF")
            array.push(labelCols, colHtf)
        if useAT
            array.push(labelVals, vwapAT)
            array.push(labelNames, "ATH")
            array.push(labelCols, colAth)
        if useSS
            array.push(labelVals, vwapSS)
            array.push(labelNames, "SESS")
            array.push(labelCols, colSession)

        n = array.size(labelVals)
        if n > 0
            if n > 1
                for i = 1 to n - 1
                    keyV = array.get(labelVals, i)
                    keyN = array.get(labelNames, i)
                    keyC = array.get(labelCols, i)
                    j = i - 1
                    bool done = false
                    while j >= 0 and not done
                        if array.get(labelVals, j) > keyV
                            array.set(labelVals, j + 1, array.get(labelVals, j))
                            array.set(labelNames, j + 1, array.get(labelNames, j))
                            array.set(labelCols, j + 1, array.get(labelCols, j))
                            j -= 1
                        else
                            done := true
                    array.set(labelVals, j + 1, keyV)
                    array.set(labelNames, j + 1, keyN)
                    array.set(labelCols, j + 1, keyC)

            for i = 0 to n - 1
                array.push(labelY, array.get(labelVals, i))

            if n > 1
                collisionGap = atr * 0.45
                for pass = 0 to 2
                    for i = 0 to n - 2
                        yA = array.get(labelY, i)
                        yB = array.get(labelY, i + 1)
                        if yB - yA < collisionGap
                            mid = (yA + yB) * 0.5
                            array.set(labelY, i, mid - collisionGap * 0.5)
                            array.set(labelY, i + 1, mid + collisionGap * 0.5)

            for i = 0 to n - 1
                nm = array.get(labelNames, i)
                cc = array.get(labelCols, i)
                actual = array.get(labelVals, i)
                y = array.get(labelY, i)
                labelX = bar_index + 4 + (i % 2) * 7
                newLabel = label.new(labelX, y, nm + " " + f_fmt(actual), xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = color.new(cc, 8), textcolor = f_text_on(cc), size = txtSize, textalign = text.align_center)
                if nm == "SH"
                    lblSH := newLabel
                if nm == "SL"
                    lblSL := newLabel
                if nm == "HTF"
                    lblHT := newLabel
                if nm == "ATH"
                    lblAT := newLabel
                if nm == "SESS"
                    lblSS := newLabel

// -------------------------------------------------
// Panel
// -------------------------------------------------
float closestDist = na
string closestName = "n/a"
if useSH
    dSH = math.abs(close - vwapSH)
    if na(closestDist) or dSH < closestDist
        closestDist := dSH
        closestName := "Swing High"
if useSL
    dSL = math.abs(close - vwapSL)
    if na(closestDist) or dSL < closestDist
        closestDist := dSL
        closestName := "Swing Low"
if useHT
    dHT = math.abs(close - vwapHT)
    if na(closestDist) or dHT < closestDist
        closestDist := dHT
        closestName := "HTF Pivot"
if useAT
    dAT = math.abs(close - vwapAT)
    if na(closestDist) or dAT < closestDist
        closestDist := dAT
        closestName := "ATH"
if useSS
    dSS = math.abs(close - vwapSS)
    if na(closestDist) or dSS < closestDist
        closestDist := dSS
        closestName := "Session"

closestAtr = na(closestDist) ? na : closestDist / atr
confText = confluenceActive ? str.tostring(bestCount) + "x / " + str.tostring(confScore) + "/100" : "None"
biasText = gridBias == 1 ? "Above Grid" : gridBias == -1 ? "Below Grid" : "Mixed"

float zoneDistanceAtr = confluenceActive ? close > zoneTop ? (close - zoneTop) / atr : close < zoneBot ? (zoneBot - close) / atr : 0.0 : na
bool nearConfluence = confluenceActive and not na(zoneDistanceAtr) and zoneDistanceAtr <= 0.5
actionText = nearConfluence ? "Watch Confluence" : gridState == "READY UP" ? "Track Up Bias" : gridState == "READY DOWN" ? "Track Down Bias" : gridState == "LEAN UP" or gridState == "LEAN DOWN" ? "Wait for alignment" : "Wait Balance"
actionColor = nearConfluence ? accentColor : gridBias == 1 ? bullColor : gridBias == -1 ? bearColor : neutralColor

darkPanel = f_dark_mode(panelTheme)
panelFrame = darkPanel ? panelBorder : color.rgb(203, 213, 225)
leftBg = darkPanel ? color.rgb(13, 22, 38) : color.rgb(241, 245, 249)
rightBg = darkPanel ? color.rgb(8, 15, 28) : color.rgb(255, 255, 255)
leftTxt = darkPanel ? panelLabelCol : color.rgb(71, 85, 105)
rightTxt = darkPanel ? panelValueCol : color.rgb(15, 23, 42)
stateBg = gridState == "READY UP" ? color.new(bullColor, darkPanel ? 24 : 82) : gridState == "READY DOWN" ? color.new(bearColor, darkPanel ? 24 : 82) : gridState == "LEAN UP" or gridState == "LEAN DOWN" ? color.new(accentColor, darkPanel ? 26 : 82) : color.new(neutralColor, darkPanel ? 26 : 82)
actionBg = nearConfluence ? color.new(accentColor, darkPanel ? 24 : 82) : gridBias == 1 ? color.new(bullColor, darkPanel ? 24 : 82) : gridBias == -1 ? color.new(bearColor, darkPanel ? 24 : 82) : color.new(neutralColor, darkPanel ? 26 : 82)
confBg = confluenceActive ? color.new(accentColor, darkPanel ? 28 : 84) : rightBg
holdBg = na(chRate) ? rightBg : chRate >= 60.0 ? color.new(bullColor, darkPanel ? 28 : 84) : chRate >= 45.0 ? color.new(neutralColor, darkPanel ? 30 : 84) : color.new(bearColor, darkPanel ? 28 : 84)

var table pnl = na
var string lastPanelPos = ""
var string lastPanelTheme = ""
var bool lastPanelVisible = false

panelNeedsReset = na(pnl) or panelPos != lastPanelPos or panelTheme != lastPanelTheme or showPanel != lastPanelVisible
if panelNeedsReset
    if not na(pnl)
        table.delete(pnl)
    if showPanel
        pnl := table.new(f_panel_pos(panelPos), 2, 10, frame_color = panelFrame, border_color = panelFrame, border_width = 1)
        table.cell(pnl, 0, 0, "AG Pro Multi-Anchor VWAP Grid", text_color = headerText, bgcolor = headerBg, text_size = panelSize, text_halign = text.align_center)
        table.cell(pnl, 1, 0, "", text_color = headerText, bgcolor = headerBg, text_size = panelSize)
        table.merge_cells(pnl, 0, 0, 1, 0)
    else
        pnl := na
    lastPanelPos := panelPos
    lastPanelTheme := panelTheme
    lastPanelVisible := showPanel

if showPanel and not na(pnl) and barstate.islast
    table.clear(pnl, 0, 1, 1, 9)
    table.cell(pnl, 0, 0, "AG Pro Multi-Anchor VWAP Grid", text_color = headerText, bgcolor = headerBg, text_size = panelSize, text_halign = text.align_center)
    table.cell(pnl, 0, 1, "State", text_color = leftTxt, bgcolor = leftBg, text_size = panelSize)
    table.cell(pnl, 1, 1, gridState, text_color = f_text_on(stateBg), bgcolor = stateBg, text_size = panelSize)
    table.cell(pnl, 0, 2, "Action", text_color = leftTxt, bgcolor = leftBg, text_size = panelSize)
    table.cell(pnl, 1, 2, actionText, text_color = f_text_on(actionBg), bgcolor = actionBg, text_size = panelSize)
    table.cell(pnl, 0, 3, "Grid Bias", text_color = leftTxt, bgcolor = leftBg, text_size = panelSize)
    table.cell(pnl, 1, 3, biasText + " / " + str.tostring(gridScore) + "/100", text_color = rightTxt, bgcolor = rightBg, text_size = panelSize)
    table.cell(pnl, 0, 4, "Position", text_color = leftTxt, bgcolor = leftBg, text_size = panelSize)
    table.cell(pnl, 1, 4, str.tostring(aboveCount) + " above / " + str.tostring(belowCount) + " below", text_color = rightTxt, bgcolor = rightBg, text_size = panelSize)
    table.cell(pnl, 0, 5, "Confluence", text_color = leftTxt, bgcolor = leftBg, text_size = panelSize)
    table.cell(pnl, 1, 5, confText, text_color = confluenceActive ? f_text_on(confBg) : rightTxt, bgcolor = confBg, text_size = panelSize)
    table.cell(pnl, 0, 6, "Hold Proof", text_color = leftTxt, bgcolor = leftBg, text_size = panelSize)
    table.cell(pnl, 1, 6, holdRead, text_color = na(chRate) ? rightTxt : f_text_on(holdBg), bgcolor = holdBg, text_size = panelSize)
    table.cell(pnl, 0, 7, "Closest VWAP", text_color = leftTxt, bgcolor = leftBg, text_size = panelSize)
    table.cell(pnl, 1, 7, closestName, text_color = rightTxt, bgcolor = rightBg, text_size = panelSize)
    table.cell(pnl, 0, 8, "Distance", text_color = leftTxt, bgcolor = leftBg, text_size = panelSize)
    table.cell(pnl, 1, 8, na(closestAtr) ? "n/a" : str.tostring(closestAtr, "#.##") + " ATR", text_color = rightTxt, bgcolor = rightBg, text_size = panelSize)
    table.cell(pnl, 0, 9, "Active Anchors", text_color = leftTxt, bgcolor = leftBg, text_size = panelSize)
    table.cell(pnl, 1, 9, str.tostring(activeCount) + " / 5", text_color = rightTxt, bgcolor = rightBg, text_size = panelSize)

// -------------------------------------------------
// Alerts
// -------------------------------------------------
newConfluence = newZoneTrigger
gridFlip = gridBias != 0 and gridBias != nz(gridBias[1], 0)
touchTol = atr * 0.03
touchAny = (useSH and math.abs(close - vwapSH) <= touchTol) or (useSL and math.abs(close - vwapSL) <= touchTol) or (useHT and math.abs(close - vwapHT) <= touchTol) or (useAT and math.abs(close - vwapAT) <= touchTol) or (useSS and math.abs(close - vwapSS) <= touchTol)

alertcondition(alertConfluence and newConfluence, "New VWAP Confluence Zone", "Multi-Anchor VWAP Grid: a fresh VWAP confluence zone has appeared.")
alertcondition(alertGridFlip and gridFlip, "VWAP Grid Bias Flip", "Multi-Anchor VWAP Grid: price position flipped across the active VWAP grid.")
alertcondition(alertVwapTouch and touchAny, "VWAP Touch", "Multi-Anchor VWAP Grid: price is touching an active VWAP reference.")

plot(chRate, "Confluence Hold Proof", color = accentColor, display = display.data_window)
````
