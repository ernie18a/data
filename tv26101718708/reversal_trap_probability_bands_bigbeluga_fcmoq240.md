# Reversal Trap Probability Bands [BigBeluga]

- url: https://www.tradingview.com/script/fcmOq240-Reversal-Trap-Probability-Bands-BigBeluga/
- type: indicator
- pine_id: PUB;f6a1ddeb222244ea9c773e79357c7c08
- version: 1.0

## Description

[b]🔵 OVERVIEW[/b]

The [b]Reversal Trap Probability Bands[/b] is an advanced technical indicator created by BigBeluga to identify and trade fakeout traps around market extremes. Traditional envelope or band indicators often fail because traders blindly enter breakouts that quickly reverse into whipsaw losses. In order to provide a solution to this problem, this indicator combines volatility-based envelope channels with a dynamic probability tracking engine, measuring historical RSI buckets to calculate real-time win probabilities for reversal traps.

The indicator aims to visualize institutional exhaustion and subsequent mean-reversion expansions. The core element of its calculation involves tracking baseline moving averages alongside outer volatility bounds defined as:

[i]upper_band = basis + (multiplier * vola)[/i]
[i]lower_band = basis - (multiplier * vola)[/i]

where [i]basis[/i] is an exponential moving average of length [i]envelope_len[/i], and [i]vola[/i] is the ATR volatility measure scaled by [i]multiplier[/i]. Higher values of [i]envelope_len[/i] and [i]multiplier[/i] allow the indicator to filter out routine market noise and isolate major structural exhaustion points.


[b]🔵 FEATURES[/b]

The system utilizes a multi-layered matrix structure to provide actionable market intelligence:

[b]1 — Volatility Envelope & Basis Engine[/b]
[list]
[*] [i]envelope_len = input.int(55, "Envelope Smoothness")[/i]: Controls the responsiveness and smoothness of the central baseline.
[*] [i]upper_band[/i] & [i]lower_band[/i]: Dynamic outer boundaries that shade gradient fills to visualize upper and lower market extremes.
[image]https://www.tradingview.com/x/X8AyuaJP/[/image]
[/list]

[b]2 — Reversal Trap Detection & RSI Probability Tracking[/b]
[list]
[*] [i]trap_window = input.int(10, "Trap Window (Candles)")[/i]: Defines the maximum candle count allowed outside the bands before invalidating a fakeout setup.
[image]https://www.tradingview.com/x/CXSZHzej/[/image]
[*] [i]rsi_bucket = math.max(0, math.min(10, math.round(rsi / 10)))[/i]: Automatically categorizes momentum into distinct RSI tiers to calculate real-time win probability rates.
[image]https://www.tradingview.com/x/RxuD95q1/[/image]
[/list]

[b]3 — Dynamic Target, Stop, & Signal Management[/b]
[list]
[*] [i]Bull_Stop = ta.lowest(low, 2) - atr[/i] & [i]Bear_Stop = ta.highest(high, 2) + atr[/i]: Calculates volatility-adjusted safety padding for active trade management.
[*] Signal Labels & Targets: Plots clear entry notifications displaying win probability percentages, along with dashed target and stop lines.
[image]https://www.tradingview.com/x/pDpjJyuO/[/image]
[/list]


[b]🔵 HOW TO USE[/b]

Apart from the basic visualization of volatility extremes, this tool can also act in alternative ways to support decision-making:

[list=1]
[*] [i]Identify Reversal Traps:[/b] Wait for price to break outside the upper or lower envelope boundaries and subsequently close back inside within the defined [i]trap_window[/i].
[*] [i]Evaluate Win Probability:[/b] Check the probability percentage displayed on the trap signal label (backed by historical RSI bucket tracking) before entering a trade.
[image]https://www.tradingview.com/x/PkGfN6QB/[/image]
[*] [i]Manage Risk with Stops and Targets:[/b] Use the projected dashed target lines (anchored to the basis line) and ATR-padded stop lines to execute and protect positions.
[/list]


