# Leverage Reset Quality Map [AGPro Series]

- url: https://www.tradingview.com/script/7WQwyKHX-Leverage-Reset-Quality-Map-AGPro-Series/
- type: indicator
- pine_id: PUB;58208d7162f3473dab4766e14237dc53
- version: 4.0

## Description

Leverage Reset Quality Map [AGPro Series]

🧠 Core Idea

Did leverage actually reset, or did the market only pause before risk rebuilt again?


📌 Overview / What it does

Leverage Reset Quality Map is a crypto derivatives context tool designed to evaluate whether a leverage washout is developing into a cleaner reset, a fragile reset, a crowded stress condition, or a reload-risk environment.

The script combines open interest when available, a transparent volume-proxy fallback, data-change behavior, volatility shock, range expansion, wick flush behavior, recovery quality, persistence, and trend context. It converts those inputs into a reset-quality ladder, compact state labels, right-side tags, pulse markers, alerts, and an AG Pro dashboard.

It does not liquidate positions, predict future price direction, automate entries, or claim that a reset must lead to a reversal. It is an analytical map for reading whether leverage pressure appears to be clearing, rebuilding, or remaining unstable.


🎯 Purpose & Design Philosophy

This script was built for traders who want to separate a true leverage reset from a simple bounce, pause, or noisy reaction.

After sharp moves, many markets look relieved for a short period. The important question is whether participation pressure cooled, volatility stabilized, and price recovered with acceptable structure. Leverage Reset Quality Map turns that question into a visible workflow.

The design philosophy is simple: a reset is not automatically bullish or bearish. A reset is a context condition. Its quality depends on stress release, recovery quality, volatility behavior, and whether participation starts rebuilding too early.


⚡ Why This Script Is Different

Most tools focus on liquidation levels, open interest changes, or raw volume spikes.

This script does NOT draw another liquidation heatmap, does NOT treat every OI drop as bullish, and does NOT mark every volume spike as meaningful leverage cleansing.

Instead, it evaluates reset quality as a multi-factor condition. It asks whether stress is building, whether pressure is releasing, whether the market is recovering cleanly, and whether leverage-style participation is reloading before the reset matures.


⚙️ Methodology

1. Context Detection
The script reads official open interest when available. If official OI is unavailable and fallback is enabled, it uses volume as a transparent leverage-participation proxy.

2. Stress Mapping
It evaluates data-change pressure, velocity, volatility shock, range shock, and wick flush behavior to estimate whether leverage-style stress is present.

3. Reset Quality Evaluation
It measures participation contraction, volatility cooling, price recovery, wick recovery, and trend context to estimate reset quality.

4. Visual Output
The output is displayed as a reset-quality ladder with state, quality, reload risk, event labels, compact pulse markers, reaction tracks, and a dashboard panel.


🗺️ How to Read the Chart

The reset-quality ladder is the main visual object.

The upper step represents the current reset or stress state.

The middle step represents reset quality.

The lower step represents reload risk.

The vertical needle shows where current reset quality sits inside the ladder.

Labels mark state transitions such as Clean Reset, Fragile Reset, Reload Risk, and Stress Build.

Compact pulse markers add context:
• R = Clean Reset pulse
• F = Fragile Reset pulse
• L = Reload Risk pulse
• S = Stress Build pulse

Colors communicate context:
• Teal = cleaner reset pressure
• Yellow = fragile or incomplete reset
• Pink = reload or stress risk
• Indigo = neutral reset-quality structure

The panel summarizes state, reset quality, data change, stress score, persistence, reload score, direction, grade, data mode, volatility shock, OI source, and trend.


🚦 Signals & States

• Clean Reset → stress release and recovery quality are improving

• Fragile Reset → some reset behavior is visible, but quality remains incomplete

• Reload Risk → participation may be rebuilding before the reset is healthy

• Crowded Stress → leverage-style pressure is building without a clean reset

• Neutral Reset → no active reset state dominates the current read

• Data Missing → official OI and fallback data are not available


🔔 Alerts Logic

Alerts trigger when the script transitions into selected reset-quality states.

Clean Reset alerts mark improving reset quality.

Fragile Reset alerts mark incomplete reset conditions.

Reload Risk alerts mark renewed leverage-style participation before quality improves.

Stress Build alerts mark stress expansion without a clean reset read.

Alerts are attention markers, not trade instructions.


🧩 Confluence Logic

The strongest context appears when several components align:

Participation contraction + volatility cooling + wick recovery + price recovery + improving reset quality.

The weakest context appears when participation expands again, volatility stays hot, and reset quality remains low.


📊 When to Use

• Crypto perpetual and futures charts

• Post-selloff or post-squeeze environments

• High-volatility reactions

• Open interest or volume-pressure analysis

• Markets where leverage reset quality matters more than a raw signal


⚠️ When NOT to Use

• Extremely illiquid symbols

• Markets with unreliable open interest or volume data

• Very low-volatility sideways charts where leverage pressure is not active

• News-driven gaps where normal reset logic may be distorted

• Any situation where the user expects a direct buy or sell signal


🎛️ Key Inputs

• Data Mode → selects official OI, manual OI, or volume-proxy behavior

• Manual Open Interest Symbol → lets the user define a specific OI source

• Context Lookback → controls the normalization window

• Fast Reaction Length → controls the short-term recovery track

