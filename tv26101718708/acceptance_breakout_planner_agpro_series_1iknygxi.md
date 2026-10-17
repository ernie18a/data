# Acceptance Breakout Planner [AGPro Series]

- url: https://www.tradingview.com/script/1IkNyGxi-Acceptance-Breakout-Planner-AGPro-Series/
- type: indicator
- pine_id: PUB;647c1075c2594a278a24fc60a36403da
- version: 5.0

## Description

Acceptance Breakout Planner [AGPro Series]


🧠 Core Idea

Did price truly accept beyond the breakout level, or did it only tag the level and fail to hold?


📌 Overview / What it does

Acceptance Breakout Planner [AGPro Series] is a chart-first breakout decision tool designed to evaluate what happens after price moves beyond a key rolling reference edge.

Instead of treating every breakout as meaningful, the script measures close persistence, time beyond the level, retest-hold behavior, range distance, candle quality, volume support, and failure shelf risk. It converts that evidence into a 0-100 Acceptance Score and a clear next-action state.

The script produces an acceptance band, a failure shelf, a target-room guide, controlled chart labels, alerts, and a clean AGPro planning panel. It does not predict price movement, automate execution, or claim that acceptance will continue.


🎯 Purpose & Design Philosophy

This script was built to fill the gap between a simple breakout marker and a full trade-management system.

Many traders can see when price crosses a level. The harder question is whether price is spending enough time beyond that level to deserve attention, or whether the break is only a low-commitment tag.

The design supports a planner mindset: observe the break, measure acceptance, watch the failure shelf, and review the next state with structure instead of reacting to a single candle.


⚡ Why This Script Is Different

Most breakout tools focus on the moment price crosses a level.

This script does NOT function as a generic breakout signal, volume-spike detector, consolidation breakout box, Donchian channel tool, or broad break-retest scanner.

Instead, it focuses on post-break acceptance quality. The key question is not simply "did price break?" The key question is "did price remain accepted beyond the broken reference long enough to reduce tag-only risk?"

This keeps the script separate from Breakout Volume Quality, Consolidation Breakout Quality, Break-Retest Quality, Price Acceptance Profile, and reference-specific breakout tools in the AGPro catalog.


⚙️ Methodology

1. Context Detection
The script maps rolling upper and lower reference edges from prior bars. These references are used only as breakout acceptance anchors.

2. Reference Mapping
When price closes beyond a reference edge by an ATR-adjusted buffer, the planner starts an active acceptance sequence.

3. Reaction Evaluation
The active sequence is scored through close persistence, time beyond the level, acceptance-band retests, candle quality, relative volume support, and distance from the failure shelf.

4. Visual Output
The chart shows an acceptance band, a failure shelf, a target-room guide, compact state labels, and a panel that summarizes acceptance score, time beyond, break side, failure risk, and action.


🗺️ How to Read the Chart

Acceptance Band = the zone around the broken level where price should hold if acceptance is developing.

Failure Shelf = the invalidation context behind the broken level. A close through this shelf means the breakout acceptance sequence needs review.

Target Room = a projected planning guide based on the prior reference range. It is not a forecast or promised target.

Labels = compact event markers such as BULL BRK, BEAR BRK, WATCH, HOLD, ACCEPT, TAG, RISK, and REJECT.

Colors = teal supports constructive acceptance, pink marks rejection or failure pressure, yellow marks caution, and indigo marks active watch states.

Panel = a compact decision view showing Acceptance Score, Time Beyond, Break Side, Failure Risk, and Action.


🚦 Signals & States

• BULL BRK → price closed beyond the upper reference and started an acceptance review.

• BEAR BRK → price closed beyond the lower reference and started an acceptance review.

• WATCH → acceptance evidence is improving but is not mature yet.

• HOLD → price revisited the acceptance band and held beyond the broken reference.

• ACCEPT → close persistence, score quality, and time beyond the level reached the accepted state.

• TAG → the sequence is active, but close persistence is still weak after the review window.

• RISK → acceptance is not mature and the failure shelf is becoming more relevant.

• REJECT → price closed through the failure shelf after the breakout sequence.


🔔 Alerts Logic

Alerts trigger when a new acceptance break starts, when accepted state appears, when a retest hold is detected, when failure risk rises, or when price rejects through the failure shelf.

Alerts are attention markers. They are not trade instructions, automation commands, or certainty statements.


🧩 Confluence Logic

The strongest acceptance context appears when several conditions align:

• price closes beyond the broken reference more than once
• the acceptance band holds during a retest
• candle structure remains directional
• failure shelf distance remains healthy
• volume support is present without being the only reason for the score

When these elements align, the Acceptance Score rises and the state becomes easier to interpret.


📊 When to Use

• Breakout review after price crosses a visible range edge
• Markets where one-bar breakout tags are common
• Trend continuation attempts that need acceptance confirmation
• Range expansion moves where the trader wants to separate holding behavior from weak level pokes
• Chart review workflows that need a clear post-break next-action state


⚠️ When NOT to Use

• Extremely low-liquidity markets with unreliable candles
• Very noisy symbols where reference edges are constantly pierced
• News-driven volatility where ATR buffers may become unstable
• Situations where the user expects automatic trade entries
• Markets where volume data is missing and volume support is treated as less useful


🎛️ Key Inputs

• Break Side → controls whether the planner evaluates bullish breaks, bearish breaks, or both.

• Reference Lookback → defines the prior-bar range used to map breakout reference edges.

• Close Beyond Level ATR → controls how far beyond the level price must close before a sequence starts.

• Acceptance Band ATR → controls the retest-hold zone around the broken level.

• Failure Shelf ATR → controls the invalidation context behind the broken level.

• Minimum Beyond Closes → controls how much close persistence is required before acceptance can mature.

• ACCEPTED Threshold → sets the minimum 0-100 score for accepted state.

• Label / Panel Controls → adjust visual density, placement, theme, and font size.


🖥️ Interface & Visual Design

The interface is designed to stay chart-first. The acceptance band and failure shelf show the current structure, while labels mark only meaningful state changes.

The panel uses the AGPro standard: a single blue merged header row, compact rows, clear state colors, adjustable location, adjustable theme, and normal font size by default.

The visual hierarchy is intentionally restrained so the chart looks active without becoming crowded.


🧪 Practical Usage Workflow

1. Read the panel to see the current Acceptance Score and action state.

2. Check whether price is holding beyond the broken reference or drifting back into the band.

3. Watch the failure shelf to understand whether the breakout is losing acceptance.

4. Review labels only as context markers, not as standalone decisions.