[b]🔵 NOTES[/b]

[b]Why this implementation is unique:[/b]
[list]
[*] It moves beyond static band indicators by integrating a self-learning historical database that calculates live win probabilities based on momentum buckets.
[*] The automated target and stop-loss line projection engine provides clear visual roadmaps for every triggered setup.
[*] The script is fully optimized for Pine Script version 6, utilizing high-performance array tracking (`var int[] bull_total = array.new_int(11, 0)`) for smooth execution.
[*] Note: Because the win probability engine evaluates historical trade performance dynamically in real time, initial signals on a freshly loaded chart may display "Tracking..." until sufficient sample data is recorded.
[/list]

## Source Code

````pine
// This work is licensed under Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International  
// https://creativecommons.org/licenses/by-nc-sa/4.0/
// © BigBeluga

//@version=6
indicator("Reversal Trap Probability Bands [BigBeluga]", overlay=true, max_labels_count=100, max_lines_count=500)

// ＩＮＰＵＴＳ ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――{

envelope_len  = input.int(55, "Envelope Smoothness", minval=1, group="Envelope Settings", tooltip="Changes the length of the central moving average line. Higher values create a smoother, slower channel.")
multiplier    = input.float(4.0, "Envelope Width", minval=0.1, step=0.1, group="Envelope Settings", tooltip="Determines how far the outer bands stretch away from the center baseline based on market volatility.")

trap_window   = input.int(10, "Trap Window (Candles)", minval=1, group="Strategy Settings", tooltip="The maximum number of candles allowed to close completely outside the bands before a reversal is disqualified as a fakeout trap.")
signal_gap    = input.int(10, "Minimum Bars Between Signals", minval=1, group="Strategy Settings", tooltip="Cooldown period. The minimum number of bars required between signal triggers to avoid cluttering your charts.")
rsi_len       = 20
stop_mult     = input.float(0.5, "ATR Stop Multiplier", minval=0.1, step=0.1, group="Strategy Settings", tooltip="Multiplies the Average True Range (ATR) value to add safety padding above or below structural key levels.")
target_source = "Basis Line"

max_bars      = input.int(5000, "Max Lookback Bars", minval=1, group="Database Limits", tooltip="Limits the script's historical memory. It will only search and record trades from the last X number of bars.")
max_trades    = input.int(500, "Max Total Trades", minval=1, group="Database Limits", tooltip="Database limit guardrail. Stops saving new trades to memory once the total historical trade counter hits this number.")

colorDn       = input.color(color.rgb(236, 51, 51), "Bearish Theme Color", group="Color Styling", tooltip="Changes the color of the upper envelope boundary, bearish labels, and shading effects.")
colorUp       = input.color(color.rgb(18, 175, 159), "Bullish Theme Color", group="Color Styling", tooltip="Changes the color of the lower envelope boundary, bullish labels, and shading effects.")
colormid      = input.color(color.rgb(120, 123, 134, 50), "MidLine Color", group="Color Styling", tooltip="Changes the color of the middle envelope boundary")

label_size_setting = input.string("Small", "Label Size", options=["Auto", "Tiny", "Small", "Normal", "Large", "Huge"], group="Color Styling", tooltip="Adjusts the size of the signal labels displayed on the chart.")

// }
// ＣＡＬＣＵＬＡＴＩＯＮＳ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――{

basis = ta.ema(close, envelope_len)
vola  = ta.atr(envelope_len)
rsi   = ta.rsi(close, rsi_len)

upper_band = basis + (multiplier * vola)
lower_band = basis - (multiplier * vola)

rsi_bucket = math.max(0, math.min(10, math.round(rsi / 10)))
atr        = ta.atr(100) * stop_mult

// Convert label size input to TradingView size type
get_label_size(size_str) =>
    switch size_str
        "Auto"   => size.auto
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Normal" => size.normal
        "Large"  => size.large
        "Huge"   => size.huge
        => size.small

selected_label_size = get_label_size(label_size_setting)

