# IS Ghostbusters - Visual Session Levels & Auto-Hedge Logic

- url: https://www.tradingview.com/script/71PD2Ian/
- type: indicator
- pine_id: PUB;b5303c0537ad4bfc8eeeec375f3d3a1a
- version: 2.0

## Description

Ghostbusters is a visual execution tool designed for traders who operate based on fixed intraday levels and seek disciplined risk management. The script does more than just project entry, stop loss, and take profit levels; it acts as a real-time session monitor, validating executions and automatically managing hedge operations.  
+1

Key Features:
Precision "Touch" Detection: Unlike standard indicators that wait for a candle to close, Ghostbusters uses intrabar prices (High/Low) to detect the exact moment price touches a level, ensuring surgical precision for entries and exits.  

"One-Shot" Logic: To prevent overtrading, the script validates only the first outcome of the day. Once a TP or SL is hit, the indicator locks until the next configured session.  
+1

Automatic Hedge System: If the initial trade hits the Stop Loss, the script automatically activates a violet-colored hedge radar. It calculates a new entry at the failure point, sets the Stop Loss at the original entry price, and calculates a reduced Take Profit (50% of the original range) to seek a quick technical recovery.  
+1

Adaptable Professional UI:

Smart Contrast: Labels automatically change color based on your chart background (light or dark) to ensure total readability.  

Level Table: Includes a dynamic table in the bottom corner that organizes SELL, BUY, and Hedge values.  

Synchronized Infinite Lines: Uses line objects that span the entire chart, maintaining perfect synchronization with the price scale when zooming or scrolling.  

How to Use It:
Configure Levels: Manually enter your Entry, SL, and TP levels for both BUY and SELL scenarios.  

Session Control: Define your session start time. The script will ignore any prior movement and place a yellow "START" circle on the starting candle.  
+1

Execution: Monitor the visual signals:

▲/▼ OPEN: Confirmed Entry.  

✔️ TP: Target Reached.  

X SL: Stop Loss Hit.  

🟣 OPEN HEDGE: Hedge activation after an initial SL.  

Technical Notes:
Written in Pine Script v6.  

Optimized to keep the chart clean by avoiding unnecessary data points, maintaining a professional aesthetic.  

Disclaimer: This script is a visualization and manual trading aid. It does not constitute financial advice or guarantee profits. Use at your own risk.

## Source Code

````pine
//@version=6
indicator("IS Ghostbusters - Final Stable", overlay=true, max_labels_count=500, max_lines_count=500)

// --- FUNCIONES DE DIBUJO ---
f_draw_dynamic_line(price, col, style) =>
    var line l = na
    if price > 0
        line.delete(l)
        l := line.new(bar_index - 1000, price, bar_index + 100, price, xloc.bar_index, extend.right, col, style, 2)

f_lab(p, t, c, s, tc, offset) => 
    p > 0 and s ? label.new(bar_index + offset, p, t, color=c, style=label.style_label_left, textcolor=tc, size=size.small) : na

// --- CONFIGURACIÓN SELL/BUY ---
gp1 = "👻 Set Ghostbusters 1 (SELL)"
sell_entry = input.float(0.0, "SELL Entrada", inline="s1", group=gp1)
show_sell_ent = input.bool(true, "Etiqueta", inline="s1", group=gp1)
sell_sl = input.float(0.0, "SELL SL", inline="s2", group=gp1)
show_sell_sl = input.bool(true, "Etiqueta", inline="s2", group=gp1)
sell_tp = input.float(0.0, "SELL TP", inline="s3", group=gp1)
show_sell_tp = input.bool(true, "Etiqueta", inline="s3", group=gp1)
col_sell = input.color(color.orange, "Color SELL", group=gp1)

gp2 = "👻 Set Ghostbusters 2 (BUY)"
buy_entry = input.float(0.0, "BUY Entrada", inline="b1", group=gp2)
show_buy_ent = input.bool(true, "Etiqueta", inline="b1", group=gp2)
buy_sl = input.float(0.0, "BUY SL", inline="b2", group=gp2)
show_buy_sl = input.bool(true, "Etiqueta", inline="b2", group=gp2)
buy_tp = input.float(0.0, "BUY TP", inline="b3", group=gp2)
show_buy_tp = input.bool(true, "Etiqueta", inline="b3", group=gp2)
col_buy = input.color(color.aqua, "Color BUY", group=gp2)