5. Confirm the broader market context before acting on any chart interpretation.


🔍 Interpretation Guidelines

Think of the script as a post-break acceptance reviewer.

A higher Acceptance Score means the breakout has stronger evidence of persistence according to the script model. A lower score means the move may still be early, weak, or vulnerable to failure.

The most useful reading is the relationship between time beyond the level, retest behavior, and failure shelf distance.


🚫 What This Script Is NOT

• Not a prediction engine
• Not financial advice
• Not an auto-trading system
• Not guaranteed signals
• Not a generic support/resistance map
• Not a consolidation breakout box tool
• Not a pure volume breakout detector
• Not a full break-retest scanner


⚠️ Limitations & Transparency

Breakout acceptance is sensitive to timeframe, volatility, liquidity, and symbol behavior.

The reference edges are rolling and can change as older bars leave the lookback window.

ATR-based buffers can expand or contract during volatile market conditions.

Relative volume may be less useful on symbols with limited or inconsistent volume data.


🧠 Market Context Notes

Acceptance after a breakout is often more useful than the initial break itself.

A level tag shows that price reached a reference. Acceptance shows whether price can keep spending time beyond that reference.

This distinction is the core purpose of the planner.


🧾 Use Case Examples

When price closes above a reference edge and then holds the acceptance band on a later retest, the script may shift from watch context toward stronger acceptance.

When price breaks a reference but quickly returns through the failure shelf, the script marks rejection context instead of treating the break as mature.

When price remains beyond the level but does not build enough persistence, the script can show TAG ONLY or FAILURE RISK.


🧱 System Philosophy

Acceptance Breakout Planner follows the AGPro decision-engine approach:

It does not ask users to react to a raw signal.

It organizes the chart into quality, state, risk, target-room context, and next-action review.


🔐 Non-Promise Statement

No script can remove uncertainty from markets.

No state, score, label, band, shelf, or alert guarantees future price behavior.


📉 Risk Disclosure

Trading involves risk.

This script is for educational and analytical use only.

It does not provide financial advice, investment advice, trade instructions, or guaranteed outcomes.

Users remain responsible for their own decisions, risk management, and market evaluation.


📚 Educational Note

Use the script to study the difference between a breakout tag and breakout acceptance.

The strongest value comes from comparing the planner state with broader structure, volatility, liquidity, and personal execution rules.

## Source Code

````pine
// -------------------------------------------------
// Acceptance Breakout Planner [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 1.8
//
// Acceptance Breakout Planner evaluates whether price truly accepts beyond a
// breakout reference or only tags the level and returns. It studies close
// persistence, time beyond the level, retest hold behavior, range distance,
// candle quality, volume support, failure shelf risk, and target room to build
// a 0-100 acceptance score with a clear next-action planning state.
// V1.8 replaces persistent historical reference traces with a current labeled
// reference map, separates the active acceptance and failure-shelf label lanes,
// and guarantees identity tags whenever a planning guide is visible without its
// companion zone. Core acceptance scoring and proof behavior remain unchanged.
// -------------------------------------------------

//@version=6
indicator("Acceptance Breakout Planner [AGPro Series]",
     shorttitle       = "AG Pro ABP",
     overlay          = true,
     max_labels_count = 160,
     max_boxes_count  = 50,
     max_lines_count  = 80)

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
darkText      = color.rgb(17, 24, 39)

// -------------------------------------------------
// Tooltips
// -------------------------------------------------
ttSide = "Selects which breakout side the planner can evaluate. Auto allows both bullish and bearish acceptance planning from rolling reference edges."
ttConfirm = "Close Confirmed updates labels and alerts only after the bar closes. Live Preview allows the active visual state to update during the current bar."
ttLookback = "Lookback used to build the current breakout reference edges from prior bars. This is a simple structural reference, not a consolidation box engine."
ttAtr = "ATR length used for buffers, acceptance band width, failure shelf distance, label offsets, and normalized distance scoring."
ttVol = "Volume baseline used only as a supporting acceptance component. The script is not a volume breakout clone."
ttBreakBuffer = "Minimum close distance beyond the reference edge, expressed in ATR, required before an acceptance sequence can start."
ttBand = "Half-width of the acceptance band around the broken level. Retests that hold this band improve acceptance quality."
ttFailure = "ATR distance behind the broken level used to draw the failure shelf. A close through this shelf moves the planner into rejection review."
ttTarget = "Projects a target-room guide from the broken reference using prior range height. This is a planning reference only."
ttMinBeyond = "Minimum number of closes beyond the broken level preferred before the state can become ACCEPTED."
ttMinBars = "Minimum elapsed bars after the break before the state can become ACCEPTED. This prevents one-bar tags from looking mature."
ttTagReview = "Number of active bars after which weak persistence is reviewed as TAG ONLY or FAILURE RISK."
ttAccepted = "Minimum 0-100 acceptance score required for ACCEPTED state. This is an attention state, not a trade command."
ttWatch = "Minimum 0-100 acceptance score required for WATCH ACCEPT state while the sequence is still building."
ttRisk = "Failure risk level that moves the planner into FAILURE RISK when acceptance is not mature."
ttUseVolume = "When enabled, relative volume contributes a small portion of the score. When disabled, the volume component is neutral."
ttRvol = "Relative volume level that earns strong volume support inside the acceptance score."
ttBandVisual = "Shows the acceptance band around the broken level with centered status text inside the band."
ttShelfVisual = "Shows the active failure shelf behind the broken level. It is an invalidation context guide, not a stop instruction."
ttTargetVisual = "Shows a target-room corridor with a separate centered premium badge. The corridor is a planning reference, not a forecast."
ttGuides = "Shows the broken reference and target-room guide while an acceptance sequence is active."
ttRefs = "Shows only the current rolling upper and lower reference edges before a breakout sequence starts. Each visible edge keeps a right-side identity tag; historical edge traces are not retained."
ttTint = "Tints active acceptance, watch, and rejection bars lightly so the state is readable without extra labels."
ttProjection = "Number of bars projected to the right for the acceptance band, failure shelf, target-room corridor, and planning guides."
ttOpacity = "Transparency for active acceptance and failure boxes. Higher values make the visual layer lighter."
ttLabels = "Shows compact BREAK, ACCEPTED, RETEST HOLD, TAG ONLY, and REJECTED labels. Labels are offset away from candles."
ttContextLabels = "Adds sparse context labels while acceptance is building. Disabled by default for a cleaner public-release chart."
ttLabelScore = "Adds the 0-100 acceptance score to chart labels. Disabled by default for cleaner publication screenshots."
ttCooldown = "Minimum bars between event labels. Higher values reduce label clusters."
ttContextSpacing = "Minimum bars between sparse context labels during active sequences."
ttMaxLabels = "Maximum number of event labels retained on the chart. Older labels are removed first for performance."
ttLabelOffset = "ATR-based vertical offset that keeps labels above or below candles."
ttLabelSize = "Font size for all chart labels and centered zone badges. Normal is the recommended publication default."
ttShowPanel = "Shows or hides the AG Pro planning panel. The default is visible for publication-ready context."
ttPanelLocation = "Moves the AG Pro panel to the preferred chart location."
ttPanelTheme = "Switches the panel between the AGPro dark theme and a clean light theme."
ttPanelFont = "Font size for the AG Pro panel. Normal is the recommended publication default."
ttAlerts = "Enables alert conditions for new break, accepted state, retest hold, failure risk, and rejected shelf states."

