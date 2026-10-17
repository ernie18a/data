# ICT Killzones & Silver Bullet

- url: https://www.tradingview.com/script/NgWtHpnx-ict-killzones-silver-bullet/
- type: indicator
- pine_id: PUB;b88aef2aa6f1410d81df3f2508016cba
- version: 1.0

## Description

EN: Highlights the key ICT time windows on your chart — Killzones and Silver Bullet
sessions — so you instantly see when institutional activity is most likely.

A clean time-window tool for ICT / Smart Money traders. It shades the key intraday
windows directly on the chart, in New York time, regardless of your local timezone:

• Killzones — 7 fully customizable time windows (on/off, start and end by hour and
  minute). Defaults follow the high-activity ICT macro windows around session opens.
• Silver Bullet — the three classic one-hour ICT windows where setups are hunted:
  London (03:00–04:00 NY), NY AM (10:00–11:00 NY), NY PM (14:00–15:00 NY).

Every window is editable, has its own toggle, color, border style and optional label.
The indicator only draws a window while price is inside it, keeping the chart clean.

raders waste focus tracking the clock — when is London, when is the Silver Bullet,
is price inside a high-probability window. This tool marks every key window
automatically in NY time, so you never miss a session and never miscount the hours.

WHAT IT SHOWS
Shaded boxes appear only while price is inside a time window. Killzones use one color,
Silver Bullet windows another, each with an optional label.

KILLZONES (group "Killzones")
- "Show Killzones" — turn the whole module on/off.
- Color, border style (Solid/Dotted/Dashed/No border), border transparency, labels.
- 7 zones (KZ1–KZ7): each row = [on/off] [start hour][min] [end hour][min], NY time.
- Defaults follow ICT macro windows. Edit any zone to your own times.

SILVER BULLET (group "Silver Bullet")
- "Show Silver Bullet" — on/off, plus color, border transparency, labels.
- 3 classic one-hour windows (editable by hour, NY time):
    London SB: 03:00–04:00
    NY AM SB:  10:00–11:00
    NY PM SB:  14:00–15:00

HOW TO USE
1. All times are New York — no manual timezone conversion needed.
2. Best on M15 and lower, where the windows are clearly visible.
3. Look for entries / liquidity grabs INSIDE these windows — that is when
   institutional activity is most likely.
4. Disable the windows you don't trade to keep the chart clean.

WANT CLASSIC KILLZONES INSTEAD OF MACROS?
Set wider windows, e.g. London 02:00–05:00, NY AM 07:00–10:00, NY PM 13:30–16:00.

NOTE: This is an analytical timing tool, not financial advice. Always confirm with
price action and risk management.

## Source Code

````pine
//@version=6
// ICT Killzones & Silver Bullet — time-window indicator
// Подсветка ключевых временных окон ICT: киллзоны + окна "Серебряная пуля".
indicator("ICT Killzones & Silver Bullet", overlay=true, max_boxes_count=500, max_labels_count=500)

NY_TZ = "America/New_York"

// ===================== KILLZONES =====================
show_kz       = input.bool(true,  "Show Killzones / Показывать киллзоны", group="Killzones / Киллзоны")
kz_col        = input.color(color.new(color.red, 88), "Killzone color / Цвет киллзоны", group="Killzones / Киллзоны")
kz_border_style = input.string("Dotted", "Border style / Стиль границы", options=["Solid", "Dotted", "Dashed", "No border"], group="Killzones / Киллзоны")
kz_border_transp = input.int(70, "Border transparency / Прозрачность границы", minval=0, maxval=100, group="Killzones / Киллзоны")
kz_show_label = input.bool(true, "Show killzone labels / Подписи киллзон", group="Killzones / Киллзоны")

kz1_on  = input.bool(true, "KZ1 on", inline="kz1", group="Killzones / Киллзоны")
kz1_h1  = input.int(2,  "h", minval=0, maxval=23, inline="kz1", group="Killzones / Киллзоны")
kz1_m1  = input.int(45, "m", minval=0, maxval=59, inline="kz1", group="Killzones / Киллзоны")
kz1_h2  = input.int(3,  "-h", minval=0, maxval=23, inline="kz1", group="Killzones / Киллзоны")
kz1_m2  = input.int(15, "m", minval=0, maxval=59, inline="kz1", group="Killzones / Киллзоны")

kz2_on  = input.bool(true, "KZ2 on", inline="kz2", group="Killzones / Киллзоны")
kz2_h1  = input.int(3,  "h", minval=0, maxval=23, inline="kz2", group="Killzones / Киллзоны")
kz2_m1  = input.int(45, "m", minval=0, maxval=59, inline="kz2", group="Killzones / Киллзоны")
kz2_h2  = input.int(4,  "-h", minval=0, maxval=23, inline="kz2", group="Killzones / Киллзоны")
kz2_m2  = input.int(15, "m", minval=0, maxval=59, inline="kz2", group="Killzones / Киллзоны")

