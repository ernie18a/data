# XAU/USD Killzones + EMA + UZB 05:00 OB

- url: https://www.tradingview.com/script/NGnWLDom-xau-usd-killzones-ema-uzb-05-00-ob/
- type: indicator
- pine_id: PUB;ba2d96506c5148af807d15190408d34d
- version: 1.0

## Description

Название: XAU/USD Killzones + EMA + УЗБ 05:00 OB

Для кого: Трейдеры из Узбекистана торгующие золотом (XAU/USD) по ICT/SMC методологии. Всё время отображается по Ташкенту (UTC+5).

📦 ЧТО ПОКАЗЫВАЕТ
🟥 Asian Killzone — 05:00–10:00 УЗБ
Азиатская сессия. Низкая волатильность, формируется диапазон. Прямоугольник захватывает точный High и Low зоны. Используй как зону ликвидности для последующих сессий.
🟦 London Killzone — 12:00–15:00 УЗБ
Открытие Лондона. Часто здесь происходит слом структуры и начало основного дневного движения. Следи за выходом за границы Asian зоны.
🟧 New York AM — 17:00–20:00 УЗБ
Открытие Нью-Йорка. Самая волатильная зона дня. Пересечение с Лондоном создаёт сильные импульсы. Лучшее время для входов по тренду.
🟪 New York PM — 23:00–02:00 УЗБ
Закрытие Нью-Йорка. Зона распределения и завершения дневных движений. Осторожно с новыми входами.

⭐ ОРДЕР-БЛОК 05:00 УЗБ
Свеча ровно в 05:00 по Ташкенту — это открытие азиатской сессии. Тело этой свечи автоматически отмечается как ордер-блок:

🟢 Зелёный OB — свеча бычья (цена выросла). Ищи покупки при возврате цены в зону
🔴 Красный OB — свеча медвежья (цена упала). Ищи продажи при возврате цены в зону

Прямоугольник тянется до 22:00 UTC (03:00 УЗБ) — конец NY сессии. После этого OB закрывается. История OB настраивается до 100 дней назад.

📈 EMA 50 и EMA 200
EMA 50 (золотая линия) — краткосрочный тренд
EMA 200 (красная линия) — долгосрочный тренд
Как использовать:

Цена выше EMA 200 → общий тренд бычий → ищи только покупки
Цена ниже EMA 200 → общий тренд медвежий → ищи только продажи
EMA 50 пересекает EMA 200 снизу вверх → метка 🟢 50×200 — Golden Cross, сигнал разворота вверх
EMA 50 пересекает EMA 200 сверху вниз → метка 🔴 50×200 — Death Cross, сигнал разворота вниз


🕐 ТАБЛИЦА (правый угол)
Показывает в реальном времени:

Текущее время Ташкента
Какая сессия сейчас активна
Статус ордер-блока (бычий/медвежий/ожидание) и его уровни Top/Bot

## Source Code

````pine
//@version=6
indicator("XAU/USD Killzones + EMA + УЗБ 05:00 OB", overlay=true, max_bars_back=1000)

