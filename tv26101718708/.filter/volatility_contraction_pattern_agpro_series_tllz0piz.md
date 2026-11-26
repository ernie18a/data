# Volatility Contraction Pattern [AGPro Series]

- url: https://www.tradingview.com/script/tLLz0piZ-Volatility-Contraction-Pattern-AGPro-Series/
- type: indicator
- pine_id: PUB;7b6f5b969bff4857a01811d189e31789
- version: 4.0

## Description

Volatility Contraction Pattern [AGPro Series]


🧠 Core Idea

Is volatility contracting into a tighter and tighter base that is coiling toward a breakout pivot, and how high-quality is that setup?

This script is built to answer that one question with structure instead of guesswork.


📌 Overview / What It Does

Volatility Contraction Pattern is a breakout-readiness decision engine built around the classic VCP structure: a base where price pulls back in successive, progressively shallower contractions, coiling into a breakout pivot. It reads the swing structure as a zigzag, measures each contraction leg, and counts how many recent legs are tightening into the present.

From that it builds a single 0-100 readiness score by weighing four things: how many successive contractions are present, how tight the latest contraction is relative to ATR, whether the base sits inside a constructive trend, and whether volume is drying up into the base. It then marks the pivot breakout level at the most recent swing high, a tight invalidation at the latest contraction low, a measured-move target projected from the base height, and a clear next-action state.

It does NOT predict price, generate buy or sell signals, or automate trades. It organizes the base-and-breakout picture into a structured, scored read so a contraction setup is easier to recognize and plan around. Every output is analytical context, not a recommendation.


🎯 Purpose & Design Philosophy

Most breakout tools react to a single breakout bar after it prints, or they mark a generic low-volatility squeeze and leave the rest to interpretation. Far fewer frame the multi-contraction base as a staged, scored readiness with a defined pivot and a tight, structural risk reference.

This engine was built to fill that gap. It is for the patient trader who prefers to wait for a proper base to form rather than chasing every move, and who values a tight, well-defined risk reference. It supports a base-and-breakout mindset: let the contraction sequence develop, read how ready and how tight it is, mark the pivot and the invalidation, and let broader market context confirm or deny the idea. The aim is structured patience, not a shortcut around it.


⚡ Why This Script Is Different

Most tools mark a single squeeze state or fire the instant a breakout bar appears.

This script does NOT call the breakout, does NOT fire trade signals, and does NOT treat one tight bar as a setup.

Instead, it stages the whole contraction sequence. It counts successive tightening legs, measures current tightness in ATR, and resolves the base into a 0-100 readiness score with a pivot breakout level, a tight invalidation at the latest contraction low, and a measured-move target. The result is a calm, structured base read with a defined risk reference, rather than a backward-looking alert or a single-bar trigger.


⚙️ Methodology

1. Context Detection
An ATR baseline and an EMA trend backbone with a slope check describe the current environment.

2. Structure Mapping
Swing highs and lows are tracked as an alternating zigzag. The amplitude of each recent leg is measured to describe the contraction sequence.

3. Contraction Evaluation
The engine counts how many successive legs are tightening into the present, measures the latest contraction tightness against ATR, checks trend context, and reads volume dry-up. These combine into a single 0-100 quality score, and the base resolves into a state.

4. Visual Output
The base zone, pivot breakout level, tight invalidation, measured-move target, a centered readiness badge, and moderate state labels are rendered cleanly on the chart and in the panel.


🗺️ How to Read the Chart

- Base zone: a shaded box spanning the contraction base from its low to its high, tinted by the current state.
- Pivot line and tag: the breakout level at the most recent swing high, the trigger reference.
- Invalidation line and tag: the latest contraction low, the tight structural risk reference.
- Target line and tag: the measured-move objective projected from the base height above the pivot.
- Readiness badge: centered inside the base zone, showing the state and its 0-100 score.
- State labels: compact markers when the pattern enters Pivot Ready, Breakout, or Reset.
- Panel: a fixed readout of state, quality score, pivot, target, contractions and tightness, invalidation, and action.


🚦 Signals & States

- No Base: not enough structure to define a contraction base.
- Base Forming: a base is developing but not yet tight or built enough.
- Coiling: successive contractions are tightening and readiness is building.
- Pivot Ready: the base is tight and near the pivot, with a qualifying score.
- Breakout: price has moved beyond the pivot level.
- Reset: the base was invalidated below its risk reference.

These are interpretive states, not instructions. Pivot Ready does not mean buy; it means the base is tight and near its trigger in the current context.


🔔 Alerts Logic

Three optional alerts are available:
- Pivot Ready: triggers when the base becomes pivot-ready.
- Breakout: triggers when price moves beyond the pivot.
- Pattern Reset: triggers when the base is invalidated.

Alerts are attention markers that point you back to the chart for context. They are not trade instructions and carry no guarantee of any outcome.


🧩 Confluence Logic

The score is itself a confluence read. When the contraction count, the latest-leg tightness, the trend context, and the volume dry-up all agree, the score is higher and the base is more pronounced. When they disagree, the score stays moderate and the state often remains Base Forming, which is information in itself: the base is not yet a clean contraction.


📊 When to Use

