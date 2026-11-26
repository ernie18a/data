# Normalized Candles RSI [Jamallo]

- url: https://www.tradingview.com/script/0CpayaVA-Normalized-Candles-RSI-Jamallo/
- type: indicator
- pine_id: PUB;840a5c35d60245719625ea252c90bb1b
- version: 2.0

## Description

🔹 Intro

The Normalized Candles RSI is a quantitative momentum and volatility indicator designed to transform raw, trending price action into a stationary 0-100 oscillator. By passing price data through a Fractional Differencing engine and a dynamic Z-Score normalization layer, it strips away market drift and presents pure, bounded candlestick momentum. This stationary price structure is then directly overlaid with a traditional RSI and Divergence engine for highly confluent signals.

🔹 Break down

[list]
[*][b]Fractional Differencing (FFD):[/b] Transforms non-stationary price data into a stationary series while retaining deep historical memory (controlled by the "d" parameter). This prevents the data loss associated with standard period-to-period differencing.

[*][b]Normalization Engine:[/b] Applies a rolling Z-Score to the differenced data, which is then passed through a Sigmoid compression function. This mathematically forces the resulting candlesticks into a strict 0-100 range without repainting.

[*][b]RSI & Divergence Engine: [/b] Overlays a classic RSI with optional smoothing moving averages and Bollinger Bands. Built-in regular bullish and bearish divergence detection algorithms automatically scan for momentum exhaustion relative to the price.
[/list]

🔹 Visual Guide: Indicator Anatomy

The true power of this indicator lies in its visual mapping. As shown in the snapshot, the indicator pane perfectly merges the structure of raw price action directly with a classic RSI oscillator.

[list]
[*][b]1:1 Structural Mapping:[/b] Notice how the normalized candles in the middle pane mirror the raw price action in the main chart exactly (highlighted by the "1:1 with overlay candle sticks" annotation). You get the exact same highs, lows, and structural candlestick patterns, but stripped of drift and mathematically squashed into a stationary box.

[*][b]Normalized Candles + Standard RSI:[/b] If you look at a standard RSI (bottom pane), you only see a floating line. By overlaying the normalized candles (middle pane), you can see exactly how the physical candlestick bodies and wicks behave relative to the RSI's 0-100 bounds and its smoothing moving average (the yellow line).

[*][b]Actionable Context:[/b] When a localized top or bottom forms, you aren't just guessing based on a purple line peaking. You can see the actual candlestick structure exhausting itself, forming wicks and reversal patterns right against the upper (70+) or lower (30-) overextended boundaries.
[/list]

[image]https://www.tradingview.com/x/Mv0mEBsp/[/image]

🔹 Settings Parameters

- [b]Diff Order (d) (0.01 - 0.99):[/b] The fractional differencing order. Higher values make the series more stationary but remove more historical memory.

- [b]Z-Score Lookback:[/b] The rolling window used to calculate the mean and standard deviation for the 0-100 normalization engine.

- [b]Sigmoid Compression Scale:[/b] Controls the elasticity of the 0-100 bounds. A higher value results in softer compression at the extremes, while a lower value makes it compress faster.

- [b]RSI Settings & Smoothing:[/b] Standard parameters for the RSI length, smoothing moving averages (SMA, EMA, VWMA, etc.), Bollinger Bands, and the divergence lookback constraints.

🔹 Credits & Acknowledgements
[i]The core RSI and Divergence engine utilized in this script is adapted from TradingView's built-in Relative Strength Index indicator code.[/i]

## Source Code

````pine
//@version=6
indicator(title="Normalized Candles RSI", overlay=false, max_bars_back=500)

// =============================================================================
// INPUTS
// =============================================================================
group_fd      = "Fractional Differencing"
fd_enabled    = input.bool(true,   "Enable Fractal Differencing",  group=group_fd, tooltip="Toggles the fractional differencing engine on or off.")
fd_d          = input.float(0.3,  "Diff Order (d)",               group=group_fd, minval=0.01, maxval=0.99, step=0.01, tooltip="The fractional differencing order. A higher value makes the series more stationary but removes more historical memory.")
fd_thresh     = input.float(0.01,   "Weight Threshold",            group=group_fd, minval=0.001, maxval=0.1, step=0.001, tooltip="Weight threshold to stop calculating historical lags. A smaller value increases the lookback memory.")
fd_maxwin     = input.int(30,      "Max Window",                   group=group_fd, minval=10, maxval=100, tooltip="Maximum number of bars to process for fractional differencing.")

group_norm    = "Normalization"
z_len         = input.int(100, "Z-Score Lookback", group=group_norm, minval=2, tooltip="The rolling lookback window used to calculate the mean and standard deviation for the Z-Score normalization.")
zClip         = input.float(4.0, "Sigmoid Compression Scale",  group=group_norm, minval=1.0, maxval=6.0, step=0.5, tooltip="Controls the elasticity of the 0-100 bounds. Lower = faster compression at the edges. Higher = softer compression.")

