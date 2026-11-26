# Volume Rejection Planner [AGPro Series]

- url: https://www.tradingview.com/script/2Qf4DujK-Volume-Rejection-Planner-AGPro-Series/
- type: indicator
- pine_id: PUB;ba8b97e82d114c6586d44cfa6c8a44d9
- version: 4.0

## Description

Volume Rejection Planner [AGPro Series]

🧠 Core Idea

Did unusual volume appear at rejection in a way that changes the current decision context?


📌 Overview / What it does

Volume Rejection Planner is a chart-first volume reaction tool built to evaluate wick-led rejection events that appear with elevated relative volume near a recent range edge.

The script maps a volume rejection zone, a risk edge, a follow-through trigger, a room guide, compact state labels, and a clean AGPro planning panel. It converts relative volume, wick quality, close location, range-edge context, follow-through progress, and time decay into a 0-100 rejection quality score.

It does not predict price, automate trades, or mark every volume spike as meaningful. Its purpose is to organize the decision window after volume appears at a rejection wick.


🎯 Purpose & Design Philosophy

This script was built for traders who want more context than a raw volume spike or a simple wick marker.

High volume at a wick can mean participation, absorption, rejection, or noise depending on where it appears and what follows next. The planner focuses on that next question: is the rejection being accepted by follow-through, or is the event failing at its risk edge?

The design supports a decision-engine mindset: identify the rejection, measure its quality, locate invalidation, monitor follow-through, and decide whether the context deserves review, patience, or dismissal.


⚡ Why This Script Is Different

Most tools focus on volume spikes, climax candles, or generic wick rejection labels.

This script does NOT clone a Volume Climax Detector, does not become a Rejection Block tool, and does not draw generic support/resistance zones.

Instead, it treats high-volume wick rejection as a short lifecycle: event, test, accepted follow-through, failed risk edge, expired window, or room-guide reach. The main output is not a raw signal; it is a structured planning state.


⚙️ Methodology

1. Context Detection
The script builds a recent range-edge reference and checks whether the rejection wick occurs near the upper or lower edge.

2. Reference Mapping
When a qualified event appears, it maps the rejection zone, risk edge, follow-through trigger, and room guide.

3. Reaction Evaluation
The model scores relative volume, wick ratio, wick size, close location, edge quality, room, follow-through progress, pressure against the event, and time decay.

4. Visual Output
The result is shown through centered zone text, compact event labels, risk/room guides, candle tint, alerts, and a premium AGPro decision panel.


🗺️ How to Read the Chart

Volume Rejection Zone = the wick-led rejection area created by elevated participation at a range edge.

Risk Edge = the invalidation boundary beyond the rejection wick.

Follow-Through Trigger = the distance price must move away from the rejection to show accepted context.

Room Guide = a forward planning reference used to judge whether the reaction has enough space to matter.

Labels = compact BULL VRP / BEAR VRP markers for primary volume rejection events. Optional secondary labels can show monitor, accepted follow-through, expiry, and room-guide reach when the user wants a more detailed chart.

Colors = teal highlights bullish rejection context, pink highlights bearish rejection context, amber highlights watch context, indigo highlights room/guide context, and red highlights invalidation.

Panel = summarizes Rejection Volume, Wick Quality, Follow-Through, Risk Edge, and Action.

The panel focuses on fresh active context only. Older historical zones can remain on the chart without forcing the panel to display stale invalidated events.


🚦 Signals & States

• Volume Rejection Event → elevated relative volume appears with a qualifying wick near a range edge.

• Testing → the event exists, but accepted follow-through is not confirmed yet.

• Monitor → the active score is high enough to keep the context under review.

• Accepted → price has moved away from the rejection wick enough to confirm follow-through context.

• Risk Edge Broken → the event has moved through its invalidation boundary.

• Window Expired → the event did not confirm within the selected follow-through window.

• Room Guide Reached → the accepted context reached its planning guide.


🔔 Alerts Logic

Alerts trigger when a qualified volume rejection event appears, when the active context reaches READY, when the state changes, when the risk edge is broken, or when the room guide is reached.

Alerts are attention markers only. They are not trade instructions, entry commands, exit commands, or automated strategy rules.


🧩 Confluence Logic

The strongest context appears when high relative volume, a clear wick ratio, a strong close back away from the wick, range-edge location, enough room, and quick follow-through align.

If price fails to move away from the rejection wick, presses back into the risk edge, or loses too much time, the planner downgrades the context.


📊 When to Use

• Range-edge reactions

• Wick rejection events with unusually high participation

• Failed pushes into recent highs or lows

• Markets where volume data is readable

• Situations where the next decision depends on whether rejection follows through


⚠️ When NOT to Use

• Very low-liquidity symbols with unreliable volume

• Extremely noisy micro-timeframes

• News spikes where wick behavior may distort quickly

• Markets where volume reporting is fragmented or unavailable

• Situations where the user expects a direct buy/sell signal


🎛️ Key Inputs

• Sensitivity → controls how strict the volume, wick, and edge requirements are.

• Range Edge Lookback → defines the recent high/low context used for rejection location.

• Minimum Rejection Score → controls which events are important enough to draw.

• Confirmation Mode → adjusts how quickly follow-through can be accepted.

• Follow-Through Window → controls how long the event remains active.

• Risk Edge Buffer → adjusts the invalidation boundary beyond the wick.

• Room Guide ATR → controls the planning guide distance.

• Visual settings → control zones, rails, primary labels, secondary labels, failure labels, candle tint, label density, and text size.

• Limit Historical Drawing / Historical Drawing Bars → controls how far back the script creates visual objects, improving load speed on long histories while preserving the current planning view.

• Adaptive HTF Events → slightly relaxes event thresholds on daily and weekly charts so higher timeframes do not look empty while intraday behavior stays stricter.


🖥️ Interface & Visual Design

The interface is designed to stay chart-first.

The rejection zone provides the visual anchor. The risk edge and room guide frame the planning context. Labels stay compact and offset away from candles so the chart remains active without becoming crowded.

The AGPro panel uses a merged blue title row and a compact five-row decision layout.


🧪 Practical Usage Workflow

1. Read the panel action state.

2. Check whether the rejection zone is bullish or bearish.

3. Review the wick quality and relative volume.

4. Compare current price against the follow-through trigger and risk edge.

5. Treat alerts as attention markers, then evaluate broader market context.


🔍 Interpretation Guidelines

Think in terms of event lifecycle, not prediction.

A stronger score means the rejection had better participation, wick structure, location, room, and follow-through behavior. A weaker or decaying score means the event is losing quality under the current rule set.

