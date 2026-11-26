# Launchpad Screener Dinho

- url: https://www.tradingview.com/script/94yFEp7u-Launchpad-Screener-Dinho/
- type: indicator
- pine_id: PUB;865a18c287b04ac5b6416071ab0ddd34
- version: 2.0

## Description

Launchpad for stocks
 try  try  try  try  try try try try try try try try try try try try try try try try try try try try try try try try try try try try try try try try try try


Launchpad for stocks
 try  try  try  try  try try try try try try try try try try try try try try try try try try try try try try try try try try try try try try try try try try

Launchpad for stocks
 try  try  try  try  try try try try try try try try try try try try try try try try try try try try try try try try try try try try try try try try try try

Launchpad for stocks
 try  try  try  try  try try try try try try try try try try try try try try try try try try try try try try try try try try try try try try try try try try

Launchpad for stocks
 try  try  try  try  try try try try try try try try try try try try try try try try try try try try try try try try try try try try try try try try try try

Launchpad for stocks
 try  try  try  try  try try try try try try try try try try try try try try try try try try try try try try try try try try try try try try try try try try

## Source Code

````pine
// © Paulo — Constanza & Lucas Portfolio
// LAUNCHPAD PATTERN INDICATOR v2.8

//@version=5
indicator(
     title            = "🚀 Launchpad Pattern v2",
     shorttitle       = "LAUNCHPAD",
     overlay          = true,
     max_labels_count = 200,
     max_lines_count  = 200
 )

// ─── INPUTS ───
grp1 = "── Medias Móviles ──"
ma_compression_pct = input.float(5.0,  "Compresión máxima MA (%)",       minval=1.0, maxval=15.0, step=0.5,  group=grp1)
price_vs_ma_pct    = input.float(6.0,  "Precio vs MA promedio (%)",      minval=1.0, maxval=15.0, step=0.5,  group=grp1)
slope_threshold    = input.float(0.50, "Flatness threshold MA10/21 (%)", minval=0.1, maxval=2.0,  step=0.05, group=grp1)
flat_threshold_50  = input.float(0.50, "Flatness threshold MA50 (%)",    minval=0.1, maxval=2.0,  step=0.05, group=grp1)

grp2 = "── Activación ──"
vol_activation_mult = input.float(1.2, "Vol activación: múltiplo MA20",  minval=0.5, maxval=4.0, step=0.1, group=grp2)
min_lp_days         = input.int(10,    "Días mínimos en compresión",     minval=3,   maxval=30,            group=grp2)

grp3 = "── Precio / ATR ──"
price_range_days    = input.int(20,     "Rango de precio: días",         minval=10,  maxval=40,             group=grp3)
price_range_pct     = input.float(20.0, "Rango máximo precio (%)",       minval=5.0, maxval=30.0, step=0.5, group=grp3)
atr_roc_period      = input.int(10,     "ROC ATR: período (días)",       minval=5,   maxval=30,             group=grp3)

grp4 = "── Score ──"
min_score           = input.float(40.0, "Score mínimo (0-100)",          minval=20.0, maxval=80.0, step=5.0, group=grp4)

grp5 = "── Visualización ──"
show_mas            = input.bool(true,  "Mostrar MA10 / MA21 / MA50",    group=grp5)
show_ma200          = input.bool(false, "Mostrar MA200",                 group=grp5)
show_compression    = input.bool(true,  "Mostrar banda de compresión",   group=grp5)
show_score          = input.bool(true,  "Mostrar score en label",        group=grp5)

// ─── MEDIAS ───
ma10  = ta.sma(close, 10)
ma21  = ta.sma(close, 21)
ma50  = ta.sma(close, 50)
ma200 = ta.sma(close, 200)

flat10         = ta.stdev(ma10, 10) / ta.sma(ma10, 10) * 100
flat21         = ta.stdev(ma21, 10) / ta.sma(ma21, 10) * 100
avg_flat_short = (flat10 + flat21) / 2
flat50         = ta.stdev(ma50, 21) / ta.sma(ma50, 21) * 100

