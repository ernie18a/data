# Rejection Block Quality [AGPro Series]

- url: https://www.tradingview.com/script/cMl0yHxI-Rejection-Block-Quality-AGPro-Series/
- type: indicator
- pine_id: PUB;ac044ff1459c44d3a80c381be885f6d6
- version: 5.0

## Description

Rejection Block Quality [AGPro Series]

🔹 OVERVIEW

Rejection Block Quality is an ICT-inspired detector that identifies long-wick rejection candles at swept swing pivots and grades each block by objective quality criteria. Unlike Order Block logic — which anchors to the last opposite-direction body before displacement — a Rejection Block (RB) is born from a wick that pierces a prior swing liquidity pool and closes back inside it, with the body confirming displacement on the follow-through bar. The rectangle is drawn from the wick base to the candle body, capturing the exact zone where smart money absorbed the sweep.

🎯 UNIQUE EDGE

Three design choices separate this tool from generic wick or order block indicators:

• Swing-pivot sweep requirement — a rejection is only counted when price sweeps a confirmed swing high or low before the reversal close. Stand-alone wick patterns without liquidity context are filtered out.

• Displacement confirmation window — the candle following the rejection must travel at least 0.6× ATR in the reversal direction, within a 1–5 bar lookahead. No displacement, no block.

• Quality tiering (A / B / C) from three orthogonal factors — wick-to-body ratio, displacement magnitude, and untested freshness. An exceptional wick ratio (≥5× body) promotes a block to A tier regardless of other scores, preserving rare high-conviction rejections.

🛠️ METHODOLOGY

Detection pipeline on every bar:

1. Confirm a pivot sweep using a user-configurable lookback (default 5 bars each side).
2. Check the wick-to-body ratio against a minimum threshold (default 1.8×), with the dominant wick on the sweep side.
3. Queue the candle as a pending block and wait for displacement confirmation.
4. Measure displacement as price travel from the body reference over 1 to 5 bars, normalized by ATR.
5. On confirmation, draw the RB zone from the wick base to the body, record the tier, and begin lifecycle tracking.

Zone lifecycle tracks four events — test (price enters the zone), hold (price exits without a body close through the far edge), break (body close through the far edge), and near miss (price approaches within a configurable ATR band without entering). All events are edge-detected to prevent inflated counts when price lingers near a zone.

📊 SIGNALS & ALERTS

• New block formation label — A / B / C tier plus wick ratio, placed with anti-collision offset.
• Test markers (T) — one per zone entry event, with cooldown to prevent visual clutter.
• Break markers (B) — placed when a zone is invalidated by a body close.
• Wick border highlight — thick colored line on the originating rejection candle.
• Alerts — configurable minimum tier (A, B, or C) fires once per bar close for each qualifying new block.

⚙️ KEY INPUTS

• Detection — Pivot Length, Min Wick-to-Body Ratio, ATR Length, Min Displacement (× ATR), Displacement Confirm Window.
• Zone Management — Max Active Zones per Side, Zone Right Extension, Near-Miss Distance, Near-Miss Cooldown, Break Requires Full Body Close.
• Visuals — Show Zones, Show Tier Labels, Highlight Rejection Wick Border, Show Test / Hold / Break Markers, Zone Fill Opacity, Label Font Size.
• Panel — Show Panel, Panel Location, Panel Font Size, Panel Theme (Dark / Light).
• Alerts — Minimum Tier for Alerts.

🧭 HOW TO USE

Start on a higher timeframe (4H or 1D) to identify macro RB zones, then drill down to execution timeframes for entries. Treat A-tier blocks as the highest-conviction zones, B-tier as situational, and C-tier as context-only. Combine with trend filters, higher-timeframe structure, and risk management — a Rejection Block is a zone of interest, not a standalone buy or sell signal. Use the panel statistics to evaluate how the selected symbol and timeframe have historically respected these zones before committing to them in live decision-making.

⚠️ LIMITATIONS & TRANSPARENCY

This indicator is a structural detector, not a trading strategy. It does not forecast price direction, generate entry or exit orders, or calculate position sizing. The Success Rate statistic reflects how often past tests on detected zones held versus failed within the visible history — it is a descriptive metric, not a performance projection. Zone detection is historical and reactive: a block only appears after the displacement bar closes, so interpretation on live-forming bars is tentative. Performance varies by symbol, timeframe, and market regime.

⚠️ RISK DISCLOSURE

Trading involves substantial risk of loss. Past behavior of any pattern does not guarantee future outcomes. Use this tool as part of a complete analytical framework that includes your own risk management, position sizing, and broader market context. Nothing in this indicator or description constitutes financial advice.

## Source Code

````pine
// ─────────────────────────────────────────────────
// Rejection Block Quality [AGPro Series]
// 
// Author  : AGProLabs | AGPro Series
// Version : 2.6
// 
// Rejection Block Quality maps wick-led rejection blocks after swept swing pivots and
// evaluates their confirmation, testing, reclaim, survival, invalidation, and distance context.
// It combines price-action rejection zones, volatility-normalized quality scoring, lifecycle
// tracking, and empirical reaction proof without presenting predictive trade signals.
// ─────────────────────────────────────────────────

