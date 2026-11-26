# Supply Demand Flip Planner [AGPro Series]

- url: https://www.tradingview.com/script/1Ic0EhON-Supply-Demand-Flip-Planner-AGPro-Series/
- type: indicator
- pine_id: PUB;5cd3483020db404695ad76d60ba7314e
- version: 3.0

## Description

Supply Demand Flip Planner [AGPro Series]

🧠 Core Idea

Has an old supply or demand zone changed role and started acting as the opposite side of the market?


📌 Overview / What it does

Supply Demand Flip Planner is a role-change price action tool designed to identify when a prior supply zone turns into demand, or when a prior demand zone turns into supply.

The script detects pivot-based supply and demand zones, monitors breaks through those zones, maps the active flip zone, evaluates retest acceptance, and displays a structured 0-100 score. It also shows invalidation shelves, target rails, centered zone text, labels, and a compact AG Pro dashboard.

It does not predict future price movement, automate trades, or provide guaranteed buy/sell signals. It is a visual decision-support framework for reading supply-demand flip behavior.


🎯 Purpose & Design Philosophy

This script was built for traders who watch support/resistance role reversal but want a cleaner way to separate meaningful flips from ordinary breaks.

Many zones break and never matter again. Some zones break, retest, and start acting as the opposite side of the market. This planner focuses on that role-change moment.

The design supports a structured workflow: map supply and demand, wait for break, monitor retest, evaluate acceptance, then track invalidation.


⚡ Why This Script Is Different

Most supply and demand tools draw zones and leave interpretation fully manual.

This script does NOT simply flood the chart with historical zones.

Instead, it focuses on the active role-change zone, measures retest quality, scores acceptance, and presents the result through a clear READY / MONITOR / WAIT / INVALIDATED framework.


⚙️ Methodology

1. Context Detection

The script detects pivot-based supply and demand zones using configurable left/right pivot confirmation.

2. Reference Mapping

It maps source supply and demand shelves, then converts a broken zone into an active flip zone.

3. Reaction Evaluation

When price retests the flip zone, the script evaluates break strength, retest depth, wick response, body quality, source-zone quality, freshness, and relative volume.

4. Visual Output

The active flip zone is shown with centered text, invalidation shelf, target rails, right-side tags, labels, and an AG Pro panel.


🗺️ How to Read the Chart

Supply zones represent pivot-based resistance shelves.

Demand zones represent pivot-based support shelves.

Demand Flip means old supply has been broken and is being evaluated as new demand.

Supply Flip means old demand has been broken and is being evaluated as new supply.

READY FLIP labels mark retests that pass the selected acceptance score.

Invalidation shelf marks where the flip context weakens or fails.

The AG Pro panel summarizes Flip State, Acceptance, Retest, Failure Risk, and Action.


🚦 Signals & States

• DEMAND → pivot-based demand zone mapped.

• SUPPLY → pivot-based supply zone mapped.

• DEMAND FLIP → old supply was broken and is being watched as new demand.

• SUPPLY FLIP → old demand was broken and is being watched as new supply.

• FLIP RETEST → price is interacting with the active flip zone.

• READY FLIP → retest acceptance reached the required score threshold.

• INVALIDATED → the active flip lost its invalidation edge.

• READY → qualified flip acceptance is active.

• MONITOR → the flip zone is active or retesting.

• WAIT → no qualified flip acceptance is active.


🔔 Alerts Logic

Demand Flip Locked triggers when price breaks above a prior supply zone.

Supply Flip Locked triggers when price breaks below a prior demand zone.

Demand Flip Acceptance Ready triggers when a bullish flip retest reaches the score threshold.

Supply Flip Acceptance Ready triggers when a bearish flip retest reaches the score threshold.

Supply Demand Flip Retest triggers when price interacts with the active flip zone.

Supply Demand Flip Invalidated triggers when the flip loses its invalidation shelf.

Alerts are attention markers, not trade instructions.


🧩 Confluence Logic

The strongest flip contexts appear when break strength, retest depth, wick response, close quality, source-zone quality, freshness, and relative volume align.

When a broken zone is retested cleanly and accepted from the opposite side, the score improves and the panel shifts toward a stronger action state.


📊 When to Use

• Support/resistance role reversal

• Breakout retests

• Trend continuation after zone breaks

• Failed range boundaries that become new reaction zones

• Markets with clear swing structure


⚠️ When NOT to Use

• Extremely noisy markets with weak pivot structure

• Very low liquidity symbols

• Markets with large spread or unreliable candles

• News spikes where zones break and fail too quickly

• Timeframes where pivot zones are too dense or too sparse


🎛️ Key Inputs

• Pivot Left / Right Bars → control how strict the source zone detection is.

• Zone Depth ATR → controls the thickness of supply and demand shelves.

• Break Buffer ATR → requires price to break beyond the source zone by a volatility-adjusted amount.

• Retest Window Bars → controls how long the flip remains relevant.

• Acceptance Buffer ATR → defines how much confirmation is required after retest.

• Invalidation Buffer ATR → controls the failure shelf beyond the flip zone.

• Minimum Ready Score → sets how strict READY labels should be.

• Visual Settings → control zones, labels, centered zone text, target rails, and right-side tags.

• Panel Settings → control panel visibility, location, theme, and font size.


🖥️ Interface & Visual Design

The interface is designed to make role-change structure readable without overwhelming the chart.

The active flip zone uses centered text so the purpose of the zone is immediately visible. Source zones are subtle, while READY labels and target rails stand out only when a valid acceptance context appears.

The panel gives a quick summary of the current flip state and risk context.


🧪 Practical Usage Workflow

1. Identify the latest supply and demand zones.

2. Wait for a zone to break and become a flip candidate.

3. Watch for retest interaction inside the flip zone.

4. Check the READY FLIP label and acceptance score.

5. Compare price with invalidation shelf and target rails.

6. Confirm broader trend, volatility, and liquidity before making decisions.


🔍 Interpretation Guidelines

A high acceptance score means the role-change reaction is cleaner according to the script's rules.

A pending retest means price has returned to the zone but has not yet shown enough acceptance.

A failed flip means price lost the invalidation edge and the role-change context should be treated as weakened.


🚫 What This Script Is NOT

This script is not a prediction engine.

