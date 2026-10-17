# Volume Profile Supertrend [HexaTrades]

- url: https://www.tradingview.com/script/hCSy1SXR-Volume-Profile-Supertrend-HexaTrades/
- type: indicator
- pine_id: PUB;895384c6c3cc428cbd8fb81b46d474a5
- version: 1.0

## Description

Volume Profile Supertrend re-imagines the classic Supertrend. Instead of trailing bands built from pure volatility (ATR), it builds them around the levels where real volume has traded the Point of Control and Value Area.

The philosophy is simple: a normal Supertrend follows volatility; this one follows where the market accepts value. Price tends to gravitate to, and trend away from, the zones where the most business gets done. By anchoring the trend engine to value migration, the indicator aims to stay on the right side of the move while filtering out a portion of low-quality volatility noise.

Everything is computed internally in Pine; no built-in Volume Profile tool is used, so it works on any symbol and timeframe that has volume.


[b]💡How it works[/b]


1. Rolling Volume Profile:
 It looks back over the last Profile Lookback bars, finds the high–low range, and divides it into Number of Rows price buckets. Every historical bar's volume is distributed across the buckets its range spans, producing a fresh volume distribution on every candle.

2. POC, VAH & VAL:
POC (Point of Control) : the price bucket with the highest traded volume (the "fairest price").
Value Area: the script expands outward from the POC until it captures the chosen Value Area % (default 70%) of total volume.
VAH / VAL: the upper and lower edges of that Value Area.

https://www.tradingview.com/x/OUYGKey6/

3. Smoothing & Supertrend bands:
POC, VAH, and VAL are smoothed with EMAs to remove jitter. Two trailing bands are then built, exactly like a Supertrend:

Lower band = smoothed VAL − (ATR × buffer) → support used while bullish.
Upper band = smoothed VAH + (ATR × buffer) → resistance used while bearish.
The bands only trail in the trend-following direction, so they lock in as the price advances.

4. Trend flip:
The trend is bullish while price holds above the lower band, and flips bearish when price closes below it (and vice-versa). The flip is evaluated against the previous bar's confirmed bands, so closed candles never change.


[b]💡How to read it[/b]

🔶Bullish:A green line sits below the price. The market is accepting a higher value; treat pullbacks toward the line as the trend "breathing." A flip to red is your warning.

🔶Bearish: A red line sits above the price. Value is migrating lower; rallies into the line are where sellers tend to re-engage. A flip to green signals a potential turn.

https://www.tradingview.com/x/njeKKJsB/

🔶Choppy Markets: When price is inside the value area and trend strength is low, the market may be sideways.
In these conditions, signals can be weaker. It may be better to wait for a clear value breakout or stronger trend strength.


[b]🔺Signals[/b]

- BUY label prints when the trend flips from bearish to bullish.
- SELL label prints when the trend flips from bullish to bearish.
- A flip dot marks the exact bar of the change on the trend line.
- Trend Strength Filter: Set Minimum Trend Strength above 0 to filter out weak trend flips and display only higher-conviction signals. (Available in the indicator settings.)
https://www.tradingview.com/x/gPZaIQ31/


[b]┼ Dashboard[/b]

-Trend: Current direction  Bullish or Bearish.
-Strength: 0–100% conviction score blending distance from POC, POC slope, and whether price has broken outside the Value Area.
-Price Position:	Above / Inside / Below Value Area.
-Last Signal: The most recent BUY or SELL that fired.

[b]Alerts[/b]

The indicator includes alerts for important events:
-Buy Signal / Sell Signal
-Bullish Trend / Bearish Trend (flip)
-Price Above Value Area / Price Below Value Area
-Price Crossing POC EMA

[b]Suggested Settings[/b]

For Intraday Trading
Use lower lookback and medium rows for faster signals.
Example:
-Profile Lookback: 50–100
-Rows: 30–50
-EMA Smoothing: 8–14
-ATR Buffer: 0.5–1.0