- After a strong move, when price begins to base and contract rather than trend.
- In constructive consolidations where pullbacks are getting shallower.
- As a continuation-base overlay alongside your own structure and risk framework.
- On liquid symbols with enough swing history for the structure to form.


⚠️ When NOT to Use

- In choppy markets with no clear base structure.
- In very low-liquidity symbols or sessions, where swings are unreliable.
- In extremely noisy conditions, where levels are violated erratically.
- As a standalone entry trigger, or in isolation from market context and risk.


🎛️ Key Inputs

- Swing Strength and Swing Memory: how swings are detected and how many are retained.
- Base Swing Window: how many recent swings define the active base.
- Trend Backbone EMA and Slope Bars: the trend-context weighting.
- Use Volume Dry-Up and its windows: whether and how decreasing volume contributes.
- Tightness Scale: the ATR reference for scoring contraction tightness.
- Pivot-Ready Score, Pivot Proximity, Ready Tightness: thresholds that define a pivot-ready base.
- Visual, label, and panel controls: base zone, pivot, target and invalidation lines and tags, label density, panel location, theme, and font size.


🖥️ Interface & Visual Design

The panel is the primary readout, leading with the state and 0-100 score, then pivot, target, contractions and tightness, invalidation, and a concise action line. On the chart, the base zone anchors the structure, the pivot and invalidation give the trigger and the tight risk, and the measured-move target frames the objective. The readiness badge sits centered inside the base so the read is tied to the structure. Labels are kept moderate and fire only on state transitions so the chart stays clean. Panel location, theme, and font size are adjustable; the panel is shown by default for readability.


🧪 Practical Usage Workflow

1. Read the panel: note the state and the quality score.
2. Check contractions and tightness: how many tightening legs, and how tight now.
3. Watch the pivot: the breakout reference at the top of the base.
4. Note the invalidation and target: the tight risk reference and the measured objective.
5. Confirm with your own market structure, higher-timeframe context, and risk framework before any decision.


🔍 Interpretation Guidelines

Think of the read as a staged base readiness, not a forecast. A higher score means more successive contractions, tighter current price action, and better trend and volume context. A moderate score or a Base Forming state means the base is not yet clean and patience is warranted. The invalidation is a structural reference, not a hard line. Always interpret the base inside the broader market context rather than in isolation.


🚫 What This Script Is NOT

- It is NOT a prediction engine and does not forecast price direction.
- It is NOT financial advice or a recommendation to buy or sell.
- It is NOT an automated trading system.
- It does NOT produce guaranteed signals or outcomes.


⚠️ Limitations & Transparency

Outputs depend on detected swing structure and may differ across timeframes and symbols. Volatility, liquidity, and changing market conditions affect how bases form and how they resolve. A base can break out, fail, or simply drift; the engine describes current structure and cannot know the future. Any pivot can be exceeded or fail to be reached, and any base can be invalidated.


🧠 Market Context Notes

Bases tend to form after directional moves, as participants pause and pullbacks get shallower. Classic contraction structure pairs successively tighter pullbacks with drying volume, often inside a constructive trend. This engine encodes that logic into a single staged read, but broader market context always has the final word, and a tight base is a condition, not a promise.


🧾 Use Case Examples

- After a strong advance, price bases with two or three progressively tighter pullbacks: the engine moves from Base Forming to Coiling and may reach Pivot Ready near the pivot.
- Volume dries up into a tight base inside an uptrend: the quality score rises as contraction, tightness, trend, and volume align.
- Price breaks below the latest contraction low: the engine reports Reset, signaling the contraction structure has invalidated.


🧱 System Philosophy

This tool reflects the AGPro Series approach: convert a familiar but messy concept into a calm, structured, decision-support read. A contraction base is easy to misjudge by eye; the value is in staging it into an honest, scored read with a defined risk reference, while respecting the trader's own judgment rather than replacing it.


🔐 Non-Promise Statement

This script makes no promise of profit, accuracy, or any specific result. It is an analytical and organizational tool. No certainty is offered or implied.


📉 Risk Disclosure

Trading involves substantial risk, and most participants can lose money. This script is provided for educational and analytical purposes only and does not constitute financial advice. All decisions, positions, and outcomes remain entirely your own responsibility. Always manage risk and trade within your own plan.


📚 Educational Note

Used as intended, the engine can sharpen how you think about contraction bases: how many tightening legs are present, how tight the base has become, where the pivot and the risk sit, and what would invalidate the structure. Treat it as a lens for structured analysis, and keep building your own market understanding alongside it.

## Source Code

````pine
// -------------------------------------------------
// Volatility Contraction Pattern [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 1.4.0
//
// Volatility Contraction Pattern is a breakout-readiness decision engine built
// around the classic VCP structure: a base of successive, progressively tighter
// price contractions that coil into a breakout pivot. It detects the contraction
// sequence from swing structure, counts the contraction legs, measures how tight
// the base has become, and weighs trend context and volume dry-up into a single
// 0-100 readiness score. It marks the pivot breakout level, a tight invalidation
// at the latest contraction low, a measured-move target, and a clear next-action
// state for patient base-and-breakout planning.
// v1.2 draws each contraction leg with its depth so the tightening sequence is
// readable at a glance, and tightens the base box to the actual coil.
// v1.3 adds owned, collision-resistant price lanes and a compact centered VCP
// identity while preserving the contraction, scoring, and state engines.
// v1.4.0 refines publication spacing, light-theme contrast, active-base identity,
// and panel hierarchy while preserving the VCP engine and alert conditions.
// -------------------------------------------------

