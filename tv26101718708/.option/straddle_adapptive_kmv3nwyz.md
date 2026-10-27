# straddle adapptive

- url: https://www.tradingview.com/script/kMv3Nwyz-straddle-adapptive/
- type: indicator
- pine_id: PUB;64f9da2de7cf42d5bd6b1b1f9649eee1
- version: 1.0

## Description

This indicator tracks the combined Call + Put option premium (straddle) to detect market momentum.

It shows:

Spike BUY when strong upward premium movement starts

Retrace SELL when that move weakens or pulls back


In simple terms: it helps identify when option premiums suddenly expand and when that move starts fading.

## Source Code

````pine
//@version=5
indicator("Adaptive Straddle Spike Detector (My Example)", overlay=false, precision=2)

//━━━━━━━━━━━━━━━━━━━
// INPUTS
//━━━━━━━━━━━━━━━━━━━

grp_entry = "TIME SETTINGS"
start_hour = input.int(9, "Start Hour", minval=0, maxval=23, group=grp_entry)
start_min  = input.int(30, "Start Minute", minval=0, maxval=59, group=grp_entry)

grp_spike = "SPIKE SETTINGS"
base_spike = input.float(10.0, "Base Spike %", step=0.1, group=grp_spike)

grp_retrace = "RETRACEMENT"
retrace_per = input.float(50.0, "Retracement %", minval=1, maxval=100, step=1, group=grp_retrace)

grp_symbol = "OPTION SYMBOLS"
symbol_ce = input.symbol("NSE:NIFTY260515C22000", "Call Option", group=grp_symbol)
symbol_pe = input.symbol("NSE:NIFTY260515P22000", "Put Option", group=grp_symbol)

grp_vix = "VIX SETTINGS"
vix_symbol = input.symbol("NSE:INDIAVIX", "India VIX Symbol", group=grp_vix)

//━━━━━━━━━━━━━━━━━━━
// DATA FETCHING
//━━━━━━━━━━━━━━━━━━━

ce_c = request.security(symbol_ce, timeframe.period, close)
ce_h = request.security(symbol_ce, timeframe.period, high)
ce_l = request.security(symbol_ce, timeframe.period, low)
ce_v = request.security(symbol_ce, timeframe.period, volume)

pe_c = request.security(symbol_pe, timeframe.period, close)
pe_h = request.security(symbol_pe, timeframe.period, high)
pe_l = request.security(symbol_pe, timeframe.period, low)
pe_v = request.security(symbol_pe, timeframe.period, volume)

vix_close = request.security(vix_symbol, timeframe.period, close)

//━━━━━━━━━━━━━━━━━━━
// STRADDLE VALUES
//━━━━━━━━━━━━━━━━━━━

straddle_close = ce_c + pe_c
straddle_high  = ce_h + pe_h
straddle_low   = ce_l + pe_l
combined_vol   = ce_v + pe_v

//━━━━━━━━━━━━━━━━━━━
// CUSTOM VWAP
//━━━━━━━━━━━━━━━━━━━

var float cum_pv = 0.0
var float cum_vol = 0.0

new_day = ta.change(time("D"))

if new_day
    cum_pv := 0.0
    cum_vol := 0.0

cum_pv += straddle_close * combined_vol
cum_vol += combined_vol

combined_vwap = cum_vol != 0 ? cum_pv / cum_vol : na

//━━━━━━━━━━━━━━━━━━━
// CORE VARIABLES
//━━━━━━━━━━━━━━━━━━━

var float day_low = na
var bool in_spike = false

is_allowed = (hour * 60 + minute) >= (start_hour * 60 + start_min)

//━━━━━━━━━━━━━━━━━━━
// DAILY RESET (DAY START)
//━━━━━━━━━━━━━━━━━━━

if new_day
    day_low := straddle_close
    in_spike := false

//━━━━━━━━━━━━━━━━━━━
// MY DAY LOW DETECTOR BLOCK
//━━━━━━━━━━━━━━━━━━━

if is_allowed and not in_spike
    if na(day_low)
        day_low := straddle_close
    else
        day_low := math.min(day_low, straddle_close)

//━━━━━━━━━━━━━━━━━━━
// LIVE DYNAMIC THRESHOLD (VIX + MULTIPLIER)
//━━━━━━━━━━━━━━━━━━━

