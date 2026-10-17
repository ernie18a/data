# BBMA Pro Strategy with Alerts

- url: https://www.tradingview.com/script/LKpPtBjR-BBMA-Pro-Strategy-with-Alerts/
- type: indicator
- pine_id: PUB;a65dccf878dd4c8ab48b3db4eab0e2aa
- version: 1.0

## Description

"BBMA (Bollinger Bands + Moving Average) is used to read the map of market price movements (trends) and find the best places to enter positions with a measured risk."

## Source Code

````pine
//@version=6
indicator("BBMA Pro Strategy with Alerts", shorttitle="BBMA PRO", overlay=true, max_bars_back=500)

// ═══════════════════════════════════════════════════════════
//  INPUTS & CONFIGURATION
// ═══════════════════════════════════════════════════════════
bb_len      = input.int(20,     "BB Length",            group="Bollinger Bands")
bb_mult     = input.float(2.0,  "BB Multiplier",        group="Bollinger Bands")

ma_fast     = input.int(5,      "Fast MA Period",       group="BBMA Moving Averages")
ma_slow     = input.int(10,     "Slow MA Period",       group="BBMA Moving Averages")
ema_filter  = input.int(50,     "Trend Filter (EMA)",   group="BBMA Moving Averages")

show_table  = input.bool(true,  "Show Status Dashboard",group="Interface Settings")

// ═══════════════════════════════════════════════════════════
//  GLOBAL HISTORICAL EVALUATIONS (v6 Strict Compliance)
// ═══════════════════════════════════════════════════════════
[bb_mid, bb_top, bb_bot] = ta.bb(close, bb_len, bb_mult)

ma5_high  = ta.sma(high, ma_fast)
ma5_low   = ta.sma(low,  ma_fast)
ma10_high = ta.sma(high, ma_slow)
ma10_low  = ta.sma(low,  ma_slow)
ema50     = ta.ema(close, ema_filter)

// Perbaikan: Fungsi crossover/crossunder wajib dihitung secara global di setiap bar
cross_mid_up   = ta.crossover(close, bb_mid)
cross_mid_down = ta.crossunder(close, bb_mid)

buy_cross_low  = ta.crossover(close, ma5_low)
sell_cross_high = ta.crossunder(close, ma5_high)

// ═══════════════════════════════════════════════════════════
//  BBMA STRUCTURAL CORE LOGIC (CSAK STRICT RULES)
// ═══════════════════════════════════════════════════════════
extreme_bull = (low < bb_bot) and (ma5_low < bb_bot)
extreme_bear = (high > bb_top) and (ma5_high > bb_top)

// CSAK BUY: Menggunakan variabel global cross_mid_up
csak_buy  = (close > open) and cross_mid_up and (close > ma5_low) and (close > ma10_low)

// CSAK SELL: Menggunakan variabel global cross_mid_down
csak_sell = (close < open) and cross_mid_down and (close < ma5_high) and (close < ma10_high)

var int last_csak_dir = 0
if csak_buy
    last_csak_dir := 1
if csak_sell
    last_csak_dir := -1

// ═══════════════════════════════════════════════════════════
//  RE-ENTRY & CONFIRMED SIGNALS
// ═══════════════════════════════════════════════════════════
re_entry_buy  = (last_csak_dir == 1)  and (close > ema50) and (low <= ma10_low or low <= ma5_low) and (close > ma5_low)
re_entry_sell = (last_csak_dir == -1) and (close < ema50) and (high >= ma10_high or high >= ma5_high) and (close < ma5_high)

// Menggunakan variabel global cross untuk memicu eksekusi sinyal
buy_signal  = buy_cross_low and re_entry_buy[1]
sell_signal = sell_cross_high and re_entry_sell[1]

// ═══════════════════════════════════════════════════════════
//  PLOTS & VISUALS
// ═══════════════════════════════════════════════════════════
plot(bb_top, "BB Top", color=color.new(color.gray, 50))
plot(bb_mid, "BB Mid", color=color.new(color.orange, 40))
plot(bb_bot, "BB Bottom", color=color.new(color.gray, 50))

p_ma5_h  = plot(ma5_high, "MA 5 High", color=color.new(color.red, 30))
p_ma10_h = plot(ma10_high, "MA 10 High", color=color.new(color.maroon, 40))
fill(p_ma5_h, p_ma10_h, color=color.new(color.red, 92), title="Bearish Zone")

p_ma5_l  = plot(ma5_low, "MA 5 Low", color=color.new(color.green, 30))
p_ma10_l = plot(ma10_low, "MA 10 Low", color=color.new(color.teal, 40))
fill(p_ma5_l, p_ma10_l, color=color.new(color.green, 92), title="Bullish Zone")

plot(ema50, "EMA 50", color=color.new(color.blue, 10), linewidth=2)

plotshape(buy_signal, "BUY RE-ENTRY", shape.triangleup, location.belowbar, color=color.green, size=size.normal, text="BBMA BUY")
plotshape(sell_signal, "SELL RE-ENTRY", shape.triangledown, location.abovebar, color=color.red, size=size.normal, text="BBMA SELL")

// ═══════════════════════════════════════════════════════════
//  DYNAMIC ALERTS (v6 Engine)
// ═══════════════════════════════════════════════════════════
if buy_signal
    alert("BBMA BUY Alert!\nSymbol: " + syminfo.ticker + "\nPrice: " + str.tostring(close), alert.freq_once_per_bar_close)

if sell_signal
    alert("BBMA SELL Alert!\nSymbol: " + syminfo.ticker + "\nPrice: " + str.tostring(close), alert.freq_once_per_bar_close)

// ═══════════════════════════════════════════════════════════
//  DIAGNOSTIC DASHBOARD
// ═══════════════════════════════════════════════════════════
var table dashboard = table.new(position.top_right, 2, 4, bgcolor=color.new(color.black, 75), border_width=1, border_color=color.gray)

if barstate.islast and show_table
    trend_txt   = close > ema50 ? "BULLISH" : "BEARISH"
    trend_color = close > ema50 ? color.green : color.red
    state_txt   = buy_signal ? "BUY SIGNAL" : sell_signal ? "SELL SIGNAL" : extreme_bull or extreme_bear ? "EXTREME" : "SCANNING"
    state_color = buy_signal ? color.green : sell_signal ? color.red : color.orange
    bias_txt    = last_csak_dir == 1 ? "CSAK BUY" : last_csak_dir == -1 ? "CSAK SELL" : "NONE"
    bias_color  = last_csak_dir == 1 ? color.green : last_csak_dir == -1 ? color.red : color.gray

    table.cell(dashboard, 0, 0, "BBMA METRIC",    text_color=color.gray,   text_size=size.small)
    table.cell(dashboard, 1, 0, "VALUE / STATE",  text_color=color.gray,   text_size=size.small)
    table.cell(dashboard, 0, 1, "Macro Trend",    text_color=color.white,  text_size=size.small)
    table.cell(dashboard, 1, 1, trend_txt,        text_color=trend_color,  text_size=size.small)
    table.cell(dashboard, 0, 2, "Market State",   text_color=color.white,  text_size=size.small)
    table.cell(dashboard, 1, 2, state_txt,        text_color=state_color,  text_size=size.small)
    table.cell(dashboard, 0, 3, "Structure Bias", text_color=color.white,  text_size=size.small)
    table.cell(dashboard, 1, 3, bias_txt,         text_color=bias_color,   text_size=size.small)
````
