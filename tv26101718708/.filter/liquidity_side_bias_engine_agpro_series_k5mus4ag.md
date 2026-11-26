# Liquidity Side Bias Engine [AGPro Series]

- url: https://www.tradingview.com/script/K5MuS4Ag-Liquidity-Side-Bias-Engine-AGPro-Series/
- type: indicator
- pine_id: PUB;c8b3268fafb8432ea7fd26028b16364a
- version: 3.0

## Description

Liquidity Side Bias Engine [AGPro Series]


🧠 Core Idea

Which side of resting liquidity is the more likely near-term draw right now: the buy-side above, or the sell-side below?

This script is built to answer that one question with structure instead of guesswork.


📌 Overview / What It Does

Liquidity Side Bias Engine is a forward-looking, two-sided liquidity planner for smart-money and ICT-style analysis. Most price action leaves resting liquidity on both sides of the market: buy-side liquidity above old highs and equal highs, and sell-side liquidity below old lows and equal lows. At any moment, one of those two sides usually has the stronger pull. This tool maps the nearest untapped liquidity on each side and weighs it into a single, readable side lean.

Concretely, it identifies the closest buy-side pool above price and the closest sell-side pool below price from equal-highs and equal-lows clusters, the prior higher-timeframe high and low, and unmitigated swing points. It then scores each side from 0 to 100 using proximity, pool strength, trend context, and premium-discount range position, and reports which side is leaning, by how much, where the primary draw sits, and which opposite level would flip the read.

It does NOT predict price, generate buy or sell signals, or automate trades. It organizes a two-sided liquidity picture into a structured bias so the chart is easier to read and plan around. Every output is analytical context, not a recommendation.

[image]https://www.tradingview.com/x/Y4LNZKtK/[/image]

🎯 Purpose & Design Philosophy

Liquidity tools usually fall into two buckets: reactive sweep detectors that mark a liquidity grab after it already happened, and static maps that draw every pool on the chart and leave interpretation entirely to the trader. Both are useful, but neither answers the practical question a planner actually asks before the move: of the two sides, which one is the market more likely leaning toward next?

This engine was built to fill that gap. It is for the trader who already understands liquidity but wants a clean, consistent way to frame the two-sided picture without manually weighing five different factors on every chart. It supports a patient, context-first mindset: read the lean, understand why it leans, watch the primary draw and the flip level, and let broader market context confirm or deny the idea. The goal is intentional, structured thinking, not a shortcut around it.


⚡ Why This Script Is Different

Most liquidity tools focus on what already happened, marking sweeps and grabs after the candle closes, or they paint a dense map of every pool and stop there.

This script does NOT try to call tops and bottoms, does NOT fire trade signals, and does NOT bury the chart in unlabeled levels.

Instead, it looks forward. It treats buy-side and sell-side liquidity as a two-sided tug-of-war and resolves it into one lean score from 0 to 100, with a clear dominant side, a primary draw target, an opposite flip level, the pool type in play, and a premium-discount range read. The leaning side is drawn solid and emphasized; the opposite side is drawn faint as the flip reference. The result is a single, calm decision-support read instead of a wall of levels or a backward-looking alert.


⚙️ Methodology

1. Context Detection
An ATR baseline, an EMA trend backbone with a slope check, and a premium-discount dealing range are computed to describe the current environment.

2. Reference Mapping
The nearest untapped buy-side pool above price and sell-side pool below price are located from equal-highs and equal-lows clusters, the prior higher-timeframe high and low, and unmitigated swing points. The prior period adapts to the chart: prior day on intraday, prior week on daily, prior month on higher timeframes.

3. Reaction Evaluation
Each side is scored from 0 to 100 across four factors: proximity (closer pools pull more), pool strength (cluster size, prior-period magnetism, freshness), trend context (the direction-aligned side is weighted), and range position (discount weights the buy-side draw, premium weights the sell-side draw). The two scores are compared into a single lean; a small balance gap is treated as two-sided.

4. Visual Output
The leaning side, its primary draw, the opposite flip level, pool type, distance, and a next-action read are rendered into a clean panel, two side lines, a centered bias badge, and moderate alternating event labels.


🗺️ How to Read the Chart

- Side lines: the buy-side line sits above price, the sell-side line below. The leaning side is solid and bold; the opposite side is faint and dashed, marking the flip reference.
- Bias badge: a compact badge near current price shows the leaning state and its 0-100 score.
- Target tag: a single right-edge tag marks the primary draw price on the leaning side.
- Faint pool lines: lighter dotted lines show other untapped pools as a soft liquidity map.
- Labels: green relates to buy-side context, pink to sell-side context, amber to balanced.
- Panel: a fixed readout of state, bias score, primary draw, pool type, range, flip level, and action.


🚦 Signals & States

- Buy-Side Lean → buy-side liquidity above is currently the leaning near-term draw.
- Sell-Side Lean → sell-side liquidity below is currently the leaning near-term draw.
- Balanced → both sides are close in score; no clear leaning side.
- Buy-Side Taken / Sell-Side Taken → a liquidity side was traded through (mitigated).

These are interpretive states, not instructions. A Buy-Side Lean does not mean buy; it means the upside pool is the weighted draw in the current context.


🔔 Alerts Logic

