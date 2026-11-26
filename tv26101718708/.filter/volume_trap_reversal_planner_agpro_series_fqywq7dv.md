# Volume Trap Reversal Planner [AGPro Series]

- url: https://www.tradingview.com/script/fQYwq7dv-Volume-Trap-Reversal-Planner-AGPro-Series/
- type: indicator
- pine_id: PUB;58e538a9f5b841ff93a148c1d30868c9
- version: 4.0

## Description

Volume Trap Reversal Planner [AGPro Series]

🧠 Core Idea

Did a volume spike trap one side of the market and reverse with enough confirmation to deserve attention?


📌 Overview / What it does

Volume Trap Reversal Planner [AGPro Series] is a chart-first reversal planning tool built around high-volume trap behavior.

Instead of treating every volume spike or wick sweep as a reversal signal, the script checks whether price expands through a recent reference, prints unusual relative volume, fails to hold the move, recovers back through the reference, and then confirms with a follow-through candle.

The output includes volume trap pockets, reclaim rails, risk edges, target-room bands, compact event labels, alerts, and a clean AGPro decision panel. It does not predict price, automate trades, or claim that every trap will reverse.


🎯 Purpose & Design Philosophy

The script was built for traders who want to separate meaningful high-volume trap events from ordinary noisy spikes.

Many reversal tools focus only on a wick, a candle pattern, or a support/resistance touch. This planner focuses on the decision layer after a volume trap forms: whether the trap is confirmed, where the risk edge sits, where target-room review begins, and what the next action state should be.

The design supports a structured review mindset: identify the trap, wait for confirmation, monitor the risk edge, and read the context through a 0-100 score instead of reacting to a single candle.


⚡ Why This Script Is Different

Most tools focus on volume spikes as standalone events or classify every sweep as a reversal attempt.

This script does NOT operate as a generic stop-run scanner, a broad liquidity sweep map, or a simple volume climax labeler.

Instead, it combines relative volume, wick sweep behavior, close recovery, confirmation candle quality, follow-through, risk edge placement, and target-room context into one planner-style reversal model.


⚙️ Methodology

1. Context Detection

The script builds a rolling high/low reference range and watches for unusual volume expansion near those references.

2. Trap Mapping

When price sweeps beyond the reference with elevated volume and recovers back inside, the script maps the volume trap pocket.

3. Reversal Evaluation

The planner evaluates wick quality, recovery strength, confirmation candle structure, follow-through distance, and the active risk edge.

4. Visual Output

The result is translated into a 0-100 reversal score, a next-action state, on-chart labels, risk/target guides, and a compact AGPro panel.


🗺️ How to Read the Chart

Zones = volume trap pockets created by a high-volume sweep and recovery.

Labels = trap watch, reversal ready, trap failed, or target review states.

Colors = bull-side reversals use teal, bear-side reversals use pink, watch states use amber, and review/target context uses indigo.

Panel = current trap side, volume spike multiple, reversal score, risk edge, and next action.


🚦 Signals & States

• VOL TRAP WATCH → a high-volume trap candidate formed and needs confirmation.

• REVERSAL READY → the trap received confirmation and reached the required score.

• TRAP FAILED → price closed beyond the risk edge and the active trap context weakened.

• TARGET REVIEW → price reached the target-room review band for the active plan.


🔔 Alerts Logic

Alerts trigger when a volume trap watch appears, when reversal confirmation reaches the required score, when the active trap fails through the risk edge, or when price reaches the target-room review band.

Alerts are attention markers only. They are not trade instructions.


🧩 Confluence Logic

The context becomes stronger when volume spike quality, wick sweep behavior, close recovery, confirmation candle structure, and follow-through align in the same direction.

The score is intentionally multi-factor so a single dramatic candle does not dominate the interpretation.


📊 When to Use

• 4H charts for the cleanest public visual balance

• Markets with reliable volume data

• High-volume reactions around recent highs or lows

• Reversal review after failed breakout or failed breakdown attempts

• Active intraday or swing charts where trap behavior is visible


⚠️ When NOT to Use

• Very low-liquidity symbols

• Markets with unreliable or missing volume data

• Extremely noisy ranges where every candle sweeps both sides

• News-driven volatility where candle structure can distort normal context


🎛️ Key Inputs

• Trap Reference Lookback → controls the rolling high/low range used for trap detection.

• Volume Spike RVOL → adjusts how much relative volume is required.

• Sensitivity → changes sweep, wick, and volume selectivity.

• Confirmation Mode → controls how strict the confirmation candle must be.

• Risk / Target Logic → controls risk edge buffers and target-room bands.

• Visual Settings → control zones, rails, labels, panel location, theme, and font sizes.


🖥️ Interface & Visual Design

The interface is built around a clean AGPro panel and chart-first visual hierarchy.

Trap pockets show where the volume trap occurred. Labels identify the current state without overcrowding the chart. Risk and target guides make the output easier to interpret as a planning tool rather than a raw signal board.


🧪 Practical Usage Workflow

1. Read the panel and check the active trap side.

2. Inspect the volume trap pocket and reclaim rail.

3. Wait for reversal confirmation instead of reacting to the spike alone.

4. Compare the current state with the risk edge and target-room band.

5. Interpret the score within broader market context.


🔍 Interpretation Guidelines

A high score means the trap structure, volume spike, recovery, and confirmation are aligned more cleanly.

A watch state means the event is still developing.

A failed state means the active trap context has weakened or invalidated according to the script's rules.

Use the output as structured context, not as a standalone decision.


🚫 What This Script Is NOT

• Not a prediction engine

• Not financial advice

• Not an auto-trading system

• Not a guaranteed reversal signal

• Not a generic liquidity sweep scanner


⚠️ Limitations & Transparency

Volume quality varies by symbol, exchange, and asset class.

Different timeframes may produce different trap pockets and confirmation states.

High volatility can make traps appear and fail quickly.

The script is rule-based and cannot know news, order flow intent, execution quality, or broader discretionary context.


🧠 Market Context Notes

Volume traps often matter most when they occur at obvious participation points, such as recent highs, recent lows, failed breakouts, or failed breakdowns.

The strongest use case is not the spike itself. The strongest use case is the sequence after the spike: recovery, confirmation, risk edge, and follow-through.


🧾 Use Case Examples

When price sweeps below a recent low on elevated volume, closes back above the reference, and confirms upward within the allowed window, the planner can mark a bullish reversal context.

When price sweeps above a recent high on elevated volume, fails to hold, and confirms downward, the planner can mark a bearish reversal context.


🧱 System Philosophy

