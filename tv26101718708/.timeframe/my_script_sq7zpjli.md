# My script

- url: https://www.tradingview.com/script/sq7zPjli-My-script/
- type: indicator
- pine_id: PUB;7e74b720996e42c088be2654f8e1d537
- version: 1.0

## Description

my plan for trading and testing the XAUUSD its for trial porpuse only

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © khurram_workflow

//@version=6
indicator("My script")
plot(close)
/// Liquidity Settings
liq_lookback     = input.int(20,  "Swing High/Low Lookback",     group="Liquidity Sweeps")
liq_sweep_pct    = input.float(0.1, "Sweep Wick Tolerance (%)", group="Liquidity Sweeps", step=0.05)

// FVG Settings
fvg_min_size     = input.float(0.5,  "Min FVG Size (points)",    group="Fair Value Gap")
fvg_bull_col     = input.color(color.new(color.green, 80), "Bullish FVG Color", group="Fair Value Gap")
fvg_bear_col     = input.color(color.new(color.red,   80), "Bearish FVG Color", group="Fair Value Gap")
fvg_max_boxes    = input.int(10, "Max FVG Boxes to Show",        group="Fair Value Gap")

// Wick Settings
wick_ratio       = input.float(0.6, "Min Wick Ratio (wick/candle)", group="Wick Pattern", step=0.05)

// Volume Settings
vol_ma_length    = input.int(20,  "Volume MA Length",            group="Volume")
vol_mult         = input.float(1.5, "Volume Spike Multiplier",   group="Volume", step=0.1)

// Risk Settings
sl_buffer_pct    = input.float(0.1, "SL Buffer beyond sweep (%)", group="Risk Management", step=0.05)
tp1_rr           = input.float(1.5, "TP1 Risk:Reward",           group="Risk Management", step=0.1)
tp2_rr           = input.float(3.0, "TP2 Risk:Reward",           group="Risk Management", step=0.1)

// Multi-Timeframe
htf              = input.timeframe("240", "Higher Timeframe Bias", group="Multi-Timeframe")

// Display
show_liq_lines   = input.bool(true,  "Show Liquidity Lines",     group="Display")
show_fvg         = input.bool(true,  "Show FVG Boxes",           group="Display")
show_signals     = input.bool(true,  "Show Entry Signals",       group="Display")
show_sl_tp       = input.bool(true,  "Show SL/TP Levels",        group="Display")

// ══════════════════════════════════════════════
//  VOLUME ANALYSIS
// ══════════════════════════════════════════════
vol_ma       = ta.sma(volume, vol_ma_length)
vol_spike    = volume > vol_ma * vol_mult

// ══════════════════════════════════════════════
//  SWING HIGH / LOW (LIQUIDITY ZONES)
// ══════════════════════════════════════════════
swing_high   = ta.highest(high, liq_lookback)[1]
swing_low    = ta.lowest(low,   liq_lookback)[1]

// Draw liquidity lines
var line liq_high_line = na
var line liq_low_line  = na

if show_liq_lines and barstate.islast
    if not na(liq_high_line)
        line.delete(liq_high_line)
    if not na(liq_low_line)
        line.delete(liq_low_line)
    liq_high_line := line.new(bar_index - liq_lookback, swing_high, bar_index, swing_high,
         color=color.new(color.orange, 20), style=line.style_dashed, width=1)
    liq_low_line  := line.new(bar_index - liq_lookback, swing_low,  bar_index, swing_low,
         color=color.new(color.orange, 20), style=line.style_dashed, width=1)

// ══════════════════════════════════════════════
//  LIQUIDITY SWEEP DETECTION
// ══════════════════════════════════════════════
tolerance_high = swing_high * (liq_sweep_pct / 100)
tolerance_low  = swing_low  * (liq_sweep_pct / 100)

// Sweep of highs (potential short setup): wick above swing high but closes below it
sweep_highs = high > (swing_high - tolerance_high) and close < swing_high and low < open

// Sweep of lows (potential long setup): wick below swing low but closes above it
sweep_lows  = low  < (swing_low  + tolerance_low)  and close > swing_low  and high > open

// Volume-confirmed sweeps
sweep_up   = sweep_lows  and vol_spike   // price swept lows -> potential long
sweep_down = sweep_highs and vol_spike   // price swept highs -> potential short

