# Opening Pullback Planner [AGPro Series]

- url: https://www.tradingview.com/script/ZDApgmmt-Opening-Pullback-Planner-AGPro-Series/
- type: indicator
- pine_id: PUB;c88b60d180ff42d693df411c76f29b00
- version: 4.0

## Description

Opening Pullback Planner [AGPro Series]

🧠 Core Idea

Is the first pullback after the open constructive, failing, or too stale to plan around?


📌 Overview / What it does

Opening Pullback Planner is a session pullback decision tool built around the first meaningful retracement after the opening drive. Instead of treating the open as only a breakout moment, it waits for the drive reference to lock, then maps the pullback area where continuation quality can be evaluated.

The script produces an opening pullback box, continuation trigger, failure line, target-room guide, 0-100 continuation score, risk-edge reading, compact event labels, alerts, and a clean AG Pro planning panel.

It does not predict price direction, automate trades, or mark every opening range breakout. Its purpose is to organize the pullback phase after the opening drive so traders can judge whether the first reset is constructive, failing, invalidated, or no longer worth attention.


🎯 Purpose & Design Philosophy

Many session tools focus on the first opening break, the opening range, or the first impulse. The problem is that a strong open often becomes difficult to plan only after price pulls back.

Opening Pullback Planner was built to fill that gap. It helps traders who study intraday continuation, first-pullback behavior, session execution, and risk-defined planning after the initial move.

The design philosophy is simple: lock the opening drive, map the first pullback box, evaluate recovery quality, define the failure line, and keep the next action readable without turning the chart into a crowded signal board.


⚡ Why This Script Is Different

Most tools focus on opening range breakouts, first-drive strength, fixed session boxes, or generic pullback signals.

This script does NOT clone Opening Drive Quality, does NOT act as an ORB breakout tool, and does NOT draw generic support/resistance zones.

Instead, it focuses on the first pullback after the opening drive. It asks whether the pullback is deep enough to matter, shallow enough to preserve structure, recovering with acceptable close quality, holding a measurable failure line, and offering enough target room for continued review.


⚙️ Methodology

1. Context Detection

The script builds an opening reference from either a fixed session window or the first bars of the day. This creates the drive structure that the pullback plan will use.

2. Reference Mapping

After the opening reference locks, the script maps a drive-native pullback box, continuation trigger, failure line, and target-room guide.

3. Reaction Evaluation

The engine evaluates pullback depth, close recovery, relative volume, volatility fit, room-to-risk, and drive quality to create a 0-100 continuation score.

4. Visual Output

The chart shows the pullback box with centered text, continuation and failure references, target-room guide, compact event labels, optional markers, and the AG Pro panel.


🗺️ How to Read the Chart

Opening Pullback Box = the first pullback review area derived from the locked opening drive.

Continuation Trigger = the level price must reclaim or break after the pullback for continuation context to strengthen.

Failure Line = the invalidation reference where the active pullback plan loses structural integrity.

Target Guide = a projected target-room reference based on the opening drive range.

Labels = event markers for drive retain, pullback test, constructive recovery, trigger readiness, pullback risk, failure line, stale plan, and target check.

Colors = teal for bullish continuation context, pink for bearish or invalid context, amber for caution, and indigo for structural emphasis.

Panel = the decision layer showing Pullback State, Drive Side, Continuation Score, Risk Edge, and Action.


🚦 Signals & States

• DRIVE RETAIN → the opening drive quality is strong enough to map a pullback plan.

• PULLBACK TEST → price has entered the opening pullback box.

• CONSTRUCTIVE → pullback depth and recovery quality are acceptable inside the model.

• TRIGGER READY → price has moved through the continuation trigger after a valid pullback.

• PULLBACK RISK → the pullback is becoming too deep, slow, or weak for clean continuation review.

• FAILURE LINE → the active pullback plan has lost structural integrity.

• PULLBACK STALE → the first pullback plan did not resolve inside the review window.

• TARGET CHECK → price reached the projected target-room guide.


🔔 Alerts Logic

The script includes alerts for:

• Opening Pullback Plan Armed → a qualified opening drive mapped the first pullback plan.

• Opening Pullback Test → price is testing the pullback box.

• Constructive Opening Pullback → the pullback is recovering constructively.

• Opening Pullback Continuation Trigger → the continuation trigger is active after the pullback.

• Opening Pullback Failure Line Broken → the plan has broken its failure reference.

• Opening Pullback Plan Expired → the first pullback plan became stale before confirmation.

• Opening Pullback Target Check → price reached the target-room guide.

Alerts are attention markers. They are not trade instructions.


🧩 Confluence Logic

The context becomes stronger when the opening drive has acceptable quality, the first pullback reaches the planned box without violating the failure line, recovery closes improve, volume does not collapse during recovery, and target room remains clean.

The context becomes weaker when the pullback is too deep, recovery is poor, the plan takes too long to resolve, or price violates the failure line.


📊 When to Use

• Intraday session planning after the opening move.

• First-pullback continuation review.

• Daily chart review when the higher-timeframe fallback is enabled.

• Markets where the opening drive often creates a useful early reference.

• Stocks, indices, futures, crypto, or FX charts where the selected opening session is meaningful.

• Review workflows where risk edge and target room need to be visible.


⚠️ When NOT to Use

• Very low-liquidity markets.

• Extremely noisy opens with unstable spreads.

• News-driven bars that distort the opening reference.

• Higher timeframes where session pullback structure is not meaningful.

• Markets where the selected opening window does not represent real participation.


🎛️ Key Inputs

• Opening Reference Mode → chooses between a fixed session window and first bars of day.

• Opening Drive Window → defines the drive reference used before pullback mapping begins.

• Higher Timeframe Fallback → keeps daily, weekly, and monthly charts visually useful by mapping broader opening references.

• Sensitivity → adjusts how strict the planner is with pullback recovery and score requirements.

• Constructive Score Threshold → controls when constructive pullback labels can appear.

• Pullback Box Shallow / Ideal / Deep → define the preferred retracement area.

• Continuation Trigger Buffer ATR → adjusts the trigger line beyond the drive extreme.

• Failure Line Buffer ATR → adjusts the invalidation reference beyond the pullback box.

• Target Guide Range Multiple → controls the projected target-room guide.

• Visual settings → control box, lines, labels, markers, projection, label limits, and font size.

• Panel settings → control panel visibility, location, theme, and font size.


🖥️ Interface & Visual Design

The interface is chart-first and decision-focused. The main visual object is one opening pullback box with centered state text, supported by a continuation trigger, failure line, and target guide.

The panel follows the AGPro public-release standard with one merged blue header row containing only the script name. The five panel rows are Pullback State, Drive Side, Continuation Score, Risk Edge, and Action.

Labels are compact, capped, and offset away from candles so the chart stays active without becoming crowded.


🧪 Practical Usage Workflow

1. Let the opening reference lock.

2. Read the panel to see whether the drive retained enough quality.

3. Watch whether price tests the opening pullback box.

4. Evaluate the continuation score, recovery state, risk edge, and failure line.

5. Treat alerts and labels as review prompts, not instructions.


🔍 Interpretation Guidelines

A strong continuation score means the pullback is controlled, recovering cleanly, preserving the failure line, and keeping useful room to the projected target guide.

A constructive label means the first pullback is behaving better inside the model. It does not mean continuation must occur.

A failure-line label means the plan has lost the structure it needed for this specific pullback framework.

The best use comes from combining the panel state with broader market context, liquidity, volatility, higher-timeframe structure, and personal risk rules.


🚫 What This Script Is NOT

• Not a prediction engine.

• Not financial advice.

• Not auto trading.

• Not guaranteed signals.

• Not a generic support/resistance map.

• Not an order block or FVG scanner.

• Not an Opening Drive Quality clone.

• Not a full opening range breakout system.


⚠️ Limitations & Transparency

Timeframe selection affects the opening reference and the pullback box. A 5-minute chart and a 15-minute chart can produce different plans.