Volume Trap Reversal Planner belongs to the AGPro planner-style workflow: detect the event, score the evidence, define the risk edge, map the review zone, and guide the next chart-reading step.


🔐 Non-Promise Statement

No trap, score, label, or alert can guarantee a reversal.

No script can provide certainty.


📉 Risk Disclosure

Trading involves risk.

Users are responsible for their own decisions, risk management, and market interpretation.

This script is for educational and analytical purposes only and does not provide financial advice.


📚 Educational Note

Use the script to study how high-volume failed moves behave after sweeping recent references. The most useful insights come from comparing confirmed traps, failed traps, and ignored spikes across different markets and timeframes.

## Source Code

````pine
// -------------------------------------------------
// Volume Trap Reversal Planner [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 1.3
//
// Volume Trap Reversal Planner is a chart-first volume trap decision engine.
// It studies high-volume sweep attempts, wick recovery, close location,
// confirmation candles, follow-through, risk edges, and target-room context
// to convert a possible volume trap into a structured 0-100 reversal score.
// This release preserves the original planner identity while tightening label
// anchoring and terminal-state object lifecycle management.
// -------------------------------------------------

//@version=6
indicator("Volume Trap Reversal Planner [AGPro Series]",
     shorttitle = "AG Pro VTR",
     overlay = true,
     max_boxes_count = 80,
     max_labels_count = 220,
     max_lines_count = 160)

// -------------------------------------------------
// AGPro Color Palette
// -------------------------------------------------
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

// -------------------------------------------------
// Tooltips
// -------------------------------------------------
string ttSide = "Selects which volume trap direction the planner can evaluate. Auto allows both downside traps that can reverse upward and upside traps that can reverse downward."
string ttConfirmClose = "When enabled, trap events, confirmation labels, and alerts wait for bar close. This keeps public chart behavior stable."
string ttLookback = "Defines the rolling high and low references used to detect high-volume trap attempts. The current candle is excluded from the reference range."
string ttAtr = "ATR length used for trap depth, pocket height, risk edges, target bands, and label spacing."
string ttVolume = "Volume baseline used for relative volume spike scoring. On markets with weak volume data, this component naturally becomes less decisive."
string ttSensitivity = "Controls how selective the trap detection should be. Conservative requires a cleaner volume spike, wick sweep, and recovery."
string ttConfirmMode = "Controls how strict the reversal confirmation candle must be after the trap. Strict requires stronger close location and body efficiency."
string ttWindow = "Number of bars after the volume trap where reversal confirmation can still qualify. After this window, the event becomes stale."
string ttMinScore = "Minimum 0-100 reversal score required before a confirmed reversal plan is treated as ready."
string ttWatchScore = "Minimum 0-100 trap score required before watch labels and early review states can appear."
string ttSpike = "Relative volume level required for the initial trap event. The final threshold is adjusted by sensitivity."
string ttFullSpike = "Relative volume level that receives the full volume component in the 0-100 score model."
string ttSweep = "ATR buffer beyond the reference high or low required before a trap attempt is considered meaningful."
string ttRecovery = "ATR buffer back inside the reference required for same-candle recovery. Higher values make trap detection stricter."
string ttRisk = "ATR buffer placed beyond the trap extreme to define the risk edge. It is a planning reference, not a stop recommendation."
string ttTarget = "ATR fallback target-room distance used when the opposite reference side is too close for a useful guide."
string ttTargetBand = "Shows a forward target-room band for confirmed reversal plans. The band is a planning guide, not a price forecast."
string ttPocket = "Shows the volume trap pocket between the swept reference and the trap extreme. Pocket labels are centered as contrast-safe badges."
string ttRails = "Shows the reclaim rail, risk edge, and target guide for qualified trap events."
string ttZoneOpacity = "Transparency of trap pockets and target bands. Higher values make the visual lighter."
string ttForward = "Number of bars projected to the right for trap pockets, rails, and target bands."
string ttLabels = "Shows compact trap, reversal, invalidation, and review labels with controlled spacing."
string ttWatchLabels = "Shows sparse volume-spike watch labels when volume expands near a reference but recovery is not confirmed yet."
string ttLabelMode = "Compact keeps public screenshots clean. Detailed adds score, volume, and action context directly to labels."
string ttLabelScore = "Adds the 0-100 score to chart labels. The default keeps the view balanced while still informative."
string ttCooldown = "Minimum bars between event labels. Higher values reduce repeated labels in fast markets."
string ttMaxObjects = "Caps retained historical event labels. Active pockets, rails, and target bands remain single-instance objects for a clean and efficient chart."
string ttOffset = "ATR-based base offset that keeps event labels away from candle bodies. The anti-collision fan is bounded so labels remain visually connected to their event candles."
string ttLabelSize = "Controls all chart labels and centered zone badges. Normal is the recommended publication default."
string ttTint = "Applies a subtle candle tint while a volume trap or confirmed reversal plan is active."
string ttShowPanel = "Shows or hides the AG Pro planning panel. The default is visible for public-release clarity."
string ttPanelLocation = "Moves the AG Pro planning panel to the preferred chart location."
string ttPanelTheme = "Switches the panel between AGPro dark and clean light themes while preserving the merged blue header row."
string ttPanelFont = "Controls panel text size. Normal is the recommended publication default."
string ttPanelReset = "Number of bars after a failed, expired, or target-review event before its panel context and remaining active furniture are cleared. The timer starts when the terminal event occurs, not when the trap first formed."

// -------------------------------------------------
// Inputs
// -------------------------------------------------
string groupEngine = "Volume Trap Engine"
string sideMode = input.string("Auto", "Planner Side", options = ["Auto", "Bull Reversal Only", "Bear Reversal Only"], group = groupEngine, tooltip = ttSide)
bool confirmOnClose = input.bool(true, "Confirm On Bar Close", group = groupEngine, tooltip = ttConfirmClose)
int trapLookback = input.int(34, "Trap Reference Lookback", minval = 10, maxval = 220, group = groupEngine, tooltip = ttLookback)
int atrLength = input.int(14, "ATR Length", minval = 5, maxval = 100, group = groupEngine, tooltip = ttAtr)
int volumeLength = input.int(34, "Volume Baseline Length", minval = 5, maxval = 200, group = groupEngine, tooltip = ttVolume)
string sensitivity = input.string("Balanced", "Sensitivity", options = ["Aggressive", "Balanced", "Conservative"], group = groupEngine, tooltip = ttSensitivity)
string confirmationMode = input.string("Balanced", "Confirmation Mode", options = ["Fast", "Balanced", "Strict"], group = groupEngine, tooltip = ttConfirmMode)
int confirmationWindowBars = input.int(5, "Confirmation Window Bars", minval = 1, maxval = 20, group = groupEngine, tooltip = ttWindow)