// --- CONFIGURACIÓN COBERTURA ---
gp_hedge = "🟣 Operación Cobertura"
use_hedge = input.bool(true, "Activar Lógica de Cobertura", group=gp_hedge)
col_hedge = color.purple 

// --- CONFIGURACIÓN DE HORARIO ---
gp_time = "🕒 Control de Sesión"
use_time_control = input.bool(false, "Activar Control de Horario", group=gp_time)
start_time_input = input.time(timestamp("2026-04-23 12:15"), "Hora de Inicio", group=gp_time)

// --- CONFIGURACIÓN VISUAL ---
gp3 = "📊 Visualización"
show_table = input.bool(true, "Mostrar Tabla de Valores", group=gp3)
text_c = chart.bg_color == color.white or color.r(chart.bg_color) > 200 ? color.black : color.white

// --- LÓGICA DE ESTADO ---
var bool in_trade = false
var bool trade_is_sell = false 
var bool day_finished = false
var bool hedge_active = false
var bool hedge_finished = false
var float h_ent = 0.0
var float h_sl = 0.0
var float h_tp = 0.0

isStartBar = use_time_control and time >= start_time_input and time[1] < start_time_input

if isStartBar
    in_trade := false, day_finished := false, hedge_active := false, hedge_finished := false
    h_ent := 0.0, h_sl := 0.0, h_tp := 0.0

currentTimeValid = use_time_control and time >= start_time_input and not day_finished

// --- GESTIÓN DE ENTRADAS ---
if currentTimeValid and not in_trade
    if sell_entry > 0 and low <= sell_entry
        in_trade := true, trade_is_sell := true
        label.new(bar_index, high, "▼ OPEN", style=label.style_label_down, color=col_sell, textcolor=text_c)
    else if buy_entry > 0 and high >= buy_entry
        in_trade := true, trade_is_sell := false
        label.new(bar_index, low, "▲ OPEN", style=label.style_label_up, color=col_buy, textcolor=text_c)

// --- SALIDAS Y ACTIVACIÓN COBERTURA ---
if in_trade and not day_finished
    if trade_is_sell
        if high >= sell_sl
            label.new(bar_index, high, "X SL", style=label.style_label_down, color=color.red, textcolor=color.white)
            in_trade := false
            if use_hedge
                hedge_active := true, h_ent := sell_sl, h_sl := sell_entry
                h_tp := sell_sl + (math.abs(sell_sl - sell_tp) / 2)
            else
                day_finished := true
        else if low <= sell_tp
            label.new(bar_index, low, "✔️ TP", style=label.style_label_up, color=color.green, textcolor=color.white)
            in_trade := false, day_finished := true
    else 
        if low <= buy_sl
            label.new(bar_index, low, "X SL", style=label.style_label_up, color=color.red, textcolor=color.white)
            in_trade := false
            if use_hedge
                hedge_active := true, h_ent := buy_sl, h_sl := buy_entry
                h_tp := buy_sl - (math.abs(buy_sl - buy_tp) / 2)
            else
                day_finished := true
        else if high >= buy_tp
            label.new(bar_index, high, "✔️ TP", style=label.style_label_down, color=color.green, textcolor=color.white)
            in_trade := false, day_finished := true

// --- LÓGICA COBERTURA ---
if hedge_active and not hedge_finished
    if (trade_is_sell and high >= h_ent) or (not trade_is_sell and low <= h_ent)
        label.new(bar_index, trade_is_sell ? high : low, "🟣 OPEN HEDGE", style=trade_is_sell ? label.style_label_up : label.style_label_down, color=col_hedge, textcolor=color.white)
    
    if trade_is_sell
        if high >= h_tp
            label.new(bar_index, high, "✔️ TP HEDGE", style=label.style_label_down, color=col_hedge, textcolor=color.white)
            hedge_finished := true, day_finished := true
        else if low <= h_sl
            label.new(bar_index, low, "X SL HEDGE", style=label.style_label_up, color=col_hedge, textcolor=color.white)
            hedge_finished := true, day_finished := true
    else 
        if low <= h_tp
            label.new(bar_index, low, "✔️ TP HEDGE", style=label.style_label_up, color=col_hedge, textcolor=color.white)
            hedge_finished := true, day_finished := true
        else if high >= h_sl
            label.new(bar_index, high, "X SL HEDGE", style=label.style_label_down, color=col_hedge, textcolor=color.white)
            hedge_finished := true, day_finished := true