vix_multiplier = vix_close < 15 ? 1.3 :
     vix_close < 20 ? 1.5 :
     vix_close < 25 ? 1.7 :
     2.0

dynamic_threshold = vix_close * vix_multiplier

//━━━━━━━━━━━━━━━━━━━
// SPIKE DETECTION
//━━━━━━━━━━━━━━━━━━━

spike_trigger = day_low * (1 + dynamic_threshold / 100)
buy_signal = is_allowed and not in_spike and straddle_close >= spike_trigger

//━━━━━━━━━━━━━━━━━━━
// SPIKE STATE
//━━━━━━━━━━━━━━━━━━━

if buy_signal
    in_spike := true

//━━━━━━━━━━━━━━━━━━━
// RETRACEMENT LOGIC
//━━━━━━━━━━━━━━━━━━━

sell_signal = false

if in_spike
    float current_spike_high = ta.highest(straddle_close, ta.barssince(buy_signal) + 1)
    float current_retrace_level = current_spike_high - ((current_spike_high - day_low) * (retrace_per / 100))
    
    if straddle_close <= current_retrace_level
        sell_signal := true
        in_spike := false
        day_low := straddle_close

//━━━━━━━━━━━━━━━━━━━
// PLOTS
//━━━━━━━━━━━━━━━━━━━

plot(straddle_close, title="Straddle Price", color=color.blue, linewidth=2)
plot(combined_vwap, title="Combined VWAP", color=color.yellow, linewidth=2)
plot(day_low, title="My Day Low Detector", color=color.green, style=plot.style_circles)

//━━━━━━━━━━━━━━━━━━━
// SIGNALS
//━━━━━━━━━━━━━━━━━━━

plotshape(buy_signal, title="SPIKE BUY", location=location.top, style=shape.labeldown, color=color.lime, text="SPIKE BUY", textcolor=color.black, size=size.small)
plotshape(sell_signal, title="RETRACE SELL", location=location.bottom, style=shape.labelup, color=color.red, text="RETRACE SELL", textcolor=color.white, size=size.small)

//━━━━━━━━━━━━━━━━━━━
// BACKGROUND
//━━━━━━━━━━━━━━━━━━━

bgcolor(in_spike ? color.new(color.orange, 92) : na)

//━━━━━━━━━━━━━━━━━━━
// DASHBOARD
//━━━━━━━━━━━━━━━━━━━

var table dashboard = table.new(position.top_right, 2, 7, bgcolor=color.black, border_width=1)

if barstate.islast
    table.cell(dashboard, 0, 0, "Live VIX", text_color=color.white)
    table.cell(dashboard, 1, 0, str.tostring(vix_close, "#.##"), text_color=color.aqua)

    table.cell(dashboard, 0, 1, "VIX Multiplier", text_color=color.white)
    table.cell(dashboard, 1, 1, str.tostring(vix_multiplier, "#.##"), text_color=color.orange)

    table.cell(dashboard, 0, 2, "Threshold", text_color=color.white)
    table.cell(dashboard, 1, 2, str.tostring(dynamic_threshold, "#.##") + "%", text_color=color.orange)

    table.cell(dashboard, 0, 3, "Day Low", text_color=color.white)
    table.cell(dashboard, 1, 3, str.tostring(day_low, "#.##"), text_color=color.lime)

    table.cell(dashboard, 0, 4, "Spike Trigger", text_color=color.white)
    table.cell(dashboard, 1, 4, str.tostring(spike_trigger, "#.##"), text_color=color.orange)

    table.cell(dashboard, 0, 5, "Formula", text_color=color.white)
    table.cell(dashboard, 1, 5, "Low × (1 + Th/100)", text_color=color.silver)

    table.cell(dashboard, 0, 6, "State", text_color=color.white)
    table.cell(dashboard, 1, 6, in_spike ? "SPIKE" : "NORMAL", text_color=in_spike ? color.orange : color.green)

//━━━━━━━━━━━━━━━━━━━
// ALERTS
//━━━━━━━━━━━━━━━━━━━

alertcondition(buy_signal, title="SPIKE BUY ALERT", message="Straddle Spike BUY Triggered")
alertcondition(sell_signal, title="RETRACE SELL ALERT", message="Straddle Retracement SELL Triggered")
````