// ══════════════════════════════════════════════
//  FAIR VALUE GAP (FVG) DETECTION
// ══════════════════════════════════════════════
// Bullish FVG: gap between candle[2] high and candle[0] low (candle[1] is the impulse)
bull_fvg_top    = high[2]
bull_fvg_bot    = low[0]
bull_fvg_valid  = low[0] > high[2] and (low[0] - high[2]) >= fvg_min_size

// Bearish FVG: gap between candle[2] low and candle[0] high
bear_fvg_top    = low[2]
bear_fvg_bot    = high[0]
bear_fvg_valid  = low[2] > high[0] and (low[2] - high[0]) >= fvg_min_size

// Draw FVG boxes
var box[] bull_fvg_boxes = array.new_box()
var box[] bear_fvg_boxes = array.new_box()

if show_fvg and bull_fvg_valid
    if array.size(bull_fvg_boxes) >= fvg_max_boxes
        box.delete(array.shift(bull_fvg_boxes))
    array.push(bull_fvg_boxes, box.new(bar_index - 2, bull_fvg_top, bar_index, bull_fvg_bot,
         border_color=color.green, bgcolor=fvg_bull_col, border_width=1, extend=extend.right))

if show_fvg and bear_fvg_valid
    if array.size(bear_fvg_boxes) >= fvg_max_boxes
        box.delete(array.shift(bear_fvg_boxes))
    array.push(bear_fvg_boxes, box.new(bar_index - 2, bear_fvg_top, bar_index, bear_fvg_bot,
         border_color=color.red, bgcolor=fvg_bear_col, border_width=1, extend=extend.right))

// ══════════════════════════════════════════════
//  WICK PATTERN DETECTION
// ══════════════════════════════════════════════
candle_range    = high - low
body_size       = math.abs(close - open)
upper_wick      = high - math.max(close, open)
lower_wick      = math.min(close, open) - low

// Bullish rejection wick: long lower wick, small body (does not require bullish close)
bull_wick = (lower_wick / candle_range >= wick_ratio) and close > open

// Bearish rejection wick: long upper wick, small body (does not require bearish close)
bear_wick = (upper_wick / candle_range >= wick_ratio) and close < open

// ══════════════════════════════════════════════
//  MULTI-TIMEFRAME BIAS
// ══════════════════════════════════════════════
htf_close  = request.security(syminfo.tickerid, htf, close)
htf_open   = request.security(syminfo.tickerid, htf, open)
htf_high   = request.security(syminfo.tickerid, htf, high)
htf_low    = request.security(syminfo.tickerid, htf, low)
htf_ema50  = request.security(syminfo.tickerid, htf, ta.ema(close, 50))
htf_ema200 = request.security(syminfo.tickerid, htf, ta.ema(close, 200))

htf_bull_bias = htf_close > htf_ema50 and htf_ema50 > htf_ema200
htf_bear_bias = htf_close < htf_ema50 and htf_ema50 < htf_ema200

// ══════════════════════════════════════════════
//  ENTRY SIGNALS
// ══════════════════════════════════════════════

// LONG SIGNAL:
// HTF bullish bias + sweep of lows + bullish FVG formed + bullish wick + volume spike
long_signal  = htf_bull_bias and sweep_up[1] and bull_fvg_valid and bull_wick and vol_spike

// SHORT SIGNAL:
// HTF bearish bias + sweep of highs + bearish FVG formed + bearish wick + volume spike
short_signal = htf_bear_bias and sweep_down[1] and bear_fvg_valid and bear_wick and vol_spike

// ══════════════════════════════════════════════
//  SL / TP CALCULATION
// ══════════════════════════════════════════════
entry_price = open
sl_buffer = entry_price * (sl_buffer_pct / 100)
long_sl   = sweep_up  ? (swing_low  - sl_buffer) : na
short_sl  = sweep_down ? (swing_high + sl_buffer) : na

// NOW declare the boolean checks (after SL variables exist)
has_long_sl  = not na(long_sl)
has_short_sl = not na(short_sl)

long_tp1 = has_long_sl ? (entry_price + (entry_price - long_sl) * tp1_rr) : na
long_tp2 = has_long_sl ? (entry_price + (entry_price - long_sl) * tp2_rr) : na

short_tp1 = has_short_sl ? (entry_price - (short_sl - entry_price) * tp1_rr) : na
short_tp2 = has_short_sl ? (entry_price - (short_sl - entry_price) * tp2_rr) : na

