# Expansion Target Planner [AGPro Series]

- url: https://www.tradingview.com/script/2dFCj0mZ-Expansion-Target-Planner-AGPro-Series/
- type: indicator
- pine_id: PUB;70d458246e0246a59cb8dd29c4405ff7
- version: 4.0

## Description

Expansion Target Planner [AGPro Series]

🧠 Core Idea

After expansion is confirmed, where is the reasonable target band, how clean is the path, and what should be reviewed next?


📌 Overview / What it does

Expansion Target Planner [AGPro Series] is a chart-first risk-target planning tool designed to evaluate the target area after a confirmed range expansion.

Instead of drawing a generic target line or copying a measured-move pattern, the script studies the prior range edge, current ATR, continuation pressure, recent structure obstacles, volatility state, and an invalidation shelf behind the move. It then converts that context into a 0-100 Target Quality score and a clear next-action state.

The output is a practical planning workflow: an expansion target band, invalidation shelf, target midpoint guide, path obstruction marker, compact chart labels, alert conditions, and a clean AGPro decision panel. It does not predict the future, automate decisions, or guarantee that any target band will be reached.


🎯 Purpose & Design Philosophy

This script was built for traders who need a cleaner way to evaluate expansion targets after price has already shown confirmation.

Many tools focus on finding a breakout, drawing an equal measured move, or plotting fixed take-profit levels. This tool fills a different gap: it asks whether the next target area is reasonable, whether the path is blocked, and whether the invalidation reference still supports the plan.

The design supports a disciplined target-review mindset. It helps users separate a clean expansion path from a stretched, obstructed, expired, or invalidated plan.


⚡ Why This Script Is Different

Most tools focus on measured moves, ABCD projections, fixed target ladders, or generic breakout confirmation.

This script does NOT become a measured-move projection tool, ABCD pattern detector, take-profit ladder, auto trading system, or generic support/resistance map.

Instead, it builds one active expansion target plan after confirmation and evaluates the quality of that plan. The core output is not a trade command. It is a planning state that helps users review whether the target band, invalidation shelf, volatility, and structure path still make sense.


⚙️ Methodology

1. Context Detection
The script identifies whether price has confirmed expansion beyond a prior range edge. Users can keep the side on Auto or force Long Expansion / Short Expansion.

2. Reference Mapping
Once confirmation appears, the script locks an active target plan. It maps the expansion anchor, ATR-adjusted target distance, target band, invalidation shelf, and recent pivot-based path obstacle.

3. Reaction Evaluation
The script scores the plan using expansion strength, ATR projection fit, nearby structure, continuation pressure, volume support, trend support, and volatility state.

4. Visual Output
The chart displays the active target band, invalidation shelf, guide lines, obstruction marker, event labels, alerts, and AGPro panel state.


🗺️ How to Read the Chart

Zones = the forward target band and the invalidation shelf behind the expansion.

Labels = the current target planning state, such as TARGET READY, WATCH, OBSTRUCTED, TARGET HIT, or INVALID REVIEW.

Colors = green/teal supports cleaner bullish expansion quality, pink marks bearish or risk states, yellow marks caution or obstruction, and indigo is used as a neutral planning accent.

Panel = the compact decision view showing Expansion Side, Target Band, Invalidation, Target Quality, and Action.


🚦 Signals & States

• TARGET READY → the target band has acceptable quality and the path is clean enough for review.

• WATCH → target context is improving, but not enough conditions are aligned yet.

• OBSTRUCTED → a recent structure obstacle sits between current price and the target band.

• TARGET HIT → price has interacted with the active target band.

• INVALID REVIEW → price has crossed the invalidation shelf and the plan should be reviewed.

• EXPIRED → the active plan has spent too many bars without completing.


🔔 Alerts Logic

Alerts trigger when the active target state changes into an important review condition.

• Target Ready alert → target quality moves into a stronger review state.

• Target Watch alert → target context improves but remains incomplete.

• Path Obstructed alert → a structure obstacle blocks the target path.

• Target Band Touched alert → price reaches the active target band.

• Invalidation Review alert → price crosses the invalidation shelf.

Alerts are attention markers, not trade instructions.


🧩 Confluence Logic

The Target Quality score improves when expansion confirmation, ATR projection fit, continuation pressure, volume support, volatility state, and open structure path align.

When the target distance is reasonable, the close is efficient, volume supports the move, and no nearby obstacle blocks the path, the context becomes stronger.


📊 When to Use

• After confirmed range expansion

• During breakout continuation review

• When evaluating whether a target area is too close, too far, or structurally blocked

• When a trader wants target context without a fixed take-profit ladder

• During volatility expansion phases where target planning matters more than another signal


⚠️ When NOT to Use

• Very low-liquidity markets

• Extremely noisy sideways chop

• News-driven spikes where ATR and structure become unstable

• Markets with unreliable volume if volume support is central to your process

• Any situation where the user expects automatic trade instructions


🎛️ Key Inputs

• Expansion Side → Auto, Long Expansion, or Short Expansion planning.

• Prior Range Lookback → defines the range edge used for confirmation.

• Confirmation Break ATR → controls how far beyond the range edge price must close.

• Range Projection Multiple → adjusts how much prior range width contributes to the target distance.

• ATR Projection Multiple → adjusts how much current volatility contributes to the target distance.

• Target Band Width ATR → controls the visual width of the target band.

• Invalidation Shelf Lookback → defines the reference shelf behind the expansion.

• TARGET READY / WATCH thresholds → control how selective the state engine is.

• Visual settings → control target band, shelf, guide lines, obstruction marker, labels, panel location, theme, and font sizes.


🖥️ Interface & Visual Design

The interface is built around one active target plan.

The target band is displayed forward on the chart with centered text. The invalidation shelf is shown behind the move so the risk reference is visible without turning the script into a generic support/resistance tool.

The panel follows the AGPro public-release standard with one merged blue header row containing only the script name. The layout is compact and designed for quick reading during live chart review.


🧪 Practical Usage Workflow

1. Read the panel to identify the active Expansion Side and Target Quality.

2. Check whether the target band is clean or obstructed.

3. Review the invalidation shelf behind the expansion.

4. Use labels and alerts as attention markers.

5. Confirm the broader market context with your own process.


🔍 Interpretation Guidelines

Treat the target band as a planning area, not a guaranteed destination.

A higher Target Quality score means the target plan is cleaner according to the script rules. It does not mean the move must continue.

An OBSTRUCTED state does not mean price cannot move through the obstacle. It means the path contains structure that deserves review.

An INVALID REVIEW state means the active shelf has been crossed and the plan context has changed.


🚫 What This Script Is NOT

• Not a prediction engine

• Not financial advice

• Not auto trading

• Not guaranteed signals

• Not a measured-move projection system

• Not an ABCD pattern scanner

• Not a take-profit ladder


⚠️ Limitations & Transparency

• Timeframe differences can change expansion quality and target distance.

