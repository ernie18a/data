# Lineas de Tendencia Pro

- url: https://www.tradingview.com/script/D69SLyle/
- type: indicator
- pine_id: PUB;e1943d2071d847a7abc13635d33c2c20
- version: 1.0

## Description

.Múltiples líneas — traza hasta 5 líneas históricas de tendencia
Probabilidad mejorada — calcula el % basándose en toques, ángulo y longitud de la línea
Color por probabilidad — línea más gruesa e intensa cuando la probabilidad es mayor al 70%
Señales BUY/SELL — cuando el precio toca la línea con volumen fuerte
Volumen como confirmación — evita señales falsas sin volumen

## Source Code

````pine
//@version=5
indicator("Lineas de Tendencia Pro", overlay=true, max_lines_count=100, max_labels_count=100)

//─── INPUTS ───────────────────────────────────────────────────────────────────
swing_len  = input.int(10,    "Fuerza del swing",              step=1)
min_toques = input.int(2,     "Minimo de toques para validar", step=1)
tolerance  = input.float(0.3, "Tolerancia de toque %",         step=0.1)
max_lines  = input.int(5,     "Numero de lineas a mostrar",    step=1)
vol_period = input.int(20,    "Periodo media volumen")
vol_mult   = input.float(1.5, "Volumen minimo confirmacion",   step=0.1)

//─── DETECCION DE SWINGS ──────────────────────────────────────────────────────
ph = ta.pivothigh(high, swing_len, swing_len)
pl = ta.pivotlow(low,   swing_len, swing_len)

var float[] high_vals = array.new_float()
var int[]   high_bars = array.new_int()
var float[] low_vals  = array.new_float()
var int[]   low_bars  = array.new_int()

if not na(ph)
    array.push(high_vals, ph)
    array.push(high_bars, bar_index[swing_len])
    if array.size(high_vals) > max_lines + 1
        array.shift(high_vals)
        array.shift(high_bars)

if not na(pl)
    array.push(low_vals, pl)
    array.push(low_bars, bar_index[swing_len])
    if array.size(low_vals) > max_lines + 1
        array.shift(low_vals)
        array.shift(low_bars)

//─── VOLUMEN ──────────────────────────────────────────────────────────────────
vol_avg    = ta.sma(volume, vol_period)
strong_vol = volume > vol_avg * vol_mult

//─── CONTAR TOQUES ────────────────────────────────────────────────────────────
count_touches(float y1, float y2, int x1, int x2) =>
    int   count = 0
    float slope = (y2 - y1) / (x2 - x1)
    for i = 0 to 200
        int   bx     = bar_index - i
        float line_y = y2 + slope * (bx - x2)
        float tol    = line_y * tolerance / 100
        bool  touch  = math.abs(high[i] - line_y) < tol or math.abs(low[i] - line_y) < tol
        if touch
            count += 1
    count

//─── PROBABILIDAD MEJORADA ───────────────────────────────────────────────────
get_probability(int touches, float slope_pct, float line_len) =>
    // Factor toques — mas toques mas fiable
    int touch_score = math.min(touches * 15, 50)
    // Factor angulo — angulos moderados mas fiables
    int angle_score = math.abs(slope_pct) < 1.0 ? 20 : math.abs(slope_pct) < 2.0 ? 10 : 0
    // Factor longitud — lineas mas largas mas fiables
    int len_score   = line_len > 50 ? 20 : line_len > 20 ? 10 : 5
    math.min(95, touch_score + angle_score + len_score)

//─── PRECIO CERCA DE LINEA ────────────────────────────────────────────────────
near_line(float y1, float y2, int x1, int x2) =>
    float slope  = (y2 - y1) / (x2 - x1)
    float line_y = y2 + slope * (bar_index - x2)
    float tol    = line_y * tolerance / 100
    math.abs(close - line_y) < tol

//─── DIBUJAR LINEAS ───────────────────────────────────────────────────────────
var bool buy_signal  = false
var bool sell_signal = false

buy_signal  := false
sell_signal := false