//@version=6
indicator("Rejection Block Quality [AGPro Series]",
     shorttitle = "AG Pro RBQ",
     overlay = true,
     max_boxes_count = 80,
     max_labels_count = 220,
     max_lines_count = 120)

// ─────────────────────────────────────────────────
// AGPro Color Palette
// ─────────────────────────────────────────────────
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

// ─────────────────────────────────────────────────
// Inputs
// ─────────────────────────────────────────────────
groupDetection = "Detection"
pivotLen = input.int(5, "Swing Pivot Length", minval = 2, maxval = 20, group = groupDetection,
     tooltip = "Defines the confirmed swing high or swing low used as the liquidity reference for a rejection block.")
minWickRatio = input.float(1.80, "Minimum Wick-to-Body Ratio", minval = 0.80, maxval = 8.00, step = 0.10, group = groupDetection,
     tooltip = "Requires the rejection wick to be meaningfully larger than the candle body before a block candidate is allowed.")
atrLen = input.int(14, "ATR Length", minval = 5, maxval = 100, group = groupDetection,
     tooltip = "Volatility baseline used for displacement confirmation, invalidation distance, and label offsets.")
minDisplacement = input.float(0.60, "Minimum Follow-Through (x ATR)", minval = 0.10, maxval = 3.00, step = 0.05, group = groupDetection,
     tooltip = "Minimum reversal-side travel required after the rejection candle before a block is confirmed.")
confirmWindow = input.int(4, "Confirmation Window", minval = 1, maxval = 10, group = groupDetection,
     tooltip = "Maximum number of bars allowed for follow-through confirmation after the rejection candle.")

groupLifecycle = "Lifecycle"
minScore = input.int(62, "Minimum Ready Score", minval = 0, maxval = 100, group = groupLifecycle,
     tooltip = "Score threshold used by the panel and alerts to separate READY-quality blocks from weaker monitoring context.")
expiryBars = input.int(220, "Block Expiry Bars", minval = 20, maxval = 1000, group = groupLifecycle,
     tooltip = "Number of bars after which an untouched or stale rejection block is treated as expired context.")
cooldownBars = input.int(40, "Label Cooldown Bars", minval = 1, maxval = 150, group = groupLifecycle,
     tooltip = "Minimum spacing between repeated lifecycle labels to keep the chart readable.")
maxContextDistanceAtr = input.float(4.0, "Maximum Active Context Distance (x ATR)", minval = 0.5, maxval = 20.0, step = 0.25, group = groupLifecycle,
     tooltip = "Prevents a structurally valid but distant block from being presented as an immediate READY context in the panel.")
breakNeedsClose = input.bool(true, "Invalidation Requires Close", group = groupLifecycle,
     tooltip = "When enabled, invalidation requires a body close beyond the block edge. When disabled, a wick breach can invalidate the block.")

groupVisuals = "Visuals"
showZones = input.bool(true, "Show Rejection Blocks", group = groupVisuals,
     tooltip = "Shows the active rejection block boxes and centered block labels.")
showLabels = input.bool(true, "Show Lifecycle Labels", group = groupVisuals,
     tooltip = "Shows block creation, hold, monitor, and invalidation labels with controlled density.")
showEdges = input.bool(true, "Show Invalidation Edge", group = groupVisuals,
     tooltip = "Draws the active invalidation edge for each rejection block.")
showClosedBlocks = input.bool(true, "Show Expired Zones", group = groupVisuals,
     tooltip = "Keeps expired but unbroken rejection zones visible. Invalidated (broken) blocks are always hidden for a clean chart.")
showClosedLabels = input.bool(false, "Show Closed-State Labels", group = groupVisuals,
     tooltip = "Shows invalidation labels for closed blocks. Disabled by default for a cleaner publication screenshot.")
showTestEvents = input.bool(false, "Show Test Event Labels", group = groupVisuals,
     tooltip = "Shows separate TEST event badges. Disabled by default because the centered block badge already reports the live testing state.")
minimumEventScore = input.int(70, "Minimum Event Label Score", minval = 0, maxval = 100, group = groupVisuals,
     tooltip = "Filters low-value historical event badges without removing their underlying rejection blocks.")
extendBars = input.int(48, "Zone Right Extension", minval = 10, maxval = 300, group = groupVisuals,
     tooltip = "Controls how far active block boxes extend into the future.")
maxBlocks = input.int(8, "Maximum Visible Zones", minval = 2, maxval = 24, group = groupVisuals,
     tooltip = "Limits the number of active block objects retained on the chart for performance and clarity.")
maxVisibleLabels = input.int(18, "Maximum Visible Labels", minval = 6, maxval = 120, group = groupVisuals,
     tooltip = "Caps lifecycle labels so the chart stays premium and readable.")
zoneOpacity = input.int(86, "Zone Fill Opacity", minval = 65, maxval = 95, group = groupVisuals,
     tooltip = "Higher values make rejection block boxes more transparent.")
