# Pullback Acceptance Planner [AGPro Series]

- url: https://www.tradingview.com/script/6LEiX7BQ-Pullback-Acceptance-Planner-AGPro-Series/
- type: indicator
- pine_id: PUB;02f4c0b00870420c84b30c94ee5f4f98
- version: 6.0

## Description

Pullback Acceptance Planner [AGPro Series]

🧠 Core Idea

Is the current trend pullback being accepted as continuation, or rejected as failure?


📌 Overview / What it does

Pullback Acceptance Planner [AGPro Series] is a public-free TradingView planner built to evaluate one specific decision point: the moment price pulls back into a trend-support area and the trader needs to know whether the retracement is being accepted or rejected.

The script maps a live pullback acceptance pocket, accepted/rejected state labels, an invalidation risk shelf, a target-room band, and a clean AGPro decision panel. It converts pullback depth, close acceptance, trend support, volume behavior, invalidation distance, and target room into a 0-100 Acceptance Score.

It does not predict price direction, automate entries, or label every small retracement. Its purpose is to make the pullback review process cleaner, more visual, and more decision-focused.


🎯 Purpose & Design Philosophy

This script was built because many pullback tools stop at showing where price touched a moving average, trend line, or generic zone. That is not enough for a trader who needs to decide whether the pullback is still constructive.

Pullback Acceptance Planner fills that gap by focusing on acceptance behavior after the pullback reaches the planning pocket. It helps traders review trend-side support, close quality, participation, risk distance, and remaining room in one structured view.

The mindset is practical: do not chase every pullback, and do not treat every retracement as a signal. Wait for the pullback to show whether it is being accepted or rejected.


⚡ Why This Script Is Different

Most pullback tools focus on moving-average touches, simple continuation markers, or generic trend-risk labels.

This script does NOT clone Low Volume Pullback Zones, Trend Pullback Risk Planner, Opening Drive Quality, SuperTrend pullback tools, or broad continuation dashboards.

Instead, it answers a narrower question: after price enters a general trend pullback pocket, is the close behavior strong enough to call the pullback accepted, or is the invalidation shelf being lost?

That acceptance-first framing is the core identity of the script.


⚙️ Methodology

1. Context Detection
The engine reads EMA stack alignment, base EMA slope, ATR structure, and the selected planning side to determine whether a bullish or bearish pullback context is active.

2. Reference Mapping
The script builds a pullback acceptance pocket around the base EMA, then maps an invalidation risk shelf behind the pocket and a target-room band toward the nearest prior obstruction.

3. Reaction Evaluation
The 0-100 Acceptance Score evaluates pullback depth, close acceptance beyond the pocket edge, trend support, volume behavior, invalidation distance, and target room.

4. Visual Output
The chart displays the acceptance pocket, risk shelf, target-room band, compact state labels, alerts, and a five-row AGPro planner panel.


🗺️ How to Read the Chart

Zones = the pullback acceptance pocket, invalidation risk shelf, and target-room band.

Labels = current state changes such as PB ACCEPTED, PB REJECTED, ACCEPT WATCH, ROOM REVIEW, or PB FORMING.

Colors = bullish acceptance uses teal, bearish acceptance uses pink, watch/room review uses yellow or indigo, and rejection uses red.

Panel = the decision summary: Pullback State, Acceptance Score, Risk Edge, Room, and Action.


🚦 Signals & States

• PB ACCEPTED → price closed beyond the active pullback pocket with enough score quality.

• ACCEPT WATCH → pullback context is improving but still needs cleaner confirmation.

• ROOM REVIEW → acceptance quality exists, but nearby obstruction leaves limited target room.

• PB FORMING → price is inside or near the pocket and the planner is still building context.

• PB REJECTED → price crossed the invalidation shelf and the active pullback context failed.

• TREND WAIT / NO PULLBACK → there is no active pullback acceptance context to review.


🔔 Alerts Logic

Alerts trigger when a bullish or bearish pullback reaches accepted state, when acceptance watch appears, when target room needs review, when the pullback is rejected, or when a major follow-through event appears after acceptance.

Alerts are attention markers. They are not trade instructions.


🧩 Confluence Logic

The context becomes stronger when trend side, clean pullback depth, constructive close acceptance, controlled or recovering volume, reasonable invalidation distance, and sufficient target room align at the same time.

The score is intentionally multi-factor so a single moving-average touch cannot create a high-quality state by itself.


📊 When to Use

• Trending markets with clean retracements

• Swing or intraday continuation review

• Markets where pullback behavior matters more than raw trend direction

• Crypto, forex, stocks, indices, and commodities with enough liquidity

• Situations where a trader wants an invalidation reference and target-room read before acting


⚠️ When NOT to Use

• Very low-liquidity symbols

• Extremely noisy sideways chop

• News-driven spikes where ATR and trend structure distort quickly

• Ultra-low timeframes with unstable spread or poor execution quality

• Markets where price repeatedly crosses the base EMA without directional structure


🎛️ Key Inputs

• Planning Side → chooses Auto, Bullish Pullback, or Bearish Pullback.

• Sensitivity → changes trend strictness and scoring behavior.

• EMA Lengths → define the trend stack and acceptance pocket anchor.

• ATR Length → normalizes pocket width, labels, risk shelf, and target room.

• Pullback Review Window → controls how long a pocket touch remains active.

• ACCEPTED Threshold → sets the minimum score for accepted-state labels.

• Label / Panel Settings → control visibility, location, theme, font size, label size, and label density.


🖥️ Interface & Visual Design

The interface is chart-first. The main chart objects are the acceptance pocket, risk shelf, and target-room band, each with centered text when displayed.

The panel uses the AGPro standard: one merged blue header row containing only the script name, followed by five decision rows. The layout is intentionally compact so the chart stays premium, readable, and useful on first glance.


🧪 Practical Usage Workflow

1. Read the panel to identify Pullback State and Acceptance Score.
2. Check whether price is inside, above, or below the acceptance pocket.
3. Review the invalidation risk shelf before interpreting an accepted state.
4. Check the target-room band to see whether the path is open or obstructed.
5. Treat labels and alerts as review markers, not automatic trade decisions.


🔍 Interpretation Guidelines

A higher score means the pullback has cleaner depth, stronger close behavior, better trend support, healthier volume behavior, more reasonable invalidation distance, and better room.

An accepted label means the pullback has met the script's rule-based acceptance conditions. It does not mean price must continue.

A rejected label means the pullback context failed according to the invalidation shelf. It does not mean the market must reverse.


🚫 What This Script Is NOT

• Not a prediction engine

• Not financial advice

• Not auto trading

• Not guaranteed signals

• Not a generic support/resistance zone tool

• Not an order block, FVG, or broad SMC map


⚠️ Limitations & Transparency

• Timeframe differences can change how clean the pocket and score appear.

• Volatility expansion can widen risk and distort close acceptance.

• Low-liquidity markets can make volume behavior less reliable.

• Strong news candles can cross both pocket and target references too quickly.

• The script uses rule-based approximations, not future knowledge.


🧠 Market Context Notes

Pullback acceptance often depends on whether price can return toward trend support without losing structure. A constructive pullback usually keeps risk contained, avoids aggressive countertrend volume, and then shows acceptance through the pocket edge.

This script turns that process into a visual planner so the user can review risk, room, and state in one place.


