# Time zone

- url: https://www.tradingview.com/script/xSuNzuif-time-zone/
- type: indicator
- pine_id: PUB;da87aad711b94b3e8040a7fbc602f064
- version: 1.0

## Description

I wrote a small indicator for myself that draws time zones and it is convenient to edit them through the settings.
I've tried a lot that I didn't find inconvenient or overloaded.
Opportunities:
1 - Allocation of a time range, the one that is convenient for you in terms of currency volatility.
2 - Adjusting the color of the periods.
3 - Display in the upper right corner of the time until the close of trading according to your timings.


Maybe it will be convenient for someone, use it, share it. Over time, I will add functionality here that will improve the convenience.

--------

Написал небольшой индикатор для себя, который отрисовывает временные зоны и их удобно править через настройки.
Перепробовал множество, которые мне не показались не удобными и перегруженными.
Возможности:
1 - Выделение временного диапазона, того, который вам удобен по волатильности валют.
2 - Корректировка цвета периодов.
3 - Отображение в правом верхнем углу времени до закрытия торгов по вашим таймингам.


Может кому то будет удобно, пользуйтесь, делитесь. Со временем добавлю сюда функционала, который будет улучшать удобство.

## Source Code

````pine
//@version=6
indicator("Time zone)", overlay = true, max_lines_count = 500, max_labels_count = 500, precision = 8)

//-------------------------
// ВХОДНЫЕ ПАРАМЕТРЫ
//-------------------------

// Группа "Сессии по МСК"
groupSessions = "Сессии по МСК"
europe_start_hour  = input.int(10,  "Европа: час начала",      minval = 0,  maxval = 23, group = groupSessions)
europe_start_min   = input.int(0,   "Европа: минута начала",   minval = 0,  maxval = 59, group = groupSessions)
europe_end_hour    = input.int(13,  "Европа: час конца",       minval = 0,  maxval = 23, group = groupSessions)
europe_end_min     = input.int(0,   "Европа: минута конца",    minval = 0,  maxval = 59, group = groupSessions)
america_start_hour = input.int(16,  "Америка: час начала",     minval = 0,  maxval = 23, group = groupSessions)
america_start_min  = input.int(0,   "Америка: минута начала",  minval = 0,  maxval = 59, group = groupSessions)
america_end_hour   = input.int(17,  "Америка: час конца",      minval = 0,  maxval = 23, group = groupSessions)
america_end_min    = input.int(0,   "Америка: минута конца",   minval = 0,  maxval = 59, group = groupSessions)
timezoneInput      = input.string("Europe/Moscow", "Таймзона расчётов", options = ["Europe/Moscow", "UTC+3"], group = groupSessions)

