# Island EMA/VWAP Cross

- url: https://www.tradingview.com/script/XoT46w0V-Island-EMA-VWAP-Cross/
- type: indicator
- pine_id: PUB;6be39c2649dc4516a3016d06eddd273f
- version: 2.0

## Description

The indicator is designed to help traders identify potential buy and sell signals based on the interactions between a 7-period Exponential Moving Average (EMA) and the Volume Weighted Average Price (VWAP). Additionally, it provides market volatility information through the Average True Range (ATR) and the Relative Volume (RVOL).

Exponential Moving Average (EMA)
Purpose: Smooths price data to identify the trend direction.
Calculation: The EMA reacts more significantly to recent price changes compared to a simple moving average.
Input: You can set its length (default is 7 periods).

Volume Weighted Average Price (VWAP)
Purpose: Provides the average price a security has traded at throughout the day, based on both price and volume.
Significance: It often serves as a key level for potential support or resistance.

## Source Code

````pine
//@version=6
indicator(title="7 EMA / VWAP Cross Signal [A+]", overlay=true, max_labels_count=500)

//──────────────────────────────────────────────────────
// INPUTS
//──────────────────────────────────────────────────────

// Core
ema_length   = input.int(7,    title="EMA Length",        minval=1)
show_ema     = input.bool(true,title="Show 1m EMA")
show_vwap    = input.bool(true,title="Show 1m VWAP")
show_signals = input.bool(true,title="Show Signal Labels")

// Price Action Confirmation
use_pa             = input.bool(true,   title="Enable PA Confirmation")
min_body_pct       = input.float(0.3,   title="Min Candle Body (x ATR)", step=0.05)
min_close_pos_bull = input.float(0.6,   title="Bull: Min Close Position (0-1)", minval=0.0, maxval=1.0, step=0.05)
max_close_pos_bear = input.float(0.4,   title="Bear: Max Close Position (0-1)", minval=0.0, maxval=1.0, step=0.05)

// ATR (used for PA and label placement)
atr_length  = input.int(14, title="ATR Period",  minval=1)

//──────────────────────────────────────────────────────
// CORE 1m CALCULATIONS
//──────────────────────────────────────────────────────
ema7    = ta.ema(close, ema_length)
vwap_   = ta.vwap(hlc3)
atr_val = ta.atr(atr_length)

// Candle properties
body      = math.abs(close - open)
range_    = high - low
close_pos = range_ > 0 ? (close - low) / range_ : 0.5

//──────────────────────────────────────────────────────
// PRICE ACTION CONFIRMATION
//──────────────────────────────────────────────────────
min_body   = atr_val * min_body_pct
bull_pa_ok = body >= min_body and close_pos >= min_close_pos_bull
bear_pa_ok = body >= min_body and close_pos <= max_close_pos_bear

//──────────────────────────────────────────────────────
// SIGNAL CONSTRUCTION (no HTF filter)
//──────────────────────────────────────────────────────
raw_bull = ta.crossover(ema7, vwap_)
raw_bear = ta.crossunder(ema7, vwap_)

pa_bull_ok = not use_pa or bull_pa_ok
pa_bear_ok = not use_pa or bear_pa_ok

bull_cross = raw_bull and pa_bull_ok
bear_cross = raw_bear and pa_bear_ok

//──────────────────────────────────────────────────────
// SIGNAL STATE (persists until opposite)
//──────────────────────────────────────────────────────
var int signal_state = 0
if bull_cross
    signal_state := 1
else if bear_cross
    signal_state := -1

is_bullish = signal_state == 1
is_bearish = signal_state == -1

//──────────────────────────────────────────────────────
// PLOTS
//──────────────────────────────────────────────────────
plot(show_ema  ? ema7  : na, title="1m 7 EMA", color=color.new(color.orange, 0), linewidth=2)
plot(show_vwap ? vwap_ : na, title="1m VWAP",  color=color.new(color.aqua,   0), linewidth=2)

//──────────────────────────────────────────────────────
// SIGNAL LABELS
//──────────────────────────────────────────────────────
var label buy_label  = na
var label sell_label = na

if show_signals
    if bull_cross
        if not na(buy_label)
            label.delete(buy_label)
        buy_label := label.new(bar_index, low - atr_val, "BUY", style=label.style_label_up, color=color.new(color.green, 0), textcolor=color.white, size=size.normal)
    if bear_cross
        if not na(sell_label)
            label.delete(sell_label)
        sell_label := label.new(bar_index, high + atr_val, "SELL", style=label.style_label_down, color=color.new(color.red, 0), textcolor=color.white, size=size.normal)

//──────────────────────────────────────────────────────
// ALERTS
//──────────────────────────────────────────────────────
alertcondition(bull_cross, title="BUY Signal",  message="[7EMA/VWAP] BUY signal on {{ticker}} {{interval}}")
alertcondition(bear_cross, title="SELL Signal", message="[7EMA/VWAP] SELL signal on {{ticker}} {{interval}}")
````
