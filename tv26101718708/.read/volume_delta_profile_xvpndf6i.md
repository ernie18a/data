# Volume Delta Profile

- url: https://www.tradingview.com/script/xvPndf6I/
- type: indicator
- pine_id: PUB;10fea7eff5fe413595ab77de1d185093
- version: 1.0

## Description

Volume Delta Profile

The Volume Delta Profile is an overlay indicator that builds a horizontal volume delta distribution directly on the price chart, similar to a Market Profile or Volume Profile but using net delta (buying pressure minus selling pressure) as the core metric instead of raw traded volume.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
WHAT IS VOLUME DELTA?
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Volume delta measures the difference between aggressive buying volume (market buy orders hitting the ask) and aggressive selling volume (market sell orders hitting the bid) within a given candle. A positive delta means buyers were more aggressive during that candle. A negative delta means sellers were more aggressive.

This indicator uses TradingView's native ta.requestVolumeDelta() function, which reconstructs delta by scanning a lower timeframe (automatically selected or manually configured) to approximate the split between up-volume and down-volume for each candle.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
HOW IT WORKS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

The indicator scans a configurable number of historical bars (default: 500) and for each bar assigns its volume delta to a price level based on the closing price of that bar. Price levels are divided into equally spaced buckets across the high-to-low range of the lookback period.

Positive delta (net buying) accumulates in the bullish bucket of that price level.
Negative delta (net selling) accumulates in the bearish bucket of that price level.

The result is a horizontal bar chart displayed to the right of the last candle, where each row represents a price level and the width of the bar represents the total delta activity at that level. The color of each bar reflects which side dominated:

• Teal bars → net buying pressure dominated at that price level
• Pink/red bars → net selling pressure dominated at that price level

The Point of Control (POC) is marked as a solid horizontal line extending 50 bars to the left, highlighting the price level where the highest total delta activity occurred across the entire lookback period.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
COMPONENTS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

1. Delta Profile (horizontal bars)
   A visual distribution of accumulated volume delta across price levels. Each bar's width is proportional to the total delta activity at that level relative to the most active level. Bars are color-coded by dominant side (buyers vs sellers).

2. Point of Control (POC)
   The price level with the highest total delta activity in the lookback window. Displayed as a solid horizontal line extending 50 bars to the left of the current bar. This is the price where the most aggressive order flow occurred — institutional interest tends to concentrate here.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
SETTINGS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

• Lookback bars (default 500): Number of historical candles to include in the profile. More bars give a broader context; fewer bars focus on recent activity.

• Bar width (default 20): Visual width in pixels of the widest bar in the profile. Adjust for chart readability.

• Price levels (default 50): Number of horizontal buckets the price range is divided into. More levels give finer granularity; fewer levels give a smoother, broader view.

• Positive delta color (default teal): Color for price levels where buying pressure dominated.

• Negative delta color (default pink): Color for price levels where selling pressure dominated.

• POC color (default black): Color of the Point of Control line.

• Profile offset (default 10): Horizontal distance in bars between the last candle and the left edge of the profile. Increase to avoid overlap with live price action.

• Custom timeframe: Override the automatic lower timeframe used for delta reconstruction. Higher timeframes load more history but reduce precision.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
HOW TO INTERPRET IT
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

DOMINANT COLOR ZONES
Large teal zones indicate price areas where institutional buyers were consistently aggressive. These levels tend to act as support — if price returns to them, buyers are likely to defend the level. Large pink zones indicate areas of consistent selling aggression, which tend to act as resistance or liquidity targets for short-side participants.

PROFILE SHAPE
A profile with a clear peak (narrow, tall distribution) suggests price spent most of its time and order flow at a specific level — strong agreement on value. A wide, flat profile suggests price moved across a broad range without clear absorption at any single level.

POINT OF CONTROL (POC)
The POC is the single most important level in the profile. It represents where the maximum institutional order flow occurred. Price has a strong tendency to gravitate back toward the POC after extended moves away from it, making it a high-probability mean-reversion target. It also acts as a decisive level: a clean break and hold above a teal POC confirms bullish institutional commitment; a rejection at a pink POC confirms continued distribution.

DIVERGENCE BETWEEN COLOR AND PRICE MOVEMENT
If price fell sharply through a level but the profile shows teal (net buying) at that level, it suggests absorption — institutions were buying the selling pressure. This is often a precursor to a reversal. Conversely, if price rose through a level but the profile shows pink, distribution was occurring into the rally.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
HOW TO USE IT
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

1. IDENTIFY THE VALUE AREA
   Look for the widest bars in the profile — these are the price levels with the most delta activity. The market considers these levels "fair value." Price tends to spend more time here and frequently returns to these zones after deviation.

2. USE THE POC AS A MAGNET
   If price is trading significantly above or below the POC, there is a structural tendency to return to it. The POC acts as a mean-reversion target, especially in range-bound or post-impulse conditions.

3. READ THE COLOR FOR BIAS
   Before entering a trade, check the delta color at the relevant support or resistance level. A teal zone below current price strengthens a long bias — institutions were buying there. A pink zone above current price strengthens a short bias — institutions were selling there.

4. SPOT ABSORPTION
   Large teal bars at price lows or large pink bars at price highs are signs of institutional absorption. These are the exact footprints of Wyckoff accumulation and distribution phases — smart money absorbing retail order flow before the next directional move.

5. COMBINE WITH STRUCTURE
   Use this indicator alongside your market structure analysis. A key structural level (support, resistance, order block) that coincides with a high-delta POC or dominant color zone has significantly higher probability of holding or acting as a reversal point.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