Three optional alerts are available:
- Buy-Side Lean: triggers when the dominant side flips to buy-side above the active threshold.
- Sell-Side Lean: triggers when the dominant side flips to sell-side above the active threshold.
- Liquidity Side Taken: triggers when a buy-side or sell-side pool is traded through.

Alerts are attention markers that point you back to the chart for context. They are not trade instructions and carry no guarantee of any outcome.


🧩 Confluence Logic

The lean is itself a confluence read. When proximity, pool strength, trend alignment, and range position agree on one side, that side scores higher and the lean is more pronounced. When they disagree, the score stays moderate and the state may resolve to Balanced, which is information in itself: the two-sided picture is unresolved.


📊 When to Use

- Trending markets, to frame whether the trend-aligned liquidity remains the dominant draw.
- Ranging markets, to read which range extreme is the more likely draw from the current premium-discount position.
- Around prior-period highs and lows, to gauge which side carries the stronger pull.
- As a planning overlay alongside your own structure, entries, and risk framework.


⚠️ When NOT to Use

- In very low-liquidity symbols or sessions, where swing points and pools are unreliable.
- In extremely noisy or news-driven conditions, where levels are violated erratically.
- As a standalone entry trigger, or in isolation from market structure and risk context.
- On data with large gaps or thin history, where pool detection has too little to work with.


🎛️ Key Inputs

- Swing Strength: how strong a swing must be to qualify as a pool. Higher keeps only major swings.
- Pool Memory: how many recent swings are retained per side.
- Equal Level Tolerance: ATR width for grouping nearby levels into an equal-highs or equal-lows cluster.
- Use Prior-Period Pools: includes the adaptive prior-period high and low as pools.
- Trend Backbone EMA and Slope Bars: define the directional context weighting.
- Premium-Discount Range: lookback for the dealing range that drives the range-position factor.
- Max Draw Distance, Pool Freshness Window: shape how distance and age affect the score.
- Active Bias Score and Balanced Gap: thresholds for an active lean versus a balanced read.
- Visual, label, and panel controls: side lines, badge, target tag, pool map, label density, panel location, theme, and font size.


🖥️ Interface & Visual Design

The panel is the primary readout, leading with the leaning state and 0-100 score, then primary draw, pool type, premium-discount range, flip level, and a concise action line. On the chart, visual hierarchy favors the leaning side: it is solid and emphasized, while the opposite side stays faint. Labels are kept moderate and strictly alternating so the chart reads cleanly at a glance. Panel location, theme, and font size are adjustable; the panel is shown by default for readability.


🧪 Practical Usage Workflow

1. Read the panel: note the leaning state and the bias score.
2. Check the primary draw and the flip level: where is the weighted draw, and what would invalidate the read.
3. Read the premium-discount range line: is price in discount or premium, and how far is the draw in ATR.
4. Confirm with your own market structure, higher-timeframe context, and risk framework before any decision.


🔍 Interpretation Guidelines

Think of the lean as a weighted opinion about the two-sided liquidity picture, not a forecast. A higher score means the factors agree more strongly; a moderate score or a Balanced state means the picture is mixed and patience is warranted. The flip level is a structural reference, not a hard line. Always interpret the lean inside the broader market context rather than in isolation.


🚫 What This Script Is NOT

- It is NOT a prediction engine and does not forecast price direction.
- It is NOT financial advice or a recommendation to buy or sell.
- It is NOT an automated trading system.
- It does NOT produce guaranteed signals or outcomes.


⚠️ Limitations & Transparency

Outputs depend on detected swing structure and may differ across timeframes and symbols. Volatility, liquidity, and changing market conditions affect how pools form and how they are taken. Prior-period pools rely on higher-timeframe data and shift as new periods print. The tool describes current structure; it cannot know the future, and any level can be exceeded or fail to be reached.


🧠 Market Context Notes

Liquidity tends to rest where many participants place stops and pending orders: above equal highs, below equal lows, and around prior-period extremes. In an uptrend, price in discount often leans toward the buy-side draw above; in a downtrend, price in premium often leans toward the sell-side draw below. This engine encodes that two-sided logic into a single read, but market context always has the final word.


🧾 Use Case Examples

- Price is in discount within its range, trend is up, and the nearest buy-side pool is a prior-week high: the engine shows a Buy-Side Lean with the prior-week high as the primary draw.
- Price is in premium, momentum is fading, and equal lows rest below: the engine may show a Sell-Side Lean with those equal lows as the primary draw and a high above as the flip level.
- Both sides score closely: the engine reports Balanced, signaling an unresolved two-sided picture.


🧱 System Philosophy

This tool reflects the AGPro Series approach: convert a familiar but messy concept into a calm, structured, decision-support read. Liquidity is everywhere on a chart; the value is in organizing it into a single, honest lean that respects the trader's own judgment rather than replacing it.


🔐 Non-Promise Statement

This script makes no promise of profit, accuracy, or any specific result. It is an analytical and organizational tool. No certainty is offered or implied.


📉 Risk Disclosure

Trading involves substantial risk, and most participants can lose money. This script is provided for educational and analytical purposes only and does not constitute financial advice. All decisions, positions, and outcomes remain entirely your own responsibility. Always manage risk and trade within your own plan.


📚 Educational Note

Used as intended, the engine can sharpen how you think about two-sided liquidity: where it rests, which side is weighted, and what would change the picture. Treat it as a lens for structured analysis, and keep building your own market understanding alongside it.

