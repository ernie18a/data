# Advanced Breakout System v2.0

- url: https://www.tradingview.com/script/gG8XPeRl-Advanced-Breakout-System-v2-0/
- type: strategy
- pine_id: PUB;6198f89ad2714ef3bd2395280017cdfc
- version: 4.0

## Description

[b]Advanced Breakout System v2.0[/b]
[b]Developed by:[/b] Mohammed Bedaiwi

This script hunts for high-probability breakouts by combining price consolidation zones, volume spikes vs. average volume, smart money flow (OBV), and a Momentum Override for explosive moves that skip consolidation. Additionally, it automatically identifies and plots Support and Resistance levels with price labels to help you visualize market structure.

The system follows a "Watch & Confirm" logic: it first prints a WATCH setup, then a BUY only if price confirms strength.

[b]💡 JUSTIFICATION OF CONCEPTS (MASHUP & ORIGINALITY)[/b]

This script is an original mashup combining several analytical concepts to address common breakout failures:
[list=1]
[*]Volatility Compression Engine: Uses built-in functions like ta.highest() and ta.lowest() to mathematically define the setup phase where price volatility is compressed below a user-defined threshold.

[*]Volume Spike Confirmation: The breakout must be confirmed by a volume increase greater than a moving average of volume, signaling strong market interest.

[*]Smart Volume Filter (OBV): This is the key component. By checking if ta.obv is above its own Moving Average, we confirm that accumulation has been occurring during the consolidation period, suggesting institutional positioning before the price break.

[*]Multi-Exit Risk System: Employs dynamic exits (EMA cross, volume dump, bearish pattern) instead of static stop-losses to manage risk adaptively based on real-time market action.

[*]Market Structure Visualization: The script also includes a Support & Resistance engine to plot key swing pivots and price labels for visual context.
[/list]
[b]✅ STRATEGY RESULTS & POLICY COMPLIANCE[/b]

To ensure non-misleading and transparent backtesting results, this strategy is published with the following fully compliant properties:
[list]
[*]Dataset Compliance: The backtest is performed on the CMTL Daily (1D) chart across a long history, generating 201 total trades. This significantly exceeds the minimum requirement of 100 trades, providing a robust test dataset.

[*]Risk Control: The strategy uses a conservative order size set to 2% of equity (default_qty_value=2), strictly adhering to the sustainable risk recommendation of 5-10% of equity per trade.

[*]Transaction Costs: Realistic trading conditions are modeled using 0.07% commission and 3 ticks slippage to prevent the overestimation of profitability.
[/list]
[b]⚙️ VISUAL GUIDE & SIGNAL LOGIC[/b]

Key Color Legend (Visual Guide):
[list]
[*]WATCH – Setup (Yellow Arrow Down): Potential breakout setup detected.

[*]BUY – Confirmation (Green Arrow Up): Confirmed breakout, triggered when price trades above the high of the WATCH candle.

[*]SELL – Break (Orange Arrow): Short-term trend weakness, triggered when price closes below the Fast EMA (9).

[*]SELL – Dump (Dark Red Arrow): Distribution / volume dump, triggered by a bearish candle with abnormally high volume.

[*]SELL – Pattern (Purple Arrow): Bearish price-action pattern (such as a bearish engulfing).

[*]Support & Resistance Lines (Red/Green): Small horizontal lines plotted at key swing points with exact price labels.
[/list]
[b]⌨️ INPUTS (DEFAULT SETTINGS)[/b]
[list]
[*]Entry settings: Consolidation Lookback (default 20) = bars used to detect consolidation. Consolidation Range % (default 12%) = max allowed range size. Volume Spike Multiplier (default 1.2) = factor above average volume to count as a spike. Force Signal on Big Moves (default ON) = forces a WATCH signal on high-momentum moves.

[*]Exit settings: Enable Fast Exit (EMA 9) toggles the SELL – Break signal. Dump Volume Multiplier defines what counts as “dump” volume.

[*]Support & Resistance: Adjustable Pivot Left/Right bars control the sensitivity of the support and resistance lines.
[/list]
[b]⚠️ Disclaimer [/b]Trading involves significant risk of loss. This script is for educational and informational purposes only and is not financial advice or a recommendation to buy or sell any asset. BUY and SELL signals are rule-based and derived from historical behavior and do not guarantee future performance. Always use your own analysis and risk management. This is an open-source strategy; users are encouraged to test it across different symbols and timeframes.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © mbedaiwi2

//@version=6
strategy("Advanced Breakout System v2.2", overlay=true, initial_capital=10000, 
     default_qty_type=strategy.percent_of_equity, 
     default_qty_value=2, currency=currency.USD, 
     commission_type=strategy.commission.percent, 
     commission_value=0.07,      slippage=3 )
     
// -------------------------------------------------------------------------
// 1. Settings (Inputs)
// -------------------------------------------------------------------------
group_entry = "Entry Settings"
lookback_input      = input.int(20, "Consolidation Lookback (Bars)", minval=5, group=group_entry)
range_percent_input = input.float(12.0, "Consolidation Range %", minval=1.0, step=0.5, group=group_entry)

