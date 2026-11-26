# Support & Resistance with MA Ribbons LITE

- url: https://www.tradingview.com/script/TOsNbfMi-Support-Resistance-with-MA-Ribbons-LITE/
- type: indicator
- pine_id: PUB;43baa69ef11f4b0ebdc881fc1b1fd302
- version: 3.0

## Description

[b]Support & Resistance with MA Ribbons LITE [/b]is a chart overlay that combines a fully configurable [b]Moving Average Ribbon[/b] with a pivot-based [b]Support & Resistance engine[/b] into a single, performance-optimized indicator. The MA Ribbon defines the prevailing trend regime; the S/R engine marks the price levels most likely to generate reactions within that regime. Used together, they provide both [i]directional context[/i] and [i]horizontal market structure[/i] in one uncluttered overlay.

This script is open-source under the [b]Mozilla Public License 2.0[/b]. Parts of the MA Ribbon logic draw conceptual inspiration from publicly shared work by [b]JustUncleL[/b] on TradingView — full credit and thanks are extended for those contributions.

═══════════════════════════════════════════

█ WHY COMBINE THESE TWO SYSTEMS?

Most MA ribbon and S/R indicators operate independently. This script was built specifically around their [i]interaction[/i]: a support level in a downtrend carries different weight than the same level in an uptrend. The color system, alert logic, and display behavior are all designed so that the two components reinforce each other rather than adding chart clutter.

Original features that do not exist in either component alone:
[list]
[*][b]Minute-based anchor timeframe logic[/b] — MA lengths scale automatically to preserve the same trend structure across chart timeframes without manual recalculation
[*][b]Mixed Source mode[/b] — Main and Strong S/R levels use wicks (High/Low) for accurate reaction zones; secondary levels use Close prices for cleaner signals
[*][b]6-tone bar coloring[/b] — distinguishes bullish/bearish candles inside vs. outside the ribbon, adding nuance beyond a standard 2-color system
[*][b]Smart label contrast[/b] — label text color is calculated automatically from background brightness using a weighted luminance formula (0.299·R + 0.587·G + 0.114·B), ensuring legibility across all color presets
[*][b]S/R heat map[/b] — line opacity scales with historical touch count, making frequently tested zones visually prominent
[*][b]Alert cooldown system[/b] — configurable minimum-bars-between-alerts prevents repeated notifications during consolidation near a level
[/list]

═══════════════════════════════════════════

█ COMPONENT 1 — MA RIBBON SYSTEM

The ribbon consists of two independently configurable moving averages ([b]Fast[/b] and [b]Slow[/b]) with [b]13 supported calculation types[/b]:
https://www.tradingview.com/x/jJmnnQ9t/
[b]EMA · SMA · WMA · VWMA · SMMA · DEMA · TEMA · LAGMA · LINREG · HullMA · ZEMA · TMA · SSMA[/b]

[b]How the ribbon works:[/b]
[list]
[*]Ribbon fills [b]bullish[/b] when Fast MA is above Slow MA, [b]bearish[/b] when below
[*]Bar coloring reflects whether price is above both MAs (bullish zone), below both (bearish zone), or inside the ribbon (neutral / transitioning)
[*]Optional [b]6-tone mode[/b] further distinguishes candles by close vs. open relationship within each zone
[/list]

[b]Anchor Timeframe Logic (minutes):[/b]

Setting an anchor (e.g., [i]60[/i] = 1 hour) causes MA lengths to multiply proportionally so that the same underlying trend structure is visible regardless of which chart timeframe is active. This eliminates the need to reconfigure MA lengths when switching timeframes.
[list]
[*][b]Anchor = 0[/b] → uses current chart timeframe lengths as-is
[*][b]Anchor = 60[/b] on a 5-min chart → MA lengths scale ×12 to reflect 1H structure
[*][b]Anchor = 240[/b] on a 15-min chart → MA lengths scale ×16 to reflect 4H structure
[/list]

[b]Optional signals:[/b]
[list]
[*][b]Swing arrows[/b] — fire when price first enters a new directional zone (filterable by ribbon color or MA slope)
[*][b]MA cross markers[/b] — highlight the crossover bar with a background color flash
[*][b]Continuation markers (XBuy / XSell)[/b] — identify early-trend momentum bars after a crossover
[/list]

═══════════════════════════════════════════

█ COMPONENT 2 — SUPPORT & RESISTANCE ENGINE

Levels are derived from [b]pivot structure analysis[/b] — price extremes confirmed by a configurable number of bars to the left and right. The system separates levels by confirmation speed:
https://www.tradingview.com/x/lz2EYscQ/
[b]⚡ Main Resistance / Support[/b] — Fast pivots (quick_right bars). Most recent, reactive levels.
[b]Strong Resistance / Support[/b] — Confirmed pivots (right bars). Structurally significant levels.
[b]Resistance 1–4 / Support 1–4[/b] — Historical confirmed pivots. Provides depth and context.

Up to [b]12 levels[/b] can be displayed simultaneously.

[b]Pivot Sensitivity Presets:[/b]
[list]
[*][b]Scalp[/b] — Left: 20 / Right: 10 — Short-term, high-frequency charts
[*][b]Intraday[/b] — Left: 30 / Right: 15 — Intraday sessions
[*][b]Swing[/b] — Left: 50 / Right: 25 — Multi-day position context
[*][b]Custom[/b] — Full manual control over all pivot parameters
[/list]

[b]Source Modes:[/b]
[list]
[*][b]High/Low[/b] — All levels use candle wicks; captures full reaction range
[*][b]Close[/b] — All levels use closing prices; reduces noise from wicks
[*][b]Mixed (Wick/Close)[/b] — Main and Strong levels use High/Low; levels 5–12 use Close. Combines precise major zones with cleaner minor levels.
[/list]

[b]Multi-Timeframe (MTF) Mode:[/b]
Higher-timeframe S/R levels can be overlaid on the current chart. HTF data is requested using [b]barmerge.lookahead_off[/b], which means levels update only after each HTF bar closes — [i]no lookahead bias on historical bars[/i].

[b]Strength Filter & Heat Map:[/b]
[list]
[*][b]Strength filter[/b] — hides any level with fewer than N historical touches within a configurable lookback window
[*][b]Heat map mode[/b] — line opacity scales proportionally to touch count; the more a level has been tested, the more visually prominent it becomes
[/list]

═══════════════════════════════════════════

█ ALERT SYSTEM

Six configurable event types:
[list]
https://www.tradingview.com/x/XitmWVd5/
[*][b]⚡ Main Resistance / Support Touch[/b] — Close within tolerance % of level
[*][b]🎯 Strong Resistance / Support Touch[/b] — Close within tolerance % of strong level
[*][b]🚀 Breakout Above Main Resistance[/b] — Close exceeds level × (1 + min breakout %)
[*][b]📉 Breakdown Below Main Support[/b] — Close falls below level × (1 − min breakout %)
[*][b]🔁 Retest of Broken Level[/b] — Price returns to a previously broken level from the correct side
[*][b]♻️ Rejection at Level[/b] — Wick pierces level but close returns inside
[/list]

[b]Cooldown logic:[/b] A minimum-bars-between-alerts setting prevents the same alert from firing repeatedly during sideways price action near a level. Set to [i]0[/i] to disable.

All alerts are informational and should be visually validated before acting.

═══════════════════════════════════════════

