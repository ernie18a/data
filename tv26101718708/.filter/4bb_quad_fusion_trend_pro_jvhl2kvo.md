# 4BB Quad Fusion + Trend Pro

- url: https://www.tradingview.com/script/jvHL2KvO-4BB-Quad-Fusion-Trend-Pro/
- type: indicator
- pine_id: PUB;0c6918d6f22b4d529661274d072b1b34
- version: 2.0

## Description

4BB Quad Fusion + Trend ProThis is a powerful multi-timeframe trend detection and entry system based on the proven 4 Bollinger Bands strategy (inspired by professional day traders).Key Features:4 Quad Bollinger Bands: Combines EMA and WMA bands on both High and Low for precise squeeze and breakout detection
Smart Higher Timeframe Analysis: Checks Daily, 4H, and 1H for MA20 slope, Bollinger scenarios, candle strength, and reversal patterns
Weekly Priority Logic: Special Monday/Tuesday candle analysis for strong directional bias
Clear Final Decision: Shows "YES: Buy Priority", "YES: Bullish confirmed", "YES: Sell Priority", or "NO: Wait" with full reasoning
Highlighted Reversal Patterns: Hammer, Shooting Star, Bull Engulf, Bear Engulf are clearly highlighted in blue in the table
Automatic Trendline Breaks: Displays "B" labels for upper and lower trendline breaks
Directional Dots: Small dots below/above candles showing current bias
Beautiful Band Fills: Clean filled areas between bands for better visual clarity
Fully Customizable: All colors, table position, and settings are adjustable

How to Use:Use on any timeframe (best results on 5m or 15m for entries)
Check the Decision row at the bottom of the table for clear trade direction
Look for Pattern column in 4H or 1H for high-probability reversal setups
Enter in the direction of the higher timeframe confirmation on 5-minute chart

Best paired with:Gold (XAUUSD)
Major forex pairs
Indices and cryptocurrencies

This indicator follows the exact logic of professional multi-timeframe Bollinger Band strategies while adding modern enhancements like pattern highlighting and clean decision logic.

Emin Hasimi

## Source Code

````pine
//@version=5
indicator("4BB Quad Fusion + Trend Pro", shorttitle="4BB + Trend Pro", overlay=true, max_labels_count=500)

// ==============================================
// 1. 4BB Quad Fusion
// ==============================================
length        = input.int(20, "BB Length", minval=1, group="4BB Settings")
mult          = input.float(2.0, "Multiplier", minval=0.5, step=0.1, group="4BB Settings")
squeeze_level = input.float(0.75, "Squeeze Level", minval=0.5, step=0.05, group="4BB Settings")

