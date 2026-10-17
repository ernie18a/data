# Institutional Candle Detector [AGPro Series]

- url: https://www.tradingview.com/script/FalPxUiY-Institutional-Candle-Detector-AGPro-Series/
- type: indicator
- pine_id: PUB;485d48335d1b491c92bdd8d7341ca595
- version: 5.0

## Description

🕯️ Institutional Candle Detector [AGPro Series]

Every trader has stared at a massive candle and asked the same question: "Was that the start of a move, the end of one, or just noise?" Most indicators stop at detection — they paint the candle, drop a label, and walk away. This one keeps watching.

Institutional Candle Detector uses a dual-track engine. The body-driven track flags high-conviction candles where ATR-normalized body size and relative volume both expand together, then classifies each event by body/wick geometry. The independent absorption track captures a different signature entirely — low-body candles on extreme volume, the classic aggression-absorbed footprint that body-only detectors miss. Every detected event is then re-evaluated over the following bars to produce a measurable outcome scorecard.


🔹 OVERVIEW

The script scans each bar for two separate, mutually-exclusive institutional signatures:

• Body-driven events. Body must exceed a multiple of ATR AND volume must exceed a multiple of its rolling average. Classified by geometry into Continuation, Reversal or Exhaustion.

• Absorption events. Volume extremely elevated BUT body contained — the market paid for a big move and did not get one. Price was absorbed.

Every detected candle is then given a reaction zone projected forward, and its outcome is automatically tagged after the configured look-forward window — Follow-Through (FT), Reverse (RV) or Consolidation (CN). The panel accumulates aggregate statistics across the loaded chart so the trader can see which candle type actually works on their instrument and timeframe.


🔸 UNIQUE EDGE

What separates this tool from generic "big candle" or "volume spike" indicators:

• Dual-track detection. A single filter cannot capture both explosive moves and absorption. This script runs two engines in parallel with independent thresholds.

• Four-class geometric taxonomy, each backed by a distinct detection path. Continuation and Reversal fire from the body-driven track with different geometry. Exhaustion catches the mid-profile edge cases. Absorption runs entirely off its own volume-first track.

• Automatic after-behavior tracking. Each event is re-examined after N bars and tagged with an outcome code. This is the part most scripts omit — and it's where edge lives.

• Aggregate statistics panel. Follow-through rate, reverse rate, consolidation rate, and per-class counts are computed continuously. The panel tells you whether institutional candles on this asset actually extend, reverse, or fade.

• Forward-projected zones, colored by class. Body-driven bull/bear events use state colors. Absorption uses an indigo accent so the rarer signature is instantly recognizable. Reversal zones use the contrarian color to emphasize the expected directional flip.


🔹 METHODOLOGY

Body-Driven Track (produces CONT, REV, EXH)
– Body is measured as absolute (close − open) and required to exceed Body × ATR multiple.
– Volume is required to exceed a configurable multiple of its SMA average.
– An optional wick filter rejects candles where total wick exceeds the body beyond a given ratio, removing wide-range noise that looks institutional but is not.
– Continuation: body% ≥ configured threshold (clean directional close).
– Reversal: opposing wick% ≥ configured threshold (sharp rejection after initial push).
– Exhaustion: passes the dual-gate but falls into neither clean category — mid profile, often late in a move.

Absorption Track (produces ABS)
– Volume must exceed an independently configurable multiple (higher than body-driven default).
– Body must be small — below a max Body × ATR and below a max Body / Range.
– When absorption fires, it takes precedence over body-driven classification.

After-Behavior Layer
– After lookFwd bars, the script compares the extreme price move in each direction against the original body size.
– If same-direction extension ≥ ftPct × body → Follow-Through (FT).
– If opposite-direction retrace ≥ revPct × body → Reverse (RV).
– Otherwise → Consolidation (CN).

Aggregate counters accumulate across the loaded chart, producing a running scorecard visible in the panel.


🔸 SIGNALS, STATES & MARKERS

On-chart signals
• Institutional body recolored by class — bull/bear direction for CONT and EXH; contrarian color for REV; accent color for ABS.
• Directional triangle marker above/below the bar.
• Classification label: INST-Bull 3.2x CONT or INST-Bear 5.4xV ABS format, ASCII only. Labels offset from the candle to stay readable on dense charts.
• Reaction zone box projected forward from the candle's high-low range, color-coded by class.
• Outcome marker (FT / RV / CN) plotted lookFwd bars after the event.

Alerts available
• Institutional Continuation
• Institutional Reversal
• Institutional Absorption
• Institutional Exhaustion

All four alerts fire on confirmed bars only.


🔹 KEY INPUTS

Detection Core (body-driven track)
– ATR Length (default 14)
– Volume Average Length (default 20)
– Min Body × ATR (default 2.0)
– Min Volume Multiple (default 2.5)
– Wick filter toggle and max Wick/Body ratio (default 2.5)

Absorption Track
– Enable Absorption Detection
– Absorption Min Volume Multiple (default 4.0)
– Absorption Max Body × ATR (default 1.5)
– Absorption Max Body / Range (default 0.40)

Classification
– Continuation body% threshold (default 0.60)
– Reversal opposing-wick% threshold (default 0.40)

After-Behavior
– Look-forward bars (default 5)
– Follow-through threshold as fraction of body (default 0.50)
– Reverse threshold as fraction of body (default 0.60)

Visuals
– Show/hide zones, zone projection length, opacity, max active zones
– Label size (default Small; increase if labels feel too compact)
– Institutional border width
– Outcome marker toggle

Panel
– 8-position panel placement
– Dark / Light theme
– Font size (default Normal)
– Recent events mini-list toggle


🔸 HOW TO USE

1. Start with defaults on a liquid asset. 4H is a strong baseline; 1H for active traders; Daily for swing context. On Daily, consider lowering Min Body × ATR to 1.5 if events are too rare.

2. Watch the panel accumulate events over two to four weeks on your instrument. The follow-through rate tells you whether institutional candles on this chart tend to extend or fade.

