# Setup Candle Indicator - TCP

- url: https://www.tradingview.com/script/G4ek71c9-Setup-Candle-Indicator-TCP/
- type: indicator
- pine_id: PUB;96bc0d2eac7d4f97add652d1c58489b4
- version: 14.0

## Description

a tradingview indicator inspired by Trade City Pro Setup Candle

## Source Code

````pine
//@version=6
indicator("Setup Candle Indicator - TCP + ZigZag Wave Filter", overlay = true, max_lines_count = 500, max_labels_count = 500)

// ═══════════════════════════════════════════════════════════════════════════
//  SETUP CANDLE FILTER TOGGLES  (unchanged logic from the original script)
// ═══════════════════════════════════════════════════════════════════════════
use_sma7    = input.bool(true,  title = "Enable SMA-7 Filter", group = "Setup Candle")
use_sma25   = input.bool(false, title = "Enable SMA-25 Filter", group = "Setup Candle")
use_sma99   = input.bool(false,  title = "Enable SMA-99 Filter", group = "Setup Candle")

sma7_max_distance_atr_mult = input.float(0.4, "SMA-7 Max Distance (× ATR14)", minval = 0.05, maxval = 2.0, step = 0.05, group = "Setup Candle", tooltip = "Max allowed distance from wick tip (low for long, high for short) to SMA7, as multiplier of ATR(14)")

candle_shape_ratio = input.float(1.6, title = "Ratio of the setup candle parts", minval = 1.0, step = 0.05, group = "Setup Candle")
max_body_ratio      = input.float(0.55, title = "Max ratio of body", maxval = 1.0, step = 0.05, group = "Setup Candle")

show_unfiltered = input.bool(false, "Also show setup candles without wave filter (faded)", group = "Setup Candle")

sma7_len     = 7
sma25_len    = 25
sma99_period = 99
atr_len      = 14

r          = high - low
body       = math.abs(close - open)
upper_wick = high - math.max(open, close)
lower_wick = math.min(open, close) - low

sma7        = ta.sma(close, sma7_len)
sma25       = ta.sma(close, sma25_len)
sma25_prev  = ta.sma(close[1], sma25_len)
sma25_slope = sma25 - sma25_prev
atr14       = ta.atr(atr_len)
sma99       = ta.sma(close, sma99_period)

buyer_pressure  = close - low
seller_pressure = high - close
buyer_try       = high - open
seller_try      = open - low
body_pct        = math.abs(open - close) / (high - low)

wick_body_long_ok  = buyer_pressure > candle_shape_ratio * seller_pressure  and seller_try > candle_shape_ratio * seller_pressure
wick_body_short_ok = seller_pressure > candle_shape_ratio * buyer_pressure and buyer_try > candle_shape_ratio * buyer_pressure
long_shape  = wick_body_long_ok and body_pct < max_body_ratio
short_shape = wick_body_short_ok and body_pct < max_body_ratio

body_bottom  = math.min(open, close)
body_top     = math.max(open, close)
max_distance = sma7_max_distance_atr_mult * atr14

sma7_2_bars_ago = sma7[2]
sma7_slope_3    = sma7 - sma7_2_bars_ago

sma7_long_ok  = not use_sma7 or (body_bottom > sma7 and low - sma7 <= max_distance)
sma7_short_ok = not use_sma7 or (body_top < sma7 and sma7 - high <= max_distance)

sma25_long_ok  = not use_sma25 or (body_bottom > sma25)
sma25_short_ok = not use_sma25 or (body_top < sma25)

sma99_long_ok  = not use_sma99 or (body_bottom >= sma99)
sma99_short_ok = not use_sma99 or (body_top <= sma99)

long_setup  = long_shape  and sma7_long_ok  and sma25_long_ok  and sma99_long_ok
short_setup = short_shape and sma7_short_ok and sma25_short_ok and sma99_short_ok

