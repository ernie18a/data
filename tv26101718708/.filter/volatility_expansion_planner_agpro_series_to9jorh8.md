# Volatility Expansion Planner [AGPro Series]

- url: https://www.tradingview.com/script/to9JOrH8-Volatility-Expansion-Planner-AGPro-Series/
- type: indicator
- pine_id: PUB;95d12127e2bb4fd880ef2709fe5b9b7b
- version: 5.0

## Description

Volatility Expansion Planner [AGPro Series]

🧠 Core Idea

Is volatility expanding with structure, or is the chart only producing random noise?


📌 Overview / What it does

Volatility Expansion Planner [AGPro Series] is a chart-first volatility expansion and breakout quality tool built to evaluate whether a release from compression has enough structure to deserve active attention.

Instead of showing another generic expansion signal, the script studies ATR expansion, prior range release, close efficiency, volume support, trend alignment, compression age, and the active risk shelf behind the move. These components are converted into a 0-100 Expansion Score and a clear next-action state.

The script produces an expansion corridor, ATR expansion band, prior range edge, risk shelf, compact quality labels, alerts, and a clean AGPro planning panel. It does not predict future price movement, automate decisions, or guarantee that an expansion will continue.


🎯 Purpose & Design Philosophy

This script was built for traders who want to separate structured volatility expansion from unstable noise.

Many volatility tools identify compression, release, or regime changes, but they often stop before answering the practical planning question: is the expansion clean enough to evaluate, and where is the risk reference if the release fails?

The design philosophy is simple: volatility expansion is only useful when it has structure, confirmation, and a readable risk shelf.


⚡ Why This Script Is Different

Most tools focus on squeeze dots, volatility regime labels, ATR readings, or basic breakout markers.

This script does NOT clone a Squeeze Momentum Indicator, does not rebuild an ATR Compression Map, and does not act as a generic breakout signal.

Instead, it evaluates whether expansion is structurally supported. The main output is not a trade command. It is a planning state that helps users distinguish STRUCTURED expansion from WATCH, RISK REVIEW, NOISE, or WAIT conditions.


⚙️ Methodology

1. Context Detection
The script reads the active expansion side using prior range release and trend context, or lets the user force long-side or short-side expansion planning.

2. Reference Mapping
It maps the prior range edge, current ATR expansion, compression age, risk shelf, and projected expansion corridor.

3. Reaction Evaluation
The model scores ATR expansion, range breakout, close efficiency, volume support, trend alignment, compression maturity, and risk shelf quality.

4. Visual Output
The result is displayed through an expansion corridor, ATR band, range edge, risk shelf, compact labels, deterministic alerts, and a premium AGPro panel.


🗺️ How to Read the Chart

Zones = the expansion corridor shows the projected release path from the prior range edge toward a measured target guide. Its label is centered inside the corridor.

Labels = compact state markers show STRUCTURED, WATCH, RISK REVIEW, NOISE, or SHELF CHECK context.

Colors = green highlights cleaner structured expansion, pink highlights unstable expansion risk, amber highlights review conditions, and indigo highlights watch conditions.

Panel = the panel summarizes Expansion Score, Squeeze Age, Confirmation, Risk Shelf, and Action.


🚦 Signals & States

• STRUCTURED → volatility is expanding with range release, confirmation, and a usable risk shelf.

• WATCH → expansion context is improving but confirmation is incomplete.

• RISK REVIEW → expansion is active but the risk shelf is too tight or too wide for clean planning.

• NOISE → volatility is hot or inefficient and may represent unstable movement.

• WAIT → the script does not detect a strong enough expansion context yet.

• SHELF CHECK → price crossed the prior risk shelf and the expansion context should be reviewed.


🔔 Alerts Logic

Alerts trigger when the planner enters STRUCTURED expansion, WATCH state, NOISE state, RISK REVIEW state, or when price crosses the prior risk shelf.

These alerts are attention markers only. They are not trade instructions, entry signals, or automated strategy commands.


🧩 Confluence Logic

The strongest context appears when ATR expands from a prior compressed structure, price closes beyond the prior range edge, candle efficiency is strong, volume support improves, trend alignment agrees with the expansion side, and the risk shelf remains readable.

When these components align, the Expansion Score improves and the state can move from WATCH to STRUCTURED.


📊 When to Use

• Before evaluating volatility expansion after a quiet range

• During breakout or continuation attempts where expansion quality matters

• When price releases from a prior structure but confirmation is uncertain

• When comparing whether an expansion has clean risk context or only noisy movement

• On liquid symbols where range, volume, and ATR behavior are readable


⚠️ When NOT to Use

• Very low-liquidity symbols with unstable candles

• Extremely noisy micro-timeframes

• News-driven spikes where ATR expands abruptly without structure

• Markets where volume is unreliable and price gaps distort the risk shelf

• Situations where the user expects a signal-only entry tool


🎛️ Key Inputs

• Expansion Side → controls Auto, Long Expansion, or Short Expansion mode.

• Prior Range Lookback → controls how the script maps the range edge before release.

• ATR Baseline → controls how current volatility is compared with normal volatility.

• Minimum Squeeze Age → defines how mature compression should be before stronger expansion scoring.

• Risk Shelf Lookback → controls the shelf used behind the expansion for planning context.

• STRUCTURED Threshold → sets the minimum score required for the strongest state.

• Label and Panel Font Size → controls chart labels, corridor text, and panel readability.


🖥️ Interface & Visual Design

The interface is designed to stay chart-first.

The expansion corridor gives the main visual story. The range edge and risk shelf define the practical planning frame. The ATR band adds volatility context without turning the script into a lower-pane oscillator.

The AGPro panel provides a compact decision summary with a merged blue title row and clear state hierarchy.


🧪 Practical Usage Workflow

1. Read the panel state and Expansion Score.

2. Check whether price is releasing from the prior range edge.

3. Review the risk shelf distance and confirmation state.

4. Compare the expansion corridor with broader structure.

5. Treat alerts as attention markers, then evaluate the broader market context.


🔍 Interpretation Guidelines

Think in terms of expansion quality, not prediction.

A stronger score means multiple structural conditions are aligned. A weaker score means expansion may be premature, poorly confirmed, too hot, or difficult to plan around.

RISK REVIEW is especially important because volatility can expand while the practical risk reference remains too tight, too wide, or unclear.


🚫 What This Script Is NOT

• Not a prediction engine

• Not financial advice

• Not an auto-trading system

• Not a guaranteed signal tool

• Not a Squeeze Momentum clone

• Not an ATR Compression Map clone


⚠️ Limitations & Transparency