kz3_on  = input.bool(true, "KZ3 on", inline="kz3", group="Killzones / Киллзоны")
kz3_h1  = input.int(4,  "h", minval=0, maxval=23, inline="kz3", group="Killzones / Киллзоны")
kz3_m1  = input.int(45, "m", minval=0, maxval=59, inline="kz3", group="Killzones / Киллзоны")
kz3_h2  = input.int(5,  "-h", minval=0, maxval=23, inline="kz3", group="Killzones / Киллзоны")
kz3_m2  = input.int(15, "m", minval=0, maxval=59, inline="kz3", group="Killzones / Киллзоны")

kz4_on  = input.bool(true, "KZ4 on", inline="kz4", group="Killzones / Киллзоны")
kz4_h1  = input.int(9,  "h", minval=0, maxval=23, inline="kz4", group="Killzones / Киллзоны")
kz4_m1  = input.int(45, "m", minval=0, maxval=59, inline="kz4", group="Killzones / Киллзоны")
kz4_h2  = input.int(10, "-h", minval=0, maxval=23, inline="kz4", group="Killzones / Киллзоны")
kz4_m2  = input.int(15, "m", minval=0, maxval=59, inline="kz4", group="Killzones / Киллзоны")

kz5_on  = input.bool(true, "KZ5 on", inline="kz5", group="Killzones / Киллзоны")
kz5_h1  = input.int(10, "h", minval=0, maxval=23, inline="kz5", group="Killzones / Киллзоны")
kz5_m1  = input.int(45, "m", minval=0, maxval=59, inline="kz5", group="Killzones / Киллзоны")
kz5_h2  = input.int(11, "-h", minval=0, maxval=23, inline="kz5", group="Killzones / Киллзоны")
kz5_m2  = input.int(15, "m", minval=0, maxval=59, inline="kz5", group="Killzones / Киллзоны")

kz6_on  = input.bool(true, "KZ6 on", inline="kz6", group="Killzones / Киллзоны")
kz6_h1  = input.int(13, "h", minval=0, maxval=23, inline="kz6", group="Killzones / Киллзоны")
kz6_m1  = input.int(45, "m", minval=0, maxval=59, inline="kz6", group="Killzones / Киллзоны")
kz6_h2  = input.int(14, "-h", minval=0, maxval=23, inline="kz6", group="Killzones / Киллзоны")
kz6_m2  = input.int(15, "m", minval=0, maxval=59, inline="kz6", group="Killzones / Киллзоны")

kz7_on  = input.bool(true, "KZ7 on", inline="kz7", group="Killzones / Киллзоны")
kz7_h1  = input.int(14, "h", minval=0, maxval=23, inline="kz7", group="Killzones / Киллзоны")
kz7_m1  = input.int(45, "m", minval=0, maxval=59, inline="kz7", group="Killzones / Киллзоны")
kz7_h2  = input.int(15, "-h", minval=0, maxval=23, inline="kz7", group="Killzones / Киллзоны")
kz7_m2  = input.int(15, "m", minval=0, maxval=59, inline="kz7", group="Killzones / Киллзоны")

// ===================== SILVER BULLET =====================
show_sb       = input.bool(true, "Show Silver Bullet / Показывать Серебряную пулю", group="Silver Bullet / Серебряная пуля")
sb_col        = input.color(color.new(color.gray, 80), "Silver Bullet color / Цвет", group="Silver Bullet / Серебряная пуля")
sb_border_transp = input.int(40, "Border transparency / Прозрачность границы", minval=0, maxval=100, group="Silver Bullet / Серебряная пуля")
sb_show_label = input.bool(true, "Show SB labels / Подписи Серебряной пули", group="Silver Bullet / Серебряная пуля")

// 3 классических окна Silver Bullet (NY), редактируемые
sb1_on = input.bool(true, "London SB on", inline="sb1", group="Silver Bullet / Серебряная пуля")
sb1_h1 = input.int(3,  "h", minval=0, maxval=23, inline="sb1", group="Silver Bullet / Серебряная пуля")
sb1_h2 = input.int(4,  "-h", minval=0, maxval=23, inline="sb1", group="Silver Bullet / Серебряная пуля")

