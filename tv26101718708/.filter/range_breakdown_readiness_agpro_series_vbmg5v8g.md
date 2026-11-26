# Range Breakdown Readiness [AGPro Series]

- url: https://www.tradingview.com/script/VBmg5v8g-Range-Breakdown-Readiness-AGPro-Series/
- type: indicator
- pine_id: PUB;c1df0ee8a1bb45cf86d442021e101afe
- version: 4.0

## Description

Range Breakdown Readiness [AGPro Series]

🧠 Core Idea

Is the range breakdown valid, early, or likely to fail?


📌 Overview / What it does

Range Breakdown Readiness is a support-side breakdown planning tool built to evaluate whether price is actually accepting below a mature range or only probing below support and returning.

The script maps a prior range, tracks the support-side breakdown, draws a breakdown acceptance band, projects a target-room corridor, marks reclaim risk, and summarizes the setup through a 0-100 Breakdown Score.

It does not predict price direction, automate decisions, or turn every low into a tradeable support level. It is a rule-based chart-reading and planning framework.


🎯 Purpose & Design Philosophy

Many breakdown tools only mark the moment price moves below a level. That is usually not enough.

This script was built for traders who want to review breakdown quality before reacting. It focuses on acceptance, failure risk, target room, and the next planning action rather than printing generic bearish signals.

The mindset is simple: a breakdown should be reviewed as a structured decision context, not as a one-bar event.


⚡ Why This Script Is Different

Most tools focus on break markers, support/resistance lines, or broad breakout confirmation.

This script does NOT clone Consolidation Breakout Quality, Range Escape Planner, Compression Breakout Readiness, or a generic S/R zone map.

Instead, it stays narrow: it evaluates the support-side breakdown of a mature range and asks whether the break has enough acceptance to deserve review, or whether reclaim/failure risk is still too high.


⚙️ Methodology

1. Context Detection
The script maps the prior range high and range support edge, then checks whether the structure is mature enough to evaluate.

2. Reference Mapping
It uses the support edge as the breakdown reference, then draws a range box, acceptance band, reclaim rail, and target-room corridor.

3. Reaction Evaluation
The score combines range age, close below support, candle close quality, volume support, retest rejection, and target room.

4. Visual Output
The chart receives clean planning zones, compact labels, guide lines, alerts, and a premium AGPro panel with state, score, acceptance, risk, and action.


🗺️ How to Read the Chart

Zones = the mapped range, the breakdown acceptance band, and the target-room corridor.

Labels = support watch, breakdown, breakdown ready, retest rejection, follow-through, reclaim risk, and failure risk states.

Colors = teal and indigo for constructive planning context, pink for active breakdown pressure, amber for caution and failure-risk review.

Panel = the planning summary: Range State, Breakdown Score, Acceptance, Failure Risk, and Action.


🚦 Signals & States

• Support Watch → price is near the support side of a mature range.

• New Range Breakdown → price closed below the mapped support edge.

• Breakdown Ready → score and failure-risk context support a stronger breakdown review.

• Retest Rejection → price revisited the broken support area and rejected from the acceptance band.

• Failure Risk Review → acceptance is weak or reclaim pressure increased.

• Breakdown Reclaim → price moved back above the reclaim rail and the active review is invalidated.

• Target Corridor Reached → price reached the projected target-room area.


🔔 Alerts Logic

Alerts trigger when the script detects support watch, a new breakdown, breakdown ready state, retest rejection, failure-risk review, follow-through, reclaim, or target-corridor contact.

Alerts are attention markers. They are not trade instructions.


🧩 Confluence Logic

The breakdown context becomes stronger when range maturity, close distance below support, bearish close quality, relative volume, retest rejection, and target room align.

The context weakens when the move stays too close to support, forms a large lower wick, lacks volume support, or reclaims back above the support rail.


📊 When to Use

• Mature ranges that begin to test the lower boundary.

• Breakdown review after a support-side close outside the range.

• Markets where target room below the range matters.

• Charts where a trader wants failure-risk context before reacting.


⚠️ When NOT to Use

• Extremely illiquid symbols.

• Very noisy micro timeframes with unreliable range structure.

• News spikes where ATR and volume become distorted.

• Markets that gap through the entire range before a readable review forms.


🎛️ Key Inputs

• Range Lookback → controls the range reference window.

• Minimum Range Age → controls how mature the range must be before readiness improves.

• Minimum Close Below Support ATR → controls the required close distance below support.

• Acceptance Band ATR → controls the width of the breakdown acceptance band.

• Reclaim Buffer ATR → controls the invalidation rail above support.

• Target Corridor Range Multiple → controls the projected target-room corridor.

• Label and Panel Font Size → controls publication readability.


🖥️ Interface & Visual Design

The interface is designed to stay chart-first. The range box, acceptance band, and target corridor provide the main visual structure.

The panel stays compact and decision-oriented, with one merged blue AGPro header row and five planner rows.

Labels are limited, offset away from candles, and controlled by cooldown and max-visible settings to preserve a premium chart view.


🧪 Practical Usage Workflow

1. Read the panel state.

2. Check whether the range is mature or only building.

3. Review the support-side acceptance band after a close below support.

4. Compare Breakdown Score with Failure Risk.

5. Watch the reclaim rail and target-room corridor as context references.


🔍 Interpretation Guidelines

Think in terms of quality and failure risk.

A low score does not mean price cannot continue. It means the current breakdown context is not yet clean.

A high score does not mean certainty. It means the script sees stronger alignment between range maturity, acceptance, volume, candle quality, retest behavior, and target room.


🚫 What This Script Is NOT

• Not a prediction engine.

• Not financial advice.

• Not auto trading.

• Not guaranteed signals.

• Not a generic support/resistance scanner.

• Not an Order Block, Fair Value Gap, BOS/CHOCH, or broad SMC map.


⚠️ Limitations & Transparency

Range quality can change by timeframe.

High volatility can make reclaim and target-room references move quickly.

Low liquidity can reduce the usefulness of volume support.

The script is rule-based and should be interpreted within broader market context.


🧠 Market Context Notes

Breakdowns are often most useful when the prior range is mature, the support edge is clear, and price has enough room below the range to develop.

Weak breakdowns often appear as a quick pierce below support followed by a reclaim back inside the range.