It is not financial advice.

It is not an automated trading system.

It does not guarantee entries, exits, profits, or outcomes.


⚠️ Limitations & Transparency

Pivot-based zones are confirmed after the selected right-side bars, so source zones appear after confirmation.

Different timeframes can create very different supply and demand structures.

High volatility can cause quick break-and-fail behavior around zones.

No rule-based script can fully account for news, liquidity shocks, or sudden market structure changes.


🧠 Market Context Notes

Supply-demand flips are a form of role reversal.

Old resistance can become new support after acceptance. Old support can become new resistance after acceptance.

The script is strongest when used with broader market structure, trend context, liquidity, and volatility analysis.


🧾 Use Case Examples

When price breaks above a supply zone, returns to the zone, and holds above it with clean reaction quality, the script may mark a Demand Flip acceptance.

When price breaks below a demand zone, retests it from below, and rejects cleanly, the script may mark a Supply Flip acceptance.


🧱 System Philosophy

Supply Demand Flip Planner follows the AG Pro Series approach: transform a common market concept into a structured decision map with context, score, risk reference, and clean visuals.

The goal is not to replace judgment. The goal is to make role-change analysis easier to read.


🔐 Non-Promise Statement

No script can provide certainty.

No signal should be treated as guaranteed.

Outputs should always be interpreted with independent analysis and responsible risk control.


📉 Risk Disclosure

Trading involves risk.

Market conditions can change quickly.

Users are responsible for their own decisions, risk management, and trade execution.

This script is for educational and analytical purposes only and does not provide financial advice.


📚 Educational Note

This script is designed to help traders study how supply zones, demand zones, breakout retests, and role-change acceptance behave across different market conditions.

## Source Code

````pine
// -------------------------------------------------
// Supply Demand Flip Planner [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 1.2
//
// Supply Demand Flip Planner is a role-change decision engine that detects
// pivot-based supply and demand zones, tracks when a zone is broken, and
// evaluates whether the old level flips into new support or resistance.
// It maps source zones, active flip zones, retest quality, invalidation
// shelves, target rails, and a 0-100 acceptance score inside a cleaner
// premium AG Pro panel. This visual refresh adds an anti-collision label
// system so clustered flip, retest and acceptance labels stay readable, plus
// user-adjustable supply and demand zone colors, while keeping the core logic
// intact.
// -------------------------------------------------

//@version=6
indicator("Supply Demand Flip Planner [AGPro Series]",
     shorttitle = "AG Pro SDF",
     overlay = true,
     max_boxes_count = 90,
     max_labels_count = 130,
     max_lines_count = 120)

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
// Helpers
// -------------------------------------------------
f_clamp(_v, _lo, _hi) =>
    math.max(_lo, math.min(_v, _hi))

f_size(_s) =>
    _s == "Tiny" ? size.tiny :
     _s == "Small" ? size.small :
     _s == "Normal" ? size.normal :
     _s == "Large" ? size.large : size.huge

f_table_size(_s) =>
    _s == "Tiny" ? size.tiny :
     _s == "Small" ? size.small :
     _s == "Normal" ? size.normal : size.large

f_panel_position(_p) =>
    _p == "Top Right" ? position.top_right :
     _p == "Top Left" ? position.top_left :
     _p == "Middle Right" ? position.middle_right :
     _p == "Middle Left" ? position.middle_left :
     _p == "Bottom Right" ? position.bottom_right : position.bottom_left

f_grade(_score) =>
    _score >= 85 ? "A+" :
     _score >= 75 ? "A" :
     _score >= 65 ? "B" :
     _score >= 55 ? "C" : "D"

f_score_text(_score) =>
    na(_score) ? "n/a" : str.tostring(math.round(_score)) + "/100  " + f_grade(_score)

f_action_color(_action) =>
    _action == "READY" ? color.new(bullColor, 8) :
     _action == "MONITOR" ? color.new(accentColor, 10) :
     _action == "WAIT" ? color.new(neutralColor, 16) :
     _action == "INVALIDATED" ? color.new(bearColor, 8) :
     _action == "EXPIRED" ? color.new(panelBorder, 8) :
     _action == "BLOCKED" ? color.new(panelBorder, 0) : color.new(panelBg, 0)

// -------------------------------------------------
// Inputs
// -------------------------------------------------
G_ZONE   = "Supply Demand Engine"
G_SCORE  = "Flip Engine"
G_VISUAL = "Visuals"
G_PANEL  = "Panel"
G_ALERTS = "Alerts"

pivotLeft = input.int(4, "Pivot Left Bars", minval = 1, maxval = 30, group = G_ZONE,
     tooltip = "Bars to the left used to confirm pivot-based supply and demand zones.")
pivotRight = input.int(4, "Pivot Right Bars", minval = 1, maxval = 30, group = G_ZONE,
     tooltip = "Bars to the right used to confirm pivot-based supply and demand zones. Higher values produce cleaner but slower zones.")
atrLength = input.int(14, "ATR Length", minval = 2, maxval = 200, group = G_ZONE,
     tooltip = "ATR normalizes zone depth, break buffers, invalidation shelves, target rails, and label spacing.")
zoneDepthAtr = input.float(0.42, "Zone Depth ATR", minval = 0.05, maxval = 5.00, step = 0.01, group = G_ZONE,
     tooltip = "ATR-based thickness of each supply or demand zone.")
maxZoneAgeBars = input.int(260, "Maximum Source Zone Age", minval = 20, maxval = 1500, group = G_ZONE,
     tooltip = "Maximum age allowed before an unflipped source zone is ignored.")
minVolume = input.float(0.0, "Minimum Volume Filter", minval = 0.0, maxval = 1000000000.0, step = 1.0, group = G_ZONE,
     tooltip = "Optional minimum bar volume filter. Keep at 0 to disable.")

confirmationMode = input.string("Balanced", "Confirmation Mode", options = ["Fast", "Balanced", "Strict"], group = G_SCORE,
     tooltip = "Fast reacts earlier, Balanced requires cleaner role-change acceptance, and Strict demands stronger confirmation.")
minReadyScore = input.int(64, "Minimum Ready Score", minval = 1, maxval = 100, group = G_SCORE,
     tooltip = "Minimum 0-100 flip acceptance score required before READY appears.")