sb2_on = input.bool(true, "NY AM SB on", inline="sb2", group="Silver Bullet / Серебряная пуля")
sb2_h1 = input.int(10, "h", minval=0, maxval=23, inline="sb2", group="Silver Bullet / Серебряная пуля")
sb2_h2 = input.int(11, "-h", minval=0, maxval=23, inline="sb2", group="Silver Bullet / Серебряная пуля")

sb3_on = input.bool(true, "NY PM SB on", inline="sb3", group="Silver Bullet / Серебряная пуля")
sb3_h1 = input.int(14, "h", minval=0, maxval=23, inline="sb3", group="Silver Bullet / Серебряная пуля")
sb3_h2 = input.int(15, "-h", minval=0, maxval=23, inline="sb3", group="Silver Bullet / Серебряная пуля")

// ===================== ЛОГИКА ВРЕМЕНИ =====================
ny_h = hour(time, NY_TZ)
ny_m = minute(time, NY_TZ)
ny_min = ny_h * 60 + ny_m

f_border_style(s) =>
    switch s
        "Solid"  => line.style_solid
        "Dotted" => line.style_dotted
        "Dashed" => line.style_dashed
        => line.style_solid

// Проверка попадания текущего времени в окно [h1:m1 - h2:m2]
f_in_window(h1, m1, h2, m2) =>
    start = h1 * 60 + m1
    fin   = h2 * 60 + m2
    ny_min >= start and ny_min < fin

// Рисуем зону: на первом баре окна создаём box, далее расширяем
f_zone(is_on, h1, m1, h2, m2, col, brd_transp, brd_style, show_lbl, lbl_txt) =>
    var box  zbox = na
    var label zlbl = na
    in_win = is_on and f_in_window(h1, m1, h2, m2)
    was_in = is_on and f_in_window(h1, m1, h2, m2)[1]
    if in_win and not was_in
        // старт окна
        zbox := box.new(bar_index, high, bar_index, low, border_color=color.new(col, brd_transp), border_style=brd_style, bgcolor=col)
        if show_lbl
            zlbl := label.new(bar_index, high, lbl_txt, style=label.style_label_down, color=color.new(color.black, 100), textcolor=color.new(col, 0), size=size.small)
    else if in_win and not na(zbox)
        // расширяем окно
        box.set_right(zbox, bar_index)
        box.set_top(zbox, math.max(box.get_top(zbox), high))
        box.set_bottom(zbox, math.min(box.get_bottom(zbox), low))
        if show_lbl and not na(zlbl)
            label.set_xy(zlbl, int(math.avg(box.get_left(zbox), bar_index)), box.get_top(zbox))
    int(0)  // нейтральный возврат, чтобы все ветки имели один тип

// ===================== ОТРИСОВКА KILLZONES =====================
kz_bs = f_border_style(kz_border_style == "No border" ? "Solid" : kz_border_style)
kz_bt = kz_border_style == "No border" ? 100 : kz_border_transp

if show_kz
    f_zone(kz1_on, kz1_h1, kz1_m1, kz1_h2, kz1_m2, kz_col, kz_bt, kz_bs, kz_show_label, "KZ1")
    f_zone(kz2_on, kz2_h1, kz2_m1, kz2_h2, kz2_m2, kz_col, kz_bt, kz_bs, kz_show_label, "KZ2")
    f_zone(kz3_on, kz3_h1, kz3_m1, kz3_h2, kz3_m2, kz_col, kz_bt, kz_bs, kz_show_label, "KZ3")
    f_zone(kz4_on, kz4_h1, kz4_m1, kz4_h2, kz4_m2, kz_col, kz_bt, kz_bs, kz_show_label, "KZ4")
    f_zone(kz5_on, kz5_h1, kz5_m1, kz5_h2, kz5_m2, kz_col, kz_bt, kz_bs, kz_show_label, "KZ5")
    f_zone(kz6_on, kz6_h1, kz6_m1, kz6_h2, kz6_m2, kz_col, kz_bt, kz_bs, kz_show_label, "KZ6")
    f_zone(kz7_on, kz7_h1, kz7_m1, kz7_h2, kz7_m2, kz_col, kz_bt, kz_bs, kz_show_label, "KZ7")

// ===================== ОТРИСОВКА SILVER BULLET =====================
if show_sb
    f_zone(sb1_on, sb1_h1, 0, sb1_h2, 0, sb_col, sb_border_transp, line.style_solid, sb_show_label, "Silver Bullet (London)")
    f_zone(sb2_on, sb2_h1, 0, sb2_h2, 0, sb_col, sb_border_transp, line.style_solid, sb_show_label, "Silver Bullet (NY AM)")
    f_zone(sb3_on, sb3_h1, 0, sb3_h2, 0, sb_col, sb_border_transp, line.style_solid, sb_show_label, "Silver Bullet (NY PM)")
````