Session definitions matter. The selected opening window should match the asset and market being studied.

Higher-timeframe fallback mode is a broader chart-reference layer. It should be read as a weekly, monthly, or yearly opening-pullback framework rather than a literal intraday open.

Volatility changes can expand or compress risk, target, and pullback behavior.

Low liquidity, abnormal spreads, and high-impact news can reduce the usefulness of any opening pullback model.


🧠 Market Context Notes

The first pullback after the open can be useful because it tests whether the opening move still has sponsorship. A shallow pullback may show strength but offer limited risk clarity. A deep pullback may offer a better reset but also higher failure risk.

This script keeps that decision visible by separating drive retention, pullback quality, continuation trigger, failure line, and target room.


🧾 Use Case Examples

When price locks a bullish opening drive, pulls back into the mapped box, holds above the failure line, and recovers toward the continuation trigger, the panel may shift toward a constructive or ready state.

When price enters the pullback box but keeps closing weakly or pushes beyond the deep boundary, the planner may mark pullback risk.

When price breaks the failure line, the opening pullback plan is no longer structurally intact inside this model.


🧱 System Philosophy

Opening Pullback Planner follows the AGPro Series decision-engine approach: a script should help the trader evaluate validity, strength, risk, target room, and next action instead of only printing another signal.

The tool is built to make one session behavior easier to read: the first pullback after the opening drive.


🔐 Non-Promise Statement

No script can provide certainty.

No opening pullback model can guarantee continuation, reversal, or profitability.

This script provides structured context only.


📉 Risk Disclosure

Trading involves risk.

Users are responsible for their own decisions.

This script does not provide financial advice, investment advice, or guaranteed trading outcomes.


📚 Educational Note

Use this script as an educational planning and visualization tool. The strongest use comes from reading the first opening pullback together with broader market structure, liquidity, volatility, and personal risk rules.

## Source Code

````pine
// -------------------------------------------------
// Opening Pullback Planner [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 1.5
//
// Opening Pullback Planner evaluates the first constructive or failing
// pullback after the opening drive. It maps a drive-native pullback box,
// continuation trigger, failure line, risk edge, and next-action state for
// session traders who need a structured pullback decision engine instead of
// another generic opening range signal.
// -------------------------------------------------

//@version=6
indicator("Opening Pullback Planner [AGPro Series]",
     shorttitle = "AG Pro OPP",
     overlay = true,
     max_boxes_count = 60,
     max_labels_count = 180,
     max_lines_count = 120)

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
const string TT_MODE = "Controls how the opening reference is built. First Bars Of Day is the publication default for broader crypto, futures, and FX visibility. Session Window uses a fixed intraday opening window."
const string TT_DRIVE_SESSION = "Defines the opening drive window used to build the drive reference before pullback evaluation starts."
const string TT_TRACKING = "Defines when pullback, continuation, failure, and target events can be evaluated after the opening reference is locked."
const string TT_TZ = "Timezone used to interpret the opening and tracking sessions."
const string TT_FIRST = "Number of first daily chart bars used to build the opening reference when First Bars Of Day mode is selected."
const string TT_FALLBACK = "Controls how daily, weekly, and monthly charts remain visually useful. Weekly Open maps the first bars of each week on daily charts and automatically uses a broader anchor on higher timeframes."
const string TT_MEMORY = "Maximum number of bars after the opening reference lock during which the pullback plan remains active."
const string TT_SENS = "Controls how strict the planner is. Responsive accepts more pullbacks, Balanced is the publication default, and Strict requires cleaner recovery and stronger context."
const string TT_ATR = "ATR normalizes drive size, pullback depth, risk-line buffer, target distance, and label offset across symbols."
const string TT_VOL = "Volume baseline used to compare pullback recovery participation against recent activity."
const string TT_MIN_DRIVE = "Minimum opening drive quality required before a pullback plan is mapped. This prevents weak early moves from creating low-value plans."
const string TT_MIN_PULL = "Minimum 0-100 continuation score required before a constructive pullback can be marked."
const string TT_CONFIRM = "Defines how strongly the planner confirms pullback recovery. Stricter modes require close quality, volume support, and target room alignment."
const string TT_SHALLOW = "Shallow retracement boundary of the opening pullback box, measured as a portion of the locked opening drive."
const string TT_IDEAL = "Preferred pullback depth used by the 0-100 continuation score. Scores are strongest when depth is controlled rather than too shallow or too deep."
const string TT_DEEP = "Deep retracement boundary of the opening pullback box. Moves beyond this area increase failure risk."
const string TT_TRIGGER = "ATR buffer added beyond the drive extreme to draw the continuation trigger line."
const string TT_RISK = "ATR buffer placed beyond the pullback box to draw the failure line and risk edge."
const string TT_TARGET = "Opening drive range multiple used to project the target-room guide after a valid pullback plan is armed."
const string TT_REVIEW = "Maximum number of bars after the opening reference lock before an unresolved first pullback is treated as stale."
const string TT_BOX = "Shows the drive-native opening pullback box with centered state text."
const string TT_TRIGGER_LINE = "Shows the continuation trigger that price must reclaim or break after the pullback."
const string TT_FAILURE = "Shows the failure line where the active pullback plan loses structural integrity."
const string TT_TARGET_LINE = "Shows the projected target-room guide derived from the opening drive range."
const string TT_LABELS = "Shows compact event labels for armed plans, pullback touches, constructive recovery, continuation trigger, failures, stale plans, and target checks."
const string TT_SCORE_LABEL = "Adds the 0-100 continuation score to constructive and continuation labels."
const string TT_RETAIN_LABELS = "Shows compact labels when a high-quality opening reference is retained. Lower-quality retained drives are still tracked in the panel but do not print labels by default."
const string TT_RETAIN_THRESHOLD = "Minimum drive quality required before a drive-retain label can appear. Raising this keeps only the strongest opening references visible."
const string TT_WEAK_LABELS = "Shows labels when the opening reference is too weak to map a pullback plan. Disabled by default because weak-drive labels can clutter publication screenshots."
const string TT_MARKERS = "Shows small optional chart markers for key events. It is disabled by default for a cleaner publication chart."
const string TT_PROJECTION = "Number of bars projected to the right for the pullback box, continuation trigger, failure line, and target guide."
const string TT_HISTORY = "Maximum number of historical pullback plans retained on the chart."
const string TT_LABEL_MAX = "Maximum number of visible event labels retained by the script. Older labels are deleted first for performance."
const string TT_LABEL_COOLDOWN = "Minimum bar spacing between major event labels. This keeps the chart active without stacking labels."
const string TT_LABEL_OFFSET = "ATR-based vertical offset that keeps labels away from candle bodies and wicks."
const string TT_LABEL_SIZE = "Controls all chart label sizes, including centered box text. Normal is the recommended public-release default."
const string TT_BADGE_LANES = "Separates pullback-box, drive, trigger, failure, stale, and target-check badges into ATR-based visual lanes so meaningful labels remain readable without stacking on the same price band."
const string TT_BADGE_SPACING = "Controls vertical distance between smart badge lanes. Increase it on compressed charts if labels need more breathing room."
const string TT_RAIL_BADGES = "Shows filled price-owned badges for the active continuation, invalidation, and target rails. Close rails are automatically staggered and connected back to their exact prices. Disabling this option hides the owned rails as one atomic visual set."
const string TT_PANEL_SHOW = "Shows or hides the AG Pro planning panel. It is visible by default for publication readability."
const string TT_PANEL_LOCATION = "Moves the AG Pro panel to the preferred chart location."
const string TT_PANEL_THEME = "Switches the panel between the premium AGPro dark theme and a clean light theme."
const string TT_PANEL_SIZE = "Controls the font size used inside the AG Pro panel. Normal is the recommended publication default."
const string TT_ALERT = "Minimum continuation score required before constructive or continuation alert conditions can trigger."