For Swing trading
Use higher lookback and smoother settings for cleaner signals.
Example:
-Profile Lookback: 100–250
-Rows: 40–70
-EMA Smoothing: 10–21
-ATR Buffer: 0.8–1.5

For Cleaner Signals
-Increase EMA Smoothing Length
-AIncrease TR Buffer
-Increase Minimum Trend Strength


Volume Profile Supertrend combines the proven structure of a Supertrend with the market's true area of value derived from a rolling Volume Profile. Instead of relying solely on price volatility, it follows the migration of value through the Point of Control (POC) and Value Area (VAH/VAL) to identify higher-quality trend changes.

Whether you're a day trader or swing trader, this indicator helps you visualize trend direction, identify dynamic support and resistance, filter weak reversals, and stay aligned with the prevailing market structure. Use it as a standalone trend-following tool or alongside your existing trading strategy for additional confirmation.


[i]We would love to hear your suggestions. If you have ideas for new features, indicators, analytics, or improvements, please share your feedback. Your input helps guide future updates and improve the indicator for all traders.
[/i]

[i]This indicator is for educational and analytical purposes only. It is not financial advice. Trading involves risk. Always use proper risk management and combine this indicator with your own analysis before taking any trade.[/i]

## Source Code

````pine
//@version=6
indicator("Volume Profile Supertrend [HexaTrades]", "HexaTrades Volume Profile Supertrend", overlay = true, max_labels_count = 500, max_bars_back = 500)

// =====================================================================================
//  INPUTS
// =====================================================================================

// ---- Profile Settings ---------------------------------------------------------------
string GRP_PROFILE = "Profile Settings"
int    lookback    = input.int(100, "Profile Lookback", minval = 10,  maxval = 500, group = GRP_PROFILE, tooltip = "Number of bars used to build the rolling volume profile.")
int    rows        = input.int(40,  "Number of Rows",   minval = 5,   maxval = 100, group = GRP_PROFILE, tooltip = "Price buckets the lookback range is divided into. More rows = finer profile (heavier).")
float  vaPercent   = input.float(70, "Value Area %",    minval = 30,  maxval = 95,  step = 1, group = GRP_PROFILE, tooltip = "Percent of total volume contained in the Value Area (VAH..VAL).")
float  volSrc      = input.source(volume, "Volume Source", group = GRP_PROFILE, tooltip = "Series used as the volume weight for each bar.")

// ---- Trend Settings -----------------------------------------------------------------
string GRP_TREND   = "Trend Settings"
int    smoothLen   = input.int(10, "EMA Smoothing Length", minval = 1, maxval = 200, group = GRP_TREND, tooltip = "EMA length applied to POC / VAH / VAL value levels.")
int    atrLen      = input.int(14, "ATR Length",           minval = 1, maxval = 200, group = GRP_TREND)
float  atrBuffer   = input.float(0.5, "ATR Buffer Multiplier", minval = 0.0, maxval = 5.0, step = 0.1, group = GRP_TREND, tooltip = "Extra volatility cushion added to the trailing value bands.")
string flipMode    = input.string("Close", "Flip Confirmation Mode", options = ["Close", "Wick"], group = GRP_TREND, tooltip = "Close: flip only on body close cross. Wick: flip when a wick crosses the band.")
float  minStrength = input.float(0, "Minimum Trend Strength", minval = 0, maxval = 100, step = 1, group = GRP_TREND, tooltip = "Suppress Buy/Sell signals weaker than this strength %.")