// --- DIBUJADO FINAL ---
plotshape(isStartBar, "START", shape.circle, location.belowbar, color.yellow, 0, "START", color.black, true, size.small)

if barstate.islast
    f_draw_dynamic_line(sell_entry, col_sell, line.style_solid)
    f_draw_dynamic_line(sell_sl, color.red, line.style_dotted)
    f_draw_dynamic_line(sell_tp, color.green, line.style_dotted)
    f_draw_dynamic_line(buy_entry, col_buy, line.style_solid)
    f_draw_dynamic_line(buy_sl, color.red, line.style_dotted)
    f_draw_dynamic_line(buy_tp, color.green, line.style_dotted)

    f_lab(sell_sl, "SELL SL", color.red, show_sell_sl, color.white, 4)
    f_lab(sell_tp, "SELL TP", color.green, show_sell_tp, color.white, 4)
    f_lab(buy_sl, "BUY SL", color.red, show_buy_sl, color.white, 4)
    f_lab(buy_tp, "BUY TP", color.green, show_buy_tp, color.white, 4)
    f_lab(sell_entry, "SELL Ent", col_sell, show_sell_ent, text_c, 2)
    f_lab(buy_entry, "BUY Ent", col_buy, show_buy_ent, text_c, 2)

    if hedge_active
        f_draw_dynamic_line(h_sl, col_hedge, line.style_dashed)
        f_draw_dynamic_line(h_tp, col_hedge, line.style_dashed)
        f_lab(h_sl, "HEDGE SL", col_hedge, true, color.white, 6)
        f_lab(h_tp, "HEDGE TP", col_hedge, true, color.white, 6)

    if show_table
        color t_txt = chart.fg_color
        var info_table = table.new(position.bottom_right, 4, 4, border_width=1, border_color=color.new(color.gray, 70))
        
        table.cell(info_table, 0, 0, "NIVELES", bgcolor=color.new(color.gray, 50), text_color=t_txt, text_size=size.small)
        table.cell(info_table, 1, 0, "SELL", bgcolor=color.new(col_sell, 60), text_color=t_txt, text_size=size.small)
        table.cell(info_table, 2, 0, "BUY", bgcolor=color.new(col_buy, 60), text_color=t_txt, text_size=size.small)
        table.cell(info_table, 3, 0, "HEDGE", bgcolor=hedge_active ? color.new(col_hedge, 60) : color.new(color.gray, 20), text_color=t_txt, text_size=size.small)
        
        table.cell(info_table, 0, 1, "ENTRADA", bgcolor=color.new(color.gray, 50), text_color=t_txt, text_halign=text.align_left, text_size=size.small)
        table.cell(info_table, 1, 1, str.tostring(sell_entry), text_color=t_txt)
        table.cell(info_table, 2, 1, str.tostring(buy_entry), text_color=t_txt)
        table.cell(info_table, 3, 1, hedge_active ? str.tostring(h_ent) : "-", text_color=t_txt)
        
        table.cell(info_table, 0, 2, "STOP LOSS", bgcolor=color.new(color.gray, 50), text_color=t_txt, text_halign=text.align_left, text_size=size.small)
        table.cell(info_table, 1, 2, str.tostring(sell_sl), text_color=t_txt)
        table.cell(info_table, 2, 2, str.tostring(buy_sl), text_color=t_txt)
        table.cell(info_table, 3, 2, hedge_active ? str.tostring(h_sl) : "-", text_color=t_txt)
        
        table.cell(info_table, 0, 3, "TAKE PROFIT", bgcolor=color.new(color.gray, 50), text_color=t_txt, text_halign=text.align_left, text_size=size.small)
        table.cell(info_table, 1, 3, str.tostring(sell_tp), text_color=t_txt)
        table.cell(info_table, 2, 3, str.tostring(buy_tp), text_color=t_txt)
        table.cell(info_table, 3, 3, hedge_active ? str.tostring(h_tp) : "-", text_color=t_txt)
````
