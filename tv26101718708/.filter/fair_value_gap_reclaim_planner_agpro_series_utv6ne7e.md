# Fair Value Gap Reclaim Planner [AGPro Series]

- url: https://www.tradingview.com/script/utV6NE7e-Fair-Value-Gap-Reclaim-Planner-AGPro-Series/
- type: indicator
- pine_id: PUB;d45d60a7f9264984858029c9b6bd7f07
- version: 4.0

## Description

Fair Value Gap Reclaim Planner [AGPro Series]

🧠 Core Idea

Has price returned into a fair value gap and reclaimed the imbalance midpoint with enough quality?


📌 Overview / What it does

Fair Value Gap Reclaim Planner is an imbalance-focused price action tool built around three-candle fair value gap structure.

The script detects bullish and bearish FVG zones, tracks fill progress, maps the midpoint, evaluates reclaim quality, and displays a structured 0-100 readiness score. It also projects an active reclaim corridor, invalidation shelf, target rails, labels, and a clean AG Pro dashboard.

It does not predict future price movement, automate entries, or provide guaranteed signals. It is a visual framework for reading fair value gap reclaim behavior.


🎯 Purpose & Design Philosophy

This script was built for traders who study imbalance zones but want a cleaner way to separate meaningful reclaim behavior from ordinary gap interaction.

Fair value gaps can attract attention, but not every touch matters. The planner focuses on whether price fills, reacts, and reclaims a meaningful reference level inside the imbalance.

The design supports patient analysis: identify the zone, measure the fill, wait for reclaim, then evaluate context.


⚡ Why This Script Is Different

Most FVG tools highlight many imbalance zones and leave the user to interpret the rest manually.

This script does NOT flood the chart with every historical imbalance.

Instead, it focuses on the active FVG context, tracks fill progress, evaluates midpoint or full-edge reclaim, and converts the reaction into a clear score and action state.


⚙️ Methodology

1. Context Detection

The script detects bullish and bearish three-candle fair value gaps using a minimum ATR-based size filter.

2. Reference Mapping

It maps the FVG top, bottom, midpoint, fill area, and invalidation boundary.

3. Reaction Evaluation

When price interacts with the active FVG, the script evaluates fill progress, reclaim distance, wick response, body quality, relative volume, gap quality, and freshness.

4. Visual Output

Qualified reclaim events are shown with labels, projected zones, target rails, right-side level tags, and a compact panel.


🗺️ How to Read the Chart

FVG Zone shows the active imbalance area.

Midline marks the primary reclaim reference when Midline mode is selected.

Fill Progress shows how deeply price has returned into the imbalance.

READY FVG RECLAIM labels mark reclaim events that meet the selected score threshold.

Invalidation Shelf marks the area where the reclaim context weakens or fails.

The AG Pro panel summarizes Gap State, Reclaim Score, Fill Progress, Risk, and Action.


🚦 Signals & States

• BULL FVG → bullish fair value gap detected and locked.

• BEAR FVG → bearish fair value gap detected and locked.

• READY FVG RECLAIM → price reclaimed the selected FVG reference with enough quality.

• FVG TOUCH → price interacted with the active FVG zone.

• INVALIDATED → the active reclaim context lost the opposite FVG edge.

• READY → a qualified reclaim event is active.

• MONITOR → the active FVG is being tested or a reclaim context remains open.

• WAIT → no qualified reclaim event is active.


🔔 Alerts Logic

Bullish FVG Reclaim Ready triggers when price reclaims the selected FVG reference upward with enough score quality.

Bearish FVG Reclaim Ready triggers when price reclaims the selected FVG reference downward with enough score quality.

FVG Touch triggers when price interacts with the active imbalance zone.

FVG Reclaim Invalidated triggers when the active reclaim context loses the opposite FVG edge.

Alerts are attention markers, not trade instructions.


🧩 Confluence Logic

The strongest reclaim contexts appear when fill progress, wick response, close quality, relative volume, gap size, and freshness align.

When price returns into the imbalance, respects the zone, and reclaims the midpoint or edge with clean reaction quality, the score improves.


📊 When to Use

• Markets with visible imbalance behavior

• Breakout pullbacks into fair value gaps

• Trend continuation reviews

• Reclaim attempts after partial FVG fills

• Intraday or swing contexts where FVG zones remain meaningful


⚠️ When NOT to Use

• Very low liquidity markets

• Extremely noisy or illiquid symbols

• Markets with unreliable candles or volume

• Wide-spread conditions where small gaps are misleading

• News spikes where imbalance zones can be invalidated quickly


🎛️ Key Inputs

• Minimum FVG Size ATR → filters out tiny imbalance zones.

• Maximum FVG Age Bars → controls how long an FVG can remain active.

• Reclaim Reference → chooses midpoint reclaim or full-edge reclaim.

• Touch Lookback Bars → controls how recent the FVG interaction must be.

• Invalidation Buffer ATR → controls the risk shelf beyond the FVG edge.

• Minimum Ready Score → sets how strict READY events should be.

• Target Rails → control projected T1 and T2 levels.

• Label Settings → control label density, size, and spacing.

• Panel Settings → control panel visibility, location, theme, and font size.


🖥️ Interface & Visual Design

The interface is designed to show the active imbalance context without filling the chart with excessive historical zones.

The FVG zone, midline, fill meter, invalidation shelf, target rails, and panel are visually separated so the chart remains readable.

The goal is a premium first-glance layout: zone first, reclaim second, action state third.


🧪 Practical Usage Workflow

1. Check the panel for active Gap State.

2. Locate the FVG zone and midpoint.

3. Watch how deeply price fills the imbalance.

4. Evaluate READY FVG RECLAIM labels and score quality.

5. Compare price with the invalidation shelf and target rails.

6. Confirm broader structure before making decisions.