breakBufferAtr = input.float(0.08, "Break Buffer ATR", minval = 0.00, maxval = 3.00, step = 0.01, group = G_SCORE,
     tooltip = "ATR-based close distance beyond the source zone required to lock a flip.")
retestWindowBars = input.int(80, "Retest Window Bars", minval = 5, maxval = 600, group = G_SCORE,
     tooltip = "Maximum number of bars after the break during which a flip retest can be evaluated.")
acceptBufferAtr = input.float(0.04, "Acceptance Buffer ATR", minval = 0.00, maxval = 3.00, step = 0.01, group = G_SCORE,
     tooltip = "ATR-based close distance beyond the flip zone required for acceptance.")
invalidationAtr = input.float(0.24, "Invalidation Buffer ATR", minval = 0.02, maxval = 5.00, step = 0.01, group = G_SCORE,
     tooltip = "ATR-based buffer beyond the failed side of the flip zone.")
targetOneAtr = input.float(0.90, "Target 1 ATR", minval = 0.10, maxval = 20.0, step = 0.05, group = G_SCORE,
     tooltip = "First projected target from the flip acceptance edge.")
targetTwoAtr = input.float(1.65, "Target 2 ATR", minval = 0.10, maxval = 30.0, step = 0.05, group = G_SCORE,
     tooltip = "Second projected target from the flip acceptance edge.")
useVolumeScore = input.bool(true, "Use Relative Volume In Score", group = G_SCORE,
     tooltip = "Adds relative volume participation to the flip acceptance score.")
volumeLength = input.int(20, "Relative Volume Length", minval = 2, maxval = 200, group = G_SCORE,
     tooltip = "Lookback used to compare current volume against recent average participation.")

showSourceZones = input.bool(true, "Show Source Zones", group = G_VISUAL,
     tooltip = "Shows latest unflipped supply and demand zones as subtle reference shelves.")
showFlipZone = input.bool(true, "Show Flip Zone", group = G_VISUAL,
     tooltip = "Shows the active role-change zone after a break.")
showZoneText = input.bool(true, "Show Centered Zone Text", group = G_VISUAL,
     tooltip = "Displays centered text inside the active flip zone.")
showSourceZoneText = input.bool(true, "Show Source Zone Text", group = G_VISUAL,
     tooltip = "Displays centered text inside source supply and demand zones. This improves visual clarity when old zones are still active.")
showInvalidationText = input.bool(false, "Show Invalidation Text", group = G_VISUAL,
     tooltip = "Displays centered text inside the invalidation shelf for clearer risk context.")
sourceSupplyColor = input.color(bearColor, "Supply Zone Color", group = G_VISUAL,
     tooltip = "Custom color for source supply zones. Use this when the default supply zone color is too subtle on your chart theme.")
sourceDemandColor = input.color(bullColor, "Demand Zone Color", group = G_VISUAL,
     tooltip = "Custom color for source demand zones. Use this when the default demand zone color is too subtle on your chart theme.")
flipColorMode = input.string("Auto", "Active Flip Color Mode", options = ["Auto", "Custom"], group = G_VISUAL,
     tooltip = "Auto uses demand/supply colors based on flip direction. Custom uses the bullish and bearish flip colors below.")
bullishFlipColorInput = input.color(bullColor, "Bullish Flip Color", group = G_VISUAL,
     tooltip = "Custom color for bullish demand-flip zones when Active Flip Color Mode is set to Custom.")
bearishFlipColorInput = input.color(bearColor, "Bearish Flip Color", group = G_VISUAL,
     tooltip = "Custom color for bearish supply-flip zones when Active Flip Color Mode is set to Custom.")
activeZoneOpacity = input.int(88, "Active Zone Transparency", minval = 70, maxval = 96, group = G_VISUAL,
     tooltip = "Transparency of the active flip zone. Lower values make the zone stronger; higher values make it more subtle.")
sourceZoneOpacity = input.int(94, "Source Zone Transparency", minval = 80, maxval = 98, group = G_VISUAL,
     tooltip = "Transparency of unflipped source supply and demand zones.")
invalidZoneOpacity = input.int(93, "Invalidation Shelf Transparency", minval = 80, maxval = 98, group = G_VISUAL,
     tooltip = "Transparency of the invalidation shelf.")
zoneBorderWidth = input.int(2, "Zone Border Width", minval = 1, maxval = 4, group = G_VISUAL,
     tooltip = "Border width for source zones, active flip zones, and invalidation shelves.")
showInvalidationShelf = input.bool(true, "Show Invalidation Shelf", group = G_VISUAL,
     tooltip = "Shows the risk shelf beyond the failed side of the flip zone.")
showTargetRails = input.bool(true, "Show Target Rails", group = G_VISUAL,
     tooltip = "Shows T1 and T2 reference rails after a qualified flip acceptance.")
showEventLabels = input.bool(true, "Show Event Labels", group = G_VISUAL,
     tooltip = "Displays zone, retest, acceptance, and invalidation labels on the chart.")
showSourceLabels = input.bool(false, "Show Source Zone Labels", group = G_VISUAL,
     tooltip = "Displays labels when new supply or demand zones are detected. Cooldown and maximum label limits keep the chart readable.")
showRetestLabels = input.bool(true, "Show Retest Labels", group = G_VISUAL,
     tooltip = "Displays labels when price retests the active flip zone.")
showInvalidLabels = input.bool(false, "Show Invalidated Labels", group = G_VISUAL,
     tooltip = "Displays labels when the active flip context is invalidated.")
showRightTags = input.bool(true, "Show Right-Side Tags", group = G_VISUAL,
     tooltip = "Displays the T1 and T2 target price tags at the right end of the target rails.")
projectionBars = input.int(72, "Projection Bars", minval = 10, maxval = 300, group = G_VISUAL,
     tooltip = "How far active zones and rails project into the future.")
maxEventLabels = input.int(8, "Maximum Event Labels", minval = 0, maxval = 80, group = G_VISUAL,
     tooltip = "Limits historical labels so the chart remains readable.")
labelCooldownBars = input.int(22, "Label Cooldown Bars", minval = 1, maxval = 300, group = G_VISUAL,
     tooltip = "Minimum bars between repeated labels of the same type.")
