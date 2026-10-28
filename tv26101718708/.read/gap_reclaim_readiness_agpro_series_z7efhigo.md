# Gap Reclaim Readiness [AGPro Series]

- url: https://www.tradingview.com/script/Z7EfHIgo-Gap-Reclaim-Readiness-AGPro-Series/
- type: indicator
- pine_id: PUB;9d899f357a6849fea01d8e6ff7766535
- version: 4.0

## Description

# Gap Reclaim Readiness [AGPro Series]

🧠 Core Idea

Can price reclaim a gap edge with enough acceptance to make the structure worth monitoring?

📌 Overview / What it does

Gap Reclaim Readiness is a chart-first gap edge decision-support script built to evaluate whether price has returned to a gap boundary and reclaimed it with enough structural quality.

The script maps active gap zones, identifies the reclaim edge, builds a focused reclaim pocket, scores the reclaim from 0 to 100, and summarizes the current state inside a compact AG Pro panel.

It does not predict price direction, automate trades, or provide guaranteed signals. It is designed to organize gap-edge context, reclaim quality, fill risk, and continuation state into a clean visual workflow.

🎯 Purpose & Design Philosophy

Many gap tools focus only on whether a gap exists or whether it has been filled.

This script was built for the more practical question: after a gap forms, does price respect and reclaim the edge strongly enough to deserve attention?

It helps traders who use price action, gap reactions, continuation structure, and intraday context, while supporting a patient decision-making process instead of impulsive reaction.

⚡ Why This Script Is Different

Most tools focus on detecting gaps or tracking gap fill.

This script does NOT behave like a generic gap fill tracker.

Instead, it focuses on the reclaim edge: whether price returns to the boundary, accepts it, loses it, or fails to develop a clean reclaim context.

⚙️ Methodology

1. Gap Context Detection
2. Reclaim Edge Mapping
3. Reclaim Pocket Construction
4. Reaction And Acceptance Evaluation
5. 0-100 Reclaim Score
6. Fill Risk And Continuation State
7. Visual Output And Panel Summary

🗺️ How to Read the Chart

The gap zone marks the structural area created by a qualifying gap or displacement-style gap event.

The reclaim edge marks the key boundary price must respect to form a valid reclaim context.

The reclaim pocket highlights the area around the edge where reaction quality is evaluated.

READY RECLAIM labels appear when the reclaim context meets the required score threshold.

Target rails show projected continuation references after a qualified reclaim.

The panel summarizes Gap Edge, Reclaim Score, Fill Risk, Continuation, and Action.

🚦 Signals & States

• READY → A qualified gap edge reclaim has formed.

• MONITOR → A gap structure exists and the script is watching for reclaim behavior.

• WAIT → No active reclaim context is currently valid.

• INVALIDATED → Price failed back through the reclaim edge.

• EXPIRED → The reclaim window closed without a qualified reclaim.

🔔 Alerts Logic

Bullish Gap Reclaim Ready triggers when price reclaims a bullish gap edge with enough score.

Bearish Gap Reclaim Ready triggers when price reclaims a bearish gap edge with enough score.

Gap Reclaim Invalidated triggers when price fails back through the reclaim edge.

Gap Reclaim Expired triggers when the reclaim window closes without a qualified reclaim.

Alerts are attention markers, not trade instructions.

🧩 Confluence Logic

The reclaim score combines edge interaction, close acceptance, time quality, relative volume, gap size, and available continuation room.

When several of these conditions align, the context becomes stronger.

When they do not align, the script remains in WAIT, MONITOR, INVALIDATED, or EXPIRED state.

📊 When to Use

• Intraday price action workflows

• Gap reaction analysis

• Breakout and reclaim structures

• Continuation after displacement

• Markets where gap edges or price void boundaries matter

⚠️ When NOT to Use

Avoid relying on this script in extremely illiquid markets, very noisy low-volume symbols, holiday sessions, or conditions where gaps and displacement structures are not meaningful.

It should also not be used as a standalone decision tool without broader market context.

🎛️ Key Inputs

• Gap Mode controls how strict the gap detection logic is.

• Minimum Gap Size filters weak structures.

• Displacement Gap Fallback helps continuous markets where classic open gaps are rare.

• Reclaim Pocket ATR controls the depth of the reclaim pocket.

• Minimum Ready Score controls how strong the reclaim must be before READY appears.

• Fill Risk Threshold controls when a reclaim context becomes too filled or exhausted.

• Visual settings control labels, zones, right-side tags, panel location, and font size.

🖥️ Interface & Visual Design

The interface is designed to keep the chart readable while making the active reclaim structure easy to understand.

The panel uses the AG Pro blue header style and summarizes the current state without covering the whole chart.

Zones, pockets, labels, and target rails are designed to show structure first and avoid unnecessary noise.

🧪 Practical Usage Workflow

1. Identify whether the panel shows an active gap edge.

2. Check the reclaim pocket and nearby price reaction.

3. Read the reclaim score and fill risk.

4. Confirm whether the action state is READY, MONITOR, WAIT, INVALIDATED, or EXPIRED.

5. Combine the output with broader structure, liquidity, trend, and risk context.

🔍 Interpretation Guidelines

A higher reclaim score means the gap edge reaction is cleaner according to the script logic.

A high fill risk means the gap context may already be too consumed.

READY means the reclaim condition deserves attention, not that price must continue.

WAIT means there is no valid active reclaim context.

🚫 What This Script Is NOT

This script is not a prediction engine.

It is not financial advice.

It is not an auto-trading system.

It does not provide guaranteed signals.

It does not replace risk management or independent analysis.

⚠️ Limitations & Transparency

Gap behavior changes across markets, timeframes, liquidity conditions, and volatility regimes.

Continuous markets may create fewer classic gaps, so adaptive displacement logic is included to support broader usability.

Different symbols and timeframes may require different sensitivity settings.

🧠 Market Context Notes

Gap reclaim behavior is often stronger when aligned with trend, liquidity response, volume participation, and clean structure.

Weak reclaim attempts can fail quickly when price loses the edge or when the gap becomes fully consumed.

🔐 Non-Promise Statement

No script can guarantee future price behavior.

This tool provides structured visual context only.

📉 Risk Disclosure

Trading involves risk.

Users remain responsible for their own decisions.

This script is for educational and analytical purposes only and does not provide financial advice or guaranteed trading outcomes.

## Source Code

````pine
// -------------------------------------------------
// Gap Reclaim Readiness [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 1.7
//
// Gap Reclaim Readiness is a chart-first gap edge decision engine that
// evaluates whether price has reclaimed a gap boundary with enough
// acceptance to justify attention. It tracks the latest active bullish
// or bearish gap, builds a reclaim pocket around the edge, scores the
// reclaim from 0-100, and organizes the next action into a clean AG Pro
// panel without turning the script into a generic gap fill or gap
// continuation overlay. Version 1.7 preserves the original engine while
// separating historical event badges and active right-side rail tags with
// font-aware, volatility-aware spacing and owned connector guides.
// -------------------------------------------------

//@version=6
indicator("Gap Reclaim Readiness [AGPro Series]",
     shorttitle = "AG Pro GR",
     overlay = true,
     max_boxes_count = 120,
     max_labels_count = 120,
     max_lines_count = 80)

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

f_text_on(_c) =>
    _lum = (color.r(_c) * 299 + color.g(_c) * 587 + color.b(_c) * 114) / 1000
    _lum >= 145 ? color.rgb(17, 24, 39) : headerText