// -------------------------------------------------
// Inputs
// -------------------------------------------------
string groupSession = "Session"
string openingMode = input.string("First Bars Of Day", "Opening Reference Mode", options = ["Session Window", "First Bars Of Day"], group = groupSession, tooltip = TT_MODE)
string driveSession = input.session("0930-1030", "Opening Drive Window", group = groupSession, tooltip = TT_DRIVE_SESSION)
string trackingSession = input.session("0930-1600", "Tracking Session", group = groupSession, tooltip = TT_TRACKING)
string sessionTimezone = input.string("America/New_York", "Session Timezone", options = ["America/New_York", "Etc/UTC", "Europe/London", "Europe/Istanbul", "Asia/Tokyo"], group = groupSession, tooltip = TT_TZ)
int firstDriveBars = input.int(2, "First Bars Count", minval = 1, maxval = 24, group = groupSession, tooltip = TT_FIRST)
string higherTimeframeFallback = input.string("Weekly Open", "Higher Timeframe Fallback", options = ["Weekly Open", "Monthly Open", "Off"], group = groupSession, tooltip = TT_FALLBACK)
int activeMemoryBars = input.int(96, "Plan Memory Bars", minval = 10, maxval = 500, group = groupSession, tooltip = TT_MEMORY)

string groupEngine = "Planner Engine"
string sensitivity = input.string("Balanced", "Sensitivity", options = ["Responsive", "Balanced", "Strict"], group = groupEngine, tooltip = TT_SENS)
int atrLength = input.int(14, "ATR Length", minval = 2, maxval = 100, group = groupEngine, tooltip = TT_ATR)
int volumeLength = input.int(20, "Relative Volume Length", minval = 2, maxval = 200, group = groupEngine, tooltip = TT_VOL)
int minimumDriveScore = input.int(44, "Minimum Drive Quality", minval = 1, maxval = 100, group = groupEngine, tooltip = TT_MIN_DRIVE)
int minimumPullbackScore = input.int(58, "Constructive Score Threshold", minval = 1, maxval = 100, group = groupEngine, tooltip = TT_MIN_PULL)
string confirmationMode = input.string("Close Confirmation", "Confirmation Mode", options = ["Realtime Allowed", "Close Confirmation", "Close + Volume", "Strict"], group = groupEngine, tooltip = TT_CONFIRM)
float shallowRetracePct = input.float(0.28, "Pullback Box Shallow %", minval = 0.05, maxval = 0.80, step = 0.01, group = groupEngine, tooltip = TT_SHALLOW)
float idealRetracePct = input.float(0.46, "Ideal Pullback Depth %", minval = 0.10, maxval = 0.90, step = 0.01, group = groupEngine, tooltip = TT_IDEAL)
float deepRetracePct = input.float(0.66, "Pullback Box Deep %", minval = 0.15, maxval = 0.95, step = 0.01, group = groupEngine, tooltip = TT_DEEP)
float continuationBufferAtr = input.float(0.06, "Continuation Trigger Buffer ATR", minval = 0.00, maxval = 1.00, step = 0.01, group = groupEngine, tooltip = TT_TRIGGER)
float riskBufferAtr = input.float(0.18, "Failure Line Buffer ATR", minval = 0.00, maxval = 2.00, step = 0.01, group = groupEngine, tooltip = TT_RISK)
float targetRangeMultiple = input.float(1.20, "Target Guide Range Multiple", minval = 0.25, maxval = 5.00, step = 0.05, group = groupEngine, tooltip = TT_TARGET)
int pullbackReviewBars = input.int(34, "Pullback Review Bars", minval = 3, maxval = 180, group = groupEngine, tooltip = TT_REVIEW)
int continuationProofWindow = input.int(14, "Hit Proof Window", minval = 3, maxval = 80, group = groupEngine, tooltip = "After a constructive or continuation readiness, the planner waits this many bars (or until the failure line) and checks whether price followed through in the drive direction. Feeds the self-measured Hit Rate.")