labelFontSize = input.string("Normal", "Label Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = groupVisuals,
     tooltip = "Controls all chart label and centered block text sizes.")

groupPanel = "Panel"
showPanel = input.bool(true, "Show Panel", group = groupPanel,
     tooltip = "Shows or hides the AG Pro decision panel. Enabled by default for public-release readability.")
panelLocation = input.string("Top Right", "Panel Location", options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group = groupPanel,
     tooltip = "Selects where the AG Pro panel appears on the chart.")
panelTheme = input.string("Dark", "Panel Theme", options = ["Dark", "Light"], group = groupPanel,
     tooltip = "Switches the panel between the AGPro dark theme and a clean light theme.")
panelFontSize = input.string("Normal", "Panel Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = groupPanel,
     tooltip = "Controls the panel text size.")

groupAlerts = "Alerts"
alertMinScore = input.int(70, "Alert Minimum Score", minval = 0, maxval = 100, group = groupAlerts,
     tooltip = "Minimum score required for new-block READY alerts.")
proofWindowBars = input.int(80, "Proof Window Bars", minval = 10, maxval = 400, group = groupAlerts,
     tooltip = "Maximum bars a reaction-proof window stays open before it is left uncounted in the proof rate.")
proofTargetAtr = input.float(1.0, "Proof Target (x ATR)", minval = 0.20, maxval = 5.00, step = 0.10, group = groupAlerts,
     tooltip = "Symmetric reaction distance, in ATR, measured from the confirmation close. A proof counts as a win if reaction-side follow-through reaches this distance before an equal adverse move occurs.")

// ─────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────
f_clamp(_value, _min, _max) =>
    math.max(_min, math.min(_max, _value))

f_size(_value) =>
    switch _value
        "Tiny" => size.tiny
        "Small" => size.small
        "Large" => size.large
        => size.normal

f_panel_pos(_value) =>
    switch _value
        "Top Left" => position.top_left
        "Bottom Right" => position.bottom_right
        "Bottom Left" => position.bottom_left
        => position.top_right

f_grade(_score) =>
    _score >= 82 ? "A" : _score >= 68 ? "B" : "C"

f_action(_invalid, _expired, _score, _survival, _reclaimState, _relevant) =>
    _invalid ? "INVALIDATED" :
     _expired ? "EXPIRED" :
     _score < minScore ? "BLOCKED" :
     not _relevant ? "STANDBY" :
     _reclaimState == "Testing" ? "MONITOR" :
     _survival >= minScore ? "READY" :
     "WAIT"

f_score_color(_score) =>
    _score >= 72 ? bullColor : _score >= 55 ? neutralColor : bearColor

f_zone_text_color() =>
    brightness = color.r(chart.bg_color) + color.g(chart.bg_color) + color.b(chart.bg_color)
    brightness >= 382.5 ? color.rgb(15, 23, 42) : headerText

f_text_on(_bg) =>
    lum = 0.299 * color.r(_bg) + 0.587 * color.g(_bg) + 0.114 * color.b(_bg)
    lum > 145 ? color.rgb(17, 24, 39) : headerText

labelSize = f_size(labelFontSize)
panelSize = f_size(panelFontSize)
atr = ta.atr(atrLen)
safeAtr = math.max(nz(atr, ta.tr(true)), syminfo.mintick)

// ─────────────────────────────────────────────────
// State Arrays
// ─────────────────────────────────────────────────
var box[] rbBoxes = array.new_box()
var line[] rbEdges = array.new_line()
var int[] rbSides = array.new_int()
var float[] rbTops = array.new_float()
var float[] rbBottoms = array.new_float()
var float[] rbScores = array.new_float()
var int[] rbBars = array.new_int()
var int[] rbTouches = array.new_int()
var int[] rbLastEvent = array.new_int()
var bool[] rbInvalid = array.new_bool()
var bool[] rbInside = array.new_bool()
var bool[] rbReclaimed = array.new_bool()
var label[] rbBadges = array.new_label()
var label[] eventLabels = array.new_label()

f_avoid_overlap(label[] _labels, float _desiredY, bool _placeAbove, float _safe) =>
    float y = _desiredY
    float minGap = _safe * 1.1
    int n = array.size(_labels)
    if n > 0
        bool moved = true
        int guard = 0
        while moved and guard < 16
            moved := false
            for i = 0 to n - 1
                lb = array.get(_labels, i)
                if math.abs(label.get_x(lb) - bar_index) <= 22
                    if math.abs(label.get_y(lb) - y) < minGap
                        y := _placeAbove ? y + minGap : y - minGap
                        moved := true
            guard += 1
    y

f_add_event(_x, _y, _text, _style, _bg) =>
    if showLabels
        bool placeAbove = _style == label.style_label_down
        float adjY = f_avoid_overlap(eventLabels, _y, placeAbove, safeAtr)
        lbl = label.new(_x, adjY, _text, xloc = xloc.bar_index, style = _style, color = _bg, textcolor = f_text_on(_bg), size = labelSize)
        array.push(eventLabels, lbl)
        while array.size(eventLabels) > maxVisibleLabels
            old = array.shift(eventLabels)
            label.delete(old)