🧾 Use Case Examples

When a bullish trend pulls back into the acceptance pocket, the script may print ACCEPT WATCH first. If price later closes above the pocket edge with enough score quality, the state can shift to PB ACCEPTED.

When a bearish trend rallies into the pocket but then closes back below the acceptance edge, the script can mark bearish acceptance. If price crosses the invalidation shelf instead, the state shifts toward rejection.


🧱 System Philosophy

Pullback Acceptance Planner follows the AGPro planner-style direction: the chart should not only show another signal. It should help the trader evaluate setup validity, strength, risk, target room, and next action.


🔐 Non-Promise Statement

No script can provide certainty.

No score can guarantee outcome.

This tool is designed for structured review and educational analysis.


📉 Risk Disclosure

Trading involves risk. Market conditions can change quickly, and historical or rule-based signals do not guarantee future results.

Users are responsible for their own analysis, risk management, and decisions.

This script does not provide financial advice.


📚 Educational Note

Use the script to study how pullbacks behave around trend support, invalidation shelves, and target-room constraints. The best value comes from comparing the planner state with broader market context.

## Source Code

````pine
// -------------------------------------------------
// Pullback Acceptance Planner [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 2.5
//
// Pullback Acceptance Planner is a trend pullback decision engine that
// evaluates whether a retracement is being accepted as continuation or
// rejected as failure. It maps a live pullback acceptance pocket, risk shelf,
// target-room corridor, 0-100 Acceptance Score, and next-action state without
// becoming a generic signal, support/resistance, or pullback-risk clone.
// Version 2.5 strengthens confirmation-anchored proof sampling, threshold
// safeguards, accepted-cycle follow-through tracking, and visual spacing while
// preserving the original pullback acceptance model and publication workflow.
// -------------------------------------------------

//@version=6
indicator("Pullback Acceptance Planner [AGPro Series]",
     shorttitle       = "AG Pro PAP",
     overlay          = true,
     max_boxes_count  = 20,
     max_labels_count = 120,
     max_lines_count  = 30,
     max_bars_back    = 1000)

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

// -------------------------------------------------
// Tooltips
// -------------------------------------------------
const string TT_SIDE = "Selects the pullback side evaluated by the planner. Auto follows the active EMA trend stack, while directional modes restrict the planner to one side only."
const string TT_CONFIRM = "Close Confirmed prints labels and alerts only after the bar closes. Live Updating lets the planner update during the active bar."
const string TT_SENS = "Controls scoring strictness and label selectivity. Balanced is tuned for public-release readability."
const string TT_FAST = "Fast EMA used to detect short-term trend pressure and pullback depth. It is not used as a standalone signal line."
const string TT_BASE = "Base EMA used as the center of the pullback acceptance pocket."
const string TT_SLOW = "Slow EMA used as broader trend support and invalidation context."
const string TT_SLOPE = "Number of bars used to evaluate base EMA slope. Higher values make trend support slower but cleaner."
const string TT_ATR = "ATR normalizes pocket width, risk shelf distance, target room, score components, and label offsets."
const string TT_VOL = "Volume baseline used to judge whether pullback volume is controlled and whether acceptance closes have enough participation."
const string TT_TARGET = "Lookback used to estimate the nearest prior obstruction in the pullback-continuation direction."
const string TT_POCKET = "ATR width around the base EMA used to build the active pullback acceptance pocket."
const string TT_WINDOW = "Number of bars after a pocket touch where acceptance, rejection, and watch states remain active."
const string TT_DEPTH = "Preferred ATR-normalized pullback depth. Pullbacks that are too shallow or too deep receive weaker depth scores."
const string TT_DEEP = "Pullbacks deeper than this ATR distance are treated as elevated failure risk."
const string TT_CLOSE = "ATR buffer beyond the pocket edge required to treat the close as acceptance."
const string TT_RISK = "ATR buffer placed beyond the pocket and slow EMA to draw the invalidation risk shelf."
const string TT_ROOM = "Minimum ATR distance toward the nearest obstruction considered clean target room."
const string TT_VOL_DRY = "Preferred relative volume during the pullback. Lower participation inside the pocket can improve acceptance quality before the reclaim close."
const string TT_READY = "Minimum 0-100 Acceptance Score required for ACCEPTED state labels and ready alerts."
const string TT_WATCH = "Minimum 0-100 Acceptance Score required for WATCH state labels."
const string TT_FT = "ATR-normalized progress beyond the accepted pocket edge required for a major follow-through alert."
const string TT_PLOT_EMA = "Shows or hides the EMA anchors used by the pullback acceptance model."
const string TT_SHOW_POCKET = "Shows the live pullback acceptance pocket with compact centered status text."
const string TT_SHOW_RISK = "Shows the invalidation risk shelf and rail. This is a planning reference, not a stop order."
const string TT_SHOW_TARGET = "Shows the target-room corridor toward the nearest prior obstruction."
const string TT_ZONE_TRANS = "Controls transparency for pocket, risk, and target zones. Higher values create lighter zones."
const string TT_LABELS = "Shows accepted, rejected, watch, and context labels with controlled spacing."
const string TT_CONTEXT = "Adds sparse context labels while a pullback is forming so the chart does not look empty. Disabled by default for a cleaner publication preset."
const string TT_COOLDOWN = "Minimum bars between event labels. Higher values reduce clustering."
const string TT_SPACING = "Minimum bars between lighter context labels."
const string TT_MAX_LABELS = "Maximum number of visible labels retained by the script. Older labels are deleted first for performance."
const string TT_HISTORY = "Limits chart-label creation to the most recent bars. Lower values improve loading speed while keeping the current chart readable."
const string TT_LABEL_OFFSET = "ATR-based vertical offset that keeps labels above or below candles."
const string TT_LABEL_SCORE = "Adds the 0-100 Acceptance Score to chart labels."
const string TT_LABEL_SIZE = "Controls all chart labels and centered zone text. Normal is the recommended public-release default."
const string TT_PANEL_SHOW = "Shows or hides the AG Pro decision panel. It is visible by default for publication readability."
const string TT_PANEL_LOCATION = "Moves the AG Pro panel to the preferred chart location."
const string TT_PANEL_THEME = "Switches the panel between the premium AGPro dark theme and a clean light theme."
const string TT_PANEL_SIZE = "Controls the font size used inside the AG Pro panel. Normal is the recommended publication default."
const string TT_ALERT = "Minimum Acceptance Score required before score-gated alert conditions can trigger."
const string TT_SHOWPROOF = "Shows the confirmation-anchored proof layer in the panel: Follow, Hold, React, and Flip rates measured across accepted pullbacks on the current symbol and timeframe. Follow means the accepted pullback continued one risk unit (1R) toward room, or reached a nearer target, before the invalidation shelf was breached. These are historical outcome rates, not predictions."
const string TT_PROOF_HORIZON = "Maximum number of bars each accepted pullback is tracked for the proof measurement before it resolves at its current outcome."
const string TT_REACT_BARS = "Number of bars after a pullback is accepted used to detect an immediate favorable continuation reaction."
const string TT_REACT_PROGRESS = "Minimum favorable continuation progress toward the 1R target, within the reaction window, required to count as an early React."

