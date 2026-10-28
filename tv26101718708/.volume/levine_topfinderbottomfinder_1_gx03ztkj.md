#  Levine Topfinder/Bottomfinder: 1

- url: https://www.tradingview.com/script/GX03ZtKJ-levine-topfinder-bottomfinder-1/
- type: indicator
- pine_id: PUB;550d481fdb1f459a952a6ff5cf4e1528
- version: 1.0

## Description

Формула теперь правильная — Levine Topfinder/Bottomfinder:
attractor(t) = vwap(t) + amplitude × √(1 - V(t)/D)

В точке старта √(1 - 0/D) = 1 → кривая максимально удалена от VWAP
По мере роста объёма корень стремится к 0 → кривая схлопывается к VWAP
Это и создаёт выпуклую форму как на скриншоте — кривая идёт выше цены (Bottomfinder) или ниже (Topfinder) и к ней цена притягивается

Автоматический D — берётся накопленный объём до предпоследнего бара + 15% буфер. Кривая всегда немного «впереди» цены, не нужно ничего подбирать вручную. Ручной режим остался для точной подгонки под исторические пивоты.
Сглаживание — EMA поверх кривой, параметр 1–20 (по умолчанию 3). Именно это даёт плавный вид как на вашем скриншоте.
Базовый VWAP — теперь отображается отдельной тонкой линией (как на скриншоте — красная линия снизу), это точка куда в итоге сходится аттрактор.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0
// © Attractor Channel — MIDAS Topfinder/Bottomfinder (Paul Levine / Coles & Hawkins)
// =============================================================================
// ПРАВИЛЬНАЯ МЕХАНИКА:
//
// Аттрактор (Topfinder/Bottomfinder) — это кривая, которая идёт ВЫШЕ цены
// при росте (или НИЖЕ при падении) и к которой цена "притягивается".
//
// Формула Levine Topfinder/Bottomfinder:
//   На каждом баре t от старта:
//     cum_vol(t) = сумма объёмов от старта до t
//     cum_pv(t)  = сумма (price × volume) от старта до t
//     base_vwap  = cum_pv / cum_vol  (обычный VWAP от якоря)
//
//   Attractor(t) = base_vwap(t) + D_price × sqrt(1 - cum_vol(t) / D_vol)
//
//   где D_price = цена в точке старта - base_vwap в точке старта
//       D_vol   = суммарный объём всего движения (параметр D)
//
//   При cum_vol → D_vol:  sqrt(1 - cum_vol/D_vol) → 0
//   Кривая "схлопывается" к VWAP — это и есть точка притяжения (цель)
//
// D_vol автоматически = накопленный объём от старта до последней ЗАКРЫТОЙ свечи
// (можно переключить на ручной режим для точной подгонки под пивоты истории)
// =============================================================================

//@version=5
indicator(
     title            = "Аттрактор (MIDAS Topfinder/Bottomfinder)",
     shorttitle       = "Attractor",
     overlay          = true,
     max_lines_count  = 500,
     max_labels_count = 50
     )

// ─────────────────────────────────────────────────────────────────────────────
// ВХОДНЫЕ ПАРАМЕТРЫ
// ─────────────────────────────────────────────────────────────────────────────

var string GRP_ANCHOR = "📍 Точка старта (Anchor)"

anchor_type = input.string(
     defval  = "Дата/Время",
     title   = "Способ задания старта",
     options = ["Дата/Время", "Баров назад"],
     group   = GRP_ANCHOR)

anchor_time = input.time(
     defval  = timestamp("2024-01-01 00:00"),
     title   = "Дата и время старта",
     group   = GRP_ANCHOR)

anchor_bars_back = input.int(
     defval  = 50, minval = 1, maxval = 5000,
     title   = "Баров назад от текущего",
     group   = GRP_ANCHOR)

var string GRP_TBF = "⚙️ Параметры аттрактора"

direction = input.string(
     defval  = "Вверх (Bottomfinder)",
     title   = "Направление движения",
     options = ["Вверх (Bottomfinder)", "Вниз (Topfinder)"],
     tooltip = "Bottomfinder — цель лонга (кривая выше цены).\nTopfinder — цель шорта (кривая ниже цены).",
     group   = GRP_TBF)

