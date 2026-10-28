# R-Multiple Progress Map [AGPro Series]

- url: https://www.tradingview.com/script/7gqCiRoM-R-Multiple-Progress-Map-AGPro-Series/
- type: indicator
- pine_id: PUB;0e6b5f289d3547f19b3f73c5a86a0cb4
- version: 6.0

## Description

R-Multiple Progress Map [AGPro Series]

🧠 Core Idea

How far has the active move progressed in R terms, and is that progress still healthy enough to monitor?


📌 Overview / What it does

R-Multiple Progress Map [AGPro Series] is a chart-first trade management overlay that tracks a setup after activation and converts price movement into R-multiple progress.

Instead of acting like a risk/reward calculator, a position sizing tool, or a take-profit promise system, the script focuses on what happens after an active cycle begins. It maps an entry proxy, invalidation proxy, R ladder, current R marker, partial-review bands, pullback-risk state, and a clean AGPro progress panel.

The script does not predict future price movement, place orders, automate trade management, or tell the user what to buy or sell. It is a structured progress-reading layer for discretionary review.


🎯 Purpose & Design Philosophy

This script was built for traders who think in R-multiples but need a cleaner way to read progress quality after a setup becomes active.

Many tools help plan the trade before activation. Fewer tools focus on the management question after activation: is the move actually making progress, is pullback pressure increasing, where is the next R review zone, and what should the user pay attention to now?

The design supports a decision-engine mindset: measure progress, evaluate health, and keep the chart readable without turning it into a crowded signal board.


⚡ Why This Script Is Different

Most tools focus on drawing entry, stop-loss, and take-profit levels before a trade begins.

This script does NOT try to become a full position planner, risk/reward visualizer, position-size calculator, or target ladder.

Instead, it starts from an activated progress cycle and evaluates the move in R terms. The unique output is not a trade instruction. It is a live progress state that separates ACTIVE, BUILDING, PROGRESSING, EXTENDED, PULLBACK RISK, STALLED, INVALIDATED, and WAIT conditions.


⚙️ Methodology

1. Context Detection
The script detects activation using range-break and trend-pulse logic, or allows the user to restrict the map to long-only or short-only progress context.

2. Reference Mapping
When a progress cycle activates, the script stores an entry proxy, invalidation proxy, R-risk unit, active side, active bar, maximum favorable R progress, and adverse R pressure.

3. Reaction Evaluation
The model evaluates R expansion, candle progress, trend support, drawdown pressure, time efficiency, and volatility stability. These components are blended into a 0-100 progress score.

4. Visual Output
The output is shown through an R ladder, centered partial-review bands, live progress fill, current R marker, event labels, alerts, and a compact AGPro panel.


🗺️ How to Read the Chart

Zones = partial-review R bands between key R levels, such as 0.5R-1R, 1R-2R, and 2R-3R.

Labels = activation, R milestone, pullback-risk, stalled-progress, and invalidation markers.

Colors = bullish progress, bearish progress, warning states, and neutral states use the AGPro color language.

Panel = the panel summarizes Current R, Progress Grade, Pullback Risk, Next R Zone, and Action.


🚦 Signals & States

• ACTIVE → a new progress cycle has activated and early R progress is being measured.

• BUILDING → price has started to make useful R progress but is not yet strong enough for a higher-grade state.

• PROGRESSING → the move has reached meaningful R progress with supportive score conditions.

• EXTENDED → progress is advanced and the next R zone deserves review.

• PULLBACK RISK → price has given back enough favorable R progress to deserve caution.

• STALLED → the active cycle has spent time without enough R progress.

• INVALIDATED → the active cycle touched the invalidation proxy.

• WAIT → no active progress cycle is currently being tracked.


🔔 Alerts Logic

Alerts trigger when a new progress cycle activates, when 0.5R, 1R, or 2R progress is reached, when pullback risk increases, when progress stalls, or when the invalidation proxy is touched.

These alerts are attention markers. They are not trade instructions, entry signals, exit signals, or automated strategy commands.


🧩 Confluence Logic

The strongest progress context appears when multiple components align:

R expansion + strong candle progress + trend support + controlled pullback drawdown + efficient timing + stable volatility.

When these components align, the script can classify the active move as PROGRESSING or EXTENDED. If drawdown pressure rises or time efficiency weakens, the state can shift toward PULLBACK RISK or STALLED.


📊 When to Use

• After a breakout or continuation attempt has activated

• While monitoring whether a setup is progressing in clean R terms

• During discretionary trade management review

• When comparing whether a move is building, stalling, or extending

• When the user wants chart-first R progress without a full position-size calculator


⚠️ When NOT to Use

• Extremely low-liquidity symbols

• Very noisy micro-timeframes with unstable wick behavior

• News-driven volatility spikes

• Markets where recent structure cannot define a useful invalidation proxy

• Situations where the user expects a complete risk/reward planning suite


🎛️ Key Inputs

• Progress Side → controls Auto, Long Progress, or Short Progress evaluation.

• Activation Mode → chooses Range Break, Trend Pulse, or Hybrid activation logic.

• Structure Lookback → defines the activation and context window.

• Invalidation Proxy Lookback → maps the R-risk reference used for progress normalization.

• Minimum Activation Score → controls how selective new progress cycles are.

• Pullback Risk R → defines how much R drawdown triggers caution.

• Visual settings → control R ladder, partial-review bands, progress fill, labels, panel location, theme, and font sizes.


🖥️ Interface & Visual Design

The interface is built around one primary idea: R progress after activation.

The R ladder and partial-review bands keep the chart visually informative, while the panel keeps the decision state compact and readable.

Labels are offset away from candles, limited by maximum count, and controlled with cooldown and sparse context settings for a balanced public-release chart.


🧪 Practical Usage Workflow

1. Read the panel action state.

2. Check the current R and maximum R progress.

3. Review whether pullback risk is low, moderate, or high.

4. Look at the next R zone for management context.

5. Treat alerts as attention markers and confirm the broader market context independently.


🔍 Interpretation Guidelines

A higher progress score means the active move is showing stronger alignment between R expansion, trend support, drawdown control, time efficiency, and volatility stability.

PROGRESSING does not mean a trade should be opened or held. It means the active cycle is showing healthier R progress under the script's rule set.

PULLBACK RISK and STALLED are caution states. They help identify when progress may be weakening after an active move has already started.


🚫 What This Script Is NOT

This script is not a prediction engine.

It is not financial advice.

It is not an auto-trading system.

It does not provide guaranteed signals.

It is not a full position planner, risk/reward visualizer, or position-size calculator.


⚠️ Limitations & Transparency

Timeframe differences can change activation behavior and invalidation proxy placement.

Volatility changes can alter ATR-normalized risk and R-progress readings.

Market structure can shift quickly after news, low-liquidity movement, or aggressive momentum expansion.

The script is rule-based and should be interpreted as an analytical progress layer, not as certainty.


🧠 Market Context Notes

R progress is not only about distance from activation. It also depends on how much progress is being retained, whether trend context still supports the active side, and whether time spent in the setup is becoming inefficient.

The tool is most useful when it helps the user review an active move with discipline instead of reacting emotionally to each candle.


🧾 Use Case Examples

When a trend-pulse activation reaches 1R with strong score conditions and low drawdown, the script may classify the move as PROGRESSING.

When a move reaches 2R but begins giving back a meaningful amount of favorable progress, the script may show PULLBACK RISK.

When a cycle stays active for many bars without reaching useful R progress, the script may show STALLED.


🧱 System Philosophy

R-Multiple Progress Map follows the AGPro Series decision-engine approach:

Progress after activation.
Risk measured in R.
Management context before emotion.
Attention markers instead of promises.


🔐 Non-Promise Statement

No script can guarantee that R progress will continue.

No state should be interpreted as certainty.

All outputs should be reviewed within broader market context.


📉 Risk Disclosure

Trading involves risk.

Users are responsible for their own decisions, risk management, and trade execution.

This script is for educational and analytical purposes only and does not provide financial advice.


📚 Educational Note

The script is designed to help users think in structured R-progress terms: activation, progress, pullback, stall, invalidation, and review.

## Source Code