labelOffsetAtr = input.float(0.38, "Label Offset ATR", minval = 0.05, maxval = 5.00, step = 0.05, group = G_VISUAL,
     tooltip = "Vertical distance between labels and candles. Clustered labels are staggered automatically beyond this base distance.")
labelSizeInput = input.string("Normal", "Label Font Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = G_VISUAL,
     tooltip = "Controls chart label font size.")
showBarColors = input.bool(false, "Color Bars By State", group = G_VISUAL,
     tooltip = "Optionally colors bars according to active flip state.")

showPanel = input.bool(true, "Show Panel", group = G_PANEL,
     tooltip = "Shows or hides the AG Pro dashboard.")
panelPositionInput = input.string("Top Right", "Panel Location",
     options = ["Top Right", "Top Left", "Middle Right", "Middle Left", "Bottom Right", "Bottom Left"],
     group = G_PANEL,
     tooltip = "Controls where the panel appears on the chart.")
panelTheme = input.string("Dark", "Panel Theme", options = ["Dark", "Light"], group = G_PANEL,
     tooltip = "Controls panel color theme.")
panelFontSizeInput = input.string("Normal", "Panel Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = G_PANEL,
     tooltip = "Controls panel text size.")
showPanelContextRows = input.bool(true, "Show Panel Context Rows", group = G_PANEL,
     tooltip = "Adds active zone and target context rows to the panel.")

alertFlipLocked = input.bool(true, "Alert: Flip Locked", group = G_ALERTS,
     tooltip = "Enables alerts when a source supply or demand zone flips after a valid break.")
alertReady = input.bool(true, "Alert: Flip Acceptance Ready", group = G_ALERTS,
     tooltip = "Enables alerts when a flip retest reaches the ready threshold.")
alertRetest = input.bool(true, "Alert: Flip Retest", group = G_ALERTS,
     tooltip = "Enables alerts when price retests the active flip zone.")
alertInvalidated = input.bool(true, "Alert: Flip Invalidated", group = G_ALERTS,
     tooltip = "Enables alerts when an active flip context is invalidated.")

// -------------------------------------------------
// Core calculations
// -------------------------------------------------
labelSize = f_size(labelSizeInput)
panelSize = f_table_size(panelFontSizeInput)
atr = ta.atr(atrLength)
volAvg = ta.sma(volume, volumeLength)
rvol = volAvg > 0 ? volume / volAvg : 1.0
volumeOk = minVolume <= 0 or volume >= minVolume
zoneDepth = atr * zoneDepthAtr
breakBuffer = atr * breakBufferAtr
acceptBuffer = atr * acceptBufferAtr
activeZoneTrans = int(f_clamp(activeZoneOpacity, 70, 96))
sourceZoneTrans = int(f_clamp(sourceZoneOpacity, 80, 98))
invalidZoneTrans = int(f_clamp(invalidZoneOpacity, 80, 98))

pivotHigh = ta.pivothigh(high, pivotLeft, pivotRight)
pivotLow = ta.pivotlow(low, pivotLeft, pivotRight)
newSupply = not na(pivotHigh)
newDemand = not na(pivotLow)
pivotAtr = nz(atr[pivotRight], atr)

var float supplyTop = na
var float supplyBottom = na
var int supplyBar = na
var bool supplyActive = false
var float demandTop = na
var float demandBottom = na
var int demandBar = na
var bool demandActive = false

if newSupply
    supplyTop := pivotHigh
    supplyBottom := pivotHigh - pivotAtr * zoneDepthAtr
    supplyBar := bar_index - pivotRight
    supplyActive := true

if newDemand
    demandBottom := pivotLow
    demandTop := pivotLow + pivotAtr * zoneDepthAtr
    demandBar := bar_index - pivotRight
    demandActive := true

supplyAge = supplyActive and not na(supplyBar) ? bar_index - supplyBar : na
demandAge = demandActive and not na(demandBar) ? bar_index - demandBar : na
if supplyActive and not na(supplyAge) and supplyAge > maxZoneAgeBars
    supplyActive := false
if demandActive and not na(demandAge) and demandAge > maxZoneAgeBars
    demandActive := false

var int activeDir = 0
var int flipBar = na
var float flipTop = na
var float flipBottom = na
var float flipMid = na
var float flipAtr = na
var float sourceQuality = na
var bool hasFlip = false
var bool activeAcceptance = false
var int acceptanceBar = na
var float acceptanceScore = na
var int lastSourceLabelBar = na
var int lastFlipLabelBar = na
var int lastRetestLabelBar = na
var int lastReadyLabelBar = na
var int lastInvalidLabelBar = na

bullFlipLocked = supplyActive and close > supplyTop + breakBuffer
bearFlipLocked = demandActive and close < demandBottom - breakBuffer
flipLocked = bullFlipLocked or bearFlipLocked

if bullFlipLocked
    activeDir := 1
    flipTop := supplyTop
    flipBottom := supplyBottom
    flipMid := (flipTop + flipBottom) * 0.5
    flipBar := bar_index
    flipAtr := atr
    sourceQuality := f_clamp((supplyTop - supplyBottom) / math.max(atr, syminfo.mintick) / 0.65, 0.0, 1.0) * 100.0
    hasFlip := true
    activeAcceptance := false
    acceptanceBar := na
    acceptanceScore := na
    supplyActive := false

if bearFlipLocked
    activeDir := -1
    flipTop := demandTop
    flipBottom := demandBottom
    flipMid := (flipTop + flipBottom) * 0.5
    flipBar := bar_index
    flipAtr := atr
    sourceQuality := f_clamp((demandTop - demandBottom) / math.max(atr, syminfo.mintick) / 0.65, 0.0, 1.0) * 100.0
    hasFlip := true
    activeAcceptance := false
    acceptanceBar := na
    acceptanceScore := na
    demandActive := false

flipAge = hasFlip and not na(flipBar) ? bar_index - flipBar : na
flipExpired = hasFlip and not na(flipAge) and flipAge > retestWindowBars and not activeAcceptance
if flipExpired
    hasFlip := false
    activeAcceptance := false