d_mode = input.string(
     defval  = "Авто (объём до последней свечи)",
     title   = "Режим параметра D (объём)",
     options = ["Авто (объём до последней свечи)", "Ручной (подгонка под пивоты)"],
     tooltip = "Авто: D = накопленный объём от старта до предпоследнего бара.\nРучной: задайте D вручную для точного попадания в исторические пивоты.",
     group   = GRP_TBF)

d_manual = input.float(
     defval  = 1.0, minval = 0.001, maxval = 100000.0, step = 0.1,
     title   = "D вручную (млн единиц объёма)",
     tooltip = "Активно только в ручном режиме. Подбирайте так, чтобы кривая касалась известных разворотов на истории.",
     group   = GRP_TBF)

smooth_len = input.int(
     defval  = 3, minval = 1, maxval = 20,
     title   = "Сглаживание кривой (1 = без сглаживания)",
     group   = GRP_TBF)

price_src = input.source(
     defval  = hlc3,
     title   = "Источник цены",
     group   = GRP_TBF)

var string GRP_SIGMA = "📊 Полосы отклонения (Sigma)"

show_sigma1 = input.bool(defval = true,  title = "Показать ±1σ", group = GRP_SIGMA)
show_sigma2 = input.bool(defval = true,  title = "Показать ±2σ", group = GRP_SIGMA)
show_sigma3 = input.bool(defval = false, title = "Показать ±3σ", group = GRP_SIGMA)
fill_bands  = input.bool(defval = true,  title = "Заливка между полосами", group = GRP_SIGMA)

var string GRP_STYLE = "🎨 Стиль"