//@version=6
indicator("Volatility Contraction Pattern [AGPro Series]",
     shorttitle       = "AG Pro VCP",
     overlay          = true,
     max_labels_count = 200,
     max_lines_count  = 100,
     max_boxes_count  = 30)

const string PANEL_QUESTION = "IS THIS CONTRACTION READY TO EXPAND?"

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
ttPivotLen = "Swing strength used to build the zigzag of swing highs and lows that defines each contraction leg. Higher values keep only stronger swings."
ttSwMemory = "How many recent alternating swing points are retained for contraction analysis. Older swings are dropped first."
ttBaseSwings = "Maximum number of recent swings the base can span. The active base is taken from the contraction sequence, capped by this value."
ttAtrLen = "ATR length used to normalize contraction tightness, distances, label offsets, and visual spacing."
ttTrendLen = "EMA backbone used for trend context. Contractions inside an established uptrend are weighted as higher quality."
ttSlopeBars = "Bars used to measure whether the trend backbone is rising or falling."
ttUseVolume = "Includes a volume dry-up factor in the score. Decreasing volume into the base is a classic contraction characteristic."
ttVolRecent = "Recent window used to measure current average volume for the dry-up comparison."
ttVolBase = "Longer base window used as the volume baseline for the dry-up comparison."
ttMaxTight = "Tightness scale in ATR. The latest contraction leg is scored against this; smaller legs relative to it score tighter."
ttReadyScore = "Minimum 0-100 readiness score required, together with proximity and tightness, to flag a Pivot Ready state."
ttReadyDist = "How close price must be to the pivot, in ATR, to be considered pivot-ready rather than still building."
ttTightReady = "Maximum latest-leg tightness in ATR allowed for a pivot-ready state. Tighter bases qualify; loose bases do not."
ttShowZone = "Shows the contraction base zone box from base low to base high."
ttShowContractions = "Shows a compact depth tag on each contraction low (C1, C2, ...), so the tightening sequence is visible at a glance."
ttShowPivot = "Shows the pivot breakout level line at the most recent swing high of the base."
ttShowTarget = "Shows the measured-move target projected from the base height above the pivot."
ttShowInvalid = "Shows the invalidation line at the latest contraction low, the tight structural risk reference."
ttProjection = "How far the zone, lines, and badge extend to the right."
ttTagOffset = "Horizontal offset beyond the projection for the owned pivot, target, and invalidation price badges."
ttShowLabels = "Shows compact state labels when the pattern enters Pivot Ready, Breakout, or Reset. Labels are offset away from candles."
ttLabelCooldown = "Minimum bars between state labels so the chart stays readable and premium."
ttMaxLabels = "Maximum number of recent state labels retained on the chart."
ttLabelOffset = "ATR-based vertical offset that keeps labels clear of candles."
ttLabelSize = "Font size for all on-chart labels and the readiness badge. Normal is the recommended publication default."
ttShowPanel = "Shows or hides the AG Pro planning panel. It is shown by default for public-release readability."
ttPanelLocation = "Moves the AG Pro panel to the preferred chart location."
ttPanelTheme = "Switches the panel between AG Pro dark and clean light themes."
ttPanelFont = "Font size for the AG Pro panel. Normal is the recommended publication default."
ttAlerts = "Enables alert conditions for Pivot Ready, Breakout, and Pattern Reset states."

// -------------------------------------------------
// Inputs
// -------------------------------------------------
gEngine = "Pattern Engine"
pivotLen = input.int(5, "Swing Strength", minval = 2, maxval = 50, group = gEngine, tooltip = ttPivotLen)
swMemory = input.int(14, "Swing Memory", minval = 6, maxval = 40, group = gEngine, tooltip = ttSwMemory)
baseSwings = input.int(6, "Base Swing Window", minval = 3, maxval = 14, group = gEngine, tooltip = ttBaseSwings)
atrLen = input.int(14, "ATR Length", minval = 5, maxval = 100, group = gEngine, tooltip = ttAtrLen)
trendLen = input.int(50, "Trend Backbone EMA", minval = 5, maxval = 300, group = gEngine, tooltip = ttTrendLen)
slopeBars = input.int(5, "Trend Slope Bars", minval = 1, maxval = 30, group = gEngine, tooltip = ttSlopeBars)
useVolume = input.bool(true, "Use Volume Dry-Up", group = gEngine, tooltip = ttUseVolume)
volRecentLen = input.int(10, "Volume Recent Window", minval = 3, maxval = 60, group = gEngine, tooltip = ttVolRecent)
volBaseLen = input.int(40, "Volume Base Window", minval = 10, maxval = 200, group = gEngine, tooltip = ttVolBase)

gScore = "Pattern Scoring"
maxTightAtr = input.float(6.0, "Tightness Scale ATR", minval = 1.0, maxval = 20.0, step = 0.5, group = gScore, tooltip = ttMaxTight)
readyScore = input.int(62, "Pivot-Ready Score", minval = 30, maxval = 95, group = gScore, tooltip = ttReadyScore)
readyDistAtr = input.float(3.0, "Pivot Proximity ATR", minval = 0.5, maxval = 15.0, step = 0.5, group = gScore, tooltip = ttReadyDist)
tightReadyAtr = input.float(3.0, "Ready Tightness ATR", minval = 0.5, maxval = 15.0, step = 0.5, group = gScore, tooltip = ttTightReady)

