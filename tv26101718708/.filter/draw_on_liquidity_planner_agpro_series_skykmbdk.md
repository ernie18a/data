# Draw On Liquidity Planner [AGPro Series]

- url: https://www.tradingview.com/script/skYKmBdk-Draw-On-Liquidity-Planner-AGPro-Series/
- type: indicator
- pine_id: PUB;feff34c91a2249e39d0a38bcc315bbaa
- version: 4.0

## Description

Draw On Liquidity Planner [AGPro Series]


🧠 Core Idea

Of all the liquidity resting around price, which single pool is the dominant draw right now, how strong is that draw, and what level would put it in question?


📌 Overview / What It Does

Draw On Liquidity Planner is a chart-first liquidity decision tool. Instead of drawing every high and low on the screen, it studies the untapped liquidity pools sitting on both sides of price and decides which one is acting as the dominant "draw on liquidity," then frames a complete read around it.

It maps buy-side liquidity above price and sell-side liquidity below price from three sources: clusters of equal highs and equal lows, the prior higher-timeframe high and low, and unmitigated swing points. It tracks which pools are still untapped and which have already been swept. It then scores each side from 0 to 100 and selects the single dominant draw, presenting a clear state, the target pool price, the draw distance in ATR, the pool type, a structural invalidation reference, and a plain next-action read in a clean panel.

The script does not predict price, generate buy or sell signals, or automate trades. It organizes scattered liquidity into one structured draw decision so the chart can be read with intent instead of guesswork.


🎯 Purpose & Design Philosophy

This planner was built to close a specific gap. Many liquidity tools fall into one of two traps: they map every level at once until the chart is unreadable, or they only flag a sweep after it has already happened. Neither answers the first question a liquidity-focused trader actually asks: of everything resting around price, which side is the real magnet, and how convinced should I be?

Draw On Liquidity Planner is designed for patient, context-driven traders who think in terms of where liquidity rests and where price is being pulled. It supports a planning mindset rather than a reflex: identify the dominant draw, note the target and the invalidation, gauge conviction from the score, and then wait for the market to confirm or reject that context. It is a decision-support layer, not a trigger.


⚡ Why This Script Is Different

Most liquidity tools either print a dense map of every swing high and low, or they detect a sweep only once it is complete and leave the interpretation to you.

This script does NOT flood the chart with every level, and it does NOT claim to know the next move.

Instead, it ranks both sides of liquidity into a single dominant draw with a transparent 0-100 score, shows one clean target, one structural invalidation, and a light reference map of the remaining pools, and keeps the detailed read in a premium panel so the price area stays clear. The decision layer — which side, how strong, what would invalidate it — is the product. The raw levels are just the inputs.


⚙️ Methodology

The internal logic runs in clear, rule-based steps:

1. Pool Detection
Swing highs and swing lows are detected with an adjustable swing strength and stored as candidate liquidity pools. The prior higher-timeframe high and low can be included as significant pools, and the period adapts to the chart: prior day on intraday charts, prior week on daily charts, and prior month on higher timeframes.

2. Mitigation Tracking
A buy-side pool is marked as taken once price trades through it, and a sell-side pool once price trades under it. Only untapped liquidity is treated as an active draw, so the read reflects what is still resting rather than what has already been consumed.

3. Cluster Evaluation
Nearby untapped levels are grouped using an ATR-based tolerance to recognize equal highs and equal lows. More touches at a level mean stronger resting liquidity, which contributes a higher draw quality.

4. Draw Scoring
Each side receives a 0-100 score built from four components: pool quality (cluster strength and prior-period status), proximity in ATR, directional context from a trend backbone, and pool freshness. The weighting favors quality and proximity while still respecting trend alignment and how recently the pool formed.

5. Dominant Draw Selection
The higher-scoring side becomes the active draw. When the two sides are close, the context is treated as balanced two-sided liquidity rather than forcing a single direction.

6. Visual Output
The active draw is drawn as a thin highlighted zone with a centered badge, a target line, a structural invalidation line, a light reference map of the remaining pools, a single right-edge target tag, and a complete summary panel.


🗺️ How to Read the Chart

- Draw Zone: the thin highlighted band around the dominant liquidity target, with a centered badge showing the state and the 0-100 score.
- Target Line: the solid line at the active draw pool price.
- Invalidation Line: the dashed line at the opposite-side structural reference (the nearest swing on the other side); losing that level weakens the current draw lean.
- Faint Pool Lines: dotted reference lines marking the other untapped pools on each side, as a light liquidity map.
- Target Tag: a single right-edge tag with the active draw target price.
- Event Labels: compact markers that print when the dominant draw flips side or when a liquidity pool is swept. They alternate by side and stay clear of the candles.
- Panel: state, draw score, target, distance, pool type, invalidation, and action.

Colors follow the AG Pro palette: teal for buy-side draws, pink for sell-side draws, and amber for balanced or lower-conviction context.


🚦 Signals & States

