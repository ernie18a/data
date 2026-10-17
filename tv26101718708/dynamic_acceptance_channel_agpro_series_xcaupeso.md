# Dynamic Acceptance Channel [AGPro Series]

- url: https://www.tradingview.com/script/xcaUPEsO-Dynamic-Acceptance-Channel-AGPro-Series/
- type: indicator
- pine_id: PUB;0e2c2b914cdd478fa4a6c75146a6f8f3
- version: 5.0

## Description

Dynamic Acceptance Channel [AGPro Series]

🔷 Overview
Dynamic Acceptance Channel is an adaptive volatility channel that builds a dynamic upper and lower edge around a robust median midpoint. The channel width breathes with the market's own return distribution and volatility regime, so it naturally widens when the market expands and tightens when it compresses. Every bar is classified as Inside, Breaching, or Respecting the channel, while the width itself is independently tracked as Compressed, Normal, or Expanded. The tool is designed to give traders a clean, consistent framework for reading acceptance, mean-reversion context, volatility squeezes, and adaptive range behavior across crypto, FX, and equities.

🟢 Unique Edge
Most channel indicators on the market rely on a single dispersion model — typically a moving average plus a fixed standard deviation or ATR multiplier. Dynamic Acceptance Channel takes a different route:

▪ Robust median midpoint instead of a simple mean, which stays stable when the market wicks or spikes and is not dragged around by outliers.
▪ Hybrid width model that combines the percentile spread of recent returns with a clamped ATR regime ratio. The user can switch between Hybrid, Return Percentile, or Volatility Regime, depending on whether distribution shape or raw volatility is the priority.
▪ Independent width regime classification (Compressed / Normal / Expanded) ranked against the channel's own history, with hysteresis applied so the regime does not flip-flop around threshold boundaries.
▪ Bar-level state machine (Inside, Breach, Respect) separated from the width regime, so traders can read location and regime as two orthogonal dimensions.
▪ Double-EMA smoothing on both the midpoint and the half-width, producing a calm, professional channel that is readable on any timeframe without looking jagged.

This combination is not found in common Bollinger Bands, Keltner Channels, or generic ATR channels.

🧭 Methodology
The midpoint is computed as a rolling median using linear-interpolation percentile logic, which is statistically more robust than an arithmetic mean when the return distribution is skewed or heavy-tailed. The half-width is then derived from two independent signals. The first is a return-percentile dispersion term: the script measures the 85th and 15th percentiles of recent per-bar returns, symmetrizes them, and scales by the square root of the lookback window to produce a percentile-based half-width proxy. The second is a volatility regime term: the current 14-bar ATR is compared to its own baseline over the adaptive window, and the resulting ratio is clamped between 0.6 and 1.8 to prevent explosive widths during regime shocks. The final half-width is either one of the two terms or their average, depending on the selected model, then scaled by a user-defined global multiplier and smoothed with double EMA. The width regime classification uses linear-interpolation percentiles of the channel width itself over a separate regime lookback, and a 10% hysteresis buffer prevents rapid state flipping around the Compressed and Expanded thresholds.

🎯 Signals & Alerts
▪ Channel Breached — fires on a fresh upper or lower breach, edge-triggered with a minimum three-bar gap to avoid clusters on choppy bars.
▪ Channel Compressed — fires when the width regime transitions into the Compressed state.
▪ Channel Expanded — fires when the width regime transitions into the Expanded state.
▪ Channel Respected — optional, fires when price wicked outside on the prior bar and closed back inside on the current bar, confirming a rejection at the edge.

Visuals include color-coded upper and lower lines, a regime-tinted fill, small circular breach markers on the breached line (no text labels to avoid clutter), and spaced Compressed or Expanded transition labels anchored outside the channel.

⚙️ Key Inputs
Adaptive Engine
▪ Adaptive Length — lookback window for the channel (default 60).
▪ Channel Width Model — Hybrid, Return Percentile, or Volatility Regime.
▪ Width Scale — global multiplier for tightening or loosening the channel.
▪ Channel Smoothing — EMA length for line smoothness.
▪ Strict Breach Logic — close-based versus wick-based breach.

Width Regime
▪ Compression Threshold — percentile below which the width is Compressed (default 25).
▪ Expansion Threshold — percentile above which the width is Expanded (default 75).
▪ Regime Lookback — lookback for the width percentile ranking (default 150).

Visuals
▪ Show Channel Fill, Show Midline, Show Breach Markers, Show Regime Transition Labels, Regime Label Spacing.

Panel
▪ Show / hide panel, Panel Location (6 options), Panel Font Size, Label Font Size.

Alerts
▪ Channel Breached, Compressed, Expanded, and Respected can be toggled independently.