string groupScore = "Readiness Score"
int minReversalScore = input.int(66, "Minimum Reversal Score", minval = 40, maxval = 95, group = groupScore, tooltip = ttMinScore)
int watchScore = input.int(52, "Trap Watch Score", minval = 20, maxval = 90, group = groupScore, tooltip = ttWatchScore)
float spikeRvol = input.float(1.55, "Volume Spike RVOL", minval = 0.70, maxval = 6.00, step = 0.05, group = groupScore, tooltip = ttSpike)
float fullSpikeRvol = input.float(2.60, "Full Volume Score RVOL", minval = 1.20, maxval = 8.00, step = 0.10, group = groupScore, tooltip = ttFullSpike)
int proofWindowBars = input.int(30, "Proof Window Bars", minval = 5, maxval = 120, group = groupScore, tooltip = "Number of bars a confirmed reversal is tracked to see whether price reaches the proof target before the risk edge. Plans that resolve neither way inside the window time out and stay uncounted.")
float proofReward = input.float(1.0, "Proof Target (R)", minval = 0.5, maxval = 4.0, step = 0.1, group = groupScore, tooltip = "Reward-to-risk multiple used by the follow-through proof. The proof asks whether a confirmed reversal travels this many risk units in its favor before reaching the risk edge. This is a balanced follow-through test and is independent of the wider planning target room.")

string groupRisk = "Risk / Target Logic"
float sweepBufferAtr = input.float(0.08, "Sweep Buffer ATR", minval = 0.00, maxval = 1.50, step = 0.01, group = groupRisk, tooltip = ttSweep)
float recoveryBufferAtr = input.float(0.02, "Recovery Buffer ATR", minval = 0.00, maxval = 1.50, step = 0.01, group = groupRisk, tooltip = ttRecovery)
float riskBufferAtr = input.float(0.18, "Risk Edge Buffer ATR", minval = 0.00, maxval = 2.50, step = 0.01, group = groupRisk, tooltip = ttRisk)
float targetFallbackAtr = input.float(1.80, "Target Room ATR Fallback", minval = 0.40, maxval = 6.00, step = 0.05, group = groupRisk, tooltip = ttTarget)
float targetBandAtr = input.float(0.24, "Target Band Thickness ATR", minval = 0.05, maxval = 1.50, step = 0.01, group = groupRisk, tooltip = ttTargetBand)

string groupVisual = "Chart Visuals"
bool showTrapPockets = input.bool(true, "Show Volume Trap Pockets", group = groupVisual, tooltip = ttPocket)
bool showGuideRails = input.bool(true, "Show Reclaim / Risk Rails", group = groupVisual, tooltip = ttRails)
bool showTargetBands = input.bool(true, "Show Reversal Target Band", group = groupVisual, tooltip = ttTargetBand)
int zoneTransparency = input.int(87, "Zone Transparency", minval = 70, maxval = 96, group = groupVisual, tooltip = ttZoneOpacity)
int forwardBars = input.int(34, "Forward Render Bars", minval = 8, maxval = 160, group = groupVisual, tooltip = ttForward)
bool tintActiveCandles = input.bool(true, "Tint Active Trap Candles", group = groupVisual, tooltip = ttTint)