f_prune_blocks() =>
    while array.size(rbBoxes) > maxBlocks
        oldBox = array.shift(rbBoxes)
        oldEdge = array.shift(rbEdges)
        box.delete(oldBox)
        line.delete(oldEdge)
        oldBadge = array.shift(rbBadges)
        if not na(oldBadge)
            label.delete(oldBadge)
        array.shift(rbSides)
        array.shift(rbTops)
        array.shift(rbBottoms)
        array.shift(rbScores)
        array.shift(rbBars)
        array.shift(rbTouches)
        array.shift(rbLastEvent)
        array.shift(rbInvalid)
        array.shift(rbInside)
        array.shift(rbReclaimed)

f_add_block(_side, _left, _top, _bottom, _ratio, _dispX, _closeQuality) =>
    zoneHeight = math.max(_top - _bottom, syminfo.mintick)
    wickScore = f_clamp((_ratio / math.max(minWickRatio, 0.10)) * 24.0, 0.0, 30.0)
    closeScore = f_clamp(_closeQuality * 20.0, 0.0, 20.0)
    followScore = f_clamp((_dispX / math.max(minDisplacement, 0.10)) * 20.0, 0.0, 25.0)
    riskFit = f_clamp(15.0 * (1.0 - zoneHeight / (safeAtr * 2.50)), 0.0, 15.0)
    freshScore = 10.0
    baseScore = math.round(f_clamp(wickScore + closeScore + followScore + riskFit + freshScore, 0.0, 100.0))
    sideText = _side == 1 ? "BULL RB" : "BEAR RB"
    grade = f_grade(baseScore)
    fillColor = _side == 1 ? color.new(bullColor, zoneOpacity) : color.new(bearColor, zoneOpacity)
    borderColor = _side == 1 ? color.new(bullColor, 10) : color.new(bearColor, 10)
    edgeLevel = _side == 1 ? _bottom : _top
    edgeColor = _side == 1 ? color.new(bullColor, 0) : color.new(bearColor, 0)
    boxText = sideText + " | FRESH | Q " + str.tostring(baseScore)
    bx = box.new(left = _left, top = _top, right = bar_index + extendBars, bottom = _bottom, xloc = xloc.bar_index,
         bgcolor = showZones ? fillColor : color.new(fillColor, 100), border_color = showZones ? borderColor : color.new(borderColor, 100),
         border_width = 1, text = "", text_color = f_zone_text_color(), text_size = labelSize,
         text_halign = text.align_center, text_valign = text.align_center)
    ln = line.new(x1 = _left, y1 = edgeLevel, x2 = bar_index + extendBars, y2 = edgeLevel, xloc = xloc.bar_index,
         color = showEdges ? edgeColor : color.new(edgeColor, 100), style = line.style_dotted, width = 1)
    zoneBadgeColor = _side == 1 ? bullColor : bearColor
    zoneMid = (_top + _bottom) * 0.5
    zoneRight = bar_index + extendBars
    zoneBadgeX = int(math.round((_left + zoneRight) * 0.5))
    badge = label.new(zoneBadgeX, zoneMid, showZones ? boxText : "", xloc = xloc.bar_index, yloc = yloc.price,
         style = label.style_label_center, color = showZones ? color.new(zoneBadgeColor, 0) : color.new(zoneBadgeColor, 100),
         textcolor = f_text_on(zoneBadgeColor), size = labelSize)
    array.push(rbBoxes, bx)
    array.push(rbEdges, ln)
    array.push(rbBadges, badge)
    array.push(rbSides, _side)
    array.push(rbTops, _top)
    array.push(rbBottoms, _bottom)
    array.push(rbScores, baseScore)
    array.push(rbBars, _left)
    array.push(rbTouches, 0)
    array.push(rbLastEvent, _left)
    array.push(rbInvalid, false)
    array.push(rbInside, false)
    array.push(rbReclaimed, false)
    f_prune_blocks()
    labelY = _side == 1 ? _bottom - safeAtr * 0.45 : _top + safeAtr * 0.45
    labelStyle = _side == 1 ? label.style_label_up : label.style_label_down
    labelBg = _side == 1 ? bullColor : bearColor
    if baseScore >= minimumEventScore
        f_add_event(bar_index, labelY, sideText + " | " + grade + " | Q " + str.tostring(baseScore), labelStyle, labelBg)
    baseScore

// ─────────────────────────────────────────────────
// Swing Sweep Detection
// ─────────────────────────────────────────────────
ph = ta.pivothigh(high, pivotLen, pivotLen)
pl = ta.pivotlow(low, pivotLen, pivotLen)

var float lastSwingHigh = na
var float lastSwingLow = na
var int lastSwingHighBar = na
var int lastSwingLowBar = na

if not na(ph)
    lastSwingHigh := ph
    lastSwingHighBar := bar_index - pivotLen

if not na(pl)
    lastSwingLow := pl
    lastSwingLowBar := bar_index - pivotLen