█ COLOR SYSTEM

A unified [b]5-preset + Custom[/b] color palette controls both the MA Ribbon and S/R lines simultaneously, ensuring visual consistency across the indicator.
https://www.tradingview.com/x/7RzUvD8O/
[b]Presets:[/b] Classic · Aqua · Cosmic · Ember · Neon · Custom

Ribbon opacity and bar/candle opacity are independently adjustable. In [b]Custom[/b] mode, all 7 color slots are individually configurable (Bullish, Bearish, Neutral, Bullish 2, Bearish 2, Bull Candle, Bear Candle).

═══════════════════════════════════════════

█ HOW TO USE

[b]1. Chart Setup[/b]
Add the indicator to any chart and timeframe. Both systems are enabled by default and can be toggled independently via [i]Master Controls[/i].

[b]2. Set the correct Color Preset[/b]
Open [i]Settings → 🎨 Color Settings[/i] and select the [b]Color Preset[/b] that best suits your chart theme (Classic, Aqua, Cosmic, Ember, Neon, or Custom). Both the MA Ribbon fill and all S/R level colors will update simultaneously. Adjust [i]Ribbon Opacity[/i] and [i]Bar Opacity[/i] to match your preferred visual weight.

[b]3. Bring the indicator to front[/b]
https://www.tradingview.com/x/AsmW5slJ/
This indicator uses [b]plotcandle[/b] to render color-coded bars directly on the price chart. If other indicators or chart overlays are layered on top, the colored candles, S/R lines, and MA ribbon may appear behind them and render incorrectly.

[b]To ensure all elements display with full color accuracy:[/b]
[list]
[*]Right-click on the indicator name label on the chart (the label that reads [i]"S/R with MA Ribbons LITE..."[/i])
[*]Select [b]"Visual Order"[/b] → [b]"Bring to Front"[/b]
[/list]

This places the indicator's candles, S/R lines, and MA ribbon [i]above all other chart elements[/i], ensuring colors render exactly as configured. This setting is saved per chart layout and only needs to be done once.

[b]4. MA Ribbon — Trend Context[/b]
[list]
[*]Price above both MAs → bullish regime; bias longs, watch support levels
[*]Price below both MAs → bearish regime; bias shorts, watch resistance levels
[*]Price inside ribbon → transitioning; reduce exposure, wait for confirmation
[*]Use the [i]Anchor Timeframe[/i] to lock ribbon behavior to a reference timeframe (e.g., 240 for 4H structure on any intraday chart)
[/list]

[b]5. Support & Resistance — Structure[/b]
[list]
[*]Focus on price [i]behavior[/i] around levels, not exact prices
[*]⚡ Main levels are the most reactive; Strong levels carry more structural weight
[*]Enable [i]Strength Filter[/i] to reduce noise from weakly tested levels
[*]Enable [i]Heat Map[/i] to visually identify the most interacted zones
[*]Use [i]MTF mode[/i] to overlay daily or weekly structure on lower timeframe charts
[/list]

[b]6. Reading Both Systems Together[/b]
[list]
[*]In uptrends → reactions near [b]support[/b] are higher-probability continuation setups
[*]In downtrends → reactions near [b]resistance[/b] are higher-probability continuation setups
[*]Breakouts above resistance are more significant when ribbon is bullish
[*]Retests of broken levels gain confirmation weight when ribbon direction agrees
[/list]

[b]7. Alerts (optional)[/b]
[list]
[*]Configure alert types in [i]S/R Alert Settings[/i]
[*]Set [i]Min Bars Between Alerts[/i] to match your instrument's typical volatility
[*]Always visually confirm before acting on any alert
[/list]

═══════════════════════════════════════════

█ PERFORMANCE NOTES
[list]
[*]Touch count loops (Strength Filter / Heat Map) only execute when enabled
[*]Reduce [i]Number of Levels[/i] to 4–6 on lower-end systems or very fast timeframes
[*]Disabling unused features (swing arrows, MA cross markers) improves rendering speed
[/list]

═══════════════════════════════════════════

█ OPEN SOURCE & CREDITS

This script is released open-source under the [b]Mozilla Public License 2.0[/b].

Parts of the MA Ribbon calculation logic draw conceptual inspiration from publicly shared work by [b]JustUncleL[/b] on TradingView. Respect and thanks are extended for those contributions.

You are free to study the code, modify it for personal use, and share improvements under the same license terms.

═══════════════════════════════════════════

█ DISCLAIMER

This indicator is provided for [b]educational and informational purposes only[/b]. It does not constitute financial advice, trading recommendations, or investment guidance of any kind. No guarantees are made regarding accuracy, performance, or outcomes. Use at your own discretion alongside independent analysis and appropriate risk management.

## Source Code

````pine
//@version=6
// © 2025–2026 alpprofitmax
// This Pine Script® code is licensed under the Mozilla Public License 2.0
//
// ============================================================
//  Support & Resistance with MA Ribbons LITE by ALP 🇹🇷
// ============================================================
//
//
//
// ============================================================

indicator(title = 'Support & Resistance with MA Ribbons LITE 🅰🅻🅿 🇹🇷', shorttitle = 'S/R with MA Ribbons LITE by 🅰🅻🅿 🇹🇷', overlay = true, max_lines_count = 500, max_labels_count = 500)

// ====================================================
//  MASTER ON/OFF SWITCHES
// ====================================================
showMARibbon = input.bool(true, '🎯 Show MA Ribbon', group = 'Master Controls', tooltip = 'Turn on/off the entire MA Ribbon system')
showSupportResistance = input.bool(true, '🎯 Show Support/Resistance', group = 'Master Controls', tooltip = 'Turn on/off the entire S/R system')

// ====================================================
//  COLOR PRESET SYSTEM - SHARED BY BOTH INDICATORS
// ====================================================
colorPreset = input.string('Aqua', '🎨 Color Preset (Both Indicators)', options = ['Classic', 'Aqua', 'Cosmic', 'Ember', 'Neon', 'Custom'], group = '🎨 Color Settings')
ribbonOpacity = input.int(20, 'Ribbon Opacity %', minval = 0, maxval = 100, step = 5, group = '🎨 Color Settings')
barOpacity = input.int(100, 'Bar Opacity %', minval = 0, maxval = 100, step = 5, group = '🎨 Color Settings')

applyOpacity(col, opacity) =>
    color.new(col, 100 - opacity)

[defaultBullish, defaultBearish, defaultNeutral] = switch colorPreset
    'Classic' => [color.rgb(0, 255, 0), color.rgb(255, 0, 0), color.rgb(128, 128, 128)]
    'Aqua' => [color.rgb(0, 191, 255), color.rgb(255, 140, 0), color.rgb(127, 127, 127)]
    'Cosmic' => [color.rgb(73, 255, 206), color.rgb(153, 50, 204), color.rgb(106, 90, 205)]
    'Ember' => [color.rgb(255, 102, 0), color.rgb(0, 204, 204), color.rgb(153, 153, 153)]
    'Neon' => [color.rgb(255, 255, 0), color.rgb(255, 0, 255), color.rgb(0, 255, 0)]
    => [color.rgb(0, 255, 0), color.rgb(255, 0, 0), color.rgb(128, 128, 128)]