This script focuses on that difference.


🧾 Use Case Examples

When price closes below range support with strong close quality, elevated relative volume, and a clean target corridor, the panel may move toward Breakdown Ready.

When price pierces below support but closes back near or above the edge, the script may show Failure Risk or Reclaim Review.


🧱 System Philosophy

AGPro planning tools are built to reduce chart ambiguity. The goal is not to add another signal, but to organize the decision context around structure, risk, acceptance, and next action.


🔐 Non-Promise Statement

No script can provide certainty.

No score should be interpreted as a guaranteed outcome.


📉 Risk Disclosure

Trading involves risk.

Users are responsible for their own decisions.

This script does not provide financial advice, investment advice, or guaranteed trading outcomes.


📚 Educational Note

Use the script as an educational planning layer to study breakdown quality, reclaim risk, and target-room context across different symbols and timeframes.

## Source Code

````pine
// -------------------------------------------------
// Range Breakdown Readiness [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 1.4
//
// Range Breakdown Readiness is a support-side breakdown planning engine that
// evaluates whether price is breaking below a mature range with acceptance,
// target room, volume support, and controlled failure risk. It maps the active
// range, breakdown acceptance band, reclaim rail, target corridor, compact
// labels, alerts, and a 0-100 Breakdown Score so the chart answers what needs
// review next instead of printing generic support and resistance signals.
// Version 1.4 adds support-floor evidence, panel context, and transition-safe alerts.
// -------------------------------------------------

//@version=6
indicator("Range Breakdown Readiness [AGPro Series]",
     shorttitle = "AG Pro RBR",
     overlay = true,
     max_boxes_count = 40,
     max_labels_count = 180,
     max_lines_count = 80,
     max_bars_back = 900)

// -------------------------------------------------
// AGPro Color Palette
// -------------------------------------------------
headerBg = color.rgb(37, 99, 235)
headerText = color.rgb(245, 247, 250)
panelBg = color.rgb(15, 23, 42)
panelBgLight = color.rgb(248, 250, 252)
panelBorder = color.rgb(51, 65, 85)
panelLabelCol = color.rgb(148, 163, 184)
panelValueCol = color.rgb(226, 232, 240)
panelLabelLight = color.rgb(71, 85, 105)
panelValueLight = color.rgb(15, 23, 42)
bullColor = color.rgb(34, 197, 166)
bearColor = color.rgb(244, 114, 182)
neutralColor = color.rgb(245, 189, 92)
accentColor = color.rgb(129, 140, 248)
darkText = color.rgb(15, 23, 42)

// -------------------------------------------------
// Tooltips
// -------------------------------------------------
ttConfirm = "Close Confirmed updates labels, alerts, and sequence states only after the bar closes. Live Updating allows the active bar to update the planning view."
ttLookback = "Lookback used to map the prior range high and support edge. The current bar is tested against the prior structure instead of being included inside it."
ttMinAge = "Minimum number of closes inside the mapped range preferred before breakdown readiness can improve."
ttMatureAge = "Inside-range count that earns full range-age score. Higher values require a more mature base before breakdown readiness rises."
ttAtr = "ATR length used for buffers, label offsets, acceptance-band width, reclaim rail distance, and normalized scoring."
ttMaxWidth = "Maximum ATR-normalized range width that can still be considered a readable planning range."
ttIdealWidth = "Ideal ATR-normalized range width used by the range-shape score. Very tiny and very wide ranges both receive weaker marks."
ttBreak = "Minimum ATR-normalized close below the range support edge required before a breakdown review can start."
ttPreBreak = "ATR distance above support used for Support Watch labels before an actual close below the range."
ttBand = "ATR width of the breakdown acceptance band below the broken support edge."
ttRetest = "ATR tolerance around the broken support edge used to classify retest rejection and reclaim risk."
ttReclaim = "ATR buffer above the broken support edge that invalidates the active breakdown review."
ttFollow = "ATR-normalized progress below support that counts as meaningful follow-through."
ttTarget = "Range-height multiple used to project the target-room corridor. It is a planning reference, not a forecast."
ttVolume = "Volume baseline used as one support component. On symbols with weak or missing volume, the component becomes neutral."
ttRvol = "Relative volume level that earns full volume-support score inside the breakdown score."
ttReady = "Minimum 0-100 Breakdown Score required for Breakdown Ready state when failure risk is also controlled."
ttWatch = "Minimum 0-100 Breakdown Score required for Breakdown Watch while the sequence is still building."
ttRiskLimit = "Maximum failure-risk value allowed for Breakdown Ready state."
ttRiskWarn = "Failure-risk value that moves the planner into Failure Risk review when acceptance is not strong enough."
ttWindow = "Maximum number of bars an active breakdown review remains active before the script waits for a fresh range. Also used as the Breakdown Rate proof window."
ttRangeBox = "Shows the active range box with a separate centered status badge. This is the reference range being tested, not a generic support/resistance map."
ttBandVisual = "Shows the breakdown acceptance band below support with a separate centered status badge."
ttTargetVisual = "Shows the projected target-room corridor below the acceptance band with a separate centered status badge."
ttGuides = "Shows support, reclaim/invalidation, and target guide lines while a breakdown review is active."
ttTint = "Applies a subtle bar tint when active breakdown states appear."
ttProjection = "Number of bars projected to the right for the range box, acceptance band, target corridor, and planning lines."
ttOpacity = "Transparency for range and planning zones. Higher values make the visual layer lighter."
ttLabels = "Shows compact Support Watch, Breakdown, Ready, Retest Reject, Failure Risk, Reclaim, and Follow-Through labels with controlled spacing."
ttContext = "Adds sparse context labels during mature range or active breakdown states so the chart stays readable without looking empty."
ttLabelScore = "Adds the 0-100 Breakdown Score to chart labels."
ttCooldown = "Minimum bars between event labels. Higher values reduce label clusters."
ttContextSpacing = "Minimum bars between sparse context labels."
ttMaxLabels = "Maximum number of labels retained on the chart. Older labels are removed first to preserve performance."
ttLabelOffset = "ATR-based vertical offset that keeps labels away from candles."
ttLabelSize = "Controls all chart labels and centered badge text. Normal is the recommended publication default."
ttShowPanel = "Shows or hides the AG Pro planning panel. It is visible by default for public-release readability."
ttPanelLocation = "Moves the AG Pro panel to the preferred chart location."
ttPanelTheme = "Switches the panel between AGPro Elite Dark, Slate, and Clean Light themes."
ttPanelFont = "Controls AG Pro panel text size. Normal is the recommended publication default."