// Vertical anti-collision for event labels (keeps stacked READY labels apart)
f_evt_y(_x, _yBase, _dir, _sep, _xWindow, _bars, _ys) =>
    float _y = _yBase
    bool _clash = true
    int _guard = 0
    while _clash and _guard < 14
        _clash := false
        if array.size(_bars) > 0
            for _i = 0 to array.size(_bars) - 1
                if math.abs(_x - array.get(_bars, _i)) <= _xWindow and math.abs(_y - array.get(_ys, _i)) < _sep
                    _y := _y + _dir * _sep
                    _clash := true
        _guard += 1
    array.push(_bars, _x)
    array.push(_ys, _y)
    if array.size(_bars) > 12
        array.shift(_bars)
        array.shift(_ys)
    _y

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
G_ENGINE = "Gap Engine"
G_SCORE  = "Reclaim Engine"
G_VISUAL = "Visuals"
G_PANEL  = "Panel"
G_ALERTS = "Alerts"

gapMode = input.string("Adaptive Reclaim Gaps", "Gap Mode",
     options = ["Adaptive Reclaim Gaps", "Classic Open Gap", "Open + Wick Gap", "Open + Body Separation"],
     group = G_ENGINE,
     tooltip = "Adaptive mode allows classic open gaps and controlled separation gaps so the script remains useful on continuous markets. More restrictive modes keep only clearer gap structures.")
atrLength = input.int(14, "ATR Length", minval = 2, maxval = 100, group = G_ENGINE,
     tooltip = "ATR normalizes gap size, pocket depth, invalidation distance, and label offset.")
minGapAtr = input.float(0.22, "Minimum Gap Size (x ATR)", minval = 0.02, maxval = 3.00, step = 0.01, group = G_ENGINE,
     tooltip = "Minimum gap height required before a new reclaim structure is created.")
useDisplacementFallback = input.bool(true, "Use Displacement Gap Fallback", group = G_ENGINE,
     tooltip = "Allows Adaptive mode to create reclaim zones from strong displacement candles when a continuous market has very few true open gaps.")
displacementStrengthAtr = input.float(0.55, "Displacement Strength (x ATR)", minval = 0.10, maxval = 3.00, step = 0.05, group = G_ENGINE,
     tooltip = "Minimum body size required for fallback displacement zones. Higher values reduce noisy gap-like structures.")
maxGapDistanceAtr = input.float(8.0, "Max Active Gap Distance (x ATR)", minval = 1.0, maxval = 50.0, step = 0.5, group = G_ENGINE,
     tooltip = "Automatically clears old active or resolved gaps when their reclaim edge becomes too far from current price.")
gapCooldownBars = input.int(18, "Gap Cooldown Bars", minval = 0, maxval = 160, group = G_ENGINE,
     tooltip = "Minimum bars between newly registered gap structures. Higher values reduce clusters.")
activeGapWindow = input.int(72, "Active Gap Window", minval = 8, maxval = 300, group = G_ENGINE,
     tooltip = "Maximum bars during which the latest gap remains a live reclaim object before expiring.")

confirmationMode = input.string("Balanced", "Confirmation Mode", options = ["Fast", "Balanced", "Strict"], group = G_SCORE,
     tooltip = "Fast reacts earlier, Balanced requires cleaner reclaim confirmation, and Strict demands stronger score and lower fill risk.")
reclaimPocketAtr = input.float(0.18, "Reclaim Pocket ATR", minval = 0.02, maxval = 2.00, step = 0.01, group = G_SCORE,
     tooltip = "ATR-based pocket depth around the selected gap edge.")
invalidationBufferAtr = input.float(0.10, "Invalidation Buffer ATR", minval = 0.00, maxval = 2.00, step = 0.01, group = G_SCORE,
     tooltip = "ATR-based close-through distance that invalidates a reclaim attempt.")
minReadyScore = input.int(64, "Minimum Ready Score", minval = 1, maxval = 100, group = G_SCORE,
     tooltip = "Minimum reclaim score required before the panel moves into READY state.")
reclaimWindowBars = input.int(30, "Reclaim Window Bars", minval = 3, maxval = 200, group = G_SCORE,
     tooltip = "Maximum number of bars after a gap is created during which a qualified edge reclaim can become active.")
useVolumeScore = input.bool(true, "Use Relative Volume In Score", group = G_SCORE,
     tooltip = "Adds relative volume participation to the reclaim score.")
volumeLength = input.int(20, "Relative Volume Length", minval = 2, maxval = 200, group = G_SCORE,
     tooltip = "Lookback used to compare current volume against recent average participation.")
fillRiskThreshold = input.float(65.0, "Fill Risk Threshold (%)", minval = 5.0, maxval = 100.0, step = 1.0, group = G_SCORE,
     tooltip = "Fill risk above this threshold weakens or invalidates the reclaim context.")
targetOneGap = input.float(0.75, "Target 1 x Gap", minval = 0.10, maxval = 5.00, step = 0.05, group = G_SCORE,
     tooltip = "First projected target distance measured in gap units from the reclaim edge.")
targetTwoGap = input.float(1.25, "Target 2 x Gap", minval = 0.10, maxval = 8.00, step = 0.05, group = G_SCORE,
     tooltip = "Second projected target distance measured in gap units from the reclaim edge.")

showGapZone = input.bool(true, "Show Gap Zone", group = G_VISUAL,
     tooltip = "Shows the active gap zone as the main chart reference.")
showReclaimPocket = input.bool(true, "Show Reclaim Pocket", group = G_VISUAL,
     tooltip = "Shows the focused reclaim pocket around the selected gap edge.")
showContinuationCorridor = input.bool(true, "Show Continuation Corridor", group = G_VISUAL,
     tooltip = "Shows a forward continuation corridor after a qualified reclaim.")
showTargetRails = input.bool(true, "Show Target Rails", group = G_VISUAL,
     tooltip = "Draws projected target rails after a qualified reclaim.")
showCenteredZoneText = input.bool(true, "Show Centered Zone Text", group = G_VISUAL,
     tooltip = "Displays centered text inside the gap, pocket, and continuation structures. Automatically suppressed while Show Right-Side Tags is enabled, so the precise edge and target tags are not duplicated and never overlap; disable right-side tags to use centered zone text instead.")
minTextZoneAtr = input.float(0.45, "Min Zone Text Height (x ATR)", minval = 0.05, maxval = 3.00, step = 0.05, group = G_VISUAL,
     tooltip = "Hides centered zone text automatically when the zone is too narrow, preventing text overlap inside small boxes.")
keepLastResolvedVisual = input.bool(true, "Keep Last Resolved Gap Visual", group = G_VISUAL,
     tooltip = "Keeps the most recent expired or invalidated gap structure on the chart in a muted state so the script does not feel visually empty between new setups.")
projectionBars = input.int(42, "Projection Bars", minval = 8, maxval = 220, group = G_VISUAL,
     tooltip = "How far the active gap, pocket, corridor, and target rails project to the right.")
zoneLabelAnchor = input.float(0.42, "Zone Label Anchor", minval = 0.20, maxval = 0.90, step = 0.05, group = G_VISUAL,
     tooltip = "Controls the horizontal position of centered gap, pocket, and corridor badges inside the projected structure. The pocket and corridor badges are offset further right so the three badges do not overlap each other or the right-side tags.")