🧠 How to Use
A common reading is to combine channel state with width regime. When the channel is Compressed and price is riding the edges, the market is often preparing for an expansion phase. When the channel transitions into Expanded, continuation on the active edge is more likely than immediate mean reversion. Respect events at either edge during Normal or Compressed regimes often line up with fade opportunities, while breaches during Expanded regimes often line up with trend continuation context. The midline can be used as a dynamic fair-value reference for pullback entries inside the channel. Traders typically overlay this script with their own structure, momentum, or higher-timeframe bias tools rather than using channel events in isolation.

⚠️ Limitations & Transparency
▪ The indicator is a context and structure tool. It does not generate buy or sell decisions and does not claim to identify every meaningful reversal or breakout.
▪ The channel is recomputed each bar from recent data, which means the current bar's channel values can refine until bar close.
▪ Width regime classification is relative to the regime lookback, not absolute. On instruments or timeframes with very low variance, the regime may behave differently than on highly volatile markets.
▪ The ATR ratio is intentionally clamped between 0.6 and 1.8. This prevents explosive widths but also means the channel will not fully mirror extreme volatility shocks; this is a deliberate design choice for readability.
▪ Alerts are configured to fire once per bar close to reduce noise. Intrabar conditions may change until close.

🛡 Risk Disclosure
This script is provided for educational and analytical purposes only. It is not a strategy, not financial advice, and not a trade recommendation. Past channel behavior on any instrument or timeframe does not imply future performance. Users are fully responsible for their own risk management, position sizing, and trading decisions.

## Source Code

````pine
// -------------------------------------------------
// Dynamic Acceptance Channel [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 1.4
//
// Dynamic Acceptance Channel is a volatility-adaptive fair value channel for
// mapping accepted price behavior, compression, expansion, channel breaches,
// and respect reactions. It builds a robust median midpoint, adapts channel
// width from return distribution and ATR regime data, then presents acceptance
// state, width regime, breach context, and live channel structure through clean
// zones, premium badges, optional markers, and a compact AG Pro decision panel.
// Version 1.3 adds a confirmation-anchored proof layer (Follow, Hold, React,
// Flip rates) showing how often channel breaches were accepted and continued
// before price reverted to the fair value midline.
// -------------------------------------------------

//@version=6
indicator("Dynamic Acceptance Channel [AGPro Series]",
     shorttitle       = "AG DAC",
     overlay          = true,
     max_lines_count  = 120,
     max_labels_count = 140,
     max_boxes_count  = 30,
     max_bars_back    = 2000)

// -------------------------------------------------
// Inputs
// -------------------------------------------------
string gEngine = "Adaptive Engine"
int adaptiveLen = input.int(60, "Adaptive Length", minval = 20, maxval = 400, group = gEngine,
     tooltip = "Lookback used to build the rolling acceptance channel. Shorter values react faster; longer values create a more structural channel.")
string widthModel = input.string("Hybrid", "Channel Width Model", options = ["Hybrid", "Return Percentile", "Volatility Regime"], group = gEngine,
     tooltip = "Selects how channel width is calculated. Hybrid combines return distribution and ATR regime data. Return Percentile follows distribution spread. Volatility Regime follows ATR expansion and compression.")
float widthScale = input.float(1.0, "Width Scale", minval = 0.4, maxval = 2.5, step = 0.1, group = gEngine,
     tooltip = "Global multiplier for channel width. Lower values tighten the channel; higher values loosen it.")
int smoothBars = input.int(5, "Channel Smoothing", minval = 1, maxval = 20, group = gEngine,
     tooltip = "EMA smoothing applied to the midpoint and channel width. Higher values produce a calmer visual channel with slightly slower response.")
bool strictBreach = input.bool(true, "Strict Breach Logic", group = gEngine,
     tooltip = "When enabled, breaches require a close beyond the channel. When disabled, wick penetration can also count as a breach.")

string gRegime = "Width Regime"
float compressPct = input.float(25.0, "Compression Threshold (%)", minval = 5.0, maxval = 45.0, step = 1.0, group = gRegime,
     tooltip = "Width percentile below which the channel is classified as Compressed.")
float expandPct = input.float(75.0, "Expansion Threshold (%)", minval = 55.0, maxval = 95.0, step = 1.0, group = gRegime,
     tooltip = "Width percentile above which the channel is classified as Expanded.")
int regimeLen = input.int(150, "Regime Lookback", minval = 50, maxval = 500, group = gRegime,
     tooltip = "Lookback used to rank current channel width against its own history.")

string gVisual = "Visuals"
bool showFill = input.bool(true, "Show Channel Fill", group = gVisual,
     tooltip = "Fills the space between the upper and lower channel with a soft regime-colored tint.")
bool showMid = input.bool(false, "Show Midline", group = gVisual,
     tooltip = "Displays the robust median midpoint of the acceptance channel.")
bool showActiveZone = input.bool(true, "Show Active Channel Zone", group = gVisual,
     tooltip = "Draws a live channel zone across the most recent bars with a centered state badge inside the channel.")
int activeZoneBars = input.int(40, "Active Zone Width (bars)", minval = 20, maxval = 160, group = gVisual,
     tooltip = "Horizontal size of the live channel zone. The center badge is placed in the middle of this zone.")
