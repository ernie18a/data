# Volume Participation Shock Map [AGPro Series]

- url: https://www.tradingview.com/script/1BR1RNxF-Volume-Participation-Shock-Map-AGPro-Series/
- type: indicator
- pine_id: PUB;5f6e169326a04103a8d4d1cc4ba1e446
- version: 4.0

## Description

Volume Participation Shock Map [AGPro Series]

🧠 Core Idea

Did the volume shock bring real participation, or did the move get absorbed after the first impulse?

[image]https://www.tradingview.com/x/cJPnm3Ku/[/image]

📌 Overview / What it does

Volume Participation Shock Map is a volume-flow interpretation tool designed to study what happens after a major participation candle appears.

The script identifies high-quality volume shocks by combining relative volume, candle body participation, ATR-adjusted range expansion, and close location. It then projects the active shock zone, tracks follow-through, detects absorption risk, highlights thin continuation attempts, and summarizes the current participation state in an AG Pro panel.

It does not predict price direction, automate trades, or claim that every high-volume candle will continue. It is a structured visualization tool for reading participation quality after volume events.

[image]https://www.tradingview.com/x/WvJeHQ5N/[/image]

🎯 Purpose & Design Philosophy

Many volume tools stop at the first spike.

This script was built to answer the next question:

Did the market continue to participate after the shock, or was the impulse absorbed?

The design goal is to help traders separate meaningful volume expansion from one-bar excitement, thin breakouts, and failed participation.


⚡ Why This Script Is Different

Most tools focus on volume spikes, climax candles, or simple high-volume alerts.

This script does NOT treat high volume as automatically bullish or bearish.

Instead, it checks whether the candle had real body participation, whether price followed through beyond the shock zone, whether the move was absorbed back through the zone, and whether later breakouts happened with weak participation.


⚙️ Methodology

1. Shock Detection

The script compares current volume with recent average volume, checks candle body share, evaluates ATR-adjusted range expansion, and scores close location.

2. Shock Zone Mapping

When a qualified shock appears, the candle range becomes an active participation shock zone.

3. Follow-Through Evaluation

After the shock, the script watches whether price accepts beyond the shock high or low with enough relative volume.

4. Absorption Evaluation

If price closes back through the shock zone after the impulse, the script can mark absorption risk.

5. Visual Output

The chart displays the active shock zone, midpoint participation rail, event labels, right-side context tags, alerts, and a compact AG Pro panel.


🗺️ How to Read the Chart

Participation Shock Zone = the active high-volume candle range being evaluated.

Participation Rail = the midpoint of the shock zone.

BULL VOLUME SHOCK = a bullish shock candle with strong volume, body participation, and range expansion.

BEAR VOLUME SHOCK = a bearish shock candle with strong volume, body participation, and range expansion.

REAL FLOW CONTINUATION = price followed through beyond the shock zone with acceptable participation.

ABSORPTION RISK = price moved back through the shock zone after the initial impulse.

THIN MOVE = price moved beyond the shock edge without enough relative volume. This appears in Detailed label mode.

Panel = summarizes participation state, quality score, shock type, relative volume, body participation, follow-through, absorption risk, and next context.


🚦 Signals & States

• BULL VOLUME SHOCK → bullish high-participation impulse appeared.

• BEAR VOLUME SHOCK → bearish high-participation impulse appeared.

• REAL FLOW UP → bullish shock followed through with acceptable participation.

• REAL FLOW DOWN → bearish shock followed through with acceptable participation.

• BULL SHOCK ABSORBED → bullish shock lost participation back through the zone.

• BEAR SHOCK ABSORBED → bearish shock lost participation back through the zone.

• SHOCK WATCH → an active shock is still being evaluated.

• QUIET FLOW → no active participation shock is currently dominant.


🔔 Alerts Logic

Alerts trigger when a major participation state appears.

• Volume Participation Shock → a high-quality volume shock appears.

• Real-Flow Continuation → price follows through beyond the active shock zone with acceptable participation.

• Absorption Risk → price closes back through the active shock zone after the shock.

• Thin Move → price moves beyond the shock edge without enough relative volume.

Alerts are attention markers, not trade instructions.


🧩 Confluence Logic

The context becomes stronger when:

• Relative volume is clearly above normal
• Candle body participation is strong
• Candle range expands versus ATR
• Price closes near the directional side of the candle
• Follow-through appears before the evaluation window expires
• The panel state agrees with the chart label

If these elements do not align, the script avoids treating volume as automatic conviction.


📊 When to Use

• Breakout participation review
• Trend continuation validation
• Reversal impulse analysis
• High-volume candle interpretation
• Futures, stocks, forex, crypto, and liquid markets
• 15m, 30m, 1H, 4H, and 1D charts where volume data is meaningful


⚠️ When NOT to Use

• Symbols with unreliable or missing volume data
• Very low-liquidity markets
• Extremely noisy micro timeframes
• News spikes where volume behavior may be abnormal
• Markets where candle volume does not represent real participation well
• Situations where a single volume event should not be over-interpreted