🔍 Interpretation Guidelines

A high reclaim score means the reaction is cleaner according to the script's rules.

A lower score means the reclaim may be weaker, late, noisy, or incomplete.

Fill progress is not a signal by itself. It becomes more meaningful when combined with reclaim quality and broader market context.


🚫 What This Script Is NOT

This script is not a prediction engine.

It is not financial advice.

It is not an automated trading system.

It does not guarantee entries, exits, profits, or outcomes.


⚠️ Limitations & Transparency

Fair value gap interpretation can vary across markets, sessions, and timeframes.

Some markets create many small gaps that may not carry meaningful context.

Volatility changes can make an active FVG less relevant over time.

No rule-based script can fully account for news, liquidity shocks, or sudden market structure shifts.


🧠 Market Context Notes

Fair value gaps often represent fast price displacement and temporary imbalance.

The reclaim of a midpoint or edge can help traders study whether the market is accepting or rejecting the imbalance area.

The script works best when combined with structure, liquidity, volatility, and trend context.


🧾 Use Case Examples

When a bullish FVG forms after displacement, price returns into the zone, partially fills it, and then reclaims the midpoint, the script may mark a bullish reclaim context.

When a bearish FVG forms after downside displacement, price retraces into the imbalance and then rejects back below the midpoint, the script may mark a bearish reclaim context.


🧱 System Philosophy

Fair Value Gap Reclaim Planner follows the AG Pro Series approach: turn a popular market concept into a structured decision map with context, score, risk reference, and clean visuals.

It is designed to support judgment, not replace it.


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

This script is designed to help traders study how fair value gap fills, midpoint reclaims, and imbalance reactions behave across different market conditions.

## Source Code

````pine
// -------------------------------------------------
// Fair Value Gap Reclaim Planner [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 1.7
//
// Fair Value Gap Reclaim Planner is an imbalance-focused decision engine
// that detects three-candle FVG zones, tracks fill progress, evaluates
// midpoint reclaim quality, and maps active reclaim context with a clean
// 0-100 score, risk shelf, target rails, labels, and AG Pro panel. A live
// Reclaim Hit Rate logs how often a qualified reclaim reaches a balanced
// one-risk target before its own invalidation, creating a confirmed-bar
// evidence record for the setup quality.
// -------------------------------------------------

