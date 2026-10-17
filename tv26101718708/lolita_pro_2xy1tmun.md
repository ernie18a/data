# Lolita Pro

- url: https://www.tradingview.com/script/2xY1tmun/
- type: indicator
- pine_id: PUB;9ca50a5472a1450bb23f3b97f903d206
- version: 1.0

## Description

Entry Signals:

Buy Signal (🟢): Triggered when the Fast EMA crosses above the Upper Channel band, indicating strong upward momentum.

Sell Signal (🔴): Triggered when the Fast EMA crosses below the Lower Channel band, indicating strong downward momentum.

Trade Management & Visuals:

Point-Based TP/SL: Users can seamlessly enable and define exact Take Profit and Stop Loss levels based on points/ticks directly from the settings.

Target Lines: Plots visual TP (Green) and SL (Red) lines on the chart while a trade is actively running.

Hit Labels: Automatically displays chart labels when the price successfully hits the Take Profit or Stop Loss targets.

## Source Code

````pine
//@version=6
indicator("Lolita Pro", "Lolita Pro", overlay=true)

// ======================================================
// Indicator (อัปเดตสีเหลืองเข้ม)
// ======================================================
Group_MA = "MA"
length = input.int(42, minval=1, title="Length Keltner", group=Group_MA)
emaFirst = input.int(10, minval=1, title="EMA First", group=Group_MA)
emaSecond = input.int(110, minval=1, title="EMA Second", group=Group_MA)

ma = ta.ema(close, length)
rangema = ta.rma(ta.tr(true), length)
upper = ma + rangema
lower = ma - rangema