Accepted follow-through does not mean price must continue. It means the rejection event has met the script's conditions for stronger review context.


🚫 What This Script Is NOT

• Not a prediction engine

• Not financial advice

• Not auto trading

• Not guaranteed signals

• Not a generic volume spike marker

• Not a Rejection Block clone

• Not a Volume Climax Detector clone


⚠️ Limitations & Transparency

The script is rule-based and depends on recent price, volatility, wick structure, and volume behavior.

Different timeframes can change how rejection and follow-through appear. Volatility spikes can temporarily distort wick size and edge quality. Symbols with weak or unreliable volume may produce less useful readings.

Outputs should always be interpreted within broader structure, liquidity, volatility, and risk context.


🧠 Market Context Notes

Volume rejection is most useful when the wick appears at a meaningful location and the follow-up reaction is clear.

High volume alone is not enough. Location, close behavior, risk edge, and follow-through all matter.


🧾 Use Case Examples

When price pushes above a recent range edge, prints a strong upper wick with elevated RVOL, and then moves away from that wick, the planner may classify the context as accepted bearish rejection.

When price probes below a recent range edge, prints a strong lower wick with elevated RVOL, but then closes below the risk edge, the planner may classify the event as invalidated.


🧱 System Philosophy

AGPro planning tools are designed to help traders evaluate context before reacting.

This script follows that approach by turning high-volume wick rejection into a structured decision question: is the event valid, strong, risky, accepted, or fading?


🔐 Non-Promise Statement

No indicator can provide certainty.

This tool provides structured visual context and rule-based attention markers. It does not guarantee continuation, reversal, rejection, or follow-through.


📉 Risk Disclosure

Trading involves risk. Market conditions can change quickly, and no script can remove uncertainty.

Users are responsible for their own analysis, risk management, and decisions.

This script is for educational and analytical use only and does not provide financial advice.


📚 Educational Note

Use the planner to study how volume behaves at wick rejection points, how quickly follow-through appears after rejection, and how risk edges help separate valid context from failed reaction events.

## Source Code

````pine
// -------------------------------------------------
// Volume Rejection Planner [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 1.3
//
// Volume Rejection Planner is a chart-first volume reaction tool that evaluates
// whether unusually high participation appears at a wick-led rejection point,
// then tracks follow-through, risk edge, room, next-action state, and an
// empirical stop-aware follow-through proof rate. It is built as a decision
// engine for volume rejection context, not as a generic volume spike signal,
// rejection block clone, or prediction tool.
// -------------------------------------------------

//@version=6
indicator("Volume Rejection Planner [AGPro Series]",
     shorttitle = "AG Pro VRP",
     overlay = true,
     max_labels_count = 180,
     max_lines_count = 90,
     max_boxes_count = 45)

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
const string TT_SENS = "Controls how selective the rejection planner is. Responsive finds more events; Strict requires stronger volume, cleaner wick rejection, and better edge context."
const string TT_LOOKBACK = "Rolling high/low window used to decide whether a wick rejection is occurring near a meaningful range edge instead of in random mid-range noise."
const string TT_VOL = "Volume baseline used to calculate relative volume. The model reads participation context; it does not guarantee institutional activity."
const string TT_ATR = "ATR normalizes wick size, edge tolerance, risk edge, follow-through distance, room guide, proof distances, and label offsets across symbols."
const string TT_MIN_SCORE = "Minimum 0-100 quality score required before a volume rejection event can create a primary zone."
const string TT_CONFIRM = "Controls how the planner classifies follow-through. Early reacts sooner, Balanced is the publication default, and Strict requires cleaner continuation away from the rejection wick."
const string TT_HTF_ADAPT = "Relaxes event thresholds on daily and weekly charts so higher timeframes do not look empty. Intraday behavior remains unchanged."
const string TT_WICK = "Minimum wick-to-body ratio required for a candle to qualify as wick-led rejection."
const string TT_RVOL = "Relative volume level that must be reached before a rejection candle can qualify. The final threshold is adjusted by Sensitivity."
const string TT_EDGE = "ATR distance allowed between the wick and the active range edge. Smaller values require the rejection to occur closer to the edge."
const string TT_MIN_WICK_ATR = "Minimum wick size in ATR terms. This filters out small cosmetic wicks that do not create meaningful rejection context."
const string TT_FOLLOW = "ATR distance price should travel away from the rejection wick before follow-through is considered accepted."
const string TT_RISK = "ATR buffer placed beyond the rejection wick to build the invalidation risk edge."
const string TT_ROOM = "Minimum ATR distance used for the room guide. It is a planning reference, not a price target promise."
const string TT_WINDOW = "Number of bars the planner will monitor after a qualified rejection event before the context can expire."
const string TT_ZONES = "Shows each retained volume rejection zone with its own centered identity badge. Zone and badge objects are retained and removed together."
const string TT_RAILS = "Shows the explicitly owned Risk Edge and Room Guide rails for the active rejection context."
const string TT_LABELS = "Shows event-state badges when rejection zones are hidden, plus any enabled secondary or failure states. Primary source badges are suppressed while centered zone badges already own the event."
const string TT_SECONDARY_LABELS = "Shows extra follow-through, monitor, expiry, and room-guide labels. Disabled by default because the zone and panel already carry those states."
const string TT_SCORE_LABEL = "Adds the 0-100 quality score to chart labels. Disabled by default to keep the publication view cleaner; zone and panel scores remain visible."
const string TT_FAILURE_LABELS = "Shows separate red invalidation labels when the risk edge breaks. Disabled by default because failed state is already shown inside the zone and panel."
const string TT_CANDLES = "Applies a subtle candle tint while a volume rejection context is active."
const string TT_COOLDOWN = "Minimum bars between new primary rejection labels. Higher values reduce clustering."
const string TT_CONTEXT_SPACING = "Minimum bars between lighter context labels such as monitor and guide-reached states."
const string TT_MAX_LABELS = "Maximum visible chart labels retained by the script. Older labels are deleted first for performance."
const string TT_MAX_ZONES = "Maximum visible rejection zones retained on the chart. Each retained zone keeps its centered identity badge; older zone-badge pairs are removed atomically."
const string TT_PROJECTION = "Number of bars projected to the right for rejection zones, risk edges, and room guides."
const string TT_HISTORY_LIMIT = "Limits historical object drawing to recent bars. This keeps the script fast on symbols with long chart histories while preserving the current planning view."
const string TT_HISTORY_BARS = "Number of recent bars allowed to create zones, guide lines, and labels when historical drawing is limited."
const string TT_OFFSET = "ATR-based vertical offset used to keep labels away from candle bodies."
const string TT_LABEL_SIZE = "Controls every chart label and centered zone label size. Normal is the recommended public-release default."
const string TT_BADGE_LANES = "Separates rejection-zone, event, risk, and room-guide badges into ATR-based visual lanes so meaningful labels remain readable without stacking on the same price band."
const string TT_BADGE_SPACING = "Controls the vertical distance between smart badge lanes. Increase it on compressed charts if labels need more breathing room."
const string TT_PANEL_SHOW = "Shows or hides the AG Pro planning panel. It is enabled by default for publication-ready first load."
const string TT_PANEL_LOCATION = "Moves the AG Pro panel to the preferred chart location."
const string TT_PANEL_THEME = "Switches the panel between the premium AGPro dark theme and a clean light theme."
const string TT_PANEL_SIZE = "Controls panel text size. Normal is the recommended public-release default."
const string TT_ALERT_SCORE = "Minimum active score required before READY and major follow-through alerts can trigger."
const string TT_PROOF_WINDOW = "Maximum bars a follow-through proof window stays open before it is left uncounted in the proof rate."