// -------------------------------------------------
// Inputs
// -------------------------------------------------
groupEngine = "Range Breakdown Engine"
confirmationMode = input.string("Close Confirmed", "Confirmation Mode", options = ["Close Confirmed", "Live Updating"], group = groupEngine, tooltip = ttConfirm)
rangeLookback = input.int(38, "Range Lookback", minval = 12, maxval = 240, group = groupEngine, tooltip = ttLookback)
minimumRangeAge = input.int(10, "Minimum Range Age", minval = 3, maxval = 100, group = groupEngine, tooltip = ttMinAge)
matureRangeAge = input.int(24, "Mature Range Age", minval = 5, maxval = 160, group = groupEngine, tooltip = ttMatureAge)
atrLength = input.int(14, "ATR Length", minval = 5, maxval = 100, group = groupEngine, tooltip = ttAtr)
maxRangeWidthAtr = input.float(5.40, "Maximum Range Width ATR", minval = 1.00, maxval = 16.00, step = 0.10, group = groupEngine, tooltip = ttMaxWidth)
idealRangeWidthAtr = input.float(2.45, "Ideal Range Width ATR", minval = 0.50, maxval = 8.00, step = 0.05, group = groupEngine, tooltip = ttIdealWidth)

groupScore = "Breakdown Score Model"
minimumBreakdownAtr = input.float(0.18, "Minimum Close Below Support ATR", minval = 0.02, maxval = 2.00, step = 0.01, group = groupScore, tooltip = ttBreak)
preBreakWatchAtr = input.float(0.55, "Support Watch Distance ATR", minval = 0.05, maxval = 3.00, step = 0.05, group = groupScore, tooltip = ttPreBreak)
acceptanceBandAtr = input.float(0.34, "Acceptance Band ATR", minval = 0.04, maxval = 2.00, step = 0.01, group = groupScore, tooltip = ttBand)
retestToleranceAtr = input.float(0.26, "Retest Tolerance ATR", minval = 0.02, maxval = 1.50, step = 0.01, group = groupScore, tooltip = ttRetest)
reclaimBufferAtr = input.float(0.22, "Reclaim Buffer ATR", minval = 0.00, maxval = 2.00, step = 0.01, group = groupScore, tooltip = ttReclaim)
followThroughAtr = input.float(0.78, "Follow-Through ATR", minval = 0.05, maxval = 4.00, step = 0.05, group = groupScore, tooltip = ttFollow)
targetRangeMultiple = input.float(1.10, "Target Corridor Range Multiple", minval = 0.25, maxval = 4.00, step = 0.05, group = groupScore, tooltip = ttTarget)
volumeLength = input.int(34, "Volume Baseline", minval = 5, maxval = 240, group = groupScore, tooltip = ttVolume)
strongRvol = input.float(1.35, "Strong RVOL Level", minval = 0.60, maxval = 5.00, step = 0.05, group = groupScore, tooltip = ttRvol)
readyThreshold = input.int(72, "Breakdown Ready Threshold", minval = 45, maxval = 95, group = groupScore, tooltip = ttReady)
watchThreshold = input.int(55, "Breakdown Watch Threshold", minval = 25, maxval = 90, group = groupScore, tooltip = ttWatch)
maxReadyFailureRisk = input.int(48, "Max Ready Failure Risk", minval = 10, maxval = 90, group = groupScore, tooltip = ttRiskLimit)
failureRiskThreshold = input.int(66, "Failure Risk Threshold", minval = 30, maxval = 95, group = groupScore, tooltip = ttRiskWarn)
reviewWindowBars = input.int(42, "Breakdown Review Window", minval = 8, maxval = 200, group = groupScore, tooltip = ttWindow)

groupVisual = "Chart Visuals"
showRangeBox = input.bool(true, "Show Range Box", group = groupVisual, tooltip = ttRangeBox)
showAcceptanceBand = input.bool(true, "Show Breakdown Acceptance Band", group = groupVisual, tooltip = ttBandVisual)
showTargetCorridor = input.bool(true, "Show Target Corridor", group = groupVisual, tooltip = ttTargetVisual)
showPlanningGuides = input.bool(true, "Show Risk / Target Guides", group = groupVisual, tooltip = ttGuides)
showCandleTint = input.bool(false, "Subtle Candle Tint", group = groupVisual, tooltip = ttTint)
projectionBars = input.int(42, "Forward Projection Bars", minval = 8, maxval = 180, group = groupVisual, tooltip = ttProjection)
zoneTransparency = input.int(88, "Zone Transparency", minval = 70, maxval = 96, group = groupVisual, tooltip = ttOpacity)

groupLabels = "Labels"
showEventLabels = input.bool(true, "Show Event Labels", group = groupLabels, tooltip = ttLabels)
showContextLabels = input.bool(true, "Show Sparse Context Labels", group = groupLabels, tooltip = ttContext)
showZoneBadges = input.bool(true, "Show Centered Zone Badges", group = groupLabels, tooltip = "Shows separate centered badges inside range, acceptance, and target zones.")
zoneBadgeAnchor = input.float(0.50, "Zone Badge Anchor", minval = 0.35, maxval = 0.90, step = 0.05, group = groupLabels,
     tooltip = "Controls the horizontal position of zone badges inside the forward planning segment. The 0.50 default keeps identifiers centered and away from historical candles.")
