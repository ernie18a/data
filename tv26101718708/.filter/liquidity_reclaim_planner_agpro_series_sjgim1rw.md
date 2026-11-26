# Liquidity Reclaim Planner [AGPro Series]

- url: https://www.tradingview.com/script/sJgim1rw-Liquidity-Reclaim-Planner-AGPro-Series/
- type: indicator
- pine_id: PUB;1355656c25ea47e3b45ac59d5b623f08
- version: 4.0

## Description

Liquidity Reclaim Planner [AGPro Series]

🧠 Core Idea

After a liquidity event, is the reclaim strong enough to matter, or is the move still fragile?


📌 Overview / What it does

Liquidity Reclaim Planner [AGPro Series] is a chart-first liquidity planning tool designed to evaluate what happens after price sweeps a recent swing liquidity reference.

Instead of treating every liquidity sweep as a finished signal, the script starts a structured reclaim workflow. It maps the liquidity event, the reclaim pocket, the failure line, the target-room corridor, a 0-100 reclaim score, failure risk, and a clear next-action state.

The script does not predict price direction, automate execution, or claim that a reclaim will continue. It organizes post-event liquidity context so traders can review whether the reclaim has enough quality, timing, participation, and room to deserve attention.


🎯 Purpose & Design Philosophy

This script was built for traders who want more than another sweep marker.

Many liquidity tools identify where a stop run, wick raid, or sweep happened. That is useful, but the harder question comes after the event: did price reclaim the level cleanly, is the failure point clear, and is there enough structure room for the idea to remain practical?

Liquidity Reclaim Planner supports a decision-engine mindset. It helps users move from raw event detection toward structured review: event, reclaim, failure risk, target room, and next action.


⚡ Why This Script Is Different

Most tools focus on detecting liquidity sweeps, equal highs, equal lows, or stop-hunt style wick events.

This script does NOT try to become a broad liquidity sweep scanner, an EQH/EQL engine, an order block map, a structural breakout reclaim planner, or a generic support/resistance zone tool.

Instead, it focuses on the post-event reclaim decision. It asks whether the sweep was reclaimed with enough depth balance, close strength, timing, volume response, and structural room to become a useful planning context.


⚙️ Methodology

1. Context Detection
The engine tracks confirmed swing highs and swing lows as active buy-side and sell-side liquidity references.

2. Reference Mapping
When price moves through a fresh liquidity reference by an ATR-normalized amount, the script registers a liquidity event and starts a reclaim plan.

3. Reaction Evaluation
The reclaim score evaluates sweep depth, reclaim close strength, time to reclaim, relative volume response, and room to the next structure reference.

4. Visual Output
The script draws the reclaim pocket, failure line, target-room corridor, event labels, sparse context labels, and the AG Pro decision panel.


🗺️ How to Read the Chart

Zones = the reclaim pocket between the swept liquidity level and the event extreme, plus an optional target-room corridor toward the next structural reference.

Labels = liquidity event, reclaim ready, room thin, failure line, and sparse context states.

Colors = bullish reclaim planning uses AGPro teal, bearish reclaim planning uses AGPro pink, neutral review uses gold, and risk/failure context uses red.

Panel = the panel shows Liquidity Event, Reclaim Score, Failure Risk, Room, and Action.


🚦 Signals & States

• Sell-side Event → price swept a recent swing low and a bullish reclaim plan is being evaluated.

• Buy-side Event → price swept a recent swing high and a bearish reclaim plan is being evaluated.

• Reclaim Watch → price has not yet reclaimed strongly enough, but context is active.

• Planner Ready → reclaim score and target room are strong enough for structured review.

• Risk Review → reclaim exists, but the quality profile is not yet clean.

• Room Thin → reclaim exists, but the next structural room is limited.

• Failure Hit → price crossed the active failure line and the reclaim plan needs reassessment.


🔔 Alerts Logic

Alerts trigger when a sell-side or buy-side liquidity event appears, when a reclaim becomes ready, when the planner reaches Planner Ready state, when target room becomes thin, or when the failure line is crossed.

Alerts are attention markers. They are not trade instructions, entry commands, or automated strategy signals.


🧩 Confluence Logic

The strongest context usually appears when sweep depth is balanced, reclaim happens quickly, the reclaim close is decisive, relative volume supports the reaction, and the target-room corridor is not compressed.

When these elements align, the reclaim score improves and the panel action becomes more useful for structured review.


📊 When to Use

• Liquidity-driven markets where swing highs and swing lows are actively swept.

• Intraday or swing charts where reclaim behavior after stop runs matters.

• 4H charts when the trader wants a balanced view between visible liquidity events and readable planning zones.

• Post-sweep review workflows.

• Situations where the trader needs a clear failure line and room assessment.


⚠️ When NOT to Use

• Extremely low-liquidity symbols where swing references are unreliable.

• Highly chaotic news candles where reclaim behavior is distorted by abnormal volatility.

• Very compressed chop where every small swing becomes noise.

• Markets where volume data is missing or not meaningful, unless volume weighting is interpreted carefully.


🎛️ Key Inputs

• Liquidity Pivot Strength → controls how swing liquidity references are confirmed.

• Max Liquidity Level Age → controls how long a swing reference remains eligible.

• Sensitivity → adjusts how selective liquidity event and reclaim thresholds are.

• Timely Reclaim Window → defines how many bars after the event can still count as timely reclaim.

• Planner Ready Score → controls the 0-100 score threshold for the main ready state.

• Minimum Target Room ATR → controls how much structure room is required before room is considered acceptable.

• Visual settings → control reclaim pockets, failure lines, target-room corridors, labels, panel theme, and font sizes.


🖥️ Interface & Visual Design

The interface is built around a clean AG Pro panel and compact chart visuals.

The first panel row is a merged blue AGPro header. The remaining rows show the active liquidity event, reclaim score, failure risk, target room, and next action.

The chart uses a limited number of zones and labels so the active plan is visible without turning the chart into a crowded liquidity map.


🧪 Practical Usage Workflow

1. Read the panel to identify whether a liquidity event is active.

2. Check the reclaim pocket to understand the swept level and event extreme.

3. Review the reclaim score and failure risk.

4. Check the target-room corridor before assigning importance to the reclaim.

5. Use the Action row to decide whether the context deserves review, waiting, or rejection.


🔍 Interpretation Guidelines

Think in terms of quality, not certainty.

A reclaim with a high score, clean timing, strong close, and enough room is more useful than a late reclaim into nearby structure.

A low score does not mean price cannot move. It means the script's reclaim-planning conditions are not well aligned.


🚫 What This Script Is NOT

• Not a prediction engine.

• Not financial advice.

• Not auto trading.

• Not guaranteed signals.

• Not a complete liquidity or smart-money framework.

• Not an order block, FVG, or generic support/resistance map.


⚠️ Limitations & Transparency