zoneSize = hasFlip ? math.max(flipTop - flipBottom, syminfo.mintick) : na
retest = hasFlip and high >= flipBottom and low <= flipTop
barsSinceRetest = ta.barssince(retest)
retestRecent = not na(barsSinceRetest) and barsSinceRetest <= 5
bullAccepted = hasFlip and activeDir == 1 and retestRecent and close > flipTop + acceptBuffer
bearAccepted = hasFlip and activeDir == -1 and retestRecent and close < flipBottom - acceptBuffer
acceptedEvent = bullAccepted or bearAccepted

rangeSize = math.max(high - low, syminfo.mintick)
breakStrength = hasFlip ? activeDir == 1 ? (close - flipTop) / math.max(atr, syminfo.mintick) : (flipBottom - close) / math.max(atr, syminfo.mintick) : 0.0
retestDepth = hasFlip ? activeDir == 1 ? f_clamp((flipTop - low) / zoneSize, 0.0, 1.0) : f_clamp((high - flipBottom) / zoneSize, 0.0, 1.0) : 0.0
wickResponse = hasFlip ? activeDir == 1 ? (math.min(open, close) - low) / rangeSize : (high - math.max(open, close)) / rangeSize : 0.0
bodyRatio = math.abs(close - open) / rangeSize
freshness = hasFlip and not na(flipAge) ? f_clamp(1.0 - flipAge / math.max(retestWindowBars, 1), 0.0, 1.0) : 0.0

breakScore = f_clamp(breakStrength / 0.70, 0.0, 1.0) * 21.0
retestScoreRaw = f_clamp(retestDepth / 0.75, 0.0, 1.0) * 20.0
wickScore = f_clamp(wickResponse / 0.55, 0.0, 1.0) * 17.0
bodyScore = f_clamp(bodyRatio / 0.62, 0.0, 1.0) * 12.0
sourceScore = f_clamp(nz(sourceQuality, 0.0) / 100.0, 0.0, 1.0) * 13.0
freshScore = freshness * 7.0
volumeScore = useVolumeScore ? f_clamp(rvol / 1.6, 0.0, 1.0) * 10.0 : 7.0
candidateScore = f_clamp(breakScore + retestScoreRaw + wickScore + bodyScore + sourceScore + freshScore + volumeScore, 0.0, 100.0)
confirmBonus = confirmationMode == "Fast" ? 5.0 : confirmationMode == "Balanced" ? 0.0 : -8.0
requiredScore = f_clamp(minReadyScore - confirmBonus, 1.0, 100.0)
readyEvent = acceptedEvent and candidateScore >= requiredScore

if readyEvent
    activeAcceptance := true
    acceptanceBar := bar_index
    acceptanceScore := candidateScore

acceptanceAge = activeAcceptance and not na(acceptanceBar) ? bar_index - acceptanceBar : na
withinAcceptanceWindow = activeAcceptance and not na(acceptanceAge) and acceptanceAge <= retestWindowBars
invalidLine = hasFlip ? activeDir == 1 ? flipBottom - atr * invalidationAtr : flipTop + atr * invalidationAtr : na
invalidatedEvent = hasFlip and ((activeDir == 1 and close < invalidLine) or (activeDir == -1 and close > invalidLine))
resetFlipAfterRender = invalidatedEvent
acceptanceExpired = activeAcceptance and not withinAcceptanceWindow
if acceptanceExpired
    activeAcceptance := false

acceptanceEdge = activeDir == 1 ? flipTop : flipBottom
t1 = activeDir == 1 ? acceptanceEdge + atr * targetOneAtr : activeDir == -1 ? acceptanceEdge - atr * targetOneAtr : na
t2 = activeDir == 1 ? acceptanceEdge + atr * targetTwoAtr : activeDir == -1 ? acceptanceEdge - atr * targetTwoAtr : na
roomToT1 = withinAcceptanceWindow and not na(t1) ? activeDir == 1 ?
     f_clamp((t1 - close) / math.max(t1 - acceptanceEdge, syminfo.mintick), 0.0, 1.5) :
     f_clamp((close - t1) / math.max(acceptanceEdge - t1, syminfo.mintick), 0.0, 1.5) : na
failureRisk = hasFlip ? f_clamp((100.0 - nz(acceptanceScore, candidateScore)) * 0.24 + (retest and not acceptedEvent ? 18.0 : 0.0) + (invalidatedEvent ? 55.0 : 0.0), 0.0, 100.0) : na

var string actionState = "WAIT"
var string flipState = "No Active Flip"
var string acceptanceText = "n/a"
var string retestText = "n/a"
var string riskText = "n/a"
var float panelScore = na

if not hasFlip
    actionState := "WAIT"
    flipState := "No Active Flip"
    acceptanceText := "n/a"
    retestText := "n/a"
    riskText := "n/a"
    panelScore := na
else if readyEvent
    actionState := "READY"
    flipState := activeDir == 1 ? "Demand Flip Accepted" : "Supply Flip Accepted"
    acceptanceText := f_score_text(candidateScore)
    retestText := str.tostring(math.round(retestDepth * 100.0)) + "%"
    riskText := str.tostring(math.round(nz(failureRisk, 0.0))) + "/100"
    panelScore := candidateScore
else if invalidatedEvent
    actionState := "INVALIDATED"
    flipState := "Flip Failed"
    acceptanceText := f_score_text(acceptanceScore)
    retestText := "Failed"
    riskText := "100/100"
    panelScore := acceptanceScore
else if withinAcceptanceWindow
    actionState := "MONITOR"
    flipState := activeDir == 1 ? "Demand Flip Active" : "Supply Flip Active"
    acceptanceText := f_score_text(acceptanceScore)
    retestText := not na(roomToT1) ? str.tostring(math.round(roomToT1 * 100.0)) + "% room" : "Active"
    riskText := str.tostring(math.round(nz(failureRisk, 0.0))) + "/100"
    panelScore := acceptanceScore
else if retest
    actionState := "MONITOR"
    flipState := "Retest In Progress"
    acceptanceText := "Pending"
    retestText := str.tostring(math.round(retestDepth * 100.0)) + "%"
    riskText := str.tostring(math.round(nz(failureRisk, 0.0))) + "/100"
    panelScore := na
else if flipExpired
    actionState := "EXPIRED"
    flipState := "Flip Expired"
    acceptanceText := "n/a"
    retestText := "n/a"
    riskText := "n/a"
    panelScore := na