• Slow Baseline Length → controls the slower reset baseline

• Minimum Stress Score → controls how much pressure is required for stress states

• Minimum Quality Score → controls how much recovery quality is required for a clean reset

• Event Label Cooldown → controls label spacing and visual density

• Panel / label settings → control visual layout and readability


🖥️ Interface & Visual Design

The interface is designed to feel different from zone-first or corridor-first tools.

Instead of drawing a large boxed area, the script uses a staggered reset-quality ladder. This keeps the chart readable on both dark and light TradingView backgrounds and reduces the risk of looking like a duplicate of nearby derivatives tools.

The panel uses a merged blue AG Pro header row and a compact information hierarchy.


🧪 Practical Usage Workflow

1. Read the panel state.

2. Check whether data mode is Open Interest or Volume Proxy.

3. Look at the reset-quality ladder.

4. Compare reset quality with reload risk.

5. Review recent event labels and pulse markers.

6. Confirm the broader chart structure.


🔍 Interpretation Guidelines

A Clean Reset does not mean price must rise.

A Reload Risk state does not mean price must fall.

The script is designed to help users think in terms of leverage pressure, reset quality, and context alignment. It should be interpreted with broader structure, liquidity, trend, and risk controls.


🚫 What This Script Is NOT

This script is not a prediction engine.

It is not financial advice.

It is not an auto-trading system.

It is not a liquidation heatmap.

It does not guarantee reversals, continuations, entries, exits, or outcomes.


⚠️ Limitations & Transparency

Open interest availability depends on the symbol, exchange, and TradingView data support.

When official OI is unavailable, the script can use volume as a transparent proxy. A proxy is not the same as official open interest.

Timeframe differences may change how reset quality appears.

Volatility spikes, exchange-specific behavior, and sudden news events may distort the read.


🧠 Market Context Notes

Leverage resets often appear after forced movement, sharp volatility expansion, wick-heavy reactions, or participation contraction.

The important distinction is whether the reset becomes cleaner or whether risk reloads before the market has stabilized.

This script focuses on that distinction.


🧾 Use Case Examples

When price flushes lower, participation contracts, volatility cools, and price recovers toward the reaction track, the script may show Clean Reset.

When a market bounces but participation expands again while reset quality remains weak, the script may show Reload Risk.

When volatility remains hot and stress score remains elevated, the script may show Crowded Stress.


🧱 System Philosophy

Leverage Reset Quality Map follows the AGProLabs principle of building decision-support maps rather than prediction tools.

The goal is to make hidden market conditions easier to observe, compare, and interpret without overclaiming certainty.


🔐 Non-Promise Statement

No script can know future price direction.

No state should be treated as certainty.

Every output should be interpreted as context, not as an instruction.


📉 Risk Disclosure

Trading involves risk.

Crypto derivatives can be highly volatile and may involve leverage, liquidation risk, exchange risk, data limitations, and rapid market movement.

Users remain fully responsible for their own decisions.

This script does not provide financial advice.


📚 Educational Note

This script is intended for educational, analytical, and visual market-structure study.

Its value comes from helping users ask better questions about leverage pressure, reset quality, and risk rebuilding.

## Source Code

````pine
// --------------------------------------------------
// Leverage Reset Quality Map [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 1.3.0
//
// Leverage Reset Quality Map is a crypto derivatives context indicator built to
// evaluate whether a leverage washout is becoming cleaner, fragile, crowded, or
// vulnerable to reload risk. It combines open interest or transparent volume
// proxy behavior, volatility shock, wick flush behavior, recovery quality,
// persistence, and trend context into a forward-anchored reset-quality ladder,
// evidence-aware participation readouts, confirmed state labels, right-side
// tags, a self-measured reset hold rate, and an AG Pro dashboard.
// --------------------------------------------------

//@version=6
indicator("Leverage Reset Quality Map [AGPro Series]",
     shorttitle = "AG Pro LRQ",
     overlay = true,
     max_lines_count = 80,
     max_labels_count = 120,
     max_boxes_count = 8)

// --------------------------------------------------
// Inputs
// --------------------------------------------------
string G_SOURCE = "Leverage Data"
string G_ENGINE = "Reset Quality Engine"
string G_VISUAL = "Visual Design"
string G_PANEL = "Panel"
string G_ALERTS = "Alerts"

string dataModeInput = input.string("Auto OI Then Volume Proxy", "Data Mode", options = ["Auto OI Then Volume Proxy", "Manual OI Symbol", "Volume Proxy Only"], group = G_SOURCE,
     tooltip = "Selects whether the script tries to read an open interest source first or uses volume as a transparent leverage-participation proxy.")
string manualOiSymbol = input.symbol("BINANCE:ETHUSDTPERP_OI", "Manual Open Interest Symbol", group = G_SOURCE,
     tooltip = "Manual open interest source. If it is unavailable, use Auto OI Then Volume Proxy or Volume Proxy Only.")
bool allowVolumeProxy = input.bool(true, "Allow Volume Proxy Fallback", group = G_SOURCE,
     tooltip = "Allows volume expansion or contraction to act as a transparent fallback when official open interest is not available.")

int lookback = input.int(120, "Context Lookback", minval = 40, maxval = 500, group = G_ENGINE,
     tooltip = "Historical window used for volatility normalization, participation-change context, and reset-quality scoring.")