// ══════════════════════════════
// EMA
// ══════════════════════════════
show_ema50   = input.bool(true, "Показать EMA 50",  group="EMA")
show_ema200  = input.bool(true, "Показать EMA 200", group="EMA")
col_ema50    = input.color(color.new(#FFD700, 0), "Цвет EMA 50",  group="EMA")
col_ema200   = input.color(color.new(#FF4444, 0), "Цвет EMA 200", group="EMA")
ema50_width  = input.int(2, "Толщина EMA 50",  minval=1, maxval=4, group="EMA")
ema200_width = input.int(2, "Толщина EMA 200", minval=1, maxval=4, group="EMA")

ema50  = ta.ema(close, 50)
ema200 = ta.ema(close, 200)

plot(show_ema50  ? ema50  : na, title="EMA 50",  color=col_ema50,  linewidth=ema50_width)
plot(show_ema200 ? ema200 : na, title="EMA 200", color=col_ema200, linewidth=ema200_width)

plotshape(show_ema50 and show_ema200 and ta.crossover(ema50, ema200),
     title="EMA Cross UP", style=shape.arrowup, location=location.belowbar,
     color=color.new(#00E676, 0), size=size.small)
plotshape(show_ema50 and show_ema200 and ta.crossunder(ema50, ema200),
     title="EMA Cross DOWN", style=shape.arrowdown, location=location.abovebar,
     color=color.new(#FF1744, 0), size=size.small)

// ══════════════════════════════
// НАСТРОЙКИ
// ══════════════════════════════
show_asian  = input.bool(true, "Asian (05:00–10:00 УЗБ)",  group="Killzones")
show_london = input.bool(true, "London (12:00–15:00 УЗБ)", group="Killzones")
show_ny_am  = input.bool(true, "NY AM (17:00–20:00 УЗБ)",  group="Killzones")
show_ny_pm  = input.bool(true, "NY PM (23:00–02:00 УЗБ)",  group="Killzones")
show_ob     = input.bool(true, "OB 05:00 УЗБ (история)",   group="OB 05:00")
ob_history  = input.int(30, "Дней истории OB", minval=1, maxval=100, group="OB 05:00")
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
// ВРЕМЯ UTC
// ══════════════════════════════
h     = hour(time,   "UTC")
uzb_h = hour(time,   "UTC+5")
uzb_m = minute(time, "UTC+5")
is_05 = uzb_h == 5 and uzb_m == 0

// Диапазоны по часу UTC
in_a = h >= 0  and h < 5
in_l = h >= 7  and h < 10
in_n = h >= 12 and h < 15
in_p = h >= 18 and h < 21
in_f = h >= 13 and h < 22

start_a = in_a and not in_a[1]
start_l = in_l and not in_l[1]
start_n = in_n and not in_n[1]
start_p = in_p and not in_p[1]

end_a = not in_a and in_a[1]
end_l = not in_l and in_l[1]
end_n = not in_n and in_n[1]
end_p = not in_p and in_p[1]
end_f = not in_f and in_f[1]

// Длина свечи в миллисекундах — для расчёта правого края
bar_ms = timeframe.in_seconds() * 1000

// ══════════════════════════════
// ASIAN BOX — xloc.bar_time
// ══════════════════════════════
var float ah       = na
var float al       = na
var int   a_t_open = na
var box   ab       = na

if show_asian and start_a
    ah       := high
    al       := low
    a_t_open := time
    ab       := box.new(
         left         = time,
         top          = high,
         right        = time + bar_ms,
         bottom       = low,
         xloc         = xloc.bar_time,
         bgcolor      = col_asian_bg,
         border_color = col_asian_br,
         border_width = 1,
         text         = "Asian",
         text_color   = color.new(#FF6B6B, 0),
         text_size    = size.small,
         text_halign  = text.align_center,
         text_valign  = text.align_top)

if show_asian and in_a and not start_a and not na(ab)
    ah := math.max(ah, high)
    al := math.min(al, low)
    box.set_top(ab,    ah)
    box.set_bottom(ab, al)
    box.set_right(ab,  time + bar_ms)

if show_asian and end_a and not na(ab)
    box.set_right(ab, time)

// ══════════════════════════════
// LONDON BOX — xloc.bar_time
// ══════════════════════════════
var float lh = na
var float ll = na
var box   lb = na

if show_london and start_l
    lh := high
    ll := low
    lb := box.new(
         left         = time,
         top          = high,
         right        = time + bar_ms,
         bottom       = low,
         xloc         = xloc.bar_time,
         bgcolor      = col_london_bg,
         border_color = col_london_br,
         border_width = 1,
         text         = "London",
         text_color   = color.new(#00D4FF, 0),
         text_size    = size.small,
         text_halign  = text.align_center,
         text_valign  = text.align_top)

if show_london and in_l and not start_l and not na(lb)
    lh := math.max(lh, high)
    ll := math.min(ll, low)
    box.set_top(lb,    lh)
    box.set_bottom(lb, ll)
    box.set_right(lb,  time + bar_ms)

if show_london and end_l and not na(lb)
    box.set_right(lb, time)

// ══════════════════════════════
// NY AM BOX — xloc.bar_time
// ══════════════════════════════
var float nh = na
var float nl = na
var box   nb = na

if show_ny_am and start_n
    nh := high
    nl := low
    nb := box.new(
         left         = time,
         top          = high,
         right        = time + bar_ms,
         bottom       = low,
         xloc         = xloc.bar_time,
         bgcolor      = col_ny_am_bg,
         border_color = col_ny_am_br,
         border_width = 1,
         text         = "New York AM",
         text_color   = color.new(#FFA040, 0),
         text_size    = size.small,
         text_halign  = text.align_center,
         text_valign  = text.align_top)

if show_ny_am and in_n and not start_n and not na(nb)
    nh := math.max(nh, high)
    nl := math.min(nl, low)
    box.set_top(nb,    nh)
    box.set_bottom(nb, nl)
    box.set_right(nb,  time + bar_ms)

if show_ny_am and end_n and not na(nb)
    box.set_right(nb, time)

// ══════════════════════════════
// NY PM BOX — xloc.bar_time
// ══════════════════════════════
var float ph = na
var float pl = na
var box   pb = na

if show_ny_pm and start_p
    ph := high
    pl := low
    pb := box.new(
         left         = time,
         top          = high,
         right        = time + bar_ms,
         bottom       = low,
         xloc         = xloc.bar_time,
         bgcolor      = col_ny_pm_bg,
         border_color = col_ny_pm_br,
         border_width = 1,
         text         = "New York PM",
         text_color   = color.new(#6699FF, 0),
         text_size    = size.small,
         text_halign  = text.align_center,
         text_valign  = text.align_top)

if show_ny_pm and in_p and not start_p and not na(pb)
    ph := math.max(ph, high)
    pl := math.min(pl, low)
    box.set_top(pb,    ph)
    box.set_bottom(pb, pl)
    box.set_right(pb,  time + bar_ms)

if show_ny_pm and end_p and not na(pb)
    box.set_right(pb, time)

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
// OB 05:00 УЗБ — ИСТОРИЯ xloc.bar_time
// ══════════════════════════════
var box   ob_cur  = na
var bool  ob_on   = false
var float ob_top  = na
var float ob_bot  = na
var bool  ob_bull = false

cutoff_time = time - ob_history * 86400000

if show_ob and is_05 and time >= cutoff_time
    ob_top  := math.max(open, close)
    ob_bot  := math.min(open, close)
    ob_bull := close >= open
    ob_on   := true
    ob_cur  := box.new(
         left         = time,
         top          = math.max(open, close),
         right        = time + bar_ms,
         bottom       = math.min(open, close),
         xloc         = xloc.bar_time,
         bgcolor      = close >= open ? col_ob_bull : col_ob_bear,
         border_color = close >= open ? color.new(#00FF6A, 20) : color.new(#FF1744, 20),
         border_width = 2,
         text         = close >= open ? "OB ▲ 05:00 УЗБ" : "OB ▼ 05:00 УЗБ",
         text_color   = close >= open ? color.new(#00FF6A, 0) : color.new(#FF5252, 0),
         text_size    = size.small,
         text_halign  = text.align_left,
         text_valign  = text.align_top)

if ob_on and not na(ob_cur)
    box.set_right(ob_cur, time + bar_ms)

if ob_on and end_f
    ob_on := false
    if not na(ob_cur)
        box.set_right(ob_cur, time)

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
         bgcolor=in_a ? color.new(#8B0000, 55) : color.new(#1A0808, 40))
    table.cell(tbl, 1, 1, in_a ? "● АКТИВНА" : "○ закрыта",
         text_color=in_a ? color.new(#FF6B6B, 0) : color.new(#444444, 0),
         text_size=size.small,
         bgcolor=in_a ? color.new(#8B0000, 55) : color.new(#1A0808, 40))

    table.cell(tbl, 0, 2, "London 12-15",
         text_color=color.new(#00D4FF, 0), text_size=size.small,
         bgcolor=in_l ? color.new(#004D6E, 55) : color.new(#081418, 40))
    table.cell(tbl, 1, 2, in_l ? "● АКТИВНА" : "○ закрыта",
         text_color=in_l ? color.new(#00D4FF, 0) : color.new(#444444, 0),
         text_size=size.small,
         bgcolor=in_l ? color.new(#004D6E, 55) : color.new(#081418, 40))

    table.cell(tbl, 0, 3, "NY AM  17-20",
         text_color=color.new(#FFA040, 0), text_size=size.small,
         bgcolor=in_n ? color.new(#5C2000, 55) : color.new(#180A00, 40))
    table.cell(tbl, 1, 3, in_n ? "● АКТИВНА" : "○ закрыта",
         text_color=in_n ? color.new(#FFA040, 0) : color.new(#444444, 0),
         text_size=size.small,
         bgcolor=in_n ? color.new(#5C2000, 55) : color.new(#180A00, 40))

    table.cell(tbl, 0, 4, "NY PM  23-02",
         text_color=color.new(#6699FF, 0), text_size=size.small,
         bgcolor=in_p ? color.new(#003366, 55) : color.new(#08080E, 40))
    table.cell(tbl, 1, 4, in_p ? "● АКТИВНА" : "○ закрыта",
         text_color=in_p ? color.new(#6699FF, 0) : color.new(#444444, 0),
         text_size=size.small,
         bgcolor=in_p ? color.new(#003366, 55) : color.new(#08080E, 40))

    _oc  = ob_on ? (ob_bull ? color.new(#00FF6A, 0) : color.new(#FF5252, 0)) : color.new(#444444, 0)
    _obg = ob_on ? (ob_bull ? color.new(#003300, 40) : color.new(#330000, 40)) : color.new(#111111, 40)
    _ost = ob_on ? (ob_bull ? "🟢 БЫЧИЙ" : "🔴 МЕДВЕЖИЙ") : "○ закрыт"
    table.cell(tbl, 0, 5, "OB 05:00",
         text_color=color.new(#FFD700, 0), text_size=size.small, bgcolor=_obg)
    table.cell(tbl, 1, 5, _ost, text_color=_oc, text_size=size.small, bgcolor=_obg)

    _lv = not na(ob_top) ? str.tostring(ob_top, "#.00") + " / " + str.tostring(ob_bot, "#.00") : "—"
    table.cell(tbl, 0, 6, "Top / Bot",
         text_color=color.new(#888888, 0), text_size=size.tiny,
         bgcolor=color.new(#0A0A0A, 40))
    table.cell(tbl, 1, 6, _lv,
         text_color=color.new(#FFD700, 0), text_size=size.tiny,
         bgcolor=color.new(#0A0A0A, 40))
````
