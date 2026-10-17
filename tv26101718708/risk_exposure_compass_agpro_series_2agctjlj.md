# Risk Exposure Compass [AGPro Series]

- url: https://www.tradingview.com/script/2aGcTJlj-Risk-Exposure-Compass-AGPro-Series/
- type: indicator
- pine_id: PUB;e70df309a2c844f9936904ef11e27dbf
- version: 6.0

## Description

Risk Exposure Compass [AGPro Series]

🧠 Core Idea

Is the current chart exposing the trader to balanced risk, or is price already stretched, blocked, or too early?


📌 Overview / What it does

Risk Exposure Compass [AGPro Series] is a chart-first risk planning tool designed to evaluate the current exposure quality of a setup before the trader treats it as actionable.

Instead of printing generic buy or sell signals, the script studies ATR stretch, range position, distance from the exposure mean, trend maturity, target-edge room, and invalidation distance. These components are converted into a 0-100 Risk Exposure Score and a clear next-action state.

The script produces a risk compass band, invalidation shelf, target-edge guide, exposure heat labels, alerts, and a clean AGPro planning panel. It does not predict price direction, automate execution, calculate position size, or guarantee that a setup will follow through.

[image]https://www.tradingview.com/x/6j3pBmUd/[/image]


🎯 Purpose & Design Philosophy

This script was built for traders who want to ask a practical pre-decision question: is the chart still offering clean exposure, or has the move become too stretched to evaluate cleanly?

The gap it fills is different from a manual risk/reward visualizer, position planner, or risk runway tool. Risk Exposure Compass focuses on the current chart location itself: how far price is from mean, how mature the move is, whether volatility load is normal, whether target room is open, and whether invalidation distance is controlled.

The design supports a disciplined review mindset. It helps users avoid treating every active move as equal by separating balanced exposure, watch context, stretched risk, blocked room, and reset conditions.


⚡ Why This Script Is Different

Most tools focus on entries, support/resistance zones, take-profit ladders, or manual risk/reward boxes.

This script does NOT build a full trade plan, does NOT calculate position size, does NOT create a TP ladder, and does NOT become a dashboard-only stress meter.

Instead, it draws a live risk compass directly on the chart and scores whether the current price location is balanced, extended, blocked by nearby target structure, or too early for clean planning.


⚙️ Methodology

1. Context Detection
The script reads automatic long-side or short-side exposure using mean and trend context, or lets the user force the exposure side manually.

2. Reference Mapping
It maps an exposure mean, active range, structural invalidation shelf, target-edge obstruction, and a projected compass band.

3. Reaction Evaluation
The model scores five core components: ATR stretch, range position, distance from mean, trend maturity, and target obstruction. Invalidation distance and volatility load refine the final state.

4. Visual Output
The output is shown through a centered compass band label, invalidation and target guide lines, compact exposure labels, deterministic alerts, and a premium AGPro panel.


🗺️ How to Read the Chart

Zones = the risk compass band where price is considered more balanced relative to the active exposure mean.

Labels = compact state markers showing BALANCED, WATCH, STRETCHED, BLOCKED, or RESET context.

Colors = teal marks cleaner exposure, pink marks blocked or failed context, amber marks stretched risk, and indigo marks watch or transition states.

Panel = the panel summarizes Exposure State, Risk Score, Volatility Load, Distance Risk, and Action.


🚦 Signals & States

• BALANCED → exposure is inside the compass band with a strong enough score.

• WATCH → exposure quality is developing but not yet clean enough for balanced status.

• STRETCHED → price is extended from mean, late in range position, volatility is overloaded, or invalidation distance is too wide.

• BLOCKED → nearby target-edge room is limited relative to current exposure.

• RESET → the chart is early, unclear, or below the minimum quality threshold.


🔔 Alerts Logic

Alerts trigger when exposure moves into BALANCED, WATCH, STRETCHED, BLOCKED, or RESET state.

These alerts are attention markers. They are not trade instructions, entry signals, exit signals, or automated strategy commands.


🧩 Confluence Logic

The strongest exposure context appears when ATR stretch is controlled, price is not at an extreme range edge, distance from mean is balanced, trend maturity is not too early or too late, and target room remains open.

When these conditions align, the Risk Exposure Score rises and the panel state becomes easier to interpret.


📊 When to Use

• Before evaluating a discretionary setup

• During pullbacks or pauses where risk location matters

• Around continuation attempts after a trend has already moved

• Before breakouts where price may already be extended

• When comparing whether one chart has cleaner exposure than another


⚠️ When NOT to Use

• Extremely low-liquidity symbols

• Very noisy micro-timeframes

• News-driven volatility spikes

• Non-standard chart types that distort candle range and ATR behavior

• Situations where the user expects a signal-only entry tool


🎛️ Key Inputs

• Exposure Side → controls Auto, Long Exposure, or Short Exposure evaluation.

• Range Lookback → defines the range used for price-location scoring.

• ATR Length → normalizes stretch, distance risk, target room, and label offsets.

• Exposure Mean EMA → defines the mean used for the compass band and distance scoring.

• Target Obstruction Lookback → controls how nearby target-edge room is estimated.

• Invalidation Shelf Lookback → controls the structural invalidation reference.

• Sensitivity → adjusts how strict the exposure model is.

• Visual settings → control compass band, guides, candle heat, labels, panel location, theme, and font sizes.


🖥️ Interface & Visual Design

The interface is built around one primary chart object: the risk compass band.

The panel follows the AGPro public-release standard with one merged blue header row containing only the script name. The rows are kept compact so the tool stays readable without becoming dashboard-heavy.

Labels are intentionally short, offset away from candles, and controlled with cooldown and maximum-visible settings.


🧪 Practical Usage Workflow

1. Read the panel Exposure State and Risk Score.

2. Check whether price is inside, below, or beyond the risk compass band.

3. Review Distance Risk to see whether invalidation is controlled, fragile, or too wide.

4. Check target-edge room before treating exposure as clean.

5. Use alerts as review prompts, not as automated trading instructions.


🔍 Interpretation Guidelines

A high score means the chart is closer to balanced exposure according to the script's rule-based model.

A low score means price may be too early, too stretched, blocked by nearby structure, or unclear relative to mean and range position.

The best interpretation comes from reading score, state, volatility load, distance risk, and target room together instead of relying on one label.


🚫 What This Script Is NOT

• Not a prediction engine

• Not financial advice

• Not auto trading

• Not guaranteed signals

• Not a position sizing calculator

• Not a manual risk/reward visualizer

• Not a take-profit ladder


⚠️ Limitations & Transparency

The model is rule-based and depends on recent structure, ATR, moving averages, candle range, and target-edge mapping.

Different timeframes can produce different exposure states because range, trend maturity, and invalidation shelves change with timeframe.

Fast volatility expansion can move the script quickly from balanced to stretched, while low-volatility environments can keep exposure in reset or watch state for longer.

No rule-based tool can know a user's actual execution plan, account risk, broker rules, or broader market thesis.