// เปลี่ยนรหัสสีเป็น #CC9900 (สีเหลืองเข้ม)
u = plot(upper, color=color.new(#CC9900, 0), title="Upper")
plot(ma, color=color.new(#CC9900, 0), title="Basis")
l = plot(lower, color=color.new(#CC9900, 0), title="Lower")
fill(u, l, color=color.new(#CC9900, 90), title="Background")

outEmaFirst = ta.ema(close, emaFirst)
plot(outEmaFirst, color=color.green, title="EMA First", linewidth=2)

outEmaSecond = ta.ema(close, emaSecond)
plot(outEmaSecond, color=color.red, title="EMA Second", linewidth=3)

// ======================================================
// Signal
// ======================================================
buy_ema = ta.crossover(outEmaFirst, upper)
sell_ema = ta.crossunder(outEmaFirst, lower)

plotshape(buy_ema, "Buy", shape.labelup, location.belowbar, color.green, text="Buy", textcolor=color.white)
plotshape(sell_ema, "Sell", shape.labeldown, location.abovebar, color.red, text="Sell", textcolor=color.white)

// ======================================================
// Setting
// ======================================================
groupAlert = "Alert"
use_tp = input.bool(true, "Use TP", group=groupAlert)
float tp_in = input.float(1000.0, "TP Point", minval=0.0, group=groupAlert)
tp_point = tp_in * syminfo.mintick

use_sl = input.bool(false, "Use SL", group=groupAlert)
float sl_in = input.float(1000.0, "SL Point", minval=0.0, group=groupAlert)
sl_point = sl_in * syminfo.mintick

show_hit = input.bool(true, "Show Label", group=groupAlert)
show_line = input.bool(true, "Show Line", group=groupAlert)

// ======================================================
// Messages
// ======================================================
tf_str(string tf) =>
    switch tf
        "1"   => "M1"
        "3"   => "M3"
        "5"   => "M5"
        "15"  => "M15"
        "30"  => "M30"
        "60"  => "H1"
        "240" => "H4"
        "D"   => "D1"
        "1D"  => "D1"
        => tf

string n = "\n"
string sep = "━━━━━━━━━━━━━━━" + n
string m_tf = "🕒 TF: " + tf_str(timeframe.period) + n
string m_pair = "💱 Pair: " + syminfo.ticker + n
string m_pr_open = str.tostring(open, format.mintick)
string m_pr_close = str.tostring(close, format.mintick)
string m_price = "💵 Price: " + m_pr_open + " - " + m_pr_close
string c_price = "💵 Price: " + m_pr_close

string msg_base = sep + m_tf + m_pair
string message_buy = "📈 Signal Alert" + n + msg_base + "🟢 Zone: Buy" + n + m_price
string message_sell = "📉 Signal Alert" + n + msg_base + "🔴 Zone: Sell" + n + m_price

string message_tp_buy = "🎯 TP Alert" + n + msg_base + "🟢 Type: TP Buy" + n + c_price
string message_sl_buy = "🛑 SL Alert" + n + msg_base + "🟢 Type: SL Buy" + n + c_price

string message_tp_sell = "🎯 TP Alert" + n + msg_base + "🔴 Type: TP Sell" + n + c_price
string message_sl_sell = "🛑 SL Alert" + n + msg_base + "🔴 Type: SL Sell" + n + c_price

// ======================================================
// Variables
// ======================================================
var bool in_buy = false
var bool in_sell = false
var float buy_entry = na
var float buy_tp = na
var float buy_sl = na
var float sell_entry = na
var float sell_tp = na
var float sell_sl = na

var int total_orders = 0
var int win_orders = 0
var int loss_orders = 0

// ======================================================
// Array Data
// ======================================================
var int max_days = 5
var array<int> a_dates = array.new_int(0)
var array<int> a_totals = array.new_int(0)
var array<int> a_wins = array.new_int(0)
var array<int> a_losses = array.new_int(0)

bool is_new_day = ta.change(time("D")) != 0
if is_new_day or barstate.isfirst
    array.push(a_dates, time)
    array.push(a_totals, 0)
    array.push(a_wins, 0)
    array.push(a_losses, 0)
    if array.size(a_dates) > max_days
        array.shift(a_dates)
        array.shift(a_totals)
        array.shift(a_wins)
        array.shift(a_losses)

update_daily(bool is_win) =>
    if array.size(a_totals) > 0
        int idx = array.size(a_totals) - 1
        int current_tot = array.get(a_totals, idx)
        array.set(a_totals, idx, current_tot + 1)
        
        if is_win
            int current_win = array.get(a_wins, idx)
            array.set(a_wins, idx, current_win + 1)
        else
            int current_loss = array.get(a_losses, idx)
            array.set(a_losses, idx, current_loss + 1)

// ======================================================
// Exit Conditions
// ======================================================
bool buy_hit_tp = in_buy and use_tp and not na(buy_tp) and high >= buy_tp
bool buy_hit_sl = in_buy and use_sl and not na(buy_sl) and low <= buy_sl

bool sell_hit_tp = in_sell and use_tp and not na(sell_tp) and low <= sell_tp
bool sell_hit_sl = in_sell and use_sl and not na(sell_sl) and high >= sell_sl

// ======================================================
// Logic
// ======================================================
if buy_hit_tp
    if show_hit
        string t = "TP Buy Hit\n@" + str.tostring(buy_tp, format.mintick)
        label.new(bar_index, high, t, style=label.style_label_down, color=color.green, textcolor=color.white)
    alert(message_tp_buy, alert.freq_once_per_bar)
    total_orders += 1
    win_orders += 1
    update_daily(true)
    in_buy := false
    buy_entry := na
    buy_tp := na
    buy_sl := na
else if buy_hit_sl
    if show_hit and use_sl
        string t = "SL Buy Hit\n@" + str.tostring(buy_sl, format.mintick)
        label.new(bar_index, low, t, style=label.style_label_up, color=color.red, textcolor=color.white)
    alert(message_sl_buy, alert.freq_once_per_bar)
    total_orders += 1
    loss_orders += 1
    update_daily(false)
    in_buy := false
    buy_entry := na
    buy_tp := na
    buy_sl := na

if sell_hit_tp
    if show_hit
        string t = "TP Sell Hit\n@" + str.tostring(sell_tp, format.mintick)
        label.new(bar_index, low, t, style=label.style_label_up, color=color.green, textcolor=color.white)
    alert(message_tp_sell, alert.freq_once_per_bar)
    total_orders += 1
    win_orders += 1
    update_daily(true)
    in_sell := false
    sell_entry := na
    sell_tp := na
    sell_sl := na
else if sell_hit_sl
    if show_hit and use_sl
        string t = "SL Sell Hit\n@" + str.tostring(sell_sl, format.mintick)
        label.new(bar_index, high, t, style=label.style_label_down, color=color.red, textcolor=color.white)
    alert(message_sl_sell, alert.freq_once_per_bar)
    total_orders += 1
    loss_orders += 1
    update_daily(false)
    in_sell := false
    sell_entry := na
    sell_tp := na
    sell_sl := na

// ======================================================
// Entry 
// ======================================================
if buy_ema and not in_buy and not in_sell
    in_buy := true
    buy_entry := close
    buy_tp := use_tp ? buy_entry + tp_point : na
    buy_sl := use_sl ? buy_entry - sl_point : na
    alert(message_buy, alert.freq_once_per_bar_close)

if sell_ema and not in_sell and not in_buy
    in_sell := true
    sell_entry := close
    sell_tp := use_tp ? sell_entry - tp_point : na
    sell_sl := use_sl ? sell_entry + sl_point : na
    alert(message_sell, alert.freq_once_per_bar_close)

// ======================================================
// TP/SL Line
// ======================================================
plot(show_line and in_buy and use_tp ? buy_tp : na, "Buy TP", color.green, style=plot.style_linebr)
plot(show_line and in_buy and use_sl ? buy_sl : na, "Buy SL", color.red, style=plot.style_linebr)
plot(show_line and in_sell and use_tp ? sell_tp : na, "Sell TP", color.green, style=plot.style_linebr)
plot(show_line and in_sell and use_sl ? sell_sl : na, "Sell SL", color.red, style=plot.style_linebr)

// ======================================================
// Dashboard
// ======================================================
var table dash = table.new(position.top_right, 5, 8, bgcolor=color.new(#131722, 10), border_width=1, border_color=color.new(#363A45, 0))

if barstate.islast
    color c_bg = color.new(#2A2E39, 0)
    color c_w = color.white
    color c_g = color.green
    color c_r = color.red
    color c_y = color.yellow
    string sz = size.small

    table.cell(dash, 0, 0, "Date", text_color=c_w, text_size=sz, bgcolor=c_bg)
    table.cell(dash, 1, 0, "Total", text_color=c_w, text_size=sz, bgcolor=c_bg)
    table.cell(dash, 2, 0, "Win", text_color=c_g, text_size=sz, bgcolor=c_bg)
    table.cell(dash, 3, 0, "Loss", text_color=c_r, text_size=sz, bgcolor=c_bg)
    table.cell(dash, 4, 0, "WR%", text_color=c_w, text_size=sz, bgcolor=c_bg)

    int t_row = 1
    int sz_arr = array.size(a_dates)
    
    if sz_arr > 0
        for i = sz_arr - 1 to 0
            int d_tot = array.get(a_totals, i)
            int d_win = array.get(a_wins, i)
            int d_loss = array.get(a_losses, i)
            float d_rate = d_tot > 0 ? (d_win / d_tot) * 100 : 0.0
            
            string date_str = str.format("{0,date,dd/MM}", array.get(a_dates, i))
            if i == sz_arr - 1
                date_str := "Today"
            
            color wr_color = d_rate >= 50 ? c_g : c_r
            
            table.cell(dash, 0, t_row, date_str, text_color=c_w, text_size=sz)
            table.cell(dash, 1, t_row, str.tostring(d_tot), text_color=c_w, text_size=sz)
            table.cell(dash, 2, t_row, str.tostring(d_win), text_color=c_g, text_size=sz)
            table.cell(dash, 3, t_row, str.tostring(d_loss), text_color=c_r, text_size=sz)
            table.cell(dash, 4, t_row, str.tostring(d_rate, "#.##") + "%", text_color=wr_color, text_size=sz)
            t_row += 1

    float all_rate = total_orders > 0 ? (win_orders / total_orders) * 100 : 0.0
    table.cell(dash, 0, t_row, "ALL-TIME", text_color=c_y, text_size=sz, bgcolor=c_bg)
    table.cell(dash, 1, t_row, str.tostring(total_orders), text_color=c_y, text_size=sz, bgcolor=c_bg)
    table.cell(dash, 2, t_row, str.tostring(win_orders), text_color=c_y, text_size=sz, bgcolor=c_bg)
    table.cell(dash, 3, t_row, str.tostring(loss_orders), text_color=c_y, text_size=sz, bgcolor=c_bg)
    table.cell(dash, 4, t_row, str.tostring(all_rate, "#.##") + "%", text_color=c_y, text_size=sz, bgcolor=c_bg)
````