// ---- Visual Settings ----------------------------------------------------------------
string GRP_VISUAL  = "Visual Settings"
bool   showTrend   = input.bool(true,  "Show Trend Line",        group = GRP_VISUAL)
bool   showGlow    = input.bool(true,  "Glow Effect",            group = GRP_VISUAL, tooltip = "Layered neon-style glow under the trend line.")
bool   showFill    = input.bool(true,  "Gradient Fill",          group = GRP_VISUAL, tooltip = "Shade between price and the trend line; intense at the line, fading toward price.")
bool   colorBars   = input.bool(true,  "Color Candles by Trend", group = GRP_VISUAL)
bool   showFlips   = input.bool(true,  "Flip Dots",              group = GRP_VISUAL, tooltip = "Mark the bar where the trend flips.")
bool   showPOC     = input.bool(true,  "Show POC EMA",           group = GRP_VISUAL)
bool   showVAEMA   = input.bool(false, "Show VAH/VAL EMA",       group = GRP_VISUAL)
bool   showLabels  = input.bool(true,  "Show Buy/Sell Labels",   group = GRP_VISUAL)
bool   showDash    = input.bool(true,  "Show Dashboard",         group = GRP_VISUAL)
int    lineWidth   = input.int(3, "Line Width", minval = 1, maxval = 6, group = GRP_VISUAL)
int    glowStrength = input.int(3, "Glow Intensity", minval = 1, maxval = 5, group = GRP_VISUAL, tooltip = "Higher = wider, more prominent glow halo.")
color  bullColor   = input.color(#00E676, "Bullish Color", group = GRP_VISUAL)
color  bearColor   = input.color(#FF1744, "Bearish Color", group = GRP_VISUAL)
color  neutColor   = input.color(#B2B5BE, "Neutral Color", group = GRP_VISUAL)

// ---- Alert Settings -----------------------------------------------------------------
string GRP_ALERT   = "Alert Settings"
bool   enableAlerts = input.bool(true, "Enable Alerts", group = GRP_ALERT, tooltip = "Master switch for the dynamic alert() calls (alertconditions are always available).")

// =====================================================================================
//  SECTION 1 - ROLLING VOLUME PROFILE (computed internally, no built-in tools)
// =====================================================================================
//  For every bar we rebuild a profile across the last `lookback` bars:
//    * find the high/low range, split it into `rows` price buckets
//    * allocate each historical bar's volume across the buckets its range spans
//    * the fullest bucket is the POC; expand around it to reach the Value Area %
// =====================================================================================

// Persisted raw value levels (carried forward when a bar can't produce a valid profile).
var float poc = na
var float vah = na
var float val = na

// Range of the rolling window.
float ph        = ta.highest(high, lookback)
float pl        = ta.lowest(low,  lookback)
float rowHeight = (ph - pl) / rows

// Only (re)build the profile once we have enough history and a non-degenerate range.
if bar_index >= lookback and rowHeight > 0
    // Fresh volume buckets for this bar.
    array<float> vol = array.new_float(rows, 0.0)

    // --- Allocate volume: spread each bar's volume across the rows its H/L spans. ---
    for i = 0 to lookback - 1
        float hi = high[i]
        float lo = low[i]
        float vi = nz(volSrc[i])
        if not na(hi) and not na(lo)
            // Clamp BOTH edges to [0, rows-1]. Without capping botRow, a bar sitting at the
            // lookback high maps to row `rows`; the for-loop would then count DOWN
            // (botRow > topRow) and read an index == rows -> out of bounds.
            int topRow = math.min(math.max(int(math.floor((hi - pl) / rowHeight)), 0), rows - 1)
            int botRow = math.min(math.max(int(math.floor((lo - pl) / rowHeight)), 0), rows - 1)
            int span   = topRow - botRow + 1
            float vPer = vi / span
            for r = botRow to topRow
                array.set(vol, r, array.get(vol, r) + vPer)

    // --- POC = fullest bucket. ---
    int   pocIdx = 0
    float maxVol = 0.0
    for r = 0 to rows - 1
        float cv = array.get(vol, r)
        if cv > maxVol
            maxVol := cv
            pocIdx := r

    // --- Value Area: grow outward from the POC until VA% of volume is captured. ---
    float totalVol = array.sum(vol)
    float target   = totalVol * vaPercent / 100.0
    float accum    = maxVol
    int   upIdx    = pocIdx
    int   dnIdx    = pocIdx
    while accum < target and (upIdx < rows - 1 or dnIdx > 0)
        float volUp = upIdx < rows - 1 ? array.get(vol, upIdx + 1) : -1.0
        float volDn = dnIdx > 0        ? array.get(vol, dnIdx - 1) : -1.0
        if volUp >= volDn
            upIdx += 1
            accum += volUp
        else
            dnIdx -= 1
            accum += volDn

    // --- Translate bucket indices back into price levels. ---
    poc := pl + (pocIdx + 0.5) * rowHeight   // centre of the POC bucket
    vah := pl + (upIdx + 1)   * rowHeight    // top edge of the value area
    val := pl + dnIdx         * rowHeight    // bottom edge of the value area

// =====================================================================================
//  SECTION 2 - SMOOTHED VALUE LEVELS
// =====================================================================================
float pocEMA = ta.ema(poc, smoothLen)
float vahEMA = ta.ema(vah, smoothLen)
float valEMA = ta.ema(val, smoothLen)

float atr = ta.atr(atrLen)

// =====================================================================================
//  SECTION 3 - SUPERTREND-STYLE TREND LOGIC (driven by value migration)
// =====================================================================================
//  lowerBand -> support used while bullish  (smoothed VAL minus an ATR cushion)
//  upperBand -> resistance used while bearish (smoothed VAH plus an ATR cushion)
//  Bands trail like a classic Supertrend; trend flips on a confirmed cross.
// =====================================================================================
float lowerBand = valEMA - atr * atrBuffer
float upperBand = vahEMA + atr * atrBuffer

// Trail the bands so they only move in the trend-following direction.
lowerBand := close[1] > nz(lowerBand[1], lowerBand) ? math.max(lowerBand, nz(lowerBand[1], lowerBand)) : lowerBand
upperBand := close[1] < nz(upperBand[1], upperBand) ? math.min(upperBand, nz(upperBand[1], upperBand)) : upperBand

// Price used for the flip test (body vs wick).
float bullTest = flipMode == "Wick" ? high : close   // breaking resistance -> bull
float bearTest = flipMode == "Wick" ? low  : close   // breaking support    -> bear

// Trend state: +1 bullish, -1 bearish. Evaluated on confirmed band values ([1]) -> no
// repaint after the candle closes.
var int trend = 1
trend := na(trend[1]) ? 1 :
         trend[1] == -1 and bullTest > nz(upperBand[1], upperBand) ?  1 :
         trend[1] ==  1 and bearTest < nz(lowerBand[1], lowerBand) ? -1 :
         trend[1]

bool isBull = trend == 1
bool isBear = trend == -1

// The single active Supertrend line.
float trendLine = isBull ? lowerBand : upperBand
color trendCol  = isBull ? bullColor : bearColor

// ==========================================================================
//  SECTION 4 - TREND STRENGTH (0..100)
// =====================================================================================
//  Blends: ATR-normalised distance from POC EMA, POC EMA slope, and whether price has
//  broken outside the value area (strong acceptance of new value).
// =====================================================================================
float atrFallback = ta.sma(math.abs(close - close[1]), 14)            // hoisted: ta.* must run every bar
float safeAtr   = atr > 0 ? atr : atrFallback
float distNorm  = na(pocEMA) or safeAtr == 0 ? 0.0 : math.abs(close - pocEMA) / safeAtr
float slopeNorm = na(pocEMA) or safeAtr == 0 ? 0.0 : math.abs(pocEMA - nz(pocEMA[smoothLen], pocEMA)) / safeAtr

float distScore  = math.min(distNorm,  3.0) / 3.0 * 40.0   // up to 40
float slopeScore = math.min(slopeNorm, 2.0) / 2.0 * 30.0   // up to 30
float posScore   = (close > vahEMA or close < valEMA) ? 30.0 : (close > valEMA and close < vahEMA ? 10.0 : 20.0)

float trendStrength = math.min(100.0, distScore + slopeScore + posScore)

// ====================================================
//  SECTION 5 - SIGNALS
// ====================================================
bool flipBull = isBull and trend[1] == -1
bool flipBear = isBear and trend[1] == 1

bool buySignal  = flipBull and trendStrength >= minStrength
bool sellSignal = flipBear and trendStrength >= minStrength

// Remember the last fired signal for the dashboard.
var string lastSignal = "-"
if buySignal
    lastSignal := "BUY"
else if sellSignal
    lastSignal := "SELL"

// ====================================================================
//  SECTION 6 - PLOTS (high-contrast green/red design)
// ====================================================================
// Split the active line per direction so the glow/fill never bridge across a flip.
float bullLine = showTrend and isBull ? trendLine : na
float bearLine = showTrend and isBear ? trendLine : na

// --- Glow halo: 3 widening, fading passes drawn UNDER the crisp core line. ---
int   gW = glowStrength
plot(showGlow ? bullLine : na, "Bull Glow 3", color = color.new(bullColor, 92), linewidth = lineWidth + gW * 4, style = plot.style_linebr)
plot(showGlow ? bullLine : na, "Bull Glow 2", color = color.new(bullColor, 84), linewidth = lineWidth + gW * 2, style = plot.style_linebr)
plot(showGlow ? bullLine : na, "Bull Glow 1", color = color.new(bullColor, 70), linewidth = lineWidth + gW,     style = plot.style_linebr)
plot(showGlow ? bearLine : na, "Bear Glow 3", color = color.new(bearColor, 92), linewidth = lineWidth + gW * 4, style = plot.style_linebr)
plot(showGlow ? bearLine : na, "Bear Glow 2", color = color.new(bearColor, 84), linewidth = lineWidth + gW * 2, style = plot.style_linebr)
plot(showGlow ? bearLine : na, "Bear Glow 1", color = color.new(bearColor, 70), linewidth = lineWidth + gW,     style = plot.style_linebr)

// --- Crisp core trend line on top. ---
plot(bullLine, "Bull Trend", color = bullColor, linewidth = lineWidth, style = plot.style_linebr)
plot(bearLine, "Bear Trend", color = bearColor, linewidth = lineWidth, style = plot.style_linebr)

// --- Gradient fill between price and the line (intense at the line, fading to price). ---
float bandHi = math.max(close, trendLine)
float bandLo = math.min(close, trendLine)
pHi = plot(showTrend and showFill ? bandHi : na, "fillHi", display = display.none)
pLo = plot(showTrend and showFill ? bandLo : na, "fillLo", display = display.none)
// In a bull trend the line is the lower bound -> intense at the bottom; bear is the mirror.
fill(pHi, pLo, top_value = bandHi, bottom_value = bandLo, top_color = color.new(trendCol, isBull ? 92 : 55), bottom_color = color.new(trendCol, isBull ? 55 : 92))

// --- Flip dots: bold marker on the bar the trend changes. ---
plotshape(showFlips and flipBull ? trendLine : na, "Bull Flip", style = shape.circle, location = location.absolute, color = bullColor, size = size.tiny)
plotshape(showFlips and flipBear ? trendLine : na, "Bear Flip", style = shape.circle, location = location.absolute, color = bearColor, size = size.tiny)

// --- Candle coloring for maximum contrast with the trend. ---
barcolor(colorBars ? trendCol : na, title = "Trend Candles")

// --- Smoothed value levels. ---
plot(showPOC   ? pocEMA : na, "POC EMA", color = color.new(neutColor, 0),  linewidth = 1)
plot(showVAEMA ? vahEMA : na, "VAH EMA", color = color.new(bearColor, 35), linewidth = 1, style = plot.style_circles)
plot(showVAEMA ? valEMA : na, "VAL EMA", color = color.new(bullColor, 35), linewidth = 1, style = plot.style_circles)

// --- Buy / Sell labels (compact, optional, high-contrast). ---
if showLabels and buySignal
    label.new(bar_index, low, "BUY", style = label.style_label_up, color = bullColor, textcolor = color.white, size = size.small, yloc = yloc.belowbar)
if showLabels and sellSignal
    label.new(bar_index, high, "SELL", style = label.style_label_down, color = bearColor, textcolor = color.white, size = size.small, yloc = yloc.abovebar)

// =====================================================================================
//  SECTION 7 - DASHBOARD
// =====================================================================================
string pricePos = close > vahEMA ? "Above Value" : close < valEMA ? "Below Value" : "Inside Value"

var table dash = table.new(position.top_right, 2, 5, border_width = 1, frame_color = color.new(neutColor, 50), frame_width = 1)

if showDash and barstate.islast
    color hdrBg   = isBull ? bullColor : bearColor
    color rowBg   = color.new(#1e222d, 0)
    color txtCol  = color.new(color.white, 0)

    // Header
    table.cell(dash, 0, 0, "VP Supertrend", text_color = color.white, text_size = size.normal, bgcolor = hdrBg)
    table.cell(dash, 1, 0, "", text_color = color.white, text_size = size.normal, bgcolor = hdrBg)

    // Trend
    table.cell(dash, 0, 1, "Trend", text_color = txtCol, bgcolor = rowBg, text_size = size.small)
    table.cell(dash, 1, 1, isBull ? "Bullish" : "Bearish", text_color = isBull ? bullColor : bearColor, bgcolor = rowBg, text_size = size.small)

    // Trend strength
    table.cell(dash, 0, 2, "Strength", text_color = txtCol, bgcolor = rowBg, text_size = size.small)
    table.cell(dash, 1, 2, str.tostring(trendStrength, "#.0") + " %", text_color = trendStrength >= 60 ? bullColor : trendStrength >= 30 ? color.orange : neutColor, bgcolor = rowBg, text_size = size.small)

    // Price position
    table.cell(dash, 0, 3, "Price Position", text_color = txtCol, bgcolor = rowBg, text_size = size.small)
    table.cell(dash, 1, 3, pricePos, text_color = pricePos == "Above Value" ? bullColor : pricePos == "Below Value" ? bearColor : neutColor, bgcolor = rowBg, text_size = size.small)

    // Last signal
    table.cell(dash, 0, 4, "Last Signal", text_color = txtCol, bgcolor = rowBg, text_size = size.small)
    table.cell(dash, 1, 4, lastSignal, text_color = lastSignal == "BUY" ? bullColor : lastSignal == "SELL" ? bearColor : neutColor, bgcolor = rowBg, text_size = size.small)

// =====================================================================================
//  SECTION 8 - ALERTS
// =====================================================================================
bool aboveVA   = close > vahEMA
bool belowVA   = close < valEMA
bool crossPOC  = ta.cross(close, pocEMA)

// Static alertconditions (always selectable in the TradingView alert dialog).
alertcondition(buySignal,  "Buy Signal",            "VP Supertrend: BUY signal")
alertcondition(sellSignal, "Sell Signal",           "VP Supertrend: SELL signal")
alertcondition(flipBull,   "Bullish Trend",         "VP Supertrend: Trend turned BULLISH")
alertcondition(flipBear,   "Bearish Trend",         "VP Supertrend: Trend turned BEARISH")
alertcondition(aboveVA,    "Price Above Value Area","VP Supertrend: Price ABOVE Value Area")
alertcondition(belowVA,    "Price Below Value Area","VP Supertrend: Price BELOW Value Area")
alertcondition(crossPOC,   "Price Crossing POC EMA","VP Supertrend: Price crossing POC EMA")

// Dynamic alerts (fire automatically when alerts are enabled; confirmed bars only).
if enableAlerts and barstate.isconfirmed
    if buySignal
        alert("VP Supertrend [HexaTrades]: BUY @ " + str.tostring(close, format.mintick) + " | Strength " + str.tostring(trendStrength, "#.0") + "%", alert.freq_once_per_bar_close)
    if sellSignal
        alert("VP Supertrend [HexaTrades]: SELL @ " + str.tostring(close, format.mintick) + " | Strength " + str.tostring(trendStrength, "#.0") + "%", alert.freq_once_per_bar_close)
````