showLabelScore = input.bool(true, "Show Label Score", group = groupLabels, tooltip = ttLabelScore)
labelCooldownBars = input.int(22, "Label Cooldown Bars", minval = 1, maxval = 120, group = groupLabels, tooltip = ttCooldown)
contextSpacingBars = input.int(56, "Context Label Spacing", minval = 6, maxval = 180, group = groupLabels, tooltip = ttContextSpacing)
maxVisibleLabels = input.int(9, "Max Visible Labels", minval = 4, maxval = 80, group = groupLabels, tooltip = ttMaxLabels)
labelOffsetAtr = input.float(1.08, "Label Offset ATR", minval = 0.10, maxval = 3.00, step = 0.05, group = groupLabels, tooltip = ttLabelOffset)
labelFontSize = input.string("Normal", "Label Font Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = groupLabels, tooltip = ttLabelSize)

groupPanel = "Panel"
showPanel = input.bool(true, "Show Panel", group = groupPanel, tooltip = ttShowPanel)
panelLocation = input.string("Top Right", "Panel Location", options = ["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], group = groupPanel, tooltip = ttPanelLocation)
panelTheme = input.string("Elite Dark", "Panel Theme", options = ["Elite Dark", "Slate", "Clean Light"], group = groupPanel, tooltip = ttPanelTheme)
panelFontSize = input.string("Normal", "Panel Font Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = groupPanel, tooltip = ttPanelFont)

// -------------------------------------------------
// Helpers
// -------------------------------------------------
f_clamp(float value, float minValue, float maxValue) =>
    math.min(math.max(nz(value, minValue), minValue), maxValue)

f_norm_high_good(float value, float weak, float strong) =>
    float span = strong - weak
    span == 0.0 ? 0.0 : f_clamp((value - weak) / span * 100.0, 0.0, 100.0)

f_norm_low_good(float value, float good, float bad) =>
    float span = bad - good
    span == 0.0 ? 0.0 : f_clamp((bad - value) / span * 100.0, 0.0, 100.0)

f_peak_score(float value, float lowValue, float idealValue, float highValue) =>
    value <= idealValue ? f_norm_high_good(value, lowValue, idealValue) : f_norm_low_good(value, idealValue, highValue)

f_text_size(string value) =>
    switch value
        "Tiny" => size.tiny
        "Small" => size.small
        "Large" => size.large
        "Huge" => size.huge
        => size.normal

f_text_on(color bgColor) =>
    float yiq = (color.r(bgColor) * 299.0 + color.g(bgColor) * 587.0 + color.b(bgColor) * 114.0) / 1000.0
    yiq >= 150.0 ? darkText : headerText

f_panel_position(string value) =>
    switch value
        "Top Left" => position.top_left
        "Top Center" => position.top_center
        "Top Right" => position.top_right
        "Middle Left" => position.middle_left
        "Middle Center" => position.middle_center
        "Middle Right" => position.middle_right
        "Bottom Left" => position.bottom_left
        "Bottom Center" => position.bottom_center
        => position.bottom_right

f_fmt_score(float value) =>
    str.tostring(math.round(f_clamp(value, 0.0, 100.0)))

f_grade(float value) =>
    value >= 82.0 ? "Elite" : value >= 72.0 ? "Ready" : value >= 55.0 ? "Watch" : value >= 38.0 ? "Early" : "Low"

f_risk_word(float value) =>
    value >= 72.0 ? "High" : value >= 50.0 ? "Medium" : "Low"

f_event_text(string labelText, float scoreValue, bool includeScore) =>
    includeScore ? labelText + "\n" + f_fmt_score(scoreValue) : labelText

f_panel_row(table target, int row, string leftText, string rightText, color rightColor, string themeInput, string fontInput) =>
    color leftBg = themeInput == "Clean Light" ? color.rgb(241, 245, 249) : themeInput == "Slate" ? color.rgb(30, 41, 59) : panelBg
    color rightBg = themeInput == "Clean Light" ? panelBgLight : themeInput == "Slate" ? color.rgb(37, 49, 70) : color.rgb(17, 31, 52)
    color leftColor = themeInput == "Clean Light" ? panelLabelLight : panelLabelCol
    table.cell(target, 0, row, leftText, text_color = leftColor, bgcolor = leftBg, text_size = f_text_size(fontInput), text_halign = text.align_left)
    table.cell(target, 1, row, rightText, text_color = rightColor, bgcolor = rightBg, text_size = f_text_size(fontInput), text_halign = text.align_right)

f_push_label(array<label> bucket, int xValue, float yValue, string textValue, color bgColor, string styleName, string sizeInput, int limitValue) =>
    labelStyle = styleName == "Up" ? label.style_label_up : label.style_label_down
    label newLabel = label.new(x = xValue, y = yValue, text = textValue, xloc = xloc.bar_index, style = labelStyle, color = color.new(bgColor, 0), textcolor = f_text_on(bgColor), size = f_text_size(sizeInput))
    array.push(bucket, newLabel)
    if array.size(bucket) > limitValue
        label oldLabel = array.shift(bucket)
        label.delete(oldLabel)

f_set_badge(label badge, int xValue, float yValue, string txt, color bgColor, string sizeInput) =>
    label.set_x(badge, xValue)
    label.set_y(badge, yValue)
    label.set_text(badge, txt)
    label.set_color(badge, color.new(bgColor, 0))
    label.set_textcolor(badge, f_text_on(bgColor))
    label.set_size(badge, f_text_size(sizeInput))
    label.set_style(badge, label.style_label_center)

f_hide_badge(label badge) =>
    label.set_text(badge, "")
    label.set_color(badge, color.new(color.white, 100))
    label.set_textcolor(badge, color.new(color.white, 100))
    label.set_x(badge, bar_index)
    label.set_y(badge, close)

// -------------------------------------------------
// Range Reference
// -------------------------------------------------
atrRaw = ta.atr(atrLength)
atrValue = math.max(nz(atrRaw, high - low), syminfo.mintick)
rawRangeHigh = ta.highest(high[1], rangeLookback)
rawRangeLow = ta.lowest(low[1], rangeLookback)
enoughBars = bar_index > rangeLookback + atrLength + 5 and not na(rawRangeHigh) and not na(rawRangeLow)
rawRangeHeight = enoughBars ? math.max(rawRangeHigh - rawRangeLow, syminfo.mintick) : syminfo.mintick
rawRangeWidthAtr = rawRangeHeight / atrValue

insideCount = 0
if enoughBars
    for idx = 1 to rangeLookback
        if close[idx] <= rawRangeHigh and close[idx] >= rawRangeLow
            insideCount += 1

rangeAgeScore = enoughBars ? f_norm_high_good(insideCount, minimumRangeAge, matureRangeAge) : 0.0
rangeWidthScore = enoughBars ? f_peak_score(rawRangeWidthAtr, 0.65, idealRangeWidthAtr, maxRangeWidthAtr) : 0.0
rangeMaturityScore = f_clamp(rangeAgeScore * 0.58 + rangeWidthScore * 0.42, 0.0, 100.0)
matureRange = enoughBars and insideCount >= minimumRangeAge and rawRangeWidthAtr <= maxRangeWidthAtr and rawRangeWidthAtr >= 0.45
preBreakDistanceAtr = enoughBars ? (close - rawRangeLow) / atrValue : 999.0
supportWatch = matureRange and preBreakDistanceAtr >= 0.0 and preBreakDistanceAtr <= preBreakWatchAtr
intrabarPierce = matureRange and low < rawRangeLow - minimumBreakdownAtr * atrValue and close >= rawRangeLow - minimumBreakdownAtr * atrValue

// -------------------------------------------------
// Active Breakdown Sequence
// -------------------------------------------------
var bool activeSequence = false
var float activeSupport = na
var float activeRangeTop = na
var float activeRangeHeight = na
var int activeBreakBar = na
var int activeInsideCount = na

stateUpdateAllowed = confirmationMode == "Live Updating" or barstate.isconfirmed
newBreakdownEvent = false
reclaimedEvent = false
expiredSequence = false

if activeSequence and stateUpdateAllowed
    tooOld = not na(activeBreakBar) and bar_index - activeBreakBar > reviewWindowBars
    reclaimedNow = not na(activeSupport) and close > activeSupport + reclaimBufferAtr * atrValue
    if reclaimedNow or tooOld
        reclaimedEvent := reclaimedNow
        expiredSequence := tooOld
        activeSequence := false
        activeSupport := na
        activeRangeTop := na
        activeRangeHeight := na
        activeBreakBar := na
        activeInsideCount := na

newBreakdownCandidate = stateUpdateAllowed and matureRange and close < rawRangeLow - minimumBreakdownAtr * atrValue
if newBreakdownCandidate and not activeSequence
    activeSequence := true
    activeSupport := rawRangeLow
    activeRangeTop := rawRangeHigh
    activeRangeHeight := rawRangeHeight
    activeBreakBar := bar_index
    activeInsideCount := insideCount
    newBreakdownEvent := true

supportEdge = activeSequence and not na(activeSupport) ? activeSupport : rawRangeLow
rangeTopEdge = activeSequence and not na(activeRangeTop) ? activeRangeTop : rawRangeHigh
rangeHeightValue = activeSequence and not na(activeRangeHeight) ? activeRangeHeight : rawRangeHeight
activeBars = activeSequence and not na(activeBreakBar) ? bar_index - activeBreakBar : 0
rangeLeft = activeSequence and not na(activeBreakBar) ? math.max(activeBreakBar - rangeLookback, 0) : math.max(bar_index - rangeLookback, 0)
rightEdge = bar_index + projectionBars

// -------------------------------------------------
// Breakdown Score
// -------------------------------------------------
breakdownDistanceAtr = enoughBars and not na(supportEdge) ? (supportEdge - close) / atrValue : 0.0
breakdownProgressScore = f_norm_high_good(breakdownDistanceAtr, minimumBreakdownAtr, followThroughAtr)
closeAccepted = activeSequence and breakdownDistanceAtr >= minimumBreakdownAtr

barSpan = math.max(high - low, syminfo.mintick)
bearishCloseQuality = f_clamp((high - close) / barSpan * 100.0, 0.0, 100.0)
lowerWickPct = f_clamp((math.min(open, close) - low) / barSpan * 100.0, 0.0, 100.0)

volumeBase = ta.sma(volume, volumeLength)
volumeUsable = not na(volume) and not na(volumeBase) and volume > 0.0 and volumeBase > 0.0
rvol = volumeUsable ? volume / volumeBase : 1.0
volumeScore = volumeUsable ? f_norm_high_good(rvol, 0.85, strongRvol) : 55.0

retestTouched = activeSequence and high >= supportEdge - retestToleranceAtr * atrValue and high <= supportEdge + retestToleranceAtr * atrValue * 2.0
retestRejected = retestTouched and close < supportEdge and close < open
retestScore = activeSequence ? retestRejected ? 100.0 : retestTouched ? 70.0 : 48.0 : 45.0

targetGuide = enoughBars and not na(supportEdge) ? supportEdge - rangeHeightValue * targetRangeMultiple : na
targetRoomAtr = not na(targetGuide) ? math.max(close - targetGuide, 0.0) / atrValue : 0.0
targetRoomScore = f_norm_high_good(targetRoomAtr, 0.60, 2.65)

breakdownScore = f_clamp(rangeMaturityScore * 0.22 + breakdownProgressScore * 0.24 + bearishCloseQuality * 0.14 + volumeScore * 0.16 + retestScore * 0.12 + targetRoomScore * 0.12, 0.0, 100.0)

proximityRisk = 100.0 - breakdownProgressScore
wickReclaimRisk = f_norm_high_good(lowerWickPct, 20.0, 68.0)
volumeRisk = 100.0 - volumeScore
supportDistanceRisk = f_norm_low_good(math.abs(close - supportEdge) / atrValue, 0.0, followThroughAtr)
maturityRisk = 100.0 - rangeMaturityScore
failureRisk = activeSequence ? f_clamp(proximityRisk * 0.28 + wickReclaimRisk * 0.22 + volumeRisk * 0.18 + supportDistanceRisk * 0.20 + maturityRisk * 0.12, 0.0, 100.0) : intrabarPierce ? 72.0 : supportWatch ? 44.0 : 35.0
if reclaimedEvent
    failureRisk := 100.0

readyState = activeSequence and closeAccepted and breakdownScore >= readyThreshold and failureRisk <= maxReadyFailureRisk
watchState = activeSequence and not readyState and breakdownScore >= watchThreshold and failureRisk < failureRiskThreshold
failureRiskState = activeSequence and failureRisk >= failureRiskThreshold and not readyState
followThroughState = activeSequence and breakdownDistanceAtr >= followThroughAtr and failureRisk < failureRiskThreshold
targetRoomTouched = activeSequence and not na(targetGuide) and low <= targetGuide

wasReadyState = bar_index > 0 ? readyState[1] : false
wasFailureRiskState = bar_index > 0 ? failureRiskState[1] : false
wasFollowThroughState = bar_index > 0 ? followThroughState[1] : false
wasRetestRejected = bar_index > 0 ? retestRejected[1] : false
wasSupportWatch = bar_index > 0 ? supportWatch[1] : false
wasTargetRoomTouched = bar_index > 0 ? targetRoomTouched[1] : false
readyEvent = stateUpdateAllowed and readyState and not wasReadyState
failureRiskEvent = stateUpdateAllowed and failureRiskState and not wasFailureRiskState
followThroughEvent = stateUpdateAllowed and followThroughState and not wasFollowThroughState
retestRejectEvent = stateUpdateAllowed and retestRejected and not wasRetestRejected
supportWatchEvent = stateUpdateAllowed and supportWatch and not activeSequence and not wasSupportWatch
targetRoomReached = stateUpdateAllowed and targetRoomTouched and not wasTargetRoomTouched

// -------------------------------------------------
// Breakdown follow-through proof (Confirm Rate)
// -------------------------------------------------
// When a breakdown is Ready, does price follow through 0.75 ATR lower before
// reclaiming above the broken support rail or the review window expires?
// Counted once per Ready. A reclaim first, or a window expiry with no
// follow-through, is treated as not-followed (conservative).
float bdMargin = math.max(nz(atrValue), syminfo.mintick) * 0.75
var int   bdTotal = 0
var int   bdWon    = 0
var bool  bdPend    = false
var float bdAnchor   = na
var float bdReclaim   = na
var int   bdLeft       = 0

if barstate.isconfirmed
    if bdPend and not na(bdAnchor) and not na(bdReclaim)
        bool bdFailed = close > bdReclaim
        bool bdFollowed = close <= bdAnchor - bdMargin
        if bdFailed
            bdTotal += 1
            bdPend := false
        else if bdFollowed
            bdTotal += 1
            bdWon += 1
            bdPend := false
        else
            bdLeft -= 1
            if bdLeft <= 0
                bdTotal += 1
                bdPend := false
    if readyEvent and not na(supportEdge) and not bdPend
        bdAnchor := close
        bdReclaim := supportEdge + reclaimBufferAtr * atrValue
        bdLeft := reviewWindowBars
        bdPend := true

float bdRate = bdTotal > 0 ? bdWon / bdTotal * 100.0 : na
string breakdownRateRead = bdTotal > 0 ? str.tostring(math.round(bdRate)) + "% (" + str.tostring(bdTotal) + ")" : "Building"

rangeState = "Building"
if matureRange and not activeSequence
    rangeState := supportWatch ? "Support Watch" : "Mature Range"
if intrabarPierce and not activeSequence
    rangeState := "Early Pierce"
if activeSequence
    rangeState := readyState ? "Breakdown Ready" : failureRiskState ? "Failure Risk" : followThroughState ? "Follow-Through" : watchState ? "Breakdown Watch" : "Acceptance Build"
if reclaimedEvent
    rangeState := "Reclaim Review"

acceptanceText = "No Closed Break"
if activeSequence
    acceptanceText := readyState ? "Accepted" : watchState ? "Building" : failureRiskState ? "Weak" : closeAccepted ? "Early" : "Pending"
else if intrabarPierce
    acceptanceText := "Pierce Only"
else if supportWatch
    acceptanceText := "Near Support"

failureText = f_risk_word(failureRisk) + " " + f_fmt_score(failureRisk)

actionText = matureRange ? "Track Range Floor" : "Wait For Maturity"
if supportWatch and not activeSequence
    actionText := "Watch Support Close"
if intrabarPierce and not activeSequence
    actionText := "Wait For Close"
if activeSequence
    actionText := readyState ? "Review Plan" : failureRiskState ? "Check Reclaim" : followThroughState ? "Manage Context" : watchState ? "Wait Acceptance" : "Monitor Band"
if reclaimedEvent
    actionText := "Reset Review"

stateColor = activeSequence ? readyState ? bearColor : failureRiskState ? neutralColor : followThroughState ? bearColor : watchState ? accentColor : neutralColor : supportWatch ? accentColor : neutralColor
riskColor = failureRisk >= 66.0 ? neutralColor : failureRisk >= 48.0 ? accentColor : bullColor

// -------------------------------------------------
// Visual Objects
// -------------------------------------------------
var box rangeBox = na
var box acceptanceBox = na
var box targetBox = na
var line supportLine = na
var line reclaimLine = na
var line targetLine = na
var label rangeBadge = label.new(bar_index, close, "", xloc = xloc.bar_index, style = label.style_label_center, color = accentColor, textcolor = f_text_on(accentColor), size = f_text_size(labelFontSize), textalign = text.align_center)
var label acceptanceBadge = label.new(bar_index, close, "", xloc = xloc.bar_index, style = label.style_label_center, color = bearColor, textcolor = f_text_on(bearColor), size = f_text_size(labelFontSize), textalign = text.align_center)
var label targetBadge = label.new(bar_index, close, "", xloc = xloc.bar_index, style = label.style_label_center, color = bearColor, textcolor = f_text_on(bearColor), size = f_text_size(labelFontSize), textalign = text.align_center)
var array<label> eventLabels = array.new<label>()
var int lastEventLabelBar = na
var int lastContextLabelBar = na

hasPlanningContext = enoughBars and not na(supportEdge) and (matureRange or activeSequence or intrabarPierce)
acceptanceTop = supportEdge
acceptanceBottom = supportEdge - acceptanceBandAtr * atrValue
reclaimLinePrice = supportEdge + reclaimBufferAtr * atrValue
scoreText = f_fmt_score(breakdownScore) + " / 100 " + f_grade(breakdownScore)
rangeAgeValue = activeSequence and not na(activeInsideCount) ? activeInsideCount : insideCount
rangeFloorRead = enoughBars and not na(supportEdge) ? str.tostring(supportEdge, format.mintick) : "Building"
rangeAgePanel = enoughBars ? str.tostring(rangeAgeValue) + " closes" : "Building"

if showRangeBox and hasPlanningContext
    boxColor = activeSequence ? bearColor : accentColor
    rangeBoxText = activeSequence ? "Range Breakdown Review" : rangeState + "\nFloor " + str.tostring(supportEdge, format.mintick) + " | Age " + str.tostring(rangeAgeValue)
    if na(rangeBox)
        rangeBox := box.new(left = rangeLeft, top = rangeTopEdge, right = rightEdge, bottom = supportEdge, xloc = xloc.bar_index, bgcolor = color.new(boxColor, zoneTransparency), border_color = color.new(boxColor, 28), border_width = 1)
    else
        box.set_lefttop(rangeBox, rangeLeft, rangeTopEdge)
        box.set_rightbottom(rangeBox, rightEdge, supportEdge)
        box.set_bgcolor(rangeBox, color.new(boxColor, zoneTransparency))
        box.set_border_color(rangeBox, color.new(boxColor, 28))
    if showZoneBadges and not activeSequence
        rangeBadgeX = int(math.round(bar_index + (rightEdge - bar_index) * zoneBadgeAnchor))
        rangeBadgeY = (rangeTopEdge + supportEdge) * 0.50
        f_set_badge(rangeBadge, rangeBadgeX, rangeBadgeY, rangeBoxText, boxColor, labelFontSize)
    else
        f_hide_badge(rangeBadge)
else
    if not na(rangeBox)
        box.delete(rangeBox)
        rangeBox := na
    f_hide_badge(rangeBadge)

if showAcceptanceBand and (activeSequence or intrabarPierce)
    bandColor = failureRiskState ? neutralColor : bearColor
    bandText = "Breakdown Acceptance | " + acceptanceText
    bandLeft = activeSequence and not na(activeBreakBar) ? activeBreakBar : bar_index
    if na(acceptanceBox)
        acceptanceBox := box.new(left = bandLeft, top = acceptanceTop, right = rightEdge, bottom = acceptanceBottom, xloc = xloc.bar_index, bgcolor = color.new(bandColor, zoneTransparency), border_color = color.new(bandColor, 18), border_width = 1)
    else
        box.set_lefttop(acceptanceBox, bandLeft, acceptanceTop)
        box.set_rightbottom(acceptanceBox, rightEdge, acceptanceBottom)
        box.set_bgcolor(acceptanceBox, color.new(bandColor, zoneTransparency))
        box.set_border_color(acceptanceBox, color.new(bandColor, 18))
    if showZoneBadges
        acceptanceBadgeX = int(math.round(bandLeft + (rightEdge - bandLeft) * zoneBadgeAnchor))
        acceptanceBadgeY = (acceptanceTop + acceptanceBottom) * 0.50
        f_set_badge(acceptanceBadge, acceptanceBadgeX, acceptanceBadgeY, bandText, bandColor, labelFontSize)
    else
        f_hide_badge(acceptanceBadge)
else
    if not na(acceptanceBox)
        box.delete(acceptanceBox)
        acceptanceBox := na
    f_hide_badge(acceptanceBadge)

if showTargetCorridor and activeSequence and not na(targetGuide)
    targetText = "Target Room | " + f_fmt_score(targetRoomScore)
    targetTop = acceptanceBottom
    targetBottom = targetGuide
    if na(targetBox)
        targetBox := box.new(left = activeBreakBar, top = targetTop, right = rightEdge, bottom = targetBottom, xloc = xloc.bar_index, bgcolor = color.new(bearColor, math.min(zoneTransparency + 4, 96)), border_color = color.new(bearColor, 35), border_width = 1)
    else
        box.set_lefttop(targetBox, activeBreakBar, targetTop)
        box.set_rightbottom(targetBox, rightEdge, targetBottom)
        box.set_bgcolor(targetBox, color.new(bearColor, math.min(zoneTransparency + 4, 96)))
        box.set_border_color(targetBox, color.new(bearColor, 35))
    if showZoneBadges
        targetBadgeX = int(math.round(activeBreakBar + (rightEdge - activeBreakBar) * math.min(zoneBadgeAnchor + 0.08, 0.92)))
        targetBadgeY = (targetTop + targetBottom) * 0.50
        f_set_badge(targetBadge, targetBadgeX, targetBadgeY, targetText, bearColor, labelFontSize)
    else
        f_hide_badge(targetBadge)
else
    if not na(targetBox)
        box.delete(targetBox)
        targetBox := na
    f_hide_badge(targetBadge)

if showPlanningGuides and (activeSequence or intrabarPierce)
    guideLeft = activeSequence and not na(activeBreakBar) ? activeBreakBar : bar_index
    if na(supportLine)
        supportLine := line.new(x1 = guideLeft, y1 = supportEdge, x2 = rightEdge, y2 = supportEdge, xloc = xloc.bar_index, color = color.new(panelValueCol, 8), style = line.style_solid, width = 1)
    else
        line.set_xy1(supportLine, guideLeft, supportEdge)
        line.set_xy2(supportLine, rightEdge, supportEdge)
        line.set_color(supportLine, color.new(panelValueCol, 8))
    if na(reclaimLine)
        reclaimLine := line.new(x1 = guideLeft, y1 = reclaimLinePrice, x2 = rightEdge, y2 = reclaimLinePrice, xloc = xloc.bar_index, color = color.new(neutralColor, 0), style = line.style_dashed, width = 1)
    else
        line.set_xy1(reclaimLine, guideLeft, reclaimLinePrice)
        line.set_xy2(reclaimLine, rightEdge, reclaimLinePrice)
        line.set_color(reclaimLine, color.new(neutralColor, 0))
    if not na(targetGuide)
        if na(targetLine)
            targetLine := line.new(x1 = guideLeft, y1 = targetGuide, x2 = rightEdge, y2 = targetGuide, xloc = xloc.bar_index, color = color.new(bearColor, 0), style = line.style_dotted, width = 1)
        else
            line.set_xy1(targetLine, guideLeft, targetGuide)
            line.set_xy2(targetLine, rightEdge, targetGuide)
            line.set_color(targetLine, color.new(bearColor, 0))
else
    if not na(supportLine)
        line.delete(supportLine)
        supportLine := na
    if not na(reclaimLine)
        line.delete(reclaimLine)
        reclaimLine := na
    if not na(targetLine)
        line.delete(targetLine)
        targetLine := na

barcolor(showCandleTint and activeSequence ? color.new(stateColor, 78) : na)

// -------------------------------------------------
// Labels
// -------------------------------------------------
canEventLabel = na(lastEventLabelBar) or bar_index - lastEventLabelBar >= labelCooldownBars
canContextLabel = na(lastContextLabelBar) or bar_index - lastContextLabelBar >= contextSpacingBars
eventLabelPlaced = false

if showEventLabels and stateUpdateAllowed and canEventLabel
    labelText = ""
    labelColor = neutralColor
    labelStyle = "Up"
    labelY = low - labelOffsetAtr * atrValue
    if reclaimedEvent
        labelText := "Reclaim Risk"
        labelColor := neutralColor
        labelStyle := "Down"
        labelY := high + labelOffsetAtr * atrValue
    else if readyEvent
        labelText := f_event_text("Breakdown Ready", breakdownScore, showLabelScore)
        labelColor := bearColor
    else if failureRiskEvent
        labelText := f_event_text("Failure Risk", failureRisk, showLabelScore)
        labelColor := neutralColor
        labelStyle := "Down"
        labelY := high + labelOffsetAtr * atrValue
    else if retestRejectEvent
        labelText := f_event_text("Retest Reject", breakdownScore, showLabelScore)
        labelColor := bearColor
    else if followThroughEvent
        labelText := f_event_text("Follow-Through", breakdownScore, showLabelScore)
        labelColor := bearColor
    else if newBreakdownEvent
        labelText := f_event_text("Breakdown", breakdownScore, showLabelScore)
        labelColor := bearColor
    else if supportWatchEvent
        labelText := "Support Watch"
        labelColor := accentColor
    if labelText != ""
        f_push_label(eventLabels, bar_index, labelY, labelText, labelColor, labelStyle, labelFontSize, maxVisibleLabels)
        lastEventLabelBar := bar_index
        eventLabelPlaced := true

if showContextLabels and stateUpdateAllowed and canContextLabel and not eventLabelPlaced
    contextText = ""
    contextColor = accentColor
    contextStyle = "Up"
    contextY = low - labelOffsetAtr * atrValue
    if activeSequence and activeBars > 3
        contextText := readyState ? "Accepted" : failureRiskState ? "Reclaim Check" : watchState ? "Acceptance Build" : "Breakdown Review"
        contextColor := failureRiskState ? neutralColor : bearColor
    else if supportWatch
        contextText := "Range Support"
        contextColor := accentColor
    else if matureRange
        contextText := "Mature Range"
        contextColor := accentColor
    if contextText != ""
        f_push_label(eventLabels, bar_index, contextY, contextText, contextColor, contextStyle, labelFontSize, maxVisibleLabels)
        lastContextLabelBar := bar_index

// -------------------------------------------------
// Data Window
// -------------------------------------------------
plot(breakdownScore, title = "Breakdown Score", color = stateColor, display = display.data_window)
plot(failureRisk, title = "Failure Risk", color = riskColor, display = display.data_window)
plot(bdRate, title = "Breakdown Follow Rate", color = bullColor, display = display.data_window)

// -------------------------------------------------
// Panel
// -------------------------------------------------
var table panel = table.new(f_panel_position(panelLocation), 2, 9, border_width = 1, frame_color = panelBorder, border_color = panelBorder)

if barstate.islast
    table.set_position(panel, f_panel_position(panelLocation))
    table.clear(panel, 0, 0, 1, 8)
    if showPanel
        color rateCol = na(bdRate) ? (panelTheme == "Clean Light" ? panelValueLight : panelValueCol) : bdRate >= 60.0 ? bullColor : bdRate >= 45.0 ? neutralColor : bearColor
        table.merge_cells(panel, 0, 0, 1, 0)
        table.cell(panel, 0, 0, "AG Pro Range Breakdown Readiness", text_color = headerText, bgcolor = headerBg, text_size = f_text_size(panelFontSize), text_halign = text.align_center)
        f_panel_row(panel, 1, "Range State", rangeState, stateColor, panelTheme, panelFontSize)
        f_panel_row(panel, 2, "Range Floor", rangeFloorRead, accentColor, panelTheme, panelFontSize)
        f_panel_row(panel, 3, "Range Age", rangeAgePanel, panelTheme == "Clean Light" ? panelValueLight : panelValueCol, panelTheme, panelFontSize)
        f_panel_row(panel, 4, "Breakdown Score", scoreText, stateColor, panelTheme, panelFontSize)
        f_panel_row(panel, 5, "Breakdown Rate", breakdownRateRead, rateCol, panelTheme, panelFontSize)
        f_panel_row(panel, 6, "Acceptance", acceptanceText, stateColor, panelTheme, panelFontSize)
        f_panel_row(panel, 7, "Failure Risk", failureText, riskColor, panelTheme, panelFontSize)
        f_panel_row(panel, 8, "Action", actionText, stateColor, panelTheme, panelFontSize)

// -------------------------------------------------
// Alerts
// -------------------------------------------------
alertcondition(barstate.isconfirmed and supportWatchEvent, title = "Support Watch", message = "Range Breakdown Readiness: price is near the support side of a mature range. This is an attention marker, not a trade instruction.")
alertcondition(barstate.isconfirmed and newBreakdownEvent, title = "New Range Breakdown", message = "Range Breakdown Readiness: price closed below the mapped range support and started a breakdown review.")
alertcondition(barstate.isconfirmed and readyEvent, title = "Breakdown Ready", message = "Range Breakdown Readiness: breakdown score and failure-risk context reached Breakdown Ready state. Review the full plan before acting.")
alertcondition(barstate.isconfirmed and failureRiskEvent, title = "Failure Risk Review", message = "Range Breakdown Readiness: breakdown acceptance is weak or reclaim risk has increased.")
alertcondition(barstate.isconfirmed and retestRejectEvent, title = "Retest Rejection", message = "Range Breakdown Readiness: price revisited the broken support area and rejected from the acceptance band.")
alertcondition(barstate.isconfirmed and followThroughEvent, title = "Breakdown Follow-Through", message = "Range Breakdown Readiness: price expanded below support with meaningful follow-through distance.")
alertcondition(barstate.isconfirmed and reclaimedEvent, title = "Breakdown Reclaim", message = "Range Breakdown Readiness: price reclaimed above the broken support rail and invalidated the active breakdown review.")
alertcondition(barstate.isconfirmed and targetRoomReached, title = "Target Corridor Reached", message = "Range Breakdown Readiness: price reached the projected target-room corridor. This is a context marker, not an exit instruction.")
````