````pine
// -------------------------------------------------
// R-Multiple Progress Map [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 1.7
//
// R-Multiple Progress Map is a chart-first trade management overlay that tracks
// active price movement in R-multiple terms after a qualified setup cycle starts.
// It maps entry proxy, invalidation proxy, R ladder levels, pullback pressure,
// time efficiency, trend support, and a 0-100 progress score. Version 1.6 adds a
// confirmation-anchored proof layer (Follow, Hold, React, Flip rates) that shows
// how often activated cycles reached 1R before invalidation on the current symbol.
// -------------------------------------------------

//@version=6
indicator("R-Multiple Progress Map [AGPro Series]",
     shorttitle       = "AG Pro RPM",
     overlay          = true,
     max_labels_count = 120,
     max_boxes_count  = 30,
     max_lines_count  = 50)

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
dangerColor   = color.rgb(239, 68, 68)

// -------------------------------------------------
// Tooltips
// -------------------------------------------------
ttPreset = "Applies a complete preset for activation strictness, tracking length, label density, and R-map behavior. Custom keeps the manual settings below."
ttDirectionMode = "Selects the progress side. Auto accepts either long or short activation. Manual modes restrict the map to one directional context without printing buy or sell commands."
ttActivationMode = "Controls how a progress cycle becomes active. Range Break uses structure edges, Trend Pulse uses trend continuation recovery, and Hybrid accepts either condition."
ttLookback = "Bars used to define the activation edge, progress context, and recent structure. Higher values create slower but more selective activation points."
ttStopLookback = "Bars used to locate the proxy invalidation level when a new progress cycle activates. The stop proxy is used only to normalize R progress."
ttAtrLen = "ATR length used for stop buffering, label offsets, volatility checks, and visual spacing."
ttStopBuffer = "ATR buffer added beyond the recent swing used as the R-risk proxy. Larger values produce wider R units and slower R progress."
ttRiskBounds = "Minimum and maximum ATR-normalized risk unit accepted by the tracker. This avoids tiny proxy risk and overly wide R maps."
ttMinActivationScore = "Minimum activation quality required before a new progress cycle starts. Higher values reduce noisy cycles."
ttMinProgressScore = "Minimum progress score used to classify strong management states such as PROGRESSING or EXTENDED."
ttPullbackRiskR = "R drawdown from the best favorable excursion that triggers a pullback-risk state."
ttStallBars = "Number of active bars after which weak R progress can be classified as stalled."
ttMaxTrackBars = "Maximum number of bars a progress cycle can remain active before it expires and waits for a new activation."
ttShowLadder = "Shows the active R ladder, including entry proxy, invalidation proxy, 0.5R, 1R, 2R, and 3R reference levels."
ttShowBands = "Shows centered partial-review bands between key R levels. These are R-progress bands, not support or resistance zones."
ttShowFill = "Shows a live progress fill between the activation entry proxy and current R progress."
ttShowLiveTags = "Shows compact right-edge tags for workflow, current R, pullback pressure, and invalidation context."
ttProjection = "Number of bars used to project the active R ladder and progress bands to the right."
ttLiveOffset = "Moves live review tags to the right of the projected R map while extending level references to the same area."
ttLiveSpacing = "Controls vertical spacing between right-side live review badges. Higher values create a more spacious public chart layout."
ttShowLabels = "Shows compact activation, R milestone, pullback, stall, invalidation, and expiry labels."
ttPullbackLabels = "Shows the first major pullback-risk label during an active R cycle. Keeping this enabled preserves the story without repeating the same warning too often."
ttExpiredLabels = "Shows EXPIRED labels when R-progress cycles time out. Disabled by default because expiry can be frequent and should not dominate publication charts."
ttShowContext = "Adds sparse context labels during long active cycles. Disabled by default for a cleaner public-release chart."
ttLabelOffset = "ATR-based label offset used to keep labels above or below candles."
ttLabelLane = "Additional ATR spacing between nearby label families. Higher values reduce overlap during milestone clusters."
ttLabelCooldown = "Minimum bars between repeated pullback or context labels."
ttContextSpacing = "Minimum bars between sparse active-cycle context labels."
ttMaxLabels = "Maximum number of chart labels retained. Older labels are removed first to preserve performance."
ttShowScore = "Adds the 0-100 progress score to event labels while keeping label text compact."
ttLabelSize = "Font size for all chart labels and R-band text. Normal is the publication default."
ttShowPanel = "Shows or hides the AG Pro progress panel. The panel is enabled by default for public-release readability."
ttPanelLocation = "Moves the AG Pro progress panel to the selected chart location."
ttPanelTheme = "Switches the panel between AGPro dark styling and a clean light theme."
ttPanelFont = "Font size for the AG Pro progress panel. Normal is the publication default."
ttAlerts = "Enables alert conditions for activation, R milestones, pullback risk, stall, invalidation, and expiry states."
ttShowProof = "Shows the confirmation-anchored proof layer in the panel: Follow, Hold, React, and Flip rates measured across activated R-cycles on the current symbol and timeframe. Follow means the cycle reached 1R in favor before touching its invalidation proxy. These are historical outcome rates, not predictions."
ttProofHorizon = "Maximum number of bars each activated cycle is tracked for the proof measurement before it resolves at its current outcome."
ttReactBars = "Number of bars after a cycle activates used to detect an immediate favorable R reaction."
ttReactProgress = "Minimum favorable R progress (as a percent of one risk unit), within the reaction window, required to count as an early React."

// -------------------------------------------------
// Inputs
// -------------------------------------------------
groupEngine = "Progress Engine"
enginePreset = input.string("Balanced Progress", "Engine Preset", options = ["Balanced Progress", "Cleaner Swing", "Active Intraday", "Custom"], group = groupEngine, tooltip = ttPreset)
directionMode = input.string("Auto", "Progress Side", options = ["Auto", "Long Progress", "Short Progress"], group = groupEngine, tooltip = ttDirectionMode)
activationMode = input.string("Hybrid", "Activation Mode", options = ["Hybrid", "Range Break", "Trend Pulse"], group = groupEngine, tooltip = ttActivationMode)
lookback = input.int(48, "Structure Lookback", minval = 12, maxval = 240, group = groupEngine, tooltip = ttLookback)
stopLookback = input.int(18, "Invalidation Proxy Lookback", minval = 5, maxval = 120, group = groupEngine, tooltip = ttStopLookback)
atrLen = input.int(14, "ATR Length", minval = 2, maxval = 100, group = groupEngine, tooltip = ttAtrLen)
stopBufferAtr = input.float(0.22, "Invalidation Buffer ATR", minval = 0.00, maxval = 2.50, step = 0.01, group = groupEngine, tooltip = ttStopBuffer)
minRiskAtr = input.float(0.45, "Minimum Risk Unit ATR", minval = 0.05, maxval = 5.00, step = 0.05, group = groupEngine, tooltip = ttRiskBounds)
maxRiskAtr = input.float(4.20, "Maximum Risk Unit ATR", minval = 0.50, maxval = 12.00, step = 0.10, group = groupEngine, tooltip = ttRiskBounds)

groupScoring = "Progress Scoring"
minActivationScore = input.float(58.0, "Minimum Activation Score", minval = 25.0, maxval = 95.0, step = 1.0, group = groupScoring, tooltip = ttMinActivationScore)
minProgressScore = input.float(64.0, "Strong Progress Score", minval = 35.0, maxval = 95.0, step = 1.0, group = groupScoring, tooltip = ttMinProgressScore)
pullbackRiskR = input.float(0.65, "Pullback Risk R", minval = 0.20, maxval = 2.50, step = 0.05, group = groupScoring, tooltip = ttPullbackRiskR)
stallBars = input.int(24, "Stall Review Bars", minval = 8, maxval = 160, group = groupScoring, tooltip = ttStallBars)
maxTrackingBars = input.int(120, "Maximum Tracking Bars", minval = 24, maxval = 500, group = groupScoring, tooltip = ttMaxTrackBars)