group_color   = "Colors"
bullColor     = input.color(color.teal,   "Bullish Candle Color",  group=group_color)
bearColor     = input.color(color.maroon, "Bearish Candle Color",  group=group_color)

// RSI Settings (Original RSI code credited to TradingView's built-in indicator)
rsiLengthInput = input.int(14, minval=1, title="RSI Length", group="RSI Settings")
rsiSourceInput = input.source(close, "Source", group="RSI Settings")
calculateDivergence = input.bool(false, title="Calculate Divergence", group="RSI Settings", display = display.none, tooltip = "Calculating divergences is needed in order for divergence alerts to fire.")

// Smoothing MA inputs
GRP = "Smoothing"
TT_BB = "Only applies when 'SMA + Bollinger Bands' is selected. Determines the distance between the SMA and the bands."
maTypeInput = input.string("SMA", "Type", options = ["None", "SMA", "SMA + Bollinger Bands", "EMA", "SMMA (RMA)", "WMA", "VWMA"], group = GRP, display = display.none)
isBB = maTypeInput == "SMA + Bollinger Bands"
maLengthInput = input.int(14, "Length", group = GRP, display = display.none)
bbMultInput = input.float(2.0, "BB StdDev", minval = 0.001, maxval = 50, step = 0.5, tooltip = TT_BB, group = GRP, display = display.none)
enableMA = maTypeInput != "None"

// =============================================================================
// FRACTIONAL DIFFERENCING ENGINE
// =============================================================================
f_fd_build_weights(float d, float thresh, int maxL) =>
    float[] _w = array.new_float(0)
    array.push(_w, 1.0)
    for k = 1 to maxL - 1
        float w_prev = array.get(_w, k - 1)
        float w_k    = -w_prev * (d - float(k) + 1.0) / float(k)
        if math.abs(w_k) < thresh
            break
        array.push(_w, w_k)
    _w

f_frac_diff(float[] _w, series float src) =>
    float val = 0.0
    int   L   = array.size(_w)
    bool  rdy = bar_index >= L - 1
    if rdy
        for k = 0 to L - 1
            val += array.get(_w, k) * nz(src[k], src)
    else
        val := src
    val

var float[] fd_w = f_fd_build_weights(fd_d, fd_thresh, fd_maxwin)
int   fd_warmup  = array.size(fd_w)

// Apply fractional differencing to Close
float fd_close_raw = f_frac_diff(fd_w, close)

// Keep relative candlestick structure relative to the differenced Close
float raw_ho = high  - close
float raw_lo = close - low
float raw_oc = close - open

float fd_close_val = fd_enabled and bar_index >= fd_warmup ? fd_close_raw : close
float fd_open_val  = fd_enabled and bar_index >= fd_warmup ? fd_close_raw - raw_oc  : open
float fd_high_val  = fd_enabled and bar_index >= fd_warmup ? fd_close_raw + raw_ho  : high
float fd_low_val   = fd_enabled and bar_index >= fd_warmup ? fd_close_raw - raw_lo  : low

// =============================================================================
// NORMALIZATION (Z-SCORE + SIGMOID)
// =============================================================================
float fd_mean = ta.sma(fd_close_val, z_len)
float fd_std  = ta.stdev(fd_close_val, z_len)
float fd_safe = math.max(fd_std, 0.0001)

f_normalize(float val) =>
    float z_score = (val - fd_mean) / fd_safe
    float scaled_z = z_score / (zClip / 2.0)
    100.0 / (1.0 + math.exp(-scaled_z))

float norm_close = f_normalize(fd_close_val)
float norm_open  = f_normalize(fd_open_val)
float norm_high  = f_normalize(fd_high_val)
float norm_low   = f_normalize(fd_low_val)

// =============================================================================
// PLOTTING
// =============================================================================
// Dynamic Candle Coloring
color candleColor = norm_close >= norm_open ? bullColor : bearColor

// Plot the normalized candles
plotcandle(norm_open, norm_high, norm_low, norm_close, title="FFD Normalized Candles", color=candleColor, wickcolor=candleColor, bordercolor=candleColor)

// =============================================================================
// RSI, BANDS, AND DIVERGENCE
// =============================================================================
change = ta.change(rsiSourceInput)
up = ta.rma(math.max(change, 0), rsiLengthInput)
down = ta.rma(-math.min(change, 0), rsiLengthInput)
rsi = down == 0 ? 100 : up == 0 ? 0 : 100 - (100 / (1 + up / down))