showEventLabels = input.bool(true, "Show Event Labels", group = G_VISUAL,
     tooltip = "Shows reclaim-ready and invalidation labels.")
showGapLabels = input.bool(false, "Show Gap Creation Labels", group = G_VISUAL,
     tooltip = "Shows gap creation labels so new structures are easier to spot at first glance.")
showInvalidationLabels = input.bool(false, "Show Invalidation Labels", group = G_VISUAL,
     tooltip = "Shows invalidation and expiration labels. Disabled by default to keep publication screenshots clean.")
showRightTags = input.bool(true, "Show Right-Side Tags", group = G_VISUAL,
     tooltip = "Shows compact tags for the active gap zone, edge, and projected targets.")
rightTagDetailMode = input.string("Compact", "Right Tag Detail Mode", options = ["Compact", "Full"], group = G_VISUAL,
     tooltip = "Compact shows only decision-critical right-side tags. Full also shows gap top and gap bottom tags.")
rightTagOffsetBars = input.int(6, "Right Tag Offset", minval = 2, maxval = 40, group = G_VISUAL,
     tooltip = "Controls how far the right-side tags are placed from the latest candle.")
rightTagMinGapAtr = input.float(0.62, "Right Tag Minimum Gap ATR", minval = 0.00, maxval = 2.00, step = 0.02, group = G_VISUAL,
     tooltip = "Base ATR separation for right-side tags. The final spacing also expands automatically with the selected label font size.")
showBarColors = input.bool(false, "Color Bars By State", group = G_VISUAL,
     tooltip = "Colors bars lightly when a reclaim state is active.")
labelSizeInput = input.string("Normal", "Label Font Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = G_VISUAL,
     tooltip = "Controls the size of chart labels and right-side tags.")
labelOffsetAtr = input.float(0.35, "Label Offset ATR", minval = 0.05, maxval = 3.00, step = 0.05, group = G_VISUAL,
     tooltip = "ATR-based vertical spacing used to keep labels clear of candle bodies.")
maxEventLabels = input.int(5, "Max Event Labels", minval = 2, maxval = 50, group = G_VISUAL,
     tooltip = "Maximum number of event labels retained on the chart.")
minEventLabelScore = input.int(72, "Minimum Event Label Score", minval = 1, maxval = 100, group = G_VISUAL,
     tooltip = "Minimum score required for a historical READY badge. Active gap structures and panel states remain visible regardless of this filter.")
eventLabelCooldownBars = input.int(52, "Event Label Cooldown", minval = 0, maxval = 200, group = G_VISUAL,
     tooltip = "Minimum number of bars between retained historical event labels. Higher values reduce label clustering.")

showPanel = input.bool(true, "Show Panel", group = G_PANEL,
     tooltip = "Displays the AG Pro decision panel. Enabled by default.")
panelPositionInput = input.string("Top Right", "Panel Position",
     options = ["Top Right", "Top Left", "Middle Right", "Middle Left", "Bottom Right", "Bottom Left"],
     group = G_PANEL,
     tooltip = "Controls where the panel appears on the chart.")
panelTheme = input.string("Dark", "Panel Theme", options = ["Dark", "Light"], group = G_PANEL,
     tooltip = "Controls whether the panel uses the AGPro dark theme or a light chart-friendly theme.")
panelFontSizeInput = input.string("Normal", "Panel Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = G_PANEL,
     tooltip = "Controls text size inside the decision panel.")

alertReady = input.bool(true, "Alert: Gap Reclaim Ready", group = G_ALERTS,
     tooltip = "Creates an alert condition when a bullish or bearish gap edge reclaim becomes READY.")
alertInvalidated = input.bool(true, "Alert: Gap Reclaim Invalidated", group = G_ALERTS,
     tooltip = "Creates an alert condition when a reclaim fails back through the edge.")
alertExpired = input.bool(false, "Alert: Gap Reclaim Expired", group = G_ALERTS,
     tooltip = "Creates an alert condition when the reclaim window expires without a qualified edge reclaim.")

// -------------------------------------------------
// Core calculations
// -------------------------------------------------
atrRaw = ta.atr(atrLength)
atr = math.max(nz(atrRaw, ta.tr(true)), syminfo.mintick)
labelSize = f_size(labelSizeInput)
panelSize = f_table_size(panelFontSizeInput)
volAvg = ta.sma(volume, volumeLength)
rvol = volAvg > 0 ? volume / volAvg : 1.0
confirmBonus = confirmationMode == "Fast" ? 4.0 : confirmationMode == "Balanced" ? 0.0 : -6.0
requiredScore = f_clamp(minReadyScore - confirmBonus, 1, 100)

prevBodyHigh = math.max(open[1], close[1])
prevBodyLow = math.min(open[1], close[1])
currBodyHigh = math.max(open, close)
currBodyLow = math.min(open, close)

bullClassic = open > high[1]
bearClassic = open < low[1]
bullWick = low > high[1]
bearWick = high < low[1]
bullBody = currBodyLow > prevBodyHigh
bearBody = currBodyHigh < prevBodyLow
bodySize = math.abs(close - open)
bullDisplacement = useDisplacementFallback and close > high[1] and bodySize >= atr * displacementStrengthAtr
bearDisplacement = useDisplacementFallback and close < low[1] and bodySize >= atr * displacementStrengthAtr

gapTopCandidate = bullClassic ? open : bullWick ? low : bullBody ? currBodyLow : bullDisplacement ? close : bearClassic ? low[1] : bearWick ? high : bearBody ? prevBodyLow : bearDisplacement ? low[1] : na
gapBottomCandidate = bullClassic ? high[1] : bullWick ? high[1] : bullBody ? prevBodyHigh : bullDisplacement ? high[1] : bearClassic ? open : bearWick ? low[1] : bearBody ? currBodyHigh : bearDisplacement ? close : na
gapHeightCandidate = math.abs(gapTopCandidate - gapBottomCandidate)
gapValidSize = not na(gapHeightCandidate) and gapHeightCandidate >= atr * minGapAtr

useAdaptive = gapMode == "Adaptive Reclaim Gaps"
useClassicOnly = gapMode == "Classic Open Gap"
useOpenWick = gapMode == "Open + Wick Gap"
useBody = gapMode == "Open + Body Separation"

bullGapSignal = gapValidSize and (useClassicOnly ? bullClassic : useOpenWick ? (bullClassic or bullWick) : useBody ? (bullClassic or bullWick or bullBody) : (bullClassic or bullWick or bullBody or bullDisplacement))
bearGapSignal = gapValidSize and (useClassicOnly ? bearClassic : useOpenWick ? (bearClassic or bearWick) : useBody ? (bearClassic or bearWick or bearBody) : (bearClassic or bearWick or bearBody or bearDisplacement))

var int activeDir = 0
var float gapTop = na
var float gapBottom = na
var float reclaimEdge = na
var int gapBar = na
var bool reclaimed = false
var bool resolved = false
var string gapState = "Waiting Gap"
var string actionState = "WAIT"
var float lastScore = na
var float lastFillRisk = na