NOTES
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

• Delta data requires a data provider that supplies volume. The indicator will throw a runtime error if volume data is unavailable for the selected symbol.
• The profile updates on bar close and on the last real-time bar to keep the display current without excessive recalculation.
• Works on any timeframe and any instrument with volume data: forex, indices, crypto, commodities, equities.
• For best results on higher timeframes (daily, weekly), enable the custom timeframe option and select a higher sub-timeframe (e.g., "60") to ensure sufficient historical delta data is available.

## Source Code

````pine
//@version=6
indicator("Volume Delta Profile", overlay=true, max_boxes_count=500, max_bars_back=500, max_lines_count=5)

import TradingView/ta/8

// ─── INPUTS ───────────────────────────────────────────────────────────────────
lookback        = input.int(500,   "Rango de barras",                minval=10, maxval=500)
box_width       = input.int(20,    "Ancho barras (píxeles)",         minval=1,  maxval=100)
price_levels    = input.int(50,    "Niveles de precio",              minval=10, maxval=100)
bull_col        = input.color(color.teal,                            "Color delta positivo")
bear_col        = input.color(color.rgb(255, 102, 178),              "Color delta negativo")
poc_col         = input.color(color.black,                           "Color POC")
profile_offset  = input.int(10,    "Separación del precio (barras)", minval=1, maxval=50)

lowerTimeframeTooltip = "The indicator scans lower timeframe data to approximate up and down volume used in the delta calculation. By default, the timeframe is chosen automatically. These inputs override this with a custom timeframe."
 + " \n\nHigher timeframes provide more historical data, but the data will be less precise."
useCustomTimeframeInput = input.bool(false, "Use custom timeframe", tooltip=lowerTimeframeTooltip)
lowerTimeframeInput     = input.timeframe("1", "Timeframe", active=useCustomTimeframeInput)

var lowerTimeframe = switch
    useCustomTimeframeInput => lowerTimeframeInput
    timeframe.isseconds     => "1S"
    timeframe.isintraday    => "1"
    timeframe.isdaily       => "5"
    => "60"

// ─── PRECARGA DE HISTORIAL ────────────────────────────────────────────────────
var float _ph = ta.highest(high, 500)
var float _pl = ta.lowest(low,   500)

// ─── DELTA ────────────────────────────────────────────────────────────────────
[openVolume, maxVolume, minVolume, lastVolume] = ta.requestVolumeDelta(lowerTimeframe)

// ─── CONSTRUCCIÓN DEL PERFIL ──────────────────────────────────────────────────
var array<box> profile_boxes = array.new_box()
var line       poc_line      = na

if barstate.isconfirmed or barstate.islast
    for b in profile_boxes
        box.delete(b)
    array.clear(profile_boxes)
    if not na(poc_line)
        line.delete(poc_line)

    float hi         = ta.highest(high, lookback)
    float lo         = ta.lowest(low,   lookback)
    float level_size = (hi - lo) / price_levels

    array<float> bull_delta = array.new_float(price_levels, 0.0)
    array<float> bear_delta = array.new_float(price_levels, 0.0)

    for i = 0 to lookback - 1
        if bar_index - i >= 0
            float d   = lastVolume[i]
            int   lvl = math.floor((close[i] - lo) / level_size)
            lvl      := math.min(lvl, price_levels - 1)
            lvl      := math.max(lvl, 0)

            if d >= 0
                array.set(bull_delta, lvl, array.get(bull_delta, lvl) + d)
            else
                array.set(bear_delta, lvl, array.get(bear_delta, lvl) + math.abs(d))

    float max_abs = 0.0
    for i = 0 to price_levels - 1
        float v = array.get(bull_delta, i) + array.get(bear_delta, i)
        if v > max_abs
            max_abs := v

    int x_right = bar_index + profile_offset
    int x_left  = x_right - box_width

    if max_abs > 0
        for i = 0 to price_levels - 1
            float bulls = array.get(bull_delta, i)
            float bears = array.get(bear_delta, i)
            float total = bulls + bears

            if total > 0
                float ratio = total / max_abs
                int   x_l   = x_right - math.round(box_width * ratio)
                float y_bot = lo + i * level_size
                float y_top = y_bot + level_size * 0.9
                color c     = bulls >= bears ? bull_col : bear_col

                box b = box.new(
                     left         = x_l,
                     top          = y_top,
                     right        = x_right,
                     bottom       = y_bot,
                     bgcolor      = color.new(c, 30),
                     border_color = color.new(c, 60),
                     border_width = 1,
                     xloc         = xloc.bar_index)
                array.push(profile_boxes, b)

    // ─── POC ──────────────────────────────────────────────────────────────────
    int   poc_level = 0
    float poc_max   = 0.0
    for i = 0 to price_levels - 1
        float total = array.get(bull_delta, i) + array.get(bear_delta, i)
        if total > poc_max
            poc_max   := total
            poc_level := i

    float poc_price = lo + poc_level * level_size + level_size * 0.5

    poc_line := line.new(
         x1    = bar_index - 50,
         y1    = poc_price,
         x2    = bar_index,
         y2    = poc_price,
         color = poc_col,
         width = 3,
         style = line.style_solid,
         xloc  = xloc.bar_index)

var cumVol = 0.
cumVol += nz(volume)
if barstate.islast and cumVol == 0
    runtime.error("The data vendor doesn't provide volume data for this symbol.")
````