Swing references are confirmed after the selected pivot strength, so the script uses confirmed structure rather than instantly known future pivots.

Different timeframes, symbols, volatility regimes, and liquidity conditions can change how reclaim behavior appears.

Relative volume can add context, but volume response does not guarantee continuation or reversal.

Target-room corridors are structural planning references, not forecasts.


🧠 Market Context Notes

Liquidity events often matter most when they occur around visible swing references that many traders can identify.

The reclaim phase is where the decision quality changes. A fast reclaim can show rejection, while a slow or weak reclaim can indicate fragile context.

The failure line exists so the user can see where the active reclaim idea becomes structurally weaker according to the script's own rules.


🧾 Use Case Examples

When price sweeps a recent swing low, quickly closes back above the level, and the target-room corridor is open, the planner may shift from Reclaim Watch to Planner Ready.

When price reclaims late or reclaims directly into nearby structure, the panel may show Risk Review or Room Thin.

When price crosses the active failure line after reclaim, the script marks Failure Hit so the context can be reassessed.


🧱 System Philosophy

Liquidity Reclaim Planner follows the AGPro Series approach: clear structure, rule-based scoring, readable visuals, and decision support without outcome promises.

The script is designed to help traders review the quality of a setup context, not to replace judgment or risk planning.


🔐 Non-Promise Statement

No script can provide certainty.

No reclaim score guarantees continuation, reversal, or profit.

The output should be interpreted as structured analytical context.


📉 Risk Disclosure

Trading involves risk.

Users are responsible for their own decisions, position sizing, risk controls, and market interpretation.

This script does not provide financial advice, investment advice, or guaranteed trading outcomes.


📚 Educational Note

Use this tool to study how liquidity events evolve after the sweep: whether price reclaims, where the failure line sits, how much room remains, and whether the context is strong enough to deserve further review.

## Source Code

````pine
// -------------------------------------------------
// Liquidity Reclaim Planner [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 1.3
//
// Liquidity Reclaim Planner is a chart-first liquidity planning engine for
// traders who need to evaluate post-sweep reclaim quality. It maps a liquidity
// event, reclaim pocket, failure line, target-room corridor, 0-100 reclaim
// score, failure risk, a target and invalidation level, a stop-aware
// follow-through proof rate, and a next-action state so liquidity context
// becomes a structured decision workflow rather than another generic sweep
// marker.
// -------------------------------------------------

//@version=6
indicator("Liquidity Reclaim Planner [AGPro Series]",
     shorttitle = "AG Pro LRP",
     overlay = true,
     max_labels_count = 220,
     max_boxes_count = 36,
     max_lines_count = 80)

// -------------------------------------------------
// AGPro Color Palette
// -------------------------------------------------
color headerBg      = color.rgb(37, 99, 235)      // #2563EB
color headerText    = color.rgb(245, 247, 250)    // #F5F7FA
color panelBg       = color.rgb(15, 23, 42)       // #0F172A
color panelBorder   = color.rgb(51, 65, 85)       // #334155
color panelLabelCol = color.rgb(148, 163, 184)    // #94A3B8
color panelValueCol = color.rgb(226, 232, 240)    // #E2E8F0
color bullColor     = color.rgb(34, 197, 166)     // #22C5A6
color bearColor     = color.rgb(244, 114, 182)    // #F472B6
color neutralColor  = color.rgb(245, 189, 92)     // #F5BD5C
color accentColor   = color.rgb(129, 140, 248)    // #818CF8
color dangerColor   = color.rgb(239, 68, 68)

// -------------------------------------------------
// Tooltips
// -------------------------------------------------
string ttPivot = "Confirmed swing strength used to define the active buy-side and sell-side liquidity reference. Higher values reduce noise but make references slower."
string ttAge = "Maximum age, in bars, for a swing liquidity reference to remain eligible for a reclaim plan."
string ttAtr = "ATR length used for sweep depth, reclaim buffer, failure line, corridor width, label spacing, and score normalization."
string ttVol = "Volume baseline used to evaluate whether the reclaim has meaningful participation. On symbols with unreliable volume, this component becomes neutral."
string ttRoom = "Lookback used to estimate the next structural room target after a reclaim. The target is a planning reference, not a forecast."
string ttSensitivity = "Controls how selective the liquidity event and reclaim thresholds are. Conservative requires cleaner penetration and reclaim behavior."
string ttConfirm = "Close Confirmed waits for bar close before event labels and alerts. Live Updating allows the active state to update intrabar."
string ttMinSweep = "Minimum ATR-normalized move through the liquidity level required to register a liquidity event."
string ttIdealSweep = "Preferred sweep depth for the score model. Extremely shallow or extremely deep sweeps receive weaker depth quality."
string ttMaxSweep = "Sweep depth above this ATR value is treated as unstable and receives a weaker score."
string ttWindow = "Number of bars after the liquidity event where a reclaim is still considered timely."
string ttReclaim = "ATR-normalized close back through the liquidity level required for a strong reclaim component."
string ttBuffer = "Small ATR buffer beyond the liquidity level required for reclaim confirmation."
string ttVolumeConfirm = "Relative volume level treated as meaningful participation during reclaim evaluation."
string ttMinScore = "Minimum 0-100 reclaim score required for Planner Ready state. This is a quality threshold, not a trade instruction."
string ttWatchScore = "Minimum 0-100 score required for active Reclaim Watch context before full planner readiness."
string ttRoomMin = "Minimum ATR room to the next structural reference required before the planner considers target room acceptable."
string ttPocket = "Shows the reclaim pocket between the swept liquidity level and the event extreme. The label is centered horizontally and vertically."
string ttFailure = "Shows the reclaimed level and the failure line beyond the event extreme. The failure rail keeps a filled right-edge owner badge. These are planning references, not stop recommendations."
string ttCorridor = "Shows the target-room corridor between the reclaimed level and the next structural room reference."
string ttForward = "How far active pockets, failure lines, and target corridors extend to the right."
string ttOpacity = "Transparency for the reclaim pocket and target-room corridor. Higher values make zones lighter."
string ttTint = "Adds a subtle candle tint while a liquidity reclaim plan is active."
string ttEvents = "Shows compact liquidity event, reclaim, room, and failure badges in font-aware ATR lanes with source-candle connectors."
string ttApproach = "Adds optional approach badges when price nears an eligible liquidity reference. Disabled by default because these are supporting context, not primary events."
string ttContext = "Adds optional periodic state badges while a reclaim plan is active. Disabled by default because the centered pocket badge and panel already carry the current state."
string ttCooldown = "Minimum bars between historical event badges. Higher values reduce repeated narration during fast markets."
string ttContextSpacing = "Minimum bars between sparse approach or active-state labels."
string ttMaxLabels = "Maximum number of chart labels retained. Older labels are deleted first to preserve performance."
string ttLabelOffset = "ATR-based vertical offset that keeps labels away from candle bodies and wicks."
string ttLabelScore = "Adds the 0-100 reclaim score to event labels."
string ttLabelSize = "Controls all chart labels and centered zone labels. Normal is the recommended publication default."
string ttPanel = "Shows or hides the AG Pro planning panel. The default is visible for public-release readability."
string ttPanelLocation = "Moves the AG Pro planning panel to the preferred chart location."
string ttPanelTheme = "Switches the panel between AGPro dark and clean light themes."
string ttPanelFont = "Controls panel text size. Normal is the recommended publication default."