// -------------------------------------------------
// Inputs
// -------------------------------------------------
groupEngine = "Acceptance Engine"
sideMode = input.string("Auto", "Break Side", options = ["Auto", "Bullish Only", "Bearish Only"], group = groupEngine, tooltip = ttSide)
confirmationMode = input.string("Close Confirmed", "Confirmation Mode", options = ["Close Confirmed", "Live Preview"], group = groupEngine, tooltip = ttConfirm)
referenceLookback = input.int(34, "Reference Lookback", minval = 8, maxval = 240, group = groupEngine, tooltip = ttLookback)
atrLength = input.int(14, "ATR Length", minval = 5, maxval = 100, group = groupEngine, tooltip = ttAtr)
volumeLength = input.int(30, "Volume Baseline Length", minval = 5, maxval = 200, group = groupEngine, tooltip = ttVol)

groupAcceptance = "Acceptance Model"
breakBufferAtr = input.float(0.10, "Close Beyond Level ATR", minval = 0.00, maxval = 1.50, step = 0.01, group = groupAcceptance, tooltip = ttBreakBuffer)
acceptanceBandAtr = input.float(0.28, "Acceptance Band ATR", minval = 0.05, maxval = 1.50, step = 0.01, group = groupAcceptance, tooltip = ttBand)
failureShelfAtr = input.float(0.42, "Failure Shelf ATR", minval = 0.05, maxval = 2.50, step = 0.01, group = groupAcceptance, tooltip = ttFailure)
targetRangeMultiple = input.float(1.00, "Target Room Multiple", minval = 0.25, maxval = 4.00, step = 0.05, group = groupAcceptance, tooltip = ttTarget)
minBeyondCloses = input.int(3, "Minimum Beyond Closes", minval = 1, maxval = 12, group = groupAcceptance, tooltip = ttMinBeyond)
minAcceptanceBars = input.int(3, "Minimum Acceptance Bars", minval = 1, maxval = 20, group = groupAcceptance, tooltip = ttMinBars)
tagReviewBars = input.int(5, "Tag Review Bars", minval = 2, maxval = 40, group = groupAcceptance, tooltip = ttTagReview)
maxActiveBars = input.int(48, "Sequence Expiry Bars", minval = 10, maxval = 200, group = groupAcceptance, tooltip = "Maximum bars an acceptance sequence remains active before the planner waits for a fresh breakout reference.")
acceptedThreshold = input.int(72, "ACCEPTED Threshold", minval = 45, maxval = 95, group = groupAcceptance, tooltip = ttAccepted)
watchThreshold = input.int(54, "WATCH Threshold", minval = 25, maxval = 90, group = groupAcceptance, tooltip = ttWatch)
riskReviewThreshold = input.int(64, "Failure Risk Threshold", minval = 35, maxval = 95, group = groupAcceptance, tooltip = ttRisk)
useVolumeSupport = input.bool(true, "Use Volume Support", group = groupAcceptance, tooltip = ttUseVolume)
rvolFullScore = input.float(1.45, "Strong RVOL Level", minval = 0.60, maxval = 5.00, step = 0.05, group = groupAcceptance, tooltip = ttRvol)

groupVisual = "Chart Visuals"
showAcceptanceBand = input.bool(true, "Show Acceptance Band", group = groupVisual, tooltip = ttBandVisual)
showFailureShelf = input.bool(true, "Show Failure Shelf", group = groupVisual, tooltip = ttShelfVisual)
showTargetRoom = input.bool(true, "Show Target-Room Corridor", group = groupVisual, tooltip = ttTargetVisual)
showPlanningGuides = input.bool(true, "Show Risk / Target Guides", group = groupVisual, tooltip = ttGuides)
showReferenceEdges = input.bool(true, "Show Reference Edges", group = groupVisual, tooltip = ttRefs)
tintStateBars = input.bool(false, "Tint State Bars", group = groupVisual, tooltip = ttTint)
projectionBars = input.int(40, "Forward Projection Bars", minval = 8, maxval = 180, group = groupVisual, tooltip = ttProjection)
zoneTransparency = input.int(88, "Zone Transparency", minval = 68, maxval = 96, group = groupVisual, tooltip = ttOpacity)

