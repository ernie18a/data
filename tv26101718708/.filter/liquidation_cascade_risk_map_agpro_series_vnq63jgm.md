# Liquidation Cascade Risk Map [AGPro Series]

- url: https://www.tradingview.com/script/vNQ63jGM-Liquidation-Cascade-Risk-Map-AGPro-Series/
- type: indicator
- pine_id: PUB;5289e493af684596b016afdf12047a02
- version: 4.0

## Description

Liquidation Cascade Risk Map [AGPro Series]

🧠 Core Idea

When leverage pressure builds, is the market entering a real cascade-risk zone, or is liquidation pressure already cooling?


📌 Overview / What it does

Liquidation Cascade Risk Map [AGPro Series] is a crypto derivatives analysis tool designed to visualize liquidation-cascade risk without pretending to know exact exchange liquidation levels.

The script evaluates open interest data when available, falls back to a transparent volume-proxy mode when needed, and combines volatility expansion, range pressure, candle body stress, directional movement, and distance from reference structure into a single cascade-risk context.

It produces a cascade pressure path, right-side state tags, event labels, optional pulse markers, and a compact AG Pro dashboard panel. It does not predict future price, automate entries, provide liquidation prices, or act as a guaranteed signal system.


🎯 Purpose & Design Philosophy

This script was built for traders who want to understand when a crypto market may be carrying unstable leverage pressure.

Many liquidation tools focus on exact levels, heatmaps, or speculative liquidation clusters. Those can be useful, but they often require external datasets and may create false certainty when used as chart overlays.

Liquidation Cascade Risk Map takes a different approach. It asks whether current market behavior has the ingredients of cascade vulnerability: expanding pressure, directional stress, range instability, aggressive bodies, and persistence.


⚡ Why This Script Is Different

Most tools focus on liquidation levels, estimated heatmap bands, or simple volatility alerts.

This script does NOT claim to know where every liquidation sits, and it does not draw exchange-style liquidation heatmaps.

Instead, it maps the quality of the surrounding cascade-risk environment. It highlights when the market is showing pressure that may support long-side cascade risk, short-side cascade risk, two-way cascade vulnerability, or cooling after a pressure build-up.


⚙️ Methodology

1. Context Detection

The script checks whether usable open interest data exists. If not, it can fall back to a volume-proxy model so the visual framework remains usable across more symbols.

2. Pressure Mapping

It evaluates data change, volatility shock, candle range pressure, body expansion, distance from reference structure, and directional movement.

3. Cascade Evaluation

Those components are blended into a cascade-risk score. The script then classifies the environment as Long Cascade Risk, Short Cascade Risk, Two-Way Cascade, Risk Cooling, Neutral Risk, or Data Missing.

4. Visual Output

The chart displays a cascade pressure path, a dotted center reference, a vertical pressure needle, right-side tags, event labels, and a panel that summarizes the active state.


🗺️ How to Read the Chart

The upper pressure rail represents elevated liquidation-cascade risk.

The lower pressure rail represents cooling or pressure release context.

The dotted centerline acts as the current reference path.

The vertical needle shows how stretched the active cascade-risk score is inside the pressure path.

Event labels identify important changes such as Long Cascade, Short Cascade, Two-Way Cascade, or Risk Cooling.

The panel summarizes state, score, data change, velocity, persistence, cooling, direction, grade, data mode, ATR shock, data source, and trend.


🚦 Signals & States

• Long Cascade Risk → downside pressure is elevated and long-side liquidation vulnerability may be rising

• Short Cascade Risk → upside pressure is elevated and short-side liquidation vulnerability may be rising

• Two-Way Cascade → volatility and pressure are elevated on both sides, suggesting unstable conditions

• Risk Cooling → cascade pressure is decreasing after a build-up

• Neutral Risk → no strong cascade-risk condition is currently active

• Data Missing → the selected data source is not usable on the current symbol or mode


🔔 Alerts Logic

Alerts can be enabled for Long Cascade Risk, Short Cascade Risk, Two-Way Cascade, and Risk Cooling.

Each alert triggers when the selected state becomes active. Alerts are designed as attention markers, not trade instructions.


🧩 Confluence Logic

The context becomes stronger when data expansion, volatility shock, range pressure, directional bias, and persistence align at the same time.

For example, high volatility with strong directional movement and rising pressure persistence may indicate a more unstable cascade-risk environment than volatility alone.


📊 When to Use

• Crypto perpetual futures

• High-volatility market phases

• Sharp directional moves

• Post-breakout acceleration

• Failed recovery or forced unwind environments

• Situations where leverage pressure may matter more than ordinary trend context


⚠️ When NOT to Use

• Very low liquidity symbols

• Symbols with unreliable volume or open interest data

• Extremely noisy low-timeframe charts

• Markets with abnormal gaps or data breaks

• Any situation where the user expects exact exchange liquidation prices


🎛️ Key Inputs

• Data Mode → chooses between automatic open interest, manual open interest symbol, or volume proxy

• Lookback Length → controls the normalization window for pressure scoring

• Fast / Slow Pressure Length → controls short-term and baseline pressure reaction