// ═══════════════════════════════════════════════════════════════════════════
//  ZIGZAG (ATR-based) — detects the wave-1 / correction / wave-3 structure
// ═══════════════════════════════════════════════════════════════════════════
zz_coef        = input.float(2.2, "ZigZag ATR multiplier (coef)", minval = 0.01, step = 0.1, group = "ZigZag / Wave Filter")
zz_atr_len     = input.int(7, "ZigZag ATR length", minval = 1, group = "ZigZag / Wave Filter")
max_retrace    = input.float(0.7, "Max correction retrace (fraction of wave 1)", minval = 0.05, maxval = 0.95, step = 0.05, group = "ZigZag / Wave Filter")
show_zigzag    = input.bool(false, "Draw ZigZag lines", group = "ZigZag / Wave Filter")
show_pivots    = input.bool(false, "Draw pivot markers", group = "ZigZag / Wave Filter")
highlight_wave = input.bool(false, "Highlight active wave-3 zone", group = "ZigZag / Wave Filter")
zz_line_color  = input.color(#2962FF, "ZigZag line color", group = "ZigZag / Wave Filter")

zz_atr       = ta.atr(zz_atr_len)
zz_threshold = zz_coef * zz_atr

var float zzLastPivotPrice = na
var int   zzLastPivotBar   = na
var int   zzDir            = 0     // 0 = undetermined, 1 = tracking up, -1 = tracking down
var float zzExtremePrice   = na
var int   zzExtremeBar     = na

var array<int>   pivTypes  = array.new_int()    // 1 = high pivot, -1 = low pivot
var array<float> pivPrices = array.new_float()
var array<int>   pivBars   = array.new_int()

var bool  longWaveActive  = false
var float longWaveFloor   = na     // L2 price — invalidation level for the long wave-3 zone
var bool  shortWaveActive = false
var float shortWaveCeil   = na     // H2 price — invalidation level for the short wave-3 zone

bool  newPivotConfirmed = false
int   newPivotType      = 0
float newPivotPrice     = na
int   newPivotBar       = na
float prevAnchorPrice   = na
int   prevAnchorBar     = na

if bar_index == 0
    zzLastPivotPrice := close
    zzLastPivotBar   := bar_index
    zzExtremePrice   := high
    zzExtremeBar     := bar_index

if zzDir == 0
    if high - zzLastPivotPrice > zz_threshold
        zzDir          := 1
        zzExtremePrice := high
        zzExtremeBar   := bar_index
    else if zzLastPivotPrice - low > zz_threshold
        zzDir          := -1
        zzExtremePrice := low
        zzExtremeBar   := bar_index

else if zzDir == 1
    if high > zzExtremePrice
        zzExtremePrice := high
        zzExtremeBar   := bar_index
    if zzExtremePrice - low > zz_threshold
        // confirm a HIGH pivot
        prevAnchorPrice   := zzLastPivotPrice
        prevAnchorBar     := zzLastPivotBar
        newPivotConfirmed := true
        newPivotType      := 1
        newPivotPrice     := zzExtremePrice
        newPivotBar       := zzExtremeBar
        zzLastPivotPrice  := zzExtremePrice
        zzLastPivotBar    := zzExtremeBar
        zzDir             := -1
        zzExtremePrice    := low
        zzExtremeBar      := bar_index

else if zzDir == -1
    if low < zzExtremePrice
        zzExtremePrice := low
        zzExtremeBar   := bar_index
    if high - zzExtremePrice > zz_threshold
        // confirm a LOW pivot
        prevAnchorPrice   := zzLastPivotPrice
        prevAnchorBar     := zzLastPivotBar
        newPivotConfirmed := true
        newPivotType      := -1
        newPivotPrice     := zzExtremePrice
        newPivotBar       := zzExtremeBar
        zzLastPivotPrice  := zzExtremePrice
        zzLastPivotBar    := zzExtremeBar
        zzDir             := 1
        zzExtremePrice    := high
        zzExtremeBar      := bar_index

// ── on a newly confirmed pivot: draw it, store it, and check the wave pattern
if newPivotConfirmed
    if show_zigzag
        line.new(prevAnchorBar, prevAnchorPrice, newPivotBar, newPivotPrice, color = zz_line_color, width = 2)
    if show_pivots
        label.new(newPivotBar, newPivotPrice, newPivotType == 1 ? "H" : "L",
             style = newPivotType == 1 ? label.style_label_down : label.style_label_up,
             color = color.new(zz_line_color, 85), textcolor = zz_line_color, size = size.tiny)

    array.push(pivTypes, newPivotType)
    array.push(pivPrices, newPivotPrice)
    array.push(pivBars, newPivotBar)
    if array.size(pivTypes) > 10
        array.shift(pivTypes)
        array.shift(pivPrices)
        array.shift(pivBars)

    int n = array.size(pivTypes)

    // Wave "done" once a fresh pivot confirms on the opposite side → stop scanning
    if newPivotType == 1 and longWaveActive
        longWaveActive := false
    if newPivotType == -1 and shortWaveActive
        shortWaveActive := false

    // Long wave-3 setup: L1(low) → H1(high) → L2(low), L2 higher than L1, retrace < max
    if newPivotType == -1 and n >= 3
        int t0 = array.get(pivTypes, n - 3)
        int t1 = array.get(pivTypes, n - 2)
        int t2 = array.get(pivTypes, n - 1)
        if t0 == -1 and t1 == 1 and t2 == -1
            float L1 = array.get(pivPrices, n - 3)
            float H1 = array.get(pivPrices, n - 2)
            float L2 = array.get(pivPrices, n - 1)
            if L2 > L1 and (H1 - L1) > 0
                float retrace = (H1 - L2) / (H1 - L1)
                if retrace < max_retrace
                    longWaveActive := true
                    longWaveFloor  := L2

    // Short wave-3 setup: H1(high) → L1(low) → H2(high), H2 lower than H1, retrace < max
    if newPivotType == 1 and n >= 3
        int t0b = array.get(pivTypes, n - 3)
        int t1b = array.get(pivTypes, n - 2)
        int t2b = array.get(pivTypes, n - 1)
        if t0b == 1 and t1b == -1 and t2b == 1
            float H1b = array.get(pivPrices, n - 3)
            float L1b = array.get(pivPrices, n - 2)
            float H2b = array.get(pivPrices, n - 1)
            if H2b < H1b and (H1b - L1b) > 0
                float retraceS = (H2b - L1b) / (H1b - L1b)
                if retraceS < max_retrace
                    shortWaveActive := true
                    shortWaveCeil   := H2b

// ── invalidate the active wave intrabar if price breaks back through the L2 / H2 level
if longWaveActive and low < longWaveFloor
    longWaveActive := false
if shortWaveActive and high > shortWaveCeil
    shortWaveActive := false

// ═══════════════════════════════════════════════════════════════════════════
//  FINAL SIGNALS — setup candle AND confirmed wave-3 context
// ═══════════════════════════════════════════════════════════════════════════
long_setup_wave  = long_setup  and longWaveActive
short_setup_wave = short_setup and shortWaveActive

waveBgColor = not highlight_wave ? na : longWaveActive ? color.new(color.green, 92) : shortWaveActive ? color.new(color.red, 92) : na
bgcolor(waveBgColor)

plotshape(long_setup_wave,  style = shape.triangleup,   location = location.belowbar, color = color.lime,    size = size.small, text = "L")
plotshape(short_setup_wave, style = shape.triangledown, location = location.abovebar, color = color.fuchsia, size = size.small, text = "S")

plotshape(show_unfiltered and long_setup  and not longWaveActive,  style = shape.triangleup,   location = location.belowbar, color = color.new(color.green, 70), size = size.tiny)
plotshape(show_unfiltered and short_setup and not shortWaveActive, style = shape.triangledown, location = location.abovebar, color = color.new(color.red, 70),   size = size.tiny)

plot(use_sma7  ? sma7  : na, "SMA 7",  color = color.blue,   linewidth = 1)
plot(use_sma25 ? sma25 : na, "SMA 25", color = color.orange, linewidth = 1)
plot(use_sma99 ? sma99 : na, "EMA 99", color = color.purple, linewidth = 1)
````