col_ema_low  = input.color(color.rgb(43, 43, 43), "EMA Low Color",  group="4BB Colors")
col_wma_low  = input.color(color.rgb(43, 43, 43), "WMA Low Color",  group="4BB Colors")
col_ema_high = input.color(#006eff, "EMA High Color", group="4BB Colors")
col_wma_high = input.color(#006eff, "WMA High Color", group="4BB Colors")

fill_low_color  = input.color(color.new(#2f2c2c, 85), "Low Bands Fill", group="4BB Fill")
fill_high_color = input.color(color.new(#0073ff, 85), "High Bands Fill", group="4BB Fill")

dev = mult * ta.stdev(close, length)

ema_low_lower = ta.ema(low, length) - dev
ema_low_upper = ta.ema(low, length) + dev
wma_low_lower = ta.wma(low, length) - dev
wma_low_upper = ta.wma(low, length) + dev

ema_high_lower = ta.ema(high, length) - dev
ema_high_upper = ta.ema(high, length) + dev
wma_high_lower = ta.wma(high, length) - dev
wma_high_upper = ta.wma(high, length) + dev

p_ema_low_lower = plot(ema_low_lower, color=col_ema_low, linewidth=2, title="EMA Low Lower")
p_ema_low_upper = plot(ema_low_upper, color=col_ema_low, linewidth=2, title="EMA Low Upper")
p_wma_low_lower = plot(wma_low_lower, color=col_wma_low, linewidth=2, title="WMA Low Lower")
p_wma_low_upper = plot(wma_low_upper, color=col_wma_low, linewidth=2, title="WMA Low Upper")

p_ema_high_lower = plot(ema_high_lower, color=col_ema_high, linewidth=2, title="EMA High Lower")
p_ema_high_upper = plot(ema_high_upper, color=col_ema_high, linewidth=2, title="EMA High Upper")
p_wma_high_lower = plot(wma_high_lower, color=col_wma_high, linewidth=2, title="WMA High Lower")
p_wma_high_upper = plot(wma_high_upper, color=col_wma_high, linewidth=2, title="WMA High Upper")

plot(ta.ema(close, 20), color=color.white, linewidth=2, title="EMA 20")
plot(ta.ema(close, 60), color=#FF00FF, linewidth=2, title="EMA 60")

fill(p_ema_low_lower, p_wma_low_lower, color=fill_low_color, title="Low Lower Fill")
fill(p_ema_low_upper, p_wma_low_upper, color=fill_low_color, title="Low Upper Fill")
fill(p_ema_high_lower, p_wma_high_lower, color=fill_high_color, title="High Lower Fill")
fill(p_ema_high_upper, p_wma_high_upper, color=fill_high_color, title="High Upper Fill")

// ==============================================
// 2. Trendline Breaks
// ==============================================
length_tl = input.int(14, "Swing Detection Lookback", group="Trendline Breaks")
mult_tl   = input.float(1.0, "Slope Multiplier", minval=0, step=0.1, group="Trendline Breaks")

ph = ta.pivothigh(length_tl, length_tl)
pl = ta.pivotlow(length_tl, length_tl)

var float upper = na
var float lower = na
var float slope_ph = na
var float slope_pl = na

slope = ta.atr(length_tl) / length_tl * mult_tl

slope_ph := ph ? slope : slope_ph
slope_pl := pl ? slope : slope_pl

upper := ph ? ph : upper - slope_ph
lower := pl ? pl : lower + slope_pl

var int upos = 0
var int dnos = 0

upos := ph ? 0 : close > upper - slope_ph * length_tl ? 1 : upos[1]
dnos := pl ? 0 : close < lower + slope_pl * length_tl ? 1 : dnos[1]

plotshape(upos > upos[1] ? low : na, title="Upper Break", style=shape.labelup, location=location.absolute, color=color.teal, text="B", textcolor=color.white, size=size.tiny)
plotshape(dnos > dnos[1] ? high : na, title="Lower Break", style=shape.labeldown, location=location.absolute, color=color.red, text="B", textcolor=color.white, size=size.tiny)

// ==============================================
// 3. EMA Trend + Strength for each timeframe
// ==============================================
table_position  = input.string("bottom_right", "Table Position", options = ["top_left", "top_right", "bottom_left", "bottom_right", "middle_left", "middle_right"], group = "Trend Table")
show_dots       = input.bool(true,  "Show Dots under Candles", group="Trend Table")

// Daily
daily_ema20 = request.security(syminfo.tickerid, "D",   ta.ema(close, 20), lookahead = barmerge.lookahead_off)
daily_ema60 = request.security(syminfo.tickerid, "D",   ta.ema(close, 60), lookahead = barmerge.lookahead_off)
daily_trend = daily_ema20 > daily_ema60 ? "Bullish" : "Bearish"
daily_dist  = math.abs(daily_ema20 - daily_ema60) / daily_ema60 * 100
daily_strength = daily_dist > 0.60 ? "Strong" : daily_dist > 0.30 ? "Medium" : "Weak"

// 4H
fourh_ema20 = request.security(syminfo.tickerid, "240", ta.ema(close, 20), lookahead = barmerge.lookahead_off)
fourh_ema60 = request.security(syminfo.tickerid, "240", ta.ema(close, 60), lookahead = barmerge.lookahead_off)
fourh_trend = fourh_ema20 > fourh_ema60 ? "Bullish" : "Bearish"
fourh_dist  = math.abs(fourh_ema20 - fourh_ema60) / fourh_ema60 * 100
fourh_strength = fourh_dist > 0.60 ? "Strong" : fourh_dist > 0.30 ? "Medium" : "Weak"

// 1H
oneh_ema20 = request.security(syminfo.tickerid, "60",  ta.ema(close, 20), lookahead = barmerge.lookahead_off)
oneh_ema60 = request.security(syminfo.tickerid, "60",  ta.ema(close, 60), lookahead = barmerge.lookahead_off)
oneh_trend = oneh_ema20 > oneh_ema60 ? "Bullish" : "Bearish"
oneh_dist  = math.abs(oneh_ema20 - oneh_ema60) / oneh_ema60 * 100
oneh_strength = oneh_dist > 0.60 ? "Strong" : oneh_dist > 0.30 ? "Medium" : "Weak"

// 5M
fivem_ema20 = request.security(syminfo.tickerid, "5",   ta.ema(close, 20), lookahead = barmerge.lookahead_off)
fivem_ema60 = request.security(syminfo.tickerid, "5",   ta.ema(close, 60), lookahead = barmerge.lookahead_off)
fivem_trend = fivem_ema20 > fivem_ema60 ? "Bullish" : "Bearish"
fivem_dist  = math.abs(fivem_ema20 - fivem_ema60) / fivem_ema60 * 100
fivem_strength = fivem_dist > 0.60 ? "Strong" : fivem_dist > 0.30 ? "Medium" : "Weak"

// Helper Functions
f_bb_bull() =>
    [_, u, l] = ta.bb(close, 20, 2.0)
    (low[1] <= l[1] and close > l) or (close > u and close[1] <= u[1])

f_bb_bear() =>
    [_, u, l] = ta.bb(close, 20, 2.0)
    (high[1] >= u[1] and close < u) or (close < l and close[1] >= l[1])

f_candle_power() =>
    body = math.abs(close - open)
    rng  = high - low
    rng == 0 ? 0 : math.round((body / rng) * 100)

f_reversal_pattern() =>
    if (high - close >= 2 * (close - open)) and (close > open)
        "Shooting Star"
    else if (close - low >= 2 * (open - close)) and (close < open)
        "Hammer"
    else if (close > open[1]) and (open < close[1]) and (close[1] < open[1])
        "Bull Engulf"
    else if (close < open[1]) and (open > close[1]) and (close[1] > open[1])
        "Bear Engulf"
    else
        "—"

// Data
bb_bull_d   = request.security(syminfo.tickerid, "D",   f_bb_bull(), lookahead = barmerge.lookahead_off)
bb_bear_d   = request.security(syminfo.tickerid, "D",   f_bb_bear(), lookahead = barmerge.lookahead_off)
bb_bull_4h  = request.security(syminfo.tickerid, "240", f_bb_bull(), lookahead = barmerge.lookahead_off)
bb_bear_4h  = request.security(syminfo.tickerid, "240", f_bb_bear(), lookahead = barmerge.lookahead_off)
bb_bull_1h  = request.security(syminfo.tickerid, "60",  f_bb_bull(), lookahead = barmerge.lookahead_off)
bb_bear_1h  = request.security(syminfo.tickerid, "60",  f_bb_bear(), lookahead = barmerge.lookahead_off)
bb_bull_5m  = request.security(syminfo.tickerid, "5",   f_bb_bull(), lookahead = barmerge.lookahead_off)
bb_bear_5m  = request.security(syminfo.tickerid, "5",   f_bb_bear(), lookahead = barmerge.lookahead_off)

power_d  = request.security(syminfo.tickerid, "D",   f_candle_power(), lookahead = barmerge.lookahead_off)
power_4h = request.security(syminfo.tickerid, "240", f_candle_power(), lookahead = barmerge.lookahead_off)
power_1h = request.security(syminfo.tickerid, "60",  f_candle_power(), lookahead = barmerge.lookahead_off)
power_5m = request.security(syminfo.tickerid, "5",   f_candle_power(), lookahead = barmerge.lookahead_off)

pattern_4h = request.security(syminfo.tickerid, "240", f_reversal_pattern(), lookahead = barmerge.lookahead_off)
pattern_1h = request.security(syminfo.tickerid, "60",  f_reversal_pattern(), lookahead = barmerge.lookahead_off)
pattern_5m = request.security(syminfo.tickerid, "5",   f_reversal_pattern(), lookahead = barmerge.lookahead_off)

// Weekly
[o_week, h_week, l_week, c_week] = request.security(syminfo.tickerid, "W", [open, high, low, close], lookahead = barmerge.lookahead_off)

// Decision
bool is_mon_tue = dayofweek == dayofweek.monday or dayofweek == dayofweek.tuesday

bool weekly_bull_priority = false
bool weekly_bear_priority = false

if is_mon_tue
    body_week  = math.abs(c_week - o_week)
    range_week = h_week - l_week
    upper_wick = h_week - math.max(o_week, c_week)
    weekly_bull_priority := c_week > o_week and body_week >= range_week * 0.6
    weekly_bear_priority := (c_week < o_week) or (upper_wick >= body_week * 1.5)

bool bull_confirm = bb_bull_d or bb_bull_4h or bb_bull_1h
bool bear_confirm = bb_bear_d or bb_bear_4h or bb_bear_1h

string final_decision = na
color  final_color    = color.gray

if weekly_bull_priority
    final_decision := "YES: Buy Priority → Switch to 5m"
    final_color    := color.new(color.blue, 70)
else if weekly_bear_priority
    final_decision := "YES: Sell Priority → Switch to 5m"
    final_color    := color.new(color.red, 70)
else if bull_confirm and not bear_confirm
    final_decision := "YES: Bullish confirmed → Switch to 5m"
    final_color    := color.new(color.blue, 70)
else if bear_confirm and not bull_confirm
    final_decision := "YES: Bearish confirmed → Switch to 5m"
    final_color    := color.new(color.red, 70)
else
    final_decision := "NO: Wait for clearer confirmation"
    final_color    := color.new(color.orange, 70)

// ==============================================
// Table with EMA Trend + Strength
// ==============================================
var table tbl = table.new(table_position, 5, 10, border_width=0, frame_width=0)

if barstate.islast
    table.clear(tbl, 0, 9)
    
    // Header
    table.cell(tbl, 0, 0, "TF",           text_size=size.normal, bgcolor=color.new(color.blue,80), text_color=color.white)
    table.cell(tbl, 1, 0, "EMA Trend",    text_size=size.normal, bgcolor=color.new(color.blue,80), text_color=color.white)
    table.cell(tbl, 2, 0, "Bollinger",    text_size=size.normal, bgcolor=color.new(color.blue,80), text_color=color.white)
    table.cell(tbl, 3, 0, "Candle Power", text_size=size.normal, bgcolor=color.new(color.blue,80), text_color=color.white)
    table.cell(tbl, 4, 0, "Pattern",      text_size=size.normal, bgcolor=color.new(color.blue,70), text_color=color.white)

    // Daily
    table.cell(tbl, 0, 2, "Daily", text_size=size.normal, bgcolor=color.new(color.gray,90), text_color=color.white)
    table.cell(tbl, 1, 2, daily_trend + " " + str.tostring(daily_dist, "0.00") + "% (" + daily_strength + ")", text_size=size.normal, bgcolor = daily_trend == "Bullish" ? color.new(color.blue,80) : color.new(color.red,80), text_color=color.white)
    table.cell(tbl, 2, 2, bb_bull_d ? "Bull ✅" : bb_bear_d ? "Bear ❌" : "—", text_size=size.normal, bgcolor = bb_bull_d ? color.new(color.blue,80) : bb_bear_d ? color.new(color.red,80) : color.new(color.gray,80), text_color=color.white)
    table.cell(tbl, 3, 2, power_d >= 65 ? "Strong" : power_d >= 45 ? "Medium" : "Weak", text_size=size.normal, bgcolor = power_d >= 65 ? color.new(color.blue,70) : power_d >= 45 ? color.new(color.gray,70) : color.new(color.red,70), text_color=color.white)
    table.cell(tbl, 4, 2, "—", text_size=size.normal, bgcolor=color.new(color.gray,80), text_color=color.white)

    // 4H
    table.cell(tbl, 0, 3, "4H", text_size=size.normal, bgcolor=color.new(color.gray,90), text_color=color.white)
    table.cell(tbl, 1, 3, fourh_trend + " " + str.tostring(fourh_dist, "0.00") + "% (" + fourh_strength + ")", text_size=size.normal, bgcolor = fourh_trend == "Bullish" ? color.new(color.blue,80) : color.new(color.red,80), text_color=color.white)
    table.cell(tbl, 2, 3, bb_bull_4h ? "Bull ✅" : bb_bear_4h ? "Bear ❌" : "—", text_size=size.normal, bgcolor = bb_bull_4h ? color.new(color.blue,80) : bb_bear_4h ? color.new(color.red,80) : color.new(color.gray,80), text_color=color.white)
    table.cell(tbl, 3, 3, power_4h >= 65 ? "Strong" : power_4h >= 45 ? "Medium" : "Weak", text_size=size.normal, bgcolor = power_4h >= 65 ? color.new(color.blue,70) : power_4h >= 45 ? color.new(color.gray,70) : color.new(color.red,70), text_color=color.white)
    table.cell(tbl, 4, 3, pattern_4h, text_size=size.normal, bgcolor=color.new(color.gray,80), text_color=color.white)

    // 1H
    table.cell(tbl, 0, 4, "1H", text_size=size.normal, bgcolor=color.new(color.gray,90), text_color=color.white)
    table.cell(tbl, 1, 4, oneh_trend + " " + str.tostring(oneh_dist, "0.00") + "% (" + oneh_strength + ")", text_size=size.normal, bgcolor = oneh_trend == "Bullish" ? color.new(color.blue,80) : color.new(color.red,80), text_color=color.white)
    table.cell(tbl, 2, 4, bb_bull_1h ? "Bull ✅" : bb_bear_1h ? "Bear ❌" : "—", text_size=size.normal, bgcolor = bb_bull_1h ? color.new(color.blue,80) : bb_bear_1h ? color.new(color.red,80) : color.new(color.gray,80), text_color=color.white)
    table.cell(tbl, 3, 4, power_1h >= 65 ? "Strong" : power_1h >= 45 ? "Medium" : "Weak", text_size=size.normal, bgcolor = power_1h >= 65 ? color.new(color.blue,70) : power_1h >= 45 ? color.new(color.gray,70) : color.new(color.red,70), text_color=color.white)
    table.cell(tbl, 4, 4, pattern_1h, text_size=size.normal, bgcolor=color.new(color.gray,80), text_color=color.white)

    // 5M
    table.cell(tbl, 0, 5, "5M", text_size=size.normal, bgcolor=color.new(color.gray,90), text_color=color.white)
    table.cell(tbl, 1, 5, fivem_trend + " " + str.tostring(fivem_dist, "0.00") + "% (" + fivem_strength + ")", text_size=size.normal, bgcolor = fivem_trend == "Bullish" ? color.new(color.blue,80) : color.new(color.red,80), text_color=color.white)
    table.cell(tbl, 2, 5, bb_bull_5m ? "Bull ✅" : bb_bear_5m ? "Bear ❌" : "—", text_size=size.normal, bgcolor = bb_bull_5m ? color.new(color.blue,80) : bb_bear_5m ? color.new(color.red,80) : color.new(color.gray,80), text_color=color.white)
    table.cell(tbl, 3, 5, power_5m >= 65 ? "Strong" : power_5m >= 45 ? "Medium" : "Weak", text_size=size.normal, bgcolor = power_5m >= 65 ? color.new(color.blue,70) : power_5m >= 45 ? color.new(color.gray,70) : color.new(color.red,70), text_color=color.white)
    table.cell(tbl, 4, 5, pattern_5m, text_size=size.normal, bgcolor=color.new(color.gray,80), text_color=color.white)

    // Decision
    string decision_text = final_decision
    table.cell(tbl, 0, 6, "Decision", text_size=size.normal, bgcolor=color.new(color.blue,70), text_color=color.white)
    table.cell(tbl, 1, 6, decision_text, text_size=size.normal, bgcolor=final_color, text_color=color.white)
    table.cell(tbl, 2, 6, "", text_size=size.normal, bgcolor=final_color, text_color=color.white)
    table.cell(tbl, 3, 6, "", text_size=size.normal, bgcolor=final_color, text_color=color.white)
    table.cell(tbl, 4, 6, "", text_size=size.normal, bgcolor=final_color, text_color=color.white)

// Force Overlay + Dots
plot(na, "Force Overlay", color=color.new(color.white, 100))

bool is_bull_dir = weekly_bull_priority or (bull_confirm and not bear_confirm)
bool is_bear_dir = weekly_bear_priority or (bear_confirm and not bull_confirm)

plotchar(show_dots and is_bull_dir, "Bull Dot", "·", location.belowbar, color.new(color.green, 0), size=size.tiny)
plotchar(show_dots and is_bear_dir, "Bear Dot", "·", location.abovebar, color.new(color.red, 0), size=size.tiny)
````
