# (MIDAS Topfinder/Bottomfinder)

- url: https://www.tradingview.com/script/o8x2dHMk-midas-topfinder-bottomfinder/
- type: indicator
- pine_id: PUB;39462b33484b4a97b02d710e7509f38f
- version: 1.0

## Description

Настройки индикатора
Точка старта — два режима:

Дата/Время — выбираешь конкретный момент начала импульса (удобно для истории)
Баров назад — проще для быстрого тестирования

Параметр D — главный параметр подбора. Это целевой суммарный объём движения (в миллионах). Логика подбора:

Увеличь D → кривая тянется дальше вправо
Уменьши D → кривая заканчивается раньше
Правильное D: кривая должна касаться известных пивотов/разворотов на истории — тогда следующее касание и будет целью

Направление:

Bottomfinder (вверх) — цель лонга, куда идёт цена в росте
Topfinder (вниз) — цель шорта

Sigma-полосы — включаются галочками ±1σ, ±2σ, ±3σ, как в Anchored VWAP

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0
// © Attractor Channel — based on MIDAS Topfinder/Bottomfinder (Paul Levine / Coles & Hawkins)
// =============================================================================
// АТТРАКТОР (MIDAS Topfinder/Bottomfinder)
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
     group   = GRP_ANCHOR
     )

anchor_time = input.time(
     defval  = timestamp("2024-01-01 00:00"),
     title   = "Дата и время старта",
     group   = GRP_ANCHOR
     )

anchor_bars_back = input.int(
     defval  = 50,
     minval  = 1,
     maxval  = 5000,
     title   = "Баров назад от текущего",
     group   = GRP_ANCHOR
     )

var string GRP_TBF = "⚙️ Параметры Topfinder/Bottomfinder"

d_mult = input.float(
     defval  = 1.0,
     minval  = 0.01,
     maxval  = 10000.0,
     step    = 0.05,
     title   = "Параметр D (множитель объёма × 10^6)",
     tooltip = "D — целевой суммарный объём движения. Подбирайте вручную:\n• Увеличьте D → кривая тянется дальше\n• Уменьшите D → кривая завершается раньше",
     group   = GRP_TBF
     )

direction = input.string(
     defval  = "Вверх (Bottomfinder)",
     title   = "Направление движения",
     options = ["Вверх (Bottomfinder)", "Вниз (Topfinder)"],
     tooltip = "Bottomfinder — цель лонга.\nTopfinder — цель шорта.",
     group   = GRP_TBF
     )

price_src = input.source(
     defval  = hlc3,
     title   = "Источник цены",
     group   = GRP_TBF
     )

var string GRP_SIGMA = "📊 Полосы отклонения (Sigma)"

show_sigma1 = input.bool(defval = true,  title = "Показать ±1σ", group = GRP_SIGMA)
show_sigma2 = input.bool(defval = true,  title = "Показать ±2σ", group = GRP_SIGMA)
show_sigma3 = input.bool(defval = false, title = "Показать ±3σ", group = GRP_SIGMA)
fill_bands  = input.bool(defval = true,  title = "Заливка между полосами", group = GRP_SIGMA)

var string GRP_STYLE = "🎨 Стиль"

