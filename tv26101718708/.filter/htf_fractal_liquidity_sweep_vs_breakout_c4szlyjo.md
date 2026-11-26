# HTF Fractal Liquidity (Sweep vs Breakout) 

- url: https://www.tradingview.com/script/c4szLYjo-htf-fractal-liquidity-sweep-vs-breakout/
- type: indicator
- pine_id: PUB;38562dfff5bc4a8eba8b186045a6c0f1
- version: 1.0

## Description

Показывает ХТФ фрактальные ликвидности и взаимодействие цены с ними

## Source Code

````pine
//@version=5
indicator("HTF Fractal Liquidity (Sweep vs Breakout) Centered X Fix", overlay=true, max_lines_count=500, max_labels_count=500)

// ==========================================
// НАСТРОЙКИ / ВХОДНЫЕ ПАРАМЕТРЫ
// ==========================================
htf_tf        = input.timeframe("240", title="Старший таймфрейм (HTF)")
eql_ticks     = input.int(20, title="Порог объединения в EQL/EQH (в тиках)", minval=0)
bsl_color     = input.color(color.green, title="Цвет BSL (Buyside)")
ssl_color     = input.color(color.red, title="Цвет SSL (Sellside)")

// Настройки визуализации пробитых уровней
broken_style  = input.string("Пунктир (Dotted)", title="Стиль снятой ликвидности", options=["Пунктир (Dotted)", "Штрих (Dashed)", "Скрывать"])
broken_color  = input.color(color.gray, title="Цвет снятой ликвидности")

// Расчет порога для равных уровней
eql_threshold = eql_ticks * syminfo.mintick

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
var int[] active_bsl_states = array.new_int()       // 0 = активен, 1 = тестируется
var int[] active_bsl_htf_times = array.new_int()   // Время начала HTF бара пробития
var int[] active_bsl_brk_times = array.new_int()   // Точка строго ДО пробойной свечи

var line[] active_ssl_lines = array.new_line()
var label[] active_ssl_labels = array.new_label()
var float[] active_ssl_prices = array.new_float()
var int[] active_ssl_states = array.new_int()       
var int[] active_ssl_htf_times = array.new_int()   
var int[] active_ssl_brk_times = array.new_int()   

get_line_style(style_str) =>
    style_str == "Пунктир (Dotted)" ? line.style_dotted : style_str == "Штрих (Dashed)" ? line.style_dashed : line.style_solid

// Фиксация изменения свечей старшего ТФ
htf_change = ta.change(time(htf_tf))

// ==========================================
// ОБРАБОТКА УРОВНЕЙ И СВЕЧЕЙ
// ==========================================

// 1. Создание BSL / EQL H
if not na(ph_val)
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
                label.set_text(lbl, "EQL H")
                
                array.set(active_bsl_prices, i, furthest_p)
                bsl_merged := true
                break
                
    if not bsl_merged
        newline = line.new(x1=ph_time, y1=ph_val, x2=time, y2=ph_val, xloc=xloc.bar_time, color=bsl_color, width=1, style=line.style_solid)
        newlabel = label.new(x=time, y=ph_val, text="BSL", xloc=xloc.bar_time, color=color.new(color.white, 100), style=label.style_label_down, textcolor=bsl_color, size=size.small)
        array.push(active_bsl_lines, newline)
        array.push(active_bsl_labels, newlabel)
        array.push(active_bsl_prices, ph_val)
        array.push(active_bsl_states, 0)
        array.push(active_bsl_htf_times, 0)
        array.push(active_bsl_brk_times, 0)

// 2. Создание SSL / EQL L
if not na(pl_val)
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
                label.set_text(lbl, "EQL L")
                
                array.set(active_ssl_prices, i, furthest_p)
                ssl_merged := true
                break

    if not ssl_merged
        newline = line.new(x1=pl_time, y1=pl_val, x2=time, y2=pl_val, xloc=xloc.bar_time, color=ssl_color, width=1, style=line.style_solid)
        newlabel = label.new(x=time, y=pl_val, text="SSL", xloc=xloc.bar_time, color=color.new(color.white, 100), style=label.style_label_up, textcolor=ssl_color, size=size.small)
        array.push(active_ssl_lines, newline)
        array.push(active_ssl_labels, newlabel)
        array.push(active_ssl_prices, pl_val)
        array.push(active_ssl_states, 0)
        array.push(active_ssl_htf_times, 0)
        array.push(active_ssl_brk_times, 0)

