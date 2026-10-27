# Impulse Follow-Through Quality [AGPro Series]

- url: https://www.tradingview.com/script/MZ6T50y9-Impulse-Follow-Through-Quality-AGPro-Series/
- type: indicator
- pine_id: PUB;d6cab1192169451388efa2a62db7077d
- version: 4.0

## Description

Impulse Follow-Through Quality [AGPro Series]


🧠 Core Idea

Did the impulse receive enough follow-through to remain valid?


📌 Overview / What it does

Impulse Follow-Through Quality [AGPro Series] is a chart-first momentum expansion planner built to evaluate what happens after a strong impulse candle appears.

Instead of treating every strong candle as a standalone signal, the script starts a follow-through review window and measures whether price extends, pauses constructively, pulls back too deeply, reaches a target-room guide, or crosses a failure rail. These elements are converted into a 0-100 Impulse Quality score and a clear next-action state.

The script produces an impulse highlight, follow-through box, failure rail, measured target guide, compact labels, alerts, and a clean AGPro planning panel. It does not predict continuation, automate trades, or guarantee that momentum will continue.


🎯 Purpose & Design Philosophy

This script was built for traders who want to separate a meaningful impulse from a candle that only looks strong for one bar.

Many momentum tools focus on the impulse itself. The practical question often comes after that candle: does the move attract follow-through, or does it begin to fail? This planner fills that gap by turning the post-impulse phase into a readable decision process.

The design supports a patient review mindset: identify the impulse, watch the follow-through window, evaluate pullback depth, check target room, and review the failure rail before reacting.


⚡ Why This Script Is Different

Most tools focus on strong candles, volume spikes, momentum bursts, or basic continuation labels.

This script does NOT act as a Volume Climax Detector, does NOT rebuild an Institutional Candle Detector, and does NOT reduce the chart to a simple buy/sell momentum signal.

Instead, it evaluates what happens after the impulse. The key output is not the candle itself. The key output is the follow-through quality state: IMPULSE, WAIT FT, FT WATCH, VALID FT, PULLBACK RISK, WEAK FT, FAILED, or TARGET REVIEW.


⚙️ Methodology

1. Context Detection
The script detects qualified bullish or bearish impulse candles using ATR-normalized range, body efficiency, close location, trend context, and participation.

2. Reference Mapping
Once an impulse qualifies, the script maps the impulse origin, follow-through box, failure rail, and target-room guide.

3. Reaction Evaluation
The model evaluates follow-through progress, closes beyond the impulse close, retracement depth, participation support, target room, and whether price crosses the failure rail.

4. Visual Output
The result is displayed through an impulse highlight, centered follow-through box label, failure rail, target guide, compact labels, deterministic alerts, and a premium AGPro panel.


🗺️ How to Read the Chart

Impulse Highlight = the latest qualified impulse leg that starts the review window.

Follow-Through Box = the active planning area between the impulse close and the measured target-room guide. Its label is centered inside the box.

Failure Rail = the practical invalidation reference behind the impulse. It is an analytical line, not a stop order.

Target Guide = a measured target-room reference based on the impulse range.

Labels = compact state markers for impulse start, constructive follow-through, weak follow-through, pullback risk, failure rail review, and target review.

Colors = teal supports constructive long-side follow-through, pink supports short-side or failure context, amber marks review risk, and indigo marks watch states.

Panel = summarizes Impulse Quality, Follow-Through, Pullback Risk, Target Room, and Action.


🚦 Signals & States

• IMPULSE → a qualified impulse candle has started a review window.

• WAIT FT → the impulse exists, but follow-through is not confirmed yet.

• FT WATCH → follow-through conditions are improving but not strong enough for the highest state.

• VALID FT → follow-through quality is constructive according to the rule set.

• PULLBACK RISK → retracement depth is elevated inside the impulse range.

• WEAK FT → the follow-through window is aging without enough progress.

• FAILED → price crossed the failure rail behind the impulse.

• TARGET REVIEW → price reached the measured target-room guide and context should be reviewed.


🔔 Alerts Logic

Alerts can trigger when a new impulse starts, follow-through becomes constructive, follow-through enters watch state, the move weakens, pullback risk rises, price crosses the failure rail, or price reaches the target-room guide.

Each alert is an attention marker. Alerts are not trade instructions, entry commands, exit commands, or automated strategy rules.


🧩 Confluence Logic

The strongest context appears when a clean impulse candle is followed by measurable progress, multiple closes beyond the impulse close, controlled retracement depth, supportive participation, and readable target room.

When these components weaken, the planner can shift toward WAIT FT, FT WATCH, PULLBACK RISK, WEAK FT, or FAILED.


📊 When to Use

• After strong momentum candles where continuation quality matters.

• During trend continuation attempts that need follow-through review.

• After breakout or expansion bars where a one-bar move may be misleading.

• On liquid symbols where ATR, candle structure, and volume behavior are readable.

• When you want a post-impulse planning map instead of another raw momentum signal.


⚠️ When NOT to Use

• Very low-liquidity symbols with unstable candles or unreliable volume.

• Extremely noisy micro-timeframes where impulse candles appear too frequently.

• News-driven spikes where one-bar expansion can distort the model.

• Markets with large gaps that make ATR and failure-rail references less useful.

• Situations where the user expects guaranteed continuation or automated trade signals.


🎛️ Key Inputs

• Follow-Through Side → controls Auto, Long Follow-Through, or Short Follow-Through mode.

• Minimum Impulse ATR → changes how large a candle must be before review begins.

• Minimum Body Efficiency → controls how clean the impulse body must be.

• Minimum Edge Close → controls how near the candle must close to its directional edge.

• Follow-Through Window → controls how many bars are used to judge early continuation.

• Required Progress ATR → defines preferred movement after the impulse close.

• Maximum Pullback Ratio → controls when retracement depth becomes elevated risk.

• Failure Rail Buffer ATR → adjusts the analytical failure rail behind the impulse.

• Visual settings → control the impulse highlight, follow-through box, failure rail, target guide, labels, panel visibility, panel location, theme, and font sizes.


🖥️ Interface & Visual Design

The interface is designed to stay chart-first.

The impulse highlight gives the origin. The follow-through box gives the active planning area. The failure rail and target guide define the practical review frame.

The AGPro panel provides a compact decision summary with a merged blue title row, adjustable panel location, adjustable theme, and adjustable font size.


🧪 Practical Usage Workflow

1. Read the panel Impulse Quality score and Action.

2. Check the impulse highlight and the direction of the follow-through box.

3. Review whether price is extending beyond the impulse close.

4. Compare pullback depth with the failure rail.

5. Use the target guide as a context-review reference, not as a guarantee.

6. Treat alerts as attention markers inside broader analysis.


🔍 Interpretation Guidelines

Think in terms of follow-through quality, not prediction.

A higher score means the impulse has more constructive continuation characteristics according to the script's rule set. A weaker score means the move may be aging, retracing too deeply, lacking progress, or crossing its failure reference.

VALID FT does not mean price must continue. FAILED does not mean the market cannot recover later. The states organize the review process.


🚫 What This Script Is NOT

• Not a prediction engine.

• Not financial advice.