The script is rule-based and depends on recent price, volatility, range, and volume behavior.

Timeframe differences can change how compression and expansion appear. Volatility spikes can temporarily distort the score. Symbols with unreliable volume may produce weaker participation readings.

Outputs should always be interpreted with broader market structure and liquidity context.


🧠 Market Context Notes

Volatility expansion is most useful when it appears after a readable compression phase and respects a clear structural shelf.

Expansion without shelf clarity can still move, but it is harder to plan around. Expansion with poor close efficiency or excessive ATR heat can be noisy even when price breaks a range edge.


🧾 Use Case Examples

When price closes beyond a prior range edge with rising ATR, improved volume support, efficient candle structure, and a defined risk shelf, the planner may classify the move as STRUCTURED.

When ATR expands sharply but candles close poorly and the shelf is too far away, the planner may classify the context as NOISE or RISK REVIEW.


🧱 System Philosophy

AGPro planning tools are designed to help traders evaluate context before reacting.

This script follows that philosophy by turning volatility expansion into a structured planning question: Is the release clean, confirmed, and readable enough to deserve attention?


🔐 Non-Promise Statement

No indicator can guarantee continuation, reversal, or follow-through.

This tool provides structured visual context and rule-based attention markers. It does not provide certainty.


📉 Risk Disclosure

Trading involves risk. Market conditions can change quickly, and no script can remove uncertainty.

Users are responsible for their own analysis, risk management, and decisions.

This script is for educational and analytical use only and does not provide financial advice.


📚 Educational Note

Use the planner to study how volatility behaves after compression, how expansion quality changes across timeframes, and how risk shelf clarity affects the readability of a move.

## Source Code

````pine
// -------------------------------------------------
// Volatility Expansion Planner [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 1.7
//
// Volatility Expansion Planner is a chart-first volatility expansion and
// range-release planning engine. It evaluates whether volatility expansion is
// active, cooling down, structurally supported, or becoming noisy by combining
// ATR expansion, prior range release, close efficiency, volume support, trend
// alignment, compression age, and risk-shelf context into a 0-100 review score.
// V1.7 locks each active plan to its release geometry, reduces competing
// annotations, and makes every visible planning rail price-specific.
// -------------------------------------------------