var box gapBox = na
var box pocketBox = na
var box corridorBox = na
var line edgeLine = na
var line targetOneLine = na
var line targetTwoLine = na
var line tagEdgeConnector = na
var line tagT1Connector = na
var line tagT2Connector = na
var label tagTop = na
var label tagBottom = na
var label tagEdge = na
var label tagT1 = na
var label tagT2 = na
var label gapZoneLabel = na
var label pocketZoneLabel = na
var label corridorZoneLabel = na
var label[] eventLabels = array.new_label()
var int lastEventLabelBar = na
var float[] elBars = array.new_float()
var float[] elYs = array.new_float()

barsSinceGap = activeDir != 0 and not na(gapBar) ? bar_index - gapBar : na
newGapAllowed = na(gapBar) or barsSinceGap > gapCooldownBars or activeDir == 0
barMs = time - nz(time[1], time - 60000)
safeBarMs = math.max(barMs, 60000)
activeEdgeDistanceAtr = activeDir != 0 and not na(reclaimEdge) and atr > 0 ? math.abs(close - reclaimEdge) / atr : na
activeGapTooFar = activeDir != 0 and not na(activeEdgeDistanceAtr) and activeEdgeDistanceAtr > maxGapDistanceAtr
resolvedGapTooOld = activeDir != 0 and resolved and not na(barsSinceGap) and barsSinceGap > activeGapWindow
eventLabelAllowed = showEventLabels and (na(lastEventLabelBar) or bar_index - lastEventLabelBar >= eventLabelCooldownBars)

if activeGapTooFar or resolvedGapTooOld
    if not na(gapBox)
        box.delete(gapBox)
        gapBox := na
    if not na(pocketBox)
        box.delete(pocketBox)
        pocketBox := na
    if not na(corridorBox)
        box.delete(corridorBox)
        corridorBox := na
    if not na(edgeLine)
        line.delete(edgeLine)
        edgeLine := na
    if not na(targetOneLine)
        line.delete(targetOneLine)
        targetOneLine := na
    if not na(targetTwoLine)
        line.delete(targetTwoLine)
        targetTwoLine := na
    if not na(tagTop)
        label.delete(tagTop)
        tagTop := na
    if not na(tagBottom)
        label.delete(tagBottom)
        tagBottom := na
    if not na(tagEdge)
        label.delete(tagEdge)
        tagEdge := na
    if not na(tagT1)
        label.delete(tagT1)
        tagT1 := na
    if not na(tagT2)
        label.delete(tagT2)
        tagT2 := na
    if not na(gapZoneLabel)
        label.delete(gapZoneLabel)
        gapZoneLabel := na
    if not na(pocketZoneLabel)
        label.delete(pocketZoneLabel)
        pocketZoneLabel := na
    if not na(corridorZoneLabel)
        label.delete(corridorZoneLabel)
        corridorZoneLabel := na
    activeDir := 0
    gapTop := na
    gapBottom := na
    reclaimEdge := na
    gapBar := na
    reclaimed := false
    resolved := false
    gapState := "Waiting Gap"
    actionState := "WAIT"
    lastScore := na
    lastFillRisk := na

if newGapAllowed and (bullGapSignal or bearGapSignal)
    activeDir := bullGapSignal ? 1 : -1
    gapTop := math.max(gapTopCandidate, gapBottomCandidate)
    gapBottom := math.min(gapTopCandidate, gapBottomCandidate)
    reclaimEdge := activeDir == 1 ? gapTop : gapBottom
    gapBar := bar_index
    reclaimed := false
    resolved := false
    gapState := activeDir == 1 ? "Bull Gap Active" : "Bear Gap Active"
    actionState := "MONITOR"
    lastScore := na
    lastFillRisk := na
    if not na(gapBox)
        box.delete(gapBox)
    if not na(pocketBox)
        box.delete(pocketBox)
    if not na(corridorBox)
        box.delete(corridorBox)
    if not na(edgeLine)
        line.delete(edgeLine)
    if not na(targetOneLine)
        line.delete(targetOneLine)
    if not na(targetTwoLine)
        line.delete(targetTwoLine)
    if not na(tagTop)
        label.delete(tagTop)
        tagTop := na
    if not na(tagBottom)
        label.delete(tagBottom)
        tagBottom := na
    if not na(tagEdge)
        label.delete(tagEdge)
        tagEdge := na
    if not na(tagT1)
        label.delete(tagT1)
        tagT1 := na
    if not na(tagT2)
        label.delete(tagT2)
        tagT2 := na
    if not na(gapZoneLabel)
        label.delete(gapZoneLabel)
        gapZoneLabel := na
    if not na(pocketZoneLabel)
        label.delete(pocketZoneLabel)
        pocketZoneLabel := na
    if not na(corridorZoneLabel)
        label.delete(corridorZoneLabel)
        corridorZoneLabel := na
    if eventLabelAllowed and showGapLabels
        label newGapLabel = label.new(bar_index, activeDir == 1 ? high + atr * labelOffsetAtr : low - atr * labelOffsetAtr,
             activeDir == 1 ? "BULL GAP\nReclaim watch" : "BEAR GAP\nReclaim watch",
             style = activeDir == 1 ? label.style_label_down : label.style_label_up,
             textcolor = f_text_on(activeDir == 1 ? bullColor : bearColor),
             color = color.new(activeDir == 1 ? bullColor : bearColor, 10),
             size = labelSize)
        array.push(eventLabels, newGapLabel)
        lastEventLabelBar := bar_index
        if array.size(eventLabels) > maxEventLabels
            label.delete(array.shift(eventLabels))

gapHeight = activeDir != 0 and not na(gapTop) and not na(gapBottom) ? gapTop - gapBottom : na
pocketDepth = atr * reclaimPocketAtr
invalidBuffer = atr * invalidationBufferAtr
hasActiveGap = activeDir != 0 and not na(gapTop) and not na(gapBottom)
gapLeftTime = hasActiveGap and not na(barsSinceGap) ? time - barsSinceGap * safeBarMs : time
projRightTime = time + projectionBars * safeBarMs
zoneTextOk = showCenteredZoneText and not showRightTags and not na(gapHeight) and atr > 0 and gapHeight >= atr * minTextZoneAtr
pocketTextOk = showCenteredZoneText and not showRightTags and atr > 0 and pocketDepth * 2.0 >= atr * minTextZoneAtr
zoneLabelTime = int(math.round(time + projectionBars * safeBarMs * zoneLabelAnchor))
pocketLabelTime = int(math.round(time + projectionBars * safeBarMs * f_clamp(zoneLabelAnchor + 0.22, 0.20, 0.96)))
corridorLabelTime = int(math.round(time + projectionBars * safeBarMs * f_clamp(zoneLabelAnchor + 0.44, 0.20, 0.96)))

if hasActiveGap and showGapZone
    if na(gapBox)
        gapBox := box.new(gapLeftTime, gapTop, projRightTime, gapBottom,
             xloc = xloc.bar_time,
             bgcolor = color.new(activeDir == 1 ? bullColor : bearColor, 88),
             border_color = color.new(activeDir == 1 ? bullColor : bearColor, 24),
             border_width = 1)
    else
        box.set_lefttop(gapBox, gapLeftTime, gapTop)
        box.set_rightbottom(gapBox, projRightTime, gapBottom)
    if zoneTextOk
        gapText = activeDir == 1 ? "Bull Gap" : "Bear Gap"
        gapY = (gapTop + gapBottom) * 0.50
        if na(gapZoneLabel)
            gapZoneLabel := label.new(zoneLabelTime, gapY, gapText, xloc = xloc.bar_time, style = label.style_label_center, textcolor = f_text_on(activeDir == 1 ? bullColor : bearColor), color = color.new(activeDir == 1 ? bullColor : bearColor, 0), size = labelSize, textalign = text.align_center)
        else
            label.set_x(gapZoneLabel, zoneLabelTime)
            label.set_y(gapZoneLabel, gapY)
            label.set_text(gapZoneLabel, gapText)
            label.set_color(gapZoneLabel, color.new(activeDir == 1 ? bullColor : bearColor, 0))
            label.set_textcolor(gapZoneLabel, f_text_on(activeDir == 1 ? bullColor : bearColor))
            label.set_size(gapZoneLabel, labelSize)
    else if not na(gapZoneLabel)
        label.delete(gapZoneLabel)
        gapZoneLabel := na