// -------------------------------------------------
// Inputs
// -------------------------------------------------
string groupEngine = "Volume Rejection Engine"
string sensitivityInput = input.string("Balanced", "Sensitivity", options = ["Responsive", "Balanced", "Strict"], group = groupEngine, tooltip = TT_SENS)
int edgeLookbackInput = input.int(48, "Range Edge Lookback", minval = 12, maxval = 300, group = groupEngine, tooltip = TT_LOOKBACK)
int volumeLengthInput = input.int(34, "Volume Baseline Length", minval = 5, maxval = 250, group = groupEngine, tooltip = TT_VOL)
int atrLengthInput = input.int(14, "ATR Length", minval = 5, maxval = 100, group = groupEngine, tooltip = TT_ATR)
int minimumScoreInput = input.int(58, "Minimum Rejection Score", minval = 30, maxval = 95, group = groupEngine, tooltip = TT_MIN_SCORE)
string confirmationModeInput = input.string("Balanced", "Confirmation Mode", options = ["Early", "Balanced", "Strict"], group = groupEngine, tooltip = TT_CONFIRM)
bool adaptiveHtfInput = input.bool(true, "Adaptive HTF Events", group = groupEngine, tooltip = TT_HTF_ADAPT)

string groupModel = "Planner Model"
float wickRatioInput = input.float(1.65, "Minimum Wick Ratio", minval = 0.50, maxval = 8.00, step = 0.05, group = groupModel, tooltip = TT_WICK)
float rvolThresholdInput = input.float(1.35, "Base RVOL Threshold", minval = 0.50, maxval = 6.00, step = 0.05, group = groupModel, tooltip = TT_RVOL)
float edgeToleranceAtrInput = input.float(0.42, "Range Edge Tolerance ATR", minval = 0.05, maxval = 3.00, step = 0.01, group = groupModel, tooltip = TT_EDGE)
float minWickAtrInput = input.float(0.24, "Minimum Wick Size ATR", minval = 0.02, maxval = 2.50, step = 0.01, group = groupModel, tooltip = TT_MIN_WICK_ATR)
float followThroughAtrInput = input.float(0.72, "Follow-Through ATR", minval = 0.10, maxval = 5.00, step = 0.05, group = groupModel, tooltip = TT_FOLLOW)
float riskBufferAtrInput = input.float(0.18, "Risk Edge Buffer ATR", minval = 0.00, maxval = 2.00, step = 0.01, group = groupModel, tooltip = TT_RISK)
float roomGuideAtrInput = input.float(1.75, "Room Guide ATR", minval = 0.30, maxval = 8.00, step = 0.05, group = groupModel, tooltip = TT_ROOM)
int trackingWindowInput = input.int(28, "Follow-Through Window", minval = 5, maxval = 120, group = groupModel, tooltip = TT_WINDOW)