int fastLen = input.int(13, "Fast Reaction Length", minval = 3, maxval = 80, group = G_ENGINE,
     tooltip = "Short-term reaction track used to evaluate price recovery after leverage stress.")
int slowLen = input.int(34, "Slow Baseline Length", minval = 8, maxval = 160, group = G_ENGINE,
     tooltip = "Slower baseline used to identify whether the market is recovering or still dislocated.")
int atrLen = input.int(14, "ATR Length", minval = 5, maxval = 80, group = G_ENGINE,
     tooltip = "ATR length used for volatility shock, ladder spacing, and label offsets.")
int stressThreshold = input.int(55, "Minimum Stress Score", minval = 1, maxval = 100, group = G_ENGINE,
     tooltip = "Minimum leverage-stress score required before a crowded stress or reset read becomes meaningful.")
int qualityThreshold = input.int(52, "Minimum Quality Score", minval = 1, maxval = 100, group = G_ENGINE,
     tooltip = "Minimum reset-quality score required before the reset can be treated as clean.")
int persistenceBars = input.int(10, "Persistence Bars", minval = 3, maxval = 50, group = G_ENGINE,
     tooltip = "Counts how often stress, reset, or reload conditions persist inside the recent window.")
int proofWindowBars = input.int(8, "Reset Proof Window", minval = 3, maxval = 60, group = G_ENGINE,
     tooltip = "After a Clean Reset, the map waits this many bars and checks whether price recovered in the expected direction. Feeds the Reset Hold Rate as a directional follow-through measure of the reset context.")

bool showLadder = input.bool(true, "Show Reset Quality Ladder", group = G_VISUAL,
     tooltip = "Shows the open reset-quality ladder with state, quality, and reload-risk rails.")
bool showCenterBadge = input.bool(true, "Show Center Ladder Badge", group = G_VISUAL,
     tooltip = "Shows a centered contrast-safe badge on the ladder so the current reset read is readable at first glance.")
bool showEventLabels = input.bool(true, "Show Event Labels", group = G_VISUAL,
     tooltip = "Shows compact event labels when leverage reset states change.")
bool showPulseMarkers = input.bool(false, "Show Compact Pulse Markers", group = G_VISUAL,
     tooltip = "Adds small pulse markers for stress, clean reset, fragile reset, and reload risk without crowding the chart.")
bool showRightTags = input.bool(true, "Show Right-Side Tags", group = G_VISUAL,
     tooltip = "Shows right-side ladder tags for state, quality, and reload risk.")
bool showTracks = input.bool(true, "Show Reaction Tracks", group = G_VISUAL,
     tooltip = "Shows fast and slow reaction tracks used to evaluate recovery quality.")
bool showBarColors = input.bool(false, "Color Bars by State", group = G_VISUAL,
     tooltip = "Optionally colors bars by the current leverage-reset state.")
int projectionBars = input.int(34, "Ladder Projection Bars", minval = 12, maxval = 120, group = G_VISUAL,
     tooltip = "Controls how far the reset-quality ladder and right-side tags extend to the right.")
string ladderAnchorInput = input.string("Forward", "Ladder Anchor", options = ["Forward", "Historical"], group = G_VISUAL,
     tooltip = "Forward keeps the active decision ladder clear of current candles. Historical preserves the wider legacy footprint.")
int ladderClearanceBars = input.int(3, "Ladder Candle Clearance", minval = 1, maxval = 20, group = G_VISUAL,
     tooltip = "Number of bars between the live candle and the start of the forward-anchored ladder.")
int ladderHistoryBars = input.int(52, "Ladder History Bars", minval = 20, maxval = 200, group = G_VISUAL,
     tooltip = "Controls how far back the ladder starts when Ladder Anchor is set to Historical.")
int labelCooldownBars = input.int(24, "Event Label Cooldown", minval = 5, maxval = 100, group = G_VISUAL,
     tooltip = "Minimum spacing between event labels.")
int maxEventLabels = input.int(7, "Maximum Event Labels", minval = 1, maxval = 30, group = G_VISUAL,
     tooltip = "Limits event-label count so the chart remains premium and readable.")
float labelOffsetAtr = input.float(0.90, "Label Offset ATR", minval = 0.10, maxval = 5.0, step = 0.05, group = G_VISUAL,
     tooltip = "Moves event labels away from candles using ATR spacing.")
string labelSizeInput = input.string("Normal", "Label Font Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = G_VISUAL,
     tooltip = "Controls chart label, centered badge, and right-side tag font size.")

bool showPanel = input.bool(true, "Show Panel", group = G_PANEL,
     tooltip = "Shows or hides the AG Pro dashboard panel.")
string panelPositionInput = input.string("Top Right", "Panel Location", options = ["Top Right", "Top Left", "Top Center", "Middle Right", "Middle Left", "Middle Center", "Bottom Right", "Bottom Left", "Bottom Center"], group = G_PANEL,
     tooltip = "Controls dashboard panel location.")
string panelThemeInput = input.string("Dark", "Panel Theme", options = ["Dark", "Light"], group = G_PANEL,
     tooltip = "Controls dashboard panel theme.")
string panelFontSizeInput = input.string("Normal", "Panel Font Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = G_PANEL,
     tooltip = "Controls dashboard panel font size.")

