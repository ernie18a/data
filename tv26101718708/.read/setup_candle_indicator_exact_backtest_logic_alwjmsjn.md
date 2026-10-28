# Setup Candle Indicator - Exact Backtest Logic

- url: https://www.tradingview.com/script/AlwJmSjn-Setup-Candle-Indicator-Exact-Backtest-Logic/
- type: indicator
- pine_id: PUB;ac454d72b4b046879560cd929b2cd572
- version: 1.0

## Description

sma7 slope condition added
shape conditions hardened

## Source Code

````pine
//@version=5
indicator("Setup Candle Indicator - Exact Backtest Logic", overlay=true)

// ═══════════════════════════════════════════════════════════════════════════
//  FILTER TOGGLES
// ═══════════════════════════════════════════════════════════════════════════
use_sma7    = input.bool(true,  title="Enable SMA-7 Filter")
use_sma25   = input.bool(false, title="Enable SMA-25 Filter")   // OFF by default (matches backtest)
use_ema99   = input.bool(true,  title="Enable EMA-99 Filter")   // ON by default
use_volume  = input.bool(true,  title="Enable Volume Filter")

// ═══════════════════════════════════════════════════════════════════════════
//  CANDLE SHAPE FILTERS
// ═══════════════════════════════════════════════════════════════════════════
body_ratio_max          = input.float(0.40, "Body Ratio Max",          minval=0, maxval=1, step=0.01)
dominant_wick_ratio_min = input.float(0.45, "Dominant Wick Ratio Min", minval=0, maxval=1, step=0.01)
opposite_wick_ratio_max = input.float(0.35, "Opposite Wick Ratio Max", minval=0, maxval=1, step=0.01)

// ═══════════════════════════════════════════════════════════════════════════
//  SMA-7 DISTANCE FILTER  (ATR-based — matches backtest exactly)
// ═══════════════════════════════════════════════════════════════════════════
sma7_max_distance_atr_mult = input.float(0.2, "SMA-7 Max Distance (× ATR14)",minval=0.05, maxval=2.0, step=0.05, tooltip="Max allowed distance from wick tip (low for long, high for short) to SMA7, as multiplier of ATR(14)")

// ═══════════════════════════════════════════════════════════════════════════
//  VOLUME FILTER
// ═══════════════════════════════════════════════════════════════════════════
volume_sma_period = input.int(7,   "Volume SMA Period",  minval=1)
volume_min_mult   = input.float(0.7, "Volume Min Multiplier", minval=0, maxval=5, step=0.05)
volume_max_mult   = input.float(1.3, "Volume Max Multiplier", minval=0, maxval=5, step=0.05)

// ═══════════════════════════════════════════════════════════════════════════
//  EMA-99 FILTER
// ═══════════════════════════════════════════════════════════════════════════
ema99_period   = input.int(99, "EMA Period",     minval=1)
ema99_slope_length = input.int(5, "EMA Slope Length", minval=1, tooltip="Number of periods for EMA slope check")

// ═══════════════════════════════════════════════════════════════════════════
//  PERIOD DEFINITIONS
// ═══════════════════════════════════════════════════════════════════════════
sma7_len  = 7
sma25_len = 25
atr_len   = 14

// ═══════════════════════════════════════════════════════════════════════════
//  CANDLE COMPONENTS
// ═══════════════════════════════════════════════════════════════════════════
r          = high - low
body       = math.abs(close - open)
upper_wick = high - math.max(open, close)
lower_wick = math.min(open, close) - low

// ═══════════════════════════════════════════════════════════════════════════
//  INDICATORS
// ═══════════════════════════════════════════════════════════════════════════
// SMA 7
sma7       = ta.sma(close, sma7_len)

// SMA 25 (was SMA 21 — now matches conditions.py SMA_PERIOD_21 = 25)
sma25      = ta.sma(close, sma25_len)
sma25_prev = ta.sma(close[1], sma25_len)
sma25_slope = sma25 - sma25_prev

// ATR(14) for SMA7 distance check
atr14 = ta.atr(atr_len)

// EMA 99 (includes current candle — matches Python backtest)
ema99      = ta.ema(close, ema99_period)
ema99_prev = ema99[ema99_slope_length]
ema99_slope = ema99 - ema99_prev

// Volume SMA
volume_sma_val = ta.sma(volume, volume_sma_period)