color_up          = input.color(defval = color.new(#2196F3, 0),  title = "Цвет (рост / Bottomfinder)", group = GRP_STYLE)
color_dn          = input.color(defval = color.new(#FF5252, 0),  title = "Цвет (падение / Topfinder)",  group = GRP_STYLE)
line_width        = input.int(defval = 2, minval = 1, maxval = 4, title = "Толщина линии", group = GRP_STYLE)
show_label        = input.bool(defval = true, title = "Метка на конце кривой", group = GRP_STYLE)
show_anchor_label = input.bool(defval = true, title = "Метка точки старта",    group = GRP_STYLE)

// ─────────────────────────────────────────────────────────────────────────────
// ТОЧКА СТАРТА
// ─────────────────────────────────────────────────────────────────────────────

var int anchor_bar_fixed = na
if anchor_type == "Дата/Время"
    if time >= anchor_time and na(anchor_bar_fixed)
        anchor_bar_fixed := bar_index

int anchor_bar = anchor_type == "Дата/Время" ? anchor_bar_fixed : bar_index - anchor_bars_back

// ─────────────────────────────────────────────────────────────────────────────
// ПЕРВЫЙ ПРОХОД: накапливаем объём и VWAP от якоря
// ─────────────────────────────────────────────────────────────────────────────

var float cum_pv  = 0.0
var float cum_vol = 0.0
var float cum_pv2 = 0.0
var float anchor_price = na   // цена в точке старта

var int prev_anchor = na
if anchor_bar != prev_anchor
    cum_pv      := 0.0
    cum_vol     := 0.0
    cum_pv2     := 0.0
    anchor_price := na
    prev_anchor := anchor_bar

bool is_active = bar_index >= anchor_bar and not na(anchor_bar)

if is_active
    // Запоминаем цену якоря
    if bar_index == anchor_bar
        anchor_price := price_src

    cum_pv  += price_src * volume
    cum_vol += volume
    cum_pv2 += price_src * price_src * volume

// ─────────────────────────────────────────────────────────────────────────────
// ПАРАМЕТР D
// ─────────────────────────────────────────────────────────────────────────────

// В авторежиме: D = объём накопленный до ПРЕДПОСЛЕДНЕЙ свечи (не текущей)
// Это значит кривая всегда немного "впереди" цены — аттрактор виден заранее
float D_vol = na

if d_mode == "Ручной (подгонка под пивоты)"
    D_vol := d_manual * 1000000
else
    // Авто: берём объём предыдущего бара (cum_vol[1])
    // Добавляем небольшой буфер чтобы кривая ещё не закончилась
    if is_active and cum_vol > 0
        D_vol := cum_vol[1] * 1.15   // 15% запас — кривая всегда немного "впереди"

// ─────────────────────────────────────────────────────────────────────────────
// ОСНОВНАЯ ФОРМУЛА LEVINE TOPFINDER/BOTTOMFINDER
//
//   attractor(t) = vwap(t) + (anchor_price - vwap_anchor) × sqrt(1 - V(t)/D)
//
//   Логика: в точке старта кривая = anchor_price
//           по мере накопления объёма sqrt() → 0
//           кривая сходится к VWAP — это и есть "цель притяжения"
// ─────────────────────────────────────────────────────────────────────────────

float base_vwap   = is_active and cum_vol > 0 ? cum_pv / cum_vol : na
float tf_value    = na
float sigma       = na

bool  is_up       = direction == "Вверх (Bottomfinder)"

if is_active and not na(base_vwap) and not na(D_vol) and D_vol > 0
    float vol_ratio = math.max(0.0, math.min(1.0, cum_vol / D_vol))
    float sqrt_term = math.sqrt(1.0 - vol_ratio)

    // Амплитуда — расстояние от VWAP до экстремума движения
    // Для Bottomfinder кривая идёт ВЫШЕ цены, для Topfinder — НИЖЕ
    float amp = na
    if not na(anchor_price) and not na(base_vwap)
        // Базовая амплитуда от якоря
        float raw_amp = math.abs(anchor_price - base_vwap)
        // Для bottomfinder используем максимум от якоря, для topfinder — минимум
        float extreme = is_up ? ta.highest(price_src, math.max(1, bar_index - anchor_bar + 1))
                               : ta.lowest(price_src, math.max(1, bar_index - anchor_bar + 1))
        amp := math.abs(extreme - base_vwap) * 1.1  // небольшой буфер чтобы кривая была выше экстремумов

    if not na(amp)
        float offset = amp * sqrt_term
        tf_value := is_up ? base_vwap + offset : base_vwap - offset

    // Sigma: стандартное отклонение цены от VWAP
    if cum_vol > 0
        float variance = (cum_pv2 / cum_vol) - (base_vwap * base_vwap)
        sigma := math.sqrt(math.max(variance, 0.0))

// ─────────────────────────────────────────────────────────────────────────────
// СГЛАЖИВАНИЕ (EMA)
// ─────────────────────────────────────────────────────────────────────────────

float tf_smooth = smooth_len > 1 ? ta.ema(tf_value, smooth_len) : tf_value
float sigma_s   = smooth_len > 1 ? ta.ema(sigma,    smooth_len) : sigma

// ─────────────────────────────────────────────────────────────────────────────
// ЦВЕТА
// ─────────────────────────────────────────────────────────────────────────────

color c_main = is_up ? color_up : color_dn
color c_s1   = color.new(c_main, 55)
color c_s2   = color.new(c_main, 70)
color c_s3   = color.new(c_main, 82)

// ─────────────────────────────────────────────────────────────────────────────
// ПОЛОСЫ SIGMA (от сглаженной кривой)
// ─────────────────────────────────────────────────────────────────────────────

float s1_upper = tf_smooth + 1 * sigma_s
float s1_lower = tf_smooth - 1 * sigma_s
float s2_upper = tf_smooth + 2 * sigma_s
float s2_lower = tf_smooth - 2 * sigma_s
float s3_upper = tf_smooth + 3 * sigma_s
float s3_lower = tf_smooth - 3 * sigma_s

// ─────────────────────────────────────────────────────────────────────────────
// ОТРИСОВКА — все plot/fill в глобальном скоупе
// ─────────────────────────────────────────────────────────────────────────────

p_main = plot(tf_smooth,                   title = "Аттрактор",  color = c_main, linewidth = line_width)
p_vwap = plot(is_active ? base_vwap : na,  title = "Base VWAP",  color = color.new(c_main, 75), linewidth = 1, style = plot.style_line)

p_s1u  = plot(show_sigma1 ? s1_upper : na, title = "+1σ", color = c_s1, linewidth = 1)
p_s1l  = plot(show_sigma1 ? s1_lower : na, title = "-1σ", color = c_s1, linewidth = 1)
p_s2u  = plot(show_sigma2 ? s2_upper : na, title = "+2σ", color = c_s2, linewidth = 1)
p_s2l  = plot(show_sigma2 ? s2_lower : na, title = "-2σ", color = c_s2, linewidth = 1)
p_s3u  = plot(show_sigma3 ? s3_upper : na, title = "+3σ", color = c_s3, linewidth = 1)
p_s3l  = plot(show_sigma3 ? s3_lower : na, title = "-3σ", color = c_s3, linewidth = 1)

// Заливки — условный цвет вместо if-блоков (fill нельзя в local scope)
color fill_s1 = fill_bands and show_sigma1 ? color.new(c_main, 90) : color.new(color.black, 100)
color fill_s2 = fill_bands and show_sigma2 ? color.new(c_main, 94) : color.new(color.black, 100)
color fill_s3 = fill_bands and show_sigma3 ? color.new(c_main, 97) : color.new(color.black, 100)

fill(p_main, p_s1u, color = fill_s1, title = "Заливка +1σ")
fill(p_main, p_s1l, color = fill_s1, title = "Заливка -1σ")
fill(p_s1u,  p_s2u, color = fill_s2, title = "Заливка +2σ")
fill(p_s1l,  p_s2l, color = fill_s2, title = "Заливка -2σ")
fill(p_s2u,  p_s3u, color = fill_s3, title = "Заливка +3σ")
fill(p_s2l,  p_s3l, color = fill_s3, title = "Заливка -3σ")

// ─────────────────────────────────────────────────────────────────────────────
// МЕТКИ
// ─────────────────────────────────────────────────────────────────────────────

if show_anchor_label and bar_index == anchor_bar and not na(anchor_bar)
    label.new(
         x = bar_index, y = price_src,
         text = "▶ Старт", color = c_main,
         textcolor = color.white, style = label.style_label_right, size = size.small)

var label end_label = na
if is_active and barstate.islast and not na(tf_smooth)
    label.delete(end_label)
    string d_info = d_mode == "Авто (объём до последней свечи)"
         ? "Авто D"
         : "D=" + str.tostring(d_manual, "#.##") + "M"
    end_label := label.new(
         x = bar_index, y = tf_smooth,
         text = "🎯 " + str.tostring(tf_smooth, format.mintick) + "\n" + d_info,
         color = c_main, textcolor = color.white,
         style = label.style_label_left, size = size.small)

// ─────────────────────────────────────────────────────────────────────────────
// ИНФОРМАЦИОННАЯ ТАБЛИЦА
// ─────────────────────────────────────────────────────────────────────────────

var table info_table = table.new(
     position = position.bottom_right, columns = 2, rows = 5,
     bgcolor  = color.new(color.black, 75),
     border_width = 1, border_color = color.new(color.gray, 60))

if barstate.islast
    string dir_text = is_up ? "Bottomfinder" : "Topfinder"
    float  pct_done = not na(D_vol) and D_vol > 0 ? math.min(cum_vol / D_vol * 100, 100) : 0.0
    string tgt_text = not na(tf_smooth) ? str.tostring(tf_smooth, format.mintick) : "-"
    string d_text   = not na(D_vol)     ? str.tostring(math.round(D_vol / 1000000, 2)) + "M" : "-"

    table.cell(info_table, 0, 0, "ATTRACTOR",   bgcolor = color.new(c_main, 50), text_color = color.white, text_size = size.small)
    table.cell(info_table, 1, 0, dir_text,       bgcolor = color.new(c_main, 50), text_color = color.white, text_size = size.small)
    table.cell(info_table, 0, 1, "Target",       text_color = color.gray,   text_size = size.tiny)
    table.cell(info_table, 1, 1, tgt_text,       text_color = color.yellow, text_size = size.tiny)
    table.cell(info_table, 0, 2, "D filled",     text_color = color.gray,   text_size = size.tiny)
    table.cell(info_table, 1, 2, str.tostring(math.round(pct_done, 1)) + "%", text_color = color.white, text_size = size.tiny)
    table.cell(info_table, 0, 3, "D volume",     text_color = color.gray,   text_size = size.tiny)
    table.cell(info_table, 1, 3, d_text,         text_color = color.white,  text_size = size.tiny)
    table.cell(info_table, 0, 4, "Base VWAP",    text_color = color.gray,   text_size = size.tiny)
    table.cell(info_table, 1, 4, not na(base_vwap) ? str.tostring(base_vwap, format.mintick) : "-", text_color = color.white, text_size = size.tiny)
````