rsiPlot = plot(rsi, "RSI", color=#7E57C2)
rsiUpperBand = hline(70, "RSI Upper Band", color=#787B86, linestyle=hline.style_dashed)
midline = hline(50, "RSI Middle Band", color=color.new(#787B86, 50), linestyle=hline.style_dotted)
rsiLowerBand = hline(30, "RSI Lower Band", color=#787B86, linestyle=hline.style_dashed)
fill(rsiUpperBand, rsiLowerBand, color=color.rgb(126, 87, 194, 90), title="RSI Background Fill")
midLinePlot = plot(50, color = na, editable = false, display = display.none)
fill(rsiPlot, midLinePlot, 100, 70, top_color = color.new(color.green, 0), bottom_color = color.new(color.green, 100),  title = "Overbought Gradient Fill")
fill(rsiPlot, midLinePlot, 30,  0,  top_color = color.new(color.red, 100), bottom_color = color.new(color.red, 0),      title = "Oversold Gradient Fill")

// Smoothing MA Calculation
ma(source, length, MAtype) =>
    switch MAtype
        "SMA"                   => ta.sma(source, length)
        "SMA + Bollinger Bands" => ta.sma(source, length)
        "EMA"                   => ta.ema(source, length)
        "SMMA (RMA)"            => ta.rma(source, length)
        "WMA"                   => ta.wma(source, length)
        "VWMA"                  => ta.vwma(source, length)

// Smoothing MA plots
smoothingMA = enableMA ? ma(rsi, maLengthInput, maTypeInput) : na
smoothingStDev = isBB ? ta.stdev(rsi, maLengthInput) * bbMultInput : na
plot(smoothingMA, "RSI-based MA", color=color.yellow, display = enableMA ? display.all : display.none, editable = true)
bbUpperBand = plot(smoothingMA + smoothingStDev, title = "Upper Bollinger Band", color=color.green, display = isBB ? display.all : display.none, editable = true)
bbLowerBand = plot(smoothingMA - smoothingStDev, title = "Lower Bollinger Band", color=color.green, display = isBB ? display.all : display.none, editable = true)
fill(bbUpperBand, bbLowerBand, color= isBB ? color.new(color.green, 90) : na, title="Bollinger Bands Background Fill", display = isBB ? display.all : display.none, editable = true)

// Divergence
lookbackRight = 5
lookbackLeft = 5
rangeUpper = 60
rangeLower = 5
bearColor_div = color.red
bullColor_div = color.green
textColor = color.white
noneColor = color.new(color.white, 100)

_inRange(bool cond) =>
    bars = ta.barssince(cond)
    rangeLower <= bars and bars <= rangeUpper

plFound = false
phFound = false
bullCond = false
bearCond = false

rsiLBR = rsi[lookbackRight]

bool inRangePl = _inRange(plFound[1])
bool inRangePh = _inRange(phFound[1])

if calculateDivergence
    // Regular Bullish
    plFound := not na(ta.pivotlow(rsi, lookbackLeft, lookbackRight))    
    rsiHL = rsiLBR > ta.valuewhen(plFound, rsiLBR, 1) and inRangePl
    lowLBR = low[lookbackRight]
    priceLL = lowLBR < ta.valuewhen(plFound, lowLBR, 1)
    bullCond := priceLL and rsiHL and plFound

    // Regular Bearish
    phFound := not na(ta.pivothigh(rsi, lookbackLeft, lookbackRight))
    rsiLH = rsiLBR < ta.valuewhen(phFound, rsiLBR, 1) and inRangePh
    highLBR = high[lookbackRight]
    priceHH = highLBR > ta.valuewhen(phFound, highLBR, 1)
    bearCond := priceHH and rsiLH and phFound

plot(plFound ? rsiLBR : na, offset = -lookbackRight, title = "Regular Bullish", linewidth = 2, color = (bullCond ? bullColor_div : noneColor), display = display.pane)
plotshape(bullCond ? rsiLBR : na, offset = -lookbackRight, title = "Regular Bullish Label", text = " Bull ", style = shape.labelup, location = location.absolute, color = bullColor_div, textcolor = textColor, display = display.pane)

plot(phFound ? rsiLBR : na, offset = -lookbackRight, title = "Regular Bearish", linewidth = 2, color = (bearCond ? bearColor_div : noneColor), display = display.pane)
plotshape(bearCond ? rsiLBR : na, offset = -lookbackRight, title = "Regular Bearish Label", text = " Bear ", style = shape.labeldown, location = location.absolute, color = bearColor_div, textcolor = textColor, display = display.pane)

alertcondition(bullCond, title='Regular Bullish Divergence', message="Found a new Regular Bullish Divergence, `Pivot Lookback Right` number of bars to the left of the current bar.")
alertcondition(bearCond, title='Regular Bearish Divergence', message='Found a new Regular Bearish Divergence, `Pivot Lookback Right` number of bars to the left of the current bar.')

alertcondition(ta.crossover(norm_close, 50),  title="Norm Close Cross Above 50", message="FFD Normalized Close crossed above 50 — bullish regime shift.")
alertcondition(ta.crossunder(norm_close, 50), title="Norm Close Cross Below 50", message="FFD Normalized Close crossed below 50 — bearish regime shift.")
alertcondition(ta.crossover(norm_close, 70),  title="Norm Close Cross Above 70", message="FFD Normalized Close crossed above 70 — overbought.")
alertcondition(ta.crossunder(norm_close, 30), title="Norm Close Cross Below 30", message="FFD Normalized Close crossed below 30 — oversold.")
````