• Volatility shifts can make a previously clean target band less useful.

• Recent structure may not capture every important higher-timeframe obstacle.

• Volume-based scoring can be less useful on symbols with unreliable volume.

• No rule-based tool can fully account for news, liquidity shocks, or sudden regime changes.


🧠 Market Context Notes

Expansion targets are more useful when the market has already shown range release and the target path is not immediately blocked by nearby structure.

Liquidity, volatility, and structure should be read together. A target band can look reasonable by distance but still become lower quality if the path is obstructed or volatility becomes overheated.


🧾 Use Case Examples

When price closes beyond a prior range edge with strong close location and the target path is open, the script may show TARGET READY.

When price expands but a recent pivot sits directly between current price and the target band, the script may show OBSTRUCTED.

When price crosses the invalidation shelf behind the plan, the script may show INVALID REVIEW.


🧱 System Philosophy

AGPro Series tools are designed to support structured decision review, not emotional signal chasing.

This script follows that philosophy by focusing on target quality, invalidation context, and next-action state rather than a simple directional signal.


🔐 Non-Promise Statement

No target band is certain.

No score guarantees continuation.

No alert should be treated as a trade instruction.


📉 Risk Disclosure

Trading involves risk.

Users are responsible for their own decisions, position sizing, risk controls, and market interpretation.

This script is for educational and analytical use only and does not provide financial advice.


📚 Educational Note

Use this tool to study how target quality changes after expansion confirmation.

The strongest value comes from comparing the target band, obstruction marker, invalidation shelf, and broader market context together.

## Source Code

````pine
// -------------------------------------------------
// Expansion Target Planner [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 1.3
//
// Expansion Target Planner is a chart-first risk-target planning engine that
// evaluates the practical target band after a confirmed expansion. It studies
// prior range release, ATR-based projection distance, nearby structure,
// continuation pressure, volatility state, and an active invalidation shelf to
// produce a 0-100 target quality score and a clear next-action panel. This is
// an analytical visualization tool, not a prediction engine, not automation,
// and not financial advice.
// V1.3 locks plan quality at confirmation, adds confirmed terminal resolution,
// and refines the target, shelf, label and panel hierarchy while preserving the
// expansion, projection, obstruction and proof models.
// -------------------------------------------------

//@version=6
indicator("Expansion Target Planner [AGPro Series]",
     shorttitle = "AG ETP",
     overlay = true,
     max_labels_count = 40,
     max_boxes_count = 4,
     max_lines_count = 10)

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
ttSide = "Selects the expansion side. Auto reads the active range release first, then falls back to trend context while waiting for confirmation."
ttConfirm = "When enabled, new plans, labels, and alerts are confirmed only after the bar closes. This keeps public chart behavior stable."
ttAtrLen = "ATR length used for target-band width, invalidation buffers, projection distance, volatility scoring, and label offsets."
ttAtrBase = "Longer ATR baseline used to judge whether current volatility is too quiet, constructive, or overheated."
ttRange = "Lookback used to define the prior range edge before expansion. This is not a measured-move impulse leg."
ttStructure = "Pivot strength used to confirm structure obstacles. Higher values require cleaner pivots before an obstacle can affect target quality."
ttStructureMemory = "Maximum number of confirmed pivot obstacles retained for path-quality review. This is a compact memory list, not a support/resistance map."
ttInvalid = "Lookback used to find the active invalidation shelf behind the expansion. The shelf is a planning reference, not a stop recommendation."
ttFast = "Fast EMA used for continuation pressure and automatic side selection. It does not create buy or sell signals."
ttSlow = "Slow EMA used for continuation pressure and trend context."
ttVolume = "Volume baseline used to evaluate participation. On symbols without reliable volume, this component becomes neutral."
ttBreak = "ATR buffer required beyond the prior range edge before the script creates a new expansion target plan."
ttRangeMult = "Projection distance contribution from the prior range width. This is blended with ATR distance and capped to avoid measured-move cloning."
ttAtrMult = "ATR projection contribution used to keep the target band proportional to current volatility."
ttMinTarget = "Minimum target distance in ATR units. Very close targets usually provide weak planning value."
ttIdealTarget = "Preferred target distance in ATR units for the highest projection-fit score."
ttMaxTarget = "Maximum target distance in ATR units. Excessively far target bands reduce practical quality."
ttBand = "Width of the target band in ATR units. Wider bands make the target area more forgiving, narrower bands make it more selective."
ttShelfBuffer = "ATR padding around the invalidation shelf. This creates the shelf zone shown behind the expansion."
ttViolation = "ATR padding beyond the invalidation shelf required before an invalidation review state is triggered."
ttHot = "ATR ratio above this value is treated as overheated expansion risk. Higher values allow stronger volatility before quality is reduced."
ttReady = "Minimum 0-100 target quality score required for Target Ready. This is an attention state, not a trading instruction."
ttWatch = "Minimum 0-100 target quality score required for Watch. Watch means the target path is improving but not fully clean."
ttPlanCooldown = "Minimum bars between new target plans. Higher values prevent repeated plans during the same expansion leg."
ttExpire = "Maximum bars an active target plan can remain open before it becomes expired."
ttResolved = "Number of bars a confirmed Target Hit, Invalid Review or Expired plan remains visible before the planner clears it and returns to fresh expansion monitoring."
ttTargetBand = "Shows the forward expansion target band with a separate centered status badge."
ttShelf = "Shows the invalidation shelf zone behind the expansion with a separate centered shelf badge."
ttGuides = "Shows the confirmation edge, target midpoint, and invalidation guides."
ttObstacle = "Shows a path obstruction marker when a confirmed pivot sits between current price and the target band."
ttProjection = "Number of bars projected to the right for target band, invalidation shelf, and guide lines."
ttZoneOpacity = "Transparency for target and shelf zones. Higher values make the zones lighter."
ttLabels = "Shows compact Target Ready, Watch, Obstructed, Target Hit, and Invalid Review labels. Labels are offset away from candles."
ttContext = "Adds sparse context labels during an active target plan so public screenshots remain informative without becoming crowded."
ttCooldown = "Minimum bars between chart labels. Higher values reduce label density."
ttContextSpacing = "Minimum bars between sparse context labels during ongoing target planning."
ttMaxLabels = "Maximum number of chart labels retained. Older labels are removed first to preserve performance."
ttLabelOffset = "ATR-based vertical offset that keeps labels above or below candles."
ttLabelScore = "Adds the 0-100 target quality score to chart labels."
ttLabelDetails = "Adds progress and obstruction context to chart labels. Disabled by default to keep screenshots clean."
ttLabelSize = "Font size for chart labels and centered zone badges. Normal is the recommended publication default."
ttShowPanel = "Shows or hides the AGPro planning panel. It is shown by default for public-release readability."
ttPanelLocation = "Moves the panel to the preferred chart location."
ttPanelTheme = "Switches the panel between AGPro dark and clean light themes."
ttPanelFont = "Font size for the AGPro panel. Normal is the recommended publication default."