// Historical Database Trackers
var int[] bull_total = array.new_int(11, 0)
var int[] bull_wins  = array.new_int(11, 0)
var int[] bear_total = array.new_int(11, 0)
var int[] bear_wins  = array.new_int(11, 0)

var int total_trades_count = 0
bars_from_live = last_bar_index - bar_index
allowed_by_limits = (bars_from_live <= max_bars) and (total_trades_count < max_trades)

// Trap Counter States
var int close_above_envelope_count = 0
var int close_below_envelope_count = 0




bool raw_bear_trap = false
if close < upper_band
    if high > upper_band and close[1] < upper_band and close_above_envelope_count[1] <= trap_window
        raw_bear_trap := true
    else if close[1] > upper_band and close_above_envelope_count[1] <= trap_window
        raw_bear_trap := true


if high > upper_band
    close_above_envelope_count += 1
else
    close_above_envelope_count := 0



bool raw_bull_trap = false
if close > lower_band
    if low < lower_band and close[1] > lower_band and close_below_envelope_count[1] <= trap_window
        raw_bull_trap := true
    else if close[1] < lower_band and close_below_envelope_count[1] <= trap_window
        raw_bull_trap := true


if low < lower_band
    close_below_envelope_count += 1
else
    close_below_envelope_count := 0


var int last_signal_bar = -1000
can_fire = (bar_index - last_signal_bar) >= signal_gap

bull_trap = raw_bull_trap and can_fire
bear_trap = raw_bear_trap and can_fire

if bull_trap or bear_trap
    last_signal_bar := bar_index

// Tracking Engines
var bool active_bull = false
var line bull_target = na
var line bull_stop   = na
var int  bull_bucket = na
var line potentialTarget = na
Bull_Stop = ta.lowest(low, 2) - atr

if bull_trap and not active_bull and allowed_by_limits
    active_bull := true
    bull_bucket := rsi_bucket
    total_trades_count += 1
    
    float calculated_target = target_source == "Basis Line" ? basis : upper_band
    
    bull_target     := line.new(bar_index, calculated_target, bar_index + 10, calculated_target, color = colorUp, style = line.style_dashed)
    bull_stop       := line.new(bar_index, Bull_Stop, bar_index + 10, Bull_Stop, color = colorUp, style = line.style_dashed)
    potentialTarget := line.new(x1=bar_index, y1=low, x2=bar_index+10, y2=calculated_target, color=colorUp, style=line.style_arrow_right)

    total_attempts = array.get(bull_total, rsi_bucket)
    total_success  = array.get(bull_wins, rsi_bucket)
    string prob_text = "Tracking..."
    rate = 0.0

    if total_attempts > 0
        rate := math.round((total_success / total_attempts) * 100)
        prob_text := str.tostring(rate) + "% WIN PROB"
        
    label.new(x=bar_index, y=low-atr, text="⬆\nTRAP\n" + prob_text + "\n(RSI: " + str.tostring(math.round(rsi)) + ")", style=label.style_label_up, color=color.new(colorUp, 100), textcolor=colorUp, size=selected_label_size, tooltip = "Win Probability: " + str.tostring(rate) + "%")

if active_bull
    bull_stop.set_x2(bar_index+10)
    bull_target.set_x2(bar_index+10)
    potentialTarget.set_x2(bar_index+10)    

    if high >= bull_target.get_price(bar_index) and bar_index - last_signal_bar > 1
        array.set(bull_total, bull_bucket, array.get(bull_total, bull_bucket) + 1)
        array.set(bull_wins,  bull_bucket, array.get(bull_wins,  bull_bucket) + 1)
        active_bull := false
        label.new(bar_index, high, "✓", style = label.style_label_down, color = color.new(colorDn, 100), textcolor = colorUp, size=selected_label_size)
        bull_stop.set_x2(bar_index)
        bull_target.set_x2(bar_index)
        potentialTarget.set_x2(bar_index)    
    else if low < bull_stop.get_price(bar_index) and bar_index - last_signal_bar > 1
        array.set(bull_total, bull_bucket, array.get(bull_total, bull_bucket) + 1)
        active_bull := false
        bull_stop.set_x2(bar_index)
        bull_target.set_x2(bar_index)
        potentialTarget.set_x2(bar_index)    

