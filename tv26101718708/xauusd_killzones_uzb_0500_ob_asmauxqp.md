# XAU/USD Killzones + UZB 05:00 OB

- url: https://www.tradingview.com/script/AsmauXQP-xau-usd-killzones-uzb-05-00-ob/
- type: indicator
- pine_id: PUB;aead01fa070c49aea0592fe997ca95aa
- version: 1.0

## Description

Краткое описание:
Индикатор торговых зон (Killzones) с выделением ордер-блоков на 05:00 по времени Ташкента (UTC+5). Разработан специально для трейдеров из Узбекистана торгующих золотом (XAU/USD) по ICT методологии.

Полное описание:
🟥 Asian Killzone — 05:00–10:00 УЗБ (00:00–05:00 UTC)
Азиатская сессия. Обычно низкая волатильность, формирует диапазон для захвата ликвидности в последующих сессиях. Прямоугольник показывает точный High и Low зоны.
🟦 London Killzone — 12:00–15:00 УЗБ (07:00–10:00 UTC)
Открытие Лондона — одна из самых активных зон дня. Часто здесь происходит слом структуры и начало основного движения дня.
🟧 New York AM — 17:00–20:00 УЗБ (12:00–15:00 UTC)
Открытие Нью-Йорка. Наибольший объём и волатильность. Пересечение с Лондоном создаёт мощные движения. Ключевая зона для входов по тренду.
🟪 New York PM — 23:00–02:00 УЗБ (18:00–21:00 UTC)
Закрытие Нью-Йорка. Зона распределения и завершения дневных движений.
⭐ Ордер-блок 05:00 УЗБ
Тело свечи ровно в 05:00 по Ташкенту отмечается как ордер-блок — это момент открытия азиатской сессии. Прямоугольник тянется до закрытия NY (22:00 UTC = 03:00 УЗБ). Зелёный — бычий OB, красный — медвежий. Хранится история за 30 дней (настраивается).
📊 Таблица (правый верхний угол)
Показывает текущее время Ташкента и статус каждой зоны в реальном времени.

Особенности:

Все зоны привязаны к UTC — работает на любом брокере независимо от часового пояса графика
Боксы автоматически закрываются по окончании зоны
История OB настраивается от 1 до 100 дней
Совместим с любым таймфреймом (рекомендуется M5–H1)
Пара: XAU/USD, XAUUSD


Теги для поиска:
xauusd gold killzones ICT orderblock sessions uzbekistan tashkent asian london newyork SMC smartmoney

## Source Code

````pine
//@version=5
indicator("XAU/USD Killzones + УЗБ 05:00 OB", overlay=true, max_bars_back=1000)