string groupLabels = "Labels"
bool showEventLabels = input.bool(true, "Show Event Labels", group = groupLabels, tooltip = ttLabels)
bool showWatchLabels = input.bool(true, "Show Volume Watch Labels", group = groupLabels, tooltip = ttWatchLabels)
string labelTextMode = input.string("Compact", "Label Text Mode", options = ["Compact", "Detailed"], group = groupLabels, tooltip = ttLabelMode)
bool showLabelScore = input.bool(true, "Show Label Score", group = groupLabels, tooltip = ttLabelScore)
int labelCooldownBars = input.int(12, "Label Cooldown Bars", minval = 1, maxval = 80, group = groupLabels, tooltip = ttCooldown)
int maxVisibleObjects = input.int(12, "Max Visible Object Sets", minval = 4, maxval = 34, group = groupLabels, tooltip = ttMaxObjects)
float labelOffsetAtr = input.float(0.90, "Label Offset ATR", minval = 0.10, maxval = 4.00, step = 0.05, group = groupLabels, tooltip = ttOffset)
string labelFontSize = input.string("Normal", "Label Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = groupLabels, tooltip = ttLabelSize)

string groupPanel = "Panel"
bool showPanel = input.bool(true, "Show Panel", group = groupPanel, tooltip = ttShowPanel)
string panelLocation = input.string("Top Right", "Panel Location", options = ["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], group = groupPanel, tooltip = ttPanelLocation)
string panelTheme = input.string("Elite Dark", "Panel Theme", options = ["Elite Dark", "Clean Light"], group = groupPanel, tooltip = ttPanelTheme)
string panelFontSize = input.string("Normal", "Panel Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = groupPanel, tooltip = ttPanelFont)
int panelResetBars = input.int(18, "Panel Reset After Terminal Bars", minval = 3, maxval = 120, group = groupPanel, tooltip = ttPanelReset)

// -------------------------------------------------
// Helpers
// -------------------------------------------------
f_clamp(float value, float minValue, float maxValue) =>
    math.min(math.max(value, minValue), maxValue)

f_norm_high(float value, float weak, float strong) =>
    float span = strong - weak
    span == 0.0 ? 0.0 : f_clamp((value - weak) / span * 100.0, 0.0, 100.0)

// Luminance-145 contrast ink. Bright fills receive dark ink, dark fills receive
// the light header ink, so every on-chart badge and filled panel cell stays legible.
f_text_on(color fill) =>
    float brightness = 0.299 * color.r(fill) + 0.587 * color.g(fill) + 0.114 * color.b(fill)
    brightness > 145 ? color.rgb(17, 24, 39) : headerText

f_text_size(string sizeText) =>
    switch sizeText
        "Tiny" => size.tiny
        "Small" => size.small
        "Large" => size.large
        => size.normal

f_panel_position(string posText) =>
    switch posText
        "Top Left" => position.top_left
        "Top Center" => position.top_center
        "Top Right" => position.top_right
        "Middle Left" => position.middle_left
        "Middle Center" => position.middle_center
        "Middle Right" => position.middle_right
        "Bottom Left" => position.bottom_left
        "Bottom Center" => position.bottom_center
        => position.bottom_right

f_panel_bg(string themeText) =>
    themeText == "Clean Light" ? color.rgb(248, 250, 252) : panelBg

f_panel_border(string themeText) =>
    themeText == "Clean Light" ? color.rgb(148, 163, 184) : panelBorder

f_panel_label(string themeText) =>
    themeText == "Clean Light" ? color.rgb(71, 85, 105) : panelLabelCol

f_panel_value(string themeText) =>
    themeText == "Clean Light" ? color.rgb(15, 23, 42) : panelValueCol

f_row_bg(string themeText, int row) =>
    bool evenRow = row % 2 == 0
    if themeText == "Clean Light"
        evenRow ? color.rgb(226, 232, 240) : color.rgb(248, 250, 252)
    else
        evenRow ? color.rgb(20, 31, 52) : panelBg

f_panel_row(table target, int row, string labelText, string valueText, color valueColor, string themeText, string sizeText) =>
    color rowBg = f_row_bg(themeText, row)
    table.cell(target, 0, row, labelText, text_color = f_panel_label(themeText), bgcolor = rowBg, text_size = f_text_size(sizeText), text_halign = text.align_left)
    table.cell(target, 1, row, valueText, text_color = valueColor, bgcolor = rowBg, text_size = f_text_size(sizeText), text_halign = text.align_right)

f_fmt_price(float value) =>
    na(value) ? "-" : str.tostring(value, format.mintick)

f_score_text(float value) =>
    na(value) ? "-" : str.tostring(math.round(f_clamp(value, 0.0, 100.0))) + "/100"

f_grade(float score) =>
    string result = "D"
    if score >= 86.0
        result := "A+"
    else if score >= 78.0
        result := "A"
    else if score >= 68.0
        result := "B"
    else if score >= 55.0
        result := "C"
    result

f_score_color(float score) =>
    color result = f_panel_value(panelTheme)
    if score >= minReversalScore
        result := bullColor
    else if score >= watchScore
        result := neutralColor
    else if score >= 35.0
        result := accentColor
    result

f_side_color(int side) =>
    side == 1 ? bullColor : side == -1 ? bearColor : panelValueCol

f_side_text(int side) =>
    side == 1 ? "Downside Trap" : side == -1 ? "Upside Trap" : "None"

f_action_text(string stateText, float score) =>
    string result = "Wait for trap"
    if stateText == "Bull Reversal" or stateText == "Bear Reversal"
        result := score >= minReversalScore ? "Review reversal" : "Confirm quality"
    else if stateText == "Trap Watch"
        result := "Wait confirmation"
    else if stateText == "Trap Failed"
        result := "Reset watch"
    else if stateText == "Expired"
        result := "Reset watch"
    else if stateText == "Target Review"
        result := "Review target room"
    result

f_state_color(string stateText, int side, float score) =>
    color result = f_panel_value(panelTheme)
    if stateText == "Bull Reversal" or stateText == "Bear Reversal"
        result := score >= minReversalScore ? f_side_color(side) : neutralColor
    else if stateText == "Trap Watch"
        result := neutralColor
    else if stateText == "Trap Failed"
        result := dangerColor
    else if stateText == "Expired"
        result := panelLabelCol
    else if stateText == "Target Review"
        result := accentColor
    result

f_trim_labels(array<label> items, int maxCount) =>
    while array.size(items) > maxCount
        label oldItem = array.shift(items)
        label.delete(oldItem)

f_keep_label(array<label> items, label newItem, int maxCount) =>
    array.push(items, newItem)
    f_trim_labels(items, maxCount)

f_keep_box(array<box> items, box newItem, int maxCount) =>
    array.push(items, newItem)
    while array.size(items) > maxCount
        box oldItem = array.shift(items)
        box.delete(oldItem)

f_keep_line(array<line> items, line newItem, int maxCount) =>
    array.push(items, newItem)
    while array.size(items) > maxCount
        line oldItem = array.shift(items)
        line.delete(oldItem)

f_zone_badge(string textValue, int x1, int x2, float topValue, float bottomValue, color badgeColor, string sizeText) =>
    int x = int(math.round((x1 + x2) * 0.5))
    float y = (topValue + bottomValue) * 0.5
    label.new(x, y, textValue, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_center, color = color.new(badgeColor, 0), textcolor = f_text_on(badgeColor), size = f_text_size(sizeText), textalign = text.align_center)

f_base_score(float rvolValue, float wickShareValue, float closeRecoveryValue, float penetrationAtrValue, float effectiveSpikeRvol) =>
    float fullRvolLevel = math.max(fullSpikeRvol, effectiveSpikeRvol + 0.10)
    float volScore = f_norm_high(rvolValue, effectiveSpikeRvol * 0.70, fullRvolLevel) * 0.30
    float wickScore = f_norm_high(wickShareValue, 0.25, 0.70) * 0.22
    float recoveryScore = f_norm_high(closeRecoveryValue, 0.52, 0.88) * 0.24
    float sweepScore = f_norm_high(penetrationAtrValue, sweepBufferAtr, 0.85) * 0.14
    float setupFitScore = rvolValue >= effectiveSpikeRvol ? 10.0 : f_norm_high(rvolValue, 1.0, effectiveSpikeRvol) * 0.10
    f_clamp(volScore + wickScore + recoveryScore + sweepScore + setupFitScore, 0.0, 70.0)

f_confirmation_score(float bodyShareValue, float closeLocationValue, float followAtrValue) =>
    float bodyScore = f_norm_high(bodyShareValue, 0.18, 0.62) * 0.10
    float closeScore = f_norm_high(closeLocationValue, 0.55, 0.90) * 0.12
    float followScore = f_norm_high(followAtrValue, 0.05, 1.25) * 0.08
    f_clamp(bodyScore + closeScore + followScore, 0.0, 30.0)

// -------------------------------------------------
// Core Measurements
// -------------------------------------------------
bool confirmedBar = confirmOnClose ? barstate.isconfirmed : true
float atrRaw = ta.atr(atrLength)
float atr = math.max(nz(atrRaw), ta.tr(true), syminfo.mintick)
float labelOffset = atr * labelOffsetAtr

float upperRefRaw = ta.highest(high[1], trapLookback)
float lowerRefRaw = ta.lowest(low[1], trapLookback)
bool referenceReady = not na(upperRefRaw) and not na(lowerRefRaw) and upperRefRaw > lowerRefRaw
float upperRef = referenceReady ? upperRefRaw : high
float lowerRef = referenceReady ? lowerRefRaw : low
float refRange = math.max(upperRef - lowerRef, syminfo.mintick)

float candleRange = math.max(high - low, syminfo.mintick)
float body = math.abs(close - open)
float bodyShare = body / candleRange
float upperWick = high - math.max(open, close)
float lowerWick = math.min(open, close) - low
float upperWickShare = upperWick / candleRange
float lowerWickShare = lowerWick / candleRange
float closeLocationBull = (close - low) / candleRange
float closeLocationBear = (high - close) / candleRange

float volumeNow = nz(volume, 0.0)
float volumeBaseRaw = ta.sma(volumeNow, volumeLength)
float volumeBase = nz(volumeBaseRaw, volumeNow)
float rvol = volumeBase > 0.0 ? volumeNow / volumeBase : 1.0

float effectiveSpikeRvol = spikeRvol
float effectiveWickNeed = 0.40
float effectiveSweepBuffer = sweepBufferAtr
float effectiveRecoveryBuffer = recoveryBufferAtr
if sensitivity == "Aggressive"
    effectiveSpikeRvol := math.max(spikeRvol - 0.20, 0.70)
    effectiveWickNeed := 0.32
    effectiveSweepBuffer := math.max(sweepBufferAtr - 0.03, 0.0)
else if sensitivity == "Conservative"
    effectiveSpikeRvol := spikeRvol + 0.25
    effectiveWickNeed := 0.48
    effectiveSweepBuffer := sweepBufferAtr + 0.04
    effectiveRecoveryBuffer := recoveryBufferAtr + 0.03

float confirmCloseNeed = 0.58
float confirmBodyNeed = 0.22
float confirmBufferAtr = 0.02
if confirmationMode == "Fast"
    confirmCloseNeed := 0.52
    confirmBodyNeed := 0.16
    confirmBufferAtr := 0.00
else if confirmationMode == "Strict"
    confirmCloseNeed := 0.66
    confirmBodyNeed := 0.32
    confirmBufferAtr := 0.05

float sweepBuffer = atr * effectiveSweepBuffer
float recoveryBuffer = atr * effectiveRecoveryBuffer
float upsidePenAtr = (high - upperRef) / atr
float downsidePenAtr = (lowerRef - low) / atr
bool allowBull = sideMode == "Auto" or sideMode == "Bull Reversal Only"
bool allowBear = sideMode == "Auto" or sideMode == "Bear Reversal Only"
bool volumeSpike = rvol >= effectiveSpikeRvol

bool upsideProbe = referenceReady and high > upperRef + sweepBuffer
bool downsideProbe = referenceReady and low < lowerRef - sweepBuffer
bool upsideTrapRaw = allowBear and upsideProbe and close < upperRef - recoveryBuffer and upperWickShare >= effectiveWickNeed and volumeSpike
bool downsideTrapRaw = allowBull and downsideProbe and close > lowerRef + recoveryBuffer and lowerWickShare >= effectiveWickNeed and volumeSpike
bool upsideTrap = confirmedBar and upsideTrapRaw and not downsideTrapRaw
bool downsideTrap = confirmedBar and downsideTrapRaw and not upsideTrapRaw
bool dualTrap = confirmedBar and upsideTrapRaw and downsideTrapRaw

float upsideBaseScore = f_base_score(rvol, upperWickShare, closeLocationBear, upsidePenAtr, effectiveSpikeRvol)
float downsideBaseScore = f_base_score(rvol, lowerWickShare, closeLocationBull, downsidePenAtr, effectiveSpikeRvol)
int candidateSide = downsideTrap ? 1 : upsideTrap ? -1 : dualTrap ? (downsideBaseScore >= upsideBaseScore ? 1 : -1) : 0
float candidateScore = candidateSide == 1 ? downsideBaseScore : candidateSide == -1 ? upsideBaseScore : na
float candidateRail = candidateSide == 1 ? lowerRef : candidateSide == -1 ? upperRef : na
float candidateExtreme = candidateSide == 1 ? low : candidateSide == -1 ? high : na
float candidateRisk = candidateSide == 1 ? candidateExtreme - atr * riskBufferAtr : candidateSide == -1 ? candidateExtreme + atr * riskBufferAtr : na
float candidateOpposite = candidateSide == 1 ? upperRef : candidateSide == -1 ? lowerRef : na
float fallbackTarget = candidateSide == 1 ? close + atr * targetFallbackAtr : candidateSide == -1 ? close - atr * targetFallbackAtr : na
float candidateTarget = candidateSide == 1 ? math.max(candidateOpposite, close + atr * 0.70, fallbackTarget) : candidateSide == -1 ? math.min(candidateOpposite, close - atr * 0.70, fallbackTarget) : na
float candidateConfirmLevel = candidateSide == 1 ? math.max(open, close) : candidateSide == -1 ? math.min(open, close) : na

// -------------------------------------------------
// Active Trap State
// -------------------------------------------------
var int activeSide = 0
var int activeStartBar = na
var float activeRail = na
var float activeExtreme = na
var float activeRisk = na
var float activeTarget = na
var float activeConfirmLevel = na
var float activeBaseScore = na
var float activeScore = na
var float activeRvol = na
var bool activeConfirmed = false
var bool activeFailed = false
var bool activeExpired = false
var bool activeTargetTouched = false
var string activeState = "Idle"
var int activeTerminalBar = na

var label[] eventLabels = array.new_label()
var box pocketBox = na
var label pocketBadge = na
var line pocketRailLine = na
var line pocketRiskLine = na
var box targetBox = na
var label targetBadge = na
var line targetLine = na
var int lastTrapEventBar = na
var int lastEventLabelBar = na

// Bounded vertical anti-collision fan. Nearby labels separate without drifting
// so far from their event candle that the historical chart loses visual meaning.
f_avoid(float proposedY, int curBar, bool moveUp) =>
    float gap = math.max(atr * 0.65, syminfo.mintick * 4.0)
    float maxShift = math.max(atr * 1.80, gap)
    int xWin = 12
    float adjY = proposedY
    bool moved = true
    int guard = 0
    while moved and guard < 6
        moved := false
        if array.size(eventLabels) > 0
            for i = 0 to array.size(eventLabels) - 1
                label ex = array.get(eventLabels, i)
                if math.abs(label.get_x(ex) - curBar) <= xWin and math.abs(label.get_y(ex) - adjY) < gap
                    adjY := moveUp ? adjY + gap : adjY - gap
                    moved := true
        if not na(pocketBadge) and math.abs(label.get_x(pocketBadge) - curBar) <= 8 and math.abs(label.get_y(pocketBadge) - adjY) < gap
            adjY := moveUp ? adjY + gap : adjY - gap
            moved := true
        if not na(targetBadge) and math.abs(label.get_x(targetBadge) - curBar) <= 8 and math.abs(label.get_y(targetBadge) - adjY) < gap
            adjY := moveUp ? adjY + gap : adjY - gap
            moved := true
        guard := guard + 1
    f_clamp(adjY, proposedY - maxShift, proposedY + maxShift)

bool trapSpacingReady = na(lastTrapEventBar) or bar_index - lastTrapEventBar >= labelCooldownBars
bool newTrapEvent = candidateSide != 0 and candidateScore >= watchScore and trapSpacingReady
bool confirmedEvent = false
bool invalidatedEvent = false
bool expiredEvent = false
bool targetReviewEvent = false

if newTrapEvent
    activeSide := candidateSide
    activeStartBar := bar_index
    activeRail := candidateRail
    activeExtreme := candidateExtreme
    activeRisk := candidateRisk
    activeTarget := candidateTarget
    activeConfirmLevel := candidateConfirmLevel
    activeBaseScore := candidateScore
    activeScore := candidateScore
    activeRvol := rvol
    activeConfirmed := false
    activeFailed := false
    activeExpired := false
    activeTargetTouched := false
    activeState := "Trap Watch"
    activeTerminalBar := na
    lastTrapEventBar := bar_index

    color sideColor = f_side_color(activeSide)
    int rightEdge = bar_index + forwardBars
    float pocketTop = activeSide == 1 ? math.max(activeRail, activeExtreme + atr * 0.12) : activeExtreme
    float pocketBottom = activeSide == 1 ? activeExtreme : math.min(activeRail, activeExtreme - atr * 0.12)

    // Single active zone: clear the previous trap's furniture before drawing the new one
    if not na(pocketBox)
        box.delete(pocketBox)
        pocketBox := na
    if not na(pocketBadge)
        label.delete(pocketBadge)
        pocketBadge := na
    if not na(pocketRailLine)
        line.delete(pocketRailLine)
        pocketRailLine := na
    if not na(pocketRiskLine)
        line.delete(pocketRiskLine)
        pocketRiskLine := na
    if not na(targetBox)
        box.delete(targetBox)
        targetBox := na
    if not na(targetBadge)
        label.delete(targetBadge)
        targetBadge := na
    if not na(targetLine)
        line.delete(targetLine)
        targetLine := na

    if showTrapPockets
        string pocketText = activeSide == 1 ? "Downside\nVol Trap" : "Upside\nVol Trap"
        pocketBox := box.new(left = bar_index, top = pocketTop, right = rightEdge, bottom = pocketBottom, xloc = xloc.bar_index, bgcolor = color.new(sideColor, zoneTransparency), border_color = color.new(sideColor, 22), border_width = 1)
        pocketBadge := f_zone_badge(pocketText, bar_index, rightEdge, pocketTop, pocketBottom, sideColor, labelFontSize)
    if showGuideRails
        pocketRailLine := line.new(x1 = bar_index, y1 = activeRail, x2 = rightEdge, y2 = activeRail, xloc = xloc.bar_index, color = color.new(sideColor, 12), width = 2, style = line.style_solid)
        pocketRiskLine := line.new(x1 = bar_index, y1 = activeRisk, x2 = rightEdge, y2 = activeRisk, xloc = xloc.bar_index, color = color.new(dangerColor, 10), width = 1, style = line.style_dashed)
    if showEventLabels and (na(lastEventLabelBar) or bar_index - lastEventLabelBar >= labelCooldownBars)
        string scorePart = showLabelScore ? "\n" + f_score_text(activeScore) : ""
        string labelText = labelTextMode == "Detailed" ? "VOLUME TRAP\nRVOL " + str.tostring(activeRvol, "#.##") + scorePart : "VOL TRAP" + scorePart
        float labelY = activeSide == 1 ? low - labelOffset : high + labelOffset
        labelY := f_avoid(labelY, bar_index, activeSide == -1)
        label trapLabel = label.new(bar_index, labelY, labelText, style = activeSide == 1 ? label.style_label_up : label.style_label_down, color = color.new(sideColor, 0), textcolor = f_text_on(sideColor), size = f_text_size(labelFontSize))
        f_keep_label(eventLabels, trapLabel, maxVisibleObjects * 3)
        lastEventLabelBar := bar_index
else if activeSide != 0
    int barsSinceTrap = bar_index - activeStartBar
    bool riskFailed = confirmedBar and not activeFailed and not activeExpired and (activeSide == 1 ? close < activeRisk : close > activeRisk)
    float followAtr = activeSide == 1 ? (close - activeRail) / atr : (activeRail - close) / atr
    float directionalClose = activeSide == 1 ? closeLocationBull : closeLocationBear
    bool directionalBody = activeSide == 1 ? close > open : close < open
    bool confirmationCandle = barsSinceTrap > 0 and barsSinceTrap <= confirmationWindowBars and directionalBody and bodyShare >= confirmBodyNeed and directionalClose >= confirmCloseNeed and (activeSide == 1 ? close > activeConfirmLevel + atr * confirmBufferAtr : close < activeConfirmLevel - atr * confirmBufferAtr)
    float confirmScore = f_confirmation_score(bodyShare, directionalClose, followAtr)

    if riskFailed
        activeFailed := true
        activeConfirmed := false
        activeState := "Trap Failed"
        activeTerminalBar := bar_index
        activeScore := math.max(activeBaseScore - 12.0, 0.0)
        invalidatedEvent := confirmedBar
        if not na(pocketBox)
            box.delete(pocketBox)
            pocketBox := na
        if not na(pocketBadge)
            label.delete(pocketBadge)
            pocketBadge := na
        if not na(pocketRailLine)
            line.delete(pocketRailLine)
            pocketRailLine := na
        if not na(pocketRiskLine)
            line.delete(pocketRiskLine)
            pocketRiskLine := na
        if not na(targetBox)
            box.delete(targetBox)
            targetBox := na
        if not na(targetBadge)
            label.delete(targetBadge)
            targetBadge := na
        if not na(targetLine)
            line.delete(targetLine)
            targetLine := na
    else if confirmedBar and not activeConfirmed and not activeFailed and barsSinceTrap > confirmationWindowBars
        activeExpired := true
        activeState := "Expired"
        activeTerminalBar := bar_index
        activeScore := math.max(activeBaseScore - 8.0, 0.0)
        expiredEvent := confirmedBar
        if not na(pocketBox)
            box.delete(pocketBox)
            pocketBox := na
        if not na(pocketBadge)
            label.delete(pocketBadge)
            pocketBadge := na
        if not na(pocketRailLine)
            line.delete(pocketRailLine)
            pocketRailLine := na
        if not na(pocketRiskLine)
            line.delete(pocketRiskLine)
            pocketRiskLine := na
    else if not activeConfirmed and not activeFailed and not activeExpired and confirmationCandle and confirmedBar
        activeConfirmed := true
        activeScore := f_clamp(activeBaseScore + confirmScore, 0.0, 100.0)
        activeState := activeSide == 1 ? "Bull Reversal" : "Bear Reversal"
        confirmedEvent := activeScore >= minReversalScore
        if showTargetBands
            color targetColor = f_side_color(activeSide)
            int targetRight = bar_index + forwardBars
            float targetTop = activeTarget + atr * targetBandAtr
            float targetBottom = activeTarget - atr * targetBandAtr
            string targetText = activeSide == 1 ? "Bull Target\nRoom" : "Bear Target\nRoom"
            targetBox := box.new(left = bar_index, top = targetTop, right = targetRight, bottom = targetBottom, xloc = xloc.bar_index, bgcolor = color.new(accentColor, 90), border_color = color.new(targetColor, 30), border_width = 1)
            targetBadge := f_zone_badge(targetText, bar_index, targetRight, targetTop, targetBottom, targetColor, labelFontSize)
        if showGuideRails
            targetLine := line.new(x1 = bar_index, y1 = activeTarget, x2 = bar_index + forwardBars, y2 = activeTarget, xloc = xloc.bar_index, color = color.new(accentColor, 18), width = 1, style = line.style_dotted)
        if showEventLabels and (na(lastEventLabelBar) or bar_index - lastEventLabelBar >= labelCooldownBars)
            string scorePart = showLabelScore ? "\n" + f_score_text(activeScore) : ""
            string labelText = labelTextMode == "Detailed" ? (activeSide == 1 ? "BULL REVERSAL" : "BEAR REVERSAL") + "\nGrade " + f_grade(activeScore) + scorePart : "REVERSAL\nREADY" + scorePart
            float labelY = activeSide == 1 ? low - labelOffset : high + labelOffset
            labelY := f_avoid(labelY, bar_index, activeSide == -1)
            label readyLabel = label.new(bar_index, labelY, labelText, style = activeSide == 1 ? label.style_label_up : label.style_label_down, color = color.new(f_side_color(activeSide), 0), textcolor = f_text_on(f_side_color(activeSide)), size = f_text_size(labelFontSize))
            f_keep_label(eventLabels, readyLabel, maxVisibleObjects * 3)
            lastEventLabelBar := bar_index
    else if activeConfirmed and not activeFailed and not activeTargetTouched
        activeScore := f_clamp(activeBaseScore + confirmScore, 0.0, 100.0)
        bool targetHit = activeSide == 1 ? high >= activeTarget : low <= activeTarget
        if targetHit and confirmedBar
            activeTargetTouched := true
            activeState := "Target Review"
            activeTerminalBar := bar_index
            targetReviewEvent := true
            if showEventLabels and (na(lastEventLabelBar) or bar_index - lastEventLabelBar >= labelCooldownBars)
                string labelText = "TARGET\nREVIEW"
                float labelY = activeSide == 1 ? high + labelOffset : low - labelOffset
                labelY := f_avoid(labelY, bar_index, activeSide == 1)
                label targetLabel = label.new(bar_index, labelY, labelText, style = activeSide == 1 ? label.style_label_down : label.style_label_up, color = color.new(accentColor, 0), textcolor = f_text_on(accentColor), size = f_text_size(labelFontSize))
                f_keep_label(eventLabels, targetLabel, maxVisibleObjects * 3)
                lastEventLabelBar := bar_index

if invalidatedEvent and showEventLabels and (na(lastEventLabelBar) or bar_index - lastEventLabelBar >= labelCooldownBars)
    float failY = activeSide == 1 ? low - labelOffset : high + labelOffset
    failY := f_avoid(failY, bar_index, activeSide == -1)
    label failLabel = label.new(bar_index, failY, "TRAP\nFAILED", style = activeSide == 1 ? label.style_label_up : label.style_label_down, color = color.new(dangerColor, 0), textcolor = f_text_on(dangerColor), size = f_text_size(labelFontSize))
    f_keep_label(eventLabels, failLabel, maxVisibleObjects * 3)
    lastEventLabelBar := bar_index

bool watchCandidate = showWatchLabels and confirmedBar and not newTrapEvent and volumeSpike and (upsideProbe or downsideProbe)
int watchSide = downsideProbe and allowBull ? 1 : upsideProbe and allowBear ? -1 : 0
float watchEventScore = watchSide == 1 ? downsideBaseScore : watchSide == -1 ? upsideBaseScore : na
if watchCandidate and watchSide != 0 and watchEventScore >= watchScore and (na(lastEventLabelBar) or bar_index - lastEventLabelBar >= labelCooldownBars)
    color watchColor = f_side_color(watchSide)
    float watchY = watchSide == 1 ? low - labelOffset : high + labelOffset
    watchY := f_avoid(watchY, bar_index, watchSide == -1)
    string watchText = showLabelScore ? "VOL WATCH\n" + f_score_text(watchEventScore) : "VOL\nWATCH"
    label watchLabel = label.new(bar_index, watchY, watchText, style = watchSide == 1 ? label.style_label_up : label.style_label_down, color = color.new(watchColor, 0), textcolor = f_text_on(watchColor), size = f_text_size(labelFontSize))
    f_keep_label(eventLabels, watchLabel, maxVisibleObjects * 3)
    lastEventLabelBar := bar_index

// Terminal lifecycle cleanup is measured from the failure, expiry, or target
// review event itself. Historical event labels remain; only stale active
// furniture and state are released.
bool terminalCleanupDue = not na(activeTerminalBar) and bar_index - activeTerminalBar > panelResetBars
if terminalCleanupDue
    if not na(pocketBox)
        box.delete(pocketBox)
        pocketBox := na
    if not na(pocketBadge)
        label.delete(pocketBadge)
        pocketBadge := na
    if not na(pocketRailLine)
        line.delete(pocketRailLine)
        pocketRailLine := na
    if not na(pocketRiskLine)
        line.delete(pocketRiskLine)
        pocketRiskLine := na
    if not na(targetBox)
        box.delete(targetBox)
        targetBox := na
    if not na(targetBadge)
        label.delete(targetBadge)
        targetBadge := na
    if not na(targetLine)
        line.delete(targetLine)
        targetLine := na
    activeSide := 0
    activeStartBar := na
    activeRail := na
    activeExtreme := na
    activeRisk := na
    activeTarget := na
    activeConfirmLevel := na
    activeBaseScore := na
    activeScore := na
    activeRvol := na
    activeConfirmed := false
    activeFailed := false
    activeExpired := false
    activeTargetTouched := false
    activeState := "Idle"
    activeTerminalBar := na

// -------------------------------------------------
// Stop-aware reversal proof engine
// Confirmed-bar gated. Resolve any open plan first, then open a new one.
// When a reversal confirms at or above the minimum score, the planner tests
// whether price travels one reward-unit (Proof Target R) in its favor from the
// confirmation close before reaching the risk edge. Risk is checked first
// (conservative), so a bar that touches both counts as a stop. This is a
// balanced follow-through test, independent of the wider planning target room.
// Plans that resolve neither way inside the window time out and stay uncounted.
// -------------------------------------------------
var int   proofWins      = 0
var int   proofTotal     = 0
var bool  proofPending   = false
var int   proofDir       = 0
var float proofTargetLvl = na
var float proofRiskLvl   = na
var int   proofBarsLeft  = 0

if barstate.isconfirmed
    if proofPending
        proofBarsLeft := proofBarsLeft - 1
        if proofDir == 1
            if low <= proofRiskLvl
                proofTotal := proofTotal + 1
                proofPending := false
            else if high >= proofTargetLvl
                proofWins  := proofWins + 1
                proofTotal := proofTotal + 1
                proofPending := false
            else if proofBarsLeft <= 0
                proofPending := false
        else if proofDir == -1
            if high >= proofRiskLvl
                proofTotal := proofTotal + 1
                proofPending := false
            else if low <= proofTargetLvl
                proofWins  := proofWins + 1
                proofTotal := proofTotal + 1
                proofPending := false
            else if proofBarsLeft <= 0
                proofPending := false
    if not proofPending and confirmedEvent
        float entryRef = close
        float riskDist = math.max(math.abs(entryRef - activeRisk), atr * 0.20)
        proofPending   := true
        proofDir       := activeSide
        proofRiskLvl   := activeRisk
        proofTargetLvl := activeSide == 1 ? entryRef + riskDist * proofReward : entryRef - riskDist * proofReward
        proofBarsLeft  := proofWindowBars

float proofRate = proofTotal > 0 ? proofWins / proofTotal * 100.0 : 0.0
bool proofReady = proofTotal >= 6
string proofText = proofReady ? str.tostring(proofRate, "#") + "%" : "Building (" + str.tostring(proofTotal) + ")"
color proofFill = not proofReady ? neutralColor : proofRate >= 55.0 ? bullColor : proofRate >= 45.0 ? neutralColor : bearColor

// -------------------------------------------------
// Visual Tint
// -------------------------------------------------
color activeTint = na
if tintActiveCandles and activeSide != 0 and not activeFailed and not activeExpired
    activeTint := activeConfirmed ? color.new(f_side_color(activeSide), 78) : color.new(neutralColor, 84)
barcolor(activeTint)

// -------------------------------------------------
// Panel
// -------------------------------------------------
var table plannerPanel = table.new(f_panel_position(panelLocation), 2, 7, border_width = 1, border_color = f_panel_border(panelTheme))

if barstate.islast
    table.clear(plannerPanel, 0, 0, 1, 6)
    if showPanel
        table.cell(plannerPanel, 0, 0, "AG Pro Volume Trap Reversal Planner", text_color = headerText, bgcolor = headerBg, text_size = f_text_size(panelFontSize), text_halign = text.align_center)
        table.cell(plannerPanel, 1, 0, "", text_color = headerText, bgcolor = headerBg, text_size = f_text_size(panelFontSize))
        table.merge_cells(plannerPanel, 0, 0, 1, 0)
        bool terminalState = activeState == "Trap Failed" or activeState == "Expired" or activeState == "Target Review"
        int barsSinceTerminal = terminalState and not na(activeTerminalBar) ? bar_index - activeTerminalBar : na
        bool terminalStateExpired = terminalState and not na(barsSinceTerminal) and barsSinceTerminal > panelResetBars
        bool showActivePanelState = activeSide != 0 and not terminalStateExpired
        string trapSideText = showActivePanelState ? f_side_text(activeSide) : "No Active Trap"
        string volumeText = showActivePanelState ? str.tostring(activeRvol, "#.##") + "x" : str.tostring(rvol, "#.##") + "x"
        string scoreText = showActivePanelState ? f_score_text(activeScore) + " " + f_grade(activeScore) : "-"
        string riskText = showActivePanelState ? f_fmt_price(activeRisk) : "-"
        string actionText = showActivePanelState ? f_action_text(activeState, activeScore) : "Wait for trap"
        f_panel_row(plannerPanel, 1, "Trap Side", trapSideText, showActivePanelState ? f_side_color(activeSide) : f_panel_value(panelTheme), panelTheme, panelFontSize)
        f_panel_row(plannerPanel, 2, "Volume Spike", volumeText, rvol >= effectiveSpikeRvol ? neutralColor : f_panel_value(panelTheme), panelTheme, panelFontSize)
        f_panel_row(plannerPanel, 3, "Reversal Score", scoreText, showActivePanelState ? f_score_color(activeScore) : f_panel_value(panelTheme), panelTheme, panelFontSize)
        color proofRowBg = f_row_bg(panelTheme, 4)
        table.cell(plannerPanel, 0, 4, "Reversal Proof", text_color = f_panel_label(panelTheme), bgcolor = proofRowBg, text_size = f_text_size(panelFontSize), text_halign = text.align_left)
        table.cell(plannerPanel, 1, 4, proofText, text_color = f_text_on(proofFill), bgcolor = proofFill, text_size = f_text_size(panelFontSize), text_halign = text.align_right)
        f_panel_row(plannerPanel, 5, "Risk Edge", riskText, showActivePanelState ? dangerColor : f_panel_value(panelTheme), panelTheme, panelFontSize)
        f_panel_row(plannerPanel, 6, "Action", actionText, showActivePanelState ? f_state_color(activeState, activeSide, activeScore) : f_panel_value(panelTheme), panelTheme, panelFontSize)

// -------------------------------------------------
// Alerts
// -------------------------------------------------
alertcondition(newTrapEvent, "Volume Trap Watch", "Volume Trap Reversal Planner: a high-volume trap watch event is active.")
alertcondition(confirmedEvent, "Reversal Ready", "Volume Trap Reversal Planner: reversal confirmation reached the required score.")
alertcondition(invalidatedEvent, "Trap Failed", "Volume Trap Reversal Planner: the active trap failed through its risk edge.")
alertcondition(targetReviewEvent, "Target Room Review", "Volume Trap Reversal Planner: price reached the active target-room review band.")
````