🎛️ Key Inputs

• Relative Volume Length → defines the volume baseline.

• Shock Relative Volume → sets how strong volume must be before a shock can qualify.

• Minimum Body Participation % → controls how much candle body commitment is required.

• Minimum Range ATR → filters out small candles with high volume.

• Shock Quality Threshold → controls how selective the main shock labels are.

• Follow-Through Window → defines how long after a shock the script watches for continuation or absorption.

• Minimum Follow Relative Volume → defines whether continuation has enough participation.

• Absorption Midline Threshold % → controls how deeply price must return into the shock zone before absorption risk is marked.

• Event Label Mode → Premium focuses on major shock, continuation, and absorption events. Detailed also allows thin-move labels.


🖥️ Interface & Visual Design

The visual hierarchy is built around the active shock zone.

The zone shows the high-volume impulse range.

The midpoint rail helps judge acceptance versus absorption.

Event labels highlight the most important participation behavior.

Right-side tags keep the current shock context visible.

The AG Pro panel compresses the current state into a fast, readable decision-support summary.


🧪 Practical Usage Workflow

1. Read the panel participation state.

2. Check whether an active shock zone is present.

3. Watch whether price accepts beyond the shock high or low.

4. Evaluate whether follow-through has enough relative volume.

5. Watch for absorption back through the shock zone.

6. Confirm the chart context with structure, trend, liquidity, and risk planning.


🔍 Interpretation Guidelines

A volume shock is not automatically a valid trade signal.

Continuation is stronger when price accepts beyond the shock zone with participation.

Absorption matters when the first impulse cannot hold its zone.

Thin moves can warn that price is extending without enough participation.

The script is best used as a participation-reading layer, not as a standalone decision system.


🚫 What This Script Is NOT

This script is not a prediction engine.

It is not financial advice.

It is not an auto-trading system.

It does not provide guaranteed entry or exit signals.

It is not a simple volume spike alert.


⚠️ Limitations & Transparency

Volume quality depends on the symbol and market.

Crypto, futures, stocks, and forex may represent volume differently.

High volatility can create sudden shock labels that need broader context.

Low-liquidity assets may produce misleading relative volume readings.

Different timeframes may show different participation behavior.


🧠 Market Context Notes

Volume can be useful only when it is read together with price behavior.

A strong candle with high volume may show participation.

But if price cannot follow through, that same candle may become an absorption reference.

This script is designed to make that difference easier to see.


🧾 Use Case Examples

If a strong bullish candle appears with high relative volume, large body participation, and range expansion, the script may mark BULL VOLUME SHOCK.

If price later closes above the shock high with enough participation, the script may mark REAL FLOW CONTINUATION.

If price closes back through the shock zone after the impulse, the script may mark ABSORPTION RISK.

If price breaks beyond the shock edge with weak relative volume, Detailed mode may mark THIN MOVE.


🧱 System Philosophy

The goal is not to make volume louder.

The goal is to make volume behavior more interpretable.

This script treats participation as a sequence:

shock → acceptance → follow-through → absorption or continuation.


🔐 Non-Promise Statement

No script can guarantee market direction.

No volume event guarantees continuation.

No absorption label guarantees reversal.

All outputs should be interpreted as analytical context.


📉 Risk Disclosure

Trading involves risk.

This script is for educational and analytical purposes only.

It does not provide financial advice, investment advice, or guaranteed trading outcomes.

Users are fully responsible for their own decisions, risk management, and trade execution.


📚 Educational Note

Use the script to study how markets behave after high-participation candles.

The most important question is not only whether volume appeared.

The better question is whether price continued to accept that participation afterward.

## Source Code

````pine
// --------------------------------------------------
// Volume Participation Shock Map [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 1.3
//
// Volume Participation Shock Map studies whether a volume shock is supported
// by real candle participation, continuation follow-through, or absorption.
// It maps active shock zones, participation rails, quality labels, right-side
// context tags, alerts, and an AG Pro panel for volume-flow interpretation.
// V1.2 adds a confirmation-anchored proof layer (Follow, Hold, React, Flip
// rates) measuring how often volume shocks followed through in their direction
// before being absorbed back through the shock midline.
// V1.3 refreshes the publication presentation only. Core calculations, alerts,
// inputs and runtime behavior remain unchanged.
// --------------------------------------------------

//@version=6
indicator("Volume Participation Shock Map [AGPro Series]",
     shorttitle = "AG Pro VPS",
     overlay = true,
     max_labels_count = 180,
     max_lines_count = 40,
     max_boxes_count = 40)

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
color dangerColor   = color.rgb(239, 68, 68)

// --------------------------------------------------
// Inputs
// --------------------------------------------------
string G_ENGINE = "Participation Shock Engine"
string G_FLOW   = "Follow-Through Logic"
string G_VISUAL = "Visuals"
string G_PANEL  = "Panel"
string G_ALERTS = "Alerts"

int volumeLen = input.int(30, "Relative Volume Length", minval = 5, maxval = 300, group = G_ENGINE,
     tooltip = "Lookback used to compare current volume with recent market participation.")