bool alertCleanReset = input.bool(true, "Alert: Clean Reset", group = G_ALERTS,
     tooltip = "Triggers when stress release and recovery quality align into a cleaner leverage reset.")
bool alertFragileReset = input.bool(true, "Alert: Fragile Reset", group = G_ALERTS,
     tooltip = "Triggers when a reset is visible but quality remains weak or incomplete.")
bool alertReloadRisk = input.bool(true, "Alert: Reload Risk", group = G_ALERTS,
     tooltip = "Triggers when leverage-style participation begins rebuilding before reset quality is strong.")
bool alertStressBuild = input.bool(true, "Alert: Stress Build", group = G_ALERTS,
     tooltip = "Triggers when leverage stress is building without a healthy reset read.")

// --------------------------------------------------
// AGPro Color Palette
// --------------------------------------------------
color headerBg = color.rgb(37, 99, 235)
color headerText = color.rgb(245, 247, 250)
color panelBg = color.rgb(15, 23, 42)
color panelBorder = color.rgb(86, 103, 130)
color panelLabelCol = color.rgb(190, 202, 220)
color panelValueCol = color.rgb(245, 247, 250)
color bullColor = color.rgb(34, 197, 166)
color bearColor = color.rgb(244, 114, 182)
color neutralColor = color.rgb(245, 189, 92)
color accentColor = color.rgb(129, 140, 248)
color resetColor = color.rgb(56, 189, 248)
color riskColor = color.rgb(251, 113, 133)
color darkText = color.rgb(17, 24, 39)

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
     posName == "Middle Right" ? position.middle_right :
     posName == "Middle Left" ? position.middle_left :
     posName == "Middle Center" ? position.middle_center :
     posName == "Bottom Right" ? position.bottom_right :
     posName == "Bottom Left" ? position.bottom_left :
     posName == "Bottom Center" ? position.bottom_center : position.top_right

f_pct(float value) =>
    na(value) ? "n/a" : str.tostring(value, "#.###") + "%"

f_score(float value) =>
    na(value) ? "n/a" : str.tostring(math.round(value))

f_ratio(float value) =>
    na(value) ? "n/a" : str.tostring(value, "#.##") + "x"

f_text_on(color bgColor) =>
    float r = color.r(bgColor)
    float g = color.g(bgColor)
    float b = color.b(bgColor)
    float yiq = (r * 299.0 + g * 587.0 + b * 114.0) / 1000.0
    yiq >= 145.0 ? darkText : headerText

f_panel_bg(string themeName) =>
    themeName == "Light" ? color.rgb(248, 250, 252) : panelBg

f_panel_label(string themeName) =>
    themeName == "Light" ? color.rgb(71, 85, 105) : panelLabelCol

f_panel_value(string themeName) =>
    themeName == "Light" ? color.rgb(15, 23, 42) : panelValueCol

f_row_bg(string themeName, int row) =>
    bool evenRow = row % 2 == 0
    if themeName == "Light"
        evenRow ? color.rgb(226, 232, 240) : color.rgb(248, 250, 252)
    else
        evenRow ? color.rgb(29, 49, 82) : color.rgb(6, 12, 24)

f_state_color(string stateName) =>
    stateName == "Clean Reset" ? bullColor :
     stateName == "Fragile Reset" ? neutralColor :
     stateName == "Reload Risk" ? riskColor :
     stateName == "Crowded Stress" ? bearColor :
     stateName == "Data Missing" ? neutralColor : accentColor

f_panel_row(table panelRef, int row, string leftText, string rightText, color rightColor, string themeName, string sizeInput) =>
    color rowBg = f_row_bg(themeName, row)
    table.cell(panelRef, 0, row, leftText, text_color = f_panel_label(themeName), bgcolor = rowBg, text_size = f_size(sizeInput), text_halign = text.align_left)
    table.cell(panelRef, 1, row, rightText, text_color = rightColor, bgcolor = rowBg, text_size = f_size(sizeInput), text_halign = text.align_right)

f_set_label(label labelRef, int x, float y, string txt, color bgCol, string styleInput, string sizeInput) =>
    label.set_xy(labelRef, x, y)
    label.set_text(labelRef, txt)
    label.set_color(labelRef, color.new(bgCol, 3))
    label.set_textcolor(labelRef, f_text_on(bgCol))
    label.set_style(labelRef, styleInput == "center" ? label.style_label_center : label.style_label_left)
    label.set_size(labelRef, f_size(sizeInput))

f_keep_label(array<label> labelArray, label newLabel, int maxCount) =>
    array.push(labelArray, newLabel)
    if array.size(labelArray) > maxCount
        label oldLabel = array.shift(labelArray)
        label.delete(oldLabel)

f_event_label(array<label> labelArray, int x, float y, string txt, color bgCol, bool upward, string sizeInput, int maxCount) =>
    label newLabel = label.new(x, y, txt, xloc = xloc.bar_index, yloc = yloc.price, style = upward ? label.style_label_up : label.style_label_down, color = color.new(bgCol, 4), textcolor = f_text_on(bgCol), size = f_size(sizeInput), textalign = text.align_center)
    f_keep_label(labelArray, newLabel, maxCount)