// ═══════════════════════════════════════════════════════════════════════════
//  CANDLE SHAPE CHECK
// ═══════════════════════════════════════════════════════════════════════════
body_ratio  = r > 0 ? body / r : 0
upper_ratio = r > 0 ? upper_wick / r : 0
lower_ratio = r > 0 ? lower_wick / r : 0

body_ok = body_ratio <= body_ratio_max

// Dominant wick must be the largest of the three
wick_body_long_ok  = lower_wick > body and lower_wick > upper_wick
wick_body_short_ok = upper_wick > body and upper_wick > lower_wick

long_shape  = body_ok and lower_ratio >= dominant_wick_ratio_min and upper_ratio <= opposite_wick_ratio_max and wick_body_long_ok
short_shape = body_ok and upper_ratio >= dominant_wick_ratio_min and lower_ratio <= opposite_wick_ratio_max and wick_body_short_ok

// ═══════════════════════════════════════════════════════════════════════════
//  SMA-7 FILTER  (ATR-based distance — matches backtest)
// ═══════════════════════════════════════════════════════════════════════════
body_bottom = math.min(open, close)
body_top    = math.max(open, close)

max_distance = sma7_max_distance_atr_mult * atr14

// SMA7 slope over last 3 candles (positive=rising, negative=falling)
sma7_2_bars_ago = sma7[2]
sma7_slope_3 = sma7 - sma7_2_bars_ago

// Long: body_bottom > sma7 AND SMA7 in wick shadow (or just below it)
sma7_long_ok = not use_sma7 or (body_bottom > sma7 and low - sma7 <= max_distance and sma7_slope_3 > 0)

// Short: body_top < sma7 AND SMA7 in wick shadow (or just above it) AND sma7 slope negative
sma7_short_ok = not use_sma7 or (body_top < sma7 and sma7 - high <= max_distance and sma7_slope_3 < 0)

// ═══════════════════════════════════════════════════════════════════════════
//  SMA-25 FILTER  (trend filter — matches backtest)
// ═══════════════════════════════════════════════════════════════════════════
// Long: sma25 slope > 0 AND body_bottom > sma25
sma25_long_ok = not use_sma25 or (sma25_slope > 0 and body_bottom > sma25)

// Short: sma25 slope < 0 AND body_top < sma25
sma25_short_ok = not use_sma25 or (sma25_slope < 0 and body_top < sma25)

// ═══════════════════════════════════════════════════════════════════════════
//  EMA-99 FILTER  (matches backtest is_ema_confirmed)
// ═══════════════════════════════════════════════════════════════════════════
// Long: body_bottom >= ema99 AND ema99 slope > 0
ema99_long_ok = not use_ema99 or (body_bottom >= ema99 and ema99_slope > 0)

// Short: body_top <= ema99 AND ema99 slope < 0
ema99_short_ok = not use_ema99 or (body_top <= ema99 and ema99_slope < 0)

// ═══════════════════════════════════════════════════════════════════════════
//  VOLUME FILTER  (matches backtest get_volume_status)
// ═══════════════════════════════════════════════════════════════════════════
// Volume must be ≥ volume_min_mult * volume_sma AND ≤ volume_max_mult * volume_sma
volume_ok = not use_volume or (volume >= volume_min_mult * volume_sma_val and volume <= volume_max_mult * volume_sma_val)

// ═══════════════════════════════════════════════════════════════════════════
//  FINAL SIGNALS
// ═══════════════════════════════════════════════════════════════════════════
long_setup  = long_shape  and sma7_long_ok  and sma25_long_ok  and ema99_long_ok  and volume_ok
short_setup = short_shape and sma7_short_ok and sma25_short_ok and ema99_short_ok and volume_ok

// ═══════════════════════════════════════════════════════════════════════════
//  PLOTTING
// ═══════════════════════════════════════════════════════════════════════════
plotshape(long_setup,  style=shape.triangleup,   location=location.belowbar, color=color.green, size=size.small, text="L")
plotshape(short_setup, style=shape.triangledown, location=location.abovebar, color=color.red,   size=size.small, text="S")

// SMAs
plot(use_sma7  ? sma7  : na, "SMA 7",  color=color.blue,   linewidth=1)
plot(use_sma25 ? sma25 : na, "SMA 25", color=color.orange, linewidth=1)

// EMA 99
plot(use_ema99 ? ema99 : na, "EMA 99", color=color.purple, linewidth=1)
````
