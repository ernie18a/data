# Tightening Trailing Stop Loss

- url: https://www.tradingview.com/script/iw08tU9z-Tightening-Trailing-Stop-Loss/
- type: indicator
- pine_id: PUB;ad869ca37fb24c81b404a947fc55cd93
- version: 1.0

## Description

A utility tool to independently simulate a Trailing Stop based on ATR and Recent Candle Structure. It's most helpful if you only want something to independently trail a Stop and nothing else. For example, if you decide where to enter via a discretionary system, but like trailing Stops via code. 

It's used by changing the 'Start Date' to the date where you wish to enter. It'll then display a Stop and Trail it, until it intersects with a candle. The Indicator will hide itself when it intersects with a candle to avoid cluttering the chart. It only moves in the direction of risk, so that means that, when set, it'll never increase the risk of your trade, unlike simple ATR bands. However, it does require resetting manually for each trade. 

By Default, it uses a 10 Period RMA ATR, which is set 0.5 ATR away from the Low/High of the recent candle structure. It'll tighten each candle by multiplying it's value with .95, meaning it always tightens a little. All of these can be changed in the settings to match your preferred method of Setting/Trailing Stops

## Source Code

````pine
//@version=6
indicator('Tightening Trailing Stop Loss', shorttitle = 'TTSL', overlay = true)

// Input parameters
length = input.int(title = 'Length', defval = 10, minval = 1)
smoothing = input.string(title = 'Smoothing', defval = 'RMA', options = ['RMA', 'SMA', 'EMA', 'WMA'])
ma_function(source, length) =>
    switch smoothing
        'RMA' => ta.rma(source, length)
        'SMA' => ta.sma(source, length)
        'EMA' => ta.ema(source, length)
        => ta.wma(source, length)

atr_value = ta.atr(length)

atr_trail_multiplier_initial = input.float(0.5, step = 0.1, title = 'ATR Trail Multiplier Initial')
atr_trail_decay = input.float(0.95, step = 0.1, title = 'ATR Trail Decay')
lookback_period = input.int(3, title = 'Rolling Lookback Period')
start_date = input.time(timestamp('2026-06-01 00:00'), title = 'Start Date')

enable_long_trail = input.bool(true, title = 'Enable Long Trailing Stop')
enable_short_trail = input.bool(true, title = 'Enable Short Trailing Stop')

// Track whether the trade is active or has been stopped out ---
var bool long_active = false
var bool short_active = false

// Trigger trade activation at the start date (and reset multipliers)
if ta.crossover(time, start_date)
    if enable_long_trail
        long_active := true
    if enable_short_trail
        short_active := true

// Initialize variables
var float atr_trail_multiplier_long = atr_trail_multiplier_initial
var float atr_trail_multiplier_short = atr_trail_multiplier_initial
var float trailing_stop_loss_long = na
var float trailing_stop_loss_short = na

rolling_min_lows = ta.lowest(low, lookback_period)
rolling_max_highs = ta.highest(high, lookback_period)

// Long Trailing Stop Logic ---
if long_active
    trailing_stop_loss_long := na(trailing_stop_loss_long) ? rolling_min_lows - atr_value * atr_trail_multiplier_long : math.max(trailing_stop_loss_long, rolling_min_lows - atr_value * atr_trail_multiplier_long)
    atr_trail_multiplier_long := atr_trail_multiplier_long * atr_trail_decay
    
    // Check if stopped out (Low breaks below the Trailing Stop)
    if low <= trailing_stop_loss_long
        long_active := false
        trailing_stop_loss_long := na // Erases the line from this point forward
else
    // Reset if not active so it's fresh for the next manual start_date change
    trailing_stop_loss_long := na
    atr_trail_multiplier_long := atr_trail_multiplier_initial

// Short Trailing Stop Logic ---
if short_active
    trailing_stop_loss_short := na(trailing_stop_loss_short) ? rolling_max_highs + atr_value * atr_trail_multiplier_short : math.min(trailing_stop_loss_short, rolling_max_highs + atr_value * atr_trail_multiplier_short)
    atr_trail_multiplier_short := atr_trail_multiplier_short * atr_trail_decay
    
    // Check if stopped out (High breaks above the Trailing Stop)
    if high >= trailing_stop_loss_short
        short_active := false
        trailing_stop_loss_short := na // Erases the line from this point forward
else
    // Reset if not active
    trailing_stop_loss_short := na
    atr_trail_multiplier_short := atr_trail_multiplier_initial

// Plotting
plot(enable_long_trail ? trailing_stop_loss_long : na, color = color.green, linewidth = 2, title = 'Long Trailing Stop Loss', style = plot.style_linebr)
plot(enable_short_trail ? trailing_stop_loss_short : na, color = color.red, linewidth = 2, title = 'Short Trailing Stop Loss', style = plot.style_linebr)
````