if hasActiveGap
    pocketTop = activeDir == 1 ? reclaimEdge + pocketDepth : reclaimEdge + pocketDepth
    pocketBottom = activeDir == 1 ? reclaimEdge - pocketDepth : reclaimEdge - pocketDepth
    if showReclaimPocket
        if na(pocketBox)
            pocketBox := box.new(gapLeftTime, pocketTop, projRightTime, pocketBottom,
                 xloc = xloc.bar_time,
                 bgcolor = color.new(accentColor, 86),
                 border_color = color.new(accentColor, 18),
                 border_width = 1)
        else
            box.set_lefttop(pocketBox, gapLeftTime, pocketTop)
            box.set_rightbottom(pocketBox, projRightTime, pocketBottom)
        if pocketTextOk
            pocketY = (pocketTop + pocketBottom) * 0.50
            if na(pocketZoneLabel)
                pocketZoneLabel := label.new(pocketLabelTime, pocketY, "Reclaim Pocket", xloc = xloc.bar_time, style = label.style_label_center, textcolor = f_text_on(accentColor), color = color.new(accentColor, 0), size = labelSize, textalign = text.align_center)
            else
                label.set_x(pocketZoneLabel, pocketLabelTime)
                label.set_y(pocketZoneLabel, pocketY)
                label.set_text(pocketZoneLabel, "Reclaim Pocket")
                label.set_color(pocketZoneLabel, color.new(accentColor, 0))
                label.set_textcolor(pocketZoneLabel, f_text_on(accentColor))
                label.set_size(pocketZoneLabel, labelSize)
        else if not na(pocketZoneLabel)
            label.delete(pocketZoneLabel)
            pocketZoneLabel := na
    if na(edgeLine)
        edgeLine := line.new(gapLeftTime, reclaimEdge, projRightTime, reclaimEdge,
             xloc = xloc.bar_time,
             color = color.new(neutralColor, 8),
             width = 1,
             style = line.style_dotted)
    else
        line.set_xy1(edgeLine, gapLeftTime, reclaimEdge)
        line.set_xy2(edgeLine, projRightTime, reclaimEdge)

enteredZone = hasActiveGap and (high >= gapBottom and low <= gapTop)
reclaimClose = hasActiveGap and activeDir == 1 ? close >= reclaimEdge :
     hasActiveGap and activeDir == -1 ? close <= reclaimEdge : false
invalidated = hasActiveGap and activeDir == 1 ? close < reclaimEdge - invalidBuffer :
     hasActiveGap and activeDir == -1 ? close > reclaimEdge + invalidBuffer : false
expired = hasActiveGap and not resolved and not na(barsSinceGap) and barsSinceGap > activeGapWindow

fillPct = hasActiveGap and activeDir == 1 and gapHeight > 0 ? f_clamp((gapTop - low) / gapHeight * 100.0, 0.0, 100.0) :
     hasActiveGap and activeDir == -1 and gapHeight > 0 ? f_clamp((high - gapBottom) / gapHeight * 100.0, 0.0, 100.0) : na

timeScore = hasActiveGap and not na(barsSinceGap) ? f_clamp(18.0 * (1.0 - barsSinceGap / math.max(reclaimWindowBars, 1)), 0.0, 18.0) : 0.0
zoneScore = enteredZone ? 16.0 : 0.0
closeScore = reclaimClose ? 26.0 : enteredZone ? 10.0 : 0.0
rvolScore = useVolumeScore ? f_clamp(rvol / 1.6, 0.0, 1.0) * 14.0 : 10.0
sizeScore = not na(gapHeight) and atr > 0 ? f_clamp(gapHeight / (atr * 0.75), 0.0, 1.0) * 12.0 : 0.0
targetOne = hasActiveGap and activeDir == 1 ? reclaimEdge + gapHeight * targetOneGap :
     hasActiveGap and activeDir == -1 ? reclaimEdge - gapHeight * targetOneGap : na
targetTwo = hasActiveGap and activeDir == 1 ? reclaimEdge + gapHeight * targetTwoGap :
     hasActiveGap and activeDir == -1 ? reclaimEdge - gapHeight * targetTwoGap : na
roomAtr = hasActiveGap and activeDir == 1 and not na(targetOne) ? (targetOne - close) / atr :
     hasActiveGap and activeDir == -1 and not na(targetOne) ? (close - targetOne) / atr : 0.0
roomScore = f_clamp(roomAtr / 1.2, 0.0, 1.0) * 14.0
candidateScore = f_clamp(timeScore + zoneScore + closeScore + rvolScore + sizeScore + roomScore, 0.0, 100.0)
candidateFillRisk = na(fillPct) ? na : f_clamp(fillPct, 0.0, 100.0)

readyEvent = hasActiveGap and not resolved and not reclaimed and enteredZone and reclaimClose and candidateScore >= requiredScore and candidateFillRisk < fillRiskThreshold
invalidatedEvent = hasActiveGap and not resolved and invalidated
expiredEvent = hasActiveGap and not resolved and expired
exhaustedReadyEvent = hasActiveGap and resolved and reclaimed and not na(candidateFillRisk) and candidateFillRisk >= fillRiskThreshold

if hasActiveGap and (enteredZone or invalidated)
    lastScore := candidateScore
    lastFillRisk := candidateFillRisk

if hasActiveGap and not resolved and enteredZone and not readyEvent and not invalidatedEvent
    gapState := activeDir == 1 ? "Testing Bull Edge" : "Testing Bear Edge"
    actionState := "MONITOR"