## Source Code

````pine
// -------------------------------------------------
// Liquidity Side Bias Engine [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 1.3.0
//
// Liquidity Side Bias Engine is a forward-looking buy-side and sell-side
// liquidity bias planner for smart-money and ICT-style analysis. It maps the
// nearest untapped liquidity on each side (equal highs, equal lows, prior-period
// high and low, unmitigated swing points), then weighs proximity, pool strength,
// trend context, and premium-discount range position into a single 0-100 side
// lean: which side of liquidity is the more likely near-term draw. It shows the
// primary draw target, the opposite flip level, pool type, draw distance, and a
// clear next-action lean for patient two-sided liquidity planning.
// v1.2 shows both sides at the right edge at once: the leaning side as a solid
// draw tag and the opposite side as a faint flip reference, so the two-sided
// liquidity tug is readable at a glance.
// -------------------------------------------------

//@version=6
indicator("Liquidity Side Bias Engine [AGPro Series]",
     shorttitle       = "AG Pro LSB",
     overlay          = true,
     max_labels_count = 200,
     max_lines_count  = 100,
     max_boxes_count  = 30)

const string PANEL_QUESTION = "WHICH LIQUIDITY SIDE HOLDS THE EDGE?"

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
ttPivot = "Swing strength used to detect the highs and lows that become liquidity pools. Higher values keep only stronger, more meaningful swings."
ttPoolMemory = "How many recent swing highs and swing lows are retained as candidate liquidity pools. Older pools are dropped first."
ttEqTol = "ATR-based tolerance used to group nearby swing levels into an equal-highs or equal-lows liquidity cluster. Higher values merge levels more loosely."
ttUsePrior = "Includes the prior higher-timeframe high and low as significant liquidity pools. The period adapts to the chart: prior day on intraday charts, prior week on daily charts, and prior month on higher timeframes."
ttAtrLen = "ATR length used to normalize draw distance, pool tolerance, label offsets, and visual spacing."
ttTrendLen = "EMA backbone used to read directional context. The side aligned with the prevailing direction is weighted as a more likely draw."
ttSlopeBars = "Bars used to measure whether the trend backbone is rising or falling for the directional context score."
ttRangeLen = "Lookback used to build the premium-discount dealing range. Price in discount weights buy-side draw; price in premium weights sell-side draw."
ttMaxDist = "Distance in ATR beyond which a liquidity pool is treated as too far to act as an active near-term draw on that side."
ttFreshWin = "Window in bars used to fade older pools. More recently formed pools contribute a stronger side lean."
ttMinBias = "Minimum 0-100 side lean required before a side is treated as an active bias for alerts and emphasis."
ttBalanceTol = "Lean gap below which buy-side and sell-side are treated as balanced two-sided liquidity instead of one leaning side."
ttShowSides = "Shows both nearest liquidity side lines. The leaning side is drawn solid and emphasized; the opposite side is drawn faint as the flip reference."
ttShowBadge = "Shows the centered side-bias badge with the leaning side and its 0-100 lean score."
ttShowTarget = "Shows the primary draw tag on the leaning side and a faint flip tag on the opposite side at the right edge."
ttShowPools = "Shows faint reference lines for the other untapped liquidity pools on each side, as a light liquidity map."
ttMaxPools = "Maximum number of additional faint pool reference lines drawn per side."
ttProjection = "How far the side lines and bias badge extend to the right."
ttTagOffset = "Horizontal offset added beyond the projection for the right-edge target tag."
ttShowLabels = "Shows compact labels when the side lean flips or when a liquidity side is taken. Labels are offset away from candles."
ttLabelCooldown = "Minimum bars between event labels so the chart stays readable and premium."
ttMaxLabels = "Maximum number of recent event labels retained on the chart."
ttLabelOffset = "ATR-based vertical offset that keeps labels clear of candles."
ttLabelSize = "Font size for all on-chart labels and the bias badge. Normal is the recommended publication default."
ttShowPanel = "Shows or hides the AG Pro planning panel. It is shown by default for public-release readability."
ttPanelLocation = "Moves the AG Pro panel to the preferred chart location."
ttPanelTheme = "Switches the panel between AG Pro dark and clean light themes."
ttPanelFont = "Font size for the AG Pro panel. Normal is the recommended publication default."
ttAlerts = "Enables alert conditions for buy-side lean, sell-side lean, and liquidity-side-taken events."

// -------------------------------------------------
// Inputs
// -------------------------------------------------
gEngine = "Bias Engine"
pivotLen = input.int(8, "Swing Strength", minval = 2, maxval = 50, group = gEngine, tooltip = ttPivot)
poolMemory = input.int(20, "Pool Memory", minval = 6, maxval = 60, group = gEngine, tooltip = ttPoolMemory)
eqTol = input.float(0.45, "Equal Level Tolerance ATR", minval = 0.05, maxval = 2.00, step = 0.05, group = gEngine, tooltip = ttEqTol)
usePrior = input.bool(true, "Use Prior-Period Pools", group = gEngine, tooltip = ttUsePrior)
atrLen = input.int(14, "ATR Length", minval = 5, maxval = 100, group = gEngine, tooltip = ttAtrLen)
trendLen = input.int(55, "Trend Backbone EMA", minval = 5, maxval = 300, group = gEngine, tooltip = ttTrendLen)
slopeBars = input.int(5, "Trend Slope Bars", minval = 1, maxval = 30, group = gEngine, tooltip = ttSlopeBars)
rangeLen = input.int(60, "Premium-Discount Range", minval = 10, maxval = 400, group = gEngine, tooltip = ttRangeLen)