// --------------------------------------------------
// Data Engine
// --------------------------------------------------
string autoOiSymbol = syminfo.tickerid + "_OI"
string oiSymbol = dataModeInput == "Manual OI Symbol" ? manualOiSymbol : autoOiSymbol
float oiRaw = dataModeInput == "Volume Proxy Only" ? na : request.security(oiSymbol, timeframe.period, close, gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off, ignore_invalid_symbol = true)
bool oiAvailable = not na(oiRaw)
float proxySource = oiAvailable ? oiRaw : allowVolumeProxy ? volume : na
bool dataReady = not na(proxySource) and proxySource > 0.0
string sourceRead = oiAvailable ? "Open Interest / Direct" : allowVolumeProxy and dataReady ? (dataModeInput == "Volume Proxy Only" ? "Volume Proxy / Selected" : "Volume Proxy / Fallback") : "No Data"

float atrRaw = ta.atr(atrLen)
float safeAtr = math.max(nz(atrRaw, ta.tr(true)), syminfo.mintick)
float fast = ta.ema(close, fastLen)
float slow = ta.ema(close, slowLen)
float proxyChangePct = dataReady and not na(proxySource[fastLen]) and proxySource[fastLen] != 0.0 ? (proxySource - proxySource[fastLen]) / proxySource[fastLen] * 100.0 : na
float proxyVelocity = dataReady ? ta.ema(proxyChangePct - nz(proxyChangePct[1]), 3) : na
float volumeBaseline = ta.sma(volume, fastLen)
float relativeVolume = not na(volumeBaseline) and volumeBaseline > 0.0 ? volume / volumeBaseline : na
string participationText = oiAvailable ? f_pct(proxyChangePct) : dataReady ? "RVOL " + f_ratio(relativeVolume) : "n/a"
float atrPct = close != 0.0 ? safeAtr / close * 100.0 : 0.0
float atrBase = ta.sma(atrPct, lookback)
float atrShock = not na(atrBase) and atrBase > 0.0 ? atrPct / atrBase : 1.0
float rangePct = close != 0.0 ? (high - low) / close * 100.0 : 0.0
float rangeBase = ta.sma(rangePct, lookback)
float rangeShock = not na(rangeBase) and rangeBase > 0.0 ? rangePct / rangeBase : 1.0
float upperWick = high - math.max(open, close)
float lowerWick = math.min(open, close) - low
float wickRange = math.max(high - low, syminfo.mintick)
float lowerFlush = lowerWick / wickRange * 100.0
float upperFlush = upperWick / wickRange * 100.0
float bodyRecovery = (close - low) / wickRange * 100.0
float bearRecovery = (high - close) / wickRange * 100.0
float distanceFromSlow = (close - slow) / math.max(safeAtr, syminfo.mintick)
bool trendUp = fast > slow and close > slow
bool trendDown = fast < slow and close < slow

float proxyChangeScore = dataReady ? f_clamp(math.abs(proxyChangePct) / 10.0 * 100.0, 0.0, 100.0) : 0.0
float velocityScore = dataReady ? f_clamp(math.abs(proxyVelocity) / 1.8 * 100.0, 0.0, 100.0) : 0.0
float volatilityScore = f_clamp((atrShock - 0.80) / 1.25 * 100.0, 0.0, 100.0)
float rangeShockScore = f_clamp((rangeShock - 0.85) / 1.40 * 100.0, 0.0, 100.0)
float flushScore = f_clamp(math.max(lowerFlush, upperFlush), 0.0, 100.0)
float stressScore = dataReady ? f_clamp(proxyChangeScore * 0.28 + velocityScore * 0.18 + volatilityScore * 0.24 + rangeShockScore * 0.18 + flushScore * 0.12, 0.0, 100.0) : 0.0

bool dataContraction = dataReady and proxyChangePct < 0.0
bool dataExpansion = dataReady and proxyChangePct > 0.0
bool volCooling = atrShock < 1.12 and rangeShock < 1.18
bool volHot = atrShock > 1.25 or rangeShock > 1.35
bool priceRecovered = math.abs(distanceFromSlow) <= 1.20 or close > fast
bool unstableRecovery = math.abs(distanceFromSlow) > 1.60 and volHot

float releaseScore = dataReady ? f_clamp(math.max(-proxyChangePct, 0.0) / 8.0 * 100.0, 0.0, 100.0) : 0.0
float coolingScore = f_clamp((1.45 - atrShock) / 0.85 * 100.0, 0.0, 100.0)
float recoveryScore = f_clamp(math.max(bodyRecovery, bearRecovery) * 0.70 + (priceRecovered ? 30.0 : 0.0), 0.0, 100.0)
float stabilityScore = unstableRecovery ? 20.0 : volCooling ? 78.0 : 48.0
float resetQualityScore = dataReady ? f_clamp(releaseScore * 0.32 + coolingScore * 0.22 + recoveryScore * 0.28 + stabilityScore * 0.18, 0.0, 100.0) : 0.0
float reloadRiskScore = dataReady ? f_clamp(math.max(proxyChangePct, 0.0) / 8.0 * 100.0 + (close < fast ? 18.0 : 0.0) + (volHot ? 16.0 : 0.0), 0.0, 100.0) : 0.0

bool stressRaw = dataReady and stressScore >= stressThreshold
bool cleanRaw = dataReady and dataContraction and resetQualityScore >= qualityThreshold and not unstableRecovery
bool fragileRaw = dataReady and dataContraction and resetQualityScore >= qualityThreshold * 0.62 and resetQualityScore < qualityThreshold
bool reloadRaw = dataReady and dataExpansion and reloadRiskScore >= 48.0 and resetQualityScore < qualityThreshold