ma_max       = math.max(ma10, ma21, ma50)
ma_min       = math.min(ma10, ma21, ma50)
ma_avg       = (ma10 + ma21 + ma50) / 3
ma_range_pct = (ma_max - ma_min) / close * 100
price_vs_ma  = math.abs(close - ma_avg) / close * 100

// ─── VOLUMEN ───
vol_ma20  = ta.sma(volume, 20)
vol_below = volume < vol_ma20
vol_ratio = volume / vol_ma20

// ─── PRECIO / ATR ───
highest_n              = ta.highest(close, price_range_days)
lowest_n               = ta.lowest(close,  price_range_days)
price_range_actual_pct = (highest_n - lowest_n) / ta.sma(close, price_range_days) * 100

atr14       = ta.atr(14)
atr_roc     = (atr14 - atr14[atr_roc_period]) / atr14[atr_roc_period] * 100
atr_falling = atr_roc < 0

// ─── SCORING ───
score_compression = math.max(0.0, 30.0 * (1.0 - ma_range_pct   / ma_compression_pct))
score_proximity   = math.max(0.0, 10.0 * (1.0 - price_vs_ma    / price_vs_ma_pct))
score_flat_short  = math.max(0.0, 10.0 * (1.0 - avg_flat_short / slope_threshold))
score_flat_50     = math.max(0.0, 10.0 * (1.0 - flat50         / flat_threshold_50))
score_vol         = vol_below ? 25.0 : math.max(0.0, 25.0 * (1.0 - (vol_ratio - 1.0) / 0.5))
score_atr         = atr_falling ? 15.0 : math.max(0.0, 15.0 * (1.0 + atr_roc / 20.0))

total_score = score_compression + score_proximity + score_flat_short + score_flat_50 + score_vol + score_atr

// ─── CONDICIONES ───
cond_compression = ma_range_pct           < ma_compression_pct
cond_proximity   = price_vs_ma            < price_vs_ma_pct
cond_flat_short  = avg_flat_short         < slope_threshold
cond_flat_50     = flat50                 < flat_threshold_50
cond_vol         = vol_below
cond_atr         = atr_falling
cond_range       = price_range_actual_pct < price_range_pct

conditions_met = (cond_compression ? 1 : 0) + (cond_proximity ? 1 : 0) +
                 (cond_flat_short  ? 1 : 0) + (cond_flat_50   ? 1 : 0) +
                 (cond_vol         ? 1 : 0) + (cond_atr        ? 1 : 0)

launchpad_active = conditions_met >= 4 and total_score >= min_score

// ─── DÍAS EN COMPRESIÓN ───
var int lp_days = 0
lp_days := launchpad_active ? lp_days + 1 : 0

// ─── ACTIVACIÓN ───
// Clave: usamos [1] en todo — valores del día ANTERIOR
// Así capturamos breakouts explosivos donde launchpad_active
// se apaga el mismo día que rompe
breakout_band = close > ma_max[1]
breakout_vol  = volume >= vol_ma20[1] * vol_activation_mult
activation    = lp_days[1] >= min_lp_days and breakout_band and breakout_vol