int atrLen = input.int(14, "ATR Length", minval = 2, maxval = 100, group = G_ENGINE,
     tooltip = "ATR length used for shock qualification, zone thickness, and label offsets.")
float shockRelVol = input.float(1.55, "Shock Relative Volume", minval = 1.0, maxval = 10.0, step = 0.05, group = G_ENGINE,
     tooltip = "Minimum relative volume needed before a candle can qualify as a participation shock.")
float minBodyPct = input.float(38.0, "Minimum Body Participation %", minval = 5.0, maxval = 95.0, step = 1.0, group = G_ENGINE,
     tooltip = "Minimum candle body share of the full candle range. Higher values require stronger directional commitment.")
float minRangeAtr = input.float(0.75, "Minimum Range ATR", minval = 0.10, maxval = 5.0, step = 0.05, group = G_ENGINE,
     tooltip = "Minimum candle range relative to ATR. This filters out small candles with high relative volume.")
int shockScoreThreshold = input.int(62, "Shock Quality Threshold", minval = 1, maxval = 100, group = G_ENGINE,
     tooltip = "Minimum quality score required before a shock receives the main participation label.")
int scoreSmoothing = input.int(3, "Participation Score Smoothing", minval = 1, maxval = 30, group = G_ENGINE,
     tooltip = "EMA smoothing applied to the participation score so the panel reads as context instead of one-bar noise.")

int followWindowBars = input.int(32, "Follow-Through Window", minval = 3, maxval = 200, group = G_FLOW,
     tooltip = "Number of bars after a shock where continuation or absorption behavior is evaluated.")
float followCloseAtr = input.float(0.12, "Follow-Through Close ATR", minval = 0.01, maxval = 2.0, step = 0.01, group = G_FLOW,
     tooltip = "Distance beyond the shock high or low required before the move is classified as follow-through.")
float followRelVol = input.float(0.85, "Minimum Follow Relative Volume", minval = 0.10, maxval = 5.0, step = 0.05, group = G_FLOW,
     tooltip = "Minimum relative volume required for continuation to be treated as real participation instead of a thin move.")
float absorptionMidPct = input.float(52.0, "Absorption Midline Threshold %", minval = 5.0, maxval = 95.0, step = 1.0, group = G_FLOW,
     tooltip = "How deeply price must close back through the shock zone before absorption risk is highlighted.")
float thinMoveRelVol = input.float(0.70, "Thin Move Relative Volume", minval = 0.10, maxval = 3.0, step = 0.05, group = G_FLOW,
     tooltip = "If price breaks a shock edge with weak relative volume, the move can be marked as thin participation.")

bool showShockZone = input.bool(true, "Show Active Shock Zone", group = G_VISUAL,
     tooltip = "Displays the latest qualified participation shock as a projected zone.")
bool showParticipationRail = input.bool(true, "Show Participation Rail", group = G_VISUAL,
     tooltip = "Draws the midpoint rail of the active shock zone to help read acceptance versus absorption.")
bool showEventLabels = input.bool(true, "Show Participation Labels", group = G_VISUAL,
     tooltip = "Prints curated labels for volume shocks, real-flow continuation, absorption risk, and thin moves.")
string eventLabelMode = input.string("Premium", "Event Label Mode", options = ["Premium", "Detailed"], group = G_VISUAL,
     tooltip = "Premium mode focuses on strong shock, continuation, and absorption states. Detailed mode also labels thin participation.")
bool showRightTags = input.bool(true, "Show Right-Side Tags", group = G_VISUAL,
     tooltip = "Shows compact right-side tags for the active shock high, shock low, and participation state.")
int projectionBars = input.int(80, "Projection Bars", minval = 10, maxval = 500, group = G_VISUAL,
     tooltip = "How far the active shock zone, participation rail, and right-side tags project to the right.")
bool adaptiveProjection = input.bool(true, "Adaptive HTF Projection", group = G_VISUAL,
     tooltip = "Shortens right-side projections on daily, weekly, and monthly charts so high-timeframe screenshots stay readable.")
int labelCooldownBars = input.int(16, "Event Label Cooldown", minval = 1, maxval = 100, group = G_VISUAL,
     tooltip = "Minimum spacing between event labels so the chart remains readable and premium.")
int maxVisibleLabels = input.int(12, "Maximum Event Labels", minval = 4, maxval = 60, group = G_VISUAL,
     tooltip = "Maximum number of historical event labels retained on the chart.")
float eventLabelOffsetAtr = input.float(1.05, "Event Label Offset ATR", minval = 0.20, maxval = 5.0, step = 0.05, group = G_VISUAL,
     tooltip = "Moves event labels away from candles to reduce overlap.")
string labelSizeInput = input.string("Normal", "Label Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = G_VISUAL,
     tooltip = "Text size used by event labels, zone labels, and right-side tags.")

bool showPanel = input.bool(true, "Show Panel", group = G_PANEL,
     tooltip = "Shows or hides the AG Pro volume participation panel.")