else
    actionState := "WAIT"
    flipState := activeDir == 1 ? "Demand Flip Locked" : "Supply Flip Locked"
    acceptanceText := "Waiting"
    retestText := "No retest"
    riskText := str.tostring(math.round(nz(failureRisk, 0.0))) + "/100"
    panelScore := na

// -------------------------------------------------
// Visuals
// -------------------------------------------------
var box supplyBox = na
var box demandBox = na
var box flipBox = na
var box invalidBox = na
var line t1Line = na
var line t2Line = na
var label tagT1 = na
var label tagT2 = na
var label badgeSupply = na
var label badgeDemand = na
var label badgeFlip = na
var label badgeShelf = na
var label[] eventLabels = array.new_label()
var label[] cycleWatch = array.new_label()
var int[] recentLabelBars = array.new_int()
int COLLISION_WIN = 25

// Places an event label with automatic anti-collision staggering. Labels that
// land within COLLISION_WIN bars of recent labels step progressively farther
// from the candles so clustered events stay readable instead of overlapping.
f_event_label(int bx, float basePrice, bool below, string txt, color col) =>
    int level = 0
    if array.size(recentLabelBars) > 0
        for i = 0 to array.size(recentLabelBars) - 1
            if math.abs(bx - array.get(recentLabelBars, i)) <= COLLISION_WIN
                level += 1
    level := math.min(level, 4)
    float off = atr * labelOffsetAtr * (1.0 + level * 0.95)
    float y = below ? basePrice - off : basePrice + off
    label lb = label.new(bx, y, txt, style = below ? label.style_label_up : label.style_label_down, textcolor = headerText, color = col, size = labelSize)
    array.push(recentLabelBars, bx)
    if array.size(recentLabelBars) > 16
        array.shift(recentLabelBars)
    array.push(eventLabels, lb)
    if array.size(eventLabels) > maxEventLabels
        label.delete(array.shift(eventLabels))
    lb

// Draws a centered zone label as a solid badge in the zone color. A filled
// badge stays readable on any chart theme, unlike plain box text which can
// vanish on light backgrounds.
f_set_badge(label lb, bool show, int leftBar, int rightBar, float yTop, float yBottom, string txt, color zoneCol) =>
    label result = lb
    if show and not na(yTop) and not na(yBottom) and txt != ""
        int midX = int(math.round((leftBar + rightBar) / 2.0))
        float midY = (yTop + yBottom) / 2.0
        if na(result)
            result := label.new(midX, midY, txt, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_center, color = color.new(zoneCol, 0), textcolor = color.white, size = labelSize)
        else
            label.set_xy(result, midX, midY)
            label.set_text(result, txt)
            label.set_color(result, color.new(zoneCol, 0))
            label.set_textcolor(result, color.white)
            label.set_size(result, labelSize)
    else
        if not na(result)
            label.delete(result)
            result := na
    result

rightX = bar_index + projectionBars
autoFlipColor = activeDir == 1 ? sourceDemandColor : activeDir == -1 ? sourceSupplyColor : accentColor
customFlipColor = activeDir == 1 ? bullishFlipColorInput : activeDir == -1 ? bearishFlipColorInput : accentColor
flipColor = flipColorMode == "Custom" ? customFlipColor : autoFlipColor

if showSourceZones and supplyActive and not na(supplyTop) and not na(supplyBottom)
    if na(supplyBox)
        supplyBox := box.new(supplyBar, supplyTop, rightX, supplyBottom,
             bgcolor = color.new(sourceSupplyColor, sourceZoneTrans),
             border_color = color.new(sourceSupplyColor, 54),
             border_width = zoneBorderWidth)
    else
        box.set_lefttop(supplyBox, supplyBar, supplyTop)
        box.set_rightbottom(supplyBox, rightX, supplyBottom)
    box.set_bgcolor(supplyBox, color.new(sourceSupplyColor, sourceZoneTrans))
    box.set_border_color(supplyBox, color.new(sourceSupplyColor, 54))
    box.set_border_width(supplyBox, zoneBorderWidth)
else
    if not na(supplyBox)
        box.delete(supplyBox)
        supplyBox := na

if showSourceZones and demandActive and not na(demandTop) and not na(demandBottom)
    if na(demandBox)
        demandBox := box.new(demandBar, demandTop, rightX, demandBottom,
             bgcolor = color.new(sourceDemandColor, sourceZoneTrans),
             border_color = color.new(sourceDemandColor, 54),
             border_width = zoneBorderWidth)
    else
        box.set_lefttop(demandBox, demandBar, demandTop)
        box.set_rightbottom(demandBox, rightX, demandBottom)
    box.set_bgcolor(demandBox, color.new(sourceDemandColor, sourceZoneTrans))
    box.set_border_color(demandBox, color.new(sourceDemandColor, 54))
    box.set_border_width(demandBox, zoneBorderWidth)
else
    if not na(demandBox)
        box.delete(demandBox)
        demandBox := na

if showFlipZone and hasFlip and not na(flipTop) and not na(flipBottom)
    if na(flipBox)
        flipBox := box.new(flipBar, flipTop, rightX, flipBottom,
             bgcolor = color.new(flipColor, activeZoneTrans),
             border_color = color.new(flipColor, 18),
             border_width = zoneBorderWidth)
    else
        box.set_lefttop(flipBox, flipBar, flipTop)
        box.set_rightbottom(flipBox, rightX, flipBottom)
        box.set_bgcolor(flipBox, color.new(flipColor, activeZoneTrans))
        box.set_border_color(flipBox, color.new(flipColor, 18))
        box.set_border_width(flipBox, zoneBorderWidth)
else
    if not na(flipBox)
        box.delete(flipBox)
        flipBox := na

invalidTop = activeDir == 1 ? flipBottom : invalidLine
invalidBottom = activeDir == 1 ? invalidLine : flipTop
if showInvalidationShelf and hasFlip and not na(invalidTop) and not na(invalidBottom)
    if na(invalidBox)
        invalidBox := box.new(flipBar, invalidTop, rightX, invalidBottom,
             bgcolor = color.new(bearColor, invalidZoneTrans),
             border_color = color.new(bearColor, 38),
             border_width = zoneBorderWidth)
    else
        box.set_lefttop(invalidBox, flipBar, invalidTop)
        box.set_rightbottom(invalidBox, rightX, invalidBottom)
    box.set_bgcolor(invalidBox, color.new(bearColor, invalidZoneTrans))
    box.set_border_color(invalidBox, color.new(bearColor, 38))
    box.set_border_width(invalidBox, zoneBorderWidth)