• Cascade Threshold → defines how demanding the script is before marking cascade-risk conditions

• Cooling Threshold → controls when pressure is considered to be cooling

• Persistence Bars → measures whether pressure is sustained or only momentary

• Visual settings → control labels, pulse markers, path visibility, panel layout, and font sizes


🖥️ Interface & Visual Design

The interface is built to make the chart readable at first glance.

The cascade path is intentionally not a large boxed zone. It is a pressure-path structure designed to remain visually distinct from corridor, ladder, and basis-style scripts.

The panel uses a merged AG Pro header row, compact metrics, and a dark professional layout. Visual elements avoid white or pale primary treatments so the script remains readable on both dark and light TradingView chart backgrounds.


🧪 Practical Usage Workflow

1. Read the panel state first.

2. Check whether Data Mode shows real open interest or volume proxy.

3. Look at the cascade pressure path and current needle position.

4. Check event labels for recent pressure build-up or cooling.

5. Compare the state with broader trend, volatility, and market structure.


🔍 Interpretation Guidelines

Do not treat a cascade-risk state as a direct entry or exit signal.

Use it as a context layer. The script is most useful when combined with structure, liquidity, volatility, market regime, and risk management.

Rising cascade risk can mean the market is becoming unstable. Cooling can mean pressure is easing, but it does not guarantee reversal or continuation.


🚫 What This Script Is NOT

This script is not a prediction engine.

It is not financial advice.

It is not an automated trading system.

It does not calculate exact liquidation prices.

It does not guarantee that a liquidation cascade will happen.


⚠️ Limitations & Transparency

Open interest availability depends on symbol, exchange, and TradingView data support.

Volume proxy mode is only a proxy. It can help visualize pressure context, but it is not the same as real open interest.

Different timeframes may produce different readings.

Fast markets, illiquid symbols, gaps, and abnormal candles can affect outputs.


🧠 Market Context Notes

Liquidation pressure is often connected to leverage, volatility, liquidity, and forced positioning.

This script focuses on context quality rather than exact liquidation geography. That makes it useful as a decision-support layer, but it should always be interpreted with broader market evidence.


🧾 Use Case Examples

When price accelerates downward while pressure score and persistence rise, the chart may show Long Cascade Risk.

When price squeezes upward with high pressure and volatility expansion, the chart may show Short Cascade Risk.

When volatility and pressure expand without clean directional separation, the chart may show Two-Way Cascade.

When pressure falls after a build-up, the chart may show Risk Cooling.


🧱 System Philosophy

AGProLabs scripts are built as structured decision-support tools.

The goal is not to make the chart louder. The goal is to make hidden market context easier to read, compare, and question.


🔐 Non-Promise Statement

No script can remove uncertainty.

No state should be treated as certainty.

No visual element should replace trader judgment.


📉 Risk Disclosure

Trading involves risk.

Crypto derivatives and leveraged markets can be especially volatile.

This script is for educational and analytical purposes only.

Nothing in this script should be interpreted as financial advice, investment advice, or a guarantee of outcome.

Users remain fully responsible for their own decisions.


📚 Educational Note

Use this script to study how pressure, volatility, persistence, and directional stress interact before and after unstable crypto market moves.

## Source Code

````pine
// --------------------------------------------------
// Liquidation Cascade Risk Map [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 1.3
//
// Liquidation Cascade Risk Map is a crypto derivatives context indicator built
// to estimate when volatility shock, participation pressure, directional
// displacement, wick failure, and distance-from-baseline conditions may create
// a higher liquidation-cascade risk environment. It does not display exchange
// liquidation levels. It maps risk pressure, cooling, and directional cascade
// context with a compact cascade board, a self-measured Cascade Hit Rate,
// scored event labels, right-side tags, and an AG Pro dashboard.
// Version 1.3 moves the live ladder into forward chart space, separates its
// gauge from candles, and removes redundant default pressure-track clutter.
// --------------------------------------------------

//@version=6
indicator("Liquidation Cascade Risk Map [AGPro Series]",
     shorttitle = "AG Pro LCR",
     overlay = true,
     max_lines_count = 90,
     max_labels_count = 120,
     max_boxes_count = 20)

// --------------------------------------------------
// AGPro Color Palette
// --------------------------------------------------
color headerBg      = color.rgb(37, 99, 235)
color headerText    = color.rgb(245, 247, 250)
color panelBg       = color.rgb(15, 23, 42)
color panelBorder   = color.rgb(51, 65, 85)
color panelLabelCol = color.rgb(148, 163, 184)
color panelValueCol = color.rgb(226, 232, 240)
color bullColor     = color.rgb(34, 197, 166)
color bearColor     = color.rgb(244, 114, 182)
color neutralColor  = color.rgb(245, 189, 92)
color accentColor   = color.rgb(129, 140, 248)
color coolColor     = color.rgb(56, 189, 248)
color riskColor     = color.rgb(251, 113, 133)
color boardBlue     = color.rgb(59, 130, 246)
color slateBadge    = color.rgb(51, 65, 85)
color darkText      = color.rgb(17, 24, 39)