// --- Optional separate settings for the Daily chart (now user-controlled) ---
group_daily = "Daily Chart Override (Optional)"
use_daily_override  = input.bool(false, "Use separate settings on Daily chart", tooltip="When off, the Entry Settings above apply on all timeframes including Daily.", group=group_daily)
daily_lookback_input = input.int(5, "Daily Lookback (Bars)", minval=2, group=group_daily)
daily_range_input    = input.float(50.0, "Daily Range %", minval=1.0, step=0.5, group=group_daily)

apply_daily     = use_daily_override and timeframe.isdaily
lookback_period = apply_daily ? daily_lookback_input : lookback_input
range_percent   = (apply_daily ? daily_range_input : range_percent_input) / 100

vol_multiplier  = input.float(1.2, "Volume Spike Multiplier", minval=1.0, step=0.1, group=group_entry)
use_obv_filter  = input.bool(true, "Enable Smart Volume Filter (OBV)", group=group_entry)
ignore_cons_on_big_move = input.bool(true, "Force Signal on Big Moves (>5%)", tooltip="Triggers an immediate WATCH signal for strong moves, bypassing all filters", group=group_entry)

group_exit = "Exit Settings (Warnings)"
use_fast_exit    = input.bool(true, "Enable Trend Exit", group=group_exit)
trend_exit_mode  = input.string("SMA 20", "Trend Exit Line", options=["EMA 9", "SMA 20"], tooltip="EMA 9 exits quickly; SMA 20 gives the trade more room.", group=group_exit)
use_initial_sl   = input.bool(false, "Enable Initial Stop-Loss (Consolidation Low)", tooltip="Places a stop at the low of the consolidation zone recorded at the breakout.", group=group_exit)
use_vol_exit     = input.bool(true, "Enable Volume Dump Exit", group=group_exit)
vol_exit_mult    = input.float(2.0, "Dump Volume Multiplier", group=group_exit)
use_pattern_exit = input.bool(true, "Enable Bearish Engulfing Exit", group=group_exit)

// --- GROUP: Backtest Range ---
group_bt   = "Backtest Range"
start_date = input.time(timestamp("2010-01-01T00:00:00"), "Backtest Start Date", tooltip="Trades are only taken from this date onward. Very old split-adjusted prices (fractions of a cent) make fixed tick slippage unrealistically large.", group=group_bt)
in_range   = time >= start_date

// --- GROUP: Support & Resistance ---
group_sr = "Support & Resistance Points"
sr_left_bars  = input.int(15, "Pivot Left Bars", minval=2, tooltip="Minimum bars to the left to confirm a point", group=group_sr)
sr_right_bars = input.int(5, "Pivot Right Bars", minval=1, tooltip="Minimum bars to the right to confirm a point (lag)", group=group_sr)

// -------------------------------------------------------------------------
// 2. Indicators & Calculations
// -------------------------------------------------------------------------
highest_high = ta.highest(high, lookback_period)[1]
lowest_low   = ta.lowest(low, lookback_period)[1]

avg_volume = ta.sma(volume, 20)
ema_fast   = ta.ema(close, 9)
sma_slow   = ta.sma(close, 20)

obv_value = ta.obv
obv_ma    = ta.sma(obv_value, lookback_period)
is_obv_strong = (obv_value > obv_ma)

// --- Pivot Calculation ---
pivot_high = ta.pivothigh(high, sr_left_bars, sr_right_bars)
pivot_low  = ta.pivotlow(low, sr_left_bars, sr_right_bars)

// -------------------------------------------------------------------------
// 3. Logic & Strategy
// -------------------------------------------------------------------------
is_consolidating = ((highest_high - lowest_low) / close[1]) < range_percent
is_big_move = (close > open * 1.05)
breakout_core = close > highest_high and volume > (avg_volume * vol_multiplier)

normal_trigger = breakout_core and is_consolidating[1]
final_normal_trigger = use_obv_filter ? (normal_trigger and is_obv_strong) : normal_trigger
momentum_trigger = breakout_core and is_big_move and ignore_cons_on_big_move
breakout_condition = final_normal_trigger or momentum_trigger

var bool pending_confirmation = false
var float breakout_high_price = 0.0
var float setup_stop_price    = na
var float active_stop_price   = na

if breakout_condition
    pending_confirmation := true
    breakout_high_price := high
    setup_stop_price := lowest_low

if pending_confirmation and close < lowest_low
    pending_confirmation := false

valid_entry = pending_confirmation and high > breakout_high_price and bar_index > 0 and not breakout_condition

if valid_entry
    pending_confirmation := false

// -------------------------------------------------------------------------
// 4. Exits Logic
// -------------------------------------------------------------------------
trend_line = trend_exit_mode == "SMA 20" ? sma_slow : ema_fast
trend_cross = ta.crossunder(close, trend_line)
exit_trend = use_fast_exit and trend_cross
exit_vol = use_vol_exit and close < open and volume > (avg_volume * vol_exit_mult)
is_engulfing = close < open and close[1] > open[1] and close < low[1] and open > high[1]
exit_pattern = use_pattern_exit and is_engulfing
any_exit_signal = exit_trend or exit_vol or exit_pattern