3. Trade-context usage:
   – Continuation with a high historical follow-through rate on this asset → trend trades in candle direction after pullback into the zone.
   – Reversal with a high historical reverse rate → fade setups at key levels.
   – Absorption → aggressive flow was met by an equal or greater defender; often precedes a reversal or compression phase.
   – Exhaustion → proceed with caution; frequently a late-move signature where the trend is losing clean structure.

4. Reaction zones act as provisional supply/demand. A retest of a zone with another institutional event near it is a confluence worth noting.

5. Tune thresholds per asset. High-liquidity instruments may need Body × ATR of 2.5+ to keep events selective; low-liquidity pairs can go down to 1.5. Absorption volume multiple can also be adjusted upward on already-volatile instruments.


🔹 LIMITATIONS & TRANSPARENCY

• This is an analytical indicator, not a strategy. No entry, exit, or stop logic is defined and no performance claims are made.
• Aggregate statistics are computed over the loaded chart window and will shift as more bars load or as timeframes change.
• Volume quality depends on the data feed; exchange-reported volume differs across sources for the same asset.
• Follow-through evaluation uses a fixed look-forward window; real trade management will differ.
• All results are historical and descriptive. Past behavior of any candle class does not guarantee future behavior.


🔸 RISK DISCLOSURE

Trading carries substantial risk. This tool is provided for analytical and educational purposes. Do your own research. Use position sizing and risk management appropriate to your account. Nothing in this script constitutes financial advice.

## Source Code

````pine
// -------------------------------------------------
// Institutional Candle Detector [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 1.6
//
// Institutional Candle Detector identifies high-conviction institutional candles
// by combining ATR-normalized body expansion, relative volume, wick control and
// an independent absorption track. This version keeps the original candle
// taxonomy, then adds event efficiency, follow-through tracking, failure risk,
// invalidation shelves and target corridors so each candle becomes a practical
// post-event decision map instead of a simple large-candle marker. Version 1.6
// refines map ownership, accumulated excursion tracking and object lifecycle clarity.
// -------------------------------------------------

//@version=6
indicator("Institutional Candle Detector [AGPro Series]",
     shorttitle = "AG Pro ICD",
     overlay = true,
     max_labels_count = 500,
     max_boxes_count = 260,
     max_lines_count = 220)

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
ttAtr = "ATR length used to normalize institutional candle body size, label distance, invalidation shelves and target corridors."
ttVol = "Rolling volume average used to calculate relative volume. Relative volume is part of the institutional event score."
ttBodyAtr = "Minimum candle body size expressed as ATR. This keeps the body-driven track focused on meaningful candle expansion."
ttVolMult = "Minimum volume multiple required by the body-driven institutional candle track."
ttWick = "When enabled, candles with excessive total wick compared with body size are filtered from the body-driven track."
ttWickRatio = "Maximum total wick divided by body size allowed for the body-driven track."
ttAbs = "Detects high-volume contained-body candles. This is separate from the body-driven track and is treated as an absorption event."
ttAbsVol = "Minimum relative volume required for absorption. Absorption requires stronger participation than ordinary body-driven events."
ttAbsAtr = "Maximum body size in ATR terms for absorption. Absorption is defined by high volume with contained displacement."
ttAbsPct = "Maximum body divided by total candle range for absorption events."
ttCont = "Body divided by range threshold used to classify clean continuation candles."
ttRev = "Opposing wick divided by range threshold used to classify reversal-style institutional candles."
ttTrend = "EMA lengths used only for trend-support scoring. They do not create moving-average signals."
ttMinScore = "Minimum 0-100 event efficiency score required for READY state. Lower scores can still be tracked as WAIT or REVIEW."
ttFollowBars = "Number of bars used to monitor follow-through, invalidation and final outcome after an institutional candle."
ttTarget = "Target guide projected from the event close by candle body multiple. This is a measurement reference, not a promise."
ttTargetCap = "Caps the visible follow-through corridor height in ATR terms. This keeps daily and high-volatility charts from drawing oversized boxes."
ttRiskBuffer = "ATR buffer placed beyond the institutional candle opposite edge to build the invalidation shelf."
ttFail = "Failure risk level that changes the action state to REVIEW RISK before final invalidation."
ttActiveMemory = "Bars after the follow-through window during which the latest event remains in the main panel state. Older events stay in Recent Events."
ttZones = "Shows a forward follow-through corridor from the event close toward the target guide. Each visible corridor receives a centered filled identity badge."
ttGuides = "Shows precise invalidation and target guide lines with paired filled reference badges. Off by default for a cleaner chart; enable when you want exact levels."
ttShelf = "Shows the invalidation shelf behind the institutional candle with a centered filled identity badge. This is a context reference, not a stop recommendation."
ttGlow = "Colors detected institutional candles using the event class color while keeping the chart readable."
ttLabels = "Shows compact event and outcome labels offset away from candles."
ttScoreLbl = "Adds the 0-100 event score to labels. Disable for a cleaner screenshot."
ttCooldown = "Minimum bars between event labels. Higher values reduce chart density."
ttMaxObjects = "Maximum retained labels, boxes and guide lines. Older objects are removed first for performance."
ttMaxMaps = "Maximum retained event maps for each enabled map layer. Lower values keep historical structure focused and prevent unowned visual remnants."
ttLabelOffset = "ATR-based label offset used to keep labels above or below candles instead of buried inside candle bodies."
ttFont = "Controls chart label font size. Normal is the recommended publication default."
ttPanel = "Shows or hides the AGPro planning panel. It is shown by default for public-release readability."
ttPanelLoc = "Moves the AGPro panel to the preferred chart location."
ttPanelTheme = "Switches between the AGPro dark panel and a clean light panel."
ttPanelFont = "Controls panel font size. Normal is the recommended publication default."
ttRecent = "Adds a compact recent-events block under the main planning rows."