• Not an auto-trading system.

• Not a guaranteed signal tool.

• Not a buy/sell signal service.

• Not a Volume Climax Detector.

• Not an Institutional Candle Detector.

• Not a generic momentum oscillator.


⚠️ Limitations & Transparency

The script is rule-based and depends on recent price action, ATR, candle structure, selected inputs, and volume behavior.

Different timeframes can produce different impulse and follow-through readings. Volatility spikes can temporarily distort the score. Symbols with unreliable volume may produce weaker participation readings.

Outputs should always be interpreted with broader market structure, liquidity, and trader-defined risk controls.


🧠 Market Context Notes

Impulse candles are only useful when the market confirms or rejects them through follow-through.

A clean impulse that receives controlled extension may deserve more attention than a larger candle that immediately retraces. A smaller impulse can also become meaningful when the follow-through window stays organized.


🧾 Use Case Examples

When price prints a strong bullish impulse, closes near the high, then follows through with multiple closes above the impulse close while pullback depth remains controlled, the planner may classify the move as VALID FT.

When an impulse appears but price fails to extend, retraces deeply, or crosses the failure rail, the planner may shift toward WEAK FT, PULLBACK RISK, or FAILED.


🧱 System Philosophy

AGPro planning tools are designed to help traders evaluate context before reacting.

This script follows that philosophy by turning impulse follow-through into a structured planning question: did the move receive enough confirmation, progress, and risk clarity to remain worth reviewing?


🔐 Non-Promise Statement

No indicator can guarantee continuation, reversal, breakout success, or outcome.

This tool provides structured visual context and rule-based attention markers. It does not provide certainty.


📉 Risk Disclosure

Trading involves risk.

Market conditions can change quickly, and no script can remove uncertainty.

Users are responsible for their own analysis, risk management, position sizing, and trading decisions.

This script is for educational and analytical use only and does not provide financial advice.


📚 Educational Note

Use the planner to study how strong candles behave after they appear, how follow-through quality changes across timeframes, and how pullback depth affects the readability of momentum continuation.

## Source Code

````pine
// -------------------------------------------------
// Impulse Follow-Through Quality [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 1.3
//
// Impulse Follow-Through Quality is a chart-first momentum expansion planner
// that evaluates whether a strong impulse candle receives enough continuation
// to remain valid. It studies impulse size, body efficiency, follow-through
// progress, participation, retracement depth, target room, and a practical
// failure rail to produce a 0-100 quality score, a clear next-action state,
// and an independent follow-through proof for every qualified impulse. Version
// 1.3 hardens terminal outcomes, proof sampling, and chart-plan readability.
// This is an analytical visualization tool, not a prediction engine, not an
// automated strategy, and not financial advice.
// -------------------------------------------------

//@version=6
indicator("Impulse Follow-Through Quality [AGPro Series]",
     shorttitle = "AG IFQ",
     overlay = true,
     max_labels_count = 100,
     max_boxes_count = 8,
     max_lines_count = 12)

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
darkText      = color.rgb(15, 23, 42)

// -------------------------------------------------
// Tooltips
// -------------------------------------------------
ttSide = "Selects the follow-through side. Auto reads the latest qualified impulse. Manual modes restrict the planner to long-side or short-side impulse follow-through."
ttConfirm = "When enabled, impulse registration, labels, and alerts are confirmed only after the bar closes. This keeps public chart behavior stable."
ttAtrLen = "ATR length used to normalize impulse size, label offsets, failure rail distance, and target-room measurements."
ttFast = "Fast EMA used for context alignment. It does not create buy or sell signals."
ttSlow = "Slow EMA used for context alignment and trend-quality scoring."
ttSlope = "Number of bars used to evaluate whether the slow EMA is supporting the impulse direction."
ttVolume = "Volume baseline used to judge participation behind the impulse and the early follow-through. Volume is a support component, not the main trigger."
ttImpulseAtr = "Minimum true-range size, measured in ATR, required before a candle can qualify as an impulse."
ttBody = "Minimum body efficiency required for impulse qualification. Higher values require cleaner candle bodies."
ttClose = "Minimum close location near the impulse edge. Bullish impulses should close near the high; bearish impulses should close near the low."
ttOversized = "ATR size where an impulse becomes potentially overextended. This helps avoid treating every extreme candle as clean follow-through quality."
ttClimax = "Volume ratio where participation can become climax-like. The script uses this to avoid becoming a volume climax detector."
ttMinImpulse = "Minimum 0-100 impulse quality required before the planner starts a follow-through window."
ttImpulseCooldown = "Minimum bars between new impulse review windows. This prevents the planner from replacing the active impulse too aggressively."
ttFollow = "Number of bars used to evaluate whether the impulse receives constructive follow-through."
ttTrack = "Maximum bars the latest impulse remains active on the panel and visual guides."
ttRequired = "ATR-normalized progress preferred during the follow-through window."
ttCloses = "Minimum number of closes beyond the impulse close preferred before the strongest follow-through state can appear."
ttPullback = "Maximum retracement depth allowed inside the impulse range before pullback risk becomes elevated."
ttFailure = "ATR buffer beyond the impulse extreme used to place the failure rail. This is an analytical reference, not a stop recommendation."
ttValid = "Minimum 0-100 score required for Valid FT state. Valid FT means follow-through quality is constructive, not that a trade should be taken."
ttWatch = "Minimum 0-100 score required for FT Watch state. FT Watch means the impulse is still under review."
ttImpulseBox = "Highlights the latest qualified impulse leg so the follow-through map has a clear origin."
ttFollowBox = "Shows the active follow-through box from the impulse close toward the measured target guide. The state badge is centered in the zone for contrast-safe reading."
ttFailureRail = "Shows the failure rail behind the impulse. A cross of this rail triggers a review alert."
ttTargetGuide = "Shows a measured target-room guide based on the impulse range. It is a planning reference only."
ttTargetMultiple = "Projection multiple applied to the impulse range for the target-room guide."
ttProjection = "Number of bars projected to the right for follow-through guides."
ttBoxOpacity = "Transparency for the follow-through box. Higher values make the zone lighter."
ttEma = "Shows light context EMAs for trend alignment. Disable if you want the cleanest possible chart."
ttMarkers = "Shows small diamond and circle markers under key labels. Disabled by default because the labels already carry the primary state information."
ttLabels = "Shows compact impulse, follow-through, pullback-risk, failure, and target-review labels. Labels are offset away from candles."
ttContext = "Adds sparse context labels during active follow-through windows. Disabled by default for a cleaner publication view."
ttCooldown = "Minimum bars between event labels. Higher values reduce label density."
ttContextSpacing = "Minimum bars between sparse context labels during ongoing follow-through states."
ttMaxLabels = "Maximum number of chart labels retained. Older labels are removed first to preserve performance."
ttLabelOffset = "ATR-based vertical offset that keeps labels above or below candles."
ttLabelScore = "Adds the 0-100 quality score to chart labels."
ttLabelSize = "Font size for all chart labels, right-edge tags, and centered zone badges. Normal is the recommended publication default."
ttShowPanel = "Shows or hides the AGPro planning panel. It is shown by default for public-release readability."
ttPanelLocation = "Moves the panel to the preferred chart location."
ttPanelTheme = "Switches the panel between AGPro dark and clean light themes."
ttPanelFont = "Font size for the AGPro panel. Normal is the recommended publication default."