else
    if not na(invalidBox)
        box.delete(invalidBox)
        invalidBox := na

// Centered zone badges (solid, in zone color) - readable on any chart theme
if barstate.islast
    flipScoreText = not na(acceptanceScore) ? "Score " + str.tostring(math.round(acceptanceScore)) : readyEvent ? "Score " + str.tostring(math.round(candidateScore)) : "Acceptance Watch"
    flipBadgeText = activeDir == 1 ? "Demand Flip\n" + flipScoreText : "Supply Flip\n" + flipScoreText
    badgeSupply := f_set_badge(badgeSupply, showSourceZones and showSourceZoneText and supplyActive, supplyBar, rightX, supplyTop, supplyBottom, "Supply Source\nBreak above -> Demand flip", sourceSupplyColor)
    badgeDemand := f_set_badge(badgeDemand, showSourceZones and showSourceZoneText and demandActive, demandBar, rightX, demandTop, demandBottom, "Demand Source\nBreak below -> Supply flip", sourceDemandColor)
    badgeFlip := f_set_badge(badgeFlip, showFlipZone and showZoneText and hasFlip, flipBar, rightX, flipTop, flipBottom, flipBadgeText, flipColor)
    badgeShelf := f_set_badge(badgeShelf, showInvalidationShelf and showInvalidationText and hasFlip, flipBar, rightX, invalidTop, invalidBottom, "Invalidation Shelf", bearColor)

if showTargetRails and withinAcceptanceWindow and not na(t1) and not na(t2)
    if na(t1Line)
        t1Line := line.new(acceptanceBar, t1, rightX, t1, color = color.new(neutralColor, 0), width = 2, style = line.style_dashed)
    else
        line.set_xy1(t1Line, acceptanceBar, t1)
        line.set_xy2(t1Line, rightX, t1)
        line.set_color(t1Line, color.new(neutralColor, 0))
        line.set_width(t1Line, 2)
    if na(t2Line)
        t2Line := line.new(acceptanceBar, t2, rightX, t2, color = color.new(accentColor, 0), width = 2, style = line.style_dashed)
    else
        line.set_xy1(t2Line, acceptanceBar, t2)
        line.set_xy2(t2Line, rightX, t2)
        line.set_color(t2Line, color.new(accentColor, 0))
        line.set_width(t2Line, 2)
else
    if not na(t1Line)
        line.delete(t1Line)
        t1Line := na
    if not na(t2Line)
        line.delete(t2Line)
        t2Line := na

canSourceLabel = na(lastSourceLabelBar) or bar_index - lastSourceLabelBar >= labelCooldownBars
canFlipLabel = na(lastFlipLabelBar) or bar_index - lastFlipLabelBar >= labelCooldownBars
canRetestLabel = na(lastRetestLabelBar) or bar_index - lastRetestLabelBar >= labelCooldownBars
canReadyLabel = na(lastReadyLabelBar) or bar_index - lastReadyLabelBar >= labelCooldownBars
canInvalidLabel = na(lastInvalidLabelBar) or bar_index - lastInvalidLabelBar >= labelCooldownBars

if showEventLabels and showSourceLabels and (newSupply or newDemand) and canSourceLabel
    sourceDir = newDemand ? 1 : -1
    f_event_label(bar_index - pivotRight, sourceDir == 1 ? pivotLow : pivotHigh, sourceDir == 1, sourceDir == 1 ? "DEMAND\nZone mapped" : "SUPPLY\nZone mapped", color.new(sourceDir == 1 ? bullColor : bearColor, 0))
    lastSourceLabelBar := bar_index

if flipLocked
    array.clear(cycleWatch)

if showEventLabels and flipLocked and canFlipLabel
    lblFlip = f_event_label(bar_index, activeDir == 1 ? low : high, activeDir == 1, activeDir == 1 ? "DEMAND FLIP\nRetest watch" : "SUPPLY FLIP\nRetest watch", color.new(activeDir == 1 ? bullColor : bearColor, 0))
    array.push(cycleWatch, lblFlip)
    lastFlipLabelBar := bar_index

if showEventLabels and showRetestLabels and retest and not readyEvent and canRetestLabel
    lblRetest = f_event_label(bar_index, activeDir == 1 ? low : high, activeDir == 1, "FLIP RETEST\nAcceptance watch", color.new(neutralColor, 0))
    array.push(cycleWatch, lblRetest)
    lastRetestLabelBar := bar_index

if showEventLabels and readyEvent
    if array.size(cycleWatch) > 0
        for i = 0 to array.size(cycleWatch) - 1
            label.delete(array.get(cycleWatch, i))
        array.clear(cycleWatch)
    if canReadyLabel
        f_event_label(bar_index, activeDir == 1 ? low : high, activeDir == 1, "READY FLIP\nScore " + str.tostring(math.round(candidateScore)), color.new(activeDir == 1 ? bullColor : bearColor, 0))
        lastReadyLabelBar := bar_index

if showEventLabels and showInvalidLabels and invalidatedEvent and canInvalidLabel
    f_event_label(bar_index, activeDir == 1 ? high : low, activeDir != 1, "INVALIDATED\nLost flip edge", color.new(bearColor, 0))
    lastInvalidLabelBar := bar_index

if barstate.islast and showRightTags and hasFlip and withinAcceptanceWindow and not na(t1) and not na(t2)
    if not na(tagT1)
        label.delete(tagT1)
    if not na(tagT2)
        label.delete(tagT2)
    tagT1 := label.new(rightX, t1,
         "T1  " + str.tostring(t1, format.mintick),
         style = label.style_label_left,
         textcolor = headerText,
         color = color.new(neutralColor, 8),
         size = labelSize)
    tagT2 := label.new(rightX, t2,
         "T2  " + str.tostring(t2, format.mintick),
         style = label.style_label_left,
         textcolor = headerText,
         color = color.new(accentColor, 8),
         size = labelSize)