// -------------------------------------------------------------------------
// 5. Strategy Execution
// -------------------------------------------------------------------------
if valid_entry and in_range
    strategy.entry("Long Position", strategy.long, stop=breakout_high_price)
    if strategy.position_size == 0
        active_stop_price := setup_stop_price

// Cancel an unfilled entry stop order after one bar so it cannot fill later at a stale price
if strategy.position_size == 0 and not valid_entry
    strategy.cancel("Long Position")

if use_initial_sl and strategy.position_size > 0 and not na(active_stop_price)
    strategy.exit("Initial SL", from_entry="Long Position", stop=active_stop_price, comment="Stop-Loss")

if strategy.position_size > 0 and any_exit_signal
    strategy.close("Long Position", comment="Exit Signal")

// -------------------------------------------------------------------------
// 6. Alerts
// -------------------------------------------------------------------------
if breakout_condition
    alert("🟡 WATCH SETUP: " + syminfo.ticker + " - Breakout Detected. Prepare for entry.", alert.freq_once_per_bar_close)

if valid_entry
    alert("🟢 BUY SIGNAL: " + syminfo.ticker + " - Price Confirmed above Breakout Level.", alert.freq_once_per_bar_close)

if any_exit_signal
    string exit_reason = ""
    if exit_trend
        exit_reason := "Trend Broken (" + trend_exit_mode + ")"
    else if exit_vol
        exit_reason := "Volume Dump (Distribution)"
    else if exit_pattern
        exit_reason := "Bearish Pattern (Engulfing)"
    alert("🔴 SELL SIGNAL: " + syminfo.ticker + " - Reason: " + exit_reason, alert.freq_once_per_bar_close)

// -------------------------------------------------------------------------
// 7. Visualization
// -------------------------------------------------------------------------
// --- Auto Theme Palette: detects chart background brightness ---
// Light background -> darker shades of the same colors; dark background -> original colors.
bg_col   = chart.bg_color
is_light = (color.r(bg_col) * 0.299 + color.g(bg_col) * 0.587 + color.b(bg_col) * 0.114) > 128

c_blue   = is_light ? #0D47A1 : color.blue
c_orange = is_light ? #D84315 : color.orange
c_gray   = is_light ? #424242 : color.gray
c_yellow = is_light ? #B8860B : color.yellow
c_green  = is_light ? #1B5E20 : color.green
c_red    = is_light ? #B71C1C : color.red
c_maroon = is_light ? #5D0A1E : color.maroon
c_purple = is_light ? #4A148C : color.purple

fill(plot(highest_high, display=display.none), plot(lowest_low, display=display.none), color=is_consolidating ? color.new(c_blue, is_light ? 85 : 90) : na, title="Consolidation Zone")
plot(ema_fast, "EMA 9", c_orange)
plot(sma_slow, "SMA 20", c_gray)
plot(use_initial_sl and strategy.position_size > 0 ? active_stop_price : na, "Initial Stop-Loss", c_red, style=plot.style_linebr)

// Signals
plotshape(breakout_condition, "Breakout Setup", shape.arrowdown, location.abovebar, c_yellow, 0, "WATCH", c_yellow, size=size.small)
plotshape(valid_entry, "Buy Confirmation", shape.arrowup, location.belowbar, c_green, 0, "BUY", c_green, size=size.small)
plotshape(exit_trend, "Trend Break", shape.arrowdown, location.abovebar, c_orange, 0, "BREAK", c_orange, size=size.small)
plotshape(exit_vol, "Volume Dump", shape.arrowdown, location.abovebar, c_maroon, 0, "DUMP", c_maroon, size=size.small)
plotshape(exit_pattern, "Bearish Pattern", shape.arrowdown, location.abovebar, c_purple, 0, "PATTERN", c_purple, size=size.small)

// --- Support & Resistance (Lines & Price Labels) ---
if not na(pivot_high)
    pivot_loc = bar_index - sr_right_bars
    line.new(x1=pivot_loc - 1, y1=pivot_high, x2=pivot_loc + 1, y2=pivot_high, color=c_red, width=2)
    label.new(x=pivot_loc, y=pivot_high, text=str.tostring(pivot_high, format.mintick), style=label.style_label_down, color=color.new(color.white, 100), textcolor=c_red, size=size.small)

if not na(pivot_low)
    pivot_loc = bar_index - sr_right_bars
    line.new(x1=pivot_loc - 1, y1=pivot_low, x2=pivot_loc + 1, y2=pivot_low, color=c_green, width=2)
    label.new(x=pivot_loc, y=pivot_low, text=str.tostring(pivot_low, format.mintick), style=label.style_label_up, color=color.new(color.white, 100), textcolor=c_green, size=size.small)
````