// -------------------------------------------------
// Inputs
// -------------------------------------------------
groupEngine = "Target Engine"
sideMode = input.string("Auto", "Expansion Side", options = ["Auto", "Long Expansion", "Short Expansion"], group = groupEngine, tooltip = ttSide)
confirmOnClose = input.bool(true, "Confirm On Bar Close", group = groupEngine, tooltip = ttConfirm)
atrLen = input.int(14, "ATR Length", minval = 2, maxval = 100, group = groupEngine, tooltip = ttAtrLen)
atrBaseLen = input.int(55, "ATR Context Baseline", minval = 10, maxval = 300, group = groupEngine, tooltip = ttAtrBase)
rangeLookback = input.int(34, "Prior Range Lookback", minval = 8, maxval = 220, group = groupEngine, tooltip = ttRange)
structurePivot = input.int(4, "Structure Pivot Strength", minval = 1, maxval = 20, group = groupEngine, tooltip = ttStructure)
structureMemoryLimit = input.int(48, "Structure Memory Levels", minval = 8, maxval = 80, group = groupEngine, tooltip = ttStructureMemory)
invalidationLookback = input.int(28, "Invalidation Shelf Lookback", minval = 6, maxval = 220, group = groupEngine, tooltip = ttInvalid)
fastEmaLen = input.int(21, "Fast Context EMA", minval = 1, maxval = 200, group = groupEngine, tooltip = ttFast)
slowEmaLen = input.int(55, "Slow Context EMA", minval = 2, maxval = 300, group = groupEngine, tooltip = ttSlow)
volumeLen = input.int(34, "Volume Support Length", minval = 5, maxval = 200, group = groupEngine, tooltip = ttVolume)

groupScoring = "Target Quality Scoring"
breakBufferAtr = input.float(0.18, "Confirmation Break ATR", minval = 0.01, maxval = 2.00, step = 0.01, group = groupScoring, tooltip = ttBreak)
rangeProjectionMultiple = input.float(0.72, "Range Projection Multiple", minval = 0.10, maxval = 2.50, step = 0.05, group = groupScoring, tooltip = ttRangeMult)
atrProjectionMultiple = input.float(2.15, "ATR Projection Multiple", minval = 0.25, maxval = 6.00, step = 0.05, group = groupScoring, tooltip = ttAtrMult)
minTargetAtr = input.float(1.15, "Minimum Target Distance ATR", minval = 0.20, maxval = 5.00, step = 0.05, group = groupScoring, tooltip = ttMinTarget)
idealTargetAtr = input.float(2.45, "Ideal Target Distance ATR", minval = 0.50, maxval = 8.00, step = 0.05, group = groupScoring, tooltip = ttIdealTarget)
maxTargetAtr = input.float(4.80, "Maximum Target Distance ATR", minval = 1.00, maxval = 12.00, step = 0.10, group = groupScoring, tooltip = ttMaxTarget)
targetBandAtr = input.float(0.58, "Target Band Width ATR", minval = 0.10, maxval = 2.50, step = 0.05, group = groupScoring, tooltip = ttBand)
shelfBufferAtr = input.float(0.32, "Invalidation Shelf Buffer ATR", minval = 0.05, maxval = 2.00, step = 0.01, group = groupScoring, tooltip = ttShelfBuffer)
violationBufferAtr = input.float(0.24, "Invalidation Review Buffer ATR", minval = 0.03, maxval = 1.50, step = 0.01, group = groupScoring, tooltip = ttViolation)
hotAtrRatio = input.float(2.35, "Hot Expansion Risk", minval = 1.10, maxval = 5.00, step = 0.05, group = groupScoring, tooltip = ttHot)
readyThreshold = input.int(74, "Target Ready Threshold", minval = 40, maxval = 95, group = groupScoring, tooltip = ttReady)
watchThreshold = input.int(56, "Watch Threshold", minval = 20, maxval = 90, group = groupScoring, tooltip = ttWatch)
planCooldownBars = input.int(22, "New Plan Cooldown Bars", minval = 1, maxval = 180, group = groupScoring, tooltip = ttPlanCooldown)
planExpireBars = input.int(72, "Plan Expiration Bars", minval = 12, maxval = 300, group = groupScoring, tooltip = ttExpire)
resolvedDisplayBars = input.int(12, "Resolved Plan Display Bars", minval = 2, maxval = 80, group = groupScoring, tooltip = ttResolved)

groupVisual = "Chart Visuals"
showTargetBand = input.bool(true, "Show Expansion Target Band", group = groupVisual, tooltip = ttTargetBand)
showInvalidationShelf = input.bool(true, "Show Invalidation Shelf", group = groupVisual, tooltip = ttShelf)
showGuideLines = input.bool(true, "Show Target / Shelf Guides", group = groupVisual, tooltip = ttGuides)
showObstructionMarker = input.bool(true, "Show Path Obstruction Marker", group = groupVisual, tooltip = ttObstacle)
projectionBars = input.int(44, "Projection Bars", minval = 8, maxval = 180, group = groupVisual, tooltip = ttProjection)
zoneTransparency = input.int(89, "Zone Transparency", minval = 70, maxval = 96, group = groupVisual, tooltip = ttZoneOpacity)