groupVisual = "R Ladder Visuals"
showRLadder = input.bool(true, "Show R Ladder", group = groupVisual, tooltip = ttShowLadder)
showPartialBands = input.bool(true, "Show Partial-Review Bands", group = groupVisual, tooltip = ttShowBands)
showProgressFill = input.bool(true, "Show Progress Fill", group = groupVisual, tooltip = ttShowFill)
showLiveReviewTags = input.bool(true, "Show Live Review Tags", group = groupVisual, tooltip = ttShowLiveTags)
projectionBars = input.int(42, "Projection Bars", minval = 12, maxval = 180, group = groupVisual, tooltip = ttProjection)
liveTagOffsetBars = input.int(8, "Live Tag Offset Bars", minval = 3, maxval = 80, group = groupVisual, tooltip = ttLiveOffset)
liveTagSpacingAtr = input.float(1.10, "Live Tag Spacing ATR", minval = 0.45, maxval = 4.00, step = 0.05, group = groupVisual, tooltip = ttLiveSpacing)

groupLabels = "Labels"
showEventLabels = input.bool(true, "Show Event Labels", group = groupLabels, tooltip = ttShowLabels)
showPullbackLabels = input.bool(true, "Show Pullback Risk Label", group = groupLabels, tooltip = ttPullbackLabels)
showExpiredLabels = input.bool(false, "Show Expired Labels", group = groupLabels, tooltip = ttExpiredLabels)
showContextLabels = input.bool(false, "Show Sparse Context Labels", group = groupLabels, tooltip = ttShowContext)
labelOffsetAtr = input.float(1.05, "Label Offset ATR", minval = 0.10, maxval = 4.00, step = 0.05, group = groupLabels, tooltip = ttLabelOffset)
labelLaneSpreadAtr = input.float(0.42, "Label Lane Spread ATR", minval = 0.00, maxval = 2.00, step = 0.05, group = groupLabels, tooltip = ttLabelLane)
labelCooldownBars = input.int(28, "Label Cooldown Bars", minval = 1, maxval = 120, group = groupLabels, tooltip = ttLabelCooldown)
contextSpacingBars = input.int(72, "Context Label Spacing", minval = 16, maxval = 240, group = groupLabels, tooltip = ttContextSpacing)
maxVisibleLabels = input.int(7, "Max Visible Labels", minval = 4, maxval = 80, group = groupLabels, tooltip = ttMaxLabels)
showLabelScore = input.bool(true, "Show Label Score", group = groupLabels, tooltip = ttShowScore)
labelSizeInput = input.string("Normal", "Label Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = groupLabels, tooltip = ttLabelSize)

groupPanel = "Panel"
showPanel = input.bool(true, "Show Panel", group = groupPanel, tooltip = ttShowPanel)
panelLocationInput = input.string("Top Right", "Panel Location", options = ["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], group = groupPanel, tooltip = ttPanelLocation)
panelThemeInput = input.string("Dark", "Panel Theme", options = ["Dark", "Light"], group = groupPanel, tooltip = ttPanelTheme)
panelFontSizeInput = input.string("Normal", "Panel Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = groupPanel, tooltip = ttPanelFont)

groupProof = "Proof"
showProof = input.bool(true, "Show Proof Layer", group = groupProof, tooltip = ttShowProof)
proofHorizonBars = input.int(30, "Proof Horizon Bars", minval = 5, maxval = 240, group = groupProof, tooltip = ttProofHorizon)
reactBars = input.int(4, "Reaction Window Bars", minval = 1, maxval = 60, group = groupProof, tooltip = ttReactBars)
reactProgressPct = input.float(33.0, "Reaction Progress %", minval = 5.0, maxval = 80.0, step = 1.0, group = groupProof, tooltip = ttReactProgress)

groupAlerts = "Alerts"
alertProgressStates = input.bool(true, "Alert on Progress States", group = groupAlerts, tooltip = ttAlerts)

// -------------------------------------------------
// Helpers
// -------------------------------------------------
f_clamp(float value, float minValue, float maxValue) =>
    math.min(math.max(value, minValue), maxValue)

f_norm_high_good(float value, float weak, float strong) =>
    span = strong - weak
    span == 0.0 ? 0.0 : f_clamp((value - weak) / span * 100.0, 0.0, 100.0)

f_norm_low_good(float value, float good, float bad) =>
    span = bad - good
    span == 0.0 ? 0.0 : f_clamp((bad - value) / span * 100.0, 0.0, 100.0)

f_risk_fit(float riskAtr, float minAtr, float maxAtr) =>
    safeMin = math.min(minAtr, maxAtr)
    safeMax = math.max(minAtr, maxAtr)
    idealAtr = f_clamp(1.15, safeMin, safeMax)
    result = 0.0
    if riskAtr < safeMin
        result := f_clamp(riskAtr / math.max(safeMin, 0.01) * 70.0, 0.0, 70.0)
    else if riskAtr <= idealAtr
        result := idealAtr == safeMin ? 100.0 : 70.0 + f_clamp((riskAtr - safeMin) / (idealAtr - safeMin) * 30.0, 0.0, 30.0)
    else if riskAtr <= safeMax
        result := safeMax == idealAtr ? 100.0 : 100.0 - f_clamp((riskAtr - idealAtr) / (safeMax - idealAtr) * 50.0, 0.0, 50.0)
    else
        result := 0.0
    result

f_size(string value) =>
    switch value
        "Tiny" => size.tiny
        "Small" => size.small
        "Large" => size.large
        => size.normal

f_position(string value) =>
    switch value
        "Top Left" => position.top_left
        "Top Center" => position.top_center
        "Middle Left" => position.middle_left
        "Middle Center" => position.middle_center
        "Middle Right" => position.middle_right
        "Bottom Left" => position.bottom_left
        "Bottom Center" => position.bottom_center
        "Bottom Right" => position.bottom_right
        => position.top_right

f_grade(float score) =>
    score >= 88.0 ? "A+" : score >= 78.0 ? "A" : score >= 66.0 ? "B" : score >= 54.0 ? "C" : "D"

f_score_color(float score, float threshold) =>
    score >= 78.0 ? bullColor : score >= threshold ? accentColor : score >= 48.0 ? neutralColor : bearColor

f_pct(float value) =>
    str.tostring(int(math.round(value))) + "%"

f_rate_color(float value) =>
    value >= 55 ? bullColor : value >= 40 ? neutralColor : bearColor

f_flip_color(float value) =>
    value <= 30 ? bullColor : value <= 55 ? neutralColor : bearColor

f_price(float value) =>
    na(value) ? "n/a" : str.tostring(value, format.mintick)

f_score_text(float value) =>
    str.tostring(int(math.round(value)))

f_r_text(float value) =>
    na(value) ? "--" : str.tostring(value, "#.##") + "R"

f_label_style(int dir) =>
    dir == 1 ? label.style_label_down : label.style_label_up

f_label_y(int dir, float highValue, float lowValue, float atrValue, float offsetAtr, float laneSpreadAtr, float lane) =>
    dir == 1 ? highValue + atrValue * (offsetAtr + laneSpreadAtr * lane) : lowValue - atrValue * (offsetAtr + laneSpreadAtr * lane)

f_state_color(string state) =>
    switch state
        "PROGRESSING" => bullColor
        "EXTENDED" => bullColor
        "BUILDING" => accentColor
        "ACTIVE" => accentColor
        "PULLBACK RISK" => neutralColor
        "STALLED" => neutralColor
        "INVALIDATED" => dangerColor
        "EXPIRED" => bearColor
        => panelLabelCol

f_state_short(string state) =>
    switch state
        "PROGRESSING" => "PROG"
        "EXTENDED" => "EXT"
        "BUILDING" => "BUILD"
        "PULLBACK RISK" => "PB RISK"
        "INVALIDATED" => "INVALID"
        => state

f_action_display(string state) =>
    switch state
        "ACTIVE" => "TRACK EARLY R"
        "BUILDING" => "WATCH 1R QUALITY"
        "PROGRESSING" => "REVIEW PULLBACK"
        "EXTENDED" => "REVIEW NEXT R"
        "PULLBACK RISK" => "REVIEW PROTECTION"
        "STALLED" => "REVIEW STALL"
        "INVALIDATED" => "RESET MAP"
        "EXPIRED" => "WAIT NEW CYCLE"
        => "WAIT ACTIVATION"

f_next_zone_text(float rValue) =>
    na(rValue) ? "ACTIVATION" : rValue < 0.50 ? "0.5R REVIEW" : rValue < 1.00 ? "1R REVIEW" : rValue < 1.50 ? "1.5R PULLBACK" : rValue < 2.00 ? "2R REVIEW" : rValue < 3.00 ? "3R EXTENSION" : "LATE PROGRESS"

f_pullback_text(bool isActive, float ddR, float riskR) =>
    not isActive ? "NONE" : ddR >= riskR ? "HIGH " + f_r_text(ddR) : ddR >= riskR * 0.55 ? "MODERATE " + f_r_text(ddR) : "LOW " + f_r_text(ddR)

f_panel_bg(bool isLight, bool alt) =>
    isLight ? (alt ? color.rgb(241, 245, 249) : color.rgb(248, 250, 252)) : (alt ? color.rgb(19, 29, 48) : panelBg)

f_panel_border(bool isLight) =>
    isLight ? color.rgb(203, 213, 225) : panelBorder

f_panel_label(bool isLight) =>
    isLight ? color.rgb(71, 85, 105) : panelLabelCol

f_panel_value(bool isLight) =>
    isLight ? color.rgb(15, 23, 42) : panelValueCol

f_best_view_text() =>
    timeframe.isintraday ? "15m / 1H / 4H" : "4H / 1D / 1W"

f_set_row(table target, int row, string leftText, string rightText, color rightColor, bool isLight, bool altRow, string fontSize) =>
    rowBg = f_panel_bg(isLight, altRow)
    table.cell(target, 0, row, leftText, text_color = f_panel_label(isLight), bgcolor = rowBg, text_size = f_size(fontSize))
    table.cell(target, 1, row, rightText, text_color = rightColor, bgcolor = rowBg, text_size = f_size(fontSize), text_halign = text.align_right)

f_trim_labels(array<label> labels, int maxCount) =>
    while array.size(labels) > maxCount
        oldLabel = array.shift(labels)
        label.delete(oldLabel)

f_line_style(string value) =>
    switch value
        "Dashed" => line.style_dashed
        "Dotted" => line.style_dotted
        => line.style_solid

f_sync_line(line id, bool show, int left, float level, int right, color lineColor, string styleText, int lineWidth) =>
    result = id
    if show and not na(level)
        if na(result)
            result := line.new(left, level, right, level, xloc = xloc.bar_index, extend = extend.none, color = lineColor, style = f_line_style(styleText), width = lineWidth)
        else
            line.set_xy1(result, left, level)
            line.set_xy2(result, right, level)
            line.set_color(result, lineColor)
            line.set_style(result, f_line_style(styleText))
            line.set_width(result, lineWidth)
    else
        if not na(result)
            line.delete(result)
        result := na
    result

f_sync_box(box id, bool show, int left, float topValue, int right, float bottomValue, color borderColor, color bgColor, color textColor, string boxText, string fontSize) =>
    result = id
    topFixed = math.max(topValue, bottomValue)
    bottomFixed = math.min(topValue, bottomValue)
    if show and not na(topValue) and not na(bottomValue) and topFixed > bottomFixed
        if na(result)
            result := box.new(left = left, top = topFixed, right = right, bottom = bottomFixed, xloc = xloc.bar_index, border_color = borderColor, bgcolor = bgColor)
        else
            box.set_left(result, left)
            box.set_right(result, right)
            box.set_top(result, topFixed)
            box.set_bottom(result, bottomFixed)
            box.set_border_color(result, borderColor)
            box.set_bgcolor(result, bgColor)
    else
        if not na(result)
            box.delete(result)
        result := na
    result

f_add_label(array<label> labels, bool show, string textValue, float labelY, int dirValue, color labelColor, color textColor, string tipText, int limit) =>
    if show and dirValue != 0 and not na(labelY)
        newLabel = label.new(bar_index, labelY, textValue, xloc = xloc.bar_index, yloc = yloc.price, style = f_label_style(dirValue), color = color.new(labelColor, 4), textcolor = textColor, size = f_size(labelSizeInput), tooltip = tipText)
        array.push(labels, newLabel)
        f_trim_labels(labels, limit)

// -------------------------------------------------
// Core measurements
// -------------------------------------------------
cleanerPreset = enginePreset == "Cleaner Swing"
activePreset = enginePreset == "Active Intraday"
customPreset = enginePreset == "Custom"

usedActivationScore = customPreset ? minActivationScore : cleanerPreset ? math.max(minActivationScore, 64.0) : activePreset ? math.max(minActivationScore - 6.0, 45.0) : minActivationScore
usedProgressScore = customPreset ? minProgressScore : cleanerPreset ? math.max(minProgressScore, 68.0) : activePreset ? math.max(minProgressScore - 5.0, 45.0) : minProgressScore

usedMaxTrackingBarsRaw = customPreset ? maxTrackingBars : cleanerPreset ? math.max(maxTrackingBars, 140) : activePreset ? math.min(maxTrackingBars, 60) : maxTrackingBars
usedStallBarsRaw = customPreset ? stallBars : cleanerPreset ? math.max(stallBars, 34) : activePreset ? math.min(stallBars, 12) : stallBars
usedMaxTrackingBars = math.max(usedMaxTrackingBarsRaw, 2)
usedStallBars = math.min(usedStallBarsRaw, usedMaxTrackingBars - 1)

usedMaxLabels = customPreset ? maxVisibleLabels : cleanerPreset ? math.min(maxVisibleLabels, 5) : activePreset ? math.min(maxVisibleLabels, 8) : math.min(maxVisibleLabels, 6)
usedLabelCooldown = customPreset ? labelCooldownBars : cleanerPreset ? math.max(labelCooldownBars, 34) : activePreset ? math.min(labelCooldownBars, 16) : labelCooldownBars
usedContextSpacing = customPreset ? contextSpacingBars : cleanerPreset ? math.max(contextSpacingBars, 96) : activePreset ? math.min(contextSpacingBars, 48) : contextSpacingBars

effectiveMinRiskAtr = math.min(minRiskAtr, maxRiskAtr)
effectiveMaxRiskAtr = math.max(minRiskAtr, maxRiskAtr)
effectiveReactBars = math.min(reactBars, math.max(proofHorizonBars - 1, 1))

atr = ta.atr(atrLen)
safeAtr = math.max(nz(atr, ta.tr(true)), syminfo.mintick)
atrBase = ta.sma(atr, lookback)
atrRatio = not na(atrBase) and atrBase > 0.0 ? safeAtr / atrBase : 1.0

emaFast = ta.ema(close, 21)
emaSlow = ta.ema(close, 55)
emaSlope = emaSlow - nz(emaSlow[5], emaSlow)

priorHigh = nz(ta.highest(high[1], lookback), high)
priorLow = nz(ta.lowest(low[1], lookback), low)
recentSwingLow = nz(ta.lowest(low[1], stopLookback), low)
recentSwingHigh = nz(ta.highest(high[1], stopLookback), high)

barRange = math.max(high - low, syminfo.mintick)
bodyEfficiency = math.abs(close - open) / barRange
closeLocation = f_clamp((close - low) / barRange, 0.0, 1.0)
directionalCloseLong = closeLocation
directionalCloseShort = 1.0 - closeLocation

volBase = ta.sma(nz(volume, 0.0), 20)
hasVolume = not na(volume) and volume > 0.0 and not na(volBase) and volBase > 0.0
volumeRatio = hasVolume ? volume / volBase : 1.0

trendLong = emaFast > emaSlow and emaSlope >= 0.0 and close >= emaFast
trendShort = emaFast < emaSlow and emaSlope <= 0.0 and close <= emaFast
rangeBreakLong = close > priorHigh and close > open
rangeBreakShort = close < priorLow and close < open
pulseLong = trendLong and close > emaFast and low <= emaFast and directionalCloseLong >= 0.58
pulseShort = trendShort and close < emaFast and high >= emaFast and directionalCloseShort >= 0.58

allowLong = directionMode == "Auto" or directionMode == "Long Progress"
allowShort = directionMode == "Auto" or directionMode == "Short Progress"
modeRange = activationMode == "Range Break"
modePulse = activationMode == "Trend Pulse"
longActivationRaw = allowLong and (modeRange ? rangeBreakLong : modePulse ? pulseLong : rangeBreakLong or pulseLong)
shortActivationRaw = allowShort and (modeRange ? rangeBreakShort : modePulse ? pulseShort : rangeBreakShort or pulseShort)

longStopCandidate = recentSwingLow - safeAtr * stopBufferAtr
shortStopCandidate = recentSwingHigh + safeAtr * stopBufferAtr
longRiskCandidate = math.abs(close - longStopCandidate)
shortRiskCandidate = math.abs(close - shortStopCandidate)
longRiskAtr = longRiskCandidate / safeAtr
shortRiskAtr = shortRiskCandidate / safeAtr

trendActivationLong = trendLong ? 100.0 : close > emaSlow ? 62.0 : 25.0
trendActivationShort = trendShort ? 100.0 : close < emaSlow ? 62.0 : 25.0
candleActivationLong = bodyEfficiency * 45.0 + directionalCloseLong * 55.0
candleActivationShort = bodyEfficiency * 45.0 + directionalCloseShort * 55.0
riskActivationLong = f_risk_fit(longRiskAtr, effectiveMinRiskAtr, effectiveMaxRiskAtr)
riskActivationShort = f_risk_fit(shortRiskAtr, effectiveMinRiskAtr, effectiveMaxRiskAtr)
volumeActivation = hasVolume ? f_norm_high_good(volumeRatio, 0.75, 1.80) : 55.0
longActivationScore = trendActivationLong * 0.30 + candleActivationLong * 0.28 + riskActivationLong * 0.26 + volumeActivation * 0.16
shortActivationScore = trendActivationShort * 0.30 + candleActivationShort * 0.28 + riskActivationShort * 0.26 + volumeActivation * 0.16

// -------------------------------------------------
// Active progress state
// -------------------------------------------------
var bool active = false
var int activeDir = 0
var float activeEntry = na
var float activeStop = na
var float activeRisk = na
var int activeBar = na
var float activeMaxR = 0.0
var float activeWorstR = 0.0
var int lastPullbackLabelBar = na
var int lastContextLabelBar = na
var bool stalledLabelDone = false
var bool pullbackLabelDone = false

longCandidateValid = longActivationRaw and longStopCandidate < close and longActivationScore >= usedActivationScore and longRiskAtr >= effectiveMinRiskAtr and longRiskAtr <= effectiveMaxRiskAtr
shortCandidateValid = shortActivationRaw and shortStopCandidate > close and shortActivationScore >= usedActivationScore and shortRiskAtr >= effectiveMinRiskAtr and shortRiskAtr <= effectiveMaxRiskAtr
candidateDir = longCandidateValid and not shortCandidateValid ? 1 : shortCandidateValid and not longCandidateValid ? -1 : longCandidateValid and shortCandidateValid ? (longActivationScore >= shortActivationScore ? 1 : -1) : 0
candidateStop = candidateDir == 1 ? longStopCandidate : candidateDir == -1 ? shortStopCandidate : na
candidateRisk = candidateDir == 1 ? longRiskCandidate : candidateDir == -1 ? shortRiskCandidate : na
candidateScore = candidateDir == 1 ? longActivationScore : candidateDir == -1 ? shortActivationScore : na

activationEvent = false
if barstate.isconfirmed and not active and candidateDir != 0 and bar_index > lookback
    active := true
    activeDir := candidateDir
    activeEntry := close
    activeStop := candidateStop
    activeRisk := math.max(candidateRisk, syminfo.mintick)
    activeBar := bar_index
    activeMaxR := 0.0
    activeWorstR := 0.0
    lastPullbackLabelBar := na
    lastContextLabelBar := na
    stalledLabelDone := false
    pullbackLabelDone := false
    activationEvent := true

maxRBefore = activeMaxR
float currentR = na
float favorableR = na
float adverseR = na
int barsActive = na
float drawdownR = na

if active
    barsActive := bar_index - activeBar
    currentR := activeDir == 1 ? (close - activeEntry) / activeRisk : (activeEntry - close) / activeRisk
    favorableR := activeDir == 1 ? (high - activeEntry) / activeRisk : (activeEntry - low) / activeRisk
    adverseR := activeDir == 1 ? (activeEntry - low) / activeRisk : (high - activeEntry) / activeRisk
    activeMaxR := math.max(activeMaxR, favorableR)
    activeWorstR := math.max(activeWorstR, adverseR)
    drawdownR := math.max(activeMaxR - currentR, 0.0)

rExpansionScore = active ? f_norm_high_good(currentR, -0.35, 2.20) : 0.0
candleProgressScore = active ? (activeDir == 1 ? candleActivationLong : candleActivationShort) : 0.0
trendSupportScore = active ? (activeDir == 1 ? trendActivationLong : trendActivationShort) : 0.0
drawdownScore = active ? f_norm_low_good(drawdownR, 0.18, math.max(pullbackRiskR * 1.65, 0.40)) : 0.0
timeTargetR = active ? barsActive <= 8 ? 0.25 : barsActive <= usedStallBars ? 0.75 : 1.10 : 0.0
timeScore = active ? f_norm_high_good(activeMaxR, timeTargetR * 0.45, timeTargetR) : 0.0
volatilityScore = active ? f_norm_low_good(math.abs(atrRatio - 1.0), 0.10, 0.85) : 0.0
progressScore = f_clamp(rExpansionScore * 0.28 + candleProgressScore * 0.16 + trendSupportScore * 0.18 + drawdownScore * 0.22 + timeScore * 0.10 + volatilityScore * 0.06, 0.0, 100.0)

invalidationEvent = active and barstate.isconfirmed and barsActive > 0 and (activeDir == 1 ? low <= activeStop : high >= activeStop)
expiredEvent = active and barstate.isconfirmed and barsActive >= usedMaxTrackingBars and not invalidationEvent

halfREvent = active and barstate.isconfirmed and not invalidationEvent and not expiredEvent and activeMaxR >= 0.50 and maxRBefore < 0.50 and barsActive > 0
oneREvent = active and barstate.isconfirmed and not invalidationEvent and not expiredEvent and activeMaxR >= 1.00 and maxRBefore < 1.00 and barsActive > 0
twoREvent = active and barstate.isconfirmed and not invalidationEvent and not expiredEvent and activeMaxR >= 2.00 and maxRBefore < 2.00 and barsActive > 0

pullbackRiskActive = active and activeMaxR >= 0.85 and drawdownR >= pullbackRiskR and not invalidationEvent and not expiredEvent
pullbackEvent = pullbackRiskActive and barstate.isconfirmed and not pullbackLabelDone and (na(lastPullbackLabelBar) or bar_index - lastPullbackLabelBar >= usedLabelCooldown)
stalledActive = active and barsActive >= usedStallBars and activeMaxR < 0.65 and not invalidationEvent and not expiredEvent
stalledEvent = stalledActive and barstate.isconfirmed and not stalledLabelDone

if pullbackEvent
    lastPullbackLabelBar := bar_index
    pullbackLabelDone := true
if stalledEvent
    stalledLabelDone := true

progressState = "WAIT"
if active
    if invalidationEvent
        progressState := "INVALIDATED"
    else if expiredEvent
        progressState := "EXPIRED"
    else if pullbackRiskActive
        progressState := "PULLBACK RISK"
    else if stalledActive
        progressState := "STALLED"
    else if currentR >= 2.0 and progressScore >= usedProgressScore
        progressState := "EXTENDED"
    else if currentR >= 1.0 and progressScore >= usedProgressScore
        progressState := "PROGRESSING"
    else if currentR >= 0.35
        progressState := "BUILDING"
    else
        progressState := "ACTIVE"

nextRZone = f_next_zone_text(active ? currentR : na)

pullbackRiskText = f_pullback_text(active, drawdownR, pullbackRiskR)
actionText = f_action_display(progressState)

stateColor = f_state_color(progressState)
sideText = activeDir == 1 ? "LONG" : activeDir == -1 ? "SHORT" : "NONE"
gradeText = active ? f_grade(progressScore) + " / " + f_score_text(progressScore) : "WAIT"

// -------------------------------------------------
// Confirmation-anchored proof (activated R-cycles, Follow = reached 1R before stop)
// -------------------------------------------------
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
var float pEvalRisk = na
var bool pReacted = false
var bool pFollowed = false

if barstate.isconfirmed
    if pEvalActive
        int heldBars = bar_index - pEvalStart
        float favorableExcursion = pEvalDir == 1 ? high - pEvalEntry : pEvalEntry - low
        float favorableR = favorableExcursion / math.max(pEvalRisk, syminfo.mintick)
        bool targetTouched = heldBars >= 1 and favorableR >= 1.0
        bool stopTouched = pEvalDir == 1 ? low <= pEvalStop : high >= pEvalStop
        bool ambiguousNow = targetTouched and stopTouched

        if heldBars >= 1 and heldBars <= effectiveReactBars and favorableR >= reactProgressPct / 100.0
            pReacted := true
        if targetTouched and not stopTouched
            pFollowed := true

        bool horizonDone = heldBars >= proofHorizonBars
        bool cycleExpired = expiredEvent
        bool resolveNow = ambiguousNow or targetTouched or stopTouched or horizonDone or cycleExpired

        if resolveNow
            if ambiguousNow
                proofAmbiguous := proofAmbiguous + 1
            else
                proofTotal := proofTotal + 1
                if pFollowed
                    proofFollow := proofFollow + 1
                if not stopTouched
                    proofHold := proofHold + 1
                if pReacted
                    proofReact := proofReact + 1
                if stopTouched
                    proofFlip := proofFlip + 1

            pEvalActive := false

    // Each qualified activation opens exactly one proof evaluation.
    if activationEvent and not pEvalActive
        pEvalActive := true
        pEvalDir := activeDir
        pEvalEntry := activeEntry
        pEvalStop := activeStop
        pEvalRisk := math.max(activeRisk, syminfo.mintick)
        pEvalStart := bar_index
        pReacted := false
        pFollowed := false

float followRate = proofTotal > 0 ? proofFollow * 100.0 / proofTotal : 0.0
float holdRate = proofTotal > 0 ? proofHold * 100.0 / proofTotal : 0.0
float reactRate = proofTotal > 0 ? proofReact * 100.0 / proofTotal : 0.0
float flipRate = proofTotal > 0 ? proofFlip * 100.0 / proofTotal : 0.0

// -------------------------------------------------
// Event labels
// -------------------------------------------------
var array<label> eventLabels = array.new<label>()
eventDir = activeDir != 0 ? activeDir : candidateDir
eventY = f_label_y(eventDir, high, low, safeAtr, labelOffsetAtr, labelLaneSpreadAtr, 0.0)
milestoneY = f_label_y(eventDir, high, low, safeAtr, labelOffsetAtr, labelLaneSpreadAtr, 0.85)
pullbackY = f_label_y(eventDir, high, low, safeAtr, labelOffsetAtr, labelLaneSpreadAtr, 0.35)
terminalY = f_label_y(eventDir, high, low, safeAtr, labelOffsetAtr, labelLaneSpreadAtr, 1.35)
scoreSuffix = showLabelScore and active ? "\n" + f_grade(progressScore) + " " + f_score_text(progressScore) : ""
darkText = color.rgb(15, 23, 42)

if showEventLabels and activationEvent
    activationText = "ACT " + (activeDir == 1 ? "L" : "S") + (showLabelScore ? "\n" + f_score_text(candidateScore) : "")
    f_add_label(eventLabels, true, activationText, eventY, activeDir, accentColor, headerText, "A new R-multiple progress cycle activated. This is an attention marker, not a trade instruction.", usedMaxLabels)

if showEventLabels and halfREvent
    f_add_label(eventLabels, true, "+0.5R" + scoreSuffix, milestoneY, activeDir, accentColor, headerText, "The active progress cycle reached the 0.5R reference.", usedMaxLabels)

if showEventLabels and oneREvent
    f_add_label(eventLabels, true, "+1R" + scoreSuffix, milestoneY, activeDir, bullColor, headerText, "The active progress cycle reached the 1R reference.", usedMaxLabels)

if showEventLabels and twoREvent
    f_add_label(eventLabels, true, "+2R" + scoreSuffix, milestoneY, activeDir, bullColor, headerText, "The active progress cycle reached the 2R reference.", usedMaxLabels)

if showEventLabels and showPullbackLabels and pullbackEvent
    f_add_label(eventLabels, true, "PB RISK\n" + f_r_text(drawdownR), pullbackY, activeDir, neutralColor, darkText, "Pullback risk increased after favorable R progress.", usedMaxLabels)

if showEventLabels and stalledEvent
    f_add_label(eventLabels, true, "STALLED\n" + f_r_text(currentR), terminalY, activeDir, neutralColor, darkText, "The active cycle is spending time without enough R progress.", usedMaxLabels)

if showEventLabels and invalidationEvent
    f_add_label(eventLabels, true, "INVALID\n" + f_r_text(currentR), terminalY, activeDir, dangerColor, headerText, "The active cycle touched the invalidation proxy.", usedMaxLabels)

if showEventLabels and showExpiredLabels and expiredEvent
    f_add_label(eventLabels, true, "EXPIRED\n" + f_r_text(currentR), terminalY, activeDir, neutralColor, darkText, "The active progress cycle reached the maximum tracking window.", usedMaxLabels)

contextDue = showContextLabels and active and barstate.isconfirmed and barsActive > 0 and not invalidationEvent and not expiredEvent and (na(lastContextLabelBar) or bar_index - lastContextLabelBar >= usedContextSpacing)
if contextDue
    contextText = f_state_short(progressState) + "\n" + f_r_text(currentR)
    f_add_label(eventLabels, true, contextText, eventY, activeDir, stateColor, progressState == "PULLBACK RISK" or progressState == "STALLED" ? darkText : headerText, "Sparse active-cycle context label. It summarizes R progress without issuing a trade instruction.", usedMaxLabels)
    lastContextLabelBar := bar_index

// -------------------------------------------------
// R ladder and progress visuals
// -------------------------------------------------
var line entryLine = na
var line stopLine = na
var line halfRLine = na
var line oneRLine = na
var line twoRLine = na
var line threeRLine = na
var box progressFillBox = na
var box bandOneBox = na
var box bandTwoBox = na
var box bandThreeBox = na
var label progressFillBadge = na
var label bandOneBadge = na
var label bandTwoBadge = na
var label bandThreeBadge = na
var label currentRTag = na
var label stateTag = na
var label scoreTag = na
var label pullbackTag = na
var label invalidTag = na
var line liveConnector = na

displayActive = active and not invalidationEvent and not expiredEvent
ladderLeft = displayActive ? activeBar : bar_index
ladderRight = displayActive ? bar_index + projectionBars : bar_index
ladderTagRight = displayActive and showLiveReviewTags ? ladderRight + liveTagOffsetBars + 3 : ladderRight
levelHalf = displayActive ? activeEntry + activeDir * activeRisk * 0.50 : na
levelOne = displayActive ? activeEntry + activeDir * activeRisk * 1.00 : na
levelTwo = displayActive ? activeEntry + activeDir * activeRisk * 2.00 : na
levelThree = displayActive ? activeEntry + activeDir * activeRisk * 3.00 : na

entryLine := f_sync_line(entryLine, displayActive and showRLadder, ladderLeft, activeEntry, ladderTagRight, color.new(accentColor, 0), "Solid", 2)
stopLine := f_sync_line(stopLine, displayActive and showRLadder, ladderLeft, activeStop, ladderTagRight, color.new(dangerColor, 0), "Dashed", 2)
halfRLine := f_sync_line(halfRLine, displayActive and showRLadder, ladderLeft, levelHalf, ladderRight, color.new(neutralColor, 12), "Dotted", 1)
oneRLine := f_sync_line(oneRLine, displayActive and showRLadder, ladderLeft, levelOne, ladderRight, color.new(bullColor, 0), "Dashed", 1)
twoRLine := f_sync_line(twoRLine, displayActive and showRLadder, ladderLeft, levelTwo, ladderRight, color.new(bullColor, 0), "Dashed", 1)
threeRLine := f_sync_line(threeRLine, displayActive and showRLadder, ladderLeft, levelThree, ladderRight, color.new(accentColor, 0), "Dotted", 1)

fillEnd = displayActive ? activeEntry + activeDir * activeRisk * f_clamp(currentR, -1.0, 3.0) : na
showFillBox = displayActive and showProgressFill and not na(fillEnd) and not na(activeEntry) and math.abs(fillEnd - activeEntry) > syminfo.mintick
zoneTextColor = panelThemeInput == "Light" ? color.rgb(15, 23, 42) : headerText
progressFillBox := f_sync_box(progressFillBox, showFillBox, activeBar, fillEnd, bar_index, activeEntry, color.new(stateColor, 54), color.new(stateColor, 86), zoneTextColor, "RPM " + f_r_text(currentR), labelSizeInput)
bandOneBox := f_sync_box(bandOneBox, displayActive and showPartialBands, ladderLeft, levelHalf, ladderRight, levelOne, color.new(neutralColor, 68), color.new(neutralColor, 91), zoneTextColor, "0.5R-1R\nREVIEW", labelSizeInput)
bandTwoBox := f_sync_box(bandTwoBox, displayActive and showPartialBands, ladderLeft, levelOne, ladderRight, levelTwo, color.new(bullColor, 70), color.new(bullColor, 92), zoneTextColor, "1R-2R\nMANAGE", labelSizeInput)
bandThreeBox := f_sync_box(bandThreeBox, displayActive and showPartialBands, ladderLeft, levelTwo, ladderRight, levelThree, color.new(accentColor, 70), color.new(accentColor, 93), zoneTextColor, "2R-3R\nEXTENSION", labelSizeInput)

if displayActive and showFillBox
    fillBadgeX = int(math.round((activeBar + bar_index) * 0.5))
    fillBadgeY = (fillEnd + activeEntry) * 0.5
    if na(progressFillBadge)
        progressFillBadge := label.new(fillBadgeX, fillBadgeY, "RPM\n" + f_r_text(currentR), xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_center, color = color.new(stateColor, 0), textcolor = progressState == "PULLBACK RISK" or progressState == "STALLED" ? darkText : headerText, size = f_size(labelSizeInput), textalign = text.align_center)
    else
        label.set_xy(progressFillBadge, fillBadgeX, fillBadgeY)
        label.set_text(progressFillBadge, "RPM\n" + f_r_text(currentR))
        label.set_style(progressFillBadge, label.style_label_center)
        label.set_color(progressFillBadge, color.new(stateColor, 0))
        label.set_textcolor(progressFillBadge, progressState == "PULLBACK RISK" or progressState == "STALLED" ? darkText : headerText)
        label.set_size(progressFillBadge, f_size(labelSizeInput))
        label.set_textalign(progressFillBadge, text.align_center)
else if not na(progressFillBadge)
    label.delete(progressFillBadge)
    progressFillBadge := na

bandBadgeX = displayActive ? int(math.round((ladderLeft + ladderRight) * 0.5)) : bar_index
if displayActive and showPartialBands
    if na(bandOneBadge)
        bandOneBadge := label.new(bandBadgeX, (levelHalf + levelOne) * 0.5, "0.5R-1R\nREVIEW", xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_center, color = color.new(neutralColor, 0), textcolor = darkText, size = f_size(labelSizeInput), textalign = text.align_center)
    else
        label.set_xy(bandOneBadge, bandBadgeX, (levelHalf + levelOne) * 0.5)
        label.set_text(bandOneBadge, "0.5R-1R\nREVIEW")
        label.set_style(bandOneBadge, label.style_label_center)
        label.set_color(bandOneBadge, color.new(neutralColor, 0))
        label.set_textcolor(bandOneBadge, darkText)
        label.set_size(bandOneBadge, f_size(labelSizeInput))
    if na(bandTwoBadge)
        bandTwoBadge := label.new(bandBadgeX, (levelOne + levelTwo) * 0.5, "1R-2R\nMANAGE", xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_center, color = color.new(bullColor, 0), textcolor = headerText, size = f_size(labelSizeInput), textalign = text.align_center)
    else
        label.set_xy(bandTwoBadge, bandBadgeX, (levelOne + levelTwo) * 0.5)
        label.set_text(bandTwoBadge, "1R-2R\nMANAGE")
        label.set_style(bandTwoBadge, label.style_label_center)
        label.set_color(bandTwoBadge, color.new(bullColor, 0))
        label.set_textcolor(bandTwoBadge, headerText)
        label.set_size(bandTwoBadge, f_size(labelSizeInput))
    if na(bandThreeBadge)
        bandThreeBadge := label.new(bandBadgeX, (levelTwo + levelThree) * 0.5, "2R-3R\nEXTENSION", xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_center, color = color.new(accentColor, 0), textcolor = headerText, size = f_size(labelSizeInput), textalign = text.align_center)
    else
        label.set_xy(bandThreeBadge, bandBadgeX, (levelTwo + levelThree) * 0.5)
        label.set_text(bandThreeBadge, "2R-3R\nEXTENSION")
        label.set_style(bandThreeBadge, label.style_label_center)
        label.set_color(bandThreeBadge, color.new(accentColor, 0))
        label.set_textcolor(bandThreeBadge, headerText)
        label.set_size(bandThreeBadge, f_size(labelSizeInput))
else
    if not na(bandOneBadge)
        label.delete(bandOneBadge)
        bandOneBadge := na
    if not na(bandTwoBadge)
        label.delete(bandTwoBadge)
        bandTwoBadge := na
    if not na(bandThreeBadge)
        label.delete(bandThreeBadge)
        bandThreeBadge := na

if barstate.islast
    if not na(currentRTag)
        label.delete(currentRTag)
        currentRTag := na
    if not na(stateTag)
        label.delete(stateTag)
        stateTag := na
    if not na(scoreTag)
        label.delete(scoreTag)
        scoreTag := na
    if not na(pullbackTag)
        label.delete(pullbackTag)
        pullbackTag := na
    if not na(invalidTag)
        label.delete(invalidTag)
        invalidTag := na
    if not na(liveConnector)
        line.delete(liveConnector)
        liveConnector := na

    if displayActive and showLiveReviewTags
        markerRight = ladderRight + liveTagOffsetBars
        invalidTagX = markerRight + 3
        tagGap = math.max(safeAtr * liveTagSpacingAtr, close * 0.012)
        stackCenterY = close
        stackTopY = stackCenterY + tagGap * 1.50
        stackCurrentY = stackCenterY + tagGap * 0.50
        stackScoreY = stackCenterY - tagGap * 0.50
        stackPullbackY = stackCenterY - tagGap * 1.50
        tagTextColor = progressState == "PULLBACK RISK" or progressState == "STALLED" ? darkText : headerText
        stateTag := label.new(markerRight, stackTopY, "WORKFLOW\n" + actionText + " | " + sideText, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_center, color = color.new(stateColor, 0), textcolor = tagTextColor, size = f_size(labelSizeInput), textalign = text.align_center)
        currentRTag := label.new(markerRight, stackCurrentY, "CURRENT\n" + f_r_text(currentR) + " | MAX " + f_r_text(activeMaxR), xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_center, color = color.new(accentColor, 4), textcolor = headerText, size = f_size(labelSizeInput), textalign = text.align_center)
        scoreTag := label.new(markerRight, stackScoreY, "SCORE\n" + f_score_text(progressScore) + "/100", xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_center, color = color.new(f_score_color(progressScore, usedProgressScore), 4), textcolor = headerText, size = f_size(labelSizeInput), textalign = text.align_center)
        pullbackTag := label.new(markerRight, stackPullbackY, "PULLBACK\n" + f_r_text(drawdownR), xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_center, color = color.new(pullbackRiskActive ? neutralColor : bullColor, 4), textcolor = pullbackRiskActive ? darkText : headerText, size = f_size(labelSizeInput), textalign = text.align_center)
        invalidTag := label.new(invalidTagX, activeStop, "INVALID\n" + f_price(activeStop), xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = color.new(dangerColor, 6), textcolor = headerText, size = f_size(labelSizeInput), textalign = text.align_center)
        liveConnector := line.new(ladderRight, close, markerRight, stackTopY, xloc = xloc.bar_index, color = color.new(stateColor, 42), width = 1, style = line.style_dotted)

// -------------------------------------------------
// Panel
// -------------------------------------------------
panelIsLight = panelThemeInput == "Light"
panelFrame = f_panel_border(panelIsLight)
panelSize = panelFontSizeInput
currentRRead = active ? f_r_text(currentR) + " / MAX " + f_r_text(activeMaxR) : "NO ACTIVE MAP"
gradeRead = active ? gradeText + " | " + sideText : "WAIT"
nextRead = active ? nextRZone : "ACTIVATION"
riskUnitRead = active ? str.tostring(activeRisk / safeAtr, "#.00") + " ATR" : "N/A"
invalidRead = active ? f_price(activeStop) : "N/A"
actionRead = active ? actionText + " | " + sideText : "WAIT ACTIVATION"
bestViewText = f_best_view_text()

proofSampleText = proofTotal > 0 ? "n = " + str.tostring(proofTotal) + (proofAmbiguous > 0 ? " | x = " + str.tostring(proofAmbiguous) : "") : proofAmbiguous > 0 ? "x = " + str.tostring(proofAmbiguous) : "building"
followText = proofTotal > 0 ? f_pct(followRate) : "-"
holdText = proofTotal > 0 ? f_pct(holdRate) : "-"
reactText = proofTotal > 0 ? f_pct(reactRate) : "-"
flipText = proofTotal > 0 ? f_pct(flipRate) : "-"
followCol = proofTotal > 0 ? f_rate_color(followRate) : f_panel_value(panelIsLight)
holdCol = proofTotal > 0 ? f_rate_color(holdRate) : f_panel_value(panelIsLight)
reactCol = proofTotal > 0 ? f_rate_color(reactRate) : f_panel_value(panelIsLight)
flipCol = proofTotal > 0 ? f_flip_color(flipRate) : f_panel_value(panelIsLight)

int panelRowCount = showProof ? 13 : 8

var table panel = na
var string lastPanelLocation = ""
var string lastPanelTheme = ""
var string lastPanelSize = ""
var bool lastProofMode = false

panelNeedsReset = showPanel and (na(panel) or panelLocationInput != lastPanelLocation or panelThemeInput != lastPanelTheme or panelFontSizeInput != lastPanelSize or showProof != lastProofMode)
if panelNeedsReset
    if not na(panel)
        table.delete(panel)
    panel := table.new(f_position(panelLocationInput), 2, panelRowCount, bgcolor = f_panel_bg(panelIsLight, false), frame_color = panelFrame, frame_width = 1, border_color = panelFrame, border_width = 1)
    table.cell(panel, 0, 0, "AG Pro R-Multiple Progress Map", text_color = headerText, bgcolor = headerBg, text_size = f_size(panelSize), text_halign = text.align_center)
    table.cell(panel, 1, 0, "", text_color = headerText, bgcolor = headerBg, text_size = f_size(panelSize))
    table.merge_cells(panel, 0, 0, 1, 0)
    lastPanelLocation := panelLocationInput
    lastPanelTheme := panelThemeInput
    lastPanelSize := panelFontSizeInput
    lastProofMode := showProof

if not showPanel and not na(panel)
    table.delete(panel)
    panel := na

if showPanel and not na(panel) and barstate.islast
    table.set_position(panel, f_position(panelLocationInput))
    table.set_frame_color(panel, panelFrame)
    table.set_border_color(panel, panelFrame)
    table.clear(panel, 0, 1, 1, panelRowCount - 1)
    f_set_row(panel, 1, "Workflow", actionRead, active ? stateColor : f_panel_value(panelIsLight), panelIsLight, false, panelSize)
    f_set_row(panel, 2, "Current R", currentRRead, active ? stateColor : f_panel_value(panelIsLight), panelIsLight, true, panelSize)
    f_set_row(panel, 3, "Risk Unit", riskUnitRead, active ? accentColor : f_panel_value(panelIsLight), panelIsLight, false, panelSize)
    f_set_row(panel, 4, "Invalidation", invalidRead, active ? dangerColor : f_panel_value(panelIsLight), panelIsLight, true, panelSize)
    f_set_row(panel, 5, "Pullback", pullbackRiskText, pullbackRiskActive ? neutralColor : active ? bullColor : f_panel_value(panelIsLight), panelIsLight, false, panelSize)
    f_set_row(panel, 6, "Next R Zone", nextRead + " | " + gradeRead, active ? f_score_color(progressScore, usedProgressScore) : f_panel_value(panelIsLight), panelIsLight, true, panelSize)
    f_set_row(panel, 7, "Review View", bestViewText, accentColor, panelIsLight, false, panelSize)
    if showProof
        color proofHeadBg = f_panel_bg(panelIsLight, true)
        table.cell(panel, 0, 8, "Proof @ Confirm", text_color = accentColor, bgcolor = proofHeadBg, text_size = f_size(panelSize), text_halign = text.align_left)
        table.cell(panel, 1, 8, proofSampleText, text_color = f_panel_label(panelIsLight), bgcolor = proofHeadBg, text_size = f_size(panelSize), text_halign = text.align_right)
        f_set_row(panel, 9, "Follow Rate", followText, followCol, panelIsLight, false, panelSize)
        f_set_row(panel, 10, "Hold Rate", holdText, holdCol, panelIsLight, true, panelSize)
        f_set_row(panel, 11, "React Rate", reactText, reactCol, panelIsLight, false, panelSize)
        f_set_row(panel, 12, "Flip Rate", flipText, flipCol, panelIsLight, true, panelSize)

// -------------------------------------------------
// Alerts And Hidden Exports
// -------------------------------------------------
alertcondition(alertProgressStates and activationEvent, title = "R-Multiple Progress Activation", message = "R-Multiple Progress Map: a new progress cycle activated. This is an attention marker, not a trade instruction.")
alertcondition(alertProgressStates and halfREvent, title = "R-Multiple Progress 0.5R", message = "R-Multiple Progress Map: active cycle reached 0.5R progress.")
alertcondition(alertProgressStates and oneREvent, title = "R-Multiple Progress 1R", message = "R-Multiple Progress Map: active cycle reached 1R progress.")
alertcondition(alertProgressStates and twoREvent, title = "R-Multiple Progress 2R", message = "R-Multiple Progress Map: active cycle reached 2R progress.")
alertcondition(alertProgressStates and pullbackEvent, title = "R-Multiple Progress Pullback Risk", message = "R-Multiple Progress Map: pullback risk increased after favorable R progress.")
alertcondition(alertProgressStates and stalledEvent, title = "R-Multiple Progress Stalled", message = "R-Multiple Progress Map: active cycle is spending time without enough R progress.")
alertcondition(alertProgressStates and invalidationEvent, title = "R-Multiple Progress Invalidated", message = "R-Multiple Progress Map: active cycle touched the invalidation proxy.")
alertcondition(alertProgressStates and expiredEvent, title = "R-Multiple Progress Expired", message = "R-Multiple Progress Map: active cycle reached the maximum tracking window.")

plot(active ? currentR : na, title = "RPM Current R", display = display.none)
plot(active ? activeMaxR : na, title = "RPM Maximum R", display = display.none)
plot(active ? drawdownR : na, title = "RPM Pullback Drawdown R", display = display.none)
plot(active ? progressScore : na, title = "RPM Progress Score", display = display.none)
plot(active ? activeWorstR : na, title = "RPM Adverse R Pressure", display = display.none)
plot(followRate, title = "RPM Follow Rate", display = display.none)
plot(holdRate, title = "RPM Hold Rate", display = display.none)
plot(reactRate, title = "RPM React Rate", display = display.none)
plot(flipRate, title = "RPM Flip Rate", display = display.none)
plot(proofAmbiguous, title = "RPM Ambiguous Proof Count", display = display.none)
plot(active ? activeRisk / safeAtr : na, title = "RPM Risk Unit ATR", display = display.none)
plot(activeDir, title = "RPM Active Direction", display = display.none)
plot(active ? barsActive : na, title = "RPM Bars Active", display = display.none)

// -------------------------------------------------
// Reset completed cycles after outputs are drawn
// -------------------------------------------------
if invalidationEvent or expiredEvent
    active := false
    activeDir := 0
    activeEntry := na
    activeStop := na
    activeRisk := na
    activeBar := na
    activeMaxR := 0.0
    activeWorstR := 0.0
    pullbackLabelDone := false
````