string groupVisual = "Chart Visuals"
bool showPullbackBox = input.bool(true, "Show Opening Pullback Box", group = groupVisual, tooltip = TT_BOX)
bool showContinuationTrigger = input.bool(true, "Show Continuation Trigger", group = groupVisual, tooltip = TT_TRIGGER_LINE)
bool showFailureLine = input.bool(true, "Show Failure Line", group = groupVisual, tooltip = TT_FAILURE)
bool showTargetGuide = input.bool(true, "Show Target Guide", group = groupVisual, tooltip = TT_TARGET_LINE)
bool showEventLabels = input.bool(true, "Show Event Labels", group = groupVisual, tooltip = TT_LABELS)
bool showLabelScore = input.bool(false, "Show Label Score", group = groupVisual, tooltip = TT_SCORE_LABEL)
bool showDriveRetainLabels = input.bool(true, "Show Strong Drive Retain Labels", group = groupVisual, tooltip = TT_RETAIN_LABELS)
int driveRetainLabelThreshold = input.int(72, "Drive Retain Label Threshold", minval = 1, maxval = 100, group = groupVisual, tooltip = TT_RETAIN_THRESHOLD)
bool showWeakDriveLabels = input.bool(false, "Show Weak Drive Labels", group = groupVisual, tooltip = TT_WEAK_LABELS)
bool showCompactMarkers = input.bool(false, "Show Compact Plot Markers", group = groupVisual, tooltip = TT_MARKERS)
int projectionBars = input.int(36, "Forward Projection Bars", minval = 8, maxval = 240, group = groupVisual, tooltip = TT_PROJECTION)
int maxHistoricalPlans = input.int(1, "Max Historical Plans", minval = 1, maxval = 20, group = groupVisual, tooltip = TT_HISTORY)
int maxVisibleLabels = input.int(5, "Max Visible Labels", minval = 4, maxval = 80, group = groupVisual, tooltip = TT_LABEL_MAX)
int labelCooldownBars = input.int(12, "Event Label Cooldown", minval = 0, maxval = 120, group = groupVisual, tooltip = TT_LABEL_COOLDOWN)
float labelOffsetAtr = input.float(0.85, "Label Offset ATR", minval = 0.05, maxval = 3.00, step = 0.05, group = groupVisual, tooltip = TT_LABEL_OFFSET)
string labelFontSize = input.string("Normal", "Label Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = groupVisual, tooltip = TT_LABEL_SIZE)
bool useSmartBadgeLanes = input.bool(true, "Use Smart Badge Lanes", group = groupVisual, tooltip = TT_BADGE_LANES)
float badgeLaneAtr = input.float(0.34, "Badge Lane Spacing ATR", minval = 0.10, maxval = 1.25, step = 0.05, group = groupVisual, tooltip = TT_BADGE_SPACING)
bool showRailBadges = input.bool(true, "Show Owned Rail Badges", group = groupVisual, tooltip = TT_RAIL_BADGES)

string groupPanel = "Panel"
bool showPanel = input.bool(true, "Show Panel", group = groupPanel, tooltip = TT_PANEL_SHOW)
string panelLocation = input.string("Top Right", "Panel Location", options = ["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], group = groupPanel, tooltip = TT_PANEL_LOCATION)
string panelTheme = input.string("Dark", "Panel Theme", options = ["Dark", "Light"], group = groupPanel, tooltip = TT_PANEL_THEME)
string panelFontSize = input.string("Normal", "Panel Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = groupPanel, tooltip = TT_PANEL_SIZE)

string groupAlerts = "Alerts"
int alertScoreThreshold = input.int(64, "Minimum Alert Score", minval = 1, maxval = 100, group = groupAlerts, tooltip = TT_ALERT)

// -------------------------------------------------
// Helpers
// -------------------------------------------------
f_clamp(float value, float minValue, float maxValue) =>
    math.max(minValue, math.min(maxValue, value))

f_text_on(color bg) =>
    float bright = (color.r(bg) * 299.0 + color.g(bg) * 587.0 + color.b(bg) * 114.0) / 1000.0
    bright >= 145.0 ? color.rgb(17, 24, 39) : headerText

f_norm_high_good(float value, float weakValue, float strongValue) =>
    float span = math.max(strongValue - weakValue, 0.000001)
    f_clamp((value - weakValue) / span * 100.0, 0.0, 100.0)

f_norm_low_good(float value, float strongValue, float weakValue) =>
    float span = math.max(weakValue - strongValue, 0.000001)
    f_clamp((weakValue - value) / span * 100.0, 0.0, 100.0)

f_peak_score(float value, float lowValue, float idealValue, float highValue) =>
    float result = 0.0
    if value <= idealValue
        result := f_norm_high_good(value, lowValue, idealValue)
    else
        result := f_norm_low_good(value, idealValue, highValue)
    result

f_text_size(string sizeInput) =>
    switch sizeInput
        "Tiny" => size.tiny
        "Small" => size.small
        "Large" => size.large
        => size.normal

f_panel_pos(string locationInput) =>
    switch locationInput
        "Top Left" => position.top_left
        "Top Center" => position.top_center
        "Top Right" => position.top_right
        "Middle Left" => position.middle_left
        "Middle Center" => position.middle_center
        "Middle Right" => position.middle_right
        "Bottom Left" => position.bottom_left
        "Bottom Center" => position.bottom_center
        => position.bottom_right

f_panel_bg(string themeInput) =>
    themeInput == "Light" ? color.rgb(248, 250, 252) : panelBg

f_panel_border(string themeInput) =>
    themeInput == "Light" ? color.rgb(203, 213, 225) : panelBorder

f_panel_label(string themeInput) =>
    themeInput == "Light" ? color.rgb(71, 85, 105) : panelLabelCol

f_panel_value(string themeInput) =>
    themeInput == "Light" ? color.rgb(15, 23, 42) : panelValueCol

f_row_bg(string themeInput, int row) =>
    color base = f_panel_bg(themeInput)
    themeInput == "Light" ? (row % 2 == 0 ? color.rgb(241, 245, 249) : base) : (row % 2 == 0 ? color.rgb(17, 29, 52) : base)

f_score_color(float scoreValue) =>
    na(scoreValue) ? panelLabelCol : scoreValue >= 75.0 ? bullColor : scoreValue >= 58.0 ? neutralColor : bearColor

f_state_color(string stateText) =>
    stateText == "CONSTRUCTIVE" or stateText == "CONTINUATION" ? bullColor : stateText == "FAILING" or stateText == "INVALIDATED" ? bearColor : neutralColor

f_badge_step(float atrInput) =>
    math.max(math.max(atrInput, syminfo.mintick) * badgeLaneAtr, syminfo.mintick * 20.0)

f_pullback_badge_y(float basePrice, int sideValue, int lane, float atrInput) =>
    float dir = sideValue == 1 ? -1.0 : sideValue == -1 ? 1.0 : 1.0
    useSmartBadgeLanes ? basePrice + dir * f_badge_step(atrInput) * lane : basePrice

f_follow_badge_y(float basePrice, int sideValue, int lane, float atrInput) =>
    float dir = sideValue == 1 ? 1.0 : sideValue == -1 ? -1.0 : 1.0
    useSmartBadgeLanes ? basePrice + dir * f_badge_step(atrInput) * lane : basePrice

f_side_text(int sideValue) =>
    sideValue == 1 ? "Bull Drive" : sideValue == -1 ? "Bear Drive" : "No Drive"

f_price(float value) =>
    na(value) ? "-" : str.tostring(value, format.mintick)

f_score(float value) =>
    na(value) ? "-" : str.tostring(math.round(value))

f_compact_score(float value) =>
    na(value) ? "Q -" : "Q " + str.tostring(math.round(value))

f_set_row(table target, int row, string leftText, string rightText, color rightColor, string themeInput, string fontSize) =>
    color rowBg = f_row_bg(themeInput, row)
    table.cell(target, 0, row, leftText, text_color = f_panel_label(themeInput), bgcolor = rowBg, text_size = f_text_size(fontSize))
    table.cell(target, 1, row, rightText, text_color = rightColor, bgcolor = rowBg, text_size = f_text_size(fontSize), text_halign = text.align_right)

f_trim_labels(array<label> labels, int maxCount) =>
    int labelCount = array.size(labels)
    if labelCount > maxCount
        int removeCount = labelCount - maxCount
        for idx = 0 to removeCount - 1
            label oldLabel = array.shift(labels)
            label.delete(oldLabel)

f_trim_boxes(array<box> boxes, int maxCount) =>
    int boxCount = array.size(boxes)
    if boxCount > maxCount
        int removeCount = boxCount - maxCount
        for idx = 0 to removeCount - 1
            box oldBox = array.shift(boxes)
            box.delete(oldBox)

f_trim_lines(array<line> lines, int maxCount) =>
    int lineCount = array.size(lines)
    if lineCount > maxCount
        int removeCount = lineCount - maxCount
        for idx = 0 to removeCount - 1
            line oldLine = array.shift(lines)
            line.delete(oldLine)

f_add_label(array<label> labels, string labelText, float yValue, int placementSide, color bgColor, int maxCount, string sizeInput) =>
    label newLabel = label.new(bar_index, yValue, labelText,
         xloc = xloc.bar_index,
         yloc = yloc.price,
         style = placementSide == 1 ? label.style_label_up : label.style_label_down,
         textcolor = f_text_on(bgColor),
         color = bgColor,
         size = f_text_size(sizeInput))
    array.push(labels, newLabel)
    f_trim_labels(labels, maxCount)

f_update_plan_box(box targetBox, int leftX, int rightX, float topValue, float bottomValue, string stateText, int sideValue, float scoreValue, string sizeInput) =>
    if not na(targetBox)
        color sideColor = sideValue == 1 ? bullColor : sideValue == -1 ? bearColor : neutralColor
        box.set_left(targetBox, leftX)
        box.set_right(targetBox, rightX)
        box.set_top(targetBox, topValue)
        box.set_bottom(targetBox, bottomValue)
        box.set_bgcolor(targetBox, color.new(sideColor, 88))
        box.set_border_color(targetBox, color.new(sideColor, 12))
        box.set_text(targetBox, "")
        box.set_text_color(targetBox, color.new(headerText, 0))
        box.set_text_size(targetBox, f_text_size(sizeInput))
        box.set_text_halign(targetBox, text.align_center)
        box.set_text_valign(targetBox, text.align_center)

f_set_center_badge(label targetLabel, int xValue, float yValue, string labelText, color bgColor, string sizeInput) =>
    label result = targetLabel
    if na(result)
        result := label.new(xValue, yValue, labelText, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_center, textcolor = f_text_on(bgColor), color = color.new(bgColor, 8), size = f_text_size(sizeInput))
    else
        label.set_x(result, xValue)
        label.set_y(result, yValue)
        label.set_text(result, labelText)
        label.set_color(result, color.new(bgColor, 8))
        label.set_textcolor(result, f_text_on(bgColor))
        label.set_size(result, f_text_size(sizeInput))
    result

f_set_rail_badge(label targetLabel, int xValue, float yValue, string labelText, color bgColor, string sizeInput) =>
    label result = targetLabel
    if na(result)
        result := label.new(xValue, yValue, labelText, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, textcolor = f_text_on(bgColor), color = color.new(bgColor, 0), size = f_text_size(sizeInput))
    else
        label.set_x(result, xValue)
        label.set_y(result, yValue)
        label.set_text(result, labelText)
        label.set_color(result, color.new(bgColor, 0))
        label.set_textcolor(result, f_text_on(bgColor))
        label.set_size(result, f_text_size(sizeInput))
    result

f_set_owned_connector(line targetLine, int railX, float railY, int badgeX, float badgeY, color lineColor, string railStyle) =>
    line result = targetLine
    if na(result)
        result := line.new(railX, railY, badgeX, badgeY, xloc = xloc.bar_index, color = color.new(lineColor, 0), width = railStyle == "trigger" ? 2 : 1, style = railStyle == "target" ? line.style_dotted : railStyle == "failure" ? line.style_dashed : line.style_solid)
    else
        line.set_xy1(result, railX, railY)
        line.set_xy2(result, badgeX, badgeY)
        line.set_color(result, color.new(lineColor, 0))
        line.set_width(result, railStyle == "trigger" ? 2 : 1)
        line.set_style(result, railStyle == "target" ? line.style_dotted : railStyle == "failure" ? line.style_dashed : line.style_solid)
    result

f_update_line(line targetLine, int leftX, int rightX, float yValue, color lineColor, string lineStyle) =>
    if not na(targetLine)
        line.set_xy1(targetLine, leftX, yValue)
        line.set_xy2(targetLine, rightX, yValue)
        line.set_color(targetLine, lineColor)
        line.set_width(targetLine, lineStyle == "trigger" ? 2 : 1)
        line.set_style(targetLine, lineStyle == "target" ? line.style_dotted : lineStyle == "failure" ? line.style_dashed : line.style_solid)

// -------------------------------------------------
// Session Build
// -------------------------------------------------
float atrValue = ta.atr(atrLength)
float atrBase = ta.sma(atrValue, 100)
float volumeBase = ta.sma(volume, volumeLength)
bool useHigherTimeframeFallback = not timeframe.isintraday and higherTimeframeFallback != "Off"
bool canUsePlanner = timeframe.isintraday or useHigherTimeframeFallback
bool newDay = timeframe.change("D")
var int dayBarCount = 0
if newDay
    dayBarCount := 0
dayBarCount += 1

bool fallbackMonthlyAnchor = higherTimeframeFallback == "Monthly Open" or timeframe.isweekly
bool fallbackYearlyAnchor = timeframe.ismonthly
bool fallbackPeriodStart = fallbackYearlyAnchor ? timeframe.change("12M") : fallbackMonthlyAnchor ? timeframe.change("M") : timeframe.change("W")
var int fallbackBarCount = 0
if fallbackPeriodStart
    fallbackBarCount := 0
fallbackBarCount += 1

bool rawDriveSession = not na(time(timeframe.period, driveSession, sessionTimezone))
bool rawTrackingSession = not na(time(timeframe.period, trackingSession, sessionTimezone))
bool sessionBuild = timeframe.isintraday and openingMode == "Session Window" and rawDriveSession
bool firstBarsBuild = timeframe.isintraday and openingMode == "First Bars Of Day" and dayBarCount <= firstDriveBars
bool fallbackBuild = useHigherTimeframeFallback and fallbackBarCount <= firstDriveBars
bool inOpeningBuild = sessionBuild or firstBarsBuild or fallbackBuild
bool openingStarted = inOpeningBuild and inOpeningBuild[1] != true
bool openingEnded = not inOpeningBuild and inOpeningBuild[1] == true
bool trackingActive = timeframe.isintraday ? (rawTrackingSession or openingMode == "First Bars Of Day") : useHigherTimeframeFallback

var float buildOpen = na
var float buildHigh = na
var float buildLow = na
var float buildClose = na
var float buildVolume = na
var int buildBars = 0

if openingStarted
    buildOpen := open
    buildHigh := high
    buildLow := low
    buildClose := close
    buildVolume := nz(volume)
    buildBars := 1
else if inOpeningBuild
    buildHigh := math.max(nz(buildHigh, high), high)
    buildLow := math.min(nz(buildLow, low), low)
    buildClose := close
    buildVolume += nz(volume)
    buildBars += 1

// -------------------------------------------------
// Planner State
// -------------------------------------------------
var bool planArmed = false
var bool pullbackTouched = false
var bool constructiveSeen = false
var bool continuationSeen = false
var bool failingSeen = false
var bool invalidated = false
var bool expired = false
var bool targetSeen = false

var int lockBar = na
var int driveSide = 0
var int pullbackBar = na
var int lastLabelBar = na

var float lockedDriveHigh = na
var float lockedDriveLow = na
var float lockedDriveOpen = na
var float lockedDriveClose = na
var float lockedDriveRange = na
var float lockedAtr = na
var float driveQuality = na
var float pullbackScore = na
var float bestPullbackDepth = na
var float zoneTop = na
var float zoneBottom = na
var float zoneMid = na
var float continuationTrigger = na
var float failureLine = na
var float targetGuide = na
var float currentRiskReward = na
var string pullbackState = "WAITING"
var string actionState = "WAIT"

var box activePullbackBox = na
var label activePullbackLabel = na
var line activeTriggerLine = na
var line activeFailureLine = na
var line activeTargetLine = na
var label activeTriggerBadge = na
var label activeFailureBadge = na
var label activeTargetBadge = na
var line activeTriggerConnector = na
var line activeFailureConnector = na
var line activeTargetConnector = na
var array<box> planBoxes = array.new<box>()
var array<line> planLines = array.new<line>()
var array<label> eventLabels = array.new<label>()

float shallowPct = math.min(shallowRetracePct, deepRetracePct - 0.05)
float deepPct = math.max(deepRetracePct, shallowRetracePct + 0.05)
float idealPct = f_clamp(idealRetracePct, shallowPct + 0.02, deepPct - 0.02)
float strictScoreShift = sensitivity == "Strict" ? 6.0 : sensitivity == "Responsive" ? -5.0 : 0.0
float effectiveDriveThreshold = f_clamp(minimumDriveScore + strictScoreShift, 1.0, 100.0)
float effectivePullbackThreshold = f_clamp(minimumPullbackScore + strictScoreShift, 1.0, 100.0)

bool eventPlanArmed = false
bool eventDriveWeak = false
bool eventPullbackTouch = false
bool eventConstructive = false
bool eventContinuation = false
bool eventFailing = false
bool eventInvalidated = false
bool eventExpired = false
bool eventTarget = false

if canUsePlanner and openingEnded and buildBars > 0
    if not na(activePullbackLabel)
        label.delete(activePullbackLabel)
        activePullbackLabel := na
    if not na(activeTriggerBadge)
        label.delete(activeTriggerBadge)
        activeTriggerBadge := na
    if not na(activeFailureBadge)
        label.delete(activeFailureBadge)
        activeFailureBadge := na
    if not na(activeTargetBadge)
        label.delete(activeTargetBadge)
        activeTargetBadge := na
    if not na(activeTriggerConnector)
        line.delete(activeTriggerConnector)
        activeTriggerConnector := na
    if not na(activeFailureConnector)
        line.delete(activeFailureConnector)
        activeFailureConnector := na
    if not na(activeTargetConnector)
        line.delete(activeTargetConnector)
        activeTargetConnector := na
    lockedDriveHigh := buildHigh
    lockedDriveLow := buildLow
    lockedDriveOpen := buildOpen
    lockedDriveClose := buildClose
    lockedDriveRange := math.max(lockedDriveHigh - lockedDriveLow, syminfo.mintick)
    lockedAtr := math.max(nz(atrValue, lockedDriveRange), syminfo.mintick)
    lockBar := bar_index - 1
    driveSide := lockedDriveClose >= (lockedDriveHigh + lockedDriveLow) * 0.5 ? 1 : -1
    float driveRangeAtr = lockedDriveRange / lockedAtr
    float closeLocation = driveSide == 1 ? (lockedDriveClose - lockedDriveLow) / lockedDriveRange : (lockedDriveHigh - lockedDriveClose) / lockedDriveRange
    float closeScore = f_clamp(closeLocation * 100.0, 0.0, 100.0)
    float thrustScore = f_norm_high_good(driveRangeAtr, 0.45, 1.70)
    float avgDriveVolume = buildVolume / math.max(buildBars, 1)
    float relativeVolume = not na(volumeBase) and volumeBase > 0.0 ? avgDriveVolume / volumeBase : 1.0
    float volumeScore = f_norm_high_good(relativeVolume, 0.70, 1.50)
    driveQuality := f_clamp(thrustScore * 0.44 + closeScore * 0.36 + volumeScore * 0.20, 0.0, 100.0)
    planArmed := driveQuality >= effectiveDriveThreshold
    pullbackTouched := false
    constructiveSeen := false
    continuationSeen := false
    failingSeen := false
    invalidated := false
    expired := false
    targetSeen := false
    pullbackBar := na
    pullbackScore := na
    bestPullbackDepth := na
    currentRiskReward := na
    if planArmed
        if driveSide == 1
            zoneTop := lockedDriveHigh - lockedDriveRange * shallowPct
            zoneBottom := lockedDriveHigh - lockedDriveRange * deepPct
            continuationTrigger := lockedDriveHigh + lockedAtr * continuationBufferAtr
            failureLine := zoneBottom - lockedAtr * riskBufferAtr
            targetGuide := lockedDriveHigh + lockedDriveRange * targetRangeMultiple
        else
            zoneTop := lockedDriveLow + lockedDriveRange * deepPct
            zoneBottom := lockedDriveLow + lockedDriveRange * shallowPct
            continuationTrigger := lockedDriveLow - lockedAtr * continuationBufferAtr
            failureLine := zoneTop + lockedAtr * riskBufferAtr
            targetGuide := lockedDriveLow - lockedDriveRange * targetRangeMultiple
        zoneMid := (zoneTop + zoneBottom) * 0.5
        pullbackState := "ARMED"
        actionState := "MONITOR"
        int rightEdge = bar_index + projectionBars
        color sideColor = driveSide == 1 ? bullColor : bearColor
        if showPullbackBox
            activePullbackBox := box.new(lockBar, zoneTop, rightEdge, zoneBottom,
                 xloc = xloc.bar_index,
                 bgcolor = color.new(sideColor, 88),
                 border_color = color.new(sideColor, 12),
                 border_width = 1,
                 text = "",
                 text_color = headerText,
                 text_size = f_text_size(labelFontSize),
                 text_halign = text.align_center,
                 text_valign = text.align_center)
            activePullbackLabel := f_set_center_badge(activePullbackLabel, int(math.round((lockBar + rightEdge) / 2.0)), zoneMid, "PULLBACK | ARMED " + f_compact_score(driveQuality), sideColor, labelFontSize)
            array.push(planBoxes, activePullbackBox)
            f_trim_boxes(planBoxes, maxHistoricalPlans)
        else
            activePullbackBox := na
            activePullbackLabel := na
        if showContinuationTrigger and showRailBadges
            activeTriggerLine := line.new(lockBar, continuationTrigger, rightEdge, continuationTrigger, xloc = xloc.bar_index, color = color.new(sideColor, 0), width = 2)
            array.push(planLines, activeTriggerLine)
        else
            activeTriggerLine := na
        if showFailureLine and showRailBadges
            activeFailureLine := line.new(lockBar, failureLine, rightEdge, failureLine, xloc = xloc.bar_index, color = color.new(bearColor, 0), width = 1, style = line.style_dashed)
            array.push(planLines, activeFailureLine)
        else
            activeFailureLine := na
        if showTargetGuide and showRailBadges
            activeTargetLine := line.new(lockBar, targetGuide, rightEdge, targetGuide, xloc = xloc.bar_index, color = color.new(accentColor, 0), width = 1, style = line.style_dotted)
            array.push(planLines, activeTargetLine)
        else
            activeTargetLine := na
        f_trim_lines(planLines, maxHistoricalPlans * 3)
        eventPlanArmed := true
    else
        zoneTop := na
        zoneBottom := na
        zoneMid := na
        continuationTrigger := na
        failureLine := na
        targetGuide := na
        pullbackState := "WEAK DRIVE"
        actionState := "WAIT"
        activePullbackBox := na
        activePullbackLabel := na
        activeTriggerLine := na
        activeFailureLine := na
        activeTargetLine := na
        eventDriveWeak := true

bool planLive = planArmed and not na(lockBar) and bar_index > lockBar and bar_index - lockBar <= activeMemoryBars and not invalidated and not expired
bool planTracking = planLive and trackingActive
float labelOffset = math.max(nz(atrValue, lockedAtr), syminfo.mintick) * labelOffsetAtr
int rightProjection = bar_index + projectionBars

if planTracking
    f_update_plan_box(activePullbackBox, lockBar, rightProjection, zoneTop, zoneBottom, pullbackState, driveSide, na(pullbackScore) ? driveQuality : pullbackScore, labelFontSize)
    if showPullbackBox and not na(activePullbackLabel)
        activePullbackLabel := f_set_center_badge(activePullbackLabel, int(math.round((lockBar + rightProjection) / 2.0)), zoneMid, "PULLBACK | " + pullbackState + " " + f_compact_score(na(pullbackScore) ? driveQuality : pullbackScore), driveSide == 1 ? bullColor : bearColor, labelFontSize)
    f_update_line(activeTriggerLine, lockBar, rightProjection, continuationTrigger, driveSide == 1 ? bullColor : bearColor, "trigger")
    f_update_line(activeFailureLine, lockBar, rightProjection, failureLine, bearColor, "failure")
    f_update_line(activeTargetLine, lockBar, rightProjection, targetGuide, accentColor, "target")
    bool wasTouched = pullbackTouched
    bool zoneTouchedNow = high >= zoneBottom and low <= zoneTop
    float liveDepth = driveSide == 1 ? (lockedDriveHigh - low) / lockedDriveRange : (high - lockedDriveLow) / lockedDriveRange
    if zoneTouchedNow
        pullbackTouched := true
        pullbackBar := na(pullbackBar) ? bar_index : pullbackBar
        bestPullbackDepth := na(bestPullbackDepth) ? liveDepth : math.max(bestPullbackDepth, liveDepth)
    eventPullbackTouch := zoneTouchedNow and not wasTouched
    float zoneHeight = math.max(zoneTop - zoneBottom, syminfo.mintick)
    float recoveryPosition = driveSide == 1 ? (close - zoneBottom) / zoneHeight : (zoneTop - close) / zoneHeight
    float depthScore = f_peak_score(f_clamp(nz(bestPullbackDepth, liveDepth), 0.0, 2.0), shallowPct, idealPct, deepPct + 0.18)
    float recoveryScore = f_clamp(recoveryPosition * 100.0, 0.0, 100.0)
    float liveVolRatio = not na(volumeBase) and volumeBase > 0.0 ? volume / volumeBase : 1.0
    float volumeSupportScore = f_norm_high_good(liveVolRatio, 0.65, 1.35)
    float volFit = not na(atrBase) and atrBase > 0.0 ? atrValue / atrBase : 1.0
    float volatilityScore = f_peak_score(volFit, 0.60, 1.00, 1.85)
    float roomAtr = driveSide == 1 ? (targetGuide - close) / lockedAtr : (close - targetGuide) / lockedAtr
    float riskAtr = driveSide == 1 ? (close - failureLine) / lockedAtr : (failureLine - close) / lockedAtr
    currentRiskReward := f_clamp(roomAtr / math.max(riskAtr, 0.10), 0.0, 9.99)
    float roomScore = f_norm_high_good(currentRiskReward, 0.75, 2.00)
    pullbackScore := pullbackTouched ? f_clamp(driveQuality * 0.18 + depthScore * 0.30 + recoveryScore * 0.27 + volumeSupportScore * 0.10 + volatilityScore * 0.05 + roomScore * 0.10, 0.0, 100.0) : na
    bool closeRecovery = driveSide == 1 ? close >= zoneMid : close <= zoneMid
    bool volumeConfirmed = confirmationMode == "Close + Volume" or confirmationMode == "Strict" ? liveVolRatio >= (confirmationMode == "Strict" ? 1.05 : 0.85) : true
    bool roomConfirmed = confirmationMode == "Strict" ? currentRiskReward >= 0.95 : true
    bool riskBrokenNow = confirmationMode == "Realtime Allowed" ? (driveSide == 1 ? low < failureLine : high > failureLine) : (driveSide == 1 ? close < failureLine : close > failureLine)
    bool continuationNow = driveSide == 1 ? close > continuationTrigger : close < continuationTrigger
    bool targetNow = driveSide == 1 ? high >= targetGuide : low <= targetGuide
    bool constructiveNow = pullbackTouched and closeRecovery and volumeConfirmed and roomConfirmed and pullbackScore >= effectivePullbackThreshold
    bool failingNow = pullbackTouched and not riskBrokenNow and (nz(bestPullbackDepth, liveDepth) > deepPct or (bar_index - nz(pullbackBar, bar_index) > math.round(pullbackReviewBars * 0.5) and pullbackScore < effectivePullbackThreshold - 8.0))
    if riskBrokenNow
        invalidated := true
        pullbackState := "INVALIDATED"
        actionState := "INVALIDATED"
        eventInvalidated := true
    else if continuationNow and pullbackTouched and pullbackScore >= alertScoreThreshold
        eventContinuation := not continuationSeen
        continuationSeen := true
        pullbackState := "CONTINUATION"
        actionState := "READY"
    else if constructiveNow
        eventConstructive := not constructiveSeen
        constructiveSeen := true
        pullbackState := "CONSTRUCTIVE"
        actionState := "READY"
    else if failingNow
        eventFailing := not failingSeen
        failingSeen := true
        pullbackState := "FAILING"
        actionState := "REDUCE"
    else if pullbackTouched
        pullbackState := "ACTIVE"
        actionState := "MONITOR"
    else
        pullbackState := "AWAITING"
        actionState := "WAIT"
    if targetNow and not targetSeen
        targetSeen := true
        eventTarget := true
    if not continuationSeen and bar_index - lockBar > pullbackReviewBars and not invalidated and not expired
        expired := true
        pullbackState := "EXPIRED"
        actionState := "EXPIRED"
        eventExpired := true
    f_update_plan_box(activePullbackBox, lockBar, rightProjection, zoneTop, zoneBottom, pullbackState, driveSide, na(pullbackScore) ? driveQuality : pullbackScore, labelFontSize)
    if showPullbackBox and not na(activePullbackLabel)
        activePullbackLabel := f_set_center_badge(activePullbackLabel, int(math.round((lockBar + rightProjection) / 2.0)), zoneMid, "PULLBACK | " + pullbackState + " " + f_compact_score(na(pullbackScore) ? driveQuality : pullbackScore), f_state_color(pullbackState), labelFontSize)

// Active rail ownership: exact prices stay on the rails while close badges are
// separated into font-aware ATR lanes and connected back to their sources.
bool ownedRailsLive = planLive and not invalidated and not expired and showRailBadges
if ownedRailsLive
    float fontGapFactor = labelFontSize == "Large" ? 2.00 : labelFontSize == "Normal" ? 1.55 : labelFontSize == "Small" ? 1.25 : 1.05
    float railGap = f_badge_step(nz(lockedAtr, atrValue)) * fontGapFactor
    float failureBadgeY = failureLine
    float triggerBadgeY = continuationTrigger
    float targetBadgeY = targetGuide
    if driveSide == 1
        triggerBadgeY := math.max(triggerBadgeY, failureBadgeY + railGap)
        targetBadgeY := math.max(targetBadgeY, triggerBadgeY + railGap)
    else
        triggerBadgeY := math.min(triggerBadgeY, failureBadgeY - railGap)
        targetBadgeY := math.min(targetBadgeY, triggerBadgeY - railGap)
    int badgeX = rightProjection + 6
    color triggerColor = driveSide == 1 ? bullColor : bearColor
    if showContinuationTrigger and not na(activeTriggerLine)
        activeTriggerBadge := f_set_rail_badge(activeTriggerBadge, badgeX, triggerBadgeY, "TRIGGER " + f_price(continuationTrigger), triggerColor, labelFontSize)
        activeTriggerConnector := f_set_owned_connector(activeTriggerConnector, rightProjection, continuationTrigger, badgeX, triggerBadgeY, triggerColor, "trigger")
    if showFailureLine and not na(activeFailureLine)
        activeFailureBadge := f_set_rail_badge(activeFailureBadge, badgeX, failureBadgeY, "INVALID " + f_price(failureLine), dangerColor, labelFontSize)
        activeFailureConnector := f_set_owned_connector(activeFailureConnector, rightProjection, failureLine, badgeX, failureBadgeY, dangerColor, "failure")
    if showTargetGuide and not na(activeTargetLine)
        activeTargetBadge := f_set_rail_badge(activeTargetBadge, badgeX, targetBadgeY, "TARGET " + f_price(targetGuide), accentColor, labelFontSize)
        activeTargetConnector := f_set_owned_connector(activeTargetConnector, rightProjection, targetGuide, badgeX, targetBadgeY, accentColor, "target")
else
    if not na(activeTriggerBadge)
        label.delete(activeTriggerBadge)
        activeTriggerBadge := na
    if not na(activeFailureBadge)
        label.delete(activeFailureBadge)
        activeFailureBadge := na
    if not na(activeTargetBadge)
        label.delete(activeTargetBadge)
        activeTargetBadge := na
    if not na(activeTriggerConnector)
        line.delete(activeTriggerConnector)
        activeTriggerConnector := na
    if not na(activeFailureConnector)
        line.delete(activeFailureConnector)
        activeFailureConnector := na
    if not na(activeTargetConnector)
        line.delete(activeTargetConnector)
        activeTargetConnector := na
    if invalidated or expired
        if not na(activeTriggerLine)
            line.delete(activeTriggerLine)
            activeTriggerLine := na
        if not na(activeFailureLine)
            line.delete(activeFailureLine)
            activeFailureLine := na
        if not na(activeTargetLine)
            line.delete(activeTargetLine)
            activeTargetLine := na

// -------------------------------------------------
// Hit Rate (Proof Pass)
// -------------------------------------------------
// On the first constructive or continuation readiness, the drive direction is
// armed with the failure line as a reference. The setup resolves as a miss if
// price closes through the failure line first, or as a hit when the move has
// followed through in the drive direction after the proof window. Timeouts are
// not counted as losses. This is a transparent, self-measured follow-through
// statistic for the readiness call.
var int ohHits = 0
var int ohTotal = 0
var bool ohPending = false
var int ohStart = na
var int ohDir = 0
var float ohEntry = na
var float ohInval = na

bool readyRise = eventConstructive or eventContinuation

if barstate.isconfirmed
    if readyRise and not ohPending and not na(failureLine)
        ohPending := true
        ohStart := bar_index
        ohDir := driveSide
        ohEntry := close
        ohInval := failureLine
    if ohPending and not na(ohStart) and bar_index > ohStart
        bool ohStop = ohDir == 1 ? close < ohInval : close > ohInval
        if ohStop
            ohTotal += 1
            ohPending := false
        else if bar_index - ohStart >= continuationProofWindow
            bool ohFollowed = ohDir == 1 ? close > ohEntry : close < ohEntry
            ohTotal += 1
            if ohFollowed
                ohHits += 1
            ohPending := false

float ohRate = ohTotal > 0 ? ohHits / ohTotal * 100.0 : na
string hitRateText = ohTotal > 0 ? str.tostring(int(math.round(ohRate))) + "% (" + str.tostring(ohHits) + "/" + str.tostring(ohTotal) + ")" : "Building"
color hitRateColor = ohTotal == 0 ? neutralColor : ohRate >= 60.0 ? bullColor : ohRate >= 45.0 ? neutralColor : bearColor

// -------------------------------------------------
// Labels
// -------------------------------------------------
bool canPrintLabel = showEventLabels and (na(lastLabelBar) or bar_index - lastLabelBar >= labelCooldownBars)
float bullLabelY = low - labelOffset
float bearLabelY = high + labelOffset
string scoreSuffix = showLabelScore and not na(pullbackScore) ? " " + f_compact_score(pullbackScore) : ""

if canPrintLabel and eventPlanArmed and showDriveRetainLabels and driveQuality >= driveRetainLabelThreshold
    string retainText = driveSide == 1 ? "BULL DRIVE" : "BEAR DRIVE"
    f_add_label(eventLabels, retainText + " " + f_compact_score(driveQuality), useSmartBadgeLanes ? f_follow_badge_y(driveSide == 1 ? continuationTrigger : continuationTrigger, driveSide, 1, nz(lockedAtr, atrValue)) : driveSide == 1 ? bullLabelY : bearLabelY, driveSide, driveSide == 1 ? bullColor : bearColor, maxVisibleLabels, labelFontSize)
    lastLabelBar := bar_index
else if canPrintLabel and eventDriveWeak
    if showWeakDriveLabels
        f_add_label(eventLabels, "WEAK DRIVE WAIT", bearLabelY, -1, neutralColor, maxVisibleLabels, labelFontSize)
        lastLabelBar := bar_index
else if canPrintLabel and eventPullbackTouch and not showPullbackBox
    f_add_label(eventLabels, "PB TEST", useSmartBadgeLanes ? f_pullback_badge_y(zoneMid, driveSide, 1, nz(lockedAtr, atrValue)) : driveSide == 1 ? bullLabelY : bearLabelY, driveSide, accentColor, maxVisibleLabels, labelFontSize)
    lastLabelBar := bar_index
else if canPrintLabel and eventConstructive and not showPullbackBox
    f_add_label(eventLabels, "CONSTRUCTIVE" + scoreSuffix, useSmartBadgeLanes ? f_follow_badge_y(zoneMid, driveSide, 2, nz(lockedAtr, atrValue)) : driveSide == 1 ? bullLabelY : bearLabelY, driveSide, bullColor, maxVisibleLabels, labelFontSize)
    lastLabelBar := bar_index
else if canPrintLabel and eventContinuation
    f_add_label(eventLabels, "TRIGGER READY" + scoreSuffix, useSmartBadgeLanes ? f_follow_badge_y(continuationTrigger, driveSide, 1, nz(lockedAtr, atrValue)) : driveSide == 1 ? bullLabelY : bearLabelY, driveSide, driveSide == 1 ? bullColor : bearColor, maxVisibleLabels, labelFontSize)
    lastLabelBar := bar_index
else if canPrintLabel and eventFailing
    f_add_label(eventLabels, "PULLBACK RISK" + scoreSuffix, useSmartBadgeLanes ? f_pullback_badge_y(failureLine, driveSide, 1, nz(lockedAtr, atrValue)) : driveSide == 1 ? bearLabelY : bullLabelY, -driveSide, neutralColor, maxVisibleLabels, labelFontSize)
    lastLabelBar := bar_index
else if canPrintLabel and eventInvalidated
    f_add_label(eventLabels, "FAIL LINE", useSmartBadgeLanes ? f_pullback_badge_y(failureLine, driveSide, 2, nz(lockedAtr, atrValue)) : driveSide == 1 ? bearLabelY : bullLabelY, -driveSide, bearColor, maxVisibleLabels, labelFontSize)
    lastLabelBar := bar_index
else if canPrintLabel and eventExpired
    f_add_label(eventLabels, "PULLBACK STALE", bearLabelY, -1, neutralColor, maxVisibleLabels, labelFontSize)
    lastLabelBar := bar_index
else if canPrintLabel and eventTarget and not (showRailBadges and showTargetGuide)
    f_add_label(eventLabels, "TARGET CHECK", useSmartBadgeLanes ? f_follow_badge_y(targetGuide, driveSide, 1, nz(lockedAtr, atrValue)) : driveSide == 1 ? bullLabelY : bearLabelY, driveSide, accentColor, maxVisibleLabels, labelFontSize)
    lastLabelBar := bar_index

// -------------------------------------------------
// Optional Markers
// -------------------------------------------------
plotshape(showCompactMarkers and eventPullbackTouch, title = "Pullback Touch", style = shape.circle, location = location.belowbar, color = accentColor, size = size.tiny, text = "PB")
plotshape(showCompactMarkers and eventConstructive, title = "Constructive Pullback", style = shape.triangleup, location = location.belowbar, color = bullColor, size = size.tiny, text = "C")
plotshape(showCompactMarkers and eventInvalidated, title = "Failure Line Break", style = shape.triangledown, location = location.abovebar, color = bearColor, size = size.tiny, text = "F")

// -------------------------------------------------
// Panel
// -------------------------------------------------
var table statePanel = table.new(f_panel_pos(panelLocation), 2, 7, bgcolor = f_panel_bg(panelTheme), border_color = f_panel_border(panelTheme), border_width = 1)

if barstate.islast
    table.clear(statePanel, 0, 0, 1, 6)
    if showPanel
        table.cell(statePanel, 0, 0, "AG Pro Opening Pullback Planner", text_color = headerText, bgcolor = headerBg, text_size = f_text_size(panelFontSize), text_halign = text.align_center)
        table.cell(statePanel, 1, 0, "", text_color = headerText, bgcolor = headerBg, text_size = f_text_size(panelFontSize))
        table.merge_cells(statePanel, 0, 0, 1, 0)
        string panelState = canUsePlanner ? pullbackState : "INTRADAY ONLY"
        string scoreText = canUsePlanner ? (na(pullbackScore) ? f_score(driveQuality) : f_score(pullbackScore)) : "-"
        string riskText = canUsePlanner and not na(currentRiskReward) ? str.tostring(currentRiskReward, "#.##") + "R" : "-"
        string driveText = canUsePlanner ? f_side_text(driveSide) + " | " + f_score(driveQuality) : "Use intraday"
        string panelAction = canUsePlanner ? actionState : "WAIT"
        f_set_row(statePanel, 1, "Pullback State", panelState, f_state_color(panelState), panelTheme, panelFontSize)
        f_set_row(statePanel, 2, "Drive Side", driveText, canUsePlanner ? (driveSide == 1 ? bullColor : driveSide == -1 ? bearColor : neutralColor) : neutralColor, panelTheme, panelFontSize)
        f_set_row(statePanel, 3, "Continuation Score", scoreText, canUsePlanner ? f_score_color(na(pullbackScore) ? driveQuality : pullbackScore) : panelValueCol, panelTheme, panelFontSize)
        f_set_row(statePanel, 4, "Risk Edge", riskText, canUsePlanner and not na(currentRiskReward) ? (currentRiskReward >= 1.25 ? bullColor : currentRiskReward >= 0.85 ? neutralColor : bearColor) : panelValueCol, panelTheme, panelFontSize)
        f_set_row(statePanel, 5, "Hit Rate", hitRateText, hitRateColor, panelTheme, panelFontSize)
        f_set_row(statePanel, 6, "Action", panelAction, f_state_color(panelState), panelTheme, panelFontSize)

// -------------------------------------------------
// Alerts
// -------------------------------------------------
alertcondition(eventPlanArmed, "Opening Pullback Plan Armed", "Opening Pullback Planner: a qualified opening drive mapped the first pullback plan.")
alertcondition(eventPullbackTouch, "Opening Pullback Test", "Opening Pullback Planner: price is testing the opening pullback box.")
alertcondition(eventConstructive and pullbackScore >= alertScoreThreshold, "Constructive Opening Pullback", "Opening Pullback Planner: the first pullback is recovering constructively.")
alertcondition(eventContinuation and pullbackScore >= alertScoreThreshold, "Opening Pullback Continuation Trigger", "Opening Pullback Planner: continuation trigger is active after the pullback.")
alertcondition(eventInvalidated, "Opening Pullback Failure Line Broken", "Opening Pullback Planner: the active pullback plan has broken the failure line.")
alertcondition(eventExpired, "Opening Pullback Plan Expired", "Opening Pullback Planner: the first pullback plan has become stale before confirmation.")
alertcondition(eventTarget, "Opening Pullback Target Check", "Opening Pullback Planner: price reached the projected target-room guide.")
````