else if barstate.islast
    if not na(tagT1)
        label.delete(tagT1)
        tagT1 := na
    if not na(tagT2)
        label.delete(tagT2)
        tagT2 := na

// -------------------------------------------------
// Panel
// -------------------------------------------------
panelBgFinal = panelTheme == "Dark" ? panelBg : color.rgb(248, 250, 252)
panelLeftFinal = panelTheme == "Dark" ? color.new(panelBorder, 0) : color.rgb(226, 232, 240)
panelTextFinal = panelTheme == "Dark" ? panelValueCol : color.rgb(15, 23, 42)
panelLabelFinal = panelTheme == "Dark" ? panelLabelCol : color.rgb(71, 85, 105)

var table panel = table.new(position.top_right, 2, 8, border_width = 1)

if showPanel and barstate.islast
    table.set_position(panel, f_panel_position(panelPositionInput))
    table.set_border_color(panel, panelBorder)
    table.set_frame_color(panel, panelBorder)
    table.cell(panel, 0, 0, "AG Pro Supply Demand Flip Planner",
         text_color = headerText,
         bgcolor = headerBg,
         text_size = panelSize)
    table.cell(panel, 1, 0, "",
         text_color = headerText,
         bgcolor = headerBg,
         text_size = panelSize)
    table.merge_cells(panel, 0, 0, 1, 0)
    table.cell(panel, 0, 1, "Flip State",
         text_color = panelLabelFinal,
         bgcolor = panelLeftFinal,
         text_size = panelSize)
    table.cell(panel, 1, 1, flipState,
         text_color = panelTextFinal,
         bgcolor = panelBgFinal,
         text_size = panelSize)
    table.cell(panel, 0, 2, "Acceptance",
         text_color = panelLabelFinal,
         bgcolor = panelLeftFinal,
         text_size = panelSize)
    table.cell(panel, 1, 2, acceptanceText,
         text_color = panelTextFinal,
         bgcolor = panelBgFinal,
         text_size = panelSize)
    table.cell(panel, 0, 3, "Retest",
         text_color = panelLabelFinal,
         bgcolor = panelLeftFinal,
         text_size = panelSize)
    table.cell(panel, 1, 3, retestText,
         text_color = panelTextFinal,
         bgcolor = panelBgFinal,
         text_size = panelSize)
    table.cell(panel, 0, 4, "Failure Risk",
         text_color = panelLabelFinal,
         bgcolor = panelLeftFinal,
         text_size = panelSize)
    table.cell(panel, 1, 4, riskText,
         text_color = panelTextFinal,
         bgcolor = panelBgFinal,
         text_size = panelSize)
    table.cell(panel, 0, 5, "Action",
         text_color = panelLabelFinal,
         bgcolor = panelLeftFinal,
         text_size = panelSize)
    table.cell(panel, 1, 5, actionState,
         text_color = headerText,
         bgcolor = f_action_color(actionState),
         text_size = panelSize)
    zoneRangeText = hasFlip ? str.tostring(flipBottom, format.mintick) + " - " + str.tostring(flipTop, format.mintick) : "n/a"
    targetsText = withinAcceptanceWindow and not na(t1) and not na(t2) ? "T1 " + str.tostring(t1, format.mintick) + " | T2 " + str.tostring(t2, format.mintick) : "n/a"
    if showPanelContextRows
        table.cell(panel, 0, 6, "Active Zone",
             text_color = panelLabelFinal,
             bgcolor = panelLeftFinal,
             text_size = panelSize)
        table.cell(panel, 1, 6, zoneRangeText,
             text_color = panelTextFinal,
             bgcolor = panelBgFinal,
             text_size = panelSize)
        table.cell(panel, 0, 7, "Targets",
             text_color = panelLabelFinal,
             bgcolor = panelLeftFinal,
             text_size = panelSize)
        table.cell(panel, 1, 7, targetsText,
             text_color = panelTextFinal,
             bgcolor = panelBgFinal,
             text_size = panelSize)
    else
        table.cell(panel, 0, 6, "", bgcolor = panelBgFinal, text_size = panelSize)
        table.cell(panel, 1, 6, "", bgcolor = panelBgFinal, text_size = panelSize)
        table.cell(panel, 0, 7, "", bgcolor = panelBgFinal, text_size = panelSize)
        table.cell(panel, 1, 7, "", bgcolor = panelBgFinal, text_size = panelSize)

if not showPanel and barstate.islast
    table.clear(panel, 0, 0, 1, 7)

// -------------------------------------------------
// Bar color and alerts
// -------------------------------------------------
barStateColor = actionState == "READY" ? color.new(activeDir == 1 ? bullColor : bearColor, 76) :
     actionState == "MONITOR" ? color.new(activeDir == 1 ? bullColor : bearColor, 84) :
     actionState == "INVALIDATED" ? color.new(bearColor, 80) : na
barcolor(showBarColors ? barStateColor : na)

alertcondition(alertFlipLocked and bullFlipLocked, "Demand Flip Locked",
     "AG Pro SDF | DEMAND FLIP LOCKED | {{ticker}} | {{interval}}")
alertcondition(alertFlipLocked and bearFlipLocked, "Supply Flip Locked",
     "AG Pro SDF | SUPPLY FLIP LOCKED | {{ticker}} | {{interval}}")
alertcondition(alertReady and readyEvent and activeDir == 1, "Demand Flip Acceptance Ready",
     "AG Pro SDF | DEMAND FLIP ACCEPTANCE READY | {{ticker}} | {{interval}}")
alertcondition(alertReady and readyEvent and activeDir == -1, "Supply Flip Acceptance Ready",
     "AG Pro SDF | SUPPLY FLIP ACCEPTANCE READY | {{ticker}} | {{interval}}")
alertcondition(alertRetest and retest, "Supply Demand Flip Retest",
     "AG Pro SDF | FLIP RETEST | {{ticker}} | {{interval}}")
alertcondition(alertInvalidated and invalidatedEvent, "Supply Demand Flip Invalidated",
     "AG Pro SDF | FLIP INVALIDATED | {{ticker}} | {{interval}}")

if resetFlipAfterRender
    hasFlip := false
    activeAcceptance := false
````