🧠 Market Context Notes

Risk exposure is not the same as direction.

A chart can be bullish but stretched, bearish but blocked, or directionally interesting while still offering poor exposure quality.

This script is designed to keep that distinction visible.


🧾 Use Case Examples

When price is above the exposure mean, inside the compass band, with controlled invalidation distance and enough target room, the panel can shift toward BALANCED.

When price accelerates far beyond the compass band with hot volatility and a late range position, the script can mark STRETCHED risk.

When price is close to a prior target edge and the room score is weak, the script can mark BLOCKED even if the broader trend still looks strong.


🧱 System Philosophy

The AGPro approach is to turn chart information into structured decision context.

Risk Exposure Compass follows that approach by converting price location into a cleaner review framework: mean, range, volatility, invalidation, target room, score, and next state.


🔐 Non-Promise Statement

This script does not provide certainty.

It does not guarantee that balanced exposure will lead to follow-through.

It only organizes current chart conditions so exposure quality is easier to review.


📉 Risk Disclosure

Trading involves risk.

Users are responsible for their own analysis, execution, risk management, and decisions.

This script is for educational and analytical purposes only and does not provide financial advice.


📚 Educational Note

Use the tool to study how price moves from reset to watch, from watch to balanced, and from balanced to stretched or blocked as market context changes.

## Source Code

````pine
// -------------------------------------------------
// Risk Exposure Compass [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 1.5
//
// Risk Exposure Compass is a chart-first risk planning dashboard that evaluates
// whether current price location is balanced, early, stretched, or blocked.
// It combines ATR stretch, range position, mean distance, trend maturity,
// target obstruction, invalidation distance, volatility load, risk pressure,
// exposure balance, and a clear next-action state, plus a confirmation-anchored
// proof layer (Follow, Hold, React, Flip rates) that shows how past constructive
// exposure calls followed through, without becoming a signal printer,
// prediction tool, or stop-loss optimizer.
// -------------------------------------------------

//@version=6
indicator("Risk Exposure Compass [AGPro Series]",
     shorttitle       = "AG Pro REC",
     overlay          = true,
     max_labels_count = 120,
     max_boxes_count  = 16,
     max_lines_count  = 36)

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
ttSide = "Selects the exposure side. Auto reads mean and trend context. Manual modes force long-side or short-side exposure review without creating entry signals."
ttConfirm = "When enabled, labels, alerts, and state transitions are confirmed only after the bar closes. This keeps public chart behavior stable."
ttRange = "Lookback used to map the active chart range. Range position is one part of the exposure score and helps detect whether price is centered or extended."
ttAtrLen = "ATR length used to normalize stretch, distance risk, target room, label offsets, and compass band size."
ttAtrBase = "Longer ATR baseline used to classify volatility load as low, normal, hot, or extreme."
ttMean = "EMA used as the exposure mean. Distance from this mean is a core part of the risk-exposure model."
ttFast = "Fast EMA used only to read automatic context. It does not create buy or sell signals."
ttTrend = "Trend EMA used to read directional support and trend maturity context."
ttMaturity = "Number of bars where trend exposure is considered mature. Very young or very late moves receive lower maturity quality."
ttTarget = "Lookback used to find the nearest target-edge obstruction. Limited room near the current edge reduces exposure quality."
ttInvalidation = "Lookback used to map the structural invalidation shelf. Distance from this shelf is shown as distance risk."
ttSensitivity = "Controls how strict the exposure model is. Conservative requires cleaner balance, while Aggressive accepts earlier exposure states."
ttMinScore = "Minimum 0-100 score required for BALANCED state. Scores below this level can still produce WATCH or RESET states."
ttWatchScore = "Minimum 0-100 score required for WATCH state. Below this level, exposure is treated as early, weak, or unclear."
ttBalanceMin = "Minimum directional ATR distance from the exposure mean for the balanced compass band."
ttBalanceIdeal = "Preferred directional ATR distance from the exposure mean. Score is strongest near this area when other components align."
ttBalanceMax = "Maximum directional ATR distance from the exposure mean for the balanced compass band. Beyond this area, chase risk starts rising."
ttStretch = "Directional ATR distance from the exposure mean where the script marks stretched-risk context."
ttTargetRoom = "Minimum ATR-normalized room required before the nearest target edge is considered clear enough for balanced exposure."
ttRiskMin = "Minimum acceptable distance from invalidation in ATR. Too little room can make exposure fragile."
ttRiskMax = "Maximum acceptable distance from invalidation in ATR. Too much room can make exposure too wide for clean planning."
ttShowBand = "Shows the active risk compass band. The centered badge describes exposure balance, risk pressure, and current state."
ttShowGuides = "Shows the active exposure mean, invalidation shelf, and target-edge guide."
ttShowHeat = "Applies subtle candle tint based on the exposure state. It is visual context only."
ttProjection = "Number of bars projected to the right for the compass band and guide lines."
ttGuideTags = "Shows right-edge guide tags for invalidation distance and target room. Tags use solid labels for readability."
ttLabels = "Shows compact BALANCED, WATCH, STRETCHED, and BLOCKED labels. Labels are offset away from candles and capped for a cleaner public chart."
ttContext = "Adds sparse context labels during meaningful ongoing exposure states. Disabled by default for a cleaner public-release chart."
ttResetLabels = "Shows RESET labels when exposure returns to early or unclear context. Disabled by default to keep the chart clean."
ttMarkers = "Shows tiny diamond markers for state transitions. Disabled by default because labels and the compass band already carry the visual story."
ttCooldown = "Minimum bars between chart labels. Higher values reduce label density."
ttContextSpacing = "Minimum bars between sparse context labels during ongoing exposure review."
ttMaxLabels = "Maximum number of chart labels retained. Older labels are removed first to preserve performance."
ttLabelOffset = "ATR-based vertical offset that keeps labels above or below candles."
ttLabelScore = "Adds the 0-100 exposure score to chart labels."
ttLabelMetrics = "Adds risk-distance and target-room ATR metrics to chart labels. Disabled by default for a cleaner first-glance view."
ttLabelSize = "Font size for all chart labels and compass-band badges. Normal is the recommended publication default."
ttSolidBand = "Uses a separate centered label badge for compass text. Solid mode gives maximum contrast; transparent mode keeps the same centered text with a lighter footprint."
ttShowPanel = "Shows or hides the AGPro exposure dashboard. It is shown by default for public-release readability."
ttPanelLocation = "Moves the panel to the preferred chart location."
ttPanelTheme = "Switches the panel between AGPro dark and clean light themes."
ttPanelFont = "Font size for the AGPro panel. Normal is the recommended publication default."
ttAlerts = "Enables alert conditions for balanced, watch, stretched, blocked, and reset exposure states."
ttShowProof = "Shows the confirmation-anchored proof layer in the panel: Follow, Hold, React, and Flip rates measured across past constructive exposure calls (entries into Balanced or Watch) on the current symbol and timeframe. These are historical outcome rates, not predictions."
ttProofHorizon = "Number of bars each constructive exposure call is tracked forward to measure whether it followed through in the exposure direction before the invalidation shelf was breached."
ttProofFollow = "Favorable distance, in ATR from the call's close, that counts as a follow-through (Follow)."
ttReactBars = "Number of bars after a constructive exposure call used to detect an immediate favorable reaction."
ttReactProgress = "Minimum favorable progress toward the follow-through distance, within the reaction window, required to count as an early React."