// ══════════════════════════════════════════════
//  PLOTTING SIGNALS
// ══════════════════════════════════════════════
if show_signals
    if long_signal
        label.new(bar_index, low - sl_buffer * 2,
             "LONG\nFVG+Sweep+Wick+Vol",
             color=color.green, textcolor=color.white,
             style=label.style_label_up, size=size.small)

    if short_signal
        label.new(bar_index, high + sl_buffer * 2,
             "SHORT\nFVG+Sweep+Wick+Vol",
             color=color.red, textcolor=color.white,
             style=label.style_label_down, size=size.small)

// SL/TP lines on signal bars - extend to right edge
if show_sl_tp and long_signal
    line.new(bar_index, long_sl,  bar_index, long_sl,  color=color.red,    width=1, style=line.style_dotted, extend=extend.right)
    line.new(bar_index, long_tp1, bar_index, long_tp1, color=color.green,  width=1, style=line.style_dotted, extend=extend.right)
    line.new(bar_index, long_tp2, bar_index, long_tp2, color=color.teal,   width=1, style=line.style_dotted, extend=extend.right)

if show_sl_tp and short_signal
    line.new(bar_index, short_sl,  bar_index, short_sl,  color=color.red,   width=1, style=line.style_dotted, extend=extend.right)
    line.new(bar_index, short_tp1, bar_index, short_tp1, color=color.green, width=1, style=line.style_dotted, extend=extend.right)
    line.new(bar_index, short_tp2, bar_index, short_tp2, color=color.teal,  width=1, style=line.style_dotted, extend=extend.right)

// ══════════════════════════════════════════════
//  VOLUME BAR COLORING
// ══════════════════════════════════════════════
barcolor(vol_spike and close > open ? color.new(color.green, 40) :
         vol_spike and close < open ? color.new(color.red,   40) : na)

// ══════════════════════════════════════════════
//  INFO TABLE
// ══════════════════════════════════════════════
var table info = table.new(position.top_right, 2, 6,
     border_color=color.gray, border_width=1,
     bgcolor=color.new(color.black, 80))

if barstate.islast
    table.cell(info, 0, 0, "HTF Bias",    text_color=color.white, text_size=size.small)
    table.cell(info, 1, 0, htf_bull_bias ? "BULL" : htf_bear_bias ? "BEAR" : "NEUTRAL",
         text_color=htf_bull_bias ? color.green : htf_bear_bias ? color.red : color.gray, text_size=size.small)

    table.cell(info, 0, 1, "Vol Spike",   text_color=color.white, text_size=size.small)
    table.cell(info, 1, 1, vol_spike ? "YES" : "NO",
         text_color=vol_spike ? color.green : color.red, text_size=size.small)

    table.cell(info, 0, 2, "Liq Sweep",   text_color=color.white, text_size=size.small)
    table.cell(info, 1, 2, sweep_up ? "Bull" : sweep_down ? "Bear" : "-",
         text_color=sweep_up ? color.green : sweep_down ? color.red : color.gray, text_size=size.small)

    table.cell(info, 0, 3, "Bull FVG",    text_color=color.white, text_size=size.small)
    table.cell(info, 1, 3, bull_fvg_valid ? "Active" : "-",
         text_color=bull_fvg_valid ? color.green : color.gray, text_size=size.small)

    table.cell(info, 0, 4, "Bear FVG",    text_color=color.white, text_size=size.small)
    table.cell(info, 1, 4, bear_fvg_valid ? "Active" : "-",
         text_color=bear_fvg_valid ? color.red : color.gray, text_size=size.small)

    table.cell(info, 0, 5, "Wick Signal", text_color=color.white, text_size=size.small)
    table.cell(info, 1, 5, bull_wick ? "Bull" : bear_wick ? "Bear" : "-",
         text_color=bull_wick ? color.green : bear_wick ? color.red : color.gray, text_size=size.small)

// ══════════════════════════════════════════════
//  ALERTS
// ══════════════════════════════════════════════
alertcondition(long_signal,  "XAUUSD LONG Signal",  "GOLD LONG: FVG + Liquidity Sweep + Wick + Volume confirmed")
alertcondition(short_signal, "XAUUSD SHORT Signal", "GOLD SHORT: FVG + Liquidity Sweep + Wick + Volume confirmed")
alertcondition(sweep_up,     "Bullish Sweep Detected", "XAUUSD: Bullish liquidity sweep detected")
alertcondition(sweep_down,   "Bearish Sweep Detected", "XAUUSD: Bearish liquidity sweep detected")
````