float stressPersistence = math.sum(stressRaw ? 1.0 : 0.0, persistenceBars) / persistenceBars * 100.0
float cleanPersistence = math.sum(cleanRaw ? 1.0 : 0.0, persistenceBars) / persistenceBars * 100.0
float fragilePersistence = math.sum(fragileRaw ? 1.0 : 0.0, persistenceBars) / persistenceBars * 100.0
float reloadPersistence = math.sum(reloadRaw ? 1.0 : 0.0, persistenceBars) / persistenceBars * 100.0
float activePersistence = math.max(math.max(cleanPersistence, fragilePersistence), math.max(reloadPersistence, stressPersistence))

bool cleanReset = cleanRaw and cleanPersistence >= 18.0
bool fragileReset = fragileRaw and not cleanReset
bool reloadRisk = reloadRaw and not cleanReset
bool crowdedStress = stressRaw and not cleanReset and not fragileReset and not reloadRisk

string stateText = not dataReady ? "Data Missing" :
     cleanReset ? "Clean Reset" :
     fragileReset ? "Fragile Reset" :
     reloadRisk ? "Reload Risk" :
     crowdedStress ? "Crowded Stress" : "Neutral Reset"
color stateColor = f_state_color(stateText)
string directionText = not dataReady ? "Check Data" :
     cleanReset ? "Reset Improving" :
     fragileReset ? "Incomplete Reset" :
     reloadRisk ? "Leverage Reloading" :
     crowdedStress ? "Stress Building" : "No Active Reset"
string qualityText = not dataReady ? "Missing" :
     resetQualityScore >= 76.0 ? "Strong" :
     resetQualityScore >= qualityThreshold ? "Clean" :
     resetQualityScore >= qualityThreshold * 0.62 ? "Fragile" : "Low"
string actionText = cleanReset ? "Monitor reset quality" :
     fragileReset ? "Wait for cleaner recovery" :
     reloadRisk ? "Watch reload pressure" :
     crowdedStress ? "Respect stress context" :
     not dataReady ? "Check data source" : "Wait for reset read"

// --------------------------------------------------
// Reset Hold Rate (Proof Pass)
// --------------------------------------------------
// On each Clean Reset, capture the flush direction (a down-flush biases toward
// recovery up, an up-flush toward a fade down) and the entry. After the proof
// window, it is a hit when price recovered in the expected direction. Clean
// Reset is a context read rather than a trade with a stop, so this measures
// directional follow-through of the reset context, not a guaranteed outcome.
var int rhpHits = 0
var int rhpTotal = 0
var bool rhpPending = false
var int rhpStart = na
var int rhpDir = 0
var float rhpEntry = na

bool prevClean = bar_index > 0 ? cleanReset[1] : false
bool cleanRising = dataReady and cleanReset and not prevClean

if barstate.isconfirmed
    if cleanRising and not rhpPending
        rhpPending := true
        rhpStart := bar_index
        rhpDir := lowerFlush >= upperFlush ? 1 : -1
        rhpEntry := close
    if rhpPending and not na(rhpStart) and bar_index - rhpStart >= proofWindowBars
        bool recovered = rhpDir > 0 ? close > rhpEntry : close < rhpEntry
        rhpTotal += 1
        if recovered
            rhpHits += 1
        rhpPending := false

float rhpRate = rhpTotal > 0 ? rhpHits / rhpTotal * 100.0 : na
string holdRateText = rhpTotal > 0 ? str.tostring(int(math.round(rhpRate))) + "% (" + str.tostring(rhpHits) + "/" + str.tostring(rhpTotal) + ")" : "Building"
color holdRateColor = rhpTotal == 0 ? neutralColor : rhpRate >= 60.0 ? bullColor : rhpRate >= 45.0 ? neutralColor : riskColor

// --------------------------------------------------
// Visual Objects
// --------------------------------------------------
color hiddenColor = color.new(color.black, 100)
var line stressStep = line.new(bar_index, close, bar_index + 1, close, xloc = xloc.bar_index, color = neutralColor, style = line.style_solid, width = 3)
var line qualityStep = line.new(bar_index, close, bar_index + 1, close, xloc = xloc.bar_index, color = accentColor, style = line.style_dotted, width = 2)
var line reloadStep = line.new(bar_index, close, bar_index + 1, close, xloc = xloc.bar_index, color = riskColor, style = line.style_solid, width = 3)
var line scoreSpine = line.new(bar_index, close, bar_index, close, xloc = xloc.bar_index, color = accentColor, style = line.style_dotted, width = 2)
var line resetNeedle = line.new(bar_index, close, bar_index, close, xloc = xloc.bar_index, color = accentColor, style = line.style_solid, width = 2)
var label centerLabel = label.new(bar_index, close, "", xloc = xloc.bar_index, style = label.style_label_center, color = accentColor, textcolor = headerText, size = size.normal, textalign = text.align_center)
var label stateTag = label.new(bar_index, close, "", xloc = xloc.bar_index, style = label.style_label_left, color = accentColor, textcolor = headerText, size = size.normal)
var label qualityTag = label.new(bar_index, close, "", xloc = xloc.bar_index, style = label.style_label_left, color = accentColor, textcolor = headerText, size = size.normal)
var label reloadTag = label.new(bar_index, close, "", xloc = xloc.bar_index, style = label.style_label_left, color = neutralColor, textcolor = darkText, size = size.normal)
var array<label> eventLabels = array.new<label>()
var int lastLabelBar = na