// -------------------------------------------------
// Inputs
// -------------------------------------------------
groupEngine = "Risk Exposure Engine"
sideMode = input.string("Auto", "Exposure Side", options = ["Auto", "Long Exposure", "Short Exposure"], group = groupEngine, tooltip = ttSide)
confirmOnClose = input.bool(true, "Confirm On Bar Close", group = groupEngine, tooltip = ttConfirm)
rangeLookback = input.int(72, "Range Lookback", minval = 20, maxval = 300, group = groupEngine, tooltip = ttRange)
atrLen = input.int(14, "ATR Length", minval = 2, maxval = 100, group = groupEngine, tooltip = ttAtrLen)
atrBaseLen = input.int(55, "ATR Load Baseline", minval = 10, maxval = 300, group = groupEngine, tooltip = ttAtrBase)
meanLen = input.int(34, "Exposure Mean EMA", minval = 2, maxval = 240, group = groupEngine, tooltip = ttMean)
fastEmaLen = input.int(13, "Fast Context EMA", minval = 1, maxval = 120, group = groupEngine, tooltip = ttFast)
trendEmaLen = input.int(89, "Trend Context EMA", minval = 5, maxval = 300, group = groupEngine, tooltip = ttTrend)
trendMaturityBars = input.int(48, "Trend Maturity Bars", minval = 8, maxval = 220, group = groupEngine, tooltip = ttMaturity)
targetLookback = input.int(96, "Target Obstruction Lookback", minval = 20, maxval = 350, group = groupEngine, tooltip = ttTarget)
invalidationLookback = input.int(34, "Invalidation Shelf Lookback", minval = 8, maxval = 180, group = groupEngine, tooltip = ttInvalidation)

groupScoring = "Exposure Scoring"
sensitivityInput = input.string("Balanced", "Sensitivity", options = ["Conservative", "Balanced", "Aggressive"], group = groupScoring, tooltip = ttSensitivity)
minimumBalancedScore = input.int(68, "Minimum Balanced Score", minval = 35, maxval = 95, group = groupScoring, tooltip = ttMinScore)
watchScore = input.int(52, "Watch Score", minval = 20, maxval = 90, group = groupScoring, tooltip = ttWatchScore)
balanceMinAtr = input.float(0.28, "Compass Band Min ATR", minval = 0.05, maxval = 3.00, step = 0.01, group = groupScoring, tooltip = ttBalanceMin)
balanceIdealAtr = input.float(1.05, "Compass Band Ideal ATR", minval = 0.10, maxval = 5.00, step = 0.05, group = groupScoring, tooltip = ttBalanceIdeal)
balanceMaxAtr = input.float(2.15, "Compass Band Max ATR", minval = 0.30, maxval = 8.00, step = 0.05, group = groupScoring, tooltip = ttBalanceMax)
stretchAtr = input.float(2.85, "Stretched Risk ATR", minval = 0.80, maxval = 10.00, step = 0.05, group = groupScoring, tooltip = ttStretch)
minimumTargetRoomAtr = input.float(1.15, "Minimum Target Room ATR", minval = 0.20, maxval = 8.00, step = 0.05, group = groupScoring, tooltip = ttTargetRoom)
minimumRiskDistanceAtr = input.float(0.55, "Minimum Invalidation Distance ATR", minval = 0.05, maxval = 5.00, step = 0.05, group = groupScoring, tooltip = ttRiskMin)
maximumRiskDistanceAtr = input.float(3.40, "Maximum Invalidation Distance ATR", minval = 0.50, maxval = 12.00, step = 0.05, group = groupScoring, tooltip = ttRiskMax)

groupVisual = "Chart Visuals"
showCompassBand = input.bool(true, "Show Risk Compass Band", group = groupVisual, tooltip = ttShowBand)
showGuideLines = input.bool(true, "Show Mean / Risk / Target Guides", group = groupVisual, tooltip = ttShowGuides)
showGuideTags = input.bool(true, "Show Guide Tags", group = groupVisual, tooltip = ttGuideTags)
showHeatCandles = input.bool(false, "Show Exposure Heat Candles", group = groupVisual, tooltip = ttShowHeat)
projectionBars = input.int(42, "Projection Bars", minval = 8, maxval = 180, group = groupVisual, tooltip = ttProjection)
useSolidBandLabel = input.bool(true, "Use Solid Compass Label", group = groupVisual, tooltip = ttSolidBand)