body = math.max(math.abs(close - open), syminfo.mintick)
barRange = math.max(high - low, syminfo.mintick)
upperWick = high - math.max(open, close)
lowerWick = math.min(open, close) - low
upperRatio = upperWick / body
lowerRatio = lowerWick / body
closeFromLow = (close - low) / barRange
closeFromHigh = (high - close) / barRange

var bool pendingBull = false
var bool pendingBear = false
var int pBullBar = na
var int pBearBar = na
var float pBullTop = na
var float pBullBottom = na
var float pBearTop = na
var float pBearBottom = na
var float pBullRatio = na
var float pBearRatio = na
var float pBullRef = na
var float pBearRef = na
var float pBullCloseQuality = na
var float pBearCloseQuality = na
var int lastBullCandidate = na
var int lastBearCandidate = na

hasHighRef = not na(lastSwingHigh) and not na(lastSwingHighBar) and bar_index > lastSwingHighBar
hasLowRef = not na(lastSwingLow) and not na(lastSwingLowBar) and bar_index > lastSwingLowBar

bearCandidate = hasHighRef and high > lastSwingHigh and close < lastSwingHigh and upperRatio >= minWickRatio and closeFromHigh >= 0.45
bullCandidate = hasLowRef and low < lastSwingLow and close > lastSwingLow and lowerRatio >= minWickRatio and closeFromLow >= 0.45

if bullCandidate and (na(lastBullCandidate) or bar_index - lastBullCandidate >= cooldownBars)
    pendingBull := true
    pBullBar := bar_index
    pBullTop := math.min(open, close)
    pBullBottom := low
    pBullRatio := lowerRatio
    pBullRef := close
    pBullCloseQuality := closeFromLow
    lastBullCandidate := bar_index

if bearCandidate and (na(lastBearCandidate) or bar_index - lastBearCandidate >= cooldownBars)
    pendingBear := true
    pBearBar := bar_index
    pBearTop := high
    pBearBottom := math.max(open, close)
    pBearRatio := upperRatio
    pBearRef := close
    pBearCloseQuality := closeFromHigh
    lastBearCandidate := bar_index

bool newReadyAlert = false
bool stateShiftAlert = false
bool invalidAlert = false

// Stop-aware reaction proof: on each confirmed block, measure whether reaction-side
// follow-through reaches the target before the block's invalidation edge breaks.
var int rbqProofTotal = 0
var int rbqProofWins = 0
var bool rbqProofPending = false
var int rbqProofDir = 0
var float rbqProofTarget = na
var float rbqProofStop = na
var int rbqProofStart = na

bool rbqConfirmedBar = barstate.isconfirmed
if rbqConfirmedBar and rbqProofPending
    bool pLoss = rbqProofDir == 1 ? close <= rbqProofStop : close >= rbqProofStop
    bool pWin = rbqProofDir == 1 ? close >= rbqProofTarget : close <= rbqProofTarget
    bool pResolved = false
    if pLoss
        rbqProofTotal += 1
        pResolved := true
    else if pWin
        rbqProofWins += 1
        rbqProofTotal += 1
        pResolved := true
    if not pResolved and not na(rbqProofStart) and bar_index - rbqProofStart >= proofWindowBars
        pResolved := true
    if pResolved
        rbqProofPending := false

if pendingBull
    barsSinceBull = bar_index - pBullBar
    bullConfirmed = barsSinceBull >= 1 and barsSinceBull <= confirmWindow and high - pBullRef >= safeAtr * minDisplacement and close > pBullTop
    if bullConfirmed
        dispX = math.max(high - pBullRef, 0.0) / safeAtr
        newScore = f_add_block(1, pBullBar, pBullTop, pBullBottom, pBullRatio, dispX, pBullCloseQuality)
        newReadyAlert := newScore >= alertMinScore
        if rbqConfirmedBar and not rbqProofPending
            rbqProofPending := true
            rbqProofDir := 1
            rbqProofTarget := close + safeAtr * proofTargetAtr
            rbqProofStop := close - safeAtr * proofTargetAtr
            rbqProofStart := bar_index
        pendingBull := false
    else if barsSinceBull > confirmWindow
        pendingBull := false

if pendingBear
    barsSinceBear = bar_index - pBearBar
    bearConfirmed = barsSinceBear >= 1 and barsSinceBear <= confirmWindow and pBearRef - low >= safeAtr * minDisplacement and close < pBearBottom
    if bearConfirmed
        dispX = math.max(pBearRef - low, 0.0) / safeAtr
        newScore = f_add_block(-1, pBearBar, pBearTop, pBearBottom, pBearRatio, dispX, pBearCloseQuality)
        newReadyAlert := newReadyAlert or newScore >= alertMinScore
        if rbqConfirmedBar and not rbqProofPending
            rbqProofPending := true
            rbqProofDir := -1
            rbqProofTarget := close - safeAtr * proofTargetAtr
            rbqProofStop := close + safeAtr * proofTargetAtr
            rbqProofStart := bar_index
        pendingBear := false
    else if barsSinceBear > confirmWindow
        pendingBear := false