// --------------------------------------------------
// Inputs
// --------------------------------------------------
string G_DATA = "Cascade Data"
string G_ENGINE = "Cascade Risk Engine"
string G_VISUAL = "Visual Design"
string G_PANEL = "Panel"
string G_ALERTS = "Alerts"

dataModeInput = input.string("Auto OI Then Volume Proxy", "Data Mode", options = ["Auto OI Then Volume Proxy", "Manual OI Symbol", "Volume Proxy Only"], group = G_DATA,
     tooltip = "Selects whether the script tries to read an open interest source first or uses volume as a transparent participation-pressure proxy.")
manualOiSymbol = input.symbol("BINANCE:ETHUSDTPERP_OI", "Manual Open Interest Symbol", group = G_DATA,
     tooltip = "Manual open interest source. If unavailable, use Auto OI Then Volume Proxy or Volume Proxy Only.")
allowVolumeProxy = input.bool(true, "Allow Volume Proxy Fallback", group = G_DATA,
     tooltip = "Allows volume to act as a transparent fallback when official open interest is unavailable.")

lookback = input.int(144, "Risk Context Lookback", minval = 50, maxval = 600, group = G_ENGINE,
     tooltip = "Controls normalization for volatility, displacement, and participation pressure.")
fastLen = input.int(10, "Fast Pressure Track", minval = 3, maxval = 60, group = G_ENGINE,
     tooltip = "Controls the short-term reaction track used for cascade direction.")
slowLen = input.int(34, "Slow Pressure Baseline", minval = 8, maxval = 160, group = G_ENGINE,
     tooltip = "Controls the slower baseline used to measure distance and instability.")
atrLen = input.int(14, "ATR Length", minval = 5, maxval = 80, group = G_ENGINE,
     tooltip = "Measures volatility shock and price expansion.")
cascadeThreshold = input.int(62, "Cascade Risk Threshold", minval = 1, maxval = 100, group = G_ENGINE,
     tooltip = "Minimum cascade risk score required for directional cascade states.")
coolingThreshold = input.int(48, "Cooling Threshold", minval = 1, maxval = 100, group = G_ENGINE,
     tooltip = "Minimum cooling score required for a risk-cooling state.")
persistenceBars = input.int(9, "Persistence Bars", minval = 3, maxval = 50, group = G_ENGINE,
     tooltip = "Counts whether cascade pressure is persisting or fading.")
proofWindowBars = input.int(8, "Risk Proof Window", minval = 3, maxval = 60, group = G_ENGINE,
     tooltip = "After the script flags an elevated cascade-risk state, it waits this many bars and checks whether a significant move actually followed. Feeds the Cascade Hit Rate readout in the panel.")
proofMoveMult = input.float(1.4, "Proof Move (x ATR)", minval = 0.5, maxval = 5.0, step = 0.1, group = G_ENGINE,
     tooltip = "How large the post-flag price excursion must be, measured in ATR, to count the risk flag as realized.")

showCascadeBoard = input.bool(true, "Show Cascade Board", group = G_VISUAL,
     tooltip = "Shows a compact risk board around current price with upper risk, center pressure, and lower cooling rails.")
showEventLabels = input.bool(true, "Show Event Labels", group = G_VISUAL,
     tooltip = "Shows compact, score-tagged event labels for major cascade-risk changes. Cooling labels are intentionally selective to avoid visual repetition.")
showPulseMarkers = input.bool(false, "Show Compact Pulse Markers", group = G_VISUAL,
     tooltip = "Optional small markers for cascade pressure. Default is off for a cleaner publication screenshot.")
showRightTags = input.bool(true, "Show Right-Side Tags", group = G_VISUAL,
     tooltip = "Shows state, risk score, and cooling score tags near the cascade board.")
showTracks = input.bool(false, "Show Pressure Tracks", group = G_VISUAL,
     tooltip = "Optionally shows fast and slow pressure tracks. Default is off so the forward cascade ladder and scored event badges remain visually dominant.")
showBarColors = input.bool(false, "Color Bars by State", group = G_VISUAL,
     tooltip = "Optionally colors candles by the current cascade state.")
adaptiveProjection = input.bool(true, "Adaptive HTF Projection", group = G_VISUAL,
     tooltip = "Shortens the forward board projection on higher timeframes so the risk map does not dominate the chart.")
projectionBars = input.int(34, "Path Projection Bars", minval = 12, maxval = 120, group = G_VISUAL,
     tooltip = "Controls how far the cascade board extends to the right.")
historyBars = input.int(0, "Board History Bars", minval = 0, maxval = 220, group = G_VISUAL,
     tooltip = "Controls how far the cascade ladder reaches into historical bars. Zero keeps the live ladder entirely in forward chart space and avoids covering candles.")
boardAnchor = input.float(0.58, "Board Badge Anchor", minval = 0.35, maxval = 0.78, step = 0.01, group = G_VISUAL,
     tooltip = "Controls where the centered cascade badge sits horizontally inside the board.")
labelCooldownBars = input.int(34, "Event Label Cooldown", minval = 5, maxval = 100, group = G_VISUAL,
     tooltip = "Controls spacing between event labels.")