groupLabels = "Labels"
showEventLabels = input.bool(true, "Show Event Labels", group = groupLabels, tooltip = ttLabels)
showContextLabels = input.bool(false, "Show Sparse Context Labels", group = groupLabels, tooltip = ttContext)
showResetLabels = input.bool(false, "Show Reset Labels", group = groupLabels, tooltip = ttResetLabels)
showEventMarkers = input.bool(false, "Show Event Markers", group = groupLabels, tooltip = ttMarkers)
labelCooldownBars = input.int(30, "Label Cooldown Bars", minval = 1, maxval = 120, group = groupLabels, tooltip = ttCooldown)
contextSpacingBars = input.int(96, "Context Label Spacing", minval = 10, maxval = 240, group = groupLabels, tooltip = ttContextSpacing)
maxVisibleLabels = input.int(6, "Max Visible Labels", minval = 4, maxval = 80, group = groupLabels, tooltip = ttMaxLabels)
labelOffsetAtr = input.float(1.05, "Label Offset ATR", minval = 0.10, maxval = 3.00, step = 0.05, group = groupLabels, tooltip = ttLabelOffset)
showLabelScore = input.bool(true, "Show Label Score", group = groupLabels, tooltip = ttLabelScore)
showLabelMetrics = input.bool(false, "Show Label Metrics", group = groupLabels, tooltip = ttLabelMetrics)
labelSizeInput = input.string("Normal", "Label Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = groupLabels, tooltip = ttLabelSize)

groupPanel = "Panel"
showPanel = input.bool(true, "Show Panel", group = groupPanel, tooltip = ttShowPanel)
panelLocationInput = input.string("Top Right", "Panel Location", options = ["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], group = groupPanel, tooltip = ttPanelLocation)
panelThemeInput = input.string("Elite Dark", "Panel Theme", options = ["Elite Dark", "Clean Light"], group = groupPanel, tooltip = ttPanelTheme)
panelFontSizeInput = input.string("Normal", "Panel Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = groupPanel, tooltip = ttPanelFont)

groupProof = "Proof"
showProof = input.bool(true, "Show Proof Layer", group = groupProof, tooltip = ttShowProof)
proofHorizonBars = input.int(24, "Proof Horizon Bars", minval = 5, maxval = 240, group = groupProof, tooltip = ttProofHorizon)
proofFollowAtr = input.float(1.50, "Proof Follow-Through ATR", minval = 0.30, maxval = 10.00, step = 0.05, group = groupProof, tooltip = ttProofFollow)
reactBars = input.int(4, "Reaction Window Bars", minval = 1, maxval = 60, group = groupProof, tooltip = ttReactBars)
reactProgressPct = input.float(33.0, "Reaction Progress %", minval = 5.0, maxval = 80.0, step = 1.0, group = groupProof, tooltip = ttReactProgress)

groupAlerts = "Alerts"
alertExposureStates = input.bool(true, "Alert on Exposure States", group = groupAlerts, tooltip = ttAlerts)

// -------------------------------------------------
// Helpers
// -------------------------------------------------
f_clamp(float value, float minValue, float maxValue) =>
    math.min(math.max(value, minValue), maxValue)

f_norm_high_good(float value, float weak, float strong) =>
    float span = strong - weak
    span == 0.0 ? 0.0 : f_clamp((value - weak) / span * 100.0, 0.0, 100.0)

f_norm_low_good(float value, float good, float bad) =>
    float span = bad - good
    span == 0.0 ? 0.0 : f_clamp((bad - value) / span * 100.0, 0.0, 100.0)

f_peak_score(float value, float lowValue, float idealValue, float highValue) =>
    value <= idealValue ? f_norm_high_good(value, lowValue, idealValue) : f_norm_low_good(value, idealValue, highValue)

f_label_size(string sizeText) =>
    switch sizeText
        "Tiny" => size.tiny
        "Small" => size.small
        "Large" => size.large
        => size.normal

f_panel_position(string posText) =>
    switch posText
        "Top Left" => position.top_left
        "Top Center" => position.top_center
        "Middle Left" => position.middle_left
        "Middle Center" => position.middle_center
        "Middle Right" => position.middle_right
        "Bottom Left" => position.bottom_left
        "Bottom Center" => position.bottom_center
        "Bottom Right" => position.bottom_right
        => position.top_right

f_panel_bg(string theme) =>
    theme == "Clean Light" ? color.rgb(241, 245, 249) : panelBg

f_panel_border(string theme) =>
    theme == "Clean Light" ? color.rgb(148, 163, 184) : panelBorder

f_panel_label(string theme) =>
    theme == "Clean Light" ? color.rgb(71, 85, 105) : panelLabelCol

f_panel_value(string theme) =>
    theme == "Clean Light" ? color.rgb(15, 23, 42) : panelValueCol

f_row_bg(string theme, int row) =>
    bool evenRow = row % 2 == 0
    if theme == "Clean Light"
        evenRow ? color.rgb(226, 232, 240) : color.rgb(241, 245, 249)
    else
        evenRow ? color.rgb(20, 31, 52) : panelBg

f_score_color(int score) =>
    score >= 78 ? bullColor : score >= 62 ? accentColor : score >= 48 ? neutralColor : bearColor

f_pressure_color(int pressure) =>
    pressure >= 72 ? dangerColor : pressure >= 55 ? neutralColor : pressure >= 35 ? accentColor : bullColor

f_pct(float value) =>
    str.tostring(int(math.round(value))) + "%"

f_rate_color(float value) =>
    value >= 55 ? bullColor : value >= 40 ? neutralColor : bearColor

f_flip_color(float value) =>
    value <= 30 ? bullColor : value <= 55 ? neutralColor : bearColor

f_state_color(string stateText) =>
    switch stateText
        "BALANCED" => bullColor
        "WATCH" => accentColor
        "STRETCHED" => neutralColor
        "BLOCKED" => bearColor
        "RESET" => panelLabelCol
        => panelLabelCol

f_state_short(string stateText) =>
    switch stateText
        "BALANCED" => "BAL"
        "STRETCHED" => "STRETCH"
        "BLOCKED" => "BLOCK"
        "WATCH" => "WATCH"
        => "RESET"

f_pressure_text(int pressure) =>
    pressure >= 72 ? "HIGH" : pressure >= 55 ? "ELEVATED" : pressure >= 35 ? "MODERATE" : "CONTROLLED"

f_balance_text(int score) =>
    score >= 78 ? "STRONG" : score >= 62 ? "FAIR" : score >= 48 ? "WEAK" : "LOW"

f_set_row(table target, int row, string leftText, string rightText, color rightColor, string theme, string fontSize) =>
    color rowBg = f_row_bg(theme, row)
    table.cell(target, 0, row, leftText, text_color = f_panel_label(theme), bgcolor = rowBg, text_size = f_label_size(fontSize))
    table.cell(target, 1, row, rightText, text_color = rightColor, bgcolor = rowBg, text_size = f_label_size(fontSize), text_halign = text.align_right)

f_trim_labels(array<label> labels, int maxCount) =>
    int labelCount = array.size(labels)
    if labelCount > maxCount
        int removeCount = labelCount - maxCount
        for idx = 0 to removeCount - 1
            label oldLabel = array.shift(labels)
            label.delete(oldLabel)

f_best_view_text(string stateText, float roomAtr, float riskAtr, string volText, float roomNeed, float riskNeed) =>
    string view = "Review"
    if stateText == "BALANCED"
        view := roomAtr >= roomNeed and riskAtr >= riskNeed ? "Cleaner review" : "Check room"
    else if stateText == "WATCH"
        view := "Wait for balance"
    else if stateText == "STRETCHED"
        view := "Avoid chasing"
    else if stateText == "BLOCKED"
        view := "Wait for room"
    else
        view := "Let context build"
    volText == "EXTREME" ? "Volatility caution" : view

// -------------------------------------------------
// Core measurements
// -------------------------------------------------
float atr = ta.atr(atrLen)
float safeAtr = math.max(nz(atr, ta.tr(true)), syminfo.mintick)
float atrBase = ta.sma(atr, atrBaseLen)
float atrRatio = not na(atrBase) and atrBase > 0.0 ? atr / atrBase : 1.0
float sensitivityFactor = sensitivityInput == "Conservative" ? 1.12 : sensitivityInput == "Aggressive" ? 0.90 : 1.0

float balanceMinRaw = math.min(balanceMinAtr, balanceMaxAtr)
float balanceMaxRaw = math.max(balanceMinAtr, balanceMaxAtr)
float effectiveBalanceMinAtr = balanceMinRaw
float effectiveBalanceMaxAtr = math.max(balanceMaxRaw, effectiveBalanceMinAtr + 0.05)
float effectiveBalanceIdealAtr = f_clamp(balanceIdealAtr, effectiveBalanceMinAtr + 0.01, effectiveBalanceMaxAtr - 0.01)
float effectiveStretchAtr = math.max(stretchAtr, effectiveBalanceMaxAtr + 0.05)

float effectiveRiskMinAtr = math.min(minimumRiskDistanceAtr, maximumRiskDistanceAtr)
float effectiveRiskMaxAtr = math.max(maximumRiskDistanceAtr, effectiveRiskMinAtr + 0.05)
float effectiveTargetRoomAtr = math.max(minimumTargetRoomAtr, 0.01)

int effectiveBalancedScore = int(math.min(95, math.max(minimumBalancedScore, watchScore + 1)))
int effectiveWatchScore = int(math.min(watchScore, effectiveBalancedScore - 1))
int effectiveReactBars = math.min(reactBars, math.max(proofHorizonBars - 1, 1))

float meanEma = ta.ema(close, meanLen)
float fastEma = ta.ema(close, fastEmaLen)
float trendEma = ta.ema(close, trendEmaLen)
float trendSlope = trendEma - nz(trendEma[5], trendEma)

bool bullBias = close >= meanEma and fastEma >= meanEma and trendSlope >= -safeAtr * 0.05
bool bearBias = close <= meanEma and fastEma <= meanEma and trendSlope <= safeAtr * 0.05
var int exposureDir = 1
int previousDir = nz(exposureDir[1], close >= meanEma ? 1 : -1)
int autoDir = bullBias ? 1 : bearBias ? -1 : previousDir
exposureDir := sideMode == "Long Exposure" ? 1 : sideMode == "Short Exposure" ? -1 : autoDir

string dirText = exposureDir == 1 ? "Long" : "Short"
color dirColor = exposureDir == 1 ? bullColor : bearColor

var int trendAge = 1
trendAge := exposureDir == nz(exposureDir[1], exposureDir) ? nz(trendAge[1], 0) + 1 : 1

float rangeHigh = ta.highest(high, rangeLookback)
float rangeLow = ta.lowest(low, rangeLookback)
float rangeSpan = math.max(rangeHigh - rangeLow, syminfo.mintick)
float rangePos = f_clamp((close - rangeLow) / rangeSpan, 0.0, 1.0)
float sideRangePos = exposureDir == 1 ? rangePos : 1.0 - rangePos

float directionalMeanAtr = exposureDir == 1 ? (close - meanEma) / safeAtr : (meanEma - close) / safeAtr
float meanDistanceAtr = math.abs(close - meanEma) / safeAtr
float barStretchAtr = math.max((high - low) / safeAtr, math.abs(close - open) / safeAtr * 1.35)

float longInvalidationShelf = ta.lowest(low, invalidationLookback)
float shortInvalidationShelf = ta.highest(high, invalidationLookback)
float invalidationShelf = exposureDir == 1 ? longInvalidationShelf : shortInvalidationShelf
float riskDistanceRaw = exposureDir == 1 ? close - invalidationShelf : invalidationShelf - close
float riskDistanceAtr = math.max(riskDistanceRaw / safeAtr, 0.0)

float longTargetEdge = nz(ta.highest(high, targetLookback)[1], high)
float shortTargetEdge = nz(ta.lowest(low, targetLookback)[1], low)
float targetEdge = exposureDir == 1 ? longTargetEdge : shortTargetEdge
float targetRoomRaw = exposureDir == 1 ? targetEdge - close : close - targetEdge
float targetRoomAtr = targetRoomRaw / safeAtr

float balanceMinAdj = effectiveBalanceMinAtr * sensitivityFactor
float balanceIdealAdj = effectiveBalanceIdealAtr * sensitivityFactor
float balanceMaxAdj = effectiveBalanceMaxAtr * sensitivityFactor
float stretchAdj = effectiveStretchAtr * sensitivityFactor
float targetRoomNeed = effectiveTargetRoomAtr * sensitivityFactor
float riskMinAdj = effectiveRiskMinAtr * sensitivityFactor
float riskMaxAdj = effectiveRiskMaxAtr * sensitivityFactor

float compassInner = exposureDir == 1 ? meanEma + safeAtr * balanceMinAdj : meanEma - safeAtr * balanceMinAdj
float compassOuter = exposureDir == 1 ? meanEma + safeAtr * balanceMaxAdj : meanEma - safeAtr * balanceMaxAdj
float compassTop = math.max(compassInner, compassOuter)
float compassBottom = math.min(compassInner, compassOuter)

// -------------------------------------------------
// Score model
// -------------------------------------------------
float atrStretchScore = f_peak_score(barStretchAtr, 0.18, 0.92, 2.80)
float rangePositionScore = f_peak_score(sideRangePos, 0.20, 0.58, 0.96)
float meanDistanceScore = directionalMeanAtr < 0.0 ? f_clamp(28.0 + directionalMeanAtr * 12.0, 0.0, 28.0) : f_peak_score(directionalMeanAtr, balanceMinAdj * 0.35, balanceIdealAdj, stretchAdj)
float trendAgeScore = f_peak_score(trendAge * 1.0, 3.0, trendMaturityBars * 0.62, trendMaturityBars * 1.72)
float targetObstructionScore = targetRoomAtr <= 0.0 ? 0.0 : f_norm_high_good(targetRoomAtr, targetRoomNeed * 0.45, targetRoomNeed * 2.40)

float rawRiskScore = atrStretchScore * 0.20 + rangePositionScore * 0.20 + meanDistanceScore * 0.20 + trendAgeScore * 0.20 + targetObstructionScore * 0.20

bool inCompassBand = directionalMeanAtr >= balanceMinAdj and directionalMeanAtr <= balanceMaxAdj
bool targetBlocked = targetRoomAtr < targetRoomNeed
bool fragileRisk = riskDistanceAtr < riskMinAdj
bool wideRisk = riskDistanceAtr > riskMaxAdj
bool volatilityHot = atrRatio > 1.72 or barStretchAtr > 2.65
bool volatilityExtreme = atrRatio > 2.15 or barStretchAtr > 3.25
bool stretchedRisk = directionalMeanAtr > stretchAdj or sideRangePos > 0.92 or volatilityExtreme

float adjustedScore = rawRiskScore
if targetBlocked
    adjustedScore := math.min(adjustedScore, 58.0)
if stretchedRisk
    adjustedScore := math.min(adjustedScore, 62.0)
if wideRisk
    adjustedScore := math.min(adjustedScore, 60.0)
if fragileRisk
    adjustedScore := math.min(adjustedScore, 66.0)

int exposureScore = int(math.round(f_clamp(adjustedScore, 0.0, 100.0)))
int pressureRaw = int(math.round(f_clamp((100.0 - exposureScore) * 0.45 + math.max(directionalMeanAtr - balanceIdealAdj, 0.0) / math.max(stretchAdj, 0.1) * 35.0 + (targetBlocked ? 18.0 : 0.0) + (wideRisk or fragileRisk ? 16.0 : 0.0) + (volatilityHot ? 12.0 : 0.0), 0.0, 100.0)))
string pressureState = f_pressure_text(pressureRaw)
string balanceState = f_balance_text(exposureScore)
string volatilityLoad = volatilityExtreme ? "EXTREME" : volatilityHot ? "HOT" : atrRatio < 0.72 ? "LOW" : "NORMAL"
string distanceState = wideRisk ? "WIDE" : fragileRisk ? "FRAGILE" : "CONTROLLED"

string exposureState = ""
if targetBlocked and exposureScore < effectiveBalancedScore
    exposureState := "BLOCKED"
else if stretchedRisk or wideRisk
    exposureState := "STRETCHED"
else if inCompassBand and exposureScore >= effectiveBalancedScore
    exposureState := "BALANCED"
else if exposureScore >= effectiveWatchScore
    exposureState := "WATCH"
else
    exposureState := "RESET"

string actionState = exposureState == "BALANCED" ? "Review plan" : exposureState == "WATCH" ? "Wait for balance" : exposureState == "STRETCHED" ? "Review stretch" : exposureState == "BLOCKED" ? "Wait for room" : "Wait"
string bestViewState = f_best_view_text(exposureState, targetRoomAtr, riskDistanceAtr, volatilityLoad, targetRoomNeed, riskMinAdj)
int engineWarmup = math.max(math.max(rangeLookback, targetLookback), math.max(math.max(invalidationLookback, trendEmaLen), atrBaseLen)) + atrLen + 5
bool engineReady = bar_index > engineWarmup

if not engineReady
    exposureState := "RESET"
    actionState := "Wait"
    bestViewState := "Let context build"

color stateColor = f_state_color(exposureState)
bool confirmedBar = not confirmOnClose or barstate.isconfirmed

// -------------------------------------------------
// Plots and heat
// -------------------------------------------------
plot(showGuideLines ? meanEma : na, "Exposure Mean", color = color.new(accentColor, 40), linewidth = 2)
plot(showGuideLines ? trendEma : na, "Trend Context", color = color.new(panelLabelCol, 82), linewidth = 1)
barcolor(showHeatCandles ? color.new(stateColor, 84) : na)

// -------------------------------------------------
// Compass band and guide objects
// -------------------------------------------------
int rightEdge = bar_index + projectionBars
int invalidationTagX = rightEdge
int meanTagX = rightEdge + 2
int targetTagX = rightEdge + 4
int zoneLeft = bar_index - math.min(rangeLookback, 55)
string bandText = "Balance " + str.tostring(exposureScore) + "\nPressure " + str.tostring(pressureRaw)
color bandColor = exposureState == "BALANCED" ? dirColor : stateColor
float bandMid = (compassTop + compassBottom) * 0.5
int bandX = bar_index + int(math.round(projectionBars * 0.50))

var box compassBand = na
var label compassBandLabel = na
if showCompassBand
    if na(compassBand)
        compassBand := box.new(left = zoneLeft, top = compassTop, right = rightEdge, bottom = compassBottom, xloc = xloc.bar_index, bgcolor = color.new(bandColor, 91), border_color = color.new(bandColor, exposureState == "BALANCED" ? 18 : 34), border_width = exposureState == "BALANCED" ? 2 : 1)
    else
        box.set_left(compassBand, zoneLeft)
        box.set_right(compassBand, rightEdge)
        box.set_top(compassBand, compassTop)
        box.set_bottom(compassBand, compassBottom)
        box.set_bgcolor(compassBand, color.new(bandColor, 91))
        box.set_border_color(compassBand, color.new(bandColor, exposureState == "BALANCED" ? 18 : 34))
        box.set_border_width(compassBand, exposureState == "BALANCED" ? 2 : 1)
    color badgeBg = useSolidBandLabel ? color.new(bandColor, 0) : color.new(bandColor, 100)
    color badgeText = useSolidBandLabel ? headerText : color.new(headerText, 0)
    if na(compassBandLabel)
        compassBandLabel := label.new(bandX, bandMid, bandText, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_center, color = badgeBg, textcolor = badgeText, size = f_label_size(labelSizeInput), textalign = text.align_center)
    else
        label.set_x(compassBandLabel, bandX)
        label.set_y(compassBandLabel, bandMid)
        label.set_text(compassBandLabel, bandText)
        label.set_color(compassBandLabel, badgeBg)
        label.set_textcolor(compassBandLabel, badgeText)
        label.set_size(compassBandLabel, f_label_size(labelSizeInput))
        label.set_textalign(compassBandLabel, text.align_center)
else
    if not na(compassBand)
        box.delete(compassBand)
        compassBand := na
    if not na(compassBandLabel)
        label.delete(compassBandLabel)
        compassBandLabel := na

var line invalidationLine = na
var label invalidationLabel = na
var line targetLine = na
var label targetLabel = na
var label meanLabel = na

if showGuideLines
    color invalidationColor = color.new(bearColor, 10)
    string invalidationText = "Risk shelf\n" + str.tostring(riskDistanceAtr, "#.00") + " ATR"
    float invalidationTagY = invalidationShelf + (exposureDir == 1 ? -safeAtr * 0.28 : safeAtr * 0.28)
    if na(invalidationLine)
        invalidationLine := line.new(bar_index, invalidationShelf, invalidationTagX, invalidationShelf, xloc = xloc.bar_index, extend = extend.none, color = invalidationColor, width = 1, style = line.style_dashed)
    else
        line.set_xy1(invalidationLine, bar_index, invalidationShelf)
        line.set_xy2(invalidationLine, invalidationTagX, invalidationShelf)
        line.set_color(invalidationLine, invalidationColor)
    if showGuideTags
        if na(invalidationLabel)
            invalidationLabel := label.new(invalidationTagX, invalidationTagY, invalidationText, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = color.new(bearColor, 0), textcolor = headerText, size = f_label_size(labelSizeInput), textalign = text.align_center)
        else
            label.set_xy(invalidationLabel, invalidationTagX, invalidationTagY)
            label.set_text(invalidationLabel, invalidationText)
            label.set_color(invalidationLabel, color.new(bearColor, 0))
            label.set_textcolor(invalidationLabel, headerText)
            label.set_size(invalidationLabel, f_label_size(labelSizeInput))
    else if not na(invalidationLabel)
        label.delete(invalidationLabel)
        invalidationLabel := na

    color targetColor = targetBlocked ? neutralColor : bullColor
    string targetText = "Target room\n" + str.tostring(targetRoomAtr, "#.00") + " ATR"
    float targetTagY = targetEdge + (exposureDir == 1 ? safeAtr * 0.28 : -safeAtr * 0.28)
    if na(targetLine)
        targetLine := line.new(bar_index, targetEdge, targetTagX, targetEdge, xloc = xloc.bar_index, extend = extend.none, color = color.new(targetColor, 10), width = 1, style = line.style_dashed)
    else
        line.set_xy1(targetLine, bar_index, targetEdge)
        line.set_xy2(targetLine, targetTagX, targetEdge)
        line.set_color(targetLine, color.new(targetColor, 10))
    if showGuideTags
        if na(targetLabel)
            targetLabel := label.new(targetTagX, targetTagY, targetText, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = color.new(targetColor, 0), textcolor = headerText, size = f_label_size(labelSizeInput), textalign = text.align_center)
        else
            label.set_xy(targetLabel, targetTagX, targetTagY)
            label.set_text(targetLabel, targetText)
            label.set_color(targetLabel, color.new(targetColor, 0))
            label.set_textcolor(targetLabel, headerText)
            label.set_size(targetLabel, f_label_size(labelSizeInput))
    else if not na(targetLabel)
        label.delete(targetLabel)
        targetLabel := na

    string meanText = "Mean\n" + str.tostring(meanDistanceAtr, "#.00") + " ATR"
    if showGuideTags
        if na(meanLabel)
            meanLabel := label.new(meanTagX, meanEma, meanText, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = color.new(accentColor, 10), textcolor = headerText, size = f_label_size(labelSizeInput), textalign = text.align_center)
        else
            label.set_xy(meanLabel, meanTagX, meanEma)
            label.set_text(meanLabel, meanText)
            label.set_color(meanLabel, color.new(accentColor, 10))
            label.set_textcolor(meanLabel, headerText)
            label.set_size(meanLabel, f_label_size(labelSizeInput))
    else if not na(meanLabel)
        label.delete(meanLabel)
        meanLabel := na
else
    if not na(invalidationLine)
        line.delete(invalidationLine)
        invalidationLine := na
    if not na(invalidationLabel)
        label.delete(invalidationLabel)
        invalidationLabel := na
    if not na(targetLine)
        line.delete(targetLine)
        targetLine := na
    if not na(targetLabel)
        label.delete(targetLabel)
        targetLabel := na
    if not na(meanLabel)
        label.delete(meanLabel)
        meanLabel := na

// -------------------------------------------------
// Labels and markers
// -------------------------------------------------
var int lastLabelBar = na
var string lastExposureState = ""
var array<label> eventLabels = array.new_label()

bool balancedEvent = confirmedBar and exposureState == "BALANCED" and lastExposureState != "BALANCED"
bool stretchedEvent = confirmedBar and exposureState == "STRETCHED" and lastExposureState != "STRETCHED"
bool blockedEvent = confirmedBar and exposureState == "BLOCKED" and lastExposureState != "BLOCKED"
bool watchEvent = confirmedBar and exposureState == "WATCH" and lastExposureState != "WATCH"
bool resetEvent = confirmedBar and exposureState == "RESET" and lastExposureState != "RESET"

// -------------------------------------------------
// Confirmation-anchored proof (constructive exposure follow-through)
// -------------------------------------------------
bool proofConstructiveState = exposureState == "BALANCED" or exposureState == "WATCH"
bool proofPreviousConstructive = bar_index > 0 and (exposureState[1] == "BALANCED" or exposureState[1] == "WATCH")
bool proofConstructiveEvent = barstate.isconfirmed and engineReady and proofConstructiveState and (not proofPreviousConstructive or exposureDir != nz(exposureDir[1], exposureDir))

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

if barstate.isconfirmed and engineReady
    if pEvalActive
        int heldBars = bar_index - pEvalStart
        float followDist = math.max(math.abs(pEvalTarget - pEvalEntry), syminfo.mintick)
        float favorableExcursion = pEvalDir == 1 ? high - pEvalEntry : pEvalEntry - low
        bool targetTouched = heldBars >= 1 and favorableExcursion >= followDist
        bool stopTouched = pEvalDir == 1 ? low <= pEvalStop : high >= pEvalStop
        bool directionReplaced = exposureDir != pEvalDir
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

    if proofConstructiveEvent and not pEvalActive
        pEvalActive := true
        pEvalDir := exposureDir
        pEvalEntry := close
        pEvalStop := invalidationShelf
        pEvalTarget := close + exposureDir * safeAtr * proofFollowAtr
        pEvalStart := bar_index
        pReacted := false
        pFollowed := false

float followRate = proofTotal > 0 ? proofFollow * 100.0 / proofTotal : 0.0
float holdRate = proofTotal > 0 ? proofHold * 100.0 / proofTotal : 0.0
float reactRate = proofTotal > 0 ? proofReact * 100.0 / proofTotal : 0.0
float flipRate = proofTotal > 0 ? proofFlip * 100.0 / proofTotal : 0.0

bool labelCooldownReady = na(lastLabelBar) or bar_index - lastLabelBar >= labelCooldownBars
bool contextReady = na(lastLabelBar) or bar_index - lastLabelBar >= contextSpacingBars
bool drawContext = showContextLabels and contextReady and (exposureState == "BALANCED" or exposureState == "STRETCHED")
bool resetLabelEvent = showResetLabels and resetEvent
bool drawEventLabel = showEventLabels and labelCooldownReady and (balancedEvent or stretchedEvent or blockedEvent or watchEvent or resetLabelEvent or drawContext)

if drawEventLabel
    bool warningLabel = exposureState == "STRETCHED" or exposureState == "BLOCKED"
    bool drawAbove = warningLabel ? exposureDir == 1 : exposureDir == -1
    float labelY = drawAbove ? high + safeAtr * labelOffsetAtr : low - safeAtr * labelOffsetAtr
    string labelText = f_state_short(exposureState)
    if showLabelScore
        labelText += " " + str.tostring(exposureScore)
    if showLabelMetrics
        labelText += "\nR " + str.tostring(riskDistanceAtr, "#.0") + " T " + str.tostring(targetRoomAtr, "#.0")
    label eventLabel = label.new(x = bar_index, y = labelY, text = labelText, xloc = xloc.bar_index, yloc = yloc.price, style = drawAbove ? label.style_label_down : label.style_label_up, color = color.new(stateColor, 0), textcolor = headerText, size = f_label_size(labelSizeInput))
    array.push(eventLabels, eventLabel)
    f_trim_labels(eventLabels, maxVisibleLabels)
    lastLabelBar := bar_index

plotshape(showEventMarkers and balancedEvent and exposureDir == 1, title = "Long Balanced Marker", style = shape.diamond, location = location.belowbar, color = color.new(bullColor, 0), size = size.tiny)
plotshape(showEventMarkers and balancedEvent and exposureDir == -1, title = "Short Balanced Marker", style = shape.diamond, location = location.abovebar, color = color.new(bullColor, 0), size = size.tiny)
plotshape(showEventMarkers and stretchedEvent, title = "Stretched Risk Marker", style = shape.diamond, location = location.abovebar, color = color.new(neutralColor, 0), size = size.tiny)
plotshape(showEventMarkers and blockedEvent, title = "Blocked Room Marker", style = shape.diamond, location = location.abovebar, color = color.new(bearColor, 0), size = size.tiny)

// -------------------------------------------------
// Data window
// -------------------------------------------------
plot(exposureScore, title = "Risk Exposure Score", color = f_score_color(exposureScore), display = display.data_window)
plot(pressureRaw, title = "Risk Pressure", color = f_pressure_color(pressureRaw), display = display.data_window)
plot(atrStretchScore, title = "ATR Stretch Score", color = neutralColor, display = display.data_window)
plot(rangePositionScore, title = "Range Position Score", color = accentColor, display = display.data_window)
plot(meanDistanceScore, title = "Mean Distance Score", color = bullColor, display = display.data_window)
plot(trendAgeScore, title = "Trend Maturity Score", color = panelValueCol, display = display.data_window)
plot(targetObstructionScore, title = "Target Obstruction Score", color = bearColor, display = display.data_window)
plot(followRate, title = "Follow Rate", color = bullColor, display = display.data_window)
plot(holdRate, title = "Hold Rate", color = accentColor, display = display.data_window)
plot(reactRate, title = "React Rate", color = neutralColor, display = display.data_window)
plot(flipRate, title = "Flip Rate", color = bearColor, display = display.data_window)
plot(proofAmbiguous, title = "Ambiguous Proof Count", color = panelValueCol, display = display.data_window)
plot(riskDistanceAtr, title = "Invalidation Distance ATR", color = bearColor, display = display.data_window)
plot(targetRoomAtr, title = "Target Room ATR", color = bullColor, display = display.data_window)
plot(exposureDir, title = "Exposure Direction", color = accentColor, display = display.data_window)
plot(trendAge, title = "Trend Exposure Age", color = panelValueCol, display = display.data_window)

// -------------------------------------------------
// Panel
// -------------------------------------------------
string theme = panelThemeInput
string panelSize = panelFontSizeInput
color dashBg = f_panel_bg(theme)
color frameColor = f_panel_border(theme)
string atrRatioText = atrRatio < 1.0 ? "0" + str.tostring(atrRatio, "#.00") : str.tostring(atrRatio, "#.00")

string biasRead = dirText + " | " + exposureState
string balanceRead = str.tostring(exposureScore) + " / " + balanceState
string pressureRead = str.tostring(pressureRaw) + " / " + pressureState
string volatilityRead = volatilityLoad + " | " + atrRatioText + "x"
string distanceRead = distanceState + " | R " + str.tostring(riskDistanceAtr, "#.00") + " / M " + str.tostring(meanDistanceAtr, "#.00")
string roomRead = (targetBlocked ? "Limited" : "Open") + " | " + str.tostring(targetRoomAtr, "#.00") + " ATR"
string actionRead = actionState + " | " + bestViewState

string proofSampleText = proofTotal > 0 ? "n = " + str.tostring(proofTotal) + (proofAmbiguous > 0 ? " | x = " + str.tostring(proofAmbiguous) : "") : proofAmbiguous > 0 ? "x = " + str.tostring(proofAmbiguous) : "building"
string followText = proofTotal > 0 ? f_pct(followRate) : "-"
string holdText = proofTotal > 0 ? f_pct(holdRate) : "-"
string reactText = proofTotal > 0 ? f_pct(reactRate) : "-"
string flipText = proofTotal > 0 ? f_pct(flipRate) : "-"
color followCol = proofTotal > 0 ? f_rate_color(followRate) : f_panel_value(theme)
color holdCol = proofTotal > 0 ? f_rate_color(holdRate) : f_panel_value(theme)
color reactCol = proofTotal > 0 ? f_rate_color(reactRate) : f_panel_value(theme)
color flipCol = proofTotal > 0 ? f_flip_color(flipRate) : f_panel_value(theme)

int panelRowCount = showProof ? 13 : 8

var table panel = table.new(f_panel_position(panelLocationInput), 2, panelRowCount, bgcolor = dashBg, frame_color = frameColor, frame_width = 1, border_color = frameColor, border_width = 1)

if barstate.islast
    table.set_position(panel, f_panel_position(panelLocationInput))
    table.set_frame_color(panel, frameColor)
    table.set_border_color(panel, frameColor)
    if showPanel
        table.clear(panel, 0, 0, 1, panelRowCount - 1)
        table.merge_cells(panel, 0, 0, 1, 0)
        table.cell(panel, 0, 0, "AG Pro Risk Exposure Compass", text_color = headerText, bgcolor = headerBg, text_size = f_label_size(panelSize), text_halign = text.align_center)
        f_set_row(panel, 1, "Exposure Bias", biasRead, stateColor, theme, panelSize)
        f_set_row(panel, 2, "Exposure Balance", balanceRead, f_score_color(exposureScore), theme, panelSize)
        f_set_row(panel, 3, "Risk Pressure", pressureRead, f_pressure_color(pressureRaw), theme, panelSize)
        f_set_row(panel, 4, "Volatility Load", volatilityRead, volatilityExtreme ? dangerColor : volatilityHot ? neutralColor : bullColor, theme, panelSize)
        f_set_row(panel, 5, "Distance Risk", distanceRead, distanceState == "CONTROLLED" ? bullColor : neutralColor, theme, panelSize)
        f_set_row(panel, 6, "Target Room", roomRead, targetBlocked ? neutralColor : bullColor, theme, panelSize)
        f_set_row(panel, 7, "Next Action", actionRead, stateColor, theme, panelSize)
        if showProof
            color proofHeadBg = f_row_bg(theme, 8)
            table.cell(panel, 0, 8, "Proof @ Confirm", text_color = accentColor, bgcolor = proofHeadBg, text_size = f_label_size(panelSize), text_halign = text.align_left)
            table.cell(panel, 1, 8, proofSampleText, text_color = f_panel_label(theme), bgcolor = proofHeadBg, text_size = f_label_size(panelSize), text_halign = text.align_right)
            f_set_row(panel, 9, "Follow Rate", followText, followCol, theme, panelSize)
            f_set_row(panel, 10, "Hold Rate", holdText, holdCol, theme, panelSize)
            f_set_row(panel, 11, "React Rate", reactText, reactCol, theme, panelSize)
            f_set_row(panel, 12, "Flip Rate", flipText, flipCol, theme, panelSize)
    else
        table.clear(panel, 0, 0, 1, panelRowCount - 1)

// -------------------------------------------------
// Alerts
// -------------------------------------------------
alertcondition(alertExposureStates and balancedEvent, title = "Balanced Exposure", message = "Risk Exposure Compass: exposure moved into a balanced risk state. This is an attention marker, not a trade instruction.")
alertcondition(alertExposureStates and stretchedEvent, title = "Stretched Risk", message = "Risk Exposure Compass: exposure moved into a stretched-risk state. Review context before acting.")
alertcondition(alertExposureStates and blockedEvent, title = "Target Room Blocked", message = "Risk Exposure Compass: target room is blocked or too limited for clean exposure review.")
alertcondition(alertExposureStates and watchEvent, title = "Exposure Watch", message = "Risk Exposure Compass: exposure moved into watch state and needs broader chart context.")
alertcondition(alertExposureStates and resetEvent, title = "Exposure Reset", message = "Risk Exposure Compass: exposure reset into early or unclear context.")

if confirmedBar
    lastExposureState := exposureState
````