• Buy-Side Draw → untapped liquidity above is the dominant magnet
• Sell-Side Draw → untapped liquidity below is the dominant magnet
• Two-Sided → both sides are roughly balanced, with no single dominant draw
• No Draw → no qualifying untapped pool is currently in range

States describe liquidity context only. They are not trade instructions and carry no guarantee of direction.


🔔 Alerts Logic

Alerts are available for:

- Buy-Side Draw: the dominant draw establishes on the buy side with a qualifying score
- Sell-Side Draw: the dominant draw establishes on the sell side with a qualifying score
- Liquidity Pool Swept: a tracked pool is traded through

Alerts are attention markers that flag a change in liquidity context. They are not signals to enter or exit a position, and each alert should be interpreted within the broader market picture.


🧩 Confluence Logic

The draw score is itself a confluence measure. A high score means pool quality, proximity, directional context, and freshness are aligning on the same side. When the active draw also agrees with your higher-timeframe bias and the prevailing structure, the context is stronger. When they disagree, the read deserves more caution, and the score will usually reflect that with a lower value.


📊 When to Use

• Trending markets, where price tends to reach for liquidity in the direction of the trend
• Range edges, where equal highs or equal lows build obvious resting liquidity
• Charts with a clear prior-period high or low acting as a reference draw
• Planning phases, when defining a target and an invalidation before committing to a view


⚠️ When NOT to Use

• Very low-liquidity symbols or thin sessions, where swing structure is unreliable
• Extreme volatility events, where levels are torn through without reaction
• Very low timeframes dominated by noise, where pools form and break too quickly
• As a standalone entry trigger, with no regard for broader context


🎛️ Key Inputs

• Swing Strength → how strong a swing must be to become a pool
• Pool Memory → how many recent pools are retained
• Equal Level Tolerance → how loosely nearby levels merge into a cluster
• Use Prior-Period Pools → include the prior higher-timeframe high and low (day, week, or month by chart)
• Trend Backbone EMA and Slope → the directional context used in scoring
• Max Draw Distance → distance beyond which a pool is treated as too far to be an active draw
• Active Draw Score → minimum score for an emphasized, alert-eligible draw
• Two-Sided Balance Gap → score gap below which liquidity is treated as balanced
• Visual and panel settings → control zones, lines, labels, density, location, theme, and font size


🖥️ Interface & Visual Design

The interface is intentionally restrained. One dominant draw zone, one target line, one structural invalidation reference, a light pool map, and a single target tag keep the chart readable. Event labels alternate by side and point at the candle that produced them, so the chart reads as a clean sequence rather than a cluster. The panel carries the detailed read, and its first row is a single merged brand header. Panel location, theme, and font size are all adjustable, and the panel is shown by default for clarity.


🧪 Practical Usage Workflow

1. Read the panel: note the state and the draw score.
2. Locate the target: confirm the highlighted draw zone and the target line.
3. Check the invalidation: note the opposite-side structural reference.
4. Confirm context: compare with your higher-timeframe bias and structure before acting on any view.


🔍 Interpretation Guidelines

Treat the draw score as a measure of how clearly liquidity leans to one side, not as a probability of profit. A strong, aligned draw is context to plan around. A balanced or weak read is a reason to wait rather than to force a trade. Every output is meant to be interpreted inside the broader market picture, never in isolation.


🚫 What This Script Is NOT

- It is NOT a prediction engine.
- It is NOT financial advice.
- It is NOT an automated trading system.
- It does NOT generate guaranteed signals or outcomes.


⚠️ Limitations & Transparency

Liquidity context behaves differently across timeframes, symbols, and volatility regimes. Pools can be ignored, swept and reversed, or run through without reaction. Swing detection depends on the chosen settings, and prior-period references behave differently across symbols and session types. This tool organizes context and frames a decision; it does not guarantee how price will respond to any level.


🧠 Market Context Notes

Liquidity tends to rest where many participants place stops: above equal highs, below equal lows, and around prior-period extremes. Price often gravitates toward these areas, but the timing and the reaction are never certain. The structure and volatility around a pool shape how meaningful any reaction near it is likely to be, which is why the score blends proximity and trend context rather than distance alone.


🧾 Use Case Examples

• In an uptrend, the planner highlights a buy-side draw at a cluster of equal highs above price, with a recent swing low as the structural invalidation below and a score that reflects how aligned and how close that draw is.
• In a range, the planner shows two-sided liquidity, signaling that no single side is dominant and that patience is warranted until one side resolves.
• After a deep move, the prior-period high or low can become the dominant draw, giving a clear reference target while the invalidation marks where that lean would weaken.


🧱 System Philosophy

The AG Pro approach favors decision-support tools over raw indicators. Each script is built to answer a specific question, present a clean read, and respect the chart. Draw On Liquidity Planner reflects that philosophy by turning scattered liquidity into one structured draw decision with a transparent score and a defined invalidation.


🔐 Non-Promise Statement

This tool offers no guarantees and no certainty about future price movement. It is a structured way to read liquidity context and frame a plan, nothing more.