// -------------------------------------------------
// Inputs
// -------------------------------------------------
string groupEngine = "Liquidity Reclaim Engine"
int pivotStrength = input.int(3, "Liquidity Pivot Strength", minval = 1, maxval = 12, group = groupEngine, tooltip = ttPivot)
int maxLevelAge = input.int(180, "Max Liquidity Level Age", minval = 20, maxval = 800, group = groupEngine, tooltip = ttAge)
int atrLength = input.int(14, "ATR Length", minval = 5, maxval = 100, group = groupEngine, tooltip = ttAtr)
int volumeLength = input.int(34, "Volume Baseline Length", minval = 5, maxval = 200, group = groupEngine, tooltip = ttVol)
int roomLookback = input.int(55, "Structure Room Lookback", minval = 10, maxval = 300, group = groupEngine, tooltip = ttRoom)
string sensitivity = input.string("Balanced", "Sensitivity", options = ["Conservative", "Balanced", "Aggressive"], group = groupEngine, tooltip = ttSensitivity)
string confirmationMode = input.string("Close Confirmed", "Confirmation Mode", options = ["Close Confirmed", "Live Updating"], group = groupEngine, tooltip = ttConfirm)

string groupScoring = "Reclaim Score Model"
float minimumSweepAtrInput = input.float(0.10, "Minimum Sweep Depth ATR", minval = 0.02, maxval = 1.00, step = 0.01, group = groupScoring, tooltip = ttMinSweep)
float idealSweepAtr = input.float(0.36, "Ideal Sweep Depth ATR", minval = 0.05, maxval = 2.00, step = 0.01, group = groupScoring, tooltip = ttIdealSweep)
float maximumSweepAtr = input.float(1.40, "Maximum Useful Sweep ATR", minval = 0.20, maxval = 4.00, step = 0.05, group = groupScoring, tooltip = ttMaxSweep)
int reclaimWindowBars = input.int(5, "Timely Reclaim Window", minval = 1, maxval = 40, group = groupScoring, tooltip = ttWindow)
float strongReclaimAtr = input.float(0.34, "Strong Reclaim Close ATR", minval = 0.03, maxval = 2.00, step = 0.01, group = groupScoring, tooltip = ttReclaim)
float reclaimBufferAtr = input.float(0.04, "Reclaim Close Buffer ATR", minval = 0.00, maxval = 0.60, step = 0.01, group = groupScoring, tooltip = ttBuffer)
float volumeConfirmRatio = input.float(1.25, "Volume Response Ratio", minval = 0.50, maxval = 5.00, step = 0.05, group = groupScoring, tooltip = ttVolumeConfirm)
int plannerReadyScore = input.int(70, "Planner Ready Score", minval = 40, maxval = 95, group = groupScoring, tooltip = ttMinScore)
int reclaimWatchScore = input.int(52, "Reclaim Watch Score", minval = 20, maxval = 90, group = groupScoring, tooltip = ttWatchScore)
float minimumRoomAtr = input.float(0.90, "Minimum Target Room ATR", minval = 0.10, maxval = 8.00, step = 0.05, group = groupScoring, tooltip = ttRoomMin)

string groupVisual = "Chart Visuals"
bool showReclaimPocket = input.bool(true, "Show Reclaim Pocket", group = groupVisual, tooltip = ttPocket)
bool showFailureLines = input.bool(true, "Show Level / Failure Lines", group = groupVisual, tooltip = ttFailure)
bool showTargetCorridor = input.bool(true, "Show Target-Room Corridor", group = groupVisual, tooltip = ttCorridor)
int forwardBars = input.int(42, "Forward Render Bars", minval = 8, maxval = 180, group = groupVisual, tooltip = ttForward)
int zoneTransparency = input.int(89, "Zone Transparency", minval = 70, maxval = 96, group = groupVisual, tooltip = ttOpacity)
bool tintActiveBars = input.bool(true, "Tint Active Reclaim Plan", group = groupVisual, tooltip = ttTint)