// -------------------------------------------------
// Inputs
// -------------------------------------------------
groupCore = "Detection Core"
atrLen = input.int(14, "ATR Length", minval = 2, maxval = 300, group = groupCore, tooltip = ttAtr)
volLen = input.int(20, "Volume Average Length", minval = 2, maxval = 300, group = groupCore, tooltip = ttVol)
bodyAtrMult = input.float(1.35, "Min Body x ATR", minval = 0.5, maxval = 10.0, step = 0.1, group = groupCore, tooltip = ttBodyAtr)
volMult = input.float(1.6, "Min Volume Multiple", minval = 1.0, maxval = 20.0, step = 0.1, group = groupCore, tooltip = ttVolMult)
useWickFilter = input.bool(true, "Exclude Oversized-Wick Candles", group = groupCore, tooltip = ttWick)
maxWickRatio = input.float(2.5, "Max Wick / Body Ratio", minval = 0.5, maxval = 10.0, step = 0.1, group = groupCore, tooltip = ttWickRatio)

groupAbs = "Absorption Track"
enableAbsorption = input.bool(true, "Enable Absorption Detection", group = groupAbs, tooltip = ttAbs)
absVolMult = input.float(2.8, "Absorption Min Volume Multiple", minval = 1.5, maxval = 30.0, step = 0.1, group = groupAbs, tooltip = ttAbsVol)
absMaxBodyAtr = input.float(1.5, "Absorption Max Body x ATR", minval = 0.1, maxval = 5.0, step = 0.1, group = groupAbs, tooltip = ttAbsAtr)
absMaxBodyPct = input.float(0.40, "Absorption Max Body / Range", minval = 0.05, maxval = 0.80, step = 0.05, group = groupAbs, tooltip = ttAbsPct)

groupClass = "Classification"
contBodyPct = input.float(0.60, "Continuation Body %", minval = 0.30, maxval = 0.95, step = 0.05, group = groupClass, tooltip = ttCont)
revWickPct = input.float(0.40, "Reversal Opposing-Wick %", minval = 0.20, maxval = 0.80, step = 0.05, group = groupClass, tooltip = ttRev)

groupScore = "Outcome Score"
fastTrendLen = input.int(21, "Fast Trend EMA", minval = 3, maxval = 200, group = groupScore, tooltip = ttTrend)
slowTrendLen = input.int(55, "Slow Trend EMA", minval = 5, maxval = 300, group = groupScore, tooltip = ttTrend)
minReadyScore = input.int(64, "READY Score Threshold", minval = 40, maxval = 95, group = groupScore, tooltip = ttMinScore)
followBars = input.int(6, "Follow-Through Bars", minval = 2, maxval = 30, group = groupScore, tooltip = ttFollowBars)
targetBodyMult = input.float(1.20, "Target Body Multiple", minval = 0.25, maxval = 4.00, step = 0.05, group = groupScore, tooltip = ttTarget)
targetAtrCap = input.float(1.80, "Max Corridor Height ATR", minval = 0.50, maxval = 8.00, step = 0.10, group = groupScore, tooltip = ttTargetCap)
riskBufferAtr = input.float(0.12, "Invalidation Shelf Buffer ATR", minval = 0.00, maxval = 1.50, step = 0.01, group = groupScore, tooltip = ttRiskBuffer)
failureRiskTrigger = input.int(68, "Failure Risk Review Level", minval = 40, maxval = 95, group = groupScore, tooltip = ttFail)
activeMemoryBars = input.int(34, "Panel Active Memory Bars", minval = 4, maxval = 300, group = groupScore, tooltip = ttActiveMemory)

groupVisual = "Chart Visuals"
showCorridors = input.bool(true, "Show Follow-Through Corridors", group = groupVisual, tooltip = ttZones)
showInvalidationShelf = input.bool(false, "Show Invalidation Shelf", group = groupVisual, tooltip = ttShelf)
showCandleGlow = input.bool(true, "Show Institutional Candle Glow", group = groupVisual, tooltip = ttGlow)
showGuides = input.bool(false, "Show Risk/Target Guide Lines", group = groupVisual, tooltip = ttGuides)
showEventMarkers = input.bool(false, "Show Event Markers", group = groupVisual)
boxTransparency = input.int(94, "Corridor Transparency", minval = 72, maxval = 96, group = groupVisual)
shelfTransparency = input.int(92, "Shelf Transparency", minval = 72, maxval = 96, group = groupVisual)