📉 Risk Disclosure

Trading involves substantial risk. This script is provided for educational and analytical purposes only and does not constitute financial advice. All trading decisions and their outcomes are solely the responsibility of the user.


📚 Educational Note

Use this planner to study how price interacts with resting liquidity over time. Watching which draws are respected, swept, or ignored on your own market and timeframe is a practical way to build liquidity-reading skill and a more structured trading process.

## Source Code

````pine
// -------------------------------------------------
// Draw On Liquidity Planner [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 1.3.0
//
// Draw On Liquidity Planner is a chart-first liquidity draw and target planner
// that maps untapped buy-side and sell-side liquidity pools (equal highs, equal
// lows, prior-day high and low, unmitigated swing points), then scores the
// single dominant draw on liquidity into a 0-100 magnet score with a clear
// next-action state, target pool, draw distance, pool type, and opposite-side
// invalidation reference for patient smart-money liquidity analysis.
// v1.2 turns the runway into an operational map: only a qualified dominant draw
// receives a target plan, nearby reference pools stay relevant, and every active
// target or invalidation rail carries an owned, contrast-safe AGPro badge.
// -------------------------------------------------

//@version=6
indicator("Draw On Liquidity Planner [AGPro Series]",
     shorttitle       = "AG Pro DOL",
     overlay          = true,
     max_labels_count = 200,
     max_lines_count  = 100,
     max_boxes_count  = 30)

const string PANEL_QUESTION = "WHERE IS PRICE BEING DRAWN NEXT?"

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
ttUsePriorDay = "Includes the prior higher-timeframe high and low as significant liquidity pools. The period adapts to the chart: prior day on intraday charts, prior week on daily charts, and prior month on higher timeframes."
ttAtrLen = "ATR length used to normalize draw distance, pool tolerance, label offsets, and the draw zone width."
ttTrendLen = "EMA backbone used to read directional context. Liquidity draws aligned with the prevailing direction score higher."
ttSlopeBars = "Bars used to measure whether the trend backbone is rising or falling for the directional context score."
ttMaxDrawAtr = "Distance in ATR beyond which a liquidity pool is treated as too far to act as an active near-term draw."
ttFreshWin = "Window in bars used to fade older pools. More recently formed pools contribute a stronger draw context."
ttMinDrawScore = "Minimum 0-100 draw score required before the dominant side is treated as an active draw for alerts and emphasis."
ttBalanceTol = "Score gap below which buy-side and sell-side draws are treated as balanced two-sided liquidity instead of one dominant draw."
ttShowZone = "Shows the draw on liquidity as a shaded runway from current price to the dominant target pool, with a centered draw badge."
ttShowTarget = "Shows the active draw target line and the opposite-side invalidation reference line."
ttShowPools = "Shows faint reference lines for the other untapped liquidity pools on each side, as a light liquidity map."
ttMaxPools = "Maximum number of additional faint pool reference lines drawn per side."
ttReferenceRange = "Maximum ATR distance from current price for secondary pool lines. Distant pools remain in the scoring memory but are not left as orphan chart rails."
ttShowTargetTag = "Shows filled right-edge badges for the active target and its structural invalidation reference."
ttProjection = "How far the active draw runway, target line, and invalidation line extend to the right."
ttTagOffset = "Horizontal offset added beyond the projection for the right-edge target tag."
ttShowLabels = "Shows compact labels when the dominant draw flips side or when a liquidity pool is swept. Labels are offset away from candles."
ttLabelCooldown = "Minimum bars between event labels so the chart stays readable and premium."
ttMaxLabels = "Maximum number of recent event labels retained on the chart."
ttLabelOffset = "ATR-based vertical offset that keeps labels clear of candles."
ttLabelSize = "Font size for all on-chart labels and the draw badge. Normal is the recommended publication default."
ttShowPanel = "Shows or hides the AG Pro planning panel. It is shown by default for public-release readability."
ttPanelLocation = "Moves the AG Pro panel to the preferred chart location."
ttPanelTheme = "Switches the panel between AG Pro dark and clean light themes."
ttPanelFont = "Font size for the AG Pro panel. Normal is the recommended publication default."
ttAlerts = "Enables alert conditions for buy-side draw, sell-side draw, and liquidity pool swept events."

// -------------------------------------------------
// Inputs
// -------------------------------------------------
gEngine = "Liquidity Engine"
pivotLen = input.int(8, "Swing Strength", minval = 2, maxval = 50, group = gEngine, tooltip = ttPivot)
poolMemory = input.int(20, "Pool Memory", minval = 6, maxval = 60, group = gEngine, tooltip = ttPoolMemory)
eqTol = input.float(0.45, "Equal Level Tolerance ATR", minval = 0.05, maxval = 2.00, step = 0.05, group = gEngine, tooltip = ttEqTol)
usePriorDay = input.bool(true, "Use Prior-Period Pools", group = gEngine, tooltip = ttUsePriorDay)
atrLen = input.int(14, "ATR Length", minval = 5, maxval = 100, group = gEngine, tooltip = ttAtrLen)
trendLen = input.int(55, "Trend Backbone EMA", minval = 5, maxval = 300, group = gEngine, tooltip = ttTrendLen)
slopeBars = input.int(5, "Trend Slope Bars", minval = 1, maxval = 30, group = gEngine, tooltip = ttSlopeBars)

