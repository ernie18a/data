# HTF Fractal Liquidity v1.02.1

- url: https://www.tradingview.com/script/w8WcjXll-htf-fractal-liquidity-v1-02-1/
- type: indicator
- pine_id: PUB;1546fa59cd614b78beb836656b2711dd
- version: 1.0

## Description

Liquidity Engine v1.2.1 — это профессиональный интрадей-инструмент для автоматического поиска, построения и отслеживания ключевых пулов ликвидности со старшего таймфрейма (HTF) прямо на вашем рабочем графике.

## Source Code

````pine
//@version=5
indicator("HTF Fractal Liquidity v1.02.1", overlay=true, max_lines_count=500, max_labels_count=500)

// ==========================================
// НАСТРОЙКИ / ВХОДНЫЕ ПАРАМЕТРЫ
// ==========================================
var string G_MAIN = "Основные настройки"
htf_tf        = input.timeframe("240", title="Старший таймфрейм (HTF)", group=G_MAIN)
eql_ticks     = input.int(20, title="Порог объединения в EQL/EQH (в тиках)", minval=0, group=G_MAIN)
bsl_color     = input.color(color.green, title="Цвет BSL (Buyside)", group=G_MAIN)
ssl_color     = input.color(color.red, title="Цвет SSL (Sellside)", group=G_MAIN)

var string G_VIS = "Настройки смещения и визуализации (v1.02.1)"
broken_style  = input.string("Пунктир (Dotted)", title="Стиль снятой ликвидности", options=["Пунктир (Dotted)", "Штрих (Dashed)", "Скрывать"], group=G_VIS)
broken_color  = input.color(color.gray, title="Цвет снятой ликвидности", group=G_VIS)
offset_sweep  = input.int(2, title="Отступ Свипа ЗА свечу (бары LTF)", minval=0, group=G_VIS)
offset_break  = input.int(1, title="Отступ Пробоя ДО свечи (бары LTF)", minval=0, group=G_VIS)

// Расчет порога для равных уровней
eql_threshold = eql_ticks * syminfo.mintick

// ==========================================
// ФОРМАТИРОВАНИЕ ТФ ДЛЯ ПОДПИСЕЙ
// ==========================================
get_tf_string(tf) =>
    str_res = tf
    if tf == "60" or tf == "1H"
        str_res := "1H"
    else if tf == "120"
        str_res := "2H"
    else if tf == "180"
        str_res := "3H"
    else if tf == "240" or tf == "4H"
        str_res := "4H"
    else if tf == "D" or tf == "1D"
        str_res := "1D"
    else if tf == "W" or tf == "1W"
        str_res := "1W"
    else if tf == "M" or tf == "1M"
        str_res := "1M"
    else
        str_res := tf + "M"
    str_res

tf_prefix = get_tf_string(htf_tf)

// Фильтр отображения (скрываем графику на ТФ, которые старше выбранного HTF)
is_allowed_tf = timeframe.in_seconds() <= timeframe.in_seconds(htf_tf)