// ══════════════════════════════
// НАСТРОЙКИ
// ══════════════════════════════
show_asian  = input.bool(true, "Asian (05:00–10:00 УЗБ)",    group="Killzones")
show_london = input.bool(true, "London (12:00–15:00 УЗБ)",   group="Killzones")
show_ny_am  = input.bool(true, "NY AM (17:00–20:00 УЗБ)",    group="Killzones")
show_ny_pm  = input.bool(true, "NY PM (23:00–02:00 УЗБ)",    group="Killzones")
show_ob     = input.bool(true, "OB 05:00 УЗБ (история)",     group="OB 05:00")
ob_history  = input.int(30,   "Дней истории OB",  minval=1, maxval=100, group="OB 05:00")
col_ob_bull = input.color(color.new(#00C853, 55), "OB Бычий",    group="OB 05:00")
col_ob_bear = input.color(color.new(#D50000, 55), "OB Медвежий", group="OB 05:00")

col_asian_bg  = input.color(color.new(#8B0000, 65), "Asian фон",      group="Цвета")
col_asian_br  = input.color(color.new(#FF3B3B, 40), "Asian граница",  group="Цвета")
col_london_bg = input.color(color.new(#002B3D, 65), "London фон",     group="Цвета")
col_london_br = input.color(color.new(#00B4D8, 40), "London граница", group="Цвета")
col_ny_am_bg  = input.color(color.new(#3D1A00, 65), "NY AM фон",      group="Цвета")
col_ny_am_br  = input.color(color.new(#FF8C00, 40), "NY AM граница",  group="Цвета")
col_ny_pm_bg  = input.color(color.new(#001433, 65), "NY PM фон",      group="Цвета")
col_ny_pm_br  = input.color(color.new(#4488FF, 40), "NY PM граница",  group="Цвета")

// ══════════════════════════════
// ВРЕМЯ — через time() надёжнее
// ══════════════════════════════
// Asian   00:00–05:00 UTC = 05:00–10:00 УЗБ
// London  07:00–10:00 UTC = 12:00–15:00 УЗБ
// NY AM   12:00–15:00 UTC = 17:00–20:00 УЗБ
// NY PM   18:00–21:00 UTC = 23:00–02:00 УЗБ
// NY full 13:00–22:00 UTC (для закрытия OB)

t_asian   = time(timeframe.period, "0000-0500:1234567", "UTC")
t_london  = time(timeframe.period, "0700-1000:1234567", "UTC")
t_ny_am   = time(timeframe.period, "1200-1500:1234567", "UTC")
t_ny_pm   = time(timeframe.period, "1800-2100:1234567", "UTC")
t_ny_full = time(timeframe.period, "1300-2200:1234567", "UTC")

in_asian   = not na(t_asian)
in_london  = not na(t_london)
in_ny_am   = not na(t_ny_am)
in_ny_pm   = not na(t_ny_pm)
in_ny_full = not na(t_ny_full)

start_asian  = in_asian   and not in_asian[1]
start_london = in_london  and not in_london[1]
start_ny_am  = in_ny_am   and not in_ny_am[1]
start_ny_pm  = in_ny_pm   and not in_ny_pm[1]

end_asian    = not in_asian   and in_asian[1]
end_london   = not in_london  and in_london[1]
end_ny_am    = not in_ny_am   and in_ny_am[1]
end_ny_pm    = not in_ny_pm   and in_ny_pm[1]
end_ny_full  = not in_ny_full and in_ny_full[1]

uzb_h = hour(time,   "UTC+5")
uzb_m = minute(time, "UTC+5")
is_05 = uzb_h == 5 and uzb_m == 0

// ══════════════════════════════
// ASIAN BOX
// ══════════════════════════════
var float ah = na
var float al = na
var box   ab = na

if show_asian and start_asian
    ah := high
    al := low
    ab := box.new(bar_index, high, bar_index + 1, low,
         bgcolor=col_asian_bg, border_color=col_asian_br, border_width=1,
         text="Asian", text_color=color.new(#FF6B6B, 0),
         text_size=size.small, text_halign=text.align_center, text_valign=text.align_top)

if show_asian and in_asian and not start_asian and not na(ab)
    ah := math.max(ah, high)
    al := math.min(al, low)
    box.set_top(ab,    ah)
    box.set_bottom(ab, al)
    box.set_right(ab,  bar_index + 1)

if show_asian and end_asian and not na(ab)
    box.set_right(ab, bar_index)

// ══════════════════════════════
// LONDON BOX
// ══════════════════════════════
var float lh = na
var float ll = na
var box   lb = na

if show_london and start_london
    lh := high
    ll := low
    lb := box.new(bar_index, high, bar_index + 1, low,
         bgcolor=col_london_bg, border_color=col_london_br, border_width=1,
         text="London", text_color=color.new(#00D4FF, 0),
         text_size=size.small, text_halign=text.align_center, text_valign=text.align_top)

if show_london and in_london and not start_london and not na(lb)
    lh := math.max(lh, high)
    ll := math.min(ll, low)
    box.set_top(lb,    lh)
    box.set_bottom(lb, ll)
    box.set_right(lb,  bar_index + 1)

if show_london and end_london and not na(lb)
    box.set_right(lb, bar_index)

// ══════════════════════════════
// NY AM BOX
// ══════════════════════════════
var float nh = na
var float nl = na
var box   nb = na

if show_ny_am and start_ny_am
    nh := high
    nl := low
    nb := box.new(bar_index, high, bar_index + 1, low,
         bgcolor=col_ny_am_bg, border_color=col_ny_am_br, border_width=1,
         text="New York AM", text_color=color.new(#FFA040, 0),
         text_size=size.small, text_halign=text.align_center, text_valign=text.align_top)

if show_ny_am and in_ny_am and not start_ny_am and not na(nb)
    nh := math.max(nh, high)
    nl := math.min(nl, low)
    box.set_top(nb,    nh)
    box.set_bottom(nb, nl)
    box.set_right(nb,  bar_index + 1)

if show_ny_am and end_ny_am and not na(nb)
    box.set_right(nb, bar_index)

// ══════════════════════════════
// NY PM BOX
// ══════════════════════════════
var float ph = na
var float pl = na
var box   pb = na

if show_ny_pm and start_ny_pm
    ph := high
    pl := low
    pb := box.new(bar_index, high, bar_index + 1, low,
         bgcolor=col_ny_pm_bg, border_color=col_ny_pm_br, border_width=1,
         text="New York PM", text_color=color.new(#6699FF, 0),
         text_size=size.small, text_halign=text.align_center, text_valign=text.align_top)

if show_ny_pm and in_ny_pm and not start_ny_pm and not na(pb)
    ph := math.max(ph, high)
    pl := math.min(pl, low)
    box.set_top(pb,    ph)
    box.set_bottom(pb, pl)
    box.set_right(pb,  bar_index + 1)

if show_ny_pm and end_ny_pm and not na(pb)
    box.set_right(pb, bar_index)

// ══════════════════════════════
// 05:00 УЗБ МАРКЕР
// ══════════════════════════════
bgcolor(is_05 ? color.new(#FFD700, 80) : na, title="05:00 фон")
plotshape(is_05,
     style    = shape.triangleup,
     location = location.belowbar,
     color    = color.new(#FFD700, 0),
     size     = size.small,
     title    = "05:00 УЗБ")

// ══════════════════════════════
// OB 05:00 УЗБ — ИСТОРИЯ
// Каждый день создаём новый бокс
// НЕ удаляем старые — храним историю
// Закрываем на конце NY (22:00 UTC)
// ══════════════════════════════
var box   ob_cur    = na   // текущий активный OB
var bool  ob_on     = false
var float ob_top    = na
var float ob_bot    = na
var bool  ob_bull   = false

// Дата старше N дней — не рисуем
cutoff_time = time - ob_history * 86400000

if show_ob and is_05 and time >= cutoff_time
    ob_top  := math.max(open, close)
    ob_bot  := math.min(open, close)
    ob_bull := close >= open
    ob_on   := true
    // Создаём НОВЫЙ бокс (старый не удаляем — история!)
    ob_cur  := box.new(
         left         = bar_index,
         top          = math.max(open, close),
         right        = bar_index + 1,
         bottom       = math.min(open, close),
         bgcolor      = close >= open ? col_ob_bull : col_ob_bear,
         border_color = close >= open ? color.new(#00FF6A, 20) : color.new(#FF1744, 20),
         border_width = 2,
         text         = close >= open ? "OB ▲ 05:00 УЗБ" : "OB ▼ 05:00 УЗБ",
         text_color   = close >= open ? color.new(#00FF6A, 0) : color.new(#FF5252, 0),
         text_size    = size.small,
         text_halign  = text.align_left,
         text_valign  = text.align_top)

// Растягиваем текущий OB вправо пока NY не закрылась
if ob_on and not na(ob_cur)
    box.set_right(ob_cur, bar_index + 1)

// Фиксируем правый край на конце NY
if ob_on and end_ny_full
    ob_on := false
    if not na(ob_cur)
        box.set_right(ob_cur, bar_index)

// ══════════════════════════════
// ТАБЛИЦА
// ══════════════════════════════
var table tbl = table.new(position.top_right, 2, 7,
     bgcolor      = color.new(#0A0A14, 5),
     border_color = color.new(#FFD700, 40),
     border_width = 1,
     frame_color  = color.new(#FFD700, 20),
     frame_width  = 2)

if barstate.islast
    table.cell(tbl, 0, 0, "⏰ УЗБ",
         text_color=color.new(#FFD700, 0), text_size=size.normal,
         bgcolor=color.new(#111122, 0), text_halign=text.align_center)
    table.cell(tbl, 1, 0,
         str.tostring(uzb_h, "00") + ":" + str.tostring(uzb_m, "00"),
         text_color=color.new(#FFD700, 0), text_size=size.large,
         bgcolor=color.new(#111122, 0), text_halign=text.align_center)

    table.cell(tbl, 0, 1, "Asian  05-10",
         text_color=color.new(#FF6B6B, 0), text_size=size.small,
         bgcolor=in_asian ? color.new(#8B0000, 55) : color.new(#1A0808, 40))
    table.cell(tbl, 1, 1, in_asian ? "● АКТИВНА" : "○ закрыта",
         text_color=in_asian ? color.new(#FF6B6B, 0) : color.new(#444444, 0),
         text_size=size.small,
         bgcolor=in_asian ? color.new(#8B0000, 55) : color.new(#1A0808, 40))

    table.cell(tbl, 0, 2, "London 12-15",
         text_color=color.new(#00D4FF, 0), text_size=size.small,
         bgcolor=in_london ? color.new(#004D6E, 55) : color.new(#081418, 40))
    table.cell(tbl, 1, 2, in_london ? "● АКТИВНА" : "○ закрыта",
         text_color=in_london ? color.new(#00D4FF, 0) : color.new(#444444, 0),
         text_size=size.small,
         bgcolor=in_london ? color.new(#004D6E, 55) : color.new(#081418, 40))

    table.cell(tbl, 0, 3, "NY AM  17-20",
         text_color=color.new(#FFA040, 0), text_size=size.small,
         bgcolor=in_ny_am ? color.new(#5C2000, 55) : color.new(#180A00, 40))
    table.cell(tbl, 1, 3, in_ny_am ? "● АКТИВНА" : "○ закрыта",
         text_color=in_ny_am ? color.new(#FFA040, 0) : color.new(#444444, 0),
         text_size=size.small,
         bgcolor=in_ny_am ? color.new(#5C2000, 55) : color.new(#180A00, 40))

    table.cell(tbl, 0, 4, "NY PM  23-02",
         text_color=color.new(#6699FF, 0), text_size=size.small,
         bgcolor=in_ny_pm ? color.new(#003366, 55) : color.new(#08080E, 40))
    table.cell(tbl, 1, 4, in_ny_pm ? "● АКТИВНА" : "○ закрыта",
         text_color=in_ny_pm ? color.new(#6699FF, 0) : color.new(#444444, 0),
         text_size=size.small,
         bgcolor=in_ny_pm ? color.new(#003366, 55) : color.new(#08080E, 40))

    _oc  = ob_on ? (ob_bull ? color.new(#00FF6A, 0) : color.new(#FF5252, 0)) : color.new(#444444, 0)
    _obg = ob_on ? (ob_bull ? color.new(#003300, 40) : color.new(#330000, 40)) : color.new(#111111, 40)
    _ost = ob_on ? (ob_bull ? "🟢 БЫЧИЙ" : "🔴 МЕДВЕЖИЙ") : "○ закрыт"
    table.cell(tbl, 0, 5, "OB 05:00",
         text_color=color.new(#FFD700, 0), text_size=size.small, bgcolor=_obg)
    table.cell(tbl, 1, 5, _ost,
         text_color=_oc, text_size=size.small, bgcolor=_obg)

    _lv = not na(ob_top) ? str.tostring(ob_top, "#.00") + " / " + str.tostring(ob_bot, "#.00") : "—"
    table.cell(tbl, 0, 6, "Top / Bot",
         text_color=color.new(#888888, 0), text_size=size.tiny,
         bgcolor=color.new(#0A0A0A, 40))
    table.cell(tbl, 1, 6, _lv,
         text_color=color.new(#FFD700, 0), text_size=size.tiny,
         bgcolor=color.new(#0A0A0A, 40))
````