gScore = "Draw Scoring"
maxDrawAtr = input.float(10.0, "Max Draw Distance ATR", minval = 2.0, maxval = 30.0, step = 0.5, group = gScore, tooltip = ttMaxDrawAtr)
freshWin = input.int(120, "Pool Freshness Window", minval = 20, maxval = 500, group = gScore, tooltip = ttFreshWin)
minDrawScore = input.int(60, "Active Draw Score", minval = 30, maxval = 95, group = gScore, tooltip = ttMinDrawScore)
balanceTol = input.int(8, "Two-Sided Balance Gap", minval = 1, maxval = 30, group = gScore, tooltip = ttBalanceTol)

gVisual = "Chart Visuals"
showZone = input.bool(true, "Show Draw Runway", group = gVisual, tooltip = ttShowZone)
showTarget = input.bool(true, "Show Target and Invalidation", group = gVisual, tooltip = ttShowTarget)
showPools = input.bool(true, "Show Other Liquidity Pools", group = gVisual, tooltip = ttShowPools)
maxPools = input.int(2, "Pools Per Side", minval = 1, maxval = 5, group = gVisual, tooltip = ttMaxPools)
referencePoolRangeAtr = input.float(5.0, "Reference Pool Range ATR", minval = 1.0, maxval = 20.0, step = 0.5, group = gVisual, tooltip = ttReferenceRange)
showTargetTag = input.bool(true, "Show Target and Invalidation Tags", group = gVisual, tooltip = ttShowTargetTag)
projectionBars = input.int(28, "Projection Bars", minval = 6, maxval = 120, group = gVisual, tooltip = ttProjection)
tagOffsetBars = input.int(3, "Target Tag Offset Bars", minval = 1, maxval = 30, group = gVisual, tooltip = ttTagOffset)