maxEventLabels = input.int(6, "Maximum Event Labels", minval = 1, maxval = 30, group = G_VISUAL,
     tooltip = "Limits event-label count to preserve a clean chart.")
labelOffsetAtr = input.float(1.00, "Label Offset ATR", minval = 0.10, maxval = 5.0, step = 0.05, group = G_VISUAL,
     tooltip = "Moves event labels away from candles.")
labelSizeInput = input.string("Normal", "Label Font Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = G_VISUAL,
     tooltip = "Controls chart label font size for event labels, the cascade badge, and right-side tags.")

showPanel = input.bool(true, "Show Panel", group = G_PANEL,
     tooltip = "Shows or hides the AG Pro dashboard panel.")
panelPositionInput = input.string("Top Right", "Panel Location", options = ["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], group = G_PANEL,
     tooltip = "Controls dashboard panel location.")
panelThemeInput = input.string("Elite Dark", "Panel Theme", options = ["Elite Dark", "Slate", "Clean Light"], group = G_PANEL,
     tooltip = "Controls dashboard panel theme.")
panelFontSizeInput = input.string("Normal", "Panel Font Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = G_PANEL,
     tooltip = "Controls dashboard panel font size.")

alertLongCascade = input.bool(true, "Alert: Long Cascade Risk", group = G_ALERTS,
     tooltip = "Triggers when downside cascade pressure becomes structurally relevant.")
alertShortCascade = input.bool(true, "Alert: Short Cascade Risk", group = G_ALERTS,
     tooltip = "Triggers when upside cascade pressure becomes structurally relevant.")
alertTwoWay = input.bool(true, "Alert: Two-Way Cascade Risk", group = G_ALERTS,
     tooltip = "Triggers when volatility and participation pressure are high but direction is mixed.")
alertCooling = input.bool(true, "Alert: Risk Cooling", group = G_ALERTS,
     tooltip = "Triggers when cascade pressure cools after an elevated-risk state.")

// --------------------------------------------------
// Helpers
// --------------------------------------------------
f_clamp(float value, float minValue, float maxValue) =>
    math.max(minValue, math.min(maxValue, value))

f_size(string sizeName) =>
    sizeName == "Tiny" ? size.tiny :
     sizeName == "Small" ? size.small :
     sizeName == "Large" ? size.large :
     sizeName == "Huge" ? size.huge : size.normal

f_pos(string posName) =>
    posName == "Top Left" ? position.top_left :
     posName == "Top Center" ? position.top_center :
     posName == "Top Right" ? position.top_right :
     posName == "Middle Left" ? position.middle_left :
     posName == "Middle Center" ? position.middle_center :
     posName == "Middle Right" ? position.middle_right :
     posName == "Bottom Left" ? position.bottom_left :
     posName == "Bottom Center" ? position.bottom_center : position.bottom_right

f_pct(float value) =>
    na(value) ? "n/a" : str.tostring(value, "#.##") + "%"

f_score(float value) =>
    na(value) ? "n/a" : str.tostring(math.round(value))

f_grade(float value) =>
    na(value) ? "" : value >= 82 ? "A" : value >= 62 ? "B" : value >= 45 ? "C" : "D"

f_text_on(color bgColor) =>
    float bright = (color.r(bgColor) * 299.0 + color.g(bgColor) * 587.0 + color.b(bgColor) * 114.0) / 1000.0
    bright >= 145.0 ? darkText : headerText

f_bg(string themeName) =>
    themeName == "Clean Light" ? color.rgb(241, 245, 249) :
     themeName == "Slate" ? color.rgb(30, 41, 59) : panelBg

f_border(string themeName) =>
    themeName == "Clean Light" ? color.rgb(148, 163, 184) :
     themeName == "Slate" ? color.rgb(71, 85, 105) : panelBorder

f_label_col(string themeName) =>
    themeName == "Clean Light" ? color.rgb(71, 85, 105) : panelLabelCol

f_value_col(string themeName) =>
    themeName == "Clean Light" ? color.rgb(15, 23, 42) : panelValueCol

f_row_bg(string themeName, int row) =>
    bool evenRow = row % 2 == 0
    themeName == "Clean Light" ? (evenRow ? color.rgb(226, 232, 240) : color.rgb(241, 245, 249)) :
     themeName == "Slate" ? (evenRow ? color.rgb(37, 49, 70) : color.rgb(30, 41, 59)) :
     (evenRow ? color.rgb(20, 31, 52) : panelBg)

f_state_color(string stateName) =>
    stateName == "Long Cascade Risk" ? bearColor :
     stateName == "Short Cascade Risk" ? bullColor :
     stateName == "Two-Way Cascade" ? riskColor :
     stateName == "Risk Cooling" ? coolColor :
     stateName == "Data Missing" ? neutralColor : accentColor

f_panel_row(table panelRef, int row, string leftText, string rightText, color rightCol, string themeName, string sizeInput) =>
    color rowBg = f_row_bg(themeName, row)
    table.cell(panelRef, 0, row, leftText, text_color = f_label_col(themeName), bgcolor = rowBg, text_size = f_size(sizeInput), text_halign = text.align_left)
    table.cell(panelRef, 1, row, rightText, text_color = rightCol, bgcolor = rowBg, text_size = f_size(sizeInput), text_halign = text.align_right)

f_set_label(label labelRef, int x, float y, string txt, color bgCol, bool centerStyle, string sizeInput) =>
    label.set_xy(labelRef, x, y)
    label.set_text(labelRef, txt)
    label.set_color(labelRef, bgCol)
    label.set_textcolor(labelRef, f_text_on(bgCol))
    label.set_style(labelRef, centerStyle ? label.style_label_center : label.style_label_left)
    label.set_size(labelRef, f_size(sizeInput))

f_event_label(array<label> labelArray, int x, float y, string txt, color bgCol, bool upward, string sizeInput, int maxCount) =>
    label newLabel = label.new(x, y, txt, xloc = xloc.bar_index, style = upward ? label.style_label_up : label.style_label_down, color = bgCol, textcolor = f_text_on(bgCol), size = f_size(sizeInput))
    array.push(labelArray, newLabel)
    if array.size(labelArray) > maxCount
        label oldLabel = array.shift(labelArray)
        label.delete(oldLabel)

// --------------------------------------------------
// Data Engine
// --------------------------------------------------
autoOiSymbol = syminfo.tickerid + "_OI"
oiSymbol = dataModeInput == "Manual OI Symbol" ? manualOiSymbol : autoOiSymbol
oiRaw = dataModeInput == "Volume Proxy Only" ? na : request.security(oiSymbol, timeframe.period, close, ignore_invalid_symbol = true)
oiAvailable = not na(oiRaw)
pressureSource = oiAvailable ? oiRaw : allowVolumeProxy ? volume : na
dataReady = not na(pressureSource) and pressureSource > 0.0
dataMode = oiAvailable ? "Open Interest" : allowVolumeProxy and dataReady ? "Volume Proxy" : "No Data"

safeAtr = math.max(nz(ta.atr(atrLen), ta.tr(true)), syminfo.mintick)
fast = ta.ema(close, fastLen)
slow = ta.ema(close, slowLen)
atrPct = safeAtr / close * 100.0
atrBase = ta.sma(atrPct, lookback)
atrShock = not na(atrBase) and atrBase > 0.0 ? atrPct / atrBase : 1.0
rangePct = (high - low) / close * 100.0
rangeBase = ta.sma(rangePct, lookback)
rangeShock = not na(rangeBase) and rangeBase > 0.0 ? rangePct / rangeBase : 1.0
body = math.abs(close - open)
bodyBase = ta.sma(body / close * 100.0, lookback)
bodyShock = not na(bodyBase) and bodyBase > 0.0 ? (body / close * 100.0) / bodyBase : 1.0
pressureChange = dataReady and not na(pressureSource[fastLen]) and pressureSource[fastLen] != 0.0 ? (pressureSource - pressureSource[fastLen]) / pressureSource[fastLen] * 100.0 : na
pressureVelocity = dataReady ? ta.ema(pressureChange - nz(pressureChange[1]), 3) : na
distanceFromSlow = (close - slow) / math.max(safeAtr, syminfo.mintick)
downDisplacement = close < open and close < fast and close < slow
upDisplacement = close > open and close > fast and close > slow
upperWick = high - math.max(open, close)
lowerWick = math.min(open, close) - low
wickRange = math.max(high - low, syminfo.mintick)
upperWickPct = upperWick / wickRange * 100.0
lowerWickPct = lowerWick / wickRange * 100.0
failedUpAuction = upperWickPct > 42.0 and close < fast
failedDownAuction = lowerWickPct > 42.0 and close > fast
trendUp = fast > slow and close > slow
trendDown = fast < slow and close < slow

volatilityScore = f_clamp((atrShock - 0.85) / 1.25 * 100.0, 0.0, 100.0)
rangeScore = f_clamp((rangeShock - 0.85) / 1.35 * 100.0, 0.0, 100.0)
bodyScore = f_clamp((bodyShock - 0.80) / 1.45 * 100.0, 0.0, 100.0)
pressureScore = dataReady ? f_clamp(math.abs(pressureChange) / 12.0 * 100.0, 0.0, 100.0) : 0.0
velocityScore = dataReady ? f_clamp(math.abs(pressureVelocity) / 2.4 * 100.0, 0.0, 100.0) : 0.0
distanceScore = f_clamp(math.abs(distanceFromSlow) / 3.2 * 100.0, 0.0, 100.0)
cascadeScore = dataReady ? f_clamp(volatilityScore * 0.24 + rangeScore * 0.18 + bodyScore * 0.16 + pressureScore * 0.20 + velocityScore * 0.12 + distanceScore * 0.10, 0.0, 100.0) : 0.0
coolingScore = dataReady ? f_clamp((1.35 - atrShock) / 0.80 * 100.0 + (math.max(-pressureVelocity, 0.0) / 1.6 * 20.0), 0.0, 100.0) : 0.0

longCascadeRaw = dataReady and cascadeScore >= cascadeThreshold and (downDisplacement or failedUpAuction) and distanceFromSlow < -0.40
shortCascadeRaw = dataReady and cascadeScore >= cascadeThreshold and (upDisplacement or failedDownAuction) and distanceFromSlow > 0.40
twoWayRaw = dataReady and cascadeScore >= cascadeThreshold and not longCascadeRaw and not shortCascadeRaw
coolingRaw = dataReady and coolingScore >= coolingThreshold and cascadeScore < cascadeThreshold

longPersistence = math.sum(longCascadeRaw ? 1.0 : 0.0, persistenceBars) / persistenceBars * 100.0
shortPersistence = math.sum(shortCascadeRaw ? 1.0 : 0.0, persistenceBars) / persistenceBars * 100.0
twoWayPersistence = math.sum(twoWayRaw ? 1.0 : 0.0, persistenceBars) / persistenceBars * 100.0
coolingPersistence = math.sum(coolingRaw ? 1.0 : 0.0, persistenceBars) / persistenceBars * 100.0

longCascade = longCascadeRaw and longPersistence >= 16.0
shortCascade = shortCascadeRaw and shortPersistence >= 16.0
twoWayCascade = twoWayRaw and twoWayPersistence >= 12.0
riskCooling = coolingRaw and coolingPersistence >= 18.0

stateText = not dataReady ? "Data Missing" :
     longCascade ? "Long Cascade Risk" :
     shortCascade ? "Short Cascade Risk" :
     twoWayCascade ? "Two-Way Cascade" :
     riskCooling ? "Risk Cooling" : "Neutral Risk"
stateColor = f_state_color(stateText)
directionText = not dataReady ? "Check Data" :
     longCascade ? "Downside Cascade" :
     shortCascade ? "Upside Cascade" :
     twoWayCascade ? "Two-Way Pressure" :
     riskCooling ? "Pressure Cooling" : "No Active Cascade"
qualityText = not dataReady ? "Missing" :
     cascadeScore >= 82.0 ? "Extreme" :
     cascadeScore >= cascadeThreshold ? "Elevated" :
     riskCooling ? "Cooling" : "Low"

// --------------------------------------------------
// Cascade Hit Rate (Proof Pass)
// --------------------------------------------------
// When the script flags an elevated cascade-risk state (Long / Short / Two-Way),
// it waits proofWindowBars and checks whether a significant move (>= proofMoveMult
// x ATR excursion) actually followed. This builds an honest, self-measured
// realization rate for the risk flags.
float winHigh = ta.highest(high, proofWindowBars)
float winLow = ta.lowest(low, proofWindowBars)
bool elevatedRisk = longCascade or shortCascade or twoWayCascade
bool elevatedArm = dataReady and elevatedRisk and not (bar_index > 0 ? elevatedRisk[1] : false)

var int riskProofHits = 0
var int riskProofTotal = 0
var bool riskProofPending = false
var int riskProofStart = na
var float riskProofEntry = na
var float riskProofArmAtr = na

if barstate.isconfirmed
    if elevatedArm and not riskProofPending
        riskProofPending := true
        riskProofStart := bar_index
        riskProofEntry := close
        riskProofArmAtr := safeAtr
    if riskProofPending and not na(riskProofStart) and bar_index - riskProofStart >= proofWindowBars
        float excursion = math.max(winHigh - riskProofEntry, riskProofEntry - winLow)
        bool proofHit = excursion >= proofMoveMult * riskProofArmAtr
        riskProofTotal += 1
        if proofHit
            riskProofHits += 1
        riskProofPending := false

float riskProofRate = riskProofTotal > 0 ? riskProofHits / riskProofTotal * 100.0 : na
string proofText = riskProofTotal > 0 ? str.tostring(int(math.round(riskProofRate))) + "% (" + str.tostring(riskProofHits) + "/" + str.tostring(riskProofTotal) + ")" : "Building"
color proofColor = riskProofTotal == 0 ? neutralColor : riskProofRate >= 60.0 ? bullColor : riskProofRate >= 45.0 ? neutralColor : bearColor

// --------------------------------------------------
// Visual Objects
// --------------------------------------------------
hiddenColor = color.new(color.black, 100)
var line riskRail = line.new(bar_index, close, bar_index + 1, close, xloc = xloc.bar_index, color = riskColor, style = line.style_solid, width = 2)
var line pressureRail = line.new(bar_index, close, bar_index + 1, close, xloc = xloc.bar_index, color = accentColor, style = line.style_dotted, width = 2)
var line coolingRail = line.new(bar_index, close, bar_index + 1, close, xloc = xloc.bar_index, color = coolColor, style = line.style_solid, width = 2)
var line pressureNeedle = line.new(bar_index, close, bar_index, close, xloc = xloc.bar_index, color = riskColor, style = line.style_solid, width = 3)
var line tracksLead = line.new(bar_index, close, bar_index + 1, close, xloc = xloc.bar_index, color = hiddenColor, style = line.style_solid, width = 2)
var label centerLabel = label.new(bar_index, close, "", xloc = xloc.bar_index, style = label.style_label_center, color = accentColor, textcolor = headerText, size = size.normal, textalign = text.align_center)
var label stateTag = label.new(bar_index, close, "", xloc = xloc.bar_index, style = label.style_label_left, color = accentColor, textcolor = headerText, size = size.normal)
var label riskTag = label.new(bar_index, close, "", xloc = xloc.bar_index, style = label.style_label_left, color = riskColor, textcolor = headerText, size = size.normal)
var label coolingTag = label.new(bar_index, close, "", xloc = xloc.bar_index, style = label.style_label_left, color = coolColor, textcolor = darkText, size = size.normal)
var label tracksTag = label.new(bar_index, close, "", xloc = xloc.bar_index, style = label.style_label_left, color = hiddenColor, textcolor = headerText, size = size.normal)
var array<label> eventLabels = array.new<label>()
var int lastLabelBar = na
var string previousState = "Neutral Risk"

visualScore = dataReady ? math.max(cascadeScore, coolingScore) : 20.0
span = safeAtr * (0.62 + visualScore / 100.0 * 0.95)
topY = close + span
midY = close
bottomY = close - span
projectionUsed = adaptiveProjection and not timeframe.isintraday ? math.max(14, int(math.round(projectionBars * 0.72))) : projectionBars
historyUsed = adaptiveProjection and not timeframe.isintraday ? int(math.round(historyBars * 0.68)) : historyBars
rightX = bar_index + projectionUsed
leftX = bar_index - historyUsed
labelX = int(math.round(leftX + (rightX - leftX) * boardAnchor))
gaugeX = math.max(leftX + 2, labelX - 4)
needleY = bottomY + (topY - bottomY) * f_clamp(cascadeScore / 100.0, 0.0, 1.0)
centerText = dataReady ? "CASCADE\n" + qualityText + " | R " + f_score(cascadeScore) + " " + f_grade(cascadeScore) : "CASCADE\nDATA MISSING"

if barstate.islast
    if showCascadeBoard
        line.set_xy1(riskRail, leftX, topY)
        line.set_xy2(riskRail, rightX, topY)
        line.set_color(riskRail, color.new(stateColor, 0))
        line.set_width(riskRail, 2)
        line.set_xy1(pressureRail, leftX, midY)
        line.set_xy2(pressureRail, rightX, midY)
        line.set_color(pressureRail, color.new(accentColor, 12))
        line.set_width(pressureRail, 2)
        line.set_xy1(coolingRail, leftX, bottomY)
        line.set_xy2(coolingRail, rightX, bottomY)
        line.set_color(coolingRail, color.new(coolColor, 0))
        line.set_width(coolingRail, 2)
        line.set_xy1(pressureNeedle, gaugeX, bottomY)
        line.set_xy2(pressureNeedle, gaugeX, needleY)
        line.set_color(pressureNeedle, color.new(stateColor, 0))
        line.set_width(pressureNeedle, 3)
        color badgeBg = color.new(stateText == "Neutral Risk" ? slateBadge : stateColor, 5)
        f_set_label(centerLabel, labelX, midY, centerText, badgeBg, true, labelSizeInput)
    else
        line.set_color(riskRail, hiddenColor)
        line.set_color(pressureRail, hiddenColor)
        line.set_color(coolingRail, hiddenColor)
        line.set_color(pressureNeedle, hiddenColor)
        label.set_text(centerLabel, "")
        label.set_color(centerLabel, hiddenColor)

    if showRightTags and showCascadeBoard
        f_set_label(stateTag, rightX, topY, stateText, color.new(stateColor, 0), false, labelSizeInput)
        f_set_label(riskTag, rightX, midY, "Risk " + f_score(cascadeScore), color.new(boardBlue, 4), false, labelSizeInput)
        f_set_label(coolingTag, rightX, bottomY, "Cooling " + f_score(coolingScore), color.new(coolColor, 0), false, labelSizeInput)
    else
        label.set_text(stateTag, "")
        label.set_text(riskTag, "")
        label.set_text(coolingTag, "")
        label.set_color(stateTag, hiddenColor)
        label.set_color(riskTag, hiddenColor)
        label.set_color(coolingTag, hiddenColor)

    if showTracks and dataReady
        line.set_xy1(tracksLead, bar_index, fast)
        line.set_xy2(tracksLead, bar_index + 2, fast)
        line.set_color(tracksLead, color.new(stateColor, 35))
        f_set_label(tracksTag, bar_index + 3, fast, "PRESSURE TRACKS", color.new(stateColor, 8), false, labelSizeInput)
    else
        line.set_color(tracksLead, hiddenColor)
        label.set_text(tracksTag, "")
        label.set_color(tracksTag, hiddenColor)

// --------------------------------------------------
// Event Labels and Plots
// --------------------------------------------------
canLabel = showEventLabels and dataReady and (na(lastLabelBar) or bar_index - lastLabelBar >= labelCooldownBars)
newState = stateText != previousState
hadCascadePressure = ta.highest(cascadeScore, persistenceBars * 4) >= cascadeThreshold
majorCooling = riskCooling and coolingScore >= 74.0 and hadCascadePressure
longEvent = alertLongCascade and longCascade and canLabel and newState
shortEvent = alertShortCascade and shortCascade and canLabel and newState
twoWayEvent = alertTwoWay and twoWayCascade and canLabel and newState
coolEvent = alertCooling and majorCooling and canLabel and newState
pulseCooldown = math.max(10, int(math.round(labelCooldownBars * 0.70)))
pulseReady = showPulseMarkers and dataReady and (bar_index % pulseCooldown == 0 or newState)

if longEvent
    f_event_label(eventLabels, bar_index, high + safeAtr * labelOffsetAtr, "Long Cascade " + f_score(cascadeScore), bearColor, false, labelSizeInput, maxEventLabels)
    lastLabelBar := bar_index
if shortEvent
    f_event_label(eventLabels, bar_index, low - safeAtr * labelOffsetAtr, "Short Cascade " + f_score(cascadeScore), bullColor, true, labelSizeInput, maxEventLabels)
    lastLabelBar := bar_index
if twoWayEvent
    f_event_label(eventLabels, bar_index, high + safeAtr * labelOffsetAtr, "Two-Way " + f_score(cascadeScore), riskColor, false, labelSizeInput, maxEventLabels)
    lastLabelBar := bar_index
if coolEvent
    f_event_label(eventLabels, bar_index, low - safeAtr * labelOffsetAtr, "Risk Cooling " + f_score(coolingScore), coolColor, true, labelSizeInput, maxEventLabels)
    lastLabelBar := bar_index

previousState := stateText

barcolor(showBarColors ? color.new(stateColor, 74) : na)
plotshape(pulseReady and longCascade, "Long Cascade Pulse", style = shape.triangledown, location = location.abovebar, color = color.new(bearColor, 0), size = size.tiny)
plotshape(pulseReady and shortCascade, "Short Cascade Pulse", style = shape.triangleup, location = location.belowbar, color = color.new(bullColor, 0), size = size.tiny)
plotshape(pulseReady and twoWayCascade, "Two-Way Cascade Pulse", style = shape.circle, location = location.abovebar, color = color.new(riskColor, 0), size = size.tiny)
plotshape(pulseReady and riskCooling, "Risk Cooling Pulse", style = shape.diamond, location = location.belowbar, color = color.new(coolColor, 0), size = size.tiny)
plot(showTracks and dataReady ? fast : na, "Fast Cascade Pressure", color = color.new(stateColor, 0), linewidth = 2)
plot(showTracks and dataReady ? slow : na, "Slow Cascade Baseline", color = color.new(accentColor, 35), linewidth = 2)

// --------------------------------------------------
// Panel
// --------------------------------------------------
var table panel = table.new(f_pos(panelPositionInput), 2, 7, bgcolor = f_bg(panelThemeInput), frame_color = f_border(panelThemeInput), frame_width = 1, border_color = f_border(panelThemeInput), border_width = 1)

if barstate.islast
    table.set_position(panel, f_pos(panelPositionInput))
    table.clear(panel, 0, 0, 1, 6)
    if showPanel
        table.merge_cells(panel, 0, 0, 1, 0)
        table.cell(panel, 0, 0, "AG Pro Liquidation Cascade Risk Map", text_color = headerText, bgcolor = headerBg, text_size = f_size(panelFontSizeInput), text_halign = text.align_center)
        f_panel_row(panel, 1, "Cascade State", stateText, stateColor, panelThemeInput, panelFontSizeInput)
        f_panel_row(panel, 2, "Risk Pressure", f_score(cascadeScore) + " / " + f_grade(cascadeScore), dataReady ? stateColor : neutralColor, panelThemeInput, panelFontSizeInput)
        f_panel_row(panel, 3, "Cooling Pressure", f_score(coolingScore), riskCooling ? coolColor : f_value_col(panelThemeInput), panelThemeInput, panelFontSizeInput)
        f_panel_row(panel, 4, "Cascade Hit Rate", proofText, proofColor, panelThemeInput, panelFontSizeInput)
        f_panel_row(panel, 5, "Direction", directionText, stateColor, panelThemeInput, panelFontSizeInput)
        f_panel_row(panel, 6, "Data Mode", dataMode, f_value_col(panelThemeInput), panelThemeInput, panelFontSizeInput)

// --------------------------------------------------
// Alerts
// --------------------------------------------------
alertcondition(alertLongCascade and longCascade and stateText != stateText[1], "Long Liquidation Cascade Risk", "Downside liquidation-cascade risk is elevated on {{ticker}}.")
alertcondition(alertShortCascade and shortCascade and stateText != stateText[1], "Short Liquidation Cascade Risk", "Upside liquidation-cascade risk is elevated on {{ticker}}.")
alertcondition(alertTwoWay and twoWayCascade and stateText != stateText[1], "Two-Way Liquidation Cascade Risk", "Two-way liquidation-cascade pressure is elevated on {{ticker}}.")
alertcondition(alertCooling and riskCooling and stateText != stateText[1], "Liquidation Cascade Risk Cooling", "Liquidation-cascade pressure is cooling on {{ticker}}.")
````