// ==========================================
// ДАННЫЕ СТАРШИХ ТФ ДЛЯ ПРОВЕРКИ СОВПАДЕНИЙ
// ==========================================
[pdh, pdl] = request.security(syminfo.tickerid, "D", [high[1], low[1]], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
[pwh, pwl] = request.security(syminfo.tickerid, "W", [high[1], low[1]], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
[pmh, pml] = request.security(syminfo.tickerid, "M", [high[1], low[1]], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)

// ==========================================
// ЛОГИКА ОПРЕДЕЛЕНИЯ ФРАКТАЛОВ НА HTF
// ==========================================
get_fractals() =>
    ph = ta.pivothigh(high, 2, 2)
    pl = ta.pivotlow(low, 2, 2)
    
    ph_breached = not na(ph) and (high[1] >= ph or high[0] >= ph)
    pl_breached = not na(pl) and (low[1] <= pl or low[0] <= pl)
    
    valid_ph = not na(ph) and not ph_breached ? ph : na
    valid_pl = not na(pl) and not pl_breached ? pl : na
    
    ph_time = not na(valid_ph) ? time[2] : na
    pl_time = not na(valid_pl) ? time[2] : na
    [valid_ph, ph_time, valid_pl, pl_time]

[ph_val, ph_time, pl_val, pl_time] = request.security(
     syminfo.tickerid, 
     htf_tf, 
     get_fractals(), 
     gaps=barmerge.gaps_on, 
     lookahead=barmerge.lookahead_off
 )

// ==========================================
// МАССИВЫ ДЛЯ ДИНАМИЧЕСКОГО ОТСЛЕЖИВАНИЯ
// ==========================================
var line[] active_bsl_lines = array.new_line()
var label[] active_bsl_labels = array.new_label()
var float[] active_bsl_prices = array.new_float()
var int[] active_bsl_states = array.new_int()       
var int[] active_bsl_htf_times = array.new_int()   
var int[] active_bsl_brk_times = array.new_int()   
var int[] active_bsl_types = array.new_int()       

var line[] active_ssl_lines = array.new_line()
var label[] active_ssl_labels = array.new_label()
var float[] active_ssl_prices = array.new_float()
var int[] active_ssl_states = array.new_int()       
var int[] active_ssl_htf_times = array.new_int()   
var int[] active_ssl_brk_times = array.new_int()   
var int[] active_ssl_types = array.new_int()       

get_line_style(style_str) =>
    style_str == "Пунктир (Dotted)" ? line.style_dotted : style_str == "Штрих (Dashed)" ? line.style_dashed : line.style_solid

// Фиксация изменения свечей старшего ТФ
htf_change = ta.change(time(htf_tf))

// Вычисление точной длительности одной свечи текущего ТФ в миллисекундах
bar_duration = int(ta.cum(time - time[1]) / bar_index)

// ==========================================
// ОБРАБОТКА УРОВНЕЙ И СВЕЧЕЙ
// ==========================================

// 1. Создание BSL / EQL H
if is_allowed_tf and not na(ph_val)
    bool bsl_merged = false
    if array.size(active_bsl_lines) > 0
        for i = 0 to array.size(active_bsl_lines) - 1
            existing_p = array.get(active_bsl_prices, i)
            existing_st = array.get(active_bsl_states, i)
            
            if existing_st == 0 and math.abs(ph_val - existing_p) <= eql_threshold
                furthest_p = math.max(ph_val, existing_p)
                l = array.get(active_bsl_lines, i)
                lbl = array.get(active_bsl_labels, i)
                
                line.set_y1(l, furthest_p)
                line.set_y2(l, furthest_p)
                label.set_y(lbl, furthest_p)
                
                array.set(active_bsl_prices, i, furthest_p)
                array.set(active_bsl_types, i, 1) 
                bsl_merged := true
                break
                
    if not bsl_merged
        newline = line.new(x1=ph_time, y1=ph_val, x2=time, y2=ph_val, xloc=xloc.bar_time, color=bsl_color, width=1, style=line.style_solid)
        newlabel = label.new(x=time, y=ph_val, text=tf_prefix + " BSL", xloc=xloc.bar_time, color=color.new(color.white, 100), style=label.style_label_down, textcolor=bsl_color, size=size.small)
        array.push(active_bsl_lines, newline)
        array.push(active_bsl_labels, newlabel)
        array.push(active_bsl_prices, ph_val)
        array.push(active_bsl_states, 0)
        array.push(active_bsl_htf_times, 0)
        array.push(active_bsl_brk_times, 0)
        array.push(active_bsl_types, 0)

// 2. Создание SSL / EQL L
if is_allowed_tf and not na(pl_val)
    bool ssl_merged = false
    if array.size(active_ssl_lines) > 0
        for i = 0 to array.size(active_ssl_lines) - 1
            existing_p = array.get(active_ssl_prices, i)
            existing_st = array.get(active_ssl_states, i)
            
            if existing_st == 0 and math.abs(pl_val - existing_p) <= eql_threshold
                furthest_p = math.min(pl_val, existing_p)
                l = array.get(active_ssl_lines, i)
                lbl = array.get(active_ssl_labels, i)
                
                line.set_y1(l, furthest_p)
                line.set_y2(l, furthest_p)
                label.set_y(lbl, furthest_p)
                
                array.set(active_ssl_prices, i, furthest_p)
                array.set(active_ssl_types, i, 1) 
                ssl_merged := true
                break

    if not ssl_merged
        newline = line.new(x1=pl_time, y1=pl_val, x2=time, y2=pl_val, xloc=xloc.bar_time, color=ssl_color, width=1, style=line.style_solid)
        newlabel = label.new(x=time, y=pl_val, text=tf_prefix + " SSL", xloc=xloc.bar_time, color=color.new(color.white, 100), style=label.style_label_up, textcolor=ssl_color, size=size.small)
        array.push(active_ssl_lines, newline)
        array.push(active_ssl_labels, newlabel)
        array.push(active_ssl_prices, pl_val)
        array.push(active_ssl_states, 0)
        array.push(active_ssl_htf_times, 0)
        array.push(active_ssl_brk_times, 0)
        array.push(active_ssl_types, 0)

// 3. Отслеживание и проверка закрытия для BSL (Верхняя ликвидность)
if is_allowed_tf and array.size(active_bsl_lines) > 0
    for i = array.size(active_bsl_lines) - 1 to 0 by 1
        l = array.get(active_bsl_lines, i)
        lbl = array.get(active_bsl_labels, i)
        p = array.get(active_bsl_prices, i)
        st = array.get(active_bsl_states, i)
        htf_t = array.get(active_bsl_htf_times, i)
        brk_t = array.get(active_bsl_brk_times, i)
        t_type = array.get(active_bsl_types, i)
        
        string display_text = t_type == 1 ? tf_prefix + " EQL H" : tf_prefix + " BSL"
        if not na(pdh) and math.abs(p - pdh) <= eql_threshold
            display_text := display_text + " / PDH"
        if not na(pwh) and math.abs(p - pwh) <= eql_threshold
            display_text := display_text + " / PWH"
        if not na(pmh) and math.abs(p - pmh) <= eql_threshold
            display_text := display_text + " / PMH"
        
        if st == 1 and htf_change and htf_t == time(htf_tf)[1]
            if close[1] > p 
                int break_target_time = brk_t - (offset_break * bar_duration)
                line.set_style(l, line.style_arrow_right)
                line.set_color(l, bsl_color)
                line.set_x2(l, break_target_time)
                label.delete(lbl)
            else // СВИП ФИТИЛЕМ (v1.02.1 - сохраняем оригинальное имя ликвидности вместо "X")
                if broken_style == "Скрывать"
                    line.delete(l)
                    label.delete(lbl)
                else
                    int sweep_target_time = time + (offset_sweep * bar_duration)
                    line.set_style(l, get_line_style(broken_style))
                    line.set_color(l, broken_color)
                    line.set_x2(l, sweep_target_time)
                    
                    label.set_x(lbl, sweep_target_time)
                    label.set_style(lbl, label.style_label_down) 
                    label.set_textcolor(lbl, broken_color)
                    label.set_y(lbl, p) 
                    label.set_text(lbl, display_text) // Текст ликвидности сохранен
            
            array.remove(active_bsl_lines, i)
            array.remove(active_bsl_labels, i)
            array.remove(active_bsl_prices, i)
            array.remove(active_bsl_states, i)
            array.remove(active_bsl_htf_times, i)
            array.remove(active_bsl_brk_times, i)
            array.remove(active_bsl_types, i)
            continue
            
        if st == 0
            if high >= p 
                array.set(active_bsl_states, i, 1)
                array.set(active_bsl_htf_times, i, time(htf_tf))
                array.set(active_bsl_brk_times, i, time[1])
                
                int sweep_target_time = time + (offset_sweep * bar_duration)
                line.set_style(l, get_line_style(broken_style))
                line.set_color(l, broken_color)
                line.set_x2(l, sweep_target_time)
                
                label.set_text(lbl, display_text) // В моменте касания текст тоже удерживается
                label.set_style(lbl, label.style_label_down) 
                label.set_textcolor(lbl, broken_color)
                label.set_y(lbl, p)
                label.set_x(lbl, sweep_target_time)
            else
                line.set_x2(l, time)
                label.set_x(lbl, time)
                label.set_text(lbl, display_text) 
        else if st == 1
            int sweep_target_time = time + (offset_sweep * bar_duration)
            line.set_x2(l, sweep_target_time)
            label.set_x(lbl, sweep_target_time)
            label.set_y(lbl, p)

// 4. Отслеживание и проверка закрытия для SSL (Нижняя ликвидность)
if is_allowed_tf and array.size(active_ssl_lines) > 0
    for i = array.size(active_ssl_lines) - 1 to 0 by 1
        l = array.get(active_ssl_lines, i)
        lbl = array.get(active_ssl_labels, i)
        p = array.get(active_ssl_prices, i)
        st = array.get(active_ssl_states, i)
        htf_t = array.get(active_ssl_htf_times, i)
        brk_t = array.get(active_ssl_brk_times, i)
        t_type = array.get(active_ssl_types, i)
        
        string display_text = t_type == 1 ? tf_prefix + " EQL L" : tf_prefix + " SSL"
        if not na(pdl) and math.abs(p - pdl) <= eql_threshold
            display_text := display_text + " / PDL"
        if not na(pwl) and math.abs(p - pwl) <= eql_threshold
            display_text := display_text + " / PWL"
        if not na(pml) and math.abs(p - pml) <= eql_threshold
            display_text := display_text + " / PML"
        
        if st == 1 and htf_change and htf_t == time(htf_tf)[1]
            if close[1] < p 
                int break_target_time = brk_t - (offset_break * bar_duration)
                line.set_style(l, line.style_arrow_right)
                line.set_color(l, ssl_color)
                line.set_x2(l, break_target_time)
                label.delete(lbl)
            else // СВИП ФИТИЛЕМ (v1.02.1 - сохраняем оригинальное имя ликвидности вместо "X")
                if broken_style == "Скрывать"
                    line.delete(l)
                    label.delete(lbl)
                else
                    int sweep_target_time = time + (offset_sweep * bar_duration)
                    line.set_style(l, get_line_style(broken_style))
                    line.set_color(l, broken_color)
                    line.set_x2(l, sweep_target_time)
                    
                    label.set_x(lbl, sweep_target_time)
                    label.set_style(lbl, label.style_label_up) 
                    label.set_textcolor(lbl, broken_color)
                    label.set_y(lbl, p)
                    label.set_text(lbl, display_text) // Текст ликвидности сохранен
            
            array.remove(active_ssl_lines, i)
            array.remove(active_ssl_labels, i)
            array.remove(active_ssl_prices, i)
            array.remove(active_ssl_states, i)
            array.remove(active_ssl_htf_times, i)
            array.remove(active_ssl_brk_times, i)
            array.remove(active_ssl_types, i)
            continue
            
        if st == 0
            if low <= p
                array.set(active_ssl_states, i, 1)
                array.set(active_ssl_htf_times, i, time(htf_tf))
                array.set(active_ssl_brk_times, i, time[1])
                
                int sweep_target_time = time + (offset_sweep * bar_duration)
                line.set_style(l, get_line_style(broken_style))
                line.set_color(l, broken_color)
                line.set_x2(l, sweep_target_time)
                
                label.set_text(lbl, display_text) // В моменте касания текст тоже удерживается
                label.set_style(lbl, label.style_label_up) 
                label.set_textcolor(lbl, broken_color)
                label.set_y(lbl, p)
                label.set_x(lbl, sweep_target_time)
            else
                line.set_x2(l, time)
                label.set_x(lbl, time)
                label.set_text(lbl, display_text) 
        else if st == 1
            int sweep_target_time = time + (offset_sweep * bar_duration)
            line.set_x2(l, sweep_target_time)
            label.set_x(lbl, sweep_target_time)
            label.set_y(lbl, p)
````