if readyEvent
    reclaimed := true
    resolved := true
    gapState := activeDir == 1 ? "Bull Edge Reclaimed" : "Bear Edge Reclaimed"
    actionState := "READY"
    lastScore := candidateScore
    lastFillRisk := candidateFillRisk
    if eventLabelAllowed and candidateScore >= minEventLabelScore
        float eventFontMult = labelSizeInput == "Huge" ? 1.45 : labelSizeInput == "Large" ? 1.25 : labelSizeInput == "Normal" ? 1.0 : labelSizeInput == "Small" ? 0.86 : 0.74
        float readyBaseY = activeDir == 1 ? low - atr * labelOffsetAtr * eventFontMult : high + atr * labelOffsetAtr * eventFontMult
        float readySep = atr * 1.90 * eventFontMult
        int readyXWindow = math.max(eventLabelCooldownBars, 36)
        float readyY = f_evt_y(bar_index, readyBaseY, activeDir == 1 ? -1.0 : 1.0, readySep, readyXWindow, elBars, elYs)
        label readyLabel = label.new(bar_index, readyY,
             "READY RECLAIM | " + str.tostring(math.round(candidateScore)),
             style = activeDir == 1 ? label.style_label_up : label.style_label_down,
             textcolor = f_text_on(activeDir == 1 ? bullColor : bearColor),
             color = color.new(activeDir == 1 ? bullColor : bearColor, 0),
             size = labelSize)
        array.push(eventLabels, readyLabel)
        lastEventLabelBar := bar_index
        if array.size(eventLabels) > maxEventLabels
            label.delete(array.shift(eventLabels))
    if showTargetRails and not na(targetOne) and not na(targetTwo)
        if not na(targetOneLine)
            line.delete(targetOneLine)
        if not na(targetTwoLine)
            line.delete(targetTwoLine)
        targetOneLine := line.new(time, targetOne, projRightTime, targetOne,
             xloc = xloc.bar_time,
             color = color.new(neutralColor, 12),
             width = 1,
             style = line.style_dashed)
        targetTwoLine := line.new(time, targetTwo, projRightTime, targetTwo,
             xloc = xloc.bar_time,
             color = color.new(accentColor, 12),
             width = 1,
             style = line.style_dashed)
    if showContinuationCorridor
        corridorTop = activeDir == 1 ? targetOne : reclaimEdge
        corridorBottom = activeDir == 1 ? reclaimEdge : targetOne
        corridorHigh = math.max(corridorTop, corridorBottom)
        corridorLow = math.min(corridorTop, corridorBottom)
        if na(corridorBox)
            corridorBox := box.new(time, corridorHigh, projRightTime, corridorLow,
                 xloc = xloc.bar_time,
                 bgcolor = color.new(activeDir == 1 ? bullColor : bearColor, 90),
                 border_color = color.new(activeDir == 1 ? bullColor : bearColor, 26),
                 border_width = 1)
        else
            box.set_lefttop(corridorBox, time, corridorHigh)
            box.set_rightbottom(corridorBox, projRightTime, corridorLow)
        corridorTextOk = showCenteredZoneText and not showRightTags and atr > 0 and (corridorHigh - corridorLow) >= atr * minTextZoneAtr
        if corridorTextOk
            corridorY = (corridorHigh + corridorLow) * 0.50
            if na(corridorZoneLabel)
                corridorZoneLabel := label.new(corridorLabelTime, corridorY, "Continuation", xloc = xloc.bar_time, style = label.style_label_center, textcolor = f_text_on(activeDir == 1 ? bullColor : bearColor), color = color.new(activeDir == 1 ? bullColor : bearColor, 0), size = labelSize, textalign = text.align_center)
            else
                label.set_x(corridorZoneLabel, corridorLabelTime)
                label.set_y(corridorZoneLabel, corridorY)
                label.set_text(corridorZoneLabel, "Continuation")
                label.set_color(corridorZoneLabel, color.new(activeDir == 1 ? bullColor : bearColor, 0))
                label.set_textcolor(corridorZoneLabel, f_text_on(activeDir == 1 ? bullColor : bearColor))
                label.set_size(corridorZoneLabel, labelSize)
        else if not na(corridorZoneLabel)
            label.delete(corridorZoneLabel)
            corridorZoneLabel := na

if exhaustedReadyEvent
    gapState := "Reclaim Exhausted"
    actionState := "WAIT"
    lastScore := na
    lastFillRisk := na
    if keepLastResolvedVisual
        archiveRightTime = time + math.max(math.floor(projectionBars * 0.45), 8) * safeBarMs
        if not na(gapBox)
            box.set_right(gapBox, archiveRightTime)
            box.set_bgcolor(gapBox, color.new(panelBorder, 92))
            box.set_border_color(gapBox, color.new(panelBorder, 35))
        if not na(pocketBox)
            box.set_right(pocketBox, archiveRightTime)
            box.set_bgcolor(pocketBox, color.new(accentColor, 92))
            box.set_border_color(pocketBox, color.new(panelBorder, 35))
    if not na(corridorBox)
        box.delete(corridorBox)
        corridorBox := na
    if not na(corridorZoneLabel)
        label.delete(corridorZoneLabel)
        corridorZoneLabel := na
    if not na(edgeLine)
        line.delete(edgeLine)
        edgeLine := na
    if not na(targetOneLine)
        line.delete(targetOneLine)
        targetOneLine := na
    if not na(targetTwoLine)
        line.delete(targetTwoLine)
        targetTwoLine := na
    if not na(tagTop)
        label.delete(tagTop)
        tagTop := na
    if not na(tagBottom)
        label.delete(tagBottom)
        tagBottom := na
    if not na(tagEdge)
        label.delete(tagEdge)
        tagEdge := na
    if not na(tagT1)
        label.delete(tagT1)
        tagT1 := na
    if not na(tagT2)
        label.delete(tagT2)
        tagT2 := na
    activeDir := 0
    gapTop := na
    gapBottom := na
    reclaimEdge := na
    gapBar := na
    reclaimed := false
    resolved := false

if invalidatedEvent
    resolved := true
    gapState := "Reclaim Invalidated"
    actionState := "INVALIDATED"
    lastScore := candidateScore
    lastFillRisk := candidateFillRisk
    if eventLabelAllowed and showInvalidationLabels
        label invalidLabel = label.new(bar_index, activeDir == 1 ? low - atr * labelOffsetAtr : high + atr * labelOffsetAtr,
             "INVALIDATED\nLost gap edge",
             style = activeDir == 1 ? label.style_label_up : label.style_label_down,
             textcolor = f_text_on(bearColor),
             color = color.new(bearColor, 0),
             size = labelSize)
        array.push(eventLabels, invalidLabel)
        lastEventLabelBar := bar_index
        if array.size(eventLabels) > maxEventLabels
            label.delete(array.shift(eventLabels))
    if keepLastResolvedVisual
        archiveRightTime = time + math.max(math.floor(projectionBars * 0.65), 8) * safeBarMs
        if not na(gapBox)
            box.set_right(gapBox, archiveRightTime)
            box.set_bgcolor(gapBox, color.new(bearColor, 91))
            box.set_border_color(gapBox, color.new(bearColor, 42))
        if not na(pocketBox)
            box.set_right(pocketBox, archiveRightTime)
            box.set_bgcolor(pocketBox, color.new(neutralColor, 88))
            box.set_border_color(pocketBox, color.new(neutralColor, 35))
    else
        if not na(gapBox)
            box.delete(gapBox)
            gapBox := na
        if not na(pocketBox)
            box.delete(pocketBox)
            pocketBox := na
    if not na(corridorBox)
        box.delete(corridorBox)
        corridorBox := na
    if not na(corridorZoneLabel)
        label.delete(corridorZoneLabel)
        corridorZoneLabel := na
    if not na(edgeLine)
        line.delete(edgeLine)
        edgeLine := na
    if not na(targetOneLine)
        line.delete(targetOneLine)
        targetOneLine := na
    if not na(targetTwoLine)
        line.delete(targetTwoLine)
        targetTwoLine := na
    if not na(tagTop)
        label.delete(tagTop)
        tagTop := na
    if not na(tagBottom)
        label.delete(tagBottom)
        tagBottom := na
    if not na(tagEdge)
        label.delete(tagEdge)
        tagEdge := na
    if not na(tagT1)
        label.delete(tagT1)
        tagT1 := na
    if not na(tagT2)
        label.delete(tagT2)
        tagT2 := na
    if not keepLastResolvedVisual
        gapBox := na
        pocketBox := na
    activeDir := 0
    gapTop := na
    gapBottom := na
    reclaimEdge := na
    gapBar := na