var bool active_bear = false
var line bear_target = na
var line bear_stop   = na
var int  bear_bucket = na
var line potentialTargetBear = na
Bear_Stop = ta.highest(high, 2) + atr

if bear_trap and not active_bear and allowed_by_limits
    active_bear := true
    bear_bucket := rsi_bucket
    total_trades_count += 1
    
    float calculated_target = target_source == "Basis Line" ? basis : lower_band
    
    bear_target         := line.new(bar_index, calculated_target, bar_index + 10, calculated_target, color = colorDn, style = line.style_dashed)
    bear_stop           := line.new(bar_index, Bear_Stop, bar_index + 10, Bear_Stop, color = colorDn, style = line.style_dashed)
    potentialTargetBear := line.new(x1=bar_index, y1=high, x2=bar_index+10, y2=calculated_target, color=colorDn, style=line.style_arrow_right)

    total_attempts = array.get(bear_total, rsi_bucket)
    total_success  = array.get(bear_wins, rsi_bucket)
    string prob_text = "Tracking..."
    rate = 0.0

    if total_attempts > 0
        rate := math.round((total_success / total_attempts) * 100)
        prob_text := str.tostring(rate) + "% WIN PROB"
        
    label.new(x=bar_index, y=high+atr, text=prob_text + "\n(RSI: " + str.tostring(math.round(rsi)) + ")" + "\nTRAP\n⬇", style=label.style_label_down, color=color.new(colorUp, 100), textcolor=colorDn, size=selected_label_size, tooltip = "Win Probability: " + str.tostring(rate) + "%")

if active_bear
    bear_stop.set_x2(bar_index+10)
    potentialTargetBear.set_x2(bar_index+10)
    bear_target.set_x2(bar_index+10)

    if low <= bear_target.get_price(bar_index) and bar_index - last_signal_bar > 1
        array.set(bear_total, bear_bucket, array.get(bear_total, bear_bucket) + 1)
        array.set(bear_wins,  bear_bucket, array.get(bear_wins,  bear_bucket) + 1)
        active_bear := false
        label.new(bar_index, low, "✓", style = label.style_label_up, color = color.new(colorDn, 100), textcolor = colorDn, size=selected_label_size)
        bear_stop.set_x2(bar_index)
        bear_target.set_x2(bar_index)
        potentialTargetBear.set_x2(bar_index)
    else if high > bear_stop.get_price(bar_index) and bar_index - last_signal_bar > 1
        array.set(bear_total, bear_bucket, array.get(bear_total, bear_bucket) + 1)
        active_bear := false
        bear_stop.set_x2(bar_index)
        bear_target.set_x2(bar_index)
        potentialTargetBear.set_x2(bar_index)

// }
// ＰＬＯＴ ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――{

plot_upper = plot(upper_band, "Envelope Ceiling", color=color.new(colorDn, 50), linewidth=3)
plot_lower = plot(lower_band, "Envelope Floor",   color=color.new(colorUp, 50), linewidth=3)
plot_basis = plot(basis, "Envelope Baseline",     color=colormid, linestyle = plot.linestyle_dashed)

fill(
     plot1        = plot_upper, 
     plot2        = plot_basis, 
     top_value    = upper_band, 
     bottom_value = basis, 
     top_color    = color.new(colorDn, 90), 
     bottom_color = color.new(colorDn, 100), 
     title        = "Upper Band Gradient"
     )

fill(
     plot1        = plot_basis, 
     plot2        = plot_lower, 
     top_value    = basis, 
     bottom_value = lower_band, 
     top_color    = color.new(colorUp, 100), 
     bottom_color = color.new(colorUp, 90), 
     title        = "Lower Band Gradient"
     )

// }
````