gLabels = "Labels"
showLabels = input.bool(true, "Show Event Labels", group = gLabels, tooltip = ttShowLabels)
labelCooldown = input.int(52, "Label Cooldown Bars", minval = 1, maxval = 80, group = gLabels, tooltip = ttLabelCooldown)
maxVisibleLabels = input.int(5, "Max Visible Labels", minval = 3, maxval = 40, group = gLabels, tooltip = ttMaxLabels)
labelOffsetAtr = input.float(0.70, "Label Offset ATR", minval = 0.0, maxval = 3.00, step = 0.05, group = gLabels, tooltip = ttLabelOffset)
labelSizeInput = input.string("Normal", "Label Font Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = gLabels, tooltip = ttLabelSize)

gPanel = "Panel"
showPanel = input.bool(true, "Show Panel", group = gPanel, tooltip = ttShowPanel)
panelLocationInput = input.string("Top Right", "Panel Location", options = ["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], group = gPanel, tooltip = ttPanelLocation)
panelThemeInput = input.string("Dark", "Panel Theme", options = ["Dark", "Light"], group = gPanel, tooltip = ttPanelTheme)
panelFontSizeInput = input.string("Normal", "Panel Font Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = gPanel, tooltip = ttPanelFont)

gAlerts = "Alerts"
alertDraw = input.bool(true, "Alert on Draw Side", group = gAlerts, tooltip = ttAlerts)
alertSwept = input.bool(true, "Alert on Pool Swept", group = gAlerts, tooltip = ttAlerts)

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
        "Huge" => size.huge
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

f_is_unique_level(array<float> levels, float level, float tolerance) =>
    bool isUnique = true
    if array.size(levels) > 0
        for i = 0 to array.size(levels) - 1
            if math.abs(array.get(levels, i) - level) <= tolerance
                isUnique := false
    isUnique

// -------------------------------------------------
// Core context
// -------------------------------------------------
labelSize = f_label_size(labelSizeInput)
atr = math.max(nz(ta.atr(atrLen), ta.tr(true)), syminfo.mintick)
trendEma = ta.ema(close, trendLen)
trendSlope = trendEma - nz(trendEma[slopeBars], trendEma)
trendUp = close > trendEma and trendSlope > 0.0
trendDown = close < trendEma and trendSlope < 0.0
rangeLow = ta.lowest(low, freshWin)
rangeHigh = ta.highest(high, freshWin)

priorTF = timeframe.isintraday ? "D" : timeframe.isdaily ? "W" : "M"
priorName = timeframe.isintraday ? "Day" : timeframe.isdaily ? "Week" : "Month"
priorDayHigh = usePriorDay ? request.security(syminfo.tickerid, priorTF, high[1], lookahead = barmerge.lookahead_on) : na
priorDayLow = usePriorDay ? request.security(syminfo.tickerid, priorTF, low[1], lookahead = barmerge.lookahead_on) : na

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
sweptBuy = false
sweptSell = false
if array.size(swingHighPrice) > 0
    for i = 0 to array.size(swingHighPrice) - 1
        if not array.get(swingHighTaken, i) and high > array.get(swingHighPrice, i)
            array.set(swingHighTaken, i, true)
            sweptBuy := true
if array.size(swingLowPrice) > 0
    for i = 0 to array.size(swingLowPrice) - 1
        if not array.get(swingLowTaken, i) and low < array.get(swingLowPrice, i)
            array.set(swingLowTaken, i, true)
            sweptSell := true

// -------------------------------------------------
// Nearest untapped pool on each side (+ prior-day pools)
// -------------------------------------------------
float buyPoolPrice = na
int buyPoolBar = na
if array.size(swingHighPrice) > 0
    for i = 0 to array.size(swingHighPrice) - 1
        if not array.get(swingHighTaken, i) and array.get(swingHighPrice, i) > close
            if na(buyPoolPrice) or array.get(swingHighPrice, i) < buyPoolPrice
                buyPoolPrice := array.get(swingHighPrice, i)
                buyPoolBar := array.get(swingHighBar, i)

bool buyIsPD = false
if not na(priorDayHigh) and priorDayHigh > close
    if na(buyPoolPrice) or priorDayHigh < buyPoolPrice
        buyPoolPrice := priorDayHigh
        buyPoolBar := na
        buyIsPD := true

float sellPoolPrice = na
int sellPoolBar = na
if array.size(swingLowPrice) > 0
    for i = 0 to array.size(swingLowPrice) - 1
        if not array.get(swingLowTaken, i) and array.get(swingLowPrice, i) < close
            if na(sellPoolPrice) or array.get(swingLowPrice, i) > sellPoolPrice
                sellPoolPrice := array.get(swingLowPrice, i)
                sellPoolBar := array.get(swingLowBar, i)

bool sellIsPD = false
if not na(priorDayLow) and priorDayLow < close
    if na(sellPoolPrice) or priorDayLow > sellPoolPrice
        sellPoolPrice := priorDayLow
        sellPoolBar := na
        sellIsPD := true

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
// Draw scoring (0-100 per side)
// -------------------------------------------------
buyDistAtr = na(buyPoolPrice) ? na : (buyPoolPrice - close) / atr
sellDistAtr = na(sellPoolPrice) ? na : (close - sellPoolPrice) / atr

buyQuality = na(buyPoolPrice) ? 0.0 : f_clamp(buyTouches / 4.0 * 100.0, 0.0, 100.0)
buyQuality := buyIsPD ? math.max(buyQuality, 72.0) : buyQuality
sellQuality = na(sellPoolPrice) ? 0.0 : f_clamp(sellTouches / 4.0 * 100.0, 0.0, 100.0)
sellQuality := sellIsPD ? math.max(sellQuality, 72.0) : sellQuality

buyProximity = na(buyDistAtr) ? 0.0 : f_clamp(100.0 - buyDistAtr / maxDrawAtr * 100.0, 0.0, 100.0)
sellProximity = na(sellDistAtr) ? 0.0 : f_clamp(100.0 - sellDistAtr / maxDrawAtr * 100.0, 0.0, 100.0)

buyTrend = trendUp ? 100.0 : close > trendEma ? 62.0 : trendDown ? 26.0 : 50.0
sellTrend = trendDown ? 100.0 : close < trendEma ? 62.0 : trendUp ? 26.0 : 50.0

buyFresh = na(buyPoolBar) ? 62.0 : f_clamp(100.0 - (bar_index - buyPoolBar) / freshWin * 100.0, 0.0, 100.0)
sellFresh = na(sellPoolBar) ? 62.0 : f_clamp(100.0 - (bar_index - sellPoolBar) / freshWin * 100.0, 0.0, 100.0)

buySideScore = na(buyPoolPrice) ? 0.0 : f_clamp(buyQuality * 0.34 + buyProximity * 0.26 + buyTrend * 0.24 + buyFresh * 0.16, 0.0, 100.0)
sellSideScore = na(sellPoolPrice) ? 0.0 : f_clamp(sellQuality * 0.34 + sellProximity * 0.26 + sellTrend * 0.24 + sellFresh * 0.16, 0.0, 100.0)

hasBuy = not na(buyPoolPrice)
hasSell = not na(sellPoolPrice)
hasAnyPool = hasBuy or hasSell
scoreGap = buySideScore - sellSideScore
drawSideCode = not hasAnyPool ? 0 : math.abs(scoreGap) <= balanceTol ? 0 : scoreGap > 0 ? 1 : -1

// Nearest opposite swing (any status) as a structural invalidation reference
float nearLowAny = na
if array.size(swingLowPrice) > 0
    for i = 0 to array.size(swingLowPrice) - 1
        lowP = array.get(swingLowPrice, i)
        if lowP < close and (na(nearLowAny) or lowP > nearLowAny)
            nearLowAny := lowP
float nearHighAny = na
if array.size(swingHighPrice) > 0
    for i = 0 to array.size(swingHighPrice) - 1
        highP = array.get(swingHighPrice, i)
        if highP > close and (na(nearHighAny) or highP < nearHighAny)
            nearHighAny := highP

domSide = buySideScore >= sellSideScore ? 1 : -1
targetPrice = domSide == 1 ? buyPoolPrice : sellPoolPrice
invalidationPrice = domSide == 1 ? (na(nearLowAny) ? rangeLow : nearLowAny) : (na(nearHighAny) ? rangeHigh : nearHighAny)
targetDistAtr = domSide == 1 ? buyDistAtr : sellDistAtr
domTouches = domSide == 1 ? buyTouches : sellTouches
domIsPD = domSide == 1 ? buyIsPD : sellIsPD
drawScore = drawSideCode == 1 ? int(math.round(buySideScore)) : drawSideCode == -1 ? int(math.round(sellSideScore)) : int(math.round(math.max(buySideScore, sellSideScore)))

activeDraw = drawSideCode != 0 and drawScore >= minDrawScore
drawColor = drawSideCode == 1 ? bullColor : drawSideCode == -1 ? bearColor : neutralColor
displayTargetPrice = activeDraw ? targetPrice : na
displayInvalidationPrice = activeDraw ? invalidationPrice : na

stateText = not hasAnyPool ? "No Draw" : drawSideCode == 1 ? "Buy-Side Draw" : drawSideCode == -1 ? "Sell-Side Draw" : "Two-Sided"
actionText = not hasAnyPool ? "Wait for New Pool" : drawSideCode == 0 ? "Wait for Side Resolution" : not activeDraw ? "Monitor Low-Score Draw" : drawSideCode == 1 ? "Track Buy-Side Target" : "Track Sell-Side Target"
poolTypeText = na(targetPrice) ? "-" : domIsPD ? (domSide == 1 ? "Prior " + priorName + " High" : "Prior " + priorName + " Low") : domTouches >= 3 ? (domSide == 1 ? "Equal Highs" : "Equal Lows") : domTouches == 2 ? (domSide == 1 ? "Double Top" : "Double Bottom") : (domSide == 1 ? "Swing High" : "Swing Low")
distText = not activeDraw or na(targetDistAtr) ? "-" : str.tostring(targetDistAtr, "#.00") + " ATR"
scoreText = hasAnyPool ? str.tostring(drawScore) + "/100" : "-"

// -------------------------------------------------
// Event detection
// -------------------------------------------------
var int lastEventSide = 0
drawEvent = barstate.isconfirmed and drawSideCode != 0 and drawSideCode != lastEventSide and drawScore >= minDrawScore
if drawEvent
    lastEventSide := drawSideCode
poolSwept = barstate.isconfirmed and (sweptBuy or sweptSell)
sweptUp = sweptBuy and not sweptSell

// -------------------------------------------------
// Visuals
// -------------------------------------------------
var box drawZone = na
var label drawBadge = na
var line targetLine = na
var line oppLine = na
var label targetTag = na
var label invalidationTag = na
var array<line> poolLines = array.new_line()
var array<label> eventLabels = array.new_label()
var int lastLabelBar = na

if barstate.islast
    rightX = bar_index + projectionBars
    leftX = bar_index - math.min(projectionBars, 30)
    zonePad = atr * 0.10
    badgeX = bar_index + math.max(8, int(math.round(projectionBars * 0.58)))

    // Other untapped liquidity pools (faint reference map)
    if array.size(poolLines) > 0
        for i = 0 to array.size(poolLines) - 1
            line.delete(array.get(poolLines, i))
        array.clear(poolLines)

    if showPools
        array<float> buyRefLevels = array.new_float()
        if array.size(swingHighPrice) > 0
            for i = 0 to array.size(swingHighPrice) - 1
                if not array.get(swingHighTaken, i) and array.get(swingHighPrice, i) > close
                    lvl = array.get(swingHighPrice, i)
                    withinRange = (lvl - close) / atr <= referencePoolRangeAtr
                    separateFromTarget = na(displayTargetPrice) or math.abs(lvl - displayTargetPrice) > zonePad
                    if withinRange and separateFromTarget and f_is_unique_level(buyRefLevels, lvl, eqTol * atr * 0.50)
                        array.push(buyRefLevels, lvl)
        array.sort(buyRefLevels, order.ascending)
        int buyRefCount = math.min(maxPools, array.size(buyRefLevels))
        if buyRefCount > 0
            for i = 0 to buyRefCount - 1
                lvl = array.get(buyRefLevels, i)
                ln = line.new(leftX, lvl, rightX, lvl, xloc = xloc.bar_index, color = color.new(bullColor, 76), style = line.style_dotted, width = 1)
                array.push(poolLines, ln)

        array<float> sellRefLevels = array.new_float()
        if array.size(swingLowPrice) > 0
            for i = 0 to array.size(swingLowPrice) - 1
                if not array.get(swingLowTaken, i) and array.get(swingLowPrice, i) < close
                    lvl = array.get(swingLowPrice, i)
                    withinRange = (close - lvl) / atr <= referencePoolRangeAtr
                    separateFromTarget = na(displayTargetPrice) or math.abs(lvl - displayTargetPrice) > zonePad
                    if withinRange and separateFromTarget and f_is_unique_level(sellRefLevels, lvl, eqTol * atr * 0.50)
                        array.push(sellRefLevels, lvl)
        array.sort(sellRefLevels, order.descending)
        int sellRefCount = math.min(maxPools, array.size(sellRefLevels))
        if sellRefCount > 0
            for i = 0 to sellRefCount - 1
                lvl = array.get(sellRefLevels, i)
                ln = line.new(leftX, lvl, rightX, lvl, xloc = xloc.bar_index, color = color.new(bearColor, 76), style = line.style_dotted, width = 1)
                array.push(poolLines, ln)

    // Active draw runway (from current price to the dominant target pool) + centered badge
    if showZone and not na(displayTargetPrice)
        zTop = math.max(close, displayTargetPrice) + zonePad
        zBot = math.min(close, displayTargetPrice) - zonePad
        badgeY = (close + displayTargetPrice) / 2.0
        badgeText = stateText + " • ACTIVE\nQ" + str.tostring(drawScore) + " • " + distText + " • " + poolTypeText
        if na(drawZone)
            drawZone := box.new(bar_index, zTop, rightX, zBot, xloc = xloc.bar_index, bgcolor = color.new(drawColor, 88), border_color = color.new(drawColor, activeDraw ? 40 : 60), border_width = 1)
        else
            box.set_lefttop(drawZone, bar_index, zTop)
            box.set_rightbottom(drawZone, rightX, zBot)
            box.set_bgcolor(drawZone, color.new(drawColor, 88))
            box.set_border_color(drawZone, color.new(drawColor, activeDraw ? 40 : 60))
        if na(drawBadge)
            drawBadge := label.new(badgeX, badgeY, badgeText, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_center, color = color.new(drawColor, 0), textcolor = f_text_on(drawColor), size = labelSize, textalign = text.align_center)
        else
            label.set_xy(drawBadge, badgeX, badgeY)
            label.set_text(drawBadge, badgeText)
            label.set_color(drawBadge, color.new(drawColor, 0))
            label.set_textcolor(drawBadge, f_text_on(drawColor))
            label.set_size(drawBadge, labelSize)
    else
        if not na(drawZone)
            box.delete(drawZone)
            drawZone := na
        if not na(drawBadge)
            label.delete(drawBadge)
            drawBadge := na

    // Target line (destination pool) + opposite invalidation line
    if showTarget and not na(displayTargetPrice)
        if na(targetLine)
            targetLine := line.new(bar_index, displayTargetPrice, rightX, displayTargetPrice, xloc = xloc.bar_index, color = color.new(drawColor, 0), width = 2)
        else
            line.set_xy1(targetLine, bar_index, displayTargetPrice)
            line.set_xy2(targetLine, rightX, displayTargetPrice)
            line.set_color(targetLine, color.new(drawColor, 0))
    else
        if not na(targetLine)
            line.delete(targetLine)
            targetLine := na

    if showTarget and not na(displayInvalidationPrice)
        oppColor = domSide == 1 ? bearColor : bullColor
        if na(oppLine)
            oppLine := line.new(bar_index, displayInvalidationPrice, rightX, displayInvalidationPrice, xloc = xloc.bar_index, color = color.new(oppColor, 35), style = line.style_dashed, width = 1)
        else
            line.set_xy1(oppLine, bar_index, displayInvalidationPrice)
            line.set_xy2(oppLine, rightX, displayInvalidationPrice)
            line.set_color(oppLine, color.new(oppColor, 35))
    else
        if not na(oppLine)
            line.delete(oppLine)
            oppLine := na

    // Owned right-edge target and invalidation tags
    if showTargetTag and not na(displayTargetPrice)
        tagText = (domSide == 1 ? "BUY-SIDE TARGET • " : "SELL-SIDE TARGET • ") + f_price_text(displayTargetPrice)
        tagX = rightX + tagOffsetBars
        if na(targetTag)
            targetTag := label.new(tagX, displayTargetPrice, tagText, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = color.new(drawColor, 0), textcolor = f_text_on(drawColor), size = labelSize)
        else
            label.set_xy(targetTag, tagX, displayTargetPrice)
            label.set_text(targetTag, tagText)
            label.set_color(targetTag, color.new(drawColor, 0))
            label.set_textcolor(targetTag, f_text_on(drawColor))
            label.set_size(targetTag, labelSize)
    else
        if not na(targetTag)
            label.delete(targetTag)
            targetTag := na

    if showTargetTag and not na(displayInvalidationPrice)
        invColor = domSide == 1 ? bearColor : bullColor
        invTagText = "INVALIDATION " + f_price_text(displayInvalidationPrice)
        invTagX = rightX + tagOffsetBars
        if na(invalidationTag)
            invalidationTag := label.new(invTagX, displayInvalidationPrice, invTagText, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = color.new(invColor, 0), textcolor = f_text_on(invColor), size = labelSize)
        else
            label.set_xy(invalidationTag, invTagX, displayInvalidationPrice)
            label.set_text(invalidationTag, invTagText)
            label.set_color(invalidationTag, color.new(invColor, 0))
            label.set_textcolor(invalidationTag, f_text_on(invColor))
            label.set_size(invalidationTag, labelSize)
    else
        if not na(invalidationTag)
            label.delete(invalidationTag)
            invalidationTag := na

// -------------------------------------------------
// Event labels
// -------------------------------------------------
cooldownOk = na(lastLabelBar) or bar_index - lastLabelBar >= labelCooldown

if showLabels and drawEvent and cooldownOk
    flipText = drawSideCode == 1 ? "BUY-SIDE DRAW • Q" : "SELL-SIDE DRAW • Q"
    flipUp = drawSideCode == 1
    flipY = flipUp ? high + atr * labelOffsetAtr : low - atr * labelOffsetAtr
    flipStyle = flipUp ? label.style_label_down : label.style_label_up
    flipCol = drawSideCode == 1 ? bullColor : bearColor
    flipLabel = label.new(bar_index, flipY, flipText + str.tostring(drawScore), xloc = xloc.bar_index, yloc = yloc.price, style = flipStyle, color = color.new(flipCol, 0), textcolor = f_text_on(flipCol), size = labelSize, textalign = text.align_center)
    f_keep_label(eventLabels, flipLabel, maxVisibleLabels)
    lastLabelBar := bar_index

else if showLabels and poolSwept and cooldownOk
    sweptText = sweptUp ? "BUY-SIDE • SWEPT" : "SELL-SIDE • SWEPT"
    sweptHi = sweptUp
    sweptY = sweptHi ? high + atr * labelOffsetAtr : low - atr * labelOffsetAtr
    sweptStyle = sweptHi ? label.style_label_down : label.style_label_up
    sweptLabel = label.new(bar_index, sweptY, sweptText, xloc = xloc.bar_index, yloc = yloc.price, style = sweptStyle, color = color.new(neutralColor, 0), textcolor = color.rgb(15, 23, 42), size = labelSize, textalign = text.align_center)
    f_keep_label(eventLabels, sweptLabel, maxVisibleLabels)
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
        table.cell(panel, 0, 0, "AG Pro Draw On Liquidity Planner", text_color = headerText, bgcolor = headerBg, text_size = f_label_size(panelFontSizeInput), text_halign = text.align_center)
        questionColor = panelThemeInput == "Light" ? color.rgb(67, 56, 202) : accentColor
        table.cell(panel, 0, 1, PANEL_QUESTION, text_color = questionColor, bgcolor = f_panel_bg(panelThemeInput, false), text_size = f_label_size(panelFontSizeInput), text_halign = text.align_center)
        valueColor = f_panel_value(panelThemeInput)
        focusColor = activeDraw ? drawColor : neutralColor
        f_panel_focus_row(panel, 2, "State", stateText, focusColor, panelThemeInput, panelFontSizeInput)
        f_panel_row(panel, 3, "Draw Score", scoreText, activeDraw ? drawColor : valueColor, panelThemeInput, panelFontSizeInput)
        f_panel_row(panel, 4, "Target", f_price_text(displayTargetPrice), drawColor, panelThemeInput, panelFontSizeInput)
        f_panel_row(panel, 5, "Distance", distText, valueColor, panelThemeInput, panelFontSizeInput)
        f_panel_row(panel, 6, "Pool Type", poolTypeText, valueColor, panelThemeInput, panelFontSizeInput)
        f_panel_row(panel, 7, "Invalidation", f_price_text(displayInvalidationPrice), domSide == 1 ? bearColor : bullColor, panelThemeInput, panelFontSizeInput)
        f_panel_focus_row(panel, 8, "Action", actionText, focusColor, panelThemeInput, panelFontSizeInput)
    else
        table.clear(panel, 0, 0, 1, 8)

// -------------------------------------------------
// Alerts
// -------------------------------------------------
alertcondition(alertDraw and drawEvent and drawSideCode == 1, "Buy-Side Draw", "Draw On Liquidity Planner: buy-side liquidity is the dominant draw. Review the upside pool and broader market context.")
alertcondition(alertDraw and drawEvent and drawSideCode == -1, "Sell-Side Draw", "Draw On Liquidity Planner: sell-side liquidity is the dominant draw. Review the downside pool and broader market context.")
alertcondition(alertSwept and poolSwept, "Liquidity Pool Swept", "Draw On Liquidity Planner: a liquidity pool was swept. Review whether price continues or reverses within broader context.")
````
