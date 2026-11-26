# IFVG NQ ES Clean Fixed

- url: https://www.tradingview.com/script/q36Zpkvj-IFVG-NQ-ES-Clean-Fixed/
- type: indicator
- pine_id: PUB;4a385dd71d934d22ae9c0d527c92622f
- version: 1.0

## Description

An ICT/SMC - based trading view indicator for NQ and ES that detects HTF Liquidity sweeps, Fair value gaps, and high- probability intraday entry setups with automated risk management

## Source Code

````pine
//@version=5
indicator("IFVG NQ ES Clean Fixed", overlay=true, max_boxes_count=100, max_lines_count=200, max_labels_count=100)

// SETTINGS
htf_tf = input.timeframe("15", "HTF Timeframe")
swing_lookback = input.int(15, "Swing Lookback", minval=5, maxval=50)
min_fvg_ticks = input.int(8, "Minimum FVG Size")
rr_ratio = input.float(2.5, "Reward Risk", step=0.5)
confirm_volume = input.bool(true, "Volume Confirmation")
atr_len = input.int(14, "ATR Length")
atr_mult = input.float(1.2, "ATR Multiplier")
use_session = input.bool(true, "Use NY Session")
ny_session = input.session("0830-1100", "NY Session")

// COLORS
bull_col = color.new(color.lime, 80)
bear_col = color.new(color.red, 80)

// SESSION FILTER
in_session = not na(time(timeframe.period, ny_session))

// HTF DATA
htf_high = request.security(syminfo.tickerid, htf_tf, high)
htf_low = request.security(syminfo.tickerid, htf_tf, low)
htf_close = request.security(syminfo.tickerid, htf_tf, close)

// SWEEP DETECTION
prior_high = ta.highest(htf_high[1], swing_lookback)
prior_low = ta.lowest(htf_low[1], swing_lookback)

bull_sweep = htf_low < prior_low and htf_close > prior_low
bear_sweep = htf_high > prior_high and htf_close < prior_high

var bool bullish_bias = false
var bool bearish_bias = false

if bull_sweep
    bullish_bias := true
    bearish_bias := false

if bear_sweep
    bearish_bias := true
    bullish_bias := false

// FVG DETECTION
bull_fvg = low > high[2]
bear_fvg = high < low[2]

bull_gap = (low - high[2]) / syminfo.mintick
bear_gap = (low[2] - high) / syminfo.mintick

show_bull_fvg = bull_fvg and bull_gap >= min_fvg_ticks and bullish_bias
show_bear_fvg = bear_fvg and bear_gap >= min_fvg_ticks and bearish_bias

// DRAW FVG BOXES
if show_bull_fvg
    box.new(bar_index - 2, low, bar_index + 20, high[2], bgcolor=bull_col, border_color=color.lime)

if show_bear_fvg
    box.new(bar_index - 2, low[2], bar_index + 20, high, bgcolor=bear_col, border_color=color.red)

// ATR
atr = ta.atr(atr_len)

// VOLUME FILTER
vol_ok = volume > ta.sma(volume, 20)

// ENTRY CONDITIONS
bull_entry = bullish_bias and close > open and low <= high[2]
bear_entry = bearish_bias and close < open and high >= low[2]

if confirm_volume
    bull_entry := bull_entry and vol_ok
    bear_entry := bear_entry and vol_ok

if use_session
    bull_entry := bull_entry and in_session
    bear_entry := bear_entry and in_session

// LONG LEVELS
long_entry = close
long_sl = long_entry - (atr * atr_mult)
long_tp = long_entry + ((long_entry - long_sl) * rr_ratio)

// SHORT LEVELS
short_entry = close
short_sl = short_entry + (atr * atr_mult)
short_tp = short_entry - ((short_sl - short_entry) * rr_ratio)

// ENTRY SIGNALS
plotshape(bull_entry, title="LONG", style=shape.labelup, location=location.belowbar, color=color.lime, text="LONG", textcolor=color.white)

plotshape(bear_entry, title="SHORT", style=shape.labeldown, location=location.abovebar, color=color.red, text="SHORT", textcolor=color.white)

// LONG LINES
if bull_entry
    line.new(bar_index, long_entry, bar_index + 20, long_entry, color=color.white)
    line.new(bar_index, long_sl, bar_index + 20, long_sl, color=color.red)
    line.new(bar_index, long_tp, bar_index + 20, long_tp, color=color.lime)

// SHORT LINES
if bear_entry
    line.new(bar_index, short_entry, bar_index + 20, short_entry, color=color.white)
    line.new(bar_index, short_sl, bar_index + 20, short_sl, color=color.red)
    line.new(bar_index, short_tp, bar_index + 20, short_tp, color=color.lime)

// ALERTS
alertcondition(bull_entry, title="LONG ALERT", message="Bullish IFVG Entry")

alertcondition(bear_entry, title="SHORT ALERT", message="Bearish IFVG Entry")
````