gScore = "Bias Scoring"
maxDist = input.float(10.0, "Max Draw Distance ATR", minval = 2.0, maxval = 30.0, step = 0.5, group = gScore, tooltip = ttMaxDist)
freshWin = input.int(120, "Pool Freshness Window", minval = 20, maxval = 500, group = gScore, tooltip = ttFreshWin)
minBiasScore = input.int(58, "Active Bias Score", minval = 30, maxval = 95, group = gScore, tooltip = ttMinBias)
balanceTol = input.int(8, "Balanced Gap", minval = 1, maxval = 30, group = gScore, tooltip = ttBalanceTol)

gVisual = "Chart Visuals"
showSides = input.bool(true, "Show Side Lines", group = gVisual, tooltip = ttShowSides)
showBadge = input.bool(true, "Show Bias Badge", group = gVisual, tooltip = ttShowBadge)
showTarget = input.bool(true, "Show Draw and Flip Tags", group = gVisual, tooltip = ttShowTarget)
showPools = input.bool(true, "Show Other Liquidity Pools", group = gVisual, tooltip = ttShowPools)
maxPools = input.int(2, "Pools Per Side", minval = 1, maxval = 5, group = gVisual, tooltip = ttMaxPools)
projectionBars = input.int(28, "Projection Bars", minval = 6, maxval = 120, group = gVisual, tooltip = ttProjection)
tagOffsetBars = input.int(3, "Target Tag Offset Bars", minval = 1, maxval = 30, group = gVisual, tooltip = ttTagOffset)