bullishColor1 = defaultBullish
bearishColor1 = defaultBearish
neutralColor = defaultNeutral
bullishColor2 = colorPreset == 'Classic' ? color.rgb(0, 128, 0) : colorPreset == 'Aqua' ? color.rgb(30, 144, 255) : colorPreset == 'Cosmic' ? color.rgb(0, 255, 157) : colorPreset == 'Ember' ? color.rgb(255, 69, 0) : color.rgb(255, 215, 0)
bearishColor2 = colorPreset == 'Classic' ? color.rgb(139, 0, 0) : colorPreset == 'Aqua' ? color.rgb(255, 69, 0) : colorPreset == 'Cosmic' ? color.rgb(138, 43, 226) : colorPreset == 'Ember' ? color.rgb(0, 139, 139) : color.rgb(255, 20, 147)
bullishCandleNeutral = colorPreset == 'Classic' ? color.rgb(0, 255, 255) : colorPreset == 'Aqua' ? color.rgb(135, 206, 250) : colorPreset == 'Cosmic' ? color.rgb(64, 224, 208) : colorPreset == 'Ember' ? color.rgb(255, 215, 0) : color.rgb(173, 255, 47)
bearishCandleNeutral = colorPreset == 'Classic' ? color.rgb(0, 0, 255) : colorPreset == 'Aqua' ? color.rgb(70, 130, 180) : colorPreset == 'Cosmic' ? color.rgb(147, 112, 219) : colorPreset == 'Ember' ? color.rgb(218, 165, 32) : color.rgb(255, 105, 180)