gVisual = "Chart Visuals"
showZone = input.bool(true, "Show Base Zone", group = gVisual, tooltip = ttShowZone)
showContractions = input.bool(true, "Show Contraction Depths", group = gVisual, tooltip = ttShowContractions)
showPivot = input.bool(true, "Show Pivot Level", group = gVisual, tooltip = ttShowPivot)
showTarget = input.bool(true, "Show Target", group = gVisual, tooltip = ttShowTarget)
showInvalidation = input.bool(true, "Show Invalidation", group = gVisual, tooltip = ttShowInvalid)
projectionBars = input.int(28, "Projection Bars", minval = 6, maxval = 120, group = gVisual, tooltip = ttProjection)
tagOffsetBars = input.int(3, "Pivot Tag Offset Bars", minval = 1, maxval = 30, group = gVisual, tooltip = ttTagOffset)

gLabels = "Labels"
showLabels = input.bool(true, "Show State Labels", group = gLabels, tooltip = ttShowLabels)
labelCooldown = input.int(52, "Label Cooldown Bars", minval = 1, maxval = 80, group = gLabels, tooltip = ttLabelCooldown)
maxVisibleLabels = input.int(5, "Max Visible Labels", minval = 3, maxval = 40, group = gLabels, tooltip = ttMaxLabels)
labelOffsetAtr = input.float(0.70, "Label Offset ATR", minval = 0.0, maxval = 3.00, step = 0.05, group = gLabels, tooltip = ttLabelOffset)
labelSizeInput = input.string("Normal", "Label Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = gLabels, tooltip = ttLabelSize)

gPanel = "Panel"
showPanel = input.bool(true, "Show Panel", group = gPanel, tooltip = ttShowPanel)
panelLocationInput = input.string("Top Right", "Panel Location", options = ["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], group = gPanel, tooltip = ttPanelLocation)
panelThemeInput = input.string("Dark", "Panel Theme", options = ["Dark", "Light"], group = gPanel, tooltip = ttPanelTheme)
panelFontSizeInput = input.string("Normal", "Panel Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = gPanel, tooltip = ttPanelFont)

gAlerts = "Alerts"
alertReady = input.bool(true, "Alert on Pivot Ready", group = gAlerts, tooltip = ttAlerts)
alertBreakout = input.bool(true, "Alert on Breakout", group = gAlerts, tooltip = ttAlerts)
alertReset = input.bool(true, "Alert on Reset", group = gAlerts, tooltip = ttAlerts)

// -------------------------------------------------
// Helpers
// -------------------------------------------------
f_clamp(float value, float minValue, float maxValue) =>
    math.min(math.max(value, minValue), maxValue)

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

f_panel_bg(string theme, bool alt) =>
    theme == "Light" ? (alt ? color.rgb(226, 232, 240) : color.rgb(241, 245, 249)) : (alt ? color.rgb(20, 31, 52) : panelBg)

f_panel_border(string theme) =>
    theme == "Light" ? color.rgb(148, 163, 184) : panelBorder

f_panel_label(string theme) =>
    theme == "Light" ? color.rgb(71, 85, 105) : panelLabelCol

f_panel_value(string theme) =>
    theme == "Light" ? color.rgb(15, 23, 42) : panelValueCol

f_text_on(color bgColor) =>
    bright = (color.r(bgColor) * 299 + color.g(bgColor) * 587 + color.b(bgColor) * 114) / 1000
    bright >= 145 ? color.rgb(15, 23, 42) : color.rgb(248, 250, 252)

f_price_text(float value) =>
    na(value) ? "-" : str.tostring(value, format.mintick)

f_panel_row(table target, int row, string leftText, string rightText, color rightColor, string theme, string fontSize) =>
    rowBg = f_panel_bg(theme, row % 2 == 0)
    table.cell(target, 0, row, leftText, text_color = f_panel_label(theme), bgcolor = rowBg, text_size = f_label_size(fontSize))
    table.cell(target, 1, row, rightText, text_color = rightColor, bgcolor = rowBg, text_size = f_label_size(fontSize), text_halign = text.align_right)

f_panel_focus_row(table target, int row, string leftText, string rightText, color focusColor, string theme, string fontSize) =>
    rowBg = f_panel_bg(theme, row % 2 == 0)
    table.cell(target, 0, row, leftText, text_color = f_panel_label(theme), bgcolor = rowBg, text_size = f_label_size(fontSize))
    table.cell(target, 1, row, rightText, text_color = f_text_on(focusColor), bgcolor = focusColor, text_size = f_label_size(fontSize), text_halign = text.align_center)

f_keep_label(array<label> labelArray, label labelId, int maxCount) =>
    array.push(labelArray, labelId)
    while array.size(labelArray) > maxCount
        oldLabel = array.shift(labelArray)
        label.delete(oldLabel)

// -------------------------------------------------
// Core context
// -------------------------------------------------
labelSize = f_label_size(labelSizeInput)
fontLaneMult = labelSizeInput == "Large" ? 1.55 : labelSizeInput == "Normal" ? 1.25 : labelSizeInput == "Small" ? 1.05 : 0.90
atr = math.max(nz(ta.atr(atrLen), ta.tr(true)), syminfo.mintick)
trendEma = ta.ema(close, trendLen)
trendSlope = trendEma - nz(trendEma[slopeBars], trendEma)
trendUp = close > trendEma and trendSlope > 0.0
trendDown = close < trendEma and trendSlope < 0.0
lowFallback = ta.lowest(low, 50)
volNow = ta.sma(volume, volRecentLen)
volBase = ta.sma(volume, volBaseLen)

// -------------------------------------------------
// Swing zigzag (alternating highs and lows)
// -------------------------------------------------
var array<float> swPrice = array.new_float()
var array<int> swBar = array.new_int()
var array<bool> swHigh = array.new_bool()

pivH = ta.pivothigh(high, pivotLen, pivotLen)
pivL = ta.pivotlow(low, pivotLen, pivotLen)

if not na(pivH)
    n0 = array.size(swPrice)
    if n0 > 0 and array.get(swHigh, n0 - 1)
        if pivH > array.get(swPrice, n0 - 1)
            array.set(swPrice, n0 - 1, pivH)
            array.set(swBar, n0 - 1, bar_index - pivotLen)
    else
        array.push(swPrice, pivH)
        array.push(swBar, bar_index - pivotLen)
        array.push(swHigh, true)
        if array.size(swPrice) > swMemory
            array.shift(swPrice)
            array.shift(swBar)
            array.shift(swHigh)

if not na(pivL)
    n1 = array.size(swPrice)
    if n1 > 0 and not array.get(swHigh, n1 - 1)
        if pivL < array.get(swPrice, n1 - 1)
            array.set(swPrice, n1 - 1, pivL)
            array.set(swBar, n1 - 1, bar_index - pivotLen)
    else
        array.push(swPrice, pivL)
        array.push(swBar, bar_index - pivotLen)
        array.push(swHigh, false)
        if array.size(swPrice) > swMemory
            array.shift(swPrice)
            array.shift(swBar)
            array.shift(swHigh)

// -------------------------------------------------
// Contraction sequence analysis
// -------------------------------------------------
n = array.size(swPrice)

float amp1 = na
float amp2 = na
float amp3 = na
float amp4 = na
if n >= 2
    amp1 := math.abs(array.get(swPrice, n - 1) - array.get(swPrice, n - 2))
if n >= 3
    amp2 := math.abs(array.get(swPrice, n - 2) - array.get(swPrice, n - 3))
if n >= 4
    amp3 := math.abs(array.get(swPrice, n - 3) - array.get(swPrice, n - 4))
if n >= 5
    amp4 := math.abs(array.get(swPrice, n - 4) - array.get(swPrice, n - 5))

// Newest leg is the tightest; count successive older legs that are larger (decreasing into the present)
int contractionCount = 0
if not na(amp1)
    contractionCount := 1
    if not na(amp2) and amp2 > amp1
        contractionCount := 2
        if not na(amp3) and amp3 > amp2
            contractionCount := 3
            if not na(amp4) and amp4 > amp3
                contractionCount := 4

latestLeg = amp1
tightness = na(latestLeg) ? na : latestLeg / atr

// Pivot (latest swing high) and latest contraction low
float pivot = na
float invalid = na
if n > 0
    for i = 0 to n - 1
        idx = n - 1 - i
        if array.get(swHigh, idx) and na(pivot)
            pivot := array.get(swPrice, idx)
        if not array.get(swHigh, idx) and na(invalid)
            invalid := array.get(swPrice, idx)

// Base taken from the actual contraction sequence (capped by the base window)
int coilSwings = math.min(math.max(contractionCount + 1, 3), baseSwings)
int lookSw = int(math.min(n, coilSwings))
float baseHigh = na
float baseLow = na
int baseStartBar = na
if lookSw > 0
    for i = 0 to lookSw - 1
        idx = n - 1 - i
        pr = array.get(swPrice, idx)
        baseHigh := na(baseHigh) or pr > baseHigh ? pr : baseHigh
        baseLow := na(baseLow) or pr < baseLow ? pr : baseLow
        baseStartBar := array.get(swBar, idx)
baseHeight = na(baseHigh) or na(baseLow) ? na : math.max(baseHigh - baseLow, atr)

invalidationPrice = not na(invalid) and invalid < close ? invalid : (not na(baseLow) and baseLow < close ? baseLow : lowFallback)
targetPrice = na(pivot) or na(baseHeight) ? na : pivot + baseHeight

// -------------------------------------------------
// Quality score (0-100)
// -------------------------------------------------
contractionScore = f_clamp(contractionCount / 3.0 * 100.0, 0.0, 100.0)
tightnessScore = na(tightness) ? 0.0 : f_clamp(100.0 - tightness / maxTightAtr * 100.0, 0.0, 100.0)
trendScore = trendUp ? 100.0 : close > trendEma ? 64.0 : trendDown ? 28.0 : 50.0
volRatio = na(volBase) or volBase == 0.0 ? 1.0 : volNow / volBase
volScore = useVolume ? f_clamp(100.0 - (volRatio - 0.5) * 100.0, 0.0, 100.0) : 50.0

hasBase = n >= 3 and not na(pivot) and not na(invalid) and not na(baseHigh) and not na(baseLow)
qualityScore = hasBase ? int(math.round(contractionScore * 0.30 + tightnessScore * 0.28 + trendScore * 0.24 + volScore * 0.18)) : 0

// -------------------------------------------------
// State machine
// -------------------------------------------------
brokeUp = hasBase and close > pivot
brokeDown = hasBase and close < invalidationPrice
nearPivot = hasBase and not brokeUp and (pivot - close) <= readyDistAtr * atr
tightOk = not na(tightness) and tightness <= tightReadyAtr

state = not hasBase ? "No Base" : brokeDown ? "Reset" : brokeUp ? "Breakout" : (qualityScore >= readyScore and nearPivot and tightOk) ? "Pivot Ready" : contractionCount >= 2 ? "Coiling" : "Base Forming"

stateColor = state == "Breakout" ? bullColor : state == "Pivot Ready" ? accentColor : state == "Reset" ? bearColor : state == "Coiling" ? neutralColor : panelValueCol

// -------------------------------------------------
// Readout text
// -------------------------------------------------
scoreText = hasBase ? str.tostring(qualityScore) + "/100" : "-"
pivotText = f_price_text(pivot)
targetText = f_price_text(targetPrice)
contractionText = hasBase ? str.tostring(contractionCount) + " | " + (na(tightness) ? "-" : str.tostring(tightness, "#.00") + " ATR") : "-"
invalidationText = f_price_text(invalidationPrice)
actionText = state == "Breakout" ? "Watch Follow-Through" : state == "Pivot Ready" ? "Watch Pivot" : state == "Reset" ? "Wait Reset" : state == "Coiling" ? "Build" : "Monitor"

// -------------------------------------------------
// Visuals
// -------------------------------------------------
var box baseZone = na
var line pivotLine = na
var line invalidLine = na
var line targetLine = na
var label readyBadge = na
var label pivotTag = na
var label targetTag = na
var label invalidTag = na
var line pivotLead = na
var line targetLead = na
var line invalidLead = na
var array<label> coilTags = array.new_label()

if barstate.islast
    rightX = bar_index + projectionBars
    leadX = math.max(bar_index + 1, rightX - 5)
    tagX = rightX + tagOffsetBars
    railLaneStep = math.max(atr * 0.42 * fontLaneMult, syminfo.mintick * 20.0)
    pivotInvalidClose = hasBase and not na(pivot) and not na(invalidationPrice) and math.abs(pivot - invalidationPrice) < railLaneStep * 2.20
    pivotTagY = pivotInvalidClose ? pivot + railLaneStep : pivot
    invalidTagY = pivotInvalidClose ? invalidationPrice - railLaneStep : invalidationPrice
    targetPivotClose = hasBase and not na(targetPrice) and not na(pivotTagY) and math.abs(targetPrice - pivotTagY) < railLaneStep * 2.20
    targetTagY = targetPivotClose ? targetPrice + railLaneStep : targetPrice
    showBase = hasBase and showZone and not na(baseStartBar)

    // Base zone box
    if showBase
        zoneFill = color.new(stateColor, panelThemeInput == "Light" ? 82 : 88)
        zoneBorder = color.new(stateColor, panelThemeInput == "Light" ? 30 : 55)
        if na(baseZone)
            baseZone := box.new(baseStartBar, baseHigh, rightX, baseLow, xloc = xloc.bar_index, border_color = zoneBorder, border_width = 1, bgcolor = zoneFill)
        else
            box.set_lefttop(baseZone, baseStartBar, baseHigh)
            box.set_rightbottom(baseZone, rightX, baseLow)
            box.set_border_color(baseZone, zoneBorder)
            box.set_bgcolor(baseZone, zoneFill)
    else
        if not na(baseZone)
            box.delete(baseZone)
            baseZone := na

    // Pivot breakout level
    if hasBase and showPivot and not na(pivot)
        pivStart = na(baseStartBar) ? bar_index - projectionBars : baseStartBar
        if na(pivotLine)
            pivotLine := line.new(pivStart, pivot, leadX, pivot, xloc = xloc.bar_index, color = color.new(accentColor, 0), style = line.style_solid, width = 2)
        else
            line.set_xy1(pivotLine, pivStart, pivot)
            line.set_xy2(pivotLine, leadX, pivot)
    else
        if not na(pivotLine)
            line.delete(pivotLine)
            pivotLine := na

    // Invalidation (latest contraction low)
    if hasBase and showInvalidation and not na(invalidationPrice)
        invStart = na(baseStartBar) ? bar_index - projectionBars : baseStartBar
        if na(invalidLine)
            invalidLine := line.new(invStart, invalidationPrice, leadX, invalidationPrice, xloc = xloc.bar_index, color = color.new(bearColor, 25), style = line.style_dashed, width = 1)
        else
            line.set_xy1(invalidLine, invStart, invalidationPrice)
            line.set_xy2(invalidLine, leadX, invalidationPrice)
            line.set_color(invalidLine, color.new(bearColor, 25))
    else
        if not na(invalidLine)
            line.delete(invalidLine)
            invalidLine := na

    // Measured-move target
    if hasBase and showTarget and not na(targetPrice)
        if na(targetLine)
            targetLine := line.new(bar_index, targetPrice, leadX, targetPrice, xloc = xloc.bar_index, color = color.new(bullColor, 45), style = line.style_dotted, width = 1)
        else
            line.set_xy1(targetLine, bar_index, targetPrice)
            line.set_xy2(targetLine, leadX, targetPrice)
            line.set_color(targetLine, color.new(bullColor, 45))
    else
        if not na(targetLine)
            line.delete(targetLine)
            targetLine := na

    // Readiness badge centered inside the base zone
    if hasBase and showZone and not na(baseStartBar)
        badgeX = int(math.round((baseStartBar + rightX) / 2.0))
        badgeY = (baseHigh + baseLow) / 2.0
        badgeTightness = na(tightness) ? "-" : str.tostring(tightness, "#.00") + " ATR"
        badgeText = "VCP • " + str.upper(state) + "\nQ" + str.tostring(qualityScore) + " • C" + str.tostring(contractionCount) + " • " + badgeTightness
        if na(readyBadge)
            readyBadge := label.new(badgeX, badgeY, badgeText, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_center, color = color.new(stateColor, 0), textcolor = f_text_on(stateColor), size = labelSize, textalign = text.align_center)
        else
            label.set_xy(readyBadge, badgeX, badgeY)
            label.set_text(readyBadge, badgeText)
            label.set_color(readyBadge, color.new(stateColor, 0))
            label.set_textcolor(readyBadge, f_text_on(stateColor))
            label.set_size(readyBadge, labelSize)
    else
        if not na(readyBadge)
            label.delete(readyBadge)
            readyBadge := na

    // Contraction depth tags (the tightening sequence) - the VCP signature
    if array.size(coilTags) > 0
        for ci = 0 to array.size(coilTags) - 1
            label.delete(array.get(coilTags, ci))
        array.clear(coilTags)
    if hasBase and showContractions and n >= 3
        int startIdx = math.max(n - lookSw, 1)
        int cNum = 0
        for idx = startIdx to n - 1
            if not array.get(swHigh, idx) and array.get(swHigh, idx - 1)
                float hiP = array.get(swPrice, idx - 1)
                float loP = array.get(swPrice, idx)
                int loBar = array.get(swBar, idx)
                if hiP > loP and hiP > 0.0
                    cNum += 1
                    float depthPct = (hiP - loP) / hiP * 100.0
                    string cTxt = "C" + str.tostring(cNum) + " • " + str.tostring(depthPct, "#.0") + "%"
                    float coilLane = labelOffsetAtr + 0.45 + (cNum - 1) % 3 * 0.75 * fontLaneMult
                    label cl = label.new(loBar, loP - atr * coilLane, cTxt, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_up, color = color.new(accentColor, 0), textcolor = f_text_on(accentColor), size = labelSize)
                    array.push(coilTags, cl)

    // Right-edge pivot tag
    if hasBase and showPivot and not na(pivot)
        tagText = "PIVOT " + f_price_text(pivot)
        if na(pivotLead)
            pivotLead := line.new(leadX, pivot, rightX, pivotTagY, xloc = xloc.bar_index, color = color.new(accentColor, 0), width = 2)
        else
            line.set_xy1(pivotLead, leadX, pivot)
            line.set_xy2(pivotLead, rightX, pivotTagY)
        if na(pivotTag)
            pivotTag := label.new(tagX, pivotTagY, tagText, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = color.new(accentColor, 0), textcolor = f_text_on(accentColor), size = labelSize)
        else
            label.set_xy(pivotTag, tagX, pivotTagY)
            label.set_text(pivotTag, tagText)
            label.set_size(pivotTag, labelSize)
    else
        if not na(pivotLead)
            line.delete(pivotLead)
            pivotLead := na
        if not na(pivotTag)
            label.delete(pivotTag)
            pivotTag := na

    // Right-edge target tag
    if hasBase and showTarget and not na(targetPrice)
        tTagText = "TARGET " + f_price_text(targetPrice)
        if na(targetLead)
            targetLead := line.new(leadX, targetPrice, rightX, targetTagY, xloc = xloc.bar_index, color = color.new(bullColor, 15), width = 2)
        else
            line.set_xy1(targetLead, leadX, targetPrice)
            line.set_xy2(targetLead, rightX, targetTagY)
        if na(targetTag)
            targetTag := label.new(tagX, targetTagY, tTagText, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = color.new(bullColor, 0), textcolor = f_text_on(bullColor), size = labelSize)
        else
            label.set_xy(targetTag, tagX, targetTagY)
            label.set_text(targetTag, tTagText)
            label.set_size(targetTag, labelSize)
    else
        if not na(targetLead)
            line.delete(targetLead)
            targetLead := na
        if not na(targetTag)
            label.delete(targetTag)
            targetTag := na

    // Right-edge invalidation tag
    if hasBase and showInvalidation and not na(invalidationPrice)
        iTagText = "INVALID " + f_price_text(invalidationPrice)
        if na(invalidLead)
            invalidLead := line.new(leadX, invalidationPrice, rightX, invalidTagY, xloc = xloc.bar_index, color = color.new(bearColor, 0), width = 2)
        else
            line.set_xy1(invalidLead, leadX, invalidationPrice)
            line.set_xy2(invalidLead, rightX, invalidTagY)
        if na(invalidTag)
            invalidTag := label.new(tagX, invalidTagY, iTagText, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = color.new(bearColor, 0), textcolor = f_text_on(bearColor), size = labelSize)
        else
            label.set_xy(invalidTag, tagX, invalidTagY)
            label.set_text(invalidTag, iTagText)
            label.set_size(invalidTag, labelSize)
    else
        if not na(invalidLead)
            line.delete(invalidLead)
            invalidLead := na
        if not na(invalidTag)
            label.delete(invalidTag)
            invalidTag := na

// -------------------------------------------------
// State labels (transition only + cooldown)
// -------------------------------------------------
var array<label> eventLabels = array.new_label()
var int lastLabelBar = na
var string prevState = ""
var int eventLane = 0

cooldownOk = na(lastLabelBar) or bar_index - lastLabelBar >= labelCooldown
meaningful = state == "Pivot Ready" or state == "Breakout" or state == "Reset"
stateEntered = barstate.isconfirmed and state != prevState
enteredReady = stateEntered and state == "Pivot Ready"
enteredBreakout = stateEntered and state == "Breakout"
enteredReset = stateEntered and state == "Reset"
labelDue = barstate.isconfirmed and meaningful and state != prevState

if showLabels and labelDue and cooldownOk
    isDown = state == "Reset"
    eventLane := (eventLane + 1) % 2
    eventGap = labelOffsetAtr + 0.24 + eventLane * 0.40 * fontLaneMult
    labY = isDown ? low - atr * eventGap : high + atr * eventGap
    labStyle = isDown ? label.style_label_up : label.style_label_down
    labCol = stateColor
    evLabel = label.new(bar_index, labY, str.upper(state), xloc = xloc.bar_index, yloc = yloc.price, style = labStyle, color = color.new(labCol, 0), textcolor = f_text_on(labCol), size = labelSize, textalign = text.align_center)
    f_keep_label(eventLabels, evLabel, maxVisibleLabels)
    lastLabelBar := bar_index

if barstate.isconfirmed
    prevState := state

// -------------------------------------------------
// Panel
// -------------------------------------------------
var table panel = table.new(position.top_right, 2, 9, bgcolor = panelBg, frame_color = panelBorder, frame_width = 1, border_width = 1, border_color = panelBorder)
var bool panelHeaderMerged = false

if not panelHeaderMerged
    table.cell(panel, 0, 0, "")
    table.cell(panel, 1, 0, "")
    table.cell(panel, 0, 1, "")
    table.cell(panel, 1, 1, "")
    table.merge_cells(panel, 0, 0, 1, 0)
    table.merge_cells(panel, 0, 1, 1, 1)
    panelHeaderMerged := true

if barstate.islast
    table.set_position(panel, f_panel_position(panelLocationInput))
    table.set_frame_color(panel, f_panel_border(panelThemeInput))
    table.set_border_color(panel, f_panel_border(panelThemeInput))
    if showPanel
        table.clear(panel, 0, 0, 1, 8)
        table.merge_cells(panel, 0, 0, 1, 0)
        table.merge_cells(panel, 0, 1, 1, 1)
        table.cell(panel, 0, 0, "AG Pro Volatility Contraction Pattern", text_color = headerText, bgcolor = headerBg, text_size = f_label_size(panelFontSizeInput), text_halign = text.align_center)
        valueColor = f_panel_value(panelThemeInput)
        questionColor = panelThemeInput == "Light" ? color.rgb(49, 46, 129) : color.rgb(165, 180, 252)
        table.cell(panel, 0, 1, PANEL_QUESTION, text_color = questionColor, bgcolor = f_panel_bg(panelThemeInput, false), text_size = f_label_size(panelFontSizeInput), text_halign = text.align_center)
        f_panel_focus_row(panel, 2, "State", state, stateColor, panelThemeInput, panelFontSizeInput)
        f_panel_row(panel, 3, "Quality Score", scoreText, hasBase and qualityScore >= readyScore ? stateColor : valueColor, panelThemeInput, panelFontSizeInput)
        f_panel_row(panel, 4, "Pivot", pivotText, accentColor, panelThemeInput, panelFontSizeInput)
        f_panel_row(panel, 5, "Target", targetText, bullColor, panelThemeInput, panelFontSizeInput)
        f_panel_row(panel, 6, "Contractions", contractionText, valueColor, panelThemeInput, panelFontSizeInput)
        f_panel_row(panel, 7, "Invalidation", invalidationText, bearColor, panelThemeInput, panelFontSizeInput)
        f_panel_focus_row(panel, 8, "Action", actionText, stateColor, panelThemeInput, panelFontSizeInput)
    else
        table.clear(panel, 0, 0, 1, 8)

// -------------------------------------------------
// Alerts
// -------------------------------------------------
alertcondition(alertReady and enteredReady, "Pivot Ready", "Volatility Contraction Pattern: the base is pivot-ready. Review the pivot level, tightness, and broader market context.")
alertcondition(alertBreakout and enteredBreakout, "Breakout", "Volatility Contraction Pattern: price moved beyond the pivot. Review follow-through within broader market context.")
alertcondition(alertReset and enteredReset, "Pattern Reset", "Volatility Contraction Pattern: the base was invalidated. The contraction structure has reset.")
````