int zoneProjectionBars = input.int(8, "Right Projection Bars", minval = 2, maxval = 40, group = gVisual,
     tooltip = "How far the active channel zone projects beyond the latest bar.")
bool showBreachMarks = input.bool(false, "Show Breach Markers", group = gVisual,
     tooltip = "Displays compact markers directly on the breached channel edge. Disabled by default for a cleaner publication view.")
bool showEdgeTags = input.bool(false, "Show Upper / Lower Tags", group = gVisual,
     tooltip = "Shows compact right-side Upper and Lower channel tags. Disabled by default because the channel lines are already clear.")
bool showBarTint = input.bool(false, "Tint Breach Bars", group = gVisual,
     tooltip = "Subtly colors bars that close beyond the channel when breach conditions are active.")
int zoneTransparency = input.int(92, "Active Zone Transparency", minval = 75, maxval = 97, group = gVisual,
     tooltip = "Transparency of the active channel zone. Higher values are lighter.")

string gLabels = "Labels"
bool showReactionLabels = input.bool(true, "Show Reaction Labels", group = gLabels,
     tooltip = "Shows spaced labels for confirmed breach and respect events. Labels are placed outside candles for readability.")
bool showRegimeLabels = input.bool(false, "Show Regime Transition Labels", group = gLabels,
     tooltip = "Labels new compression and expansion states. Disabled by default to keep the public chart focused on the channel itself.")
string labelDensity = input.string("Balanced", "Label Density", options = ["Minimal", "Balanced", "Detailed"], group = gLabels,
     tooltip = "Controls how many historical reaction labels remain visible. Balanced is the recommended publication default.")
int reactionLabelSpacing = input.int(30, "Reaction Label Spacing", minval = 3, maxval = 120, group = gLabels,
     tooltip = "Minimum number of bars between reaction labels. Higher values reduce label clustering.")
int regimeLabelSpacing = input.int(48, "Regime Label Spacing", minval = 5, maxval = 160, group = gLabels,
     tooltip = "Minimum bars between consecutive regime transition labels.")
float labelOffsetAtr = input.float(0.90, "Label Offset ATR", minval = 0.10, maxval = 3.00, step = 0.05, group = gLabels,
     tooltip = "ATR-based vertical spacing used to keep event labels away from candles.")
string labelFont = input.string("Normal", "Label Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = gLabels,
     tooltip = "Controls on-chart label and badge font size. Normal is the default publish-friendly setting.")

string gPanel = "Panel"
bool showPanel = input.bool(true, "Show Panel", group = gPanel,
     tooltip = "Shows the compact status panel with state, width regime, rank, model, and channel levels.")