float visualScore = dataReady ? math.max(stressScore, resetQualityScore) : 20.0
float ladderSpan = safeAtr * (0.60 + visualScore / 100.0 * 0.95)
float ladderTop = close + ladderSpan
float ladderMid = close
float ladderBottom = close - ladderSpan
int rightX = bar_index + math.max(projectionBars, ladderClearanceBars + 12)
int leftX = ladderAnchorInput == "Forward" ? bar_index + ladderClearanceBars : math.max(bar_index - ladderHistoryBars, 0)
int ladderWidth = math.max(rightX - leftX, 12)
int stepGap = math.max(3, int(math.round(ladderWidth * 0.14)))
int stressStartX = leftX
int qualityStartX = leftX + stepGap
int reloadStartX = leftX + stepGap * 2
int labelX = int(math.round(leftX + ladderWidth * 0.52))
float needleY = ladderBottom + (ladderTop - ladderBottom) * f_clamp(resetQualityScore / 100.0, 0.0, 1.0)

if barstate.islast
    if showLadder
        line.set_xy1(stressStep, stressStartX, ladderTop)
        line.set_xy2(stressStep, rightX, ladderTop)
        line.set_color(stressStep, color.new(stateColor, 0))
        line.set_width(stressStep, 3)
        line.set_style(stressStep, line.style_solid)
        line.set_xy1(qualityStep, qualityStartX, ladderMid)
        line.set_xy2(qualityStep, rightX, ladderMid)
        line.set_color(qualityStep, color.new(accentColor, 0))
        line.set_width(qualityStep, 2)
        line.set_style(qualityStep, line.style_dotted)
        line.set_xy1(reloadStep, reloadStartX, ladderBottom)
        line.set_xy2(reloadStep, rightX, ladderBottom)
        line.set_color(reloadStep, color.new(neutralColor, 0))
        line.set_width(reloadStep, 3)
        line.set_style(reloadStep, line.style_solid)
        line.set_xy1(scoreSpine, labelX, ladderBottom)
        line.set_xy2(scoreSpine, labelX, ladderTop)
        line.set_color(scoreSpine, color.new(stateColor, 18))
        line.set_width(scoreSpine, 2)
        line.set_xy1(resetNeedle, labelX, ladderBottom)
        line.set_xy2(resetNeedle, labelX, needleY)
        line.set_color(resetNeedle, color.new(stateColor, 0))
        line.set_width(resetNeedle, 3)
        if showCenterBadge
            string centerText = dataReady ? str.upper(stateText) + " | Q" + f_score(resetQualityScore) + "\nStress " + f_score(stressScore) + " | Reload " + f_score(reloadRiskScore) : "LEVERAGE DATA\nMISSING"
            f_set_label(centerLabel, labelX, ladderMid, centerText, stateColor, "center", labelSizeInput)
        else
            label.set_text(centerLabel, "")
            label.set_color(centerLabel, hiddenColor)
    else
        line.set_color(stressStep, hiddenColor)
        line.set_color(qualityStep, hiddenColor)
        line.set_color(reloadStep, hiddenColor)
        line.set_color(scoreSpine, hiddenColor)
        line.set_color(resetNeedle, hiddenColor)
        label.set_text(centerLabel, "")
        label.set_color(centerLabel, hiddenColor)

    if showRightTags and showLadder
        f_set_label(stateTag, rightX, ladderTop, "STATE " + str.upper(stateText), stateColor, "left", labelSizeInput)
        f_set_label(qualityTag, rightX, ladderMid, "QUALITY " + f_score(resetQualityScore), accentColor, "left", labelSizeInput)
        f_set_label(reloadTag, rightX, ladderBottom, "RELOAD " + f_score(reloadRiskScore), neutralColor, "left", labelSizeInput)
    else
        label.set_text(stateTag, "")
        label.set_text(qualityTag, "")
        label.set_text(reloadTag, "")
        label.set_color(stateTag, hiddenColor)
        label.set_color(qualityTag, hiddenColor)
        label.set_color(reloadTag, hiddenColor)

// --------------------------------------------------
// Event Labels and Plots
// --------------------------------------------------
bool canLabel = showEventLabels and dataReady and (na(lastLabelBar) or bar_index - lastLabelBar >= labelCooldownBars)
bool newState = barstate.isconfirmed and stateText != stateText[1]
bool cleanEvent = cleanReset and canLabel and newState
bool fragileEvent = fragileReset and canLabel and newState
bool reloadEvent = reloadRisk and canLabel and newState
bool stressEvent = crowdedStress and canLabel and newState
int pulseCooldown = math.max(8, int(math.round(labelCooldownBars * 0.50)))
bool pulseReady = showPulseMarkers and dataReady and (bar_index % pulseCooldown == 0 or newState)

if cleanEvent
    f_event_label(eventLabels, bar_index, low - safeAtr * labelOffsetAtr, "CLEAN RESET | Q" + f_score(resetQualityScore), bullColor, true, labelSizeInput, maxEventLabels)
    lastLabelBar := bar_index