string groupLabels = "Labels"
bool showEventLabels = input.bool(true, "Show Event Labels", group = groupLabels, tooltip = ttEvents)
bool showApproachLabels = input.bool(false, "Show Liquidity Approach Labels", group = groupLabels, tooltip = ttApproach)
bool showContextLabels = input.bool(false, "Show Sparse Context Labels", group = groupLabels, tooltip = ttContext)
int labelCooldownBars = input.int(34, "Label Cooldown Bars", minval = 1, maxval = 120, group = groupLabels, tooltip = ttCooldown)
int contextSpacingBars = input.int(52, "Context Label Spacing", minval = 8, maxval = 240, group = groupLabels, tooltip = ttContextSpacing)
int maxVisibleLabels = input.int(4, "Max Visible Labels", minval = 4, maxval = 80, group = groupLabels, tooltip = ttMaxLabels)
float labelOffsetAtr = input.float(0.88, "Label Offset ATR", minval = 0.10, maxval = 3.00, step = 0.05, group = groupLabels, tooltip = ttLabelOffset)
bool showLabelScore = input.bool(true, "Show Label Score", group = groupLabels, tooltip = ttLabelScore)
string labelFontSize = input.string("Normal", "Label Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = groupLabels, tooltip = ttLabelSize)

string groupPanel = "Panel"
bool showPanel = input.bool(true, "Show Panel", group = groupPanel, tooltip = ttPanel)
string panelLocation = input.string("Top Right", "Panel Location", options = ["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], group = groupPanel, tooltip = ttPanelLocation)
string panelTheme = input.string("Elite Dark", "Panel Theme", options = ["Elite Dark", "Clean Light"], group = groupPanel, tooltip = ttPanelTheme)
string panelFontSize = input.string("Normal", "Panel Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = groupPanel, tooltip = ttPanelFont)

// -------------------------------------------------
// Helpers
// -------------------------------------------------
f_clamp(float value, float minValue, float maxValue) =>
    math.min(math.max(value, minValue), maxValue)

// Luminance-aware text color so every on-chart badge stays legible on its fill
f_text_on(color bg) =>
    float lum = 0.299 * color.r(bg) + 0.587 * color.g(bg) + 0.114 * color.b(bg)
    lum > 145 ? color.rgb(17, 24, 39) : headerText

f_norm_high(float value, float weak, float strong) =>
    float span = strong - weak
    span == 0.0 ? 0.0 : f_clamp((value - weak) / span * 100.0, 0.0, 100.0)

f_norm_low(float value, float good, float bad) =>
    float span = bad - good
    span == 0.0 ? 0.0 : f_clamp((bad - value) / span * 100.0, 0.0, 100.0)

f_peak_score(float value, float lowValue, float idealValue, float highValue) =>
    float result = 0.0
    if value <= idealValue
        result := f_norm_high(value, lowValue, idealValue)
    else
        result := f_norm_low(value, idealValue, highValue)
    result

f_text_size(string sizeText) =>
    switch sizeText
        "Tiny" => size.tiny
        "Small" => size.small
        "Large" => size.large
        => size.normal

f_panel_pos(string posText) =>
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
    themeText == "Clean Light" ? color.rgb(241, 245, 249) : panelBg

f_panel_border(string themeText) =>
    themeText == "Clean Light" ? color.rgb(148, 163, 184) : panelBorder

f_panel_label(string themeText) =>
    themeText == "Clean Light" ? color.rgb(71, 85, 105) : panelLabelCol

f_panel_value(string themeText) =>
    themeText == "Clean Light" ? color.rgb(15, 23, 42) : panelValueCol

f_row_bg(string themeText, int row) =>
    bool evenRow = row % 2 == 0
    if themeText == "Clean Light"
        evenRow ? color.rgb(226, 232, 240) : color.rgb(241, 245, 249)
    else
        evenRow ? color.rgb(20, 31, 52) : panelBg

f_set_row(table target, int row, string leftText, string rightText, color rightColor, string themeText, string sizeText) =>
    color rowBg = f_row_bg(themeText, row)
    table.cell(target, 0, row, leftText, text_color = f_panel_label(themeText), bgcolor = rowBg, text_size = f_text_size(sizeText), text_halign = text.align_left)
    table.cell(target, 1, row, rightText, text_color = rightColor, bgcolor = rowBg, text_size = f_text_size(sizeText), text_halign = text.align_right)

f_grade(float score) =>
    string gradeText = "D"
    if score >= 86.0
        gradeText := "A+"
    else if score >= 78.0
        gradeText := "A"
    else if score >= 68.0
        gradeText := "B"
    else if score >= 55.0
        gradeText := "C"
    gradeText

f_score_color(float score) =>
    score >= plannerReadyScore ? bullColor : score >= reclaimWatchScore ? neutralColor : bearColor

f_risk_color(float riskValue) =>
    riskValue >= 72.0 ? dangerColor : riskValue >= 45.0 ? neutralColor : bullColor

f_state_color(string stateText) =>
    switch stateText
        "Planner Ready" => bullColor
        "Reclaim Watch" => neutralColor
        "Risk Review" => accentColor
        "Room Thin" => neutralColor
        "Failure Hit" => dangerColor
        "Reclaim Expired" => dangerColor
        "No Event" => panelLabelCol
        => panelValueCol

f_side_text(int sideValue) =>
    sideValue == 1 ? "Sell-side sweep" : sideValue == -1 ? "Buy-side sweep" : "No event"

f_fmt(float value) =>
    na(value) ? "-" : str.tostring(value, "#.##")

f_fmt_price(float value) =>
    na(value) ? "-" : str.tostring(value, format.mintick)

f_trim_owned_badges(array<label> labels, array<line> connectors, int maxCount) =>
    while array.size(labels) > maxCount
        label oldLabel = array.shift(labels)
        line oldConnector = array.shift(connectors)
        if not na(oldLabel)
            label.delete(oldLabel)
        if not na(oldConnector)
            line.delete(oldConnector)

f_badge_y(array<label> labels, int x, float anchorY, bool placeBelow, float atrValue, float baseOffset, string sizeText) =>
    int radiusBars = sizeText == "Large" ? 30 : sizeText == "Normal" ? 25 : sizeText == "Small" ? 21 : 17
    float fontPad = sizeText == "Large" ? 0.42 : sizeText == "Normal" ? 0.28 : sizeText == "Small" ? 0.18 : 0.12
    int nearby = 0
    int count = array.size(labels)
    if count > 0
        for idx = 0 to count - 1
            label prior = array.get(labels, idx)
            if math.abs(x - label.get_x(prior)) <= radiusBars
                nearby += 1
    int lane = nearby % 3
    float gap = atrValue * (baseOffset + fontPad + lane * (0.58 + fontPad))
    anchorY + (placeBelow ? -gap : gap)

f_add_owned_badge(array<label> labels, array<line> connectors, int x, float anchorY, bool placeBelow, string badgeText, color badgeColor, float atrValue, int maxCount) =>
    float badgeY = f_badge_y(labels, x, anchorY, placeBelow, atrValue, labelOffsetAtr, labelFontSize)
    line connector = line.new(x1 = x, y1 = anchorY, x2 = x, y2 = badgeY, xloc = xloc.bar_index, color = color.new(badgeColor, 38), width = 1)
    label badge = label.new(x = x, y = badgeY, text = badgeText, xloc = xloc.bar_index, yloc = yloc.price, style = placeBelow ? label.style_label_up : label.style_label_down, color = color.new(badgeColor, 6), textcolor = f_text_on(badgeColor), size = f_text_size(labelFontSize))
    array.push(labels, badge)
    array.push(connectors, connector)
    f_trim_owned_badges(labels, connectors, maxCount)

// -------------------------------------------------
// Core measurements
// -------------------------------------------------
bool confirmedBar = confirmationMode == "Close Confirmed" ? barstate.isconfirmed : true
float atrRaw = ta.atr(atrLength)
float safeAtr = math.max(nz(atrRaw, ta.tr(true)), syminfo.mintick)
float volumeBase = ta.sma(volume, volumeLength)
float relativeVolume = na(volume) or na(volumeBase) or volumeBase <= 0.0 ? 1.0 : volume / volumeBase
float barRange = math.max(high - low, syminfo.mintick)
float closePosition = (close - low) / barRange
float upperStructure = ta.highest(high[1], roomLookback)
float lowerStructure = ta.lowest(low[1], roomLookback)

float sensitivityMult = sensitivity == "Conservative" ? 1.25 : sensitivity == "Aggressive" ? 0.78 : 1.0
float minimumSweepAtr = minimumSweepAtrInput * sensitivityMult
float reclaimBuffer = safeAtr * reclaimBufferAtr * sensitivityMult

// -------------------------------------------------
// Liquidity reference tracking
// -------------------------------------------------
float pivotHigh = ta.pivothigh(high, pivotStrength, pivotStrength)
float pivotLow = ta.pivotlow(low, pivotStrength, pivotStrength)

var float lastSwingHigh = na
var int lastSwingHighBar = na
var bool lastSwingHighSwept = false
var float lastSwingLow = na
var int lastSwingLowBar = na
var bool lastSwingLowSwept = false

if not na(pivotHigh)
    lastSwingHigh := pivotHigh
    lastSwingHighBar := bar_index - pivotStrength
    lastSwingHighSwept := false

if not na(pivotLow)
    lastSwingLow := pivotLow
    lastSwingLowBar := bar_index - pivotStrength
    lastSwingLowSwept := false

bool highLevelFresh = not na(lastSwingHigh) and not na(lastSwingHighBar) and bar_index - lastSwingHighBar <= maxLevelAge
bool lowLevelFresh = not na(lastSwingLow) and not na(lastSwingLowBar) and bar_index - lastSwingLowBar <= maxLevelAge

float bullSweepDepthAtr = lowLevelFresh ? math.max(0.0, lastSwingLow - low) / safeAtr : 0.0
float bearSweepDepthAtr = highLevelFresh ? math.max(0.0, high - lastSwingHigh) / safeAtr : 0.0

bool sellSideEventRaw = confirmedBar and lowLevelFresh and not lastSwingLowSwept and bullSweepDepthAtr >= minimumSweepAtr
bool buySideEventRaw = confirmedBar and highLevelFresh and not lastSwingHighSwept and bearSweepDepthAtr >= minimumSweepAtr
bool chooseSellSideEvent = sellSideEventRaw and (not buySideEventRaw or bullSweepDepthAtr >= bearSweepDepthAtr)
bool chooseBuySideEvent = buySideEventRaw and not chooseSellSideEvent

// -------------------------------------------------
// Active reclaim plan state
// -------------------------------------------------
var int activeSide = 0
var float activeLevel = na
var float activeExtreme = na
var int activeEventBar = na
var float activeEventDepthAtr = na
var float activeEventRvol = na
var bool activeReclaimed = false
var int activeReclaimBar = na
var bool activeFailed = false
var bool activeExpired = false

bool newLiquidityEvent = chooseSellSideEvent or chooseBuySideEvent

if chooseSellSideEvent
    activeSide := 1
    activeLevel := lastSwingLow
    activeExtreme := low
    activeEventBar := bar_index
    activeEventDepthAtr := bullSweepDepthAtr
    activeEventRvol := relativeVolume
    activeReclaimed := false
    activeReclaimBar := na
    activeFailed := false
    activeExpired := false
    lastSwingLowSwept := true

if chooseBuySideEvent
    activeSide := -1
    activeLevel := lastSwingHigh
    activeExtreme := high
    activeEventBar := bar_index
    activeEventDepthAtr := bearSweepDepthAtr
    activeEventRvol := relativeVolume
    activeReclaimed := false
    activeReclaimBar := na
    activeFailed := false
    activeExpired := false
    lastSwingHighSwept := true

bool hasEvent = activeSide != 0 and not na(activeLevel) and not na(activeExtreme) and not na(activeEventBar)
int eventAge = hasEvent ? bar_index - activeEventBar : 0

if hasEvent and not activeReclaimed and not activeFailed
    if activeSide == 1 and low < activeExtreme
        activeExtreme := low
        activeEventDepthAtr := math.max(activeEventDepthAtr, math.max(0.0, activeLevel - activeExtreme) / safeAtr)
    if activeSide == -1 and high > activeExtreme
        activeExtreme := high
        activeEventDepthAtr := math.max(activeEventDepthAtr, math.max(0.0, activeExtreme - activeLevel) / safeAtr)

bool timelyWindow = hasEvent and eventAge <= reclaimWindowBars
bool bullReclaimClose = hasEvent and activeSide == 1 and close > activeLevel + reclaimBuffer
bool bearReclaimClose = hasEvent and activeSide == -1 and close < activeLevel - reclaimBuffer
bool reclaimedNow = confirmedBar and hasEvent and not activeReclaimed and not activeFailed and timelyWindow and (bullReclaimClose or bearReclaimClose)

if reclaimedNow
    activeReclaimed := true
    activeReclaimBar := bar_index

if confirmedBar and hasEvent and not activeReclaimed and not activeFailed and eventAge > reclaimWindowBars
    activeExpired := true

float failureLinePrice = hasEvent ? activeSide == 1 ? activeExtreme - safeAtr * 0.08 : activeExtreme + safeAtr * 0.08 : na
bool failedNow = confirmedBar and hasEvent and activeReclaimed and not activeFailed and (activeSide == 1 ? close < failureLinePrice : close > failureLinePrice)

if failedNow
    activeFailed := true

// -------------------------------------------------
// Score model
// -------------------------------------------------
float targetGuide = hasEvent ? activeSide == 1 ? upperStructure : lowerStructure : na
bool targetValid = hasEvent and not na(targetGuide) and (activeSide == 1 ? targetGuide > activeLevel : targetGuide < activeLevel)
float roomAtr = hasEvent and targetValid ? activeSide == 1 ? math.max(0.0, targetGuide - close) / safeAtr : math.max(0.0, close - targetGuide) / safeAtr : 0.0
float reclaimAtr = hasEvent ? activeSide == 1 ? math.max(0.0, close - activeLevel) / safeAtr : math.max(0.0, activeLevel - close) / safeAtr : 0.0
float pocketRange = hasEvent ? math.max(math.abs(activeLevel - activeExtreme), syminfo.mintick) : syminfo.mintick
float reclaimProgress = hasEvent ? activeSide == 1 ? f_clamp((close - activeExtreme) / pocketRange, 0.0, 1.0) : f_clamp((activeExtreme - close) / pocketRange, 0.0, 1.0) : 0.0
float closeLocationScore = hasEvent ? activeSide == 1 ? f_norm_high(closePosition, 0.48, 0.88) : f_norm_high(1.0 - closePosition, 0.48, 0.88) : 0.0
float depthScore = hasEvent ? f_peak_score(nz(activeEventDepthAtr, 0.0), minimumSweepAtr, idealSweepAtr, maximumSweepAtr) : 0.0
float reclaimCloseScore = hasEvent ? activeReclaimed ? f_clamp(f_norm_high(reclaimAtr, 0.02, strongReclaimAtr) * 0.65 + closeLocationScore * 0.35, 0.0, 100.0) : f_clamp(reclaimProgress * 66.0, 0.0, 66.0) : 0.0
float timeScore = hasEvent ? f_norm_low(float(eventAge), 0.0, float(reclaimWindowBars + 2)) : 0.0
float volumeScore = hasEvent ? f_norm_high(relativeVolume, 0.75, volumeConfirmRatio) : 0.0
float roomScore = hasEvent ? f_norm_high(roomAtr, minimumRoomAtr * 0.55, minimumRoomAtr * 2.60) : 0.0
float reclaimPlannerScore = hasEvent ? f_clamp(depthScore * 0.20 + reclaimCloseScore * 0.32 + timeScore * 0.16 + volumeScore * 0.14 + roomScore * 0.18, 0.0, 100.0) : na

float failureDistanceAtr = hasEvent ? activeSide == 1 ? math.max(0.0, close - failureLinePrice) / safeAtr : math.max(0.0, failureLinePrice - close) / safeAtr : na
float proximityRisk = hasEvent ? f_norm_low(failureDistanceAtr, 0.10, 1.60) : 0.0
float roomPenalty = hasEvent and roomAtr < minimumRoomAtr ? 22.0 : 0.0
float timePenalty = hasEvent and not activeReclaimed and eventAge > reclaimWindowBars ? 28.0 : 0.0
float failureRisk = hasEvent ? activeFailed ? 100.0 : activeExpired ? 86.0 : f_clamp((100.0 - nz(reclaimPlannerScore, 0.0)) * 0.55 + proximityRisk * 0.30 + roomPenalty + timePenalty, 0.0, 100.0) : na

bool plannerReady = hasEvent and activeReclaimed and not activeFailed and reclaimPlannerScore >= plannerReadyScore and roomAtr >= minimumRoomAtr
bool reclaimWatch = hasEvent and not activeReclaimed and not activeExpired and not activeFailed and reclaimPlannerScore >= reclaimWatchScore
bool roomThin = hasEvent and activeReclaimed and not activeFailed and roomAtr < minimumRoomAtr
bool riskReview = hasEvent and activeReclaimed and not activeFailed and not plannerReady and not roomThin
bool plannerReadyAlert = plannerReady and not plannerReady[1]
bool roomThinAlert = roomThin and not roomThin[1]

string reclaimState = "No Event"
if hasEvent
    if activeFailed
        reclaimState := "Failure Hit"
    else if activeExpired
        reclaimState := "Reclaim Expired"
    else if plannerReady
        reclaimState := "Planner Ready"
    else if roomThin
        reclaimState := "Room Thin"
    else if riskReview
        reclaimState := "Risk Review"
    else
        reclaimState := "Reclaim Watch"

string actionText = "Wait for event"
if reclaimState == "Planner Ready"
    actionText := "Plan with invalidation"
else if reclaimState == "Reclaim Watch"
    actionText := "Wait for reclaim"
else if reclaimState == "Risk Review"
    actionText := "Review before acting"
else if reclaimState == "Room Thin"
    actionText := "Target room is thin"
else if reclaimState == "Failure Hit"
    actionText := "Stand down"
else if reclaimState == "Reclaim Expired"
    actionText := "Ignore late reclaim"

// -------------------------------------------------
// Stop-aware Proof — reclaim follow-through
// Measured from the reclaim bar close (the actual decision point), did price
// CLOSE to a 1.5 ATR follow-through before closing 1.0 ATR against it? Both
// sides close-based, resolve-then-open, timeout uncounted, "Building (n)" until
// at least 6 samples.
// -------------------------------------------------
var float lrpProofTarget = na
var float lrpProofStop   = na
var int   lrpProofDir    = 0
var bool  lrpProofOpen   = false
var int   lrpProofAge    = na
var int   lrpProofWins   = 0
var int   lrpProofLosses = 0
int lrpProofWindow = math.max(forwardBars, 30)

if reclaimedNow and barstate.isconfirmed and not lrpProofOpen
    lrpProofDir    := activeSide == 1 ? 1 : -1
    lrpProofTarget := lrpProofDir == 1 ? close + safeAtr * 1.5 : close - safeAtr * 1.5
    lrpProofStop   := lrpProofDir == 1 ? close - safeAtr * 1.0 : close + safeAtr * 1.0
    lrpProofAge    := 0
    lrpProofOpen   := true

if lrpProofOpen and barstate.isconfirmed and not na(lrpProofTarget) and not na(lrpProofStop)
    bool proofHitStop   = lrpProofDir == 1 ? close <= lrpProofStop : close >= lrpProofStop
    bool proofHitTarget = lrpProofDir == 1 ? close >= lrpProofTarget : close <= lrpProofTarget
    if proofHitStop
        lrpProofLosses += 1
        lrpProofOpen := false
    else if proofHitTarget
        lrpProofWins += 1
        lrpProofOpen := false
    else
        lrpProofAge := nz(lrpProofAge) + 1
        if lrpProofAge > lrpProofWindow
            lrpProofOpen := false   // timeout — uncounted

int lrpProofTotal = lrpProofWins + lrpProofLosses
float lrpProofRate = lrpProofTotal == 0 ? 0.0 : 100.0 * lrpProofWins / lrpProofTotal
string proofText = lrpProofTotal < 6 ? "Building (" + str.tostring(lrpProofTotal) + ")" : str.tostring(math.round(lrpProofRate)) + "% (" + str.tostring(lrpProofTotal) + ")"
color proofColor = lrpProofTotal < 6 ? f_panel_label(panelTheme) : lrpProofRate >= 55 ? bullColor : lrpProofRate >= 45 ? neutralColor : bearColor

// -------------------------------------------------
// Visual objects
// -------------------------------------------------
color sideColor = activeSide == 1 ? bullColor : activeSide == -1 ? bearColor : neutralColor
color zoneColor = color.new(sideColor, zoneTransparency)
color corridorColor = color.new(accentColor, math.min(zoneTransparency + 2, 96))

var box reclaimPocketBox = na
var label reclaimPocketLabel = na
var line reclaimLevelLine = na
var line failureGuideLine = na
var label failureGuideTag = na
var box targetRoomBox = na
var label targetRoomLabel = na

if hasEvent and showReclaimPocket
    int leftX = activeEventBar
    int rightX = bar_index + forwardBars
    float pocketTop = math.max(activeLevel, activeExtreme)
    float pocketBottom = math.min(activeLevel, activeExtreme)
    int centerX = int(math.round((leftX + rightX) * 0.5))
    float centerY = (pocketTop + pocketBottom) * 0.5
    string pocketSide = activeSide == 1 ? "SELL" : "BUY"
    string pocketState = activeReclaimed ? "RECLAIM" : "SWEEP WATCH"
    string pocketScore = not na(reclaimPlannerScore) ? " | Q" + str.tostring(math.round(reclaimPlannerScore)) : ""
    string pocketText = pocketSide + " " + pocketState + pocketScore
    if na(reclaimPocketBox)
        reclaimPocketBox := box.new(left = leftX, top = pocketTop, right = rightX, bottom = pocketBottom, xloc = xloc.bar_index, bgcolor = zoneColor, border_color = color.new(sideColor, 18), border_width = 1)
    else
        box.set_lefttop(reclaimPocketBox, leftX, pocketTop)
        box.set_rightbottom(reclaimPocketBox, rightX, pocketBottom)
        box.set_bgcolor(reclaimPocketBox, zoneColor)
        box.set_border_color(reclaimPocketBox, color.new(sideColor, 18))
    if na(reclaimPocketLabel)
        reclaimPocketLabel := label.new(centerX, centerY, pocketText, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_center, textcolor = f_text_on(sideColor), color = color.new(sideColor, 12), size = f_text_size(labelFontSize))
    else
        label.set_x(reclaimPocketLabel, centerX)
        label.set_y(reclaimPocketLabel, centerY)
        label.set_text(reclaimPocketLabel, pocketText)
        label.set_textcolor(reclaimPocketLabel, f_text_on(sideColor))
        label.set_color(reclaimPocketLabel, color.new(sideColor, 12))
        label.set_size(reclaimPocketLabel, f_text_size(labelFontSize))
else
    if not na(reclaimPocketBox)
        box.delete(reclaimPocketBox)
        reclaimPocketBox := na
    if not na(reclaimPocketLabel)
        label.delete(reclaimPocketLabel)
        reclaimPocketLabel := na

if hasEvent and showFailureLines
    int rightX = bar_index + forwardBars
    if na(reclaimLevelLine)
        reclaimLevelLine := line.new(activeEventBar, activeLevel, rightX, activeLevel, xloc = xloc.bar_index, color = color.new(sideColor, 5), style = line.style_solid, width = 2)
    else
        line.set_xy1(reclaimLevelLine, activeEventBar, activeLevel)
        line.set_xy2(reclaimLevelLine, rightX, activeLevel)
        line.set_color(reclaimLevelLine, color.new(sideColor, 5))
    if na(failureGuideLine)
        failureGuideLine := line.new(activeEventBar, failureLinePrice, rightX, failureLinePrice, xloc = xloc.bar_index, color = color.new(dangerColor, 18), style = line.style_dashed, width = 1)
    else
        line.set_xy1(failureGuideLine, activeEventBar, failureLinePrice)
        line.set_xy2(failureGuideLine, rightX, failureLinePrice)
        line.set_color(failureGuideLine, color.new(dangerColor, 18))
    string failureText = "FAILURE " + f_fmt_price(failureLinePrice)
    if na(failureGuideTag)
        failureGuideTag := label.new(rightX, failureLinePrice, failureText, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = dangerColor, textcolor = f_text_on(dangerColor), size = f_text_size(labelFontSize))
    else
        label.set_x(failureGuideTag, rightX)
        label.set_y(failureGuideTag, failureLinePrice)
        label.set_text(failureGuideTag, failureText)
        label.set_color(failureGuideTag, dangerColor)
        label.set_textcolor(failureGuideTag, f_text_on(dangerColor))
        label.set_size(failureGuideTag, f_text_size(labelFontSize))
else
    if not na(reclaimLevelLine)
        line.delete(reclaimLevelLine)
        reclaimLevelLine := na
    if not na(failureGuideLine)
        line.delete(failureGuideLine)
        failureGuideLine := na
    if not na(failureGuideTag)
        label.delete(failureGuideTag)
        failureGuideTag := na

if hasEvent and showTargetCorridor and targetValid
    int leftX = activeEventBar
    int rightX = bar_index + forwardBars
    float corridorTop = math.max(activeLevel, targetGuide)
    float corridorBottom = math.min(activeLevel, targetGuide)
    int centerX = int(math.round((leftX + rightX) * 0.5))
    float centerY = (corridorTop + corridorBottom) * 0.5
    string roomText = "Room " + f_fmt(roomAtr) + " ATR"
    if na(targetRoomBox)
        targetRoomBox := box.new(left = leftX, top = corridorTop, right = rightX, bottom = corridorBottom, xloc = xloc.bar_index, bgcolor = corridorColor, border_color = color.new(accentColor, 28), border_width = 1)
    else
        box.set_lefttop(targetRoomBox, leftX, corridorTop)
        box.set_rightbottom(targetRoomBox, rightX, corridorBottom)
        box.set_bgcolor(targetRoomBox, corridorColor)
        box.set_border_color(targetRoomBox, color.new(accentColor, 28))
    if na(targetRoomLabel)
        targetRoomLabel := label.new(centerX, centerY, roomText, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_center, textcolor = f_text_on(accentColor), color = color.new(accentColor, 18), size = f_text_size(labelFontSize))
    else
        label.set_x(targetRoomLabel, centerX)
        label.set_y(targetRoomLabel, centerY)
        label.set_text(targetRoomLabel, roomText)
        label.set_textcolor(targetRoomLabel, f_text_on(accentColor))
        label.set_color(targetRoomLabel, color.new(accentColor, 18))
        label.set_size(targetRoomLabel, f_text_size(labelFontSize))
else
    if not na(targetRoomBox)
        box.delete(targetRoomBox)
        targetRoomBox := na
    if not na(targetRoomLabel)
        label.delete(targetRoomLabel)
        targetRoomLabel := na

color activeTint = na
if tintActiveBars and hasEvent and not activeFailed and not activeExpired
    activeTint := color.new(sideColor, activeReclaimed ? 88 : 92)
barcolor(activeTint)

// -------------------------------------------------
// Labels
// -------------------------------------------------
var array<label> eventLabels = array.new_label()
var array<line> eventConnectors = array.new_line()
var int lastEventLabelBar = na
var int lastContextLabelBar = na
var int lastApproachLabelBar = na

bool canPrintEvent = na(lastEventLabelBar) or bar_index - lastEventLabelBar >= labelCooldownBars
bool canPrintContext = na(lastContextLabelBar) or bar_index - lastContextLabelBar >= contextSpacingBars
bool canPrintApproach = na(lastApproachLabelBar) or bar_index - lastApproachLabelBar >= contextSpacingBars
bool activePlanLive = hasEvent and not activeFailed and not activeExpired

bool sellSideApproach = showApproachLabels and confirmedBar and lowLevelFresh and not lastSwingLowSwept and close > lastSwingLow and (close - lastSwingLow) / safeAtr <= 0.80 and close < close[1]
bool buySideApproach = showApproachLabels and confirmedBar and highLevelFresh and not lastSwingHighSwept and close < lastSwingHigh and (lastSwingHigh - close) / safeAtr <= 0.80 and close > close[1]

if (sellSideApproach or buySideApproach) and canPrintApproach and not activePlanLive
    bool approachBull = sellSideApproach
    float anchorY = approachBull ? low : high
    string labelText = approachBull ? "SELL-SIDE NEAR" : "BUY-SIDE NEAR"
    f_add_owned_badge(eventLabels, eventConnectors, bar_index, anchorY, approachBull, labelText, accentColor, safeAtr, maxVisibleLabels)
    lastApproachLabelBar := bar_index

if showEventLabels and confirmedBar and canPrintEvent
    bool printEvent = false
    bool labelBelow = activeSide == 1
    string labelText = ""
    color labelColor = sideColor
    if newLiquidityEvent
        printEvent := true
        labelBelow := chooseSellSideEvent
        labelText := chooseSellSideEvent ? "SELL SWEEP" : "BUY SWEEP"
        labelColor := chooseSellSideEvent ? bullColor : bearColor
    else if reclaimedNow
        printEvent := true
        labelText := "RECLAIM READY"
        labelColor := sideColor
    else if failedNow
        printEvent := true
        labelText := "RECLAIM FAILED"
        labelColor := dangerColor
    else if roomThinAlert
        printEvent := true
        labelText := "ROOM THIN"
        labelColor := neutralColor
    if printEvent
        string scoreSuffix = showLabelScore and hasEvent and not na(reclaimPlannerScore) ? " | Q" + str.tostring(math.round(reclaimPlannerScore)) : ""
        float anchorY = labelBelow ? low : high
        f_add_owned_badge(eventLabels, eventConnectors, bar_index, anchorY, labelBelow, labelText + scoreSuffix, labelColor, safeAtr, maxVisibleLabels)
        lastEventLabelBar := bar_index

if showContextLabels and confirmedBar and hasEvent and canPrintContext and not activeFailed and not activeExpired and not newLiquidityEvent and not reclaimedNow and not roomThinAlert
    bool labelBelow = activeSide == 1
    float anchorY = labelBelow ? low : high
    string contextText = reclaimState == "Planner Ready" ? "PLANNER READY" : reclaimState == "Risk Review" ? "RISK REVIEW" : reclaimState == "Room Thin" ? "ROOM THIN" : "RECLAIM WATCH"
    f_add_owned_badge(eventLabels, eventConnectors, bar_index, anchorY, labelBelow, contextText, f_state_color(reclaimState), safeAtr, maxVisibleLabels)
    lastContextLabelBar := bar_index

// -------------------------------------------------
// Data window
// -------------------------------------------------
plot(reclaimPlannerScore, title = "Reclaim Score", color = sideColor, display = display.data_window)
plot(failureRisk, title = "Failure Risk", color = dangerColor, display = display.data_window)
plot(roomAtr, title = "Target Room ATR", color = accentColor, display = display.data_window)
plot(activeEventDepthAtr, title = "Sweep Depth ATR", color = neutralColor, display = display.data_window)

// -------------------------------------------------
// Panel
// -------------------------------------------------
string eventText = hasEvent ? f_side_text(activeSide) + " / " + (activeReclaimed ? "Reclaimed" : activeExpired ? "Expired" : "Watching") : "No active event"
string scoreText = hasEvent and not na(reclaimPlannerScore) ? str.tostring(math.round(reclaimPlannerScore)) + " / 100 " + f_grade(reclaimPlannerScore) : "-"
string riskText = hasEvent and not na(failureRisk) ? str.tostring(math.round(failureRisk)) + " / 100" : "-"
string roomTextPanel = hasEvent ? f_fmt(roomAtr) + " ATR to structure" : "-"
string targetText = hasEvent and targetValid and not na(targetGuide) ? f_fmt_price(targetGuide) : "-"
string invalText = hasEvent and not na(failureLinePrice) ? f_fmt_price(failureLinePrice) : "-"
color scoreColor = hasEvent and not na(reclaimPlannerScore) ? f_score_color(reclaimPlannerScore) : f_panel_value(panelTheme)
color riskColor = hasEvent and not na(failureRisk) ? f_risk_color(failureRisk) : f_panel_value(panelTheme)

var table infoPanel = na
var string lastPanelLocation = ""
var string lastPanelTheme = ""

if barstate.islast
    if showPanel
        color panelBgActive = f_panel_bg(panelTheme)
        color panelBorderActive = f_panel_border(panelTheme)
        if na(infoPanel) or panelLocation != lastPanelLocation or panelTheme != lastPanelTheme
            if not na(infoPanel)
                table.delete(infoPanel)
            infoPanel := table.new(f_panel_pos(panelLocation), 2, 9, bgcolor = panelBgActive, frame_color = panelBorderActive, frame_width = 1, border_color = panelBorderActive, border_width = 1)
            table.merge_cells(infoPanel, 0, 0, 1, 0)
            lastPanelLocation := panelLocation
            lastPanelTheme := panelTheme
        table.cell(infoPanel, 0, 0, "AG Pro Liquidity Reclaim Planner", text_color = headerText, bgcolor = headerBg, text_size = f_text_size(panelFontSize), text_halign = text.align_center)
        f_set_row(infoPanel, 1, "Liquidity Event", eventText, hasEvent ? sideColor : f_panel_value(panelTheme), panelTheme, panelFontSize)
        f_set_row(infoPanel, 2, "Reclaim Score", scoreText, scoreColor, panelTheme, panelFontSize)
        f_set_row(infoPanel, 3, "Failure Risk", riskText, riskColor, panelTheme, panelFontSize)
        f_set_row(infoPanel, 4, "Target", targetText, hasEvent and targetValid ? accentColor : f_panel_value(panelTheme), panelTheme, panelFontSize)
        f_set_row(infoPanel, 5, "Invalidation", invalText, hasEvent ? dangerColor : f_panel_value(panelTheme), panelTheme, panelFontSize)
        f_set_row(infoPanel, 6, "Room", roomTextPanel, hasEvent and roomAtr >= minimumRoomAtr ? accentColor : neutralColor, panelTheme, panelFontSize)
        f_set_row(infoPanel, 7, "Action", actionText, f_state_color(reclaimState), panelTheme, panelFontSize)
        f_set_row(infoPanel, 8, "Proof", proofText, proofColor, panelTheme, panelFontSize)
    else
        if not na(infoPanel)
            table.delete(infoPanel)
            infoPanel := na
            lastPanelLocation := ""
            lastPanelTheme := ""

// -------------------------------------------------
// Alerts
// -------------------------------------------------
alertcondition(chooseSellSideEvent, title = "Sell-side Liquidity Event", message = "Liquidity Reclaim Planner: sell-side liquidity event detected. Watch for reclaim quality. This is an attention marker, not a trade instruction.")
alertcondition(chooseBuySideEvent, title = "Buy-side Liquidity Event", message = "Liquidity Reclaim Planner: buy-side liquidity event detected. Watch for reclaim quality. This is an attention marker, not a trade instruction.")
alertcondition(reclaimedNow and activeSide == 1, title = "Bullish Reclaim Ready", message = "Liquidity Reclaim Planner: sell-side event has reclaimed with active planner context.")
alertcondition(reclaimedNow and activeSide == -1, title = "Bearish Reclaim Ready", message = "Liquidity Reclaim Planner: buy-side event has reclaimed with active planner context.")
alertcondition(plannerReadyAlert, title = "Planner Ready", message = "Liquidity Reclaim Planner: reclaim score and room are strong enough for planner-ready review.")
alertcondition(failedNow, title = "Failure Line Hit", message = "Liquidity Reclaim Planner: price crossed the active failure line. Review the liquidity reclaim plan.")
alertcondition(roomThinAlert, title = "Target Room Thin", message = "Liquidity Reclaim Planner: reclaim exists but structural target room is thin.")
````