if expiredEvent
    resolved := true
    gapState := "Gap Reclaim Expired"
    actionState := "EXPIRED"
    if eventLabelAllowed and showInvalidationLabels
        label expiredLabel = label.new(bar_index, close,
             "EXPIRED\nNo clean reclaim",
             style = label.style_label_left,
             textcolor = f_text_on(panelBorder),
             color = color.new(panelBorder, 0),
             size = labelSize)
        array.push(eventLabels, expiredLabel)
        lastEventLabelBar := bar_index
        if array.size(eventLabels) > maxEventLabels
            label.delete(array.shift(eventLabels))
    if keepLastResolvedVisual
        archiveRightTime = time + math.max(math.floor(projectionBars * 0.65), 8) * safeBarMs
        if not na(gapBox)
            box.set_right(gapBox, archiveRightTime)
            box.set_bgcolor(gapBox, color.new(activeDir == 1 ? bullColor : bearColor, 93))
            box.set_border_color(gapBox, color.new(panelBorder, 30))
        if not na(pocketBox)
            box.set_right(pocketBox, archiveRightTime)
            box.set_bgcolor(pocketBox, color.new(accentColor, 91))
            box.set_border_color(pocketBox, color.new(panelBorder, 24))
    else
        if not na(gapBox)
            box.delete(gapBox)
            gapBox := na
        if not na(pocketBox)
            box.delete(pocketBox)
            pocketBox := na
    if not na(corridorBox)
        box.delete(corridorBox)
        corridorBox := na
    if not na(corridorZoneLabel)
        label.delete(corridorZoneLabel)
        corridorZoneLabel := na
    if not na(edgeLine)
        line.delete(edgeLine)
        edgeLine := na
    if not na(targetOneLine)
        line.delete(targetOneLine)
        targetOneLine := na
    if not na(targetTwoLine)
        line.delete(targetTwoLine)
        targetTwoLine := na
    if not na(tagTop)
        label.delete(tagTop)
        tagTop := na
    if not na(tagBottom)
        label.delete(tagBottom)
        tagBottom := na
    if not na(tagEdge)
        label.delete(tagEdge)
        tagEdge := na
    if not na(tagT1)
        label.delete(tagT1)
        tagT1 := na
    if not na(tagT2)
        label.delete(tagT2)
        tagT2 := na
    if not keepLastResolvedVisual
        gapBox := na
        pocketBox := na
    activeDir := 0
    gapTop := na
    gapBottom := na
    reclaimEdge := na
    gapBar := na

if not hasActiveGap
    gapState := "Waiting Gap"
    actionState := "WAIT"

currentHasActiveGap = activeDir != 0 and not na(gapTop) and not na(gapBottom) and not na(reclaimEdge)

// -------------------------------------------------
// Reclaim follow-through proof (stop-aware)
// -------------------------------------------------
// After a READY reclaim, was Target 1 reached before price closed back
// through the reclaim edge (the same invalidation rail the engine uses)?
// Win = T1 reached first, Loss = edge lost first, neither in window = uncounted.
var int   pfTotal   = 0
var int   pfWins    = 0
var bool  pfOpen    = false
var int   pfDir     = 0
var float pfTarget  = na
var float pfStop    = na
var int   pfOpenBar = na
int proofWindowBars = math.max(reclaimWindowBars, 24)

if barstate.isconfirmed
    if pfOpen
        bool pfWin  = pfDir == 1 ? high >= pfTarget : low <= pfTarget
        bool pfLoss = pfDir == 1 ? close < pfStop : close > pfStop
        if pfLoss
            pfTotal += 1
            pfOpen  := false
        else if pfWin
            pfTotal += 1
            pfWins  += 1
            pfOpen  := false
        else if not na(pfOpenBar) and bar_index - pfOpenBar > proofWindowBars
            pfOpen := false
    if readyEvent and not pfOpen and not na(targetOne)
        pfOpen    := true
        pfDir     := activeDir
        pfTarget  := targetOne
        pfStop    := activeDir == 1 ? reclaimEdge - invalidBuffer : reclaimEdge + invalidBuffer
        pfOpenBar := bar_index

float pfRate = pfTotal > 0 ? pfWins / pfTotal * 100.0 : na


// -------------------------------------------------
// Right-side tags
// -------------------------------------------------
if barstate.islast
    if not na(tagEdgeConnector)
        line.delete(tagEdgeConnector)
        tagEdgeConnector := na
    if not na(tagT1Connector)
        line.delete(tagT1Connector)
        tagT1Connector := na
    if not na(tagT2Connector)
        line.delete(tagT2Connector)
        tagT2Connector := na

if barstate.islast and currentHasActiveGap and showRightTags
    tagX = bar_index + rightTagOffsetBars + 8
    tagLeadX = bar_index + 1
    tagJoinX = tagX - 1
    tagFontMult = labelSizeInput == "Huge" ? 1.55 : labelSizeInput == "Large" ? 1.32 : labelSizeInput == "Normal" ? 1.10 : labelSizeInput == "Small" ? 0.92 : 0.78
    tagGap = math.max(atr * rightTagMinGapAtr * tagFontMult, syminfo.mintick * 20.0)
    showFullRightTags = rightTagDetailMode == "Full"
    zoneMidForTags = (gapTop + gapBottom) * 0.50
    tagTopY = gapTop + tagGap * 0.35
    tagBottomY = gapBottom - tagGap * 0.35
    tagEdgeY = reclaimEdge
    if showFullRightTags
        tagEdgeY := activeDir == 1 ? zoneMidForTags + tagGap * 0.55 : zoneMidForTags - tagGap * 0.55
    tagT1Y = targetOne
    tagT2Y = targetTwo
    if showTargetRails and actionState == "READY" and not na(targetOne) and not na(targetTwo)
        if showFullRightTags and activeDir == 1
            tagT1Y := math.max(targetOne, tagTopY + tagGap)
            tagT2Y := math.max(targetTwo, tagT1Y + tagGap)
        else if showFullRightTags and activeDir == -1
            tagT1Y := math.min(targetOne, tagBottomY - tagGap)
            tagT2Y := math.min(targetTwo, tagT1Y - tagGap)
        else if activeDir == 1
            tagT1Y := math.max(targetOne, tagEdgeY + tagGap)
            tagT2Y := math.max(targetTwo, tagT1Y + tagGap)
        else
            tagT1Y := math.min(targetOne, tagEdgeY - tagGap)
            tagT2Y := math.min(targetTwo, tagT1Y - tagGap)
    if not na(tagTop)
        label.delete(tagTop)
    if not na(tagBottom)
        label.delete(tagBottom)
    if not na(tagEdge)
        label.delete(tagEdge)
    if not na(tagT1)
        label.delete(tagT1)
    if not na(tagT2)
        label.delete(tagT2)
    if showFullRightTags
        tagTop := label.new(tagX, tagTopY,
             "Gap Top  " + str.tostring(gapTop, format.mintick),
             style = label.style_label_left,
             textcolor = f_text_on(bullColor),
             color = color.new(bullColor, 18),
             size = labelSize)
        tagBottom := label.new(tagX + 3, tagBottomY,
             "Gap Bottom  " + str.tostring(gapBottom, format.mintick),
             style = label.style_label_left,
             textcolor = f_text_on(bearColor),
             color = color.new(bearColor, 18),
             size = labelSize)
    tagEdgeX = tagX
    tagT1X = tagX
    tagT2X = tagX
    tagEdge := label.new(tagEdgeX, tagEdgeY,
         (activeDir == 1 ? "Reclaim Edge  " : "Reclaim Edge  ") + str.tostring(reclaimEdge, format.mintick),
         style = label.style_label_left,
         textcolor = f_text_on(neutralColor),
         color = color.new(neutralColor, 18),
         size = labelSize)
    if showTargetRails and actionState == "READY" and not na(targetOne) and not na(targetTwo)
        tagT1 := label.new(tagT1X, tagT1Y,
             "T1  " + str.tostring(targetOne, format.mintick),
             style = label.style_label_left,
             textcolor = f_text_on(neutralColor),
             color = color.new(neutralColor, 12),
             size = labelSize)
        tagT2 := label.new(tagT2X, tagT2Y,
             "T2  " + str.tostring(targetTwo, format.mintick),
             style = label.style_label_left,
             textcolor = f_text_on(accentColor),
             color = color.new(accentColor, 12),
             size = labelSize)
    tagEdgeConnector := line.new(tagLeadX, reclaimEdge, tagJoinX, tagEdgeY,
         xloc = xloc.bar_index,
         color = color.new(neutralColor, 8),
         width = 2)
    if showTargetRails and actionState == "READY" and not na(targetOne) and not na(targetTwo)
        tagT1Connector := line.new(tagLeadX, targetOne, tagJoinX, tagT1Y,
             xloc = xloc.bar_index,
             color = color.new(neutralColor, 8),
             width = 2)
        tagT2Connector := line.new(tagLeadX, targetTwo, tagJoinX, tagT2Y,
             xloc = xloc.bar_index,
             color = color.new(accentColor, 8),
             width = 2)

