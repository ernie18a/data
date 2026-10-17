# GOOD INFINITE TRAIL Free

- url: https://www.tradingview.com/script/rtZMivwy-good-infinite-trail-free/
- type: indicator
- pine_id: PUB;caecfe9e3b0e44c4b6bff4aede215f0c
- version: 1.0

## Description

[url=https://www.tradingview.com/x/45Njb0TC/]https://www.tradingview.com/x/45Njb0TC/[/url]
What it is
Minimalist indicator for automatic position management via trailing stop. Enters with trend, exits at stop. No extra filters or complex settings.

What it does

Entry on breakout after pullback to local low or high. Exit when trailing stop is hit — stop follows price automatically. Three direction modes — auto following trend, force long or force short. Re-entry after position closes. Visual position track on chart. Trailing stop line. Info panel with current PnL, trend and settings. Phone alerts on entry and exit.

What it doesn't have

No adaptive take profit. No entry filters for volume or VFI. No trap protection. No quick exit on reversal. No time exit. Pure trailing stop mechanics only.

Who it's for

For those who want minimum settings and pure trailing stop. For traders who determine entries themselves but want automated exits. For those who don't need complex filters or adaptive targets.

For professional trading, a PRO version is available.
PRO version gives you complete position management system:

Smart take profit that adapts to market conditions

Multiple protection layers against false entries

Volume confirmation for every trade

Trap detection and quick exit

Time-based risk management

Full visual feedback on targets and volume

FREE is for trailing stop only. PRO is for professional risk management.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © GOOD_Strategy
//@version=6
indicator("♾️ GOOD INFINITE TRAIL Free", overlay=true, max_lines_count=500, max_labels_count=500)

// ==================== 🎛️ НАСТРОЙКИ ====================
trail_entry_percent = input.float(0.5, "📈 Трейлинг на вход (%)", minval=0.1, maxval=5.0, step=0.1)
trail_exit_percent = input.float(1.0, "📉 Трейлинг на выход (%)", minval=0.1, maxval=5.0, step=0.1)
direction_mode = input.string("Auto (Gold Trend)", "🎯 Направление", options=["Auto (Gold Trend)", "Force Long", "Force Short"])

allow_reentry = input.bool(true, "🔄 Повторный вход после выхода")
reentry_delay_bars = input.int(0, "⏱️ Задержка перед повтором (баров)", minval=0, maxval=10)
reentry_same_bar = input.bool(true, "📊 Повторный вход на том же баре")

// ==================== НАСТРОЙКИ GOLD TREND ====================
magic_line_period = input.int(8, "Период Magic Line", minval=2, maxval=100)
magic_line_damping = input.float(0.88, "Демпфирование", minval=0.1, maxval=1.0, step=0.01)

// ==================== НАСТРОЙКИ ВИЗУАЛИЗАЦИИ ====================
show_position_track = input.bool(true, "📊 Показывать трек позиции")
show_entry_labels = input.bool(true, "🏷️ Показывать метки входа")
show_exit_labels = input.bool(true, "🏷️ Показывать метки выхода")
show_trend_line = input.bool(true, "📉 Показывать Gold Trend линию")
show_trail_line = input.bool(true, "📊 Показывать линию трейлинг-стопа")
show_info_panel = input.bool(true, "ℹ️ Показывать инфо-панель")

color_long = input.color(color.new(#00C853, 0), "🟢 Long Color")
color_short = input.color(color.new(#D50000, 0), "🔴 Short Color")
color_neutral = input.color(color.new(#757575, 70), "⚪ Neutral Color")
color_track_long = input.color(color.new(#00C853, 30), "🟢 Track Long")
color_track_short = input.color(color.new(#D50000, 30), "🔴 Track Short")
color_trail_line = input.color(color.new(#FF9800, 0), "🟠 Trail Stop Line")
color_exit = input.color(color.new(#FF6D00, 0), "🟠 Exit Color")

// ==================== ФУНКЦИИ ====================
gold_trend_filter(float src, int length, float damping) =>
    float omega = 2.0 * math.pi / math.max(length, 2)
    float alpha = damping * omega
    float beta = math.pow(omega, 2)
    var float f1 = src
    var float f2 = src
    f1 := nz(f1[1], src) + alpha * (src - nz(f1[1], src))
    f2 := nz(f2[1], src) + beta * (f1 - nz(f2[1], src))
    f2

// ==================== РАСЧЕТ ТРЕНДА ====================
gold_trend = gold_trend_filter(close, magic_line_period, magic_line_damping)
gold_trend_rising = gold_trend > gold_trend[1]
gold_trend_falling = gold_trend < gold_trend[1]
gold_trend_neutral = not gold_trend_rising and not gold_trend_falling

// ==================== ПЕРЕМЕННЫЕ СОСТОЯНИЯ ====================
var bool in_position = false
var bool is_long = false
var float entry_price = na
var float entry_price_display = na
var int entry_bar = na
var int last_entry_bar = -999
var int last_exit_bar = -99999
var float last_pnl = na

var float trail_lowest = na
var float trail_highest = na
var float trail_stop = na
var bool entry_pending = false
var float pending_price = na
var int bars_since_entry = 0

var bool exit_fired_this_bar = false
var bool entry_fired_this_bar = false
var bool position_entered_this_bar = false

bool alert_long = false
bool alert_short = false
bool alert_trail_long = false
bool alert_trail_short = false

var line track_line = na
var line trail_line = na
var label entry_label = na
var label exit_label = na
var label pnl_label = na

// ==================== ОПРЕДЕЛЕНИЕ НАПРАВЛЕНИЯ ====================
bool trend_up = false
bool trend_down = false

if direction_mode == "Force Long"
    trend_up := true
    trend_down := false
else if direction_mode == "Force Short"
    trend_up := false
    trend_down := true
else
    trend_up := gold_trend_rising
    trend_down := gold_trend_falling

bool trend_neutral = not trend_up and not trend_down

float current_lowest_5 = ta.lowest(low, 5)
float current_highest_5 = ta.highest(high, 5)

// ==================== ЛОГИКА ВХОДА ====================
if not in_position and ((trend_up and not trend_up[1]) or (trend_down and not trend_down[1]))
    trail_lowest := na
    trail_highest := na
    entry_pending := false

if not in_position and not trend_neutral
    bool can_enter = (bar_index != last_entry_bar) or (reentry_same_bar and bar_index == last_exit_bar)
    
    if can_enter
        if trend_up and not trend_down
            if na(trail_lowest) or current_lowest_5 < trail_lowest
                trail_lowest := current_lowest_5
            
            float entry_trigger = trail_lowest * (1 + trail_entry_percent / 100)
            
            if not entry_pending and close >= entry_trigger
                entry_pending := true
                pending_price := close
        
        else if trend_down and not trend_up
            if na(trail_highest) or current_highest_5 > trail_highest
                trail_highest := current_highest_5
            
            float entry_trigger = trail_highest * (1 - trail_entry_percent / 100)
            
            if not entry_pending and close <= entry_trigger
                entry_pending := true
                pending_price := close

// ==================== ОТКРЫТИЕ ПОЗИЦИИ ====================
if entry_pending and not in_position and not position_entered_this_bar
    int bars_since_last_exit = bar_index - last_exit_bar
    bool delay_ok = bars_since_last_exit >= reentry_delay_bars or reentry_delay_bars == 0
    bool same_bar_ok = reentry_same_bar or bar_index != last_exit_bar
    
    if delay_ok and same_bar_ok
        if trend_up and not trend_down
            in_position := true
            is_long := true
            entry_price := pending_price
            entry_price_display := pending_price
            entry_bar := bar_index
            last_entry_bar := bar_index
            position_entered_this_bar := true
            entry_fired_this_bar := true
            bars_since_entry := 0
            
            alert_long := true
            alert("♾️ LONG ENTRY | {{ticker}} | {{close}}", alert.freq_once_per_bar)
            
            trail_highest := entry_price
            trail_stop := entry_price * (1 - trail_exit_percent / 100)
            
            if show_position_track
                track_line := line.new(entry_bar, entry_price, bar_index, close, color=color_track_long, width=2, style=line.style_dotted)
            if show_trail_line
                trail_line := line.new(entry_bar, trail_stop, bar_index, trail_stop, color=color_trail_line, width=1, style=line.style_dashed)
            if show_entry_labels
                entry_label := label.new(bar_index, low, "♾️ LONG\n" + str.tostring(entry_price, "#.#####"), color=color_long, textcolor=color.white, style=label.style_label_up, size=size.small)
        
        else if trend_down and not trend_up
            in_position := true
            is_long := false
            entry_price := pending_price
            entry_price_display := pending_price
            entry_bar := bar_index
            last_entry_bar := bar_index
            position_entered_this_bar := true
            entry_fired_this_bar := true
            bars_since_entry := 0
            
            alert_short := true
            alert("♾️ SHORT ENTRY | {{ticker}} | {{close}}", alert.freq_once_per_bar)
            
            trail_lowest := entry_price
            trail_stop := entry_price * (1 + trail_exit_percent / 100)
            
            if show_position_track
                track_line := line.new(entry_bar, entry_price, bar_index, close, color=color_track_short, width=2, style=line.style_dotted)
            if show_trail_line
                trail_line := line.new(entry_bar, trail_stop, bar_index, trail_stop, color=color_trail_line, width=1, style=line.style_dashed)
            if show_entry_labels
                entry_label := label.new(bar_index, high, "♾️ SHORT\n" + str.tostring(entry_price, "#.#####"), color=color_short, textcolor=color.white, style=label.style_label_down, size=size.small)
    
    entry_pending := false
    pending_price := na

// ==================== УПРАВЛЕНИЕ ПОЗИЦИЕЙ И ВЫХОД ====================
if in_position
    bars_since_entry := bar_index - entry_bar
    bool exit_allowed = bar_index > entry_bar
    float old_trail_stop = trail_stop
    
    if is_long
        if high > trail_highest
            trail_highest := high
            trail_stop := trail_highest * (1 - trail_exit_percent / 100)
        
        if show_trail_line and not na(trail_line) and old_trail_stop != trail_stop
            line.set_xy1(trail_line, entry_bar, trail_stop)
            line.set_xy2(trail_line, bar_index, trail_stop)
        
        if exit_allowed and low <= trail_stop and not exit_fired_this_bar
            float exit_price_local = trail_stop
            last_pnl := (exit_price_local - entry_price) / entry_price * 100
            last_pnl := math.round(last_pnl * 100) / 100
            exit_fired_this_bar := true
            last_exit_bar := bar_index
            
            alert_trail_long := true
            alert("♾️ TRAIL EXIT LONG | {{ticker}} | PnL: " + str.tostring(last_pnl, "#.##") + "%", alert.freq_once_per_bar)
            
            if show_exit_labels
                exit_label := label.new(bar_index, exit_price_local, "♾️ EXIT\n" + str.tostring(last_pnl, "#.##") + "%", color=color_exit, textcolor=color.white, style=label.style_label_center, size=size.small)
            
            in_position := false
            line.delete(track_line)
            track_line := na
            line.delete(trail_line)
            trail_line := na
    
    else
        if low < trail_lowest
            trail_lowest := low
            trail_stop := trail_lowest * (1 + trail_exit_percent / 100)
        
        if show_trail_line and not na(trail_line) and old_trail_stop != trail_stop
            line.set_xy1(trail_line, entry_bar, trail_stop)
            line.set_xy2(trail_line, bar_index, trail_stop)
        
        if exit_allowed and high >= trail_stop and not exit_fired_this_bar
            float exit_price_local = trail_stop
            last_pnl := (entry_price - exit_price_local) / entry_price * 100
            last_pnl := math.round(last_pnl * 100) / 100
            exit_fired_this_bar := true
            last_exit_bar := bar_index
            
            alert_trail_short := true
            alert("♾️ TRAIL EXIT SHORT | {{ticker}} | PnL: " + str.tostring(last_pnl, "#.##") + "%", alert.freq_once_per_bar)
            
            if show_exit_labels
                exit_label := label.new(bar_index, exit_price_local, "♾️ EXIT\n" + str.tostring(last_pnl, "#.##") + "%", color=color_exit, textcolor=color.white, style=label.style_label_center, size=size.small)
            
            in_position := false
            line.delete(track_line)
            track_line := na
            line.delete(trail_line)
            trail_line := na

if in_position
    if not na(track_line)
        line.set_x2(track_line, bar_index)
        line.set_y2(track_line, close)
    if show_trail_line and not na(trail_line)
        line.set_x2(trail_line, bar_index)

// ==================== PnL МЕТКА ====================
if in_position and show_position_track
    float current_pnl_val = is_long ? (close - entry_price) / entry_price * 100 : (entry_price - close) / entry_price * 100
    string pnl_text = (current_pnl_val >= 0 ? "+" : "") + str.tostring(current_pnl_val, "#.##") + "%"
    if na(pnl_label)
        pnl_label := label.new(bar_index, close, pnl_text, color=color.new(#FF6D00, 100), textcolor=color.white, style=label.style_label_center, size=size.small)
    else
        label.set_xy(pnl_label, bar_index, close)
        label.set_text(pnl_label, pnl_text)
if not in_position and not na(pnl_label)
    label.delete(pnl_label)
    pnl_label := na

// ==================== ПОВТОРНЫЙ ВХОД ====================
if not in_position and allow_reentry and not entry_pending
    int bars_since_exit = bar_index - last_exit_bar
    bool can_reenter = (bars_since_exit >= reentry_delay_bars) or (reentry_same_bar and bars_since_exit == 0)
    
    if can_reenter and not trend_neutral
        if trend_up and not trend_down
            trail_lowest := na
            trail_highest := na
        else if trend_down and not trend_up
            trail_lowest := na
            trail_highest := na

// ==================== ВИЗУАЛИЗАЦИЯ ====================
trend_color = gold_trend_rising ? color_long : gold_trend_falling ? color_short : color_neutral
plot(show_trend_line ? gold_trend : na, "Gold Trend", color=trend_color, linewidth=2, style=plot.style_stepline)

// ==================== ИНФО-ПАНЕЛЬ ====================
if show_info_panel and barstate.islast
    var table info = table.new(position.top_right, 2, 5, bgcolor=color.new(color.black, 85), border_width=1, border_color=color.gray)
    string trend_text = gold_trend_rising ? "🟢 BULLISH" : gold_trend_falling ? "🔴 BEARISH" : "⚪ NEUTRAL"
    string mode_text = direction_mode == "Force Long" ? "♾️ FORCE LONG" : direction_mode == "Force Short" ? "♾️ FORCE SHORT" : "♾️ AUTO"
    string pos_text = in_position ? (is_long ? "🟢 LONG" : "🔴 SHORT") : "⚪ NO POSITION"
    string trail_text = "In: " + str.tostring(trail_entry_percent, "#.##") + "% / Out: " + str.tostring(trail_exit_percent, "#.##") + "%"
    string pnl_display = "--"
    if in_position
        float pnl_val = is_long ? (close - entry_price) / entry_price * 100 : (entry_price - close) / entry_price * 100
        pnl_display := (pnl_val >= 0 ? "+" : "") + str.tostring(pnl_val, "#.##") + "%"
    else if not na(last_pnl)
        pnl_display := str.tostring(last_pnl, "#.##") + "%"
    color pnl_color = color.white
    if pnl_display != "--"
        string first_char = str.substring(pnl_display, 0, 1)
        if first_char == "+"
            pnl_color := color.green
        else if first_char == "-"
            pnl_color := color.red
    table.cell(info, 0, 0, mode_text, text_color=color.new(#FFD600, 0), text_size=size.small)
    table.cell(info, 1, 0, pos_text, text_color=in_position ? (is_long ? color.green : color.red) : color.gray, text_size=size.small)
    table.cell(info, 0, 1, "Trend", text_color=color.gray, text_size=size.small)
    table.cell(info, 1, 1, trend_text, text_color=trend_color, text_size=size.small)
    table.cell(info, 0, 2, "Trail", text_color=color.gray, text_size=size.small)
    table.cell(info, 1, 2, trail_text, text_color=color.white, text_size=size.small)
    table.cell(info, 0, 3, "Entry", text_color=color.gray, text_size=size.small)
    table.cell(info, 1, 3, not na(entry_price_display) ? str.tostring(entry_price_display, "#.#####") : "--", text_color=color.white, text_size=size.small)
    table.cell(info, 0, 4, "PnL", text_color=color.gray, text_size=size.small)
    table.cell(info, 1, 4, pnl_display, text_color=pnl_color, text_size=size.small)

// ==================== СБРОС ФЛАГОВ ====================
if barstate.isconfirmed
    alert_long := false
    alert_short := false
    alert_trail_long := false
    alert_trail_short := false
    exit_fired_this_bar := false
    entry_fired_this_bar := false
    position_entered_this_bar := false
````