if fragileEvent
    f_event_label(eventLabels, bar_index, high + safeAtr * labelOffsetAtr, "FRAGILE RESET | Q" + f_score(resetQualityScore), neutralColor, false, labelSizeInput, maxEventLabels)
    lastLabelBar := bar_index
if reloadEvent
    f_event_label(eventLabels, bar_index, high + safeAtr * labelOffsetAtr, "RELOAD RISK | Q" + f_score(reloadRiskScore), riskColor, false, labelSizeInput, maxEventLabels)
    lastLabelBar := bar_index
if stressEvent
    f_event_label(eventLabels, bar_index, high + safeAtr * labelOffsetAtr, "STRESS BUILD | Q" + f_score(stressScore), bearColor, false, labelSizeInput, maxEventLabels)
    lastLabelBar := bar_index

barcolor(showBarColors ? color.new(stateColor, 72) : na)
plotshape(pulseReady and cleanReset, "Clean Reset Pulse", style = shape.diamond, location = location.belowbar, color = color.new(bullColor, 0), size = size.tiny, text = "R", textcolor = color.white)
plotshape(pulseReady and fragileReset, "Fragile Reset Pulse", style = shape.square, location = location.belowbar, color = color.new(neutralColor, 0), size = size.tiny, text = "F", textcolor = color.rgb(15, 23, 42))
plotshape(pulseReady and reloadRisk, "Reload Risk Pulse", style = shape.triangledown, location = location.abovebar, color = color.new(riskColor, 0), size = size.tiny, text = "L", textcolor = color.white)
plotshape(pulseReady and crowdedStress, "Stress Build Pulse", style = shape.circle, location = location.abovebar, color = color.new(bearColor, 0), size = size.tiny, text = "S", textcolor = color.white)
plot(showTracks and dataReady ? fast : na, "Fast Reset Reaction", color = color.new(stateColor, 0), linewidth = 2)
plot(showTracks and dataReady ? slow : na, "Slow Leverage Baseline", color = color.new(accentColor, 35), linewidth = 2)

// --------------------------------------------------
// Panel
// --------------------------------------------------
var table panel = na
var string panelLocationCache = ""
var string panelThemeCache = ""

if showPanel and (na(panel) or panelLocationCache != panelPositionInput or panelThemeCache != panelThemeInput)
    if not na(panel)
        table.delete(panel)
    panel := table.new(f_pos(panelPositionInput), 2, 8, bgcolor = f_panel_bg(panelThemeInput), frame_color = panelBorder, frame_width = 1, border_color = panelBorder, border_width = 1)
    panelLocationCache := panelPositionInput
    panelThemeCache := panelThemeInput

if barstate.islast
    if showPanel and not na(panel)
        table.clear(panel, 0, 0, 1, 7)
        table.merge_cells(panel, 0, 0, 1, 0)
        table.cell(panel, 0, 0, "AG Pro Leverage Reset Quality Map", text_color = headerText, bgcolor = headerBg, text_size = f_size(panelFontSizeInput), text_halign = text.align_center)
        f_panel_row(panel, 1, "State", stateText + " / " + f_score(resetQualityScore), stateColor, panelThemeInput, panelFontSizeInput)
        f_panel_row(panel, 2, "Pressure", "Stress " + f_score(stressScore) + " / Reload " + f_score(reloadRiskScore), stressScore >= stressThreshold ? bearColor : reloadRiskScore >= 48.0 ? riskColor : f_panel_value(panelThemeInput), panelThemeInput, panelFontSizeInput)
        f_panel_row(panel, 3, "Participation", participationText + " / P " + f_score(activePersistence), f_panel_value(panelThemeInput), panelThemeInput, panelFontSizeInput)
        f_panel_row(panel, 4, "Source", sourceRead, f_panel_value(panelThemeInput), panelThemeInput, panelFontSizeInput)
        f_panel_row(panel, 5, "Context", directionText + " / " + qualityText, stateColor, panelThemeInput, panelFontSizeInput)
        f_panel_row(panel, 6, "Reset Hold Rate", holdRateText, holdRateColor, panelThemeInput, panelFontSizeInput)
        f_panel_row(panel, 7, "Action", actionText, stateColor, panelThemeInput, panelFontSizeInput)
    else
        if not na(panel)
            table.delete(panel)
            panel := na
            panelLocationCache := ""
            panelThemeCache := ""

// --------------------------------------------------
// Alerts
// --------------------------------------------------
alertcondition(alertCleanReset and barstate.isconfirmed and cleanReset and stateText != stateText[1], "Clean Leverage Reset", "Leverage reset quality is improving on {{ticker}}.")
alertcondition(alertFragileReset and barstate.isconfirmed and fragileReset and stateText != stateText[1], "Fragile Leverage Reset", "Leverage reset is visible but quality remains incomplete on {{ticker}}.")
alertcondition(alertReloadRisk and barstate.isconfirmed and reloadRisk and stateText != stateText[1], "Leverage Reload Risk", "Leverage-style participation may be rebuilding before reset quality improves on {{ticker}}.")
alertcondition(alertStressBuild and barstate.isconfirmed and crowdedStress and stateText != stateText[1], "Leverage Stress Build", "Leverage stress is building without a clean reset read on {{ticker}}.")
````