// -------------------------------------------------
// Inputs
// -------------------------------------------------
groupEngine = "Impulse Engine"
sideMode = input.string("Auto", "Follow-Through Side", options = ["Auto", "Long Follow-Through", "Short Follow-Through"], group = groupEngine, tooltip = ttSide)
confirmOnClose = input.bool(true, "Confirm On Bar Close", group = groupEngine, tooltip = ttConfirm)
atrLen = input.int(14, "ATR Length", minval = 2, maxval = 100, group = groupEngine, tooltip = ttAtrLen)
fastEmaLen = input.int(21, "Fast Context EMA", minval = 1, maxval = 200, group = groupEngine, tooltip = ttFast)
slowEmaLen = input.int(55, "Slow Context EMA", minval = 2, maxval = 300, group = groupEngine, tooltip = ttSlow)
slopeBars = input.int(5, "Trend Slope Bars", minval = 1, maxval = 30, group = groupEngine, tooltip = ttSlope)
volumeLen = input.int(34, "Volume Support Length", minval = 5, maxval = 200, group = groupEngine, tooltip = ttVolume)

groupImpulse = "Impulse Qualification"
minimumImpulseAtr = input.float(1.25, "Minimum Impulse ATR", minval = 0.40, maxval = 5.00, step = 0.05, group = groupImpulse, tooltip = ttImpulseAtr)
minimumBodyEfficiency = input.float(0.58, "Minimum Body Efficiency", minval = 0.20, maxval = 0.95, step = 0.01, group = groupImpulse, tooltip = ttBody)
minimumCloseLocation = input.float(0.68, "Minimum Edge Close", minval = 0.50, maxval = 0.98, step = 0.01, group = groupImpulse, tooltip = ttClose)
oversizedImpulseAtr = input.float(3.10, "Oversized Impulse ATR", minval = 1.20, maxval = 8.00, step = 0.05, group = groupImpulse, tooltip = ttOversized)
climaxVolumeRatio = input.float(3.00, "Climax Volume Ratio", minval = 1.20, maxval = 8.00, step = 0.05, group = groupImpulse, tooltip = ttClimax)
minimumImpulseScore = input.int(58, "Minimum Impulse Score", minval = 20, maxval = 95, group = groupImpulse, tooltip = ttMinImpulse)
newImpulseCooldown = input.int(10, "New Impulse Cooldown", minval = 1, maxval = 80, group = groupImpulse, tooltip = ttImpulseCooldown)

groupScoring = "Follow-Through Scoring"
followThroughBars = input.int(9, "Follow-Through Window", minval = 2, maxval = 40, group = groupScoring, tooltip = ttFollow)
trackingBars = input.int(22, "Active Tracking Bars", minval = 5, maxval = 80, group = groupScoring, tooltip = ttTrack)
requiredProgressAtr = input.float(0.70, "Required Progress ATR", minval = 0.10, maxval = 4.00, step = 0.05, group = groupScoring, tooltip = ttRequired)
minimumFollowCloses = input.int(2, "Minimum Follow-Through Closes", minval = 1, maxval = 10, group = groupScoring, tooltip = ttCloses)
maximumPullbackRatio = input.float(0.56, "Maximum Pullback Ratio", minval = 0.10, maxval = 1.50, step = 0.01, group = groupScoring, tooltip = ttPullback)
failureBufferAtr = input.float(0.20, "Failure Rail Buffer ATR", minval = 0.00, maxval = 2.00, step = 0.05, group = groupScoring, tooltip = ttFailure)
validThreshold = input.int(72, "Valid FT Threshold", minval = 40, maxval = 95, group = groupScoring, tooltip = ttValid)
watchThreshold = input.int(55, "FT Watch Threshold", minval = 20, maxval = 90, group = groupScoring, tooltip = ttWatch)

groupVisual = "Chart Visuals"
showImpulseHighlight = input.bool(true, "Show Impulse Highlight", group = groupVisual, tooltip = ttImpulseBox)
showFollowThroughBox = input.bool(true, "Show Follow-Through Box", group = groupVisual, tooltip = ttFollowBox)
showFailureRail = input.bool(true, "Show Failure Rail", group = groupVisual, tooltip = ttFailureRail)
showTargetGuide = input.bool(true, "Show Target Guide", group = groupVisual, tooltip = ttTargetGuide)
targetRangeMultiple = input.float(1.20, "Target Guide Range Multiple", minval = 0.25, maxval = 4.00, step = 0.05, group = groupVisual, tooltip = ttTargetMultiple)
projectionBars = input.int(36, "Projection Bars", minval = 8, maxval = 160, group = groupVisual, tooltip = ttProjection)
boxTransparency = input.int(89, "Follow-Through Box Transparency", minval = 72, maxval = 96, group = groupVisual, tooltip = ttBoxOpacity)
showContextEma = input.bool(true, "Show Context EMAs", group = groupVisual, tooltip = ttEma)
showSmallMarkers = input.bool(false, "Show Small Markers", group = groupVisual, tooltip = ttMarkers)