bool rbqProofReady = rbqProofTotal >= 6
int rbqProofRate = rbqProofReady ? int(math.round(f_clamp(rbqProofWins / rbqProofTotal * 100.0, 0.0, 100.0))) : na
string rbqProofRead = rbqProofReady ? str.tostring(rbqProofRate) + "%  (" + str.tostring(rbqProofTotal) + ")" : "Building (" + str.tostring(rbqProofTotal) + ")"
color rbqProofColor = not rbqProofReady ? neutralColor : rbqProofRate >= 55 ? bullColor : rbqProofRate >= 45 ? neutralColor : bearColor

// ─────────────────────────────────────────────────
// Lifecycle Update
// ─────────────────────────────────────────────────
int activeIndex = na
float activeSurvival = na
float activeDistanceAtr = na
string activeReclaim = "None"
string activeAction = "WAIT"
bool activeOpen = false
bool activeRelevant = false
int activeBar = na
int activeTouches = 0

if array.size(rbBoxes) > 0
    for i = 0 to array.size(rbBoxes) - 1
        bx = array.get(rbBoxes, i)
        ln = array.get(rbEdges, i)
        badge = array.get(rbBadges, i)
        side = array.get(rbSides, i)
        top = array.get(rbTops, i)
        bottom = array.get(rbBottoms, i)
        baseScore = array.get(rbScores, i)
        originBar = array.get(rbBars, i)
        touches = array.get(rbTouches, i)
        lastEvent = array.get(rbLastEvent, i)
        invalid = array.get(rbInvalid, i)
        wasInside = array.get(rbInside, i)
        reclaimed = array.get(rbReclaimed, i)
        age = bar_index - originBar
        expired = age > expiryBars
        currentlyInside = high >= bottom and low <= top
        closeInvalid = side == 1 ? close < bottom : close > top
        wickInvalid = side == 1 ? low < bottom : high > top
        invalidNow = not expired and (breakNeedsClose ? closeInvalid : wickInvalid)
        if invalidNow and not invalid
            invalid := true
            array.set(rbInvalid, i, true)
            invalidAlert := true
            yInvalid = side == 1 ? bottom - safeAtr * 0.55 : top + safeAtr * 0.55
            invalidStyle = side == 1 ? label.style_label_up : label.style_label_down
            if showClosedLabels
                f_add_event(bar_index, yInvalid, "INVALID | Q 0", invalidStyle, bearColor)
        if currentlyInside and not wasInside and not invalid and not expired and bar_index - lastEvent >= cooldownBars
            touches += 1
            array.set(rbTouches, i, touches)
            array.set(rbLastEvent, i, bar_index)
            yTest = side == 1 ? bottom - safeAtr * 0.35 : top + safeAtr * 0.35
            testStyle = side == 1 ? label.style_label_up : label.style_label_down
            if showTestEvents and baseScore >= minimumEventScore
                f_add_event(bar_index, yTest, "TEST | Q " + str.tostring(math.round(baseScore)), testStyle, neutralColor)
        reclaimNow = wasInside and not invalid and not expired and (side == 1 ? close > top : close < bottom)
        if reclaimNow and bar_index - lastEvent >= cooldownBars
            reclaimed := true
            array.set(rbReclaimed, i, true)
            array.set(rbLastEvent, i, bar_index)
            stateShiftAlert := true
            yHold = side == 1 ? high + safeAtr * 0.45 : low - safeAtr * 0.45
            holdStyle = side == 1 ? label.style_label_down : label.style_label_up
            if baseScore >= minimumEventScore
                f_add_event(bar_index, yHold, "RECLAIM | Q " + str.tostring(math.round(baseScore)), holdStyle, bullColor)
        array.set(rbInside, i, currentlyInside and not reclaimNow and not invalid and not expired)

        reactionBoost = math.min(touches * 6.0, 18.0)
        reclaimBoost = reclaimed ? 8.0 : 0.0
        agePenalty = math.min(age * 1.0 / math.max(expiryBars * 1.0, 1.0) * 20.0, 24.0)
        testPenalty = currentlyInside and not reclaimed ? 7.0 : 0.0
        survival = invalid ? 0.0 : f_clamp(baseScore + reactionBoost + reclaimBoost - agePenalty - testPenalty, 0.0, 100.0)
        reclaimState = "Untested"
        if invalid
            reclaimState := "Invalidated"
        else if expired
            reclaimState := "Expired"
        else if reclaimed
            reclaimState := "Reclaimed"
        else if currentlyInside
            reclaimState := "Testing"
        else if touches > 0
            reclaimState := "Surviving"
        distancePrice = close > top ? close - top : close < bottom ? bottom - close : 0.0
        distanceAtr = distancePrice / safeAtr
        candidateOpen = not invalid and not expired
        contextRelevant = candidateOpen and distanceAtr <= maxContextDistanceAtr
        action = f_action(invalid, expired, baseScore, survival, reclaimState, contextRelevant)
        stateToken = reclaimState == "Untested" ? "FRESH" : reclaimState == "Testing" ? "TESTING" : reclaimState == "Reclaimed" ? "RECLAIMED" : reclaimState == "Surviving" ? "SURVIVING" : reclaimState == "Invalidated" ? "INVALIDATED" : "EXPIRED"
        liveText = (side == 1 ? "BULL RB" : "BEAR RB") + " | " + stateToken + " | Q " + str.tostring(math.round(survival))
        if invalid
            liveText := "INVALID | Q 0"
        else if expired
            liveText := "EXPIRED | Q " + str.tostring(math.round(survival))
        isClosed = invalid or expired
        showThisBlock = showZones and not invalid and (not expired or showClosedBlocks)
        visualRight = invalid ? math.min(bar_index, originBar + extendBars) : bar_index + extendBars
        liveFill = color.new(panelBorder, 92)
        if not invalid
            sideZoneColor = side == 1 ? bullColor : bearColor
            matureOpacity = math.min(zoneOpacity + 5, 96)
            liveFill := color.new(sideZoneColor, expired ? matureOpacity : zoneOpacity)
        liveBorder = invalid ? color.new(panelBorder, 72) : expired ? color.new(side == 1 ? bullColor : bearColor, 28) : f_score_color(survival)
        box.set_right(bx, visualRight)
        box.set_bgcolor(bx, showThisBlock ? liveFill : color.new(liveFill, 100))
        box.set_border_color(bx, showThisBlock ? liveBorder : color.new(liveBorder, 100))
        showZoneText = showThisBlock and (not isClosed or showClosedLabels)
        box.set_text(bx, "")
        zoneMidLive = (top + bottom) * 0.5
        badgeXLive = int(math.round((originBar + visualRight) * 0.5))
        badgeFill = invalid ? color.new(panelBorder, 35) : expired ? color.new(side == 1 ? bullColor : bearColor, 22) : color.new(f_score_color(survival), 0)
        if not na(badge)
            label.set_xy(badge, badgeXLive, zoneMidLive)
            label.set_text(badge, showZoneText ? liveText : "")
            label.set_color(badge, showZoneText ? badgeFill : color.new(badgeFill, 100))
            label.set_textcolor(badge, showZoneText ? f_text_on(badgeFill) : color.new(headerText, 100))
            label.set_size(badge, labelSize)
        box.set_text_size(bx, labelSize)
        edgeLevel = side == 1 ? bottom : top
        line.set_x2(ln, visualRight)
        showThisEdge = showEdges and showThisBlock
        line.set_color(ln, showThisEdge ? liveBorder : color.new(liveBorder, 100))
        line.set_y1(ln, edgeLevel)
        line.set_y2(ln, edgeLevel)

        chooseActive = false
        if na(activeIndex)
            chooseActive := true
        else if candidateOpen
            if not activeOpen or distanceAtr < activeDistanceAtr or (distanceAtr == activeDistanceAtr and originBar > activeBar)
                chooseActive := true
        else if not candidateOpen and not activeOpen and originBar > activeBar
            chooseActive := true
        if chooseActive
            activeIndex := i
            activeSurvival := survival
            activeDistanceAtr := distanceAtr
            activeReclaim := reclaimState
            activeAction := action
            activeOpen := candidateOpen
            activeRelevant := contextRelevant
            activeBar := originBar
            activeTouches := touches