groupLabels = "Labels"
showEventLabels = input.bool(true, "Show Event Labels", group = groupLabels, tooltip = ttLabels)
showContextLabels = input.bool(false, "Show Sparse Context Labels", group = groupLabels, tooltip = ttContextLabels)
showLabelScore = input.bool(false, "Show Label Score", group = groupLabels, tooltip = ttLabelScore)
labelCooldownBars = input.int(30, "Label Cooldown Bars", minval = 1, maxval = 120, group = groupLabels, tooltip = ttCooldown)
contextSpacingBars = input.int(96, "Context Label Spacing", minval = 6, maxval = 180, group = groupLabels, tooltip = ttContextSpacing)
maxVisibleLabels = input.int(7, "Max Visible Labels", minval = 4, maxval = 80, group = groupLabels, tooltip = ttMaxLabels)
labelOffsetAtr = input.float(1.05, "Label Offset ATR", minval = 0.10, maxval = 3.00, step = 0.05, group = groupLabels, tooltip = ttLabelOffset)
labelFontSize = input.string("Normal", "Label Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = groupLabels, tooltip = ttLabelSize)

groupPanel = "Panel"
showPanel = input.bool(true, "Show Panel", group = groupPanel, tooltip = ttShowPanel)
panelLocation = input.string("Top Right", "Panel Location", options = ["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], group = groupPanel, tooltip = ttPanelLocation)
panelTheme = input.string("Elite Dark", "Panel Theme", options = ["Elite Dark", "Clean Light"], group = groupPanel, tooltip = ttPanelTheme)
panelFontSize = input.string("Normal", "Panel Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = groupPanel, tooltip = ttPanelFont)

groupAlerts = "Alerts"
alertAcceptanceStates = input.bool(true, "Alert on Acceptance States", group = groupAlerts, tooltip = ttAlerts)

// -------------------------------------------------
// Helpers
// -------------------------------------------------
f_clamp(float value, float minValue, float maxValue) =>
    math.min(math.max(value, minValue), maxValue)

f_norm_high_good(float value, float weak, float strong) =>
    float span = strong - weak
    span == 0.0 ? 0.0 : f_clamp((value - weak) / span * 100.0, 0.0, 100.0)

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
        evenRow ? color.rgb(226, 232, 240) : color.rgb(248, 250, 252)
    else
        evenRow ? color.rgb(20, 31, 52) : panelBg

f_state_color(string stateText) =>
    switch stateText
        "ACCEPTED" => bullColor
        "WATCH ACCEPT" => accentColor
        "RETEST HOLD" => bullColor
        "FAILURE RISK" => neutralColor
        "TAG ONLY" => neutralColor
        "REJECTED" => bearColor
        => f_panel_value(panelTheme)

f_side_text(int sideValue) =>
    switch sideValue
        1 => "Bullish"
        -1 => "Bearish"
        => "Neutral"

f_fmt_score(float value) =>
    str.tostring(math.round(value))

f_fmt_atr(float value) =>
    na(value) ? "-" : str.tostring(value, "#.##") + " ATR"

f_grade(float value) =>
    string result = "D"
    if value >= 88
        result := "A+"
    else if value >= 78
        result := "A"
    else if value >= 66
        result := "B"
    else if value >= 54
        result := "C"
    result

f_score_grade(float value) =>
    f_fmt_score(value) + " " + f_grade(value)

f_text_on(color bgColor) =>
    float r = color.r(bgColor)
    float g = color.g(bgColor)
    float b = color.b(bgColor)
    float yiq = (r * 299.0 + g * 587.0 + b * 114.0) / 1000.0
    yiq >= 150.0 ? darkText : headerText

f_panel_row(table panelRef, int row, string leftText, string rightText, color rightColor, string theme, string textSize) =>
    color rowBg = f_row_bg(theme, row)
    table.cell(panelRef, 0, row, leftText, text_color = f_panel_label(theme), bgcolor = rowBg, text_size = f_text_size(textSize), text_halign = text.align_left)
    table.cell(panelRef, 1, row, rightText, text_color = rightColor, bgcolor = rowBg, text_size = f_text_size(textSize), text_halign = text.align_right)

f_trim_labels(array<label> labels, int maxCount) =>
    int labelCount = array.size(labels)
    if labelCount > maxCount
        int removeCount = labelCount - maxCount
        for idx = 0 to removeCount - 1
            label oldLabel = array.shift(labels)
            label.delete(oldLabel)

// -------------------------------------------------
// Core model
// -------------------------------------------------
bool allowBull = sideMode == "Auto" or sideMode == "Bullish Only"
bool allowBear = sideMode == "Auto" or sideMode == "Bearish Only"
bool closeConfirmed = confirmationMode == "Close Confirmed"
bool stateUpdateAllowed = closeConfirmed ? barstate.isconfirmed : true

float atrRaw = ta.atr(atrLength)
float safeAtr = math.max(nz(atrRaw, high - low), syminfo.mintick)
float volumeBase = ta.sma(volume, volumeLength)
float rvol = not na(volumeBase) and volumeBase > 0.0 ? volume / volumeBase : 1.0

float upperRefRaw = ta.highest(high[1], referenceLookback)
float lowerRefRaw = ta.lowest(low[1], referenceLookback)
bool validReference = not na(upperRefRaw) and not na(lowerRefRaw) and upperRefRaw > lowerRefRaw
float upperRef = validReference ? upperRefRaw : high
float lowerRef = validReference ? lowerRefRaw : low
float referenceHeight = math.max(upperRef - lowerRef, syminfo.mintick)

bool bullBreak = allowBull and validReference and close > upperRef + breakBufferAtr * safeAtr
bool bearBreak = allowBear and validReference and close < lowerRef - breakBufferAtr * safeAtr

var int activeSide = 0
var float activeLevel = na
var float activeHeight = na
var int activeStartBar = na
var int beyondCloseCount = 0
var int retestHoldCount = 0
var string lastPlannerState = "NO BREAK"
var int lastEventLabelBar = na
var int lastContextLabelBar = na
var int lastRetestLabelBar = na
var array<label> eventLabels = array.new_label()

int existingAge = activeSide != 0 and not na(activeStartBar) ? bar_index - activeStartBar : 0
bool canStartFresh = activeSide == 0 or existingAge > maxActiveBars or (bullBreak and activeSide == -1) or (bearBreak and activeSide == 1)
bool startBull = stateUpdateAllowed and bullBreak and canStartFresh
bool startBear = stateUpdateAllowed and bearBreak and canStartFresh and not startBull
bool newBreakEvent = startBull or startBear

if newBreakEvent
    activeSide := startBull ? 1 : -1
    activeLevel := startBull ? upperRef : lowerRef
    activeHeight := referenceHeight
    activeStartBar := bar_index
    beyondCloseCount := 0
    retestHoldCount := 0

bool activeSequence = activeSide != 0 and not na(activeLevel) and not na(activeStartBar)
int barsActive = activeSequence ? bar_index - activeStartBar : 0
float bandHalf = activeSequence ? safeAtr * acceptanceBandAtr : na
float bandTop = activeSequence ? activeLevel + bandHalf : na
float bandBottom = activeSequence ? activeLevel - bandHalf : na
float failureShelf = activeSequence ? activeLevel - activeSide * failureShelfAtr * safeAtr : na
float targetGuide = activeSequence ? activeLevel + activeSide * activeHeight * targetRangeMultiple : na
float signedCloseDistanceAtr = activeSequence ? (close - activeLevel) * activeSide / safeAtr : 0.0
bool closeBeyond = activeSequence and signedCloseDistanceAtr > 0.0
bool insideAcceptanceBand = activeSequence and high >= bandBottom and low <= bandTop
bool retestHold = activeSequence and barsActive > 0 and insideAcceptanceBand and closeBeyond
bool failureShelfBreak = activeSequence and ((activeSide == 1 and close < failureShelf) or (activeSide == -1 and close > failureShelf))

if barstate.isconfirmed and activeSequence
    if closeBeyond
        beyondCloseCount += 1
    if retestHold
        retestHoldCount += 1

float barRange = math.max(high - low, syminfo.mintick)
float bodyEfficiency = math.abs(close - open) / barRange
float directionalCloseLocation = activeSide == 1 ? (close - low) / barRange : activeSide == -1 ? (high - close) / barRange : 0.5
float directionalBody = activeSide == 1 and close >= open ? bodyEfficiency : activeSide == -1 and close <= open ? bodyEfficiency : bodyEfficiency * 0.35
float candleScore = f_clamp(directionalBody * 62.0 + directionalCloseLocation * 38.0, 0.0, 100.0)

float beyondSample = math.max(math.min(barsActive + 1, maxActiveBars), 1)
float persistenceRatio = f_clamp(beyondCloseCount / beyondSample, 0.0, 1.0)
float persistenceScore = f_clamp(f_norm_high_good(beyondCloseCount, 1.0, minBeyondCloses) * 0.72 + persistenceRatio * 100.0 * 0.28, 0.0, 100.0)
float retestScore = retestHoldCount > 0 ? 100.0 : retestHold ? 78.0 : closeBeyond ? 56.0 : 20.0
float distanceScore = f_norm_high_good(signedCloseDistanceAtr, breakBufferAtr, math.max(breakBufferAtr + 0.75, 0.85))
float volumeScore = useVolumeSupport ? f_norm_high_good(rvol, 0.75, rvolFullScore) : 70.0
float acceptanceScoreRaw = persistenceScore * 0.30 + retestScore * 0.25 + distanceScore * 0.20 + candleScore * 0.15 + volumeScore * 0.10
float acceptanceScore = activeSequence ? f_clamp(acceptanceScoreRaw, 0.0, 100.0) : 0.0

float shelfDistanceAtr = activeSequence ? (close - failureShelf) * activeSide / safeAtr : na
float shelfSafetyScore = activeSequence ? f_norm_high_good(shelfDistanceAtr, 0.10, 1.50) : 0.0
float failureRiskRaw = (100.0 - shelfSafetyScore) * 0.42 + (100.0 - persistenceScore) * 0.38 + (100.0 - candleScore) * 0.20
float failureRisk = activeSequence ? f_clamp(failureShelfBreak ? 100.0 : failureRiskRaw, 0.0, 100.0) : 0.0
float targetRoomAtr = activeSequence ? math.abs(targetGuide - close) / safeAtr : na

bool matureEnough = barsActive >= minAcceptanceBars and beyondCloseCount >= minBeyondCloses
bool acceptedNow = activeSequence and matureEnough and acceptanceScore >= acceptedThreshold and not failureShelfBreak
bool watchNow = activeSequence and closeBeyond and acceptanceScore >= watchThreshold and not acceptedNow and not failureShelfBreak
bool tagOnlyNow = activeSequence and barsActive >= tagReviewBars and beyondCloseCount < minBeyondCloses and not failureShelfBreak
bool failureRiskNow = activeSequence and failureRisk >= riskReviewThreshold and not acceptedNow and not failureShelfBreak

string plannerState = "NO BREAK"
if activeSequence
    if failureShelfBreak
        plannerState := "REJECTED"
    else if acceptedNow
        plannerState := "ACCEPTED"
    else if retestHold
        plannerState := "RETEST HOLD"
    else if failureRiskNow
        plannerState := "FAILURE RISK"
    else if tagOnlyNow
        plannerState := "TAG ONLY"
    else if watchNow
        plannerState := "WATCH ACCEPT"
    else
        plannerState := "BUILDING"

string actionState = "Wait For Close"
if plannerState == "ACCEPTED"
    actionState := "Review Continuation"
else if plannerState == "RETEST HOLD"
    actionState := "Review Hold"
else if plannerState == "WATCH ACCEPT"
    actionState := "Track Persistence"
else if plannerState == "FAILURE RISK"
    actionState := "Review Shelf"
else if plannerState == "TAG ONLY"
    actionState := "Wait For Proof"
else if plannerState == "REJECTED"
    actionState := "Re-map Context"
else if plannerState == "BUILDING"
    actionState := "Monitor Closes"

bool acceptedEvent = stateUpdateAllowed and plannerState == "ACCEPTED" and lastPlannerState != "ACCEPTED"
bool rejectedEvent = stateUpdateAllowed and plannerState == "REJECTED" and lastPlannerState != "REJECTED"
bool tagOnlyEvent = stateUpdateAllowed and plannerState == "TAG ONLY" and lastPlannerState != "TAG ONLY"
bool riskReviewEvent = stateUpdateAllowed and plannerState == "FAILURE RISK" and lastPlannerState != "FAILURE RISK"
bool retestHoldEvent = stateUpdateAllowed and retestHold and (na(lastRetestLabelBar) or bar_index - lastRetestLabelBar >= labelCooldownBars)
bool watchContextEvent = stateUpdateAllowed and showContextLabels and activeSequence and closeBeyond and not newBreakEvent and not acceptedEvent and not rejectedEvent and not tagOnlyEvent and not riskReviewEvent and not retestHoldEvent and (na(lastContextLabelBar) or bar_index - lastContextLabelBar >= contextSpacingBars)
bool renderSequence = activeSequence and not failureShelfBreak

// -------------------------------------------------
// Accept-rate proof (Confirm Rate)
// -------------------------------------------------
var int  acceptTotal   = 0
var int  acceptWon      = 0
var bool seqResolvable  = false
var bool seqAccepted    = false

if stateUpdateAllowed
    if newBreakEvent
        if seqResolvable
            acceptTotal += 1
            if seqAccepted
                acceptWon += 1
        seqResolvable := true
        seqAccepted := false
    if activeSequence and plannerState == "ACCEPTED"
        seqAccepted := true
    if seqResolvable and not newBreakEvent and activeSequence and (barsActive > maxActiveBars or failureShelfBreak)
        acceptTotal += 1
        if seqAccepted
            acceptWon += 1
        seqResolvable := false

float acceptRate = acceptTotal > 0 ? acceptWon / acceptTotal * 100.0 : na

// -------------------------------------------------
// Current labeled visual references
// -------------------------------------------------
var line upperRefLine = na
var line lowerRefLine = na
var label upperRefBadge = na
var label lowerRefBadge = na

bool renderReferenceMap = showReferenceEdges and activeSide == 0 and validReference
if renderReferenceMap
    int refLeft = math.max(bar_index - math.min(referenceLookback, 20), 0)
    int refRight = bar_index + 8
    string upperRefText = "UPPER REF\n" + str.tostring(upperRef, format.mintick)
    string lowerRefText = "LOWER REF\n" + str.tostring(lowerRef, format.mintick)
    if na(upperRefLine)
        upperRefLine := line.new(refLeft, upperRef, refRight, upperRef, xloc = xloc.bar_index, color = color.new(bullColor, 28), width = 2)
        lowerRefLine := line.new(refLeft, lowerRef, refRight, lowerRef, xloc = xloc.bar_index, color = color.new(bearColor, 28), width = 2)
        upperRefBadge := label.new(refRight, upperRef, upperRefText, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = color.new(bullColor, 0), textcolor = f_text_on(bullColor), size = f_text_size(labelFontSize), textalign = text.align_center)
        lowerRefBadge := label.new(refRight, lowerRef, lowerRefText, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = color.new(bearColor, 0), textcolor = f_text_on(bearColor), size = f_text_size(labelFontSize), textalign = text.align_center)
    else
        line.set_xy1(upperRefLine, refLeft, upperRef)
        line.set_xy2(upperRefLine, refRight, upperRef)
        line.set_xy1(lowerRefLine, refLeft, lowerRef)
        line.set_xy2(lowerRefLine, refRight, lowerRef)
        label.set_x(upperRefBadge, refRight)
        label.set_y(upperRefBadge, upperRef)
        label.set_text(upperRefBadge, upperRefText)
        label.set_size(upperRefBadge, f_text_size(labelFontSize))
        label.set_x(lowerRefBadge, refRight)
        label.set_y(lowerRefBadge, lowerRef)
        label.set_text(lowerRefBadge, lowerRefText)
        label.set_size(lowerRefBadge, f_text_size(labelFontSize))
else
    if not na(upperRefLine)
        line.delete(upperRefLine)
        line.delete(lowerRefLine)
        label.delete(upperRefBadge)
        label.delete(lowerRefBadge)
        upperRefLine := na
        lowerRefLine := na
        upperRefBadge := na
        lowerRefBadge := na

color stateColor = f_state_color(plannerState)
barcolor(tintStateBars and activeSequence ? color.new(stateColor, 72) : na)
int safeProjectionBars = math.min(projectionBars, 480)
int projectionRight = bar_index + safeProjectionBars

var box acceptanceBox = na
var box shelfBox = na
var box targetRoomBox = na
var label acceptanceBadge = na
var label shelfBadge = na
var label targetRoomBadge = na
var line levelLine = na
var line targetLine = na
var label levelGuideBadge = na
var label targetGuideBadge = na

if renderSequence and showAcceptanceBand
    color boxColor = activeSide == 1 ? bullColor : bearColor
    string compactState = plannerState == "WATCH ACCEPT" ? "WATCH" : plannerState == "RETEST HOLD" ? "HOLD" : plannerState == "FAILURE RISK" ? "RISK" : plannerState == "TAG ONLY" ? "TAG" : plannerState
    string bandText = compactState + "\n" + f_score_grade(acceptanceScore) + " / " + str.tostring(beyondCloseCount) + "c"
    float minReadableBand = safeAtr * math.max(acceptanceBandAtr * 3.20, 0.78)
    float visualBandHalf = math.max(bandHalf, minReadableBand * 0.5)
    float visualBandTop = activeLevel + visualBandHalf
    float visualBandBottom = activeLevel - visualBandHalf
    int bandBadgeX = int(math.round((activeStartBar + projectionRight) * 0.50))
    float bandBadgeY = (visualBandTop + visualBandBottom) * 0.50
    if na(acceptanceBox)
        acceptanceBox := box.new(left = activeStartBar, top = visualBandTop, right = projectionRight, bottom = visualBandBottom, xloc = xloc.bar_index, bgcolor = color.new(boxColor, zoneTransparency), border_color = color.new(boxColor, 18), text = "")
    else
        box.set_lefttop(acceptanceBox, activeStartBar, visualBandTop)
        box.set_rightbottom(acceptanceBox, projectionRight, visualBandBottom)
        box.set_bgcolor(acceptanceBox, color.new(boxColor, zoneTransparency))
        box.set_border_color(acceptanceBox, color.new(boxColor, 18))
        box.set_text(acceptanceBox, "")
    if na(acceptanceBadge)
        acceptanceBadge := label.new(bandBadgeX, bandBadgeY, bandText, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_center, color = color.new(boxColor, 0), textcolor = f_text_on(boxColor), size = f_text_size(labelFontSize), textalign = text.align_center)
    else
        label.set_x(acceptanceBadge, bandBadgeX)
        label.set_y(acceptanceBadge, bandBadgeY)
        label.set_text(acceptanceBadge, bandText)
        label.set_color(acceptanceBadge, color.new(boxColor, 0))
        label.set_textcolor(acceptanceBadge, f_text_on(boxColor))
        label.set_size(acceptanceBadge, f_text_size(labelFontSize))
else
    if not na(acceptanceBox)
        box.delete(acceptanceBox)
        acceptanceBox := na
    if not na(acceptanceBadge)
        label.delete(acceptanceBadge)
        acceptanceBadge := na

if renderSequence and showFailureShelf
    float shelfHalf = math.max(safeAtr * 0.055, safeAtr * 0.13)
    float shelfTop = failureShelf + shelfHalf
    float shelfBottom = failureShelf - shelfHalf
    int shelfLaneOffset = math.max(2, int(math.round(safeProjectionBars * 0.22)))
    int shelfLeft = math.min(bar_index + shelfLaneOffset, projectionRight - 2)
    int shelfBadgeX = int(math.round((shelfLeft + projectionRight) * 0.50))
    string shelfText = "RISK SHELF\n" + f_fmt_atr(shelfDistanceAtr)
    if na(shelfBox)
        shelfBox := box.new(left = shelfLeft, top = shelfTop, right = projectionRight, bottom = shelfBottom, xloc = xloc.bar_index, bgcolor = color.new(dangerColor, 92), border_color = color.new(dangerColor, 30), text = "")
    else
        box.set_lefttop(shelfBox, shelfLeft, shelfTop)
        box.set_rightbottom(shelfBox, projectionRight, shelfBottom)
        box.set_bgcolor(shelfBox, color.new(dangerColor, 92))
        box.set_border_color(shelfBox, color.new(dangerColor, 30))
        box.set_text(shelfBox, "")
    if na(shelfBadge)
        shelfBadge := label.new(shelfBadgeX, failureShelf, shelfText, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_center, color = color.new(dangerColor, 0), textcolor = headerText, size = f_text_size(labelFontSize), textalign = text.align_center)
    else
        label.set_x(shelfBadge, shelfBadgeX)
        label.set_y(shelfBadge, failureShelf)
        label.set_text(shelfBadge, shelfText)
        label.set_color(shelfBadge, color.new(dangerColor, 0))
        label.set_textcolor(shelfBadge, headerText)
        label.set_size(shelfBadge, f_text_size(labelFontSize))
else
    if not na(shelfBox)
        box.delete(shelfBox)
        shelfBox := na
    if not na(shelfBadge)
        label.delete(shelfBadge)
        shelfBadge := na

if renderSequence and showTargetRoom
    float targetHalf = safeAtr * math.max(acceptanceBandAtr * 0.40, 0.08)
    float targetTop = targetGuide + targetHalf
    float targetBottom = targetGuide - targetHalf
    string targetText = "TARGET ROOM\n" + f_fmt_atr(targetRoomAtr)
    int targetBadgeX = int(math.round((bar_index + projectionRight) * 0.50))
    if na(targetRoomBox)
        targetRoomBox := box.new(left = bar_index, top = targetTop, right = projectionRight, bottom = targetBottom, xloc = xloc.bar_index, bgcolor = color.new(accentColor, 92), border_color = color.new(accentColor, 38), text = "")
    else
        box.set_lefttop(targetRoomBox, bar_index, targetTop)
        box.set_rightbottom(targetRoomBox, projectionRight, targetBottom)
        box.set_bgcolor(targetRoomBox, color.new(accentColor, 92))
        box.set_border_color(targetRoomBox, color.new(accentColor, 38))
        box.set_text(targetRoomBox, "")
    if na(targetRoomBadge)
        targetRoomBadge := label.new(targetBadgeX, targetGuide, targetText, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_center, color = color.new(accentColor, 0), textcolor = headerText, size = f_text_size(labelFontSize), textalign = text.align_center)
    else
        label.set_x(targetRoomBadge, targetBadgeX)
        label.set_y(targetRoomBadge, targetGuide)
        label.set_text(targetRoomBadge, targetText)
        label.set_color(targetRoomBadge, color.new(accentColor, 0))
        label.set_textcolor(targetRoomBadge, headerText)
        label.set_size(targetRoomBadge, f_text_size(labelFontSize))
else
    if not na(targetRoomBox)
        box.delete(targetRoomBox)
        targetRoomBox := na
    if not na(targetRoomBadge)
        label.delete(targetRoomBadge)
        targetRoomBadge := na

if renderSequence and showPlanningGuides
    color levelGuideColor = showAcceptanceBand ? color.new(accentColor, 100) : color.new(accentColor, 0)
    int levelGuideWidth = showAcceptanceBand ? 1 : 3
    if na(levelLine)
        levelLine := line.new(activeStartBar, activeLevel, projectionRight, activeLevel, xloc = xloc.bar_index, color = levelGuideColor, width = levelGuideWidth)
    else
        line.set_xy1(levelLine, activeStartBar, activeLevel)
        line.set_xy2(levelLine, projectionRight, activeLevel)
        line.set_color(levelLine, levelGuideColor)
        line.set_width(levelLine, levelGuideWidth)
    if na(targetLine)
        targetLine := line.new(activeStartBar, targetGuide, projectionRight, targetGuide, xloc = xloc.bar_index, color = color.new(neutralColor, 10), width = 2, style = line.style_dashed)
    else
        line.set_xy1(targetLine, activeStartBar, targetGuide)
        line.set_xy2(targetLine, projectionRight, targetGuide)
        line.set_color(targetLine, color.new(neutralColor, 10))
        line.set_width(targetLine, 2)

    if not showAcceptanceBand
        string levelGuideText = "BREAK REF\n" + str.tostring(activeLevel, format.mintick)
        if na(levelGuideBadge)
            levelGuideBadge := label.new(projectionRight, activeLevel, levelGuideText, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = color.new(accentColor, 0), textcolor = headerText, size = f_text_size(labelFontSize), textalign = text.align_center)
        else
            label.set_x(levelGuideBadge, projectionRight)
            label.set_y(levelGuideBadge, activeLevel)
            label.set_text(levelGuideBadge, levelGuideText)
            label.set_size(levelGuideBadge, f_text_size(labelFontSize))
    else if not na(levelGuideBadge)
        label.delete(levelGuideBadge)
        levelGuideBadge := na

    if not showTargetRoom
        string targetGuideText = "TARGET\n" + str.tostring(targetGuide, format.mintick)
        if na(targetGuideBadge)
            targetGuideBadge := label.new(projectionRight, targetGuide, targetGuideText, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = color.new(neutralColor, 0), textcolor = f_text_on(neutralColor), size = f_text_size(labelFontSize), textalign = text.align_center)
        else
            label.set_x(targetGuideBadge, projectionRight)
            label.set_y(targetGuideBadge, targetGuide)
            label.set_text(targetGuideBadge, targetGuideText)
            label.set_size(targetGuideBadge, f_text_size(labelFontSize))
    else if not na(targetGuideBadge)
        label.delete(targetGuideBadge)
        targetGuideBadge := na
else
    if not na(levelLine)
        line.delete(levelLine)
        levelLine := na
    if not na(targetLine)
        line.delete(targetLine)
        targetLine := na
    if not na(levelGuideBadge)
        label.delete(levelGuideBadge)
        levelGuideBadge := na
    if not na(targetGuideBadge)
        label.delete(targetGuideBadge)
        targetGuideBadge := na

// -------------------------------------------------
// Labels
// -------------------------------------------------
f_add_event_label(string textValue, float yValue, bool isAbove, color bgColor) =>
    label newLabel = label.new(bar_index, yValue, textValue, xloc = xloc.bar_index, yloc = yloc.price, style = isAbove ? label.style_label_down : label.style_label_up, color = color.new(bgColor, 8), textcolor = f_text_on(bgColor), size = f_text_size(labelFontSize))
    array.push(eventLabels, newLabel)
    f_trim_labels(eventLabels, maxVisibleLabels)

string scoreSuffix = showLabelScore ? "\n" + f_fmt_score(acceptanceScore) + " " + f_grade(acceptanceScore) : ""
bool labelAbove = activeSide == 1
float labelY = labelAbove ? high + safeAtr * labelOffsetAtr : low - safeAtr * labelOffsetAtr

if showEventLabels and newBreakEvent
    string breakText = activeSide == 1 ? "BULL BRK" : "BEAR BRK"
    f_add_event_label(breakText + scoreSuffix, labelY, labelAbove, activeSide == 1 ? bullColor : bearColor)
    lastEventLabelBar := bar_index

bool labelCooldownReady = na(lastEventLabelBar) or bar_index - lastEventLabelBar >= labelCooldownBars
if showEventLabels and acceptedEvent and labelCooldownReady
    f_add_event_label("ACCEPT" + scoreSuffix, labelY, labelAbove, bullColor)
    lastEventLabelBar := bar_index
if showEventLabels and retestHoldEvent and labelCooldownReady
    f_add_event_label("HOLD" + scoreSuffix, labelY, labelAbove, accentColor)
    lastRetestLabelBar := bar_index
    lastEventLabelBar := bar_index
if showEventLabels and riskReviewEvent and labelCooldownReady
    f_add_event_label("RISK" + scoreSuffix, labelY, labelAbove, neutralColor)
    lastEventLabelBar := bar_index
if showEventLabels and tagOnlyEvent and labelCooldownReady
    f_add_event_label("TAG" + scoreSuffix, labelY, labelAbove, neutralColor)
    lastEventLabelBar := bar_index
if showEventLabels and rejectedEvent and labelCooldownReady
    f_add_event_label("REJECT" + scoreSuffix, labelY, labelAbove, bearColor)
    lastEventLabelBar := bar_index
if showEventLabels and watchContextEvent
    f_add_event_label("WATCH" + scoreSuffix, labelY, labelAbove, accentColor)
    lastContextLabelBar := bar_index

// -------------------------------------------------
// Data window
// -------------------------------------------------
plot(acceptanceScore, title = "Acceptance Score", color = stateColor, display = display.data_window)
plot(acceptRate, title = "Accept Rate", color = accentColor, display = display.data_window)
plot(failureRisk, title = "Failure Risk", color = failureRisk >= riskReviewThreshold ? bearColor : neutralColor, display = display.data_window)
plot(targetRoomAtr, title = "Target Room ATR", color = accentColor, display = display.data_window)
plot(rvol, title = "Relative Volume", color = rvol >= 1.0 ? bullColor : neutralColor, display = display.data_window)

// -------------------------------------------------
// Panel
// -------------------------------------------------
var table panel = na
var string lastPanelLocation = ""
var string lastPanelTheme = ""

if barstate.islast
    if showPanel
        if na(panel) or lastPanelLocation != panelLocation or lastPanelTheme != panelTheme
            if not na(panel)
                table.delete(panel)
            panel := table.new(f_panel_pos(panelLocation), 2, 8, bgcolor = f_panel_bg(panelTheme), frame_color = f_panel_border(panelTheme), frame_width = 1, border_width = 1, border_color = f_panel_border(panelTheme))
            lastPanelLocation := panelLocation
            lastPanelTheme := panelTheme
        table.clear(panel, 0, 0, 1, 7)
        table.merge_cells(panel, 0, 0, 1, 0)
        table.cell(panel, 0, 0, "AG Pro Acceptance Breakout Planner", text_color = headerText, bgcolor = headerBg, text_size = f_text_size(panelFontSize), text_halign = text.align_center)
        string scoreRead = activeSequence ? f_score_grade(acceptanceScore) : "-"
        string acceptRateRead = acceptTotal > 0 ? str.tostring(int(math.round(acceptRate))) + "% (" + str.tostring(acceptTotal) + ")" : "Building"
        color acceptRateColor = na(acceptRate) ? f_panel_value(panelTheme) : acceptRate >= 55.0 ? bullColor : acceptRate >= 45.0 ? neutralColor : bearColor
        string timeRead = activeSequence ? str.tostring(beyondCloseCount) + " closes / " + str.tostring(barsActive) + " bars" : "-"
        string sideRead = f_side_text(activeSide)
        string riskRead = activeSequence ? f_fmt_score(failureRisk) + " / " + f_fmt_atr(shelfDistanceAtr) : "-"
        string roomRead = activeSequence ? f_fmt_atr(targetRoomAtr) : "-"
        f_panel_row(panel, 1, "Acceptance Score", scoreRead, activeSequence ? stateColor : f_panel_value(panelTheme), panelTheme, panelFontSize)
        f_panel_row(panel, 2, "Accept Rate", acceptRateRead, acceptRateColor, panelTheme, panelFontSize)
        f_panel_row(panel, 3, "Time Beyond", timeRead, activeSequence and beyondCloseCount >= minBeyondCloses ? bullColor : neutralColor, panelTheme, panelFontSize)
        f_panel_row(panel, 4, "Break Side", sideRead, activeSide == 1 ? bullColor : activeSide == -1 ? bearColor : f_panel_value(panelTheme), panelTheme, panelFontSize)
        f_panel_row(panel, 5, "Failure Risk", riskRead, failureRisk >= riskReviewThreshold ? bearColor : activeSequence ? neutralColor : f_panel_value(panelTheme), panelTheme, panelFontSize)
        f_panel_row(panel, 6, "Target Room", roomRead, activeSequence ? accentColor : f_panel_value(panelTheme), panelTheme, panelFontSize)
        f_panel_row(panel, 7, "Action", actionState, stateColor, panelTheme, panelFontSize)
    else
        if not na(panel)
            table.delete(panel)
            panel := na
            lastPanelLocation := ""
            lastPanelTheme := ""

// -------------------------------------------------
// Alerts
// -------------------------------------------------
alertcondition(alertAcceptanceStates and newBreakEvent, title = "New Acceptance Break", message = "Acceptance Breakout Planner: price closed beyond a breakout reference and started an acceptance review.")
alertcondition(alertAcceptanceStates and acceptedEvent, title = "Accepted Beyond Level", message = "Acceptance Breakout Planner: close persistence and acceptance quality reached the accepted state. This is an attention marker, not a trade instruction.")
alertcondition(alertAcceptanceStates and retestHoldEvent, title = "Retest Hold", message = "Acceptance Breakout Planner: price revisited the acceptance band and held beyond the broken reference.")
alertcondition(alertAcceptanceStates and riskReviewEvent, title = "Failure Risk Review", message = "Acceptance Breakout Planner: acceptance is not mature and failure risk has increased.")
alertcondition(alertAcceptanceStates and rejectedEvent, title = "Rejected Through Failure Shelf", message = "Acceptance Breakout Planner: price crossed the failure shelf after a breakout acceptance sequence.")

if stateUpdateAllowed
    lastPlannerState := plannerState

if stateUpdateAllowed and activeSequence and (barsActive > maxActiveBars or failureShelfBreak)
    activeSide := 0
    activeLevel := na
    activeHeight := na
    activeStartBar := na
    beyondCloseCount := 0
    retestHoldCount := 0
    lastPlannerState := "NO BREAK"
````