// Группа "Визуал"
groupVisual        = "Визуал"
europe_color       = input.color(color.new(#1E90FF, 0), "Цвет Европы", group = groupVisual)
america_color      = input.color(color.new(#FF4500, 0), "Цвет Америки", group = groupVisual)
bg_transparency    = input.int(80,  "Прозрачность фона (0-100)", minval = 0, maxval = 100, group = groupVisual)
line_width         = input.int(2,   "Толщина вертикальных линий (1-4)", minval = 1, maxval = 4, group = groupVisual)
label_font_size    = input.int(12,  "Размер шрифта (лейблы/таблица)", minval = 8, maxval = 20, group = groupVisual)
table_position_str = input.string("Top Right", "Позиция таблицы", options = ["Top Left", "Top Right", "Bottom Left", "Bottom Right"], group = groupVisual)

// Группа "Ограничения"
groupLimits        = "Ограничения"
show_on_higher_tf  = input.bool(false, "Показывать на D1 и старше", group = groupLimits)

//-------------------------
// ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ
//-------------------------

// Преобразование числового размера шрифта к enum size.*
f_size_from_int(fontSize) =>
    fontSize <= 9  ? size.tiny  :
     fontSize <= 11 ? size.small :
     fontSize <= 14 ? size.normal :
     fontSize <= 17 ? size.large  :
     size.huge

// Позиция таблицы из строки
f_table_position(posStr) =>
    posStr == "Top Left"     ? position.top_left    :
     posStr == "Top Right"   ? position.top_right   :
     posStr == "Bottom Left" ? position.bottom_left :
     position.bottom_right

// Форматирование оставшегося времени в минутах в строку "Xч Yм" или "Yм"
f_format_remaining(mins) =>
    string result = ""
    if mins <= 0
        result := "0м"
    else if mins < 60
        result := str.tostring(mins) + "м"
    else
        hours   = math.floor(mins / 60)
        minsRem = mins % 60
        result := minsRem > 0 ?
             str.tostring(hours) + "ч " + str.tostring(minsRem) + "м" :
             str.tostring(hours) + "ч"
    result

// Проверка, является ли текущий ТФ дневным или старше (D/W/M и выше)
is_tf_daily_or_higher = timeframe.isdaily or timeframe.isweekly or timeframe.ismonthly

// Размер шрифта для лейблов/таблицы
label_size_enum = f_size_from_int(label_font_size)
table_pos_enum  = f_table_position(table_position_str)

//-------------------------
// ОГРАНИЧЕНИЕ ТАЙМФРЕЙМА
//-------------------------

var label higher_tf_label = na
var color bg_color = na

only_lower_tf = not show_on_higher_tf and is_tf_daily_or_higher

if only_lower_tf
    if barstate.islast
        if not na(higher_tf_label)
            label.delete(higher_tf_label)
        mid_price = (high + low) / 2.0
        higher_tf_label := label.new(
             bar_index,
             mid_price,
             "Индикатор работает только на таймфреймах ниже D1",
             style     = label.style_label_center,
             textcolor = color.red,
             size      = size.huge,
             color     = color.new(color.white, 100)
         )
    bg_color := na
else
    if not na(higher_tf_label)
        label.delete(higher_tf_label)
        higher_tf_label := na

    //-------------------------
    // РАСЧЁТ ВРЕМЕНИ В ВЫБРАННОЙ ТАЙМЗОНЕ
    //-------------------------

    bar_time_tz = time(timeframe.period, timezoneInput)

    bar_year  = year(bar_time_tz,  timezoneInput)
    bar_month = month(bar_time_tz, timezoneInput)
    bar_day   = dayofmonth(bar_time_tz, timezoneInput)

    europe_start_ts  = timestamp(timezoneInput, bar_year, bar_month, bar_day, europe_start_hour,  europe_start_min,  0)
    europe_end_ts    = timestamp(timezoneInput, bar_year, bar_month, bar_day, europe_end_hour,    europe_end_min,    0)
    america_start_ts = timestamp(timezoneInput, bar_year, bar_month, bar_day, america_start_hour, america_start_min, 0)
    america_end_ts   = timestamp(timezoneInput, bar_year, bar_month, bar_day, america_end_hour,   america_end_min,   0)

    in_europe_raw  = bar_time_tz >= europe_start_ts  and bar_time_tz < europe_end_ts
    in_america_raw = bar_time_tz >= america_start_ts and bar_time_tz < america_end_ts

    in_europe  = in_europe_raw
    in_america = not in_europe and in_america_raw

    //-------------------------
    // ФОН ПО СЕССИЯМ
    //-------------------------

    bg_color :=
         in_europe  ? color.new(europe_color, bg_transparency) :
         in_america ? color.new(america_color, bg_transparency) :
         na

    //-------------------------
    // ЛИНИИ И ЛЕЙБЛЫ СТАРТА/КОНЦА СЕССИЙ
    //-------------------------

    var line[]  europe_lines   = array.new_line()
    var line[]  america_lines  = array.new_line()
    var label[] session_labels = array.new_label()

    thirty_days_ms    = 30 * 24 * 60 * 60 * 1000
    recent_limit_time = timenow - thirty_days_ms

    was_in_europe  = bar_index > 0 ? in_europe[1]  : false
    was_in_america = bar_index > 0 ? in_america[1] : false

    europe_session_start  = in_europe  and not was_in_europe
    europe_session_end    = not in_europe  and was_in_europe
    america_session_start = in_america and not was_in_america
    america_session_end   = not in_america and was_in_america

    can_draw = bar_time_tz >= recent_limit_time

    if can_draw
        if europe_session_start
            le = line.new(
                 bar_index, low,
                 bar_index, high,
                 extend = extend.both,
                 color  = europe_color,
                 width  = line_width
            )
            array.push(europe_lines, le)

            lbl_eu = label.new(
                 bar_index, high,
                 "Европа",
                 style     = label.style_label_down,
                 textcolor = europe_color,
                 size      = label_size_enum,
                 color     = color.new(color.white, 100)
            )
            array.push(session_labels, lbl_eu)

        if europe_session_end
            le_end = line.new(
                 bar_index, low,
                 bar_index, high,
                 extend = extend.both,
                 color  = europe_color,
                 width  = line_width
            )
            array.push(europe_lines, le_end)

        if america_session_start
            la = line.new(
                 bar_index, low,
                 bar_index, high,
                 extend = extend.both,
                 color  = america_color,
                 width  = line_width
            )
            array.push(america_lines, la)

            lbl_us = label.new(
                 bar_index, high,
                 "Америка",
                 style     = label.style_label_down,
                 textcolor = america_color,
                 size      = label_size_enum,
                 color     = color.new(color.white, 100)
            )
            array.push(session_labels, lbl_us)

        if america_session_end
            la_end = line.new(
                 bar_index, low,
                 bar_index, high,
                 extend = extend.both,
                 color  = america_color,
                 width  = line_width
            )
            array.push(america_lines, la_end)

    //-------------------------
    // ТАБЛИЦА ТЕКУЩЕЙ СЕССИИ
    //-------------------------

    var table session_table = table.new(
         table_pos_enum,
         2, 2,
         border_width = 1,
         frame_color  = color.new(color.white, 70),
         border_color = color.new(color.white, 70)
     )

    if barstate.islast and not only_lower_tf
        string current_session_name = ""
        string remaining_str        = ""
        color  text_col             = color.new(color.white, 0)

        if in_europe
            current_session_name := "Европа"
            text_col := europe_color
            remaining_min = math.round(math.max(0, (europe_end_ts - bar_time_tz) / 60000.0))
            remaining_str := f_format_remaining(remaining_min)
        else if in_america
            current_session_name := "Америка"
            text_col := america_color
            remaining_min = math.round(math.max(0, (america_end_ts - bar_time_tz) / 60000.0))
            remaining_str := f_format_remaining(remaining_min)
        else
            current_session_name := "Вне сессий"
            remaining_str := "—"
            text_col := color.new(color.white, 0)

        table.cell(
             session_table, 0, 0,
             "Сессия",
             text_color = color.new(color.white, 0),
             text_size  = label_size_enum,
             bgcolor    = color.new(color.black, 80)
         )
        table.cell(
             session_table, 1, 0,
             "Оставшееся время",
             text_color = color.new(color.white, 0),
             text_size  = label_size_enum,
             bgcolor    = color.new(color.black, 80)
         )

        table.cell(
             session_table, 0, 1,
             current_session_name,
             text_color = text_col,
             text_size  = label_size_enum,
             bgcolor    = color.new(color.black, 80)
         )
        table.cell(
             session_table, 1, 1,
             remaining_str,
             text_color = text_col,
             text_size  = label_size_enum,
             bgcolor    = color.new(color.black, 80)
         )

// Вызов заливки фона должен быть в глобальном скоупе
bgcolor(bg_color)
````