//@version=6
indicator("Fair Value Gap Reclaim Planner [AGPro Series]",
     shorttitle = "AG Pro FVG",
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
darkText      = color.rgb(17, 24, 39)

// -------------------------------------------------
// Helpers
// -------------------------------------------------
f_clamp(_v, _lo, _hi) =>
    math.max(_lo, math.min(_v, _hi))

f_text_on(color _bg) =>
    bright = (color.r(_bg) * 299 + color.g(_bg) * 587 + color.b(_bg) * 114) / 1000
    bright >= 145 ? darkText : headerText

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
     _p == "Top Center" ? position.top_center :
     _p == "Top Left" ? position.top_left :
     _p == "Middle Right" ? position.middle_right :
     _p == "Middle Center" ? position.middle_center :
     _p == "Middle Left" ? position.middle_left :
     _p == "Bottom Right" ? position.bottom_right :
     _p == "Bottom Center" ? position.bottom_center : position.bottom_left

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

f_action_textcol(_action) =>
    base = _action == "READY" ? bullColor :
     _action == "MONITOR" ? accentColor :
     _action == "WAIT" ? neutralColor :
     _action == "INVALIDATED" ? bearColor :
     _action == "EXPIRED" ? panelBorder :
     _action == "BLOCKED" ? panelBorder : panelBg
    f_text_on(base)

// -------------------------------------------------
// Inputs
// -------------------------------------------------
G_FVG    = "FVG Engine"
G_SCORE  = "Reclaim Engine"
G_VISUAL = "Visuals"
G_PANEL  = "Panel"
G_ALERTS = "Alerts"

atrLength = input.int(14, "ATR Length", minval = 2, maxval = 200, group = G_FVG,
     tooltip = "ATR normalizes minimum FVG size, reclaim buffers, invalidation shelves, target rails, and label spacing.")
minFvgAtr = input.float(0.12, "Minimum FVG Size ATR", minval = 0.01, maxval = 5.00, step = 0.01, group = G_FVG,
     tooltip = "Minimum imbalance size required before a three-candle fair value gap is accepted.")
maxFvgAgeBars = input.int(240, "Maximum FVG Age Bars", minval = 20, maxval = 2000, group = G_FVG,
     tooltip = "Maximum number of bars an active FVG can remain relevant before it expires.")
preferFreshFvg = input.bool(true, "Prefer Fresh FVG", group = G_FVG,
     tooltip = "When enabled, a new valid FVG replaces the previous active FVG. This keeps the chart focused on the freshest imbalance context.")
minVolume = input.float(0.0, "Minimum Volume Filter", minval = 0.0, maxval = 1000000000.0, step = 1.0, group = G_FVG,
     tooltip = "Optional minimum bar volume filter. Keep at 0 to disable.")

confirmationMode = input.string("Balanced", "Confirmation Mode", options = ["Fast", "Balanced", "Strict"], group = G_SCORE,
     tooltip = "Fast reacts earlier, Balanced requires cleaner reclaim quality, and Strict demands stronger acceptance.")
minReadyScore = input.int(64, "Minimum Ready Score", minval = 1, maxval = 100, group = G_SCORE,
     tooltip = "Minimum 0-100 reclaim score required before READY appears.")
reclaimMode = input.string("Midline", "Reclaim Reference", options = ["Midline", "Full Edge"], group = G_SCORE,
     tooltip = "Midline accepts reclaim through the FVG midpoint. Full Edge requires reclaim beyond the outer edge of the imbalance.")
touchLookback = input.int(36, "Touch Lookback Bars", minval = 2, maxval = 500, group = G_SCORE,
     tooltip = "How recently price must have interacted with the active FVG before reclaim can be scored.")
invalidationAtr = input.float(0.18, "Invalidation Buffer ATR", minval = 0.01, maxval = 5.00, step = 0.01, group = G_SCORE,
     tooltip = "ATR-based buffer beyond the opposite FVG edge where the active reclaim context is considered invalidated.")
targetOneAtr = input.float(0.85, "Target 1 ATR", minval = 0.10, maxval = 20.0, step = 0.05, group = G_SCORE,
     tooltip = "First projected target from the reclaim reference after a qualified reclaim.")
targetTwoAtr = input.float(1.55, "Target 2 ATR", minval = 0.10, maxval = 30.0, step = 0.05, group = G_SCORE,
     tooltip = "Second projected target from the reclaim reference after a qualified reclaim.")
reclaimWindowBars = input.int(90, "Reclaim Window Bars", minval = 5, maxval = 600, group = G_SCORE,
     tooltip = "Maximum number of bars after reclaim during which the reclaim context remains active.")
proofWindowBars = input.int(40, "Reclaim Proof Window Bars", minval = 10, maxval = 300, group = G_SCORE,
     tooltip = "Bars allowed for a qualified reclaim to reach its one-risk target or invalidation before the sample is left unresolved (uncounted) in the Reclaim Hit Rate.")
useVolumeScore = input.bool(true, "Use Relative Volume In Score", group = G_SCORE,
     tooltip = "Adds relative volume participation to reclaim score.")
volumeLength = input.int(20, "Relative Volume Length", minval = 2, maxval = 200, group = G_SCORE,
     tooltip = "Lookback used to compare current volume against recent average participation.")

showFvgZone = input.bool(true, "Show FVG Zone", group = G_VISUAL,
     tooltip = "Shows the active fair value gap as an extended imbalance zone.")
showZoneBadge = input.bool(true, "Show Zone Center Badge", group = G_VISUAL,
     tooltip = "Shows a contrast-safe centered badge inside the active FVG zone for dark and light chart readability.")
showMidline = input.bool(true, "Show Midline", group = G_VISUAL,
     tooltip = "Shows the midpoint of the active FVG. This is the default reclaim reference.")
showFillMeter = input.bool(true, "Show Fill Progress", group = G_VISUAL,
     tooltip = "Shows the current fill progress inside the FVG zone.")
showInvalidationShelf = input.bool(true, "Show Invalidation Shelf", group = G_VISUAL,
     tooltip = "Shows the risk shelf beyond the opposite FVG edge.")
showTargetRails = input.bool(true, "Show Target Rails", group = G_VISUAL,
     tooltip = "Shows T1 and T2 reference rails after a qualified reclaim.")
showEventLabels = input.bool(true, "Show Event Labels", group = G_VISUAL,
     tooltip = "Displays FVG, reclaim, and invalidation labels on the chart.")
showNewFvgLabels = input.bool(true, "Show New FVG Labels", group = G_VISUAL,
     tooltip = "Displays labels when a new FVG is locked.")
showTouchLabels = input.bool(false, "Show Touch Labels", group = G_VISUAL,
     tooltip = "Displays optional touch labels when price first interacts with the FVG. Disabled by default to keep the chart clean.")
showInvalidLabels = input.bool(false, "Show Invalidated Labels", group = G_VISUAL,
     tooltip = "Displays labels when an active reclaim context is invalidated. Disabled by default to keep higher-timeframe charts clean.")
showRightTags = input.bool(true, "Show Right-Side Tags", group = G_VISUAL,
     tooltip = "Displays filled price-bearing owner badges for FVG boundaries, invalidation, and active target rails.")
projectionBarsInput = input.int(70, "Projection Bars", minval = 10, maxval = 300, group = G_VISUAL,
     tooltip = "How far active zones and rails project into the future.")
maxEventLabels = input.int(5, "Maximum Event Labels", minval = 0, maxval = 80, group = G_VISUAL,
     tooltip = "Limits historical labels so the chart remains readable.")
labelCooldownBars = input.int(34, "Label Cooldown Bars", minval = 1, maxval = 300, group = G_VISUAL,
     tooltip = "Minimum bars between repeated labels of the same type.")
labelOffsetAtr = input.float(0.38, "Label Offset ATR", minval = 0.05, maxval = 5.00, step = 0.05, group = G_VISUAL,
     tooltip = "Vertical distance between labels and candles.")
labelSizeInput = input.string("Normal", "Label Font Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = G_VISUAL,
     tooltip = "Controls chart label font size.")
showBarColors = input.bool(false, "Color Bars By State", group = G_VISUAL,
     tooltip = "Optionally colors bars according to active FVG reclaim state.")

showPanel = input.bool(true, "Show Panel", group = G_PANEL,
     tooltip = "Shows or hides the AG Pro dashboard.")
panelPositionInput = input.string("Top Right", "Panel Location",
     options = ["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"],
     group = G_PANEL,
     tooltip = "Controls where the panel appears on the chart.")
panelTheme = input.string("Dark", "Panel Theme", options = ["Dark", "Light"], group = G_PANEL,
     tooltip = "Controls panel color theme.")
panelFontSizeInput = input.string("Normal", "Panel Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = G_PANEL,
     tooltip = "Controls panel text size.")

alertReady = input.bool(true, "Alert: FVG Reclaim Ready", group = G_ALERTS,
     tooltip = "Enables alerts when a bullish or bearish FVG reclaim reaches the ready threshold.")
alertTouch = input.bool(true, "Alert: FVG Touch", group = G_ALERTS,
     tooltip = "Enables alerts when price interacts with the active FVG zone.")
alertInvalidated = input.bool(true, "Alert: FVG Invalidated", group = G_ALERTS,
     tooltip = "Enables alerts when an active FVG reclaim is invalidated.")
alertNewFvg = input.bool(false, "Alert: New FVG Locked", group = G_ALERTS,
     tooltip = "Enables alerts when a new valid FVG is detected and locked.")

// -------------------------------------------------
// Core calculations
// -------------------------------------------------
labelSize = f_size(labelSizeInput)
panelSize = f_table_size(panelFontSizeInput)
atr = math.max(nz(ta.atr(atrLength), ta.tr(true)), syminfo.mintick)
volAvg = ta.sma(volume, volumeLength)
rvol = volAvg > 0 ? volume / volAvg : 1.0
volumeOk = minVolume <= 0 or volume >= minVolume

gapMin = atr * minFvgAtr
bullFvgRaw = bar_index >= 2 and low > high[2]
bearFvgRaw = bar_index >= 2 and high < low[2]
bullFvgSize = bullFvgRaw ? low - high[2] : 0.0
bearFvgSize = bearFvgRaw ? low[2] - high : 0.0
bullFvg = bullFvgRaw and bullFvgSize >= gapMin and volumeOk
bearFvg = bearFvgRaw and bearFvgSize >= gapMin and volumeOk
newFvgDir = bullFvg ? 1 : bearFvg ? -1 : 0
newFvgTop = bullFvg ? low : bearFvg ? low[2] : na
newFvgBottom = bullFvg ? high[2] : bearFvg ? high : na
newFvgMid = not na(newFvgTop) and not na(newFvgBottom) ? (newFvgTop + newFvgBottom) * 0.5 : na

var int activeDir = 0
var int fvgBar = na
var float fvgTop = na
var float fvgBottom = na
var float fvgMid = na
var float fvgAtr = na
var float fvgScoreSeed = na
var bool hasActiveFvg = false
var int reclaimBar = na
var float reclaimScore = na
var bool activeReclaim = false
var float maxFillProgress = 0.0
var float lockedT1 = na
var float lockedT2 = na
var int lastFvgLabelBar = na
var int lastTouchLabelBar = na
var int lastReadyLabelBar = na
var int lastInvalidLabelBar = na

confirmedBar = barstate.isconfirmed
newFvgAccepted = confirmedBar and newFvgDir != 0 and (preferFreshFvg or not hasActiveFvg)
if newFvgAccepted
    activeDir := newFvgDir
    fvgBar := bar_index - 1
    fvgTop := newFvgTop
    fvgBottom := newFvgBottom
    fvgMid := newFvgMid
    fvgAtr := atr
    fvgScoreSeed := f_clamp((math.abs(newFvgTop - newFvgBottom) / math.max(atr, syminfo.mintick)) / 0.65, 0.0, 1.0) * 100.0
    hasActiveFvg := true
    activeReclaim := false
    reclaimBar := na
    reclaimScore := na
    maxFillProgress := 0.0
    lockedT1 := na
    lockedT2 := na

fvgAge = hasActiveFvg and not na(fvgBar) ? bar_index - fvgBar : na
fvgExpired = hasActiveFvg and not na(fvgAge) and fvgAge > maxFvgAgeBars
if fvgExpired
    hasActiveFvg := false
    activeReclaim := false

zoneSize = hasActiveFvg ? math.max(fvgTop - fvgBottom, syminfo.mintick) : na
narrowZone = hasActiveFvg and not na(zoneSize) and zoneSize <= atr * 0.80
enteredZone = hasActiveFvg and high >= fvgBottom and low <= fvgTop
touchEvent = confirmedBar and enteredZone and not enteredZone[1]
barsSinceTouch = ta.barssince(enteredZone)
touchRecent = not na(barsSinceTouch) and barsSinceTouch <= touchLookback

fillProgress = hasActiveFvg ? activeDir == 1 ?
     f_clamp((fvgTop - low) / zoneSize, 0.0, 1.0) * 100.0 :
     f_clamp((high - fvgBottom) / zoneSize, 0.0, 1.0) * 100.0 : na
if hasActiveFvg and not na(fillProgress)
    maxFillProgress := math.max(maxFillProgress, fillProgress)
lifecycleFillProgress = hasActiveFvg ? maxFillProgress : na
balancedFill = hasActiveFvg ? 100.0 - math.abs(nz(fillProgress, 0.0) - 50.0) : na

reclaimRef = reclaimMode == "Midline" ? fvgMid : activeDir == 1 ? fvgTop : fvgBottom
bullReclaim = hasActiveFvg and activeDir == 1 and touchRecent and close > reclaimRef and close[1] <= reclaimRef
bearReclaim = hasActiveFvg and activeDir == -1 and touchRecent and close < reclaimRef and close[1] >= reclaimRef
reclaimEvent = bullReclaim or bearReclaim

rangeSize = math.max(high - low, syminfo.mintick)
closeDistance = hasActiveFvg ? activeDir == 1 ? (close - reclaimRef) / math.max(atr, syminfo.mintick) : (reclaimRef - close) / math.max(atr, syminfo.mintick) : 0.0
wickResponse = hasActiveFvg ? activeDir == 1 ? (math.min(open, close) - low) / rangeSize : (high - math.max(open, close)) / rangeSize : 0.0
bodyRatio = math.abs(close - open) / rangeSize
freshness = hasActiveFvg and not na(fvgAge) ? f_clamp(1.0 - fvgAge / math.max(maxFvgAgeBars, 1), 0.0, 1.0) : 0.0
fillScore = f_clamp(nz(balancedFill, 0.0) / 100.0, 0.0, 1.0) * 18.0
closeScore = f_clamp(closeDistance / 0.65, 0.0, 1.0) * 22.0
wickScore = f_clamp(wickResponse / 0.55, 0.0, 1.0) * 17.0
bodyScore = f_clamp(bodyRatio / 0.62, 0.0, 1.0) * 12.0
gapScore = f_clamp(nz(fvgScoreSeed, 0.0) / 100.0, 0.0, 1.0) * 14.0
freshScore = freshness * 7.0
volumeScore = useVolumeScore ? f_clamp(rvol / 1.6, 0.0, 1.0) * 10.0 : 7.0
candidateScore = f_clamp(closeScore + wickScore + bodyScore + fillScore + gapScore + freshScore + volumeScore, 0.0, 100.0)
confirmBonus = confirmationMode == "Fast" ? 5.0 : confirmationMode == "Balanced" ? 0.0 : -8.0
requiredScore = f_clamp(minReadyScore - confirmBonus, 1.0, 100.0)
readyEvent = confirmedBar and reclaimEvent and candidateScore >= requiredScore and not activeReclaim

if readyEvent
    activeReclaim := true
    reclaimBar := bar_index
    reclaimScore := candidateScore
    lockedT1 := reclaimRef + activeDir * atr * targetOneAtr
    lockedT2 := reclaimRef + activeDir * atr * targetTwoAtr

barsFromReclaim = activeReclaim and not na(reclaimBar) ? bar_index - reclaimBar : na
withinReclaimWindow = activeReclaim and not na(barsFromReclaim) and barsFromReclaim <= reclaimWindowBars
invalidLine = hasActiveFvg ? activeDir == 1 ? fvgBottom - fvgAtr * invalidationAtr : fvgTop + fvgAtr * invalidationAtr : na
invalidatedEvent = confirmedBar and hasActiveFvg and ((activeDir == 1 and close < invalidLine) or (activeDir == -1 and close > invalidLine))
resetFvgAfterRender = invalidatedEvent
if invalidatedEvent
    activeReclaim := false

reclaimExpired = activeReclaim and not withinReclaimWindow
if reclaimExpired
    activeReclaim := false

// -------------------------------------------------
// Reclaim-Hit-Rate Proof
// On a qualified READY reclaim, a win is recorded when price reaches one
// risk-distance in the reclaim direction (a balanced one-risk target) before
// closing beyond the FVG invalidation line (the script's own stop). Samples
// that resolve neither inside the proof window are left unresolved and
// uncounted. Updated only on confirmed bars so the evidence record is based
// on closed candles.
// -------------------------------------------------
var int   proofWins    = 0
var int   proofTotal   = 0
var bool  proofPending = false
var int   proofDir     = 0
var float proofTarget  = na
var float proofStop    = na
var int   proofStartBar = na

if barstate.isconfirmed
    if proofPending
        favHit  = proofDir == 1 ? high >= proofTarget : low <= proofTarget
        stopHit = proofDir == 1 ? close < proofStop : close > proofStop
        expired = bar_index - proofStartBar >= proofWindowBars
        if favHit and stopHit
            proofTotal += 1
            proofPending := false
        else if favHit
            proofWins += 1
            proofTotal += 1
            proofPending := false
        else if stopHit
            proofTotal += 1
            proofPending := false
        else if expired
            proofPending := false
    if readyEvent and not na(invalidLine)
        riskDist = math.max(math.abs(close - invalidLine), atr * 0.10)
        proofDir := activeDir
        proofTarget := close + activeDir * riskDist
        proofStop := invalidLine
        proofStartBar := bar_index
        proofPending := true

proofRate = proofTotal > 0 ? proofWins / proofTotal * 100.0 : na

t1 = activeReclaim ? lockedT1 : na
t2 = activeReclaim ? lockedT2 : na
roomToT1 = withinReclaimWindow and not na(t1) ? activeDir == 1 ?
     f_clamp((t1 - close) / math.max(t1 - reclaimRef, syminfo.mintick), 0.0, 1.5) :
     f_clamp((close - t1) / math.max(reclaimRef - t1, syminfo.mintick), 0.0, 1.5) : na
riskScore = hasActiveFvg ? f_clamp((100.0 - nz(reclaimScore, candidateScore)) * 0.22 + (nz(fillProgress, 0.0) > 88 ? 22.0 : 0.0) + (invalidatedEvent ? 50.0 : 0.0), 0.0, 100.0) : na

var string actionState = "WAIT"
var string actionText = "Wait for valid FVG"
var string gapState = "No Active FVG"
var string fillText = "n/a"
var string riskText = "n/a"
var float panelScore = na

if not hasActiveFvg
    actionState := "WAIT"
    actionText := "Wait for valid FVG"
    gapState := "No Active FVG"
    fillText := "n/a"
    riskText := "n/a"
    panelScore := na
else if readyEvent
    actionState := "READY"
    actionText := "Review qualified reclaim"
    gapState := activeDir == 1 ? "Bull FVG Reclaimed" : "Bear FVG Reclaimed"
    fillText := str.tostring(math.round(nz(lifecycleFillProgress, 0.0))) + "%"
    riskText := str.tostring(math.round(nz(riskScore, 0.0))) + "/100"
    panelScore := candidateScore
else if invalidatedEvent
    actionState := "INVALIDATED"
    actionText := "Stand down from reclaim"
    gapState := "FVG Invalidated"
    fillText := str.tostring(math.round(nz(lifecycleFillProgress, 0.0))) + "%"
    riskText := "100/100"
    panelScore := reclaimScore
else if withinReclaimWindow
    actionState := "MONITOR"
    actionText := "Track active reclaim"
    gapState := activeDir == 1 ? "Bull Reclaim Active" : "Bear Reclaim Active"
    fillText := str.tostring(math.round(nz(lifecycleFillProgress, 0.0))) + "%"
    riskText := str.tostring(math.round(nz(riskScore, 0.0))) + "/100"
    panelScore := reclaimScore
else if enteredZone
    actionState := "MONITOR"
    actionText := "Test in progress"
    gapState := "FVG Testing"
    fillText := str.tostring(math.round(nz(lifecycleFillProgress, 0.0))) + "%"
    riskText := str.tostring(math.round(nz(riskScore, 0.0))) + "/100"
    panelScore := candidateScore
else
    actionState := "WAIT"
    actionText := "Wait for gap return"
    gapState := activeDir == 1 ? "Bull FVG Active" : "Bear FVG Active"
    fillText := str.tostring(math.round(nz(lifecycleFillProgress, 0.0))) + "%"
    riskText := str.tostring(math.round(nz(riskScore, 0.0))) + "/100"
    panelScore := candidateScore

// -------------------------------------------------
// Visuals
// -------------------------------------------------
var box fvgBox = na
var box fillBox = na
var box invalidBox = na
var line midLine = na
var line t1Line = na
var line t2Line = na
var label tagTop = na
var label tagMid = na
var label tagBottom = na
var label tagInvalid = na
var label tagT1 = na
var label tagT2 = na
var label fvgZoneBadge = na
var label[] eventLabels = array.new_label()

projectionBars = timeframe.ismonthly ? math.min(projectionBarsInput, 18) : timeframe.isweekly ? math.min(projectionBarsInput, 30) : projectionBarsInput
rightX = bar_index + projectionBars
zoneColor = activeDir == 1 ? bullColor : activeDir == -1 ? bearColor : accentColor

if showFvgZone and hasActiveFvg and not na(fvgTop) and not na(fvgBottom)
    if na(fvgBox)
        fvgBox := box.new(fvgBar, fvgTop, rightX, fvgBottom,
             bgcolor = color.new(zoneColor, 91),
             border_color = color.new(zoneColor, 34),
             border_width = 1)
    else
        box.set_lefttop(fvgBox, fvgBar, fvgTop)
        box.set_rightbottom(fvgBox, rightX, fvgBottom)
        box.set_bgcolor(fvgBox, color.new(zoneColor, 91))
        box.set_border_color(fvgBox, color.new(zoneColor, 34))
    if showZoneBadge and not narrowZone
        int zoneBadgeX = int(math.round((fvgBar + rightX) * 0.5))
        float zoneBadgeY = (fvgTop + fvgBottom) * 0.5
        string reclaimRefText = reclaimMode == "Midline" ? "MID RECLAIM" : "EDGE RECLAIM"
        string zoneBadgeText = (activeDir == 1 ? "BULL FVG" : "BEAR FVG") + "\n" + reclaimRefText + " | FILL " + str.tostring(math.round(nz(lifecycleFillProgress, 0.0))) + "%"
        color badgeBg = activeDir == 1 ? bullColor : bearColor
        if na(fvgZoneBadge)
            fvgZoneBadge := label.new(zoneBadgeX, zoneBadgeY, zoneBadgeText,
                 style = label.style_label_center,
                 textcolor = f_text_on(badgeBg),
                 color = color.new(badgeBg, 0),
                 size = labelSize)
        else
            label.set_xy(fvgZoneBadge, zoneBadgeX, zoneBadgeY)
            label.set_text(fvgZoneBadge, zoneBadgeText)
            label.set_textcolor(fvgZoneBadge, f_text_on(badgeBg))
            label.set_color(fvgZoneBadge, color.new(badgeBg, 0))
            label.set_size(fvgZoneBadge, labelSize)
    else if not na(fvgZoneBadge)
        label.delete(fvgZoneBadge)
        fvgZoneBadge := na
else
    if not na(fvgBox)
        box.delete(fvgBox)
        fvgBox := na
    if not na(fvgZoneBadge)
        label.delete(fvgZoneBadge)
        fvgZoneBadge := na

fillLevel = hasActiveFvg ? activeDir == 1 ? fvgTop - zoneSize * f_clamp(nz(lifecycleFillProgress, 0.0) / 100.0, 0.0, 1.0) :
     fvgBottom + zoneSize * f_clamp(nz(lifecycleFillProgress, 0.0) / 100.0, 0.0, 1.0) : na
fillTop = activeDir == 1 ? fvgTop : fillLevel
fillBottom = activeDir == 1 ? fillLevel : fvgBottom
if showFillMeter and hasActiveFvg and not na(fillLevel)
    if na(fillBox)
        fillBox := box.new(fvgBar, fillTop, rightX, fillBottom,
             bgcolor = color.new(neutralColor, 88),
             border_color = color.new(neutralColor, 48),
             border_width = 1)
    else
        box.set_lefttop(fillBox, fvgBar, fillTop)
        box.set_rightbottom(fillBox, rightX, fillBottom)
else
    if not na(fillBox)
        box.delete(fillBox)
        fillBox := na

if showMidline and hasActiveFvg and not na(fvgMid)
    if na(midLine)
        midLine := line.new(fvgBar, fvgMid, rightX, fvgMid,
             color = color.new(accentColor, 10),
             width = 1,
             style = line.style_dotted)
    else
        line.set_xy1(midLine, fvgBar, fvgMid)
        line.set_xy2(midLine, rightX, fvgMid)
else
    if not na(midLine)
        line.delete(midLine)
        midLine := na

invalidTop = activeDir == 1 ? fvgBottom : invalidLine
invalidBottom = activeDir == 1 ? invalidLine : fvgTop
if showInvalidationShelf and hasActiveFvg and not na(invalidTop) and not na(invalidBottom)
    if na(invalidBox)
        invalidBox := box.new(fvgBar, invalidTop, rightX, invalidBottom,
             bgcolor = color.new(bearColor, 94),
             border_color = color.new(bearColor, 48),
             border_width = 1)
    else
        box.set_lefttop(invalidBox, fvgBar, invalidTop)
        box.set_rightbottom(invalidBox, rightX, invalidBottom)
else
    if not na(invalidBox)
        box.delete(invalidBox)
        invalidBox := na

if showTargetRails and withinReclaimWindow and not na(t1) and not na(t2)
    if na(t1Line)
        t1Line := line.new(reclaimBar, t1, rightX, t1, color = color.new(neutralColor, 8), width = 1, style = line.style_dashed)
    else
        line.set_xy1(t1Line, reclaimBar, t1)
        line.set_xy2(t1Line, rightX, t1)
    if na(t2Line)
        t2Line := line.new(reclaimBar, t2, rightX, t2, color = color.new(accentColor, 10), width = 1, style = line.style_dashed)
    else
        line.set_xy1(t2Line, reclaimBar, t2)
        line.set_xy2(t2Line, rightX, t2)
else
    if not na(t1Line)
        line.delete(t1Line)
        t1Line := na
    if not na(t2Line)
        line.delete(t2Line)
        t2Line := na

canFvgLabel = na(lastFvgLabelBar) or bar_index - lastFvgLabelBar >= labelCooldownBars
canTouchLabel = na(lastTouchLabelBar) or bar_index - lastTouchLabelBar >= labelCooldownBars
canReadyLabel = na(lastReadyLabelBar) or bar_index - lastReadyLabelBar >= labelCooldownBars
canInvalidLabel = na(lastInvalidLabelBar) or bar_index - lastInvalidLabelBar >= labelCooldownBars

if showEventLabels and showNewFvgLabels and newFvgAccepted and canFvgLabel
    color fvgBg = activeDir == 1 ? bullColor : bearColor
    label fvgLabel = label.new(bar_index, activeDir == 1 ? low - atr * labelOffsetAtr : high + atr * labelOffsetAtr,
         activeDir == 1 ? "BULL FVG" : "BEAR FVG",
         style = activeDir == 1 ? label.style_label_up : label.style_label_down,
         textcolor = f_text_on(fvgBg),
         color = color.new(fvgBg, 0),
         size = labelSize)
    lastFvgLabelBar := bar_index
    array.push(eventLabels, fvgLabel)
    if array.size(eventLabels) > maxEventLabels
        label.delete(array.shift(eventLabels))

if showEventLabels and showTouchLabels and touchEvent and canTouchLabel
    label touchLabel = label.new(bar_index, activeDir == 1 ? low - atr * labelOffsetAtr : high + atr * labelOffsetAtr,
         "TOUCH | Fill " + str.tostring(math.round(nz(fillProgress, 0.0))) + "%",
         style = activeDir == 1 ? label.style_label_up : label.style_label_down,
         textcolor = f_text_on(neutralColor),
         color = color.new(neutralColor, 0),
         size = labelSize)
    lastTouchLabelBar := bar_index
    array.push(eventLabels, touchLabel)
    if array.size(eventLabels) > maxEventLabels
        label.delete(array.shift(eventLabels))

if showEventLabels and readyEvent and canReadyLabel
    color readyBg = activeDir == 1 ? bullColor : bearColor
    label readyLabel = label.new(bar_index, activeDir == 1 ? low - atr * labelOffsetAtr : high + atr * labelOffsetAtr,
         "READY | Q " + str.tostring(math.round(candidateScore)),
         style = activeDir == 1 ? label.style_label_up : label.style_label_down,
         textcolor = f_text_on(readyBg),
         color = color.new(readyBg, 0),
         size = labelSize)
    lastReadyLabelBar := bar_index
    array.push(eventLabels, readyLabel)
    if array.size(eventLabels) > maxEventLabels
        label.delete(array.shift(eventLabels))

if showEventLabels and showInvalidLabels and invalidatedEvent and canInvalidLabel
    label invalidLabel = label.new(bar_index, activeDir == 1 ? high + atr * labelOffsetAtr : low - atr * labelOffsetAtr,
         "INVALIDATED | Lost FVG edge",
         style = activeDir == 1 ? label.style_label_down : label.style_label_up,
         textcolor = f_text_on(bearColor),
         color = color.new(bearColor, 0),
         size = labelSize)
    lastInvalidLabelBar := bar_index
    array.push(eventLabels, invalidLabel)
    if array.size(eventLabels) > maxEventLabels
        label.delete(array.shift(eventLabels))

if barstate.islast and showRightTags and hasActiveFvg
    tagX = rightX + 2
    compactZoneTag = narrowZone
    ownerClearance = math.max(atr * 0.20, syminfo.mintick * 2.0)
    color fvgTagBg = activeDir == 1 ? bullColor : bearColor
    if not na(tagTop)
        label.delete(tagTop)
    if not na(tagMid)
        label.delete(tagMid)
    if not na(tagBottom)
        label.delete(tagBottom)
    if not na(tagInvalid)
        label.delete(tagInvalid)
    if not na(tagT1)
        label.delete(tagT1)
    if not na(tagT2)
        label.delete(tagT2)
    if compactZoneTag
        tagMid := label.new(tagX, fvgMid,
             (activeDir == 1 ? "BULL FVG | " : "BEAR FVG | ") + str.tostring(fvgMid, format.mintick),
             style = label.style_label_left,
             textcolor = f_text_on(fvgTagBg),
             color = color.new(fvgTagBg, 8),
             size = labelSize)
    else
        tagTop := label.new(tagX, fvgTop - ownerClearance,
             "FVG TOP  " + str.tostring(fvgTop, format.mintick),
             style = label.style_label_left,
             textcolor = f_text_on(fvgTagBg),
             color = color.new(fvgTagBg, 8),
             size = labelSize)
        tagBottom := label.new(tagX, fvgBottom + ownerClearance,
             "FVG BOTTOM  " + str.tostring(fvgBottom, format.mintick),
             style = label.style_label_left,
             textcolor = f_text_on(fvgTagBg),
             color = color.new(fvgTagBg, 8),
             size = labelSize)
    if showInvalidationShelf and not na(invalidLine)
        invalidTagY = activeDir == 1 ? invalidLine - ownerClearance : invalidLine + ownerClearance
        tagInvalid := label.new(tagX, invalidTagY,
             "INVALIDATION  " + str.tostring(invalidLine, format.mintick),
             style = label.style_label_left,
             textcolor = f_text_on(bearColor),
             color = color.new(bearColor, 8),
             size = labelSize)
    if withinReclaimWindow and not na(t1) and not na(t2)
        tagT1 := label.new(tagX, t1,
             "T1  " + str.tostring(t1, format.mintick),
             style = label.style_label_left,
             textcolor = f_text_on(neutralColor),
             color = color.new(neutralColor, 8),
             size = labelSize)
        tagT2 := label.new(tagX, t2,
             "T2  " + str.tostring(t2, format.mintick),
             style = label.style_label_left,
             textcolor = f_text_on(accentColor),
             color = color.new(accentColor, 8),
             size = labelSize)
else if barstate.islast
    if not na(tagTop)
        label.delete(tagTop)
        tagTop := na
    if not na(tagMid)
        label.delete(tagMid)
        tagMid := na
    if not na(tagBottom)
        label.delete(tagBottom)
        tagBottom := na
    if not na(tagInvalid)
        label.delete(tagInvalid)
        tagInvalid := na
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
scoreText = f_score_text(panelScore)
proofText = proofTotal > 0 ? str.tostring(math.round(nz(proofRate, 0.0))) + "% (" + str.tostring(proofTotal) + ")" : "Building"
proofCol = na(proofRate) ? panelLabelFinal : proofRate >= 55 ? bullColor : proofRate >= 45 ? neutralColor : bearColor

var table panel = table.new(position.top_right, 2, 7, border_width = 1)

if showPanel and barstate.islast
    table.set_position(panel, f_panel_position(panelPositionInput))
    table.set_border_color(panel, panelBorder)
    table.set_frame_color(panel, panelBorder)
    table.cell(panel, 0, 0, "AG Pro Fair Value Gap Reclaim Planner",
         text_color = headerText,
         bgcolor = headerBg,
         text_size = panelSize)
    table.cell(panel, 1, 0, "",
         text_color = headerText,
         bgcolor = headerBg,
         text_size = panelSize)
    table.merge_cells(panel, 0, 0, 1, 0)
    table.cell(panel, 0, 1, "Gap State",
         text_color = panelLabelFinal,
         bgcolor = panelLeftFinal,
         text_size = panelSize)
    table.cell(panel, 1, 1, gapState,
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
    table.cell(panel, 0, 3, "Fill Progress",
         text_color = panelLabelFinal,
         bgcolor = panelLeftFinal,
         text_size = panelSize)
    table.cell(panel, 1, 3, fillText,
         text_color = panelTextFinal,
         bgcolor = panelBgFinal,
         text_size = panelSize)
    table.cell(panel, 0, 4, "Risk",
         text_color = panelLabelFinal,
         bgcolor = panelLeftFinal,
         text_size = panelSize)
    table.cell(panel, 1, 4, riskText,
         text_color = panelTextFinal,
         bgcolor = panelBgFinal,
         text_size = panelSize)
    table.cell(panel, 0, 5, "Reclaim Hit Rate",
         text_color = panelLabelFinal,
         bgcolor = panelLeftFinal,
         text_size = panelSize)
    table.cell(panel, 1, 5, proofText,
         text_color = proofCol,
         bgcolor = panelBgFinal,
         text_size = panelSize)
    table.cell(panel, 0, 6, "Action",
         text_color = panelLabelFinal,
         bgcolor = panelLeftFinal,
         text_size = panelSize)
    table.cell(panel, 1, 6, actionText,
         text_color = f_action_textcol(actionState),
         bgcolor = f_action_color(actionState),
         text_size = panelSize)

if not showPanel and barstate.islast
    table.clear(panel, 0, 0, 1, 6)

// -------------------------------------------------
// Bar color and alerts
// -------------------------------------------------
barStateColor = actionState == "READY" ? color.new(activeDir == 1 ? bullColor : bearColor, 76) :
     actionState == "MONITOR" ? color.new(activeDir == 1 ? bullColor : bearColor, 84) :
     actionState == "INVALIDATED" ? color.new(bearColor, 80) : na
barcolor(showBarColors ? barStateColor : na)

alertcondition(alertNewFvg and newFvgAccepted and activeDir == 1, "Bullish FVG Locked",
     "AG Pro FVG | BULLISH FVG LOCKED | {{ticker}} | {{interval}}")
alertcondition(alertNewFvg and newFvgAccepted and activeDir == -1, "Bearish FVG Locked",
     "AG Pro FVG | BEARISH FVG LOCKED | {{ticker}} | {{interval}}")
alertcondition(alertReady and readyEvent and activeDir == 1, "Bullish FVG Reclaim Ready",
     "AG Pro FVG | BULLISH FVG RECLAIM READY | {{ticker}} | {{interval}}")
alertcondition(alertReady and readyEvent and activeDir == -1, "Bearish FVG Reclaim Ready",
     "AG Pro FVG | BEARISH FVG RECLAIM READY | {{ticker}} | {{interval}}")
alertcondition(alertTouch and touchEvent, "FVG Touch",
     "AG Pro FVG | FVG TOUCH | {{ticker}} | {{interval}}")
alertcondition(alertInvalidated and invalidatedEvent, "FVG Reclaim Invalidated",
     "AG Pro FVG | FVG RECLAIM INVALIDATED | {{ticker}} | {{interval}}")

if resetFvgAfterRender
    hasActiveFvg := false
    activeReclaim := false
````