// ─── COLORES ───
COLOR_GOLD  = color.new(#FFB800, 0)
COLOR_GREEN = color.new(#00C853, 0)
COLOR_WHITE = color.new(#FFFFFF, 0)
COLOR_GRAY  = color.new(#888888, 0)

score_color = total_score >= 70 ? COLOR_GREEN :
              total_score >= 40 ? COLOR_GOLD  : COLOR_GRAY

ma_alpha = cond_compression ? 0 : 50
col_ma10 = color.new(#FF6B35, ma_alpha)
col_ma21 = color.new(#1565C0, ma_alpha)
col_ma50 = color.new(#FF1744, ma_alpha)

// ─── PLOTS MEDIAS ───
plot(show_mas   ? ma10  : na, "MA10",  color=col_ma10, linewidth=2)
plot(show_mas   ? ma21  : na, "MA21",  color=col_ma21, linewidth=2)
plot(show_mas   ? ma50  : na, "MA50",  color=col_ma50, linewidth=2)
plot(show_ma200 ? ma200 : na, "MA200", color=color.new(#555555, 40), linewidth=1)

// ─── BANDA DE COMPRESIÓN ───
band_top    = plot(show_compression ? ma_max : na, "Banda Top",    color=color.new(#FFB800, 100))
band_bottom = plot(show_compression ? ma_min : na, "Banda Bottom", color=color.new(#FFB800, 100))
fill(band_top, band_bottom,
     color = launchpad_active ? color.new(#FFB800, 85) : color.new(#888888, 95))

// ─── BACKGROUND ───
bgcolor(launchpad_active ? color.new(#FFB800, 93) : na)
bgcolor(activation       ? color.new(#00C853, 85) : na)

// ─── LABEL SCORE ───
if launchpad_active and show_score and bar_index % 10 == 0
    label.new(bar_index, ma_max * 1.005,
         text      = "🚀 " + str.tostring(math.round(total_score, 1)),
         color     = color.new(#1A1A2E, 10),
         textcolor = score_color,
         style     = label.style_label_down,
         size      = size.tiny)

// ─── LABEL DÍAS ───
if launchpad_active and bar_index % 5 == 0 and lp_days > 0
    label.new(bar_index, ma_min * 0.995,
         text      = str.tostring(lp_days) + "d",
         color     = color.new(#1A1A2E, 80),
         textcolor = COLOR_GOLD,
         style     = label.style_label_up,
         size      = size.tiny)

// ─── LABEL ACTIVACIÓN ───
if activation
    label.new(bar_index, low * 0.995,
         text      = "🔥 LAUNCHPAD\nActivado",
         color     = COLOR_GREEN,
         textcolor = COLOR_WHITE,
         style     = label.style_label_up,
         size      = size.normal)

// ─── SHAPES ───
plotshape(launchpad_active and not launchpad_active[1],
     style    = shape.diamond,
     location = location.belowbar,
     color    = COLOR_GOLD,
     size     = size.small,
     text     = "LP")

plotshape(activation,
     style    = shape.triangleup,
     location = location.belowbar,
     color    = COLOR_GREEN,
     size     = size.large)

// ─── TABLE ───
var table st = table.new(
     position.top_right, 2, 11,
     bgcolor      = color.new(#1A1A2E, 10),
     border_width = 1,
     border_color = color.new(#FFB800, 40),
     frame_width  = 2,
     frame_color  = color.new(#FFB800, 0))

f_ok(cond)  => cond ? color.new(#00C853, 20) : color.new(#FF1744, 20)
f_txt(cond) => cond ? "✓" : "✗"

if barstate.islast
    table.cell(st, 0, 0, "🚀 LAUNCHPAD",
         text_color=COLOR_GOLD, text_size=size.small, bgcolor=color.new(#1A1A2E,0))
    table.cell(st, 1, 0,
         launchpad_active ? "ACTIVO" : "INACTIVO",
         text_color = launchpad_active ? COLOR_GREEN : COLOR_GRAY,
         text_size=size.small, bgcolor=color.new(#1A1A2E,0))

    table.cell(st, 0, 1, "Score",
         text_color=COLOR_GRAY, text_size=size.tiny, bgcolor=color.new(#0D0D1E,0))
    table.cell(st, 1, 1, str.tostring(math.round(total_score,1)) + " / 100",
         text_color=score_color, text_size=size.tiny, bgcolor=color.new(#0D0D1E,0))

    table.cell(st, 0, 2, "Días compresión",
         text_color=COLOR_GRAY, text_size=size.tiny, bgcolor=color.new(#0D0D1E,0))
    table.cell(st, 1, 2, str.tostring(lp_days) + " / " + str.tostring(min_lp_days) + " mín",
         text_color = lp_days >= min_lp_days ? COLOR_GREEN : COLOR_GOLD,
         text_size=size.tiny, bgcolor=color.new(#0D0D1E,0))

    table.cell(st, 0, 3, "Compres. MA",
         text_color=COLOR_GRAY, text_size=size.tiny, bgcolor=f_ok(cond_compression))
    table.cell(st, 1, 3, f_txt(cond_compression) + " " + str.tostring(math.round(ma_range_pct,2)) + "%",
         text_color=COLOR_WHITE, text_size=size.tiny, bgcolor=f_ok(cond_compression))

    table.cell(st, 0, 4, "Precio vs MA",
         text_color=COLOR_GRAY, text_size=size.tiny, bgcolor=f_ok(cond_proximity))
    table.cell(st, 1, 4, f_txt(cond_proximity) + " " + str.tostring(math.round(price_vs_ma,2)) + "%",
         text_color=COLOR_WHITE, text_size=size.tiny, bgcolor=f_ok(cond_proximity))

    table.cell(st, 0, 5, "Flat MA10/21",
         text_color=COLOR_GRAY, text_size=size.tiny, bgcolor=f_ok(cond_flat_short))
    table.cell(st, 1, 5, f_txt(cond_flat_short) + " " + str.tostring(math.round(avg_flat_short,3)) + "%",
         text_color=COLOR_WHITE, text_size=size.tiny, bgcolor=f_ok(cond_flat_short))

    table.cell(st, 0, 6, "Flat MA50",
         text_color=COLOR_GRAY, text_size=size.tiny, bgcolor=f_ok(cond_flat_50))
    table.cell(st, 1, 6, f_txt(cond_flat_50) + " " + str.tostring(math.round(flat50,3)) + "%",
         text_color=COLOR_WHITE, text_size=size.tiny, bgcolor=f_ok(cond_flat_50))

    table.cell(st, 0, 7, "Vol < MA20",
         text_color=COLOR_GRAY, text_size=size.tiny, bgcolor=f_ok(cond_vol))
    table.cell(st, 1, 7, f_txt(cond_vol) + " " + str.tostring(math.round(vol_ratio,2)) + "x",
         text_color=COLOR_WHITE, text_size=size.tiny, bgcolor=f_ok(cond_vol))

    table.cell(st, 0, 8, "ROC ATR",
         text_color=COLOR_GRAY, text_size=size.tiny, bgcolor=f_ok(cond_atr))
    table.cell(st, 1, 8, f_txt(cond_atr) + " " + str.tostring(math.round(atr_roc,1)) + "%",
         text_color=COLOR_WHITE, text_size=size.tiny, bgcolor=f_ok(cond_atr))

    table.cell(st, 0, 9, "Rango 20d",
         text_color=COLOR_GRAY, text_size=size.tiny, bgcolor=f_ok(cond_range))
    table.cell(st, 1, 9, f_txt(cond_range) + " " + str.tostring(math.round(price_range_actual_pct,1)) + "%",
         text_color=COLOR_WHITE, text_size=size.tiny, bgcolor=f_ok(cond_range))

    table.cell(st, 0, 10, "Activación",
         text_color=COLOR_GRAY, text_size=size.tiny, bgcolor=color.new(#0D0D1E,0))
    table.cell(st, 1, 10,
         activation ? "🔥 SÍ" : "—",
         text_color = activation ? COLOR_GREEN : COLOR_GRAY,
         text_size=size.tiny, bgcolor=color.new(#0D0D1E,0))

// ─── ALERTS ───
alertcondition(launchpad_active and not launchpad_active[1],
     "Launchpad detectado",
     "Launchpad activo en este ticker")
alertcondition(activation,
     "Launchpad ACTIVADO",
     "Precio rompe banda de compresion - Launchpad activado")
````