// ─────────────────────────────────────────────────
// Panel
// ─────────────────────────────────────────────────
panelMainBg = panelTheme == "Dark" ? panelBg : color.rgb(248, 250, 252)
panelAltBg = panelTheme == "Dark" ? color.rgb(30, 41, 59) : color.rgb(203, 213, 225)
panelLab = panelTheme == "Dark" ? color.rgb(203, 213, 225) : color.rgb(30, 41, 59)
panelVal = panelTheme == "Dark" ? panelValueCol : color.rgb(15, 23, 42)
panelFrame = panelTheme == "Dark" ? panelBorder : color.rgb(148, 163, 184)

var table panel = table.new(f_panel_pos(panelLocation), 2, 8, border_width = 1, border_color = panelFrame)

if barstate.islast
    if showPanel
        table.clear(panel, 0, 0, 1, 7)
        table.merge_cells(panel, 0, 0, 1, 0)
        table.cell(panel, 0, 0, "AG Pro Rejection Block Quality", bgcolor = headerBg, text_color = headerText, text_size = panelSize)
        if not na(activeIndex)
            side = array.get(rbSides, activeIndex)
            baseScore = array.get(rbScores, activeIndex)
            originBar = array.get(rbBars, activeIndex)
            activeTop = array.get(rbTops, activeIndex)
            activeBottom = array.get(rbBottoms, activeIndex)
            invalid = array.get(rbInvalid, activeIndex)
            activeBlock = "Bearish Block"
            if invalid
                activeBlock := "Invalidated"
            else if activeReclaim == "Expired"
                activeBlock := "Expired"
            else if side == 1
                activeBlock := "Bullish Block"
            scoreText = str.tostring(math.round(baseScore))
            survivalText = str.tostring(math.round(activeSurvival))
            contextText = activeDistanceAtr == 0.0 ? "Inside / " + str.tostring(activeTouches) + " tests" : str.tostring(activeDistanceAtr, "#.##") + " ATR / " + str.tostring(activeTouches) + " tests"
            actionBg = color.new(accentColor, 12)
            if activeAction == "READY"
                actionBg := color.new(bullColor, 12)
            else if activeAction == "MONITOR"
                actionBg := color.new(neutralColor, 8)
            else if activeAction == "STANDBY"
                actionBg := color.new(accentColor, 12)
            else if activeAction == "BLOCKED" or activeAction == "INVALIDATED" or activeAction == "EXPIRED"
                actionBg := color.new(bearColor, 10)
            table.cell(panel, 0, 1, "Active Block", bgcolor = panelAltBg, text_color = panelLab, text_size = panelSize)
            table.cell(panel, 1, 1, activeBlock, bgcolor = panelMainBg, text_color = panelVal, text_size = panelSize)
            table.cell(panel, 0, 2, "Rejection Score", bgcolor = panelMainBg, text_color = panelLab, text_size = panelSize)
            table.cell(panel, 1, 2, scoreText, bgcolor = color.new(f_score_color(baseScore), 20), text_color = f_text_on(f_score_color(baseScore)), text_size = panelSize)
            table.cell(panel, 0, 3, "Survival", bgcolor = panelAltBg, text_color = panelLab, text_size = panelSize)
            table.cell(panel, 1, 3, survivalText, bgcolor = color.new(f_score_color(activeSurvival), 22), text_color = f_text_on(f_score_color(activeSurvival)), text_size = panelSize)
            table.cell(panel, 0, 4, "Reaction Proof", bgcolor = panelMainBg, text_color = panelLab, text_size = panelSize)
            table.cell(panel, 1, 4, rbqProofRead, bgcolor = color.new(rbqProofColor, 18), text_color = f_text_on(rbqProofColor), text_size = panelSize)
            table.cell(panel, 0, 5, "Reclaim State", bgcolor = panelAltBg, text_color = panelLab, text_size = panelSize)
            table.cell(panel, 1, 5, activeReclaim, bgcolor = panelMainBg, text_color = panelVal, text_size = panelSize)
            table.cell(panel, 0, 6, "Distance / Tests", bgcolor = panelMainBg, text_color = panelLab, text_size = panelSize)
            table.cell(panel, 1, 6, contextText, bgcolor = panelMainBg, text_color = activeRelevant ? panelVal : accentColor, text_size = panelSize)
            table.cell(panel, 0, 7, "Action", bgcolor = panelAltBg, text_color = panelLab, text_size = panelSize)
            table.cell(panel, 1, 7, activeAction, bgcolor = actionBg, text_color = f_text_on(actionBg), text_size = panelSize)
        else
            table.cell(panel, 0, 1, "Active Block", bgcolor = panelAltBg, text_color = panelLab, text_size = panelSize)
            table.cell(panel, 1, 1, "None", bgcolor = panelMainBg, text_color = panelVal, text_size = panelSize)
            table.cell(panel, 0, 2, "Rejection Score", bgcolor = panelMainBg, text_color = panelLab, text_size = panelSize)
            table.cell(panel, 1, 2, "Waiting", bgcolor = panelMainBg, text_color = panelVal, text_size = panelSize)
            table.cell(panel, 0, 3, "Survival", bgcolor = panelAltBg, text_color = panelLab, text_size = panelSize)
            table.cell(panel, 1, 3, "Waiting", bgcolor = panelMainBg, text_color = panelVal, text_size = panelSize)
            table.cell(panel, 0, 4, "Reaction Proof", bgcolor = panelMainBg, text_color = panelLab, text_size = panelSize)
            table.cell(panel, 1, 4, rbqProofRead, bgcolor = color.new(rbqProofColor, 18), text_color = f_text_on(rbqProofColor), text_size = panelSize)
            table.cell(panel, 0, 5, "Reclaim State", bgcolor = panelAltBg, text_color = panelLab, text_size = panelSize)
            table.cell(panel, 1, 5, "Waiting", bgcolor = panelMainBg, text_color = panelVal, text_size = panelSize)
            table.cell(panel, 0, 6, "Distance / Tests", bgcolor = panelMainBg, text_color = panelLab, text_size = panelSize)
            table.cell(panel, 1, 6, "Waiting", bgcolor = panelMainBg, text_color = panelVal, text_size = panelSize)
            table.cell(panel, 0, 7, "Action", bgcolor = panelAltBg, text_color = panelLab, text_size = panelSize)
            table.cell(panel, 1, 7, "WAIT", bgcolor = color.new(accentColor, 12), text_color = f_text_on(accentColor), text_size = panelSize)
    else
        table.clear(panel, 0, 0, 1, 7)

// ─────────────────────────────────────────────────
// Alerts
// ─────────────────────────────────────────────────
alertcondition(newReadyAlert, "RBQ New Ready Block", "A new Rejection Block Quality setup has reached the configured READY score threshold.")
alertcondition(stateShiftAlert, "RBQ Reclaim / Hold State", "A tracked rejection block has shifted into a reclaim or hold state.")
alertcondition(invalidAlert, "RBQ Block Invalidated", "A tracked rejection block has reached its invalidation condition.")
````