//@version=6
indicator("Volatility Expansion Planner [AGPro Series]",
     shorttitle = "AG Pro VEP",
     overlay = true,
     max_labels_count = 40,
     max_boxes_count = 4,
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
dangerColor   = color.rgb(239, 68, 68)
darkText      = color.rgb(15, 23, 42)

// -------------------------------------------------
// Tooltips
// -------------------------------------------------
const string ttSide = "Selects the expansion side. Auto reads the active range release and trend context. Manual modes force long-side or short-side expansion planning."
const string ttConfirm = "When enabled, state changes, labels, and alerts are confirmed only after the bar closes. This keeps public chart behavior stable."
const string ttAtrLen = "ATR length used to measure volatility expansion, visual bands, label offsets, risk shelf distance, and projection guides."
const string ttAtrBase = "Longer ATR baseline used to decide whether current volatility is compressed, active, cooling down, balanced, or noisy."
const string ttRange = "Lookback used to map the prior range edge before expansion. This is not a Bollinger or Keltner squeeze model."
const string ttRangeBase = "Longer baseline used to compare the current structural range width against normal range width."
const string ttShelf = "Lookback used to locate the active risk shelf behind the expansion. The shelf is a planning reference, not a stop recommendation."
const string ttFast = "Fast EMA used for directional context and trend confirmation. It does not create buy or sell signals."
const string ttSlow = "Slow EMA used for directional context and trend confirmation."
const string ttSlope = "Number of bars used to evaluate whether the slow EMA is supporting the active expansion side."
const string ttVolume = "Volume baseline used to check whether expansion has participation. On symbols without reliable volume, this component becomes neutral."
const string ttCompression = "Maximum structural range ratio that counts as compression before expansion. Lower values require a tighter prior range."
const string ttAtrCompression = "Maximum ATR ratio that can count as compressed context before expansion."
const string ttMinAge = "Minimum compression age preferred before a release is treated as mature enough for a stronger expansion score."
const string ttBreak = "Minimum ATR-normalized close beyond the prior range edge required for a stronger expansion-break score."
const string ttHot = "ATR ratio above this level is treated as noisy expansion risk. Higher values allow stronger volatility before the script flags noise."
const string ttMinShelf = "Minimum ATR-normalized distance from price to the risk shelf. Very tight shelves can be vulnerable to normal noise."
const string ttMaxShelf = "Maximum ATR-normalized distance from price to the risk shelf. Very wide shelves reduce clean planning quality."
const string ttReady = "Minimum 0-100 score required for STRUCTURED state. STRUCTURED means expansion quality is clean enough to deserve attention, not that a trade should be taken."
const string ttWatch = "Minimum 0-100 score required for WATCH state. WATCH means expansion context is improving but confirmation is incomplete."
const string ttFollowWindow = "Number of bars a structured expansion has to follow through in the plan direction within, for the Follow Rate proof. It only measures historical follow-through and is not a forecast."
const string ttCorridor = "Shows the projected expansion corridor from the prior range edge toward a measured target guide. The centered badge summarizes state, score, and ATR context."
const string ttAtrBand = "Shows a light ATR expansion band around price so current volatility width can be read quickly."
const string ttRangeEdge = "Shows the prior range edge that price is attempting to release from."
const string ttRiskShelf = "Shows the active risk shelf behind the expansion. It is used for planning context and alerts, not as a guaranteed invalidation level."
const string ttContextEma = "Shows the fast and slow context EMAs used inside the directional score model. Disabled by default for a cleaner publication preset."
const string ttGuideBadges = "Shows compact, price-specific tags on the active range edge, risk shelf, and target guide. Tags are staggered to reduce collisions."
const string ttTarget = "Projection multiple applied to the prior range width for the forward expansion guide. This is a planning reference only."
const string ttProjection = "Number of bars projected to the right for corridor, shelf, range-edge, and target guides."
const string ttCorridorOpacity = "Transparency for the expansion corridor. Higher values make the corridor lighter."
const string ttLabels = "Shows compact EXP, WATCH, NOISE, SHELF, and COOLDOWN labels. Labels are offset away from candles."
const string ttContext = "Adds sparse context labels during ongoing expansion planning so the chart does not look empty while staying controlled."
const string ttCooldown = "Minimum bars between chart labels. Higher values reduce label density."
const string ttContextSpacing = "Minimum bars between sparse context labels during ongoing states."
const string ttMaxLabels = "Maximum number of chart labels retained. Older labels are removed first to preserve performance."
const string ttLabelOffset = "ATR-based vertical offset that keeps labels above or below candles."
const string ttLabelScore = "Adds the 0-100 expansion score to chart labels."
const string ttLabelSize = "Font size for all chart labels and centered corridor text. Normal is the recommended publication default."
const string ttShowPanel = "Shows or hides the AGPro planning panel. It is shown by default for public-release readability."
const string ttPanelLocation = "Moves the panel to the preferred chart location."
const string ttPanelTheme = "Switches the panel between AGPro dark and clean light themes."
const string ttPanelFont = "Font size for the AGPro panel. Normal is the recommended publication default."

// -------------------------------------------------
// Inputs
// -------------------------------------------------
groupEngine = "Expansion Engine"
sideMode = input.string("Auto", "Expansion Side", options = ["Auto", "Long Expansion", "Short Expansion"], group = groupEngine, tooltip = ttSide)
confirmOnClose = input.bool(true, "Confirm On Bar Close", group = groupEngine, tooltip = ttConfirm)
atrLen = input.int(14, "ATR Length", minval = 2, maxval = 100, group = groupEngine, tooltip = ttAtrLen)
atrBaseLen = input.int(55, "ATR Baseline", minval = 10, maxval = 300, group = groupEngine, tooltip = ttAtrBase)
rangeLookback = input.int(34, "Prior Range Lookback", minval = 8, maxval = 220, group = groupEngine, tooltip = ttRange)
rangeBaseLen = input.int(89, "Range Width Baseline", minval = 20, maxval = 400, group = groupEngine, tooltip = ttRangeBase)
riskShelfLookback = input.int(21, "Risk Shelf Lookback", minval = 5, maxval = 160, group = groupEngine, tooltip = ttShelf)
fastEmaLen = input.int(21, "Fast Context EMA", minval = 1, maxval = 200, group = groupEngine, tooltip = ttFast)
slowEmaLen = input.int(55, "Slow Context EMA", minval = 2, maxval = 300, group = groupEngine, tooltip = ttSlow)
slopeBars = input.int(5, "Trend Slope Bars", minval = 1, maxval = 30, group = groupEngine, tooltip = ttSlope)
volumeLen = input.int(34, "Volume Support Length", minval = 5, maxval = 200, group = groupEngine, tooltip = ttVolume)

groupScoring = "Expansion Scoring"
compressionRangeRatio = input.float(0.78, "Compression Range Ratio", minval = 0.20, maxval = 1.25, step = 0.01, group = groupScoring, tooltip = ttCompression)
compressionAtrRatio = input.float(0.92, "Compression ATR Ratio", minval = 0.30, maxval = 1.40, step = 0.01, group = groupScoring, tooltip = ttAtrCompression)
minimumSqueezeAge = input.int(5, "Minimum Squeeze Age", minval = 1, maxval = 60, group = groupScoring, tooltip = ttMinAge)
minimumBreakAtr = input.float(0.18, "Minimum Edge Break ATR", minval = 0.01, maxval = 2.00, step = 0.01, group = groupScoring, tooltip = ttBreak)
hotAtrRatio = input.float(2.25, "Hot Expansion Risk", minval = 1.10, maxval = 5.00, step = 0.05, group = groupScoring, tooltip = ttHot)
minimumShelfAtr = input.float(0.55, "Minimum Risk Shelf ATR", minval = 0.05, maxval = 4.00, step = 0.05, group = groupScoring, tooltip = ttMinShelf)
maximumShelfAtr = input.float(3.40, "Maximum Risk Shelf ATR", minval = 0.30, maxval = 12.00, step = 0.05, group = groupScoring, tooltip = ttMaxShelf)
structuredThreshold = input.int(72, "STRUCTURED Threshold", minval = 40, maxval = 95, group = groupScoring, tooltip = ttReady)
watchThreshold = input.int(55, "WATCH Threshold", minval = 20, maxval = 90, group = groupScoring, tooltip = ttWatch)
followWindow = input.int(24, "Follow Proof Window (bars)", minval = 5, maxval = 200, group = groupScoring, tooltip = ttFollowWindow)

groupVisual = "Chart Visuals"
showExpansionCorridor = input.bool(true, "Show Expansion Corridor", group = groupVisual, tooltip = ttCorridor)
showAtrExpansionBand = input.bool(false, "Show ATR Expansion Band", group = groupVisual, tooltip = ttAtrBand)
showContextEma = input.bool(false, "Show Context EMAs", group = groupVisual, tooltip = ttContextEma)
showRangeEdge = input.bool(true, "Show Range Edge", group = groupVisual, tooltip = ttRangeEdge)
showRiskShelf = input.bool(true, "Show Risk Shelf", group = groupVisual, tooltip = ttRiskShelf)
showGuideBadges = input.bool(true, "Show Planning Rail Tags", group = groupVisual, tooltip = ttGuideBadges)
showStateMarkers = input.bool(false, "Show Tiny State Markers", group = groupVisual, tooltip = "Shows tiny diamond markers for state changes. Disabled by default because labels and zones already carry the main visual story.")
targetRangeMultiple = input.float(1.20, "Target Guide Range Multiple", minval = 0.25, maxval = 4.00, step = 0.05, group = groupVisual, tooltip = ttTarget)
projectionBars = input.int(42, "Projection Bars", minval = 8, maxval = 180, group = groupVisual, tooltip = ttProjection)
corridorTransparency = input.int(91, "Corridor Transparency", minval = 70, maxval = 96, group = groupVisual, tooltip = ttCorridorOpacity)

groupLabels = "Labels"
showEventLabels = input.bool(true, "Show Event Labels", group = groupLabels, tooltip = ttLabels)
showContextLabels = input.bool(false, "Show Sparse Context Labels", group = groupLabels, tooltip = ttContext)
labelCooldownBars = input.int(40, "Label Cooldown Bars", minval = 1, maxval = 120, group = groupLabels, tooltip = ttCooldown)
contextSpacingBars = input.int(72, "Context Label Spacing", minval = 8, maxval = 240, group = groupLabels, tooltip = ttContextSpacing)
maxVisibleLabels = input.int(6, "Max Visible Labels", minval = 5, maxval = 100, group = groupLabels, tooltip = ttMaxLabels)
labelOffsetAtr = input.float(1.05, "Label Offset ATR", minval = 0.10, maxval = 3.00, step = 0.05, group = groupLabels, tooltip = ttLabelOffset)
showLabelScore = input.bool(true, "Show Label Score", group = groupLabels, tooltip = ttLabelScore)
labelSizeInput = input.string("Normal", "Label Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = groupLabels, tooltip = ttLabelSize)

groupPanel = "Panel"
showPanel = input.bool(true, "Show Panel", group = groupPanel, tooltip = ttShowPanel)
panelLocationInput = input.string("Top Right", "Panel Location", options = ["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], group = groupPanel, tooltip = ttPanelLocation)
panelThemeInput = input.string("Elite Dark", "Panel Theme", options = ["Elite Dark", "Clean Light"], group = groupPanel, tooltip = ttPanelTheme)
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
    float result = 0.0
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

f_state_color(string stateText) =>
    switch stateText
        "STRUCTURED" => bullColor
        "WATCH" => accentColor
        "RISK REVIEW" => neutralColor
        "NOISE" => bearColor
        "SHELF CHECK" => neutralColor
        "COOLDOWN" => accentColor
        "WAIT" => panelLabelCol
        => panelLabelCol

f_mode_color(string modeText) =>
    switch modeText
        "Active ATR" => bullColor
        "Cooldown ATR" => accentColor
        "Noisy ATR" => bearColor
        "Quiet ATR" => neutralColor
        => panelValueCol

f_state_code(string stateText) =>
    switch stateText
        "STRUCTURED" => "EXP"
        "WATCH" => "WATCH"
        "RISK REVIEW" => "SHELF"
        "NOISE" => "NOISE"
        "SHELF CHECK" => "SHELF"
        "COOLDOWN" => "COOL"
        => "WAIT"

f_label_title(string stateText) =>
    switch stateText
        "STRUCTURED" => "Expansion"
        "WATCH" => "Watch"
        "RISK REVIEW" => "Shelf Review"
        "NOISE" => "Noise"
        "SHELF CHECK" => "Shelf Check"
        "COOLDOWN" => "Cooldown"
        "WAIT" => "Wait"
        => "Wait"

f_set_row(table target, int row, string leftText, string rightText, color rightColor, string theme, string fontSize) =>
    color rowBg = f_row_bg(theme, row)
    table.cell(target, 0, row, leftText, text_color = f_panel_label(theme), bgcolor = rowBg, text_size = f_label_size(fontSize), text_halign = text.align_left)
    table.cell(target, 1, row, rightText, text_color = rightColor, bgcolor = rowBg, text_size = f_label_size(fontSize), text_halign = text.align_right)

f_fmt(float value) =>
    na(value) ? "-" : str.tostring(value, "#.##")

f_trim_labels(array<label> labels, int maxCount) =>
    int labelCount = array.size(labels)
    if labelCount > maxCount
        int removeCount = labelCount - maxCount
        for idx = 0 to removeCount - 1
            label oldLabel = array.shift(labels)
            if not na(oldLabel)
                label.delete(oldLabel)

f_delete_label(label item) =>
    if not na(item)
        label.delete(item)

// -------------------------------------------------
// Core measurements
// -------------------------------------------------
float atr = ta.atr(atrLen)
float safeAtr = math.max(nz(atr, ta.tr(true)), syminfo.mintick)
float atrBase = ta.sma(atr, atrBaseLen)
float atrRatio = not na(atrBase) and atrBase > 0.0 ? atr / atrBase : 1.0
float atrSlope = not na(atr[slopeBars]) and atr[slopeBars] > 0.0 ? (atr - atr[slopeBars]) / atr[slopeBars] : 0.0

float fastEma = ta.ema(close, fastEmaLen)
float slowEma = ta.ema(close, slowEmaLen)
float trendSlope = slowEma - nz(slowEma[slopeBars], slowEma)
float trendSlopeAtr = math.abs(trendSlope) / safeAtr

float priorRangeHigh = nz(ta.highest(high, rangeLookback)[1], high)
float priorRangeLow = nz(ta.lowest(low, rangeLookback)[1], low)
float priorRangeWidth = math.max(priorRangeHigh - priorRangeLow, syminfo.mintick)
float rangeBase = ta.sma(priorRangeWidth, rangeBaseLen)
float rangeRatio = not na(rangeBase) and rangeBase > 0.0 ? priorRangeWidth / rangeBase : 1.0

float breakAboveAtr = math.max(close - priorRangeHigh, 0.0) / safeAtr
float breakBelowAtr = math.max(priorRangeLow - close, 0.0) / safeAtr
bool bullBreak = breakAboveAtr >= minimumBreakAtr
bool bearBreak = breakBelowAtr >= minimumBreakAtr

bool bullTrend = close >= slowEma and fastEma >= slowEma
bool bearTrend = close <= slowEma and fastEma <= slowEma
int autoDir = bullBreak and not bearBreak ? 1 : bearBreak and not bullBreak ? -1 : bullTrend and not bearTrend ? 1 : bearTrend and not bullTrend ? -1 : close >= slowEma ? 1 : -1
int planDir = sideMode == "Long Expansion" ? 1 : sideMode == "Short Expansion" ? -1 : autoDir
string dirText = planDir == 1 ? "Long" : "Short"
color dirColor = planDir == 1 ? bullColor : bearColor

float rangeEdge = planDir == 1 ? priorRangeHigh : priorRangeLow
float breakCloseAtr = math.max(planDir == 1 ? close - rangeEdge : rangeEdge - close, 0.0) / safeAtr
bool rangeBreak = breakCloseAtr >= minimumBreakAtr

float rawShelf = planDir == 1 ? nz(ta.lowest(low, riskShelfLookback), low) : nz(ta.highest(high, riskShelfLookback), high)
float riskShelf = planDir == 1 ? math.min(rangeEdge, rawShelf) : math.max(rangeEdge, rawShelf)
float shelfDistanceAtr = math.max(planDir == 1 ? close - riskShelf : riskShelf - close, 0.0) / safeAtr

float barRange = math.max(high - low, syminfo.mintick)
float closeLocation = planDir == 1 ? (close - low) / barRange : (high - close) / barRange
float bodyShare = math.abs(close - open) / barRange
float closeEfficiencyScore = f_clamp(closeLocation * 62.0 + bodyShare * 38.0, 0.0, 100.0)

float rawVolume = na(volume) ? 1.0 : volume
float volumeBase = ta.sma(rawVolume, volumeLen)
float volumeRatio = not na(volumeBase) and volumeBase > 0.0 ? rawVolume / volumeBase : 1.0
float volumeScore = na(volume) ? 55.0 : f_norm_high_good(volumeRatio, 0.75, 1.55)

bool compressedContext = rangeRatio <= compressionRangeRatio and atrRatio <= compressionAtrRatio
var int squeezeAge = 0
squeezeAge := compressedContext ? nz(squeezeAge[1]) + 1 : 0
int priorSqueezeAge = nz(squeezeAge[1])
int activeSqueezeAge = rangeBreak ? priorSqueezeAge : squeezeAge

// -------------------------------------------------
// Quality model
// -------------------------------------------------
float atrExpansionScore = f_clamp(f_peak_score(atrRatio, 0.82, 1.38, hotAtrRatio) * 0.72 + f_norm_high_good(atrSlope, -0.02, 0.18) * 0.28, 0.0, 100.0)
float rangeBreakScore = f_norm_high_good(breakCloseAtr, minimumBreakAtr * 0.35, minimumBreakAtr + 0.95)
float trendBaseScore = planDir == 1 ? (close >= slowEma ? 55.0 : 18.0) : (close <= slowEma ? 55.0 : 18.0)
float trendStackScore = planDir == 1 ? (fastEma >= slowEma ? 28.0 : 0.0) : (fastEma <= slowEma ? 28.0 : 0.0)
float trendSlopeScore = (planDir == 1 ? trendSlope >= 0.0 : trendSlope <= 0.0) ? f_norm_high_good(trendSlopeAtr, 0.01, 0.32) * 0.17 : 0.0
float trendScore = f_clamp(trendBaseScore + trendStackScore + trendSlopeScore, 0.0, 100.0)
float shelfScore = f_peak_score(shelfDistanceAtr, minimumShelfAtr, (minimumShelfAtr + maximumShelfAtr) * 0.42, maximumShelfAtr)
float squeezeAgeScore = f_norm_high_good(activeSqueezeAge, minimumSqueezeAge * 0.45, minimumSqueezeAge * 2.15)

float rawQuality = atrExpansionScore * 0.24 + rangeBreakScore * 0.22 + closeEfficiencyScore * 0.18 + volumeScore * 0.12 + trendScore * 0.14 + shelfScore * 0.06 + squeezeAgeScore * 0.04
bool tooHot = atrRatio > hotAtrRatio and closeEfficiencyScore < 58.0
bool shelfTooTight = shelfDistanceAtr < minimumShelfAtr
bool shelfTooWide = shelfDistanceAtr > maximumShelfAtr
bool shelfWeak = shelfTooTight or shelfTooWide
int expansionScore = int(math.round(f_clamp(tooHot ? math.min(rawQuality, 48.0) : rawQuality, 0.0, 100.0)))

string confirmationState = ""
if not rangeBreak
    confirmationState := compressedContext ? "BUILDING" : "WAIT EDGE"
else if tooHot
    confirmationState := "CHAOTIC"
else if closeEfficiencyScore >= 62.0 and volumeScore >= 52.0 and trendScore >= 55.0
    confirmationState := "CONFIRMED"
else
    confirmationState := "PARTIAL"

string shelfState = shelfTooTight ? "TOO TIGHT" : shelfTooWide ? "TOO WIDE" : "DEFINED"
string expansionState = ""
if rangeBreak and expansionScore >= structuredThreshold and confirmationState == "CONFIRMED" and not shelfWeak
    expansionState := "STRUCTURED"
else if tooHot
    expansionState := "NOISE"
else if shelfWeak and rangeBreak
    expansionState := "RISK REVIEW"
else if expansionScore >= watchThreshold and (rangeBreak or compressedContext)
    expansionState := "WATCH"
else
    expansionState := "WAIT"

int barsSinceBreak = nz(ta.barssince(rangeBreak), 100000)
bool cooldownActive = not rangeBreak and barsSinceBreak <= math.max(labelCooldownBars, 8) and atrRatio >= 1.0
string volatilityMode = tooHot ? "Noisy ATR" : rangeBreak ? "Active ATR" : cooldownActive ? "Cooldown ATR" : compressedContext ? "Quiet ATR" : "Balanced ATR"
color volatilityModeColor = f_mode_color(volatilityMode)

string workflowText = expansionState == "STRUCTURED" ? "Review expansion" : expansionState == "WATCH" ? "Track confirmation" : expansionState == "RISK REVIEW" ? "Check shelf" : expansionState == "NOISE" ? "Reduce noise" : cooldownActive ? "Cooldown active" : compressedContext ? "Wait release" : "Wait setup"
string reviewText = expansionState == "STRUCTURED" ? "Expansion review" : expansionState == "WATCH" ? "Watch confirmation" : expansionState == "RISK REVIEW" ? "Shelf review" : expansionState == "NOISE" ? "Noise filter" : cooldownActive ? "Cooldown review" : compressedContext ? "Compression build" : "No release"
color stateColor = f_state_color(expansionState)
bool confirmedBar = not confirmOnClose or barstate.isconfirmed
bool corridorActive = rangeBreak or cooldownActive or expansionState == "STRUCTURED" or expansionState == "RISK REVIEW" or expansionState == "NOISE"

// Lock the release geometry once, so an active/cooldown plan does not drift
// with the rolling range on every subsequent bar.
bool newReleaseEvent = confirmedBar and rangeBreak and (not rangeBreak[1] or planDir != planDir[1])
var float lockedRangeEdge = na
var float lockedRangeWidth = na
var float lockedRiskShelf = na
var int lockedPlanDir = 0
var int lockedPlanBar = na

if newReleaseEvent
    lockedRangeEdge := rangeEdge
    lockedRangeWidth := priorRangeWidth
    lockedRiskShelf := riskShelf
    lockedPlanDir := planDir
    lockedPlanBar := bar_index

bool lockedPlanActive = corridorActive and not na(lockedRangeEdge) and not na(lockedRangeWidth)
float displayRangeEdge = lockedPlanActive ? lockedRangeEdge : rangeEdge
float displayRiskShelf = lockedPlanActive ? lockedRiskShelf : riskShelf
int displayPlanDir = lockedPlanActive ? lockedPlanDir : planDir
float displayShelfDistanceAtr = math.max(displayPlanDir == 1 ? close - displayRiskShelf : displayRiskShelf - close, 0.0) / safeAtr
bool displayShelfTooTight = displayShelfDistanceAtr < minimumShelfAtr
bool displayShelfTooWide = displayShelfDistanceAtr > maximumShelfAtr
bool displayShelfWeak = displayShelfTooTight or displayShelfTooWide
string displayShelfState = displayShelfTooTight ? "TOO TIGHT" : displayShelfTooWide ? "TOO WIDE" : "DEFINED"

// -------------------------------------------------
// ATR expansion band
// -------------------------------------------------
float atrBandUpper = close + safeAtr * atrRatio
float atrBandLower = close - safeAtr * atrRatio
atrUpperPlot = plot(showAtrExpansionBand ? atrBandUpper : na, "ATR Expansion Upper Band", color = color.new(accentColor, 100), linewidth = 1)
atrLowerPlot = plot(showAtrExpansionBand ? atrBandLower : na, "ATR Expansion Lower Band", color = color.new(accentColor, 100), linewidth = 1)
fill(atrUpperPlot, atrLowerPlot, color = showAtrExpansionBand ? color.new(accentColor, 94) : na, title = "ATR Expansion Band")

plot(showContextEma ? fastEma : na, "Fast Context EMA", color = color.new(panelLabelCol, 88), linewidth = 1)
plot(showContextEma ? slowEma : na, "Slow Context EMA", color = color.new(panelLabelCol, 82), linewidth = 1)

// -------------------------------------------------
// Expansion corridor and rails
// -------------------------------------------------
int rightEdge = bar_index + projectionBars
int leftEdge = lockedPlanActive ? lockedPlanBar : math.max(bar_index - math.min(rangeLookback, 42), 0)
float targetGuide = displayRangeEdge + displayPlanDir * (lockedPlanActive ? lockedRangeWidth : priorRangeWidth) * targetRangeMultiple
float corridorTop = math.max(displayRangeEdge, targetGuide)
float corridorBottom = math.min(displayRangeEdge, targetGuide)
float corridorMid = (corridorTop + corridorBottom) * 0.5
int corridorCenterX = leftEdge + int(math.round((rightEdge - leftEdge) * 0.5))
color corridorColor = expansionState == "STRUCTURED" ? dirColor : expansionState == "NOISE" ? bearColor : expansionState == "RISK REVIEW" ? neutralColor : cooldownActive ? accentColor : expansionState == "WATCH" ? accentColor : panelLabelCol
string corridorBadgeState = (cooldownActive and expansionState == "WAIT") ? "COOLDOWN" : expansionState
string corridorDirection = displayPlanDir == 1 ? "LONG" : "SHORT"
string corridorBadgeText = corridorDirection + " | " + corridorBadgeState + " | Q " + str.tostring(expansionScore)

var box expansionCorridor = na
var label corridorBadge = na
var line rangeEdgeLine = na
var line shelfLine = na
var line targetLine = na
var label rangeEdgeBadge = na
var label shelfBadge = na
var label targetGuideBadge = na

if showExpansionCorridor and lockedPlanActive
    if na(expansionCorridor)
        expansionCorridor := box.new(left = leftEdge, top = corridorTop, right = rightEdge, bottom = corridorBottom, xloc = xloc.bar_index, bgcolor = color.new(corridorColor, corridorTransparency), border_color = color.new(corridorColor, 30), border_width = expansionState == "STRUCTURED" ? 2 : 1)
    else
        box.set_left(expansionCorridor, leftEdge)
        box.set_right(expansionCorridor, rightEdge)
        box.set_top(expansionCorridor, corridorTop)
        box.set_bottom(expansionCorridor, corridorBottom)
        box.set_bgcolor(expansionCorridor, color.new(corridorColor, corridorTransparency))
        box.set_border_color(expansionCorridor, color.new(corridorColor, 30))
        box.set_border_width(expansionCorridor, expansionState == "STRUCTURED" ? 2 : 1)
    color badgeTextColor = corridorBadgeState == "RISK REVIEW" or corridorBadgeState == "WAIT" ? darkText : headerText
    if na(corridorBadge)
        corridorBadge := label.new(corridorCenterX, corridorMid, corridorBadgeText, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_center, color = color.new(corridorColor, 0), textcolor = badgeTextColor, size = f_label_size(labelSizeInput), textalign = text.align_center)
    else
        label.set_x(corridorBadge, corridorCenterX)
        label.set_y(corridorBadge, corridorMid)
        label.set_text(corridorBadge, corridorBadgeText)
        label.set_color(corridorBadge, color.new(corridorColor, 0))
        label.set_textcolor(corridorBadge, badgeTextColor)
        label.set_size(corridorBadge, f_label_size(labelSizeInput))
else
    if not na(expansionCorridor)
        box.delete(expansionCorridor)
        expansionCorridor := na
    f_delete_label(corridorBadge)
    corridorBadge := na

if showRangeEdge
    color edgeColor = rangeBreak ? color.new(dirColor, 0) : color.new(panelLabelCol, 35)
    if na(rangeEdgeLine)
        rangeEdgeLine := line.new(leftEdge, displayRangeEdge, rightEdge, displayRangeEdge, xloc = xloc.bar_index, extend = extend.none, color = edgeColor, width = 2)
    else
        line.set_xy1(rangeEdgeLine, leftEdge, displayRangeEdge)
        line.set_xy2(rangeEdgeLine, rightEdge, displayRangeEdge)
        line.set_color(rangeEdgeLine, edgeColor)
else
    if not na(rangeEdgeLine)
        line.delete(rangeEdgeLine)
        rangeEdgeLine := na

if showRiskShelf
    color shelfColor = displayShelfWeak ? neutralColor : stateColor
    int shelfLeft = lockedPlanActive ? lockedPlanBar : math.max(bar_index - math.min(riskShelfLookback, 42), 0)
    if na(shelfLine)
        shelfLine := line.new(shelfLeft, displayRiskShelf, rightEdge, displayRiskShelf, xloc = xloc.bar_index, extend = extend.none, color = shelfColor, width = 2, style = line.style_dashed)
    else
        line.set_xy1(shelfLine, shelfLeft, displayRiskShelf)
        line.set_xy2(shelfLine, rightEdge, displayRiskShelf)
        line.set_color(shelfLine, shelfColor)
else
    if not na(shelfLine)
        line.delete(shelfLine)
        shelfLine := na

if showExpansionCorridor and lockedPlanActive
    color targetColor = expansionState == "STRUCTURED" ? color.new(dirColor, 0) : color.new(accentColor, 20)
    if na(targetLine)
        targetLine := line.new(lockedPlanBar, targetGuide, rightEdge, targetGuide, xloc = xloc.bar_index, extend = extend.none, color = targetColor, width = 1, style = line.style_dotted)
    else
        line.set_xy1(targetLine, lockedPlanBar, targetGuide)
        line.set_xy2(targetLine, rightEdge, targetGuide)
        line.set_color(targetLine, targetColor)
else
    if not na(targetLine)
        line.delete(targetLine)
        targetLine := na

int edgeTagX = rightEdge + 2
int targetTagX = rightEdge + 4
int shelfTagX = rightEdge + 6

if barstate.islast and showGuideBadges and showRangeEdge
    string edgeBadgeText = (rangeBreak ? "BREAK EDGE " : "RANGE EDGE ") + str.tostring(displayRangeEdge, format.mintick)
    color edgeBadgeColor = rangeBreak ? dirColor : color.new(panelBorder, 0)
    if na(rangeEdgeBadge)
        rangeEdgeBadge := label.new(edgeTagX, displayRangeEdge, edgeBadgeText, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = edgeBadgeColor, textcolor = headerText, size = f_label_size(labelSizeInput))
    else
        label.set_x(rangeEdgeBadge, edgeTagX)
        label.set_y(rangeEdgeBadge, displayRangeEdge)
        label.set_text(rangeEdgeBadge, edgeBadgeText)
        label.set_color(rangeEdgeBadge, edgeBadgeColor)
        label.set_textcolor(rangeEdgeBadge, headerText)
        label.set_size(rangeEdgeBadge, f_label_size(labelSizeInput))
else
    f_delete_label(rangeEdgeBadge)
    rangeEdgeBadge := na

if barstate.islast and showGuideBadges and showRiskShelf
    string shelfBadgeText = (displayShelfWeak ? "SHELF REVIEW " : "RISK SHELF ") + str.tostring(displayRiskShelf, format.mintick) + " | " + f_fmt(displayShelfDistanceAtr) + " ATR"
    color shelfBadgeColor = displayShelfWeak ? neutralColor : stateColor
    color shelfBadgeTextColor = displayShelfWeak ? darkText : headerText
    if na(shelfBadge)
        shelfBadge := label.new(shelfTagX, displayRiskShelf, shelfBadgeText, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = color.new(shelfBadgeColor, 4), textcolor = shelfBadgeTextColor, size = f_label_size(labelSizeInput))
    else
        label.set_x(shelfBadge, shelfTagX)
        label.set_y(shelfBadge, displayRiskShelf)
        label.set_text(shelfBadge, shelfBadgeText)
        label.set_color(shelfBadge, color.new(shelfBadgeColor, 4))
        label.set_textcolor(shelfBadge, shelfBadgeTextColor)
        label.set_size(shelfBadge, f_label_size(labelSizeInput))
else
    f_delete_label(shelfBadge)
    shelfBadge := na

if barstate.islast and showGuideBadges and showExpansionCorridor and lockedPlanActive
    string targetGuideText = "TARGET " + str.tostring(targetGuide, format.mintick) + " | " + str.tostring(targetRangeMultiple, "#.##") + "R"
    if na(targetGuideBadge)
        targetGuideBadge := label.new(targetTagX, targetGuide, targetGuideText, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = color.new(accentColor, 0), textcolor = headerText, size = f_label_size(labelSizeInput))
    else
        label.set_x(targetGuideBadge, targetTagX)
        label.set_y(targetGuideBadge, targetGuide)
        label.set_text(targetGuideBadge, targetGuideText)
        label.set_color(targetGuideBadge, color.new(accentColor, 0))
        label.set_textcolor(targetGuideBadge, headerText)
        label.set_size(targetGuideBadge, f_label_size(labelSizeInput))
else
    f_delete_label(targetGuideBadge)
    targetGuideBadge := na

// -------------------------------------------------
// Labels and markers
// -------------------------------------------------
var int lastLabelBar = na
var string lastExpansionState = ""
var array<label> eventLabels = array.new_label()

bool structuredEvent = confirmedBar and expansionState == "STRUCTURED" and lastExpansionState != "STRUCTURED"
bool watchEvent = confirmedBar and expansionState == "WATCH" and lastExpansionState != "WATCH"
bool noiseEvent = confirmedBar and expansionState == "NOISE" and lastExpansionState != "NOISE"
bool riskReviewEvent = confirmedBar and expansionState == "RISK REVIEW" and lastExpansionState != "RISK REVIEW"
bool cooldownWasActive = bar_index > 0 ? cooldownActive[1] : false
bool cooldownEvent = confirmedBar and cooldownActive and not cooldownWasActive
bool shelfCheckEvent = confirmedBar and rangeBreak and not na(riskShelf[1]) and (planDir == 1 ? close < riskShelf[1] : close > riskShelf[1])
bool labelCooldownReady = na(lastLabelBar) or bar_index - lastLabelBar >= labelCooldownBars
bool contextReady = na(lastLabelBar) or bar_index - lastLabelBar >= contextSpacingBars
bool drawContext = showContextLabels and contextReady and (expansionState == "STRUCTURED" or expansionState == "WATCH" or expansionState == "RISK REVIEW" or cooldownActive)
bool drawEventLabel = showEventLabels and labelCooldownReady and (structuredEvent or watchEvent or noiseEvent or riskReviewEvent or shelfCheckEvent or cooldownEvent or drawContext)

if drawEventLabel
    string labelState = shelfCheckEvent ? "SHELF CHECK" : (cooldownEvent and expansionState == "WAIT") ? "COOLDOWN" : expansionState
    string labelText = f_label_title(labelState)
    if showLabelScore and not shelfCheckEvent
        labelText += " " + str.tostring(expansionScore)
    labelText += "\n" + str.tostring(atrRatio, "#.00") + "x ATR"
    float labelY = planDir == 1 ? low - safeAtr * labelOffsetAtr : high + safeAtr * labelOffsetAtr
    color labelBg = color.new(shelfCheckEvent ? neutralColor : f_state_color(labelState), 6)
    color labelTextColor = labelState == "SHELF CHECK" or labelState == "RISK REVIEW" ? darkText : headerText
    label eventLabel = label.new(x = bar_index, y = labelY, text = labelText, xloc = xloc.bar_index, yloc = yloc.price, style = planDir == 1 ? label.style_label_up : label.style_label_down, color = labelBg, textcolor = labelTextColor, size = f_label_size(labelSizeInput), textalign = text.align_center)
    array.push(eventLabels, eventLabel)
    f_trim_labels(eventLabels, maxVisibleLabels)
    lastLabelBar := bar_index

plotshape(showStateMarkers and structuredEvent and planDir == 1, title = "Long Structured Expansion Marker", style = shape.diamond, location = location.belowbar, color = color.new(bullColor, 0), size = size.tiny)
plotshape(showStateMarkers and structuredEvent and planDir == -1, title = "Short Structured Expansion Marker", style = shape.diamond, location = location.abovebar, color = color.new(bearColor, 0), size = size.tiny)
plotshape(showStateMarkers and (watchEvent or riskReviewEvent or cooldownEvent), title = "Expansion Watch Marker", style = shape.diamond, location = location.abovebar, color = color.new(neutralColor, 0), size = size.tiny)
plotshape(showStateMarkers and (noiseEvent or shelfCheckEvent), title = "Expansion Risk Marker", style = shape.diamond, location = location.abovebar, color = color.new(bearColor, 0), size = size.tiny)

// -------------------------------------------------
// Expansion follow-through proof
// -------------------------------------------------
var int   folTotal   = 0
var int   folWon       = 0
var bool  folPend      = false
var int   folDir       = 0
var float folAnchor    = na
var float folShelf     = na
var float folMargin    = na
var int   folLeft      = 0

if barstate.isconfirmed
    if folPend and not na(folAnchor)
        bool favHit = folDir == 1 ? close >= folAnchor + folMargin : close <= folAnchor - folMargin
        bool shelfHit = not na(folShelf) and (folDir == 1 ? close < folShelf : close > folShelf)
        bool advMove = folDir == 1 ? close <= folAnchor - folMargin : close >= folAnchor + folMargin
        bool advHit = shelfHit or advMove
        if favHit
            folTotal += 1
            folWon += 1
            folPend := false
        else if advHit
            folTotal += 1
            folPend := false
        else
            folLeft -= 1
            if folLeft <= 0
                folTotal += 1
                folPend := false
    if structuredEvent and planDir != 0 and not folPend
        folPend := true
        folDir := planDir
        folAnchor := close
        folShelf := lockedPlanActive ? lockedRiskShelf : riskShelf
        folMargin := safeAtr * 0.75
        folLeft := followWindow

float folRate = folTotal > 0 ? folWon / folTotal * 100.0 : na

// -------------------------------------------------
// Data window
// -------------------------------------------------
plot(expansionScore, title = "Expansion Score", color = stateColor, display = display.data_window)
plot(atrExpansionScore, title = "ATR Expansion Score", color = accentColor, display = display.data_window)
plot(rangeBreakScore, title = "Range Break Score", color = bullColor, display = display.data_window)
plot(closeEfficiencyScore, title = "Close Efficiency Score", color = neutralColor, display = display.data_window)
plot(volumeScore, title = "Volume Support Score", color = bearColor, display = display.data_window)
plot(trendScore, title = "Trend Alignment Score", color = panelLabelCol, display = display.data_window)
plot(folRate, title = "Expansion Follow Rate", color = bullColor, display = display.data_window)

// -------------------------------------------------
// Panel
// -------------------------------------------------
string theme = panelThemeInput
string panelSize = panelFontSizeInput
color dashBg = f_panel_bg(theme)
color frameColor = f_panel_border(theme)

string scoreRead = str.tostring(expansionScore) + " / " + expansionState
string atrRead = str.tostring(atrRatio, "#.00") + "x / " + volatilityMode
string squeezeRead = str.tostring(activeSqueezeAge) + " bars / R " + str.tostring(rangeRatio, "#.00")
string confirmationRead = confirmationState + " / V " + str.tostring(volumeRatio, "#.00") + "x"
string shelfRead = displayShelfState + " / " + str.tostring(displayShelfDistanceAtr, "#.00") + " ATR"
string directionRead = (displayPlanDir == 1 ? "Long" : "Short") + " / " + confirmationState
string followRead = folTotal > 0 ? str.tostring(math.round(folRate)) + "% | " + str.tostring(folWon) + "/" + str.tostring(folTotal) : "Building"
color followColor = na(folRate) ? f_panel_value(theme) : folRate >= 60.0 ? bullColor : folRate >= 45.0 ? neutralColor : dangerColor

var table panel = na
var string panelKey = ""
string activePanelKey = panelLocationInput + "|" + panelThemeInput

if barstate.islast
    if showPanel
        if na(panel) or panelKey != activePanelKey
            if not na(panel)
                table.delete(panel)
            panel := table.new(f_panel_position(panelLocationInput), 2, 8, bgcolor = dashBg, frame_color = frameColor, frame_width = 1, border_color = frameColor, border_width = 1)
            panelKey := activePanelKey
        table.clear(panel, 0, 0, 1, 7)
        table.merge_cells(panel, 0, 0, 1, 0)
        table.cell(panel, 0, 0, "AG Pro Volatility Expansion Planner", text_color = headerText, bgcolor = headerBg, text_size = f_label_size(panelSize), text_halign = text.align_center)
        f_set_row(panel, 1, "Workflow", workflowText, (expansionState == "WAIT" and cooldownActive) ? accentColor : stateColor, theme, panelSize)
        f_set_row(panel, 2, "Volatility State", atrRead, volatilityModeColor, theme, panelSize)
        f_set_row(panel, 3, "Expansion Score", scoreRead, stateColor, theme, panelSize)
        f_set_row(panel, 4, "Follow Proof", followRead, followColor, theme, panelSize)
        f_set_row(panel, 5, "Squeeze / Range", squeezeRead, activeSqueezeAge >= minimumSqueezeAge ? accentColor : neutralColor, theme, panelSize)
        f_set_row(panel, 6, "Shelf / Direction", shelfRead + " | " + (displayPlanDir == 1 ? "Long" : "Short"), displayShelfWeak ? neutralColor : (displayPlanDir == 1 ? bullColor : bearColor), theme, panelSize)
        f_set_row(panel, 7, "Review", reviewText + " / " + directionRead, expansionState == "WAIT" ? f_panel_value(theme) : stateColor, theme, panelSize)
    else
        if not na(panel)
            table.delete(panel)
            panel := na
            panelKey := ""

// -------------------------------------------------
// Alerts
// -------------------------------------------------
alertcondition(structuredEvent, title = "Structured Expansion", message = "Volatility Expansion Planner: structured expansion quality is active. This is an attention marker, not a trade instruction.")
alertcondition(watchEvent, title = "Expansion Watch", message = "Volatility Expansion Planner: expansion context is improving but confirmation is incomplete.")
alertcondition(noiseEvent, title = "Expansion Noise", message = "Volatility Expansion Planner: volatility expansion is hot or inefficient and may represent noise.")
alertcondition(riskReviewEvent, title = "Risk Shelf Review", message = "Volatility Expansion Planner: expansion is active but the risk shelf is too tight or too wide for clean planning.")
alertcondition(cooldownEvent, title = "Expansion Cooldown", message = "Volatility Expansion Planner: volatility remains elevated after a release and the context is in cooldown review.")
alertcondition(shelfCheckEvent, title = "Risk Shelf Check", message = "Volatility Expansion Planner: price crossed the prior risk shelf. Review the expansion context.")

if confirmedBar
    lastExpansionState := expansionState
````