color_up          = input.color(defval = color.new(#00BCD4, 0), title = "Цвет (рост / Bottomfinder)", group = GRP_STYLE)
color_dn          = input.color(defval = color.new(#FF5252, 0), title = "Цвет (падение / Topfinder)",  group = GRP_STYLE)
line_width        = input.int(defval = 2, minval = 1, maxval = 4, title = "Толщина линии", group = GRP_STYLE)
show_label        = input.bool(defval = true, title = "Метка на конце кривой",  group = GRP_STYLE)
show_anchor_label = input.bool(defval = true, title = "Метка точки старта",     group = GRP_STYLE)

// ─────────────────────────────────────────────────────────────────────────────
// ТОЧКА СТАРТА
// ─────────────────────────────────────────────────────────────────────────────

var int anchor_bar_fixed = na
if anchor_type == "Дата/Время"
    if time >= anchor_time and na(anchor_bar_fixed)
        anchor_bar_fixed := bar_index

int anchor_bar = anchor_type == "Дата/Время" ? anchor_bar_fixed : bar_index - anchor_bars_back

// ─────────────────────────────────────────────────────────────────────────────
// РАСЧЁТ MIDAS TOPFINDER / BOTTOMFINDER
// ─────────────────────────────────────────────────────────────────────────────

// D в единицах объёма (1_000_000 заменено на 1000000 — Pine Script не поддерживает разделители)
float D = d_mult * 1000000

var float cum_pv  = 0.0
var float cum_vol = 0.0
var float cum_pv2 = 0.0

var int prev_anchor = na
if anchor_bar != prev_anchor
    cum_pv      := 0.0
    cum_vol     := 0.0
    cum_pv2     := 0.0
    prev_anchor := anchor_bar

bool is_active   = bar_index >= anchor_bar and not na(anchor_bar)
bool is_complete = cum_vol >= D

float tf_value = na
float sigma    = na

if is_active and not is_complete
    cum_pv  += price_src * volume
    cum_vol += volume
    cum_pv2 += price_src * price_src * volume

    float remaining_vol_ratio = math.max(0.0, 1.0 - cum_vol / D)
    float base_vwap           = cum_pv / cum_vol
    float vwap_deviation      = price_src - base_vwap

    tf_value := base_vwap + vwap_deviation * remaining_vol_ratio

    if cum_vol > 0
        float variance = (cum_pv2 / cum_vol) - (base_vwap * base_vwap)
        sigma          := math.sqrt(math.max(variance, 0.0))

// ─────────────────────────────────────────────────────────────────────────────
// ЦВЕТА
// ─────────────────────────────────────────────────────────────────────────────

bool  is_up  = direction == "Вверх (Bottomfinder)"
color c_main = is_up ? color_up : color_dn
color c_s1   = color.new(c_main, 55)
color c_s2   = color.new(c_main, 70)
color c_s3   = color.new(c_main, 82)
color c_fill = color.new(c_main, 88)

// ─────────────────────────────────────────────────────────────────────────────
// ПОЛОСЫ SIGMA
// ─────────────────────────────────────────────────────────────────────────────

float s1_upper = tf_value + 1 * sigma
float s1_lower = tf_value - 1 * sigma
float s2_upper = tf_value + 2 * sigma
float s2_lower = tf_value - 2 * sigma
float s3_upper = tf_value + 3 * sigma
float s3_lower = tf_value - 3 * sigma

// ─────────────────────────────────────────────────────────────────────────────
// ОТРИСОВКА — plot() всегда в глобальном скоупе
// ─────────────────────────────────────────────────────────────────────────────

p_main = plot(tf_value,                   title = "Аттрактор", color = c_main, linewidth = line_width)
p_s1u  = plot(show_sigma1 ? s1_upper : na, title = "+1σ",      color = c_s1,   linewidth = 1)
p_s1l  = plot(show_sigma1 ? s1_lower : na, title = "-1σ",      color = c_s1,   linewidth = 1)
p_s2u  = plot(show_sigma2 ? s2_upper : na, title = "+2σ",      color = c_s2,   linewidth = 1)
p_s2l  = plot(show_sigma2 ? s2_lower : na, title = "-2σ",      color = c_s2,   linewidth = 1)
p_s3u  = plot(show_sigma3 ? s3_upper : na, title = "+3σ",      color = c_s3,   linewidth = 1)
p_s3l  = plot(show_sigma3 ? s3_lower : na, title = "-3σ",      color = c_s3,   linewidth = 1)

// fill() тоже должен быть в глобальном скоупе — используем условный цвет вместо if-блоков
color fill_s1_color  = fill_bands and show_sigma1 ? c_fill                       : color.new(color.black, 100)
color fill_s2_color  = fill_bands and show_sigma2 ? color.new(c_main, 93)        : color.new(color.black, 100)
color fill_s3_color  = fill_bands and show_sigma3 ? color.new(c_main, 96)        : color.new(color.black, 100)

fill(p_main, p_s1u, color = fill_s1_color, title = "Заливка +1σ")
fill(p_main, p_s1l, color = fill_s1_color, title = "Заливка -1σ")
fill(p_s1u,  p_s2u, color = fill_s2_color, title = "Заливка +2σ")
fill(p_s1l,  p_s2l, color = fill_s2_color, title = "Заливка -2σ")
fill(p_s2u,  p_s3u, color = fill_s3_color, title = "Заливка +3σ")
fill(p_s2l,  p_s3l, color = fill_s3_color, title = "Заливка -3σ")

// ─────────────────────────────────────────────────────────────────────────────
// МЕТКИ
// ─────────────────────────────────────────────────────────────────────────────

if show_anchor_label and bar_index == anchor_bar and not na(anchor_bar)
    label.new(
         x         = bar_index,
         y         = price_src,
         text      = "Start",
         color     = c_main,
         textcolor = color.white,
         style     = label.style_label_right,
         size      = size.small
         )

var label end_label = na
if is_active and not is_complete and barstate.islast
    label.delete(end_label)
    end_label := label.new(
         x         = bar_index,
         y         = tf_value,
         text      = "Target: " + str.tostring(tf_value, format.mintick) + "\nD: " + str.tostring(math.round(cum_vol / 1000000, 2)) + "/" + str.tostring(d_mult, "#.##") + "M",
         color     = c_main,
         textcolor = color.white,
         style     = label.style_label_left,
         size      = size.small
         )

var bool completion_labeled = false
if is_complete and not completion_labeled and show_label
    label.new(
         x         = bar_index,
         y         = tf_value,
         text      = "Attractor reached\n" + str.tostring(tf_value, format.mintick),
         color     = color.new(c_main, 20),
         textcolor = color.white,
         style     = label.style_label_up,
         size      = size.normal
         )
    completion_labeled := true

var line completion_line = na
if is_complete and na(completion_line)
    completion_line := line.new(
         x1    = bar_index,
         y1    = tf_value - sigma * 3,
         x2    = bar_index,
         y2    = tf_value + sigma * 3,
         color = color.new(c_main, 50),
         width = 1,
         style = line.style_dashed
         )

// ─────────────────────────────────────────────────────────────────────────────
// ИНФОРМАЦИОННАЯ ТАБЛИЦА
// ─────────────────────────────────────────────────────────────────────────────

var table info_table = table.new(
     position     = position.bottom_right,
     columns      = 2,
     rows         = 6,
     bgcolor      = color.new(color.black, 75),
     border_width = 1,
     border_color = color.new(color.gray, 60)
     )

if barstate.islast
    string dir_text  = is_up ? "Bottomfinder" : "Topfinder"
    string status    = is_complete ? "Done" : (is_active ? "Active" : "Waiting")
    float  pct_done  = D == 0 ? 0.0 : math.min(cum_vol / D * 100, 100)
    string tgt_text  = not na(tf_value) ? str.tostring(tf_value, format.mintick) : "-"
    string sig_text  = not na(sigma)    ? str.tostring(s1_lower, format.mintick) + " - " + str.tostring(s1_upper, format.mintick) : "-"

    table.cell(info_table, 0, 0, "ATTRACTOR",   bgcolor = color.new(c_main, 60), text_color = color.white, text_size = size.small)
    table.cell(info_table, 1, 0, dir_text,       bgcolor = color.new(c_main, 60), text_color = color.white, text_size = size.small)
    table.cell(info_table, 0, 1, "Status",       text_color = color.gray,   text_size = size.tiny)
    table.cell(info_table, 1, 1, status,         text_color = color.white,  text_size = size.tiny)
    table.cell(info_table, 0, 2, "D filled",     text_color = color.gray,   text_size = size.tiny)
    table.cell(info_table, 1, 2, str.tostring(math.round(pct_done, 1)) + "%", text_color = color.white, text_size = size.tiny)
    table.cell(info_table, 0, 3, "Target",       text_color = color.gray,   text_size = size.tiny)
    table.cell(info_table, 1, 3, tgt_text,       text_color = color.yellow, text_size = size.tiny)
    table.cell(info_table, 0, 4, "1sigma range", text_color = color.gray,   text_size = size.tiny)
    table.cell(info_table, 1, 4, sig_text,        text_color = color.white,  text_size = size.tiny)
    table.cell(info_table, 0, 5, "D param",      text_color = color.gray,   text_size = size.tiny)
    table.cell(info_table, 1, 5, str.tostring(d_mult) + "M", text_color = color.white, text_size = size.tiny)
````