// -------------------------------------------------
// Inputs
// -------------------------------------------------
string groupEngine = "Pullback Acceptance Engine"
string sideMode = input.string("Auto", "Planning Side", options = ["Auto", "Bullish Pullback", "Bearish Pullback"], group = groupEngine, tooltip = TT_SIDE)
string confirmationMode = input.string("Close Confirmed", "Confirmation Mode", options = ["Close Confirmed", "Live Updating"], group = groupEngine, tooltip = TT_CONFIRM)
string sensitivity = input.string("Balanced", "Sensitivity", options = ["Responsive", "Balanced", "Strict"], group = groupEngine, tooltip = TT_SENS)
int fastEmaLength = input.int(13, "Fast EMA Length", minval = 2, maxval = 100, group = groupEngine, tooltip = TT_FAST)
int baseEmaLength = input.int(34, "Base EMA Length", minval = 5, maxval = 200, group = groupEngine, tooltip = TT_BASE)
int slowEmaLength = input.int(89, "Slow EMA Length", minval = 10, maxval = 400, group = groupEngine, tooltip = TT_SLOW)
int slopeLookback = input.int(8, "Trend Slope Lookback", minval = 2, maxval = 80, group = groupEngine, tooltip = TT_SLOPE)
int atrLength = input.int(14, "ATR Length", minval = 5, maxval = 100, group = groupEngine, tooltip = TT_ATR)
int volumeLength = input.int(34, "Volume Baseline Length", minval = 5, maxval = 200, group = groupEngine, tooltip = TT_VOL)
int targetLookback = input.int(90, "Target Room Lookback", minval = 20, maxval = 500, group = groupEngine, tooltip = TT_TARGET)

string groupModel = "Acceptance Score Model"
float pocketWidthAtr = input.float(0.62, "Acceptance Pocket Width ATR", minval = 0.10, maxval = 2.50, step = 0.01, group = groupModel, tooltip = TT_POCKET)
int pullbackReviewBars = input.int(14, "Pullback Review Window", minval = 2, maxval = 80, group = groupModel, tooltip = TT_WINDOW)
float idealPullbackAtr = input.float(0.95, "Ideal Pullback Depth ATR", minval = 0.10, maxval = 4.00, step = 0.05, group = groupModel, tooltip = TT_DEPTH)
float deepPullbackAtr = input.float(2.60, "Deep Pullback Risk ATR", minval = 0.50, maxval = 8.00, step = 0.05, group = groupModel, tooltip = TT_DEEP)
float closeAcceptanceAtr = input.float(0.16, "Acceptance Close Buffer ATR", minval = 0.00, maxval = 1.50, step = 0.01, group = groupModel, tooltip = TT_CLOSE)
float riskShelfBufferAtr = input.float(0.24, "Risk Shelf Buffer ATR", minval = 0.00, maxval = 2.00, step = 0.01, group = groupModel, tooltip = TT_RISK)
float cleanRoomAtr = input.float(2.10, "Clean Target Room ATR", minval = 0.25, maxval = 10.00, step = 0.05, group = groupModel, tooltip = TT_ROOM)
float preferredDryVolume = input.float(0.82, "Preferred Pullback RVOL", minval = 0.10, maxval = 2.00, step = 0.01, group = groupModel, tooltip = TT_VOL_DRY)
int acceptedThreshold = input.int(68, "ACCEPTED Threshold", minval = 40, maxval = 95, group = groupModel, tooltip = TT_READY)
int watchThreshold = input.int(54, "WATCH Threshold", minval = 20, maxval = 90, group = groupModel, tooltip = TT_WATCH)
float followThroughAtr = input.float(0.72, "Major Follow-Through ATR", minval = 0.05, maxval = 4.00, step = 0.05, group = groupModel, tooltip = TT_FT)

string groupVisual = "Chart Visuals"
bool showEmaAnchors = input.bool(false, "Show EMA Anchors", group = groupVisual, tooltip = TT_PLOT_EMA)
bool showAcceptancePocket = input.bool(true, "Show Acceptance Pocket", group = groupVisual, tooltip = TT_SHOW_POCKET)
bool showRiskShelf = input.bool(true, "Show Risk Shelf", group = groupVisual, tooltip = TT_SHOW_RISK)
bool showTargetBand = input.bool(true, "Show Target-Room Corridor", group = groupVisual, tooltip = TT_SHOW_TARGET)
int projectionBars = input.int(44, "Forward Projection Bars", minval = 8, maxval = 180, group = groupVisual, tooltip = "Controls how far pocket, risk shelf, and target-room visuals extend to the right.")
int zoneTransparency = input.int(90, "Zone Transparency", minval = 70, maxval = 96, group = groupVisual, tooltip = TT_ZONE_TRANS)