string panelLoc = input.string("Top Right", "Panel Location",
     options = ["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], group = gPanel,
     tooltip = "Controls where the panel is anchored on the chart.")
string panelTheme = input.string("Dark", "Panel Theme", options = ["Dark", "Light"], group = gPanel,
     tooltip = "Switches the panel between dark and light chart backgrounds.")
string panelFont = input.string("Normal", "Panel Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = gPanel,
     tooltip = "Controls panel text size. Normal is the recommended default.")

string gAlerts = "Alerts"
bool alertBreach = input.bool(true, "Alert: Channel Breached", group = gAlerts,
     tooltip = "Enables alerts for confirmed upper or lower channel breaches.")
bool alertCompress = input.bool(true, "Alert: Channel Compressed", group = gAlerts,
     tooltip = "Enables alerts when the channel shifts into compression.")
bool alertExpand = input.bool(true, "Alert: Channel Expanded", group = gAlerts,
     tooltip = "Enables alerts when the channel shifts into expansion.")
bool alertRespect = input.bool(false, "Alert: Channel Respected", group = gAlerts,
     tooltip = "Enables alerts for channel respect reactions.")

string gProof = "Proof"
bool showProof = input.bool(true, "Show Proof Layer", group = gProof,
     tooltip = "Shows the confirmation-anchored proof layer in the panel: Follow, Hold, React, and Flip rates measured across confirmed channel breaches on the current symbol and timeframe. Follow means a breach was accepted and continued one risk unit (1R) before price reverted to the fair value midline; Flip means price reverted to the midline (mean reversion). These are historical outcome rates, not predictions.")
int proofHorizonBars = input.int(16, "Proof Horizon Bars", minval = 3, maxval = 160, group = gProof,
     tooltip = "Maximum number of bars each breach is tracked for the proof measurement before it resolves at its current outcome.")
int reactBars = input.int(3, "Reaction Window Bars", minval = 1, maxval = 40, group = gProof,
     tooltip = "Number of bars after a breach used to detect an immediate favorable continuation reaction.")
float reactProgressPct = input.float(33.0, "Reaction Progress %", minval = 5.0, maxval = 80.0, step = 1.0, group = gProof,
     tooltip = "Minimum favorable continuation progress toward the 1R target, within the reaction window, required to count as an early React.")

// -------------------------------------------------
// AGPro Color Palette
// -------------------------------------------------
color headerBg = color.rgb(37, 99, 235)
color headerText = color.rgb(245, 247, 250)
color panelBgDark = color.rgb(15, 23, 42)
color panelBgLight = color.rgb(248, 250, 252)
color panelBorderD = color.rgb(51, 65, 85)
color panelBorderL = color.rgb(203, 213, 225)
color panelLabelD = color.rgb(148, 163, 184)
color panelLabelL = color.rgb(71, 85, 105)
color panelValueD = color.rgb(226, 232, 240)
color panelValueL = color.rgb(15, 23, 42)
color bullColor = color.rgb(34, 197, 166)
color bearColor = color.rgb(244, 114, 182)
color neutralColor = color.rgb(245, 189, 92)
color accentColor = color.rgb(129, 140, 248)
color darkText = color.rgb(17, 24, 39)

bool isLightPanel = panelTheme == "Light"
color panelBg = isLightPanel ? panelBgLight : panelBgDark
color panelBorder = isLightPanel ? panelBorderL : panelBorderD
color panelLabelCol = isLightPanel ? panelLabelL : panelLabelD
color panelValueCol = isLightPanel ? panelValueL : panelValueD
color panelRowAlt = isLightPanel ? color.rgb(241, 245, 249) : color.rgb(24, 35, 55)

// -------------------------------------------------
// Helpers
// -------------------------------------------------
f_size(string s) =>
    switch s
        "Tiny" => size.tiny
        "Small" => size.small
        "Large" => size.large
        => size.normal

f_pos(string s) =>
    switch s
        "Top Left" => position.top_left
        "Top Center" => position.top_center
        "Top Right" => position.top_right
        "Middle Left" => position.middle_left
        "Middle Center" => position.middle_center
        "Middle Right" => position.middle_right
        "Bottom Left" => position.bottom_left
        "Bottom Center" => position.bottom_center
        => position.bottom_right

f_clamp(float x, float lo, float hi) =>
    math.max(lo, math.min(hi, x))

f_text_on(color bgColor) =>
    float r = color.r(bgColor)
    float g = color.g(bgColor)
    float b = color.b(bgColor)
    float yiq = (r * 299.0 + g * 587.0 + b * 114.0) / 1000.0
    yiq >= 150.0 ? darkText : headerText

f_pct(float value) =>
    str.tostring(int(math.round(value))) + "%"

f_rate_color(float value) =>
    value >= 55.0 ? bullColor : value >= 40.0 ? neutralColor : bearColor

f_flip_color(float value) =>
    value <= 30.0 ? bullColor : value <= 55.0 ? neutralColor : bearColor

f_regime_color(string r) =>
    r == "Compressed" ? neutralColor : r == "Expanded" ? accentColor : panelValueCol

f_state_color(string s) =>
    str.contains(s, "Upper") ? bullColor : str.contains(s, "Lower") ? bearColor : s == "Inside" ? accentColor : panelValueCol

f_width_model_text(string s) =>
    s == "Return Percentile" ? "Percentile" : s == "Volatility Regime" ? "ATR Regime" : "Hybrid"

f_panel_row(table panelRef, int row, string leftText, string rightText, color valueColor, string sizeInput) =>
    color rowBg = row % 2 == 0 ? panelRowAlt : panelBg
    table.cell(panelRef, 0, row, leftText, text_color = panelLabelCol, bgcolor = rowBg, text_size = f_size(sizeInput), text_halign = text.align_left)
    table.cell(panelRef, 1, row, rightText, text_color = valueColor, bgcolor = rowBg, text_size = f_size(sizeInput), text_halign = text.align_right)

panelSize = f_size(panelFont)
labelSize = f_size(labelFont)
int maxVisibleLabels = labelDensity == "Detailed" ? 26 : labelDensity == "Balanced" ? 14 : 8

var array<label> eventLabels = array.new<label>()

f_keep_label(label id) =>
    array.push(eventLabels, id)
    while array.size(eventLabels) > maxVisibleLabels
        label old = array.shift(eventLabels)
        if not na(old)
            label.delete(old)

// -------------------------------------------------
// Adaptive Channel Engine
// -------------------------------------------------
float midRaw = ta.percentile_linear_interpolation(close, adaptiveLen, 50.0)

float ret = ta.change(close)
float retUp = ta.percentile_linear_interpolation(ret, adaptiveLen, 85.0)
float retDn = ta.percentile_linear_interpolation(ret, adaptiveLen, 15.0)
float dispUp = math.max(nz(retUp, 0.0), 0.0)
float dispDn = math.max(-nz(retDn, 0.0), 0.0)
float percHalfWidth = (dispUp + dispDn) * 0.5 * math.sqrt(adaptiveLen)

float atrNow = math.max(nz(ta.atr(14), high - low), syminfo.mintick)
float atrBase = ta.sma(atrNow, adaptiveLen)
float volRatio = atrBase > 0.0 ? atrNow / atrBase : 1.0
volRatio := f_clamp(volRatio, 0.6, 1.8)
float volHalfWidth = atrNow * 1.5 * volRatio

float halfWidthRaw = switch widthModel
    "Return Percentile" => percHalfWidth
    "Volatility Regime" => volHalfWidth
    => (percHalfWidth + volHalfWidth) * 0.5

float halfWidthScaled = math.max(syminfo.mintick * 10.0, halfWidthRaw * widthScale)

float midSmooth = ta.ema(ta.ema(midRaw, smoothBars), smoothBars)
float hwSmooth = ta.ema(ta.ema(halfWidthScaled, smoothBars), smoothBars)

float upperB = midSmooth + hwSmooth
float lowerB = midSmooth - hwSmooth
float widthB = math.max(upperB - lowerB, syminfo.mintick)

// -------------------------------------------------
// Width Regime
// -------------------------------------------------
float widthCompressLvl = ta.percentile_linear_interpolation(widthB, regimeLen, compressPct)
float widthExpandLvl = ta.percentile_linear_interpolation(widthB, regimeLen, expandPct)
float rankDenom = math.max(widthExpandLvl - widthCompressLvl, syminfo.mintick)
float widthRank = not na(widthCompressLvl) and not na(widthExpandLvl) ? f_clamp((widthB - widthCompressLvl) / rankDenom * 100.0, 0.0, 100.0) : 50.0

var string widthRegime = "Normal"
string prevRegime = widthRegime[1]
bool readyRegime = not na(widthCompressLvl) and not na(widthExpandLvl)
float hystBuf = readyRegime ? math.max((widthExpandLvl - widthCompressLvl) * 0.10, syminfo.mintick) : syminfo.mintick

if readyRegime
    if prevRegime == "Compressed"
        widthRegime := widthB > widthCompressLvl + hystBuf ? (widthB >= widthExpandLvl ? "Expanded" : "Normal") : "Compressed"
    else if prevRegime == "Expanded"
        widthRegime := widthB < widthExpandLvl - hystBuf ? (widthB <= widthCompressLvl ? "Compressed" : "Normal") : "Expanded"
    else
        widthRegime := widthB <= widthCompressLvl ? "Compressed" : widthB >= widthExpandLvl ? "Expanded" : "Normal"
else
    widthRegime := "Normal"

bool newCompression = barstate.isconfirmed and widthRegime == "Compressed" and prevRegime != "Compressed"
bool newExpansion = barstate.isconfirmed and widthRegime == "Expanded" and prevRegime != "Expanded"

// -------------------------------------------------
// Channel State
// -------------------------------------------------
bool closeAbove = close > upperB
bool closeBelow = close < lowerB
bool wickAbove = high > upperB
bool wickBelow = low < lowerB

bool breachUpper = strictBreach ? closeAbove : wickAbove
bool breachLower = strictBreach ? closeBelow : wickBelow

bool respectUpper = not breachUpper and high[1] > upperB[1] and close[1] < upperB[1] and close < upperB and close > midSmooth
bool respectLower = not breachLower and low[1] < lowerB[1] and close[1] > lowerB[1] and close > lowerB and close < midSmooth

var int lastBreachBar = na
bool breachGapOk = na(lastBreachBar) or bar_index - lastBreachBar >= 3
bool newBreachUpper = barstate.isconfirmed and breachUpper and not breachUpper[1] and breachGapOk
bool newBreachLower = barstate.isconfirmed and breachLower and not breachLower[1] and breachGapOk
if newBreachUpper or newBreachLower
    lastBreachBar := bar_index

bool respectUpperEvent = barstate.isconfirmed and respectUpper and not respectUpper[1]
bool respectLowerEvent = barstate.isconfirmed and respectLower and not respectLower[1]

string channelState =
     breachUpper ? "Upper Breach" :
     breachLower ? "Lower Breach" :
     respectUpper ? "Upper Respect" :
     respectLower ? "Lower Respect" :
     "Inside"

string stateTextShort =
     breachUpper or breachLower ? "BREAK" :
     respectUpper or respectLower ? "RESPECT" :
     "INSIDE"

// -------------------------------------------------
// Confirmation-anchored proof (breach acceptance: Follow = continued 1R before reverting to midline)
// -------------------------------------------------
int breachDir = newBreachUpper ? 1 : newBreachLower ? -1 : 0
bool breachEvent = newBreachUpper or newBreachLower

var int proofTotal = 0
var int proofFollow = 0
var int proofHold = 0
var int proofReact = 0
var int proofFlip = 0
var bool pEvalActive = false
var int pEvalDir = 0
var int pEvalStart = na
var float pEvalEntry = na
var float pEvalStop = na
var float pEvalTarget = na
var bool pReacted = false
var bool pFollowed = false
var bool pFlipped = false

int proofWarmup = math.max(adaptiveLen, regimeLen) + 5
if barstate.isconfirmed and bar_index > proofWarmup
    if pEvalActive
        int heldBars = bar_index - pEvalStart
        float followDist = math.max(math.abs(pEvalTarget - pEvalEntry), syminfo.mintick)
        float favExc = pEvalDir * (close - pEvalEntry)
        if heldBars >= 1 and heldBars <= reactBars and favExc >= followDist * reactProgressPct / 100.0
            pReacted := true
        bool stopBreached = pEvalDir == 1 ? close < pEvalStop : close > pEvalStop
        bool hitTarget = heldBars >= 1 and favExc >= followDist
        if stopBreached
            pFlipped := true
        bool followNow = hitTarget and not pFlipped
        if followNow
            pFollowed := true
        bool naturalResolve = pFlipped or followNow or heldBars >= proofHorizonBars
        if naturalResolve or breachEvent
            proofTotal := proofTotal + 1
            if pFollowed
                proofFollow := proofFollow + 1
            if not pFlipped
                proofHold := proofHold + 1
            if pReacted
                proofReact := proofReact + 1
            if pFlipped
                proofFlip := proofFlip + 1
            pEvalActive := false
    if breachEvent and not pEvalActive and breachDir != 0
        pEvalActive := true
        pEvalDir := breachDir
        pEvalEntry := close
        pEvalStop := midSmooth
        float pRevertDist = math.max(math.abs(close - midSmooth), syminfo.mintick)
        pEvalTarget := close + breachDir * pRevertDist
        pEvalStart := bar_index
        pReacted := false
        pFollowed := false
        pFlipped := false

float followRate = proofTotal > 0 ? proofFollow * 100.0 / proofTotal : 0.0
float holdRate = proofTotal > 0 ? proofHold * 100.0 / proofTotal : 0.0
float reactRate = proofTotal > 0 ? proofReact * 100.0 / proofTotal : 0.0
float flipRate = proofTotal > 0 ? proofFlip * 100.0 / proofTotal : 0.0

// -------------------------------------------------
// Plots
// -------------------------------------------------
color upperCol = color.new(bullColor, widthRegime == "Expanded" ? 8 : 18)
color lowerCol = color.new(bearColor, widthRegime == "Expanded" ? 8 : 18)
color midCol = color.new(panelLabelCol, 45)
color fillCol = widthRegime == "Compressed" ? color.new(neutralColor, 92) : widthRegime == "Expanded" ? color.new(accentColor, 92) : color.new(panelValueCol, 96)

upperPlot = plot(upperB, "Upper Channel", color = upperCol, linewidth = 2)
lowerPlot = plot(lowerB, "Lower Channel", color = lowerCol, linewidth = 2)
plot(showMid ? midSmooth : na, "Acceptance Midline", color = midCol, linewidth = 1)
fill(upperPlot, lowerPlot, color = showFill ? fillCol : na, title = "Acceptance Channel Fill")

plotshape(showBreachMarks and newBreachUpper ? upperB : na, title = "Upper Breach Marker", style = shape.circle, location = location.absolute, color = bullColor, size = size.tiny)
plotshape(showBreachMarks and newBreachLower ? lowerB : na, title = "Lower Breach Marker", style = shape.circle, location = location.absolute, color = bearColor, size = size.tiny)

barcolor(showBarTint and breachUpper ? color.new(bullColor, 70) : showBarTint and breachLower ? color.new(bearColor, 70) : na)

plot(followRate, title = "DAC Follow Rate", display = display.none)
plot(holdRate, title = "DAC Hold Rate", display = display.none)
plot(reactRate, title = "DAC React Rate", display = display.none)
plot(flipRate, title = "DAC Flip Rate", display = display.none)

// -------------------------------------------------
// Active Zone With Centered Label
// -------------------------------------------------
var box activeBox = na
var label activeCenterLabel = na
var label upperTag = na
var label lowerTag = na

if barstate.islast
    int leftEdge = math.max(0, bar_index - activeZoneBars)
    int rightEdge = bar_index + zoneProjectionBars
    int centerX = int(math.round((leftEdge + rightEdge) * 0.5))
    color zoneBorder = widthRegime == "Compressed" ? color.new(neutralColor, 48) : widthRegime == "Expanded" ? color.new(accentColor, 48) : color.new(panelBorder, 62)
    color zoneBg = widthRegime == "Compressed" ? color.new(neutralColor, zoneTransparency) : widthRegime == "Expanded" ? color.new(accentColor, zoneTransparency) : color.new(panelValueCol, 96)

    if showActiveZone
        if na(activeBox)
            activeBox := box.new(leftEdge, upperB, rightEdge, lowerB, xloc = xloc.bar_index, bgcolor = zoneBg, border_color = zoneBorder, border_width = 1)
        else
            box.set_lefttop(activeBox, leftEdge, upperB)
            box.set_rightbottom(activeBox, rightEdge, lowerB)
            box.set_bgcolor(activeBox, zoneBg)
            box.set_border_color(activeBox, zoneBorder)

        string centerText = "ACCEPTANCE\n" + stateTextShort + " / " + widthRegime
        color centerBase = widthRegime == "Compressed" ? neutralColor : widthRegime == "Expanded" ? accentColor : headerBg
        color centerBg = color.new(centerBase, 6)
        if na(activeCenterLabel)
            activeCenterLabel := label.new(centerX, midSmooth, centerText, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_center, color = centerBg, textcolor = f_text_on(centerBase), size = labelSize, textalign = text.align_center)
        else
            label.set_xy(activeCenterLabel, centerX, midSmooth)
            label.set_text(activeCenterLabel, centerText)
            label.set_color(activeCenterLabel, centerBg)
            label.set_textcolor(activeCenterLabel, f_text_on(centerBase))
            label.set_size(activeCenterLabel, labelSize)
    else
        if not na(activeBox)
            box.delete(activeBox)
            activeBox := na
        if not na(activeCenterLabel)
            label.delete(activeCenterLabel)
            activeCenterLabel := na

    if showEdgeTags
        if na(upperTag)
            upperTag := label.new(rightEdge, upperB, "Upper", xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = color.new(bullColor, 8), textcolor = headerText, size = labelSize)
        else
            label.set_xy(upperTag, rightEdge, upperB)
            label.set_text(upperTag, "Upper")
            label.set_color(upperTag, color.new(bullColor, 8))
            label.set_textcolor(upperTag, headerText)
            label.set_size(upperTag, labelSize)

        if na(lowerTag)
            lowerTag := label.new(rightEdge, lowerB, "Lower", xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = color.new(bearColor, 8), textcolor = headerText, size = labelSize)
        else
            label.set_xy(lowerTag, rightEdge, lowerB)
            label.set_text(lowerTag, "Lower")
            label.set_color(lowerTag, color.new(bearColor, 8))
            label.set_textcolor(lowerTag, headerText)
            label.set_size(lowerTag, labelSize)
    else
        if not na(upperTag)
            label.delete(upperTag)
            upperTag := na
        if not na(lowerTag)
            label.delete(lowerTag)
            lowerTag := na

// -------------------------------------------------
// Event Labels
// -------------------------------------------------
var int lastReactionLabelBar = na
bool reactionLabelOk = showReactionLabels and (na(lastReactionLabelBar) or bar_index - lastReactionLabelBar >= reactionLabelSpacing)
float eventOffset = math.max(syminfo.mintick * 20.0, atrNow * labelOffsetAtr)

if reactionLabelOk and newBreachUpper
    label lbl = label.new(bar_index, high + eventOffset, "Upper Breach", xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_down, color = color.new(bullColor, 8), textcolor = headerText, size = labelSize)
    f_keep_label(lbl)
    lastReactionLabelBar := bar_index

if reactionLabelOk and newBreachLower
    label lbl = label.new(bar_index, low - eventOffset, "Lower Breach", xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_up, color = color.new(bearColor, 8), textcolor = headerText, size = labelSize)
    f_keep_label(lbl)
    lastReactionLabelBar := bar_index

if reactionLabelOk and respectUpperEvent
    label lbl = label.new(bar_index, high + eventOffset, "Upper Respect", xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_down, color = color.new(neutralColor, 6), textcolor = f_text_on(neutralColor), size = labelSize)
    f_keep_label(lbl)
    lastReactionLabelBar := bar_index

if reactionLabelOk and respectLowerEvent
    label lbl = label.new(bar_index, low - eventOffset, "Lower Respect", xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_up, color = color.new(neutralColor, 6), textcolor = f_text_on(neutralColor), size = labelSize)
    f_keep_label(lbl)
    lastReactionLabelBar := bar_index

var int lastCompressLabelBar = na
var int lastExpandLabelBar = na
bool compressLabelOk = showRegimeLabels and newCompression and (na(lastCompressLabelBar) or bar_index - lastCompressLabelBar >= regimeLabelSpacing)
bool expandLabelOk = showRegimeLabels and newExpansion and (na(lastExpandLabelBar) or bar_index - lastExpandLabelBar >= regimeLabelSpacing)

if compressLabelOk
    label lbl = label.new(bar_index, lowerB - eventOffset * 0.40, "Compressed", xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_up, color = color.new(neutralColor, 6), textcolor = f_text_on(neutralColor), size = labelSize)
    f_keep_label(lbl)
    lastCompressLabelBar := bar_index

if expandLabelOk
    label lbl = label.new(bar_index, upperB + eventOffset * 0.40, "Expanded", xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_down, color = color.new(accentColor, 6), textcolor = headerText, size = labelSize)
    f_keep_label(lbl)
    lastExpandLabelBar := bar_index

// -------------------------------------------------
// Panel
// -------------------------------------------------
int panelRowCount = showProof ? 12 : 7
var table panel = na
var string lastPanelLoc = ""
var string lastPanelTheme = ""
var string lastPanelFont = ""
var bool lastPanelVisible = false
var bool lastProofMode = false

bool panelNeedsBuild = showPanel and (na(panel) or panelLoc != lastPanelLoc or panelTheme != lastPanelTheme or panelFont != lastPanelFont or not lastPanelVisible or showProof != lastProofMode)
if panelNeedsBuild
    if not na(panel)
        table.delete(panel)
    panel := table.new(f_pos(panelLoc), 2, panelRowCount, bgcolor = panelBg, border_color = panelBorder, border_width = 1, frame_color = panelBorder, frame_width = 1)
    table.cell(panel, 0, 0, "AG Pro Dynamic Acceptance Channel", text_color = headerText, bgcolor = headerBg, text_size = panelSize, text_halign = text.align_center)
    table.cell(panel, 1, 0, "", text_color = headerText, bgcolor = headerBg, text_size = panelSize)
    table.merge_cells(panel, 0, 0, 1, 0)
    lastPanelLoc := panelLoc
    lastPanelTheme := panelTheme
    lastPanelFont := panelFont
    lastPanelVisible := true
    lastProofMode := showProof

if not showPanel and not na(panel)
    table.delete(panel)
    panel := na
    lastPanelVisible := false

if showPanel and not na(panel) and barstate.islast
    table.set_position(panel, f_pos(panelLoc))
    table.clear(panel, 0, 1, 1, panelRowCount - 1)

    float widthPctOfPrice = close > 0.0 ? widthB / close * 100.0 : 0.0
    color stateCol = f_state_color(channelState)
    color regimeCol = f_regime_color(widthRegime)
    string modelText = f_width_model_text(widthModel)

    f_panel_row(panel, 1, "State", channelState, stateCol, panelFont)
    f_panel_row(panel, 2, "Width Regime", widthRegime, regimeCol, panelFont)
    f_panel_row(panel, 3, "Width Rank", str.tostring(widthRank, "#") + " / 100", panelValueCol, panelFont)
    f_panel_row(panel, 4, "Width", str.tostring(widthPctOfPrice, "#.##") + "%", panelValueCol, panelFont)
    f_panel_row(panel, 5, "Model", modelText, panelValueCol, panelFont)
    f_panel_row(panel, 6, "Upper / Lower", str.tostring(upperB, format.mintick) + " / " + str.tostring(lowerB, format.mintick), panelValueCol, panelFont)

    if showProof
        string proofSampleText = proofTotal > 0 ? "n = " + str.tostring(proofTotal) : "building"
        color proofHeadBg = panelBg
        table.cell(panel, 0, 7, "Proof @ Confirm", text_color = accentColor, bgcolor = proofHeadBg, text_size = panelSize, text_halign = text.align_left)
        table.cell(panel, 1, 7, proofSampleText, text_color = panelLabelCol, bgcolor = proofHeadBg, text_size = panelSize, text_halign = text.align_right)
        f_panel_row(panel, 8, "Follow Rate", proofTotal > 0 ? f_pct(followRate) : "-", proofTotal > 0 ? f_rate_color(followRate) : panelValueCol, panelFont)
        f_panel_row(panel, 9, "Hold Rate", proofTotal > 0 ? f_pct(holdRate) : "-", proofTotal > 0 ? f_rate_color(holdRate) : panelValueCol, panelFont)
        f_panel_row(panel, 10, "React Rate", proofTotal > 0 ? f_pct(reactRate) : "-", proofTotal > 0 ? f_rate_color(reactRate) : panelValueCol, panelFont)
        f_panel_row(panel, 11, "Flip Rate", proofTotal > 0 ? f_pct(flipRate) : "-", proofTotal > 0 ? f_flip_color(flipRate) : panelValueCol, panelFont)

// -------------------------------------------------
// Alerts
// -------------------------------------------------
alertcondition(alertBreach and newBreachUpper, "Upper Channel Breached", "Dynamic Acceptance Channel: upper channel breach confirmed. This is an attention marker, not a trade instruction.")
alertcondition(alertBreach and newBreachLower, "Lower Channel Breached", "Dynamic Acceptance Channel: lower channel breach confirmed. This is an attention marker, not a trade instruction.")
alertcondition(alertCompress and newCompression, "Channel Compressed", "Dynamic Acceptance Channel: width regime shifted to Compressed. This is an attention marker, not a trade instruction.")
alertcondition(alertExpand and newExpansion, "Channel Expanded", "Dynamic Acceptance Channel: width regime shifted to Expanded. This is an attention marker, not a trade instruction.")
alertcondition(alertRespect and respectUpperEvent, "Upper Channel Respected", "Dynamic Acceptance Channel: upper channel respect event confirmed. This is an attention marker, not a trade instruction.")
alertcondition(alertRespect and respectLowerEvent, "Lower Channel Respected", "Dynamic Acceptance Channel: lower channel respect event confirmed. This is an attention marker, not a trade instruction.")
````