string panelPositionInput = input.string("Top Right", "Panel Location", options = ["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], group = G_PANEL,
     tooltip = "Controls where the panel appears on the chart.")
string panelTheme = input.string("Dark", "Panel Theme", options = ["Dark", "Light"], group = G_PANEL,
     tooltip = "Switches the panel between a high-contrast dark AGPro surface and a clean light surface.")
string panelFontSizeInput = input.string("Normal", "Panel Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = G_PANEL,
     tooltip = "Text size used inside the panel.")

bool alertShock = input.bool(true, "Alert: Participation Shock", group = G_ALERTS,
     tooltip = "Enables alerts when a new high-quality volume participation shock appears.")
bool alertRealFlow = input.bool(true, "Alert: Real-Flow Continuation", group = G_ALERTS,
     tooltip = "Enables alerts when price follows through beyond the active shock zone with acceptable participation.")
bool alertAbsorption = input.bool(true, "Alert: Absorption Risk", group = G_ALERTS,
     tooltip = "Enables alerts when price closes back through the active shock zone after a qualified shock.")
bool alertThinMove = input.bool(false, "Alert: Thin Move", group = G_ALERTS,
     tooltip = "Enables alerts when price breaks a shock edge without enough relative volume.")

string G_PROOF = "Proof"
bool showProof = input.bool(true, "Show Proof Layer", group = G_PROOF,
     tooltip = "Shows the confirmation-anchored proof layer in the panel: Follow, Hold, React, and Flip rates measured across volume shocks on the current symbol and timeframe. Follow means the shock continued one risk unit in its direction before being absorbed back through the shock midline. These are historical outcome rates, not predictions.")
int proofHorizonBars = input.int(32, "Proof Horizon Bars", minval = 4, maxval = 300, group = G_PROOF,
     tooltip = "Maximum number of bars each shock is tracked for the proof measurement before it resolves at its current outcome.")
int reactBars = input.int(3, "Reaction Window Bars", minval = 1, maxval = 40, group = G_PROOF,
     tooltip = "Number of bars after a shock used to detect an immediate favorable follow-through reaction.")
float reactProgressPct = input.float(40.0, "Reaction Progress %", minval = 5.0, maxval = 90.0, step = 1.0, group = G_PROOF,
     tooltip = "Minimum favorable progress toward the risk-unit target, within the reaction window, required to count as an early React.")

// --------------------------------------------------
// Helpers
// --------------------------------------------------
f_clamp(float value, float minValue, float maxValue) =>
    math.max(minValue, math.min(maxValue, value))

f_size(string sizeName) =>
    switch sizeName
        "Tiny" => size.tiny
        "Small" => size.small
        "Large" => size.large
        => size.normal

f_panel_pos(string posName) =>
    switch posName
        "Top Left" => position.top_left
        "Top Center" => position.top_center
        "Middle Left" => position.middle_left
        "Middle Center" => position.middle_center
        "Middle Right" => position.middle_right
        "Bottom Left" => position.bottom_left
        "Bottom Center" => position.bottom_center
        "Bottom Right" => position.bottom_right
        => position.top_right

f_fmt(float value) =>
    na(value) ? "n/a" : str.tostring(value, format.mintick)

f_score_text(float value) =>
    na(value) ? "n/a" : str.tostring(math.round(value))

f_rate_pct(value) =>
    str.tostring(int(math.round(value))) + "%"

f_rate_color(value) =>
    value >= 55.0 ? bullColor : value >= 40.0 ? neutralColor : bearColor

f_flip_color(value) =>
    value <= 30.0 ? bullColor : value <= 55.0 ? neutralColor : bearColor

f_text_on(color bgColor) =>
    float r = color.r(bgColor)
    float g = color.g(bgColor)
    float b = color.b(bgColor)
    float yiq = (r * 299.0 + g * 587.0 + b * 114.0) / 1000.0
    yiq >= 150.0 ? color.rgb(15, 23, 42) : headerText

f_panel_bg(string themeName) =>
    themeName == "Light" ? color.rgb(248, 250, 252) : panelBg

f_panel_border(string themeName) =>
    themeName == "Light" ? color.rgb(148, 163, 184) : color.rgb(86, 103, 130)

f_panel_label(string themeName) =>
    themeName == "Light" ? color.rgb(71, 85, 105) : color.rgb(190, 202, 220)

f_panel_value(string themeName) =>
    themeName == "Light" ? color.rgb(15, 23, 42) : color.rgb(245, 247, 250)

f_row_bg(string themeName, int row) =>
    bool evenRow = row % 2 == 0
    if themeName == "Light"
        evenRow ? color.rgb(226, 232, 240) : color.rgb(241, 245, 249)
    else
        evenRow ? color.rgb(29, 49, 82) : color.rgb(6, 12, 24)

f_panel_state_color(color sourceColor, string themeName) =>
    themeName == "Light" ? sourceColor : sourceColor == panelValueCol ? color.rgb(245, 247, 250) : sourceColor == panelBorder ? color.rgb(190, 202, 220) : sourceColor

f_set_row(table panelRef, int row, string leftText, string rightText, color rightColor, string themeName, string sizeName) =>
    color rowBg = f_row_bg(themeName, row)
    table.cell(panelRef, 0, row, leftText, text_color = f_panel_label(themeName), bgcolor = rowBg, text_size = f_size(sizeName), text_halign = text.align_left)
    table.cell(panelRef, 1, row, rightText, text_color = f_panel_state_color(rightColor, themeName), bgcolor = rowBg, text_size = f_size(sizeName), text_halign = text.align_right)

f_keep_label(array<label> labelArray, label newLabel, int limit) =>
    array.push(labelArray, newLabel)
    if array.size(labelArray) > limit
        label oldLabel = array.shift(labelArray)
        label.delete(oldLabel)

// --------------------------------------------------
// Participation Shock Engine
// --------------------------------------------------
labelSize = f_size(labelSizeInput)
panelSize = f_size(panelFontSizeInput)
float atr = ta.atr(atrLen)
float safeAtr = math.max(nz(atr, ta.tr(true)), syminfo.mintick)
float volBase = ta.sma(nz(volume, 0.0), volumeLen)
float relVol = not na(volBase) and volBase > 0.0 ? volume / volBase : 1.0

float barRange = math.max(high - low, syminfo.mintick)
float body = math.abs(close - open)
float bodyPct = body / barRange * 100.0
float rangeAtr = barRange / safeAtr
float closePos = f_clamp((close - low) / barRange * 100.0, 0.0, 100.0)

bool bullCommit = close > open and closePos >= 58.0
bool bearCommit = close < open and closePos <= 42.0
float rangeScore = f_clamp(rangeAtr / minRangeAtr * 100.0, 0.0, 140.0)
float volumeScore = f_clamp(relVol / shockRelVol * 100.0, 0.0, 160.0)
float bodyScore = f_clamp(bodyPct / minBodyPct * 100.0, 0.0, 150.0)
float locationScore = bullCommit ? closePos : bearCommit ? 100.0 - closePos : 50.0
float participationRaw = f_clamp(volumeScore * 0.38 + bodyScore * 0.27 + rangeScore * 0.22 + locationScore * 0.13, 0.0, 100.0)
float participationScore = ta.ema(participationRaw, scoreSmoothing)

bool bullShock = barstate.isconfirmed and bullCommit and relVol >= shockRelVol and bodyPct >= minBodyPct and rangeAtr >= minRangeAtr and participationRaw >= shockScoreThreshold
bool bearShock = barstate.isconfirmed and bearCommit and relVol >= shockRelVol and bodyPct >= minBodyPct and rangeAtr >= minRangeAtr and participationRaw >= shockScoreThreshold
bool shockEvent = bullShock or bearShock

var float shockHigh = na
var float shockLow = na
var float shockMid = na
var float shockQ = na
var int shockDir = 0
var int shockBar = na
var bool followMemory = false
var bool absorptionMemory = false
var bool thinMoveMemory = false
var array<label> eventLabels = array.new<label>()

if shockEvent
    shockHigh := high
    shockLow := low
    shockMid := (high + low) * 0.5
    shockQ := participationRaw
    shockDir := bullShock ? 1 : -1
    shockBar := bar_index
    followMemory := false
    absorptionMemory := false
    thinMoveMemory := false

bool hasActiveShock = not na(shockBar) and not na(shockHigh) and not na(shockLow) and shockHigh > shockLow
int barsFromShock = hasActiveShock ? bar_index - shockBar : 0
bool withinFollowWindow = hasActiveShock and barsFromShock > 0 and barsFromShock <= followWindowBars
float shockRange = hasActiveShock ? math.max(shockHigh - shockLow, syminfo.mintick) : na
float shockAgeScore = hasActiveShock ? f_clamp(100.0 - barsFromShock / followWindowBars * 45.0, 40.0, 100.0) : na

bool bullFollow = withinFollowWindow and shockDir == 1 and close > shockHigh + safeAtr * followCloseAtr and relVol >= followRelVol and not followMemory
bool bearFollow = withinFollowWindow and shockDir == -1 and close < shockLow - safeAtr * followCloseAtr and relVol >= followRelVol and not followMemory
bool realFlowEvent = barstate.isconfirmed and (bullFollow or bearFollow)

bool bullAbsorption = withinFollowWindow and shockDir == 1 and close < shockLow + shockRange * (absorptionMidPct / 100.0) and close < open and not absorptionMemory
bool bearAbsorption = withinFollowWindow and shockDir == -1 and close > shockHigh - shockRange * (absorptionMidPct / 100.0) and close > open and not absorptionMemory
bool absorptionEvent = barstate.isconfirmed and (bullAbsorption or bearAbsorption)

bool bullThinMove = withinFollowWindow and shockDir == 1 and high > shockHigh and close > shockHigh and relVol <= thinMoveRelVol and not followMemory and not thinMoveMemory
bool bearThinMove = withinFollowWindow and shockDir == -1 and low < shockLow and close < shockLow and relVol <= thinMoveRelVol and not followMemory and not thinMoveMemory
bool thinMoveEvent = barstate.isconfirmed and (bullThinMove or bearThinMove) and eventLabelMode == "Detailed"

if realFlowEvent
    followMemory := true

if absorptionEvent
    absorptionMemory := true

if thinMoveEvent
    thinMoveMemory := true

float followQ = realFlowEvent ? f_clamp((shockQ + participationRaw + shockAgeScore) / 3.0, 0.0, 100.0) : na
float absorptionQ = absorptionEvent ? f_clamp(shockQ * 0.45 + (100.0 - participationRaw) * 0.20 + shockAgeScore * 0.35, 0.0, 100.0) : na
float thinQ = thinMoveEvent ? f_clamp(shockQ * 0.50 + (100.0 - relVol / followRelVol * 100.0) * 0.50, 0.0, 100.0) : na

string stateText = absorptionMemory ? (shockDir == 1 ? "Bull Shock Absorbed" : "Bear Shock Absorbed") : followMemory ? (shockDir == 1 ? "Real Flow Up" : "Real Flow Down") : hasActiveShock and withinFollowWindow ? "Shock Watch" : shockEvent ? (bullShock ? "Bull Shock" : "Bear Shock") : participationScore >= 62 ? "Participation Rising" : "Quiet Flow"
color stateColor = absorptionMemory ? neutralColor : followMemory ? (shockDir == 1 ? bullColor : bearColor) : shockDir == 1 ? bullColor : shockDir == -1 ? bearColor : participationScore >= 62 ? accentColor : panelValueCol
string shockTypeText = shockDir == 1 ? "Bull volume shock" : shockDir == -1 ? "Bear volume shock" : "No active shock"
string followText = followMemory ? "Confirmed" : withinFollowWindow ? "Watching" : "No active window"
string absorptionText = absorptionMemory ? "Active risk" : withinFollowWindow ? "Not confirmed" : "No active window"
string nextContext = absorptionMemory ? "Check failed participation" : followMemory ? "Monitor continuation" : withinFollowWindow ? "Wait follow-through" : participationScore >= 62 ? "Watch next shock" : "Wait for participation"
string ageText = hasActiveShock ? str.tostring(barsFromShock) + " bars" : "No active shock"

// --------------------------------------------------
// Confirmation-anchored proof (volume shocks: Follow = 1R continuation before absorption back through the midline)
// --------------------------------------------------
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

int proofWarmup = math.max(volumeLen, atrLen) + 10
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
        if naturalResolve or shockEvent
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
    if shockEvent and not pEvalActive and shockDir != 0
        float pRisk = math.max(math.abs(close - shockMid), safeAtr * 0.25)
        pEvalActive := true
        pEvalDir := shockDir
        pEvalEntry := close
        pEvalStop := shockMid
        pEvalTarget := close + shockDir * pRisk
        pEvalStart := bar_index
        pReacted := false
        pFollowed := false
        pFlipped := false

float followRate = proofTotal > 0 ? proofFollow * 100.0 / proofTotal : 0.0
float holdRate = proofTotal > 0 ? proofHold * 100.0 / proofTotal : 0.0
float reactRate = proofTotal > 0 ? proofReact * 100.0 / proofTotal : 0.0
float flipRate = proofTotal > 0 ? proofFlip * 100.0 / proofTotal : 0.0
string proofSampleText = proofTotal > 0 ? "n = " + str.tostring(proofTotal) : "building"

// --------------------------------------------------
// Visual Structure
// --------------------------------------------------
var box shockBox = na
var line shockRail = na
var label zoneLabel = na
var label highTag = na
var label lowTag = na
var label stateTag = na

int adaptiveProjectionBars = adaptiveProjection ? timeframe.ismonthly ? math.min(projectionBars, 8) : timeframe.isweekly ? math.min(projectionBars, 26) : timeframe.isdaily ? math.min(projectionBars, 55) : projectionBars : projectionBars
int visualLeft = hasActiveShock ? shockBar : bar_index
int visualRight = hasActiveShock ? bar_index + adaptiveProjectionBars : bar_index + adaptiveProjectionBars
int centerX = hasActiveShock ? int(math.round((visualLeft + visualRight) * 0.5)) : bar_index
color zoneColor = shockDir == 1 ? bullColor : bearColor

if barstate.islast and hasActiveShock and showShockZone
    if na(shockBox)
        shockBox := box.new(visualLeft, shockHigh, visualRight, shockLow, xloc = xloc.bar_index, bgcolor = color.new(zoneColor, 88), border_color = color.new(zoneColor, 35), border_width = 1)
    else
        box.set_lefttop(shockBox, visualLeft, shockHigh)
        box.set_rightbottom(shockBox, visualRight, shockLow)
        box.set_bgcolor(shockBox, color.new(zoneColor, 88))
        box.set_border_color(shockBox, color.new(zoneColor, 35))
    string zoneText = "Participation Shock\nScore " + f_score_text(shockQ)
    if na(zoneLabel)
        zoneLabel := label.new(centerX, shockMid, zoneText, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_center, textcolor = f_text_on(zoneColor), color = color.new(zoneColor, 0), size = labelSize, textalign = text.align_center)
    else
        label.set_x(zoneLabel, centerX)
        label.set_y(zoneLabel, shockMid)
        label.set_text(zoneLabel, zoneText)
        label.set_color(zoneLabel, color.new(zoneColor, 0))
        label.set_textcolor(zoneLabel, f_text_on(zoneColor))
        label.set_size(zoneLabel, labelSize)

if barstate.islast and (not showShockZone or not hasActiveShock)
    if not na(shockBox)
        box.delete(shockBox)
        shockBox := na
    if not na(zoneLabel)
        label.delete(zoneLabel)
        zoneLabel := na

if barstate.islast and hasActiveShock and showParticipationRail
    if na(shockRail)
        shockRail := line.new(visualLeft, shockMid, visualRight, shockMid, xloc = xloc.bar_index, color = color.new(accentColor, 10), width = 2, style = line.style_dotted)
    else
        line.set_xy1(shockRail, visualLeft, shockMid)
        line.set_xy2(shockRail, visualRight, shockMid)
        line.set_color(shockRail, color.new(accentColor, 10))
        line.set_width(shockRail, 2)
        line.set_style(shockRail, line.style_dotted)

if barstate.islast and (not showParticipationRail or not hasActiveShock)
    if not na(shockRail)
        line.delete(shockRail)
        shockRail := na

// --------------------------------------------------
// Labels and Right Tags
// --------------------------------------------------
bool eventCandidate = shockEvent or realFlowEvent or absorptionEvent or thinMoveEvent
var int lastEventBar = na
bool canPrintEvent = na(lastEventBar) or bar_index - lastEventBar >= labelCooldownBars
bool eventIsBearSide = bearShock or bearFollow or bullAbsorption or bearThinMove
float eventY = eventIsBearSide ? high + safeAtr * eventLabelOffsetAtr : low - safeAtr * eventLabelOffsetAtr
eventStyle = eventIsBearSide ? label.style_label_down : label.style_label_up
string eventText = shockEvent ? (bullShock ? "Bull Volume Shock\nScore " + f_score_text(participationRaw) : "Bear Volume Shock\nScore " + f_score_text(participationRaw)) : realFlowEvent ? "Real Flow\nScore " + f_score_text(followQ) : absorptionEvent ? "Absorption Risk\nScore " + f_score_text(absorptionQ) : "Thin Move\nScore " + f_score_text(thinQ)
color eventCol = shockEvent ? (bullShock ? bullColor : bearColor) : realFlowEvent ? (shockDir == 1 ? bullColor : bearColor) : absorptionEvent ? neutralColor : accentColor

if showEventLabels and eventCandidate and canPrintEvent
    label newLabel = label.new(bar_index, eventY, eventText, xloc = xloc.bar_index, yloc = yloc.price, style = eventStyle, textcolor = f_text_on(eventCol), color = color.new(eventCol, 4), size = labelSize, textalign = text.align_center)
    f_keep_label(eventLabels, newLabel, maxVisibleLabels)
    lastEventBar := bar_index

if barstate.islast and hasActiveShock and showRightTags
    if not na(highTag)
        label.delete(highTag)
    if not na(lowTag)
        label.delete(lowTag)
    if not na(stateTag)
        label.delete(stateTag)
    bool compactZone = shockRange <= safeAtr * 0.75
    float rightTagGap = math.max(syminfo.mintick * 20.0, math.min(safeAtr * 0.28, shockRange * 0.22))
    float highTagY = compactZone ? shockHigh + rightTagGap : shockHigh
    float lowTagY = compactZone ? shockLow - rightTagGap : shockLow
    float stateTagYRaw = math.abs(close - shockHigh) <= shockRange * 0.18 or math.abs(close - shockLow) <= shockRange * 0.18 ? shockMid : close
    float stateTagY = compactZone ? shockMid : stateTagYRaw
    int tagX = bar_index + adaptiveProjectionBars
    highTag := label.new(tagX, highTagY, "Shock High", xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, textcolor = f_text_on(bearColor), color = color.new(bearColor, 0), size = labelSize)
    lowTag := label.new(tagX, lowTagY, "Shock Low", xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, textcolor = f_text_on(bullColor), color = color.new(bullColor, 0), size = labelSize)
    stateTag := label.new(tagX, stateTagY, "Score " + f_score_text(participationScore), xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, textcolor = f_text_on(stateColor), color = color.new(stateColor, 0), size = labelSize)

if barstate.islast and (not showRightTags or not hasActiveShock)
    if not na(highTag)
        label.delete(highTag)
        highTag := na
    if not na(lowTag)
        label.delete(lowTag)
        lowTag := na
    if not na(stateTag)
        label.delete(stateTag)
        stateTag := na

// --------------------------------------------------
// Panel
// --------------------------------------------------
var table panel = na
var string panelPosMemory = ""
var string panelThemeMemory = ""
var bool panelProofMemory = false
int panelRowCount = showProof ? 13 : 8

if showPanel and (na(panel) or panelPosMemory != panelPositionInput or panelThemeMemory != panelTheme or panelProofMemory != showProof)
    if not na(panel)
        table.delete(panel)
    panel := table.new(f_panel_pos(panelPositionInput), 2, panelRowCount, bgcolor = f_panel_bg(panelTheme), frame_color = f_panel_border(panelTheme), frame_width = 1, border_color = f_panel_border(panelTheme), border_width = 1)
    panelPosMemory := panelPositionInput
    panelThemeMemory := panelTheme
    panelProofMemory := showProof

if showPanel and not na(panel) and barstate.islast
    table.clear(panel, 0, 0, 1, panelRowCount - 1)
    table.merge_cells(panel, 0, 0, 1, 0)
    table.cell(panel, 0, 0, "AG Pro Volume Participation Shock Map", text_color = headerText, bgcolor = headerBg, text_size = panelSize, text_halign = text.align_center)
    f_set_row(panel, 1, "Participation State", stateText, stateColor, panelTheme, panelFontSizeInput)
    f_set_row(panel, 2, "Quality Score", f_score_text(participationScore) + " / 100", stateColor, panelTheme, panelFontSizeInput)
    f_set_row(panel, 3, "Shock Type", shockTypeText, panelValueCol, panelTheme, panelFontSizeInput)
    f_set_row(panel, 4, "RelVol / Body", str.tostring(relVol, "#.##") + " / " + f_score_text(bodyPct) + "%", panelValueCol, panelTheme, panelFontSizeInput)
    f_set_row(panel, 5, "Follow-Through", followText + " / " + ageText, followMemory ? stateColor : panelValueCol, panelTheme, panelFontSizeInput)
    f_set_row(panel, 6, "Absorption Risk", absorptionText, absorptionMemory ? neutralColor : panelValueCol, panelTheme, panelFontSizeInput)
    f_set_row(panel, 7, "Action", nextContext, stateColor, panelTheme, panelFontSizeInput)
    if showProof
        color proofHeadBg = f_row_bg(panelTheme, 8)
        table.cell(panel, 0, 8, "Proof @ Confirm", text_color = accentColor, bgcolor = proofHeadBg, text_size = panelSize, text_halign = text.align_left)
        table.cell(panel, 1, 8, proofSampleText, text_color = f_panel_label(panelTheme), bgcolor = proofHeadBg, text_size = panelSize, text_halign = text.align_right)
        f_set_row(panel, 9, "Follow Rate", proofTotal > 0 ? f_rate_pct(followRate) : "-", proofTotal > 0 ? f_rate_color(followRate) : panelValueCol, panelTheme, panelFontSizeInput)
        f_set_row(panel, 10, "Hold Rate", proofTotal > 0 ? f_rate_pct(holdRate) : "-", proofTotal > 0 ? f_rate_color(holdRate) : panelValueCol, panelTheme, panelFontSizeInput)
        f_set_row(panel, 11, "React Rate", proofTotal > 0 ? f_rate_pct(reactRate) : "-", proofTotal > 0 ? f_rate_color(reactRate) : panelValueCol, panelTheme, panelFontSizeInput)
        f_set_row(panel, 12, "Flip Rate", proofTotal > 0 ? f_rate_pct(flipRate) : "-", proofTotal > 0 ? f_flip_color(flipRate) : panelValueCol, panelTheme, panelFontSizeInput)

if not showPanel and not na(panel)
    table.delete(panel)
    panel := na
    panelPosMemory := ""
    panelThemeMemory := ""

// --------------------------------------------------
// Alerts
// --------------------------------------------------
bool shockAlertEvent = barstate.isconfirmed and shockEvent
bool realFlowAlertEvent = barstate.isconfirmed and realFlowEvent
bool absorptionAlertEvent = barstate.isconfirmed and absorptionEvent
bool thinMoveAlertEvent = barstate.isconfirmed and thinMoveEvent

alertcondition(alertShock and shockAlertEvent, "Volume Participation Shock", "Volume Participation Shock Map: a high-quality volume participation shock appeared.")
alertcondition(alertRealFlow and realFlowAlertEvent, "Real-Flow Continuation", "Volume Participation Shock Map: price followed through beyond the active shock zone with acceptable participation.")
alertcondition(alertAbsorption and absorptionAlertEvent, "Absorption Risk", "Volume Participation Shock Map: price closed back through the active shock zone after a qualified volume shock.")
alertcondition(alertThinMove and thinMoveAlertEvent, "Thin Move", "Volume Participation Shock Map: price moved beyond the active shock edge without enough relative volume.")

// --------------------------------------------------
// Hidden Exports
// --------------------------------------------------
plot(participationScore, "VPS Participation Score", display = display.none)
plot(followRate, "VPS Follow Rate", display = display.none)
plot(holdRate, "VPS Hold Rate", display = display.none)
plot(reactRate, "VPS React Rate", display = display.none)
plot(flipRate, "VPS Flip Rate", display = display.none)
````