string groupLabels = "Labels"
bool showEventLabels = input.bool(true, "Show State Labels", group = groupLabels, tooltip = TT_LABELS)
bool showContextLabels = input.bool(false, "Show Sparse Context Labels", group = groupLabels, tooltip = TT_CONTEXT)
int labelCooldownBars = input.int(32, "Event Label Cooldown", minval = 1, maxval = 120, group = groupLabels, tooltip = TT_COOLDOWN)
int contextSpacingBars = input.int(64, "Context Label Spacing", minval = 6, maxval = 240, group = groupLabels, tooltip = TT_SPACING)
int maxVisibleLabels = input.int(5, "Max Visible Labels", minval = 4, maxval = 80, group = groupLabels, tooltip = TT_MAX_LABELS)
int labelHistoryBars = input.int(260, "Label History Bars", minval = 50, maxval = 1000, group = groupLabels, tooltip = TT_HISTORY)
float labelOffsetAtr = input.float(1.00, "Label Offset ATR", minval = 0.10, maxval = 3.00, step = 0.05, group = groupLabels, tooltip = TT_LABEL_OFFSET)
bool showLabelScore = input.bool(true, "Show Label Score", group = groupLabels, tooltip = TT_LABEL_SCORE)
string labelFontSize = input.string("Normal", "Label Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = groupLabels, tooltip = TT_LABEL_SIZE)

string groupPanel = "Panel"
bool showPanel = input.bool(true, "Show Panel", group = groupPanel, tooltip = TT_PANEL_SHOW)
string panelLocation = input.string("Top Right", "Panel Location", options = ["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], group = groupPanel, tooltip = TT_PANEL_LOCATION)
string panelTheme = input.string("Elite Dark", "Panel Theme", options = ["Elite Dark", "Clean Light"], group = groupPanel, tooltip = TT_PANEL_THEME)
string panelFontSize = input.string("Normal", "Panel Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = groupPanel, tooltip = TT_PANEL_SIZE)

string groupProof = "Proof"
bool showProof = input.bool(true, "Show Proof Layer", group = groupProof, tooltip = TT_SHOWPROOF)
int proofHorizonBars = input.int(30, "Proof Horizon Bars", minval = 5, maxval = 240, group = groupProof, tooltip = TT_PROOF_HORIZON)
int reactBars = input.int(4, "Reaction Window Bars", minval = 1, maxval = 60, group = groupProof, tooltip = TT_REACT_BARS)
float reactProgressPct = input.float(33.0, "Reaction Progress %", minval = 5.0, maxval = 80.0, step = 1.0, group = groupProof, tooltip = TT_REACT_PROGRESS)

string groupAlerts = "Alerts"
int alertScoreThreshold = input.int(68, "Minimum Alert Score", minval = 40, maxval = 95, group = groupAlerts, tooltip = TT_ALERT)

// -------------------------------------------------
// Helpers
// -------------------------------------------------
f_clamp(float value, float minValue, float maxValue) =>
    math.max(minValue, math.min(maxValue, value))

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

f_score_grade(int scoreValue) =>
    scoreValue >= 86 ? "A+" : scoreValue >= 76 ? "A" : scoreValue >= 68 ? "B" : scoreValue >= 54 ? "C" : scoreValue >= 40 ? "D" : "E"

f_score_color(int scoreValue) =>
    color result = bearColor
    if scoreValue >= 76
        result := bullColor
    else if scoreValue >= 68
        result := accentColor
    else if scoreValue >= 54
        result := neutralColor
    result

f_pct(float value) =>
    str.tostring(int(math.round(value))) + "%"

f_rate_color(float value) =>
    value >= 55 ? bullColor : value >= 40 ? neutralColor : bearColor

f_flip_color(float value) =>
    value <= 30 ? bullColor : value <= 55 ? neutralColor : bearColor

f_state_color(string stateText, int dir) =>
    color result = panelValueCol
    if stateText == "PB ACCEPTED"
        result := dir == 1 ? bullColor : bearColor
    else if stateText == "PB REJECTED"
        result := bearColor
    else if stateText == "ACCEPT WATCH"
        result := accentColor
    else if stateText == "PB FORMING"
        result := neutralColor
    else if stateText == "ROOM REVIEW"
        result := neutralColor
    result

f_price(float value) =>
    na(value) ? "-" : str.tostring(value, format.mintick)

f_atr(float value) =>
    na(value) ? "-" : str.tostring(value, "#.##") + " ATR"

f_panel_row(table target, int row, string leftText, string rightText, color rightColor, string themeText, string fontSizeText) =>
    color rowBg = f_row_bg(themeText, row)
    table.cell(target, 0, row, leftText, text_color = f_panel_label(themeText), bgcolor = rowBg, text_size = f_text_size(fontSizeText), text_halign = text.align_left)
    table.cell(target, 1, row, rightText, text_color = rightColor, bgcolor = rowBg, text_size = f_text_size(fontSizeText), text_halign = text.align_right)

f_trim_labels(array<label> labels, int maxCount) =>
    while array.size(labels) > maxCount
        label oldLabel = array.shift(labels)
        label.delete(oldLabel)

f_direction_text(int dir) =>
    dir == 1 ? "Bullish" : dir == -1 ? "Bearish" : "Neutral"

f_state_badge(string stateText) =>
    switch stateText
        "PB ACCEPTED" => "Accepted"
        "PB REJECTED" => "Rejected"
        "ACCEPT WATCH" => "Watch"
        "PB FORMING" => "Forming"
        "ROOM REVIEW" => "Room"
        "NO PULLBACK" => "No pullback"
        => "Trend wait"

f_box_set(box id, int leftValue, float topValue, int rightValue, float bottomValue, color bgValue, color borderValue) =>
    box.set_left(id, leftValue)
    box.set_right(id, rightValue)
    box.set_top(id, topValue)
    box.set_bottom(id, bottomValue)
    box.set_bgcolor(id, bgValue)
    box.set_border_color(id, borderValue)

f_badge_set(label id, int xValue, float yValue, string textValue, color bgValue, string sizeValue) =>
    label result = id
    if na(result)
        result := label.new(x = xValue, y = yValue, text = textValue, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_center, color = color.new(bgValue, 0), textcolor = headerText, size = f_text_size(sizeValue), textalign = text.align_center)
    else
        label.set_x(result, xValue)
        label.set_y(result, yValue)
        label.set_text(result, textValue)
        label.set_color(result, color.new(bgValue, 0))
        label.set_textcolor(result, headerText)
        label.set_size(result, f_text_size(sizeValue))
    result

// -------------------------------------------------
// Core calculations
// -------------------------------------------------
int effectiveAcceptedThreshold = int(math.min(95, math.max(acceptedThreshold, watchThreshold + 1)))
int effectiveWatchThreshold = int(math.min(watchThreshold, effectiveAcceptedThreshold - 1))
int effectiveAlertScoreThreshold = int(math.max(alertScoreThreshold, effectiveWatchThreshold))

float effectiveDeepPullbackAtr = math.max(deepPullbackAtr, 0.15)
float effectiveIdealPullbackAtr = f_clamp(idealPullbackAtr, 0.10, effectiveDeepPullbackAtr - 0.05)
float effectiveCleanRoomAtr = math.max(cleanRoomAtr, 0.05)
float effectiveDryVolumeWeak = math.max(preferredDryVolume + 0.15, 1.60)
int effectiveReactBars = math.min(reactBars, math.max(proofHorizonBars - 1, 1))

int engineWarmup = math.max(
     math.max(targetLookback, slowEmaLength),
     math.max(math.max(volumeLength, baseEmaLength), math.max(atrLength, fastEmaLength))
 ) + slopeLookback + atrLength + 5
bool engineReady = bar_index > engineWarmup
bool proofConfirmedBar = barstate.isconfirmed

float atrRaw = ta.atr(atrLength)
float safeAtr = math.max(nz(atrRaw, ta.tr(true)), syminfo.mintick)
float fastEma = ta.ema(close, fastEmaLength)
float baseEma = ta.ema(close, baseEmaLength)
float slowEma = ta.ema(close, slowEmaLength)
float slopeBase = nz(baseEma[slopeLookback], baseEma)
float slopeAtr = (baseEma - slopeBase) / safeAtr

float strictSlope = sensitivity == "Responsive" ? 0.025 : sensitivity == "Strict" ? 0.075 : 0.045
float closeScoreBoost = sensitivity == "Responsive" ? 0.82 : sensitivity == "Strict" ? 1.16 : 1.00
float trendScoreBoost = sensitivity == "Responsive" ? 0.88 : sensitivity == "Strict" ? 1.12 : 1.00

bool bullTrend = fastEma > baseEma and baseEma > slowEma and slopeAtr > strictSlope
bool bearTrend = fastEma < baseEma and baseEma < slowEma and slopeAtr < -strictSlope

int trendDir = 0
if bullTrend
    trendDir := 1
else if bearTrend
    trendDir := -1

int activeDir = 0
if engineReady
    if sideMode == "Bullish Pullback"
        activeDir := bullTrend ? 1 : 0
    else if sideMode == "Bearish Pullback"
        activeDir := bearTrend ? -1 : 0
    else
        activeDir := trendDir

float pocketHalfWidth = pocketWidthAtr * safeAtr
float pocketTop = baseEma + pocketHalfWidth
float pocketBottom = baseEma - pocketHalfWidth
bool pocketTouch = activeDir != 0 and low <= pocketTop and high >= pocketBottom
int barsSinceTouchRaw = ta.barssince(pocketTouch)
bool hasRecentTouch = not na(barsSinceTouchRaw) and barsSinceTouchRaw <= pullbackReviewBars

float recentLow = ta.lowest(low, pullbackReviewBars)
float recentHigh = ta.highest(high, pullbackReviewBars)
float recentPullbackExtreme = activeDir == 1 ? recentLow : activeDir == -1 ? recentHigh : close
float pullbackDepthAtr = activeDir == 1 ? math.max((fastEma - recentPullbackExtreme) / safeAtr, 0.0) : activeDir == -1 ? math.max((recentPullbackExtreme - fastEma) / safeAtr, 0.0) : 0.0

float priorHigh = ta.highest(high[1], targetLookback)
float priorLow = ta.lowest(low[1], targetLookback)
float targetRefRaw = activeDir == 1 ? priorHigh : activeDir == -1 ? priorLow : na
float rawRoomAtr = activeDir == 1 ? (targetRefRaw - close) / safeAtr : activeDir == -1 ? (close - targetRefRaw) / safeAtr : na
bool targetFallback = activeDir != 0 and (na(targetRefRaw) or na(rawRoomAtr) or rawRoomAtr < 0.20)
float targetRef = activeDir == 1 ? (targetFallback ? close + safeAtr * cleanRoomAtr : targetRefRaw) : activeDir == -1 ? (targetFallback ? close - safeAtr * cleanRoomAtr : targetRefRaw) : na
float targetRoomAtr = activeDir == 1 ? math.max((targetRef - close) / safeAtr, 0.0) : activeDir == -1 ? math.max((close - targetRef) / safeAtr, 0.0) : na

float riskRail = activeDir == 1 ? math.min(pocketBottom, slowEma) - safeAtr * riskShelfBufferAtr : activeDir == -1 ? math.max(pocketTop, slowEma) + safeAtr * riskShelfBufferAtr : na
float riskDistanceAtr = activeDir == 1 ? math.max((close - riskRail) / safeAtr, 0.0) : activeDir == -1 ? math.max((riskRail - close) / safeAtr, 0.0) : na

float volumeNow = nz(volume, 0.0)
float volumeAvgRaw = ta.sma(volumeNow, volumeLength)
float volumeBase = na(volumeAvgRaw) ? math.max(volumeNow, 1.0) : math.max(volumeAvgRaw, 1.0)
float rvol = volumeNow / volumeBase

bool bullAcceptClose = activeDir == 1 and close > pocketTop + safeAtr * closeAcceptanceAtr
bool bearAcceptClose = activeDir == -1 and close < pocketBottom - safeAtr * closeAcceptanceAtr
bool acceptClose = bullAcceptClose or bearAcceptClose
bool bullRejected = activeDir == 1 and close < riskRail
bool bearRejected = activeDir == -1 and close > riskRail
bool rejectedClose = bullRejected or bearRejected
bool confirmationOk = confirmationMode == "Live Updating" or barstate.isconfirmed

float depthScore = f_peak_score(pullbackDepthAtr, 0.05, effectiveIdealPullbackAtr, effectiveDeepPullbackAtr)
float closeAcceptanceRaw = activeDir == 1 ? (close - pocketTop) / safeAtr : activeDir == -1 ? (pocketBottom - close) / safeAtr : 0.0
float closeScore = acceptClose ? f_norm_high_good(closeAcceptanceRaw * closeScoreBoost, 0.00, 0.65) : f_norm_high_good(closeAcceptanceRaw * closeScoreBoost, -0.45, 0.18)
float trendScore = activeDir == 1 ? f_norm_high_good(slopeAtr * trendScoreBoost, strictSlope * 0.25, strictSlope * 5.0) : activeDir == -1 ? f_norm_high_good(math.abs(slopeAtr) * trendScoreBoost, strictSlope * 0.25, strictSlope * 5.0) : 0.0
float dryVolumeScore = f_norm_low_good(rvol, preferredDryVolume, effectiveDryVolumeWeak)
float recoveryVolumeScore = f_norm_high_good(rvol, 0.70, 1.45)
float volumeBehaviorScore = acceptClose ? recoveryVolumeScore : dryVolumeScore
float riskDistanceForScore = na(riskDistanceAtr) ? 0.0 : riskDistanceAtr
float targetRoomForScore = na(targetRoomAtr) ? 0.0 : targetRoomAtr
float riskScore = f_peak_score(riskDistanceForScore, 0.25, 1.35, 4.20)
float roomScore = f_norm_high_good(targetRoomForScore, 0.20, effectiveCleanRoomAtr)

float weightedScore = depthScore * 0.22 + closeScore * 0.24 + trendScore * 0.20 + volumeBehaviorScore * 0.14 + riskScore * 0.12 + roomScore * 0.08
int acceptanceScore = activeDir == 0 or na(weightedScore) ? 0 : int(math.round(f_clamp(weightedScore, 0.0, 100.0)))

bool acceptedNow = activeDir != 0 and hasRecentTouch and acceptClose and acceptanceScore >= effectiveAcceptedThreshold and confirmationOk
bool rejectedNow = activeDir != 0 and hasRecentTouch and rejectedClose and confirmationOk
bool roomReviewNow = activeDir != 0 and hasRecentTouch and targetRoomAtr < effectiveCleanRoomAtr * 0.45 and acceptanceScore >= effectiveWatchThreshold and not acceptedNow and not rejectedNow
bool watchNow = activeDir != 0 and hasRecentTouch and acceptanceScore >= effectiveWatchThreshold and not acceptedNow and not rejectedNow and not roomReviewNow
bool formingNow = activeDir != 0 and hasRecentTouch and not acceptedNow and not rejectedNow and not watchNow and not roomReviewNow

string stateText = "TREND WAIT"
if activeDir == 0
    stateText := "TREND WAIT"
else if rejectedNow
    stateText := "PB REJECTED"
else if acceptedNow
    stateText := "PB ACCEPTED"
else if roomReviewNow
    stateText := "ROOM REVIEW"
else if watchNow
    stateText := "ACCEPT WATCH"
else if formingNow
    stateText := "PB FORMING"
else
    stateText := "NO PULLBACK"

string actionText = "Wait trend"
if stateText == "PB ACCEPTED"
    actionText := "Review plan"
else if stateText == "PB REJECTED"
    actionText := "Stand down"
else if stateText == "ROOM REVIEW"
    actionText := "Check room"
else if stateText == "ACCEPT WATCH"
    actionText := "Wait close"
else if stateText == "PB FORMING"
    actionText := "Monitor pocket"
else if stateText == "NO PULLBACK"
    actionText := "Wait pullback"

color stateColor = f_state_color(stateText, activeDir)
bool panelContextActive = activeDir != 0 and hasRecentTouch
string scoreText = panelContextActive ? str.tostring(acceptanceScore) + "/100 " + f_score_grade(acceptanceScore) : "-"
string riskText = panelContextActive ? f_atr(riskDistanceAtr) : "-"
string roomText = panelContextActive ? f_atr(targetRoomAtr) : "-"
color scorePanelColor = panelContextActive ? f_score_color(acceptanceScore) : f_panel_value(panelTheme)
color riskPanelColor = f_panel_value(panelTheme)
color roomPanelColor = f_panel_value(panelTheme)
if panelContextActive
    riskPanelColor := riskDistanceAtr <= 0.45 ? bearColor : accentColor
    roomPanelColor := targetRoomAtr >= effectiveCleanRoomAtr ? bullColor : neutralColor

// -------------------------------------------------
// Optional anchors
// -------------------------------------------------
plot(showEmaAnchors ? fastEma : na, "Fast EMA", color = color.new(accentColor, 30), linewidth = 1)
plot(showEmaAnchors ? baseEma : na, "Base EMA", color = color.new(neutralColor, 25), linewidth = 2)
plot(showEmaAnchors ? slowEma : na, "Slow EMA", color = color.new(panelLabelCol, 20), linewidth = 2)

// -------------------------------------------------
// Zones and guides
// -------------------------------------------------
var box pocketBox = na
var box riskBox = na
var box targetBox = na
var line riskLine = na
var line targetLine = na
var label pocketBadge = na
var label riskBadge = na
var label targetBadge = na

int leftEdge = math.max(bar_index - pullbackReviewBars, 0)
int rightEdge = bar_index + projectionBars
int centerX = int(math.round((leftEdge + rightEdge) * 0.5))
int riskBadgeX = leftEdge + int(math.round((rightEdge - leftEdge) * 0.70))
int targetBadgeX = leftEdge + int(math.round((rightEdge - leftEdge) * 0.84))
bool visualContextActive = activeDir != 0 and hasRecentTouch
float riskShelfHalf = safeAtr * math.max(riskShelfBufferAtr, 0.08)
float riskTopRaw = activeDir == 1 ? riskRail + riskShelfHalf : riskRail
float riskBottomRaw = activeDir == 1 ? riskRail : riskRail - riskShelfHalf
float riskTop = math.max(riskTopRaw, riskBottomRaw)
float riskBottom = math.min(riskTopRaw, riskBottomRaw)
float pocketMid = (pocketTop + pocketBottom) * 0.5
float riskMid = (riskTop + riskBottom) * 0.5
bool pocketRiskOverlap = visualContextActive and pocketTop >= riskBottom and riskTop >= pocketBottom
bool pocketRiskClose = visualContextActive and math.abs(pocketMid - riskMid) <= safeAtr * 0.38
bool mergePocketRiskText = showAcceptancePocket and showRiskShelf and (pocketRiskOverlap or pocketRiskClose)

if barstate.islast
    if showAcceptancePocket and visualContextActive
        color pocketColor = stateText == "PB REJECTED" ? bearColor : activeDir == 1 ? bullColor : bearColor
        string pocketText = mergePocketRiskText ? "Pullback | " + f_state_badge(stateText) + " | Q " + str.tostring(acceptanceScore) : "Accept | " + f_state_badge(stateText) + " | Q " + str.tostring(acceptanceScore)
        if na(pocketBox)
            pocketBox := box.new(left = leftEdge, top = pocketTop, right = rightEdge, bottom = pocketBottom, xloc = xloc.bar_index, bgcolor = color.new(pocketColor, zoneTransparency), border_color = color.new(pocketColor, 28), border_width = 1)
        else
            f_box_set(pocketBox, leftEdge, pocketTop, rightEdge, pocketBottom, color.new(pocketColor, zoneTransparency), color.new(pocketColor, 28))
        pocketBadge := f_badge_set(pocketBadge, centerX, pocketMid, pocketText, pocketColor, labelFontSize)
    else if not na(pocketBox)
        box.delete(pocketBox)
        pocketBox := na
        if not na(pocketBadge)
            label.delete(pocketBadge)
            pocketBadge := na

    if showRiskShelf and visualContextActive and not na(riskRail)
        string riskBoxText = mergePocketRiskText ? "" : "Risk | " + f_price(riskRail)
        if na(riskBox)
            riskBox := box.new(left = leftEdge, top = riskTop, right = rightEdge, bottom = riskBottom, xloc = xloc.bar_index, bgcolor = color.new(bearColor, 92), border_color = color.new(bearColor, 35), border_width = 1)
        else
            f_box_set(riskBox, leftEdge, riskTop, rightEdge, riskBottom, color.new(bearColor, 92), color.new(bearColor, 35))
        if mergePocketRiskText
            if not na(riskBadge)
                label.delete(riskBadge)
                riskBadge := na
        else
            riskBadge := f_badge_set(riskBadge, riskBadgeX, riskMid, riskBoxText, bearColor, labelFontSize)
        if na(riskLine)
            riskLine := line.new(x1 = leftEdge, y1 = riskRail, x2 = rightEdge, y2 = riskRail, xloc = xloc.bar_index, extend = extend.none, color = color.new(bearColor, 0), style = line.style_dotted, width = 1)
        else
            line.set_xy1(riskLine, leftEdge, riskRail)
            line.set_xy2(riskLine, rightEdge, riskRail)
            line.set_color(riskLine, color.new(bearColor, 0))
    else
        if not na(riskBox)
            box.delete(riskBox)
            riskBox := na
        if not na(riskBadge)
            label.delete(riskBadge)
            riskBadge := na
        if not na(riskLine)
            line.delete(riskLine)
            riskLine := na

    bool targetAvailable = visualContextActive and not na(targetRef) and targetRoomAtr > 0.10
    float targetTopRaw = activeDir == 1 ? targetRef : close
    float targetBottomRaw = activeDir == 1 ? close : targetRef
    float targetTop = math.max(targetTopRaw, targetBottomRaw)
    float targetBottom = math.min(targetTopRaw, targetBottomRaw)
    float minTargetHeight = safeAtr * 0.14
    float targetMid = (targetTop + targetBottom) * 0.5
    if targetAvailable and targetTop - targetBottom < minTargetHeight
        targetTop += minTargetHeight * 0.50
        targetBottom -= minTargetHeight * 0.50
    if showTargetBand and targetAvailable
        string targetText = "Room | " + f_atr(targetRoomAtr)
        color targetColor = targetRoomAtr >= effectiveCleanRoomAtr ? accentColor : neutralColor
        if na(targetBox)
            targetBox := box.new(left = centerX, top = targetTop, right = rightEdge, bottom = targetBottom, xloc = xloc.bar_index, bgcolor = color.new(targetColor, 93), border_color = color.new(targetColor, 45), border_width = 1)
        else
            f_box_set(targetBox, centerX, targetTop, rightEdge, targetBottom, color.new(targetColor, 93), color.new(targetColor, 45))
        targetBadge := f_badge_set(targetBadge, targetBadgeX, targetMid, targetText, targetColor, labelFontSize)
        if na(targetLine)
            targetLine := line.new(x1 = centerX, y1 = targetRef, x2 = rightEdge, y2 = targetRef, xloc = xloc.bar_index, extend = extend.none, color = color.new(targetColor, 10), style = line.style_dashed, width = 1)
        else
            line.set_xy1(targetLine, centerX, targetRef)
            line.set_xy2(targetLine, rightEdge, targetRef)
            line.set_color(targetLine, color.new(targetColor, 10))
    else
        if not na(targetBox)
            box.delete(targetBox)
            targetBox := na
        if not na(targetBadge)
            label.delete(targetBadge)
            targetBadge := na
        if not na(targetLine)
            line.delete(targetLine)
            targetLine := na

// -------------------------------------------------
// Labels
// -------------------------------------------------
var array<label> eventLabels = array.new_label()
var int lastEventLabelBar = na
var int lastContextLabelBar = na

bool previousAccepted = bar_index > 0 ? acceptedNow[1] : false
bool previousRejected = bar_index > 0 ? rejectedNow[1] : false
bool previousWatch = bar_index > 0 ? watchNow[1] : false
bool previousRoomReview = bar_index > 0 ? roomReviewNow[1] : false
bool acceptedEvent = acceptedNow and not previousAccepted
bool rejectedEvent = rejectedNow and not previousRejected
bool watchEvent = watchNow and not previousWatch
bool roomReviewEvent = roomReviewNow and not previousRoomReview
bool eventCooldownOk = na(lastEventLabelBar) or bar_index - lastEventLabelBar >= labelCooldownBars
bool contextCooldownOk = na(lastContextLabelBar) or bar_index - lastContextLabelBar >= contextSpacingBars
bool contextEvent = showContextLabels and contextCooldownOk and formingNow and acceptanceScore >= math.max(effectiveWatchThreshold - 8, 20)
bool labelHistoryOk = bar_index >= last_bar_index - labelHistoryBars
bool criticalPrimaryEvent = acceptedEvent or rejectedEvent
bool secondaryPrimaryEvent = watchEvent or roomReviewEvent
bool primaryEvent = criticalPrimaryEvent or secondaryPrimaryEvent
bool labelEvent = labelHistoryOk and showEventLabels and activeDir != 0 and (criticalPrimaryEvent or (secondaryPrimaryEvent and eventCooldownOk) or contextEvent)

if labelEvent
    bool eventRejected = rejectedEvent
    bool labelBelow = eventRejected ? activeDir == -1 : activeDir == 1
    float labelY = labelBelow ? low - safeAtr * labelOffsetAtr : high + safeAtr * labelOffsetAtr
    string labelState = contextEvent ? "PB FORMING" : rejectedEvent ? "PB REJECTED" : acceptedEvent ? "PB ACCEPTED" : roomReviewEvent ? "ROOM REVIEW" : "ACCEPT WATCH"
    string labelText = f_state_badge(labelState)
    if showLabelScore and labelState != "PB REJECTED"
        labelText += " | Q " + str.tostring(acceptanceScore)
    if labelState == "PB REJECTED"
        labelText += " | Invalid"
    else if labelState == "ROOM REVIEW"
        labelText += " | Room " + f_atr(targetRoomAtr)
    else if labelState == "PB ACCEPTED"
        labelText += " | Risk " + f_atr(riskDistanceAtr)
    else if labelState == "PB FORMING"
        labelText += " | " + f_direction_text(activeDir)
    color labelColor = f_state_color(labelState, activeDir)
    label eventLabel = label.new(x = bar_index, y = labelY, text = labelText, xloc = xloc.bar_index, yloc = yloc.price, style = labelBelow ? label.style_label_up : label.style_label_down, color = color.new(labelColor, 3), textcolor = headerText, size = f_text_size(labelFontSize), textalign = text.align_center)
    array.push(eventLabels, eventLabel)
    f_trim_labels(eventLabels, maxVisibleLabels)
    if contextEvent
        lastContextLabelBar := bar_index
    else
        lastEventLabelBar := bar_index

// -------------------------------------------------
// Confirmation-anchored proof (accepted pullbacks, Follow = continued 1R toward room before risk rail)
// -------------------------------------------------
bool proofAcceptedEvent = proofConfirmedBar and engineReady and acceptedNow and not acceptedNow[1]

var int proofTotal = 0
var int proofFollow = 0
var int proofHold = 0
var int proofReact = 0
var int proofFlip = 0
var int proofAmbiguous = 0
var bool pEvalActive = false
var int pEvalDir = 0
var int pEvalStart = na
var float pEvalEntry = na
var float pEvalStop = na
var float pEvalTarget = na
var bool pReacted = false
var bool pFollowed = false

if proofConfirmedBar and engineReady
    if pEvalActive
        int heldBars = bar_index - pEvalStart
        float followDist = math.max(math.abs(pEvalTarget - pEvalEntry), syminfo.mintick)
        float favorableExcursion = pEvalDir == 1 ? high - pEvalEntry : pEvalEntry - low
        bool targetTouched = heldBars >= 1 and favorableExcursion >= followDist
        bool stopTouched = pEvalDir == 1 ? low <= pEvalStop : high >= pEvalStop
        bool directionReplaced = activeDir != pEvalDir
        bool ambiguousNow = targetTouched and (stopTouched or directionReplaced)

        if heldBars >= 1 and heldBars <= effectiveReactBars and favorableExcursion >= followDist * reactProgressPct / 100.0
            pReacted := true
        if targetTouched and not stopTouched and not directionReplaced
            pFollowed := true

        bool horizonDone = heldBars >= proofHorizonBars
        bool resolveNow = ambiguousNow or targetTouched or stopTouched or directionReplaced or horizonDone

        if resolveNow
            if ambiguousNow
                proofAmbiguous := proofAmbiguous + 1
            else
                proofTotal := proofTotal + 1
                if pFollowed
                    proofFollow := proofFollow + 1
                if not stopTouched and not directionReplaced
                    proofHold := proofHold + 1
                if pReacted
                    proofReact := proofReact + 1
                if stopTouched or directionReplaced
                    proofFlip := proofFlip + 1
            pEvalActive := false

    // Open exactly one evaluation for each confirmed accepted-pullback call.
    // New accepted calls are ignored while the current non-overlapping sample is active.
    if proofAcceptedEvent and not pEvalActive and not na(riskRail) and not na(targetRef)
        pEvalActive := true
        pEvalDir := activeDir
        pEvalEntry := close
        pEvalStop := riskRail

        float pStopDist = math.max(math.abs(close - riskRail), syminfo.mintick)
        float pRoomDist = math.max(math.abs(targetRef - close), syminfo.mintick)
        float pFollowDist = math.min(pStopDist, pRoomDist)
        pEvalTarget := close + pEvalDir * pFollowDist
        pEvalStart := bar_index
        pReacted := false
        pFollowed := false

float followRate = proofTotal > 0 ? proofFollow * 100.0 / proofTotal : 0.0
float holdRate = proofTotal > 0 ? proofHold * 100.0 / proofTotal : 0.0
float reactRate = proofTotal > 0 ? proofReact * 100.0 / proofTotal : 0.0
float flipRate = proofTotal > 0 ? proofFlip * 100.0 / proofTotal : 0.0

// -------------------------------------------------
// Data Window
// -------------------------------------------------
plot(acceptanceScore, title = "Pullback Acceptance Score", color = f_score_color(acceptanceScore), display = display.data_window)
plot(depthScore, title = "Pullback Depth Score", color = neutralColor, display = display.data_window)
plot(closeScore, title = "Close Acceptance Score", color = accentColor, display = display.data_window)
plot(riskDistanceAtr, title = "Risk Distance ATR", color = bearColor, display = display.data_window)
plot(targetRoomAtr, title = "Target Room ATR", color = bullColor, display = display.data_window)
plot(followRate, title = "Follow Rate", color = f_rate_color(followRate), display = display.data_window)
plot(holdRate, title = "Hold Rate", color = f_rate_color(holdRate), display = display.data_window)
plot(reactRate, title = "React Rate", color = f_rate_color(reactRate), display = display.data_window)
plot(flipRate, title = "Flip Rate", color = f_flip_color(flipRate), display = display.data_window)
plot(proofAmbiguous, title = "Ambiguous Proof Count", color = panelValueCol, display = display.data_window)
plot(pullbackDepthAtr, title = "Pullback Depth ATR", color = neutralColor, display = display.data_window)
plot(activeDir, title = "Pullback Direction", color = accentColor, display = display.data_window)
plot(hasRecentTouch ? barsSinceTouchRaw : na, title = "Bars Since Pocket Touch", color = panelValueCol, display = display.data_window)

// -------------------------------------------------
// Panel
// -------------------------------------------------
string proofSampleText = proofTotal > 0 ? "n = " + str.tostring(proofTotal) + (proofAmbiguous > 0 ? " | x = " + str.tostring(proofAmbiguous) : "") : proofAmbiguous > 0 ? "x = " + str.tostring(proofAmbiguous) : "building"
string followTextPanel = proofTotal > 0 ? f_pct(followRate) : "-"
string holdTextPanel = proofTotal > 0 ? f_pct(holdRate) : "-"
string reactTextPanel = proofTotal > 0 ? f_pct(reactRate) : "-"
string flipTextPanel = proofTotal > 0 ? f_pct(flipRate) : "-"
color followColPanel = proofTotal > 0 ? f_rate_color(followRate) : f_panel_value(panelTheme)
color holdColPanel = proofTotal > 0 ? f_rate_color(holdRate) : f_panel_value(panelTheme)
color reactColPanel = proofTotal > 0 ? f_rate_color(reactRate) : f_panel_value(panelTheme)
color flipColPanel = proofTotal > 0 ? f_flip_color(flipRate) : f_panel_value(panelTheme)

int panelRowCount = showProof ? 12 : 7
var table infoPanel = na
var string lastPanelLocation = ""
var string lastPanelTheme = ""
var string lastPanelFont = ""
var bool lastProofMode = false

if barstate.islast
    if showPanel
        if na(infoPanel) or panelLocation != lastPanelLocation or panelTheme != lastPanelTheme or panelFontSize != lastPanelFont or showProof != lastProofMode
            if not na(infoPanel)
                table.delete(infoPanel)
            infoPanel := table.new(f_panel_position(panelLocation), 2, panelRowCount, bgcolor = f_panel_bg(panelTheme), frame_color = f_panel_border(panelTheme), frame_width = 1, border_color = f_panel_border(panelTheme), border_width = 1)
            lastPanelLocation := panelLocation
            lastPanelTheme := panelTheme
            lastPanelFont := panelFontSize
            lastProofMode := showProof
        table.clear(infoPanel, 0, 0, 1, panelRowCount - 1)
        table.merge_cells(infoPanel, 0, 0, 1, 0)
        table.cell(infoPanel, 0, 0, "AG Pro Pullback Acceptance Planner", text_color = headerText, bgcolor = headerBg, text_size = f_text_size(panelFontSize), text_halign = text.align_center)
        bool bestViewActive = timeframe.isintraday and (timeframe.multiplier == 15 or timeframe.multiplier == 30)
        string bestViewText = bestViewActive ? "15m / 30m Active" : "Use 15m / 30m"
        color bestViewColor = bestViewActive ? bullColor : accentColor
        f_panel_row(infoPanel, 1, "Pullback State", stateText, stateColor, panelTheme, panelFontSize)
        f_panel_row(infoPanel, 2, "Acceptance Score", scoreText, scorePanelColor, panelTheme, panelFontSize)
        f_panel_row(infoPanel, 3, "Risk Edge", riskText, riskPanelColor, panelTheme, panelFontSize)
        f_panel_row(infoPanel, 4, "Room", roomText, roomPanelColor, panelTheme, panelFontSize)
        f_panel_row(infoPanel, 5, "Action", actionText, stateColor, panelTheme, panelFontSize)
        f_panel_row(infoPanel, 6, "Best View", bestViewText, bestViewColor, panelTheme, panelFontSize)
        if showProof
            color proofHeadBg = f_row_bg(panelTheme, 7)
            table.cell(infoPanel, 0, 7, "Proof @ Confirm", text_color = accentColor, bgcolor = proofHeadBg, text_size = f_text_size(panelFontSize), text_halign = text.align_left)
            table.cell(infoPanel, 1, 7, proofSampleText, text_color = f_panel_label(panelTheme), bgcolor = proofHeadBg, text_size = f_text_size(panelFontSize), text_halign = text.align_right)
            f_panel_row(infoPanel, 8, "Follow Rate", followTextPanel, followColPanel, panelTheme, panelFontSize)
            f_panel_row(infoPanel, 9, "Hold Rate", holdTextPanel, holdColPanel, panelTheme, panelFontSize)
            f_panel_row(infoPanel, 10, "React Rate", reactTextPanel, reactColPanel, panelTheme, panelFontSize)
            f_panel_row(infoPanel, 11, "Flip Rate", flipTextPanel, flipColPanel, panelTheme, panelFontSize)
    else if not na(infoPanel)
        table.delete(infoPanel)
        infoPanel := na
        lastPanelLocation := ""
        lastPanelTheme := ""
        lastPanelFont := ""

// -------------------------------------------------
// Alerts
// -------------------------------------------------
var bool acceptedCycleActive = false
var bool acceptedCycleAlerted = false
var int acceptedCycleDir = 0
var int acceptedCycleStartBar = na
var float acceptedCycleEdge = na

if acceptedEvent
    acceptedCycleActive := true
    acceptedCycleAlerted := false
    acceptedCycleDir := activeDir
    acceptedCycleStartBar := bar_index
    acceptedCycleEdge := activeDir == 1 ? pocketTop : pocketBottom

if acceptedCycleActive and (rejectedEvent or activeDir != acceptedCycleDir or activeDir == 0)
    acceptedCycleActive := false

float acceptedCycleProgressAtr = acceptedCycleActive and not na(acceptedCycleEdge) ?
     acceptedCycleDir == 1 ? (high - acceptedCycleEdge) / safeAtr : (acceptedCycleEdge - low) / safeAtr :
     0.0

bool followThroughNow = acceptedCycleActive and bar_index > acceptedCycleStartBar and acceptedCycleProgressAtr >= followThroughAtr
bool followThroughEvent = confirmationOk and followThroughNow and not acceptedCycleAlerted
if followThroughEvent
    acceptedCycleAlerted := true

bool scoreGate = acceptanceScore >= effectiveAlertScoreThreshold

alertcondition(acceptedEvent and scoreGate and activeDir == 1, title = "Bullish Pullback Accepted", message = "Pullback Acceptance Planner: bullish pullback acceptance reached READY state. This is an attention marker, not a trade instruction.")
alertcondition(acceptedEvent and scoreGate and activeDir == -1, title = "Bearish Pullback Accepted", message = "Pullback Acceptance Planner: bearish pullback acceptance reached READY state. This is an attention marker, not a trade instruction.")
alertcondition(watchEvent and scoreGate, title = "Pullback Acceptance Watch", message = "Pullback Acceptance Planner: pullback context is near acceptance quality but still needs cleaner confirmation.")
alertcondition(roomReviewEvent and scoreGate, title = "Pullback Room Review", message = "Pullback Acceptance Planner: pullback quality is active but target room is limited near prior obstruction.")
alertcondition(rejectedEvent, title = "Pullback Rejected", message = "Pullback Acceptance Planner: price rejected the active pullback pocket and crossed the invalidation shelf.")
alertcondition(followThroughEvent and scoreGate, title = "Pullback Follow-Through", message = "Pullback Acceptance Planner: accepted pullback context has produced major follow-through progress. Review risk and target context.")
````