// 3. Отслеживание и проверка закрытия для BSL (Верхняя ликвидность)
if array.size(active_bsl_lines) > 0
    for i = array.size(active_bsl_lines) - 1 to 0 by 1
        l = array.get(active_bsl_lines, i)
        lbl = array.get(active_bsl_labels, i)
        p = array.get(active_bsl_prices, i)
        st = array.get(active_bsl_states, i)
        htf_t = array.get(active_bsl_htf_times, i)
        brk_t = array.get(active_bsl_brk_times, i)
        
        // Переход на новую HTF свечу: фиксируем итог
        if st == 1 and htf_change and htf_t == time(htf_tf)[1]
            if close[1] > p // ИСТИННЫЙ ПРОБОЙ -> Стрелка
                line.set_style(l, line.style_arrow_right)
                line.set_color(l, bsl_color)
                line.set_x2(l, brk_t)
                label.delete(lbl)
            else // СВИП ФИТИЛЕМ -> Оставляем пунктир с "X"
                if broken_style == "Скрывать"
                    line.delete(l)
                    label.delete(lbl)
                else
                    line.set_style(l, get_line_style(broken_style))
                    line.set_color(l, broken_color)
                    line.set_x2(l, time)
                    label.set_x(lbl, time)
                    // label.style_none автоматически центрирует текст по осям X и Y
                    label.set_style(lbl, label.style_none) 
                    label.set_textcolor(lbl, broken_color)
                    label.set_y(lbl, p) 
                    label.set_text(lbl, "X")
            
            array.remove(active_bsl_lines, i)
            array.remove(active_bsl_labels, i)
            array.remove(active_bsl_prices, i)
            array.remove(active_bsl_states, i)
            array.remove(active_bsl_htf_times, i)
            array.remove(active_bsl_brk_times, i)
            continue
            
        // Пока уровень активен в текущих торгах
        if st == 0
            if high >= p // Момент первого пересечения уровня на младшем ТФ
                array.set(active_bsl_states, i, 1)
                array.set(active_bsl_htf_times, i, time(htf_tf))
                array.set(active_bsl_brk_times, i, time[1])
                
                line.set_style(l, get_line_style(broken_style))
                line.set_color(l, broken_color)
                label.set_text(lbl, "X")
                label.set_style(lbl, label.style_none) 
                label.set_textcolor(lbl, broken_color)
                label.set_y(lbl, p)
            
            line.set_x2(l, time)
            label.set_x(lbl, time)
        else if st == 1
            line.set_x2(l, time)
            label.set_x(lbl, time)
            label.set_y(lbl, p)

// 4. Отслеживание и проверка закрытия для SSL (Нижняя ликвидность)
if array.size(active_ssl_lines) > 0
    for i = array.size(active_ssl_lines) - 1 to 0 by 1
        l = array.get(active_ssl_lines, i)
        lbl = array.get(active_ssl_labels, i)
        p = array.get(active_ssl_prices, i)
        st = array.get(active_ssl_states, i)
        htf_t = array.get(active_ssl_htf_times, i)
        brk_t = array.get(active_ssl_brk_times, i)
        
        if st == 1 and htf_change and htf_t == time(htf_tf)[1]
            if close[1] < p // ИСТИННЫЙ ПРОБОЙ -> Стрелка
                line.set_style(l, line.style_arrow_right)
                line.set_color(l, ssl_color)
                line.set_x2(l, brk_t)
                label.delete(lbl)
            else // СВИП ФИТИЛЕМ -> Пунктир
                if broken_style == "Скрывать"
                    line.delete(l)
                    label.delete(lbl)
                else
                    line.set_style(l, get_line_style(broken_style))
                    line.set_color(l, broken_color)
                    line.set_x2(l, time)
                    label.set_x(lbl, time)
                    // label.style_none автоматически центрирует текст по осям X и Y
                    label.set_style(lbl, label.style_none) 
                    label.set_textcolor(lbl, broken_color)
                    label.set_y(lbl, p)
                    label.set_text(lbl, "X")
            
            array.remove(active_ssl_lines, i)
            array.remove(active_ssl_labels, i)
            array.remove(active_ssl_prices, i)
            array.remove(active_ssl_states, i)
            array.remove(active_ssl_brk_times, i)
            continue
            
        if st == 0
            if low <= p
                array.set(active_ssl_states, i, 1)
                array.set(active_ssl_htf_times, i, time(htf_tf))
                array.set(active_ssl_brk_times, i, time[1])
                
                line.set_style(l, get_line_style(broken_style))
                line.set_color(l, broken_color)
                label.set_text(lbl, "X")
                label.set_style(lbl, label.style_none) 
                label.set_textcolor(lbl, broken_color)
                label.set_y(lbl, p)
            
            line.set_x2(l, time)
            label.set_x(lbl, time)
        else if st == 1
            line.set_x2(l, time)
            label.set_x(lbl, time)
            label.set_y(lbl, p)
````