gLabels = "Labels"
showLabels = input.bool(true, "Show Event Labels", group = gLabels, tooltip = ttShowLabels)
labelCooldown = input.int(52, "Label Cooldown Bars", minval = 1, maxval = 80, group = gLabels, tooltip = ttLabelCooldown)
maxVisibleLabels = input.int(5, "Max Visible Labels", minval = 3, maxval = 40, group = gLabels, tooltip = ttMaxLabels)
labelOffsetAtr = input.float(0.65, "Label Offset ATR", minval = 0.0, maxval = 3.00, step = 0.05, group = gLabels, tooltip = ttLabelOffset)
labelSizeInput = input.string("Normal", "Label Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = gLabels, tooltip = ttLabelSize)

gPanel = "Panel"
showPanel = input.bool(true, "Show Panel", group = gPanel, tooltip = ttShowPanel)
panelLocationInput = input.string("Top Right", "Panel Location", options = ["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], group = gPanel, tooltip = ttPanelLocation)
panelThemeInput = input.string("Dark", "Panel Theme", options = ["Dark", "Light"], group = gPanel, tooltip = ttPanelTheme)
panelFontSizeInput = input.string("Normal", "Panel Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = gPanel, tooltip = ttPanelFont)

gAlerts = "Alerts"
alertLean = input.bool(true, "Alert on Side Lean", group = gAlerts, tooltip = ttAlerts)
alertTaken = input.bool(true, "Alert on Side Taken", group = gAlerts, tooltip = ttAlerts)

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
atr = math.max(nz(ta.atr(atrLen), ta.tr(true)), syminfo.mintick)
trendEma = ta.ema(close, trendLen)
trendSlope = trendEma - nz(trendEma[slopeBars], trendEma)
trendUp = close > trendEma and trendSlope > 0.0
trendDown = close < trendEma and trendSlope < 0.0
rangeLow = ta.lowest(low, rangeLen)
rangeHigh = ta.highest(high, rangeLen)
freshLow = ta.lowest(low, freshWin)
freshHigh = ta.highest(high, freshWin)
rangeSpan = math.max(rangeHigh - rangeLow, atr)
rangePos = f_clamp((close - rangeLow) / rangeSpan, 0.0, 1.0)

priorTF = timeframe.isintraday ? "D" : timeframe.isdaily ? "W" : "M"
priorName = timeframe.isintraday ? "Day" : timeframe.isdaily ? "Week" : "Month"
priorHigh = usePrior ? request.security(syminfo.tickerid, priorTF, high[1], lookahead = barmerge.lookahead_on) : na
priorLow = usePrior ? request.security(syminfo.tickerid, priorTF, low[1], lookahead = barmerge.lookahead_on) : na

// -------------------------------------------------
// Liquidity pool collection
// -------------------------------------------------
var array<float> swingHighPrice = array.new_float()
var array<int> swingHighBar = array.new_int()
var array<bool> swingHighTaken = array.new_bool()
var array<float> swingLowPrice = array.new_float()
var array<int> swingLowBar = array.new_int()
var array<bool> swingLowTaken = array.new_bool()

pivHigh = ta.pivothigh(high, pivotLen, pivotLen)
pivLow = ta.pivotlow(low, pivotLen, pivotLen)

if not na(pivHigh)
    array.push(swingHighPrice, pivHigh)
    array.push(swingHighBar, bar_index - pivotLen)
    array.push(swingHighTaken, false)
    if array.size(swingHighPrice) > poolMemory
        array.shift(swingHighPrice)
        array.shift(swingHighBar)
        array.shift(swingHighTaken)

if not na(pivLow)
    array.push(swingLowPrice, pivLow)
    array.push(swingLowBar, bar_index - pivotLen)
    array.push(swingLowTaken, false)
    if array.size(swingLowPrice) > poolMemory
        array.shift(swingLowPrice)
        array.shift(swingLowBar)
        array.shift(swingLowTaken)

// Mitigation: a high pool is taken once price trades through it; a low pool once price trades under it
takenBuy = false
takenSell = false
if array.size(swingHighPrice) > 0
    for i = 0 to array.size(swingHighPrice) - 1
        if not array.get(swingHighTaken, i) and high > array.get(swingHighPrice, i)
            array.set(swingHighTaken, i, true)
            takenBuy := true
if array.size(swingLowPrice) > 0
    for i = 0 to array.size(swingLowPrice) - 1
        if not array.get(swingLowTaken, i) and low < array.get(swingLowPrice, i)
            array.set(swingLowTaken, i, true)
            takenSell := true

// -------------------------------------------------
// Nearest untapped pool on each side (+ prior-period pools)
// -------------------------------------------------
float buyPoolPrice = na
int buyPoolBar = na
if array.size(swingHighPrice) > 0
    for i = 0 to array.size(swingHighPrice) - 1
        if not array.get(swingHighTaken, i) and array.get(swingHighPrice, i) > close
            if na(buyPoolPrice) or array.get(swingHighPrice, i) < buyPoolPrice
                buyPoolPrice := array.get(swingHighPrice, i)
                buyPoolBar := array.get(swingHighBar, i)

bool buyIsPrior = false
if not na(priorHigh) and priorHigh > close
    if na(buyPoolPrice) or priorHigh < buyPoolPrice
        buyPoolPrice := priorHigh
        buyPoolBar := na
        buyIsPrior := true

float sellPoolPrice = na
int sellPoolBar = na
if array.size(swingLowPrice) > 0
    for i = 0 to array.size(swingLowPrice) - 1
        if not array.get(swingLowTaken, i) and array.get(swingLowPrice, i) < close
            if na(sellPoolPrice) or array.get(swingLowPrice, i) > sellPoolPrice
                sellPoolPrice := array.get(swingLowPrice, i)
                sellPoolBar := array.get(swingLowBar, i)

bool sellIsPrior = false
if not na(priorLow) and priorLow < close
    if na(sellPoolPrice) or priorLow > sellPoolPrice
        sellPoolPrice := priorLow
        sellPoolBar := na
        sellIsPrior := true

// Equal-level cluster strength near each active pool
int buyTouches = 0
if not na(buyPoolPrice) and array.size(swingHighPrice) > 0
    for i = 0 to array.size(swingHighPrice) - 1
        if not array.get(swingHighTaken, i) and math.abs(array.get(swingHighPrice, i) - buyPoolPrice) <= eqTol * atr
            buyTouches += 1

int sellTouches = 0
if not na(sellPoolPrice) and array.size(swingLowPrice) > 0
    for i = 0 to array.size(swingLowPrice) - 1
        if not array.get(swingLowTaken, i) and math.abs(array.get(swingLowPrice, i) - sellPoolPrice) <= eqTol * atr
            sellTouches += 1

// -------------------------------------------------
// Side lean scoring (0-100 per side, forward draw lean)
// -------------------------------------------------
buyDistAtr = na(buyPoolPrice) ? na : (buyPoolPrice - close) / atr
sellDistAtr = na(sellPoolPrice) ? na : (close - sellPoolPrice) / atr

// Factor 1: proximity (closer pool = more likely first draw)
buyProx = na(buyDistAtr) ? 0.0 : f_clamp(100.0 - buyDistAtr / maxDist * 100.0, 0.0, 100.0)
sellProx = na(sellDistAtr) ? 0.0 : f_clamp(100.0 - sellDistAtr / maxDist * 100.0, 0.0, 100.0)

// Factor 2: pool strength (cluster touches + prior-period magnetism + freshness)
buyStrength = na(buyPoolPrice) ? 0.0 : f_clamp(buyTouches / 4.0 * 100.0, 0.0, 100.0)
buyStrength := buyIsPrior ? math.max(buyStrength, 72.0) : buyStrength
sellStrength = na(sellPoolPrice) ? 0.0 : f_clamp(sellTouches / 4.0 * 100.0, 0.0, 100.0)
sellStrength := sellIsPrior ? math.max(sellStrength, 72.0) : sellStrength
buyFresh = na(buyPoolBar) ? 62.0 : f_clamp(100.0 - (bar_index - buyPoolBar) / freshWin * 100.0, 0.0, 100.0)
sellFresh = na(sellPoolBar) ? 62.0 : f_clamp(100.0 - (bar_index - sellPoolBar) / freshWin * 100.0, 0.0, 100.0)
buyStrengthAdj = na(buyPoolPrice) ? 0.0 : buyStrength * 0.7 + buyFresh * 0.3
sellStrengthAdj = na(sellPoolPrice) ? 0.0 : sellStrength * 0.7 + sellFresh * 0.3

// Factor 3: trend context (the direction-aligned side is the weighted draw)
buyTrendBias = trendUp ? 100.0 : close > trendEma ? 64.0 : trendDown ? 28.0 : 50.0
sellTrendBias = trendDown ? 100.0 : close < trendEma ? 64.0 : trendUp ? 28.0 : 50.0

// Factor 4: premium-discount range position (discount -> buy-side draw, premium -> sell-side draw)
buyRangeBias = f_clamp(50.0 + (0.5 - rangePos) * 100.0, 0.0, 100.0)
sellRangeBias = f_clamp(50.0 + (rangePos - 0.5) * 100.0, 0.0, 100.0)

buyLean = na(buyPoolPrice) ? 0.0 : f_clamp(buyProx * 0.28 + buyStrengthAdj * 0.26 + buyTrendBias * 0.26 + buyRangeBias * 0.20, 0.0, 100.0)
sellLean = na(sellPoolPrice) ? 0.0 : f_clamp(sellProx * 0.28 + sellStrengthAdj * 0.26 + sellTrendBias * 0.26 + sellRangeBias * 0.20, 0.0, 100.0)

hasBuy = not na(buyPoolPrice)
hasSell = not na(sellPoolPrice)
hasAny = hasBuy or hasSell
biasTilt = buyLean - sellLean
biasSideCode = not hasAny ? 0 : math.abs(biasTilt) <= balanceTol ? 0 : biasTilt > 0 ? 1 : -1
domSide = buyLean >= sellLean ? 1 : -1

biasScore = biasSideCode == 1 ? int(math.round(buyLean)) : biasSideCode == -1 ? int(math.round(sellLean)) : int(math.round(math.max(buyLean, sellLean)))
activeBias = biasSideCode != 0 and biasScore >= minBiasScore
leanColor = biasSideCode == 1 ? bullColor : biasSideCode == -1 ? bearColor : neutralColor

// Primary draw (leaning side), opposite flip level, distance
primaryPrice = domSide == 1 ? buyPoolPrice : sellPoolPrice
oppositePrice = domSide == 1 ? sellPoolPrice : buyPoolPrice
flipPrice = na(oppositePrice) ? (domSide == 1 ? freshLow : freshHigh) : oppositePrice
primaryDistAtr = domSide == 1 ? buyDistAtr : sellDistAtr
domTouches = domSide == 1 ? buyTouches : sellTouches
domIsPrior = domSide == 1 ? buyIsPrior : sellIsPrior

// -------------------------------------------------
// Readout text
// -------------------------------------------------
stateText = not hasAny ? "No Liquidity" : biasSideCode == 1 ? "Buy-Side Lean" : biasSideCode == -1 ? "Sell-Side Lean" : "Balanced"
sideText = not hasAny ? "-" : biasSideCode == 1 ? "Upside" : biasSideCode == -1 ? "Downside" : "Both Sides"
actionText = not hasAny ? "Monitor" : biasSideCode == 1 ? "Watch Upside" : biasSideCode == -1 ? "Watch Downside" : "Wait Resolution"
poolTypeText = na(primaryPrice) ? "-" : domIsPrior ? (domSide == 1 ? "Prior " + priorName + " High" : "Prior " + priorName + " Low") : domTouches >= 3 ? (domSide == 1 ? "Equal Highs" : "Equal Lows") : domTouches == 2 ? (domSide == 1 ? "Double Top" : "Double Bottom") : (domSide == 1 ? "Swing High" : "Swing Low")
distText = na(primaryDistAtr) ? "-" : str.tostring(primaryDistAtr, "#.00") + " ATR"
scoreText = hasAny ? str.tostring(biasScore) + "/100" : "-"
zoneText = not hasAny ? "-" : rangePos < 0.5 ? "Discount" : rangePos > 0.5 ? "Premium" : "Equilibrium"

// -------------------------------------------------
// Event detection
// -------------------------------------------------
// Alert flip tracks the genuine dominant-side change, independent of label cooldown
var int lastAlertSide = 0
biasFlipAlert = barstate.isconfirmed and biasSideCode != 0 and biasSideCode != lastAlertSide and biasScore >= minBiasScore
if biasFlipAlert
    lastAlertSide := biasSideCode
sideTaken = barstate.isconfirmed and (takenBuy or takenSell)
takenIsBuy = takenBuy and not takenSell
takenSideCode = takenIsBuy ? 1 : -1

// -------------------------------------------------
// Visuals (two-sided liquidity tug)
// -------------------------------------------------
var line buyLine = na
var line sellLine = na
var label biasBadge = na
var label targetTag = na
var label flipTag = na
var array<line> poolLines = array.new_line()
var array<label> eventLabels = array.new_label()
var int lastLabelBar = na
var int lastLabelSide = 0
var int lastTakenSide = 0

if barstate.islast
    rightX = bar_index + projectionBars
    leftX = bar_index - math.min(projectionBars, 30)
    badgeX = bar_index + math.max(8, int(math.round(projectionBars * 0.58)))
    zonePad = atr * 0.10

    // Other untapped liquidity pools (faint reference map)
    if array.size(poolLines) > 0
        for i = 0 to array.size(poolLines) - 1
            line.delete(array.get(poolLines, i))
        array.clear(poolLines)

    if showPools
        int drawnBuy = 0
        if array.size(swingHighPrice) > 0
            for i = 0 to array.size(swingHighPrice) - 1
                if drawnBuy < maxPools and not array.get(swingHighTaken, i) and array.get(swingHighPrice, i) > close
                    lvl = array.get(swingHighPrice, i)
                    if na(buyPoolPrice) or math.abs(lvl - buyPoolPrice) > zonePad
                        ln = line.new(leftX, lvl, rightX, lvl, xloc = xloc.bar_index, color = color.new(bearColor, 74), style = line.style_dotted, width = 1)
                        array.push(poolLines, ln)
                        drawnBuy += 1
        int drawnSell = 0
        if array.size(swingLowPrice) > 0
            for i = 0 to array.size(swingLowPrice) - 1
                if drawnSell < maxPools and not array.get(swingLowTaken, i) and array.get(swingLowPrice, i) < close
                    lvl = array.get(swingLowPrice, i)
                    if na(sellPoolPrice) or math.abs(lvl - sellPoolPrice) > zonePad
                        ln = line.new(leftX, lvl, rightX, lvl, xloc = xloc.bar_index, color = color.new(bullColor, 74), style = line.style_dotted, width = 1)
                        array.push(poolLines, ln)
                        drawnSell += 1

    // Buy-side line (above). Solid + emphasized when buy-side leans; faint dashed otherwise.
    if showSides and hasBuy
        buyLeans = domSide == 1
        buyStyle = buyLeans ? line.style_solid : line.style_dashed
        buyWidth = buyLeans ? 2 : 1
        buyTransp = buyLeans ? 0 : 52
        if na(buyLine)
            buyLine := line.new(bar_index, buyPoolPrice, rightX, buyPoolPrice, xloc = xloc.bar_index, color = color.new(bullColor, buyTransp), style = buyStyle, width = buyWidth)
        else
            line.set_xy1(buyLine, bar_index, buyPoolPrice)
            line.set_xy2(buyLine, rightX, buyPoolPrice)
            line.set_color(buyLine, color.new(bullColor, buyTransp))
            line.set_style(buyLine, buyStyle)
            line.set_width(buyLine, buyWidth)
    else
        if not na(buyLine)
            line.delete(buyLine)
            buyLine := na

    // Sell-side line (below). Solid + emphasized when sell-side leans; faint dashed otherwise.
    if showSides and hasSell
        sellLeans = domSide == -1
        sellStyle = sellLeans ? line.style_solid : line.style_dashed
        sellWidth = sellLeans ? 2 : 1
        sellTransp = sellLeans ? 0 : 52
        if na(sellLine)
            sellLine := line.new(bar_index, sellPoolPrice, rightX, sellPoolPrice, xloc = xloc.bar_index, color = color.new(bearColor, sellTransp), style = sellStyle, width = sellWidth)
        else
            line.set_xy1(sellLine, bar_index, sellPoolPrice)
            line.set_xy2(sellLine, rightX, sellPoolPrice)
            line.set_color(sellLine, color.new(bearColor, sellTransp))
            line.set_style(sellLine, sellStyle)
            line.set_width(sellLine, sellWidth)
    else
        if not na(sellLine)
            line.delete(sellLine)
            sellLine := na

    // Centered bias badge between the two sides (to the right, clear of candles)
    if showBadge and hasAny
        midY = close
        badgeText = stateText + " • ACTIVE\nQ" + str.tostring(biasScore) + " • " + zoneText + " • " + distText
        if na(biasBadge)
            biasBadge := label.new(badgeX, midY, badgeText, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_center, color = color.new(leanColor, 0), textcolor = f_text_on(leanColor), size = labelSize, textalign = text.align_center)
        else
            label.set_xy(biasBadge, badgeX, midY)
            label.set_text(biasBadge, badgeText)
            label.set_color(biasBadge, color.new(leanColor, 0))
            label.set_textcolor(biasBadge, f_text_on(leanColor))
            label.set_size(biasBadge, labelSize)
    else
        if not na(biasBadge)
            label.delete(biasBadge)
            biasBadge := na

    // Right-edge primary draw tag on the leaning side (solid, emphasized)
    if showTarget and not na(primaryPrice)
        tagText = (domSide == 1 ? "BUY DRAW • " : "SELL DRAW • ") + f_price_text(primaryPrice)
        tagX = rightX + tagOffsetBars
        drawCol = domSide == 1 ? bullColor : bearColor
        if na(targetTag)
            targetTag := label.new(tagX, primaryPrice, tagText, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = color.new(drawCol, 0), textcolor = f_text_on(drawCol), size = labelSize)
        else
            label.set_xy(targetTag, tagX, primaryPrice)
            label.set_text(targetTag, tagText)
            label.set_color(targetTag, color.new(drawCol, 0))
            label.set_textcolor(targetTag, f_text_on(drawCol))
            label.set_size(targetTag, labelSize)
    else
        if not na(targetTag)
            label.delete(targetTag)
            targetTag := na

    // Right-edge flip tag on the opposite side (faint, the two-sided reference)
    if showTarget and not na(flipPrice)
        flipText = (domSide == 1 ? "SELL FLIP • " : "BUY FLIP • ") + f_price_text(flipPrice)
        flipTagX = rightX + tagOffsetBars
        flipCol = domSide == 1 ? bearColor : bullColor
        if na(flipTag)
            flipTag := label.new(flipTagX, flipPrice, flipText, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = color.new(flipCol, 18), textcolor = f_text_on(flipCol), size = labelSize)
        else
            label.set_xy(flipTag, flipTagX, flipPrice)
            label.set_text(flipTag, flipText)
            label.set_color(flipTag, color.new(flipCol, 18))
            label.set_textcolor(flipTag, f_text_on(flipCol))
            label.set_size(flipTag, labelSize)
    else
        if not na(flipTag)
            label.delete(flipTag)
            flipTag := na

// -------------------------------------------------
// Event labels (strict per-type alternation + shared cooldown)
// -------------------------------------------------
cooldownOk = na(lastLabelBar) or bar_index - lastLabelBar >= labelCooldown
leanLabelDue = barstate.isconfirmed and biasSideCode != 0 and biasSideCode != lastLabelSide and biasScore >= minBiasScore

if showLabels and leanLabelDue and cooldownOk
    flipUp = biasSideCode == 1
    flipText = flipUp ? "BUY-SIDE • LEAN" : "SELL-SIDE • LEAN"
    flipY = flipUp ? high + atr * labelOffsetAtr : low - atr * labelOffsetAtr
    flipStyle = flipUp ? label.style_label_down : label.style_label_up
    flipCol = flipUp ? bullColor : bearColor
    flipLabel = label.new(bar_index, flipY, flipText, xloc = xloc.bar_index, yloc = yloc.price, style = flipStyle, color = color.new(flipCol, 0), textcolor = f_text_on(flipCol), size = labelSize, textalign = text.align_center)
    f_keep_label(eventLabels, flipLabel, maxVisibleLabels)
    lastLabelSide := biasSideCode
    lastLabelBar := bar_index

if showLabels and sideTaken and takenSideCode != lastTakenSide and cooldownOk
    takenHi = takenIsBuy
    takenText = takenHi ? "BUY-SIDE • TAKEN" : "SELL-SIDE • TAKEN"
    takenY = takenHi ? high + atr * labelOffsetAtr : low - atr * labelOffsetAtr
    takenStyle = takenHi ? label.style_label_down : label.style_label_up
    takenCol = takenHi ? bullColor : bearColor
    takenLabel = label.new(bar_index, takenY, takenText, xloc = xloc.bar_index, yloc = yloc.price, style = takenStyle, color = color.new(takenCol, 0), textcolor = f_text_on(takenCol), size = labelSize, textalign = text.align_center)
    f_keep_label(eventLabels, takenLabel, maxVisibleLabels)
    lastTakenSide := takenSideCode
    lastLabelBar := bar_index

// -------------------------------------------------
// Panel
// -------------------------------------------------
var table panel = table.new(position.top_right, 2, 9, bgcolor = panelBg, frame_color = panelBorder, frame_width = 1, border_width = 1, border_color = panelBorder)
var bool panelHeaderMerged = false

if not panelHeaderMerged
    table.cell(panel, 0, 0, "", bgcolor = headerBg)
    table.cell(panel, 1, 0, "", bgcolor = headerBg)
    table.cell(panel, 0, 1, "", bgcolor = panelBg)
    table.cell(panel, 1, 1, "", bgcolor = panelBg)
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
        table.cell(panel, 0, 0, "AG Pro Liquidity Side Bias Engine", text_color = headerText, bgcolor = headerBg, text_size = f_label_size(panelFontSizeInput), text_halign = text.align_center)
        questionColor = panelThemeInput == "Light" ? color.rgb(67, 56, 202) : accentColor
        table.cell(panel, 0, 1, PANEL_QUESTION, text_color = questionColor, bgcolor = f_panel_bg(panelThemeInput, false), text_size = f_label_size(panelFontSizeInput), text_halign = text.align_center)
        valueColor = f_panel_value(panelThemeInput)
        focusColor = activeBias ? leanColor : neutralColor
        f_panel_focus_row(panel, 2, "State", stateText, focusColor, panelThemeInput, panelFontSizeInput)
        f_panel_row(panel, 3, "Bias Score", scoreText, activeBias ? leanColor : valueColor, panelThemeInput, panelFontSizeInput)
        f_panel_row(panel, 4, "Primary Draw", f_price_text(primaryPrice), leanColor, panelThemeInput, panelFontSizeInput)
        f_panel_row(panel, 5, "Pool Type", poolTypeText, valueColor, panelThemeInput, panelFontSizeInput)
        f_panel_row(panel, 6, "Range", zoneText + " | " + distText, valueColor, panelThemeInput, panelFontSizeInput)
        f_panel_row(panel, 7, "Flip Level", f_price_text(flipPrice), domSide == 1 ? bearColor : bullColor, panelThemeInput, panelFontSizeInput)
        f_panel_focus_row(panel, 8, "Action", actionText + " | " + sideText, focusColor, panelThemeInput, panelFontSizeInput)
    else
        table.clear(panel, 0, 0, 1, 8)

// -------------------------------------------------
// Alerts
// -------------------------------------------------
alertcondition(alertLean and biasFlipAlert and biasSideCode == 1, "Buy-Side Lean", "Liquidity Side Bias Engine: buy-side liquidity is the leaning near-term draw. Review the upside pool and broader market context.")
alertcondition(alertLean and biasFlipAlert and biasSideCode == -1, "Sell-Side Lean", "Liquidity Side Bias Engine: sell-side liquidity is the leaning near-term draw. Review the downside pool and broader market context.")
alertcondition(alertTaken and sideTaken, "Liquidity Side Taken", "Liquidity Side Bias Engine: a liquidity side was taken. Review whether price continues or reverses within broader context.")
````
