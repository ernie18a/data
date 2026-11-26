# TCC

- url: https://www.tradingview.com/script/IyyamLNL-tcc/
- type: indicator
- pine_id: PUB;bd0bb53e9a9e44969a456d937e863c32
- version: 1.0

## Description

Timer until the candle closes
Timer until the candle closes
Timer until the candle closes
Timer until the candle closes
Timer until the candle closes

## Source Code

````pine
//@version=5
indicator("MTF Таймеры до закрытия свечи", overlay=true, precision=0)

// =========================================================================
// 1. НАСТРОЙКИ (INPUTS)
// =========================================================================

grp_tf = "Выбор таймфреймов"
show_1m  = input.bool(true, "1 Минута",  group=grp_tf)
show_3m  = input.bool(true, "3 Минуты",  group=grp_tf)
show_5m  = input.bool(true, "5 Минут",   group=grp_tf)
show_15m = input.bool(true, "15 Минут",  group=grp_tf)
show_30m = input.bool(true, "30 Минут",  group=grp_tf)
show_1h  = input.bool(true, "1 Час",     group=grp_tf)
show_4h  = input.bool(true, "4 Часа",    group=grp_tf)

grp_ui = "Настройки отображения (Таблица)"
pos_str = input.string("Внизу справа", "Расположение таблицы",
  options=["Вверху слева", "Вверху по центру", "Вверху справа", 
           "Посередине слева", "Посередине по центру", "Посередине справа", 
           "Внизу слева", "Внизу по центру", "Внизу справа"], group=grp_ui)

bg_color    = input.color(color.new(color.black, 40), "Цвет фона таблицы", group=grp_ui)
text_color  = input.color(color.white, "Стандартный цвет текста", group=grp_ui)
alert_color = input.color(color.red, "Цвет текста (осталась < 1 мин)", group=grp_ui)
border_col  = input.color(color.new(color.gray, 60), "Цвет границ", group=grp_ui)
txt_size    = input.string("Обычный", "Размер текста", 
  options=["Очень маленький", "Маленький", "Обычный", "Большой"], group=grp_ui)

// =========================================================================
// 2. ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ (FUNCTIONS)
// =========================================================================

f_get_pos(p) =>
    p == "Вверху слева"         ? position.top_left      :
     p == "Вверху по центру"    ? position.top_center    :
     p == "Вверху справа"       ? position.top_right     :
     p == "Посередине слева"    ? position.middle_left   :
     p == "Посередине по центру"? position.middle_center :
     p == "Посередине справа"   ? position.middle_right  :
     p == "Внизу слева"         ? position.bottom_left   :
     p == "Внизу по центру"     ? position.bottom_center : 
     position.bottom_right

f_get_size(s) =>
    s == "Очень маленький" ? size.tiny   :
     s == "Маленький"      ? size.small  :
     s == "Обычный"        ? size.normal : 
     size.large

f_format_time(int ms) =>
    if na(ms) or ms <= 0
        "00:00:00"
    else
        int s = math.floor(ms / 1000) % 60
        int m = math.floor(ms / 60000) % 60
        int h = math.floor(ms / 3600000)
        str.format("{0,number,00}:{1,number,00}:{2,number,00}", h, m, s)

// ГЛАВНАЯ ФУНКЦИЯ: Математический расчет времени для любого таймфрейма
// Независимо от того, какой график открыт, таймер будет считаться правильно
f_get_remaining_time(int tf_minutes) =>
    int ms_per_tf = tf_minutes * 60000
    // Получаем начало текущего дня для правильного выравнивания по сессиям биржи
    int day_start = time("D")
    int base = na(day_start) ? 0 : day_start
    int elapsed = math.max(0, timenow - base)
    // Вычисляем остаток времени
    int rem = ms_per_tf - (elapsed % ms_per_tf)
    rem

// =========================================================================
// 3. ИНИЦИАЛИЗАЦИЯ ТАБЛИЦЫ
// =========================================================================

num_rows = (show_1m ? 1 : 0) + (show_3m ? 1 : 0) + (show_5m ? 1 : 0) + 
           (show_15m ? 1 : 0) + (show_30m ? 1 : 0) + (show_1h ? 1 : 0) + (show_4h ? 1 : 0)

var table tb = table.new(
  position     = f_get_pos(pos_str), 
  columns      = 2, 
  rows         = math.max(num_rows, 1), 
  bgcolor      = bg_color, 
  border_width = 1, 
  border_color = border_col
  )

// =========================================================================
// 4. ЛОГИКА ОБНОВЛЕНИЯ ДАННЫХ (CORE LOGIC)
// =========================================================================

if barstate.islast
    int row = 0
    string sz = f_get_size(txt_size)

    if num_rows == 0
        table.cell(tb, 0, 0, "Нет выбранных ТФ", text_color=text_color, text_size=sz)
        table.cell(tb, 1, 0, "-", text_color=text_color, text_size=sz)
    else
        // --- 1м ---
        if show_1m
            int rem = f_get_remaining_time(1)
            color c = rem <= 60000 ? alert_color : text_color
            table.cell(tb, 0, row, "1m", text_color=text_color, text_size=sz, text_halign=text.align_left)
            table.cell(tb, 1, row, f_format_time(rem), text_color=c, text_size=sz, text_halign=text.align_right)
            row += 1

        // --- 3м ---
        if show_3m
            int rem = f_get_remaining_time(3)
            color c = rem <= 60000 ? alert_color : text_color
            table.cell(tb, 0, row, "3m", text_color=text_color, text_size=sz, text_halign=text.align_left)
            table.cell(tb, 1, row, f_format_time(rem), text_color=c, text_size=sz, text_halign=text.align_right)
            row += 1

        // --- 5м ---
        if show_5m
            int rem = f_get_remaining_time(5)
            color c = rem <= 60000 ? alert_color : text_color
            table.cell(tb, 0, row, "5m", text_color=text_color, text_size=sz, text_halign=text.align_left)
            table.cell(tb, 1, row, f_format_time(rem), text_color=c, text_size=sz, text_halign=text.align_right)
            row += 1

        // --- 15м ---
        if show_15m
            int rem = f_get_remaining_time(15)
            color c = rem <= 60000 ? alert_color : text_color
            table.cell(tb, 0, row, "15m", text_color=text_color, text_size=sz, text_halign=text.align_left)
            table.cell(tb, 1, row, f_format_time(rem), text_color=c, text_size=sz, text_halign=text.align_right)
            row += 1

        // --- 30м ---
        if show_30m
            int rem = f_get_remaining_time(30)
            color c = rem <= 60000 ? alert_color : text_color
            table.cell(tb, 0, row, "30m", text_color=text_color, text_size=sz, text_halign=text.align_left)
            table.cell(tb, 1, row, f_format_time(rem), text_color=c, text_size=sz, text_halign=text.align_right)
            row += 1

        // --- 1ч ---
        if show_1h
            int rem = f_get_remaining_time(60)
            color c = rem <= 60000 ? alert_color : text_color
            table.cell(tb, 0, row, "1h", text_color=text_color, text_size=sz, text_halign=text.align_left)
            table.cell(tb, 1, row, f_format_time(rem), text_color=c, text_size=sz, text_halign=text.align_right)
            row += 1

        // --- 4ч ---
        if show_4h
            int rem = f_get_remaining_time(240)
            color c = rem <= 60000 ? alert_color : text_color
            table.cell(tb, 0, row, "4h", text_color=text_color, text_size=sz, text_halign=text.align_left)
            table.cell(tb, 1, row, f_format_time(rem), text_color=c, text_size=sz, text_halign=text.align_right)
            row += 1
````