groupLabels = "Labels"
showEventLabels = input.bool(true, "Show Event Labels", group = groupLabels, tooltip = ttLabels)
showContextLabels = input.bool(false, "Show Sparse Context Labels", group = groupLabels, tooltip = ttContext)
labelCooldownBars = input.int(18, "Label Cooldown Bars", minval = 1, maxval = 120, group = groupLabels, tooltip = ttCooldown)
contextSpacingBars = input.int(42, "Context Label Spacing", minval = 6, maxval = 240, group = groupLabels, tooltip = ttContextSpacing)
maxVisibleLabels = input.int(6, "Max Visible Labels", minval = 4, maxval = 80, group = groupLabels, tooltip = ttMaxLabels)
labelOffsetAtr = input.float(0.88, "Label Offset ATR", minval = 0.10, maxval = 3.00, step = 0.05, group = groupLabels, tooltip = ttLabelOffset)
showLabelScore = input.bool(true, "Show Label Score", group = groupLabels, tooltip = ttLabelScore)
labelSizeInput = input.string("Normal", "Label Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = groupLabels, tooltip = ttLabelSize)

groupPanel = "Panel"
showPanel = input.bool(true, "Show Panel", group = groupPanel, tooltip = ttShowPanel)
panelLocationInput = input.string("Top Right", "Panel Location", options = ["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], group = groupPanel, tooltip = ttPanelLocation)
panelThemeInput = input.string("Dark", "Panel Theme", options = ["Dark", "Light"], group = groupPanel, tooltip = ttPanelTheme)
panelFontSizeInput = input.string("Normal", "Panel Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = groupPanel, tooltip = ttPanelFont)

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
        "Middle Right" => position.middle_right
        "Bottom Left" => position.bottom_left
        "Bottom Center" => position.bottom_center
        "Bottom Right" => position.bottom_right
        => position.top_right

f_panel_bg(string theme) =>
    theme == "Light" ? color.rgb(248, 250, 252) : panelBg

f_panel_border(string theme) =>
    theme == "Light" ? color.rgb(148, 163, 184) : panelBorder

f_panel_label(string theme) =>
    theme == "Light" ? color.rgb(71, 85, 105) : panelLabelCol

f_panel_value(string theme) =>
    theme == "Light" ? color.rgb(15, 23, 42) : panelValueCol

f_row_bg(string theme, int row) =>
    evenRow = row % 2 == 0
    theme == "Light" ? (evenRow ? color.rgb(241, 245, 249) : color.rgb(248, 250, 252)) : (evenRow ? color.rgb(20, 31, 52) : panelBg)

f_text_on(color bgColor) =>
    bright = (color.r(bgColor) * 299 + color.g(bgColor) * 587 + color.b(bgColor) * 114) / 1000
    bright >= 145 ? darkText : headerText

f_state_color(string stateText) =>
    switch stateText
        "Valid FT" => bullColor
        "FT Watch" => accentColor
        "Impulse" => accentColor
        "Wait FT" => neutralColor
        "Pullback Risk" => neutralColor
        "Weak FT" => bearColor
        "Failed" => bearColor
        "Target Review" => bullColor
        => panelLabelCol

f_trend_score(int dir, float price, float fast, float slow, float slopeValue, float atrValue) =>
    baseScore = dir == 1 ? (price >= slow ? 42.0 : 16.0) : (price <= slow ? 42.0 : 16.0)
    stackScore = dir == 1 ? (fast >= slow ? 34.0 : 0.0) : (fast <= slow ? 34.0 : 0.0)
    slopeAtr = math.abs(slopeValue) / math.max(atrValue, syminfo.mintick)
    slopeScore = dir == 1 ? (slopeValue >= 0.0 ? f_norm_high_good(slopeAtr, 0.01, 0.30) * 0.24 : 0.0) : (slopeValue <= 0.0 ? f_norm_high_good(slopeAtr, 0.01, 0.30) * 0.24 : 0.0)
    f_clamp(baseScore + stackScore + slopeScore, 0.0, 100.0)

f_trim_labels(array<label> labels, int maxCount) =>
    while array.size(labels) > maxCount
        oldLabel = array.shift(labels)
        if not na(oldLabel)
            label.delete(oldLabel)

f_quality_band(int score) =>
    score >= 82 ? "STRONG" : score >= 70 ? "CONSTRUCTIVE" : score >= 55 ? "MIXED" : "WEAK"

f_set_row(table target, int row, string leftText, string rightText, color rightColor, string theme, string fontSize, color rightBg) =>
    rowBg = f_row_bg(theme, row)
    table.cell(target, 0, row, leftText, text_color = f_panel_label(theme), bgcolor = rowBg, text_size = f_label_size(fontSize), text_halign = text.align_left)
    table.cell(target, 1, row, rightText, text_color = rightColor, bgcolor = rightBg, text_size = f_label_size(fontSize), text_halign = text.align_right)

f_panel_workflow(string stateText) =>
    stateText == "Valid FT" ? "Track Follow-Through" :
     stateText == "FT Watch" or stateText == "Wait FT" or stateText == "Impulse" ? "Track Impulse" :
     stateText == "Pullback Risk" ? "Review Pullback" :
     stateText == "Target Review" ? "Review Target" :
     stateText == "Failed" or stateText == "Weak FT" ? "Review Failure" :
     "Standby"

// -------------------------------------------------
// Core measurements
// -------------------------------------------------
atr = ta.atr(atrLen)
safeAtr = math.max(nz(atr, ta.tr(true)), syminfo.mintick)
barRange = math.max(high - low, syminfo.mintick)
bodySize = math.abs(close - open)
bodyEfficiency = bodySize / barRange
closeLocation = (close - low) / barRange
bullEdgeClose = closeLocation
bearEdgeClose = 1.0 - closeLocation
impulseAtr = barRange / safeAtr

fastEma = ta.ema(close, fastEmaLen)
slowEma = ta.ema(close, slowEmaLen)
trendSlope = slowEma - nz(slowEma[slopeBars], slowEma)

volumeBase = ta.sma(volume, volumeLen)
volumeRatio = not na(volumeBase) and volumeBase > 0.0 and not na(volume) ? volume / volumeBase : 1.0
volumeScore = f_peak_score(volumeRatio, 0.65, 1.35, climaxVolumeRatio)

impulseSizeScore = f_peak_score(impulseAtr, minimumImpulseAtr * 0.70, minimumImpulseAtr + 0.75, oversizedImpulseAtr)
bodyScore = f_norm_high_good(bodyEfficiency, minimumBodyEfficiency * 0.85, 0.92)
bullCloseScore = f_norm_high_good(bullEdgeClose, minimumCloseLocation * 0.85, 0.95)
bearCloseScore = f_norm_high_good(bearEdgeClose, minimumCloseLocation * 0.85, 0.95)
bullTrendScore = f_trend_score(1, close, fastEma, slowEma, trendSlope, safeAtr)
bearTrendScore = f_trend_score(-1, close, fastEma, slowEma, trendSlope, safeAtr)

bullImpulseScore = f_clamp(impulseSizeScore * 0.30 + bodyScore * 0.24 + bullCloseScore * 0.22 + volumeScore * 0.10 + bullTrendScore * 0.14, 0.0, 100.0)
bearImpulseScore = f_clamp(impulseSizeScore * 0.30 + bodyScore * 0.24 + bearCloseScore * 0.22 + volumeScore * 0.10 + bearTrendScore * 0.14, 0.0, 100.0)

allowBull = sideMode != "Short Follow-Through"
allowBear = sideMode != "Long Follow-Through"
bullQualified = allowBull and close > open and impulseAtr >= minimumImpulseAtr and bodyEfficiency >= minimumBodyEfficiency and bullEdgeClose >= minimumCloseLocation and bullImpulseScore >= minimumImpulseScore
bearQualified = allowBear and close < open and impulseAtr >= minimumImpulseAtr and bodyEfficiency >= minimumBodyEfficiency and bearEdgeClose >= minimumCloseLocation and bearImpulseScore >= minimumImpulseScore

candidateDir = bullQualified ? 1 : bearQualified ? -1 : 0
candidateScore = candidateDir == 1 ? bullImpulseScore : candidateDir == -1 ? bearImpulseScore : 0.0
confirmedBar = not confirmOnClose or barstate.isconfirmed

// -------------------------------------------------
// Active impulse state
// -------------------------------------------------
var int activeDir = 0
var int activeStartBar = na
var float activeHigh = na
var float activeLow = na
var float activeClose = na
var float activeRange = na
var float activeAtr = na
var float activeBestPrice = na
var float activeWorstPullback = 0.0
var float activeImpulseScore = na
var float activeBestVolumeScore = na
var float activeVolumeRatio = na
var int activeFollowCloses = 0
var bool activeFailed = false
var bool activeTargetReached = false
var float activeResolutionClose = na
var int lastImpulseBar = na

impulseEvent = confirmedBar and candidateDir != 0 and (na(lastImpulseBar) or bar_index - lastImpulseBar >= newImpulseCooldown)

if impulseEvent
    activeDir := candidateDir
    activeStartBar := bar_index
    activeHigh := high
    activeLow := low
    activeClose := close
    activeRange := barRange
    activeAtr := safeAtr
    activeBestPrice := candidateDir == 1 ? high : low
    activeWorstPullback := 0.0
    activeImpulseScore := candidateScore
    activeBestVolumeScore := volumeScore
    activeVolumeRatio := volumeRatio
    activeFollowCloses := 0
    activeFailed := false
    activeTargetReached := false
    activeResolutionClose := na
    lastImpulseBar := bar_index

hasActiveImpulse = activeDir != 0 and not na(activeStartBar)
barsActive = hasActiveImpulse ? bar_index - activeStartBar : 0
activeWindow = hasActiveImpulse and barsActive <= trackingBars

failureRail = hasActiveImpulse ? (activeDir == 1 ? activeLow - activeAtr * failureBufferAtr : activeHigh + activeAtr * failureBufferAtr) : na
targetGuide = hasActiveImpulse ? activeClose + activeDir * activeRange * targetRangeMultiple : na

if hasActiveImpulse and bar_index > activeStartBar and barsActive <= trackingBars and not activeFailed and not activeTargetReached
    activeBestPrice := activeDir == 1 ? math.max(activeBestPrice, high) : math.min(activeBestPrice, low)
    pullbackNow = activeDir == 1 ? math.max(activeClose - low, 0.0) / activeRange : math.max(high - activeClose, 0.0) / activeRange
    activeWorstPullback := math.max(activeWorstPullback, pullbackNow)
    activeBestVolumeScore := math.max(activeBestVolumeScore, volumeScore)
    activeVolumeRatio := math.max(activeVolumeRatio, volumeRatio)
    if barsActive <= followThroughBars
        followClose = activeDir == 1 ? close > activeClose : close < activeClose
        if followClose and confirmedBar
            activeFollowCloses += 1
    failHit = activeDir == 1 ? close <= failureRail : close >= failureRail
    targetHit = activeDir == 1 ? high >= targetGuide : low <= targetGuide
    if confirmedBar
        if failHit
            activeFailed := true
            activeResolutionClose := close
        else if targetHit
            activeTargetReached := true
            activeResolutionClose := close

evaluationClose = activeFailed or activeTargetReached ? nz(activeResolutionClose, close) : close
followProgressAtr = hasActiveImpulse ? (activeDir == 1 ? math.max(activeBestPrice - activeClose, 0.0) / activeAtr : math.max(activeClose - activeBestPrice, 0.0) / activeAtr) : na
targetRoomAtr = hasActiveImpulse ? (targetGuide - evaluationClose) * activeDir / activeAtr : na
pullbackScore = hasActiveImpulse ? f_norm_low_good(activeWorstPullback, 0.08, maximumPullbackRatio) : 0.0
progressScore = hasActiveImpulse ? f_norm_high_good(followProgressAtr, requiredProgressAtr * 0.25, requiredProgressAtr * 1.65) : 0.0
closeCountScore = hasActiveImpulse ? f_norm_high_good(activeFollowCloses, 1.0, minimumFollowCloses) : 0.0
followThroughScore = f_clamp(progressScore * 0.50 + closeCountScore * 0.30 + pullbackScore * 0.20, 0.0, 100.0)
targetRoomScore = hasActiveImpulse ? f_norm_high_good(targetRoomAtr, 0.10, 1.40) : 0.0
rawQuality = hasActiveImpulse ? activeImpulseScore * 0.36 + followThroughScore * 0.38 + activeBestVolumeScore * 0.10 + pullbackScore * 0.08 + targetRoomScore * 0.08 : 0.0
cappedQuality = activeFailed ? math.min(rawQuality, 38.0) : barsActive > followThroughBars and followThroughScore < 45.0 ? math.min(rawQuality, 52.0) : rawQuality
qualityScore = activeWindow ? int(math.round(f_clamp(cappedQuality, 0.0, 100.0))) : 0

pullbackRisk = not activeWindow ? "n/a" : activeWorstPullback >= maximumPullbackRatio ? "Elevated" : activeWorstPullback >= maximumPullbackRatio * 0.65 ? "Moderate" : "Low"
impulseState = "Wait"
if activeWindow
    if activeFailed
        impulseState := "Failed"
    else if barsActive == 0
        impulseState := "Impulse"
    else if activeTargetReached
        impulseState := "Target Review"
    else if activeWorstPullback >= maximumPullbackRatio
        impulseState := "Pullback Risk"
    else if qualityScore >= validThreshold and followThroughScore >= 55.0 and activeFollowCloses >= minimumFollowCloses
        impulseState := "Valid FT"
    else if qualityScore >= watchThreshold
        impulseState := "FT Watch"
    else if barsActive > followThroughBars
        impulseState := "Weak FT"
    else
        impulseState := "Wait FT"

actionState = "Wait Impulse"
if impulseState == "Valid FT"
    actionState := "Review Continuation"
else if impulseState == "FT Watch"
    actionState := "Wait Follow-Through"
else if impulseState == "Impulse"
    actionState := "Observe Next Bars"
else if impulseState == "Wait FT"
    actionState := "Wait Confirmation"
else if impulseState == "Pullback Risk"
    actionState := "Review Pullback"
else if impulseState == "Weak FT"
    actionState := "Review Weakness"
else if impulseState == "Failed"
    actionState := "Review Failure Rail"
else if impulseState == "Target Review"
    actionState := "Review Target Room"

stateColor = f_state_color(impulseState)
dirColor = activeDir == 1 ? bullColor : bearColor
dirText = not activeWindow ? "n/a" : activeDir == 1 ? "Long" : "Short"

// -------------------------------------------------
// Follow-through rate proof (Confirm Rate)
// -------------------------------------------------
var int ftTotal = 0
var int ftGood = 0
var array<int> proofDirs = array.new<int>()
var array<float> proofCloses = array.new<float>()
var array<float> proofAtrs = array.new<float>()
var array<float> proofRanges = array.new<float>()
var array<float> proofImpulseScores = array.new<float>()
var array<float> proofTargets = array.new<float>()
var array<float> proofRails = array.new<float>()
var array<float> proofBestPrices = array.new<float>()
var array<float> proofBestVolumeScores = array.new<float>()
var array<float> proofWorstPullbacks = array.new<float>()
var array<int> proofCloseCounts = array.new<int>()
var array<int> proofStartBars = array.new<int>()

if barstate.isconfirmed
    proofCountAtOpen = array.size(proofDirs)
    if proofCountAtOpen > 0
        for step = 0 to proofCountAtOpen - 1
            i = proofCountAtOpen - 1 - step
            proofDir = array.get(proofDirs, i)
            proofClose = array.get(proofCloses, i)
            proofAtr = array.get(proofAtrs, i)
            proofRange = array.get(proofRanges, i)
            proofImpulseScore = array.get(proofImpulseScores, i)
            proofTarget = array.get(proofTargets, i)
            proofRail = array.get(proofRails, i)
            proofBest = array.get(proofBestPrices, i)
            proofBestVolumeScore = array.get(proofBestVolumeScores, i)
            proofWorstPullback = array.get(proofWorstPullbacks, i)
            proofClosesCount = array.get(proofCloseCounts, i)
            proofStart = array.get(proofStartBars, i)
            if bar_index > proofStart
                proofBest := proofDir == 1 ? math.max(proofBest, high) : math.min(proofBest, low)
                proofPullbackNow = proofDir == 1 ? math.max(proofClose - low, 0.0) / proofRange : math.max(high - proofClose, 0.0) / proofRange
                proofWorstPullback := math.max(proofWorstPullback, proofPullbackNow)
                proofBestVolumeScore := math.max(proofBestVolumeScore, volumeScore)
                if bar_index - proofStart <= followThroughBars and (proofDir == 1 ? close > proofClose : close < proofClose)
                    proofClosesCount += 1
                proofProgress = proofDir == 1 ? math.max(proofBest - proofClose, 0.0) / proofAtr : math.max(proofClose - proofBest, 0.0) / proofAtr
                proofFailed = proofDir == 1 ? close <= proofRail : close >= proofRail
                proofTargetHit = proofDir == 1 ? high >= proofTarget : low <= proofTarget
                proofPullbackScore = f_norm_low_good(proofWorstPullback, 0.08, maximumPullbackRatio)
                proofProgressScore = f_norm_high_good(proofProgress, requiredProgressAtr * 0.25, requiredProgressAtr * 1.65)
                proofCloseCountScore = f_norm_high_good(proofClosesCount, 1.0, minimumFollowCloses)
                proofFollowScore = f_clamp(proofProgressScore * 0.50 + proofCloseCountScore * 0.30 + proofPullbackScore * 0.20, 0.0, 100.0)
                proofTargetRoomAtr = (proofTarget - close) * proofDir / proofAtr
                proofTargetRoomScore = f_norm_high_good(proofTargetRoomAtr, 0.10, 1.40)
                proofQuality = f_clamp(proofImpulseScore * 0.36 + proofFollowScore * 0.38 + proofBestVolumeScore * 0.10 + proofPullbackScore * 0.08 + proofTargetRoomScore * 0.08, 0.0, 100.0)
                proofValid = proofWorstPullback < maximumPullbackRatio and proofQuality >= validThreshold and proofFollowScore >= 55.0 and proofClosesCount >= minimumFollowCloses
                proofTimedOut = bar_index - proofStart >= trackingBars
                if proofFailed or proofTargetHit or proofValid or proofTimedOut
                    ftTotal += 1
                    if not proofFailed and (proofTargetHit or proofValid)
                        ftGood += 1
                    array.remove(proofDirs, i)
                    array.remove(proofCloses, i)
                    array.remove(proofAtrs, i)
                    array.remove(proofRanges, i)
                    array.remove(proofImpulseScores, i)
                    array.remove(proofTargets, i)
                    array.remove(proofRails, i)
                    array.remove(proofBestPrices, i)
                    array.remove(proofBestVolumeScores, i)
                    array.remove(proofWorstPullbacks, i)
                    array.remove(proofCloseCounts, i)
                    array.remove(proofStartBars, i)
                else
                    array.set(proofBestPrices, i, proofBest)
                    array.set(proofBestVolumeScores, i, proofBestVolumeScore)
                    array.set(proofWorstPullbacks, i, proofWorstPullback)
                    array.set(proofCloseCounts, i, proofClosesCount)
    if impulseEvent
        array.push(proofDirs, activeDir)
        array.push(proofCloses, activeClose)
        array.push(proofAtrs, activeAtr)
        array.push(proofRanges, activeRange)
        array.push(proofImpulseScores, activeImpulseScore)
        array.push(proofTargets, targetGuide)
        array.push(proofRails, failureRail)
        array.push(proofBestPrices, activeDir == 1 ? activeHigh : activeLow)
        array.push(proofBestVolumeScores, activeBestVolumeScore)
        array.push(proofWorstPullbacks, 0.0)
        array.push(proofCloseCounts, 0)
        array.push(proofStartBars, bar_index)

followThroughRate = ftTotal > 0 ? ftGood / ftTotal * 100.0 : na

// -------------------------------------------------
// Visual guides
// -------------------------------------------------
plot(showContextEma ? fastEma : na, "Fast Context EMA", color = color.new(panelLabelCol, 84), linewidth = 1)
plot(showContextEma ? slowEma : na, "Slow Context EMA", color = color.new(panelLabelCol, 78), linewidth = 1)

var box impulseBox = na
var box followBox = na
var label followBoxLabel = na
var line railLine = na
var line targetLine = na
var label railTag = na
var label targetTag = na

visualRight = activeWindow ? bar_index + projectionBars : bar_index
followTop = activeWindow ? math.max(activeClose, targetGuide) : na
followBottom = activeWindow ? math.min(activeClose, targetGuide) : na
guideColor = impulseState == "Failed" or impulseState == "Weak FT" ? bearColor : impulseState == "Pullback Risk" ? neutralColor : impulseState == "FT Watch" or impulseState == "Wait FT" or impulseState == "Impulse" ? accentColor : dirColor
badgeDirection = activeDir == 1 ? "LONG" : "SHORT"
zoneText = activeWindow ? badgeDirection + " | " + str.upper(impulseState) + "\nQ " + str.tostring(qualityScore) + " | FT " + str.tostring(followProgressAtr, "#.00") + " ATR" : ""
zoneLeft = activeWindow ? math.min(visualRight, bar_index + 2) : bar_index
zoneX = activeWindow ? int(math.round((zoneLeft + visualRight) / 2.0)) : bar_index
zoneY = activeWindow ? (followTop + followBottom) * 0.5 : close

if showImpulseHighlight and activeWindow
    if na(impulseBox)
        impulseBox := box.new(left = activeStartBar, top = activeHigh, right = activeStartBar + 1, bottom = activeLow, xloc = xloc.bar_index, bgcolor = color.new(dirColor, 84), border_color = color.new(dirColor, 18), border_width = 1)
    else
        box.set_left(impulseBox, activeStartBar)
        box.set_right(impulseBox, activeStartBar + 1)
        box.set_top(impulseBox, activeHigh)
        box.set_bottom(impulseBox, activeLow)
        box.set_bgcolor(impulseBox, color.new(dirColor, 84))
        box.set_border_color(impulseBox, color.new(dirColor, 18))
else
    if not na(impulseBox)
        box.delete(impulseBox)
        impulseBox := na

if showFollowThroughBox and activeWindow
    if na(followBox)
        followBox := box.new(left = activeStartBar, top = followTop, right = visualRight, bottom = followBottom, xloc = xloc.bar_index, bgcolor = color.new(guideColor, boxTransparency), border_color = color.new(guideColor, 32), border_width = 1)
    else
        box.set_left(followBox, activeStartBar)
        box.set_right(followBox, visualRight)
        box.set_top(followBox, followTop)
        box.set_bottom(followBox, followBottom)
        box.set_bgcolor(followBox, color.new(guideColor, boxTransparency))
        box.set_border_color(followBox, color.new(guideColor, 32))
    if na(followBoxLabel)
        followBoxLabel := label.new(zoneX, zoneY, zoneText, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_center, color = color.new(guideColor, 0), textcolor = f_text_on(guideColor), size = f_label_size(labelSizeInput), textalign = text.align_center, tooltip = "Centered follow-through zone badge. It summarizes the active state and quality score without acting as a trade instruction.")
    else
        label.set_xy(followBoxLabel, zoneX, zoneY)
        label.set_text(followBoxLabel, zoneText)
        label.set_color(followBoxLabel, color.new(guideColor, 0))
        label.set_textcolor(followBoxLabel, f_text_on(guideColor))
        label.set_size(followBoxLabel, f_label_size(labelSizeInput))
else
    if not na(followBox)
        box.delete(followBox)
        followBox := na
    if not na(followBoxLabel)
        label.delete(followBoxLabel)
        followBoxLabel := na

if showFailureRail and activeWindow
    railColor = activeFailed ? bearColor : neutralColor
    if na(railLine)
        railLine := line.new(activeStartBar, failureRail, visualRight, failureRail, xloc = xloc.bar_index, extend = extend.none, color = railColor, width = 2, style = line.style_dashed)
    else
        line.set_xy1(railLine, activeStartBar, failureRail)
        line.set_xy2(railLine, visualRight, failureRail)
        line.set_color(railLine, railColor)
    if na(railTag)
        railTag := label.new(visualRight + 1, failureRail, "", xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = railColor, textcolor = f_text_on(railColor), size = f_label_size(labelSizeInput))
    label.set_xy(railTag, visualRight + 1, failureRail)
    label.set_text(railTag, "Failure " + str.tostring(failureRail, format.mintick))
    label.set_color(railTag, railColor)
    label.set_textcolor(railTag, f_text_on(railColor))
    label.set_size(railTag, f_label_size(labelSizeInput))
else
    if not na(railLine)
        line.delete(railLine)
        railLine := na
    if not na(railTag)
        label.delete(railTag)
        railTag := na

if showTargetGuide and activeWindow
    targetColor = activeTargetReached ? bullColor : color.new(accentColor, 10)
    if na(targetLine)
        targetLine := line.new(activeStartBar, targetGuide, visualRight, targetGuide, xloc = xloc.bar_index, extend = extend.none, color = targetColor, width = 1, style = line.style_dotted)
    else
        line.set_xy1(targetLine, activeStartBar, targetGuide)
        line.set_xy2(targetLine, visualRight, targetGuide)
        line.set_color(targetLine, targetColor)
    if na(targetTag)
        targetTag := label.new(visualRight + 1, targetGuide, "", xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = targetColor, textcolor = f_text_on(targetColor), size = f_label_size(labelSizeInput))
    label.set_xy(targetTag, visualRight + 1, targetGuide)
    label.set_text(targetTag, "Target " + str.tostring(targetGuide, format.mintick))
    label.set_color(targetTag, targetColor)
    label.set_textcolor(targetTag, f_text_on(targetColor))
    label.set_size(targetTag, f_label_size(labelSizeInput))
else
    if not na(targetLine)
        line.delete(targetLine)
        targetLine := na
    if not na(targetTag)
        label.delete(targetTag)
        targetTag := na

// -------------------------------------------------
// Labels and markers
// -------------------------------------------------
var int lastLabelBar = na
var string lastImpulseState = ""
var array<label> eventLabels = array.new<label>()

validEvent = confirmedBar and impulseState == "Valid FT" and lastImpulseState != "Valid FT"
watchEvent = confirmedBar and impulseState == "FT Watch" and lastImpulseState != "FT Watch"
weakEvent = confirmedBar and impulseState == "Weak FT" and lastImpulseState != "Weak FT"
pullbackEvent = confirmedBar and impulseState == "Pullback Risk" and lastImpulseState != "Pullback Risk"
failEvent = confirmedBar and impulseState == "Failed" and lastImpulseState != "Failed"
targetEvent = confirmedBar and impulseState == "Target Review" and lastImpulseState != "Target Review"
labelCooldownReady = na(lastLabelBar) or bar_index - lastLabelBar >= labelCooldownBars
contextReady = na(lastLabelBar) or bar_index - lastLabelBar >= contextSpacingBars
drawContext = showContextLabels and contextReady and activeWindow and (impulseState == "Valid FT" or impulseState == "FT Watch" or impulseState == "Wait FT" or impulseState == "Pullback Risk")
drawEventLabel = showEventLabels and labelCooldownReady and (impulseEvent or validEvent or watchEvent or weakEvent or pullbackEvent or failEvent or targetEvent or drawContext)

if drawEventLabel
    labelDir = activeDir == 0 ? candidateDir : activeDir
    labelState = impulseEvent ? "Impulse" : impulseState
    labelText = labelState
    labelScoreValue = impulseEvent ? int(math.round(activeImpulseScore)) : qualityScore
    if showLabelScore and activeWindow
        labelText += "\nScore " + str.tostring(labelScoreValue)
    if activeWindow and not impulseEvent
        labelText += "\nFT " + str.tostring(followProgressAtr, "#.00") + " ATR"
    labelY = labelDir == 1 ? low - safeAtr * labelOffsetAtr : high + safeAtr * labelOffsetAtr
    eventLabel = label.new(x = bar_index, y = labelY, text = labelText, xloc = xloc.bar_index, yloc = yloc.price, style = labelDir == 1 ? label.style_label_up : label.style_label_down, color = color.new(f_state_color(labelState), 4), textcolor = f_text_on(f_state_color(labelState)), size = f_label_size(labelSizeInput), textalign = text.align_center, tooltip = "Impulse Follow-Through Quality event label. It is an analytical attention marker, not a trade instruction.")
    array.push(eventLabels, eventLabel)
    f_trim_labels(eventLabels, maxVisibleLabels)
    lastLabelBar := bar_index

plotshape(showSmallMarkers and impulseEvent and activeDir == 1, title = "Bullish Impulse Marker", style = shape.diamond, location = location.belowbar, color = color.new(bullColor, 0), size = size.tiny)
plotshape(showSmallMarkers and impulseEvent and activeDir == -1, title = "Bearish Impulse Marker", style = shape.diamond, location = location.abovebar, color = color.new(bearColor, 0), size = size.tiny)
plotshape(showSmallMarkers and validEvent, title = "Valid Follow-Through Marker", style = shape.circle, location = location.belowbar, color = color.new(bullColor, 0), size = size.tiny)
plotshape(showSmallMarkers and (weakEvent or failEvent or pullbackEvent), title = "Follow-Through Risk Marker", style = shape.circle, location = location.abovebar, color = color.new(bearColor, 0), size = size.tiny)

// -------------------------------------------------
// Data window
// -------------------------------------------------
plot(activeWindow ? qualityScore : na, title = "Impulse Follow-Through Quality Score", color = stateColor, display = display.data_window)
plot(followThroughRate, title = "Follow-Through Rate", color = accentColor, display = display.data_window)
plot(activeWindow ? activeImpulseScore : na, title = "Impulse Quality Component", color = accentColor, display = display.data_window)
plot(activeWindow ? followThroughScore : na, title = "Follow-Through Component", color = bullColor, display = display.data_window)
plot(activeWindow ? activeWorstPullback * 100.0 : na, title = "Pullback Depth Percent", color = neutralColor, display = display.data_window)
plot(activeWindow ? targetRoomAtr : na, title = "Target Room ATR", color = panelLabelCol, display = display.data_window)

// -------------------------------------------------
// Panel
// -------------------------------------------------
theme = panelThemeInput
panelSize = panelFontSizeInput
dashBg = f_panel_bg(theme)
frameColor = f_panel_border(theme)
defaultValueColor = f_panel_value(theme)

bullPanelText = theme == "Light" ? color.rgb(5, 105, 88) : bullColor
bearPanelText = theme == "Light" ? color.rgb(190, 24, 93) : bearColor
neutralPanelText = theme == "Light" ? color.rgb(146, 92, 10) : neutralColor
accentPanelText = theme == "Light" ? color.rgb(67, 56, 202) : accentColor
statePanelText = stateColor == bullColor ? bullPanelText : stateColor == bearColor ? bearPanelText : stateColor == neutralColor ? neutralPanelText : stateColor == accentColor ? accentPanelText : defaultValueColor
workflowRead = activeWindow ? f_panel_workflow(impulseState) : "Standby"
scoreRead = activeWindow ? str.tostring(qualityScore) + "/100 | " + f_quality_band(qualityScore) : "No Active Impulse"
followRead = activeWindow ? str.tostring(followProgressAtr, "#.00") + " ATR | " + str.tostring(activeFollowCloses) + " closes" : "n/a"
pullbackRead = activeWindow ? pullbackRisk + " | " + str.tostring(activeWorstPullback * 100.0, "#") + "%" : "n/a"
targetRead = activeWindow ? str.tostring(targetRoomAtr, "#.00") + " ATR | " + dirText : "n/a"
windowRead = activeWindow ? str.tostring(barsActive) + " / " + str.tostring(trackingBars) + " bars" : "n/a"
ftRateRead = ftTotal > 0 ? str.tostring(int(math.round(followThroughRate))) + "% (" + str.tostring(ftTotal) + ")" : "Building"

followColor = activeWindow and followThroughScore >= 60.0 ? bullPanelText : activeWindow and followThroughScore >= 40.0 ? neutralPanelText : activeWindow ? bearPanelText : defaultValueColor
pullbackColor = pullbackRisk == "Low" ? bullPanelText : pullbackRisk == "Moderate" ? neutralPanelText : pullbackRisk == "Elevated" ? bearPanelText : defaultValueColor
targetColorPanel = activeWindow and targetRoomAtr > 0.35 ? bullPanelText : activeWindow and targetRoomAtr >= 0.0 ? neutralPanelText : activeWindow ? bearPanelText : defaultValueColor
ftRateColor = na(followThroughRate) ? defaultValueColor : followThroughRate >= 55.0 ? bullPanelText : followThroughRate >= 45.0 ? neutralPanelText : bearPanelText
scoreBg = activeWindow ? color.new(stateColor, theme == "Light" ? 76 : 18) : f_row_bg(theme, 3)
stateBg = activeWindow ? color.new(stateColor, theme == "Light" ? 72 : 18) : f_row_bg(theme, 2)

var table panel = na
var string lastPanelLocation = ""
var string lastPanelTheme = ""
var bool lastPanelVisible = false

panelNeedsReset = showPanel and (na(panel) or panelLocationInput != lastPanelLocation or panelThemeInput != lastPanelTheme or showPanel != lastPanelVisible)
if panelNeedsReset
    if not na(panel)
        table.delete(panel)
    panel := table.new(f_panel_position(panelLocationInput), 2, 9, bgcolor = dashBg, frame_color = frameColor, frame_width = 1, border_color = frameColor, border_width = 1)
    table.cell(panel, 0, 0, "AG Pro Impulse Follow-Through Quality", text_color = headerText, bgcolor = headerBg, text_size = f_label_size(panelSize), text_halign = text.align_center)
    table.cell(panel, 1, 0, "", text_color = headerText, bgcolor = headerBg, text_size = f_label_size(panelSize))
    table.merge_cells(panel, 0, 0, 1, 0)
    lastPanelLocation := panelLocationInput
    lastPanelTheme := panelThemeInput
    lastPanelVisible := showPanel

if not showPanel and not na(panel)
    table.delete(panel)
    panel := na
    lastPanelVisible := false

if showPanel and not na(panel) and barstate.islast
    table.clear(panel, 0, 1, 1, 8)
    table.cell(panel, 0, 0, "AG Pro Impulse Follow-Through Quality", text_color = headerText, bgcolor = headerBg, text_size = f_label_size(panelSize), text_halign = text.align_center)
    f_set_row(panel, 1, "Workflow", workflowRead, activeWindow ? statePanelText : defaultValueColor, theme, panelSize, f_row_bg(theme, 1))
    f_set_row(panel, 2, "State", activeWindow ? str.upper(impulseState) + " | " + str.upper(dirText) : "NO ACTIVE IMPULSE", activeWindow ? f_text_on(stateBg) : defaultValueColor, theme, panelSize, stateBg)
    f_set_row(panel, 3, "Quality", scoreRead, activeWindow ? f_text_on(scoreBg) : defaultValueColor, theme, panelSize, scoreBg)
    f_set_row(panel, 4, "Continuation Proof", ftRateRead, ftRateColor, theme, panelSize, f_row_bg(theme, 4))
    f_set_row(panel, 5, "Follow-Through", followRead, followColor, theme, panelSize, f_row_bg(theme, 5))
    f_set_row(panel, 6, "Pullback Risk", pullbackRead, pullbackColor, theme, panelSize, f_row_bg(theme, 6))
    f_set_row(panel, 7, "Target Room", targetRead, targetColorPanel, theme, panelSize, f_row_bg(theme, 7))
    f_set_row(panel, 8, "Window", windowRead, accentPanelText, theme, panelSize, f_row_bg(theme, 8))

// -------------------------------------------------
// Alerts
// -------------------------------------------------
alertcondition(impulseEvent, title = "New Impulse Review", message = "Impulse Follow-Through Quality: a qualified impulse started a follow-through review window. This is an attention marker, not a trade instruction.")
alertcondition(validEvent, title = "Valid Follow-Through", message = "Impulse Follow-Through Quality: follow-through quality is constructive enough for review. This is not a trade instruction.")
alertcondition(watchEvent, title = "Follow-Through Watch", message = "Impulse Follow-Through Quality: the impulse remains under follow-through review.")
alertcondition(weakEvent, title = "Weak Follow-Through", message = "Impulse Follow-Through Quality: follow-through is weakening after the impulse.")
alertcondition(pullbackEvent, title = "Pullback Risk Review", message = "Impulse Follow-Through Quality: retracement depth is elevated inside the follow-through window.")
alertcondition(failEvent, title = "Failure Rail Check", message = "Impulse Follow-Through Quality: price crossed the failure rail behind the impulse. Review context.")
alertcondition(targetEvent, title = "Target Room Review", message = "Impulse Follow-Through Quality: price reached the measured target-room guide. Review context.")

if confirmedBar
    lastImpulseState := impulseState
````