if barstate.islast

    // Lineas bajistas — maximos decrecientes
    if array.size(high_vals) >= 2
        for j = array.size(high_vals) - 1 to 1
            float y1 = array.get(high_vals, j - 1)
            float y2 = array.get(high_vals, j)
            int   x1 = array.get(high_bars, j - 1)
            int   x2 = array.get(high_bars, j)

            if y2 < y1 and x2 > x1
                int   touches   = count_touches(y1, y2, x1, x2)
                float slope_pct = (y2 - y1) / y1 * 100
                float line_len  = x2 - x1
                int   prob      = get_probability(touches, slope_pct, line_len)
                float end_y     = y2 + (y2 - y1) / (x2 - x1) * (bar_index + 30 - x2)

                if touches >= min_toques
                    // Color segun probabilidad
                    color lc = prob >= 70 ? color.new(color.red, 0) :
                               prob >= 50 ? color.new(color.orange, 0) :
                               color.new(color.red, 50)
                    int lw = prob >= 70 ? 2 : 1

                    line.new(x1, y1, bar_index + 30, end_y,
                         color = lc, width = lw, style = line.style_solid)

                    label.new(x2, y2,
                         text      = "BAJISTA\n" + str.tostring(prob) + "% rebote\n" + str.tostring(touches) + " toques",
                         color     = color.new(color.red, 20),
                         textcolor = color.white,
                         style     = label.style_label_left,
                         size      = size.small)

    // Lineas alcistas — minimos crecientes
    if array.size(low_vals) >= 2
        for j = array.size(low_vals) - 1 to 1
            float y1 = array.get(low_vals, j - 1)
            float y2 = array.get(low_vals, j)
            int   x1 = array.get(low_bars, j - 1)
            int   x2 = array.get(low_bars, j)

            if y2 > y1 and x2 > x1
                int   touches   = count_touches(y1, y2, x1, x2)
                float slope_pct = (y2 - y1) / y1 * 100
                float line_len  = x2 - x1
                int   prob      = get_probability(touches, slope_pct, line_len)
                float end_y     = y2 + (y2 - y1) / (x2 - x1) * (bar_index + 30 - x2)

                if touches >= min_toques
                    color lc = prob >= 70 ? color.new(color.green, 0) :
                               prob >= 50 ? color.new(color.lime,  0) :
                               color.new(color.green, 50)
                    int lw = prob >= 70 ? 2 : 1

                    line.new(x1, y1, bar_index + 30, end_y,
                         color = lc, width = lw, style = line.style_solid)

                    label.new(x2, y2,
                         text      = "ALCISTA\n" + str.tostring(prob) + "% rebote\n" + str.tostring(touches) + " toques",
                         color     = color.new(color.green, 20),
                         textcolor = color.white,
                         style     = label.style_label_left,
                         size      = size.small)

//─── SEÑALES CUANDO TOCA LA LINEA ────────────────────────────────────────────
if array.size(low_vals) >= 2
    int   sz = array.size(low_vals)
    float y1 = array.get(low_vals, sz - 2)
    float y2 = array.get(low_vals, sz - 1)
    int   x1 = array.get(low_bars, sz - 2)
    int   x2 = array.get(low_bars, sz - 1)
    if y2 > y1 and x2 > x1 and near_line(y1, y2, x1, x2) and strong_vol and close > open
        buy_signal := true

if array.size(high_vals) >= 2
    int   sz = array.size(high_vals)
    float y1 = array.get(high_vals, sz - 2)
    float y2 = array.get(high_vals, sz - 1)
    int   x1 = array.get(high_bars, sz - 2)
    int   x2 = array.get(high_bars, sz - 1)
    if y2 < y1 and x2 > x1 and near_line(y1, y2, x1, x2) and strong_vol and close < open
        sell_signal := true

//─── SEÑALES EN GRAFICO ───────────────────────────────────────────────────────
plotshape(buy_signal,
     title     = "BUY",
     style     = shape.labelup,
     location  = location.belowbar,
     color     = color.new(color.green, 0),
     text      = "BUY",
     textcolor = color.white,
     size      = size.large)

plotshape(sell_signal,
     title     = "SELL",
     style     = shape.labeldown,
     location  = location.abovebar,
     color     = color.new(color.red, 0),
     text      = "SELL",
     textcolor = color.white,
     size      = size.large)

barcolor(buy_signal  ? color.new(color.green, 0) :
         sell_signal ? color.new(color.red,   0) : na)

//─── ALERTAS ─────────────────────────────────────────────────────────────────
alertcondition(buy_signal,  title="BUY Tendencia", message="Precio rebotando en linea de tendencia alcista")
alertcondition(sell_signal, title="SELL Tendencia", message="Precio rebotando en linea de tendencia bajista")
alertcondition(buy_signal or sell_signal, title="Senal Tendencia", message="Senal de entrada en linea de tendencia")
````