groupLabels = "Labels"
showEventLabels = input.bool(true, "Show Event Labels", group = groupLabels, tooltip = ttLabels)
showContextLabels = input.bool(false, "Show Sparse Context Labels", group = groupLabels, tooltip = ttContext)
labelCooldownBars = input.int(44, "Label Cooldown Bars", minval = 1, maxval = 120, group = groupLabels, tooltip = ttCooldown)
contextSpacingBars = input.int(42, "Context Label Spacing", minval = 8, maxval = 240, group = groupLabels, tooltip = ttContextSpacing)
maxVisibleLabels = input.int(10, "Max Visible Labels", minval = 5, maxval = 40, group = groupLabels, tooltip = ttMaxLabels)
labelOffsetAtr = input.float(1.20, "Label Offset ATR", minval = 0.10, maxval = 3.00, step = 0.05, group = groupLabels, tooltip = ttLabelOffset)
showLabelScore = input.bool(true, "Show Label Score", group = groupLabels, tooltip = ttLabelScore)
showLabelDetails = input.bool(false, "Show Label Details", group = groupLabels, tooltip = ttLabelDetails)
labelSizeInput = input.string("Normal", "Label Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = groupLabels, tooltip = ttLabelSize)

groupPanel = "Panel"
showPanel = input.bool(true, "Show Panel", group = groupPanel, tooltip = ttShowPanel)
panelLocationInput = input.string("Top Right", "Panel Location", options = ["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], group = groupPanel, tooltip = ttPanelLocation)
panelThemeInput = input.string("Dark", "Panel Theme", options = ["Dark", "Light"], group = groupPanel, tooltip = ttPanelTheme)
panelFontSizeInput = input.string("Normal", "Panel Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = groupPanel, tooltip = ttPanelFont)

groupProof = "Proof"
showProof = input.bool(true, "Show Proof Layer", group = groupProof, tooltip = "Shows the confirmation-anchored proof layer in the panel: Follow, Hold, React, and Flip rates measured across target plans on the current symbol and timeframe. Follow means price reached the target band before the invalidation shelf. These are historical outcome rates, not predictions.")
proofReactBars = input.int(3, "Reaction Window Bars", minval = 1, maxval = 40, group = groupProof, tooltip = "Number of bars after a plan is created used to detect an immediate favorable reaction toward the target band.")
proofReactProgressPct = input.float(40.0, "Reaction Progress %", minval = 5.0, maxval = 90.0, step = 1.0, group = groupProof, tooltip = "Minimum favorable progress toward the target band, within the reaction window, required to count as an early React.")

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

f_peak_score(float value, float lowValue, float idealValue, float highValue) =>
    result = 0.0
    if value <= idealValue
        result := f_norm_high_good(value, lowValue, idealValue)
    else
        result := f_norm_low_good(value, idealValue, highValue)
    result

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

f_text_on(color bgColor) =>
    bright = (color.r(bgColor) * 299 + color.g(bgColor) * 587 + color.b(bgColor) * 114) / 1000
    bright >= 145 ? darkText : headerText

f_rate_pct(value) =>
    str.tostring(int(math.round(value))) + "%"

f_rate_color(value) =>
    value >= 55.0 ? bullColor : value >= 40.0 ? neutralColor : bearColor

f_flip_color(value) =>
    value <= 30.0 ? bullColor : value <= 55.0 ? neutralColor : bearColor

f_state_color(string stateText) =>
    switch stateText
        "Target Ready" => bullColor
        "Target Hit" => bullColor
        "Watch" => accentColor
        "Obstructed" => neutralColor
        "Invalid Review" => bearColor
        "Expired" => panelLabelCol
        => neutralColor

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

f_set_row(table target, int row, string leftText, string rightText, color rightColor, string theme, string fontSize, color rightBg) =>
    rowBg = f_row_bg(theme, row)
    table.cell(target, 0, row, leftText, text_color = f_panel_label(theme), bgcolor = rowBg, text_size = f_label_size(fontSize), text_halign = text.align_left)
    table.cell(target, 1, row, rightText, text_color = rightColor, bgcolor = rightBg, text_size = f_label_size(fontSize), text_halign = text.align_right)

f_fmt_price(float value) =>
    na(value) ? "n/a" : str.tostring(value, format.mintick)

f_fmt_atr(float value) =>
    na(value) ? "n/a" : str.tostring(value, "#.##") + " ATR"

f_grade(int scoreValue) =>
    scoreValue >= 85 ? "A+" : scoreValue >= 74 ? "A" : scoreValue >= 56 ? "B" : scoreValue >= 40 ? "C" : "D"

f_trim_labels(array<label> items, int limit) =>
    while array.size(items) > limit
        oldLabel = array.shift(items)
        if not na(oldLabel)
            label.delete(oldLabel)

f_trim_float(array<float> items, int limit) =>
    while array.size(items) > limit
        removed = array.shift(items)

f_nearest_above(array<float> levels, float basePrice) =>
    float best = na
    levelCount = array.size(levels)
    if levelCount > 0
        for idx = 0 to levelCount - 1
            level = array.get(levels, idx)
            if level > basePrice and (na(best) or level < best)
                best := level
    best

f_nearest_below(array<float> levels, float basePrice) =>
    float best = na
    levelCount = array.size(levels)
    if levelCount > 0
        for idx = 0 to levelCount - 1
            level = array.get(levels, idx)
            if level < basePrice and (na(best) or level > best)
                best := level
    best

f_workflow(string stateText) =>
    stateText == "Target Ready" ? "Track Target" :
     stateText == "Watch" ? "Watch Path" :
     stateText == "Obstructed" ? "Review Obstacle" :
     stateText == "Target Hit" ? "Target complete" :
     stateText == "Invalid Review" ? "Rebuild context" :
     stateText == "Expired" ? "Archive plan" :
     "Standby"

// -------------------------------------------------
// Core measurements
// -------------------------------------------------
atr = ta.atr(atrLen)
safeAtr = math.max(nz(atr, ta.tr(true)), syminfo.mintick)
atrBase = ta.sma(atr, atrBaseLen)
atrRatio = not na(atrBase) and atrBase > 0.0 ? safeAtr / atrBase : 1.0

priorHighRaw = ta.highest(high[1], rangeLookback)
priorLowRaw = ta.lowest(low[1], rangeLookback)
priorHigh = nz(priorHighRaw, high)
priorLow = nz(priorLowRaw, low)
priorRange = math.max(priorHigh - priorLow, safeAtr)
priorRangeAtr = priorRange / safeAtr

fastEma = ta.ema(close, fastEmaLen)
slowEma = ta.ema(close, slowEmaLen)
trendSlope = slowEma - nz(slowEma[5], slowEma)

volumeBase = ta.sma(volume, volumeLen)
hasVolume = not na(volume) and not na(volumeBase) and volumeBase > 0.0
volumeRatio = hasVolume ? volume / volumeBase : 1.0

barSpan = math.max(high - low, syminfo.mintick)
bodyShare = math.abs(close - open) / barSpan

barReady = not confirmOnClose or barstate.isconfirmed
longBreak = barReady and close > priorHigh + safeAtr * breakBufferAtr
shortBreak = barReady and close < priorLow - safeAtr * breakBufferAtr
autoDir = longBreak ? 1 : shortBreak ? -1 : close >= slowEma ? 1 : -1
candidateDir = sideMode == "Long Expansion" ? 1 : sideMode == "Short Expansion" ? -1 : autoDir
candidateConfirmed = candidateDir == 1 ? longBreak : shortBreak

// -------------------------------------------------
// Structure memory
// -------------------------------------------------
var array<float> swingHighs = array.new_float()
var array<float> swingLows = array.new_float()

ph = ta.pivothigh(high, structurePivot, structurePivot)
pl = ta.pivotlow(low, structurePivot, structurePivot)
if not na(ph)
    array.push(swingHighs, ph)
    f_trim_float(swingHighs, structureMemoryLimit)
if not na(pl)
    array.push(swingLows, pl)
    f_trim_float(swingLows, structureMemoryLimit)

// -------------------------------------------------
// Candidate target model
// -------------------------------------------------
candidateAnchor = candidateDir == 1 ? priorHigh : priorLow
rangeDistance = priorRange * rangeProjectionMultiple
atrDistance = safeAtr * atrProjectionMultiple
rawTargetDistance = (rangeDistance + atrDistance) * 0.5
candidateTargetDistance = f_clamp(rawTargetDistance, safeAtr * minTargetAtr, safeAtr * maxTargetAtr)
candidateTargetDistanceAtr = candidateTargetDistance / safeAtr
candidateTargetMid = candidateDir == 1 ? candidateAnchor + candidateTargetDistance : candidateAnchor - candidateTargetDistance
candidateBandHalf = safeAtr * targetBandAtr * 0.5
candidateTargetTop = candidateTargetMid + candidateBandHalf
candidateTargetBottom = candidateTargetMid - candidateBandHalf
longShelf = ta.lowest(low[1], invalidationLookback)
shortShelf = ta.highest(high[1], invalidationLookback)
candidateShelf = candidateDir == 1 ? longShelf : shortShelf
candidateShelf := nz(candidateShelf, candidateDir == 1 ? priorLow : priorHigh)
nearestHighObstacle = f_nearest_above(swingHighs, close)
nearestLowObstacle = f_nearest_below(swingLows, close)
candidateObstacle = candidateDir == 1 ? nearestHighObstacle : nearestLowObstacle
candidateObstruction = not na(candidateObstacle) and (candidateDir == 1 ? candidateObstacle > close and candidateObstacle < candidateTargetBottom : candidateObstacle < close and candidateObstacle > candidateTargetTop)

edgeBreakAtr = candidateDir == 1 ? (close - priorHigh) / safeAtr : (priorLow - close) / safeAtr
expansionScore = f_clamp(f_norm_high_good(edgeBreakAtr, breakBufferAtr * 0.35, breakBufferAtr + 0.85) * 0.68 + f_peak_score(priorRangeAtr, 0.75, 2.40, 6.00) * 0.32, 0.0, 100.0)
projectionScore = f_peak_score(candidateTargetDistanceAtr, minTargetAtr, idealTargetAtr, maxTargetAtr)

obstacleDistanceAtr = not na(candidateObstacle) ? math.abs(candidateObstacle - close) / safeAtr : candidateTargetDistanceAtr
pathRatio = candidateTargetDistanceAtr > 0.0 ? obstacleDistanceAtr / candidateTargetDistanceAtr : 1.0
structureScore = na(candidateObstacle) ? 88.0 : candidateObstruction ? f_clamp(pathRatio * 100.0 * 0.62, 0.0, 62.0) : 90.0

closeLocation = candidateDir == 1 ? (close - low) / barSpan : (high - close) / barSpan
trendSupport = 0.0
trendSupport += candidateDir == 1 ? (close > fastEma ? 34.0 : 0.0) : (close < fastEma ? 34.0 : 0.0)
trendSupport += candidateDir == 1 ? (fastEma > slowEma ? 34.0 : 0.0) : (fastEma < slowEma ? 34.0 : 0.0)
trendSupport += candidateDir == 1 ? (trendSlope >= 0.0 ? 32.0 : 0.0) : (trendSlope <= 0.0 ? 32.0 : 0.0)
volumeScore = hasVolume ? f_norm_high_good(volumeRatio, 0.75, 1.60) : 55.0
continuationScore = f_clamp(closeLocation * 42.0 + bodyShare * 26.0 + trendSupport * 0.24 + volumeScore * 0.08, 0.0, 100.0)
volatilityScore = f_peak_score(atrRatio, 0.78, 1.32, hotAtrRatio)

rawQuality = expansionScore * 0.25 + projectionScore * 0.20 + structureScore * 0.22 + continuationScore * 0.23 + volatilityScore * 0.10
qualityCapped = candidateObstruction ? math.min(rawQuality, 72.0) : rawQuality
candidateQuality = int(math.round(f_clamp(qualityCapped, 0.0, 100.0)))

// -------------------------------------------------
// Active plan state
// -------------------------------------------------
var bool planActive = false
var int planDir = 0
var int planStartBar = na
var int lastPlanBar = na
var float planAnchor = na
var float planTargetMid = na
var float planTargetTop = na
var float planTargetBottom = na
var float planShelf = na
var float planObstacle = na
var float planAtr = na
var int planStartQuality = na
var bool planTargetReached = false
var bool planInvalidated = false
var bool planExpiredLatched = false
var int planResolvedBar = na
var string previousState = "Wait"

existingResolvedAge = not na(planResolvedBar) ? bar_index - planResolvedBar : 0
if planActive and (planTargetReached or planInvalidated or planExpiredLatched) and existingResolvedAge > resolvedDisplayBars
    planActive := false
    planDir := 0
    planStartBar := na
    planAnchor := na
    planTargetMid := na
    planTargetTop := na
    planTargetBottom := na
    planShelf := na
    planObstacle := na
    planAtr := na
    planStartQuality := na
    planTargetReached := false
    planInvalidated := false
    planExpiredLatched := false
    planResolvedBar := na
    previousState := "Wait"

planClosed = planTargetReached or planInvalidated or planExpiredLatched
cooldownReady = na(lastPlanBar) or bar_index - lastPlanBar >= planCooldownBars
newPlanEvent = candidateConfirmed and cooldownReady and (not planActive or planClosed or planDir != candidateDir)

if newPlanEvent
    planActive := true
    planDir := candidateDir
    planStartBar := bar_index
    lastPlanBar := bar_index
    planAnchor := candidateAnchor
    planTargetMid := candidateTargetMid
    planTargetTop := candidateTargetTop
    planTargetBottom := candidateTargetBottom
    planShelf := candidateShelf
    planObstacle := candidateObstacle
    planAtr := safeAtr
    planStartQuality := candidateQuality
    planTargetReached := false
    planInvalidated := false
    planExpiredLatched := false
    planResolvedBar := na
    previousState := "Watch"

planHasObstacle = planActive and not na(planObstacle)
obstructionInPath = planHasObstacle and (planDir == 1 ? planObstacle > close and planObstacle < planTargetBottom : planObstacle < close and planObstacle > planTargetTop)
activeAge = planActive and not na(planStartBar) ? bar_index - planStartBar : 0
rawInvalidReview = barReady and planActive and not planTargetReached and not planExpiredLatched and (planDir == 1 ? close < planShelf - planAtr * violationBufferAtr : close > planShelf + planAtr * violationBufferAtr)
rawTargetHit = barReady and planActive and not planInvalidated and not planExpiredLatched and (planDir == 1 ? close >= planTargetBottom : close <= planTargetTop)
rawPlanExpired = planActive and not planTargetReached and not planInvalidated and activeAge > planExpireBars
invalidReviewSignal = rawInvalidReview and not planInvalidated
targetHitSignal = rawTargetHit and not planTargetReached
planExpiredSignal = rawPlanExpired and not planExpiredLatched
if invalidReviewSignal
    planInvalidated := true
    planResolvedBar := bar_index
else if targetHitSignal
    planTargetReached := true
    planResolvedBar := bar_index
else if planExpiredSignal
    planExpiredLatched := true
    planResolvedBar := bar_index
targetHit = planActive and planTargetReached
invalidReview = planActive and planInvalidated
planExpired = planActive and planExpiredLatched
resolvedAge = not na(planResolvedBar) ? bar_index - planResolvedBar : 0

progressDenom = planActive ? math.max(math.abs(planTargetMid - planAnchor), syminfo.mintick) : na
rawProgress = planActive ? (planDir == 1 ? (close - planAnchor) / progressDenom * 100.0 : (planAnchor - close) / progressDenom * 100.0) : na
targetProgress = planActive ? (planTargetReached ? 100.0 : f_clamp(rawProgress, 0.0, 100.0)) : na

displayQuality = planActive ? planStartQuality : candidateQuality
planState = "Wait"
if planActive
    if invalidReview
        planState := "Invalid Review"
    else if targetHit
        planState := "Target Hit"
    else if planExpired
        planState := "Expired"
    else if obstructionInPath
        planState := "Obstructed"
    else if displayQuality >= readyThreshold
        planState := "Target Ready"
    else if displayQuality >= watchThreshold
        planState := "Watch"

stateChanged = planState != previousState
stateColor = f_state_color(planState)
sideText = planActive ? (planDir == 1 ? "Long Expansion" : "Short Expansion") : (candidateDir == 1 ? "Long Watch" : "Short Watch")
actionText = switch planState
    "Target Ready" => "Review Target"
    "Watch" => "Track Path"
    "Obstructed" => "Check Obstacle"
    "Target Hit" => "Target complete"
    "Invalid Review" => "Rebuild context"
    "Expired" => "Archive plan"
    => "Wait"

// -------------------------------------------------
// Confirmation-anchored proof (plans: Follow = target band reached before invalidation shelf)
// -------------------------------------------------
var int proofTotal = 0
var int proofFollow = 0
var int proofHold = 0
var int proofReact = 0
var int proofFlip = 0
var bool pEvalActive = false
var int pEvalDir = 0
var int pEvalStart = na
var float pEvalEntry = na
var float pEvalStop = na
var float pEvalTarget = na
var bool pReacted = false
var bool pFollowed = false
var bool pFlipped = false

int proofWarmup = rangeLookback + atrBaseLen + 5
bool proofTargetAhead = planDir == 1 ? close < planTargetBottom : planDir == -1 ? close > planTargetTop : false
bool planAnchorEvent = barstate.isconfirmed and newPlanEvent and planDir != 0 and not na(planTargetBottom) and not na(planTargetTop) and not na(planShelf) and not na(planAtr) and proofTargetAhead
if barstate.isconfirmed and bar_index > proofWarmup
    if pEvalActive
        int heldBars = bar_index - pEvalStart
        float followDist = math.max(math.abs(pEvalTarget - pEvalEntry), syminfo.mintick)
        float favExc = pEvalDir * (close - pEvalEntry)
        if heldBars >= 1 and heldBars <= proofReactBars and favExc >= followDist * proofReactProgressPct / 100.0
            pReacted := true
        bool stopBreached = pEvalDir == 1 ? close < pEvalStop : close > pEvalStop
        bool hitTarget = heldBars >= 1 and favExc >= followDist
        if stopBreached
            pFlipped := true
        bool followNow = hitTarget and not pFlipped
        if followNow
            pFollowed := true
        bool naturalResolve = pFlipped or followNow or heldBars >= planExpireBars
        if naturalResolve or planAnchorEvent
            proofTotal := proofTotal + 1
            if pFollowed
                proofFollow := proofFollow + 1
            if not pFlipped
                proofHold := proofHold + 1
            if pReacted
                proofReact := proofReact + 1
            if pFlipped
                proofFlip := proofFlip + 1
            pEvalActive := false
    if planAnchorEvent and not pEvalActive
        pEvalActive := true
        pEvalDir := planDir
        pEvalEntry := close
        pEvalStop := planDir == 1 ? planShelf - planAtr * violationBufferAtr : planShelf + planAtr * violationBufferAtr
        pEvalTarget := planDir == 1 ? planTargetBottom : planTargetTop
        pEvalStart := bar_index
        pReacted := false
        pFollowed := false
        pFlipped := false

float followRate = proofTotal > 0 ? proofFollow * 100.0 / proofTotal : 0.0
float holdRate = proofTotal > 0 ? proofHold * 100.0 / proofTotal : 0.0
float reactRate = proofTotal > 0 ? proofReact * 100.0 / proofTotal : 0.0
float proofFlipRate = proofTotal > 0 ? proofFlip * 100.0 / proofTotal : 0.0
string proofSampleText = proofTotal > 0 ? "n = " + str.tostring(proofTotal) : "building"

// -------------------------------------------------
// Visual objects
// -------------------------------------------------
var box targetBox = na
var box shelfBox = na
var line anchorLine = na
var line targetLine = na
var line shelfLine = na
var line obstacleLine = na
var label targetBadge = na
var label shelfBadge = na
var label obstacleLabel = na

renderLeft = planActive ? planStartBar : bar_index
renderRight = bar_index + projectionBars
shelfTop = planActive ? planShelf + planAtr * shelfBufferAtr : na
shelfBottom = planActive ? planShelf - planAtr * shelfBufferAtr : na
planSideShort = planDir == 1 ? "LONG" : "SHORT"
targetBadgeText = planSideShort + " " + planState + " | Q" + str.tostring(displayQuality) + " | P" + str.tostring(targetProgress, "#") + "%"
shelfDistanceAtr = planActive ? math.abs(planAnchor - planShelf) / math.max(planAtr, syminfo.mintick) : na
shelfBadgeText = "INVALID " + f_fmt_price(planShelf) + " | " + f_fmt_atr(shelfDistanceAtr)

if planActive and showTargetBand
    bandColor = planDir == 1 ? bullColor : bearColor
    if na(targetBox)
        targetBox := box.new(left = renderLeft, top = planTargetTop, right = renderRight, bottom = planTargetBottom, xloc = xloc.bar_index, bgcolor = color.new(bandColor, zoneTransparency), border_color = color.new(bandColor, 30), border_width = 1)
    else
        box.set_left(targetBox, renderLeft)
        box.set_right(targetBox, renderRight)
        box.set_top(targetBox, planTargetTop)
        box.set_bottom(targetBox, planTargetBottom)
        box.set_bgcolor(targetBox, color.new(bandColor, zoneTransparency))
        box.set_border_color(targetBox, color.new(bandColor, 30))
    badgeX = int(math.round((renderLeft + renderRight) / 2.0))
    badgeY = (planTargetTop + planTargetBottom) * 0.5
    if na(targetBadge)
        targetBadge := label.new(badgeX, badgeY, targetBadgeText, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_center, color = color.new(bandColor, 0), textcolor = f_text_on(bandColor), size = f_label_size(labelSizeInput), textalign = text.align_center, tooltip = "Centered target-band badge. It summarizes target quality without acting as a trade instruction.")
    else
        label.set_xy(targetBadge, badgeX, badgeY)
        label.set_text(targetBadge, targetBadgeText)
        label.set_color(targetBadge, color.new(bandColor, 0))
        label.set_textcolor(targetBadge, f_text_on(bandColor))
        label.set_size(targetBadge, f_label_size(labelSizeInput))
else
    if not na(targetBox)
        box.delete(targetBox)
        targetBox := na
    if not na(targetBadge)
        label.delete(targetBadge)
        targetBadge := na

if planActive and showInvalidationShelf
    if na(shelfBox)
        shelfBox := box.new(left = renderLeft, top = shelfTop, right = renderRight, bottom = shelfBottom, xloc = xloc.bar_index, bgcolor = color.new(neutralColor, 90), border_color = color.new(neutralColor, 36), border_width = 1)
    else
        box.set_left(shelfBox, renderLeft)
        box.set_right(shelfBox, renderRight)
        box.set_top(shelfBox, shelfTop)
        box.set_bottom(shelfBox, shelfBottom)
        box.set_bgcolor(shelfBox, color.new(neutralColor, 90))
        box.set_border_color(shelfBox, color.new(neutralColor, 36))
    shelfBadgeX = int(math.round((renderLeft + renderRight) / 2.0))
    shelfBadgeY = (shelfTop + shelfBottom) * 0.5
    if na(shelfBadge)
        shelfBadge := label.new(shelfBadgeX, shelfBadgeY, shelfBadgeText, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_center, color = color.new(neutralColor, 0), textcolor = f_text_on(neutralColor), size = f_label_size(labelSizeInput), textalign = text.align_center, tooltip = "Centered invalidation-shelf badge. It is a planning reference, not a stop instruction.")
    else
        label.set_xy(shelfBadge, shelfBadgeX, shelfBadgeY)
        label.set_text(shelfBadge, shelfBadgeText)
        label.set_color(shelfBadge, color.new(neutralColor, 0))
        label.set_textcolor(shelfBadge, f_text_on(neutralColor))
        label.set_size(shelfBadge, f_label_size(labelSizeInput))
else
    if not na(shelfBox)
        box.delete(shelfBox)
        shelfBox := na
    if not na(shelfBadge)
        label.delete(shelfBadge)
        shelfBadge := na

if planActive and showGuideLines
    guideColor = color.new(stateColor, 12)
    if na(anchorLine)
        anchorLine := line.new(renderLeft, planAnchor, renderRight, planAnchor, xloc = xloc.bar_index, color = color.new(accentColor, 20), style = line.style_dotted, width = 1)
    else
        line.set_xy1(anchorLine, renderLeft, planAnchor)
        line.set_xy2(anchorLine, renderRight, planAnchor)
    if na(targetLine)
        targetLine := line.new(renderLeft, planTargetMid, renderRight, planTargetMid, xloc = xloc.bar_index, color = guideColor, style = line.style_dashed, width = 1)
    else
        line.set_xy1(targetLine, renderLeft, planTargetMid)
        line.set_xy2(targetLine, renderRight, planTargetMid)
        line.set_color(targetLine, guideColor)
    if na(shelfLine)
        shelfLine := line.new(renderLeft, planShelf, renderRight, planShelf, xloc = xloc.bar_index, color = color.new(neutralColor, 18), style = line.style_dashed, width = 1)
    else
        line.set_xy1(shelfLine, renderLeft, planShelf)
        line.set_xy2(shelfLine, renderRight, planShelf)
else
    if not na(anchorLine)
        line.delete(anchorLine)
        anchorLine := na
    if not na(targetLine)
        line.delete(targetLine)
        targetLine := na
    if not na(shelfLine)
        line.delete(shelfLine)
        shelfLine := na

if planActive and showObstructionMarker and obstructionInPath
    if na(obstacleLine)
        obstacleLine := line.new(bar_index, planObstacle, renderRight, planObstacle, xloc = xloc.bar_index, color = color.new(neutralColor, 0), style = line.style_dotted, width = 1)
    else
        line.set_xy1(obstacleLine, bar_index, planObstacle)
        line.set_xy2(obstacleLine, renderRight, planObstacle)
    if na(obstacleLabel)
        obstacleLabel := label.new(renderRight, planObstacle, "Path Obstacle", xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = color.new(neutralColor, 4), textcolor = f_text_on(neutralColor), size = f_label_size(labelSizeInput))
    else
        label.set_x(obstacleLabel, renderRight)
        label.set_y(obstacleLabel, planObstacle)
        label.set_text(obstacleLabel, "Path Obstacle")
        label.set_color(obstacleLabel, color.new(neutralColor, 4))
        label.set_textcolor(obstacleLabel, f_text_on(neutralColor))
        label.set_size(obstacleLabel, f_label_size(labelSizeInput))
else
    if not na(obstacleLine)
        line.delete(obstacleLine)
        obstacleLine := na
    if not na(obstacleLabel)
        label.delete(obstacleLabel)
        obstacleLabel := na

// -------------------------------------------------
// Labels
// -------------------------------------------------
var array<label> eventLabels = array.new<label>()
var int lastLabelBar = na
var int lastContextBar = na

importantState = planState == "Target Ready" or planState == "Obstructed" or planState == "Target Hit" or planState == "Invalid Review" or planState == "Watch"
labelCooldownReady = na(lastLabelBar) or bar_index - lastLabelBar >= labelCooldownBars
contextReady = planActive and showContextLabels and (na(lastContextBar) or bar_index - lastContextBar >= contextSpacingBars)
criticalState = planState == "Target Hit" or planState == "Invalid Review"
eventLabelNow = showEventLabels and planActive and (labelCooldownReady or criticalState) and (newPlanEvent or (stateChanged and importantState))
contextLabelNow = contextReady and not eventLabelNow and planState != "Wait" and planState != "Expired"

if eventLabelNow or contextLabelNow
    labelEventDir = planDir
    labelOffset = criticalState ? labelOffsetAtr * 1.45 : labelOffsetAtr
    labelY = labelEventDir == 1 ? low - safeAtr * labelOffset : high + safeAtr * labelOffset
    scoreText = showLabelScore ? " | Q" + str.tostring(displayQuality) : ""
    detailsText = showLabelDetails ? " | P" + str.tostring(targetProgress, "#") + "% | " + (obstructionInPath ? "BLOCKED" : "OPEN") : ""
    stateLabelText = planState == "Target Ready" ? "READY" : planState == "Target Hit" ? "TARGET" : planState == "Invalid Review" ? "INVALID" : planState == "Obstructed" ? "OBSTRUCTED" : planState == "Watch" ? "WATCH" : planState
    labelText = contextLabelNow ? planSideShort + " PLAN" + scoreText + detailsText : planSideShort + " " + stateLabelText + scoreText + detailsText
    eventLabel = label.new(x = bar_index, y = labelY, text = labelText, xloc = xloc.bar_index, yloc = yloc.price, style = labelEventDir == 1 ? label.style_label_up : label.style_label_down, color = color.new(stateColor, 4), textcolor = f_text_on(stateColor), size = f_label_size(labelSizeInput), tooltip = "Expansion Target Planner\nState: " + planState + "\nQuality: " + str.tostring(displayQuality) + "/100\nProgress: " + str.tostring(targetProgress, "#") + "%\nAction: " + actionText, textalign = text.align_center)
    array.push(eventLabels, eventLabel)
    f_trim_labels(eventLabels, maxVisibleLabels)
    lastLabelBar := bar_index
    lastContextBar := bar_index

// -------------------------------------------------
// Panel
// -------------------------------------------------
theme = panelThemeInput
panelSize = panelFontSizeInput
dashBg = f_panel_bg(theme)
frameColor = f_panel_border(theme)
panelValueActive = f_panel_value(theme)
targetBandRead = planActive ? f_fmt_price(planTargetMid) + " | " + f_fmt_atr(math.abs(planTargetMid - planAnchor) / math.max(planAtr, syminfo.mintick)) : "Waiting"
invalidRead = planActive ? f_fmt_price(planShelf) : "Waiting"
qualityRead = str.tostring(displayQuality) + " / 100  " + f_grade(displayQuality)
progressRead = planActive ? str.tostring(targetProgress, "#") + "%" : "-"
workflowRead = f_workflow(planState)
stateBg = color.new(stateColor, theme == "Light" ? 74 : 18)
qualityBg = color.new(stateColor, theme == "Light" ? 78 : 24)

var table panel = na
var string lastPanelLocation = ""
var string lastPanelTheme = ""
var bool lastPanelVisible = false
var bool lastProofMode = false
int panelRowCount = showProof ? 9 : 6

panelNeedsReset = showPanel and (na(panel) or panelLocationInput != lastPanelLocation or panelThemeInput != lastPanelTheme or showPanel != lastPanelVisible or showProof != lastProofMode)
if panelNeedsReset
    if not na(panel)
        table.delete(panel)
    panel := table.new(f_panel_position(panelLocationInput), 2, panelRowCount, bgcolor = dashBg, frame_color = frameColor, frame_width = 1, border_color = frameColor, border_width = 1)
    table.cell(panel, 0, 0, "AG Pro Expansion Target Planner", text_color = headerText, bgcolor = headerBg, text_size = f_label_size(panelSize), text_halign = text.align_center)
    table.cell(panel, 1, 0, "", text_color = headerText, bgcolor = headerBg, text_size = f_label_size(panelSize))
    table.merge_cells(panel, 0, 0, 1, 0)
    lastPanelLocation := panelLocationInput
    lastPanelTheme := panelThemeInput
    lastPanelVisible := showPanel
    lastProofMode := showProof

if not showPanel and not na(panel)
    table.delete(panel)
    panel := na
    lastPanelVisible := false

if showPanel and not na(panel) and barstate.islast
    table.clear(panel, 0, 1, 1, panelRowCount - 1)
    table.cell(panel, 0, 0, "AG Pro Expansion Target Planner", text_color = headerText, bgcolor = headerBg, text_size = f_label_size(panelSize), text_halign = text.align_center)
    f_set_row(panel, 1, "Workflow", workflowRead, stateColor, theme, panelSize, f_row_bg(theme, 1))
    f_set_row(panel, 2, "State", planState + " / " + sideText, f_text_on(stateBg), theme, panelSize, stateBg)
    f_set_row(panel, 3, "Quality / Progress", qualityRead + " | " + progressRead, f_text_on(qualityBg), theme, panelSize, qualityBg)
    f_set_row(panel, 4, "Target / Band", targetBandRead, stateColor, theme, panelSize, f_row_bg(theme, 4))
    f_set_row(panel, 5, "Shelf / Path", invalidRead + " | " + (obstructionInPath ? "Blocked" : "Open"), obstructionInPath ? neutralColor : panelValueActive, theme, panelSize, f_row_bg(theme, 5))
    if showProof
        rowBgProof = f_row_bg(theme, 6)
        table.cell(panel, 0, 6, "Proof @ Confirm", text_color = accentColor, bgcolor = rowBgProof, text_size = f_label_size(panelSize), text_halign = text.align_left)
        table.cell(panel, 1, 6, proofSampleText, text_color = f_panel_label(theme), bgcolor = rowBgProof, text_size = f_label_size(panelSize), text_halign = text.align_right)
        f_set_row(panel, 7, "Follow / Hold", (proofTotal > 0 ? f_rate_pct(followRate) : "-") + " / " + (proofTotal > 0 ? f_rate_pct(holdRate) : "-"), proofTotal > 0 ? f_rate_color(followRate) : panelValueActive, theme, panelSize, f_row_bg(theme, 7))
        f_set_row(panel, 8, "React / Flip", (proofTotal > 0 ? f_rate_pct(reactRate) : "-") + " / " + (proofTotal > 0 ? f_rate_pct(proofFlipRate) : "-"), proofTotal > 0 ? f_rate_color(reactRate) : panelValueActive, theme, panelSize, f_row_bg(theme, 8))

previousState := planState

// -------------------------------------------------
// Alerts
// -------------------------------------------------
readyEvent = planActive and planState == "Target Ready" and stateChanged
watchEvent = planActive and planState == "Watch" and stateChanged
obstructionEvent = planActive and planState == "Obstructed" and stateChanged
targetHitEvent = planActive and planState == "Target Hit" and stateChanged
invalidReviewEvent = planActive and planState == "Invalid Review" and stateChanged

alertcondition(readyEvent, title = "Target Ready", message = "Expansion Target Planner: target quality is ready for review. This is an attention marker, not a trade instruction.")
alertcondition(watchEvent, title = "Target Watch", message = "Expansion Target Planner: target context is improving but still requires confirmation.")
alertcondition(obstructionEvent, title = "Path Obstructed", message = "Expansion Target Planner: a structure obstacle sits between current price and the planned target band.")
alertcondition(targetHitEvent, title = "Target Band Reached", message = "Expansion Target Planner: a confirmed close reached the active expansion target band.")
alertcondition(invalidReviewEvent, title = "Invalidation Review", message = "Expansion Target Planner: a confirmed close crossed the active invalidation shelf and the plan requires review.")

// Hidden reference plots
plot(displayQuality, "Target Quality Score", display = display.none)
plot(planActive ? targetProgress : na, "Target Progress", display = display.none)
plot(planActive ? planTargetMid : na, "Target Midpoint", display = display.none)
plot(planActive ? planShelf : na, "Invalidation Shelf", display = display.none)
plot(followRate, "ETP Follow Rate", display = display.none)
plot(holdRate, "ETP Hold Rate", display = display.none)
plot(reactRate, "ETP React Rate", display = display.none)
plot(proofFlipRate, "ETP Flip Rate", display = display.none)
````