// -------------------------------------------------
// Panel
// -------------------------------------------------
panelBgFinal = panelTheme == "Dark" ? panelBg : color.rgb(248, 250, 252)
panelLeftFinal = panelTheme == "Dark" ? color.new(panelBorder, 0) : color.rgb(226, 232, 240)
panelTextFinal = panelTheme == "Dark" ? panelValueCol : color.rgb(15, 23, 42)
panelLabelFinal = panelTheme == "Dark" ? panelLabelCol : color.rgb(71, 85, 105)
edgeText = currentHasActiveGap ? str.tostring(reclaimEdge, format.mintick) : "n/a"
scoreText = currentHasActiveGap ? f_score_text(lastScore) : "n/a"
fillRiskText = currentHasActiveGap and not na(lastFillRisk) ? str.tostring(math.round(lastFillRisk)) + "/100" : "n/a"
continuationText = currentHasActiveGap and activeDir == 1 ? "Bullish" : currentHasActiveGap and activeDir == -1 ? "Bearish" : "Neutral"
reachText = pfTotal >= 6 ? str.tostring(math.round(pfRate)) + "%  (" + str.tostring(pfTotal) + ")" : "Building (" + str.tostring(pfTotal) + ")"
reachCol = panelTheme == "Dark" and pfTotal >= 6 ? (pfRate >= 55.0 ? bullColor : pfRate >= 45.0 ? neutralColor : bearColor) : panelTextFinal

var table panel = table.new(position.top_right, 2, 7, border_width = 1)

if showPanel and barstate.islast
    table.set_position(panel, f_panel_position(panelPositionInput))
    table.set_border_color(panel, panelBorder)
    table.set_frame_color(panel, panelBorder)
    table.clear(panel, 0, 0, 1, 6)
    table.merge_cells(panel, 0, 0, 1, 0)
    table.cell(panel, 0, 0, "AG Pro Gap Reclaim Readiness",
         text_color = headerText,
         bgcolor = headerBg,
         text_size = panelSize)
    table.cell(panel, 0, 1, "Gap Edge",
         text_color = panelLabelFinal,
         bgcolor = panelLeftFinal,
         text_size = panelSize)
    table.cell(panel, 1, 1, edgeText,
         text_color = panelTextFinal,
         bgcolor = panelBgFinal,
         text_size = panelSize)
    table.cell(panel, 0, 2, "Reclaim Score",
         text_color = panelLabelFinal,
         bgcolor = panelLeftFinal,
         text_size = panelSize)
    table.cell(panel, 1, 2, scoreText,
         text_color = panelTextFinal,
         bgcolor = panelBgFinal,
         text_size = panelSize)
    table.cell(panel, 0, 3, "Fill Risk",
         text_color = panelLabelFinal,
         bgcolor = panelLeftFinal,
         text_size = panelSize)
    table.cell(panel, 1, 3, fillRiskText,
         text_color = panelTextFinal,
         bgcolor = panelBgFinal,
         text_size = panelSize)
    table.cell(panel, 0, 4, "Reach Rate",
         text_color = panelLabelFinal,
         bgcolor = panelLeftFinal,
         text_size = panelSize)
    table.cell(panel, 1, 4, reachText,
         text_color = reachCol,
         bgcolor = panelBgFinal,
         text_size = panelSize)
    table.cell(panel, 0, 5, "Continuation",
         text_color = panelLabelFinal,
         bgcolor = panelLeftFinal,
         text_size = panelSize)
    table.cell(panel, 1, 5, continuationText,
         text_color = f_text_on(activeDir == 1 ? bullColor : activeDir == -1 ? bearColor : neutralColor),
         bgcolor = activeDir == 1 ? color.new(bullColor, 12) : activeDir == -1 ? color.new(bearColor, 12) : color.new(neutralColor, 18),
         text_size = panelSize)
    table.cell(panel, 0, 6, "Action",
         text_color = panelLabelFinal,
         bgcolor = panelLeftFinal,
         text_size = panelSize)
    table.cell(panel, 1, 6, actionState,
         text_color = f_text_on(f_action_color(actionState)),
         bgcolor = f_action_color(actionState),
         text_size = panelSize)

if not showPanel and barstate.islast
    table.clear(panel, 0, 0, 1, 6)

// -------------------------------------------------
// Bar color and alerts
// -------------------------------------------------
barStateColor = actionState == "READY" ? color.new(activeDir == 1 ? bullColor : bearColor, 76) :
     actionState == "MONITOR" ? color.new(accentColor, 84) :
     actionState == "INVALIDATED" ? color.new(bearColor, 80) :
     actionState == "EXPIRED" ? color.new(panelBorder, 84) : na
barcolor(showBarColors ? barStateColor : na)

alertcondition(alertReady and readyEvent and activeDir == 1, "Bullish Gap Reclaim Ready",
     "AG Pro GR | BULL GAP RECLAIM READY | {{ticker}} | {{interval}}")
alertcondition(alertReady and readyEvent and activeDir == -1, "Bearish Gap Reclaim Ready",
     "AG Pro GR | BEAR GAP RECLAIM READY | {{ticker}} | {{interval}}")
alertcondition(alertInvalidated and invalidatedEvent, "Gap Reclaim Invalidated",
     "AG Pro GR | GAP RECLAIM INVALIDATED | {{ticker}} | {{interval}}")
alertcondition(alertExpired and expiredEvent, "Gap Reclaim Expired",
     "AG Pro GR | GAP RECLAIM EXPIRED | {{ticker}} | {{interval}}")
````