string groupVisual = "Chart Visuals"
bool showZonesInput = input.bool(true, "Show Rejection Zones", group = groupVisual, tooltip = TT_ZONES)
bool showRailsInput = input.bool(true, "Show Risk / Room Guides", group = groupVisual, tooltip = TT_RAILS)
bool showEventLabelsInput = input.bool(true, "Show State Labels", group = groupVisual, tooltip = TT_LABELS)
bool showSecondaryLabelsInput = input.bool(false, "Show Secondary Labels", group = groupVisual, tooltip = TT_SECONDARY_LABELS)
bool showLabelScoresInput = input.bool(false, "Show Label Scores", group = groupVisual, tooltip = TT_SCORE_LABEL)
bool showFailureLabelsInput = input.bool(false, "Show Failure Labels", group = groupVisual, tooltip = TT_FAILURE_LABELS)
bool tintCandlesInput = input.bool(true, "Tint Active Context Candles", group = groupVisual, tooltip = TT_CANDLES)
int labelCooldownInput = input.int(12, "Event Label Cooldown", minval = 1, maxval = 120, group = groupVisual, tooltip = TT_COOLDOWN)
int contextSpacingInput = input.int(34, "Context Label Spacing", minval = 5, maxval = 160, group = groupVisual, tooltip = TT_CONTEXT_SPACING)
int maxVisibleLabelsInput = input.int(5, "Max Visible Labels", minval = 4, maxval = 80, group = groupVisual, tooltip = TT_MAX_LABELS)
int maxVisibleZonesInput = input.int(4, "Max Visible Zones", minval = 1, maxval = 18, group = groupVisual, tooltip = TT_MAX_ZONES)
int projectionBarsInput = input.int(30, "Forward Projection Bars", minval = 8, maxval = 180, group = groupVisual, tooltip = TT_PROJECTION)
bool limitHistoryInput = input.bool(true, "Limit Historical Drawing", group = groupVisual, tooltip = TT_HISTORY_LIMIT)
int historyBarsInput = input.int(650, "Historical Drawing Bars", minval = 150, maxval = 2500, group = groupVisual, tooltip = TT_HISTORY_BARS)
float labelOffsetAtrInput = input.float(0.86, "Label Offset ATR", minval = 0.10, maxval = 4.00, step = 0.05, group = groupVisual, tooltip = TT_OFFSET)
string labelSizeInput = input.string("Normal", "Label Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = groupVisual, tooltip = TT_LABEL_SIZE)
bool useSmartBadgeLanesInput = input.bool(true, "Use Smart Badge Lanes", group = groupVisual, tooltip = TT_BADGE_LANES)
float badgeLaneAtrInput = input.float(0.34, "Badge Lane Spacing ATR", minval = 0.10, maxval = 1.25, step = 0.05, group = groupVisual, tooltip = TT_BADGE_SPACING)

string groupPanel = "Panel"
bool showPanelInput = input.bool(true, "Show Panel", group = groupPanel, tooltip = TT_PANEL_SHOW)
string panelLocationInput = input.string("Top Right", "Panel Location", options = ["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], group = groupPanel, tooltip = TT_PANEL_LOCATION)
string panelThemeInput = input.string("Elite Dark", "Panel Theme", options = ["Elite Dark", "Clean Light"], group = groupPanel, tooltip = TT_PANEL_THEME)
string panelSizeInput = input.string("Normal", "Panel Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = groupPanel, tooltip = TT_PANEL_SIZE)

string groupAlerts = "Alerts"
int alertScoreInput = input.int(66, "Minimum Alert Score", minval = 40, maxval = 95, group = groupAlerts, tooltip = TT_ALERT_SCORE)
int proofWindowInput = input.int(28, "Proof Window Bars", minval = 5, maxval = 200, group = groupAlerts, tooltip = TT_PROOF_WINDOW)

// -------------------------------------------------
// Helpers
// -------------------------------------------------
f_clamp(float value, float minValue, float maxValue) =>
    math.max(minValue, math.min(maxValue, value))

// Luminance-based contrast: dark ink on bright fills, light ink on dark fills.
f_text_on(color bg) =>
    float lum = 0.299 * color.r(bg) + 0.587 * color.g(bg) + 0.114 * color.b(bg)
    lum > 145 ? color.rgb(17, 24, 39) : headerText

// Vertical anti-collision: nudge a new label away from nearby existing labels.
f_avoid_overlap(label[] labels, float desiredY, bool placeAbove, float safe) =>
    float y = desiredY
    float minGap = safe * 1.1
    int n = array.size(labels)
    if n > 0
        bool moved = true
        int guard = 0
        while moved and guard < 18
            moved := false
            for i = 0 to n - 1
                label lb = array.get(labels, i)
                if math.abs(label.get_x(lb) - bar_index) <= 24
                    if math.abs(label.get_y(lb) - y) < minGap
                        y := placeAbove ? y + minGap : y - minGap
                        moved := true
            guard += 1
    y

f_norm_high_good(float value, float weakValue, float strongValue) =>
    float span = math.max(strongValue - weakValue, 0.000001)
    f_clamp((value - weakValue) / span * 100.0, 0.0, 100.0)

f_norm_low_good(float value, float strongValue, float weakValue) =>
    float span = math.max(weakValue - strongValue, 0.000001)
    f_clamp((weakValue - value) / span * 100.0, 0.0, 100.0)

f_size(string value) =>
    switch value
        "Tiny" => size.tiny
        "Small" => size.small
        "Large" => size.large
        => size.normal

f_panel_position(string location) =>
    switch location
        "Top Left" => position.top_left
        "Top Center" => position.top_center
        "Top Right" => position.top_right
        "Middle Left" => position.middle_left
        "Middle Right" => position.middle_right
        "Bottom Left" => position.bottom_left
        "Bottom Center" => position.bottom_center
        => position.bottom_right

f_panel_bg() =>
    panelThemeInput == "Clean Light" ? color.rgb(248, 250, 252) : panelBg

f_panel_border() =>
    panelThemeInput == "Clean Light" ? color.rgb(203, 213, 225) : panelBorder

f_panel_label() =>
    panelThemeInput == "Clean Light" ? color.rgb(71, 85, 105) : panelLabelCol

f_panel_value() =>
    panelThemeInput == "Clean Light" ? color.rgb(15, 23, 42) : panelValueCol

f_panel_row_bg(int row) =>
    if panelThemeInput == "Clean Light"
        row % 2 == 0 ? color.rgb(241, 245, 249) : color.rgb(248, 250, 252)
    else
        row % 2 == 0 ? color.rgb(20, 31, 52) : panelBg

f_panel_row(table target, int row, string leftText, string rightText, color valueColor, string fontSize) =>
    color bg = f_panel_row_bg(row)
    table.cell(target, 0, row, leftText, text_color = f_panel_label(), bgcolor = bg, text_size = f_size(fontSize), text_halign = text.align_left)
    table.cell(target, 1, row, rightText, text_color = valueColor, bgcolor = bg, text_size = f_size(fontSize), text_halign = text.align_right)

f_panel_row_fill(table target, int row, string leftText, string rightText, color fillColor, string fontSize) =>
    color bg = f_panel_row_bg(row)
    table.cell(target, 0, row, leftText, text_color = f_panel_label(), bgcolor = bg, text_size = f_size(fontSize), text_halign = text.align_left)
    table.cell(target, 1, row, rightText, text_color = f_text_on(fillColor), bgcolor = fillColor, text_size = f_size(fontSize), text_halign = text.align_right)

f_score_color(float score) =>
    score >= 76 ? bullColor : score >= 62 ? accentColor : score >= 48 ? neutralColor : bearColor

f_side_color(int side) =>
    side == 1 ? bullColor : side == -1 ? bearColor : neutralColor

f_state_color(string state, int side, float score) =>
    color result = f_score_color(score)
    if state == "ACCEPTED"
        result := f_side_color(side)
    else if state == "TESTING"
        result := accentColor
    else if state == "FAILED"
        result := dangerColor
    else if state == "EXPIRED"
        result := color.rgb(100, 116, 139)
    result

f_action_color(string actionText) =>
    switch actionText
        "READY" => bullColor
        "MONITOR" => accentColor
        "WAIT" => neutralColor
        "INVALIDATED" => dangerColor
        "EXPIRED" => color.rgb(100, 116, 139)
        => neutralColor

f_format_price(float value) =>
    na(value) ? "-" : str.tostring(value, format.mintick)

f_format_score(float value) =>
    na(value) ? "-" : str.tostring(math.round(value)) + "/100"

f_compact_score(float value) =>
    na(value) ? "Q -" : "Q " + str.tostring(math.round(value))

f_grade(float score) =>
    score >= 86 ? "A+" : score >= 76 ? "A" : score >= 64 ? "B" : score >= 52 ? "C" : "D"

f_badge_step(float atrValue) =>
    math.max(math.max(atrValue, syminfo.mintick) * badgeLaneAtrInput, syminfo.mintick * 20.0)

f_rejection_badge_y(float basePrice, int side, int lane, float atrValue) =>
    float dir = side == 1 ? -1.0 : side == -1 ? 1.0 : 1.0
    useSmartBadgeLanesInput ? basePrice + dir * f_badge_step(atrValue) * lane : basePrice

f_follow_badge_y(float basePrice, int side, int lane, float atrValue) =>
    float dir = side == 1 ? 1.0 : side == -1 ? -1.0 : 1.0
    useSmartBadgeLanesInput ? basePrice + dir * f_badge_step(atrValue) * lane : basePrice

f_trim_labels(label[] ids, int limit) =>
    while array.size(ids) > limit
        label.delete(array.shift(ids))

f_trim_zone_pairs(box[] boxes, label[] badges, int limit) =>
    while array.size(boxes) > limit
        box oldBox = array.shift(boxes)
        label oldBadge = array.shift(badges)
        if not na(oldBox)
            box.delete(oldBox)
        if not na(oldBadge)
            label.delete(oldBadge)

// -------------------------------------------------
// Core Calculations
// -------------------------------------------------
float atrRaw = ta.atr(atrLengthInput)
float atr = math.max(nz(atrRaw, ta.tr(true)), syminfo.mintick)
float volumeNow = nz(volume, 0.0)
float volumeBase = ta.sma(volumeNow, volumeLengthInput)
float rvol = volumeBase > 0.0 ? volumeNow / volumeBase : 1.0
bool processVisualHistory = not limitHistoryInput or bar_index >= last_bar_index - historyBarsInput

float rangeHigh = ta.highest(high[1], edgeLookbackInput)
float rangeLow = ta.lowest(low[1], edgeLookbackInput)
float rangeHeight = rangeHigh - rangeLow
bool rangeReady = not na(rangeHigh) and not na(rangeLow) and rangeHeight > syminfo.mintick

float candleRange = math.max(high - low, syminfo.mintick)
float bodySize = math.max(math.abs(close - open), syminfo.mintick)
float bodyTop = math.max(open, close)
float bodyBottom = math.min(open, close)
float upperWick = math.max(high - bodyTop, 0.0)
float lowerWick = math.max(bodyBottom - low, 0.0)
float upperWickRatio = upperWick / bodySize
float lowerWickRatio = lowerWick / bodySize
float closeLocation = (close - low) / candleRange

float sensitivityRvolMult = sensitivityInput == "Strict" ? 1.22 : sensitivityInput == "Responsive" ? 0.86 : 1.00
float sensitivityWickMult = sensitivityInput == "Strict" ? 1.18 : sensitivityInput == "Responsive" ? 0.86 : 1.00
float sensitivityCloseNeed = sensitivityInput == "Strict" ? 0.64 : sensitivityInput == "Responsive" ? 0.54 : 0.58
float modeFollowMult = confirmationModeInput == "Strict" ? 1.18 : confirmationModeInput == "Early" ? 0.82 : 1.00
float htfThresholdMult = adaptiveHtfInput and timeframe.isweekly ? 0.84 : adaptiveHtfInput and timeframe.isdaily ? 0.91 : 1.00
float htfScoreRelax = adaptiveHtfInput and timeframe.isweekly ? 12.0 : adaptiveHtfInput and timeframe.isdaily ? 8.0 : 0.0
float effectiveScoreFloor = math.max(42.0, minimumScoreInput - htfScoreRelax)

float activeRvolNeed = rvolThresholdInput * sensitivityRvolMult * htfThresholdMult
float activeWickNeed = wickRatioInput * sensitivityWickMult * htfThresholdMult
float activeFollowNeed = followThroughAtrInput * modeFollowMult
float fullRvolScore = activeRvolNeed * 2.15
float fullWickScore = activeWickNeed * 2.25

bool nearUpperEdge = rangeReady and high >= rangeHigh - atr * edgeToleranceAtrInput
bool nearLowerEdge = rangeReady and low <= rangeLow + atr * edgeToleranceAtrInput
float upperEdgeDistanceAtr = rangeReady ? math.abs(rangeHigh - high) / atr : na
float lowerEdgeDistanceAtr = rangeReady ? math.abs(low - rangeLow) / atr : na

bool upperVolumeRejection = processVisualHistory and nearUpperEdge and rvol >= activeRvolNeed and upperWickRatio >= activeWickNeed and upperWick >= atr * minWickAtrInput and closeLocation <= 1.0 - sensitivityCloseNeed
bool lowerVolumeRejection = processVisualHistory and nearLowerEdge and rvol >= activeRvolNeed and lowerWickRatio >= activeWickNeed and lowerWick >= atr * minWickAtrInput and closeLocation >= sensitivityCloseNeed

f_event_score(int side, float wickRatio, float wickSize, float edgeDistanceAtr) =>
    float closeScore = side == 1 ? f_clamp(closeLocation * 18.0, 0.0, 18.0) : f_clamp((1.0 - closeLocation) * 18.0, 0.0, 18.0)
    float volumeScore = f_norm_high_good(rvol, activeRvolNeed * 0.80, fullRvolScore) * 0.28
    float wickScore = f_norm_high_good(wickRatio, activeWickNeed, fullWickScore) * 0.24
    float wickSizeScore = f_norm_high_good(wickSize / atr, minWickAtrInput, minWickAtrInput * 3.50) * 0.12
    float edgeScore = f_norm_low_good(edgeDistanceAtr, 0.0, edgeToleranceAtrInput * 1.80) * 0.16
    float roomAtr = side == 1 ? (rangeHigh - close) / atr : (close - rangeLow) / atr
    float roomScore = f_norm_high_good(roomAtr, 0.40, roomGuideAtrInput) * 0.12
    math.round(f_clamp(volumeScore + wickScore + wickSizeScore + edgeScore + closeScore + roomScore, 0.0, 100.0))

float bullEventScore = lowerVolumeRejection ? f_event_score(1, lowerWickRatio, lowerWick, lowerEdgeDistanceAtr) : na
float bearEventScore = upperVolumeRejection ? f_event_score(-1, upperWickRatio, upperWick, upperEdgeDistanceAtr) : na
bool bullQualified = lowerVolumeRejection and bullEventScore >= effectiveScoreFloor
bool bearQualified = upperVolumeRejection and bearEventScore >= effectiveScoreFloor

// -------------------------------------------------
// Active Event State
// -------------------------------------------------
var int activeSide = 0
var int activeStartBar = na
var float activeTop = na
var float activeBottom = na
var float activeClose = na
var float activeAtr = na
var float activeBaseScore = na
var float activeScore = na
var float activeRiskEdge = na
var float activeFollowLevel = na
var float activeRoomGuide = na
var float activeRvol = na
var float activeWickRatio = na
var string activeState = "NONE"
var bool activeAccepted = false
var bool activeFailed = false
var bool activeExpired = false
var bool activeGuideReached = false
var bool activeVisualFrozen = false
var int activeVisualRight = na
var box activeZone = na
var label activeZoneLabel = na
var line activeRiskLine = na
var line activeRoomLine = na
var label activeRiskTag = na
var label activeRoomTag = na
var int lastEventBar = na
var int lastContextBar = na
var label[] eventLabels = array.new_label()
var box[] rejectionZones = array.new_box()
var label[] rejectionZoneBadges = array.new_label()

bool newEvent = false
bool newReady = false
bool newStateShift = false
bool newInvalidated = false
bool newMajorFollow = false

labelSize = f_size(labelSizeInput)

f_add_label(int x, float y, string labelTextValue, string styleValue, color bgColor) =>
    if showEventLabelsInput
        bool placeAbove = styleValue == label.style_label_down
        float adjY = f_avoid_overlap(eventLabels, y, placeAbove, atr)
        label id = label.new(x, adjY, labelTextValue, xloc = xloc.bar_index, style = styleValue, color = bgColor, textcolor = f_text_on(bgColor), size = labelSize)
        array.push(eventLabels, id)
        f_trim_labels(eventLabels, maxVisibleLabelsInput)

f_zone_badge(int x, float y, string labelTextValue, color bgColor) =>
    label.new(x, y, labelTextValue, xloc = xloc.bar_index, style = label.style_label_center, color = bgColor, textcolor = f_text_on(bgColor), size = labelSize)

bool cooldownReady = na(lastEventBar) or bar_index - lastEventBar >= labelCooldownInput
int eventSide = processVisualHistory and bullQualified and (not bearQualified or bullEventScore >= bearEventScore) ? 1 : processVisualHistory and bearQualified ? -1 : 0
float eventScore = eventSide == 1 ? bullEventScore : eventSide == -1 ? bearEventScore : na

if eventSide != 0 and cooldownReady
    if not na(activeZoneLabel)
        activeZoneLabel := na
    if not na(activeRiskLine)
        line.delete(activeRiskLine)
        activeRiskLine := na
    if not na(activeRoomLine)
        line.delete(activeRoomLine)
        activeRoomLine := na
    if not na(activeRiskTag)
        label.delete(activeRiskTag)
        activeRiskTag := na
    if not na(activeRoomTag)
        label.delete(activeRoomTag)
        activeRoomTag := na
    activeSide := eventSide
    activeStartBar := bar_index
    activeAtr := atr
    activeClose := close
    activeBaseScore := eventScore
    activeScore := eventScore
    activeRvol := rvol
    activeWickRatio := eventSide == 1 ? lowerWickRatio : upperWickRatio
    activeAccepted := false
    activeFailed := false
    activeExpired := false
    activeGuideReached := false
    activeVisualFrozen := false
    activeVisualRight := na
    activeState := "TESTING"
    activeTop := eventSide == 1 ? bodyBottom : high
    activeBottom := eventSide == 1 ? low : bodyTop
    activeRiskEdge := eventSide == 1 ? low - atr * riskBufferAtrInput : high + atr * riskBufferAtrInput
    activeFollowLevel := eventSide == 1 ? close + atr * activeFollowNeed : close - atr * activeFollowNeed
    float structuralGuide = eventSide == 1 ? rangeHigh : rangeLow
    float minimumGuide = eventSide == 1 ? close + atr * roomGuideAtrInput : close - atr * roomGuideAtrInput
    activeRoomGuide := eventSide == 1 ? math.max(structuralGuide, minimumGuide) : math.min(structuralGuide, minimumGuide)
    color sideColor = f_side_color(eventSide)
    color zoneFill = showZonesInput ? color.new(sideColor, 84) : color.new(sideColor, 100)
    color zoneBorder = showZonesInput ? color.new(sideColor, 5) : color.new(sideColor, 100)
    string sideText = eventSide == 1 ? "BULL" : "BEAR"
    string zoneText = sideText + " REJECT | TEST " + f_compact_score(eventScore)
    int zoneCenterX = int(math.round((bar_index + bar_index + projectionBarsInput) / 2.0))
    float zoneCenterY = (activeTop + activeBottom) / 2.0
    activeZone := box.new(left = bar_index, top = activeTop, right = bar_index + projectionBarsInput, bottom = activeBottom, xloc = xloc.bar_index,
         bgcolor = zoneFill, border_color = zoneBorder, border_width = 1, text = "",
         text_color = headerText, text_size = labelSize, text_halign = text.align_center, text_valign = text.align_center)
    if showZonesInput
        activeZoneLabel := f_zone_badge(zoneCenterX, zoneCenterY, zoneText, color.new(sideColor, 10))
    activeRiskLine := line.new(x1 = bar_index, y1 = activeRiskEdge, x2 = bar_index + projectionBarsInput, y2 = activeRiskEdge, xloc = xloc.bar_index,
         color = showRailsInput ? color.new(dangerColor, 0) : color.new(dangerColor, 100), style = line.style_dotted, width = 1)
    activeRoomLine := line.new(x1 = bar_index, y1 = activeRoomGuide, x2 = bar_index + projectionBarsInput, y2 = activeRoomGuide, xloc = xloc.bar_index,
         color = showRailsInput ? color.new(accentColor, 0) : color.new(accentColor, 100), style = line.style_dashed, width = 1)
    if showRailsInput
        activeRiskTag := label.new(bar_index + projectionBarsInput, activeRiskEdge, "RISK EDGE", xloc = xloc.bar_index, style = label.style_label_left, color = dangerColor, textcolor = f_text_on(dangerColor), size = labelSize)
        activeRoomTag := label.new(bar_index + projectionBarsInput, activeRoomGuide, "ROOM GUIDE", xloc = xloc.bar_index, style = label.style_label_left, color = accentColor, textcolor = f_text_on(accentColor), size = labelSize)
    array.push(rejectionZones, activeZone)
    array.push(rejectionZoneBadges, activeZoneLabel)
    f_trim_zone_pairs(rejectionZones, rejectionZoneBadges, maxVisibleZonesInput)
    if not showZonesInput
        string labelText = sideText + " VRP"
        if showLabelScoresInput
            labelText += " " + f_compact_score(eventScore)
        float labelY = useSmartBadgeLanesInput ? f_rejection_badge_y(activeClose, eventSide, 2, atr) : (eventSide == 1 ? low - atr * labelOffsetAtrInput : high + atr * labelOffsetAtrInput)
        string labelStyle = eventSide == 1 ? label.style_label_up : label.style_label_down
        f_add_label(bar_index, labelY, labelText, labelStyle, sideColor)
    lastEventBar := bar_index
    lastContextBar := bar_index
    newEvent := true
    newStateShift := true

bool hasActive = activeSide != 0 and not na(activeStartBar)
int activeAge = hasActive ? bar_index - activeStartBar : 0

if hasActive
    float progressAtr = activeSide == 1 ? (high - activeClose) / activeAtr : (activeClose - low) / activeAtr
    float pressureAgainstAtr = activeSide == 1 ? (activeClose - low) / activeAtr : (high - activeClose) / activeAtr
    float progressBonus = f_norm_high_good(progressAtr, 0.0, activeFollowNeed) * 0.15
    float pressurePenalty = f_norm_high_good(pressureAgainstAtr, activeFollowNeed * 0.35, activeFollowNeed * 1.45) * 0.12
    float timePenalty = f_norm_high_good(activeAge, trackingWindowInput * 0.35, trackingWindowInput) * 0.14
    activeScore := f_clamp(activeBaseScore + progressBonus - pressurePenalty - timePenalty, 0.0, 100.0)

    bool hitRisk = activeSide == 1 ? close < activeRiskEdge : close > activeRiskEdge
    bool hitFollow = activeSide == 1 ? high >= activeFollowLevel : low <= activeFollowLevel
    bool hitGuide = activeSide == 1 ? high >= activeRoomGuide : low <= activeRoomGuide
    bool hitExpiry = activeAge > trackingWindowInput and not activeAccepted and not activeFailed

    if not activeFailed and hitRisk
        activeFailed := true
        activeVisualFrozen := true
        activeVisualRight := bar_index + math.min(projectionBarsInput, 8)
        activeState := "FAILED"
        if showFailureLabelsInput
            float failY = useSmartBadgeLanesInput ? f_rejection_badge_y(activeRiskEdge, activeSide, 2, atr) : (activeSide == 1 ? low - atr * labelOffsetAtrInput : high + atr * labelOffsetAtrInput)
            string failStyle = activeSide == 1 ? label.style_label_up : label.style_label_down
            f_add_label(bar_index, failY, "RISK EDGE BROKEN", failStyle, dangerColor)
        newInvalidated := true
        newStateShift := true

    if not activeAccepted and not activeFailed and hitFollow
        activeAccepted := true
        activeState := "ACCEPTED"
        if showSecondaryLabelsInput
            float acceptY = useSmartBadgeLanesInput ? f_follow_badge_y(activeFollowLevel, activeSide, 1, atr) : (activeSide == 1 ? high + atr * labelOffsetAtrInput : low - atr * labelOffsetAtrInput)
            string acceptStyle = activeSide == 1 ? label.style_label_down : label.style_label_up
            string acceptText = "FOLLOW ACCEPTED"
            if showLabelScoresInput
                acceptText += " " + f_compact_score(activeScore)
            f_add_label(bar_index, acceptY, acceptText, acceptStyle, f_side_color(activeSide))
        newReady := activeScore >= alertScoreInput
        newStateShift := true

    if not activeGuideReached and activeAccepted and hitGuide
        activeGuideReached := true
        activeVisualFrozen := true
        activeVisualRight := bar_index + math.min(projectionBarsInput, 8)
        if showSecondaryLabelsInput
            float guideY = useSmartBadgeLanesInput ? f_follow_badge_y(activeRoomGuide, activeSide, 1, atr) : (activeSide == 1 ? high + atr * (labelOffsetAtrInput + 0.20) : low - atr * (labelOffsetAtrInput + 0.20))
            string guideStyle = activeSide == 1 ? label.style_label_down : label.style_label_up
            f_add_label(bar_index, guideY, "ROOM GUIDE REACHED", guideStyle, accentColor)
        newMajorFollow := activeScore >= alertScoreInput
        newStateShift := true

    if not activeExpired and hitExpiry
        activeExpired := true
        activeVisualFrozen := true
        activeVisualRight := bar_index + math.min(projectionBarsInput, 8)
        activeState := "EXPIRED"
        if showSecondaryLabelsInput and (na(lastContextBar) or bar_index - lastContextBar >= contextSpacingInput)
            float expireY = useSmartBadgeLanesInput ? f_rejection_badge_y(activeClose, activeSide, 3, atr) : (activeSide == 1 ? low - atr * labelOffsetAtrInput : high + atr * labelOffsetAtrInput)
            string expireStyle = activeSide == 1 ? label.style_label_up : label.style_label_down
            f_add_label(bar_index, expireY, "WINDOW EXPIRED", expireStyle, color.rgb(100, 116, 139))
            lastContextBar := bar_index
        newStateShift := true

    if not activeAccepted and not activeFailed and not activeExpired
        activeState := "TESTING"
        if showSecondaryLabelsInput and activeScore >= minimumScoreInput and (na(lastContextBar) or bar_index - lastContextBar >= contextSpacingInput)
            float monitorY = useSmartBadgeLanesInput ? f_rejection_badge_y(activeClose, activeSide, 3, atr) : (activeSide == 1 ? low - atr * labelOffsetAtrInput : high + atr * labelOffsetAtrInput)
            string monitorStyle = activeSide == 1 ? label.style_label_up : label.style_label_down
            f_add_label(bar_index, monitorY, "MONITOR " + f_compact_score(activeScore), monitorStyle, accentColor)
            lastContextBar := bar_index

    bool shouldUpdateVisuals = not activeVisualFrozen or newStateShift
    int visualRight = activeVisualFrozen and not na(activeVisualRight) ? activeVisualRight : bar_index + projectionBarsInput
    if shouldUpdateVisuals and not na(activeZone)
        string sideTextUpdate = activeSide == 1 ? "BULL" : "BEAR"
        string zoneState = activeFailed ? "FAILED" : activeAccepted ? "ACCEPTED" : activeExpired ? "EXPIRED" : "TESTING"
        string compactState = activeFailed ? "FAIL" : activeAccepted ? "ACCEPT" : activeExpired ? "EXPIRED" : "TEST"
        string boxText = sideTextUpdate + " REJECT | " + compactState + " " + f_compact_score(activeScore)
        color stateColor = f_state_color(zoneState, activeSide, activeScore)
        box.set_right(activeZone, visualRight)
        box.set_text(activeZone, "")
        box.set_bgcolor(activeZone, showZonesInput ? color.new(stateColor, 84) : color.new(stateColor, 100))
        box.set_border_color(activeZone, showZonesInput ? color.new(stateColor, 5) : color.new(stateColor, 100))
        if showZonesInput and not na(activeZoneLabel)
            label.set_x(activeZoneLabel, int(math.round((activeStartBar + visualRight) / 2.0)))
            label.set_y(activeZoneLabel, (activeTop + activeBottom) / 2.0)
            label.set_text(activeZoneLabel, boxText)
            label.set_color(activeZoneLabel, color.new(stateColor, 10))
            label.set_textcolor(activeZoneLabel, f_text_on(stateColor))
            label.set_size(activeZoneLabel, labelSize)
    if shouldUpdateVisuals and not na(activeRiskLine)
        line.set_x2(activeRiskLine, visualRight)
        line.set_color(activeRiskLine, showRailsInput ? color.new(dangerColor, 0) : color.new(dangerColor, 100))
    if shouldUpdateVisuals and not na(activeRoomLine)
        line.set_x2(activeRoomLine, visualRight)
        line.set_color(activeRoomLine, showRailsInput ? color.new(accentColor, 0) : color.new(accentColor, 100))
    if shouldUpdateVisuals and showRailsInput and not na(activeRiskTag)
        label.set_x(activeRiskTag, visualRight)
        label.set_y(activeRiskTag, activeRiskEdge)
        label.set_size(activeRiskTag, labelSize)
    if shouldUpdateVisuals and showRailsInput and not na(activeRoomTag)
        label.set_x(activeRoomTag, visualRight)
        label.set_y(activeRoomTag, activeRoomGuide)
        label.set_size(activeRoomTag, labelSize)

// -------------------------------------------------
// Stop-aware follow-through proof (confirmed-bar gated)
// Mirrors the engine's own Accepted (follow reached) vs Failed (risk edge
// broken) outcome, accumulated into an honest hit rate.
// -------------------------------------------------
var int proofTotal = 0
var int proofWins = 0
var bool proofPending = false
var int proofDir = 0
var float proofTarget = na
var float proofStop = na
var int proofStartBar = na

if barstate.isconfirmed
    if proofPending
        bool los = proofDir == 1 ? close < proofStop : close > proofStop
        bool win = proofDir == 1 ? close >= proofTarget : close <= proofTarget
        bool resolved = false
        if los
            proofTotal += 1
            resolved := true
        else if win
            proofWins += 1
            proofTotal += 1
            resolved := true
        if not resolved and not na(proofStartBar) and bar_index - proofStartBar >= proofWindowInput
            resolved := true
        if resolved
            proofPending := false
    if not proofPending and newEvent
        proofPending := true
        proofDir := activeSide
        proofTarget := activeFollowLevel
        proofStop := activeRiskEdge
        proofStartBar := bar_index

proofReady = proofTotal >= 6
proofRate = proofReady ? int(math.round(f_clamp(proofWins / proofTotal * 100.0, 0.0, 100.0))) : na
proofText = proofReady ? str.tostring(proofRate) + "%  (" + str.tostring(proofTotal) + ")" : "Building (" + str.tostring(proofTotal) + ")"
proofColor = not proofReady ? neutralColor : proofRate >= 55 ? bullColor : proofRate >= 45 ? neutralColor : bearColor

string followThroughText = "No active context"
bool panelHasActive = hasActive and activeAge <= trackingWindowInput + projectionBarsInput
if panelHasActive
    followThroughText := activeFailed ? "Failed" : activeAccepted ? "Accepted" : activeExpired ? "Expired" : "Testing"

string actionText = "WAIT"
if panelHasActive
    actionText := activeFailed ? "INVALIDATED" : activeExpired ? "EXPIRED" : activeAccepted and activeScore >= alertScoreInput ? "READY" : activeScore >= minimumScoreInput ? "MONITOR" : "WAIT"
else
    actionText := "WAIT"

string rejectionVolumeText = panelHasActive ? str.tostring(activeRvol, "#.##") + "x RVOL" : str.tostring(rvol, "#.##") + "x RVOL"
string wickQualityText = panelHasActive ? (activeSide == 1 ? "Lower " : "Upper ") + str.tostring(activeWickRatio, "#.##") + "x" : "-"
string riskEdgeText = panelHasActive ? f_format_price(activeRiskEdge) : "-"
color followFillColor = panelHasActive ? f_state_color(activeState, activeSide, activeScore) : neutralColor

barcolor(tintCandlesInput and hasActive and not activeFailed and not activeExpired ? color.new(f_side_color(activeSide), 82) : na)

// -------------------------------------------------
// Panel
// -------------------------------------------------
var table plannerPanel = table.new(f_panel_position(panelLocationInput), 2, 7,
     bgcolor = f_panel_bg(),
     frame_color = f_panel_border(),
     border_color = f_panel_border(),
     border_width = 1)

if barstate.islast
    table.clear(plannerPanel, 0, 0, 1, 6)
    if showPanelInput
        table.merge_cells(plannerPanel, 0, 0, 1, 0)
        table.cell(plannerPanel, 0, 0, "AG Pro Volume Rejection Planner", text_color = f_text_on(headerBg), bgcolor = headerBg, text_size = f_size(panelSizeInput), text_halign = text.align_center)
        f_panel_row(plannerPanel, 1, "Rejection Volume", rejectionVolumeText, f_panel_value(), panelSizeInput)
        f_panel_row(plannerPanel, 2, "Wick Quality", wickQualityText, f_panel_value(), panelSizeInput)
        f_panel_row_fill(plannerPanel, 3, "Follow-Through", followThroughText, followFillColor, panelSizeInput)
        f_panel_row_fill(plannerPanel, 4, "Reaction Proof", proofText, proofColor, panelSizeInput)
        f_panel_row(plannerPanel, 5, "Risk Edge", riskEdgeText, hasActive ? dangerColor : f_panel_value(), panelSizeInput)
        f_panel_row_fill(plannerPanel, 6, "Action", actionText, f_action_color(actionText), panelSizeInput)

// -------------------------------------------------
// Alerts
// -------------------------------------------------
alertcondition(newEvent, "Volume Rejection Event", "Volume Rejection Planner: a qualified volume rejection event has been detected.")
alertcondition(newReady, "READY State", "Volume Rejection Planner: follow-through reached READY context.")
alertcondition(newStateShift, "Confirmed State Shift", "Volume Rejection Planner: the active volume rejection context changed state.")
alertcondition(newInvalidated, "Invalidation", "Volume Rejection Planner: the active rejection context broke its risk edge.")
alertcondition(newMajorFollow, "Major Follow-Through", "Volume Rejection Planner: the active rejection context reached its room guide.")
````