if colorPreset == 'Custom'
    bullishColor1 := input.color(#4caf50, '🟢 Bullish', group = '🔧 Custom Colors')
    bearishColor1 := input.color(#f23645, '🔴 Bearish', group = '🔧 Custom Colors')
    neutralColor := input.color(#808080FF, '⚪ Neutral', group = '🔧 Custom Colors')
    bullishColor2 := input.color(#008000FF, '🟢 Bullish 2', group = '🔧 Custom Colors')
    bearishColor2 := input.color(#8B0000FF, '🔴 Bearish 2', group = '🔧 Custom Colors')
    bullishCandleNeutral := input.color(#00FFFFFF, '🟡 Bull Candle', group = '🔧 Custom Colors')
    bearishCandleNeutral := input.color(#0000FFFF, '🔵 Bear Candle', group = '🔧 Custom Colors')
    bearishCandleNeutral

ribbonBullishColor = applyOpacity(bullishColor1, ribbonOpacity)
ribbonBearishColor = applyOpacity(bearishColor1, ribbonOpacity)
barBullishColor1 = applyOpacity(bullishColor1, barOpacity)
barBullishColor2 = applyOpacity(bullishColor2, barOpacity)
barBearishColor1 = applyOpacity(bearishColor1, barOpacity)
barBearishColor2 = applyOpacity(bearishColor2, barOpacity)
barNeutralColor = applyOpacity(neutralColor, barOpacity)
barBullishCandleNeutral = applyOpacity(bullishCandleNeutral, barOpacity)
barBearishCandleNeutral = applyOpacity(bearishCandleNeutral, barOpacity)

supportBaseColor = bullishColor1
resistBaseColor = bearishColor1

// ====================================================
//  MA RIBBON SETTINGS
// ====================================================
groupMA = 'MA Ribbon Settings'

anchor = input.int(0, minval = 0, title = 'Anchor TimeFrame (mins, 0=none)', group = groupMA)
showRibbon = input(false, title = 'Show Ribbon If Chart TF > Anchor', group = groupMA)

fastType = input.string(defval = 'EMA', title = 'Fast MA Type', options = ['SMA', 'EMA', 'WMA', 'VWMA', 'SMMA', 'DEMA', 'TEMA', 'LAGMA', 'LINREG', 'HullMA', 'ZEMA', 'TMA', 'SSMA'], group = groupMA)
fastLen = input.int(defval = 30, title = 'Fast MA Length', minval = 1, group = groupMA)

slowType = input.string(defval = 'EMA', title = 'Slow MA Type', options = ['SMA', 'EMA', 'WMA', 'VWMA', 'SMMA', 'DEMA', 'TEMA', 'LAGMA', 'LINREG', 'HullMA', 'ZEMA', 'TMA', 'SSMA'], group = groupMA)
slowLen = input.int(defval = 48, title = 'Slow MA Length', minval = 2, group = groupMA)

ma_src = input(close, title = 'MA Source', group = groupMA)
sBars = input(true, title = 'Show Colored Bars', group = groupMA)
uGrabClr = input(false, title = 'Use 6-tone Bar Colors', group = groupMA)
uOpen = input(false, title = 'Bars Must Open/Close Outside Ribbon', group = groupMA)

ShowMACross = input(false, title = 'Show MA Cross Alerts', group = groupMA)
ShowSwing = input(false, title = 'Show Swing Alerts', group = groupMA)
rFilter = input(false, title = 'Filter Swings to Ribbon Color', group = groupMA)
dFilter = input(false, title = 'Filter Swings to MA Slope', group = groupMA)

// ====================================================
//  MA FUNCTIONS
// ====================================================
variant_supersmoother(src, len) =>
    a1 = math.exp(-1.414 * 3.14159 / len)
    b1 = 2 * a1 * math.cos(1.414 * 3.14159 / len)
    c2 = b1
    c3 = -a1 * a1
    c1 = 1 - c2 - c3
    v9 = 0.0
    v9 := c1 * (src + nz(src[1])) / 2 + c2 * nz(v9[1]) + c3 * nz(v9[2])
    v9

variant_smoothed(src, len) =>
    v5 = 0.0
    sma_1 = ta.sma(src, len)
    v5 := na(v5[1]) ? sma_1 : (v5[1] * (len - 1) + src) / len
    v5

variant_zerolagema(src, len) =>
    xLag = (len - 1) / 2
    xEMA = src + src - src[xLag]
    ta.ema(xEMA, len)

variant_doubleema(src, len) =>
    v2 = ta.ema(src, len)
    2 * v2 - ta.ema(v2, len)

variant_tripleema(src, len) =>
    v2 = ta.ema(src, len)
    3 * (v2 - ta.ema(v2, len)) + ta.ema(ta.ema(v2, len), len)

variant_lag(p, g) =>
    L0 = 0.0
    L1 = 0.0
    L2 = 0.0
    L3 = 0.0
    L0 := (1 - g) * p + g * nz(L0[1])
    L1 := -g * L0 + nz(L0[1]) + g * nz(L1[1])
    L2 := -g * L1 + nz(L1[1]) + g * nz(L2[1])
    L3 := -g * L2 + nz(L2[1]) + g * nz(L3[1])
    (L0 + 2 * L1 + 2 * L2 + L3) / 6

variant(type, src, len, g) =>
    result = src
    if len > 1
        ema_1 = ta.ema(src, len)
        wma_1 = ta.wma(src, len)
        vwma_1 = ta.vwma(src, len)
        smma_1 = variant_smoothed(src, len)
        dema_1 = variant_doubleema(src, len)
        tema_1 = variant_tripleema(src, len)
        lagma_1 = variant_lag(src, g)
        linreg_1 = ta.linreg(src, len, 0)
        hull_1 = ta.wma(2 * ta.wma(src, len / 2) - ta.wma(src, len), math.round(math.sqrt(len)))
        ssma_1 = variant_supersmoother(src, len)
        zema_1 = variant_zerolagema(src, len)
        sma_1 = ta.sma(src, len)
        tma_1 = ta.sma(sma_1, len)
        result := type == 'EMA' ? ema_1 : type == 'WMA' ? wma_1 : type == 'VWMA' ? vwma_1 : type == 'SMMA' ? smma_1 : type == 'DEMA' ? dema_1 : type == 'TEMA' ? tema_1 : type == 'LAGMA' ? lagma_1 : type == 'LINREG' ? linreg_1 : type == 'HullMA' ? hull_1 : type == 'SSMA' ? ssma_1 : type == 'ZEMA' ? zema_1 : type == 'TMA' ? tma_1 : sma_1
        result
    result

// ====================================================
//  MA CALCULATIONS
// ====================================================
currentTFmins = timeframe.isintraday ? timeframe.multiplier : timeframe.isdaily ? timeframe.multiplier * 1440 : timeframe.isweekly ? timeframe.multiplier * 7200 : timeframe.ismonthly ? timeframe.multiplier * 30240 : timeframe.multiplier

multAnchor(anchor) =>
    mult = 1
    if timeframe.isintraday
        mult := anchor > 0 ? timeframe.multiplier <= 0 ? 1 : timeframe.multiplier >= anchor ? 1 : math.round(anchor / timeframe.multiplier) : 1
        mult
    else
        mult := anchor > 0 ? timeframe.isdaily ? anchor <= 1440 ? 1 : math.round(anchor / 1440) : timeframe.isweekly ? anchor <= 7200 ? 1 : math.round(anchor / 7200) : timeframe.ismonthly ? anchor <= 30240 ? 1 : math.round(anchor / 30240) : 1 : 1
        mult
    mult

// TradingView hard limit: indicator functions can reference max 5000 historical bars.
// Anchor logic on very low timeframes (e.g. 1m with anchor=60) can produce lengths
// far exceeding this limit. Capped at 4999 to prevent runtime errors.
_MAX_LEN = 4999
mult = multAnchor(anchor)
LengthFast = math.min(mult == 1 ? fastLen : fastLen * mult, _MAX_LEN)
LengthSlow = math.min(mult == 1 ? slowLen : slowLen * mult, _MAX_LEN)

fastMA = variant(fastType, ma_src, LengthFast, 0)
slowMA = variant(slowType, ma_src, LengthSlow, 0)

showRibbonFlag = showMARibbon and (showRibbon or anchor == 0 or currentTFmins <= anchor)

fDirection = 0
sDirection = 0
fDirection := hlc3 > fastMA ? 1 : hlc3 < fastMA ? -1 : nz(fDirection[1], 1)
sDirection := hlc3 > slowMA ? 1 : hlc3 < slowMA ? -1 : nz(sDirection[1], 1)

// ====================================================
//  MA RIBBON PLOTS
// ====================================================
fastMA_ = plot(showRibbonFlag ? fastMA : na, color = fDirection == 1 ? bullishColor1 : bearishColor1, style = plot.style_line, join = true, linewidth = 1, title = 'Fast MA')
slowMA_ = plot(showRibbonFlag ? slowMA : na, color = sDirection == 1 ? bullishColor1 : bearishColor1, style = plot.style_line, join = true, linewidth = 1, title = 'Slow MA')
fcolor = fastMA > slowMA ? ribbonBullishColor : ribbonBearishColor
fill(fastMA_, slowMA_, color = showRibbonFlag ? fcolor : na, title = 'Ribbon Fill')

// ====================================================
//  BAR COLORING
// ====================================================
getBarColor() =>
    isBullish = hlc3 > fastMA and hlc3 > slowMA and (not uOpen or open > fastMA and open > slowMA)
    isBearish = hlc3 < fastMA and hlc3 < slowMA and (not uOpen or open < fastMA and open < slowMA)
    color barColor = na
    if uGrabClr
        barColor := isBullish ? close >= open ? barBullishColor1 : barBullishColor2 : isBearish ? close >= open ? barBearishColor1 : barBearishColor2 : close >= open ? barBullishCandleNeutral : barBearishCandleNeutral
        barColor
    else
        barColor := isBullish ? barBullishColor1 : isBearish ? barBearishColor1 : barNeutralColor
        barColor
    barColor

barCol = getBarColor()
TrendingUp = fastMA > slowMA
TrendingDown = fastMA < slowMA
maCrossBarCol = TrendingUp ? barBullishColor1 : TrendingDown ? barBearishColor1 : color.blue

shouldColorBars = showRibbonFlag and sBars
shouldColorMACrossBars = showRibbonFlag and sBars and ShowMACross
finalCandleColor = shouldColorMACrossBars ? maCrossBarCol : shouldColorBars ? barCol : na
shouldShowCandle = shouldColorBars or shouldColorMACrossBars

plotcandle(shouldShowCandle ? open : na, shouldShowCandle ? high : na, shouldShowCandle ? low : na, shouldShowCandle ? close : na, title = 'Colored Candles', color = finalCandleColor, wickcolor = finalCandleColor, bordercolor = finalCandleColor)

barcolor(shouldShowCandle ? finalCandleColor : na, title = 'Bar Colours')

// ====================================================
//  MA ALERTS & SIGNALS
// ====================================================
buy = 0
sell = 0
buyT = 0
sellT = 0

buy := barCol == barBullishColor1 or barCol == barBullishColor2 ? nz(buy[1]) + 1 : 0
sell := barCol == barBearishColor1 or barCol == barBearishColor2 ? nz(sell[1]) + 1 : 0

falling_1 = ta.falling(fastMA, 2)
rising_1 = ta.rising(fastMA, 2)
buyT := buy == 0 ? 0 : rFilter and fastMA < slowMA or dFilter and falling_1 ? 0 : nz(buyT[1]) + 1
sellT := sell == 0 ? 0 : rFilter and fastMA > slowMA or dFilter and rising_1 ? 0 : nz(sellT[1]) + 1

exitbuy = nz(buyT[1]) > 0 and buyT == 0
exitsell = nz(sellT[1]) > 0 and sellT == 0

plotarrow(showRibbonFlag and ShowSwing and buyT == 1 ? 1 : na, title = 'BUY Swing Arrow', colorup = color.new(bullishColor1, 80), maxheight = 60, minheight = 50)
plotarrow(showRibbonFlag and ShowSwing and sellT == 1 ? -1 : na, title = 'SELL Swing Arrow', colordown = color.new(bearishColor1, 80), maxheight = 60, minheight = 50)

plotshape(showRibbonFlag and ShowSwing and exitbuy, title = 'BUY Exit', style = shape.xcross, location = location.belowbar, color = color.new(neutralColor, 0), text = 'Exit\nBuy', offset = 0)
plotshape(showRibbonFlag and ShowSwing and exitsell, title = 'Sell Exit', style = shape.xcross, location = location.abovebar, color = color.new(neutralColor, 0), text = 'Exit\nSell', offset = 0)

MAcrossing = ta.cross(fastMA, slowMA) ? fastMA : na
plot(showRibbonFlag and ShowMACross ? MAcrossing : na, style = plot.style_cross, linewidth = 4, color = color.new(#000000, 0))

Uptrend = TrendingUp and TrendingDown[1]
Downtrend = TrendingDown and TrendingUp[1]
bgcolor(showRibbonFlag and ShowMACross ? Uptrend ? applyOpacity(bullishColor1, 50) : Downtrend ? applyOpacity(bearishColor1, 50) : na : na)

XBuy = 0
XSell = 0
XBuy := nz(XBuy[1])
XSell := nz(XSell[1])
XBuy := TrendingUp and close > close[1] ? XBuy + 1 : TrendingDown or XBuy == 0 ? 0 : XBuy + 1
XSell := TrendingDown and close < close[1] ? XSell + 1 : TrendingUp or XSell == 0 ? 0 : XSell + 1

plotshape(showRibbonFlag and ShowMACross and XBuy == 1 ? close : na, color = color.new(#000000, 0), style = shape.triangleup, text = 'XBuy', location = location.bottom, size = size.small)
plotshape(showRibbonFlag and ShowMACross and XSell == 1 ? close : na, color = color.new(#000000, 0), style = shape.triangledown, text = 'XSell', location = location.top, size = size.small)

// ====================================================
//  MA VARIABLE ALERTS
// ====================================================
i_alert_mode = input.string(alert.freq_once_per_bar_close, 'Alerts Mode', group = 'MA Variable Alerts', options = [alert.freq_once_per_bar, alert.freq_once_per_bar_close])
XBuyy = input.bool(false, 'TREND UP X BUY', group = 'MA Variable Alerts')
XSelll = input.bool(false, 'TREND DOWN X SELL', group = 'MA Variable Alerts')
buyTT = input.bool(false, 'EMA CROSS BUY', group = 'MA Variable Alerts')
sellTT = input.bool(false, 'EMA CROSS SELL', group = 'MA Variable Alerts')
exitbuyy = input.bool(false, 'ExitCrossBuy', group = 'MA Variable Alerts')
exitselll = input.bool(false, 'ExitCrossSell', group = 'MA Variable Alerts')

_alert(cond, txt) =>
    if cond
        alert(txt + timeframe.period + ' chart. Price is ' + str.tostring(close), i_alert_mode)

alertcondition(showRibbonFlag and buyT == 1, title = 'BUY Alert', message = 'BUY')
alertcondition(showRibbonFlag and sellT == 1, title = 'SELL Alert', message = 'SELL')
alertcondition(showRibbonFlag and XBuy == 1, title = 'X BUY Alert', message = 'X BUY')
alertcondition(showRibbonFlag and XSell == 1, title = 'X SELL Alert', message = 'X SELL')
alertcondition(showRibbonFlag and exitbuy, title = 'BUY Exit Alert', message = 'ExitBuy')
alertcondition(showRibbonFlag and exitsell, title = 'SELL Exit Alert', message = 'ExitSell')

_alert(XBuyy and XBuy > 0, 'TREND UP X BUY Alert')
_alert(XSelll and XSell > 0, 'TREND DOWN X SELL Alert')
_alert(buyTT and buyT > 0, 'EMA CROSS BUY Alert')
_alert(sellTT and sellT > 0, 'EMA CROSS SELL Alert')
_alert(exitbuyy and exitbuy, 'ExitCrossBuy Alert')
_alert(exitselll and exitsell, 'ExitCrossSell')

// ====================================================
//  SUPPORT/RESISTANCE SETTINGS
// ====================================================
groupAlert = 'S/R Alert Settings'
mainResistanceAlert = input.bool(true, '⚡ Main Resistance Alert', tooltip = 'Alert when price touches main resistance', group = groupAlert)
mainSupportAlert = input.bool(true, '⚡ Main Support Alert', tooltip = 'Alert when price touches main support', group = groupAlert)
strongResistanceAlert = input.bool(true, 'Strong Resistance Alert', tooltip = 'Alert when price touches strong resistance', group = groupAlert)
strongSupportAlert = input.bool(true, 'Strong Support Alert', tooltip = 'Alert when price touches strong support', group = groupAlert)
tolerance = input.float(0.1, 'Touch Tolerance %', tooltip = 'Price tolerance for touch alerts', minval = 0.01, maxval = 1.0, step = 0.01, group = groupAlert) * 0.01
alertBreakout = input.bool(true, 'Alert on Breakout', group = groupAlert, tooltip = 'Alert when price closes beyond a main level')
alertRetest = input.bool(true, 'Alert on Retest', group = groupAlert, tooltip = 'Alert when price retests a broken level')
alertRejection = input.bool(false, 'Alert on Rejection', group = groupAlert, tooltip = 'Alert when price wicks beyond level but closes back')
breakoutMinPctInput = input.float(0.2, 'Min Breakout Distance %', group = groupAlert, minval = 0.0, maxval = 5.0, step = 0.05, tooltip = 'Minimum % distance beyond level to confirm breakout')
breakoutMinPct = breakoutMinPctInput * 0.01
alertCooldownBars = input.int(5, 'Min Bars Between Alerts', group = groupAlert, minval = 0, maxval = 500, tooltip = 'Minimum bars between alerts')

var int lastAlertBar = na

fireAlert(string msg) =>
    int _last = lastAlertBar
    if alertCooldownBars == 0
        alert(msg, alert.freq_once_per_bar)
        _last := bar_index
        _last
    else
        if na(_last) or bar_index - _last >= alertCooldownBars
            alert(msg, alert.freq_once_per_bar)
            _last := bar_index
            _last
    _last

// ====================================================
//  S/R CORE SETTINGS
// ====================================================
groupCore = 'S/R Core Settings'
corePreset = input.string('Custom', 'Pivot Sensitivity Preset', options = ['Scalp', 'Intraday', 'Swing', 'Custom'], group = groupCore, tooltip = 'Preset pivot sensitivity')
leftInput = input.int(50, 'Left Bars', group = groupCore, tooltip = 'Bars to left for pivot detection')
rightInput = input.int(25, 'Right Bars', group = groupCore, tooltip = 'Bars to right for pivot confirmation')
quickRightInput = input.int(5, 'Quick Right', group = groupCore, tooltip = 'Right bars for quick pivot detection')
src = input.string('High/Low', 'Source', options = ['Close', 'High/Low', 'Mixed (Wick/Close)'], group = groupCore, tooltip = 'Price source for pivot calculations')

left = corePreset == 'Scalp' ? 20 : corePreset == 'Intraday' ? 30 : corePreset == 'Swing' ? 50 : leftInput
right = corePreset == 'Scalp' ? 10 : corePreset == 'Intraday' ? 15 : corePreset == 'Swing' ? 25 : rightInput
quick_right = corePreset == 'Scalp' ? 3 : corePreset == 'Intraday' ? 5 : corePreset == 'Swing' ? 5 : quickRightInput

// ====================================================
//  S/R DISPLAY SETTINGS
// ====================================================
groupDisp = 'S/R Display Settings'
line_thickness = input.int(2, 'Line Thickness', minval = 1, maxval = 5, group = groupDisp)
num_levels = input.int(8, 'Number of Levels', minval = 4, maxval = 12, group = groupDisp, tooltip = 'Total S/R levels (max 12 for performance)')
show_labels = input.bool(true, 'Show Labels', group = groupDisp)
label_offset = input.int(10, 'Label Right Offset', minval = 0, maxval = 50, group = groupDisp)
label_size = input.string('Normal', 'Label Size', options = ['Small', 'Normal', 'Large', 'Very Large'], group = groupDisp)
show_price = input.bool(true, 'Show Price in Labels', group = groupDisp)
decimal_places = input.int(5, 'Decimal Places', minval = 0, maxval = 8, group = groupDisp)

label_text_color_option = input.string('Auto (Smart Contrast)', 'Label Text Color', options = ['Auto (Smart Contrast)', 'Black', 'White', 'Custom'], group = groupDisp, tooltip = 'Choose label text color for best readability')
custom_label_text_color = input.color(color.black, 'Custom Text Color', group = groupDisp)

getTextColor(bgColor) =>
    if label_text_color_option == 'Black'
        color.black
    else if label_text_color_option == 'White'
        color.white
    else if label_text_color_option == 'Custom'
        custom_label_text_color
    else
        r = color.r(bgColor)
        g = color.g(bgColor)
        b = color.b(bgColor)
        brightness = (r * 299 + g * 587 + b * 114) / 1000
        brightness > 128 ? color.black : color.white

// ====================================================
//  S/R SMART STRENGTH FILTER
// ====================================================
strength_group = 'S/R Strength Filter'
use_strength_filter = input.bool(false, 'Filter by Strength', group = strength_group, tooltip = 'Show only levels with enough touches')
strength_lookback = input.int(100, 'Lookback Bars', group = strength_group, minval = 10, maxval = 5000)
min_touch_count = input.int(2, 'Minimum Touch Count', group = strength_group, minval = 1, maxval = 20)
strength_tol_pct_input = input.float(0.1, 'Touch Tolerance %', group = strength_group, minval = 0.01, maxval = 2.0, step = 0.01)
strength_tol_pct = strength_tol_pct_input * 0.01

// ====================================================
//  S/R HEAT MAP
// ====================================================
heat_group = 'S/R Heat Map Colors'
use_heatmap = input.bool(false, 'Use Heat Map Intensity', group = heat_group)
heat_max_touch = input.int(6, 'Touch Count for Max Intensity', group = heat_group, minval = 1, maxval = 20)

// ====================================================
//  S/R MULTI TIME FRAME
//  FIX: barmerge.lookahead_off prevents lookahead bias on
//       historical bars. HTF data updates at each HTF bar close.
// ====================================================
groupMTF = 'S/R Multi Time Frame'
timeframe_sr = input.timeframe('', 'Higher Timeframe', tooltip = 'Timeframe for MTF S/R analysis. Levels update at each HTF bar close (no lookahead bias).', group = groupMTF)
use_mtf = input.bool(false, 'Use Multi Time Frame', tooltip = 'Overlay S/R levels from a higher timeframe. Uses lookahead_off — no future leakage.', group = groupMTF)

// ====================================================
//  S/R HELPERS
// ====================================================
get_label_size() =>
    switch label_size
        'Small' => size.tiny
        'Normal' => size.small
        'Large' => size.normal
        'Very Large' => size.large
        => size.small

label_size_val = get_label_size()

get_format_string(decimal_count) =>
    if decimal_count > 0
        format_str = '.'
        for i = 1 to decimal_count by 1
            format_str := format_str + '0'
            format_str
        format_str
    else
        ''

// ====================================================
//  S/R LEVEL ENGINE — TIMEFRAME-CORRECT MTF
//
//  BUG FIX: Previously the HTF high/low/close were pulled down to the
//  chart with request.security and then pivots (ta.pivothigh/low) were
//  detected on the CHART timeline. That meant the pivot windows
//  (left / right / quick_right) counted CHART bars, not HTF bars, and
//  ran over a stair-stepped HTF series. Result: the levels drawn from a
//  4H HTF on a 1H chart did NOT line up with the levels the same
//  indicator draws natively on a 4H chart.
//
//  CORRECT APPROACH: run the ENTIRE pivot + level computation inside the
//  requested timeframe's own context (request.security of a function),
//  so pivots are detected NATIVELY on the HTF and only the finished
//  level VALUES are brought down to the chart. When MTF is off, sr_tf
//  resolves to the chart timeframe, so the security call is an identity
//  (== native). lookahead_off keeps everything free of future leakage.
// ====================================================
computeSRLevels(h, l, c) =>
    hi_final = src == 'Close' ? c : h
    lo_final = src == 'Close' ? c : l
    hi_main = h
    lo_main = l
    hi_oth = src == 'Mixed (Wick/Close)' ? c : hi_final
    lo_oth = src == 'Mixed (Wick/Close)' ? c : lo_final

    ph_main = ta.pivothigh(hi_main, left, quick_right)
    pl_main = ta.pivotlow(lo_main, left, quick_right)
    ph_strong = ta.pivothigh(hi_main, left, right)
    pl_strong = ta.pivotlow(lo_main, left, right)
    ph_oth = ta.pivothigh(hi_oth, left, right)
    pl_oth = ta.pivotlow(lo_oth, left, right)

    b_ph_main = not na(ph_main)
    b_pl_main = not na(pl_main)
    b_ph_strong = not na(ph_strong)
    b_pl_strong = not na(pl_strong)
    b_ph_oth = not na(ph_oth)
    b_pl_oth = not na(pl_oth)

    l1 = ta.valuewhen(b_ph_main, hi_main[quick_right], 0)
    l2 = ta.valuewhen(b_pl_main, lo_main[quick_right], 0)
    l3 = ta.valuewhen(b_ph_strong, hi_main[right], 0)
    l4 = ta.valuewhen(b_pl_strong, lo_main[right], 0)
    l5 = ta.valuewhen(b_ph_oth, hi_oth[right], 1)
    l6 = ta.valuewhen(b_pl_oth, lo_oth[right], 1)
    l7 = ta.valuewhen(b_ph_oth, hi_oth[right], 2)
    l8 = ta.valuewhen(b_pl_oth, lo_oth[right], 2)
    l9 = ta.valuewhen(b_ph_oth, hi_oth[right], 3)
    l10 = ta.valuewhen(b_pl_oth, lo_oth[right], 3)
    l11 = ta.valuewhen(b_ph_oth, hi_oth[right], 4)
    l12 = ta.valuewhen(b_pl_oth, lo_oth[right], 4)
    [l1, l2, l3, l4, l5, l6, l7, l8, l9, l10, l11, l12]

// MTF on -> requested HTF; MTF off -> chart timeframe (identity, == native)
sr_tf = use_mtf and timeframe_sr != '' ? timeframe_sr : timeframe.period

[level1, level2, level3, level4, level5, level6, level7, level8, level9, level10, level11, level12] = request.security(syminfo.tickerid, sr_tf, computeSRLevels(high, low, close), barmerge.gaps_off, barmerge.lookahead_off)

// ====================================================
//  S/R TOUCH COUNTS
// ====================================================
calcTouches = use_strength_filter or use_heatmap

touchCount(level) =>
    float cnt = 0.0
    if calcTouches and not na(level)
        for i = 0 to math.min(strength_lookback - 1, bar_index) by 1
            float price = close[i]
            bool isTouch = not na(price) and math.abs(price - level) <= level * strength_tol_pct
            if isTouch
                cnt := cnt + 1.0
                cnt
    cnt

float tc1 = calcTouches and not na(level1) ? touchCount(level1) : na
float tc2 = calcTouches and not na(level2) ? touchCount(level2) : na
float tc3 = calcTouches and not na(level3) ? touchCount(level3) : na
float tc4 = calcTouches and not na(level4) ? touchCount(level4) : na
float tc5 = calcTouches and not na(level5) ? touchCount(level5) : na
float tc6 = calcTouches and not na(level6) ? touchCount(level6) : na
float tc7 = calcTouches and not na(level7) ? touchCount(level7) : na
float tc8 = calcTouches and not na(level8) ? touchCount(level8) : na
float tc9 = calcTouches and not na(level9) ? touchCount(level9) : na
float tc10 = calcTouches and not na(level10) ? touchCount(level10) : na
float tc11 = calcTouches and not na(level11) ? touchCount(level11) : na
float tc12 = calcTouches and not na(level12) ? touchCount(level12) : na

isStrong(tc) =>
    not use_strength_filter or nz(tc) >= min_touch_count

// ====================================================
//  S/R COLORS
// ====================================================
current_close = close

baseColor(level) =>
    current_close >= level ? supportBaseColor : resistBaseColor

heatColor(colBase, float touches) =>
    if not use_heatmap
        colBase
    else
        cnt = na(touches) ? 0.0 : touches
        ratio = heat_max_touch > 0 ? math.min(cnt / heat_max_touch, 1.0) : 0.0
        transp = 80 - int(ratio * 60)
        color.new(colBase, transp)

level1_col = not na(level1) ? heatColor(baseColor(level1), tc1) : color.new(color.red, 100)
level2_col = not na(level2) ? heatColor(baseColor(level2), tc2) : color.new(color.red, 100)
level3_col = not na(level3) ? heatColor(baseColor(level3), tc3) : color.new(color.red, 100)
level4_col = not na(level4) ? heatColor(baseColor(level4), tc4) : color.new(color.red, 100)
level5_col = not na(level5) ? heatColor(baseColor(level5), tc5) : color.new(color.red, 100)
level6_col = not na(level6) ? heatColor(baseColor(level6), tc6) : color.new(color.red, 100)
level7_col = not na(level7) ? heatColor(baseColor(level7), tc7) : color.new(color.red, 100)
level8_col = not na(level8) ? heatColor(baseColor(level8), tc8) : color.new(color.red, 100)
level9_col = not na(level9) ? heatColor(baseColor(level9), tc9) : color.new(color.red, 100)
level10_col = not na(level10) ? heatColor(baseColor(level10), tc10) : color.new(color.red, 100)
level11_col = not na(level11) ? heatColor(baseColor(level11), tc11) : color.new(color.red, 100)
level12_col = not na(level12) ? heatColor(baseColor(level12), tc12) : color.new(color.red, 100)

// ====================================================
//  S/R LABEL TEXT
// ====================================================
create_label_text(level_name, level_value) =>
    if show_price
        format_str = get_format_string(decimal_places)
        mtf_info = use_mtf and timeframe_sr != '' ? ' [' + timeframe_sr + ']' : ''
        level_name + mtf_info + ' (' + str.tostring(level_value, format_str) + ')'
    else
        level_name + (use_mtf and timeframe_sr != '' ? ' [' + timeframe_sr + ']' : '')

// ====================================================
//  S/R ALERT CONDITIONS
// ====================================================
main_resistance_touch = not na(level1) and math.abs(close - level1) <= level1 * tolerance
main_support_touch = not na(level2) and math.abs(close - level2) <= level2 * tolerance
strong_resistance_touch = not na(level3) and math.abs(close - level3) <= level3 * tolerance
strong_support_touch = not na(level4) and math.abs(close - level4) <= level4 * tolerance

prevClose = bar_index > 0 ? close[1] : na

main_res_breakout_up = alertBreakout and not na(prevClose) and not na(level1) and prevClose <= level1 and close > level1 * (1.0 + breakoutMinPct)
main_sup_breakout_down = alertBreakout and not na(prevClose) and not na(level2) and prevClose >= level2 and close < level2 * (1.0 - breakoutMinPct)

var bool mainResBrokenUp = false
var bool mainSupBrokenDown = false

main_res_retest = alertRetest and mainResBrokenUp and not na(level1) and low <= level1 * (1.0 + tolerance) and low >= level1 * (1.0 - tolerance) and close > level1
main_sup_retest = alertRetest and mainSupBrokenDown and not na(level2) and high >= level2 * (1.0 - tolerance) and high <= level2 * (1.0 + tolerance) and close < level2

main_res_rejection = alertRejection and not na(level1) and high > level1 * (1.0 + tolerance) and close < level1
main_sup_rejection = alertRejection and not na(level2) and low < level2 * (1.0 - tolerance) and close > level2

var bool inMainResZone = false
var bool inMainSupZone = false
var bool inStrongResZone = false
var bool inStrongSupZone = false

// ====================================================
//  S/R ALERT FIRING
// ====================================================
if showSupportResistance
    if main_res_breakout_up
        mainResBrokenUp := true
        lastAlertBar := fireAlert('🚀 BREAKOUT ABOVE MAIN RESISTANCE - ' + syminfo.ticker + ' (' + timeframe.period + ') Close: ' + str.tostring(close) + ' | Level: ' + str.tostring(level1))
        lastAlertBar

    if main_sup_breakout_down
        mainSupBrokenDown := true
        lastAlertBar := fireAlert('📉 BREAKDOWN BELOW MAIN SUPPORT - ' + syminfo.ticker + ' (' + timeframe.period + ') Close: ' + str.tostring(close) + ' | Level: ' + str.tostring(level2))
        lastAlertBar

    if main_res_retest
        mainResBrokenUp := false
        lastAlertBar := fireAlert('🔁 RETEST OF BROKEN MAIN RESISTANCE - ' + syminfo.ticker + ' (' + timeframe.period + ') Price: ' + str.tostring(close) + ' | Level: ' + str.tostring(level1))
        lastAlertBar

    if main_sup_retest
        mainSupBrokenDown := false
        lastAlertBar := fireAlert('🔁 RETEST OF BROKEN MAIN SUPPORT - ' + syminfo.ticker + ' (' + timeframe.period + ') Price: ' + str.tostring(close) + ' | Level: ' + str.tostring(level2))
        lastAlertBar

    if main_res_rejection
        lastAlertBar := fireAlert('♻️ REJECTION AT MAIN RESISTANCE - ' + syminfo.ticker + ' (' + timeframe.period + ') Close: ' + str.tostring(close) + ' | Level: ' + str.tostring(level1))
        lastAlertBar

    if main_sup_rejection
        lastAlertBar := fireAlert('♻️ REJECTION AT MAIN SUPPORT - ' + syminfo.ticker + ' (' + timeframe.period + ') Close: ' + str.tostring(close) + ' | Level: ' + str.tostring(level2))
        lastAlertBar

    if main_resistance_touch
        if not inMainResZone and mainResistanceAlert
            lastAlertBar := fireAlert('⚡ MAIN RESISTANCE TOUCH - ' + syminfo.ticker + ' (' + timeframe.period + ') Price: ' + str.tostring(close) + ' | Level: ' + str.tostring(level1))
            lastAlertBar
        inMainResZone := true
        inMainResZone
    else
        inMainResZone := false
        inMainResZone

    if main_support_touch
        if not inMainSupZone and mainSupportAlert
            lastAlertBar := fireAlert('⚡ MAIN SUPPORT TOUCH - ' + syminfo.ticker + ' (' + timeframe.period + ') Price: ' + str.tostring(close) + ' | Level: ' + str.tostring(level2))
            lastAlertBar
        inMainSupZone := true
        inMainSupZone
    else
        inMainSupZone := false
        inMainSupZone

    if strong_resistance_touch
        if not inStrongResZone and strongResistanceAlert
            lastAlertBar := fireAlert('🎯 STRONG RESISTANCE TOUCH - ' + syminfo.ticker + ' (' + timeframe.period + ') Price: ' + str.tostring(close) + ' | Level: ' + str.tostring(level3))
            lastAlertBar
        inStrongResZone := true
        inStrongResZone
    else
        inStrongResZone := false
        inStrongResZone

    if strong_support_touch
        if not inStrongSupZone and strongSupportAlert
            lastAlertBar := fireAlert('🎯 STRONG SUPPORT TOUCH - ' + syminfo.ticker + ' (' + timeframe.period + ') Price: ' + str.tostring(close) + ' | Level: ' + str.tostring(level4))
            lastAlertBar
        inStrongSupZone := true
        inStrongSupZone
    else
        inStrongSupZone := false
        inStrongSupZone

// ====================================================
//  S/R PLOT CONDITIONS
// ====================================================
cond1 = showSupportResistance and num_levels >= 1 and not na(level1) and isStrong(tc1)
cond2 = showSupportResistance and num_levels >= 2 and not na(level2) and isStrong(tc2)
cond3 = showSupportResistance and num_levels >= 3 and not na(level3) and isStrong(tc3)
cond4 = showSupportResistance and num_levels >= 4 and not na(level4) and isStrong(tc4)
cond5 = showSupportResistance and num_levels >= 5 and not na(level5) and isStrong(tc5)
cond6 = showSupportResistance and num_levels >= 6 and not na(level6) and isStrong(tc6)
cond7 = showSupportResistance and num_levels >= 7 and not na(level7) and isStrong(tc7)
cond8 = showSupportResistance and num_levels >= 8 and not na(level8) and isStrong(tc8)
cond9 = showSupportResistance and num_levels >= 9 and not na(level9) and isStrong(tc9)
cond10 = showSupportResistance and num_levels >= 10 and not na(level10) and isStrong(tc10)
cond11 = showSupportResistance and num_levels >= 11 and not na(level11) and isStrong(tc11)
cond12 = showSupportResistance and num_levels >= 12 and not na(level12) and isStrong(tc12)

// ====================================================
//  S/R PLOTS
// ====================================================
plot(cond1 ? level1 : na, title = '⚡ Main Resistance', style = plot.style_circles, color = level1_col, show_last = 3, linewidth = math.max(1, line_thickness), trackprice = true)
plot(cond2 ? level2 : na, title = '⚡ Main Support', style = plot.style_circles, color = level2_col, show_last = 3, linewidth = math.max(1, line_thickness), trackprice = true)
plot(cond3 ? level3 : na, title = 'Strong Resistance', style = plot.style_circles, color = level3_col, show_last = 3, linewidth = math.max(1, line_thickness), trackprice = true)
plot(cond4 ? level4 : na, title = 'Strong Support', style = plot.style_circles, color = level4_col, show_last = 3, linewidth = math.max(1, line_thickness), trackprice = true)
plot(cond5 ? level5 : na, title = 'Resistance 1', style = plot.style_circles, color = level5_col, show_last = 3, linewidth = math.max(1, line_thickness), trackprice = true)
plot(cond6 ? level6 : na, title = 'Support 1', style = plot.style_circles, color = level6_col, show_last = 3, linewidth = math.max(1, line_thickness), trackprice = true)
plot(cond7 ? level7 : na, title = 'Resistance 2', style = plot.style_circles, color = level7_col, show_last = 3, linewidth = math.max(1, line_thickness), trackprice = true)
plot(cond8 ? level8 : na, title = 'Support 2', style = plot.style_circles, color = level8_col, show_last = 3, linewidth = math.max(1, line_thickness), trackprice = true)
plot(cond9 ? level9 : na, title = 'Resistance 3', style = plot.style_circles, color = level9_col, show_last = 3, linewidth = math.max(1, line_thickness), trackprice = true)
plot(cond10 ? level10 : na, title = 'Support 3', style = plot.style_circles, color = level10_col, show_last = 3, linewidth = math.max(1, line_thickness), trackprice = true)
plot(cond11 ? level11 : na, title = 'Resistance 4', style = plot.style_circles, color = level11_col, show_last = 3, linewidth = math.max(1, line_thickness), trackprice = true)
plot(cond12 ? level12 : na, title = 'Support 4', style = plot.style_circles, color = level12_col, show_last = 3, linewidth = math.max(1, line_thickness), trackprice = true)

// ====================================================
//  S/R LABELS
// ====================================================
var array<label> srLabels = array.new_label()

if show_labels and barstate.islast and showSupportResistance
    while array.size(srLabels) > 0
        label.delete(array.pop(srLabels))

    label_x = bar_index + label_offset

    if cond1
        array.push(srLabels, label.new(label_x, level1, create_label_text('⚡ Main Resistance', level1), xloc.bar_index, yloc.price, level1_col, label.style_label_left, getTextColor(level1_col), label_size_val))
    if cond2
        array.push(srLabels, label.new(label_x, level2, create_label_text('⚡ Main Support', level2), xloc.bar_index, yloc.price, level2_col, label.style_label_left, getTextColor(level2_col), label_size_val))
    if cond3
        array.push(srLabels, label.new(label_x, level3, create_label_text('Strong Resistance', level3), xloc.bar_index, yloc.price, level3_col, label.style_label_left, getTextColor(level3_col), label_size_val))
    if cond4
        array.push(srLabels, label.new(label_x, level4, create_label_text('Strong Support', level4), xloc.bar_index, yloc.price, level4_col, label.style_label_left, getTextColor(level4_col), label_size_val))
    if cond5
        array.push(srLabels, label.new(label_x, level5, create_label_text('Resistance 1', level5), xloc.bar_index, yloc.price, level5_col, label.style_label_left, getTextColor(level5_col), label_size_val))
    if cond6
        array.push(srLabels, label.new(label_x, level6, create_label_text('Support 1', level6), xloc.bar_index, yloc.price, level6_col, label.style_label_left, getTextColor(level6_col), label_size_val))
    if cond7
        array.push(srLabels, label.new(label_x, level7, create_label_text('Resistance 2', level7), xloc.bar_index, yloc.price, level7_col, label.style_label_left, getTextColor(level7_col), label_size_val))
    if cond8
        array.push(srLabels, label.new(label_x, level8, create_label_text('Support 2', level8), xloc.bar_index, yloc.price, level8_col, label.style_label_left, getTextColor(level8_col), label_size_val))
    if cond9
        array.push(srLabels, label.new(label_x, level9, create_label_text('Resistance 3', level9), xloc.bar_index, yloc.price, level9_col, label.style_label_left, getTextColor(level9_col), label_size_val))
    if cond10
        array.push(srLabels, label.new(label_x, level10, create_label_text('Support 3', level10), xloc.bar_index, yloc.price, level10_col, label.style_label_left, getTextColor(level10_col), label_size_val))
    if cond11
        array.push(srLabels, label.new(label_x, level11, create_label_text('Resistance 4', level11), xloc.bar_index, yloc.price, level11_col, label.style_label_left, getTextColor(level11_col), label_size_val))
    if cond12
        array.push(srLabels, label.new(label_x, level12, create_label_text('Support 4', level12), xloc.bar_index, yloc.price, level12_col, label.style_label_left, getTextColor(level12_col), label_size_val))
````