groupLabels = "Labels"
showLabels = input.bool(true, "Show Labels", group = groupLabels, tooltip = ttLabels)
showLabelScore = input.bool(true, "Show Label Score", group = groupLabels, tooltip = ttScoreLbl)
labelCooldownBars = input.int(14, "Event Label Cooldown", minval = 1, maxval = 120, group = groupLabels, tooltip = ttCooldown)
maxVisibleObjects = input.int(10, "Max Visible Objects", minval = 5, maxval = 100, group = groupLabels, tooltip = ttMaxObjects)
maxVisibleMaps = input.int(5, "Max Visible Event Maps", minval = 2, maxval = 20, group = groupLabels, tooltip = ttMaxMaps)
labelOffsetAtr = input.float(1.10, "Label Offset ATR", minval = 0.10, maxval = 4.00, step = 0.05, group = groupLabels, tooltip = ttLabelOffset)
labelFontSize = input.string("Normal", "Label Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = groupLabels, tooltip = ttFont)

groupPanel = "Panel"
showPanel = input.bool(true, "Show Panel", group = groupPanel, tooltip = ttPanel)
panelLocation = input.string("Top Right", "Panel Location", options = ["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], group = groupPanel, tooltip = ttPanelLoc)
panelTheme = input.string("Elite Dark", "Panel Theme", options = ["Elite Dark", "Clean Light"], group = groupPanel, tooltip = ttPanelTheme)
panelFontSize = input.string("Normal", "Panel Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = groupPanel, tooltip = ttPanelFont)
showRecentBlock = input.bool(true, "Show Recent Events", group = groupPanel, tooltip = ttRecent)

groupAlerts = "Alerts"
alertReady = input.bool(true, "Alert on READY Event", group = groupAlerts)
alertRisk = input.bool(true, "Alert on Failure Risk", group = groupAlerts)
alertInvalid = input.bool(true, "Alert on Invalidation", group = groupAlerts)
alertOutcome = input.bool(true, "Alert on Final Outcome", group = groupAlerts)

// -------------------------------------------------
// Helpers
// -------------------------------------------------
f_clamp(float value, float minValue, float maxValue) =>
    math.min(math.max(value, minValue), maxValue)

// Luminance-aware text color so every on-chart badge stays legible on its fill
f_text_on(color bg) =>
    lum = 0.299 * color.r(bg) + 0.587 * color.g(bg) + 0.114 * color.b(bg)
    lum > 145 ? color.rgb(17, 24, 39) : headerText

f_norm_high_good(float value, float weak, float strong) =>
    float span = strong - weak
    span == 0.0 ? 0.0 : f_clamp((value - weak) / span * 100.0, 0.0, 100.0)

f_norm_low_good(float value, float good, float bad) =>
    float span = bad - good
    span == 0.0 ? 0.0 : f_clamp((bad - value) / span * 100.0, 0.0, 100.0)

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
    theme == "Clean Light" ? color.rgb(241, 245, 249) : panelBg

f_panel_border(string theme) =>
    theme == "Clean Light" ? color.rgb(148, 163, 184) : panelBorder

f_panel_label(string theme) =>
    theme == "Clean Light" ? color.rgb(71, 85, 105) : panelLabelCol

f_panel_value(string theme) =>
    theme == "Clean Light" ? color.rgb(15, 23, 42) : panelValueCol

f_class_text(int classCode) =>
    switch classCode
        1 => "Continuation"
        2 => "Reversal"
        3 => "Absorption"
        4 => "Exhaustion"
        => "None"

f_class_short(int classCode) =>
    switch classCode
        1 => "CONT"
        2 => "REV"
        3 => "ABS"
        4 => "EXH"
        => "NONE"

f_result_text(int resultCode) =>
    switch resultCode
        1 => "Follow-Through"
        -1 => "Invalidated"
        2 => "Consolidated"
        => "Tracking"

f_event_color(int classCode, int dir) =>
    classCode == 3 ? accentColor :
     classCode == 4 ? neutralColor :
     dir == 1 ? bullColor : bearColor

f_action_color(string actionText) =>
    actionText == "READY" or actionText == "MONITOR" or actionText == "CONFIRMED" ? bullColor :
     actionText == "INVALIDATED" or actionText == "REVIEW RISK" ? bearColor :
     actionText == "EXPIRED" ? neutralColor : panelValueCol

f_panel_row(table target, int row, string leftText, string rightText, color rightColor, color rowBg, color leftColor, string fontSize) =>
    table.cell(target, 0, row, leftText, text_color = leftColor, bgcolor = rowBg, text_size = f_label_size(fontSize), text_halign = text.align_left)
    table.cell(target, 1, row, rightText, text_color = rightColor, bgcolor = rowBg, text_size = f_label_size(fontSize), text_halign = text.align_right)

// -------------------------------------------------
// Core Metrics
// -------------------------------------------------
atrValue = math.max(nz(ta.atr(atrLen), ta.tr(true)), syminfo.mintick)
volumeAverage = ta.sma(volume, volLen)
fastEma = ta.ema(close, fastTrendLen)
slowEma = ta.ema(close, slowTrendLen)

bodySize = math.abs(close - open)
rangeSize = high - low
upperWick = high - math.max(close, open)
lowerWick = math.min(close, open) - low
totalWick = upperWick + lowerWick
isBullCandle = close > open
isBearCandle = close < open
bodyAtr = atrValue > 0.0 ? bodySize / atrValue : 0.0
volRatio = volumeAverage > 0.0 ? volume / volumeAverage : 1.0
bodyPctRange = rangeSize > 0.0 ? bodySize / rangeSize : 0.0
upperWickPct = rangeSize > 0.0 ? upperWick / rangeSize : 0.0
lowerWickPct = rangeSize > 0.0 ? lowerWick / rangeSize : 0.0
totalWickRatio = bodySize > 0.0 ? totalWick / bodySize : 99.0
closeLocation = rangeSize > 0.0 ? (close - low) / rangeSize : 0.5

bodyGate = atrValue > 0.0 and bodySize >= bodyAtrMult * atrValue
volumeGate = volumeAverage > 0.0 and volume >= volMult * volumeAverage
wickGate = not useWickFilter or (bodySize > 0.0 and totalWick <= maxWickRatio * bodySize)
bodyDriven = bodyGate and volumeGate and wickGate and (isBullCandle or isBearCandle)

absorption = enableAbsorption and
     volumeAverage > 0.0 and volume >= absVolMult * volumeAverage and
     atrValue > 0.0 and bodySize <= absMaxBodyAtr * atrValue and
     bodyPctRange <= absMaxBodyPct and
     (isBullCandle or isBearCandle)

opposingWickPct = isBullCandle ? upperWickPct : lowerWickPct
classCode = absorption ? 3 :
     bodyDriven ? (opposingWickPct >= revWickPct ? 2 : bodyPctRange >= contBodyPct ? 1 : 4) : 0

// Continuation and exhaustion use candle direction. Reversal and absorption use the opposite expected review side.
rawDir = isBullCandle ? 1 : -1
eventDir = classCode == 2 or classCode == 3 ? -rawDir : rawDir
eventColor = f_event_color(classCode, eventDir)

bodyEfficiencyScore = classCode == 3 ? f_norm_low_good(bodyPctRange, 0.08, absMaxBodyPct) : f_norm_high_good(bodyPctRange, 0.30, 0.82)
wickControlScore = classCode == 2 ? f_norm_high_good(opposingWickPct, revWickPct, 0.75) : f_norm_low_good(totalWickRatio, 0.25, maxWickRatio)
volumeScore = classCode == 3 ? f_norm_high_good(volRatio, absVolMult * 0.70, absVolMult * 1.60) : f_norm_high_good(volRatio, volMult * 0.75, volMult * 1.60)
expansionScore = classCode == 3 ? f_norm_low_good(bodyAtr, 0.10, absMaxBodyAtr) : f_norm_high_good(bodyAtr, bodyAtrMult * 0.70, bodyAtrMult * 1.60)
trendSideScore = eventDir == 1 ?
     (close > fastEma ? 34.0 : 0.0) + (fastEma > slowEma ? 33.0 : 0.0) + (fastEma > fastEma[1] ? 33.0 : 0.0) :
     (close < fastEma ? 34.0 : 0.0) + (fastEma < slowEma ? 33.0 : 0.0) + (fastEma < fastEma[1] ? 33.0 : 0.0)

eventScoreRaw = bodyEfficiencyScore * 0.24 + wickControlScore * 0.20 + volumeScore * 0.22 + expansionScore * 0.18 + trendSideScore * 0.16
eventScore = int(math.round(f_clamp(eventScoreRaw, 0.0, 100.0)))
qualifiedEvent = classCode != 0 and barstate.isconfirmed

eventRiskEdge = eventDir == 1 ? low - atrValue * riskBufferAtr : high + atrValue * riskBufferAtr
targetMove = math.min(bodySize * targetBodyMult, atrValue * targetAtrCap)
eventTarget = eventDir == 1 ? close + targetMove : close - targetMove
eventShelfOuter = eventDir == 1 ? eventRiskEdge - atrValue * 0.18 : eventRiskEdge + atrValue * 0.18

// -------------------------------------------------
// State Arrays
// -------------------------------------------------
var array<int> eventBars = array.new<int>()
var array<int> eventClasses = array.new<int>()
var array<int> eventDirs = array.new<int>()
var array<int> eventScores = array.new<int>()
var array<float> eventCloses = array.new<float>()
var array<float> eventBodies = array.new<float>()
var array<float> eventRisks = array.new<float>()
var array<float> eventTargets = array.new<float>()
var array<float> eventHighs = array.new<float>()
var array<float> eventLows = array.new<float>()
var array<int> eventResults = array.new<int>()
var array<bool> eventRiskAlerts = array.new<bool>()
var array<float> eventProofTargets = array.new<float>()
var array<float> eventProofStops = array.new<float>()
var array<int> eventProofResults = array.new<int>()

var array<label> eventLabelObjects = array.new<label>()
var array<label> outcomeLabelObjects = array.new<label>()
var array<label> corridorBadgeObjects = array.new<label>()
var array<label> shelfBadgeObjects = array.new<label>()
var array<label> guideBadgeObjects = array.new<label>()
var array<box> corridorObjects = array.new<box>()
var array<box> shelfObjects = array.new<box>()
var array<line> guideObjects = array.new<line>()

var int lastEventLabelBar = na
var bool readyEvent = false
var bool riskReviewEvent = false
var bool invalidationEvent = false
var bool finalOutcomeEvent = false

// Follow-through proof: of finalized events, how many reached target vs invalidation
var int icdProofWins = 0
var int icdProofLosses = 0

readyEvent := false
riskReviewEvent := false
invalidationEvent := false
finalOutcomeEvent := false

// -------------------------------------------------
// Event Registration
// -------------------------------------------------
if qualifiedEvent
    array.push(eventBars, bar_index)
    array.push(eventClasses, classCode)
    array.push(eventDirs, eventDir)
    array.push(eventScores, eventScore)
    array.push(eventCloses, close)
    array.push(eventBodies, bodySize)
    array.push(eventRisks, eventRiskEdge)
    array.push(eventTargets, eventTarget)
    array.push(eventHighs, high)
    array.push(eventLows, low)
    array.push(eventResults, 0)
    array.push(eventRiskAlerts, false)
    array.push(eventProofTargets, eventDir == 1 ? close + atrValue * 1.5 : close - atrValue * 1.5)
    array.push(eventProofStops, eventDir == 1 ? close - atrValue * 1.0 : close + atrValue * 1.0)
    array.push(eventProofResults, 0)

    while array.size(eventBars) > 240
        array.shift(eventBars)
        array.shift(eventClasses)
        array.shift(eventDirs)
        array.shift(eventScores)
        array.shift(eventCloses)
        array.shift(eventBodies)
        array.shift(eventRisks)
        array.shift(eventTargets)
        array.shift(eventHighs)
        array.shift(eventLows)
        array.shift(eventResults)
        array.shift(eventRiskAlerts)
        array.shift(eventProofTargets)
        array.shift(eventProofStops)
        array.shift(eventProofResults)

    readyEvent := eventScore >= minReadyScore

    if showCorridors
        int rightBar = bar_index + followBars
        float corridorTop = math.max(close, eventTarget)
        float corridorBottom = math.min(close, eventTarget)
        box corridor = box.new(left = bar_index, top = corridorTop, right = rightBar, bottom = corridorBottom, xloc = xloc.bar_index,
             bgcolor = color.new(eventColor, boxTransparency), border_color = color.new(eventColor, 50), border_width = 1)
        array.push(corridorObjects, corridor)
        if showLabels
            int corridorMidBar = bar_index + int(math.floor(followBars * 0.5))
            float corridorMidPrice = (corridorTop + corridorBottom) * 0.5
            string corridorBadgeText = f_class_short(classCode) + " MAP"
            label corridorBadge = label.new(x = corridorMidBar, y = corridorMidPrice, text = corridorBadgeText,
                 xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_center,
                 color = eventColor, textcolor = f_text_on(eventColor), size = f_label_size(labelFontSize),
                 tooltip = f_class_text(classCode) + " follow-through corridor", textalign = text.align_center)
            array.push(corridorBadgeObjects, corridorBadge)
        while array.size(corridorObjects) > maxVisibleMaps
            box oldBox = array.shift(corridorObjects)
            box.delete(oldBox)
            if array.size(corridorBadgeObjects) > 0
                label oldCorridorBadge = array.shift(corridorBadgeObjects)
                label.delete(oldCorridorBadge)

    if showInvalidationShelf
        int shelfRight = bar_index + followBars
        float shelfTop = eventDir == 1 ? low : eventShelfOuter
        float shelfBottom = eventDir == 1 ? eventShelfOuter : high
        box shelf = box.new(left = bar_index, top = math.max(shelfTop, shelfBottom), right = shelfRight, bottom = math.min(shelfTop, shelfBottom), xloc = xloc.bar_index,
             bgcolor = color.new(neutralColor, shelfTransparency), border_color = color.new(neutralColor, 50), border_width = 1)
        array.push(shelfObjects, shelf)
        if showLabels
            int shelfMidBar = bar_index + int(math.floor(followBars * 0.5))
            float shelfMidPrice = (math.max(shelfTop, shelfBottom) + math.min(shelfTop, shelfBottom)) * 0.5
            label shelfBadge = label.new(x = shelfMidBar, y = shelfMidPrice, text = "RISK SHELF",
                 xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_center,
                 color = neutralColor, textcolor = f_text_on(neutralColor), size = f_label_size(labelFontSize),
                 tooltip = "Institutional candle invalidation shelf", textalign = text.align_center)
            array.push(shelfBadgeObjects, shelfBadge)
        while array.size(shelfObjects) > maxVisibleMaps
            box oldShelf = array.shift(shelfObjects)
            box.delete(oldShelf)
            if array.size(shelfBadgeObjects) > 0
                label oldShelfBadge = array.shift(shelfBadgeObjects)
                label.delete(oldShelfBadge)

    if showGuides
        line riskLine = line.new(bar_index, eventRiskEdge, bar_index + followBars, eventRiskEdge, xloc = xloc.bar_index, extend = extend.none,
             color = color.new(neutralColor, 0), width = 2, style = line.style_dashed)
        line targetLine = line.new(bar_index, eventTarget, bar_index + followBars, eventTarget, xloc = xloc.bar_index, extend = extend.none,
             color = color.new(accentColor, 0), width = 1, style = line.style_dotted)
        array.push(guideObjects, riskLine)
        array.push(guideObjects, targetLine)
        if showLabels
            label riskBadge = label.new(x = bar_index + followBars, y = eventRiskEdge, text = "RISK",
                 xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left,
                 color = neutralColor, textcolor = f_text_on(neutralColor), size = f_label_size(labelFontSize),
                 tooltip = "Institutional candle invalidation reference", textalign = text.align_center)
            label targetBadge = label.new(x = bar_index + followBars, y = eventTarget, text = "TARGET",
                 xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left,
                 color = accentColor, textcolor = f_text_on(accentColor), size = f_label_size(labelFontSize),
                 tooltip = "Institutional candle follow-through target reference", textalign = text.align_center)
            array.push(guideBadgeObjects, riskBadge)
            array.push(guideBadgeObjects, targetBadge)
        while array.size(guideObjects) > maxVisibleMaps * 2
            line oldGuide = array.shift(guideObjects)
            line.delete(oldGuide)
            if array.size(guideBadgeObjects) > 0
                label oldGuideBadge = array.shift(guideBadgeObjects)
                label.delete(oldGuideBadge)

    bool labelAllowed = na(lastEventLabelBar) or bar_index - lastEventLabelBar >= labelCooldownBars
    if showLabels and labelAllowed
        string sideText = eventDir == 1 ? "Bull" : "Bear"
        string scoreText = showLabelScore ? " " + str.tostring(eventScore) : ""
        string labelText = f_class_short(classCode) + scoreText
        string tipText = "Institutional Candle Detector\nType: " + f_class_text(classCode) + "\nEfficiency: " + str.tostring(eventScore) + "\nBody Efficiency: " + str.tostring(math.round(bodyEfficiencyScore)) + "\nVolume Support: " + str.tostring(math.round(volumeScore)) + "\nExpected Side: " + sideText
        float labelY = eventDir == 1 ? low - atrValue * labelOffsetAtr : high + atrValue * labelOffsetAtr
        labelStyle = eventDir == 1 ? label.style_label_up : label.style_label_down
        label newEventLabel = label.new(x = bar_index, y = labelY, text = labelText, xloc = xloc.bar_index, yloc = yloc.price,
             style = labelStyle, color = color.new(eventColor, 6), textcolor = f_text_on(eventColor), size = f_label_size(labelFontSize),
             tooltip = tipText, textalign = text.align_center)
        array.push(eventLabelObjects, newEventLabel)
        lastEventLabelBar := bar_index
        while array.size(eventLabelObjects) > maxVisibleObjects
            label oldLabel = array.shift(eventLabelObjects)
            label.delete(oldLabel)

// -------------------------------------------------
// Outcome Evaluation
// -------------------------------------------------
highestFollow = ta.highest(high, followBars)
lowestFollow = ta.lowest(low, followBars)

if array.size(eventBars) > 0 and barstate.isconfirmed
    int i = 0
    while i < array.size(eventBars)
        int resultCode = array.get(eventResults, i)
        if resultCode == 0
            int eBar = array.get(eventBars, i)
            int barsSince = bar_index - eBar
            int dir = array.get(eventDirs, i)
            float eClose = array.get(eventCloses, i)
            float eBody = math.max(array.get(eventBodies, i), syminfo.mintick)
            float eRisk = array.get(eventRisks, i)
            float eTarget = array.get(eventTargets, i)
            float eHigh = math.max(array.get(eventHighs, i), high)
            float eLow = math.min(array.get(eventLows, i), low)
            array.set(eventHighs, i, eHigh)
            array.set(eventLows, i, eLow)
            bool invalidNow = dir == 1 ? low <= eRisk : high >= eRisk
            bool targetNow = dir == 1 ? high >= eTarget : low <= eTarget
            float activeAdverse = dir == 1 ? eClose - eLow : eHigh - eClose
            float activeFailureRisk = f_clamp(activeAdverse / math.max(math.abs(eClose - eRisk), syminfo.mintick) * 100.0, 0.0, 100.0)
            bool eventFinalizedNow = false

            if activeFailureRisk >= failureRiskTrigger and not array.get(eventRiskAlerts, i)
                array.set(eventRiskAlerts, i, true)
                riskReviewEvent := true

            if invalidNow
                array.set(eventResults, i, -1)
                invalidationEvent := true
                finalOutcomeEvent := true
                eventFinalizedNow := true
            else if targetNow
                array.set(eventResults, i, 1)
                finalOutcomeEvent := true
                eventFinalizedNow := true
            else if barsSince >= followBars
                bool finalTarget = dir == 1 ? highestFollow >= eTarget : lowestFollow <= eTarget
                bool finalInvalid = dir == 1 ? lowestFollow <= eRisk : highestFollow >= eRisk
                int finalResult = finalTarget ? 1 : finalInvalid ? -1 : 2
                array.set(eventResults, i, finalResult)
                invalidationEvent := finalResult == -1
                finalOutcomeEvent := true
                eventFinalizedNow := true

            int updatedResult = array.get(eventResults, i)
            if showLabels and updatedResult != 0 and eventFinalizedNow
                color resultColor = updatedResult == 1 ? bullColor : updatedResult == -1 ? bearColor : neutralColor
                string resultText = updatedResult == 1 ? "FT" : updatedResult == -1 ? "INVALID" : "CN"
                float outcomeY = dir == 1 ? high + atrValue * 0.75 : low - atrValue * 0.75
                outcomeStyle = dir == 1 ? label.style_label_down : label.style_label_up
                label outcomeLabel = label.new(x = bar_index, y = outcomeY, text = resultText, xloc = xloc.bar_index, yloc = yloc.price,
                     style = outcomeStyle, color = resultColor, textcolor = f_text_on(resultColor), size = f_label_size(labelFontSize),
                     tooltip = "Institutional candle outcome: " + f_result_text(updatedResult), textalign = text.align_center)
                array.push(outcomeLabelObjects, outcomeLabel)
                while array.size(outcomeLabelObjects) > maxVisibleObjects
                    label oldOutcome = array.shift(outcomeLabelObjects)
                    label.delete(oldOutcome)

        int pRes = array.get(eventProofResults, i)
        if pRes == 0
            int pBar = array.get(eventBars, i)
            int pSince = bar_index - pBar
            int pDir = array.get(eventDirs, i)
            float pT = array.get(eventProofTargets, i)
            float pS = array.get(eventProofStops, i)
            bool pHitStop = pDir == 1 ? close <= pS : close >= pS
            bool pHitTarget = pDir == 1 ? close >= pT : close <= pT
            if pHitStop
                array.set(eventProofResults, i, -1)
                icdProofLosses += 1
            else if pHitTarget
                array.set(eventProofResults, i, 1)
                icdProofWins += 1
            else if pSince >= 20
                array.set(eventProofResults, i, 2)
        i := i + 1

// -------------------------------------------------
// Active Panel State
// -------------------------------------------------
int activeIndex = array.size(eventBars) > 0 ? array.size(eventBars) - 1 : na
bool hasActive = not na(activeIndex)

string panelTypeText = "None"
string panelEfficiencyText = "0"
string panelFollowText = "Waiting"
string panelRiskText = "0"
string panelActionText = "WAIT"
color panelActionCol = panelValueCol
color panelTypeCol = panelValueCol

if hasActive
    int aClass = array.get(eventClasses, activeIndex)
    int aDir = array.get(eventDirs, activeIndex)
    int aResult = array.get(eventResults, activeIndex)
    int aScore = array.get(eventScores, activeIndex)
    float aClose = array.get(eventCloses, activeIndex)
    float aRisk = array.get(eventRisks, activeIndex)
    float aTarget = array.get(eventTargets, activeIndex)
    float aHigh = array.get(eventHighs, activeIndex)
    float aLow = array.get(eventLows, activeIndex)
    int aBars = bar_index - array.get(eventBars, activeIndex)
    float aTargetDistance = math.max(math.abs(aTarget - aClose), syminfo.mintick)
    float aFavorable = aDir == 1 ? aHigh - aClose : aClose - aLow
    float aAdverse = aDir == 1 ? aClose - aLow : aHigh - aClose
    float aProgress = f_clamp(aFavorable / aTargetDistance * 100.0, 0.0, 100.0)
    float aFailureRisk = f_clamp(aAdverse / math.max(math.abs(aClose - aRisk), syminfo.mintick) * 100.0, 0.0, 100.0)
    bool staleForPanel = aBars > followBars + activeMemoryBars and aResult != 0
    if staleForPanel
        panelTypeText := "No Active Event"
        panelEfficiencyText := "-"
        panelFollowText := "Standing By"
        panelRiskText := "-"
        panelActionText := "WAIT"
        panelActionCol := panelValueCol
        panelTypeCol := panelLabelCol
    else
        panelTypeText := f_class_text(aClass) + " " + (aDir == 1 ? "Bull" : "Bear")
        panelEfficiencyText := str.tostring(int(math.round(aScore))) + "/100"
        panelFollowText := aResult == 1 ? "Confirmed" :
             aResult == -1 ? "Invalidated" :
             aResult == 2 ? "Expired" :
             aProgress >= 75 ? "Near Target" :
             aProgress >= 35 ? "Building" :
             aBars <= followBars ? "Tracking" : "Waiting"
        panelRiskText := str.tostring(int(math.round(aFailureRisk))) + "/100"
        panelActionText := aResult == 1 ? "CONFIRMED" :
             aResult == -1 ? "INVALIDATED" :
             aResult == 2 ? "EXPIRED" :
             aFailureRisk >= failureRiskTrigger ? "REVIEW RISK" :
             aScore >= minReadyScore and aBars <= 1 ? "READY" :
             aScore >= minReadyScore ? "MONITOR" : "WAIT"
        panelActionCol := f_action_color(panelActionText)
        panelTypeCol := f_event_color(aClass, aDir)

// -------------------------------------------------
// Plots
// -------------------------------------------------
plotshape(showEventMarkers and classCode != 0 and eventDir == 1, title = "Institutional Bull Event", style = shape.triangleup, location = location.belowbar, color = eventColor, size = size.tiny)
plotshape(showEventMarkers and classCode != 0 and eventDir == -1, title = "Institutional Bear Event", style = shape.triangledown, location = location.abovebar, color = eventColor, size = size.tiny)

plotcandle(showCandleGlow and classCode != 0 ? open : na,
     showCandleGlow and classCode != 0 ? high : na,
     showCandleGlow and classCode != 0 ? low : na,
     showCandleGlow and classCode != 0 ? close : na,
     title = "Institutional Candle Glow",
     color = color.new(eventColor, 0),
     wickcolor = color.new(eventColor, 0),
     bordercolor = color.new(eventColor, 0))

float scorePlot = na
if hasActive
    scorePlot := array.get(eventScores, activeIndex)
plot(scorePlot, title = "Institutional Candle Efficiency Score", color = panelActionCol, display = display.data_window)

// -------------------------------------------------
// Panel
// -------------------------------------------------
var table panel = na

if barstate.islast
    if not na(panel)
        table.delete(panel)
        panel := na
    if showPanel
        int panelRows = showRecentBlock ? 11 : 7
        color pBg = f_panel_bg(panelTheme)
        color pBorder = f_panel_border(panelTheme)
        color pLabel = f_panel_label(panelTheme)
        color pValue = f_panel_value(panelTheme)
        panel := table.new(f_panel_position(panelLocation), 2, panelRows, bgcolor = pBg, border_color = pBorder, border_width = 1, frame_color = pBorder, frame_width = 1)

        table.cell(panel, 0, 0, "AG Pro Institutional Candle Detector", text_color = headerText, bgcolor = headerBg, text_size = f_label_size(panelFontSize), text_halign = text.align_center)
        table.merge_cells(panel, 0, 0, 1, 0)

        int icdProofTotal = icdProofWins + icdProofLosses
        float icdProofRate = icdProofTotal == 0 ? 0.0 : 100.0 * icdProofWins / icdProofTotal
        string proofText = icdProofTotal < 6 ? "Building (" + str.tostring(icdProofTotal) + ")" : str.tostring(math.round(icdProofRate)) + "% (" + str.tostring(icdProofTotal) + ")"
        color proofCol = icdProofTotal < 6 ? pLabel : icdProofRate >= 55 ? bullColor : icdProofRate >= 45 ? neutralColor : bearColor

        f_panel_row(panel, 1, "Candle Type", panelTypeText, panelTypeCol, pBg, pLabel, panelFontSize)
        f_panel_row(panel, 2, "Efficiency", panelEfficiencyText, panelActionCol, pBg, pLabel, panelFontSize)
        f_panel_row(panel, 3, "Follow-Through", panelFollowText, panelActionCol, pBg, pLabel, panelFontSize)
        f_panel_row(panel, 4, "Failure Risk", panelRiskText, panelRiskText == "0" ? pValue : panelActionCol, pBg, pLabel, panelFontSize)
        f_panel_row(panel, 5, "Action", panelActionText, panelActionCol, pBg, pLabel, panelFontSize)
        f_panel_row(panel, 6, "Proof", proofText, proofCol, pBg, pLabel, panelFontSize)

        if showRecentBlock
            table.cell(panel, 0, 7, "Recent Events", text_color = accentColor, bgcolor = pBg, text_size = f_label_size(panelFontSize), text_halign = text.align_left)
            table.cell(panel, 1, 7, "Outcome", text_color = accentColor, bgcolor = pBg, text_size = f_label_size(panelFontSize), text_halign = text.align_right)
            int eventCount = array.size(eventBars)
            int visibleRecent = math.min(3, eventCount)
            int r = 0
            while r < visibleRecent
                int idx = eventCount - 1 - r
                int cls = array.get(eventClasses, idx)
                int dir = array.get(eventDirs, idx)
                int res = array.get(eventResults, idx)
                int barsAgo = bar_index - array.get(eventBars, idx)
                string leftText = str.tostring(barsAgo) + "b " + f_class_short(cls)
                string rightText = f_result_text(res)
                color leftCol = f_event_color(cls, dir)
                color rightCol = res == 1 ? bullColor : res == -1 ? bearColor : res == 2 ? neutralColor : pValue
                table.cell(panel, 0, 8 + r, leftText, text_color = leftCol, bgcolor = pBg, text_size = f_label_size(panelFontSize), text_halign = text.align_left)
                table.cell(panel, 1, 8 + r, rightText, text_color = rightCol, bgcolor = pBg, text_size = f_label_size(panelFontSize), text_halign = text.align_right)
                r := r + 1
            while r < 3
                table.cell(panel, 0, 8 + r, "-", text_color = pLabel, bgcolor = pBg, text_size = f_label_size(panelFontSize), text_halign = text.align_left)
                table.cell(panel, 1, 8 + r, "-", text_color = pLabel, bgcolor = pBg, text_size = f_label_size(panelFontSize), text_halign = text.align_right)
                r := r + 1

// -------------------------------------------------
// Alerts
// -------------------------------------------------
alertcondition(alertReady and readyEvent, title = "Institutional Candle READY", message = "Institutional Candle Detector: a qualified institutional candle entered READY state. Review efficiency, follow-through corridor and invalidation shelf. This is an attention marker, not a trade instruction.")
alertcondition(alertRisk and riskReviewEvent, title = "Institutional Candle Failure Risk", message = "Institutional Candle Detector: failure risk reached the review threshold. Check the active invalidation shelf before acting.")
alertcondition(alertInvalid and invalidationEvent, title = "Institutional Candle Invalidated", message = "Institutional Candle Detector: price crossed the active invalidation shelf for a tracked institutional candle.")
alertcondition(alertOutcome and finalOutcomeEvent, title = "Institutional Candle Outcome", message = "Institutional Candle Detector: a tracked institutional candle reached a final follow-through, invalidation or consolidation outcome.")
````
