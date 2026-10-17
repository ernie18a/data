# Market Structure Buy/Sell Signals

- url: https://www.tradingview.com/script/YWlxuIeN-Market-Structure-Buy-Sell-Signals/
- type: indicator
- pine_id: PUB;9783457394024489884c33fecc317518
- version: 1.0

## Description

This script is designed to automate the Market Structure and N-pattern analysis detailed in the sources, transforming hand-drawn technical principles into real-time visual signals. It identifies high-probability entry points based on structural shifts and wave retracements.

## Source Code

````pine
//@version=5
indicator("Market Structure Buy/Sell Signals", overlay=true)

// --- User Inputs ---
lookback = input.int(5, "Pivot Lookback (LS/LB Detection)")
retrace_min = input.float(70.0, "Min Retrace %", minval=0, maxval=100) / 100
retrace_max = input.float(80.0, "Max Retrace %", minval=0, maxval=100) / 100

// --- Market Structure Detection ---
// Identifying the LS (Last Selling Point) and LB (Last Buying Point) [3, 4]
ph = ta.pivothigh(high, lookback, lookback)
pl = ta.pivotlow(low, lookback, lookback)

var float last_ls = na
var float last_lb = na
var float prev_ls = na
var float prev_lb = na

if not na(ph)
    prev_ls := last_ls
    last_ls := ph

if not na(pl)
    prev_lb := last_lb
    last_lb := pl

// --- Signal Logic from Sources ---

// 1. N-Pattern Confirmation [4, 5]
// Buy condition: Price crosses the last high (LS) [4]
// Sell condition: Price goes below the last low (LB) [5]
is_uptrend_confirmed = not na(last_ls) and ta.crossover(close, last_ls)
is_downtrend_confirmed = not na(last_lb) and ta.crossunder(close, last_lb)

// 2. Retracement Logic (The 70-80% Rule) [1, 2]
// Buy (Call) Logic: After a fall, price retraces 70-80% upside relative to the last fall [1]
float last_down_wave = prev_ls - last_lb
float current_buy_retrace = (high - last_lb) / last_down_wave
bool valid_buy_zone = current_buy_retrace >= retrace_min and current_buy_retrace <= retrace_max

// Sell (Put) Logic: After a rise, price retraces 70-80% downside relative to the last rise [2]
float last_up_wave = last_ls - prev_lb
float current_sell_retrace = (last_ls - low) / last_up_wave
bool valid_sell_zone = current_sell_retrace >= retrace_min and current_sell_retrace <= retrace_max

// --- Signal Triggering ---
// Signals trigger when the N-pattern structure is valid and price enters the 70-80% zone
buy_signal = valid_buy_zone and close > last_lb
sell_signal = valid_sell_zone and close < last_ls

// --- Visual Indicators ---
// Buy Signal (Call Option) [1]
plotshape(buy_signal, title="Buy Signal", text="BUY\n(CALL)", style=shape.labelup, location=location.belowbar, color=color.green, textcolor=color.white, size=size.small)

// Sell Signal (Put Option) [2]
plotshape(sell_signal, title="Sell Signal", text="SELL\n(PUT)", style=shape.labeldown, location=location.abovebar, color=color.red, textcolor=color.white, size=size.small)

// --- Level Plotting ---
plot(last_ls, "LS Level (Red)", color=color.new(color.red, 50), style=plot.style_linebr, offset=-lookback)
plot(last_lb, "LB Level (Green)", color=color.new(color.green, 50), style=plot.style_linebr, offset=-lookback)

// Trend Strength: "Very Strong" if no overlap between current LB and previous LS [6]
is_strong = last_lb > prev_ls 
bgcolor(is_strong ? color.new(color.blue, 90) : na)
````
